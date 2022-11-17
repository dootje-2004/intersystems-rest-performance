Class Demo.Production Extends Ens.Production [ DependsOn = Demo.ClientOperation ]
{

XData ProductionDefinition
{
<Production Name="Demo.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Demo.ClientOperation" Category="" ClassName="Demo.ClientOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
    <Setting Target="Adapter" Name="HTTPPort">52773</Setting>
    <Setting Target="Adapter" Name="HTTPServer">demoserver</Setting>
    <Setting Target="Adapter" Name="URL">/demo/</Setting>
  </Item>
</Production>
}

}
