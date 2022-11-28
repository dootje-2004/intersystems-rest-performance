/// 
Class Demo.ClientProcess Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Demo.ConfigRequest' height='2000' width='2000' >
<context>
<property name='counter' type='%Integer' instantiate='0' />
</context>
<sequence xend='200' yend='450' >
<assign name="set counter" property="context.counter" value="request.MessageCount" action="set" xpos='200' ypos='250' />
<while name='counter &gt; 0 ?' condition='context.counter' xpos='200' ypos='350' xend='200' yend='550' >
<call name='Send test request' target='Demo.ClientOperation' async='1' xpos='200' ypos='250' >
<request type='Demo.Request' >
<assign property="callrequest.Id" value="context.counter" action="set" />
<assign property="callrequest.Message" value="&quot;DEMO&quot;" action="set" />
</request>
<response type='Demo.Response' />
</call>
<assign name="decrement counter" property="context.counter" value="context.counter - 1" action="set" xpos='200' ypos='350' />
<sync name='Wait for response' calls='Send test request' type='all' xpos='200' ypos='450' />
</while>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
