Class Demo.Request Extends Ens.Request
{

Property Id As %Integer;

Property Message As %Stream.GlobalCharacter;

Storage Default
{
<Data name="RequestDefaultData">
<Subscript>"Request"</Subscript>
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>Message</Value>
</Value>
</Data>
<DefaultData>RequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
