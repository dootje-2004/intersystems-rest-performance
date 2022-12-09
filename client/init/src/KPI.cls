Class Demo.KPI Extends %DeepSee.KPI
{

Parameter DOMAIN = "RESTdemo";

Parameter RESOURCE = "KPI_Resource";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="RESTperformance" sourceType="sql"
 caption="REST performance"
 sql="SELECT COUNT(*), AVG(ServerTime) * 1000, AVG(NetworkTime) * 1000 FROM Demo.Measurement">
  <property name="RequestCount" displayName="RequestCount" columnNo="1"/>
  <property name="AvgServerTime" displayName="AverageServerTime" columnNo="2"/>
  <property name="AvgNetworkTime" displayName="AverageNetworkTime" columnNo="3"/>
  <filter name="Synchronization" valueList="FULL,MIXED,OFF" multiSelect="false"
  displayList="Full,Async backend,None" defaultValue="Full"/>
  <action name="Run"/>
</kpi>
}

ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
  if pAction = "Run" {
    // TODO: How to access current filter settings? pContext.filters appears to be empty.
    do ##class(Demo.ClientService).RunTest(100)
    set pContext.command="refresh:*;"
  }
  quit $$$OK
}

}
