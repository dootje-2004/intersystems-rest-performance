Include %occIO

/// This class contains the methods for the demo's implementation class,
/// as well as the code to copy them there.
Class Demo.Implementation Extends %REST.Impl
{

/// Processes the payload.
ClassMethod Test() As %Status
{
	quit $$$OK
}

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
			// Preserve the target method's sequenceNumber, or the editor will get confused.
			set seq = target.SequenceNumber
			if target.Name = source.Name quit
		}

		if targetKey = "" {
			// The target class does not yet have a method with the source's name, so we append a new method.
			set targetKey = class.Methods.Count() + 1
			set seq = targetKey
		}

		set target = source.%ConstructClone(1) // Deep copy.
		set target.SequenceNumber = seq // Set or restore the sequence number.
		set status = class.Methods.SetAt(target, targetKey) // Replace or append the method.
		if status '= $$$OK quit
		set status = target.%Save()
		if status '= $$$OK quit
		set status = class.%Save()
	}
	if status '= $$$OK quit status
	set status = $system.OBJ.Compile(className)
	quit status
}

/// Returns the number of test requests.
ClassMethod getRequestCount() As %Integer
{
	&sql(SELECT TOP 1 RequestCount INTO :count FROM Demo.Settings)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "plain/text")
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
    do ..%SetHeader("Content-Type", "plain/text")
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
    do ..%SetHeader("Content-Type", "plain/text")
    quit method
}

/// Sets the synchronization method.
ClassMethod setSyncMethod(method As %String) As %String
{
	&sql(UPDATE Demo.Settings SET SyncMethod = :method)
    do ..%SetStatusCode(204)
	quit "OK"
}

/// Returns the server delay (ms).
ClassMethod getServerDelay() As %Integer
{
	&sql(SELECT TOP 1 ServerDelay INTO :delay FROM Demo.Settings)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "plain/text")
    quit delay
}

/// Sets the server delay (ms).
ClassMethod setServerDelay(delay As %Integer) As %String
{
	&sql(UPDATE Demo.Settings SET ServerDelay = :delay)
    do ..%SetStatusCode(204)
	quit "OK"
}

/// Returns the poolsize of the server's Business Process.
ClassMethod getServerPoolsize() As %Integer
{
	&sql(SELECT TOP 1 ServerPoolSize INTO :poolsize FROM Demo.Settings)
    do ..%SetStatusCode(200)
    do ..%SetHeader("Content-Type", "plain/text")
    quit poolsize
}

/// Sets the poolsize of the server's Business Process.
ClassMethod setServerPoolsize(poolsize As %Integer) As %String
{
	&sql(UPDATE Demo.Settings SET ServerPoolSize = :poolsize)
    do ..%SetStatusCode(204)
	quit "OK"
}

}
