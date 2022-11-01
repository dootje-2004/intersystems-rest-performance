# Tasks

## Set up a repository

Create a new, empty repository <https://github.com/dootje-2004/intersystems-rest-demo>.
Make it private for now.

Before we can clone it, we need to set up an SSH key.
We follow [GitHub's instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).
On the Mac, issue these commands:
```bash
$ ssh-keygen -t ed25519 -C "dootje_2004@hotmail.com"
$ eval "$(ssh-agent -s)"
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

Pull the latest IRIS Community Edition from Docker Hub 
with `docker pull intersystemsdc/iris-community:latest`.

Create a simple docker-compose file that names the container and assigns an external port. 
We pick port 9090 for the client and 9091 for the server.

In order to avoid repeated typing of commands, we (ab)use a Makefile.
Info on Makefile syntax [here](https://makefiletutorial.com/).

Issue `make run` to deploy the demo, `make halt` to remove it.

## Define REST interface in OpenAPI format

## Create Dockerfile for the client

## Create Dockerfile for the server

## Create server dashboard
