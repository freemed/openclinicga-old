<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.Vector"%>
<%@ page import="be.openclinic.adt.Planning" %>
<%=checkPermission("planning","select",activeUser)%>
<%!
    //--- WRITE TAB -------------------------------------------------------------------------------
    public String writeTab(String sId, String sFocusField, String sLanguage){
        return "<script>sTabs+= ',"+sId+"';</script>"+
               "<td style='border-bottom:1px solid #000;width:10px'>&nbsp;</td>"+
               "<td class='tabunselected' width='1%' style='padding:2px 4px;text-align:center;' onclick='activateTab(\""+sId+"\")' id='tab"+sId+"' nowrap><b>"+getTran("planning",sId,sLanguage)+"</b></td>";
    }

    //--- WRITE TAB BEGIN -------------------------------------------------------------------------
    public String writeTabBegin(String sId){
        return "<tr id='tr"+sId+"' style='display:none'><td>";
    }

    //--- WRITE TAB END ---------------------------------------------------------------------------
    public String writeTabEnd(){
        return "</td></tr>";
    }
%>
<%
    String sFindDate = checkString(request.getParameter("FindDate"));
%>
<script>
var ClientMsg = Class.create();
ClientMsg.prototype = {
    initialize:function(div) {
        this.div = $(div);
    },
    setDiv:function(div) {
        this.div = $(div);
    },
    setError:function(msg, option,time) {
        this.div.hide();
        if (!time) {
            time = 5000;
        }
        if (option) {
            if (option == "before") {
                this.div.update("<span class='error'><img src='<%=sCONTEXTPATH%>/_img/warning.gif' style='vertical-align:-3px;'>&nbsp;<blink>" + msg + "</blink></span>" +
                                "<br>" + this.div.innerHTML);
            }
            else if (option == "after") {
                this.div.update(this.div.innerHTML + "<br><span class='error'><img src='<%=sCONTEXTPATH%>/_img/warning.gif' style='vertical-align:-3px;'>&nbsp;<blink>" + msg + "</blink></span>");
            }
        }
        else {
            this.div.update("<span class='error'><img src='<%=sCONTEXTPATH%>/_img/warning.gif' style='vertical-align:-3px;'>&nbsp;<blink>" + msg + "</blink></span>");
        }
        this.div.style.display = "block";
        setTimeout(function() {
            $(clientMsg.div).style.display = 'none';
        }, time);
    },
    setValid:function(msg, option,time) {
        this.div.hide();
         if (!time) {
            time = 5000;
        }
        if (option) {
            if (option == "before") {
                this.div.update("<span class='valid'><img src='<%=sCONTEXTPATH%>/_img/valid.gif' style='vertical-align:-3px;'>&nbsp;" + msg + "</span><br>" + this.div.innerHTML);
            }
            else if (option == "after") {
                this.div.update(this.div.innerHTML + "<br><span class='valid'><img src='<%=sCONTEXTPATH%>/_img/valid.gif' style='vertical-align:-3px;'>&nbsp;" + msg + "</span>");
            }
        }
        else {
            this.div.update("<span class='valid'><img src='<%=sCONTEXTPATH%>/_img/valid.gif' style='vertical-align:-3px;'>&nbsp;" + msg + "</span>");
        }
        this.div.style.display = "block";
        setTimeout(function() {
            $(clientMsg.div).style.display = 'none';
        }, time);
    }
}
var clientMsg = new ClientMsg("");
  var sTabs = "";
  var activeTab = "";
</script>
<div id="weekSchedulerFormByAjax" style="position:absolute;z-index:5000000">&nbsp;</div>
<table style="margin:0;padding:0;" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <%=writeTab("user", "planning", sWebLanguage)%>
        <% if(activePatient!=null){%>
        <script>sTabs += ',patient';</script>
        <td style='width:10px'>&nbsp;</td>
        <td class='tabunselected' width='1%' style='padding:2px 4px;text-align:center;' onclick='activatePatient("patient");' id='tabpatient' nowrap><b><%=getTran("planning", "patient", sWebLanguage)%></b></td>
        <% } %>
        <%=writeTab("service", "planning", sWebLanguage)%>
        <%=writeTab("missedAppointments", "planning", sWebLanguage)%>
        <%=writeTab("managePlanning", "web.userprofile", sWebLanguage)%>
        <td width="*">&nbsp;</td>
    </tr>
</table>
  <table id="tabsTable" width="100%" style="margin:0;padding:0;" cellspacing="0" cellpadding="0">
    <%=writeTabBegin("user")%>
    <%ScreenHelper.setIncludePage(customerInclude("planning/findPlanningUser.jsp?FindUserDate=" + sFindDate), pageContext);%>
    <%=writeTabEnd()%>
      <%=(activePatient!=null)?writeTabBegin("patient"):""%>
    <%=(activePatient!=null)?writeTabEnd():""%>
   <%=writeTabBegin("service")%>
    <%//ScreenHelper.setIncludePage(customerInclude("healthrecord/globalReferenceSummary.jsp"), pageContext);%>
    <%=writeTabEnd()%>
    <%=writeTabBegin("missedAppointments")%>
    <%ScreenHelper.setIncludePage(customerInclude("planning/missedAppointments.jsp"),pageContext);%>
    <%=writeTabEnd()%>
     <%=writeTabBegin("managePlanning")%>
    <%ScreenHelper.setIncludePage(customerInclude("userprofile/managePlanning.jsp"),pageContext);%>
    <%=writeTabEnd()%>
</table>
<script>
  var aTabs = sTabs.split(',');

  <%-- ACTIVATE TAB -----------------------------------------------------------------------------%>
    function activateTab(sTab,initialize) {
        for (var i = 0; i < aTabs.length; i++) {
            sTmp = aTabs[i];
            if (sTmp.length > 0) {
                $("tr" + sTmp).style.display = "none";
                $("tab" + sTmp).className = "tabunselected";
            }
        }
        $("tr" + sTab).style.display = "";
        $("tab" + sTab).className = "tabselected";
        if(sTab=="user"){
            $("FindUserUID").selectedIndex=1;
            $("PatientID").value = "";
            if(!initialize) displayCountedWeek(makeDate($('beginDate').value),$("FindUserUID").options[$("FindUserUID").selectedIndex].value);
            $("tableHeaderTitle").update("&nbsp;&nbsp;<%=getTran("planning","useropenplanning",sWebLanguage)%>")
            togglePrintButtons(sTab);
        }else if(sTab=="managePlanning"){
            setSlider();
        }

    }
  <%
    String sTab = checkString(request.getParameter("Tab"));
    sTab = "user";
  %>


  function doBack(){
      history.go(-1);
      return false;
  }

  function doNext(object, form, sValue, sTab){
      object.value = addDays(object.value,sValue);
      window.location.href="<c:url value='/main.do'/>?Page=planning/findPlanning.jsp&FindDate="+object.value+"&Tab="+sTab+"&ts="+new Date().getTime();
  }

  function doExamination(sPlanningUID,sPatientID, sTransactionType){
      window.location.href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType="+sTransactionType+"&be.mxs.healthrecord.createTransaction.context=&PersonID="+sPatientID+"&UpdatePlanning="+sPlanningUID+"&ts="+new Date().getTime();
  }
  function openExamination(ServerID,TransactionID, sPatientID,sTransactionType){
      window.location.href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType="+sTransactionType+"&be.mxs.healthrecord.createTransaction.context=&be.mxs.healthrecord.server_id="+ServerID+"&be.mxs.healthrecord.transaction_id="+TransactionID+"&PersonID="+sPatientID+"&ts="+new Date().getTime();
  }
     function activatePatient(sTab){

         if(!$("truser").visible()){
             $("truser").style.display = "";
         }
         for (var i = 0; i < aTabs.length; i++) {
            sTmp = aTabs[i];
            if (sTmp.length > 0) {
                $("tab" + sTmp).className = "tabunselected";
            }
        }
      //activeTab = sTab;
        $("tab" + sTab).className = "tabselected";
        $("FindUserUID").selectedIndex=0;
         <%
           if(activePatient!=null){
         %>
        $("PatientID").value = "<%=activePatient.personid%>";
         displayWeek(makeDate($('beginDate').value));

        $("tableHeaderTitle").update("&nbsp;&nbsp;<%=getTran("planning","patientplanningstoday",sWebLanguage)%>")
         <%
         
         }
         %>
         togglePrintButtons(sTab);
    }
  function togglePrintButtons(sTab){
        if(sTab=="patient"){
           var a = $("weekScheduler_container").getElementsByClassName('print_user_button');
            for (var index = 0; index < a.length; ++index) {
              var item = a[index];
              item.hide();
            }
            var a = $("weekScheduler_container").getElementsByClassName('print_patient_button');
            for (var index = 0; index < a.length; ++index) {
              var item = a[index];
              item.style.display = '';
            }
        }else if(sTab=="user"){
            var a = $("weekScheduler_container").getElementsByClassName('print_user_button');
            for (var index = 0; index < a.length; ++index) {
              var item = a[index];
              item.style.display = '';
            }
            var a = $("weekScheduler_container").getElementsByClassName('print_patient_button');
            for (var index = 0; index < a.length; ++index) {
              var item = a[index];
              item.hide();
            }

        }
  }
     activateTab("<%=sTab%>",true);
</script>