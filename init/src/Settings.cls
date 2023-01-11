Class Demo.Settings Extends (%Persistent, %Projection.AbstractProjection)
{

/// Indicates how the browser calls the API.
Property ClientSync As %Boolean;

/// Business Process poolsize.
Property PoolSize As %Integer(MINVAL = 1);

/// Number of test requests.
Property RequestCount As %Integer(MINVAL = 1);

/// Size (in characters) of each request's payload.
Property RequestSize As %Integer(MINVAL = 1);

/// Indicates how the REST implementation class forwards requests.
Property RestForwardingMethod As %String(VALUELIST = ",SYNC,ASYNC,STORE");

Projection Populate As Demo.Settings;

ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    // Fill the table with default values if it is empty.
    &sql(SELECT COUNT(*) INTO :cnt FROM Demo.Settings)
    if (cnt = 0) {
        &sql(INSERT INTO Demo.Settings(ClientSync, PoolSize, RequestCount, RequestSize, RestForwardingMethod) VALUES (1, 1, 100, 1000, 'SYNC'))
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
<Value>ClientSync</Value>
</Value>
<Value name="3">
<Value>PoolSize</Value>
</Value>
<Value name="4">
<Value>RequestCount</Value>
</Value>
<Value name="5">
<Value>RequestSize</Value>
</Value>
<Value name="6">
<Value>RestForwardingMethod</Value>
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
