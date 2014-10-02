<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<%!
    //--- ADD FAMI --------------------------------------------------------------------------------
    private String addFami(int iTotal, String sTmpFamiDate, String sTmpFamiDescr, String sTmpFamiVerwantschap, String sWebLanguage) {
        return "<tr id='rowFami" + iTotal + "'>"
                + "<td width='36'>"
                + " <a href='javascript:deleteFami(rowFami" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
                + " <a href='javascript:editFami(rowFami" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icons/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
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
    String sFami = "", sDivFami = "", sFamiliaalComment = "";

    if (transaction != null){
        TransactionVO tran = (TransactionVO)transaction;
        if (tran!=null){
            sFami             = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
            sFamiliaalComment = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
        }

        // herneem data van vorig klinisch onderzoek of RPR
        if (tran.getTransactionId().intValue()<0){
            if (sFami.length() == 0){
                sFami+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_FAMILIALE_ANTECEDENTEN");
            }

            sFamiliaalComment+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT");
            for(int i=1; i<8; i++){
                sFamiliaalComment+= getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_FAMILIAAL_COMMENT"+i);
            }

        }
    }

    int iTotal = 1;
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
                sTmpFamiDate = ScreenHelper.convertDate(sTmpFamiDate);
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
                                    <input type="button" class="button" name="ButtonAddFami" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addFami()">
                                    <input type="button" class="button" name="ButtonUpdateFami" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>" onclick="updateFami()">
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
var iIndex = <%=iTotal%>;
var sFami = "<%=sFami%>";

var editFamiRowid = "";

<%-- disable update buttons --%>
document.getElementById("transactionForm").ButtonUpdateFami.disabled = true;

<%-- FAMI FUNCTIONS -----------------------------------------------------------------------------%>
function addFami(){
  if(isAtLeastOneFamiFieldFilled()){
    iIndex ++;

    sFami+="rowFami"+iIndex+"="+document.getElementById("transactionForm").FamiDate.value+"£"+document.getElementById("transactionForm").FamiDescription.value+"£"+document.getElementById("transactionForm").FamiVerwantschap.value+"$";

    var tr = tblFami.insertRow(tblFami.rows.length);
    tr.id = "rowFami"+iIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteFami(rowFami"+iIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                  +"<a href='javascript:editFami(rowFami"+iIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a> ";
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
      
    row.cells[0].innerHTML = "<a href='javascript:deleteFami("+editFamiRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editFami("+editFamiRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiDate.value;
    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiDescription.value;
    row.cells[3].innerHTML = "&nbsp;"+document.getElementById("transactionForm").FamiVerwantschap.value;

    <%-- reset --%>
    clearFamiFields();
    document.getElementById("transactionForm").ButtonUpdateFami.disabled = true;
  }
}
</script>

