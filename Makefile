build:
	$(MAKE) halt
	docker-compose up --build -d

run:
	$(MAKE) halt
	docker-compose up -d

halt:
	- docker-compose stop
	- docker rm rest-client
