/// Persists the test settings, so the UI can show them.
Class Demo.Settings Extends (%Persistent, %Projection.AbstractProjection)
{

/// Indicates how the browser calls the API.
Property ClientSync As %Boolean;

/// Number of test requests.
Property CallCount As %Integer(MINVAL = 1);

/// Size (in characters) of each request's payload.
Property PayloadSize As %Integer(MINVAL = 1);

/// Indicates how the REST implementation class forwards requests.
Property RestForwarding As %String(VALUELIST = ",SYNC,ASYNC,STORE");

/// Treat request payload as a string (1) or a stream (0).
Property PayloadDatatype As %String(VALUELIST = ",stream,string");

Projection Populate As Demo.Settings;

ClassMethod CreateProjection(cls As %String, ByRef params) As %Status
{
    // Fill the table with default values if it is empty.
    &sql(SELECT COUNT(*) INTO :cnt FROM Demo.Settings)
    if (cnt = 0) {
        &sql(INSERT INTO Demo.Settings(
            ClientSync, CallCount, PayloadSize, RestForwarding, PayloadDatatype) 
            VALUES (1, 100, 1000, 'SYNC', 'string' )
        )
    }
    return $$$OK
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
<Value>CallCount</Value>
</Value>
<Value name="4">
<Value>PayloadSize</Value>
</Value>
<Value name="5">
<Value>RestForwarding</Value>
</Value>
<Value name="6">
<Value>PayloadDatatype</Value>
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
