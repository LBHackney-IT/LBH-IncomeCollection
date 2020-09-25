# Development

Requirements:

* Docker CE
* Income API
* Tenancy API
* Universal Housing Simulator

## Environment Setup

1. Install [Docker CE](https://docs.docker.com/install/)
2. Run `make setup`
3. `git clone` the required projects & follow setup guides
   - [lbh-income-api](https://github.com/LBHackney-IT/lbh-income-api)
   - [LBHTenancyAPI](https://github.com/LBHackney-IT/LBHTenancyAPI)
   - [universal-housing-simulator](https://github.com/LBHackney-IT/universal-housing-simulator)
4. Rename the `.env.test` to `.env` and set the variables

## Running the service locally

You can run all of the services locally by running, this spins up docker containers with the relevant services.
You will need to ensure the other services are configured correctly.

```sh
make run-all
```

Your worktray in the app will probably be empty, so to get data in there run the sync and refresh:
```sh
make sync-uh-simulator-data
```

The breach detector should run nighly in deployed environments, you can run the breach detector locally using:
```sh
make run-breach-detector
```

## Run tests

Tests are written using rspec. They will be executed within a docker container.

```
make test
```

## Run linter

A linter ([Rubocop](https://github.com/rubocop-hq/rubocop)) ensures consistent style standards.

```
make lint
```

## Adding Dependencies (gems)

1. Add your gem to the Gemfile.
2. Run `make bundle`. This will update the Gemfile.lock, and rebuild the docker image.

## Infrastructure

The staging and production applications are hosted on Heroku. You will need to ask an active maintainer for access.

## Static IP addresses

To communicate with the on-premHackney API, which is hosted on premises, we need whitelisted static IP addresses for the Heroku instances outbound traffic. They are provided by QuotaGuard Static as a Heroku addon, you can find them in the addon config.
