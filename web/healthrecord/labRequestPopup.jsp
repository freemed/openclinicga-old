<%@page import="be.openclinic.medical.RequestedLabAnalysis,java.util.*,be.openclinic.medical.Labo" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSDROPDOWNMENU%>
<%=sJSSORTTABLE%>
<%!
    //--- ADD LABANALYSIS -------------------------------------------------------------------------
    private String addLA(int iTotal, String sCode, String sType, String sLabel, String sComment,
                         String sMonster, String sResultValue, String sResultModifier, String sWebLanguage){
        // translate comment
        if(sComment.trim().length() > 0){
            sComment = getTranNoLink("web.analysis",sComment,sWebLanguage);
        }

        // alternate row-style; red when empty resultModifier
        String sClass;
        if(sResultModifier.length()==0){
            sClass = "red";
        }
        else{
            if(iTotal%2==0) sClass = "list1";
            else            sClass = "list";
        }

        String detailsTran = getTran("web","showDetails",sWebLanguage);
        StringBuffer buf = new StringBuffer();
        buf.append("<tr id='rowLA"+iTotal+"' class='"+sClass+"' title='"+detailsTran+"' >")
           .append(" <td>&nbsp;"+sCode+"</td>")
           .append(" <td>&nbsp;"+sType+"</td>")
           .append(" <td>&nbsp;"+sLabel+"</td>")
           .append(" <td>&nbsp;"+sComment+"</td>")
           .append(" <td>&nbsp;"+sMonster+"</td>")
           .append(" <td>&nbsp;"+sResultValue+"</td>")
           .append(" <td>&nbsp;"+(sResultModifier.length()>0?getTran("labanalysis.resultmodifier",sResultModifier,sWebLanguage):"")+"</td>")
           .append("</tr>");

        return buf.toString();
    }
%>
<%=checkPermission("labrequest","select",activeUser)%>
<html>
<head>
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSDATE%>
</head>
<body>
<form>
  <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
  <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%
        // variables
        String sTmpCode, sTmpComment, sTmpModifier, sTmpResultUnit, sTmpResultValue, sTmpResult,
                sTmpType = "", sTmpLabel = "", sTmpMonster = "";
        StringBuffer sScriptsToExecute = new StringBuffer();
        TransactionVO tran = (TransactionVO) transaction;
        Hashtable labAnalyses = new Hashtable();
        RequestedLabAnalysis labAnalysis;
        String sDivLA = "";
        int iTotal = 1;

        // get chosen labanalyses from existing transaction.
        if (transaction != null) {
            if (tran != null && tran.getTransactionId().intValue() > 0) {
                labAnalyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(tran.getServerId(), tran.getTransactionId().intValue());
            }
        }

        // sort analysis-codes
        Vector codes = new Vector(labAnalyses.keySet());
        Collections.sort(codes);

        // run thru saved labanalysis
        for (int i = 0; i < codes.size(); i++) {
            sTmpCode = (String) codes.get(i);
            labAnalysis = (RequestedLabAnalysis) labAnalyses.get(sTmpCode);

            sTmpComment = labAnalysis.getComment();
            sTmpModifier = labAnalysis.getResultModifier();

            // get resultvalue
            sTmpResultValue = labAnalysis.getResultValue();
            sTmpResultUnit = getTranNoLink("labanalysis.resultunit", labAnalysis.getResultUnit(), sWebLanguage);
            sTmpResult = sTmpResultValue + " " + sTmpResultUnit;

            // get default-data from DB

            Hashtable hLabRequestData = Labo.getLabRequestDefaultData(sTmpCode);

            if(hLabRequestData!=null){
                sTmpType = (String)hLabRequestData.get("labtype");
                sTmpLabel = (String)hLabRequestData.get("OC_LABEL_VALUE");
                sTmpMonster = (String)hLabRequestData.get("monster");
            }

            // translate labtype
            if (sTmpType.equals("1")) sTmpType = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
            else if (sTmpType.equals("2")) sTmpType = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
            else if (sTmpType.equals("3")) sTmpType = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
            else if (sTmpType.equals("4")) sTmpType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
            else if (sTmpType.equals("5")) sTmpType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
            else if (sTmpType.equals("6")) sTmpType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
            else if (sTmpType.equals("7")) sTmpType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

            sDivLA += addLA(iTotal, sTmpCode, sTmpType, sTmpLabel, sTmpComment, sTmpMonster, sTmpResult, sTmpModifier, sWebLanguage);
            sScriptsToExecute.append("addToMonsterList('" + sTmpMonster + "');");
            iTotal++;
        }
    %>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%-- DATE --%>
    <table width="100%" class="list" cellspacing="1">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" READONLY>
            </td>
        </tr>
    </table>

    <br>

    <%-- LABANALYSIS --------------------------------------------------------------------------------%>
    <table id="tblLA" width="100%" cellspacing="1" class="sortable">
        <%-- HEADER --%>
        <tr class="admin">
            <%-- default data --%>
            <td width="80"><%=getTran("Web.manage","labanalysis.cols.code",sWebLanguage)%></td>
            <td width="80"><%=getTran("Web.manage","labanalysis.cols.type",sWebLanguage)%></td>
            <td width="200"><%=getTran("Web.manage","labanalysis.cols.name",sWebLanguage)%></td>
            <td width="150"><%=getTran("Web.manage","labanalysis.cols.comment",sWebLanguage)%></td>
            <td width="200"><%=getTran("Web.manage","labanalysis.cols.monster",sWebLanguage)%></td>

            <%-- result data --%>
            <td width="100"><%=getTran("Web.manage","labanalysis.cols.resultvalue",sWebLanguage)%></td>
            <td width="100"><%=getTran("Web.manage","labanalysis.cols.resultmodifier",sWebLanguage)%></td>
        </tr>

        <%-- chosen LabAnalysis --%>
        <%=sDivLA%>
    </table>

    <br>

    <table width="100%" class="list" cellspacing="1">
        <%-- MONSTERS --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","labrequest.monsters",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" size="80" id="monsterList" READONLY>
            </td>
        </tr>

        <%-- MONSTER HOUR --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","labrequest.hour",sWebLanguage)%></td>
            <td class="admin2">
                <input id="hour" type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HOUR" property="value"/>" READONLY>
            </td>
        </tr>

        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("Web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea id="remark" class="text" rows="2" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_COMMENT" property="itemId"/>]>.value" READONLY><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_COMMENT" property="value"/></textarea>
            </td>
        </tr>

        <%-- URGENCY --%>
        <%
            ItemVO item = ((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_URGENCY");
            String sUrgency = "";
            if(item!=null) sUrgency = item.getValue();
        %>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","urgency",sWebLanguage)%></td>
            <td class="admin2"><%=getTran("labrequest.urgency",sUrgency,sWebLanguage)%></td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <p align="center">
        <input class="button" type="button" value="<%=getTran("Web","close",sWebLanguage)%>" onclick="window.close();">
    </p>
</form>

<script>
  window.resizeTo(900,500);
  window.moveTo((self.screen.width-document.body.clientWidth)/2,(self.screen.height-document.body.clientHeight)/2);

  <%-- UPDATE ROW STYLES (especially after sorting, red row when no resultmodifier) --%>
  function updateRowStyles(){
    for(var i=1; i<tblLA.rows.length; i++){
      if(tblLA.rows[i].cells(6).innerHTML == "&nbsp;"){
        tblLA.rows[i].className = "red";
      }
      else{
        if(i%2>0){
          tblLA.rows[i].className = "list";
        }
        else{
          tblLA.rows[i].className = "list1";
        }
      }
    }
  }
</script>
<%=ScreenHelper.contextFooter(request)%>
</body>
</html>