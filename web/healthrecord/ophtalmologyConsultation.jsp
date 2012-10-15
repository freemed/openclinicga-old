<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.ophtalmology.consultation","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%
        String sTranCurrentGlasses_OD    = "";
        String sTranCurrentGlasses_OD_D  = "";
        String sTranCurrentGlasses_OD_DX = "";
        String sTranCurrentGlasses_ADD   = "";
        String sTranCurrentGlasses_OG    = "";
        String sTranCurrentGlasses_OG_D  = "";
        String sTranCurrentGlasses_OG_DX = "";

        String sTranAutorefractor_OD     = "";
        String sTranAutorefractor_OD_D   = "";
        String sTranAutorefractor_OD_DX  = "";
        String sTranAutorefractor_ADD    = "";
        String sTranAutorefractor_OG     = "";
        String sTranAutorefractor_OG_D   = "";
        String sTranAutorefractor_OG_DX  = "";

        String sTranBlurtest_OD          = "";
        String sTranBlurtest_OD_D        = "";
        String sTranBlurtest_OD_DX       = "";
        String sTranBlurtest_ADD         = "";
        String sTranBlurtest_OG          = "";
        String sTranBlurtest_OG_D        = "";
        String sTranBlurtest_OG_DX       = "";

        String sTranNewGlasses_OD        = "";
        String sTranNewGlasses_OD_D      = "";
        String sTranNewGlasses_OD_DX     = "";
        String sTranNewGlasses_ADD       = "";
        String sTranNewGlasses_OG        = "";
        String sTranNewGlasses_OG_D      = "";
        String sTranNewGlasses_OG_DX     = "";

        String sTranOcularTension_OD     = "";
        String sTranOcularTension_OG     = "";

        String sTranOphtalmologyConsContext = "";

        if (transaction != null){
            TransactionVO tran = (TransactionVO)transaction;
            if (tran!=null){
                /*CURRENT GLASS VALUES*/
                sTranCurrentGlasses_OD    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD");
                sTranCurrentGlasses_OD_D  = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D");
                sTranCurrentGlasses_OD_DX = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX");
                sTranCurrentGlasses_ADD   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD");
                sTranCurrentGlasses_OG    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG");
                sTranCurrentGlasses_OG_D  = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D");
                sTranCurrentGlasses_OG_DX = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX");

                /*AUTOREFRACTOR VALUES*/
                sTranAutorefractor_OD     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD");
                sTranAutorefractor_OD_D   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D");
                sTranAutorefractor_OD_DX  = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX");
                sTranAutorefractor_ADD    = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD");
                sTranAutorefractor_OG     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG");
                sTranAutorefractor_OG_D   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D");
                sTranAutorefractor_OG_DX  = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX");

                /*BLURTEST VALUES*/
                sTranBlurtest_OD          = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD");
                sTranBlurtest_OD_D        = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D");
                sTranBlurtest_OD_DX       = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX");
                sTranBlurtest_ADD         = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_ADD");
                sTranBlurtest_OG          = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG");
                sTranBlurtest_OG_D        = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D");
                sTranBlurtest_OG_DX       = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX");

                /*NEW GLASSES VALUES*/
                sTranNewGlasses_OD        = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD");
                sTranNewGlasses_OD_D      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D");
                sTranNewGlasses_OD_DX     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX");
                sTranNewGlasses_ADD       = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD");
                sTranNewGlasses_OG        = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG");
                sTranNewGlasses_OG_D      = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D");
                sTranNewGlasses_OG_DX     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX");


                sTranOcularTension_OD     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD");
                sTranOcularTension_OG     = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG");

                sTranOphtalmologyConsContext = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT");
            }
        }

    %>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" colspan="3">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="4">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script type="text/javascript">writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
		<tr>
			<td colspan="7" class="admin2">
			        	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
			</td>
		</tr>

        <%-- context --%>
        <tr>
            <td class="admin" colspan="3"><%=getTran("openclinic.chuk","context",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input onDblClick="uncheckRadio(this);" id="rbcontextambulant" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT")%> type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT;value=ophtalmology.consultation.ambulant" property="value" outputString="checked"/> value="ophtalmology.consultation.ambulant"/>
                &nbsp;<%=getLabel("web.occup","ophtalmology.consultation.ambulant",sWebLanguage,"rbcontextambulant")%>
                &nbsp;<input onDblClick="uncheckRadio(this);" id="rbcontextpatient" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT")%> type="radio" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT;value=ophtalmology.consultation.hospitalized" property="value" outputString="checked"/> value="ophtalmology.consultation.hospitalized"/>
                &nbsp;<%=getLabel("web.occup","ophtalmology.consultation.hospitalized",sWebLanguage,"rbcontextpatient")%>
            </td>
        </tr>

        <%-- anamnese --%>
        <tr>
            <td class="admin" colspan="3"><%=getTran("openclinic.chuk","anamnese",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE" property="value"/></textarea>
            </td>
        </tr>

        <%-- vision.acuity ----------------------------------------------------------------------%>
        <%-- right : current glasses / dx --%>
        <tr>
            <td class="admin" width="150" rowspan="6"><%=getTran("openclinic.chuk","vision.acuity",sWebLanguage)%></td>
            <td class="admin" width="150" rowspan="2"><%=getTran("openclinic.chuk","current.glasses",sWebLanguage)%></td>
            <td class="admin" width="50"><%=getTran("openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran("openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>

        <%-- left : current glasses / dx --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX" property="itemId"/>]>.value" value="<%=sTranCurrentGlasses_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
        </tr>

        <%-- right : autorefactor --%>
        <tr>
            <td class="admin" rowspan="2"><%=getTran("openclinic.chuk","autorefractor",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran("openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_ADD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD" property="itemId"/>]>.value" value="<%=sTranAutorefractor_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>

        <%-- left : autorefactor --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX" property="itemId"/>]>.value" value="<%=sTranAutorefractor_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
        </tr>

        <%-- right : blurtest --%>
        <tr>
            <td class="admin" rowspan="2"><%=getTran("openclinic.chuk","blurtest",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD" property="itemId"/>]>.value" value="<%=sTranBlurtest_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D" property="itemId"/>]>.value" value="<%=sTranBlurtest_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX" property="itemId"/>]>.value" value="<%=sTranBlurtest_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran("openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_AAD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_ADD" property="itemId"/>]>.value" value="<%=sTranBlurtest_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>

        <%-- left : blurtest --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG" property="itemId"/>]>.value" value="<%=sTranBlurtest_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D" property="itemId"/>]>.value" value="<%=sTranBlurtest_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX" property="itemId"/>]>.value" value="<%=sTranBlurtest_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
        </tr>

        <%-- pupil --%>
        <tr>
            <td class="admin" colspan="3"><%=getTran("openclinic.chuk","pupil",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL" property="value"/></textarea>
            </td>
        </tr>

        <%-- biomicroscopy ----------------------------------------------------------------------%>
        <%-- cornea --%>
        <tr>
            <td class="admin" rowspan="3"><%=getTran("openclinic.chuk","biomicroscopy",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","cornea",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA" property="value"/></textarea>
            </td>
        </tr>

        <%-- chambre.anterieure --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","chambre.anterieure",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE" property="value"/></textarea>
            </td>
        </tr>

        <%-- cristallin --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","cristallin",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN" property="value"/></textarea>
            </td>
        </tr>

        <%-- ocular.tension ---------------------------------------------------------------------%>
        <tr>
            <td class="admin" rowspan="2"><%=getTran("openclinic.chuk","ocular.tension",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD" property="itemId"/>]>.value" value="<%=sTranOcularTension_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;mmHg
            </td>
        </tr>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG" property="itemId"/>]>.value" value="<%=sTranOcularTension_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;mmHg
            </td>
        </tr>

        <%-- retina -----------------------------------------------------------------------------%>
        <%-- optical.nerve --%>
        <tr>
            <td class="admin" rowspan="3"><%=getTran("openclinic.chuk","retina",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","optical.nerve",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE" property="value"/></textarea>
            </td>
        </tr>

        <%-- macula --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","macula",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_MACULA")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_MACULA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_MACULA" property="value"/></textarea>
            </td>
        </tr>

        <%-- periphery --%>
        <tr>
            <td class="admin" colspan="2"><%=getTran("openclinic.chuk","periphery",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY" property="value"/></textarea>
            </td>
        </tr>

        <%-- diagnosis --%>
        <tr>
            <td class="admin" colspan="3"><%=getTran("openclinic.chuk","diagnosis",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS" property="value"/></textarea>
            </td>
        </tr>

        <%-- treatment --%>
        <tr>
            <td class="admin" rowspan="3"><%=getTran("openclinic.chuk","treatment",sWebLanguage)%></td>
            <td class="admin" colspan="2"></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT" property="value"/></textarea>
            </td>
        </tr>

        <%-- new.glasses ------------------------------------------------------------------------%>
        <tr>
            <td class="admin" rowspan="2"><%=getTran("openclinic.chuk","new.glasses",sWebLanguage)%></td>
            <td class="admin"><%=getTran("openclinic.chuk","od",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OD_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OD_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
            <td rowspan="2" class="admin2">
                <%=getTran("openclinic.chuk","add",sWebLanguage)%>+&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD" property="itemId"/>]>.value" value="<%=sTranNewGlasses_ADD%>" size="4" onblur="isMyNumber(this);"/>&nbsp;D
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","og",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OG%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                D <img src="<c:url value="/_img/up_down_arrow.gif"/>" alt=""/> &nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OG_D%>" size="4" onblur="isMyNumber(this);"/>&nbsp;
            </td>
            <td class="admin2">
                Dx&nbsp;<input <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX")%> class="text" type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX" property="itemId"/>]>.value" value="<%=sTranNewGlasses_OG_DX%>" size="4" onblur="isMyNumber(this);"/>&nbsp;°
            </td>
        </tr>

        <%-- remarks --%>
        <tr>
            <td class="admin" colspan="3"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2" colspan="4">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        <%-- BUTTONS --%>
        <tr>
            <td class="admin" colspan="3"/>
            <td class="admin2" colspan="4">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.ophtalmology.consultation",sWebLanguage)%>
            </td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  if("<%=sTranOphtalmologyConsContext%>" == "0"){
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value')[0].checked = true;
  }
  else if("<%=sTranOphtalmologyConsContext%>" == "1"){
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT" property="itemId"/>]>.value')[1].checked = true;
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    if(document.getElementById('encounteruid').value==''){
		alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
		searchEncounter();
	}	
    else {
	    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	    document.transactionForm.saveButton.style.visibility = "hidden";
	    document.transactionForm.submit();
    }
  }
  function searchEncounter(){
      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  if(document.getElementById('encounteruid').value==''){
	alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	searchEncounter();
  }	

  <%-- IS MY NUMBER --%>
  function isMyNumber(sObject){
    if(sObject.value==0) return false;
    sObject.value = sObject.value.replace(",",".");
    var string = sObject.value;
    var vchar = "01234567890.+-";
    var dotCount = 0;

    for(var i=0; i < string.length; i++){
      if (vchar.indexOf(string.charAt(i)) == -1)	{
        sObject.value = "";
        return false;
      }
      else{
        if(string.charAt(i)=="."){
          dotCount++;
          if(dotCount > 1){
            sObject.value = "";
            return false;
          }
        }

        if ((string.charAt(i)=="-")||(string.charAt(i)=="+")){
          if (i>0){
            sObject.value = "";
            return false;
          }
        }
      }
    }

    if(sObject.value.length > 250){
      sObject.value = sObject.value.substring(0,249);
    }

    return true;
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>