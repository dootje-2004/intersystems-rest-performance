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
    set tMessage = {}.%Set("id", pRequest.Id).%Set("timestamp", $ZDATETIME($ZTIMESTAMP, 3, 7, 6)).%Set("message", pRequest.Message).%ToJSON()
    $$$TRACE(tMessage)
    // quit ..Adapter.Post(.resp, , json) // DOES NOT WORK: Content-Type header is not accessible, can't be set to "application/json"

    set tRequest = ##class(%Net.HttpRequest).%New()
    set tRequest.Server = ..Adapter.HTTPServer
    set tRequest.Port = ..Adapter.HTTPPort
    do tRequest.EntityBody.Write(tMessage)
    set tRequest.ContentType = "application/json"
    set tStatus =  tRequest.Post(..Adapter.URL)
    $$$TRACE(tRequest.HttpResponse.Data.Read())
    quit tStatus
}

}
