<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%%>

<%!
    //--- GET ITEM VALUE --------------------------------------------------------------------------
    public String getItemValue(TransactionVO transactionVO, String itemType){
        if(transactionVO != null){
            itemType = "be.mxs.common.model.vo.healthrecord.IConstants."+itemType.trim();
            ItemVO itemVO = transactionVO.getItem(itemType);
            if(itemVO != null){
                return ScreenHelper.checkString(itemVO.getValue());
            }
        }

        return "";
    }
%>
      
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

<%
    TransactionVO tran = (TransactionVO)transaction;

    // 3 sections in previous jsp
    int sectionCount = 4;

    long diffYears = 0;
    if (checkString(activePatient.dateOfBirth).length()>0){
        java.sql.Date dDOB = ScreenHelper.getSQLDate(activePatient.dateOfBirth);
        String sNow = getDate();
        java.sql.Date dNow = ScreenHelper.getSQLDate(sNow);
        Calendar cNow = Calendar.getInstance();
        cNow.setTime(dNow);

        Calendar cDOB = Calendar.getInstance();
        cDOB.setTime(dDOB);

        long diffMillis = cNow.getTimeInMillis()-cDOB.getTimeInMillis();

        diffYears = diffMillis / (1000 * 60 * 60 * 24);
        diffYears = diffYears / 365;
    }
%>                 

<%-- TODO : SECTION 4 --%>
<%-- SECTION HEADER --%>
<tr class="label" height="18">
    <td colspan="3">
        <img id="img<%=sectionCount%>" src="<c:url value="/"/>/_img/plus.jpg" onClick="toggleSection('section<%=sectionCount%>','img<%=sectionCount%>');" class="link">&nbsp;
        <%=getTran("web","section",sWebLanguage)%> <%=sectionCount%>
    </td>
</tr>
<tbody id="section<%=sectionCount%>" style="display:none;">
    <%-- Visus nabij binoculair --------------------------------------------------------------%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.workers-on-screen-binoculair-VP",sWebLanguage)%></td>
        <td colspan="2" class="admin2" width="800">
            <table cellspacing="1">
                <tr>
                    <td align="center"><input id="nearodg0" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=0"   property="value" outputString="checked"/> value="0"></td>
                    <td align="center"><input id="nearodg0.5" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=0,5" property="value" outputString="checked"/> value="0,5"></td>
                    <td align="center"><input id="nearodg2" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=2"   property="value" outputString="checked"/> value="2"></td>
                    <td align="center"><input id="nearodg4" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=4"   property="value" outputString="checked"/> value="4"></td>
                    <td align="center"><input id="nearodg5" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=5"   property="value" outputString="checked"/> value="5"></td>
                    <td align="center"><input id="nearodg6" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=6"   property="value" outputString="checked"/> value="6"></td>
                    <td align="center"><input id="nearodg8" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=8"   property="value" outputString="checked"/> value="8"></td>
                    <td align="center"><input id="nearodg10" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=10"  property="value" outputString="checked"/> value="10"></td>
                    <td align="center"><input id="nearodg12" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2;value=12"  property="value" outputString="checked"/> value="12"></td>
                    <td rowspan="2" align="right">
                        &nbsp;
                        <select class="text" id="nearodgcorr" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VP_CORRECTION" property="itemId"/>]>.value">
                            <option/>
                            <option value="medwan.healthrecord.ophtalmology.avec-correction" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VP_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%></option>
                            <option value="medwan.healthrecord.ophtalmology.sans-correction" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VP_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%></option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="admin" width="20" style="text-align:center;">0</td>
                    <td class="admin" width="20" style="text-align:center;">0,5</td>
                    <td class="admin" width="20" style="text-align:center;">2</td>
                    <td class="admin" width="20" style="text-align:center;">4</td>
                    <td class="admin" width="20" style="text-align:center;">5</td>
                    <td class="admin" width="20" style="text-align:center;">6</td>
                    <td class="admin" width="20" style="text-align:center;">8</td>
                    <td class="admin" width="20" style="text-align:center;">10</td>
                    <td class="admin" width="20" style="text-align:center;">12</td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- Visus tussenafstand binoculair ------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.workers-on-screen-binoculair-VI",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <table cellspacing="1">
                <tr>
                    <td align="center"><input id="interodg0" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=0"   property="value" outputString="checked"/> value="0"></td>
                    <td align="center"><input id="interodg0.5" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=0,5" property="value" outputString="checked"/> value="0,5"></td>
                    <td align="center"><input id="interodg2" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=2"   property="value" outputString="checked"/> value="2"></td>
                    <td align="center"><input id="interodg4" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=4"   property="value" outputString="checked"/> value="4"></td>
                    <td align="center"><input id="interodg5" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=5"   property="value" outputString="checked"/> value="5"></td>
                    <td align="center"><input id="interodg6" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=6"   property="value" outputString="checked"/> value="6"></td>
                    <td align="center"><input id="interodg8" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=8"   property="value" outputString="checked"/> value="8"></td>
                    <td align="center"><input id="interodg10" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=10"  property="value" outputString="checked"/> value="10"></td>
                    <td align="center"><input id="interodg12" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2;value=12"  property="value" outputString="checked"/> value="12"></td>
                    <td rowspan="2" align="right">
                        &nbsp;
                        <select class="text" id="interodgcorr" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VI_CORRECTION" property="itemId"/>]>.value">
                            <option/>
                            <option value="medwan.healthrecord.ophtalmology.avec-correction" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VI_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%></option>
                            <option value="medwan.healthrecord.ophtalmology.sans-correction" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VI_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%></option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="admin" width="20" style="text-align:center;">0</td>
                    <td class="admin" width="20" style="text-align:center;">0,5</td>
                    <td class="admin" width="20" style="text-align:center;">2</td>
                    <td class="admin" width="20" style="text-align:center;">4</td>
                    <td class="admin" width="20" style="text-align:center;">5</td>
                    <td class="admin" width="20" style="text-align:center;">6</td>
                    <td class="admin" width="20" style="text-align:center;">8</td>
                    <td class="admin" width="20" style="text-align:center;">10</td>
                    <td class="admin" width="20" style="text-align:center;">12</td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- Visus ver-zien binoculair -----------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.workers-on-screen-binoculair-VL",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <table cellspacing="1">
                <tr>
                    <td align="center"><input id="farodg0" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=0"   property="value" outputString="checked"/> value="0"></td>
                    <td align="center"><input id="farodg0.5" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=0,5" property="value" outputString="checked"/> value="0,5"></td>
                    <td align="center"><input id="farodg2" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=2"   property="value" outputString="checked"/> value="2"></td>
                    <td align="center"><input id="farodg4" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=4"   property="value" outputString="checked"/> value="4"></td>
                    <td align="center"><input id="farodg5" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=5"   property="value" outputString="checked"/> value="5"></td>
                    <td align="center"><input id="farodg6" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=6"   property="value" outputString="checked"/> value="6"></td>
                    <td align="center"><input id="farodg8" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=8"   property="value" outputString="checked"/> value="8"></td>
                    <td align="center"><input id="farodg10" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=10"  property="value" outputString="checked"/> value="10"></td>
                    <td align="center"><input id="farodg12" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2;value=12"  property="value" outputString="checked"/> value="12"></td>
                    <td rowspan="2" align="right">
                        &nbsp;
                        <select class="text" id="farodgcorr" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VL_CORRECTION" property="itemId"/>]>.value">
                            <option/>
                            <option value="medwan.healthrecord.ophtalmology.avec-correction" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VL_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage)%></option>
                            <option value="medwan.healthrecord.ophtalmology.sans-correction" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_VL_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage)%></option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td class="admin" width="20" style="text-align:center;">0</td>
                    <td class="admin" width="20" style="text-align:center;">0,5</td>
                    <td class="admin" width="20" style="text-align:center;">2</td>
                    <td class="admin" width="20" style="text-align:center;">4</td>
                    <td class="admin" width="20" style="text-align:center;">5</td>
                    <td class="admin" width="20" style="text-align:center;">6</td>
                    <td class="admin" width="20" style="text-align:center;">8</td>
                    <td class="admin" width="20" style="text-align:center;">10</td>
                    <td class="admin" width="20" style="text-align:center;">12</td>
                </tr>
            </table>
        </td>
    </tr>
</tbody>

<%
    if(tran.getTransactionId().intValue() < 0){
        // new transaction
        %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
    }
    else{
        // existing transaction
        if(getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_CORRECTION").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_CORRECTION").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_CORRECTION").length() > 0){
            %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
        }
    }

    sectionCount++;
%>

<%-- TODO : SECTION 5 --%>
<%-- SECTION HEADER --%>
<tr class="label" height="18">
    <td colspan="3">
        <img id="img<%=sectionCount%>" src="<c:url value="/"/>/_img/plus.jpg" onClick="toggleSection('section<%=sectionCount%>','img<%=sectionCount%>');" class="link">&nbsp;
        <%=getTran("web","section",sWebLanguage)%> <%=sectionCount%>
    </td>
</tr>
<tbody id="section<%=sectionCount%>" style="display:none;">
    <%-- Vermoeidheid ------------------------------------------------------------------------%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.fatigue",sWebLanguage)%></td>
        <td class="admin2" colspan="2" width="800">
            <table>
                <tr>
                    <td>
                        <table>
                            <tr>
                                <td align="center"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.time-span",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN" property="value"/>" class="text" size="8" maxLength="255">
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td width="1%">&nbsp;</td>
                    <td>
                        <table>
                            <tr>
                                <td>&nbsp;</td>
                                <td>1</td>
                                <td>&nbsp;</td>
                                <td>3</td>
                                <td>&nbsp;</td>
                                <td>5</td>
                                <td>&nbsp;</td>
                                <td>2</td>
                                <td>&nbsp;</td>
                                <td>4</td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.far",sWebLanguage)%></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5;value=5" property="value" outputString="checked"/> value="5"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td>&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.close",sWebLanguage)%></td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2;value=2" property="value" outputString="checked"/> value="2"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                <td>&nbsp;</td>
                                <td><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5;value=5" property="value" outputString="checked"/> value="5"></td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>2</td>
                                <td>&nbsp;</td>
                                <td>4</td>
                                <td>&nbsp;</td>
                                <td>1</td>
                                <td>&nbsp;</td>
                                <td>3</td>
                                <td>&nbsp;</td>
                                <td>5</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- PHORIES VI --------------------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phoriesvi",sWebLanguage)%></td>
        <td colspan="2" class="admin2">
            <table cellspacing="1" border="1">
                <%-- HEADER --%>
                <tr>
                    <td/>
                    <td class="admin" align="center">1</td>
                    <td class="admin" align="center">2</td>
                    <td class="admin" align="center">3</td>
                    <td class="admin" align="center">4</td>
                    <td class="admin" align="center">5</td>
                    <td class="admin" align="center">6</td>
                    <td class="admin" align="center">7</td>
                    <td class="admin" align="center">8</td>
                    <td class="admin" align="center">9</td>
                    <td class="admin" align="center">10</td>
                    <td class="admin" align="center">11</td>
                    <td class="admin" align="center">12</td>
                    <td class="admin" align="center">13</td>
                    <td class="admin" align="center">14</td>
                    <td class="admin" align="center">15</td>
                </tr>
                <%-- ROUND --%>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.round",sWebLanguage)%>&nbsp;</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=1" property="value" outputString="checked"/> value="1"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=2" property="value" outputString="checked"/> value="2"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=3" property="value" outputString="checked"/> value="3"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=4" property="value" outputString="checked"/> value="4"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=5" property="value" outputString="checked"/> value="5"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=6" property="value" outputString="checked"/> value="6"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=7" property="value" outputString="checked"/> value="7"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=8" property="value" outputString="checked"/> value="8"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=9" property="value" outputString="checked"/> value="9"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=10" property="value" outputString="checked"/> value="10"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=11" property="value" outputString="checked"/> value="11"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=12" property="value" outputString="checked"/> value="12"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=13" property="value" outputString="checked"/> value="13"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=14" property="value" outputString="checked"/> value="14"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=15" property="value" outputString="checked"/> value="15"></td>
                </tr>
                <%-- SQUARE --%>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.square",sWebLanguage)%>&nbsp;</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=16" property="value" outputString="checked"/> value="16"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=17" property="value" outputString="checked"/> value="17"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=18" property="value" outputString="checked"/> value="18"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=19" property="value" outputString="checked"/> value="19"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=20" property="value" outputString="checked"/> value="20"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=21" property="value" outputString="checked"/> value="21"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=22" property="value" outputString="checked"/> value="22"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=23" property="value" outputString="checked"/> value="23"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=24" property="value" outputString="checked"/> value="24"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=25" property="value" outputString="checked"/> value="25"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=26" property="value" outputString="checked"/> value="26"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=27" property="value" outputString="checked"/> value="27"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=28" property="value" outputString="checked"/> value="28"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=29" property="value" outputString="checked"/> value="29"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=30" property="value" outputString="checked"/> value="30"></td>
                </tr>
                <%-- TRIANGLE --%>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.triangle",sWebLanguage)%>&nbsp;</td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=31" property="value" outputString="checked"/> value="31"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=32" property="value" outputString="checked"/> value="32"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=33" property="value" outputString="checked"/> value="33"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=34" property="value" outputString="checked"/> value="34"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=35" property="value" outputString="checked"/> value="35"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=36" property="value" outputString="checked"/> value="36"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=37" property="value" outputString="checked"/> value="37"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=38" property="value" outputString="checked"/> value="38"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=39" property="value" outputString="checked"/> value="39"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=40" property="value" outputString="checked"/> value="40"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=41" property="value" outputString="checked"/> value="41"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=42" property="value" outputString="checked"/> value="42"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=43" property="value" outputString="checked"/> value="43"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=44" property="value" outputString="checked"/> value="44"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES;value=45" property="value" outputString="checked"/> value="45"></td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- MOVEMENT --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.movement",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT" property="itemId"/>]>.value" class="text">
                <option/>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.stable" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.stable" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.movement.stable",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.arise_left" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.arise_left" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.movement.arise_left",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.arise_right" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.arise_right" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.movement.arise_right",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.movement.outside_grating_left",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT;value=medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.phories.movement.outside_grating_right",sWebLanguage)%></option>
            </select>
        </td>
    </tr>
    <%-- FUSION --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.fusion",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <select id="fus" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FUSION" property="itemId"/>]>.value" class="text">
                <option/>
                <option value="medwan.healthrecord.ophtalmology.fusion.aligned" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FUSION;value=medwan.healthrecord.ophtalmology.fusion.aligned" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.fusion.aligned",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.fusion.not_aligned" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_FUSION;value=medwan.healthrecord.ophtalmology.fusion.not_aligned" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.fusion.not_aligned",sWebLanguage)%></option>
            </select>
        </td>
    </tr>
</tbody>

<%
    if(tran.getTransactionId().intValue() < 0){
        // new transaction
        %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
    }
    else{
        // existing transaction
        if(getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_PHORIES_MOVEMENT").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FUSION").length() > 0){
            %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
        }
    }

    sectionCount++;
%>

<%-- TODO : SECTION 6 --%>
<%-- SECTION HEADER --%>
<tr class="label" height="18">
    <td colspan="3">
        <img id="img<%=sectionCount%>" src="<c:url value="/"/>/_img/plus.jpg" onClick="toggleSection('section<%=sectionCount%>','img<%=sectionCount%>');" class="link">&nbsp;
        <%=getTran("web","section",sWebLanguage)%> <%=sectionCount%>
    </td>
</tr>
<tbody id="section<%=sectionCount%>" style="display:none;">
    <%-- stereoscopie ------------------------------------------------------------------------%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.stereoscopie",sWebLanguage)%></td>
        <td class="admin2" colspan="2" width="800">
            <table>
                <tr>
                    <td>
                        <table>
                            <tr>
                                <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.plus-pres",sWebLanguage)%></td>
                                <td><img class="link" src='<c:url value="/_img/top.jpg"/>'></td>
                            </tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr><td>&nbsp;</td></tr>
                            <tr>
                                <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.plus-loin",sWebLanguage)%></td>
                                <td><img class="link" src='<c:url value="/_img/bottom.jpg"/>'></td>
                            </tr>
                        </table>
                    </td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>
                        <table class="list" cellspacing="1">
                            <tr>
                                <td width="50" id="line-1.col-1"><input id="r11" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('1','1')"> 1</td>
                                <td width="50" id="line-1.col-2"><input id="r12" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('1','2')"> 2</td>
                                <td width="50" id="line-1.col-3"><input id="r13" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('1','3')"> 3</td>
                                <td width="50" id="line-1.col-4"><input id="r14" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('1','4')"> 4</td>
                                <td width="50" id="line-1.col-5"><input id="r15" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('1','5')"> 5</td>
                            </tr>
                            <tr>
                                <td id="line-2.col-1"><input id="r21" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('2','1')"> 1</td>
                                <td id="line-2.col-2"><input id="r22" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('2','2')"> 2</td>
                                <td id="line-2.col-3"><input id="r23" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('2','3')"> 3</td>
                                <td id="line-2.col-4"><input id="r24" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('2','4')"> 4</td>
                                <td id="line-2.col-5"><input id="r25" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('2','5')"> 5</td>
                            </tr>
                            <tr>
                                <td id="line-3.col-1"><input id="r31" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('3','1')"> 1</td>
                                <td id="line-3.col-2"><input id="r32" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('3','2')"> 2</td>
                                <td id="line-3.col-3"><input id="r33" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('3','3')"> 3</td>
                                <td id="line-3.col-4"><input id="r34" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('3','4')"> 4</td>
                                <td id="line-3.col-5"><input id="r35" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('3','5')"> 5</td>
                            </tr>
                            <tr>
                                <td id="line-4.col-1"><input id="r41" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('4','1')"> 1</td>
                                <td id="line-4.col-2"><input id="r42" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('4','2')"> 2</td>
                                <td id="line-4.col-3"><input id="r43" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('4','3')"> 3</td>
                                <td id="line-4.col-4"><input id="r44" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('4','4')"> 4</td>
                                <td id="line-4.col-5"><input id="r45" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('4','5')"> 5</td>
                            </tr>
                            <tr>
                                <td id="line-5.col-1"><input id="r51" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=1" property="value" outputString="checked"/> value="1" onclick="toggleColor('5','1')"> 1</td>
                                <td id="line-5.col-2"><input id="r52" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=2" property="value" outputString="checked"/> value="2" onclick="toggleColor('5','2')"> 2</td>
                                <td id="line-5.col-3"><input id="r53" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=3" property="value" outputString="checked"/> value="3" onclick="toggleColor('5','3')"> 3</td>
                                <td id="line-5.col-4"><input id="r54" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=4" property="value" outputString="checked"/> value="4" onclick="toggleColor('5','4')"> 4</td>
                                <td id="line-5.col-5"><input id="r55" type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5;value=5" property="value" outputString="checked"/> value="5" onclick="toggleColor('5','5')"> 5</td>
                            </tr>
                        </table>
                    </td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>
                        <input type="hidden" id="normalOrAbnormal" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL" property="itemId"/>]>.value">
                        <input id="stereoNormal" type="radio" DISABLED><span id="normalRadioLabel"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.Normal",sWebLanguage)%></span>
                        <input id="stereoAbnormal" type="radio" DISABLED><span id="abnormalRadioLabel"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.Abnormal",sWebLanguage)%></span>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- Gezichtsveld (grote ovaal) ----------------------------------------------------------%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.vision-peripherique",sWebLanguage)%></td>
        <td class="admin2" colspan="2" width="800">
            <table>
                <tr>
                    <td height="223" background="<c:url value='/_img/gezichtsveld_cbmt.gif'/>" width="447">
                        <%-- ovaal --%>
                        <table id="peripheriqueTable" width="100%">
                            <tr>
                                <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%></td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td align="left">&nbsp;2<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_2;value=2" property="value" outputString="checked"/> value="2">03<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_3;value=3" property="value" outputString="checked"/> value="3"></td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td align="left"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_3;value=3" property="value" outputString="checked"/> value="3">3<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_2;value=2" property="value" outputString="checked"/> value="2">02</td>
                                <td>&nbsp;</td>
                                <td>&nbsp;</td>
                                <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td colspan="6">&nbsp;</td>
                                <td colspan="2" align="left">7<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_7;value=7" property="value" outputString="checked"/> value="7">&nbsp;<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_7;value=7" property="value" outputString="checked"/> value="7">07</td>
                                <td colspan="5">&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="3">&nbsp;</td>
                                <td align="right">6<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_6;value=6" property="value" outputString="checked"/> value="6"></td>
                                <td colspan="6">&nbsp;</td>
                                <td align="left"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_6;value=6" property="value" outputString="checked"/> value="6">06</td>
                                <td colspan="2">&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="13">&nbsp;</td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td colspan="4">01<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_01" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_01;value=01" property="value" outputString="checked"/> value="01">22<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_22" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_22;value=22" property="value" outputString="checked"/> value="22">11<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_11" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_11;value=11" property="value" outputString="checked"/> value="11">1<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_1;value=1" property="value" outputString="checked"/> value="1"></td>
                                <td colspan="4">&nbsp;</td>
                                <td colspan="4"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_01" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_01;value=01" property="value" outputString="checked"/> value="01">01<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_11" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_11;value=11" property="value" outputString="checked"/> value="11">11<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_22" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_22;value=22" property="value" outputString="checked"/> value="22">22<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_1;value=1" property="value" outputString="checked"/> value="1">1</td>
                            </tr>
                            <tr>
                                <td colspan="6">&nbsp;</td>
                                <td colspan="2" align="left">8<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_8;value=8" property="value" outputString="checked"/> value="8">&nbsp;<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_8;value=8" property="value" outputString="checked"/> value="8">08</td>
                                <td colspan="5">&nbsp;</td>
                            </tr>
                            <tr>
                                <td colspan="4">&nbsp;</td>
                                <td align="left">&nbsp;5<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_5;value=5" property="value" outputString="checked"/> value="5">04<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_4;value=4" property="value" outputString="checked"/> value="4"></td>
                                <td colspan="4">&nbsp;</td>
                                <td align="left"><input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_4;value=4" property="value" outputString="checked"/> value="4">4<input type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_5;value=5" property="value" outputString="checked"/> value="5">05</td>
                                <td colspan="3">&nbsp;</td>
                            </tr>
                        </table>
                    </td>
                    <%-- select all --%>
                    <td class="admin2" valign="bottom" width="145">
                        <input type="button" class="button" id="allPeriOn" onClick="selectAllPeri(true);" value="<%=getTranNoLink("Web","selectAll",sWebLanguage)%>">
                        <input type="button" class="button" id="allPeriOff" onClick="selectAllPeri(false);" value="<%=getTranNoLink("Web","deselectAll",sWebLanguage)%>">
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</tbody>

<%
    if(tran.getTransactionId().intValue() < 0){
        // new transaction
        %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
    }
    else{
        // existing transaction
        if(getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_1").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_3").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_4").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_5").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_2").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_3").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_2").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_3").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_7").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_7").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_6").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_6").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_01").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_22").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_11").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_1").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_01").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_11").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_22").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_1").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_8").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_8").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_5").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_4").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_4").length() == 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_5").length() == 0){
            %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
        }
    }

    sectionCount++;
%>

<%-- TODO : SECTION 7 --%>
<%-- SECTION HEADER --%>
<tr class="label" height="18">
    <td colspan="3">
        <img id="img<%=sectionCount%>" src="<c:url value="/"/>/_img/plus.jpg" onClick="toggleSection('section<%=sectionCount%>','img<%=sectionCount%>');" class="link">&nbsp;
        <%=getTran("web","section",sWebLanguage)%> <%=sectionCount%>
    </td>
</tr>
<tbody id="section<%=sectionCount%>" style="display:none;">
    <%-- Kleurenzicht ------------------------------------------------------------------------%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.vision.color",sWebLanguage)%></td>
        <td class="admin2" colspan="2" width="800">
            <table>
                <%-- ROW 1 --%>
                <tr>
                    <td>
                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_1" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="57" style="background-color:'silver'" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_1;value=57" property="value" outputString="selected"/>>57</option>
                            <option value="35" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_1;value=35" property="value" outputString="selected"/>>35</option>
                        </select>
                    </td>
                    <td>
                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_2" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="74" style="background-color:'silver'" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_2;value=74" property="value" outputString="selected"/>>74</option>
                            <option value="21" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_2;value=21" property="value" outputString="selected"/>>21</option>
                        </select>
                    </td>
                    <td>
                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_3" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="97" style="background-color:'silver'" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_3;value=97" property="value" outputString="selected"/>>97</option>
                        </select>
                    </td>
                    <td>
                        <input type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_4" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_4" property="value"/>" maxLength="255">
                    </td>
                    <%-- niets voor alle testen --%>
                    <td rowspan="2">
                        <input type="checkbox" id="movi_c15" value="true" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_NOTHING_SELECTED" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_NOTHING_SELECTED;value=true" property="value" outputString="checked"/>>
                        <%=getLabel("Web.Occup","healthrecord.ophtalmology.ergovision.color-vision.nothing",sWebLanguage,"movi_c15")%>
                    </td>
                </tr>
                <%-- ROW 2 --%>
                <tr>
                    <td>
                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_5" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="16" style="background-color:'silver'" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_5;value=16" property="value" outputString="selected"/>>16</option>
                        </select>
                    </td>
                    <td>
                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_6" property="itemId"/>]>.value" class="text">
                            <option value="" style="background-color:'silver'"></option>
                            <option value="46" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_6;value=46" property="value" outputString="selected"/>>46</option>
                        </select>
                    </td>
                    <td>
                        <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_7" property="itemId"/>]>.value" class="text">
                            <option/>
                            <option value="96" style="background-color:'silver'" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_7;value=96" property="value" outputString="selected"/>>96</option>
                            <option value="9/6" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_7;value=9/6" property="value" outputString="selected"/>>9/6</option>
                        </select>
                    </td>
                    <td>
                        <input type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_8" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_8" property="value"/>" maxLength="255">
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- SCREEN WORKERS CONTRAST -------------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.workers-on-screen-vision-contrast",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <table cellspacing="1">
                <tr>
                    <td>&nbsp;</td>
                    <td class="admin">0,6 </td>
                    <td class="admin">0,4 </td>
                    <td class="admin">0,2 </td>
                </tr>
                <tr>
                    <td class="admin"> 4 </td>
                    <td><input id="c406" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06;value=406" property="value" outputString="checked"/> value="406"></td>
                    <td><input id="c404" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04;value=404" property="value" outputString="checked"/> value="404"></td>
                    <td><input id="c402" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02;value=402" property="value" outputString="checked"/> value="402"></td>
                </tr>
                <tr>
                    <td class="admin"> 6 </td>
                    <td><input id="c606" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06;value=606" property="value" outputString="checked"/> value="606"></td>
                    <td><input id="c604" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04;value=604" property="value" outputString="checked"/> value="604"></td>
                    <td><input id="c602" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02;value=602" property="value" outputString="checked"/> value="602"></td>
                </tr>
                <tr>
                    <td class="admin"> 8 </td>
                    <td><input id="c806" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06;value=806" property="value" outputString="checked"/> value="806"></td>
                    <td><input id="c804" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04;value=804" property="value" outputString="checked"/> value="804"></td>
                    <td><input id="c802" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02;value=802" property="value" outputString="checked"/> value="802"></td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- MESOPIC & PHOTOPIC VISION -----------------------------------------------------------%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.vision-mesopique",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <table cellspacing="1">
                <tr>
                    <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-mesopique",sWebLanguage)%>&nbsp;</td>
                    <td><input id="m0" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_0" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_0;value=0" property="value" outputString="checked"/> value="0"     onclick="if(this.checked==false){document.all['m1'].checked=false;document.all['m2'].checked=false;document.all['m3'].checked=false;document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}"></td>
                    <td><input id="m1" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_2;value=2" property="value" outputString="checked"/> value="2"     onclick="if(this.checked==false){document.all['m2'].checked=false;document.all['m3'].checked=false;document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m0'].checked=true;}"></td>
                    <td><input id="m2" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_4;value=4" property="value" outputString="checked"/> value="4"     onclick="if(this.checked==false){document.all['m3'].checked=false;document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m0'].checked=true;document.all['m1'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="m3" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_6;value=6" property="value" outputString="checked"/> value="6"     onclick="if(this.checked==false){document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m0'].checked=true;document.all['m1'].checked=true;document.all['m2'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="m4" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_8;value=8" property="value" outputString="checked"/> value="8"     onclick="if(this.checked==false){document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m0'].checked=true;document.all['m1'].checked=true;document.all['m2'].checked=true;document.all['m3'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="m5" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_10;value=10" property="value" outputString="checked"/> value="10" onclick="if(this.checked==false){document.all['m6'].checked=false;}else{document.all['m0'].checked=true;document.all['m1'].checked=true;document.all['m2'].checked=true;document.all['m3'].checked=true;document.all['m4'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="m6" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_12;value=12" property="value" outputString="checked"/> value="12" onclick="if(this.checked==false){}else{document.all['m0'].checked=true;document.all['m1'].checked=true;document.all['m2'].checked=true;document.all['m3'].checked=true;document.all['m4'].checked=true;document.all['m5'].checked=true;}"></td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td class="admin" align="center">0</td>
                    <td class="admin" align="center">2</td>
                    <td class="admin" align="center">4</td>
                    <td class="admin" align="center">6</td>
                    <td class="admin" align="center">8</td>
                    <td class="admin" align="center">10</td>
                    <td class="admin" align="center">12</td>
                </tr>
                <tr>
                    <td><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-photopique",sWebLanguage)%>&nbsp;</td>
                    <td><input id="p0" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_0" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_0;value=0" property="value" outputString="checked"/> value="0"     onclick="if(this.checked==false){document.all['p1'].checked=false;document.all['p2'].checked=false;document.all['p3'].checked=false;document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}"></td>
                    <td><input id="p1" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_2;value=2" property="value" outputString="checked"/> value="2"     onclick="if(this.checked==false){document.all['p2'].checked=false;document.all['p3'].checked=false;document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p0'].checked=true;}"></td>
                    <td><input id="p2" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_4;value=4" property="value" outputString="checked"/> value="4"     onclick="if(this.checked==false){document.all['p3'].checked=false;document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p0'].checked=true;document.all['p1'].checked=true;}"></td>
                    <td><input id="p3" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_6;value=6" property="value" outputString="checked"/> value="6"     onclick="if(this.checked==false){document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p0'].checked=true;document.all['p1'].checked=true;document.all['p2'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="p4" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_8;value=8" property="value" outputString="checked"/> value="8"     onclick="if(this.checked==false){document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p0'].checked=true;document.all['p1'].checked=true;document.all['p2'].checked=true;document.all['p3'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="p5" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_10;value=10" property="value" outputString="checked"/> value="10" onclick="if(this.checked==false){document.all['p6'].checked=false;}else{document.all['p0'].checked=true;document.all['p1'].checked=true;document.all['p2'].checked=true;document.all['p3'].checked=true;document.all['p4'].checked=true;}"></td>
                    <td bgcolor="gray"><input id="p6" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_12;value=12" property="value" outputString="checked"/> value="12" onclick="if(this.checked==false){}else{document.all['p0'].checked=true;document.all['p1'].checked=true;document.all['p2'].checked=true;document.all['p3'].checked=true;document.all['p4'].checked=true;document.all['p5'].checked=true;}"></td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td class="admin" align="center">0</td>
                    <td class="admin" align="center">2</td>
                    <td class="admin" align="center">4</td>
                    <td class="admin" align="center">6</td>
                    <td class="admin" align="center">8</td>
                    <td class="admin" align="center">10</td>
                    <td class="admin" align="center">12</td>
                </tr>
            </table>
        </td>
    </tr>
    <%-- RECUP AFTER BLINDNESS ---------------------------------------------------------------%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.recuperationtime_after_blindness",sWebLanguage)%></td>
        <td class="admin2" colspan="2" width="800">
            <table style="text-align:center;" cellspacing="1">
                <%-- HEADER --%>
                <tr>
                    <td width="80"/>
                    <td class="admin" width="40">0-10</td>
                    <td class="admin" width="40">10-20</td>
                    <td class="admin" width="40">20-30</td>
                    <td class="admin" width="40">30-40</td>
                    <td class="admin" width="40">40-50</td>
                    <td class="admin" width="40">50-60</td>
                    <td class="admin" width="40">60-70</td>
                    <td class="admin" width="40">70-80</td>
                    <td class="admin" width="40">80-90</td>
                    <td class="admin" width="50">90-100</td>
                    <td class="admin" width="60">100-110</td>
                    <td class="admin" width="60">110-120</td>
                </tr>
                <%
                    if (diffYears < 40){
                %>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","healthrecord.ophtalmology.recuperationtime_after_blindness.lt40", sWebLanguage)%></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=0-10" property="value" outputString="checked"/> value="0-10"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=10-20" property="value" outputString="checked"/> value="10-20"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=20-30" property="value" outputString="checked"/> value="20-30"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=30-40" property="value" outputString="checked"/> value="30-40"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=40-50" property="value" outputString="checked"/> value="40-50"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=50-60" property="value" outputString="checked"/> value="50-60"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=60-70" property="value" outputString="checked"/> value="60-70"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=70-80" property="value" outputString="checked"/> value="70-80"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=80-90" property="value" outputString="checked"/> value="80-90"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=90-100" property="value" outputString="checked"/> value="90-100"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=100-110" property="value" outputString="checked"/> value="100-110"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=110-120" property="value" outputString="checked"/> value="110-120"></td>
                </tr>
                <%
                    }
                    if ((diffYears==0)||(diffYears>39 && diffYears < 51)){
                %>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","healthrecord.ophtalmology.recuperationtime_after_blindness.40-50", sWebLanguage)%></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=0-10" property="value" outputString="checked"/> value="0-10"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=10-20" property="value" outputString="checked"/> value="10-20"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=20-30" property="value" outputString="checked"/> value="20-30"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=30-40" property="value" outputString="checked"/> value="30-40"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=40-50" property="value" outputString="checked"/> value="40-50"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=50-60" property="value" outputString="checked"/> value="50-60"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=60-70" property="value" outputString="checked"/> value="60-70"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=70-80" property="value" outputString="checked"/> value="70-80"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=80-90" property="value" outputString="checked"/> value="80-90"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=90-100" property="value" outputString="checked"/> value="90-100"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=100-110" property="value" outputString="checked"/> value="100-110"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=110-120" property="value" outputString="checked"/> value="110-120"></td>
                </tr>
                <%
                    }
                    if ((diffYears==0)||(diffYears>50)){
                %>
                <tr>
                    <td class="admin"><%=getTran("Web.Occup","healthrecord.ophtalmology.recuperationtime_after_blindness.gt50", sWebLanguage)%></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=0-10" property="value" outputString="checked"/> value="0-10"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=10-20" property="value" outputString="checked"/> value="10-20"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=20-30" property="value" outputString="checked"/> value="20-30"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=30-40" property="value" outputString="checked"/> value="30-40"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=40-50" property="value" outputString="checked"/> value="40-50"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=50-60" property="value" outputString="checked"/> value="50-60"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=60-70" property="value" outputString="checked"/> value="60-70"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=70-80" property="value" outputString="checked"/> value="70-80"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=80-90" property="value" outputString="checked"/> value="80-90"></td>
                    <td bgcolor="gray"><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=90-100" property="value" outputString="checked"/> value="90-100"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=100-110" property="value" outputString="checked"/> value="100-110"></td>
                    <td><input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION;value=110-120" property="value" outputString="checked"/> value="110-120"></td>
                </tr>
                <%
                    }
                %>
            </table>
        </td>
    </tr>
</tbody>

<%
    if(tran.getTransactionId().intValue() < 0){
        // new transaction
        %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
    }
    else{
        // existing transaction
        if(getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_1").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_3").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_4").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_5").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_6").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_7").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_8").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_COLOR_VISION_NOTHING_SELECTED").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_0").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_4").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_6").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_8").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_10").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_12").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_0").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_2").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_4").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_6").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_8").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_10").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_12").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_RECUPERATION").length() > 0){
            %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
        }
    }

    sectionCount++;
%>

<%-- TODO : SECTION 8 --%>
<%-- SECTION HEADER --%>
<tr class="label" height="18">
    <td colspan="3">
        <img id="img<%=sectionCount%>" src="<c:url value="/"/>/_img/plus.jpg" onClick="toggleSection('section<%=sectionCount%>','img<%=sectionCount%>');" class="link">&nbsp;
        <%=getTran("web","section",sWebLanguage)%> <%=sectionCount%>
    </td>
</tr>
<tbody id="section<%=sectionCount%>" style="display:none;">
    <%-- FINAL DECISION --%>
    <tr>
        <td class="admin" width="<%=(Integer.parseInt(sTDAdminWidth)-4)%>"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.final_decision",sWebLanguage)%></td>
        <td class="admin2" colspan="2" width="800">
            <select name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_DECISION" property="itemId"/>]>.value" class="text">
                <option/>
                <option value="medwan.healthrecord.ophtalmology.final_decision.good_vision" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_DECISION;value=medwan.healthrecord.ophtalmology.final_decision.good_vision" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.final_decision.good_vision",sWebLanguage)%></option>
                <option value="medwan.healthrecord.ophtalmology.final_decision.bad_vision" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_DECISION;value=medwan.healthrecord.ophtalmology.final_decision.bad_vision" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.final_decision.bad_vision",sWebLanguage)%></option>
            </select>
        </td>
    </tr>
    <%-- REMARK --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%></td>
        <td class="admin2" colspan="2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_COMMENT" property="itemId"/>]>.value" rows="2" cols="75" class="text"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_COMMENT" property="value"/></textarea>
        </td>
    </tr>
</tbody>

<%
    if(tran.getTransactionId().intValue() < 0){
        // new transaction
        %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
    }
    else{
        // existing transaction
        if(getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_DECISION").length() > 0 ||
           getItemValue(tran,"ITEM_TYPE_OPTHALMOLOGY_ERGOVISION_OTHER_COMMENT").length() > 0){
            %><script>showSection("section<%=sectionCount%>","img<%=sectionCount%>");</script><%
        }
    }
%>

<%-- PRESTATION TYPE --%>
<tr>
    <td class="admin"><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_opthalmology_type_prestation",sWebLanguage)%></td>
    <td class="admin2" colspan="2">
        <input type="radio" id="rTypeErgovision" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.ergovision" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.ergovision">
        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.ergovision",sWebLanguage,"rTypeErgovision")%>&nbsp;

        <input type="radio" id="rTypeVisiotest" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.visiotest" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.visiotest">
        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.visiotest",sWebLanguage,"rTypeVisiotest")%>&nbsp;

        <input type="radio" id="rTypeFullVisionTest" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.fullvisiontest" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.fullvisiontest">
        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.fullvisiontest",sWebLanguage,"rTypeFullVisionTest")%>&nbsp;

        <input type="radio" id="rTypeNoPrestation" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION" property="itemId"/>]>.value" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION")%> <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_TYPE_PRESTATION;value=medwan.healthrecord.ophtalmology.noprestation" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.noprestation">
        <%=getLabel("web.occup","medwan.healthrecord.ophtalmology.noprestation",sWebLanguage,"rTypeNoPrestation")%>
    </td>
</tr>