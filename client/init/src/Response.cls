Class Demo.Response Extends (Ens.Response, %JSON.Adaptor)
{

/// The ID of the original request.
Property Id As %Integer (%JSONFIELDNAME = "id");

/// The server's return status.
Property Status As %String (%JSONFIELDNAME = "status");

/// The size of the payload reported by the server.
Property Size As %Integer (%JSONFIELDNAME = "size");

}
