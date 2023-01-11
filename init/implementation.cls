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
		set t1 = $ztimestamp

		// Forward request to the production.
		set st = ##class(Ens.Director).CreateBusinessService("Demo.Service", .service)
		$$$ThrowOnError(st)

		// TODO: Can this call be made asynchronously? E.g. with  set st = service.ProcessInput(payload)
		set st = service.ProcessInput(payload, .result)
		$$$ThrowOnError(st)

		// Compose REST response.
		set response = {}.%Set("id",payload.%Get("id")).%Set("size", result)
		do ..%SetContentType("application/json")
		do ..%SetStatusCode(201)
		do response.%Set("status","OK")
		set t2 = $ztimestamp
		do ..%SetHeader("x-server-time", ($p(t2,",")-$p(t1,","))*86400+$p(t2,",",2)-$p(t1,",",2))
	} catch ex {
		set msg = "ERROR | code: " _ ex.Code
		_ $c(13,10) _ "name: " _ ex.Name
		_ $c(13,10) _ "location: " _ ex.Location
		_ $c(13,10) _ "data: " _ ex.Data
		do ..%SetStatusCode(500)
		do response.%Set("status", msg)
	}
	return response
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
ClassMethod PrepareResponse() As %Status
{
    do ..%SetHeader("Content-Type", "text/plain")
	do ..%SetStatusCode(200)
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
	do ..PrepareResponse()
	return "OK"
}

}
