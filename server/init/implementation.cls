Include %occIO

/// This class contains the methods for the demo's implementation class,
/// as well as the code to copy them there.
Class demo.implementation Extends %REST.Impl
{

/// Processes the payload.
ClassMethod processPayload(payload As %DynamicObject) As %DynamicObject
{
	do ..%SetContentType("application/json")
	do ..%SetStatusCode(201)
	quit {}.%Set("status","OK")
}

/// Loops over all methods in this class (with the exception of itself) and copies 
/// them to the class <var>className</var>.
ClassMethod copy(className As %String) As %Status
{
	set sc = $$$OK
	set sources = ##class(%Dictionary.ClassDefinition).%OpenId($$$CurrentClass).Methods
	set cls = ##class(%Dictionary.ClassDefinition).%OpenId(className)
	if cls = "" quit $system.Status.Error(5351, className)

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
			set target = cls.Methods.GetNext(.targetKey)
			if targetKey = "" quit
			// We need to preserve the target method's sequenceNumber.
			set seq = target.SequenceNumber
			if target.Name = source.Name quit
		}

		if targetKey = "" {
			// The target class does not yet have a method with the source's name, so we append a new method.
			set targetKey = cls.Methods.Count() + 1
			set seq = targetKey
		}

		set target = source.%ConstructClone(1) // Deep copy.
		set target.SequenceNumber = seq // Set or restore the sequence number.
		set sc = cls.Methods.SetAt(target, targetKey) // Replace or append the method.
		if sc '= $$$OK quit
		set sc = target.%Save()
		if sc '= $$$OK quit
		set sc = cls.%Save()
	}
	if sc '= $$$OK quit sc
	set sc = $system.OBJ.Compile(className)
	quit sc
}

}
