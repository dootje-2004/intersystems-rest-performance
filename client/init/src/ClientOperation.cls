Class Demo.ClientOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

XData MessageMap
{
<MapItems>
    <MapItem MessageType = "Demo.Request">
        <Method>ForwardWithTimestamp</Method>
    </MapItem>
</MapItems>
}

/// Accepts a single <class>Demo.Request</class> and forwards it to the server.
/// The time it takes to obtain a response is stored in <class>Demo.Metrics</class>.
Method ForwardWithTimestamp(request As Demo.Request, Output response As Demo.Response) As %Status
{
    // We use the HttpRequest object to send the HTTP request, instead of inserting it into the .Post() method of the adapter
    // (which is necessary if you want to set the Content-Type header).
    set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ..Adapter.HTTPServer
    set req.Port = ..Adapter.HTTPPort
    set req.ContentType = "application/json"
     
    set st = request.%JSONExportToStream(req.EntityBody)
    $$$TRACE("Exporting request to entity body: " _ st)
    if st '= $$$OK return st
    set t1 = $ztimestamp
    set st = req.Post(..Adapter.URL)
    $$$TRACE("POST status: " _ st)
    if st '= $$$OK return st
    set t2 = $ztimestamp
    
    // Save metrics.
    set metric = ##class(Demo.Metrics).%New()
    set metric.Id = request.Id
    set metric.ServerTime = req.HttpResponse.GetHeader("x-server-time")
    set metric.NetworkTime = ($p(t2,",")-$p(t1,","))*86400+$p(t2,",",2)-$p(t1,",",2) - metric.ServerTime
    set st = metric.%Save()
    if st '= $$$OK return st

    set resp = req.HttpResponse.Data.Read(, .st)
    if st '= $$$OK return st
    $$$TRACE("server response: " _ resp)
    set response = ##class(Demo.Response).%New()
    set st = response.%JSONImport(resp)
    quit st
}

}
