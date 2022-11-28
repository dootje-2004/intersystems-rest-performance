Class Demo.ClientService Extends Ens.BusinessService [ DependsOn = Demo.ClientOperation ]
{

ClassMethod RunTest(count As %Integer = 1, payloadSize As %Integer = 5) As %Status
{
    for i=1:1:count {
        // If we create the Business Service outside this block, all visual traces are combined into one.
        set st = ##class(Ens.Director).CreateBusinessService($this,.serv)
        if st '= $$$OK return st
        set req = ##class(Demo.Request).%New()
        set req.Id = i
        set len = payloadSize
        while len > 0 {
            set st = req.Message.Write("DEMO ")
            if st '= $$$OK return st
            set len = len - 5
        }
        set st = serv.SendRequestSync("Demo.ClientOperation", req, .resp)
        if st '= $$$OK return st
    }
    quit st
}

}
