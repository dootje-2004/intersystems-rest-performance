/// This class contains the method bodies for the demo,
/// as well as the code to copy them to the actual implementation class.
Class demo.implementation Extends %REST.Impl
{

ClassMethod processPayload(payload As %DynamicObject) As %DynamicObject
{
	do ..%SetContentType("application/json")
	do ..%SetStatusCode(201)
	quit {}.%Set("status","OK")
}

/// Loops over the methods in this class (with the exception of itself) and copies 
/// their implementations (code bodies) to the target class <var>cls</var>.
ClassMethod copy(cls As %String) As %Status
{
	set sc = $$$OK
	set list = ##class(%Dictionary.ClassDefinition).%OpenId($this).Methods
	set key = ""
	for {
		set source = list.GetNext(.key)
		quit:key=""
		continue:source.Name="copy"
		set target = ##class(%Dictionary.MethodDefinition).%OpenId(cls _ "||" _ source.Name)
		if target = $$$NULLOREF {
			set target = ##class(%Dictionary.MethodDefinition).%New()
			set target.Name = source.Name
			do ##class(%Dictionary.ClassDefinition).%OpenId(cls).Methods.SetAt(target, list.Count() + 1)
		}
		set target.Implementation = source.Implementation
		do target.%Save()
	}
	do $system.OBJ.Compile(cls)
	quit sc
}

}
