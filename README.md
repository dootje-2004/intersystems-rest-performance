# REST performance demo

## Purpose

Show the performance (requests per second) of IRIS's REST functionality.

## Usage

Access the client at <http://localhost:9090/csp/sys/utilhome.csp>
and the server at <http://localhost:9090/csp/sys/utilhome.csp>.

## Setup

Send a controlled number of requests per second from one IRIS instance (the *client*) to another (the *server*).
Have a dashboard show the time it takes to pass each stage of the processing (network, unpacking, business logic, storage, response).

Parameters on the client side:
* Number of requests per second
* Type of request (GET, PUT, PATCH, DELETE)
* Payload size

Parameters on the server side:
* Number of threads (parallel processes) handling the requests
