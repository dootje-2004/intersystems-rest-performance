Class Demo.ConfigRequest Extends Ens.Request
{

/// Number of test messages to send.
Property MessageCount As %Integer [InitialExpression = 1];

/// Size of the payload (in wide characters).
Property PayloadSize As %Integer [InitialExpression = 5];

/// Number of test messages per second.
Property Rate As %Integer [InitialExpression = 1];

}