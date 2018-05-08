build:
	docker-compose build

setup: build
	docker-compose run --rm app rails db:setup db:migrate

serve:
	docker-compose up

test:
	docker-compose run --rm app rspec
