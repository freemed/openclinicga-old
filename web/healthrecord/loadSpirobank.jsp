<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.system.Miscelaneous,
                be.mxs.common.util.io.Imed"%>

<%
    if (request.getParameter("load")!=null){
        if(MedwanQuery.getInstance().getConfigString("spiroBankOut").length() > 0){
            Imed.clearOut(MedwanQuery.getInstance().getConfigString("spiroBankOut"));
        }

        if(MedwanQuery.getInstance().getConfigString("spiroBankIn").length() > 0){
            Imed.writeIdent(MedwanQuery.getInstance().getConfigString("spiroBankIn")+"/ident.xml",activePatient,activeUser);
        }

        if(MedwanQuery.getInstance().getConfigString("spiroBankExecutable").length() > 0 && MedwanQuery.getInstance().getConfigString("spiroBankDirectory").length() > 0){
            Miscelaneous.startApplication(MedwanQuery.getInstance().getConfigString("spiroBankExecutable"),MedwanQuery.getInstance().getConfigString("spiroBankDirectory"));
        }
    }
    else if (request.getParameter("read")!=null){
        if (MedwanQuery.getInstance().getConfigString("spiroBankOut").length() > 0){
            Imed.Spirometry spirometry = Imed.readSpiro(MedwanQuery.getInstance().getConfigString("spiroBankOut"),activePatient);
            if (spirometry.initialized){
                out.print("<script>window.opener.document.getElementsByName('trandate')[0].value='"+ScreenHelper.stdDateFormat.format(spirometry.date)+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyFEV1')[0].value='"+spirometry.fev1+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyFEV1pct')[0].value='"+spirometry.fev1pct+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyFVC')[0].value='"+spirometry.fvc+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyFVCpct')[0].value='"+spirometry.fvcpct+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyPEF')[0].value='"+spirometry.pef+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyPEFpct')[0].value='"+spirometry.pefpct+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyVC')[0].value='"+spirometry.vc+"';</script>");
                out.print("<script>window.opener.document.getElementsByName('MyVCpct')[0].value='"+spirometry.vcpct+"';</script>");
                out.print("<script>window.opener.calculateTiffeneau();</script>");
                out.print("<script>window.close();</script>");
                out.flush();
            }
        }
        else {
            out.print("<script>window.close();</script>");
            out.flush();
        }
    }
%>

<%-- Try to find the response of the winspiro program as long as the calling window remains alive --%>
<script>
  if (window.opener.document.getElementsByName('alive')[0] == undefined){
    window.close();
  }

  window.setTimeout("window.location.href='loadSpirobank.jsp?read=1'",2000);
</script>
