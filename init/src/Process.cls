/// 
Class Demo.Process Extends Ens.BusinessProcessBPL
{

/// Processing delay in milliseconds.
Property Delay As %Integer [ InitialExpression = 3 ];

Parameter SETTINGS = "Delay:Basic";

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Demo.Request' response='Demo.Response' height='2000' width='2000' >
<sequence xend='200' yend='650' >
<assign name="Set reception timestamp" property="^testdata(request.Id,6)" value="$lb($ztimestamp,$job)" action="set" xpos='200' ypos='250' />
<assign name="Copy id" property="response.Id" value="request.Id" action="set" xpos='200' ypos='250' />
<assign name="Set status" property="response.Status" value="&quot;OK&quot;" action="set" xpos='200' ypos='350' />
<code name='Delay' xpos='718' ypos='510' >
<![CDATA[ hang ##class(Ens.Director).GetItemSettingValue("Demo.Production||Demo.Process","Host","Delay",.st) / 1000]]>
</code>
<assign name="Set response timestamp" property="^testdata(request.Id,7)" value="$lb($ztimestamp,$job)" action="set" xpos='200' ypos='250' />
</sequence>
</process>
}

Storage Default
{
<Data name="ProcessDefaultData">
<Subscript>"Process"</Subscript>
<Value name="1">
<Value>Delay</Value>
</Value>
</Data>
<DefaultData>ProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
