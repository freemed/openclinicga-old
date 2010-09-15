<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                java.util.*" %>
<%@ page import="be.openclinic.adt.Encounter" %>
<%@ page import="be.openclinic.medical.*" %>
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
            prescriptions.append("<tr class='list" + sClass + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\" title='" + detailsTran + "'>")
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
                                <div id="BMI"></div>
                                <script>
                                  if (document.all['lastHeight'].value.length > 0 && document.all['lastWeight'].value.length>0){
                                    var _BMI = (document.all['lastWeight'].value * 10000) / (document.all['lastHeight'].value * document.all['lastHeight'].value);
                                    document.all['BMI'].innerHTML = "<b>"+Math.round(_BMI*10)/10+"</b>";
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
        <td width="50%">
            <table class="list" width="100%" height="100%" cellspacing="1">
                <tr class="admin">
                    <td align="center" colspan="4"><%=getTran("Web.Occup","medwan.healthrecord.general",sWebLanguage)%></td>
                </tr>
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
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <input type="text" class="text" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(0,45,this)){alert('<%=getTran("Web.Occup","medwan.common.unrealistic-value",sWebLanguage)%>');}}" size="5"/>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("openclinic.chuk","respiratory.frequency",sWebLanguage)%></td>
                    <td colspan="3" class="admin2">
                        <input type="text" class="text" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY" property="value"/>" onBlur="isNumber(this)" size="5"/> /min
                    </td>
                </tr>
            </table>
        </td>

        <%-- KLINISCH ONDERZOEK -------------------------------------------------------------------------------------%>
        <td valign="top" colspan="2">
            <table class="list" width="100%" cellspacing="1">
                    <%
                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                        TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
                        Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(new SimpleDateFormat("dd/MM/yyyy 23:99").format(curTran.getUpdateTime())).getTime()),activePatient.personid);
                        String rfe="";
                        if(encounter!=null){
                            rfe=ReasonForEncounter.getReasonsForEncounterAsHtml(encounter,sWebLanguage,"_img/icon_delete.gif","deleteRFE($serverid,$objectid)");
                            %>
                            <tr class="admin">
                                <td align="center"><a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=encounter.getUid()%>&ts=<%=getTs()%>',700,400)"><%=getTran("openclinic.chuk","rfe",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
                            </tr>
                            <tr>
                                <td id='rfe'>
                                    <%=rfe%>
                                </td>
                            </tr>
                            <%
                        }
                    %>
                <tr class="admin">
                    <td align="center"><a href="javascript:openPopup('healthrecord/findICPC.jsp&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>',700,400)"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td id='icpccodes'>
                    <%
                	sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                    curTran = sessionContainerWO.getCurrentTransactionVO();
                    Iterator items = curTran.getItems().iterator();
                    ItemVO item;

                    String sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
                    String sReferenceType = "Transaction";
                    Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID, sReferenceType);
                    Hashtable hDiagnosisInfo;
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
                                    <%=item.getType().replaceAll("ICPCCode","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%></i>
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
                                    <%=item.getType().replaceAll("ICD10Code","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%></i>
                                    <br/>
                              </span>
                            <%
                        }
                    }
                    %>
                    </td>
                </tr>
            </table>
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
                    <td align="center"><%=getTran("Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></td>
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
          isbp = document.all[sbp].value*1;
          idbp = document.all[dbp].value*1;
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

  function deleteRFE(serverid,objectid){
      if(confirm("<%=getTran("Web","AreYouSure",sWebLanguage)%>")){
          var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=encounter!=null?encounter.getUid():""%>&language=<%=sWebLanguage%>";
          var today = new Date();
          var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+today;
          new Ajax.Request(url,{
                  method: "GET",
                  parameters: params,
                  onSuccess: function(resp){
                      rfe.innerHTML=resp.responseText;
                  },
                  onFailure: function(){
                  }
              }
          );
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

    <%
    if(encounter!=null && rfe.length()==0){
    %>
      window.setTimeout("openPopup('healthrecord/findRFE.jsp&field=rfe&trandate="+document.getElementById("trandate")+"&encounterUid=<%=encounter.getUid()%>&ts=<%=getTs()%>',700,400)",200);
    <%
    }
    %>
</script>
</logic:present>