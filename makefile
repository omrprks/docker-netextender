build:
	@docker-compose build

up:
	@docker-compose run --rm --service-ports netextender

run:
	@docker-compose run --rm -e SOURCE_PORT=${port} -e TARGET_ADDRESS=${target_address} -p ${port}:${target_port} netextender
