build:
	@docker-compose build

up:
	@docker-compose run --rm --service-ports vpn
