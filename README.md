# Bitcoin Core 0.4.0 Docker Build

Container to build an ancient Bitcoin Core version 0.4.0.

## Build Docker Image

To build the Docker image, run the following command in the root of the repository:

```sh
docker build -t bitcoin-core-0.4.0 .
```

## Run

You probably want to use a blockchain data directory downloaded beforehand:

```sh
docker run -it --rm -v /path/to/bitcoin/data:/root/.bitcoin -v /path/to/bitcoin.conf:/root/.bitcoin/bitcoin.conf bitcoin-setup bash
```

```sh
/root/bitcoin/src/bitcoind -conf=/root/.bitcoin/bitcoin.conf
```
