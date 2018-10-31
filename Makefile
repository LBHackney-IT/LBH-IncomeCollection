.PHONY: docker-build
docker-build:
	docker-compose build

.PHONY: docker-down
docker-down:
	docker-compose down

.PHONY: bundle
bundle:
	docker-compose run --rm app bundle install

test_migrate:
	docker-compose run --rm app rails db:migrate RAILS_ENV=test

setup: docker-build bundle test_migrate
	docker-compose run --rm app rails db:create db:migrate

serve-staging:
	docker-compose run -e RAILS_ENV=staging RACK_ENV=staging --service-ports --rm app

serve:
	rm tmp/pids/server.pid || echo ""
	docker-compose up

lint:
	docker-compose run --rm app rubocop

test:
	docker-compose run --rm app rspec

check: lint test
	echo 'Deployable!'

shell:
	docker-compose run --rm app /bin/bash

guard:
	docker-compose run --rm app guard

