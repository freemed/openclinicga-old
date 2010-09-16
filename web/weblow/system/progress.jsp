<%@ page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                 be.mxs.webapp.wl.session.SessionContainerFactory"%>
<%
    int kill=0;
    SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
    SessionContainerWO.Progress progress = sessionContainerWO.getProgress(request.getParameter("progressId"));
    if (("1".equals(request.getParameter("kill"))) && !"1".equals(request.getParameter("clear"))){
        out.print("<script>window.opener='';window.close();</script>");
    }
    else {
        kill=0;
        if (progress!=null){
            if ("1".equals(request.getParameter("clear"))){
                progress.percent = 0;
            }
            else {
                if (progress.percent >=100){
                    kill=1;
                }
                out.print("<head><title>"+progress.status+"</title></head>");
                out.print("<h5>Loading...</h5><table width='100%'><td width='"+progress.percent+"%' bgcolor='blue'>&nbsp</td><td bgcolor='yellow' width='"+(100-progress.percent)+"%'>&nbsp;</td></tr></table>");
            }
        }
    }
%>
<script>
    window.focus();
    window.setTimeout("window.location.href='progress.jsp?progressId=<%=request.getParameter("progressId")%>&kill=<%=kill%>'",500);
</script>