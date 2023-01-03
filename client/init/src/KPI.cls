Class Demo.KPI Extends %DeepSee.KPI
{

Parameter DOMAIN;

Parameter RESOURCE;

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="RESTperformance" sourceType="sql"
 caption="REST performance"
 sql="SELECT COUNT(*), AVG(ServerTime) * 1000, AVG(NetworkTime) * 1000 FROM Demo.Measurement">
  <property name="RequestCount" displayName="RequestCount" columnNo="1"/>
  <property name="AvgServerTime" displayName="AverageServerTime" columnNo="2"/>
  <property name="AvgNetworkTime" displayName="AverageNetworkTime" columnNo="3"/>
</kpi>
}

}
