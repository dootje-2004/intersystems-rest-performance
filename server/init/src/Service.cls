Class Demo.Service Extends Ens.BusinessService
{

Property Async As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "Async:Basic";

Method OnProcessInput(input As %RegisteredObject, Output output As %RegisteredObject) As %Status
{
    set request = ##class(Demo.Request).%New()
    set request.Id = input.%Get("id")
    set st = request.Message.Write(input.%Get("message"))
    if ..Async = 1 {
        set st = ..SendRequestAsync("Demo.Process", request)
    } else {
        set st = ..SendRequestSync("Demo.Process", request, .reponse)
    }
    quit $$$OK
}

}
