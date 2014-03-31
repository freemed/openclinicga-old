<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.medical.Problem,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                be.openclinic.medical.Prescription,
                java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product = new Product();
        product = product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }

    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions, String sWebLanguage) throws SQLException {
        Vector idsVector = new Vector();
        java.util.Date tmpDate;
        Product product = null;
        String sClass = "1", sPrescriptionUid = "", sDateBeginFormatted = "", sDateEndFormatted = "",
                sProductName = "", sProductUid = "", sPreviousProductUid = "", sTimeUnit = "", sTimeUnitCount = "",
                sUnitsPerTimeUnit = "", sPrescrRule = "", sProductUnit = "", timeUnitTran = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while (iter.hasNext()) {
            prescription = (Prescription)iter.next();
            sPrescriptionUid = prescription.getUid();
            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            idsVector.add(sPrescriptionUid);

            // format begin date
            tmpDate = prescription.getBegin();
            if (tmpDate != null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else sDateBeginFormatted = "";

            // format end date
            tmpDate = prescription.getEnd();
            if (tmpDate != null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if (!sProductUid.equals(sPreviousProductUid)) {
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if (product != null) {
                    sProductName = product.getName();
                } else {
                    sProductName = "";
                }
                if (sProductName.length() == 0) {
                    sProductName = "<font color='red'>" + getTran("web", "nonexistingproduct", sWebLanguage) + "</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = prescription.getTimeUnit();
            sTimeUnitCount = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if (product != null) {
                    sProductUnit = product.getUnit();
                } else {
                    sProductUnit = "";
                }
                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran("product.unit", sProductUnit, sWebLanguage);
                } else {
                    sProductUnit = getTran("product.unit", sProductUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran("prescription.timeunit", sTimeUnit, sWebLanguage);
                } else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits", sTimeUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append("<tr class='list" + sClass + "'  title='" + detailsTran + "'>")
                    .append(" <td align='center'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' border='0' title='" + deleteTran + "' onclick=\"doDelete('" + sPrescriptionUid + "');\">")
                    .append(" <td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sProductName + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sDateBeginFormatted + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sDateEndFormatted + "</td>")
                    .append(" <td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sPrescrRule.toLowerCase() + "</td>")
                    .append("</tr>");
        }
        return idsVector;
    }

    private class TransactionID {
        public int transactionid = 0;
        public int serverid = 0;
    }

    //--- GET MY TRANSACTION ID -------------------------------------------------------------------
    private TransactionID getMyTransactionID(String sPersonId, String sItemTypes, JspWriter out) {
        TransactionID transactionID = new TransactionID();
        Transaction transaction = Transaction.getSummaryTransaction(sItemTypes, sPersonId);
        try {
            if (transaction != null) {
                String sUpdateTime = ScreenHelper.getSQLDate(transaction.getUpdatetime());
                transactionID.transactionid = transaction.getTransactionId();
                transactionID.serverid = transaction.getServerid();
                out.print(sUpdateTime);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        return transactionID;
    }

    //--- GET MY ITEM VALUE -----------------------------------------------------------------------
    private String getMyItemValue(TransactionID transactionID, String sItemType, String sWebLanguage) {
        String sItemValue = "";
        Vector vItems = Item.getItems(Integer.toString(transactionID.transactionid), Integer.toString(transactionID.serverid), sItemType);
        Iterator iter = vItems.iterator();

        Item item;

        while (iter.hasNext()) {
            item = (Item) iter.next();
            sItemValue = item.getValue();//checkString(rs.getString(1));
            sItemValue = getTranNoLink("Web.Occup", sItemValue, sWebLanguage);
        }
        return sItemValue;
    }
%>
<logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="healthRecordVO">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <bean:define id="lastTransaction_biometry" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry"/>

<%
    if (session.getAttribute("sessionCounter")==null){
        session.setAttribute("sessionCounter",new Integer(0));
    }
    else {
        session.setAttribute("sessionCounter",new Integer(((Integer)session.getAttribute("sessionCounter")).intValue()+1));
    }
%>

<input type="hidden" name="sessionCounter" value="<%=session.getAttribute("sessionCounter")%>"/>

<table class="list" width="100%" border="0" cellspacing="1" cellpadding="0">
    <tr>
        <%-- LAST GENERAL CLINICAL EXAMINATION --%>
        <td style="vertical-align:top;" colspan="2" height="100%">
            <table  class="list" width="100%" border="0" cellspacing="0" cellpadding="1" height="100%">
                <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeGeneralClinicalExamination">
                    <bean:define id="lastTransaction_generalClinicalExamination" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeGeneralClinicalExamination"/>
                </logic:present>
                <tr class="admin">
                    <td colspan="2" align="center" nowrap><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination.systeme-cardiovasculaire.TA",sWebLanguage)%>
                            (<%
                            TransactionID transactionID = getMyTransactionID(activePatient.personid,"'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT'", out);
                            String sSBPR = "", sDBPR = "", sSBPL = "", sDBPL = "";
                            if (transactionID.transactionid>0){
                                sSBPR = getMyItemValue(transactionID,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT",sWebLanguage);
                                sDBPR = getMyItemValue(transactionID,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT",sWebLanguage);
                                sSBPL = getMyItemValue(transactionID,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT",sWebLanguage);
                                sDBPL = getMyItemValue(transactionID,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT",sWebLanguage);
                            }
                        %>)
                    </td>
                </tr>
                <tr height="100%">
                    <td align="center">
                        <b>
                            <span <%=setRightClickMini("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%>>
                                <%=sSBPR%>
                            </span>
                            /
                            <span <%=setRightClickMini("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%>>
                                <%=sDBPR%>
                            </span>
                        </b>
                    </td>
                    <td align="center">
                        <b>
                            <span <%=setRightClickMini("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%>>
                                <%=sSBPL%>
                            </span>
                            /
                            <span <%=setRightClickMini("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%>>
                                <%=sDBPL%>
                            </span>
                        </b>
                    </td>
                </tr>
            </table>
        </td>

        <%-- LAST BIOMETRY EXAMINATION --%>
        <td style="vertical-align:top;" colspan="2" height="100%">
            <table class="list" width="100%" border="0" cellspacing="0" cellpadding="0" height="100%">
                <tr class="admin">
                    <td align="center" width="33%"><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%></td>
                    <td align="center" width="33%"><%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%></td>
                    <td align="center" width="33%"><%=getTran("Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%></td>
                </tr>
                <tr height="100%">
                    <td align="center">
                         <b>
                            <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry">
                                <div <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%>><mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>&nbsp;</div>
                                <input id="lastWeight" type="hidden" name="lastTransaction_biometry.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>"/>
                            </logic:present>
                        </b>
                    </td>
                    <td align="center">
                        <b>
                            <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry">
                                <div <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%>><mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>&nbsp;</div>
                                <input id="lastHeight" type="hidden" name="lastTransaction_biometry.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>"/>
                            </logic:present>
                        </b>
                    </td>
                    <td align="center">
                        <b>
                            <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry">
                                <div id="BMI"></div>
                                <script>
                                  if (document.getElementsByName('lastHeight')[0].value.length > 0 && document.getElementsByName('lastWeight')[0].value.length>0){
                                    var _BMI = (document.getElementsByName('lastWeight')[0].value * 10000) / (document.getElementsByName('lastHeight')[0].value * document.getElementsByName('lastHeight')[0].value);
                                    document.getElementsByName('BMI')[0].innerHTML = Math.round(_BMI*10)/10;
                                  }
                                </script>
                            </logic:present>
                        </b>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <tr class="admin">
        <td align="center" width="50%" colspan="2"><%=getTran("Web.Occup","medwan.healthrecord.general",sWebLanguage)%></td>
        <td align="center" width="50%" colspan="2"><%=getTran("Web.Occup","medwan.healthrecord.specific",sWebLanguage)%></td>
    </tr>

    <%-- ANAMNESE ---------------------------------------------------------------------------------------------------%>
    <tr>
        <td colspan="2">
            <table class="list" width="100%" height="100%" cellspacing="1">
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.subjective",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE")%> class="text" cols="70" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE7" property="itemId"/>]>.value">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.objective",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE")%> class="text" cols="70" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_OBJECTIVE7" property="itemId"/>]>.value">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.evaluation",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION")%> class="text" cols="70" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION7" property="itemId"/>]>.value">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.planning",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING")%> class="text" cols="70" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING7" property="itemId"/>]>.value">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.cardial.frequence-cardiaque",sWebLanguage)%></td>
                    <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="value"/>" onblur="setHF(this);"> /min
                        <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1a" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH" property="itemId"/>]>.value" value="medwan.healthrecord.cardial.regulier" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH;value=medwan.healthrecord.cardial.regulier" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.cardial.regulier",sWebLanguage,"sum_r1a")%>
                        <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1b" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH" property="itemId"/>]>.value" value="medwan.healthrecord.cardial.irregulier" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH;value=medwan.healthrecord.cardial.irregulier" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.cardial.irregulier",sWebLanguage,"sum_r1b")%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%></td>
                    <td class="admin2" nowrap>
                        <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-droit",sWebLanguage)%>
                        <input id="sbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> /
                        <input id="dbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> mmHg
                    </td>
                    <td class="admin2" colspan="2" nowrap>
                        <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-gauche",sWebLanguage)%>
                        <input id="sbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> /
                        <input id="dbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> mmHg
                    </td>
                </tr>
                <tr class="admin">
                    <td align="center" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></td>
                </tr>
                <tr><td colspan="4">
                <%
                    //--- DISPLAY ACTIVE PRESCRIPTIONS (of activePatient) ---------------------------------
                    // compose query
                    Vector vActivePrescriptions = Prescription.findActive(activePatient.personid,activeUser.userid,"","","","","","");

                    StringBuffer prescriptions = new StringBuffer();
                    Vector idsVector = getActivePrescriptionsFromRs(prescriptions, vActivePrescriptions , sWebLanguage);
                    int foundPrescrCount = idsVector.size();

                    if (foundPrescrCount > 0) {
                %>
                            <table width="100%" cellspacing="0" cellpadding="0" class="list">
                                <%-- clickable header (current sort-col in italic) --%>
                                <tr class="admin">
                                    <td width="22" nowrap>&nbsp;</td>
                                    <td width="30%"><%=getTran("Web","product",sWebLanguage)%></td>
                                    <td width="15%"><%=getTran("Web","begindate",sWebLanguage)%></td>
                                    <td width="15%"><%=getTran("Web","enddate",sWebLanguage)%></td>
                                    <td width="40%"><%=getTran("Web","prescriptionrule",sWebLanguage)%></td>
                                </tr>

                                <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                    <%=prescriptions%>
                                </tbody>
                            </table>
                        <%
                    }
                    else{
                        // no records found
                        %>
                            <%=getTran("web","noactiveprescriptionsfound",sWebLanguage)%>
                            <br>
                        <%
                    }
                    %>
                </td></tr>
            </table>
        </td>

        <%-- KLINISCH ONDERZOEK -------------------------------------------------------------------------------------%>
        <td style="vertical-align:top;" colspan="2">
            <table class="list" width="100%" cellspacing="1">
                <tr>
                    <td class="admin2">
                        <img src='<c:url value="/_img/pijl.gif"/>'>
                        <a  href="javascript:document.getElementsByName('sum_r2a')[0].checked=true;document.getElementsByName('sum_r2b')[0].checked=false;subScreen('/main.do?Page=healthrecord/ausculatie.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","Ausculatie_hart_longen",sWebLanguage)%></a>
                    </td>
                    <td align="right" class="admin2"> <%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.complaints",sWebLanguage)%>
                        <input <%=setRightClick("ITEM_TYPE_CARDIAL_COMPLAINTS")%> id='sum_r2a' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_COMPLAINTS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="sum_r2a">+</label>
                        <input <%=setRightClick("ITEM_TYPE_CARDIAL_COMPLAINTS")%> id='sum_r2b' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_COMPLAINTS;value=medwan.common.false" property="value" outputString="checked"/> value="medwan.common.false"><label for="sum_r2b">-</label>
                    </td>
                </tr>
                <tr>
                    <td class="admin2">
                        <img src='<c:url value="/_img/pijl.gif"/>'>
                        <a  href="javascript:document.getElementsByName('sum_r3a')[0].checked=true;document.getElementsByName('sum_r3b')[0].checked=false;subScreen('/main.do?Page=healthrecord/orl_endocrino.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","medwan.healthrecord.ORL",sWebLanguage)%> - Endocrino</a>
                    </td>
                    <td align="right" class="admin2" width="10%" nowrap> <%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.complaints",sWebLanguage)%>
                        <input <%=setRightClick("ITEM_TYPE_ORL_COMPLAINTS")%> id='sum_r3a' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORL_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORL_COMPLAINTS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="sum_r3a">+</label>
                        <input <%=setRightClick("ITEM_TYPE_ORL_COMPLAINTS")%> id='sum_r3b' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORL_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORL_COMPLAINTS;value=medwan.common.false" property="value" outputString="checked"/> value="medwan.common.false"><label for="sum_r3b">-</label>
                    </td>
                </tr>
                <tr>
                    <td class="admin2">
                        <img src='<c:url value="/_img/pijl.gif"/>'>
                        <a  href="javascript:document.getElementsByName('sum_r4a')[0].checked=true;document.getElementsByName('sum_r4b')[0].checked=false;subScreen('/main.do?Page=healthrecord/abdominaal.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","Abdominaal_onderzoek",sWebLanguage)%></a>
                    </td>
                    <td align="right" class="admin2"> <%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.complaints",sWebLanguage)%>
                        <input <%=setRightClick("ITEM_TYPE_ABDOMINAL_COMPLAINTS")%> id='sum_r4a' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_COMPLAINTS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="sum_r4a">+</label>
                        <input <%=setRightClick("ITEM_TYPE_ABDOMINAL_COMPLAINTS")%> id='sum_r4b' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMINAL_COMPLAINTS;value=medwan.common.false" property="value" outputString="checked"/> value="medwan.common.false"><label for="sum_r4b">-</label>
                    </td>
                </tr>
                <tr>
                    <td class="admin2">
                        <img src='<c:url value="/_img/pijl.gif"/>'>
                        <a  href="javascript:document.getElementsByName('sum_r5a')[0].checked=true;document.getElementsByName('sum_r5b')[0].checked=false;subScreen('/main.do?Page=healthrecord/locomotorisch_stelsel.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","Locomotorisch_stelsel",sWebLanguage)%></a>
                    </td>
                    <td align="right" class="admin2"> <%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.complaints",sWebLanguage)%>
                        <input <%=setRightClick("ITEM_TYPE_ORTHO_COMPLAINTS")%> id='sum_r5a' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHO_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHO_COMPLAINTS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="sum_r5a">+</label>
                        <input <%=setRightClick("ITEM_TYPE_ORTHO_COMPLAINTS")%> id='sum_r5b' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHO_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHO_COMPLAINTS;value=medwan.common.false" property="value" outputString="checked"/> value="medwan.common.false"><label for="sum_r5b">-</label>
                    </td>
                </tr>
                <tr>
                    <td class="admin2">
                        <img src='<c:url value="/_img/pijl.gif"/>'>
                        <a  href="javascript:document.getElementsByName('sum_r6a')[0].checked=true;document.getElementsByName('sum_r6b')[0].checked=false;subScreen('/main.do?Page=healthrecord/neuro.jsp&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>');"><%=getTran("Web.Occup","Neuropsychiatrie",sWebLanguage)%></a>
                    </td>
                    <td align="right" class="admin2"> <%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.complaints",sWebLanguage)%>
                        <input <%=setRightClick("ITEM_TYPE_NEURO_COMPLAINTS")%> id='sum_r6a' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEURO_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEURO_COMPLAINTS;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="sum_r6a">+</label>
                        <input <%=setRightClick("ITEM_TYPE_NEURO_COMPLAINTS")%> id='sum_r6b' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEURO_COMPLAINTS" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEURO_COMPLAINTS;value=medwan.common.false" property="value" outputString="checked"/> value="medwan.common.false"><label for="sum_r6b">-</label>
                    </td>
                </tr>
            </table>
            <table class="list" width="100%" cellspacing="1">
                <tr class="admin">
                    <td align="center" colspan='2'><a href="javascript:openPopup('healthrecord/findICPC.jsp?ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>')"><%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td colspan='2' id='icpccodes'>
                    <%
                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                        TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
                        Iterator items = curTran.getItems().iterator();
                        ItemVO item;

                        String sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
                        String sReferenceType = "Transaction";
                        Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID, sReferenceType);
                        Hashtable hDiagnosisInfo = new Hashtable();
                        String sCode, sGravity, sCertainty;

                        while (items.hasNext()) {
                            item = (ItemVO) items.next();
                            if (item.getType().indexOf("ICPCCode") == 0) {
                                sCode = item.getType().substring("ICPCCode".length(), item.getType().length());
                                hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
                                if (hDiagnosisInfo != null) {
                                    sGravity = (String) hDiagnosisInfo.get("Gravity");
                                    sCertainty = (String) hDiagnosisInfo.get("Certainty");
                                } else {
                                    sGravity = "";
                                    sCertainty = "";
                                }
                    %><span id="ICPCCode<%=item.getItemId()%>">
                                        <img src="<c:url value='/_img/icon_delete.gif'/>" onclick="document.getElementById('ICPCCode<%=item.getItemId()%>').innerHTML='';"/><input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/><input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/>
                                        <%=item.getType().replaceAll("ICPCCode","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>
                                        <br/>
                                  </span>
                                <%
                            }
                            else if (item.getType().indexOf("ICD10Code")==0){
                                sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
                                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
                                if (hDiagnosisInfo != null) {
	                                sGravity = (String)hDiagnosisInfo.get("Gravity");
	                                sCertainty = (String)hDiagnosisInfo.get("Certainty");
                                } else {
                                    sGravity = "";
                                    sCertainty = "";
                                }
                                %><span id='ICD10Code<%=item.getItemId()%>'>
                                        <img src='<c:url value="/_img/icon_delete.gif"/>' onclick="document.getElementById('ICD10Code<%=item.getItemId()%>').innerHTML='';"/><input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/><input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/>
                                        <%=item.getType().replaceAll("ICD10Code","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>
                                        <br/>
                                  </span>
                                <%
                            }
                        }
                    %>
                    </td>
                </tr>
                <tr class="admin">
                    <td align="center" colspan='2'><a href="javascript:showProblemlist();"><%=getTran("web.occup","medwan.common.problemlist",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td colspan="2"  id="problemList">
                        <%
                            Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
                            if(activeProblems.size()>0){
                                out.print("<table width='100%' cellspacing='0'><tr class='admin'><td>"+getTran("web.occup","medwan.common.description",sWebLanguage)+"</td><td nowrap>"+getTran("web.occup","medwan.common.datebegin",sWebLanguage)+"</td></tr>");
                            }
                            String sClass = "1";

                            for(int n=0;n<activeProblems.size();n++){
                                if(sClass.equals("")){
                                    sClass = "1";
                                }else{
                                    sClass = "";
                                }
                                Problem activeProblem = (Problem)activeProblems.elementAt(n);
                                String comment="";
                                if(activeProblem.getComment().trim().length()>0){
                                    comment=":&nbsp;<i>"+activeProblem.getComment().trim()+"</i>";
                                }
                                out.print("<tr class='list" + sClass + "'><td><b>"+(activeProblem.getCode()+" "+MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(),sWebLanguage)+"</b>"+comment)+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy").format(activeProblem.getBegin())+"</td></tr>");
                            }
                        %>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<script>
  function setBP(oObject,sbp,dbp){
      if (oObject.value.length>0){
        if (!isNumberLimited(oObject,40,300)){
          var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=999999999&labelType=Web.occup&labelID=out-of-bounds-value";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          window.showModalDialog(popupUrl,'',modalities);
        }
        else if ((sbp.length>0)&&(dbp.length>0)){
          isbp = document.getElementsByName(sbp)[0].value*1;
          idbp = document.getElementsByName(dbp)[0].value*1;
          if (idbp>isbp){
            var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=999999999&labelType=Web.occup&labelID=error.dbp_greather_than_sbp";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            window.showModalDialog(popupUrl,'',modalities);
          }
        }
      }
  }

  function setHF(oObject){
      if (oObject.value.length>0){
        if(!isNumberLimited(oObject,30,300)){
          var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=999999999&labelType=Web.occup&labelID=out-of-bounds-value";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          window.showModalDialog(popupUrl,'',modalities);
        }
      }
  }

  function deleteDiagnose(rowid){
    activeDiagnosis.deleteRow(rowid.rowIndex);
  }

  function showProblemlist(){
    openPopup("medical/manageProblems.jsp&ts=<%=getTs()%>");
  }

  function doShowDetails(uid){
    openPopup("medical/managePrescriptionsPopup.jsp&Action=showDetails&EditPrescrUid="+uid);
  }

</script>
</logic:present>