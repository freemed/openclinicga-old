<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.protocol.procotology","select",activeUser)%>
<%=sJSGRAPHICS%>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","motive",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_MOTIVE")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_MOTIVE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_MOTIVE" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","eternal_examination",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_EXTERNAL_EXAMINATION")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_EXTERNAL_EXAMINATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_EXTERNAL_EXAMINATION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","touch_rectum",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_TOUCH_RECTUM")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_TOUCH_RECTUM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_TOUCH_RECTUM" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","anuscopy",sWebLanguage)%></td>
            <td class="admin2">
                <table cellspacing="0" cellpadding="0" width="525" border="0">
                    <tr>
                        <td rowspan="2">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BACK")%> class="text" cols="40" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BACK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BACK" property="value"/></textarea>
                        </td>
                        <td style="text-align:center;vertical-align:bottom;"><%=getTran("openclinic.chuk","back",sWebLanguage)%></td>
                        <td rowspan="2">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BACK")%> class="text" cols="39" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BACK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BACK" property="value"/></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td rowspan="3">
                            <div id="pointer_div" onclick="point_it(event)" style = "background-image:url('<c:url value="/_img/anuscopie.gif"/>');width:77px;height:77px;"></div>
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align:right;padding-right:10px;"><%=getTran("web.occup","medwan.common.left",sWebLanguage)%></td>
                        <td style="text-align:left;padding-left:10px;">
                            <%=getTran("web.occup","medwan.common.right",sWebLanguage)%>
                            &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  
                            <input type="button" class="button" name="buttonClear" value="<%=getTran("web","clear",sWebLanguage)%>" onclick="doClear()"/>
                        </td>
                    </tr>
                    <tr>
                        <td rowspan="2">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BELLY")%> class="text" cols="40" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BELLY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BELLY" property="value"/></textarea>
                        </td>
                        <td rowspan="2">
                            <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BELLY")%> class="text" cols="39" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BELLY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BELLY" property="value"/></textarea>
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align:center;vertical-align:top;"><%=getTran("openclinic.chuk","belly",sWebLanguage)%></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","rectosigmoidoscopy",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RECTOSIGMOIDOSCOPY")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RECTOSIGMOIDOSCOPY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RECTOSIGMOIDOSCOPY" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","Investigations_done",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY")%> type="checkbox" id="central"   name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><label for="central"><%=getTran("openclinic.chuk","biopsy",sWebLanguage)%></label>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_CONCLUSION")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_PROCOTOLOGY_PROTOCOL_REMARKS")%> class="text" cols="100" rows="2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_REMARKS" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"/>
            <td class="admin2">
<%-- BUTTONS --%>
    <%
      if (activeUser.getAccessRight("occup.protocol.proctology.add") || activeUser.getAccessRight("occup.protocol.proctology.edit")){
    %>
                <INPUT class="button" type="button" name="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="doSubmit();"/>
    <%
      }
    %>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
    </table>
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_IMAGE_COORDS" property="itemId"/>]>.value" id="coord" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROCOTOLOGY_PROTOCOL_IMAGE_COORDS" property="value"/>"/>

<%=ScreenHelper.contextFooter(request)%>
</form>
<script>
    function doSubmit(){
        document.transactionForm.saveButton.disabled = true;
        document.transactionForm.submit();
    }

    var cnv = document.getElementById("pointer_div");
    var jg = new jsGraphics(cnv);

    function point_it(event){
        pos_x = event.offsetX?(event.offsetX):event.pageX-document.getElementById("pointer_div").offsetLeft;
        pos_y = event.offsetY?(event.offsetY):event.pageY-document.getElementById("pointer_div").offsetTop;

        if ((document.transactionForm.coord.value.indexOf(pos_x+","+pos_y)==-1)&&(pos_x > 5) && (pos_y > 5)){
            jg.setColor("red");
            jg.fillEllipse(437+pos_x,190+pos_y,5,5);
            jg.paint();

            document.transactionForm.coord.value += ";"+pos_x+","+pos_y;
        }
    }

    function doClear() {
        jg.clear();
        document.transactionForm.coord.value = "";
    }

    function doPoint(){
        var array = document.transactionForm.coord.value.split(";");
        for(var i=0; i<array.length; i++){
            if (array[i].length>0){
                aCoord = array[i].split(",");
                iX = aCoord[0]*1;
                iY = aCoord[1]*1;
                jg.setColor("red");
                jg.fillEllipse(437+iX,190+iY,5,5);
                jg.paint();
            }
        }
    }

    doPoint();
</script>