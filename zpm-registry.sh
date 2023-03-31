docker stop zpm-registry
docker rm zpm-registry
docker run --name zpm-registry -d -p 9001:52773 --hostname zpm intersystemsdc/iris-community:2022.1.0.209.0-zpm --check-caps false
docker network connect intersystems-rest-demo_default zpm-registry
