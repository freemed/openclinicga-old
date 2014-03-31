<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.dentist.consultation","select",activeUser)%>

<%=sJSGRAPHICS%>
<%=sJSHASHTABLE%>

<script>
  var vSelectedHashtable = new Hashtable();
</script>

<%!
    //--- ADD TOOTH -------------------------------------------------------------------------------
    private StringBuffer addTooth(int iTotal, String sDate, String sToothNr, String sDescription,
                                  String sTreatment, String sStatus, String sWebLanguage){
        sTreatment = sTreatment.replaceAll("\r\n","<br>");
        sDescription = sDescription.replaceAll("\r\n","<br>");

        StringBuffer sTmp = new StringBuffer();
        sTmp.append("<tr id='rowTooth").append(iTotal).append("'>")
             .append("<td class='admin2'>")
              .append("<a href='javascript:deleteTooth(rowTooth").append(iTotal).append(");'><img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' alt='"+getTran("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></a> ")
              .append("<a href='javascript:editTooth(rowTooth").append(iTotal).append(");'><img src='"+sCONTEXTPATH+"/_img/icon_edit.gif' alt='"+getTran("Web.Occup","medwan.common.edit",sWebLanguage)+"' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;").append(sDate).append("</td>")
             .append("<td class='admin2'>&nbsp;").append(sToothNr).append("</td>")
             .append("<td class='admin2'>").append(sDescription).append("</td>")
             .append("<td class='admin2'>").append(sTreatment).append("</td>")
             .append("<td class='admin2'>&nbsp;").append(getTran("openclinic.chuk",sStatus,sWebLanguage)).append("</td>")
             .append("<td class='admin2'></td>")
            .append("</tr>");

        return sTmp;
    }
%>
<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>

<%
    StringBuffer sTeeth = new StringBuffer(),
                 sDivTeeth = new StringBuffer();
    int iTeethTotal = 1;

    TransactionVO tran = (TransactionVO)transaction;
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH1"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH2"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH3"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH4"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH5"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH6"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH7"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH8"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH9"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH10"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH11"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH12"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH13"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH14"));
    sTeeth.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH15"));

    if (sTeeth.indexOf("£")>-1){
        StringBuffer sTmpTeeth = sTeeth;
        String sTmpTooth,sTmpDescription,sTmpTreatment,sTmpStatus, sTmpDate;
        sTeeth = new StringBuffer();

        String[] teeth = sTmpTeeth.toString().split("\\$");
        for (int n=0;n<teeth.length;n++) {
            sTmpDate = "";
            sTmpTooth  = "";
            sTmpDescription = "";
            sTmpTreatment  = "";
            sTmpStatus = "";

            if(teeth[n].split("£").length>0){
                sTmpDate = teeth[n].split("£")[0];
            }

            if(teeth[n].split("£").length>1){
                sTmpTooth = teeth[n].split("£")[1];
            }

            if(teeth[n].split("£").length>2){
                sTmpDescription = teeth[n].split("£")[2];
            }

            if(teeth[n].split("£").length>3){
                sTmpTreatment = teeth[n].split("£")[3];
            }

            if(teeth[n].split("£").length>4){
                sTmpStatus = teeth[n].split("£")[4];
            }

            sTeeth.append("rowTooth"+iTeethTotal+"="+sTmpDate+"£"+sTmpTooth+"£"+sTmpDescription+"£"+sTmpTreatment+"£"+sTmpStatus+"$");
            sDivTeeth.append(addTooth(iTeethTotal, sTmpDate,sTmpTooth,sTmpDescription,sTmpTreatment, sTmpStatus, sWebLanguage));
            iTeethTotal++;

            %><script>vSelectedHashtable.put("<%=sTmpTooth%>","<%=sTmpStatus%>");</script><%
        }
    }
%>

    <table cellspacing="1" cellpadding="0" >
        <tr>
            <%-- IMAGE --%>
            <td align="center">
                <div id="img_gebit" style="position:relative;height:300px;width:309px;">
                    <img src="<c:url value='/'/>_img/img_gebit.gif" alt=""/>
                </div>
            </td>

            <%-- LEGEND --%>
            <td style="vertical-align:top;">
                <table cellspacing="1" cellpadding="0">
                    <tr>
                        <td><div width="10" height="10" style="background-color: aqua;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.absent",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: blue;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.fill",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: fuchsia;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.unnerve",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: gray;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.unnerve_fill",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: lime;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.fracturée",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: maroon;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.impactée",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: gold;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.incluse",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: red;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.ectopique",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: green;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.surnuméraire",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: black;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.caries",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><div width="10" height="10" style="background-color: orange;">&nbsp;&nbsp;</div></td><td>&nbsp;<%=getTran("openclinic.chuk","tooth.other",sWebLanguage)%></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <%=contextHeader(request,sWebLanguage)%>

    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<%=getDate()%>">
            </td>
        </tr>

        <tr>
            <td colspan="2">
                <table cellspacing="1" cellpadding="0" width="100%" id="tblTeeth">
                    <%-- header --%>
                    <tr>
                        <td class="admin" width="40px"></td>
                        <td class="admin" width="50px"><%=getTran("web.occup","medwan.common.date",sWebLanguage)%></td>
                        <td class="admin" width="50px"><%=getTran("openclinic.chuk","tooth",sWebLanguage)%></td>
                        <td class="admin" width="250px"><%=getTran("openclinic.chuk","problem description",sWebLanguage)%></td>
                        <td class="admin" width="250px"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
                        <td class="admin" width="150px"><%=getTran("openclinic.chuk","status",sWebLanguage)%></td>
                        <td class="admin" width="*"/>
                    </tr>

                    <%-- add-row --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2" style="vertical-align:top;">
                            <%=writeDateField("toothDate","transactionForm",getDate(),sWebLanguage)%>
                        </td>
                        <td class="admin2" style="vertical-align:top;">
                            <input class="text" type="text" name="toothNr" value="" size="4" onblur="checkTeethNumber(this);"/>
                        </td>
                        <td class="admin2" style="vertical-align:top;">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="toothDescription"></textarea>
                        </td>
                        <td class="admin2" style="vertical-align:top;">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="toothTreatment"></textarea>
                        </td>
                        <td class="admin2" style="vertical-align:top;">
                            <select class="text" name="toothStatus">
                            	<option value=""></option>
                                <option value="tooth.absent"><%=getTran("openclinic.chuk","tooth.absent",sWebLanguage)%></option>
                                <option value="tooth.fill"><%=getTran("openclinic.chuk","tooth.fill",sWebLanguage)%></option>
                                <option value="tooth.unnerve"><%=getTran("openclinic.chuk","tooth.unnerve",sWebLanguage)%></option>
                                <option value="tooth.unnerve_fill"><%=getTran("openclinic.chuk","tooth.unnerve_fill",sWebLanguage)%></option>
                                <option value="tooth.fracturée"><%=getTran("openclinic.chuk","tooth.fracturée",sWebLanguage)%></option>
                                <option value="tooth.impactée"><%=getTran("openclinic.chuk","tooth.impactée",sWebLanguage)%></option>
                                <option value="tooth.incluse"><%=getTran("openclinic.chuk","tooth.incluse",sWebLanguage)%></option>
                                <option value="tooth.ectopique"><%=getTran("openclinic.chuk","tooth.ectopique",sWebLanguage)%></option>
                                <option value="tooth.surnuméraire"><%=getTran("openclinic.chuk","tooth.surnuméraire",sWebLanguage)%></option>
                                <option value="tooth.caries"><%=getTran("openclinic.chuk","tooth.caries",sWebLanguage)%></option>
                                <option value="tooth.other"><%=getTran("openclinic.chuk","tooth.other",sWebLanguage)%></option>
                            </select>
                        </td>

                        <%-- add buttons --%>
                        <td class="admin2">
                            <input type="button" class="button" name="ButtonAddTooth" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addTooth(true);">
                            <input type="button" class="button" name="ButtonUpdateTooth" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateTooth();">
                        </td>
                    </tr>

                    <%-- hidden fields --%>
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH1" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH2" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH3" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH4" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH5" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH6" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH7" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH8" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH9" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH10" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH11" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH12" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH13" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH14" property="itemId"/>]>.value">
                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH15" property="itemId"/>]>.value">

                    <%=sDivTeeth%>
                </table>
            </td>
        </tr>

        <%-- STATE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","state",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_STOMATOLOGY_DENTIST_STATE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_DENTIST_STATE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_DENTIST_STATE" property="value"/></textarea>
            </td>
        </tr>

        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DENTIST_COMMENT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DENTIST_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DENTIST_COMMENT" property="value"/></textarea>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>                    
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.dentist.consultation",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<%=writeJSButtons("transactionForm", "saveButton")%>

<script>
  var iTeethIndex = <%=iTeethTotal%>;
  var sTeeth = "<%=sTeeth.toString().replaceAll("\r\n","<br>")%>";
  var editTeethRowid = "";

  var cnv = document.getElementById("img_gebit");
  var jg = new jsGraphics(cnv);
  var coord;
  var vHashtable = new Hashtable();

  fillCoordsHashtable();
  markTeeths();

function addTooth(displayAlert){
  if(isAtLeastOneToothFieldFilled()){
    vSelectedHashtable.put(transactionForm.toothNr.value,transactionForm.toothStatus.value);
    iTeethIndex++;

    sTeeth+="rowTooth"+iTeethIndex+"="+transactionForm.toothDate.value+"£"
                                      +transactionForm.toothNr.value+"£"
                                      +transactionForm.toothDescription.value+"£"
                                      +transactionForm.toothTreatment.value+"£"
                                      +transactionForm.toothStatus.value+"$";
    var tr = tblTeeth.insertRow(tblTeeth.rows.length);
    tr.id = "rowTooth"+iTeethIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteTooth(rowTooth"+iTeethIndex+");'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                  +"<a href='javascript:editTooth(rowTooth"+iTeethIndex+");'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+transactionForm.toothDate.value;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+transactionForm.toothNr.value;
    tr.appendChild(td);

    td = tr.insertCell(3);
    while(transactionForm.toothDescription.value.indexOf("\r\n") > -1){
      transactionForm.toothDescription.value = transactionForm.toothDescription.value.replace("\r\n","<br>");
    }
    td.innerHTML = transactionForm.toothDescription.value;
    tr.appendChild(td);

    td = tr.insertCell(4);
    while(transactionForm.toothTreatment.value.indexOf("\r\n") > -1){
      transactionForm.toothTreatment.value = transactionForm.toothTreatment.value.replace("\r\n","<br>");
    }
    td.innerHTML = transactionForm.toothTreatment.value;
    tr.appendChild(td);

    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;"+translate(transactionForm.toothStatus.value);
    tr.appendChild(td);

    td = tr.insertCell(6);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);

    setCellStyle(tr);
    clearToothFields()
    transactionForm.ButtonUpdateTooth.disabled = true;
    markTeeths();
  }
  else{
    if(displayAlert){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      transactionForm.toothNr.focus();

      if(window.showModalDialog){
        window.showModalDialog(popupUrl,"",modalities);
      }
      else{
        window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
      }
    }
  }

  return true;
}

function updateTooth(){
  if(isAtLeastOneToothFieldFilled()){
    <%-- update arrayString --%>
    vSelectedHashtable.put(transactionForm.toothNr.value,transactionForm.toothStatus.value);
    updateSelectedHashtable(transactionForm.toothNr.value,transactionForm.toothStatus.value,getCelFromRowString(getRowFromArrayString(sTeeth,editTeethRowid.id),0));
    var newRow, row;

    newRow = editTeethRowid.id+"="+transactionForm.toothDate.value+"£"
                                  +transactionForm.toothNr.value+"£"
                                  +transactionForm.toothDescription.value+"£"
                                  +transactionForm.toothTreatment.value+"£"
                                  +transactionForm.toothStatus.value;

    sTeeth = replaceRowInArrayString(sTeeth,newRow,editTeethRowid.id);

    <%-- update table object --%>
    row = tblTeeth.rows[editTeethRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='javascript:deleteTooth("+editTeethRowid.id+");'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editTooth("+editTeethRowid.id+");'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+ transactionForm.toothDate.value;
    row.cells[2].innerHTML = "&nbsp;"+ transactionForm.toothNr.value;

    while(transactionForm.toothDescription.value.indexOf("\r\n") > -1){
      transactionForm.toothDescription.value = transactionForm.toothDescription.value.replace("\r\n","<br>");
    }
    row.cells[3].innerHTML = transactionForm.toothDescription.value;

    while(transactionForm.toothTreatment.value.indexOf("\r\n") > -1){
      transactionForm.toothTreatment.value = transactionForm.toothTreatment.value.replace("\r\n","<br>");
    }
    row.cells[4].innerHTML = transactionForm.toothTreatment.value;

    row.cells[5].innerHTML = "&nbsp;"+ translate(transactionForm.toothStatus.value);

    setCellStyle(row);
    clearToothFields();
    transactionForm.ButtonUpdateTooth.disabled = true;
    markTeeths();
  }
}

function isAtLeastOneToothFieldFilled(){
  if(transactionForm.toothNr.value != "")          return true;
  if(transactionForm.toothDescription.value != "") return true;
  if(transactionForm.toothTreatment.value != "")   return true;
  if(transactionForm.toothStatus.value != "")      return true;
  return false;
}

function clearToothFields(){
  transactionForm.toothDate.value = "";
  transactionForm.toothNr.value = "";
  transactionForm.toothDescription.value = "";
  transactionForm.toothTreatment.value = "";
  transactionForm.toothStatus.value = "";
}

function deleteTooth(rowid){
  var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
  var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
  var answer;

  if(window.showModalDialog){
    answer = window.showModalDialog(popupUrl,'',modalities);
  }
  else{
    answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
  }

  if(answer==1){
    vSelectedHashtable.remove(getCelFromRowString(getRowFromArrayString(sTeeth,rowid.id),0));
    sTeeth = deleteRowFromArrayString(sTeeth,rowid.id);
    tblTeeth.deleteRow(rowid.rowIndex);
    clearToothFields();
    markTeeths();
  }
}

function editTooth(rowid){
  resizeTextarea(transactionForm.toothDescription);
  resizeTextarea(transactionForm.toothTreatment);

  var row = getRowFromArrayString(sTeeth,rowid.id);
  transactionForm.toothDate.value = getCelFromRowString(row,0);
  transactionForm.toothNr.value   = getCelFromRowString(row,1);

  transactionForm.toothDescription.value = getCelFromRowString(row,2).replace("<br>","\r\n");
  while(transactionForm.toothDescription.value.indexOf("<br>") > -1){
    transactionForm.toothDescription.value = transactionForm.toothDescription.value.replace("<br>","\r\n");
  }

  transactionForm.toothTreatment.value = getCelFromRowString(row,3).replace("<br>","\r\n");
  while(transactionForm.toothTreatment.value.indexOf("<br>") > -1){
    transactionForm.toothTreatment.value = transactionForm.toothTreatment.value.replace("<br>","\r\n");
  }
    
  transactionForm.toothStatus.value = getCelFromRowString(row,4);

  editTeethRowid = rowid;
  transactionForm.ButtonUpdateTooth.disabled = false;
}

<!-- GENERAL FUNCTIONS -------------------------------------------------------------------------->
function deleteRowFromArrayString(sArray,rowid){
  var array = sArray.split("$");
  for(var i=0; i<array.length; i++){
    if(array[i].indexOf(rowid) > -1){
      array.splice(i,1);
    }
  }
  return array.join("$");
}

  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
    return row;
  }

  function getCelFromRowString(sRow,celid){
    var row = sRow.split("£");
    return row[celid];
  }

  function replaceRowInArrayString(sArray,newRow,rowid){
    var array = sArray.split("$");
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        array.splice(i,1,newRow);
        break;
      }
    }

    return array.join("$")
  }

  <%--SUBMIT FORM --%>
  function submitForm() {
    if(document.getElementById('encounteruid').value==''){
		alertDialog("web","no.encounter.linked");
		searchEncounter();
	}	
    else{
	    var maySubmit = true;
	
	    if(isAtLeastOneToothFieldFilled()){
	      if(maySubmit){
	        if(!addTooth(false)){
	          maySubmit = false;
	        }
	      }
	    }
	
	    var sTmpBegin;
	    var sTmpEnd;
	
	    while(sTeeth.indexOf("rowTooth") > -1){
	      sTmpBegin = sTeeth.substring(sTeeth.indexOf("rowTooth"));
	      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
	      sTeeth = sTeeth.substring(0, sTeeth.indexOf("rowTooth"))+sTmpEnd;
	    }
	
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH1" property="itemId"/>]>.value")[0].value = sTeeth.substring(0,254);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH2" property="itemId"/>]>.value")[0].value = sTeeth.substring(254,508);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH3" property="itemId"/>]>.value")[0].value = sTeeth.substring(508,762);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH4" property="itemId"/>]>.value")[0].value = sTeeth.substring(762,1016);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH5" property="itemId"/>]>.value")[0].value = sTeeth.substring(1016,1270);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH6" property="itemId"/>]>.value")[0].value = sTeeth.substring(1270,1524);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH7" property="itemId"/>]>.value")[0].value = sTeeth.substring(1524,1778);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH8" property="itemId"/>]>.value")[0].value = sTeeth.substring(1778,2032);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH9" property="itemId"/>]>.value")[0].value = sTeeth.substring(2032,2286);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH10" property="itemId"/>]>.value")[0].value = sTeeth.substring(2286,2540);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH11" property="itemId"/>]>.value")[0].value = sTeeth.substring(2540,2794);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH12" property="itemId"/>]>.value")[0].value = sTeeth.substring(2794,3048);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH13" property="itemId"/>]>.value")[0].value = sTeeth.substring(3048,3302);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH14" property="itemId"/>]>.value")[0].value = sTeeth.substring(3302,3556);
	    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH15" property="itemId"/>]>.value")[0].value = sTeeth.substring(3556,3810);
	
	    if(maySubmit){
	      var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	      document.getElementById("buttonsDiv").style.visibility = "hidden";
	      <%
	          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	      %>
	    }
    }
  }
  
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if(document.getElementById('encounteruid').value==''){
	alertDialog("web","no.encounter.linked");
	searchEncounter();
  }	

  <%-- SETT CELL STYLE --%>
  function setCellStyle(row){
    for(var i =0;i<row.cells.length;i++){
      row.cells[i].style.color = "#333333";
      row.cells[i].style.fontFamily = "arial";
      row.cells[i].style.fontSize = "10px";
      row.cells[i].style.fontWeight = "normal";
      row.cells[i].style.textAlign = "left";
      row.cells[i].style.paddingLeft = "5px";
      row.cells[i].style.paddingRight = "1px";
      row.cells[i].style.paddingTop = "1px";
      row.cells[i].style.paddingBottom = "1px";
      row.cells[i].style.backgroundColor = "#E0EBF2";
    }
  }

  <%-- CHECK TOOTH NUMBER --%>
  function checkTeethNumber(toothNr){
    if(vHashtable.containsKey(toothNr.value)){
      if(vSelectedHashtable.containsKey(toothNr.value)){
        //transactionForm.toothNr.value = "";
      }
    }
    else{
      transactionForm.toothNr.value = "";
    }
  }

  <%-- UPDATE SELECTED HASH TABLE --%>
  function updateSelectedHashtable(tooth,status,oldTooth){
    if(vSelectedHashtable.containsKey(oldTooth)){
      vSelectedHashtable.remove(oldTooth);
      vSelectedHashtable.put(tooth,status);
    }
  }

  <%-- FILL COORDS HASH TABLE --%>
  function fillCoordsHashtable(){
    try{
        coord = new Array(75,21,10,10);
      vHashtable.put(11,coord);
        coord = new Array(57,28,10,10);
      vHashtable.put(12,coord);
        coord = new Array(46,41,10,10);
      vHashtable.put(13,coord);
        coord = new Array(38,57,10,10);
      vHashtable.put(14,coord);
        coord = new Array(29,74,10,10);
      vHashtable.put(15,coord);
        coord = new Array(23,92,10,10);
      vHashtable.put(16,coord);
        coord = new Array(19,112,10,10);
      vHashtable.put(17,coord);
        coord = new Array(21,132,10,10);
      vHashtable.put(18,coord);
        coord = new Array(95,21,10,10);
      vHashtable.put(21,coord);
        coord = new Array(112,28,10,10);
      vHashtable.put(22,coord);
        coord = new Array(124,40,10,10);
      vHashtable.put(23,coord);
        coord = new Array(133,55,10,10);
      vHashtable.put(24,coord);
        coord = new Array(141,74,10,10);
      vHashtable.put(25,coord);
        coord = new Array(148,92,10,10);
      vHashtable.put(26,coord);
        coord = new Array(151,112,10,10);
      vHashtable.put(27,coord);
        coord = new Array(152,132,10,10);
      vHashtable.put(28,coord);
        coord = new Array(92,276,7,7);
      vHashtable.put(31,coord);
        coord = new Array(106,272,7,7);
      vHashtable.put(32,coord);
        coord = new Array(116,264,7,7);
      vHashtable.put(33,coord);
        coord = new Array(125,250,10,10);
      vHashtable.put(34,coord);
        coord = new Array(137,232,10,10);
      vHashtable.put(35,coord);
        coord = new Array(145,212,10,10);
      vHashtable.put(36,coord);
        coord = new Array(149,188,10,10);
      vHashtable.put(37,coord);
        coord = new Array(149,165,10,10);
      vHashtable.put(38,coord);
        coord = new Array(79,275,7,7);
      vHashtable.put(41,coord);
        coord = new Array(66,272,7,7);
      vHashtable.put(42,coord);
        coord = new Array(56,264,7,7);
      vHashtable.put(43,coord);
        coord = new Array(43,249,10,10);
      vHashtable.put(44,coord);
        coord = new Array(31,230,10,10);
      vHashtable.put(45,coord);
        coord = new Array(22,207,10,10);
      vHashtable.put(46,coord);
        coord = new Array(19,186,10,10);
      vHashtable.put(47,coord);
        coord = new Array(21,165,10,10);
      vHashtable.put(48,coord);
        coord = new Array(225,69,10,10);
      vHashtable.put(51,coord);
        coord = new Array(212,79,10,10);
      vHashtable.put(52,coord);
        coord = new Array(203,94,10,10);
      vHashtable.put(53,coord);
        coord = new Array(194,111,10,10);
      vHashtable.put(54,coord);
        coord = new Array(193,132,10,10);
      vHashtable.put(55,coord);
        coord = new Array(240,70,10,10);
      vHashtable.put(61,coord);
        coord = new Array(253,79,10,10);
      vHashtable.put(62,coord);
        coord = new Array(262,91,10,10);
      vHashtable.put(63,coord);
        coord = new Array(272,110,10,10);
      vHashtable.put(64,coord);
        coord = new Array(274,130,10,10);
      vHashtable.put(65,coord);
        coord = new Array(242,226,7,7);
      vHashtable.put(71,coord);
        coord = new Array(253,218,10,10);
      vHashtable.put(72,coord);
        coord = new Array(265,207,10,10);
      vHashtable.put(73,coord);
        coord = new Array(273,190,10,10);
      vHashtable.put(74,coord);
        coord = new Array(275,169,10,10);
      vHashtable.put(75,coord);
        coord = new Array(227,226,7,7);
      vHashtable.put(81,coord);
        coord = new Array(212,219,10,10);
      vHashtable.put(82,coord);
        coord = new Array(201,207,10,10);
      vHashtable.put(83,coord);
        coord = new Array(192,190,10,10);
      vHashtable.put(84,coord);
        coord = new Array(190,170,10,10);
      vHashtable.put(85,coord);
    }
    catch(error){
      alert("Hashtable put() error: "+error.name);
    }
  }

  <%-- MARK TEETH --%>
  function markTeeths(){
    jg.clear();

    var array = vSelectedHashtable.keys();
    for(var i=0; i<vSelectedHashtable.keys().length; i++){
      draw(array[i],vSelectedHashtable.get(array[i]));
    }
  }

  <%-- DRAW --%>
  function draw(tooth, status){
    if(vHashtable.containsKey(tooth)){
      var tmpCoord = vHashtable.get(tooth);

      if(status!=""){
             if(status=="tooth.absent")       jg.setColor("aqua");
        else if(status=="tooth.fill")         jg.setColor("blue");
        else if(status=="tooth.unnerve")      jg.setColor("fuchsia");
        else if(status=="tooth.unnerve_fill") jg.setColor("gray");
        else if(status=="tooth.fracturée")    jg.setColor("lime");
        else if(status=="tooth.impactée")     jg.setColor("maroon");
        else if(status=="tooth.incluse")      jg.setColor("gold");
        else if(status=="tooth.ectopique")    jg.setColor("red");
        else if(status=="tooth.surnuméraire") jg.setColor("green");
        else if(status=="tooth.caries") 		jg.setColor("black");
        else if(status=="tooth.other") 		jg.setColor("orange");

        jg.fillEllipse(tmpCoord[0],tmpCoord[1],tmpCoord[2],tmpCoord[3]);
        jg.paint();
      }
    }
  }

  <%-- TRANSLATE --%>
  function translate(tmpLabel){
    if(tmpLabel=="tooth.absent"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.absent",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.fill"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.fill",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.unnerve"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.unnerve",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.unnerve_fill"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.unnerve_fill",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.fracturée"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.fracturée",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.impactée"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.impactée",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.incluse"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.incluse",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.ectopique"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.ectopique",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.surnuméraire"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.surnuméraire",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.caries"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.caries",sWebLanguage)%>";
    }
    else if(tmpLabel=="tooth.other"){
      return "<%=getTranNoLink("openclinic.chuk","tooth.other",sWebLanguage)%>";
    }

    return "";
  }
</script>