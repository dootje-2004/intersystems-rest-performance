Class Demo.Response Extends (Ens.Response, %JSON.Adaptor)
{

/// The ID of the original request.
Property Id As %Integer(%JSONFIELDNAME = "id");

/// The server's return status.
Property Status As %String(%JSONFIELDNAME = "status");

/// The size of the payload reported by the server.
Property Size As %Integer(%JSONFIELDNAME = "size");

Storage Default
{
<Data name="ResponseDefaultData">
<Subscript>"Response"</Subscript>
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>Status</Value>
</Value>
<Value name="3">
<Value>Size</Value>
</Value>
</Data>
<DefaultData>ResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
