run:
	$(MAKE) halt
	docker-compose up -d

halt:
	- docker-compose stop
	- docker rm iris-client
