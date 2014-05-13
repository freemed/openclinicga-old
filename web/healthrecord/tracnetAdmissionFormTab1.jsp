<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<%!
    private StringBuffer addChildren(int iTotal,String sAge,String sAdopt,String sTest, String sResult, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();

        String sTmpAdopt = "";

        if (sAdopt.length()>0){
            sTmpAdopt = getTran("web.occup",sAdopt,sWebLanguage);
        }

        String sTmpTest = "";

        if (sTest.length()>0){
            sTmpTest = getTran("web.occup",sTest,sWebLanguage);
        }
        sTmp.append("<tr id='rowChildren"+iTotal+"'>")
             .append("<td class=\"admin2\">")
              .append("<a href='javascript:deleteChildren(rowChildren"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
              .append("<a href='javascript:editChildren(rowChildren"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + sAge + "</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpAdopt + "</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpTest + "</td>")
             .append("<td class='admin2'>&nbsp;" + sResult + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }

    private StringBuffer addARV(int iTotal,String sMolecule,String sDuration,String sComment, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        String sTmpMolecule = "";

        if (sMolecule.length()>0){
            sTmpMolecule = getTran("tracnet.molecules",sMolecule,sWebLanguage);
        }

        sTmp.append("<tr id='rowARV"+iTotal+"'>")
             .append("<td class=\"admin2\">")
              .append("<a href='javascript:deleteARV(rowARV"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
              .append("<a href='javascript:editARV(rowARV"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpMolecule + "</td>")
             .append("<td class='admin2'>&nbsp;" +sDuration + "</td>")
             .append("<td class='admin2'>&nbsp;" + sComment + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }

   private StringBuffer addAntecedents(int iTotal,String sMolecule,String sDateBegin,String sDateEnd, String sComment, String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        String sTmpMolecule = "";

        if (sMolecule.length()>0){
            sTmpMolecule = getTran("tracnet.antecedents.molecules",sMolecule,sWebLanguage);
        }

        sTmp.append("<tr id='rowAntecedents"+iTotal+"'>")
             .append("<td class=\"admin2\">")
              .append("<a href='javascript:deleteAntecedents(rowAntecedents"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
              .append("<a href='javascript:editAntecedents(rowAntecedents"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup","medwan.common.edit",sWebLanguage) + "' border='0'></a>")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + sTmpMolecule + "</td>")
             .append("<td class='admin2'>&nbsp;" +sDateBegin + "</td>")
             .append("<td class='admin2'>&nbsp;" + sDateEnd + "</td>")
             .append("<td class='admin2'>&nbsp;" + sComment + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }
%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table class="list" width="100%" cellspacing="1">
    <%-- DATE --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>">
            <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur="checkDate(this);">
            <script>writeTranDate();</script>
        </td>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.first.hiv.test",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_FIRST_HIV_TEST" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_FIRST_HIV_TEST" property="value"/>" id="first_hiv_test" OnBlur='checkDate(this)'>
            <script>writeMyDate("first_hiv_test");</script>
        </td>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.partner",sWebLanguage)%></td>
        <td class="admin2">
            <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_PARTNER" property="itemId"/>]>.value">
                <option/>
                <%
                    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                    String sType = checkString(request.getParameter("type"));

                    if(sType.length() == 0){
                        ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_ADMISSION_FORM_PARTNER");
                        if (item!=null){
                            sType = checkString(item.getValue());
                        }
                    }
                %>
                <%=ScreenHelper.writeSelect("tracnet.admission.form.partner",sType,sWebLanguage,false,true)%>
            </select>
        </td>
    </tr>
</table>
<br>
<table class="list" cellspacing="1" cellpadding="0" id="tblChildren" width="100%">
    <tr class="admin">
            <td colspan="6"><%=getTran("openclinic.chuk","tracnet.admission.form.children",sWebLanguage)%></td>
        </tr>
    <tr>
        <td class="admin" width="40"/>
        <td class="admin" width="100"><%=getTran("openclinic.chuk","tracnet.admission.form.children.age",sWebLanguage)%></td>
        <td class="admin" width="100"><%=getTran("openclinic.chuk","tracnet.admission.form.children.adopt",sWebLanguage)%></td>
        <td class="admin" width="100"><%=getTran("openclinic.chuk","tracnet.admission.form.children.test",sWebLanguage)%></td>
        <td class="admin" width="300"><%=getTran("openclinic.chuk","tracnet.admission.form.children.result",sWebLanguage)%></td>
        <td class="admin"/>
    </tr>
    <tr>
        <td class="admin2"/>
        <td class="admin2"><input type="text" class="text" size="5" name="childrenAge" onblur="isNumber(this)"></td>
        <td class="admin2">
            <select class="text" name="childrenAdopt">
                <option/>
                <option value="medwan.common.yes"><%=getTran("web.occup","medwan.common.yes",sWebLanguage)%></option>
                <option value="medwan.common.no"><%=getTran("web.occup","medwan.common.no",sWebLanguage)%></option>
            </select>
        </td>
        <td class="admin2">
            <select class="text" name="childrenTest">
                <option/>
                <option value="medwan.common.yes"><%=getTran("web.occup","medwan.common.yes",sWebLanguage)%></option>
                <option value="medwan.common.no"><%=getTran("web.occup","medwan.common.no",sWebLanguage)%></option>
            </select>
        </td>
        <td class="admin2"><input type="text" class="text" size="50" name="childrenResult"></td>
        <td class="admin2">
            <input type="button" class="button" name="ButtonAddChildren" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addChildren();">
            <input type="button" class="button" name="ButtonUpdateChildren" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateChildren();">
        </td>
    </tr>
    <%
StringBuffer sDivChildren = new StringBuffer(),
         sChildren    = new StringBuffer();
int iChildrenTotal = 0;

if (transaction != null){
TransactionVO tran = (TransactionVO)transaction;
if (tran!=null){
    sChildren.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_CHILDREN1"));
    sChildren.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_CHILDREN2"));
    sChildren.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_CHILDREN3"));
    sChildren.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_CHILDREN4"));
    sChildren.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_CHILDREN5"));
}

iChildrenTotal = 1;

if (sChildren.indexOf("£")>-1){
    StringBuffer sTmpChildren = sChildren;
    String sTmpAge, sTmpAdopt, sTmpTest, sTmpResult;
    sChildren = new StringBuffer();

    while (sTmpChildren.toString().toLowerCase().indexOf("$")>-1) {
        sTmpAge = "";
        sTmpAdopt = "";
        sTmpTest = "";
        sTmpResult = "";

        if (sTmpChildren.toString().toLowerCase().indexOf("£")>-1){
            sTmpAge = sTmpChildren.substring(0,sTmpChildren.toString().toLowerCase().indexOf("£"));
            sTmpChildren = new StringBuffer(sTmpChildren.substring(sTmpChildren.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpChildren.toString().toLowerCase().indexOf("£")>-1){
            sTmpAdopt = sTmpChildren.substring(0,sTmpChildren.toString().toLowerCase().indexOf("£"));
            sTmpChildren = new StringBuffer(sTmpChildren.substring(sTmpChildren.toString().toLowerCase().indexOf("£")+1));
        }
        if (sTmpChildren.toString().toLowerCase().indexOf("£")>-1){
            sTmpTest = sTmpChildren.substring(0,sTmpChildren.toString().toLowerCase().indexOf("£"));
            sTmpChildren = new StringBuffer(sTmpChildren.substring(sTmpChildren.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpChildren.toString().toLowerCase().indexOf("$")>-1){
            sTmpResult = sTmpChildren.substring(0,sTmpChildren.toString().toLowerCase().indexOf("$"));
            sTmpChildren = new StringBuffer(sTmpChildren.substring(sTmpChildren.toString().toLowerCase().indexOf("$")+1));
        }

        sChildren.append("rowChildren"+iChildrenTotal+"="+sTmpAge+"£"+sTmpAdopt+"£"+sTmpTest+"£"+sTmpResult+"$");
        sDivChildren.append(addChildren(iChildrenTotal, sTmpAge, sTmpAdopt, sTmpTest, sTmpResult, sWebLanguage));
        iChildrenTotal++;
    }
}
}
%>
        <%=sDivChildren%>
</table>
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN1" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN2" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN3" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN4" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN5" property="itemId"/>]>.value">
<br>
<table class="list" cellspacing="1" cellpadding="0" id="tblSuivi" width="100%">
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.admission.type",sWebLanguage)%></td>
        <td class="admin2">
            <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ADMISSION_TYPE" property="itemId"/>]>.value">
                <option/>
                <%
                    sType = checkString(request.getParameter("type"));

                    if(sType.length() == 0){
                        ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_ADMISSION_FORM_ADMISSION_TYPE");
                        if (item!=null){
                            sType = checkString(item.getValue());
                        }
                    }
                %>
                <%=ScreenHelper.writeSelect("tracnet.admission.form.admission.type",sType,sWebLanguage,false,true)%>
            </select>
            <%=getTran("openclinic.chuk","tracnet.admission.form.admission.type.other",sWebLanguage)%>
            <input type="text" class="text" size="50" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_ADMISSION_OTHER")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ADMISSION_OTHER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ADMISSION_OTHER" property="value"/>">
            <br>
            <%=getTran("openclinic.chuk","tracnet.admission.form.admission.type.place",sWebLanguage)%>
            <input type="text" class="text" size="50" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_ADMISSION_PLACE")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ADMISSION_PLACE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ADMISSION_PLACE" property="value"/>">
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.took.arv",sWebLanguage)%></td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_TOOK_ARV")%> type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_TOOK_ARV" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_TOOK_ARV;value=medwan.common.yes" property="value" outputString="checked"/> id="cbtookarv_yes"><%=getLabel("web.occup","medwan.common.yes",sWebLanguage,"cbtookarv_yes")%>
            <input <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_TOOK_ARV")%> type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_TOOK_ARV" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_TOOK_ARV;value=medwan.common.no" property="value" outputString="checked"/> id="cbtookarv_no"><%=getLabel("web.occup","medwan.common.no",sWebLanguage,"cbtookarv_no")%>
        </td>
    </tr>
</table>
<br>
<table class="list" cellspacing="1" cellpadding="0" id="tblARV" width="100%">
    <tr class="admin">
        <td colspan="5"><%=getTran("openclinic.chuk","tracnet.admission.form.wich.arvs",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin" width="40"/>
        <td class="admin" width="200"><%=getTran("openclinic.chuk","tracnet.admission.form.arv.molecule",sWebLanguage)%></td>
        <td class="admin" width="100"><%=getTran("openclinic.chuk","tracnet.admission.form.arv.duration",sWebLanguage)%></td>
        <td class="admin" width="300"><%=getTran("openclinic.chuk","tracnet.admission.form.arv.comment",sWebLanguage)%></td>
        <td class="admin"/>
    </tr>
    <tr>
        <td class="admin2"/>
        <td class="admin2">
             <select class="text" name="ARVMolecule">
                <option/>
                <%=ScreenHelper.writeSelect("tracnet.molecules","",sWebLanguage,false,true)%>
            </select>
        </td>
        <td class="admin2"><input type="text" class="text" size="5" name="ARVDuration" onblur="isNumber(this)"></td>
        <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="ARVComment"></textarea></td>
        <td class="admin2">
            <input type="button" class="button" name="ButtonAddARV" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addARV();">
            <input type="button" class="button" name="ButtonUpdateARV" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateARV();">
        </td>
    </tr>
    <%
StringBuffer sDivARV = new StringBuffer(),
         sARV    = new StringBuffer();
int iARVTotal = 0;

if (transaction != null){
TransactionVO tran = (TransactionVO)transaction;
if (tran!=null){
    sARV.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_WICH_ARV1"));
    sARV.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_WICH_ARV2"));
    sARV.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_WICH_ARV3"));
    sARV.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_WICH_ARV4"));
    sARV.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_WICH_ARV5"));
}

iARVTotal = 1;

if (sARV.indexOf("£")>-1){
    StringBuffer sTmpARV = sARV;
    String sTmpMolecule, sTmpDuration, sTmpComment;
    sARV = new StringBuffer();

    while (sTmpARV.toString().toLowerCase().indexOf("$")>-1) {
        sTmpMolecule = "";
        sTmpDuration = "";
        sTmpComment = "";

        if (sTmpARV.toString().toLowerCase().indexOf("£")>-1){
            sTmpMolecule = sTmpARV.substring(0,sTmpARV.toString().toLowerCase().indexOf("£"));
            sTmpARV = new StringBuffer(sTmpARV.substring(sTmpARV.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpARV.toString().toLowerCase().indexOf("£")>-1){
            sTmpDuration = sTmpARV.substring(0,sTmpARV.toString().toLowerCase().indexOf("£"));
            sTmpARV = new StringBuffer(sTmpARV.substring(sTmpARV.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpARV.toString().toLowerCase().indexOf("$")>-1){
            sTmpComment = sTmpARV.substring(0,sTmpARV.toString().toLowerCase().indexOf("$"));
            sTmpARV = new StringBuffer(sTmpARV.substring(sTmpARV.toString().toLowerCase().indexOf("$")+1));
        }

        sARV.append("rowARV"+iARVTotal+"="+sTmpMolecule+"£"+sTmpDuration+"£"+sTmpComment+"$");
        sDivARV.append(addARV(iARVTotal, sTmpMolecule, sTmpDuration, sTmpComment, sWebLanguage));
        iARVTotal++;
    }
}
}
%>
        <%=sDivARV%>
</table>
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV1" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV2" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV3" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV4" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV5" property="itemId"/>]>.value">
<br>

<table class="list" cellspacing="1" cellpadding="0" id="tblAntecedents" width="100%">
    <tr class="admin">
        <td colspan="6"><%=getTran("openclinic.chuk","tracnet.admission.form.antecedents",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin" width="40"/>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.antecedents.molecule.arv",sWebLanguage)%></td>
        <td class="admin" width="100"><%=getTran("openclinic.chuk","tracnet.admission.form.antecedents.date.begin",sWebLanguage)%></td>
        <td class="admin" width="100"><%=getTran("openclinic.chuk","tracnet.admission.form.antecedents.date.end",sWebLanguage)%></td>
        <td class="admin" width="300"><%=getTran("openclinic.chuk","tracnet.suivi.arv.comment",sWebLanguage)%></td>
        <td class="admin"/>
    </tr>
    <tr>
        <td class="admin2"/>
        <td class="admin2">
            <select class="text" name="antecedentsMolecule">
                <option/>
                <%=ScreenHelper.writeSelect("tracnet.antecedents.molecules","",sWebLanguage,false,true)%>
            </select>
        </td>
        <td class="admin2"><%=writeDateField("antecedentsDateBegin","transactionForm","",sWebLanguage)%></td>
        <td class="admin2"><%=writeDateField("antecedentsDateEnd","transactionForm","",sWebLanguage)%></td>
        <td class="admin2"><textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="50" rows="2" name="antecedentsComment"></textarea></td>
        <td class="admin2">
            <input type="button" class="button" name="ButtonAddAntecedents" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addAntecedents();">
            <input type="button" class="button" name="ButtonUpdateAntecedents" value="<%=getTran("Web","edit",sWebLanguage)%>" onclick="updateAntecedents();">
        </td>
    </tr>
        <%
StringBuffer sDivAntecedents = new StringBuffer(),
         sAntecedents    = new StringBuffer();
int iAntecedentsTotal = 0;

if (transaction != null){
TransactionVO tran = (TransactionVO)transaction;
if (tran!=null){
    sAntecedents.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER1"));
    sAntecedents.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER2"));
    sAntecedents.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER3"));
    sAntecedents.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER4"));
    sAntecedents.append(getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER5"));
}

iAntecedentsTotal = 1;

if (sAntecedents.indexOf("£")>-1){
    StringBuffer sTmpAntecedents = sAntecedents;
    String sTmpMolecule, sTmpDateBegin, sTmpDateEnd, sTmpComment;
    sAntecedents = new StringBuffer();

    while (sTmpAntecedents.toString().toLowerCase().indexOf("$")>-1) {
        sTmpMolecule = "";
        sTmpDateBegin = "";
        sTmpDateEnd = "";
        sTmpComment = "";

        if (sTmpAntecedents.toString().toLowerCase().indexOf("£")>-1){
            sTmpMolecule = sTmpAntecedents.substring(0,sTmpAntecedents.toString().toLowerCase().indexOf("£"));
            sTmpAntecedents = new StringBuffer(sTmpAntecedents.substring(sTmpAntecedents.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpAntecedents.toString().toLowerCase().indexOf("£")>-1){
            sTmpDateBegin = sTmpAntecedents.substring(0,sTmpAntecedents.toString().toLowerCase().indexOf("£"));
            sTmpAntecedents = new StringBuffer(sTmpAntecedents.substring(sTmpAntecedents.toString().toLowerCase().indexOf("£")+1));
        }
        if (sTmpAntecedents.toString().toLowerCase().indexOf("£")>-1){
            sTmpDateEnd = sTmpAntecedents.substring(0,sTmpAntecedents.toString().toLowerCase().indexOf("£"));
            sTmpAntecedents = new StringBuffer(sTmpAntecedents.substring(sTmpAntecedents.toString().toLowerCase().indexOf("£")+1));
        }

        if (sTmpAntecedents.toString().toLowerCase().indexOf("$")>-1){
            sTmpComment = sTmpAntecedents.substring(0,sTmpAntecedents.toString().toLowerCase().indexOf("$"));
            sTmpAntecedents = new StringBuffer(sTmpAntecedents.substring(sTmpAntecedents.toString().toLowerCase().indexOf("$")+1));
        }

        sAntecedents.append("rowAntecedents"+iAntecedentsTotal+"="+sTmpMolecule+"£"+sTmpDateBegin+"£"+sTmpDateEnd+"£"+sTmpComment+"$");
        sDivAntecedents.append(addAntecedents(iAntecedentsTotal, sTmpMolecule, sTmpDateBegin, sTmpDateEnd, sTmpComment, sWebLanguage));
        iAntecedentsTotal++;
    }
}
}
%>
    <%=sDivAntecedents%>
</table>
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER1" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER2" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER3" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER4" property="itemId"/>]>.value">
<input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER5" property="itemId"/>]>.value">
<br>
<table class="list" cellspacing="1" cellpadding="0" id="tblSuivi" width="100%">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","tracnet.admission.form.allergy",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_ALLERGY")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ALLERGY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ALLERGY" property="value"/></textarea>
        </td>
    </tr>
</table>
<script>
  var iChildrenIndex = <%=iChildrenTotal%>;
  var sChildren = "<%=sChildren%>";
  var editChildrenRowid = "";

  var iARVIndex = <%=iARVTotal%>;
  var sARV = "<%=sARV%>";
  var editARVRowid = "";

  var iAntecedentsIndex = <%=iAntecedentsTotal%>;
  var sAntecedents = "<%=sAntecedents%>";
  var editAntecedentsRowid = "";

  function submitTab1(){
    if (isAtLeastOneChildrenFieldFilled()) {
      if (maySubmit) {
        if (!addChildren()) {
          maySubmit = false;
        }
      }
    }

    var sTmpBegin, sTmpEnd;
    while (sChildren.indexOf("rowChildren") > -1) {
      sTmpBegin = sChildren.substring(sChildren.indexOf("rowChildren"));
      sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
      sChildren = sChildren.substring(0, sChildren.indexOf("rowChildren")) + sTmpEnd;
    }

    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN1" property="itemId"/>]>.value")[0].value = sChildren.substring(0,254);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN2" property="itemId"/>]>.value")[0].value = sChildren.substring(254,508);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN3" property="itemId"/>]>.value")[0].value = sChildren.substring(508,762);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN4" property="itemId"/>]>.value")[0].value = sChildren.substring(762,1016);
    document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_CHILDREN5" property="itemId"/>]>.value")[0].value = sChildren.substring(1016,1270);

    if (isAtLeastOneARVFieldFilled()) {
        if (maySubmit) {
          if (!addARV()) {
            maySubmit = false;
          }
        }
      }

      while (sARV.indexOf("rowARV") > -1) {
        sTmpBegin = sARV.substring(sARV.indexOf("rowARV"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sARV = sARV.substring(0, sARV.indexOf("rowARV")) + sTmpEnd;
      }

      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV1" property="itemId"/>]>.value")[0].value = sARV.substring(0,254);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV2" property="itemId"/>]>.value")[0].value = sARV.substring(254,508);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV3" property="itemId"/>]>.value")[0].value = sARV.substring(508,762);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV4" property="itemId"/>]>.value")[0].value = sARV.substring(762,1016);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_WICH_ARV5" property="itemId"/>]>.value")[0].value = sARV.substring(1016,1270);

      if (isAtLeastOneAntecedentsFieldFilled()) {
        if (maySubmit) {
          if (!addAntecedents()) {
            maySubmit = false;
          }
        }
      }

      while (sAntecedents.indexOf("rowAntecedents") > -1) {
        sTmpBegin = sAntecedents.substring(sAntecedents.indexOf("rowAntecedents"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=") + 1);
        sAntecedents = sAntecedents.substring(0, sAntecedents.indexOf("rowAntecedents")) + sTmpEnd;
      }

      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER1" property="itemId"/>]>.value")[0].value = sAntecedents.substring(0,254);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER2" property="itemId"/>]>.value")[0].value = sAntecedents.substring(254,508);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER3" property="itemId"/>]>.value")[0].value = sAntecedents.substring(508,762);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER4" property="itemId"/>]>.value")[0].value = sAntecedents.substring(762,1016);
      document.getElementsByName("currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_ANTECEDENT_OTHER5" property="itemId"/>]>.value")[0].value = sAntecedents.substring(1016,1270);
  }

  function addChildren(){
    if(isAtLeastOneChildrenFieldFilled()){
      iChildrenIndex++;

      sChildren+="rowChildren"+iChildrenIndex+"="+transactionForm.childrenAge.value+"£"
              +transactionForm.childrenAdopt.value+"£"
              +transactionForm.childrenTest.value+"£"
              +transactionForm.childrenResult.value+"$";

      var tr;
      tr = tblChildren.insertRow(tblChildren.rows.length);
      tr.id = "rowChildren"+iChildrenIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteChildren(rowChildren"+iChildrenIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editChildren(rowChildren"+iChildrenIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.childrenAge.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.childrenAdopt.options[transactionForm.childrenAdopt.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.childrenTest.options[transactionForm.childrenTest.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.childrenResult.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearChildrenFields();
      transactionForm.ButtonUpdateChildren.disabled = true;
    }
    return true;
  }

  function updateChildren(){
    if(isAtLeastOneChildrenFieldFilled()){
      <%-- update arrayString --%>
      var newRow,row;

      newRow = editChildrenRowid.id+"="+transactionForm.childrenAge.value+"£"
               +transactionForm.childrenAdopt.value+"£"
               +transactionForm.childrenTest.value+"£"
               +transactionForm.childrenResult.value;

      sChildren = replaceRowInArrayString(sChildren,newRow,editChildrenRowid.id);

      <%-- update table object --%>
      row = tblChildren.rows[editChildrenRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteChildren("+editChildrenRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editChildren("+editChildrenRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = "&nbsp;"+transactionForm.childrenAge.value;
      row.cells[2].innerHTML = "&nbsp;"+transactionForm.childrenAdopt.options[transactionForm.childrenAdopt.selectedIndex].text;
      row.cells[3].innerHTML = "&nbsp;"+transactionForm.childrenTest.options[transactionForm.childrenTest.selectedIndex].text;
      row.cells[4].innerHTML = "&nbsp;"+transactionForm.childrenResult.value;

      setCellStyle(row);

      <%-- reset --%>
      clearChildrenFields();
      transactionForm.ButtonUpdateChildren.disabled = true;
    }
  }

  function isAtLeastOneChildrenFieldFilled(){
    if(transactionForm.childrenAge.value != "")        return true;
    if(transactionForm.childrenAdopt.value != "")       return true;
    if(transactionForm.childrenTest.value != "")       return true;
    if(transactionForm.childrenResult.value != "")       return true;
    return false;
  }

  function clearChildrenFields(){
    transactionForm.childrenAge.value = "";
    transactionForm.childrenAdopt.selectedIndex = 0;
    transactionForm.childrenTest.selectedIndex = 0;
    transactionForm.childrenResult.value = "";
  }

  function deleteChildren(rowid){
    if(yesnoDialog("Web","areYouSureToDelete")){
      sChildren = deleteRowFromArrayString(sChildren,rowid.id);
      tblChildren.deleteRow(rowid.rowIndex);
      clearChildrenFields();
    }
  }

  function editChildren(rowid){
    var row = getRowFromArrayString(sChildren,rowid.id);
    transactionForm.childrenAge.value = getCelFromRowString(row,0);
    transactionForm.childrenAdopt.value = getCelFromRowString(row,1);
    transactionForm.childrenTest.value = getCelFromRowString(row,2);
    transactionForm.childrenResult.value = getCelFromRowString(row,3);

    editChildrenRowid = rowid;
    transactionForm.ButtonUpdateChildren.disabled = false;
  }


 function addARV(){
    if(isAtLeastOneARVFieldFilled()){
      iARVIndex++;

      sARV+="rowARV"+iARVIndex+"="+transactionForm.ARVMolecule.value+"£"
              +transactionForm.ARVDuration.value+"£"
              +transactionForm.ARVComment.value+"$";
      var tr;
      tr = tblARV.insertRow(tblARV.rows.length);
      tr.id = "rowARV"+iARVIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteARV(rowARV"+iARVIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editARV(rowARV"+iARVIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.ARVMolecule.options[transactionForm.ARVMolecule.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.ARVDuration.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.ARVComment.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearARVFields()
      transactionForm.ButtonUpdateARV.disabled = true;
    }
    return true;
  }

  function updateARV(){
    if(isAtLeastOneARVFieldFilled()){
      <%-- update arrayString --%>
      var newRow,row;

      newRow = editARVRowid.id+"="+transactionForm.ARVMolecule.value+"£"
               +transactionForm.ARVDuration.value+"£"
               +transactionForm.ARVComment.value;

      sARV = replaceRowInArrayString(sARV,newRow,editARVRowid.id);

      <%-- update table object --%>
      row = tblARV.rows[editARVRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteARV("+editARVRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editARV("+editARVRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = "&nbsp;"+transactionForm.ARVMolecule.options[transactionForm.ARVMolecule.selectedIndex].text;
      row.cells[2].innerHTML = "&nbsp;"+transactionForm.ARVDuration.value;
      row.cells[3].innerHTML = "&nbsp;"+transactionForm.ARVComment.value;

      setCellStyle(row);

      <%-- reset --%>
      clearARVFields();
      transactionForm.ButtonUpdateARV.disabled = true;
    }
  }

  function isAtLeastOneARVFieldFilled(){
    if(transactionForm.ARVMolecule.value != "")        return true;
    if(transactionForm.ARVDuration.value != "")       return true;
    if(transactionForm.ARVComment.value != "")       return true;
    return false;
  }

  function clearARVFields(){
    transactionForm.ARVMolecule.selectedIndex = 0;
    transactionForm.ARVDuration.value = "";
    transactionForm.ARVComment.value = "";
  }

  function deleteARV(rowid){
    if(yesnoDialog("Web","areYouSureToDelete")){
      sARV = deleteRowFromArrayString(sARV,rowid.id);
      tblARV.deleteRow(rowid.rowIndex);
      clearARVFields();
    }
  }

  function editARV(rowid){
    var row = getRowFromArrayString(sARV,rowid.id);
    transactionForm.ARVMolecule.value = getCelFromRowString(row,0);
    transactionForm.ARVDuration.value = getCelFromRowString(row,1);
    transactionForm.ARVComment.value = getCelFromRowString(row,2);

    editARVRowid = rowid;
    transactionForm.ButtonUpdateARV.disabled = false;
  }


function addAntecedents(){
    if(isAtLeastOneAntecedentsFieldFilled()){
      iAntecedentsIndex++;

      sAntecedents+="rowAntecedents"+iAntecedentsIndex+"="+transactionForm.antecedentsMolecule.value+"£"
              +transactionForm.antecedentsDateBegin.value+"£"
              +transactionForm.antecedentsDateEnd.value+"£"
              +transactionForm.antecedentsComment.value+"$";
      var tr;
      tr = tblAntecedents.insertRow(tblAntecedents.rows.length);
      tr.id = "rowAntecedents"+iAntecedentsIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteAntecedents(rowAntecedents"+iAntecedentsIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='javascript:editAntecedents(rowAntecedents"+iAntecedentsIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.antecedentsMolecule.options[transactionForm.antecedentsMolecule.selectedIndex].text;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.antecedentsDateBegin.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+transactionForm.antecedentsDateEnd.value;
      tr.appendChild(td);

      td = tr.insertCell(4);
      td.innerHTML = "&nbsp;"+transactionForm.antecedentsComment.value;
      tr.appendChild(td);

      td = tr.insertCell(5);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);
      <%-- reset --%>
      clearAntecedentsFields()
      transactionForm.ButtonUpdateAntecedents.disabled = true;
    }
    return true;
  }

  function updateAntecedents(){
    if(isAtLeastOneAntecedentsFieldFilled()){
      <%-- update arrayString --%>
      var newRow,row;

      newRow = editAntecedentsRowid.id+"="+transactionForm.antecedentsMolecule.value+"£"
               +transactionForm.antecedentsDateBegin.value+"£"
               +transactionForm.antecedentsDateEnd.value+"£"
               +transactionForm.antecedentsComment.value;

      sAntecedents = replaceRowInArrayString(sAntecedents,newRow,editAntecedentsRowid.id);

      <%-- update table object --%>
      row = tblAntecedents.rows[editAntecedentsRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteAntecedents("+editAntecedentsRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editAntecedents("+editAntecedentsRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = "&nbsp;"+transactionForm.antecedentsMolecule.options[transactionForm.antecedentsMolecule.selectedIndex].text;
      row.cells[2].innerHTML = "&nbsp;"+transactionForm.antecedentsDateBegin.value;
      row.cells[3].innerHTML = "&nbsp;"+transactionForm.antecedentsDateEnd.value;
      row.cells[4].innerHTML = "&nbsp;"+transactionForm.antecedentsComment.value;

      setCellStyle(row);

      <%-- reset --%>
      clearAntecedentsFields();
      transactionForm.ButtonUpdateAntecedents.disabled = true;
    }
  }

  function isAtLeastOneAntecedentsFieldFilled(){
    if(transactionForm.antecedentsMolecule.value != "")        return true;
    if(transactionForm.antecedentsDateBegin.value != "")       return true;
    if(transactionForm.antecedentsDateEnd.value != "")       return true;
    if(transactionForm.antecedentsComment.value != "")       return true;
    return false;
  }

  function clearAntecedentsFields(){
    transactionForm.antecedentsMolecule.selectedIndex = 0;
    transactionForm.antecedentsDateBegin.value = "";
    transactionForm.antecedentsDateEnd.value = "";
    transactionForm.antecedentsComment.value = "";
  }

  function deleteAntecedents(rowid){
    if(yesnoDialog("Web","areYouSureToDelete")){
      sAntecedents = deleteRowFromArrayString(sAntecedents,rowid.id);
      tblAntecedents.deleteRow(rowid.rowIndex);
      clearAntecedentsFields();
    }
  }

  function editAntecedents(rowid){
    var row = getRowFromArrayString(sAntecedents,rowid.id);
    transactionForm.antecedentsMolecule.value = getCelFromRowString(row,0);
    transactionForm.antecedentsDateBegin.value = getCelFromRowString(row,1);
    transactionForm.antecedentsDateEnd.value = getCelFromRowString(row,2);
    transactionForm.antecedentsComment.value = getCelFromRowString(row,3);

    editAntecedentsRowid = rowid;
    transactionForm.ButtonUpdateAntecedents.disabled = false;
  }
</script>