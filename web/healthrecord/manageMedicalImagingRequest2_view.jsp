<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    String permissionCheckFU = checkPermission("occup.medicalimagingrequest_fixedunit","",activeUser),
           permissionCheckMU = checkPermission("occup.medicalimagingrequest_mobileunit","",activeUser);

    if(permissionCheckFU.length()>0){
        %><%=permissionCheckFU%><%
    }
    else if(permissionCheckMU.length()>0){
        %><%=permissionCheckMU%><%
    }
%>

<script>
  function forward(url){
    window.location.href = "<%=sCONTEXTPATH%>"+url;
  }

  function doBack(){
    window.location.href = '<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>';
  }
</script>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" name="subClass" value="GENERAL"/>

<%
    TransactionVO transactionVO = (TransactionVO)transaction;

    // use template ? (yes by default)
    String useTemplate = checkString(request.getParameter("useTemplate"));
    if(useTemplate.length() == 0) useTemplate = "yes";

    if (transactionVO!=null && transactionVO.getTransactionId().intValue() >= 0){

        //--- show FIXED_UNIT ----------------------------------------------------------------------
        ItemVO itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SCREEN_FIXED_UNIT");
        if (itemVO!=null){
            String sFixedUnit = checkString(itemVO.getValue());

            if(sFixedUnit.equalsIgnoreCase("medwan.common.true")){
                out.print("</form>");

                if(useTemplate.equalsIgnoreCase("yes")){
                    out.print("<script>forward('/main.do?Page=healthrecord/manageMedicalImagingRequestFixedUnit.jsp&be.mxs.healthrecord.transaction_id="+transactionVO.getTransactionId()+"&be.mxs.healthrecord.server_id="+transactionVO.getServerId()+"&ts="+getTs()+"');</script>");
                }
                else{
                    out.print("<script>forward('/healthrecord/viewLastTransaction.jsp?Page=healthrecord/manageMedicalImagingRequestFixedUnit.jsp&historyBack=2&be.mxs.healthrecord.transaction_id="+transactionVO.getTransactionId()+"&be.mxs.healthrecord.server_id="+transactionVO.getServerId()+"&ts="+getTs()+"');</script>");
                }

                out.flush();
            }
        }

        //--- show MOBILE_UNIT ---------------------------------------------------------------------
        itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_SCREEN_MOBILE_UNIT");
        if (itemVO!=null){
            String sMobileUnit = checkString(itemVO.getValue());

            if(sMobileUnit.equalsIgnoreCase("medwan.common.true")){
                out.print("</form>");

                if(useTemplate.equalsIgnoreCase("yes")){
                    out.print("<script>forward('/main.do?Page=healthrecord/manageMedicalImagingRequestMobileUnit.jsp&be.mxs.healthrecord.transaction_id="+transactionVO.getTransactionId()+"&be.mxs.healthrecord.server_id="+transactionVO.getServerId()+"&ts="+getTs()+"');</script>");
                }
                else{
                    out.print("<script>forward('/healthrecord/viewLastTransaction.jsp?Page=healthrecord/manageMedicalImagingRequestMobileUnit.jsp&historyBack=2&be.mxs.healthrecord.transaction_id="+transactionVO.getTransactionId()+"&be.mxs.healthrecord.server_id="+transactionVO.getServerId()+"&ts="+getTs()+"');</script>");
                }

                out.flush();
            }
        }
    }
    else{
%>
    <%-- CONTINUE BUILDING HTML --%>
    <%=writeTableHeader("Web.Occup","medwan.healthrecord.medical-imaging.v2",sWebLanguage,sCONTEXTPATH+"/main.do?Page=curative/index.jsp&ts="+getTs())%>
    <table class="list" width="100%" cellspacing="1">
        <%-- FIXED UNIT --%>
        <tr height="20">
            <td class="admin2">
                <a href="javascript:forward('/main.do?be.mxs.healthrecord.transaction_id=currentTransaction&Page=healthrecord/manageMedicalImagingRequestFixedUnit.jsp&type=0&ts=<%=getTs()%>');">
                    <%=getTran("Web.Occup","medwan.healthrecord.medical-imaging.fixed-unit",sWebLanguage)%>
                </a>
            </td>
        </tr>
        
        <%-- MOBILE UNIT --%>
        <tr height="20">
            <td class="admin2">
                <a href="javascript:forward('/main.do?be.mxs.healthrecord.transaction_id=currentTransaction&Page=healthrecord/manageMedicalImagingRequestMobileUnit.jsp&type=1&ts=<%=getTs()%>');">
                    <%=getTran("Web.Occup","medwan.healthrecord.medical-imaging.mobile-unit",sWebLanguage)%>
                </a>
            </td>
        </tr>
    </table>
    <br>
    
    <%-- BUTTONS --%>
    <INPUT class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
</form>
<%
    }
%>