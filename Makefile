build:
	$(MAKE) clean
	docker-compose up -d --build --force-recreate

clean:
	- docker-compose stop
	- docker rm rest-client rest-server
	- docker rmi intersystems-rest-demo-server:latest intersystems-rest-demo-client:latest
