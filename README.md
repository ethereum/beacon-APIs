# Ethereum 2.0 APIs

![CI](https://github.com/ethereum/eth2.0-APIs/workflows/CI/badge.svg)

Collection of RESTful APIs provided by Ethereum 2.0 clients

API browser: [https://ethereum.github.io/eth2.0-APIs/](https://ethereum.github.io/eth2.0-APIs/)

## Validator

API facilitating communication between a Validator Client and a Beacon Node

* [Beacon Node API for Validator](apis/validator/README.md)
* [OpenAPI Specification](apis/validator/beacon-node-oapi.yaml)
   * [APIs Documentation viewer](https://ethereum.github.io/eth2.0-APIs/)

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