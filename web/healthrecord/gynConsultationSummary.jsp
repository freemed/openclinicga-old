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
<%@ page import="java.sql.Date" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product = Product.get(sProductUid);

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
                    sProductUnit = getTran("product.units", sProductUnit, sWebLanguage);
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
        <td valign="top" height="100%">
            <table  class="list" width="100%" border="0" cellspacing="1" cellpadding="1" height="100%">
                <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeGeneralClinicalExamination">
                    <bean:define id="lastTransaction_generalClinicalExamination" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeGeneralClinicalExamination"/>
                </logic:present>
                <tr class="gray">
                    <td width="33%"><%=getTran("Web.Occup","medwan.healthrecord.clinical-examination.systeme-cardiovasculaire.TA",sWebLanguage)%>
                            (<%
                            TransactionID transactionID = getMyTransactionID(activePatient.personid,"'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT','be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT'", out);
                            String sSBPR = "", sDBPR = "", sSBPL = "", sDBPL = "";
                            if (transactionID.transactionid>0){
                                sSBPR = getMyItemValue(transactionID,sPREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT",sWebLanguage);
                                sDBPR = getMyItemValue(transactionID,sPREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT",sWebLanguage);
                                sSBPL = getMyItemValue(transactionID,sPREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT",sWebLanguage);
                                sDBPL = getMyItemValue(transactionID,sPREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT",sWebLanguage);
                            }
                        %>)
                    </td>
                    <td width="33%">
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
                    <td width="33%">
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
        <td valign="top" colspan="2" height="100%">
            <table class="list" width="100%" border="0" cellspacing="1" cellpadding="0" height="100%">
                <tr class="gray">
                    <td width="33%">
                        <%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>
                        <b>
                            <%
                                String weight=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT");
                                if(weight.length()>0){
                            %>
                            <div <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%>><%=weight%></div>
                            <input id="lastWeight" type="hidden" name="lastWeight" value="<%=weight%>"/>
                            <%
                                }
                            %>
                        </b>
                    </td>
                    <td width="33%">
                        <%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>
                        <b>
                            <%
                                 String height=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT");
                                if(height.length()>0){
                            %>
                                <div <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%>><%=height%></div>
                                <input id="lastHeight" type="hidden" name="lastHeight" value="<%=height%>"/>
                            <%
                                }
                            %>
                        </b>
                    </td>
                    <td width="33%">
                        <%=getTran("Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%>
                        <b>
                            <%
                                if(height.length()*weight.length()>0){
                            %>
                                <div id="BMI"/>
                                <script>
                                  if (document.getElementsByName('lastHeight')[0].value.length > 0 && document.getElementsByName('lastWeight')[0].value.length>0){
                                    var _BMI = (document.getElementsByName('lastWeight')[0].value * 10000) / (document.getElementsByName('lastHeight')[0].value * document.getElementsByName('lastHeight')[0].value);
                                    document.getElementsByName('BMI')[0].innerHTML = "<b>"+Math.round(_BMI*10)/10+"</b>";
                                  }
                                </script>
                            <%
                                }
                            %>
                        </b>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <%-- ANAMNESE ---------------------------------------------------------------------------------------------------%>
    <tr>
        <td width="50%" valign="top">
            <table class="list" width="100%" height="100%" cellspacing="1">
                <tr class="admin">
                    <td align="center" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.general",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.subjective",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE")%> class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SUBJECTIVE7" property="value"/></textarea>
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
                        <table>
                            <tr>
                                <td><%=getTran("web","inspection",sWebLanguage)%></td>
                                <td><%=getTran("web","palpation",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_INSPECTION")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_INSPECTION7" property="itemId"/>]>.value">
                                </td>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_PALPATION")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PALPATION7" property="itemId"/>]>.value">
                                </td>
                            </tr>
                            <tr>
                                <td><%=getTran("web","percussion",sWebLanguage)%></td>
                                <td><%=getTran("web","auscultation",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_PERCUSSION")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_PERCUSSION7" property="itemId"/>]>.value">
                                </td>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_AUSCULTATION")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_AUSCULTATION7" property="itemId"/>]>.value">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="admin">
                        <%=getTran("web","breast-examination",sWebLanguage)%>
                        <img id="trBreastsS" name="trBreastsS" src="<c:url value='/_img/plus.png'/>" onclick="showD('divBreasts','trBreastsS','trBreastsH');">
                        <img id="trBreastsH" name="trBreastsH" src="<c:url value='/_img/minus.png'/>" onclick="hideD('divBreasts','trBreastsS','trBreastsH');" style="display:none">
                    </td>
                    <td colspan="3" class="admin2">
                        <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_BREAST_EXAMINATION")%> class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION7" property="itemId"/>]>.value">

                        <input type="hidden" id="EditCoordinates" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION_COORDINATES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BREAST_EXAMINATION_COORDINATES" property="value"/>">
                        <div id="divBreasts" name="divBreasts" style="display:none">
                            <table style="background-image:url('<c:url value='/_img/mammae.gif'/>')" cellspacing="0" cellpadding="0" onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'>
                                <%
                                    for (int i=1; i<21;i++){
                                        %>
                                        <tr height="7">
                                        <%
                                        for (int y=1;y<21;y++){
                                            %>
                                            <td id="rowBreastsH<%=i%>W<%=y%>" width="7" onclick="setCoord(this)" value="<%=i%>,<%=y%>"/>
                                            <%
                                        }
                                        %>
                                        </tr>
                                        <%
                                    }
                                %>
                            </table>
                            <script>
                                function setCoord(oObject){
                                    if (oObject.style.backgroundColor == ''){
                                        oObject.style.backgroundColor='black';

                                        if ($("EditCoordinates").value.indexOf((oObject.value+"$"))<0){
                                            $("EditCoordinates").value += (oObject.value+"$");
                                        }
                                    }
                                    else {
                                        oObject.style.backgroundColor='';
                                        $("EditCoordinates").value = deleteRowFromArrayString($("EditCoordinates").value,oObject.value);
                                    }
                                }

                                if ($("EditCoordinates").value.length>0){
                                    var aCoords = $("EditCoordinates").value.split("$");

                                    for (var i=0; i< aCoords.length; i++) {
                                        if (aCoords[i].length>0) {
                                            if (aCoords[i].indexOf(",")>-1){
                                                var aCoordinate = aCoords[i].split(",");
                                                setCoord($("rowBreastsH"+aCoordinate[0]+"W"+aCoordinate[1]));
                                            }
                                        }
                                    }
                                }
                            </script>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("web","gynaecology.examination",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <table>
                            <tr>
                                <td><%=getTran("web","inspection",sWebLanguage)%></td>
                                <td><%=getTran("web","speculum",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_GYNINSPECTION")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_GYNINSPECTION7" property="itemId"/>]>.value">
                                </td>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_SPECULUM")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_SPECULUM7" property="itemId"/>]>.value">
                                </td>
                            </tr>
                            <tr>
                                <td><%=getTran("web","vaginal.touche",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td>
                                    <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE")%> class="text" cols="35" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE7" property="value"/></textarea>
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE1" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE2" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE3" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE4" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE5" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE6" property="itemId"/>]>.value">
                                    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBJECTIVE_VAGINAL_TOUCHE7" property="itemId"/>]>.value">
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("gynaecology","gynaecology.echography",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_ECHOGRAPHY")%> class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ECHOGRAPHY7" property="itemId"/>]>.value">
                        <br>
                        <a href="<c:url value="/healthrecord/loadPDF.jsp"/>?file=<%=MedwanQuery.getInstance().getConfigString("echo.gyn.url","base/FR_EchoGyn.pdf")%>" target="_new"><%=getTran("gynaeco", "echogyn_url", sWebLanguage)%></a>
                        <br>
                        <a href="<c:url value="/healthrecord/loadPDF.jsp"/>?file=<%=MedwanQuery.getInstance().getConfigString("echo.firsttrim.url","base/FR_EchoPremierTrimestre.pdf")%>" target="_new"><%=getTran("gynaeco", "echofirsttrim_url", sWebLanguage)%></a>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.evaluation",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION")%> class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION7" property="value"/></textarea>
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
                        <textarea rows="1" onKeyup="resizeTextarea(this,10);" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING")%> class="text" cols="75" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING1" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING2" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING3" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING4" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING5" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING6" property="value"/><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING7" property="value"/></textarea>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING1" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING2" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING3" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING4" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING5" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING6" property="itemId"/>]>.value">
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_PLANNING7" property="itemId"/>]>.value">
                    </td>
                </tr>
            </table>
        </td>

        <%-- KLINISCH ONDERZOEK -------------------------------------------------------------------------------------%>
        <td valign="top" colspan="2">
            <table class="list" width="100%" cellspacing="1" cellpadding="0">
                <tr class="admin">
                    <td align="center" colspan="2"><%=getTran("gynaeco", "age.gestationnel", sWebLanguage)%></td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("gynaeco", "date.dr", sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_DR" property="value" formatType="date" format="dd-mm-yyyy"/>" id="drdate" onblur='checkDate(this);calculateGestAge();clearDr()' onchange='calculateGestAge();' onfocus='calculateGestAge();' onkeyup='calculateGestAge();'/>
                        <script>writeMyDate("drdate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                        <input id="agedatedr" <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_DATE_DR")%> readonly type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_DATE_DR" property="value"/>" > <%=getTran("web", "weeks.abr", sWebLanguage)%> <%=getTran("web", "delivery.date", sWebLanguage)%>:
                        <input id="drdeldate" <%=setRightClick("ITEM_TYPE_DELIVERY_DATE_DR")%> type="text" class="text" size="12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_DR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_DR" property="value"/>" onblur="checkDate(this);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("gynaeco", "date.echography", sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_ECHO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_ECHO" property="value" formatType="date" format="dd-mm-yyyy"/>" id="echodate" onBlur='checkDate(this);calculateGestAge();' onchange='calculateGestAge();' onkeyup='calculateGestAge();'/>
                        <script>writeMyDate("echodate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY" property="value"/>" id="agedateecho" onblur='isNumber(this);calculateGestAge();' onchange='calculateGestAge();' onkeyup="calculateGestAge();"> <%=getTran("web", "weeks.abr", sWebLanguage)%> <%=getTran("web", "delivery.date", sWebLanguage)%>:
                        <input id="echodeldate" <%=setRightClick("ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY")%> type="text" class="text" size="12" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY" property="value"/>" onblur="checkDate(this);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                        <%=getTran("gynaeco", "actual.age", sWebLanguage)%>
                        <input id="ageactualecho" <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_ACTUEL")%> readonly type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ACTUEL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ACTUEL" property="value"/>" onblur="isNumber(this)"> <%=getTran("web", "weeks.abr", sWebLanguage)%>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("gynaeco", "age.trimstre", sWebLanguage)%></td>
                    <td class="admin2">
                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="1"
                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=1"
                                                  property="value" outputString="checked"/>>1
                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="2"
                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=2"
                                                  property="value" outputString="checked"/>>2
                        <input <%=setRightClick("ITEM_TYPE_DELIVERY_AGE_TRIMESTRE")%> type="radio" onDblClick="uncheckRadio(this);" id="trimestre_r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE" property="itemId"/>]>.value" value="3"
                        <mxs:propertyAccessorI18N name="transaction.items" scope="page"
                                                  compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_TRIMESTRE;value=3"
                                                  property="value" outputString="checked"/>>3
                    </td>
                </tr>
            </table>
            <br>
        	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
            <br/>
            <table width="100%" class="list" cellspacing="1">
                <tr class="admin">
                    <td align="center"><a href="javascript:showProblemlist();"><%=getTran("web.occup","medwan.common.problemlist",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td id="problemList">
                        <%
                            Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
                            if(activeProblems.size()>0){
                                out.print("<table width='100%' cellspacing='0' class='list'><tr class='admin'><td>"+getTran("web.occup","medwan.common.description",sWebLanguage)+"</td><td nowrap>"+getTran("web.occup","medwan.common.datebegin",sWebLanguage)+"</td></tr>");

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
                                out.print("</table>");
                            }
                        %>
                    </td>
                </tr>
            </table>
            <br/>
            <table width="100%" class="list" cellspacing="1">
                <tr class="admin">
                    <td align="center"><a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');"><%=getTran("Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td>
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
                    </td>
                </tr>
                <tr class="admin">
                    <td align="center"><%=getTran("curative","medication.paperprescriptions",sWebLanguage)%> (<%=new SimpleDateFormat("dd/MM/yyyy").format(((TransactionVO)transaction).getUpdateTime())%>)</td>
                </tr>
                <%
                    Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",new SimpleDateFormat("dd/MM/yyyy").format(((TransactionVO)transaction).getUpdateTime()),new SimpleDateFormat("dd/MM/yyyy").format(((TransactionVO)transaction).getUpdateTime()),"","DESC");
                    if(paperprescriptions.size()>0){
                        out.print("<tr><td><table width='100%'>");
                        String l="";
                        for(int n=0;n<paperprescriptions.size();n++){
                            if(l.length()==0){
                                l="1";
                            }
                            else{
                                l="";
                            }
                            PaperPrescription paperPrescription = (PaperPrescription)paperprescriptions.elementAt(n);
                            out.println("<tr class='list"+l+"' id='pp"+paperPrescription.getUid()+"'><td valign='top' width='90px'><img src='_img/icon_delete.gif' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+new SimpleDateFormat("dd/MM/yyyy").format(paperPrescription.getBegin())+"</b></td><td><i>");
                            Vector products =paperPrescription.getProducts();
                            for(int i=0;i<products.size();i++){
                                out.print(products.elementAt(i)+"<br/>");
                            }
                            out.println("</i></td></tr>");
                        }
                        out.print("</table></td></tr>");
                    }
                %>
                <tr>
                    <td><a href="javascript:openPopup('medical/managePrescriptionForm.jsp&amp;skipEmpty=1',650,430,'medication');"><%=getTran("web","medicationpaperprescription",sWebLanguage)%></a></td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<script>
  function setBP(oObject,sbp,dbp){
      if (oObject.value.length>0){
        if (!isNumberLimited(oObject,40,300)){
          var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.occup&labelID=out-of-bounds-value";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.occup","out-of-bounds-value",sWebLanguage)%>");
        }
        else if ((sbp.length>0)&&(dbp.length>0)){
          isbp = document.getElementsByName(sbp)[0].value*1;
          idbp = document.getElementsByName(dbp)[0].value*1;
          if (idbp>isbp){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.occup&labelID=error.dbp_greather_than_sbp";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.occup","error.dbp_greather_than_sbp",sWebLanguage)%>");
          }
        }
      }
  }

  function setHF(oObject){
      if (oObject.value.length>0){
        if(!isNumberLimited(oObject,30,300)){
          var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.occup&labelID=out-of-bounds-value";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web.occup","out-of-bounds-value",sWebLanguage)%>");
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

    function clearDr(){
        if (document.getElementById("drdate").value.length==0){
            document.getElementById("agedatedr").value = "";
            document.getElementById("drdeldate").value = "";
        }
    }

    function calculateGestAge() {
        var trandate = new Date();
        var d1 = document.getElementById('trandate').value.split("/");

        if (d1.length == 3) {
            trandate.setDate(d1[0]);
            trandate.setMonth(d1[1] - 1);
            trandate.setFullYear(d1[2]);
            var lmdate = new Date();
            d1 = document.getElementById('drdate').value.split("/");
            if (d1.length == 3) {
                lmdate.setDate(d1[0]);
                lmdate.setMonth(d1[1] - 1);
                lmdate.setFullYear(d1[2]);
                var timeElapsed = trandate.getTime() - lmdate.getTime();
                timeElapsed = timeElapsed / (1000 * 3600 * 24 * 7);

                if (!isNaN(timeElapsed) && timeElapsed > 0 && timeElapsed < 60) {
                    var age = Math.round(timeElapsed * 10) / 10;
                    age = age+"";

                    if (age.indexOf(".")>-1){
                        var aAge = age.split(".");
                        aAge[1] = Math.round(aAge[1]*1*0.7);

                        age = aAge[0]+" "+aAge[1];
                    }
                    document.getElementById("agedatedr").value = age;
                    var drdeldate = lmdate;
                    drdeldate.setTime(drdeldate.getTime() + 1000 * 3600 * 24 * 280);
                    document.getElementById("drdeldate").value = drdeldate.getDate() + "/" + (drdeldate.getMonth() + 1) + "/" + drdeldate.getFullYear();
                    checkDate(document.getElementById("drdeldate"));
                    if (timeElapsed < 12) {
                        document.getElementById('trimestre_r1').checked = true;
                    }
                    else if (timeElapsed < 24) {
                        document.getElementById('trimestre_r2').checked = true;
                    }
                    else {
                        document.getElementById('trimestre_r3').checked = true;
                    }
                }
                else {
                    document.getElementById("drdeldate").value = '';
                }
            }
            //recalculate actual age based on echography estimation
            var ledate = new Date();
            d1 = document.getElementById('echodate').value.split("/");
            if (d1.length == 3) {
                ledate.setDate(d1[0]);
                ledate.setMonth(d1[1] - 1);
                ledate.setFullYear(d1[2]);
                var te = trandate.getTime() - ledate.getTime();
                var timeElapsed = te / (1000 * 3600 * 24 * 7);
                if (!isNaN(timeElapsed) && document.getElementById("agedateecho").value.length > 0 && !isNaN(document.getElementById("agedateecho").value)) {
                    if (timeElapsed < 12) {
                        document.getElementById('trimestre_r1').checked = true;
                    }
                    else if (timeElapsed < 24) {
                        document.getElementById('trimestre_r2').checked = true;
                    }
                    else {
                        document.getElementById('trimestre_r3').checked = true;
                    }
                    var age="";
                	ag = (document.getElementById("agedateecho").value * 1 + Math.round(timeElapsed * 10) / 10)+"";
                    if (ag.indexOf(".")>-1){
                        aAge = ag.split(".");
                        age = aAge[0]+ " " +aAge[1];
                    }
                    else{
                    	age=ag+"";
                    }
                    document.getElementById("ageactualecho").value = age;
                    echodeldate=new Date();
                    echodeldate.setTime(trandate.getTime()+(38-ag*1)*(1000 * 3600 * 24 * 7));
                    document.getElementById("echodeldate").value = echodeldate.getDate() + "/" + (echodeldate.getMonth() + 1) + "/" + echodeldate.getFullYear();
                }
            }
        }
    }

    if (document.getElementById("transactionId").value.startsWith("-")){
        <%
            String sAgeDateDr = "";
            ItemVO itemDelAgeDateDr = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_DR");

            if (itemDelAgeDateDr!=null){
                sAgeDateDr = itemDelAgeDateDr.getValue();
                %>document.getElementById("drdate").value = "<%=sAgeDateDr%>";<%
            }

            ItemVO itemAgeDateEcho = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE_ECHOGRAPHY");
            if (itemAgeDateEcho!=null){
                Date dNow = ScreenHelper.getSQLDate(ScreenHelper.getDate());
                long lNow = dNow.getTime()/1000/3600/24/7;
                long lEcho = Long.parseLong(itemAgeDateEcho.getValue());

                if (lNow-lEcho < 43){
                    %>document.getElementById("agedateecho").value = "<%=lNow-lEcho%>";<%

                    ItemVO itemEcho = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DATE_ECHO");
                    if (itemEcho!=null){
                        %>document.getElementById("echodate").value = "<%=itemEcho.getValue()%>";<%
                    }

                    ItemVO itemDateEcho = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_DATE_ECHOGRAPHY");
                    if (itemEcho!=null){
                        %>document.getElementById("echodeldate").value = "<%=itemDateEcho.getValue()%>";<%
                    }
                }
            }
            %>
            calculateGestAge();

            if (document.getElementById("agedatedr").value.length>0){
                var aDate = document.getElementById("agedatedr").value.split(" ");
                if (aDate[0].length>0){
                    if (aDate[0]*1>43){
                        document.getElementById("drdate").value = "";
                        clearDr();
                    }
                }
            }

            if (document.getElementById("ageactualecho").value.length>0){
                var aDate = document.getElementById("ageactualecho").value.split(" ");
                if (aDate[0].length>0){
                    if (aDate[0]*1>43){
                        document.getElementById("echodate").value = "";
                        document.getElementById("agedateecho").value = "";
                        document.getElementById("echodeldate").value = "";
                        document.getElementById("ageactualecho").value = "";
                    }
                }
            }
    }
    else {
        calculateGestAge();
    }
</script>

</logic:present>
