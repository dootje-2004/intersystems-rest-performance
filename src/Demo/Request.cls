Class Demo.Request Extends Ens.Request
{

Property Id As %Integer;

Property MessageStream As %Stream.GlobalCharacter;

Property MessageString As %String(MAXLEN = 3641144);

Storage Default
{
<Data name="RequestDefaultData">
<Subscript>"Request"</Subscript>
<Value name="1">
<Value>Id</Value>
</Value>
<Value name="2">
<Value>MessageStream</Value>
</Value>
<Value name="3">
<Value>MessageString</Value>
</Value>
</Data>
<DefaultData>RequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
