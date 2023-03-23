Class Demo.StringMessage Extends %Persistent
{

Property Id As %Integer;

Property Payload As %String(MAXLEN = 3641144);

Storage Default
{
<Data name="StringMessageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Id</Value>
</Value>
<Value name="3">
<Value>Payload</Value>
</Value>
</Data>
<DataLocation>^Demo.StringMessageD</DataLocation>
<DefaultData>StringMessageDefaultData</DefaultData>
<IdLocation>^Demo.StringMessageD</IdLocation>
<IndexLocation>^Demo.StringMessageI</IndexLocation>
<StreamLocation>^Demo.StringMessageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
