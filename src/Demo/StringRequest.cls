Class Demo.StringRequest Extends Ens.Request
{

Property Id As %Integer;

Property Payload As %String(MAXLEN = 3641144);

Storage Default
{
<Data name="StringRequestDefaultData">
<Subscript>"StringRequest"</Subscript>
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>StringRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
