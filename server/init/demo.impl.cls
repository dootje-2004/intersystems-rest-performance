/// A simple REST interface to evaluate the ingestion speed of an InterSystems IRIS REST API<br/>
Class demo.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Processes the payload.
ClassMethod processPayload(payload As %DynamicObject) As %DynamicObject
{
	do ..%SetContentType("application/json")
	do ..%SetStatusCode(201)
	quit {}.%Set("status","OK")
}

}
