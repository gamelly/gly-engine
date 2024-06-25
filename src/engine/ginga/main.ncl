<?xml version='1.0' encoding='utf-8'?>
<ncl>
  <head>
    <regionBase>
      <region id='luaRegion' width='100%' height='100%'/>
    </regionBase>
    <descriptorBase>
      <descriptor id='luaDesc' region='luaRegion' focusIndex='0'/>
    </descriptorBase>
  </head>
  <body>
    <port id='init' component='lua'/>
    <media id='lua' descriptor='luaDesc' src='main.lua'/>
  </body>
</ncl>
