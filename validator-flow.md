---
layout: page
title: "Validator flow"
permalink: /validator-flow/
---

# Validator Flow

Detail explanation how validator should utilize this API to perform his regular BeaconChain duties.


### Block Proposing

On start of every epoch, validator should [fetch proposer duties](#/Validator/getProposerDuties).
Result is array of objects, each containing proposer pubkey and slot at which he is suppose to propose.

If proposing block, then at immediate start of slot:
1. Ask Beacon Node for BeaconBlock object:
   - Pre-Gloas forks: [produceBlockV3](#/Validator/produceBlockV3)
   - Post-Gloas fork: [produceBlockV4](#/Validator/produceBlockV4)
2. Sign block
3. [Submit SignedBeaconBlock](#/ValidatorRequiredApi/publishBlock) (BeaconBlock + signature)

Monitor chain block reorganization events (TBD) as they could change block proposers.
If reorg is detected, ask for new proposer duties and proceed from 1.

### Attestation

On start of every epoch, validator should ask for attester duties for epoch + 1.
Result are array of objects with validator, his committee and attestation slot.

Attesting:
1. Upon receiving duty, have beacon node prepare committee subnet
    - [Check if aggregator by computing `slot_signature`](https://github.com/ethereum/consensus-specs/blob/v1.3.0/specs/phase0/validator.md#attestation-aggregation)
    - [Ask beacon node to prepare your subnet](#/ValidatorRequiredApi/prepareBeaconCommitteeSubnet)
      -- Note, validator client only needs to submit one call to
      `prepareBeaconCommitteeSubnet` per committee/slot its validators have
      been assigned to. If any validators in the committee are aggregators,
      set `is_aggregator` to `True`,
2. Wait for new BeaconBlock for the assigned slot (either stream updates or poll)
    - Pre-Gloas forks: Max wait `SECONDS_PER_SLOT / 3` seconds into the assigned slot
    - Post-Gloas forks: Max wait `SECONDS_PER_SLOT / 4` seconds into the assigned slot
3. [Fetch AttestationData](#/ValidatorRequiredApi/produceAttestationData)
4. [Submit Attestation](#/ValidatorRequiredApi/submitPoolAttestations) (AttestationData + aggregation bits)
    - Aggregation bits are `Bitlist` with length of committee (received in AttesterDuty)
    with bit on position `validator_committee_index` (see AttesterDuty) set to true
5. If aggregator:
    - Pre-Gloas forks: Wait for `SECONDS_PER_SLOT * 2 / 3` seconds into the assigned slot
    - Post-Gloas forks: Wait for `SECONDS_PER_SLOT / 2` seconds into the assigned slot
    - [Fetch aggregated Attestation](#/ValidatorRequiredApi/getAggregatedAttestation) from Beacon Node you've subscribed to your subnet
    - [Publish SignedAggregateAndProofs](#/ValidatorRequiredApi/publishAggregateAndProofs)

Monitor chain block reorganization events (TBD) as they could change attesters and aggregators.
If reorg is detected, ask for new attester duties and proceed from 1..

### PTC Attesting

On start of every epoch beginning with the Gloas fork, validator should [fetch PTC duties](#/Validator/getPtcDuties) for epoch + 1.
Result are array of objects with validator index and assigned slot for payload timeliness committee participation.

PTC Attesting:
1. Wait for new BeaconBlock for the assigned slot
    - Max wait: `SECONDS_PER_SLOT / 4` seconds into the assigned slot
2. [Fetch PayloadAttestationData](#/ValidatorRequiredApi/producePayloadAttestationData) for the assigned slot
3. Sign PayloadAttestationData to create PayloadAttestationMessage
4. [Submit PayloadAttestationMessage](#/ValidatorRequiredApi/submitPayloadAttestationMessage)
    - Must be submitted by `3/4` of slot duration (`PAYLOAD_ATTESTATION_DUE_BPS` = 75% of slot)
    - Attestation indicates whether execution payload envelope has been seen for the block and if blobs were received

Monitor chain block reorganization events (TBD) as they could change PTC assignments.
If reorg is detected, ask for new PTC duties and proceed from 1..

### Builder (Optional)

Post-Gloas fork, validators may optionally act as builders to submit execution payload bids for block inclusion.
This requires registering with builder-specific withdrawal credentials (`BUILDER_WITHDRAWAL_PREFIX`).

Building:
1. [Fetch ExecutionPayloadBid](#/Validator/getExecutionPayloadBid) from beacon node
    - Beacon node obtains payload via `engine_getPayload` call to execution client
2. Cache fields required to form an [ExecutionPayloadEnvelope](https://github.com/ethereum/consensus-specs/blob/master/specs/gloas/beacon-chain.md#executionpayloadenvelope)
2. Sign ExecutionPayloadBid to create SignedExecutionPayloadBid
3. [Submit SignedExecutionPayloadBid](#/Beacon/publishExecutionPayloadBid) to network for proposer consideration
4. If bid is selected by proposer in their block:
    - [Fetch ExecutionPayloadEnvelope](#/Validator/getExecutionPayloadEnvelope) from beacon node
    - Sign envelope and [submit SignedExecutionPayloadEnvelope](#/Beacon/publishExecutionPayloadEnvelope)
    - Must submit early enough for PTC attestation by `3/4` of slot duration

Monitor for block proposals containing your bid to trigger envelope release.


