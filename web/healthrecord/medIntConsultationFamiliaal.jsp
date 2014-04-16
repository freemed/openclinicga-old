<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.util.Collection" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<%!
    //--- ADD KINDEREN ----------------------------------------------------------------------------
    private String addKinderen(int iTotal, String sTmpKinderenGeboortejaar, String sTmpKinderenGeslacht, String sTmpKinderenFirstname, String sWebLanguage) {
        StringBuffer sOut = new StringBuffer();

        sOut.append("<tr id='rowKinderen" + iTotal + "'>")
            .append(" <td width='36'>")
            .append("  <a href='javascript:deleteKinderen(rowKinderen" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> ")
            .append("  <a href='javascript:editKinderen(rowKinderen" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>")
            .append(" </td>");

        sOut.append("<td>&nbsp;" + sTmpKinderenGeboortejaar + "</td>");

        // M/F
        sOut.append("<td>&nbsp;");
        if (sTmpKinderenGeslacht.equalsIgnoreCase("M")) {
            sOut.append(getTran("Web.Occup", "Male", sWebLanguage));
        } else if (sTmpKinderenGeslacht.equalsIgnoreCase("F")) {
            sOut.append(getTran("Web.Occup", "Female", sWebLanguage));
        }
        sOut.append("</td>");

        sOut.append(" <td>&nbsp;" + sTmpKinderenFirstname + "</td>")
                .append("</tr>");

        return sOut.toString();
    }

    //--- ADD FAMI --------------------------------------------------------------------------------
    private String addFami(int iTotal, String sTmpFamiDate, String sTmpFamiDescr, String sTmpFamiVerwantschap, String sWebLanguage) {
        return "<tr id='rowFami" + iTotal + "'>"
                + "<td width='36'>"
                + " <a href='javascript:deleteFami(rowFami" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
                + " <a href='javascript:editFami(rowFami" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
                + "</td>"
                + "<td>&nbsp;" + sTmpFamiDate + "</td>"
                + "<td>&nbsp;" + sTmpFamiDescr + "</td>"
                + "<td>&nbsp;" + sTmpFamiVerwantschap + "</td>"
                + "</tr>";
    }

    //--- GET LAST ITEM VALUE ---------------------------------------------------------------------
    private String getLastItemValue(HttpServletRequest request, String sItemType) {
        String sReturn = "";
        ItemVO lastItem = ScreenHelper.getLastItem(request, sItemType);
        if (lastItem != null) {
            sReturn = checkString(lastItem.getValue());
        }

        return sReturn;
    }
%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<%
    String sKinderen = "", sStatus = "", sDivKinderen = "", sFami = "", sDivFami = "", sStatusComment = "", sFamiliaalComment = "";

    if (transaction != null){
        TransactionVO tran = (TransactionVO)transaction;
        if (tran!=null){
            sKinderen         = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_KINDEREN");
            sFami             = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
            sStatus           = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_STATUS");
            sStatusComment    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_STATUS_COMMENT");
            sFamiliaalComment = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
        }

        // herneem data van vorig klinisch onderzoek of RPR
        if (tran.getTransactionId().intValue()<0){
            if (sKinderen.length() == 0){
                sKinderen+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_KINDEREN");
            }

            if (sFami.length() == 0){
                sFami+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
            }

            if (sStatus.length() == 0){
                sStatus+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_STATUS");
            }

            sStatusComment+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_STATUS_COMMENT");

            sFamiliaalComment+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
            for(int i=1; i<8; i++){
                sFamiliaalComment+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT"+i);
            }
        }
    }

    int iTotal = 1;

    //--- kinderen --------------------------------------------------------------------------------
    if ((sKinderen.toLowerCase().startsWith("<tr>"))||(sKinderen.toLowerCase().startsWith("<tbody>"))){
        String sTmpKinderen = sKinderen;
        String sTmpKinderenGeslacht, sTmpKinderenGeboortejaar;
        sKinderen = "";

        while (sTmpKinderen.toLowerCase().indexOf("<tr>")>-1) {
            sTmpKinderenGeslacht = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("<td>")+4,sTmpKinderen.toLowerCase().indexOf("</td>"));
            sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("</td>")+11);
            sTmpKinderenGeboortejaar = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("</td>"));
            sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("</tr>")+5);
            sKinderen += "rowKinderen"+iTotal+"="+sTmpKinderenGeslacht+"£"+sTmpKinderenGeboortejaar+"$";
            sDivKinderen += addKinderen(iTotal,sTmpKinderenGeslacht,sTmpKinderenGeboortejaar,"",sWebLanguage);
            iTotal++;
        }
    }
    else if (sKinderen.indexOf("£")>-1){
        String sTmpKinderen = sKinderen;
        String sTmpKinderenGeboortejaar, sTmpKinderenGeslacht, sTmpKinderenFirstname;
        sKinderen = "";
        while (sTmpKinderen.toLowerCase().indexOf("$")>-1) {
            sTmpKinderenGeboortejaar = "";
            sTmpKinderenGeslacht = "";
            sTmpKinderenFirstname = "";

            if (sTmpKinderen.toLowerCase().indexOf("£")>-1){
                sTmpKinderenGeboortejaar = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("£"));
                sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("£")+1);
            }

            if (sTmpKinderen.toLowerCase().indexOf("£")>-1){
                sTmpKinderenGeslacht = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("£"));
                sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("£")+1);
            }

            if (sTmpKinderen.toLowerCase().indexOf("$")>-1){
                sTmpKinderenFirstname = sTmpKinderen.substring(0,sTmpKinderen.toLowerCase().indexOf("$"));
                sTmpKinderen = sTmpKinderen.substring(sTmpKinderen.toLowerCase().indexOf("$")+1);
            }

            sKinderen += "rowKinderen"+iTotal+"="+sTmpKinderenGeboortejaar+"£"+sTmpKinderenGeslacht+"£"+sTmpKinderenFirstname+"$";
            sDivKinderen += addKinderen(iTotal, sTmpKinderenGeboortejaar, sTmpKinderenGeslacht, sTmpKinderenFirstname, sWebLanguage);
            iTotal++;
        }
    }
    else if (sKinderen.length()>0) {
        String sTmpKinderen = sKinderen;
        sKinderen += "rowKinderen"+iTotal+"=£"+sTmpKinderen+"£$";
        sDivKinderen += addKinderen(iTotal, "", sTmpKinderen, "", sWebLanguage);
        iTotal++;
    }

    //--- Fami ------------------------------------------------------------------------------------
    if (sFami.indexOf("$")>0){
        String sTmpFami = sFami;
        String sTmpFamiDate, sTmpFamiDescr, sTmpFamiVerwantschap;
        sFami = "";

        while (sTmpFami.toLowerCase().indexOf("$")>-1) {
            sTmpFamiDate = "";
            sTmpFamiDescr = "";
            sTmpFamiVerwantschap = "";

            if (sTmpFami.toLowerCase().indexOf("£")>-1){
                sTmpFamiDate = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("£"));
                sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("£")+1);
            }

            if (sTmpFami.toLowerCase().indexOf("£")>-1){
                sTmpFamiDescr = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("£"));
                sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("£")+1);
            }

            if (sTmpFami.toLowerCase().indexOf("$")>-1){
                sTmpFamiVerwantschap = sTmpFami.substring(0,sTmpFami.toLowerCase().indexOf("$"));
                sTmpFami = sTmpFami.substring(sTmpFami.toLowerCase().indexOf("$")+1);
            }

            sFami += "rowFami"+iTotal+"="+sTmpFamiDate+"£"+sTmpFamiDescr+"£"+sTmpFamiVerwantschap+"$";
            sDivFami += addFami(iTotal, sTmpFamiDate, sTmpFamiDescr, sTmpFamiVerwantschap, sWebLanguage);
            iTotal++;
        }
    }
    else if (sFami.length()>0){
        String sTmpFamiDescr = sFami;
        sFami = "rowFami"+iTotal+"=£"+sFami+"£$";
        sDivFami += addFami(iTotal, "", sTmpFamiDescr, "", sWebLanguage);
        iTotal++;
    }
%>
<table class="list" width="100%" border="0" cellspacing="1">
    <%-- STATUS ---------------------------------------------------------------------------------%>
    <tr>
        <td class="admin" ><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.status",sWebLanguage)%></td>
        <td class="admin2">
            <select id="EditStatus" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_STATUS" property="itemId"/>]>.value" class="text">
                <option/>
                <%=ScreenHelper.writeSelect("clinicalexamination.familialstatus","",sWebLanguage)%>
            </select>
        </td>
    </tr>

    <%-- COMMENT --------------------------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web","Comment",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CE_STATUS_COMMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_STATUS_COMMENT" property="itemId"/>]>.value"><%=sStatusComment%></textarea>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="0" cellpadding="0" class="list">
            <%-- CHILDREN -------------------------------------------------------------------------------%>
                <tr class="admin">
                    <td colspan="2"><%=getTran("Web.Occup","Children",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" cellspacing="1" id="tblKinderen">
                            <tr>
                                <td class="admin" width="36">&nbsp;</td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","Birth_Year",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web.Occup","cbmt.occup.individual.gender",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web","firstname",sWebLanguage)%></td>
                                <td class="admin">&nbsp;</td>
                            </tr>

                            <tr>
                                <td class="admin2"></td>
                                <td class="admin2"><%=ScreenHelper.writeLooseDateFieldYear("KinderenGeboortejaar", "transactionForm","",true,false,sWebLanguage,sCONTEXTPATH)%></td>
                                <td class="admin2">
                                    <select name="KinderenGeslacht" class="text">
                                        <option/>
                                        <option value="M"><%=getTran("Web.Occup","Male",sWebLanguage)%></option>
                                        <option value="F"><%=getTran("Web.Occup","Female",sWebLanguage)%></option>
                                    </select>
                                </td>
                                <td class="admin2">
                                    <input type="text" class="text" size="40" name="KinderenFirstname" onblur="limitLength(this);">
                                </td>
                                <td class="admin2">
                                    <input type="button" class="button" name="ButtonAddKinderen" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addKinderen()">
                                    <input type="button" class="button" name="ButtonUpdateKinderen" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateKinderen()">
                                </td>
                            </tr>

                            <%=sDivKinderen%>
                        </table>

                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_KINDEREN" property="itemId"/>]>.value">
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="0" cellpadding="0" class="list">
                <%-- Familial Antecedents -------------------------------------------------------------------%>
                <tr class="admin">
                    <td colspan="2"><%=getTran("Web.Occup","Familial_Antecedents",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" cellspacing="1" id="tblFami">
                            <tr>
                                <td class="admin" width="36">&nbsp;</td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web.Occup","verwantschap",sWebLanguage)%></td>
                                <td class="admin">&nbsp;</td>
                            </tr>

                            <tr>
                                <td class="admin2"></td>
                                <td class="admin2"><%=ScreenHelper.writeLooseDateFieldYear("FamiDate","transactionForm","",true,false,sWebLanguage,sCONTEXTPATH)%></td>
                                <td class="admin2">
                                    <input type="text" class="text" name="FamiDescription" size="40" onblur="limitLength(this);">
                                </td>
                                <td class="admin2">
                                    <input type="text" class="text" name="FamiVerwantschap" size="40" onblur="limitLength(this);">
                                </td>
                                <td class="admin2">
                                    <input type="button" class="button" name="ButtonAddFami" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addFami()">
                                    <input type="button" class="button" name="ButtonUpdateFami" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateFami()">
                                </td>
                            </tr>

                            <%=sDivFami%>
                        </table>

                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN" property="itemId"/>]>.value">
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <%-- COMMENT --------------------------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web","Comment",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_CE_FAMILIAAL_COMMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT" property="itemId"/>]>.value"><%=sFamiliaalComment%></textarea>

            <%-- hidden fields --%>
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT1" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT2" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT3" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT4" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT5" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT6" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_FAMILIAAL_COMMENT7" property="itemId"/>]>.value">
        </td>
    </tr>
</table>


<%-- SCRIPTS TILL END OF PAGE -------------------------------------------------------------------%>
<script>
var statusId = "<%=sStatus%>";
for (var n=0;n<document.getElementById("transactionForm").EditStatus.length;n++){
  if (document.getElementById("transactionForm").EditStatus.options[n].value==statusId){
    document.getElementById("transactionForm").EditStatus.selectedIndex = n;
    break;
  }
}

var iIndex = <%=iTotal%>;
var sKinderen = "<%=sKinderen%>";
var sFami = "<%=sFami%>";

var editKinderenRowid = "";
var editFamiRowid = "";

<%-- disable update buttons --%>
document.getElementById("transactionForm").ButtonUpdateKinderen.disabled = true;
document.getElementById("transactionForm").ButtonUpdateFami.disabled = true;


<%-- KINDEREN FUNCTIONS -------------------------------------------------------------------------%>
function addKinderen(){
  if(isAtLeastOneKinderenFieldFilled()){
    var today = new Date();

    var birthDate = new Date();
    var birthDateStr = document.getElementById("transactionForm").KinderenGeboortejaar.value;
    if(birthDateStr.length > 0){
      if(birthDateStr.length == 4){
         birthDateStr = "01/01/"+birthDateStr;
      }
      birthDate = makeDate(birthDateStr);
    }
    if(birthDate.getTime() > today.getTime()){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=Web.Occup&labelID=futureDateNotAllowed";
      var modalitiesIE = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

      if(window.showModalDialog){
          window.showModalDialog(popupUrl,'',modalitiesIE);
      }else{
          window.confirm("<%=getTranNoLink("Web.occup","futureDateNotAllowed",sWebLanguage)%>");
      }
      document.getElementById("transactionForm").KinderenGeboortejaar.select();
      return false;
    }
    else{
      iIndex++;
      sKinderen+="rowKinderen"+iIndex+"="+document.getElementById("transactionForm").KinderenGeboortejaar.value+"£"+document.getElementById("transactionForm").KinderenGeslacht.value+"£"+document.getElementById("transactionForm").KinderenFirstname.value+"$";

      var tr = tblKinderen.insertRow(tblKinderen.rows.length);
      tr.id = "rowKinderen"+iIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteKinderen(rowKinderen"+iIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editKinderen(rowKinderen"+iIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").KinderenGeboortejaar.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      if(document.getElementById("transactionForm").KinderenGeslacht.value == "M"){
        td.innerHTML = "&nbsp;<%=getTran("Web.Occup","male",sWebLanguage)%>";
      }
      else if(document.getElementById("transactionForm").KinderenGeslacht.value == "F"){
        td.innerHTML = "&nbsp;<%=getTran("Web.Occup","female",sWebLanguage)%>";
      }
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").KinderenFirstname.value;
      tr.appendChild(td);


      <%-- reset --%>
      clearKinderenFields();
      document.getElementById("transactionForm").ButtonUpdateKinderen.disabled = true;
    }
  }
  return true;
}

function isAtLeastOneKinderenFieldFilled(){
  if(document.getElementById("transactionForm").KinderenGeboortejaar.value != "") return true;
  if(document.getElementById("transactionForm").KinderenGeslacht.value != "") return true;
  if(document.getElementById("transactionForm").KinderenFirstname.value != "") return true;
  return false;
}

function clearKinderenFields(){
  document.getElementById("transactionForm").KinderenGeboortejaar.value = "";
  document.getElementById("transactionForm").KinderenGeslacht.value = "";
  document.getElementById("transactionForm").KinderenFirstname.value = "";
}

function deleteKinderen(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sKinderen = deleteRowFromArrayString(sKinderen,rowid.id);
    tblKinderen.deleteRow(rowid.rowIndex);
    clearKinderenFields();
  }
}

function editKinderen(rowid){
  var row = getRowFromArrayString(sKinderen,rowid.id);

  document.getElementById("transactionForm").KinderenGeboortejaar.value = getCelFromRowString(row,0);
  document.getElementById("transactionForm").KinderenGeslacht.value = getCelFromRowString(row,1);
  document.getElementById("transactionForm").KinderenFirstname.value = getCelFromRowString(row,2);

  editKinderenRowid = rowid;
  document.getElementById("transactionForm").ButtonUpdateKinderen.disabled = false;
}

function updateKinderen(){
  if(isAtLeastOneKinderenFieldFilled()){
    <%-- update arrayString --%>
    newRow = editKinderenRowid.id+"="
             +document.getElementById("transactionForm").KinderenGeboortejaar.value+"£"
             +document.getElementById("transactionForm").KinderenGeslacht.value+"£"
             +document.getElementById("transactionForm").KinderenFirstname.value;

    sKinderen = replaceRowInArrayString(sKinderen,newRow,editKinderenRowid.id);

    <%-- update table object --%>
    var row = tblKinderen.rows[editKinderenRowid.rowIndex];
    //row = tblKinderen.rows[editKinderenRowid.rowIndex];

    row.cells[0].innerHTML = "<a href='javascript:deleteKinderen("+editKinderenRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editKinderen("+editKinderenRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").KinderenGeboortejaar.value;

      <%-- translate gender --%>
      if(document.getElementById("transactionForm").KinderenGeslacht.value == "M"){
        row.cells[2].innerHTML = "&nbsp;<%=getTran("Web.Occup","male",sWebLanguage)%>";
      }
      else if(document.getElementById("transactionForm").KinderenGeslacht.value == "F"){
        row.cells[2].innerHTML = "&nbsp;<%=getTran("Web.Occup","female",sWebLanguage)%>";
      }

      row.cells[3].innerHTML = "&nbsp;"+document.getElementById("transactionForm").KinderenFirstname.value;

    <%-- reset --%>
    clearKinderenFields();
    document.getElementById("transactionForm").ButtonUpdateKinderen.disabled = true;
  }
}

<%-- FAMI FUNCTIONS -----------------------------------------------------------------------------%>
function addFami(){
  if(isAtLeastOneFamiFieldFilled()){
    iIndex ++;

    sFami+="rowFami"+iIndex+"="+document.getElementById("transactionForm").FamiDate.value+"£"+document.getElementById("transactionForm").FamiDescription.value+"£"+document.getElementById("transactionForm").FamiVerwantschap.value+"$";

    var tr = tblFami.insertRow(tblFami.rows.length);
    tr.id = "rowFami"+iIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteFami(rowFami"+iIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                  +"<a href='javascript:editFami(rowFami"+iIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a> ";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").FamiDate.value;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").FamiDescription.value;
    tr.appendChild(td);

    td = tr.insertCell(3);
    td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiVerwantschap.value;
    tr.appendChild(td);

    <%-- reset --%>
    clearFamiFields();
    document.getElementById("transactionForm").ButtonUpdateFami.disabled = true;
  }
}

function isAtLeastOneFamiFieldFilled(){
  if(document.getElementById("transactionForm").FamiDate.value != "") return true;
  if(document.getElementById("transactionForm").FamiDescription.value != "") return true;
  if(document.getElementById("transactionForm").FamiVerwantschap.value != "") return true;
  return false;
}

function clearFamiFields(){
  document.getElementById("transactionForm").FamiDate.value = "";
  document.getElementById("transactionForm").FamiDescription.value = "";
  document.getElementById("transactionForm").FamiVerwantschap.value = "";
}

function deleteFami(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sFami = deleteRowFromArrayString(sFami,rowid.id);
    tblFami.deleteRow(rowid.rowIndex);
    clearFamiFields();
  }
}

function editFami(rowid){
  var row = getRowFromArrayString(sFami,rowid.id);

  document.getElementById("transactionForm").FamiDate.value = getCelFromRowString(row,0);
  document.getElementById("transactionForm").FamiDescription.value = getCelFromRowString(row,1);
  document.getElementById("transactionForm").FamiVerwantschap.value = getCelFromRowString(row,2);

  editFamiRowid = rowid;
  document.getElementById("transactionForm").ButtonUpdateFami.disabled = false;
}

function updateFami(){
  if(isAtLeastOneFamiFieldFilled()){
    <%-- update arrayString --%>
    newRow = editFamiRowid.id+"="
             +document.getElementById("transactionForm").FamiDate.value+"£"
             +document.getElementById("transactionForm").FamiDescription.value+"£"
             +document.getElementById("transactionForm").FamiVerwantschap.value;

    sFami = replaceRowInArrayString(sFami,newRow,editFamiRowid.id);

    <%-- update table object --%>
    var row = tblFami.rows[editFamiRowid.rowIndex];
      
    row.cells[0].innerHTML = "<a href='javascript:deleteFami("+editFamiRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editFami("+editFamiRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiDate.value;
    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiDescription.value;
    row.cells[3].innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiVerwantschap.value;

    <%-- reset --%>
    clearFamiFields();
    document.getElementById("transactionForm").ButtonUpdateFami.disabled = true;
  }
}
</script>

