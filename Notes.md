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

TODO: Before packaging, remove all storage definitions from %Persistent classes.

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

## Timing

In general, we can't assume the client and server clocks to run in sync.
This is especially true when running the tests on separate machines.

## Terminology

We are dealing with data that is taking a different shape at each step in the
testing process. To clarify things, we use different names for that data at
each stage.

A **call** is the act of sending an HHTP request from the client to the server;
we also use this term to signify the HTTP request itself, to distinguish it from
the requests transmitted inside the IRIS server production.

The body of a call is the **message** we are transmitting. In our case this is an
object consisting of an ID and a **payload**.
The server processes that payload either as a string or as a stream.

If the test involves injecting the message into the server's production, the
server's REST class creates a **request** from it and sends it to the production.
The REST class may receive a **response** in return.

## Research

TODO: What influence does the network (actually the socket) have?
What speeds does it support?

TODO: Difference between Docker and bare-metal (e.g. network speed)?

TODO: ZPM package for bare-metal install.

* Compare scenarios two by two (instead of collecting test results for comparison):
not implemented. The user can open as many browser tabs as they wish and compare
results between them.

TODO: Database expansion: determine and set size
before starting a test to eliminate overhead.

TODO: Influence of stream compression.
%Stream.GlobalCharacter property met parameter COMPRESS = -1.
See [here](https://docs.intersystems.com/iris20222/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%25SYS&PRIVATE=1&CLASSNAME=%25Stream.GlobalCharacter).

It turns out that embedded SQL calls can be quite costly.
We have replaced the most time-critical ones by globals
(^clientsync, ^treatment, ^restforwarding).
This, in turn, has been superseded by creating totally separate paths for
the different options.

The maximum string length is returned by `$system.SYS.MaxLocalLength()`.

## IPM (formerly known as ZPM)

Things to consider when preparing the app for the InterSystems Package Manager:

* Naming: Sources must reside in `/src/cls/company/project/subpackage/ClassNames.cls`.
See [this post by Evgeny](https://community.intersystems.com/post/objectscript-package-manager-naming-convention).

* IRIS Community Version Docker images are IPM-ready. The command is still `zpm`.

* Configure a local filesystem repo with
`repo -name <repo name> -filesystem -path <absolute path>`.
If packages are not installed at the top level of the repo, use the `depth` parameter.

* The IRIS container came with ZPM version 0.4.0.
Update to the latest version by executing `install zpm` in the zpm shell.
This updates the ZPM client to version 0.5.3.

* To install our IPM package in a container, we have three options.
The first is to copy the package into the container at build time,
configure a local repo and install from there.
This would replace part of the Docker commands.
The second option is to map the local repo to a Docker volume
and install from there.
The third option is to set up a repo server on the Docker host (as described
[here](https://community.intersystems.com/post/setting-your-own-intersystems-objectscript-package-manager-registry)),
configure that ZPM repo in the container, and install from there.
This last method is most in line with the intended use,
and does not clutter the container setup.

### Setting up a local ZPM registry

* Start a new IRIS container acting as a local registry:
`docker run --name zpm-registry -d -p 9001:52773 intersystemsdc/iris-community:2022.1.0.209.0-zpm --check-caps false`.

* Open the Management Portal at `http://localhost:9001/csp/sys/utilhome.csp` and give the **_system** user a new password.

* Get a command line inside the container with `docker exec -it zpm-registry iris session iris`.
You will find yourself in the **USER** namespace.

* Open the ZPM shell with `zpm`.

* Install **zpm-registry** with `install zpm-registry`.

* As a test, add [the math example](https://github.com/psteiwer/ObjectScript-Math) by sending a HTTP POST request
to <http://localhost:9001/registry/package> with a JSON body `{"repository": "https://github.com/psteiwer/ObjectScript-Math"}`.
Use basic authentication with user **_system** and the password you set earlier.

* Verify that the new registry works by sending a GET request to <http://localhost:9001/registry/packages/-/all>.
The **objectscript-math** package should be listed.

* On GitHub, make [the **intersystems-rest-performance** repo](https://github.com/dootje-2004/intersystems-rest-performance)
public.

* Add the repo to the registry by issuing a POST request to <http://localhost:9001/registry/package>.
Attach a JSON body `{"repository": "https://github.com/dootje-2004/intersystems-rest-performance"}`.
As before, use appropriate authentication.

* Repeat the verification by sending a GET request to <http://localhost:9001/registry/packages/-/all>.
Both packages (**objectscript-math** and **rest-demo**) should be listed.

### Connecting to the local registry

* Make sure that the registry container is on the same Docker network as the REST container:
`docker network connect intersystems-rest-demo_default zpm-registry`.

* Get the hostname of the registry container with
`docker inspect -f '{{.Config.Hostname}}' zpm-registry`.
The hostname can also be seen in the upper-left corner of the Management Portal of the registry container.
We need this for setting up the registry reference on the REST container.
The Docker hostname is usually a random hexadecimal string like `8e763a6c85c1`.

* We install the package in a separate namespace of the existing REST container.
We expect future users to create a dedicated namespace themselves.
Our new namespace is called **TEST**. We set it up through the Management Portal.

* Open a terminal inside the REST container with `docker exec -it rest-demo-server iris session iris`.

* Switch to the **TEST** namespace with `zn "TEST"`.

* Open the **ZPM** shell with `zpm`.

* Add the local registry to the registry pool with
`repo -n local -r -url http://<hostname>:52773/registry/ -user _system -pass <password>`.
ZPM should respond with something like

```text
local
        Source:                 http://8e763a6c85c1:52773/registry/
        Enabled?                Yes
        Available?              Yes
        Use for Snapshots?      Yes
        Use for Prereleases?    Yes
        Is Read-Only?           No
        Deployment Enabled?     No
```

Pay special attention to the *Available* setting. This must read *Yes* for the registry server to work as expected.

### Installing the package from the local registry

After all this setting up, all we need to do is issue `install rest-demo` in the ZPM shell on the REST container.

TODO: This does not work yet. Needs reconfiguring.
