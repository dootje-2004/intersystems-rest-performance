Class Demo.Message Extends %Persistent
{

Property Id As %Integer;

Property PayloadStream As %Stream.GlobalCharacter;

Property PayloadString As %String(MAXLEN = 3641144);

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
<Value>PayloadStream</Value>
</Value>
<Value name="4">
<Value>PayloadString</Value>
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
