Include %occIO

/// This class contains the methods for the demo's implementation class,
/// as well as the code to copy them there.
Class demo.implementation Extends %REST.Impl
{

/// Processes the payload.
ClassMethod processPayload(payload As %DynamicObject) As %DynamicObject
{
	do payload.%Set("time_received", $zdatetime($ztimestamp, 3, 7, 6))
	set ^data(payload.%Get("id")) = payload.%ToJSON()
	do ..%SetContentType("application/json")
	do ..%SetStatusCode(201)
	quit payload.%Set("time_returned", $zdatetime($ztimestamp, 3, 7, 6))
}

/// Loops over all methods in this class (with the exception of itself) and copies 
/// them to the class <var>className</var>.
ClassMethod copyMethods(className As %String) As %Status
{
	set tStatus = $$$OK
	set tSources = ##class(%Dictionary.ClassDefinition).%OpenId($$$CurrentClass).Methods
	set tClass = ##class(%Dictionary.ClassDefinition).%OpenId(className)
	if tClass = "" quit $system.Status.Error(5351, className)

	// Loop over all methods (sources) is this class.
	set sourceKey = ""
	for {
		set tSource = tSources.GetNext(.sourceKey)
		if sourceKey = "" quit // We are done looping.
		if tSource.Name = $$$CurrentMethod continue // Skip this method.

		// Loop over all methods (targets) in the target class until
		// we find one with the same name as the current source method.
		set targetKey = ""
		for {
			set target = tClass.Methods.GetNext(.targetKey)
			if targetKey = "" quit
			// Preserve the target method's sequenceNumber, or the editor will get confused.
			set seq = target.SequenceNumber
			if target.Name = tSource.Name quit
		}

		if targetKey = "" {
			// The target class does not yet have a method with the source's name, so we append a new method.
			set targetKey = tClass.Methods.Count() + 1
			set seq = targetKey
		}

		set target = tSource.%ConstructClone(1) // Deep copy.
		set target.SequenceNumber = seq // Set or restore the sequence number.
		set tStatus = tClass.Methods.SetAt(target, targetKey) // Replace or append the method.
		if tStatus '= $$$OK quit
		set tStatus = target.%Save()
		if tStatus '= $$$OK quit
		set tStatus = tClass.%Save()
	}
	if tStatus '= $$$OK quit tStatus
	set tStatus = $system.OBJ.Compile(className)
	quit tStatus
}

}
