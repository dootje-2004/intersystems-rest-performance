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
	if status '= $$$OK quit status
	set status = $system.OBJ.Compile(className)
	quit status
}

/// Processes the payload.
ClassMethod processRequest(payload As %DynamicObject) As %DynamicObject
{
	try {
		set id = payload.%Get("id")
		set ^testdata(id, 2) = $ztimestamp
		set ^testdata(id, 0) = id // Allows for more uniform data handling.

		&sql(SELECT TOP 1 RestForwardingMethod INTO :fwdMethod FROM Demo.Settings)

		if fwdMethod = "STORE" {
			// Store message without sending it to the production.
    		set msg = payload.%Get("message",,"stream")
			&sql(INSERT INTO Demo.Message(Id, Payload) VALUES(:id,:msg))
			set result = msg.SizeGet()
		} else {
			// Forward request to the production.
			set ^testdata(id, 3) = $ztimestamp
			
			if fwdMethod = "SYNC" {
				// The standard way.
				set st = ##class(Ens.Director).CreateBusinessService("Demo.Service", .service)
				$$$ThrowOnError(st)
				set st = service.ProcessInput(payload, .result)
				$$$ThrowOnError(st)
				set ^testdata(id, 10) = $ztimestamp
			} elseif fwdMethod = "ASYNC" {
				// Job off the insertion into the production and ignore Business Service's response.
				job ..CallServiceAsync(payload)
				set result = payload.%Get("message",,"stream").SizeGet()
			} else {
				// Throw exception: unknown forwarding method.
				throw ##class(%Exception.StatusException).%New("Unknown option: %1",,,$lb(fwdMethod))
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
	set ^testdata(id, 11) = $ztimestamp
	return response
}

/// Jobs off the call to a Business Service to simulate asynchronous calling.
/// The calls <var>result</var> argument is simply ignored.
ClassMethod CallServiceAsync(payload As %DynamicObject) As %Status
{
	set st = ##class(Ens.Director).CreateBusinessService("Demo.Service", .service)
	$$$ThrowOnError(st)
	set st = service.ProcessInput(payload, .result)
	$$$ThrowOnError(st)
	/// TODO: Uniform behavior: either "return" or "quit".
	quit $$$OK
}

/// Returns the number of test requests.
ClassMethod getCount() As %Integer
{
	&sql(SELECT TOP 1 RequestCount INTO :count FROM Demo.Settings)
	do ..PrepareResponse()
	return count
}

/// Stores the number of test requests.
ClassMethod setCount(count) As %String
{
	&sql(Update Demo.Settings SET RequestCount = :count FROM Demo.Settings)
	do ..PrepareResponse()
	return "OK"
}

/// Returns the size of each request's payload.
ClassMethod getSize() As %Integer
{
	&sql(SELECT TOP 1 RequestSize INTO :size FROM Demo.Settings)
	do ..PrepareResponse()
	return size
}

/// Stores the payload size of the test requests.
ClassMethod setSize(size) As %String
{
	&sql(Update Demo.Settings SET RequestSize = :size FROM Demo.Settings)
	do ..PrepareResponse()
	return "OK"
}

/// Returns the client synchronization method.
ClassMethod getClientSync() As %Integer
{
	&sql(SELECT TOP 1 ClientSync INTO :sync FROM Demo.Settings)
	do ..PrepareResponse()
	return sync
}

/// Stores the client synchronization method.
ClassMethod setClientSync(sync As %Boolean) As %String
{
	&sql(UPDATE Demo.Settings SET ClientSync = :sync)
	do ..PrepareResponse()
	return "OK"
}

/// Returns the processing delay of the server's Business Process.
ClassMethod getDelay() As %Integer
{
	// https://community.intersystems.com/post/getting-production-settings-value
	set delay = ##class(Ens.Director).GetItemSettingValue("Demo.Process","Host","Delay")
	do ..PrepareResponse()
	return delay
}

/// Sets the processing delay of the server's Business Process.
ClassMethod setDelay(delay As %Integer) As %String
{
	set settings("Demo.Process", "Host", "Delay") = delay
	set st = ##class(Ens.Production).ApplySettings("Demo.Production",.settings)
	do ..PrepareResponse()
	return "OK"
}

/// Returns the poolsize of the server's Business Process.
ClassMethod getPoolsize() As %Integer
{
	set st = ##class(Ens.Config.Item).NameExists("Demo.Production","Demo.Process",.id)
	set item = ##class(Ens.Config.Item).%OpenId(id)
	do ..PrepareResponse()
  	return item.PoolSize
}

/// Sets the poolsize of the server's Business Process.
ClassMethod setPoolsize(poolsize As %Integer) As %String
{
	set st = ##class(Ens.Config.Item).NameExists("Demo.Production","Demo.Process",.id)
	set item = ##class(Ens.Config.Item).%OpenId(id)
	set item.PoolSize = poolsize
	set st = item.%Save()
	do ..PrepareResponse()
	return "OK"
}

/// Sets the response's content type and statuscode.
ClassMethod PrepareResponse(mimeType As %String = "text", statusCode As %Integer = 200) As %Status
{
    do ..%SetHeader("Content-Type", $case(mimeType,"json":"application/json",:"text/plain"))
	do ..%SetStatusCode(statusCode)
	return $$$OK
}

/// Returns the Sync settings of the Business Service.
ClassMethod getServiceSync() As %Integer
{
	set sync = ##class(Ens.Director).GetItemSettingValue("Demo.Service","Host","Sync")
	do ..PrepareResponse()
	return sync
}

/// Sets the Sync parameter of the Business Service.
ClassMethod setServiceSync(sync As %Integer) As %String
{
	set settings("Demo.Service", "Host", "Sync") = sync
	set st = ##class(Ens.Production).ApplySettings("Demo.Production",.settings)
	do ..PrepareResponse()
	return "OK"
}

/// Returns the forwarding method of the REST class.
ClassMethod getForwardingMethod() As %String
{
	&sql(SELECT TOP 1 RestForwardingMethod INTO :method FROM Demo.Settings)
	do ..PrepareResponse()
	return method
}

/// Stores the forwarding method of the REST class.
ClassMethod setForwardingMethod(method As %String) As %String
{
	&sql(UPDATE Demo.Settings SET RestForwardingMethod = :method)
	if SQLCODE = 0 {
		do ..PrepareResponse()
		return "OK"
	} else {
		// TODO: Decent error message.
		do ..PrepareResponse( , 400)
		return "ERROR. SQLCODE = " _ SQLCODE
	}
}

/// Removes all data points.
ClassMethod deleteData() As %DynamicObject
{
	kill ^testdata
	&sql(TRUNCATE TABLE Demo.Message)
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
	do dataObject.%Set( seriesName, [] )
	
	set cls = $piece( func, ".", 1, *-1 )
	if (cls = "") || (cls = ".") set cls = $classname()
	set mtd = $piece( func, ".", * )

	for key = 0:1:$order(^testdata(""),-1) {
		if $data( ^testdata( key, tdIndex) ) '= 0 {
			if func = "" {
				do dataObject.%Get(seriesName).%Push( ^testdata( key, tdIndex), dataType )
			} else {
				do dataObject.%Get(seriesName).%Push( $classmethod( cls, mtd, ^testdata( key, tdIndex) ), dataType )
			}
		}
	}
	quit $$$OK
}

/// Returns the Unix epoch with fractional seconds of a $HOROLOG value.
/// The default precision is 6 decimals, i.e. microseconds.
ClassMethod ts2uf(horolog As %String, precision As %Integer = 6) As %Double
{
	return $zdatetime(horolog,-2) _ "." _ $e($p($p(horolog,",",2),".",2),1,precision)
}

}
