INCOME_API_DIR  ?= ../lbh-income-api
UHSIM_DIR       ?= ../universal-housing-simulator
TENANCY_API_DIR ?= ../LBHTenancyAPI

export

.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: docker-down
docker-down:
	docker-compose down

.PHONY: bundle
bundle:
	docker-compose run --rm app bundle install

setup: docker-build

serve-staging:
	docker-compose run -e RAILS_ENV=staging RACK_ENV=staging --service-ports --rm app

serve:
	rm tmp/pids/server.pid || echo ""
	docker-compose up

lint:
	docker-compose run --rm app rubocop

test:
	docker-compose run --rm app rspec

jest:
	docker-compose run --rm app yarn test

check: lint test jest
	echo 'Deployable!'

run-all:
	rm tmp/pids/server.pid || true
	rm ${INCOME_API_DIR}/tmp/pids/server.pid || true
	docker build --tag managearrears .
	cd ${INCOME_API_DIR} && docker build --tag incomeapi .
	cd ${TENANCY_API_DIR} && docker build --tag tenancyapi -f ./LBHTenancyAPI/Dockerfile .
	docker-compose -f ${UHSIM_DIR}/docker-compose.service.yml \
		-f ${INCOME_API_DIR}/docker-compose.service.yml \
		-f ${TENANCY_API_DIR}/docker-compose.service.yml \
		-f docker-compose.service.yml \
		up

shell:
	docker-compose run --rm app /bin/bash

guard:
	docker-compose run --rm app guard

sync-uh-simulator-data:
	docker exec -ti universal-housing-simulator_incomeapi_1 sh -c "export CAN_AUTOMATE_LETTERS=true && rake income:rent:sync:manual_sync"

run-breach-detector:
	docker exec -ti universal-housing-simulator_incomeapi_1 sh -c "rake income:update_all_agreement_state"
