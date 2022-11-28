Class Demo.Request Extends (Ens.Request, %JSON.Adaptor)
{

Property Id As %Integer (%JSONFIELDNAME = "id");

Property Message As %Stream.GlobalCharacter (%JSONFIELDNAME = "message");

}
