build:
	$(MAKE) clean
	docker-compose up -d --build --force-recreate

run:
	$(MAKE) clean
	docker-compose up -d

clean:
	- docker-compose stop
	- docker rm rest-client rest-server
	- docker rmi intersystems-rest-demo_server:latest intersystems-rest-demo_client:latest
