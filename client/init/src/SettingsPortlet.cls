Class Demo.SettingsPortlet Extends %DeepSee.Component.Portlet.abstractPortlet
{

Property Count As %Integer(MINVAL = 1);

Property Size As %Integer(MINVAL = 1);

Property Method As %String(VALUELIST = ",Full,Mixed,None");

Property Delay As %Integer(MINVAL = 0);

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="My Page">
<page xmlns="http://www.intersystems.com/zen" title="Test Settings">
  <html id="title">Test Settings</html>
  <vgroup width="100%" height="100%">
      <html>Number of test requests: </html>
      <text name="count" clientType="integer"/>
      <html>Size of each request: </html>
      <text name="size" clientType="integer"/>
      <html>Synchronization method: </html>
      <select name="method" valueList="Full,Mixed,None"/>
      <button caption="Run Test" onclick="zenPage.RunTestServer(zen('settingsform').getValuesAsObject());"/>
  </vgroup>
</page>
</page>
}

Method %DrawHTML()
{
    &sql(SELECT RequestCount, RequestSize, ServerDelay, SyncMethod INTO :count, :size, :delay, :method FROM Demo.Settings)
    set ..Count = count
    set ..Size = size
    set ..Delay = delay
    set ..Method = method
    #; set ..renderFlag = ..renderFlag + 1
    &html<<style>#settingsDiv input,button,select {width: 6em;} #settingsDiv td {padding: 4px;} #settingsDiv button {display: block; margin: auto;}</style>>
    &html<<div id="settingsDiv">>
    &html<<h3>Test Settings</h3>>
    #; &html<<form id="settingsform" OnLoadForm="GetTestSettings">>
    &html<<table><tr><td>>
    &html<<label for="count">Number of test requests: </label>>
    &html<</td><td>>
    &html<<input name="count" id="count" type="number" min="1" value="#(..Count)#"/>>
    &html<</td></tr><tr><td>>
    &html<<label for="size">Size of each request: </label>>
    &html<</td><td>>
    &html<<input name="size" id="size" type="number" min="1" value="#(..Size)#"/>>
    &html<</td></tr><tr><td>>
    &html<<label for="delay">Server delay (ms): </label>>
    &html<</td><td>>
    &html<<input name="delay" id="delay" type="number" min="0" value="#(..Delay)#"/>>
    &html<</td></tr><tr><td>>
    &html<<label for="method">Synchronization method: </label>>
    &html<</td><td>>
    &html<<select name="method" id="method">>
    &html<<option value="Full">Full</option>>
    &html<<option value="Mixed">Mixed</option>>
    &html<<option value="None">None</option>>
    &html<</select>>
    &html<</td></tr><tr><td colspan="2">>
    #; &html<<button onclick="zenPage.RunTest4(zen('settingsform').getValuesAsObject());">Run Test</button>>
    &html<<button onclick="var obj = {};
	obj.count = document.getElementById('count').value;
	obj.size = document.getElementById('size').value;
	obj.delay = document.getElementById('delay').value;
	obj.method = document.getElementById('method').value;
	zenPage.RunTestServer(JSON.stringify(obj));">Run Test</button>>
    &html<</td></tr></table>>
    #; &html<</form>>
    &html<</div>>
    &html<<script>
    document.getElementById('method').value = '#(..Method)#';
    function RunTest2(arg){alert(JSON.stringify(arg));}
    </script>>
    #; &js<document.getElementById('method').value = '#(..Method)#';>
}

ClassMethod %OnGetPortletName() As %String
{
    return "Test Settings"
}

ClientMethod RunTestClient(arg) [ Language = javascript ]
{
    alert(JSON.stringify(arg));
}

ClassMethod RunTestServer(arg) [ ZenMethod ]
{
    set ^x = "Done"
}

// Method GetTestSettings(pKey As %String, ByRef pValues As %String) As %Status

// {

//   &sql(SELECT RequestCount, RequestSize, SyncMethod INTO :pValues("count"), :pValues("size"), :pValues("method") FROM Demo.Settings)

//   quit $$$OK

// }

// Method RunTest3(parm As %ZEN.proxyObject) [ ZenMethod ]

// {

//   &sql(UPDATE Demo.Settings SET RequestCount = :parm.count, RequestSize = :parm.size, SyncMethod = :parm.method)

//   &js<window.parent.location.reload();>

// }

// Method RunTest(arg As %Integer) [ ZenMethod ]

// {

//     set ^x = arg

//     #; set count = arg.count

//     #; set size = arg.size

//     #; set delay = arg.delay

//     #; set method = arg.method

//     #; &sql(UPDATE Demo.Settings SET RequestCount = :count, RequestSize = :size, ServerDelay = :delay, SyncMethod = :method)

// }

}
