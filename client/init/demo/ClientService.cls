Class Demo.ClientService Extends Ens.BusinessService [ DependsOn = Demo.ClientOperation ]
{

ClassMethod RunTest(pCount As %Integer) As %Status
{
    // TODO: How do we kick off this method at production startup?
    for i=1:1:pCount {
        // If we create the Business Service outside this block, all visual traces are combined into one.
        set tStatus = ##class(Ens.Director).CreateBusinessService($this,.tService)
        set tRequest = ##class(Demo.Request).%New()
        set tRequest.Id = i
        set tRequest.Message = "DEMO"
        set tStatus = tService.SendRequestAsync("Demo.ClientOperation", tRequest)
        if tStatus '= 1 quit
    }
    quit tStatus
}

}
