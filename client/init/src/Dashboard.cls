Include %DeepSee

Class Demo.Dashboard Extends %DeepSee.UserLibrary.Container [ Not ProcedureBlock ]
{

/// Items Exported From Folder Manager.
XData Contents [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<items><dashboard xmlns="http://www.intersystems.com/deepsee/library" name="REST" folderName="Demo" title="REST performance" description="" keywords="" owner="" shared="true" public="true" locked="false" resource="" timeCreated="2022-12-05T09:48:05.883Z" createdBy="UnknownUser" category="" bookCover="" scheme="" worklistCount="2" snapTo="true" snapGrid="true" gridRows="10" gridCols="10" canResize="true" canModify="true" showTitleBar="true" titleBarOpacity="" titleBarColor="" selectedTitleBarOpacity="" selectedTitleBarColor="" titleBarTextColor="" selectedTitleBarTextColor="" titleBarFont="" companyName="" companyLogo="" companyStyle="" backgroundColor="white" backgroundImage="none" backgroundRepeat="no-repeat" backgroundSize="100% 100%" backgroundOpacity="1" widgetBorders="1px solid #F0F0F0" widgetBordersSwitch="edit" widgetBordersColor="#F0F0F0" widgetBordersStyle="solid" widgetBordersWidth="1" widgetBordersToggle="true">
  <widget name="WidgetCount" type="meter" subtype="textMeter" subtypeClass="" title="" dataSource="RESTperformance.kpi" dataLink="" drillDownDataSource="" width="200" height="200" sidebarContent="" showSidebar="false" sidebarWidth="" maximized="false" homeRowL="0" homeColL="0" colSpanL="3" rowSpanL="2" showToolbar="true" showToolbarBottomBorder="true" showToolbarOnlyWhenMaximized="false" colorToolbar="#F0F0F0" opacityToolbar="1" backgroundColor="#F0F0F0" opacity="1" theme="" dataColorList="">
    <control name="" action="Run" target="" targetProperty="" location="dashboard" type="button" controlClass="" label="Run test" title="" value="" text="" readOnly="false" valueList="" displayList="" activeWhen="">
      <valueRequired>false</valueRequired>
    </control>
    <control name="" action="setFilter" target="" targetProperty="Synchronization" location="dashboard" type="dropdown" controlClass="" label="Synchronization" title="" value="FULL" text="Full" readOnly="false" valueList="" displayList="" activeWhen="">
      <valueRequired>false</valueRequired>
    </control>
    <dataProperty name="" label="# requests" width="" align="" subtype="" style="" display="" format="" showAs="" valueColumn="false" summary="" summaryValue="" dataValue="RequestCount" targetValue="" thresholdLower="" thresholdUpper="" rangeLower="" rangeUpper="" baseValue="" override=""></dataProperty>
  </widget>
  <widget name="WidgetServerTime" type="meter" subtype="textMeter" subtypeClass="" title="" dataSource="RESTperformance.kpi" dataLink="" drillDownDataSource="" width="200" height="200" sidebarContent="" showSidebar="false" sidebarWidth="" maximized="false" homeRowL="2" homeColL="0" colSpanL="3" rowSpanL="2" showToolbar="true" showToolbarBottomBorder="true" showToolbarOnlyWhenMaximized="false" colorToolbar="#F0F0F0" opacityToolbar="1" backgroundColor="#F0F0F0" opacity="1" theme="" dataColorList="">
    <dataProperty name="" label="server (ms)" width="" align="" subtype="" style="" display="" format="" showAs="" valueColumn="false" summary="" summaryValue="" dataValue="AvgServerTime" targetValue="" thresholdLower="" thresholdUpper="" rangeLower="" rangeUpper="" baseValue="" override=""></dataProperty>
    <property name="format">#,##.##</property>
  </widget>
  <widget name="WidgetNetwork" type="meter" subtype="textMeter" subtypeClass="" title="" dataSource="RESTperformance.kpi" dataLink="" drillDownDataSource="" width="200" height="200" sidebarContent="" showSidebar="false" sidebarWidth="" maximized="false" homeRowL="4" homeColL="0" colSpanL="3" rowSpanL="2" showToolbar="true" showToolbarBottomBorder="true" showToolbarOnlyWhenMaximized="false" colorToolbar="#F0F0F0" opacityToolbar="1" backgroundColor="#F0F0F0" opacity="1" theme="" dataColorList="">
    <dataProperty name="" label="network (ms)" width="" align="" subtype="textMeter" style="" display="value" format="" showAs="value" valueColumn="false" summary="" summaryValue="" dataValue="AvgNetworkTime" targetValue="" thresholdLower="" thresholdUpper="" rangeLower="" rangeUpper="" baseValue="" override="{height:97,width:389,disabled:true,_type:&apos;textMeter&apos;}"></dataProperty>
    <property name="format">#,##.##</property>
  </widget>
  <widget name="WidgetDataSeries" type="pivot" subtype="columnChartStacked" subtypeClass="barChart" title="" dataSource="REST data series.kpi" dataLink="" drillDownDataSource="" width="200" height="200" sidebarContent="" showSidebar="false" sidebarWidth="" maximized="false" homeRowL="0" homeColL="3" colSpanL="7" rowSpanL="6" showToolbar="true" showToolbarBottomBorder="true" showToolbarOnlyWhenMaximized="false" colorToolbar="#F0F0F0" opacityToolbar="1" backgroundColor="#F0F0F0" opacity="1" theme="" dataColorList="">
    <override name="barChart">{legendVisible:'false',seriesColorScheme:'bright',xAxis:{_type:'axis'},yAxisList:[{_type:'axis'}],chartStacked:true,_type:'barChart'}</override>
  </widget>
</dashboard>
</items>
}

}
