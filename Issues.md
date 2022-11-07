# Issues

## Open issues

How to change the IRIS default instance name from `IRIS` to `REST CLIENT` or `REST SERVER`?

## Solved issues

*What type of license is best for the GitHub repository?*
I took the MIT license from <https://github.com/intersystems-community/iko-01-basic-iris-cluster> on Open Exchange as an example.

*Push is rejected by GitHub.*
Turns out the git mail address on the Mac was set to gmail.com instead of hotmail.com.
Corrected with `$ git config --global user.email "dootje_2004@hotmail.com"`.

*`docker-compose -build` will not run the `init.sh` script.*
The Docker COPY command preserves file permissions. Just do `chmod a+x client/init.sh`.

*How to set a password for the SuperUser account in Dockerfile?*
This is done through the Security.Users class by setting the property *Password* to the desired string.
However, we opt to remove all security in the first place (see the `init.cos` script).

*Installer class with manifest is imported, but no namespace is created.*
The manifest is missing a database configuration clause.

*Documatic reports `This class has no methods or properties`, but the `setup` class method definitely exists.*
Apparently the method name `setup` is special and ignored by Documatic.
Adding a dummy class method shows that Documatic does actually work.
