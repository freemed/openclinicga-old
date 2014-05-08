<%@page import="be.openclinic.medical.Problem"%>
<%@page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin">
        <td colspan="3">
            <%=getTran("web.occup","medwan.common.problemlist",sWebLanguage)%>&nbsp;
            <a href="javascript:showProblemlist();"><img src="<c:url value='/_img/icon_edit.gif'/>" class="link" alt="<%=getTran("web","editproblemlist",sWebLanguage)%>" style="vertical-align:-4px;"></a>
        </td>
    </tr>
    
    <%
        Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
        Problem activeProblem;

        for (int n = 0; n < activeProblems.size(); n++) {
            activeProblem = (Problem) activeProblems.elementAt(n);
            String c = "";
            if(activeProblem.getCode()!=null && activeProblem.getCode().length()>0){
                c = (MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType() + "code" + activeProblem.getCode(), sWebLanguage));
            }
            
            //We moeten controleren of er geen toegangsrecht-restricties gelden voor deze diagnose
            if(activeUser.getAccessRight("occup.restricteddiagnosis.select") || !MedwanQuery.getInstance().isRestrictedDiagnosis(activeProblem.getCodeType(),activeProblem.getCode())){
                out.print("<tr valign='top'><td><b>" + activeProblem.getCode() + "</b></td><td><b>" + c.trim() + "</b><i>" + (c.trim().length() > 0 ? " " : "") + activeProblem.getComment().trim() + "</i></td><td>" + ScreenHelper.stdDateFormat.format(activeProblem.getBegin()) + "</td></tr>");
            }
            else{
                out.print("<tr valign='top'><td style='{color: red}'><b><i>!!!</i></b></td><td style='{color: red}'><b><i>" + getTran("web","diagnosis.restrictedaccess",sWebLanguage).toUpperCase() + "</i></td><td>" + ScreenHelper.stdDateFormat.format(activeProblem.getBegin()) + "</td></tr>");
            }
        }

    %>
    <tr height="99%"><td/></tr>
</table>

<script>
  function showProblemlist(){
    openPopup("medical/manageProblems.jsp&ts=<%=getTs()%>",700,500);
  }
</script>
