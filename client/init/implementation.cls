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
	set class = ##class(%Dictionary.ClassDefinition).%OpenId(className)
	if class = "" quit $system.Status.Error(5351, className)

	// Loop over all methods (sources) is this class.
	set sourceKey = ""
	for {
		set source = sources.GetNext(.sourceKey)
		
		if sourceKey = "" quit // We are done looping.
		if source.Name = $$$CurrentMethod continue // Skip this method.

		// Loop over all methods (targets) in the target class until
		// we find one with the same name as the current source method.
		set targetKey = ""
		for {
			set target = class.Methods.GetNext(.targetKey)
			if targetKey = "" quit
			// Preserve the target method's sequenceNumber, or the IDE editor will get confused.
			set seq = target.SequenceNumber
			if target.Name = source.Name quit
		}

		if targetKey = "" {
			// The target class does not yet have a method with the source's name, so we append a new method.
			write "Create new target key ", targetKey,!
			set targetKey = class.Methods.Count() + 1
			set seq = targetKey
		}

		set target = source.%ConstructClone(1) // Deep copy.
		set target.parent = class

		set target.SequenceNumber = seq // Set or restore the sequence number.
		set status = class.Methods.SetAt(target, targetKey) // Replace or append the method.
		if status '= $$$OK quit
		set status = target.%Save()
		if status '= $$$OK quit
	}
	set status = class.%Save()
	if status '= $$$OK quit status
	set status = $system.OBJ.Compile(className)
	quit status
}

/// Returns the number of test requests.
ClassMethod getRequestCount() As %Integer
{
	&sql(SELECT TOP 1 RequestCount INTO :count FROM Demo.Settings)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "text/plain")
    quit count
}

/// Sets the number of test requests.
ClassMethod setRequestCount(count As %Integer) As %String
{
	&sql(UPDATE Demo.Settings SET RequestCount = :count)
    do ..%SetStatusCode(204)
	quit "OK"
}

/// Returns the payload size of a test request.
ClassMethod getRequestSize() As %Integer
{
	&sql(SELECT TOP 1 RequestSize INTO :size FROM Demo.Settings)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "text/plain")
    quit size
}

/// Sets the payload size of each test request.
ClassMethod setRequestSize(size As %Integer) As %String
{
	&sql(UPDATE Demo.Settings SET RequestSize = :size)
    do ..%SetStatusCode(204)
	quit "OK"
}

/// Returns the synchronization method.
ClassMethod getSyncMethod() As %String
{
	&sql(SELECT TOP 1 SyncMethod INTO :method FROM Demo.Settings)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "text/plain")
    quit method
}

/// Sets the synchronization method.
ClassMethod setSyncMethod(method As %String) As %String
{
	// TODO: Propagate sync method to server.
	&sql(UPDATE Demo.Settings SET SyncMethod = :method)
    do ..%SetStatusCode(204)
	quit "OK"
}

/// Returns the server delay (ms).
ClassMethod getServerDelay() As %Integer
{
	// Get setting from server.
	set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPServer")
    set req.Port = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPPort")
    set st = req.Get("/demo/delay")
	set delay = req.HttpResponse.Data.Read()
	
	&sql(UPDATE Demo.Settings SET ServerDelay = :delay)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "text/plain")
    quit delay
}

/// Sets the server delay (ms).
ClassMethod setServerDelay(delay As %Integer) As %String
{
	&sql(UPDATE Demo.Settings SET ServerDelay = :delay)

	// Propagate setting to server.
	set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPServer")
    set req.Port = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPPort")
    set st = req.Put("/demo/delay/" _ delay)
    
	do ..%SetStatusCode(204)
	quit "OK"
}

/// Returns the poolsize of the server's Business Process.
ClassMethod getServerPoolsize() As %Integer
{
	// Get setting from server.
	set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPServer")
    set req.Port = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPPort")
    set st = req.Get("/demo/poolsize")
	set poolsize = req.HttpResponse.Data.Read()
	
	&sql(UPDATE Demo.Settings SET ServerPoolSize = :poolsize)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "text/plain")
    quit poolsize
}

/// Sets the poolsize of the server's Business Process.
ClassMethod setServerPoolsize(poolsize As %Integer) As %String
{
	&sql(UPDATE Demo.Settings SET ServerPoolSize = :poolsize)

	// Propagate setting to server.
	set req = ##class(%Net.HttpRequest).%New()
    set req.Server = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPServer")
    set req.Port = ##class(Ens.Director).GetItemSettingValue("Demo.ClientOperation","Adapter","HTTPPort")
    set st = req.Put("/demo/poolsize/" _ poolsize)
    
	&sql(UPDATE Demo.Settings SET ServerPoolSize = :poolsize)
	do ..%SetStatusCode(204)
	quit "OK"
}

/// Initiates a test run on the server.
ClassMethod startTest() As %String
{
    do ..%SetHeader("Content-Type", "text/plain")

	// Check if a test is running.
	if ($g(^testrun) = 1) {
	    do ..%SetStatusCode(503)
		quit "BUSY"
	}
	set ^testrun = 1
	job ##class(Demo.ClientService).RunTest()
    do ..%SetStatusCode(200)
	quit "OK"
}

/// Returns test status (BUSY or DONE).
ClassMethod getTestStatus() As %String
{
	set result = $case($d(^testrun), 0:"DONE", :"BUSY")
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type","text/plain")
	quit result
}

/// Returns the time-related data series.
ClassMethod getDataSeries() As %DynamicObject
{
	set tStatement = ##class(%SQL.Statement).%New()
	set sql = 5
	set sql(1) = "SELECT MIN(Id), MAX(Id), AVG(ServerTime) * 1000, AVG(NetworkTime) * 1000"
	set sql(2) = "FROM Demo.Measurement"
	set sql(3) = "GROUP BY FLOOR((Id-1)/("
	set sql(4) = "SELECT CAST(CASE WHEN COUNT(*) < 50 THEN 50 ELSE COUNT(*) END/50 AS INT) FROM Demo.Measurement)"
	set sql(5) = ")"
	set rset = tStatement.%ExecDirect(, .sql)
	set id = [], networkTime = [], serverTime = []
	
	while rset.%Next() {
		if (rset.%GetData(1) = rset.%GetData(2)) {
			do id.%Push(rset.%GetData(1), "string")
		} else {
			do id.%Push(rset.%GetData(1) _ "-" _ rset.%GetData(2), "string")
		}
		do serverTime.%Push(rset.%GetData(3), "number")
		do networkTime.%Push(rset.%GetData(4), "number")
	}
	quit {}.%Set("id",id).%Set("serverTime",serverTime).%Set("networkTime",networkTime)
}

/// Returns the average network time for the test.
ClassMethod getAverageNetworkTime() As %Double
{
	&sql(SELECT AVG(NetworkTime) * 1000 INTO :result FROM Demo.Measurement)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type","text/plain")
	quit result
}

/// Returns the average server processing time for the test.
ClassMethod getAverageServerTime() As %Double
{
	&sql(SELECT AVG(ServerTime) * 1000 INTO :result FROM Demo.Measurement)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type","text/plain")
	quit result
}

}
