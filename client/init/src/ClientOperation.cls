Class Demo.ClientOperation Extends Ens.BusinessOperation [ DependsOn = (Demo.Request, Demo.Response) ]
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

Method ForwardWithTimestamp(request As Demo.Request, Output response As Demo.Response) As %Status
{
    // We use the HttpRequest object to send the HTTP request, instead of inserting it into the .Post() method of the adapter
    // (which is necessary if you want to set the Content-Type header).
    set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ..Adapter.HTTPServer
    set req.Port = ..Adapter.HTTPPort
    set req.ContentType = "application/json"
 
    set st = request.%JSONExportToStream(req.EntityBody)
    if st '= $$$OK return st
    set st = req.SetHeader("t1", ..Timestamp())
    if st '= $$$OK return st
    set st = req.Post(..Adapter.URL)
    $$$TRACE("POST status: " _ st)
    if st '= $$$OK return st
    // TODO: Add fourth timestamp and store results.

    set resp = req.HttpResponse.Data.Read(, .st)
    if st '= $$$OK return st
    $$$TRACE("server response: " _ resp)
    set response = ##class(Demo.Response).%New()
    set st = response.%JSONImport(resp)
    quit st
}

/// Returns the current timestamp in microsecond precision.
ClassMethod Timestamp() As %String
{
    return $zdatetime($ztimestamp, 3, 7, 6)
}

}
