Class Demo.ClientOperation Extends Ens.BusinessOperation [ DependsOn = Demo.Request ]
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

Method ForwardWithTimestamp(pRequest As Demo.Request, Output pResponse As Ens.Response) As %Status
{
    set msg = {}.%Set("id", pRequest.Id).%Set("timestamp", $ZDATETIME($ZTIMESTAMP, 3, 7, 6)).%Set("message", pRequest.Message).%ToJSON()
    $$$TRACE(msg)
    // quit ..Adapter.Post(.resp, , json) // DOES NOT WORK: Content-Type header is not accessible, can't be set to "application/json"

    set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ..Adapter.HTTPServer
    set req.Port = ..Adapter.HTTPPort
    do req.EntityBody.Write(msg)
    set req.ContentType = "application/json"
    set sc =  req.Post(..Adapter.URL)
    $$$TRACE(req.HttpResponse.Data.Read())
    quit sc
}

}
