<?xml version='1.0' encoding='utf-8'?>
<ncl>
  <head>
    <regionBase>
      <region id='luaRegion' width='100%' height='100%' zIndex="1"/>
      <region id='regionBrowser' width='100%' height='100%' zIndex="2"/>
    </regionBase>
    <descriptorBase>
      <descriptor id='descriptorBrowser' region='regionBrowser' focusIndex='0'/>
      <descriptor id='luaDesc' region='luaRegion' focusIndex='0'/>
    </descriptorBase>
  </head>
  <body>
    <port id='init' component='lua'/>
    <media id='lua' descriptor='luaDesc' src='main.lua'/>
    <media id="browser" src="index.html" descriptor="descriptorBrowser" type="application/x-ginga-html"/>
  </body>
</ncl>
