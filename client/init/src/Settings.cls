Class Demo.Settings Extends (%Persistent, %Projection.AbstractProjection)
{

Property RequestCount As %Integer(MINVAL = 1);

Property RequestSize As %Integer(MINVAL = 1);

Property ServerDelay As %Integer(MINVAL = 0);

Property ServerPoolSize As %Integer(MINVAL = 1);

Property SyncMethod As %String(VALUELIST = ",Full,Mixed,None");

Projection Populate As Demo.Settings;

ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    // Fill the table with default values if it is empty.
    &sql(SELECT COUNT(*) INTO :cnt FROM Demo.Settings)
    if (cnt = 0) {
        &sql(INSERT INTO Demo.Settings(RequestCount, RequestSize, ServerDelay, ServerPoolSize, SyncMethod) VALUES (1, 1000, 3, 1, 'Full'))
    }
    quit $$$OK
}

Storage Default
{
<Data name="SettingsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RequestCount</Value>
</Value>
<Value name="3">
<Value>RequestSize</Value>
</Value>
<Value name="4">
<Value>ServerDelay</Value>
</Value>
<Value name="5">
<Value>ServerPoolSize</Value>
</Value>
<Value name="6">
<Value>SyncMethod</Value>
</Value>
</Data>
<DataLocation>^Demo.SettingsD</DataLocation>
<DefaultData>SettingsDefaultData</DefaultData>
<IdLocation>^Demo.SettingsD</IdLocation>
<IndexLocation>^Demo.SettingsI</IndexLocation>
<StreamLocation>^Demo.SettingsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
