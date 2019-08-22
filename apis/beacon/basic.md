# Beacon Node Basic API

## Introduction

This document provides a list of abstract API definitions, each accompanied by
a specification of that endpoint when served via HTTP.

Clients may adhere to this specification by:

- Implementing the HTTP specifications exactly (or a implementing a superset).
- Using their own transport with respect to the abstract definitions (e.g.
	gRPC, JSON RPC).
  - Optionally, basing their resource access paths upon the
	HTTP paths.

### Notes

- The examples use `localhost:5051` purely for example purposes. The HTTP API
port is not part of the specification.
- This document seeks to be loosely coupled to the Eth2 spec, reducing the
	overhead in maintaining this document as the specification progresses.
  - Eth2 types (e.g., `BeaconBlock`) are loosely defined
	and their version (e.g., `v0.8.3`) is open to interpretation.
  - The JSON encoding of these types is analogous to the YAML serialization
	  format (each endpoint should include a JSON-encoded example).

## Endpoints

Table of endpoints:

| Title | HTTP Path |
| --- | --- |
[Beacon Head](#beacon-head) | `/beacon/head`
[Beacon Block](#beacon-block) | `/beacon/block`
[Beacon State](#beacon-state) | `/beacon/state`
[Network Peer Id](#network-peerid) | `/network/peer_id`
[Network Peers](#network-peers) | `/network/peers`
[Network ENR Address](#network-enr-address) | `/network/enr`

## Beacon Head

Requests information about the head of the beacon chain, from the node's
perspective.

#### Example Response

```
{
	slot: 1,
	block_root: "0xe7bb65da065e8ea1f6d5adde378348ed",
	state_root: "0x981fbdb550d2b5a36370f471fc16ddcf"
}
```

### HTTP Specification

| Property | Specification |
| --- |--- |
Path | `/beacon/head`
Method | GET
JSON Encoding | Object
Query Parameters | None
Typical Responses | 200

#### HTTP Example

```
$ curl "localhost:5051/node/head"
{"slot":546,"block_root":"0xee0973130905bfdf1deeed88ac0c09623c2cc071b03db68097f2e3b496258c17","state_root":"0xc87889ad8c760b1ec14746271372f9fb53d9f16463dcd224f86a6207799ad702"}
```

## Beacon Block

Request that the node return a beacon chain block that matches the provided
criteria (a block `root` or beacon chain `slot`). Only one of the parameters
should be provided as a criteria.

### Parameters

Accepts one of the following parameters:

#### `slot`: `Slot`

Query by slot number. Any block returned must be in the canonical chain (i.e.,
either the head or an ancestor of the head).

#### `root`: `Bytes32`

Query by tree hash root. A returned block is not required to be in the
canonical chain.

### Returns

Returns an object containing a single `BeaconBlock` and it's signed root.

#### Example Response

```
{
	root: "0x98e5edb27e53d238a9524590e62b1413",
	beacon_block: {
		slot: 42,
		parent_root: "0xabfb96c38165791636acaf72c4529c0b",
		...
	},
}
```

### HTTP Specification

| Property | Specification |
| --- |--- |
Path | `/beacon/block`
Method | GET
JSON Encoding | Object
Query Parameters | `slot`, `root`
Typical Responses | 200, 404

#### HTTP Example

```
$ curl "localhost:5051/beacon/block?slot=0"
{"root":"0x4eaf79f207428f2b6b6cbee14d4e7d19a114e1f60334905a10c58b10791243b9","beacon_block":{"slot":0,
```

_Truncated for brevity._

## Beacon State

Request that the node return a beacon chain state that matches the provided
criteria (a state `root` or beacon chain `slot`). Only one of the parameters
should be provided as a criteria.

### Parameters

Accepts one of the following parameters:

#### `slot`: `Slot`

Query by slot number. Any state returned must be in the canonical chain (i.e.,
either the head or an ancestor of the head).

#### `root`: `Bytes32`

Query by tree hash root. A returned state is not required to be in the
canonical chain.

### Returns

Returns an object containing a single `BeaconState` and it's tree hash root.

#### Example Response

```
{
	root: "0x68861c0151d232c75b8dfa24b8a07b65",
	beacon_state: {
		genesis_time: 1566444600,
		slot: 42,
		...
	},
}
```

### HTTP Specification

| Property | Specification |
| --- |--- |
Path | `/beacon/state`
Method | GET
JSON Encoding | Object
Query Parameters | `slot`, `root`
Typical Responses | 200, 404

#### HTTP Example

```
$ curl localhost:5051/beacon/state?slot=0
{"root":"0x3c06d45011320bc5a340811898e27c427547ee79e1e0f29892b4c5235d0c8c8e","beacon_state":{"genesis_time":1566448200,"slot":0,
```

_Truncated for brevity._

## Network Peer ID

Requests the beacon node's local `PeerId`.

#### Example Response

```
"QmVFcULBYZecPdCKgGmpEYDqJLqvMecfhJadVBtB371Avd"
```

### HTTP Specification

| Property | Specification |
| --- |--- |
Path | `/network/peer_id`
Method | GET
JSON Encoding | String (base58)
Query Parameters | None
Typical Responses | 200

#### HTTP Example

```
$ curl localhost:5051/network/peer_id
"QmVFcULBYZecPdCKgGmpEYDqJLqvMecfhJadVBtB371Avd"
```

## Network Peers

Requests the beacon node for one `MultiAddr` for each connected peer.

#### Example Response

```
[
	"QmaPGeXcfKFMU13d8VgbnnpeTxcvoFoD9bUpnRGMUJ1L9w",
	"QmZt47cP8V96MgiS35WzHKpPbKVBMqr1eoBNTLhQPqpP3m"
]
```

### HTTP Specification

| Property | Specification |
| --- |--- |
Path | `/network/peers`
Method | GET
JSON Encoding | [String] (base58)
Query Parameters | None
Typical Responses | 200

#### HTTP Example

```
$ curl localhost:5051/network/peers
["QmaPGeXcfKFMU13d8VgbnnpeTxcvoFoD9bUpnRGMUJ1L9w","QmZt47cP8V96MgiS35WzHKpPbKVBMqr1eoBNTLhQPqpP3m"]
```

## Network ENR Address

Requests the beacon node for it's listening `ENR` address.

#### Example Response

```
-IW4QPYyGkXJSuJ2Eji8b-m4PTNrW4YMdBsNOBrYAdCk8NLMJcddAiQlpcv6G_hdNjiLACOPTkqTBhUjnC0wtIIhyQkEgmlwhKwqAPqDdGNwgiMog3VkcIIjKIlzZWNwMjU2azGhA1sBKo0yCfw4Z_jbggwflNfftjwKACu-a-CoFAQHJnrm
```

### HTTP Specification

| Property | Specification |
| --- |--- |
Path | `/network/enr`
Method | GET
JSON Encoding | String (base64)
Query Parameters | None
Typical Responses | 200

#### HTTP Example

```
$ curl localhost:5051/network/enr
"-IW4QPYyGkXJSuJ2Eji8b-m4PTNrW4YMdBsNOBrYAdCk8NLMJcddAiQlpcv6G_hdNjiLACOPTkqTBhUjnC0wtIIhyQkEgmlwhKwqAPqDdGNwgiMog3VkcIIjKIlzZWNwMjU2azGhA1sBKo0yCfw4Z_jbggwflNfftjwKACu-a-CoFAQHJnrm"
```
