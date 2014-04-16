<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO"%>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.system.Item" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<%!
    //--- ADD CHIRURGIE ---------------------------------------------------------------------------
    private String addChirurgie(int iTotal, String sTmpChirurgieDateBegin, String sTmpChirurgieDateEnd, String sTmpChirurgieDescr, String sWebLanguage) {
        return "<tr id='rowChirurgie" + iTotal + "'>"
                + "<td width='36'>"
                + " <a href='#' onclick='deleteChirurgie(rowChirurgie" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
                + " <a href='#' onclick='editChirurgie(rowChirurgie" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
                + "</td>"
                + "<td>&nbsp;" + sTmpChirurgieDateBegin + "</td>"
                + "<td>&nbsp;" + sTmpChirurgieDateEnd + "</td>"
                + "<td>&nbsp;" + sTmpChirurgieDescr + "</td>"
                + "</tr>";
    }

    //--- ADD HEELKUNDE ---------------------------------------------------------------------------
    private String addHeelkunde(int iTotal, String sTmpHeelkundeDateBegin, String sTmpHeelkundeDateEnd, String sTmpHeelkundeDescr, String sWebLanguage) {
        return "<tr id='rowHeelkunde" + iTotal + "'>"
                + "<td width='36'>"
                + " <a href='#' onclick='deleteHeelkunde(rowHeelkunde" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
                + " <a href='#' onclick='editHeelkunde(rowHeelkunde" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
                + "</td>"
                + "<td>&nbsp;" + sTmpHeelkundeDateBegin + "</td>"
                + "<td>&nbsp;" + sTmpHeelkundeDateEnd + "</td>"
                + "<td>&nbsp;" + sTmpHeelkundeDescr + "</td>"
                + "</tr>";
    }

    //--- ADD LETSEL ------------------------------------------------------------------------------
    private String addLetsel(int iTotal, String sTmpLetselsDate, String sTmpLetselsDescr, String sTmpLetselsBI, String sWebLanguage) {
        return "<tr id='rowLetsels" + iTotal + "'>"
                + "<td>"
                + " <a href='#' onclick='deleteLetsels(rowLetsels" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup", "medwan.common.delete", sWebLanguage) + "' border='0'></a> "
                + " <a href='#' onclick='editLetsels(rowLetsels" + iTotal + ")'><img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web.Occup", "medwan.common.edit", sWebLanguage) + "' border='0'></a>"
                + "</td>"
                + "<td>&nbsp;" + sTmpLetselsDate + "</td>"
                + "<td>&nbsp;" + sTmpLetselsDescr + "</td>"
                + "<td>&nbsp;" + sTmpLetselsBI + (sTmpLetselsBI.equals("") ? "" : "%") + "</td>"
                + "</tr>";
    }
%>

<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<%
    String sChirurgie = "", sLetsels = "", sComment = "", sDivChirurgie = "", sDivLetsels = "", sHeelkunde = "", sDivHeelkunde = "";
    if (transaction != null) {
        TransactionVO tran = (TransactionVO) transaction;
        if (tran != null) {
            sChirurgie = getItemType(tran.getItems(), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN");
            sLetsels = getItemType(tran.getItems(), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS");
            sHeelkunde = getItemType(tran.getItems(), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE");
            sComment = getItemType(tran.getItems(), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT");
        }

        if (tran.getTransactionId().intValue() < 0) {
            boolean bChirurgie = (sChirurgie.equalsIgnoreCase(""));
            boolean bLetsels = (sLetsels.equalsIgnoreCase(""));
            boolean bHeelkunde = (sHeelkunde.equalsIgnoreCase(""));
            boolean bComment = (sComment.equalsIgnoreCase(""));

            String sType, sValue;
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
            tran = sessionContainerWO.getLastTransaction(tran.getTransactionType());
            if (tran != null) {
                Vector vItems = Item.getItems(tran.getTransactionId().toString(),Integer.toString(tran.getServerId()),"");
                Iterator iter = vItems.iterator();

                Item item;
                while(iter.hasNext()){
                    item = (Item)iter.next();
                    sType = checkString(item.getType());
                    sValue = checkString(item.getValue());
                    sValue = replace(sValue, "\n", "");
                    sValue = replace(sValue, "\r", "");

                    if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN")) {
                        if (bChirurgie) {
                            sChirurgie += sValue;
                        }
                    } else
                    if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS")) {
                        if (bLetsels) {
                            sLetsels += sValue;
                        }
                    } else
                    if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE")) {
                        if (bHeelkunde) {
                            sHeelkunde += sValue;
                        }
                    } else
                    if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT")) {
                        if (bComment) {
                            sComment += sValue;
                        }
                    }
                }
            }
        }
    }

    int iTotal = 1;

    //--- chirurgie -------------------------------------------------------------------------------
    if ((sChirurgie.toLowerCase().startsWith("<tr>")) || (sChirurgie.toLowerCase().startsWith("<tbody>"))) {
        String sTmpChirurgie = sChirurgie;
        String sTmpChirurgieDate, sTmpChirurgieDescr;
        sChirurgie = "";

        while (sTmpChirurgie.toLowerCase().indexOf("<tr>") > -1) {
            sTmpChirurgieDate = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("<td>") + 4, sTmpChirurgie.toLowerCase().indexOf("</td>"));
            sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("</td>") + 11);
            sTmpChirurgieDescr = sTmpChirurgie.substring(0, sTmpChirurgie.toLowerCase().indexOf("</td>"));
            sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("</tr>") + 5);
            sChirurgie += "rowChirurgie" + iTotal + "=" + sTmpChirurgieDate + "££" + sTmpChirurgieDescr + "$";
            sDivChirurgie += addChirurgie(iTotal, sTmpChirurgieDate, "", sTmpChirurgieDescr, sWebLanguage);
            iTotal++;
        }
    } else if (sChirurgie.indexOf("£") > -1) {
        String sTmpChirurgie = sChirurgie;
        String sTmpChirurgieDateBegin, sTmpChirurgieDateEnd, sTmpChirurgieDescr;
        sChirurgie = "";
        while (sTmpChirurgie.toLowerCase().indexOf("$") > -1) {
            sTmpChirurgieDateBegin = "";
            sTmpChirurgieDateEnd = "";
            sTmpChirurgieDescr = "";

            if (sTmpChirurgie.toLowerCase().indexOf("£") > -1) {
                sTmpChirurgieDateBegin = sTmpChirurgie.substring(0, sTmpChirurgie.toLowerCase().indexOf("£"));
                sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("£") + 1);
            }
            if (sTmpChirurgie.toLowerCase().indexOf("£") > -1) {
                sTmpChirurgieDateEnd = sTmpChirurgie.substring(0, sTmpChirurgie.toLowerCase().indexOf("£"));
                sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("£") + 1);
            }
            if (sTmpChirurgie.toLowerCase().indexOf("$") > -1) {
                sTmpChirurgieDescr = sTmpChirurgie.substring(0, sTmpChirurgie.toLowerCase().indexOf("$"));
                sTmpChirurgie = sTmpChirurgie.substring(sTmpChirurgie.toLowerCase().indexOf("$") + 1);
            }

            sChirurgie += "rowChirurgie" + iTotal + "=" + sTmpChirurgieDateBegin + "£" + sTmpChirurgieDateEnd + "£" + sTmpChirurgieDescr + "$";
            sDivChirurgie += addChirurgie(iTotal, sTmpChirurgieDateBegin, sTmpChirurgieDateEnd, sTmpChirurgieDescr, sWebLanguage);
            iTotal++;
        }
    } else if (sChirurgie.length() > 0) {
        String sTmpChirurgie = sChirurgie;
        sChirurgie += "rowChirurgie" + iTotal + "=££" + sTmpChirurgie + "$";
        sDivChirurgie += addChirurgie(iTotal, "", "", sTmpChirurgie, sWebLanguage);
        iTotal++;
    }

    //--- heelkunde -------------------------------------------------------------------------------
    if (sHeelkunde.indexOf("£") > -1) {
        String sTmpHeelkunde = sHeelkunde;
        String sTmpHeelkundeDateBegin, sTmpHeelkundeDateEnd, sTmpHeelkundeDescr;
        sHeelkunde = "";

        while (sTmpHeelkunde.toLowerCase().indexOf("$") > -1) {
            sTmpHeelkundeDateBegin = sTmpHeelkunde.substring(0, sTmpHeelkunde.toLowerCase().indexOf("£"));
            sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.toLowerCase().indexOf("£") + 1);
            sTmpHeelkundeDateEnd = sTmpHeelkunde.substring(0, sTmpHeelkunde.toLowerCase().indexOf("£"));
            sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.toLowerCase().indexOf("£") + 1);
            sTmpHeelkundeDescr = sTmpHeelkunde.substring(0, sTmpHeelkunde.toLowerCase().indexOf("$"));
            sTmpHeelkunde = sTmpHeelkunde.substring(sTmpHeelkunde.toLowerCase().indexOf("$") + 1);

            sHeelkunde += "rowHeelkunde" + iTotal + "=" + sTmpHeelkundeDateBegin + "£" + sTmpHeelkundeDateEnd + "£" + sTmpHeelkundeDescr + "$";
            sDivHeelkunde += addHeelkunde(iTotal, sTmpHeelkundeDateBegin, sTmpHeelkundeDateEnd, sTmpHeelkundeDescr, sWebLanguage);
            iTotal++;
        }
    } else if (sHeelkunde.length() > 0) {
        String sTmpHeelkunde = sHeelkunde;
        sHeelkunde += "rowHeelkunde" + iTotal + "=££" + sTmpHeelkunde + "$";
        sDivHeelkunde += addHeelkunde(iTotal, "", "", sTmpHeelkunde, sWebLanguage);
        iTotal++;
    }

    //--- letsels ---------------------------------------------------------------------------------
    if ((sLetsels.toLowerCase().startsWith("<tr>")) || (sLetsels.toLowerCase().startsWith("<tbody>"))) {
        String sTmpLetsels = sLetsels;
        String sTmpLetselsDate, sTmpLetselsDescr, sTmpLetselsBI;
        sLetsels = "";

        while (sTmpLetsels.toLowerCase().indexOf("<tr>") > -1) {
            sTmpLetselsDate = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("<td>") + 4, sTmpLetsels.toLowerCase().indexOf("</td>"));
            sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("</td>") + 11);
            sTmpLetselsDescr = sTmpLetsels.substring(0, sTmpLetsels.toLowerCase().indexOf("</td>"));
            sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("</td>") + 11);
            sTmpLetselsBI = sTmpLetsels.substring(0, sTmpLetsels.toLowerCase().indexOf("</td>"));
            sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("</tr>") + 5);
            sLetsels += "rowLetsels" + iTotal + "=" + sTmpLetselsDate + "£" + sTmpLetselsDescr + "£" + sTmpLetselsBI + "$";
            sDivLetsels += addLetsel(iTotal, sTmpLetselsDate, sTmpLetselsDescr, sTmpLetselsBI, sWebLanguage);
            iTotal++;
        }
    } else if (sLetsels.indexOf("£") > -1) {
        String sTmpLetsels = sLetsels;
        String sTmpLetselsDate, sTmpLetselsDescr, sTmpLetselsBI;
        sLetsels = "";

        while (sTmpLetsels.toLowerCase().indexOf("$") > -1) {
            sTmpLetselsDate = "";
            sTmpLetselsBI = "";
            sTmpLetselsDescr = "";

            if (sTmpLetsels.toLowerCase().indexOf("£") > -1) {
                sTmpLetselsDate = sTmpLetsels.substring(0, sTmpLetsels.toLowerCase().indexOf("£"));
                sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("£") + 1);
            }
            if (sTmpLetsels.toLowerCase().indexOf("£") > -1) {
                sTmpLetselsDescr = sTmpLetsels.substring(0, sTmpLetsels.toLowerCase().indexOf("£"));
                sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("£") + 1);
            }
            if (sTmpLetsels.toLowerCase().indexOf("$") > -1) {
                sTmpLetselsBI = sTmpLetsels.substring(0, sTmpLetsels.toLowerCase().indexOf("$"));
                sTmpLetsels = sTmpLetsels.substring(sTmpLetsels.toLowerCase().indexOf("$") + 1);
            }

            sLetsels += "rowLetsels" + iTotal + "=" + sTmpLetselsDate + "£" + sTmpLetselsDescr + "£" + sTmpLetselsBI + "$";
            sDivLetsels += addLetsel(iTotal, sTmpLetselsDate, sTmpLetselsDescr, sTmpLetselsBI, sWebLanguage);
            iTotal++;
        }
    } else if (sLetsels.length() > 0) {
        String sTmpLetsels = sLetsels;
        sLetsels += "rowLetsels" + iTotal + "£" + sTmpLetsels + "£$";
        sDivLetsels += addLetsel(iTotal, "", sTmpLetsels, "", sWebLanguage);
        iTotal++;
    }

%>

<table class="list" width="100%" border="0" cellspacing="1">
    <%-- COMMENT --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);" class="text" name="PersoonlijkComment" rows="2" cols="75"><%=sComment%></textarea>
            <%-- hidden fields --%>
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT1" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT2" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT3" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT4" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT5" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT6" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_PERSONAL_COMMENT7" property="itemId"/>]>.value">
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="0" cellpadding="0" class="list">
                <%-- MEDICAL ANTECEDENTS --%>
                <tr class="admin">
                    <td colspan="2"><%=getTran("Web.Occup","Medical_Antecedents",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" cellspacing="1" id="tblChirurgie">
                            <tr>
                                <td class="admin" width="36">&nbsp;</td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date-begin",sWebLanguage)%></td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date-end",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                                <td class="admin">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="admin2"></td>
                                <td class="admin2"><%=writeDateField("ChirurgieDateBegin", "transactionForm","",sWebLanguage)%></td>
                                <td class="admin2"><%=writeDateField("ChirurgieDateEnd", "transactionForm","",sWebLanguage)%></td>
                                <td class="admin2"><input type="text" class="text" name="ChirurgieDescription" size="40" onblur="limitLength(this);"></td>
                                <td class="admin2">
                                    <input type="button" class="button" name="ButtonAddChirurgie" onclick="addChirurgie()" value="<%=getTran("Web","add",sWebLanguage)%>">
                                    <input type="button" class="button" name="ButtonUpdateChirurgie" onclick="updateChirurgie()" value="<%=getTran("Web","edit",sWebLanguage)%>">
                                </td>
                            </tr>
                            <%=sDivChirurgie%>
                        </table>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN1" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN2" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN3" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN4" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_MEDISCHE_ANTECEDENTEN5" property="itemId"/>]>.value"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="0" cellpadding="0" class="list">
    <%-- HEELKUNDIGE ANTECEDENTEN --%>
                <tr class="admin">
                    <td colspan="2"><%=getTran("Web.Occup","Heelkundige_antecedenten",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" cellspacing="1" id="tblHeelkunde">
                            <tr>
                                <td class="admin" width="36">&nbsp;</td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date-begin",sWebLanguage)%></td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date-end",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                                <td class="admin">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="admin2"></td>
                                <td class="admin2"><%=writeDateField("HeelkundeDateBegin", "transactionForm","",sWebLanguage)%></td>
                                <td class="admin2"><%=writeDateField("HeelkundeDateEnd", "transactionForm","",sWebLanguage)%></td>
                                <td class="admin2"><input type="text" class="text" name="HeelkundeDescription" size="40" onblur="limitLength(this);"></td>
                                <td class="admin2">
                                    <input type="button" class="button" name="ButtonAddHeelkunde" onclick="addHeelkunde()" value="<%=getTran("Web","add",sWebLanguage)%>">
                                    <input type="button" class="button" name="ButtonUpdateHeelkunde" onclick="updateHeelkunde()" value="<%=getTran("Web","edit",sWebLanguage)%>">
                                </td>
                            </tr>
                            <%=sDivHeelkunde%>
                        </table>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE1" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE2" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE3" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE4" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_HEELKUNDE5" property="itemId"/>]>.value"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2">
            <table width="100%" cellspacing="0" cellpadding="0" class="list">
    <%-- LETSELS --%>
                <tr class="admin">
                    <td colspan="2"><%=getTran("Web.Occup","Lesions_with_%_PI",sWebLanguage)%></td>
                </tr>
                <tr>
                    <td colspan="2">
                        <table width="100%" cellspacing="1" id="tblLetsels">
                            <tr>
                                <td class="admin" width="36">&nbsp;</td>
                                <td class="admin" width="150"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                                <td class="admin" width="250"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                                <td class="admin" width="70">%<%=getTran("Web.Occup","PI",sWebLanguage)%></td>
                                <td class="admin">&nbsp;</td>
                            </tr>
                            <tr>
                                <td class="admin2"></td>
                                <td class="admin2"><%=writeDateField("LetselsDate", "transactionForm","",sWebLanguage)%></td>
                                <td class="admin2"><input type="text" class="text" name="LetselsDescription" size="40" onblur="limitLength(this);"></td>
                                <td class="admin2"><input type="text" name="LetselsBI" class="text" size="5" onblur="if(!isNumberLimited(this,0,100)){alert('<%=getTran("Web.Occup","out-of-bounds-value",sWebLanguage)%>');}"></td>
                                <td class="admin2">
                                    <input type="button" class="button" name="ButtonAddLetsels" onclick="addLetsels()" value="<%=getTran("Web","add",sWebLanguage)%>">
                                    <input type="button" class="button" name="ButtonUpdateLetsels" onclick="updateLetsels()" value="<%=getTran("Web","edit",sWebLanguage)%>">
                                </td>
                            </tr>
                            <%=sDivLetsels%>
                        </table>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS1" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS2" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS3" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS4" property="itemId"/>]>.value"/>
                        <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_LETSELS5" property="itemId"/>]>.value"/>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<script>
var iIndexPersoonlijk = <%=iTotal%>;
var sChirurgie = "<%=sChirurgie%>";
var sLetsels = "<%=sLetsels%>";
var sHeelkunde = "<%=sHeelkunde%>";

var editChirurgieRowid = "";
var editHeelkundeRowid = "";
var editLetselsRowid = "";

// disable update buttons
document.getElementById("transactionForm").ButtonUpdateChirurgie.disabled = true;
document.getElementById("transactionForm").ButtonUpdateHeelkunde.disabled = true;
document.getElementById("transactionForm").ButtonUpdateLetsels.disabled = true;


function addChirurgie(){
  if(isAtLeastOneChirurgieFieldFilled()){
    var beginDate = document.getElementById("transactionForm").ChirurgieDateBegin.value;
    var endDate   = document.getElementById("transactionForm").ChirurgieDateEnd.value;

    if((beginDate!="" && endDate!="") && !before(beginDate,endDate)){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=Web.Occup&labelID=endMustComeAfterBegin";
      var modalitiesIE = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      if(window.showModalDialog){
          window.showModalDialog(popupUrl,'',modalitiesIE);
      }else{
          window.confirm("<%=getTran("Web.occup","endMustComeAfterBegin",sWebLanguage)%>");
      }
      document.getElementById("transactionForm").ChirurgieDateEnd.select();
      return false;
    }
    else{
      iIndexPersoonlijk ++;

      sChirurgie+="rowChirurgie"+iIndexPersoonlijk+"="+document.getElementById("transactionForm").ChirurgieDateBegin.value+"£"+document.getElementById("transactionForm").ChirurgieDateEnd.value+"£"+document.getElementById("transactionForm").ChirurgieDescription.value+"$";

      var tr = tblChirurgie.insertRow(tblChirurgie.rows.length);
      tr.id = "rowChirurgie"+iIndexPersoonlijk;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='#' onclick='deleteChirurgie(rowChirurgie"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                    +"<a href='#' onclick='editChirurgie(rowChirurgie"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").ChirurgieDateBegin.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").ChirurgieDateEnd.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").ChirurgieDescription.value;
      tr.appendChild(td);

      // reset
      document.getElementById("transactionForm").ButtonUpdateChirurgie.disabled = true;
      clearChirurgieFields();
    }
  }
}

function isAtLeastOneChirurgieFieldFilled(){
  if(document.getElementById("transactionForm").ChirurgieDateBegin.value != "") return true;
  if(document.getElementById("transactionForm").ChirurgieDateEnd.value != "") return true;
  if(document.getElementById("transactionForm").ChirurgieDescription.value != "") return true;
  return false;
}

function editChirurgie(rowid){
  var row = getRowFromArrayString(sChirurgie,rowid.id);

  document.getElementById("transactionForm").ChirurgieDateBegin.value = getCelFromRowString(row,0);
  document.getElementById("transactionForm").ChirurgieDateEnd.value = getCelFromRowString(row,1);
  document.getElementById("transactionForm").ChirurgieDescription.value = getCelFromRowString(row,2);

  editChirurgieRowid = rowid;
  document.getElementById("transactionForm").ButtonUpdateChirurgie.disabled = false;
}

function updateChirurgie(){
  if(isAtLeastOneChirurgieFieldFilled()){
    // update arrayString
    newRow = editChirurgieRowid.id+"="
             +document.getElementById("transactionForm").ChirurgieDateBegin.value+"£"
             +document.getElementById("transactionForm").ChirurgieDateEnd.value+"£"
             +document.getElementById("transactionForm").ChirurgieDescription.value;

    sChirurgie = replaceRowInArrayString(sChirurgie,newRow,editChirurgieRowid.id);

    // update table object
    var row = tblChirurgie.rows[editChirurgieRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='#' onclick='deleteChirurgie("+editChirurgieRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='#' onclick='editChirurgie("+editChirurgieRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").ChirurgieDateBegin.value;
    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").ChirurgieDateEnd.value;
    row.cells[3].innerHTML = "&nbsp;"+document.getElementById("transactionForm").ChirurgieDescription.value;

    // reset
    clearChirurgieFields();
    document.getElementById("transactionForm").ButtonUpdateChirurgie.disabled = true;
  }
}

function deleteChirurgie(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sChirurgie = deleteRowFromArrayString(sChirurgie,rowid.id);
    tblChirurgie.deleteRow(rowid.rowIndex);
    clearChirurgieFields();
  }
}

function clearChirurgieFields(){
  document.getElementById("transactionForm").ChirurgieDateBegin.value = "";
  document.getElementById("transactionForm").ChirurgieDateEnd.value = "";
  document.getElementById("transactionForm").ChirurgieDescription.value = "";
}


function addHeelkunde(){
  if(isAtLeastOneHeelkundeFieldFilled()){
    var beginDate = document.getElementById("transactionForm").HeelkundeDateBegin.value;
    var endDate   = document.getElementById("transactionForm").HeelkundeDateEnd.value;

    if((beginDate!="" && endDate!="") && !before(beginDate,endDate)){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=Web.Occup&labelID=endMustComeAfterBegin";
      var modalitiesIE = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

      if(window.showModalDialog){
          window.showModalDialog(popupUrl,'',modalitiesIE);
      }else{
          window.confirm("<%=getTran("Web.Occup","endMustComeAfterBegin",sWebLanguage)%>");
      }
      document.getElementById("transactionForm").HeelkundeDateEnd.select();
      return false;
    }
    else{
      iIndexPersoonlijk ++;

      sHeelkunde+="rowHeelkunde"+iIndexPersoonlijk+"="+document.getElementById("transactionForm").HeelkundeDateBegin.value+"£"+document.getElementById("transactionForm").HeelkundeDateEnd.value+"£"+document.getElementById("transactionForm").HeelkundeDescription.value+"$";
      var tr = tblHeelkunde.insertRow(tblHeelkunde.rows.length);
      tr.id = "rowHeelkunde"+iIndexPersoonlijk;

      var td = tr.insertCell(0);
      td.innerHTML =  "<a href='#' onclick='deleteHeelkunde(rowHeelkunde"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                     +"<a href='#' onclick='editHeelkunde(rowHeelkunde"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").HeelkundeDateBegin.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").HeelkundeDateEnd.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").HeelkundeDescription.value;
      tr.appendChild(td);

      // reset
      clearHeelkundeFields();
      document.getElementById("transactionForm").ButtonUpdateHeelkunde.disabled = true;
    }
  }
}

function isAtLeastOneHeelkundeFieldFilled(){
  if(document.getElementById("transactionForm").HeelkundeDateBegin.value != "") return true;
  if(document.getElementById("transactionForm").HeelkundeDateEnd.value != "") return true;
  if(document.getElementById("transactionForm").HeelkundeDescription.value != "") return true;
  return false;
}

function deleteHeelkunde(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sHeelkunde = deleteRowFromArrayString(sHeelkunde,rowid.id);
    tblHeelkunde.deleteRow(rowid.rowIndex);
    clearHeelkundeFields();
  }
}

function editHeelkunde(rowid){
  var row = getRowFromArrayString(sHeelkunde,rowid.id);

  document.getElementById("transactionForm").HeelkundeDateBegin.value = getCelFromRowString(row,0);
  document.getElementById("transactionForm").HeelkundeDateEnd.value = getCelFromRowString(row,1);
  document.getElementById("transactionForm").HeelkundeDescription.value = getCelFromRowString(row,2);

  editHeelkundeRowid = rowid;
  document.getElementById("transactionForm").ButtonUpdateHeelkunde.disabled = false;
}

function updateHeelkunde(){
  if(isAtLeastOneHeelkundeFieldFilled()){
    // update arrayString
    newRow = editHeelkundeRowid.id+"="
             +document.getElementById("transactionForm").HeelkundeDateBegin.value+"£"
             +document.getElementById("transactionForm").HeelkundeDateEnd.value+"£"
             +document.getElementById("transactionForm").HeelkundeDescription.value;

    sHeelkunde = replaceRowInArrayString(sHeelkunde,newRow,editHeelkundeRowid.id);

    // update table object
    var row = tblHeelkunde.rows[editHeelkundeRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='#' onclick='deleteHeelkunde("+editHeelkundeRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='#' onclick='editHeelkunde("+editHeelkundeRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").HeelkundeDateBegin.value;
    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").HeelkundeDateEnd.value;
    row.cells[3].innerHTML = "&nbsp;"+document.getElementById("transactionForm").HeelkundeDescription.value;

    // reset
    clearHeelkundeFields();
    document.getElementById("transactionForm").ButtonUpdateHeelkunde.disabled = true;
  }
}

function clearHeelkundeFields(){
  document.getElementById("transactionForm").HeelkundeDateBegin.value = "";
  document.getElementById("transactionForm").HeelkundeDateEnd.value = "";
  document.getElementById("transactionForm").HeelkundeDescription.value = "";
}


function addLetsels(){
  if(isAtLeastOneLetselsFieldFilled()){
    iIndexPersoonlijk ++;

    sLetsels+="rowLetsels"+iIndexPersoonlijk+"="+document.getElementById("transactionForm").LetselsDate.value+"£"+document.getElementById("transactionForm").LetselsDescription.value+"£"+document.getElementById("transactionForm").LetselsBI.value+"$";

    var sBI = formatBI(document.getElementById("transactionForm").LetselsBI.value);

    var tr = tblLetsels.insertRow(tblLetsels.rows.length);
    tr.id = "rowLetsels"+iIndexPersoonlijk;

    var td = tr.insertCell(0);
    td.innerHTML =  "<a href='#' onclick='deleteLetsels(rowLetsels"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                   +"<a href='#' onclick='editLetsels(rowLetsels"+iIndexPersoonlijk+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML =  "&nbsp;"+document.getElementById("transactionForm").LetselsDate.value;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+document.getElementById("transactionForm").LetselsDescription.value;
    tr.appendChild(td);

    td = tr.insertCell(3);
    td.innerHTML = "&nbsp;"+sBI;
    tr.appendChild(td);

    // reset
    clearLetselsFields();
    document.getElementById("transactionForm").ButtonUpdateLetsels.disabled = true;
  }
}

function isAtLeastOneLetselsFieldFilled(){
  if(document.getElementById("transactionForm").LetselsDate.value != "") return true;
  if(document.getElementById("transactionForm").LetselsDescription.value != "") return true;
  if(document.getElementById("transactionForm").LetselsBI.value != "") return true;
  return false;
}

function deleteLetsels(rowid){
  if(yesnoDialog("Web","areYouSureToDelete")){
    sLetsels = deleteRowFromArrayString(sLetsels,rowid.id);
    tblLetsels.deleteRow(rowid.rowIndex);
    clearLetselsFields();
  }
}

function editLetsels(rowid){
  var row = getRowFromArrayString(sLetsels,rowid.id);

  document.getElementById("transactionForm").LetselsDate.value = getCelFromRowString(row,0);
  document.getElementById("transactionForm").LetselsDescription.value = getCelFromRowString(row,1);
  document.getElementById("transactionForm").LetselsBI.value = getCelFromRowString(row,2);

  editLetselsRowid = rowid;
  document.getElementById("transactionForm").ButtonUpdateLetsels.disabled = false;
}

function updateLetsels(){
  if(isAtLeastOneLetselsFieldFilled()){
    // update arrayString
    newRow = editLetselsRowid.id+"="
             +document.getElementById("transactionForm").LetselsDate.value+"£"
             +document.getElementById("transactionForm").LetselsDescription.value+"£"
             +document.getElementById("transactionForm").LetselsBI.value;

    sLetsels = replaceRowInArrayString(sLetsels,newRow,editLetselsRowid.id);

    // update table object
    var sBI = formatBI(document.getElementById("transactionForm").LetselsBI.value);

    var row = tblLetsels.rows[editLetselsRowid.rowIndex];
    row.cells[0].innerHTML = "<a href='#' onclick='deleteLetsels("+editLetselsRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='#' onclick='editLetsels("+editLetselsRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells[1].innerHTML = "&nbsp;"+document.getElementById("transactionForm").LetselsDate.value;
    row.cells[2].innerHTML = "&nbsp;"+document.getElementById("transactionForm").LetselsDescription.value;
    row.cells[3].innerHTML = "&nbsp;"+sBI;

    // reset
    clearLetselsFields();
    document.getElementById("transactionForm").ButtonUpdateLetsels.disabled = true;
  }
}

function clearLetselsFields(){
  document.getElementById("transactionForm").LetselsDate.value = "";
  document.getElementById("transactionForm").LetselsDescription.value = "";
  document.getElementById("transactionForm").LetselsBI.value = "";
}

function formatBI(sBI){
  if(sBI.length>0){
    if(sBI.indexOf("%")<0){
      sBI = sBI+"%";
    }
  }
  return sBI;
}
</script>

