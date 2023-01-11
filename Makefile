build:
	$(MAKE) clean
	docker-compose up -d --build --force-recreate

clean:
	- docker-compose stop
	- docker rm rest-demo-server
	- docker rmi intersystems-rest-demo-server:latest
