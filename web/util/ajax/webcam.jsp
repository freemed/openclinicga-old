<%@include file="/includes/validateUser.jsp"%>

<div>
  <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
    id="testcam" width="100%" height="390px"
    codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
    <param name="movie" value="<c:url value="/flex/webcam/webcam.swf"/>"/>
    <param name="quality" value="high"/>
    <param name="bgcolor" value="#ECF5FF"/>
    <param name="allowScriptAccess" value="sameDomain"/>
    <param name="flashVars" value="language=<%=activeUser.person.language.toLowerCase()%>&prefix=<%=sProject%>"/>
    <param name="wmode" value="transparent"/>
    <embed src="<c:url value="/flex/webcam/webcam.swf"/>?flashvars=" quality="high" bgcolor="#ECF5FF"
      width="100%" height="390px" name="testcam" align="middle"
      play="true"
      loop="false"
      quality="high"
      flashVars="language=<%=activeUser.person.language.toLowerCase()%>&prefix=<%=sProject%>"
      wmode="transparent"
      allowScriptAccess="sameDomain"
      type="application/x-shockwave-flash"
      pluginspage="http://www.adobe.com/go/getflashplayer">
    </embed>
  </object>
</div>