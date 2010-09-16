<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.statistics.DiagnosisStats" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="be.openclinic.statistics.Comorbidity" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="be.openclinic.statistics.DiagnosisGroupStats" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    String contacttype="admission";
    boolean bGroups="yes".equalsIgnoreCase(request.getParameter("groupcodes"));
    try{
        double totalcases = Integer.parseInt(request.getParameter("TotalCases"));
        String sDiagnosisCode = request.getParameter("DiagnosisCode");
        String sDiagnosisCodeType = request.getParameter("DiagnosisCodeType");
        Date dBegin = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("Start"));
        Date dEnd = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("End"));
        String sOutcome = request.getParameter("Outcome");
        String sService = checkString(request.getParameter("ServiceID"));
        if(request.getParameter("contacttype")!=null){
            contacttype=request.getParameter("contacttype");
        }
        int detail=3;
        if(request.getParameter("Detail")!=null){
            detail=Integer.parseInt(request.getParameter("Detail"));
        }
%>
<table width='100%'>
    <tr class='admin'>
        <td colspan='2'><%=getTran("medical.diagnosis","comorbidityfor",sWebLanguage)%> <%=MedwanQuery.getInstance().getCodeTran(sDiagnosisCodeType + "code" + ScreenHelper.padRight(sDiagnosisCode,"0",5), sWebLanguage)%> (n=<%=totalcases%>)</td>
    </tr>
    <tr class='admin'>
        <td>#</td>
        <td><%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%></td>
    </tr>
<%
        Vector comorbidities;
        if(bGroups){
            comorbidities = DiagnosisGroupStats.getAssociatedPathologies(sDiagnosisCode, sDiagnosisCodeType, dBegin, dEnd, sOutcome,sService,detail,contacttype);
        }
        else {
            comorbidities = DiagnosisStats.getAssociatedPathologies(sDiagnosisCode, sDiagnosisCodeType, dBegin, dEnd, sOutcome,sService,detail,contacttype);
        }
        for (int n = 0; n < comorbidities.size(); n++) {
            Comorbidity comorbidity = (Comorbidity) comorbidities.elementAt(n);
            String codeLabel=(comorbidity.diagnosisCode.length()>0?MedwanQuery.getInstance().getCodeTran(sDiagnosisCodeType + "code" + (sDiagnosisCodeType.equalsIgnoreCase("icpc")?ScreenHelper.padRight(comorbidity.diagnosisCode,"0",5):comorbidity.diagnosisCode), sWebLanguage):sDiagnosisCodeType.toUpperCase());
            codeLabel=codeLabel.replaceAll(sDiagnosisCodeType+"code","");
            out.println("<tr><td class='admin2' nowrap>"+(n==0?"<b>":"") + comorbidity.cases + " (" + new DecimalFormat("#0.00").format(comorbidity.cases * 100 / totalcases)+"%)"+(n==0?"</b>":"")+"</td>" +
                    "<td class='admin2'><a href='javascript:listcases(\""+comorbidity.diagnosisCode+"\");'>"+(n==0?"<b>":"")+comorbidity.diagnosisCode+" "+codeLabel+(n==0?"</b>":"")+"</a></td></tr>");
        }
    }
    catch(Exception e){
        e.printStackTrace();
        out.print("<script>window.close();</script>");
    }
%>
    <tr class='admin'>
        <td><%=getTran("web","detail",sWebLanguage)%></td>
        <td>
            <a href="javascript:showAgain(1)">1</a>
            <a href="javascript:showAgain(2)">2</a>
            <a href="javascript:showAgain(3)">3</a>
            <%
                if("icd10".equalsIgnoreCase(request.getParameter("DiagnosisCodeType"))){
            %>
            <a href="javascript:showAgain(5)">4</a>
            <%
                }
            %>
        </td>
    </tr>

</table>
<script type="text/javascript">
    function listcases(code){
        window.open("<c:url value='/popup.jsp'/>?Page=medical/manageDiagnosesPop.jsp&PopupHeight=600&ts=<%=getTs()%>&selectrecord=1&Action=SEARCH&FindDiagnosisFromDate=<%=request.getParameter("Start")%>&FindDiagnosisToDate=<%=request.getParameter("End")%>&FindDiagnosisCode=<%=request.getParameter("DiagnosisCode")%>&FindDiagnosisCodeType=<%=request.getParameter("DiagnosisCodeType")%>&FindDiagnosisCodeLabel=<%=request.getParameter("DiagnosisCode")%> <%=MedwanQuery.getInstance().getCodeTran(request.getParameter("DiagnosisCodeType") + "code" + ScreenHelper.padRight(request.getParameter("DiagnosisCode"),"0",5), sWebLanguage)%>&FindEncounterOutcome=<%=request.getParameter("Outcome")%>&FindDiagnosisCodeExtra="+code+"&contacttype=<%=contacttype%>","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=500, menubar=no").moveTo((screen.width-800)/2,(screen.height-500)/2);
    }
    function showAgain(detail){
        window.location.href="<c:url value='/popup.jsp'/>?Page=/statistics/showComorbidity.jsp&PopupHeight=600&TotalCases=<%=request.getParameter("TotalCases")%>&DiagnosisCode=<%=request.getParameter("DiagnosisCode")%>&DiagnosisCodeType=<%=request.getParameter("DiagnosisCodeType")%>&Start=<%=request.getParameter("Start")%>&End=<%=request.getParameter("End")%>&Outcome=<%=request.getParameter("Outcome")%>&ServiceID=<%=request.getParameter("ServiceID")%>&Detail="+detail+"&contacttype=<%=contacttype%>&PopupHeight=500&PopupWidth=500&groupcodes=<%=bGroups?"yes":"no"%>";
    }
</script>
