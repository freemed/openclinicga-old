<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@include file="/_common/templateAddIns.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.surveillance.USI","select",activeUser)%>

<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<%!
    public int getFreeDataSetNr(TransactionVO transaction){
        ItemVO item;
        for(int i = 1; i<=100; i++){
            item = transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIME-" + i);
            if(item.getValue().equals("")){
                return i;
            }
        }

        return -1;
    }
%>
<%
    String sAction = checkString(request.getParameter("Action"));
    String sTranDate = checkString(request.getParameter("trandate"));
    String sDataSetNr = checkString(request.getParameter("DataSetNr"));
    String sContext = checkString(request.getParameter("CONTEXT_CONTEXT"));
    String sContextDepartment = checkString(request.getParameter("CONTEXT_DEPARTMENT"));
try{
    if (sAction.equals("SAVE")) {
        Enumeration enum2 = request.getParameterNames();
        String sParam, sValue;
        ItemVO item;

        while (enum2.hasMoreElements()) {
            sParam = (String) enum2.nextElement();

            if (sParam.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.")) {
                item = ((TransactionVO) transaction).getItem(sParam);
                sValue = checkString(request.getParameter(sParam));

                if (!sValue.equals("")) {
                    item.setValue(sValue);
                }
            }
        }
        MedwanQuery.getInstance().updateTransaction(Integer.parseInt(activePatient.personid), (TransactionVO) transaction);
%>
        <script>
            window.opener.location.href = "main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
            window.close();
        </script>
<%
    }else if(sAction.equals("DELETE")){

        Collection cItems = ((TransactionVO)transaction).getItems();
        Iterator iter = cItems.iterator();

        ItemVO item;

        while(iter.hasNext()){
            item = (ItemVO)iter.next();

            if(item.getType().endsWith(sDataSetNr)){
                item.setValue("");
            }
        }

        MedwanQuery.getInstance().updateTransaction(Integer.parseInt(activePatient.personid),(TransactionVO)transaction);
%>
        <script>
            window.opener.location.href = "main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
            window.close();
        </script>
<%
    }else {
%>
<form name="transactionForm" id="transactionForm" method="POST" action='' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <table cellspacing="0" cellpadding="0" width="100%">
    <tr class='admin' height='25'>
        <td><%=ScreenHelper.getTran("Web.Occup", ((TransactionVO)transaction).getTransactionType(), sWebLanguage)%></td>
    </tr>
    <input type="hidden" name="Action" value="SAVE">
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%

        int iDataSetNr;

        if(sDataSetNr.length() > 0){
            iDataSetNr = Integer.parseInt(sDataSetNr);
        }else{
            iDataSetNr = getFreeDataSetNr(((TransactionVO)transaction));
        }

        if(iDataSetNr <= 6 && iDataSetNr!=-1){
    %>
    <input type="hidden" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT").getType()%>" value="<%=sContext%>">
    <input type="hidden" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT").getType()%>" value="<%=sContextDepartment%>">
    <input type="hidden" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_UPDATEUSERID-" + iDataSetNr).getType()%>" value="<%=activeUser.userid%>">
        <tr>
            <td style="vertical-align:top;">
                <div style="overflow:auto;min-height:450px;height:550px;border: 1px solid black;">
                    <table class="list" width="100%" cellspacing="1">
                        <%-- actual date --%>
                        <tr>
                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","date",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" readonly class="text" size="12" maxLength="10" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE-"+iDataSetNr).getType()%>" value="<%=ScreenHelper.stdDateFormat.format(new java.util.Date())%>" id="date">
                            </td>
                        </tr>
                        <%-- actual hour --%>
                        <tr>
                            <td class="admin"><%=getTran("web.occup","medwan.common.hour",sWebLanguage)%></td>
                            <td class="admin2">
                                <%=ScreenHelper.writeTimeField(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIME-"+iDataSetNr).getType(), checkString(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIME-"+iDataSetNr).getValue()))%>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","lactate",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LACTATE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LACTATE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalIn();" id="lactate"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","glucose",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GLUCOSE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GLUCOSE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalIn();" id="glucose"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","physiology",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIOLOGY-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIOLOGY-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalIn();" id="physiology"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","shaem",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SHAEM-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SHAEM-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalIn();" id="shaem"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","transfusion",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSFUSION-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSFUSION-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalIn();" id="transfusion"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","blood",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BLOOD-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BLOOD-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalIn();" id="sang"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","total_in",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TOTAL_IN-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TOTAL_IN-"+iDataSetNr).getValue()%>" size="5" readonly="readonly" onblur="calculateBilan();" id="total_in"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pompe_syringe_text1",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE_TEXT1-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE_TEXT1-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pompe_syringe1",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE1-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE1-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);"> ml/h
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pompe_syringe_text2",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE_TEXT2-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE_TEXT2-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pompe_syringe2",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE2-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE2-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);"> ml/h
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pompe_syringe_text3",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE_TEXT3-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE_TEXT3-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pompe_syringe3",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE3-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_POMPE_SYRINGE3-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);"> ml/h
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","remarks1",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REMARKS1-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REMARKS1-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","glycemie",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GLYCEMIE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GLYCEMIE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPERATURE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPERATURE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","gcs_y",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GCS_Y-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GCS_Y-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","gcs_v",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GCS_V-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GCS_V-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","gcs_m",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GCS_M-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GCS_M-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","isocorie",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="isocorie_yes" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ISOCORIE-"+iDataSetNr).getType()%>" value="medwan.common.yes" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ISOCORIE-"+iDataSetNr).getValue().equals("medwan.common.yes")) out.print("checked");%>><label for="isocorie_yes"><%=getTran("web.occup","medwan.common.yes",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="isocorie_dr-g" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ISOCORIE-"+iDataSetNr).getType()%>" value="usi.surveillance.dr-g" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ISOCORIE-"+iDataSetNr).getValue().equals("usi.surveillance.dr-g")) out.print("checked");%>><label for="isocorie_dr-g"><%=getTran("web.occup","usi.surveillance.dr-g",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="isocorie_g-dr" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ISOCORIE-"+iDataSetNr).getType()%>" value="usi.surveillance.g-dr" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ISOCORIE-"+iDataSetNr).getValue().equals("usi.surveillance.g-dr")) out.print("checked");%>><label for="isocorie_g-dr"><%=getTran("web.occup","usi.surveillance.g-dr",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","reaction_light",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="reaction_light++" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getType()%>" value="usi.surveillance.plus_plus" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getValue().equals("usi.surveillance.plus_plus")) out.print("checked");%>><label for="reaction_light++"><%=getTran("web.occup","usi.surveillance.plus_plus",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="reaction_light+-" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getType()%>" value="usi.surveillance.plus_minus" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getValue().equals("usi.surveillance.plus_minus")) out.print("checked");%>><label for="reaction_light+-"><%=getTran("web.occup","usi.surveillance.plus_minus",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="reaction_light-+" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getType()%>" value="usi.surveillance.minus_plus" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getValue().equals("usi.surveillance.minus_plus")) out.print("checked");%>><label for="reaction_light-+"><%=getTran("web.occup","usi.surveillance.minus_plus",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="reaction_light--" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getType()%>" value="usi.surveillance.minus_minus" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION_LIGHT-"+iDataSetNr).getValue().equals("usi.surveillance.minus_minus")) out.print("checked");%>><label for="reaction_light--"><%=getTran("web.occup","usi.surveillance.minus_minus",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","rc",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RC-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RC-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","tas",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TAS-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TAS-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","tad",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TAD-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TAD-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","tam",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TAM-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TAM-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pvc",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PVC-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PVC-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","rr",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RR-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RR-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","sat",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SAT-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SAT-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","fio2",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FIO2-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FIO2-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","l_min",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_L_MIN-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_L_MIN-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","voie",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="voie_masque" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOIE-"+iDataSetNr).getType()%>"  value="usi.surveillance.masque" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOIE-"+iDataSetNr).getValue().equals("usi.surveillance.masque")) out.print("checked");%>><label for="voie_masque"><%=getTran("web.occup","usi.surveillance.masque",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="voie_masque_sac" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOIE-"+iDataSetNr).getType()%>" value="usi.surveillance.masque_sac" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOIE-"+iDataSetNr).getValue().equals("usi.surveillance.masque_sac")) out.print("checked");%>><label for="voie_masque_sac"><%=getTran("web.occup","usi.surveillance.masque_sac",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="voie_sonde" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOIE-"+iDataSetNr).getType()%>" value="usi.surveillance.sonde" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOIE-"+iDataSetNr).getValue().equals("usi.surveillance.sonde")) out.print("checked");%>><label for="voie_sonde"><%=getTran("web.occup","usi.surveillance.sonde",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","nebulisation",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEBULISATION-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEBULISATION-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","cpap",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="cpap_yes" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CPAP-"+iDataSetNr).getType()%>" value="medwan.common.yes" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CPAP-"+iDataSetNr).getValue().equals("medwan.common.yes")) out.print("checked");%>><label for="cpap_yes"><%=getTran("web.occup","medwan.common.yes",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="cpap_non" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CPAP-"+iDataSetNr).getType()%>" value="medwan.common.no" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CPAP-"+iDataSetNr).getValue().equals("medwan.common.no")) out.print("checked");%>><label for="cpap_non"><%=getTran("web.occup","medwan.common.no",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","intubation",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="intubation_yes" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INTUBATION_USI-"+iDataSetNr).getType()%>" value="medwan.common.yes" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INTUBATION_USI-"+iDataSetNr).getValue().equals("medwan.common.yes")) out.print("checked");%>><label for="intubation_yes"><%=getTran("web.occup","medwan.common.yes",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="intubation_non" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INTUBATION_USI-"+iDataSetNr).getType()%>" value="medwan.common.no" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INTUBATION_USI-"+iDataSetNr).getValue().equals("medwan.common.no")) out.print("checked");%>><label for="intubation_non"><%=getTran("web.occup","medwan.common.no",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","tube",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TUBE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TUBE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","days_intubation",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAYS_INTUBATION-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAYS_INTUBATION-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","tracheostomie",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="tracheostomie_yes" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACHEOSTOMIE-"+iDataSetNr).getType()%>" value="medwan.common.yes" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACHEOSTOMIE-"+iDataSetNr).getValue().equals("medwan.common.yes")) out.print("checked");%>><label for="tracheostomie_yes"><%=getTran("web.occup","medwan.common.yes",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="tracheostomie_non" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACHEOSTOMIE-"+iDataSetNr).getType()%>" value="medwan.common.no" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRACHEOSTOMIE-"+iDataSetNr).getValue().equals("medwan.common.no")) out.print("checked");%>><label for="tracheostomie_non"><%=getTran("web.occup","medwan.common.no",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","days_tracheostomie",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAYS_TRACHEOSTOMIE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAYS_TRACHEOSTOMIE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","aspiration",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASPIRATION-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASPIRATION-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","vc",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VC-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VC-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","pc",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PC-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PC-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","peep_pression",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PA-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PA-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","days_ventilation",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAYS_VENTILATION-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DAYS_VENTILATION-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","frequency",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FREQUENCY-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FREQUENCY-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","tidal_vol",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIDAL_VOL-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIDAL_VOL-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","min_volume",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIN_VOLUME-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIN_VOLUME-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","max_pression",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MAX_PRESSION-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MAX_PRESSION-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","diurese",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIURESE-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIURESE-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="diurese">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain_text1",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT1-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT1-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain1",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN1-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN1-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="drain1"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain_text2",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT2-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN2-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain2",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN2-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN2-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="drain2"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain_text3",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT3-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT3-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain3",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN3-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN3-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="drain3"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain_text4",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT4-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT4-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain4",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN4-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN4-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="drain4"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain_text5",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT5-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN_TEXT5-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","drain5",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN5-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DRAIN5-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="drain5"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","sng",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SNG-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SNG-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);calculateTotalOut();" id="sng"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","total_out",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TOTAL_OUT-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TOTAL_OUT-"+iDataSetNr).getValue()%>" size="5" readonly="readonly" onblur="calculateBilan();" id="total_out"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","out",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OUT-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OUT-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);"> ml/kg/<%=getTran("web.occup","medwan.common.hour",sWebLanguage)%>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","vomissements",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOMISSEMENTS-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VOMISSEMENTS-"+iDataSetNr).getValue()%>" size="5" onchange="isNumber(this);">
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","selles",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="radio" onDblClick="uncheckRadio(this);" id="selles_dur" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SELLES-"+iDataSetNr).getType()%>" value="usi.surveillance.dur" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SELLES-"+iDataSetNr).getValue().equals("usi.surveillance.dur")) out.print("checked");%>><label for="selles_dur"><%=getTran("web.occup","usi.surveillance.dur",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="selles_moyen" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SELLES-"+iDataSetNr).getType()%>" value="usi.surveillance.moyen" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SELLES-"+iDataSetNr).getValue().equals("usi.surveillance.moyen")) out.print("checked");%>><label for="selles_moyen"><%=getTran("web.occup","usi.surveillance.moyen",sWebLanguage)%></label>
                                <input type="radio" onDblClick="uncheckRadio(this);" id="selles_diarrhee" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SELLES-"+iDataSetNr).getType()%>" value="usi.surveillance.diarrhee" <%if(((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SELLES-"+iDataSetNr).getValue().equals("usi.surveillance.diarrhee")) out.print("checked");%>><label for="selles_diarrhee"><%=getTran("web.occup","usi.surveillance.diarrhee",sWebLanguage)%></label>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","remarks2",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REMARKS2-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REMARKS2-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","bilan_in_out",sWebLanguage)%></td>
                            <td class="admin2">
                                <input type="text" class="text" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BILAN_IN_OUT-"+iDataSetNr).getType()%>" value="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BILAN_IN_OUT-"+iDataSetNr).getValue()%>" size="5" readonly="readonly" id="bilan_in_out"> ml
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","nurse_notes",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_NOTES-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_NOTES-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td class="admin"/>
                            <td class="admin2"/>
                        </tr>
                        <tr>
                            <td class="admin"><%=getTran("openclinic.chuk","remarks3",sWebLanguage)%></td>
                            <td class="admin2">
                                <textarea class="text" onkeyup="resizeTextarea(this,10);limitChars(this,255);" name="<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REMARKS3-"+iDataSetNr).getType()%>" cols="50" rows="2"><%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REMARKS3-"+iDataSetNr).getValue()%></textarea>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
            
	        <tr>
	            <td align="center">
	                <br>
	                <%-- BUTTONS --%>
	                <%
	                  if (activeUser.getAccessRight("occup.surveillance.USI.add") || activeUser.getAccessRight("occup.surveillance.USI.edit")){
	                %>
	                    <INPUT class="button" type="button" name="saveButton" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="doSubmit();"/>
	                <%
	                  }
	                %>
	                    <INPUT class="button" type="button" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onclick="window.close();">
	            </td>
	        <tr>
	        
        <script>
            if(document.getElementsByName("<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIME-"+iDataSetNr).getType()%>")[0].value == ""){
                document.getElementsByName("<%=((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TIME-"+iDataSetNr).getType()%>")[0].value = "<%=ScreenHelper.formatSQLDate(ScreenHelper.getSQLTime(),"HH:mm")%>";
            }
            function doSubmit(){

                transactionForm.saveButton.disabled = true;
                document.transactionForm.submit();
            }

            function calculateTotalIn(){
                var sum = 0;
                sum += Number(document.getElementById("lactate").value);
                sum += Number(document.getElementById("glucose").value);
                sum += Number(document.getElementById("physiology").value);
                sum += Number(document.getElementById("shaem").value);
                sum += Number(document.getElementById("transfusion").value);
                sum += Number(document.getElementById("sang").value);

                document.getElementById("total_in").value = sum;
                calculateBilan();
            }

            function calculateTotalOut(){
                var sum = 0;
                sum += Number(document.getElementById("diurese").value);
                sum += Number(document.getElementById("drain1").value);
                sum += Number(document.getElementById("drain2").value);
                sum += Number(document.getElementById("drain3").value);
                sum += Number(document.getElementById("drain4").value);
                sum += Number(document.getElementById("drain5").value);
                sum += Number(document.getElementById("sng").value);

                document.getElementById("total_out").value = sum;
                calculateBilan();
            }

            function calculateBilan(){
                var sum = 0;
                var t_in = Number(document.getElementById("total_in").value);
                var t_out = Number(document.getElementById("total_out").value);

                sum += Number(t_in);
                sum -= Number(t_out);

                document.getElementById("bilan_in_out").value = sum;
            }
        </script>
        <%
            }else{
                out.print("<tr><td>You have reached the maximum Data Sets available for this examination</td></tr>");
            }
        %>
</table>
</form>
<%
    }
}catch(Exception e){
	e.printStackTrace();
}
%>