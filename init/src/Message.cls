Class Demo.Message Extends %Persistent
{

Property Id As %Integer;

Property Payload As %Stream.GlobalCharacter;

Storage Default
{
<Data name="MessageDefaultData">
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
<DataLocation>^Demo.MessageD</DataLocation>
<DefaultData>MessageDefaultData</DefaultData>
<IdLocation>^Demo.MessageD</IdLocation>
<IndexLocation>^Demo.MessageI</IndexLocation>
<StreamLocation>^Demo.MessageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
