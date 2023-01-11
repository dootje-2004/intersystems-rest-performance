Class Demo.Service Extends Ens.BusinessService
{

Property Sync As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "Sync:Basic";

/// Accepts a dynamic object, forwards it to <class>Demo.Process</class> and returns the length of the payload message.
/// Forwarding is synchronous or asynchronous, depending on the value of the <property>Async</property> setting.
Method OnProcessInput(input As %RegisteredObject, Output output As %RegisteredObject) As %Status
{
    set request = ##class(Demo.Request).%New()
    // Note that request.%FromJSON() will not work for messages larger than MAXSTRING.
    set request.Id = input.id
    set request.Message = input.%Get("message",,"stream")
    set output = request.Message.SizeGet()

    if ..Sync = 1 {
        set st = ..SendRequestSync("Demo.Process", request, .response)
    } else {
        set st = ..SendRequestAsync("Demo.Process", request)
    }
    quit $$$OK
}

}
