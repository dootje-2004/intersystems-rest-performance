# Issues

## Open issues

TODO: When REST setting = ASYNC, no data points are collected.

## Solved issues

*What type of license is best for the GitHub repository?*
I took the MIT license from <https://github.com/intersystems-community/iko-01-basic-iris-cluster>
on Open Exchange as an example.

*Push is rejected by GitHub.*
Turns out the git mail address on the Mac was set to gmail.com instead of hotmail.com.
Corrected with `$ git config --global user.email "dootje_2004@hotmail.com"`.

*`docker-compose -build` will not run the `init.sh` script.*
The Docker COPY command preserves file permissions. Just do `chmod a+x client/init.sh`.

*How to set a password for the SuperUser account in Dockerfile?*
This is done through the Security.Users class by setting the property *Password*
to the desired string.
However, we opt to remove all security in the first place (see the `init.cos` script).

*Installer class with manifest is imported, but no namespace is created.*
The manifest is missing a database configuration clause.

*Documatic reports `This class has no methods or properties`, but the `setup`
class method definitely exists.*
Apparently the method name `setup` is special and ignored by Documatic.
Adding a dummy class method shows that Documatic does actually work.

*New init files are missing in the server container.*
Bug: The `docker-compose.yml` file pointed the server config to the client environment.

*Containers exit immediately after Docker update.*
See [this post](https://community.intersystems.com/post/using-intersystems-iris-containers-docker-201014).
Adding `command: --check-caps false` to `docker-compose.yml` fixes it.

*Fractional seconds values in a BP's `<delay>` setting make it zero.*
This is [the normal behaviour](https://docs.intersystems.com/iris20222/csp/docbook/DocBook.UI.Page.cls?KEY=EBPLR_delay#EBPLR_delay_details).
As a consequence, we cannot use the `<delay>` action as is.
We use the `hang` command instead.

*The `%FromJSON()` method fails for large property values*
If the string length of a dynamic object's property exceeds IRIS's maximum string
length, a `<MAXSTRING>` error occurs,
even if the receiving class declares the property as a stream.
The workaround is to copy the value explicitly as a stream, as in
`set request.Message = input.%Get("message",,"stream")`.

*Dashboard definitions can't be imported as-is*
The contents of a `.DFI` file as shown in the VScode editor are not accepted by
the `$system.OBJ.Load()` method.
We need to export the DeepSee item first. This is easiest done through the
Management Portal.
Update: We opt to use Highcharts in the browser instead of a DeepSee dashboard.

*The client Demo production is not autostarted*
Turns out there is a `.DS_Store` file in the `/src` directory that is copied into
the container.
Compilation obviously fails, suppressing the subsequent autostart action.

*Custom KPI filter is not programmatically accessible.*
Solved. Probable reason is the `filterProperty` attribute. If this is missing,
the context is not filled.
Also, this property should refer to an existing field in the KPI's query.

*DeepSee portlets do not support ZenMethods.*
This is - unfortunately - a feature, not a bug.
Only Zen pages have a tight binding with the backend, not the individual Zen components.

*Docker copies entire directory instead of its contents*
As per the docs, the source directory must end with `/.` for copying the
contents only:
`$ docker cp client/init/html/. rest-demo-client:/usr/irissys/csp/demo`.

*jQuery $.get is not a function*
The *slim* version of jQuery lacks the Ajax methods *get*, *post* etc.
Use the normal (minified) version instead.

*The CopyMethods() method does not copy all methods*
It is essential to keep track of the `SequenceNumber` settings of each method.
You need to preserve the sequence number of the method you are overwriting.
If you don't, the order of the methods is jumbled and the editor (and mabe IRIS itself)
won't render them correctly.
Note that the sequence number is contiguous over ALL class children (methods, parameters,
properties, indices, etc.). This is especially important if you add a new method
to the collection.

## Unsolved issues

How to change the IRIS default instance name from `IRIS` to `REST CLIENT`
or `REST SERVER`?
