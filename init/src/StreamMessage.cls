Class Demo.StreamMessage Extends %Persistent
{

Property Id As %Integer;

Property Payload As %Stream.GlobalCharacter;

Storage Default
{
<Data name="StreamMessageDefaultData">
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
<DataLocation>^Demo.StreamMessageD</DataLocation>
<DefaultData>StreamMessageDefaultData</DefaultData>
<IdLocation>^Demo.StreamMessageD</IdLocation>
<IndexLocation>^Demo.StreamMessageI</IndexLocation>
<StreamLocation>^Demo.StreamMessageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
