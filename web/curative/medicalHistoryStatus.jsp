<%@page import="be.openclinic.adt.Encounter" %>
<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
try{
    // context
    String contextSelector =(String)session.getAttribute("contextSelector");
    if(contextSelector==null){
        contextSelector = activeUser.activeService.code;
    }
%>
<table width="100%" class="list" cellspacing="0">
    <form name="transactionForm" method="post">
        <input type="hidden" name="Page" value="curative/index.jsp"/>
        <%-- PAGE TITLE --%>
        <tr class="admin">
            <td>
                <%=getTran("curative","medicalhistory.status.title",sWebLanguage)%>&nbsp;
                <a href="javascript:newExamination();"><img src="<c:url value='/_img/icon_new.gif'/>" class="link" alt="<%=getTran("web","manageexaminations",sWebLanguage)%>" style="vertical-align:-4px;"></a>
				<%if(MedwanQuery.getInstance().getConfigString("quickTransaction1."+activeUser.userid,"").length()>0){ %>
                    <a href="javascript:newFastTransaction('<%=MedwanQuery.getInstance().getConfigString("quickTransaction1."+activeUser.userid)%>');"><img src="<c:url value='/_img/icon_new1.gif'/>" class="link" title="<%=getTranNoLink("web.occup",MedwanQuery.getInstance().getConfigString("quickTransaction1."+activeUser.userid).split("\\&")[0],sWebLanguage)%>" style="vertical-align:-4px;"></a>
                <%} %>
				<%if(MedwanQuery.getInstance().getConfigString("quickTransaction2."+activeUser.userid,"").length()>0){ %>
                    <a href="javascript:newFastTransaction('<%=MedwanQuery.getInstance().getConfigString("quickTransaction2."+activeUser.userid)%>');"><img src="<c:url value='/_img/icon_new2.gif'/>" class="link" title="<%=getTranNoLink("web.occup",MedwanQuery.getInstance().getConfigString("quickTransaction2."+activeUser.userid).split("\\&")[0],sWebLanguage)%>" style="vertical-align:-4px;"></a>
                <%} %>
				<%if(MedwanQuery.getInstance().getConfigString("quickTransaction3."+activeUser.userid,"").length()>0){ %>
                    <a href="javascript:newFastTransaction('<%=MedwanQuery.getInstance().getConfigString("quickTransaction3."+activeUser.userid)%>');"><img src="<c:url value='/_img/icon_new3.gif'/>" class="link" title="<%=getTranNoLink("web.occup",MedwanQuery.getInstance().getConfigString("quickTransaction3."+activeUser.userid).split("\\&")[0],sWebLanguage)%>" style="vertical-align:-4px;"></a>
                <%} %>
				<%if(MedwanQuery.getInstance().getConfigString("quickTransaction4."+activeUser.userid,"").length()>0){ %>
                    <a href="javascript:newFastTransaction('<%=MedwanQuery.getInstance().getConfigString("quickTransaction4."+activeUser.userid)%>');"><img src="<c:url value='/_img/icon_new4.gif'/>" class="link" title="<%=getTranNoLink("web.occup",MedwanQuery.getInstance().getConfigString("quickTransaction4."+activeUser.userid).split("\\&")[0],sWebLanguage)%>" style="vertical-align:-4px;"></a>
                <%} %>
				<%if(MedwanQuery.getInstance().getConfigString("quickTransaction5."+activeUser.userid,"").length()>0){ %>
                    <a href="javascript:newFastTransaction('<%=MedwanQuery.getInstance().getConfigString("quickTransaction5."+activeUser.userid)%>');"><img src="<c:url value='/_img/icon_new5.gif'/>" class="link" title="<%=getTranNoLink("web.occup",MedwanQuery.getInstance().getConfigString("quickTransaction5."+activeUser.userid).split("\\&")[0],sWebLanguage)%>" style="vertical-align:-4px;"></a>
                <%} %>
            </td>
        </tr>

        <tr>
            <td style="padding:0;">
                <%-- EXAMINATIONS OVERVIEW ------------------------------------------------------%>
                <%
                    if (activePatient != null) {
                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                        sessionContainerWO.init(activePatient.personid);

                        if (sessionContainerWO.getTransactionsLimited() != null && sessionContainerWO.getTransactionsLimited().size() > 0) {
                            %>
                                <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="healthRecordVO">
                                <table width="100%" cellspacing="0" class="sortable" id="searchresults" style="border:0;">

                                    <%-- HEADER --%>
                                    <tr class='gray'>
                                        <td width='1%'>&nbsp;</td>
                                        <td align="center" width='100'><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                                        <td align="center" width='42%'><%=getTran("Web.Occup","medwan.common.contacttype",sWebLanguage)%></td>
                                        <td align="center" width='20%'><%=getTran("Web.Occup","medwan.common.user",sWebLanguage)%></td>
                                        <td align="center" width='*'>
                                            <select class="text" name="contextSelector" id="contextSelector" onchange="transactionForm.submit();">
                                                <%
                                                    String sTmpContextSelector = checkString(request.getParameter("contextSelector"));
                                                %>
                                                <option value=""<%if(sTmpContextSelector.equals("")){out.print(" selected");}%>/>
                                                <%
                                                    if(!sTmpContextSelector.equalsIgnoreCase(contextSelector)){
                                                        contextSelector = sTmpContextSelector;
                                                        session.setAttribute("contextSelector",contextSelector);
                                                        sessionContainerWO.getFlags().setContext(contextSelector);
                                                    }
                                                    Service service;
                                                    for (int i=0; i<activeUser.vServices.size(); i++){
                                                        service = (Service)activeUser.vServices.elementAt(i);
                                                        %><option value="<%=service.code%>"<%if(service.code.equals(contextSelector)){out.print(" selected");}%>><%=getTran("Service",service.code,sWebLanguage)%></option><%
                                                    }
                                                %>
                                            </select>
                                        </td>
                                    </tr>
                                    <%
                                        Iterator transactions = new Vector().iterator();
                                        try{
                                            if ("1".equalsIgnoreCase(request.getParameter("showAll"))) {
                                                transactions = sessionContainerWO.getHealthRecordVO().getTransactions().iterator();
                                            } 
                                            else {
                                                transactions = sessionContainerWO.getTransactionsLimited().iterator();
                                            }
                                        }
                                        catch(Exception e){
                                            e.printStackTrace();
                                        }

                                        String sClass, transactionType, sList = "", docType, servicecode;
                                        TransactionVO transactionVO;
                                        ItemVO itemVO, item, encounteritem;
                                        Encounter encounter;
                                        Encounter activeEncounter;

                                        while(transactions.hasNext()){
                                            transactionVO = (TransactionVO) transactions.next();
                                            itemVO = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                                            encounteritem = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                                            servicecode="";
                                            if(encounteritem!=null){
                                            	encounter = Encounter.get(encounteritem.getValue());
                                            	if(encounter!=null){
                                            		servicecode= encounter.getServiceUID(transactionVO.getUpdateDateTime());
                                            	}
                                            }
                                            if(contextSelector == null || contextSelector.length() == 0 || (itemVO != null && itemVO.getValue()!=null && itemVO.getValue().equalsIgnoreCase(contextSelector))) {
                                                activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
                                                sClass = "disabled";

                                                try{
                                                    if(activeEncounter != null && transactionVO.getUpdateTime()!=null && activeEncounter!=null && !transactionVO.getUpdateTime().before(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(activeEncounter.getBegin()))) && (activeEncounter.getEnd() == null || !transactionVO.getUpdateTime().after(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(activeEncounter.getEnd()))))) {
                                                        sClass = "bold";
                                                    }
                                                }
                                                catch(Exception e){
                                                    e.printStackTrace();
                                                }
                                                
                                                // alternate row-styles
                                                if(sList.equals("")) sList = "1";
                                                else                 sList = "";
                                    %>
                                                    <tr id="<%=sClass%>" class="list<%=sClass+sList%>" >
                                                        <td class="modal" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' onclick="deltran(<%=transactionVO.getTransactionId()%>,<%=transactionVO.getServerId()%>,<%=transactionVO.getUser().getUserId()%>)">
                                                            <img class='hand' src="<c:url value='/_img/icon_delete.gif'/>" alt="<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>" border="0">
                                                        </td>
                                                        <td align="center"><%=new SimpleDateFormat("dd/MM/yyyy").format(transactionVO.getUpdateTime())%></td>
                                                        <td align="center">
                                                            <%
                                                                try {
                                                                    transactionType = transactionVO.getTransactionType();

                                                                    //  Document
                                                                    if(transactionType.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DOCUMENT")){
                                                                        %>
                                                                            <a target="refdocument" href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=transactionType%>&be.mxs.healthrecord.transaction_id=<%=transactionVO.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transactionVO.getServerId()%>&ts=<%=getTs()%>" onMouseOver="window.status='';return true;">
                                                                                <%=getTran("web.occup",transactionType,sWebLanguage)%>
                                                                                <%

                                                                                    docType = "ERROR";
                                                                                    item = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOCUMENT_TYPE");

                                                                                    if (item==null){
                                                                                        item = transactionVO.getItem("documentId");

                                                                                        if (item!=null){
                                                                                            docType = item.getValue().replaceAll(".pdf","");
                                                                                        }
                                                                                    }
                                                                                    else{
                                                                                        docType = item.getValue();
                                                                                    }

                                                                                %>
                                                                                (<%=getTran("web.documents",docType,sWebLanguage)%>)
                                                                            </a>
                                                                        <%
                                                                    }
                                                                    else if(transactionType.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_EXTERNAL_DOCUMENT")){
                                                                        %>
                                                                            <a href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=transactionType%>&be.mxs.healthrecord.transaction_id=<%=transactionVO.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transactionVO.getServerId()%>&ts=<%=getTs()%>" onMouseOver="window.status='';return true;">
                                                                                <%=getTran("web.occup",transactionType,sWebLanguage)%>
                                                                                <%
                                                                                    item = MedwanQuery.getInstance().getItem(transactionVO.getServerId(),transactionVO.getTransactionId().intValue(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EXTERNAL_DOCUMENT_TITLE");
                                                                                    String sDocumentTitle = "";
                                                                                    if (item!=null){
                                                                                        sDocumentTitle = checkString(item.getValue());
                                                                                    }
                                                                                %>
                                                                                (<%=sDocumentTitle%>)
                                                                            </a>
                                                                        <%
                                                                    }
                                                                    // no Document
                                                                    else{
                                                                        %>
                                                                            <a href="<c:url value='/healthrecord/editTransaction.do'/>?be.mxs.healthrecord.createTransaction.transactionType=<%=transactionType%>&be.mxs.healthrecord.transaction_id=<%=transactionVO.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=transactionVO.getServerId()%>&ts=<%=getTs()%>" onMouseOver="window.status='';return true;">
                                                                                <%=getTran("web.occup",transactionType,sWebLanguage)%>
                                                                        <%

                                                                        // add vaccination type
                                                                        if(transactionType.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION")){
                                                                            ItemVO vItem = transactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE");
                                                                            if(vItem!=null){
                                                                                %> (<%=getTran("web.occup",vItem.getValue(),sWebLanguage)%>)<%
                                                                            }
                                                                        }

                                                                        %>
                                                                            </a>
                                                                        <%
                                                                    }
                                                                }
                                                                catch(Exception e){
                                                                    e.printStackTrace();
                                                                }
                                                            %>
                                                        </td>
                                                        <td align="center"><%=transactionVO.getUser()!=null?transactionVO.getUser().getPersonVO().getFirstname():""%>,&nbsp;<%=transactionVO.getUser()!=null?transactionVO.getUser().getPersonVO().getLastname():""%></td>
                                                        <td align="center"><%=servicecode.length()>0?servicecode+": "+getTran("service",servicecode,sWebLanguage):getTran("service",itemVO!=null?itemVO.getValue():"",sWebLanguage)%></td>
                                                    </tr>
                                                <%
                                            }
                                        }
                                    %>
                                </table>
                                </logic:present>

                                <br>
                            <%
                            // SHOW "ALL EXAMINATIONS"-LINK
                            if(sessionContainerWO.getHealthRecordVO()!=null){
                                int totalTransactions =  sessionContainerWO.getHealthRecordVO().getTransactions().size();

                                int numberOfTransToList = MedwanQuery.getInstance().getConfigInt("numberOfTransToListInSummary");
                                if(numberOfTransToList < 0) numberOfTransToList = 25; // default

                                if(!"1".equalsIgnoreCase(request.getParameter("showAll")) && totalTransactions > numberOfTransToList){
                                    %>
                                        <img src='<c:url value="/_img/pijl.gif"/>'>
                                        <a href="<c:url value='/main.do?Page=/curative/index.jsp'/>&showAll=1&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.common.all",sWebLanguage)%></a>
                                    <%
                                }

                                if("1".equalsIgnoreCase(request.getParameter("showAll"))){
                                    %>
                                        <img src='<c:url value="/_img/pijl.gif"/>'>
                                        <a href="<c:url value='/main.do?Page=/curative/index.jsp'/>&showAll=0&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.common.summary",sWebLanguage)%></a>
                                    <%
                                }
                            }
                        }
                    }
                %>
            </td>
        </tr>
    </form>
</table>

<script>
  <%-- DEL TRAN --%>
  function deltran(transactionId,serverId,userId){
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    if(userId!=<%=activeUser.userid%>){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/promptPopup.jsp&ts=<%=getTs()%>&labelType=web.occup&labelID=medwan.transaction.delete.question";
      var answer =(window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
      if(answer=="deleteit"){
        window.location.href = "<c:url value='/healthrecord/manageDeleteTransaction.do'/>?transactionId="+transactionId+"&serverId="+serverId+"&ts=<%=getTs()%>&be.mxs.healthrecord.updateTransaction.actionForwardKey=/main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
      }
      else{
        popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.occup&labelID=medwan.transaction.delete.wrong-password";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.occup","medwan.transaction.delete.wrong-password",sWebLanguage)%>");
      }
    }
    else{
      if(yesnoDialog("Web","areYouSureToDelete")){
        window.location.href="<c:url value='/healthrecord/manageDeleteTransaction.do'/>?transactionId="+transactionId+"&serverId="+serverId+"&ts=<%=getTs()%>&be.mxs.healthrecord.updateTransaction.actionForwardKey=/main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
      }
    }
  }

  <%-- COMPARE.. --%>
  function compareText (option1, option2) {
    return option1.text < option2.text ? -1 : (option1.text > option2.text ? 1 : 0);
  }

  function compareValue (option1, option2) {
    return option1.value < option2.value ? -1 : (option1.value > option2.value ? 1 : 0);
  }

  function compareTextAsFloat (option1, option2) {
    var value1 = parseFloat(option1.text.replace(",","."));
    var value2 = parseFloat(option2.text.replace(",","."));

    return value1 < value2 ? -1 : (value1 > value2 ? 1 : 0);
  }

  function compareValueAsFloat (option1, option2) {
    var value1 = parseFloat(option1.value.replace(",","."));
    var value2 = parseFloat(option2.value.replace(",","."));

    return value1 < value2 ? -1 : (value1  > value2 ? 1 : 0);
  }

  <%-- SORT SELECT --%>
  function sortSelect(select,compareFunction){
    if(select!=null){
      if(!compareFunction) compareFunction = compareText;

      var options = new Array (select.options.length);
      for(var i=0; i<options.length; i++){
        options[i] =
          new Option (
            select.options[i].text,
            select.options[i].value,
            select.options[i].defaultSelected,
            select.options[i].selected
          );
      }

      options.sort(compareFunction);
      select.options.length = 0;

      for(var i=0; i<options.length; i++){
        select.options[i] = options[i];
        if(select.options[i].value=='<%=contextSelector%>'){
          select.options[i].selected=true;
        }
      }
    }
  }

  <%-- UPDATE ROW STYLES --%>
  function updateRowStyles(){
    var sClassName;

    for(var i=1; i<searchresults.rows.length; i++){
      searchresults.rows[i].style.cursor = "hand";
      sClassName = searchresults.rows[i].className;

      if(sClassName.indexOf("disabled") > -1){
        searchresults.rows[i].className = "listdisabled";
      }
      else if(sClassName.indexOf("bold") > -1){
        searchresults.rows[i].className = "listbold";
      }
      else{
        searchresults.rows[i].className = "list";
      }

      if(i%2>0){
        searchresults.rows[i].className+= "1";
      }

      if(i%2>0){
        searchresults.rows[i].onmouseout = function(){
          if(this.id.indexOf("disabled")==0){
            this.className = "listdisabled1";
          }
          else{
            this.className = "listbold1";
          }
        }
      }
      else{
        searchresults.rows[i].onmouseout = function(){
          if(this.id.indexOf("disabled")==0){
            this.className = "listdisabled";
          }
          else{
            this.className = "listbold";
          }
        }
      }
    }
  }

  sortSelect(document.getElementById('contextSelector'));

  function newExamination(){
	if(<%=Encounter.selectEncounters("","","","","","","","",activePatient.personid,"").size()%>>0){
	  window.location.href="<c:url value='/main.do'/>?Page=curative/manageExaminations.jsp&ts=<%=getTs()%>";
	}
	else{
	  alertDialog("web","create.encounter.first");
	}
  }
</script>
<%
}
catch(Exception e){
	e.printStackTrace();
}
%>