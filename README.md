# Ethereum Beacon APIs

![CI](https://github.com/ethereum/beacon-APIs/workflows/CI/badge.svg)

Collection of RESTful APIs provided by Ethereum Beacon nodes

API browser: [https://ethereum.github.io/beacon-APIs/](https://ethereum.github.io/beacon-APIs/)

## Outline

This document outlines an application programming interface (API) which is exposed by a beacon node implementation of the Ethereum [consensus layer specifications](https://github.com/ethereum/consensus-specs).

The API is a REST interface, accessed via HTTP. The API should not, unless protected by additional security layers, be exposed to the public Internet as the API includes multiple endpoints which could open your node to denial-of-service (DoS) attacks through endpoints triggering heavy processing.
 Currently, the only supported return data type is JSON.

The beacon node (BN) maintains the state of the beacon chain by communicating with other beacon nodes in the Ethereum network.
Conceptually, it does not maintain keypairs that participate with the beacon chain.

The validator client (VC) is a conceptually separate entity which utilizes private keys
to perform validator related tasks, called "duties", on the beacon chain.
 These duties include the production of beacon blocks and signing of attestations.

The goal of this specification is to promote interoperability between various beacon node implementations.

## Build and Serve Locally

The easiest way to build and serve the API spec locally is using the provided Makefile:

```bash
# Build and serve the spec (default)
make

# Build only
make build

# Serve only (after building)
make serve

# Run linting
make lint

# Clean build artifacts
make clean
```

### Usage

Local changes will be observable if "dev" is selected in the "Select a definition" drop-down in the web UI.

Users may need to tick the "Disable Cache" box in their browser's developer tools to see changes after modifying the source.

## Contributing
Api spec is checked for lint errors before merge.

To run lint locally, run
```
make lint
```

## Releasing

This repository supports both stable and pre-releases. The version of the next release has to be
determined based on the changes in `master` branch since the last stable release. It is recommended
to create a pre-release before releasing a new stable version.

### Stable releases

Steps to create a new stable release:

- Create and push a tag with the version of the release, e.g. `v3.0.0`
- CD will create the github release, upload bundled spec files, and open a release PR
- Review, approve and merge the release PR to `master` branch

### Pre-releases

Steps to create a new pre-release:

- Create and push a tag with the version of the release, e.g. `v3.0.0-alpha.0`
- CD will create the github release and upload bundled spec files

Pre-releases will not be listed in `index.html` and are intended to allow early testing against the spec.
