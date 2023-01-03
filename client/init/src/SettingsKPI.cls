Class Demo.SettingsKPI Extends %DeepSee.KPI
{

Parameter DOMAIN;

Parameter RESOURCE;

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="Setttings" sourceType="sql"
 caption="Test Settings"
 sql="SELECT RequestCount, RequestSize, ServerDelay, SyncMethod FROM Demo.Settings">
  <property name="RequestCount" displayName="RequestCount" columnNo="1"/>
  <property name="RequestSize" displayName="RequestSize" columnNo="2"/>
  <property name="ServerDelay" displayName="ServerDelay" columnNo="3"/>
  <property name="SyncMethod" displayName="SyncMethod" columnNo="4"/>
  <filter name="Count" displayName="Count" filterProperty="RequestCount"/>
  <filter name="Size" displayName="Size" filterProperty="RequestSize"/>
  <filter name="Delay" displayName="Delay" filterProperty="ServerDelay"/>
  <filter name="Method" displayName="Method" multiSelect="false" filterProperty="SyncMethod" valueList="Full,Mixed,None" defaultValue="Full"/>
  <action name="RunTest" displayName="Run Test"/>
</kpi>
}

ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
    kill ^x
    set ^x(0) = pAction
    if (pAction = "RunTest") {
        set ^x(1) = pContext.%Serialize()
        set ^x(2) = pContext.filters.%Serialize()
        do ##class(Demo.ClientService).RunTest()
    }
    quit $$$OK
}

}
