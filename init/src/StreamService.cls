Class Demo.StreamService Extends Ens.BusinessService
{

Property Sync As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "Sync:Basic";

/// Accepts a dynamic object, forwards it to <class>Demo.Process</class> and returns a confirmation text.
/// Forwarding is synchronous or asynchronous, depending on the value of the <property>Sync</property> setting.
Method OnProcessInput(input As %RegisteredObject, Output output As %RegisteredObject) As %Status
{
    set ^testdata(input.id, 4) = $lb($ztimestamp, $job)
    set request = ##class(Demo.StreamRequest).%New()
    set request.Id = input.id
    set request.Payload = input.%Get("message",,"stream")

    set ^testdata(input.id, 5) = $lb($ztimestamp, $job)
    
    if ..Sync = 1 {
        set st = ..SendRequestSync("Demo.StreamProcess", request, .response)
        set ^testdata(input.id, 8) = $lb($ztimestamp, $job)
    } else {
        set st = ..SendRequestAsync("Demo.StreamProcess", request)
    }

    set output = "request sent"
    set ^testdata(input.id, 9) = $lb($ztimestamp, $job)
    quit $$$OK
}

}
