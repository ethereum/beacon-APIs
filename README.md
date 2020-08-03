# Ethereum 2.0 APIs

![CI](https://github.com/ethereum/eth2.0-APIs/workflows/CI/badge.svg)

Collection of RESTful APIs provided by Ethereum 2.0 clients

API browser: [https://ethereum.github.io/eth2.0-APIs/](https://ethereum.github.io/eth2.0-APIs/)

## Outline

This document outlines an application programming interface (API) which is exposed by a beacon node implementation
 which aims to facilitate [Phase 0](https://github.com/ethereum/eth2.0-specs#phase-0) of Ethereum 2.0.

The API is a REST interface, accessed via HTTP,designed for use as a public communications protocol.
 Currently, the only supported return data type is JSON.

The beacon node (BN) maintains the state of the beacon chain by communicating with other beacon nodes in the Ethereum 2.0 network.
Conceptually, it does not maintain keypairs that participate with the beacon chain.

The validator client (VC) is a conceptually separate entity which utilizes private keys 
to perform validator related tasks, called "duties", on the beacon chain.
 These duties include the production of beacon blocks and signing of attestations.

The goal of this specification is to promote interoperability between various beacon node implementations.

## Render 
To render spec in browser you will need any http server to load `index.html` file
in root of the repo.

##### Python
```
python -m SimpleHTTPServer 8080
```
And api spec will render on [http://localhost:8080](http://localhost:8080).

##### NodeJs
```
npm install simplehttpserver -g

# OR

yarn global add simplehttpserver

simplehttpserver
```
And api spec will render on [http://localhost:8000](http://localhost:8000).

## Contributing
Api spec is checked for lint errors before merge. 

To run lint locally, install linter with
```
npm install -g @stoplight/spectral

# OR

yarn global add @stoplight/spectral
```
and run lint with
```
spectral lint beacon-node-oapi.yaml 
```

## Releasing

1. Create and push tag

   - Make sure info.version in beacon-node-oapi.yaml file is updated before tagging.
   - CD will create github release and upload bundled spec file
   
2. Add release entrypoint in index.html

In SwaggerUIBundle configuration (inside index.html file), add another entry in "urls" field (SwaggerUI will load first item as default).
Entry should be in following format(replace `<tag>` with real tag name from step 1.):
```javascript
         {url: "https://cors-anywhere.herokuapp.com/https://github.com/ethereum/eth2.0-APIs/releases/download/<tag>/beacon-node-oapi.yaml", name: "<tag>"},
```