<%@page import="be.mxs.common.util.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,
                be.mxs.common.util.db.*,be.mxs.common.util.system.*,be.openclinic.finance.*,net.admin.*,
                java.util.*,java.text.*,be.openclinic.adt.*"%>
<script>
  window.location.href="<%=MedwanQuery.getInstance().getConfigString("remoteServer","http://10.254.0.2/openclinic/login.jsp?javaPOSServer=http://10.254.1.27/openclinic")%>";
</script>