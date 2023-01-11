Include %occIO

/// This class contains the methods for the demo's implementation class,
/// as well as the code to copy them there.
Class Demo.Implementation Extends %REST.Impl
{

/// Returns the time-related data series.
ClassMethod getDataSeries() As %DynamicObject
{
	set tStatement = ##class(%SQL.Statement).%New()
	set sql = 5
	set sql(1) = "SELECT MIN(Id), MAX(Id), AVG(ServerTime) * 1000, AVG(NetworkTime) * 1000"
	set sql(2) = "FROM Demo.Measurement"
	set sql(3) = "GROUP BY FLOOR((Id-1)/("
	set sql(4) = "SELECT CAST(CASE WHEN COUNT(*) < 50 THEN 50 ELSE COUNT(*) END/50 AS INT) FROM Demo.Measurement)"
	set sql(5) = ")"
	set rset = tStatement.%ExecDirect(, .sql)
	set id = [], networkTime = [], serverTime = []
	
	while rset.%Next() {
		if (rset.%GetData(1) = rset.%GetData(2)) {
			do id.%Push(rset.%GetData(1), "string")
		} else {
			do id.%Push(rset.%GetData(1) _ "-" _ rset.%GetData(2), "string")
		}
		do serverTime.%Push(rset.%GetData(3), "number")
		do networkTime.%Push(rset.%GetData(4), "number")
	}
	quit {}.%Set("id",id).%Set("serverTime",serverTime).%Set("networkTime",networkTime)
}

}
