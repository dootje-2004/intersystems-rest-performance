Class Demo.Service Extends Ens.BusinessService
{

Property Sync As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "Sync:Basic";

/// Accepts a dynamic object, forwards it to <class>Demo.Process</class> and returns the length of the payload message.
/// Forwarding is synchronous or asynchronous, depending on the value of the <property>Async</property> setting.
Method OnProcessInput(input As %RegisteredObject, Output output As %RegisteredObject) As %Status
{
    set ^testdata(input.id, 4) = $ztimestamp
    set request = ##class(Demo.Request).%New()
    // Note that request.%FromJSON() will not work for messages larger than MAXSTRING.
    set request.Id = input.id
    set request.Message = input.%Get("message",,"stream")

    set ^testdata(input.id, 5) = $ztimestamp
    if ..Sync = 1 {
        set st = ..SendRequestSync("Demo.Process", request, .response)
        set ^testdata(input.id, 8) = $ztimestamp
    } else {
        set st = ..SendRequestAsync("Demo.Process", request)
        set ^testdata(input.id, 8) = ""
    }
    set output = request.Message.SizeGet()
    set ^testdata(input.id, 9) = $ztimestamp
    quit $$$OK
}

}
