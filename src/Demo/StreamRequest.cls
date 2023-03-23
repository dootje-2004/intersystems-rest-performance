Class Demo.StreamRequest Extends Ens.Request
{

Property Id As %Integer;

Property Payload As %Stream.GlobalCharacter;

Storage Default
{
<Data name="StreamRequestDefaultData">
<Subscript>"StreamRequest"</Subscript>
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>StreamRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
