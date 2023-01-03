Class Demo.SettingsPage Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION;

/// Displayed name of this page.
Parameter PAGENAME = "REST demo";

/// Domain used for localization.
Parameter DOMAIN;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
html, * {
  font-family: Verdana;
  font-size: 1em;
}
input, select {
  margin-top: 3px;
  margin-bottom: 12px;
  width: 7em;
}
#title {
  background: #C5D6D6;
  color: black;
  font-size: 1.5em;
  font-weight: bold;
  padding: 5px;
  border-bottom: 1px solid black;
  text-align: center;
}
</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="REST demo">
  <html id="title">REST API test</html>
  <hgroup width="100%" height="100%">
    <vgroup width="20%" height="100%">
      <form id="settingsform" OnLoadForm="GetTestSettings">
        <html>Number of test requests: </html>
        <text name="count" clientType="integer"/>
        <html>Size of each request: </html>
        <text name="size" clientType="integer"/>
        <html>Synchronization method: </html>
        <select name="method" valueList="Full,Mixed,None"/>
        <button caption="Run Test" onclick="zenPage.RunTest(zen('settingsform').getValuesAsObject());"/>
      </form>
    </vgroup>
    <vgroup width="80%" height="100%">
      <iframe id="dashboard" width="100%" height="800px" src="/csp/demo/_DeepSee.UserPortal.DashboardViewer.zen?DASHBOARD=Demo/REST.dashboard"/>
    </vgroup>
  </hgroup>
</page>
}

Method GetTestSettings(pKey As %String, ByRef pValues As %String) As %Status
{
  &sql(SELECT RequestCount, RequestSize, SyncMethod INTO :pValues("count"), :pValues("size"), :pValues("method") FROM Demo.Settings)
  quit $$$OK
}

Method RunTest(parm As %ZEN.proxyObject) [ ZenMethod ]
{
  #; &js<
  #;   // https://stackoverflow.com/a/58118385
  #;   window.removeEventListener("beforeunload");
  #; >
  &sql(UPDATE Demo.Settings SET RequestCount = :parm.count, RequestSize = :parm.size, SyncMethod = :parm.method)
  // TODO: Set server's sync method; we'll need to enhance the server API for that.
  // TODO: Set the server delay; this also requires an API change.
  set st = ##class(Demo.ClientService).RunTest(parm.count, parm.size)
  // TODO: How to avoid the reload prompt?
  // We could work around it if we can refresh the widgets in code; how does that work?
  #; &js<window.dashboard.location.reload();>
  &js<
    console.log("Refreshing dashboard...");
    // Adapted from comment at https://stackoverflow.com/a/86771
    var frame = document.getElementById("dashboard").getElementsByTagName("iframe")[0];
    // frame.addEventListener("beforeunload", function(e){
    //   e.preventDefault();
    // }, false);
    console.log("src = " + frame.src);
    frame.src = frame.src;
    console.log("Done");
  >
}

}
