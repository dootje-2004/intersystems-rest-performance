Class Demo.Service Extends Ens.BusinessService
{

Property Sync As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "Sync:Basic";

/// Accepts a dynamic object, forwards it to <class>Demo.Process</class> and returns the length of the payload message.
/// Forwarding is synchronous or asynchronous, depending on the value of the <property>Async</property> setting.
Method OnProcessInput(input As %RegisteredObject, Output output As %RegisteredObject) As %Status
{
    set ^testdata(input.id, 4) = $lb($ztimestamp, $job)
    set request = ##class(Demo.Request).%New()
    set request.Id = input.id
    
    #; &sql(SELECT TOP 1 TreatAsString INTO :treat FROM Demo.Settings)
    if ^treatAsString = 0 {
        // Note that request.%FromJSON() will not work for messages larger than MAXSTRING.
        set request.MessageStream = input.%Get("message",,"stream")
    } else {
        set request.MessageString = input.%Get("message",,"string")
    }

    set ^testdata(input.id, 5) = $lb($ztimestamp, $job)
    if ..Sync = 1 {
        set st = ..SendRequestSync("Demo.Process", request, .response)
        set ^testdata(input.id, 8) = $lb($ztimestamp, $job)
    } else {
        set st = ..SendRequestAsync("Demo.Process", request)
    }
    if ^treatAsString = 0 {
        set output = request.MessageStream.SizeGet()
    } else {
        set output = $length(request.MessageString)
    }
    set ^testdata(input.id, 9) = $lb($ztimestamp, $job)
    quit $$$OK
}

}
