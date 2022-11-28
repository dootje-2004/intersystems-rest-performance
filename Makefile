build:
	$(MAKE) clean
	docker-compose up -d --build --force-recreate

clean:
	- docker-compose stop
	- docker rm rest-demo-client rest-demo-server
	- docker rmi intersystems-rest-demo-client:latest intersystems-rest-demo-server:latest
