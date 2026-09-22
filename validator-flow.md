---
layout: page
title: "Validator flow"
permalink: /validator-flow/
---

# Validator Flow

How validators use this API for block proposals, attestations and payload timeliness committee duties.

Monitor [`head_v2` events](#/Events/eventstream) as described by the duty endpoints. When a dependent
root changes, refresh outstanding duties and update subnet subscriptions and proposer preferences.

### Block Proposing

At startup and the start of each epoch, [fetch proposer duties](#/Validator/getProposerDutiesV2)
for the current epoch. From Fulu onwards, also fetch the next epoch's duties.
Each duty contains the proposer's public key and assigned slot.

[Submit signed proposer preferences](#/Validator/submitProposerPreferences) for upcoming Gloas
proposal slots, starting one epoch before the fork.

In the epoch prior to a post-Gloas proposal the validator MAY
[submit builder preferences](#/Validator/submitBuilderPreferences) so builders hold them before the
bid request arrives.

If proposing block, then at immediate start of slot:

1. Ask Beacon Node for BeaconBlock object:
   - Pre-Gloas forks: [produceBlockV3](#/Validator/produceBlockV3)
   - Post-Gloas fork: [produceBlockV4](#/Validator/produceBlockV4)
     - Supply a `BuilderConfig` in the required request body, with the `Eth-Consensus-Version`
       header: the builder entries to solicit builder-API bids, plus the top-level `min_bid` and
       `builder_boost_factor` that apply to p2p bids.
     - `include_payload=true`: returns `BlockContents` (beacon block, execution payload envelope,
       blobs, and KZG proofs). Enables stateless operation (multi-BN setups, distributed validators, failover).
     - `include_payload=false`: returns only the `BeaconBlock`. The beacon node caches the execution payload
       envelope and blobs internally (stateful operation, must publish via the same beacon node).
     - When a bid wins, only the `BeaconBlock` is returned regardless of `include_payload`, and
       `Eth-Builder-Url` names the builder if the bid came through the builder-API channel.
2. Sign the returned block
3. Submit the signed block via [`publishBlindedBlockV2`](#/ValidatorRequiredApi/publishBlindedBlockV2) if blinded,
   otherwise [`publishBlockV2`](#/ValidatorRequiredApi/publishBlockV2). For unblinded Deneb through Fulu blocks,
   use `SignedBlockContents`. Echo the `Eth-Builder-Url` header if one was returned
4. Post-Gloas, if self-building (the bid's `builder_index` is [BUILDER_INDEX_SELF_BUILD](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/beacon-chain.md#misc)):
   - Stateless (`include_payload=true`): envelope and blobs are already available from step 1.
     Sign envelope and [submit `SignedExecutionPayloadEnvelopeContents`](#/Beacon/publishExecutionPayloadEnvelope)
     (envelope + blobs + KZG proofs) with `Eth-Blob-Data-Included: true`.
   - Stateful (`include_payload=false`): [fetch ExecutionPayloadEnvelope](#/Validator/getExecutionPayloadEnvelope)
     from the same beacon node. Sign envelope and [submit `SignedExecutionPayloadEnvelope`](#/Beacon/publishExecutionPayloadEnvelope)
     with `Eth-Blob-Data-Included: false` (beacon node attaches blobs and KZG proofs from its cache).
   - Must submit before [`get_payload_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/fork-choice.md#new-get_payload_due_ms) milliseconds into the slot

5. Post-Gloas, if a bid won (any other `builder_index`): nothing further. The winning builder
   releases the execution payload envelope.

### Attestation

At startup, [fetch attester duties](#/Validator/getAttesterDuties) for the current and next epoch.
At the start of each subsequent epoch, fetch duties for the next epoch.
Each duty identifies the validator, committee and attestation slot.

Attesting:

1. Upon receiving duty, have beacon node prepare committee subnet
    - [Check if aggregator by computing `slot_signature`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/phase0/validator.md#attestation-aggregation)
    - [Ask beacon node to prepare your subnet](#/ValidatorRequiredApi/prepareBeaconCommitteeSubnet)
      - Submit one entry per validator per attestation duty, with `is_aggregator` set to `true`
        for aggregators
2. Wait for a valid beacon block for the assigned slot (either stream updates or poll)
    - Pre-Gloas forks: Max wait [`get_attestation_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/phase0/fork-choice.md#get_attestation_due_ms) milliseconds into the assigned slot
    - Post-Gloas forks: Max wait [`get_attestation_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/fork-choice.md#modified-get_attestation_due_ms) milliseconds into the assigned slot
3. [Fetch AttestationData](#/ValidatorRequiredApi/produceAttestationData)
4. [Submit the signed attestation](#/ValidatorRequiredApi/submitPoolAttestationsV2)
    - Before Electra: use `Attestation`, with the bit at `validator_committee_index` set in `aggregation_bits`
    - From Electra onwards: use `SingleAttestation`
5. If aggregator:
    - Pre-Gloas forks: Wait for [`get_aggregate_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/phase0/fork-choice.md#get_aggregate_due_ms) milliseconds into the assigned slot
    - Post-Gloas forks: Wait for [`get_aggregate_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/fork-choice.md#modified-get_aggregate_due_ms) milliseconds into the assigned slot
    - [Fetch aggregated Attestation](#/ValidatorRequiredApi/getAggregatedAttestationV2) from Beacon Node you've subscribed to your subnet
    - Construct and sign `AggregateAndProof`, then [publish `SignedAggregateAndProof`](#/ValidatorRequiredApi/publishAggregateAndProofsV2)

### PTC Attesting

From Gloas onwards, at startup and the start of each epoch,
[fetch PTC duties](#/Validator/getPtcDuties) for the current and next epoch.
Each duty contains the validator index and assigned slot for payload timeliness committee participation.

PTC Attesting:

1. Wait for the beacon node to receive the payload envelope and confirm blob data availability for the assigned slot
    - Max wait [`get_payload_attestation_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/fork-choice.md#new-get_payload_attestation_due_ms) milliseconds into the assigned slot
2. [Fetch PayloadAttestationData](#/ValidatorRequiredApi/producePayloadAttestationData) for the assigned slot
    - On `204` (no block seen), skip signing and submission
3. Sign `PayloadAttestationData` to create `PayloadAttestationMessage`
4. [Submit PayloadAttestationMessages](#/ValidatorRequiredApi/submitPayloadAttestationMessages)

### Builder (Optional)

Post-Gloas fork, builders are separate non-validating staked actors that submit execution payload bids for block inclusion.
Builders register by depositing with builder-specific withdrawal credentials (`BUILDER_WITHDRAWAL_PREFIX`) and are tracked
in the beacon state's builder registry.

Building:

1. Obtain payload via `engine_getPayload` call to execution client and construct `ExecutionPayloadBid` for the current or next slot's proposer to include.
2. Cache fields required to form an [ExecutionPayloadEnvelope](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/beacon-chain.md#executionpayloadenvelope)
3. Sign `ExecutionPayloadBid` to create `SignedExecutionPayloadBid`
4. [Submit SignedExecutionPayloadBid](#/Beacon/publishExecutionPayloadBid) to network for proposer consideration
5. If a valid block includes your bid, sign the envelope and [submit `SignedExecutionPayloadEnvelopeContents`](#/Beacon/publishExecutionPayloadEnvelope)
   (envelope + blobs + KZG proofs) with `Eth-Blob-Data-Included: true` via any beacon node
    - Must submit before [`get_payload_due_ms()`](https://github.com/ethereum/consensus-specs/blob/v1.7.0-beta.0/specs/gloas/fork-choice.md#new-get_payload_due_ms) milliseconds into the slot

Monitor for block proposals containing your bid to trigger envelope release.
