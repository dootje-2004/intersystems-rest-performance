Class Demo.Series Extends %DeepSee.KPI
{

Parameter DOMAIN = "RESTdemo";

Parameter RESOURCE = "KPI_Resource";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="REST data series" sourceType="sql"
 caption="REST data series"
 sql="SELECT MIN(Id), AVG(ServerTime) * 1000, AVG(NetworkTime) * 1000 FROM Demo.Measurement 
GROUP BY FLOOR((Id-1)/ (SELECT CAST(COUNT(*)/50 AS INT) FROM Demo.Measurement) )"
>
<property name="ServerTime" displayName="ServerTime" columnNo="2"/>
<property name="NetworkTime" displayName="NetworkTime" columnNo="3"/>
</kpi>
}

}
