Class Demo.ClientService Extends Ens.BusinessService
{

ClassMethod RunTest(count As %Integer = 1, payloadSize As %Integer = 5) As %Status
{
    // Remove old measurements.
    &sql(TRUNCATE TABLE Demo.Measurement)
    
    // To speed up the test, create the payload once and reuse it for each request.
    set payload = ##class(%Stream.TmpCharacter).%New()
    for i=1:10:payloadSize {
        set st = payload.Write("REST DEMO ")
        if st '= $$$OK return st
    }

    for i=1:1:count {
        // If we create the Business Service outside this block, all visual traces are combined into one.
        set st = ##class(Ens.Director).CreateBusinessService($this,.serv)
        if st '= $$$OK return st
        set req = ##class(Demo.Request).%New()
        set req.Id = i
        set req.Message = payload
        set st = serv.SendRequestSync("Demo.ClientOperation", req, .resp)
        if st '= $$$OK return st
    }
    quit st
}

}
