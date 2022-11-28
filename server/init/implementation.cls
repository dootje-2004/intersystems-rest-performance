Include %occIO

/// This class contains the methods for the demo's implementation class,
/// as well as the code to copy them there.
Class Demo.Implementation
{

/// Processes the payload.
ClassMethod ProcessPayload(payload As %DynamicObject) As %DynamicObject
{
	try {
		do ..%SetHeader("rx-server", ..Timestamp())

		// Forward request in the production.
		set status = ##class(Ens.Director).CreateBusinessService("Demo.Service", .service)
		$$$ThrowOnError(status)
		set status = service.ProcessInput(payload, .out)
		$$$ThrowOnError(status)

		// Compose REST response.
		set response = {}.%Set("id",payload.%Get("id"))
		do ..%SetHeader("tx-client", ..%GetHeader("tx-client"))
		do ..%SetContentType("application/json")
		do ..%SetStatusCode(201)
		do response.%Set("status","OK")
		do ..%SetHeader("tx-server", ..Timestamp())
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

/// Returns the current timestamp in microsecond precision.
ClassMethod Timestamp() As %String
{
    return $zdatetime($ztimestamp, 3, 7, 6)
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

}
