Include %occIO

/// This class contains the methods for the demo's implementation class,
/// as well as the code to copy them there.
Class Demo.Implementation Extends %REST.Impl
{

/// Loops over all methods in this class (with the exception of itself) and copies
/// them to the class <var>className</var>.
ClassMethod CopyMethods(className As %String) As %Status
{
	set status = $$$OK
	set sources = ##class(%Dictionary.ClassDefinition).%OpenId($$$CurrentClass).Methods

	// Loop over all methods (sources) is this class.
	set sourceKey = ""
	for {
		set item = sources.GetNext(.sourceKey)
		if sourceKey = "" quit // We are done looping.
		if item.Name = $$$CurrentMethod continue // Skip this method.

		set class = ##class(%Dictionary.ClassDefinition).%OpenId(className)
		if class = "" {
			set status = $system.Status.Error(5351, className)
			quit
		}

		// Find the method with the same name in the target class.
		set targetKey = ""
		for {
			set target = class.Methods.GetNext(.targetKey)
			if targetKey = "" quit // End of the list.
			if target.Name = item.Name quit
		}

		if targetKey = "" {
			// The target class does not have a method with the source's name, so we append a new method.
			set targetKey = class.Methods.Count() + 1
			// TODO: Is there a simpler way to count all children of a class definition?
			set seq = class.ForeignKeys.Count() + class.Indices.Count() + class.Methods.Count() + class.Parameters.Count() + class.Projections.Count()
			+ class.Properties.Count() + class.Queries.Count() + class.Storages.Count() + class.Triggers.Count() + class.UDLTexts.Count() + class.XDatas.Count() + 1
		} else {
			set seq = ##class(%Dictionary.MethodDefinition).%OpenId(className _ "||" _ item.Name).SequenceNumber
		}

		set source = ##class(%Dictionary.MethodDefinition).%OpenId($$$CurrentClass _ "||" _ item.Name)
		set target = source.%ConstructClone()
		set target.parent = className
		set target.SequenceNumber = seq

		set status = class.Methods.SetAt(target, targetKey) // Replace or append the method.
		if status '= $$$OK quit

		set status = class.%Save()
		if status '= $$$OK quit
	}
	if status '= $$$OK return status
	set status = $system.OBJ.Compile(className)
	return status
}

/// Accepts a call; forwards message synchronously with stream payload.
ClassMethod forwardMessageSyncWithStreamPayload(message As %DynamicObject) As %DynamicObject
{
	set id = message.%Get("id")
	set ^testdata(id, 2) = $lb($ztimestamp, $job)
	set ^testdata(id, 0) = $lb(id, $job) // Allows for more uniform data handling.

	set ^testdata(id, 3) = $lb($ztimestamp, $job)
	set st = ##class(Ens.Director).CreateBusinessService("Demo.StreamService", .service)
	set st = service.ProcessInput(message, .result)
	set ^testdata(id, 10) = $lb($ztimestamp, $job)

	set response = {}.%Set("status", "OK").%Set("id", id).%Set("result", result)
	do ..PrepareResponse("json", 201)
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Accepts a call; forwards message synchronously with string payload.
ClassMethod forwardMessageSyncWithStringPayload(message As %DynamicObject) As %DynamicObject
{
	set id = message.%Get("id")
	set ^testdata(id, 2) = $lb($ztimestamp, $job)
	set ^testdata(id, 0) = $lb(id, $job)

	set ^testdata(id, 3) = $lb($ztimestamp, $job)
	set st = ##class(Ens.Director).CreateBusinessService("Demo.StringService", .service)
	set st = service.ProcessInput(message, .result)
	set ^testdata(id, 10) = $lb($ztimestamp, $job)

	set response = {}.%Set("status", "OK").%Set("id", id).%Set("result", result)
	do ..PrepareResponse("json", 201)
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Accepts a call; forwards message asynchronously with stream payload.
ClassMethod forwardMessageAsyncWithStreamPayload(message As %DynamicObject) As %DynamicObject
{
	set id = message.%Get("id")
	set ^testdata(id, 2) = $lb($ztimestamp, $job)
	set ^testdata(id, 0) = $lb(id, $job)

	set ^testdata(id, 3) = $lb($ztimestamp, $job)
	// Job off the insertion into the production and ignore Business Service's response.
	job ..CallServiceAsync("Demo.StreamService", message)

	set response = {}.%Set("status", "OK").%Set("id", id).%Set("result", "sent")
	do ..PrepareResponse("json", 201)
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Accepts a call; forwards message asynchronously with string payload.
ClassMethod forwardMessageAsyncWithStringPayload(message As %DynamicObject) As %DynamicObject
{
	set id = message.%Get("id")
	set ^testdata(id, 2) = $lb($ztimestamp, $job)
	set ^testdata(id, 0) = $lb(id, $job)

	set ^testdata(id, 3) = $lb($ztimestamp, $job)
	job ..CallServiceAsync("Demo.StringService", message)

	set response = {}.%Set("status", "OK").%Set("id", id).%Set("result", "sent")
	do ..PrepareResponse("json", 201)
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Accepts a call; stores message with string payload.
ClassMethod storeMessageWithStringPayload(message As %DynamicObject) As %DynamicObject
{
	set id = message.%Get("id")
	set ^testdata(id, 2) = $lb($ztimestamp, $job)
	set ^testdata(id, 0) = $lb(id, $job)

	set msg = message.%Get("message",,"string")
	&sql(INSERT INTO Demo.StringMessage(Id, Payload) VALUES(:id, :msg))

	set response = {}.%Set("status", "OK").%Set("id", id).%Set("result", "stored")
	do ..PrepareResponse("json", 201)
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Accepts a call; stores message with stream payload.
ClassMethod storeMessageWithStreamPayload(message As %DynamicObject) As %DynamicObject
{
	set id = message.%Get("id")
	set ^testdata(id, 2) = $lb($ztimestamp, $job)
	set ^testdata(id, 0) = $lb(id, $job)

	set msg = message.%Get("message",,"stream")
	&sql(INSERT INTO Demo.StreamMessage(Id, Payload) VALUES(:id, :msg))

	set response = {}.%Set("status", "OK").%Set("id", id).%Set("result", "stored")
	do ..PrepareResponse("json", 201)
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Processes the payload.
ClassMethod processRequest(payload As %DynamicObject) As %DynamicObject
{
	try {
		set id = payload.%Get("id")
		set ^testdata(id, 2) = $lb($ztimestamp, $job)
		set ^testdata(id, 0) = $lb(id, $job) // Allows for more uniform data handling.

		#; &sql(SELECT TOP 1 RestForwardingMethod, TreatAsString INTO :fwdMethod, :treat FROM Demo.Settings)
		#; Use ^restforwarding and ^treatment instead.

		if ^restforwarding = "STORE" {
			// Store message without sending it to the production.
			if ^treatment = 0 {
    			set msg = payload.%Get("message",,"stream")
				&sql(INSERT INTO Demo.Message(Id, PayloadStream) VALUES(:id,:msg))
			} else {
    			set msg = payload.%Get("message",,"string")
				&sql(INSERT INTO Demo.Message(Id, PayloadString) VALUES(:id,:msg))
			}
			set result = msg.SizeGet()
		} else {
			// Forward request to the production.
			set ^testdata(id, 3) = $lb($ztimestamp, $job)
			
			if ^restforwarding = "SYNC" {
				// The standard way.
				set st = ##class(Ens.Director).CreateBusinessService("Demo.Service", .service)
				$$$ThrowOnError(st)
				set st = service.ProcessInput(payload, .result)
				$$$ThrowOnError(st)
				set ^testdata(id, 10) = $lb($ztimestamp, $job)
			} elseif ^restforwarding = "ASYNC" {
				// Job off the insertion into the production and ignore Business Service's response.
				job ..CallServiceAsync(payload)
				set result = payload.%Get("message",,$case(^treatment,1:"string",:"stream")).SizeGet()
			}
		}

		// Compose REST response.
		set response = {}.%Set("id", id).%Set("size", result)
		do ..PrepareResponse("json", 201)
		do response.%Set("status","OK")
	} catch ex {
		set msg = "ERROR | code: " _ ex.Code
		_ $c(13,10) _ "name: " _ ex.Name
		_ $c(13,10) _ "location: " _ ex.Location
		_ $c(13,10) _ "data: " _ ex.Data
		do ..PrepareResponse( , 500)
		do response.%Set("status", msg)
	}
	set ^testdata(id, 11) = $lb($ztimestamp, $job)
	return response
}

/// Jobs off the call to a Business Service to simulate asynchronous calling.
/// The calls <var>result</var> argument is simply ignored.
ClassMethod CallServiceAsync(serviceName As %String, payload As %DynamicObject) As %Status
{
	set st = ##class(Ens.Director).CreateBusinessService(serviceName, .service)
	set st = service.ProcessInput(payload, .result)
	/// TODO: Uniform behavior: either "return" or "quit".
	return $$$OK
}

/// Returns all test settings.
ClassMethod getAllSettings() As %DynamicObject
{
	set output = {}

	// Client-side settings.
	set sql = "SELECT * FROM Demo.Settings"
	set resultset = ##class(%SQL.Statement).%ExecDirect(, .sql)
	do resultset.%GetRow(.row)
	set metadata = resultset.%GetMetadata()
	for i=2:1:metadata.columnCount // Skip first (ID) column.
	{
		do output.%Set( $zconvert(metadata.columns.GetAt(i).colName, "L") , $lg(row,i) )
	}

	// Host settings.
	set st = ##class(Ens.Config.Item).NameExists("Demo.Production", "Demo.StreamProcess", .id)
	set item = ##class(Ens.Config.Item).%OpenId(id)
	do output.%Set("bppoolsize", item.PoolSize)

	// Delay - https://community.intersystems.com/post/getting-production-settings-value
	set delay = ##class(Ens.Director).GetItemSettingValue("Demo.StreamProcess", "Host", "Delay")
	do output.%Set("bpdelay", delay)
	
	set sync = ##class(Ens.Director).GetItemSettingValue("Demo.StreamService","Host","Sync")
	do output.%Set("bssync", sync)

	do ..PrepareResponse("json")
	return output
}

/// Returns a setting.
ClassMethod getSetting(settingname As %String) As %String
{
	do ..PrepareResponse()
	
	if settingname = "bppoolsize"
	{
		set st = ##class(Ens.Config.Item).NameExists("Demo.Production", "Demo.StreamProcess", .id)
		set item = ##class(Ens.Config.Item).%OpenId(id)
		return item.PoolSize
	}

	if settingname = "bpdelay"
	{
		return ##class(Ens.Director).GetItemSettingValue("Demo.StreamProcess", "Host", "Delay")
	}

	if settingname = "bssync"
	{
		return ##class(Ens.Director).GetItemSettingValue("Demo.StreamService","Host","Sync")
	}

	set sql = "SELECT TOP 1 " _ settingname _ " FROM Demo.Settings"
	set rset = ##class(%SQL.Statement).%ExecDirect(, .sql)
	do rset.%Next()
	return rset.%GetData(1)
}

/// Stores a setting and updates the production, if applicable.
ClassMethod updateSetting(settingname As %String, settingvalue As %String) As %Stream.Object
{
	do ..PrepareResponse()

	if settingname = "bppoolsize"
	{
		for bpname = "Demo.StreamProcess","Demo.StringProcess"
		{
			set st = ##class(Ens.Config.Item).NameExists("Demo.Production", bpname, .id)
			set item = ##class(Ens.Config.Item).%OpenId(id)
			set item.PoolSize = settingvalue
			set st = item.%Save()
		}
		return "OK"
	}

	if settingname = "bpdelay"
	{
		set settings("Demo.StreamProcess", "Host", "Delay") = settingvalue
		set settings("Demo.StringProcess", "Host", "Delay") = settingvalue
		set st = ##class(Ens.Production).ApplySettings("Demo.Production", .settings)
		return "OK"
	}

	if settingname = "bssync"
	{
		set settings("Demo.StreamService", "Host", "Sync") = settingvalue
		set settings("Demo.StringService", "Host", "Sync") = settingvalue
		set st = ##class(Ens.Production).ApplySettings("Demo.Production", .settings)
		return "OK"
	}

	set sql = "UPDATE Demo.Settings SET " _ settingname _ " = ?"
	set st = ##class(%SQL.Statement).%ExecDirect( , .sql, settingvalue)

	// Stop unused production items, so we don't use up more resources than we need.
	if settingname = "payloaddatatype"
	{
		set st = ##class(Ens.Director).EnableConfigItem("Demo.StreamService", settingvalue = "stream" )
		set st = ##class(Ens.Director).EnableConfigItem("Demo.StreamProcess", settingvalue = "stream" )
		set st = ##class(Ens.Director).EnableConfigItem("Demo.StringService", settingvalue = "string" )
		set st = ##class(Ens.Director).EnableConfigItem("Demo.StringProcess", settingvalue = "string" )
	}
	return "OK"
}

/// Sets the response's content type and statuscode.
ClassMethod PrepareResponse(mimeType As %String = "text", statusCode As %Integer = 200) As %Status
{
    do ..%SetHeader("Content-Type", $case(mimeType,"json":"application/json",:"text/plain"))
	do ..%SetStatusCode(statusCode)
	return $$$OK
}

/// Removes all data points.
ClassMethod deleteData() As %DynamicObject
{
	kill ^testdata
	&sql(TRUNCATE TABLE Demo.StreamMessage)
	&sql(TRUNCATE TABLE Demo.StringMessage)
	do ..PrepareResponse()
	return "OK"
}

/// Returns all data points.
ClassMethod getData() As %DynamicObject
{
	set data = {}
	
	do ..AddDataSeries(.data, "id", 0, "string")
	do ..AddDataSeries(.data, "apiReqIn", 2,, "ts2uf")
	do ..AddDataSeries(.data, "apiReqOut", 3,, "ts2uf")
	do ..AddDataSeries(.data, "bsReqIn", 4,, "ts2uf")
	do ..AddDataSeries(.data, "bsReqOut", 5,, "ts2uf")
	do ..AddDataSeries(.data, "bpReqIn", 6,, "ts2uf")
	do ..AddDataSeries(.data, "bpRespOut", 7,, "ts2uf")
	do ..AddDataSeries(.data, "bsRespIn", 8,, "ts2uf")
	do ..AddDataSeries(.data, "bsRespOut", 9,, "ts2uf")
	do ..AddDataSeries(.data, "apiRespIn", 10,, "ts2uf")
	do ..AddDataSeries(.data, "apiRespOut", 11,, "ts2uf")

	do ..PrepareResponse("json")
	return data
}

/// Copies the measured series with index <var>tdIndex</var> from the <pre>^testdata</pre> global into an array named <var>dataObject</var>.<var>seriesName</var>.
/// The array values have JSON datatype <var>dataType</var>.
/// Before appending a measurement to the array, the method <var>func</var> is executed on the measured value.
/// This can be used for formatting the output. The method must accept the measured value as its first argument.
/// If the method is part of the current class, its name can be provided without prefix, with the <pre>..</pre> prefix, or with the full package name.
ClassMethod AddDataSeries(ByRef dataObject As %DynamicObject, seriesName As %String, tdIndex As %Integer, dataType As %String = "number", func As %String = "") As %Status
{
	do dataObject.%Set( seriesName, {"y":[], "pid":[] } )
	
	set cls = $piece( func, ".", 1, *-1 )
	if (cls = "") || (cls = ".") set cls = $classname()
	set mtd = $piece( func, ".", * )

	for key = 0:1:$order(^testdata(""),-1) {
		if $data( ^testdata( key, tdIndex) ) '= 0 {
			set $lb(value, pid) = ^testdata( key, tdIndex )
			if func '= "" set value = $classmethod( cls, mtd, value )
			do dataObject.%Get(seriesName).%Get("y").%Push( value, dataType )
			do dataObject.%Get(seriesName).%Get("pid").%Push( pid, "number")
		}
	}
	return $$$OK
}

/// Returns the Unix epoch with fractional seconds of a $HOROLOG value.
/// The default precision is 6 decimals, i.e. microseconds.
ClassMethod ts2uf(horolog As %String, precision As %Integer = 6) As %Double
{
	return $zdatetime(horolog,-2) _ "." _ $e($p($p(horolog,",",2),".",2),1,precision)
}

}
