# Validator Flow

Detail explanation how validator should utilize this API to perform his regular BeaconChain duties.


### Block Proposing

On start of every epoch, validator should [fetch proposer duties](#/Validator/getProposerDuties).
Result is array of objects, each containing proposer pubkey and slot at which he is suppose to propose.

Proposing block:
1. [Ask Beacon Node for BeaconBlock object](#/Validator/produceBlock)
2. Sign block
3. [Submit SignedBeaconBlock](#/ValidatorRequiredApi/publishBlock) (BeaconBlock + signature)

Monitor chain block reorganization events (TBD) as they could change block proposers. 
If reorg is detected, ask for new proposer duties and proceed from 1.

### Attestation

On start of every epoch, validator should ask for attester duties for epoch + 1.
Result are array of objects with validator, his committee and attestation slot.

Attesting:
1. [Upon receiving duty check if aggregator](https://github.com/ethereum/eth2.0-specs/blob/v0.11.3/specs/phase0/validator.md#aggregation-selection)
    - Validator is aggregator
    - [Ask beacon node to subscribe to your subnet](#/ValidatorRequiredApi/subscribeToBeaconCommitteeSubnet)                                             
2. on start of attesting slot, [fetch AttestationData](#/ValidatorRequiredApi/produceAttestationData)
3. wait for AttestationData block (TBD)
    - max wait: SECONDS_PER_SLOT / 3 * 1000
4. [submit Attestation](#/ValidatorRequiredApi/submitPoolAttestations) (AttestationData + aggregation bits)
    - Aggregation bits are `Bitlist` with length of committee (received in AttesterDuty)
    with bit on position `validator_committee_index` (see AttesterDuty) set to true
5. [Featch aggregated attestation](#/ValidatorRequiredApi/getAggregatedAttestation) from Beacon Node you've subscribed to your subnet
6. wait for SECONDS_PER_SLOT * 2 / 3 of attesting slot
7. [Publish SignedAggregateAndProof](#/ValidatorRequiredApi/publishAggregateAndProof)

Monitor chain block reorganization events (TBD) as they could change attesters and aggregators. 
If reorg is detected, ask for new attester duties and proceed from 1..
