<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%!
    private String addBeroep(int iTotal, String sTmpBeroepDateBegin, String sTmpBeroepDateEnd, String sTmpBeroepDescr,
                             String sTmpBeroepPA, String sWebLanguage){
        StringBuffer sOut = new StringBuffer();
        sOut.append("<tr id='rowBeroeps"+iTotal+"'>")
            .append("<td width='36'>")
             .append("<a href='javascript:deleteBeroep(rowBeroeps"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></a> ")
             .append("<a href='javascript:editBeroep(rowBeroeps"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)+"' border='0'></a>")
            .append("</td>")
            .append("<td>&nbsp;"+sTmpBeroepDateBegin+"</td>")
            .append("<td>&nbsp;"+sTmpBeroepDateEnd+"</td>")
            .append("<td>&nbsp;"+sTmpBeroepDescr+"</td>");

        // yes/no
        sOut.append("<td>&nbsp;");
        if(sTmpBeroepPA.equalsIgnoreCase("Y")){
            sOut.append(getTran("Web","yes",sWebLanguage));
        }
        else if(sTmpBeroepPA.equalsIgnoreCase("N")){
            sOut.append(getTran("Web","no",sWebLanguage));
        }
        sOut.append("</td>")
            .append("</tr>");

        return sOut.toString();
    }

    private String addAO(int iTotal, String sTmpAODate, String sTmpAODescr, String sTmpAOBI, String sWebLanguage){
        return "<tr id='rowAO"+iTotal+"'>"
               +"<td width='36'>"
                +"<a href='javascript:deleteArbeidsOngeval(rowAO"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></a> "
                +"<a href='javascript:editArbeidsOngeval(rowAO"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)+"' border='0'></a>"
                +"</td>"
                +"<td>&nbsp;"+sTmpAODate+"</td>"
                +"<td>&nbsp;"+sTmpAODescr+"</td>"
                +"<td>&nbsp;"+sTmpAOBI+(sTmpAOBI.replaceAll("%","").equals("")?"":"%")+"</td>"
              +"</tr>";
    }

    private String addBZ(int iTotal, String sTmpBZDate, String sTmpBZDescr, String sTmpBZBI, String sTmpBZErkenning, String sWebLanguage){
        StringBuffer sOut = new StringBuffer();
        sOut.append("<tr id='rowBZ"+iTotal+"'>")
            .append("<td width='36'>")
             .append("<a href='javascript:deleteBZ(rowBZ"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></a> ")
             .append("<a href='javascript:editBZ(rowBZ"+iTotal+")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)+"' border='0'></a>")
            .append("</td>")
            .append("<td>&nbsp;"+sTmpBZDate+"</td>")
            .append("<td>&nbsp;"+sTmpBZDescr+"</td>")
            .append("<td>&nbsp;"+sTmpBZBI+(sTmpBZBI.equals("")?"":"%")+"</td>");

        // yes/no
        sOut.append("<td>&nbsp;");
        if(sTmpBZErkenning.equalsIgnoreCase("Y")){
            sOut.append(getTran("Web","yes",sWebLanguage));
        }
        else if(sTmpBZErkenning.equalsIgnoreCase("N")){
            sOut.append(getTran("Web","no",sWebLanguage));
        }
        sOut.append("</td>")
            .append("</tr>");

        return sOut.toString();
    }
%>

<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<%
    String sBeroeps = "", sArbeidsOngevallen = "", sBeroepsziekten = "", sDivBeroeps = "", sDivAO = "", sDivBZ = "";
    int iTotal = 1;
    if (transaction!=null){

        TransactionVO tran = (TransactionVO) transaction;
        if (tran!=null){
            sBeroeps = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE");
            sArbeidsOngevallen = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN");
            sBeroepsziekten = getItemType(tran.getItems(),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN");
        }
        if (tran.getTransactionId().intValue()<0){
            boolean bBeroepsziekten = (sBeroepsziekten.equalsIgnoreCase(""));
            boolean bArbeidsOngevallen = (sArbeidsOngevallen.equalsIgnoreCase(""));
            boolean bBeroeps = (sBeroeps.equalsIgnoreCase(""));
            String sType, sValue;
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            tran = sessionContainerWO.getLastTransaction(tran.getTransactionType());
            if (tran!=null){
                String sSelect = " SELECT type, "+MedwanQuery.getInstance().getConfigString("valueColumn")+"  FROM Items WHERE transactionId = ? AND serverid = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                PreparedStatement ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,tran.getTransactionId().intValue());
                ps.setInt(2,tran.getServerId());
                ResultSet Occuprs = ps.executeQuery();
                while (Occuprs.next()){
                    sType = checkString(Occuprs.getString("type"));
                    sValue = checkString(Occuprs.getString("value"));
                    sValue = replace(sValue,"\n","");
                    sValue = replace(sValue,"\r","");
                    
                    //beroeps
                    if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE")){
                        if (bBeroeps) {sBeroeps += sValue;}
                    }
                    else if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN")){
                        if (bArbeidsOngevallen) {sArbeidsOngevallen += sValue;}
                    }
                    else if (sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN")){
                        if (bBeroepsziekten) {sBeroepsziekten += sValue;}
                    }
                }

                if(Occuprs!=null) Occuprs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
        }
    }
//Beroeps
    if ((sBeroeps.toLowerCase().startsWith("<tr>"))||(sBeroeps.toLowerCase().startsWith("<tbody>"))){
        String sTmpBeroeps = sBeroeps;
        String sTmpBeroepDate, sTmpBeroepDescr;
        sBeroeps = "";
        while (sTmpBeroeps.toLowerCase().indexOf("<tr>")>-1) {
            try {
                sTmpBeroepDate = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("<td>")+4,sTmpBeroeps.toLowerCase().indexOf("</td>"));
                sTmpBeroeps = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("</td>")+11);
                sTmpBeroepDescr = sTmpBeroeps.substring(0,sTmpBeroeps.toLowerCase().indexOf("</td>"));
                sTmpBeroeps = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("</tr>")+5);
                sBeroeps += "rowBeroeps"+iTotal+"="+sTmpBeroepDate+"££"+sTmpBeroepDescr+"£$";
                sDivBeroeps += addBeroep(iTotal,sTmpBeroepDate,"",sTmpBeroepDescr,"",sWebLanguage);
                iTotal++;
            }
            catch (Exception e){
                // nothing
            }
        }
    }
    else if (sBeroeps.indexOf("£")>-1){
        String sTmpBeroeps = sBeroeps;
        String sTmpBeroepDateBegin, sTmpBeroepDateEnd, sTmpBeroepDescr, sTmpBeroepPA;
        sBeroeps = "";
        while (sTmpBeroeps.toLowerCase().indexOf("$")>-1) {
            try {
                sTmpBeroepDateBegin = "";
                sTmpBeroepDateEnd = "";
                sTmpBeroepDescr = "";
                sTmpBeroepPA = "";

                if (sTmpBeroeps.toLowerCase().indexOf("£")>-1){
                    sTmpBeroepDateBegin = sTmpBeroeps.substring(0,sTmpBeroeps.toLowerCase().indexOf("£"));
                    sTmpBeroepDateBegin = ScreenHelper.convertDate(sTmpBeroepDateBegin);
                    sTmpBeroeps = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("£")+1);
                }
                if (sTmpBeroeps.toLowerCase().indexOf("£")>-1){
                    sTmpBeroepDateEnd = sTmpBeroeps.substring(0,sTmpBeroeps.toLowerCase().indexOf("£"));
                    sTmpBeroeps = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("£")+1);
                }
                if (sTmpBeroeps.toLowerCase().indexOf("£")>-1){
                    sTmpBeroepDescr = sTmpBeroeps.substring(0,sTmpBeroeps.toLowerCase().indexOf("£"));
                    sTmpBeroeps = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("£")+1);
                }
                if (sTmpBeroeps.toLowerCase().indexOf("$")>-1){
                    sTmpBeroepPA = sTmpBeroeps.substring(0,sTmpBeroeps.toLowerCase().indexOf("$"));
                    sTmpBeroeps = sTmpBeroeps.substring(sTmpBeroeps.toLowerCase().indexOf("$")+1);
                }

                sBeroeps += "rowBeroeps"+iTotal+"="+sTmpBeroepDateBegin+"£"+sTmpBeroepDateEnd+"£"+sTmpBeroepDescr+"£"+sTmpBeroepPA+"$";
                sDivBeroeps += addBeroep(iTotal,sTmpBeroepDateBegin,sTmpBeroepDateEnd,sTmpBeroepDescr,sTmpBeroepPA,sWebLanguage);
                iTotal++;
            }
            catch (Exception e){
                // nothing
            }
        }
    }
    else if (sBeroeps.length() > 0){
        String sTmpBeroeps = sBeroeps;
        sBeroeps = "rowBeroeps"+iTotal+"=£££"+sTmpBeroeps+"$";
        sDivBeroeps += addBeroep(iTotal,"","",sTmpBeroeps,"",sWebLanguage);
        iTotal++;
    }

//AO
    if ((sArbeidsOngevallen.toLowerCase().startsWith("<tr>"))||(sArbeidsOngevallen.toLowerCase().startsWith("<tbody>"))){
        String sTmpAO = sArbeidsOngevallen;
        String sTmpAODate, sTmpAODescr, sTmpAOBI;
        sArbeidsOngevallen = "";
        while (sTmpAO.toLowerCase().indexOf("<tr>")>-1) {
            try{
                sTmpAODate = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("<td>")+4,sTmpAO.toLowerCase().indexOf("</td>"));
                sTmpAO = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("</td>")+11);
                sTmpAODescr = sTmpAO.substring(0,sTmpAO.toLowerCase().indexOf("</td>"));
                sTmpAO = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("</td>")+11);
                sTmpAOBI = sTmpAO.substring(0,sTmpAO.toLowerCase().indexOf("</td>"));
                sTmpAO = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("</tr>")+5);
                sArbeidsOngevallen += "rowAO"+iTotal+"="+sTmpAODate+"£"+sTmpAODescr+"£"+sTmpAOBI+"$";
                sDivAO += addAO(iTotal, sTmpAODate, sTmpAODescr, sTmpAOBI, sWebLanguage);
                iTotal++;
            }
            catch (Exception e){}
        }
    }
    else if (sArbeidsOngevallen.indexOf("£")>-1){
        String sTmpAO = sArbeidsOngevallen;
        String sTmpAODate, sTmpAODescr, sTmpAOBI;
        sArbeidsOngevallen = "";

        while (sTmpAO.toLowerCase().indexOf("$")>-1) {
            try {
                sTmpAODate = "";
                sTmpAODescr = "";
                sTmpAOBI = "";

                if (sTmpAO.toLowerCase().indexOf("£")>-1){
                    sTmpAODate = sTmpAO.substring(0,sTmpAO.toLowerCase().indexOf("£"));
                    sTmpAO = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("£")+1);
                }
                if (sTmpAO.toLowerCase().indexOf("£")>-1){
                    sTmpAODescr = sTmpAO.substring(0,sTmpAO.toLowerCase().indexOf("£"));
                    sTmpAO = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("£")+1);
                }
                if (sTmpAO.toLowerCase().indexOf("$")>-1){
                    sTmpAOBI = sTmpAO.substring(0,sTmpAO.toLowerCase().indexOf("$"));
                    sTmpAO = sTmpAO.substring(sTmpAO.toLowerCase().indexOf("$")+1);
                }
                sArbeidsOngevallen += "rowAO"+iTotal+"="+sTmpAODate+"£"+sTmpAODescr+"£"+sTmpAOBI+"$";
                sDivAO += addAO(iTotal, sTmpAODate, sTmpAODescr, sTmpAOBI, sWebLanguage);
                iTotal++;
            }
            catch (Exception e){}
        }
    }
    else if (sArbeidsOngevallen.length() > 0){
        String sTmpAO = sArbeidsOngevallen;
        sArbeidsOngevallen = "rowAO"+iTotal+"=£"+sTmpAO+"£$";
        sDivAO += addAO(iTotal, "", sTmpAO, "", sWebLanguage);
        iTotal++;
    }
//BZ
    if ((sBeroepsziekten.toLowerCase().startsWith("<tr>"))||(sBeroepsziekten.toLowerCase().startsWith("<tbody>"))){
        String sTmpBZ = sBeroepsziekten;
        String sTmpBZDate, sTmpBZDescr, sTmpBZBI, sTmpBZErkenning;
        sBeroepsziekten = "";
        while (sTmpBZ.toLowerCase().indexOf("<tr>")>-1) {
            try {
                sTmpBZDate = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("<td>")+4,sTmpBZ.toLowerCase().indexOf("</td>"));
                sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("</td>")+11);
                sTmpBZDescr = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("</td>"));
                sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("</td>")+11);
                sTmpBZBI = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("</td>"));
                sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("</td>")+11);
                sTmpBZErkenning = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("</td>"));
                sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("</tr>")+5);
                sBeroepsziekten += "rowBZ"+iTotal+"="+sTmpBZDate+"£"+sTmpBZDescr+"£"+sTmpBZBI+"£"+sTmpBZErkenning+"$";
                sDivBZ += addBZ(iTotal, sTmpBZDate, sTmpBZDescr, sTmpBZBI, sTmpBZErkenning, sWebLanguage);
                iTotal++;
            }
            catch (Exception e){
                // nothing
            }
        }
    }
    else if (sBeroepsziekten.indexOf("£")>-1){
        String sTmpBZ = sBeroepsziekten;
        String sTmpBZDate, sTmpBZDescr, sTmpBZBI, sTmpBZErkenning;
        sBeroepsziekten = "";
        while (sTmpBZ.toLowerCase().indexOf("$")>-1) {
            try {
                sTmpBZDate = "";
                sTmpBZDescr = "";
                sTmpBZBI = "";
                sTmpBZErkenning = "";

                if (sTmpBZ.toLowerCase().indexOf("£")>-1){
                    sTmpBZDate = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("£"));
                    sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("£")+1);
                }
                if (sTmpBZ.toLowerCase().indexOf("£")>-1){
                    sTmpBZDescr = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("£"));
                    sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("£")+1);
                }
                if (sTmpBZ.toLowerCase().indexOf("£")>-1){
                    sTmpBZBI = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("£"));
                    sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("£")+1);
                }
                if (sTmpBZ.toLowerCase().indexOf("$")>-1){
                    sTmpBZErkenning = sTmpBZ.substring(0,sTmpBZ.toLowerCase().indexOf("$"));
                    sTmpBZ = sTmpBZ.substring(sTmpBZ.toLowerCase().indexOf("$")+1);
                }
                sBeroepsziekten += "rowBZ"+iTotal+"="+sTmpBZDate+"£"+sTmpBZDescr+"£"+sTmpBZBI+"£"+sTmpBZErkenning+"$";
                sDivBZ += addBZ(iTotal, sTmpBZDate, sTmpBZDescr, sTmpBZBI, sTmpBZErkenning, sWebLanguage);
                iTotal++;
            }
            catch (Exception e){
                // nothing
            }
        }
    }
    else if (sBeroepsziekten.length() > 0){
        String sTmpBZ = sBeroepsziekten;
        sBeroepsziekten += "rowBZ"+iTotal+"=£"+sTmpBZ+"££$";
        sDivBZ += addBZ(iTotal, "", sTmpBZ, "", "", sWebLanguage);
        iTotal++;
    }

%>

<table class="list" width="100%" border="0" cellspacing="1">
    <%-- HISTORY --------------------------------------------------------------------------------%>
    <tr class="admin">
        <td><%=getTran("Web.Occup","HistoryWorkpost",sWebLanguage)%></td>
    </tr>
    <tr>
        <td>
            <table cellspacing="1" id="tblBeroeps" width="100%">
                <tr>
                    <td width="36" class="admin">&nbsp;</td>
                    <td width="150" class="admin"><%=getTran("Web.Occup","medwan.common.date-begin",sWebLanguage)%></td>
                    <td width="150" class="admin"><%=getTran("Web.Occup","medwan.common.date-end",sWebLanguage)%></td>
                    <td width="250" class="admin"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                    <td width="100" class="admin"><%=getTran("Web.Occup","medwan.occupational-medicine.ploegenarbeid",sWebLanguage)%></td>
                    <td class="admin">&nbsp;</td>
                </tr>
                <tr>
                    <td class="admin2">&nbsp;</td>
                    <td class="admin2"><%=writeDateField("BeroepsDateBegin", "transactionForm","",sWebLanguage)%></td>
                    <td class="admin2"><%=writeDateField("BeroepsDateEnd", "transactionForm","",sWebLanguage)%></td>
                    <td class="admin2"><input type="text" class="text" name="BeroepsDescription" size="40" onblur="limitLength(this);"></td>
                    <td class="admin2">
                        <select class="text" name="BeroepsPA">
                            <option/>
                            <option value="Y"><%=getTran("Web","Yes",sWebLanguage)%></option>
                            <option value="N"><%=getTran("Web","No",sWebLanguage)%></option>
                        </select>
                    </td>
                    <td class="admin2">
                        <input type="button" class="button" name="ButtonAddBeroep" onclick="addBeroep()" value="<%=getTranNoLink("Web","add",sWebLanguage)%>">
                        <input type="button" class="button" name="ButtonUpdateBeroep" onclick="updateBeroep()" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
                    </td>
                </tr>

                <%=sDivBeroeps%>
            </table>

            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE1" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE2" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE3" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE4" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSANAMNESE5" property="itemId"/>]>.value">
        </td>
    </tr>

    <%-- ONGEVALLEN -----------------------------------------------------------------------------%>
    <tr class="admin">
        <td><%=getTran("Web.Occup","medwan.healthrecord.work-accidents",sWebLanguage)%></td>
    </tr>
    <tr>
        <td>
            <table cellspacing="1" id="tblAO" width="100%">
                <tr>
                    <td width="36" class="admin">&nbsp;</td>
                    <td width="150" class="admin"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                    <td width="250" class="admin"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                    <td width="70" class="admin">%<%=getTran("Web.Occup","PI",sWebLanguage)%></td>
                    <td class="admin">&nbsp;</td>
                </tr>
                <tr>
                    <td class="admin2"></td>
                    <td class="admin2"><%=writeDateField("ArbeidsOngevallenDate", "transactionForm","",sWebLanguage)%></td>
                    <td class="admin2"><input type="text" class="text" name="ArbeidsOngevallenDescription" size="40" onblur="limitLength(this);"></td>
                    <td class="admin2"><input type="text" name="ArbeidsOngevallenBI" class="text" size="5" onblur="if(!isNumberLimited(this,0,100)){alertDialog('Web.Occup','out-of-bounds-value');}"></td>
                    <td class="admin2">
                        <input type="button" class="button" name="ButtonAddArbeidsOngeval" onclick="addArbeidsOngeval()" value="<%=getTranNoLink("Web","add",sWebLanguage)%>">
                        <input type="button" class="button" name="ButtonUpdateArbeidsOngeval" onclick="updateArbeidsOngeval()" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
                    </td>
                </tr>
                <%=sDivAO%>
            </table>

            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN1" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN2" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN3" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN4" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ARBEIDSONGEVALLEN5" property="itemId"/>]>.value">
        </td>
    </tr>

    <%-- ZIEKTEN -----------------------------------------------------------------------------------------------------%>
    <tr class="admin">
        <td><%=getTran("Web.Occup","medwan.occupational-medicine.manage-professional-diseases",sWebLanguage)%></td>
    </tr>
    <tr>
        <td>
            <table cellspacing="1" id="tblBZ" width="100%">
                <tr>
                    <td width="36" class="admin">&nbsp;</td>
                    <td width="150" class="admin"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                    <td width="250" class="admin"><%=getTran("Web.Occup","medwan.common.description",sWebLanguage)%></td>
                    <td width="70" class="admin">%<%=getTran("Web.Occup","PI",sWebLanguage)%></td>
                    <td width="100" class="admin"><%=getTran("Web.Occup","Recognized",sWebLanguage)%></td>
                    <td class="admin">&nbsp;</td>
                </tr>
                <tr>
                    <td class="admin2"></td>
                    <td class="admin2"><%=writeDateField("BeroepsziektenDate", "transactionForm","",sWebLanguage)%></td>
                    <td class="admin2"><input type="text" class="text" name="BeroepsziektenDescription" size="40" onblur="limitLength(this);"></td>
                    <td class="admin2"><input type="text" name="BeroepsziektenBI" class="text" size="5" onblur="if(!isNumberLimited(this,0,100)){alertDialog('Web.Occup','out-of-bounds-value');"></td>
                    <td class="admin2">
                        <select name="BeroepsziektenErkenning" class="text">
                            <option/>
                            <option value="Y"><%=getTran("Web","Yes",sWebLanguage)%></option>
                            <option value="N"><%=getTran("Web","No",sWebLanguage)%></option>
                        </select>
                    </td>
                    <td class="admin2">
                      <input type="button" class="button" name="ButtonAddBeroepsZiekten" onclick="addBZ()" value="<%=getTranNoLink("Web","add",sWebLanguage)%>">
                      <input type="button" class="button" name="ButtonUpdateBeroepsziekten" onclick="updateBZ()" value="<%=getTranNoLink("Web","edit",sWebLanguage)%>">
                    </td>
                </tr>
                <%=sDivBZ%>
            </table>

            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN1" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN2" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN3" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN4" property="itemId"/>]>.value">
            <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_BEROEPSZIEKTEN5" property="itemId"/>]>.value">
        </td>
    </tr>
</table>

<script>
var iIndexBeroeps = <%=iTotal%>;
var sBeroeps = "<%=sBeroeps%>";
var sAO = "<%=sArbeidsOngevallen%>";
var sBZ = "<%=sBeroepsziekten%>";

var editBeroepRowid = "";
var editBZRowid = "";
var editAORowid = "";

// disable update buttons
transactionForm.ButtonUpdateBeroepsziekten.disabled = true;
transactionForm.ButtonUpdateArbeidsOngeval.disabled = true;


function addBeroep(){
  if(isAtLeastOneBeroepsFieldFilled()){
    var beginDate = transactionForm.BeroepsDateBegin.value;
    var endDate   = transactionForm.BeroepsDateEnd.value;

    if((beginDate!="" && endDate!="") && !before(beginDate,endDate)){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=Web.Occup&labelID=endMustComeAfterBegin";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,'',modalities);
      transactionForm.BeroepsDateEnd.select();
      return false;
    }
    else{
      iIndexBeroeps ++;

      sBeroeps+="rowBeroeps"+iIndexBeroeps+"="+transactionForm.BeroepsDateBegin.value+"£"+transactionForm.BeroepsDateEnd.value+"£"+transactionForm.BeroepsDescription.value+"£"+transactionForm.BeroepsPA.value+"$";
      row = tblBeroeps.insertRow();
      row.id = "rowBeroeps"+iIndexBeroeps;

      row.insertCell();
      row.insertCell();
      row.insertCell();
      row.insertCell();
      row.insertCell();

      row.cells(0).innerHTML = "<a href='javascript:deleteBeroep(rowBeroeps"+iIndexBeroeps+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                              +"<a href='javascript:editBeroep(rowBeroeps"+iIndexBeroeps+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
      row.cells(1).innerHTML = "&nbsp;"+transactionForm.BeroepsDateBegin.value;
      row.cells(2).innerHTML = "&nbsp;"+transactionForm.BeroepsDateEnd.value;
      row.cells(3).innerHTML = "&nbsp;"+transactionForm.BeroepsDescription.value;

      if(transactionForm.BeroepsPA.value == "Y"){
        row.cells(4).innerHTML = "&nbsp;<%=getTran("Web","yes",sWebLanguage)%>";
      }
      else if(transactionForm.BeroepsPA.value == "N"){
        row.cells(4).innerHTML = "&nbsp;<%=getTran("Web","no",sWebLanguage)%>";
      }

      // reset
      clearBeroepsFields();
      transactionForm.ButtonUpdateBeroep.disabled = true;
    }
  }
}

function isAtLeastOneBeroepsFieldFilled(){
  if(transactionForm.BeroepsDateBegin.value != "") return true;
  if(transactionForm.BeroepsDateEnd.value != "") return true;
  if(transactionForm.BeroepsDescription.value != "") return true;
  if(transactionForm.BeroepsPA.value != "") return true;
  return false;
}

function deleteBeroep(rowid){
  if(yesnoDialog("web","areYouSureToDelete")){
    sBeroeps = deleteRowFromArrayString(sBeroeps,rowid.id);
    tblBeroeps.deleteRow(rowid.rowIndex);
    clearBeroepsFields();
  }
}

function editBeroep(rowid){
  var row = getRowFromArrayString(sBeroeps,rowid.id);

  transactionForm.BeroepsDateBegin.value = getCelFromRowString(row,0);
  transactionForm.BeroepsDateEnd.value = getCelFromRowString(row,1);
  transactionForm.BeroepsDescription.value = getCelFromRowString(row,2);
  transactionForm.BeroepsPA.value = getCelFromRowString(row,3);

  editBeroepRowid = rowid;
  transactionForm.ButtonUpdateBeroep.disabled = false;
}

function updateBeroep(){
  if(isAtLeastOneBeroepsFieldFilled()){
    // update arrayString
    newRow = editBeroepRowid.id+"="
             +transactionForm.BeroepsDateBegin.value+"£"
             +transactionForm.BeroepsDateEnd.value+"£"
             +transactionForm.BeroepsDescription.value+"£"
             +transactionForm.BeroepsPA.value+"$";

    sBeroeps = replaceRowInArrayString(sBeroeps,newRow,editBeroepRowid.id);

    // update table object
    row = tblBeroeps.rows[editBeroepRowid.rowIndex];
    row.cells(0).innerHTML = "<a href='javascript:deleteBeroep("+editBeroepRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
	                        +"<a href='javascript:editBeroep("+editBeroepRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells(1).innerHTML = "&nbsp;"+transactionForm.BeroepsDateBegin.value;
    row.cells(2).innerHTML = "&nbsp;"+transactionForm.BeroepsDateEnd.value;
    row.cells(3).innerHTML = "&nbsp;"+transactionForm.BeroepsDescription.value;
    row.cells(4).innerHTML = "&nbsp;"+transactionForm.BeroepsPA.value;

    // reset
    clearBeroepsFields();
    transactionForm.ButtonUpdateBeroep.disabled = true;
  }
}

function clearBeroepsFields(){
  transactionForm.BeroepsDateBegin.value = "";
  transactionForm.BeroepsDateEnd.value = "";
  transactionForm.BeroepsDescription.value = "";
  transactionForm.BeroepsPA.value = "";
}


function addArbeidsOngeval(){
  if(isAtLeastOneAOFieldFilled()){
    iIndexBeroeps ++;

    sAO+="rowAO"+iIndexBeroeps+"="+transactionForm.ArbeidsOngevallenDate.value+"£"+transactionForm.ArbeidsOngevallenDescription.value+"£"+transactionForm.ArbeidsOngevallenBI.value+"$";
    row = tblAO.insertRow();
    row.id = "rowAO"+iIndexBeroeps;

    row.insertCell();
    row.insertCell();
    row.insertCell();
    row.insertCell();

    sBI = formatBI(transactionForm.ArbeidsOngevallenBI.value);

	row.cells(0).innerHTML = "<a href='javascript:deleteArbeidsOngeval(rowAO"+iIndexBeroeps+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editArbeidsOngeval(rowAO"+iIndexBeroeps+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells(1).innerHTML = "&nbsp;"+transactionForm.ArbeidsOngevallenDate.value;
    row.cells(2).innerHTML = "&nbsp;"+transactionForm.ArbeidsOngevallenDescription.value;
    row.cells(3).innerHTML = "&nbsp;"+sBI;

    // reset
    clearArbeidsOngevalFields();
    transactionForm.ButtonUpdateArbeidsOngeval.disabled = true;
  }
}

function isAtLeastOneAOFieldFilled(){
  if(transactionForm.ArbeidsOngevallenDate.value != "") return true;
  if(transactionForm.ArbeidsOngevallenDescription.value != "") return true;
  if(transactionForm.ArbeidsOngevallenBI.value != "") return true;
  return false;
}

function deleteArbeidsOngeval(rowid){
  if(yesnoDialog("web","areYouSureToDelete")){
    sAO = deleteRowFromArrayString(sAO,rowid.id);
    tblAO.deleteRow(rowid.rowIndex);
    clearArbeidsOngevalFields();
  }
}

function editArbeidsOngeval(rowid){
  var row = getRowFromArrayString(sAO,rowid.id);

  transactionForm.ArbeidsOngevallenDate.value = getCelFromRowString(row,0);
  transactionForm.ArbeidsOngevallenDescription.value = getCelFromRowString(row,1);
  transactionForm.ArbeidsOngevallenBI.value = getCelFromRowString(row,2);

  editAORowid = rowid;
  transactionForm.ButtonUpdateArbeidsOngeval.disabled = false;
}

function updateArbeidsOngeval(){
  if(isAtLeastOneAOFieldFilled()){
    // update arrayString
    newRow = editAORowid.id+"="
             +transactionForm.ArbeidsOngevallenDate.value+"£"
             +transactionForm.ArbeidsOngevallenDescription.value+"£"
             +transactionForm.ArbeidsOngevallenBI.value+"$";

    sAO = replaceRowInArrayString(sAO,newRow,editAORowid.id);

    // update table object
    sBI = formatBI(transactionForm.ArbeidsOngevallenBI.value);

    row = tblAO.rows[editAORowid.rowIndex];
    row.cells(0).innerHTML = "<a href='javascript:deleteArbeidsOngeval("+editAORowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
                            +"<a href='javascript:editArbeidsOngeval("+editAORowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells(1).innerHTML = "&nbsp;"+transactionForm.ArbeidsOngevallenDate.value;
    row.cells(2).innerHTML = "&nbsp;"+transactionForm.ArbeidsOngevallenDescription.value;
    row.cells(3).innerHTML = "&nbsp;"+sBI;

    // reset
    clearArbeidsOngevalFields();
    transactionForm.ButtonUpdateArbeidsOngeval.disabled = true;
  }
}

function clearArbeidsOngevalFields(){
  transactionForm.ArbeidsOngevallenDate.value = "";
  transactionForm.ArbeidsOngevallenDescription.value = "";
  transactionForm.ArbeidsOngevallenBI.value = "";
}


function addBZ(){
  if(isAtLeastOneBZFieldFilled()){
    iIndexBeroeps ++;

    sBZ+= "rowBZ"+iIndexBeroeps+"="+transactionForm.BeroepsziektenDate.value+"£"+transactionForm.BeroepsziektenDescription.value+"£"+transactionForm.BeroepsziektenBI.value+"£"+transactionForm.BeroepsziektenErkenning.value+"$";
    row = tblBZ.insertRow();
    row.id = "rowBZ"+iIndexBeroeps;

    row.insertCell();
    row.insertCell();
    row.insertCell();
    row.insertCell();
    row.insertCell();
    row.insertCell();

    sBI = formatBI(transactionForm.BeroepsziektenBI.value);

    row.cells(0).innerHTML = "<a href='javascript:deleteBZ(rowBZ"+iIndexBeroeps+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
	                        +"<a href='javascript:editBZ(rowBZ"+iIndexBeroeps+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells(1).innerHTML = "&nbsp;"+transactionForm.BeroepsziektenDate.value;
    row.cells(2).innerHTML = "&nbsp;"+transactionForm.BeroepsziektenDescription.value;
    row.cells(3).innerHTML = "&nbsp;"+sBI;

    if(transactionForm.BeroepsziektenErkenning.value == "Y"){
      row.cells(4).innerHTML = "&nbsp;<%=getTran("Web","yes",sWebLanguage)%>";
    }
    else if(transactionForm.BeroepsziektenErkenning.value == "N"){
      row.cells(4).innerHTML = "&nbsp;<%=getTran("Web","no",sWebLanguage)%>";
    }

    // reset
    clearBZFields();
    transactionForm.ButtonUpdateBeroepsziekten.disabled = true;
  }
}

function isAtLeastOneBZFieldFilled(){
  if(transactionForm.BeroepsziektenDate.value != "") return true;
  if(transactionForm.BeroepsziektenDescription.value != "") return true;
  if(transactionForm.BeroepsziektenBI.value != "") return true;
  if(transactionForm.BeroepsziektenErkenning.value != "") return true;
  return false;
}

function deleteBZ(rowid){
  if(yesnoDialog("web","areYouSureToDelete")){
    sBZ = deleteRowFromArrayString(sBZ,rowid.id);
    tblBZ.deleteRow(rowid.rowIndex);
    clearBZFields();
  }
}

function editBZ(rowid){
  var row = getRowFromArrayString(sBZ,rowid.id);

  transactionForm.BeroepsziektenDate.value = getCelFromRowString(row,0);
  transactionForm.BeroepsziektenDescription.value = getCelFromRowString(row,1);
  transactionForm.BeroepsziektenBI.value = getCelFromRowString(row,2);
  transactionForm.BeroepsziektenErkenning.value = getCelFromRowString(row,3);

  editBZRowid = rowid;
  transactionForm.ButtonUpdateBeroepsziekten.disabled = false;
}

function updateBZ(){
  if(isAtLeastOneBZFieldFilled()){
    // update arrayString
    newRow = editBZRowid.id+"="
             +transactionForm.BeroepsziektenDate.value+"£"
             +transactionForm.BeroepsziektenDescription.value+"£"
             +transactionForm.BeroepsziektenBI.value+"£"
             +transactionForm.BeroepsziektenErkenning.value+"$";

    sBZ = replaceRowInArrayString(sBZ,newRow,editBZRowid.id);

    // update table object
    sBI = formatBI(transactionForm.BeroepsziektenBI.value);

    row = tblBZ.rows[editBZRowid.rowIndex];
    row.cells(0).innerHTML = "<a href='javascript:deleteBZ("+editBZRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a> "
	                        +"<a href='javascript:editBZ("+editBZRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("Web.Occup","medwan.common.edit",sWebLanguage)%>' border='0'></a>";
    row.cells(1).innerHTML = "&nbsp;"+transactionForm.BeroepsziektenDate.value;
    row.cells(2).innerHTML = "&nbsp;"+transactionForm.BeroepsziektenDescription.value;
    row.cells(3).innerHTML = "&nbsp;"+sBI;
    row.cells(4).innerHTML = "&nbsp;"+transactionForm.BeroepsziektenErkenning.value;

    // reset
    clearBZFields();
    transactionForm.ButtonUpdateBeroepsziekten.disabled = true;
  }
}

function clearBZFields(){
  transactionForm.BeroepsziektenDate.value = "";
  transactionForm.BeroepsziektenDescription.value = "";
  transactionForm.BeroepsziektenBI.value = "";
  transactionForm.BeroepsziektenErkenning.value = "";
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
