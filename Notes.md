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
Note: In a Dockerfile, it is best to refer to the version explicitly to avoid future upgrade issues.

Create a simple docker-compose file that names the container and assigns an external port.
We pick port 9090 for the client and 9091 for the server.

In order to avoid repeated typing of commands, we (ab)use a Makefile.
Info on Makefile syntax [here](https://makefiletutorial.com/).

Issue `make build` to deploy the demo, `make halt` to remove it.
Use `make run` to restart the containers without rebuilding.

## Create Dockerfile for the server and client containers

The only thing it needs to do is define the base image and invoke the script `int.sh`.
Combining all shell commands into one script avoids the creation of multiple layers in the container, and it makes for more readable code.
Note that we explicitly define the image version; this is preferable to using the *latest* tag, since it avoids unexpected container updates.

## Configure the server instance

A portable way to do this is through a manifest file.
The manifest defines a namespace *DEMO*.

## Define REST interface in OpenAPI format

IRIS still relies on OpenAPI version 2 (aka Swagger).
Make sure to include the client timestamp in the messages.
Have one of the fields be a stream with adjustable length, so we can vary the size of the messages.

## Create the API

The initial server's REST API classes can be created in [one of the three ways described in the IRIS documentation](https://docs.intersystems.com/iris20222/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_intro#GREST_intro_create_overview).
Since we follow the spec-first approach, we create the API by invoking `##class(%REST.API).CreateApplication()`.

## Implement server-side methods

After creating the API, we need to implement the server-side methods it calls.
In our case this is just the `processPayload()` method in the implementation class.
The easiest way to deal with this is to reload the entire `demo.impl` class.

## Expose the API

Create a new web application on the server to allow external clients to send data.

## Configure the client instance

On the client, the manifest also creates a namespace called *DEMO*.
We supply class files to create a production *Demo.Production* with
a request class *Demo.Request* and a business operation *Demo.ClientOperation*.

Note that extending the business operation from *EnsLib.HTTP.OutboundAdapter* allows us to define
a number of useful settings (like the server name, port number and endpoint), but the adapter
methods do not allow us to set the content type of the request.
Instead of `..Adapter.Post()` we leverage a general `%Net.HttpRequest` object.

As for the server and port settings on the client, note that both containers publish their native
port numbers to the Docker network. The published ports are only relevant to the host.
The REST calls must be made to the standard web-server port, i.e. 52773.

## Create server metrics
