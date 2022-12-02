Class Demo.Measurement Extends %Persistent
{

/// Message ID.
Property Id As %Integer;

/// Timestamp.
Property Timestamp As %TimeStamp;

/// Time it took to send the message to the server and back.
Property NetworkTime As %Double;

/// Time it took the server to process the request and send an answer back.
Property ServerTime As %Double;

}
