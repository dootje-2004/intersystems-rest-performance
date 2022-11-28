/// 
Class Demo.Process Extends Ens.BusinessProcessBPL
{

/// Processing delay in milliseconds.
Property Delay As %Integer [ InitialExpression = 1 ];

Parameter SETTINGS = "Delay:Basic";

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Demo.Request' response='Demo.Response' height='2000' width='2000' >
<sequence xend='200' yend='650' >
<assign name="Copy id" property="response.Id" value="request.Id" action="set" xpos='200' ypos='250' />
<assign name="Set status" property="response.Status" value="&quot;OK&quot;" action="set" xpos='200' ypos='350' />
<code name='Delay' xpos='718' ypos='510' >
<![CDATA[ hang ##class(Ens.Director).GetItemSettingValue("Demo.Production||Demo.Process","Host","Delay",.st) / 1000]]>
</code>
</sequence>
</process>
}

}
