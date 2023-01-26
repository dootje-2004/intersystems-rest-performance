# Tasks

## Set up a repository

Create a new, empty repository <https://github.com/dootje-2004/intersystems-rest-demo>.
Make it private for now.

Before we can clone it, we need to set up an SSH key.
We follow [GitHub's instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).
On the Mac, issue these commands:

```bash
ssh-keygen -t ed25519 -C "dootje_2004@hotmail.com"
eval "$(ssh-agent -s)"
```

Add the lines

```text
Host *.github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/github
```

to `~/.ssh/config`.

Add the new key to the keychain with `$ ssh-add -K ~/.ssh/github`.
Note that the `--apple-use-keychain` option is rejected.

Copy the public key to the clipboard with `$ pbcopy < ~/.ssh/github.pub`.

In your GitHub account, paste the new key under **Settings** > **SSH and GPG keys**.
We name it *mac os*.

Finally, we can clone the new repository with `$ git clone git@github.com:dootje-2004/intersystems-rest-demo.git`.

## Create docker-compose file to run client and server containers

Pull the latest IRIS Community Edition from Docker Hub with `docker pull intersystemsdc/iris-community:latest`.
This is version 2022.1.0.209.0-zpm.
Note: In a Dockerfile, it is best to refer to the version explicitly
to avoid future upgrade issues.

Create a simple docker-compose file that names the container
and assigns an external port.
We pick port 9090 for the client and 9091 for the server.

In order to avoid repeated typing of commands, we (ab)use a Makefile.
Info on Makefile syntax [here](https://makefiletutorial.com/).

Issue `make build` to deploy the demo, `make halt` to remove it.
Use `make run` to restart the containers without rebuilding.

## Create Dockerfile for the server and client containers

The only thing it needs to do is define the base image and invoke the script `int.sh`.
Combining all shell commands into one script avoids the creation of multiple
layers in the container, and it makes for more readable code.
Note that we explicitly define the image version; this is preferable to
using the *latest* tag, since it avoids unexpected container updates.

## Configure the server instance

A portable way to do this is through a manifest file.
The manifest defines a namespace *DEMO*.

## Define REST interface in OpenAPI format

IRIS still relies on OpenAPI version 2 (aka Swagger).
Make sure to include the client timestamp in the messages.
Have one of the fields be a stream with adjustable length,
so we can vary the size of the messages.

## Create the API

The initial server's REST API classes can be created in
[one of the three ways described in the IRIS documentation](https://docs.intersystems.com/iris20222/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_intro#GREST_intro_create_overview).
Since we follow the spec-first approach, we create the API by invoking `##class(%REST.API).CreateApplication()`.

## Implement server-side methods

After creating the API, we need to implement the server-side methods it calls.
In our case this is just the `processPayload()` method in the implementation class.
The easiest way to deal with this is to reload the entire `demo.impl` class.
The disadvantage of this approach, however, is that any new `operationId`s
in the Swagger spec will be overwritten when we reload the entire class.
To avoid this, we copy the individual methods from the implementation file to `demo.impl`
with `copyMethods()`.

## Expose the API

Create a new web application on the server to allow external clients to send data.
For this, invoke `##class(%REST.API).CreateApplication()`.

## Configure the client instance

On the client, the manifest also creates a namespace called *DEMO*.
We supply class files to create a production *Demo.Production* with
a request class *Demo.Request* and a business operation *Demo.ClientOperation*.

Note that extending the business operation from *EnsLib.HTTP.OutboundAdapter*
allows us to define a number of useful settings (like the server name,
port number and endpoint), but the adapter methods do not allow us
to set the content type of the request.
Instead of `..Adapter.Post()` we leverage a general `%Net.HttpRequest` object.

As for the server and port settings on the client, note that both containers
publish their native port numbers to the Docker network.
The published ports are only relevant to the host.
The REST calls must be made to the standard web-server port, i.e. 52773.

## Create metrics

We register the time the server takes to process each request,
as well as the request's overall round-trip time.
The difference between these values is assumed to be the network delay.

TODO: Split docker-compose into client and server part,
in case the demo is run on two different machines.

TODO: Before packaging, remove all storage definitions from %Persistent classes.

TODO: Implement different synchronization methods.
These are:

The events we monitor are:

* **1**: A message is sent from the client's Business Operation.
* **2**: The message is received by the server's REST implementation class.
* **3**: The message is forwarded by the REST implementation class.
* **4**: The message is received by the server's Business Service.
* **5**: The message is forwarded by the Business Service.
* **6**: The message is received by the server's Business Process.
* **7**: The message has been processed by the server's Business Process.
* **8**: A response is received by the server's Business Service.
* **9**: The response is forwarded by the Business Service.
* **10**: The response is received by the REST implementation class.
* **11**: An HTTP response is sent back to the client by the REST
  implementation class.
* **12**: The HTTP response is received by the client's Business Operation.

The modes we test are:

* **Fully synchronous mode**: All events occur in order, one after the other,
  before a next message is sent.
  This is the slowest mode, but yields a complete visual trace on the server.
  The execution speed may be influenced by varying the server BP's poolsize.
  It is certainly changed by altering the processing delay in the Business Process.
  All of the above events are registered.

* **Async production mode**: Messages are sent asynchronously from the
  server's Business Service to its Business Process.
  The visual trace only shows the request, not the BP's response.
  Since the Business Service does not wait for the response, this mode
  should be faster than the fully synchronous one.
  Event 6 is not registered.

* **Async injection mode**: The REST implementation class does not wait
  for the Business Service response.
  Not sure if this is possible, since `##class(Ens.BusinessService).ProcessInput()`
  seems synchronous-only.
  Perhaps jobbing off in separate method?
  Also not sure if this is going to speed up the tests:
  the same processing still needs to be done, only the network connection may be
  freed up quicker. There may be an effect in combination with a higher BP poolsize.
  Events 6 and 7 are not registered.

* **Direct storage mode**: The server's production is bypassed entirely.
  The REST implementation takes care of storing the message.
  This should be the fastest mode, forgoing all traceability.
  Only events 1 and 2 are registered.

* **Flood mode**: The tranfer of an HTTP request is synchronous,
  as required by the protocol. This is also the way IRIS implements it.
  If we want to send multiple requests in parallel, the only option is to
  set the client's BO poolsize higher. This still limits the number of
  concurrent requests to a handfull; it is not really flooding the server.
  As an alternative we could use a JavaScript method (or rather a jQuery one),
  omitting the `success` callback.
  This means the IRIS client is not involved at all.
  This mode can be combined with any of the three previous ones,
  but is only relevant when combined with the fastest, i.e. direct storage.

TODO: Server BP must store and then delete each message.

## Timing

In general, we can't assume the client and server clocks to run in sync.
This is especially true when running the tests on separate machines.

TODO: Make drawing in UI to show data flow.
