<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>

    <input type="hidden" name="subClass" value="MESO"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS" property="itemId"/>]>.value" value="medwan.common.false"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" name="trandate">

<script>
  function setTrue(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.all[fieldName].value = "medwan.common.false";
  }
</script>

<table width="100%" class="list" cellspacing="0">
    <tr class="admin">
        <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.vision-mesopique",sWebLanguage)%></td>
        <td align="right" width="20%">
            <%=getLabel("web.occup","medwan.common.not-executed",sWebLanguage,"mom_c1")%>&nbsp;<input name="visus-ras" type="checkbox" id="mom_c1" value="medwan.common.true" onclick="if(this.checked == true){hide('visus-details');setTrue('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS" property="itemId"/>'); } else{show('visus-details');setFalse('<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISUS_MESO_RAS" property="itemId"/>'); }">
        </td>
        <td align="right" width ="1%"><a href="#top"><img class="link" src='<c:url value="/_img/top.jpg"/>'></a></td>
    </tr>
    <tr id="visus-details" style="display:none" width="100%">
        <td colspan="4" width="100%">
            <table width="100%" cellspacing="1">
                <tr>
                    <td class="admin" width="15%">
                        TEST
                    </td>
                    <td class="admin" width="5%">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.No",sWebLanguage)%>
                    </td>
                    <td class="admin"></td>
                </tr>
                <tr>
                    <td class="admin">
                        <%=getTran("web.occup","medwan.healthrecord.ophtalmology.vision-mesopique",sWebLanguage)%>
                    </td>
                    <td class="admin">11</td>
                    <td class="admin2">
                        <table>
                            <tr>
                                <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.acuite-mesopique",sWebLanguage)%>&nbsp;</td>
                                <td><input id="m1" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_2;value=2" property="value" outputString="checked"/> value="2" onclick="if(this.checked==false){document.all['m2'].checked=false;document.all['m3'].checked=false;document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}"></td>
                                <td><input id="m2" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_4;value=4" property="value" outputString="checked"/> value="4" onclick="if(this.checked==false){document.all['m3'].checked=false;document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m1'].checked=true;}"></td>
                                <td class="main"><input id="m3" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_6;value=6" property="value" outputString="checked"/> value="6" onclick="if(this.checked==false){document.all['m4'].checked=false;document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m1'].checked=true;document.all['m2'].checked=true;}"></td>
                                <td class="main"><input id="m4" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_8;value=8" property="value" outputString="checked"/> value="8" onclick="if(this.checked==false){document.all['m5'].checked=false;document.all['m6'].checked=false;}else{document.all['m1'].checked=true;document.all['m2'].checked=true;document.all['m3'].checked=true;}"></td>
                                <td class="main"><input id="m5" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_10;value=10" property="value" outputString="checked"/> value="10" onclick="if(this.checked==false){document.all['m6'].checked=false;}else{document.all['m1'].checked=true;document.all['m2'].checked=true;document.all['m3'].checked=true;document.all['m4'].checked=true;}"></td>
                                <td class="main"><input id="m6" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_12;value=12" property="value" outputString="checked"/> value="12" onclick="if(this.checked==false){}else{document.all['m1'].checked=true;document.all['m2'].checked=true;document.all['m3'].checked=true;document.all['m4'].checked=true;document.all['m5'].checked=true;}"></td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                            <tr>
                                <td><%=getTran("web.occup","medwan.healthrecord.ophtalmology.acuite-photopique",sWebLanguage)%>&nbsp;</td>
                                <td><input id="p1" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_2;value=2" property="value" outputString="checked"/> value="2" onclick="if(this.checked==false){document.all['p2'].checked=false;document.all['p3'].checked=false;document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}"></td>
                                <td><input id="p2" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_4;value=4" property="value" outputString="checked"/> value="4" onclick="if(this.checked==false){document.all['p3'].checked=false;document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p1'].checked=true;}"></td>
                                <td><input id="p3" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_6;value=6" property="value" outputString="checked"/> value="6" onclick="if(this.checked==false){document.all['p4'].checked=false;document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p1'].checked=true;document.all['p2'].checked=true;}"></td>
                                <td class="main"><input id="p4" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_8;value=8" property="value" outputString="checked"/> value="8" onclick="if(this.checked==false){document.all['p5'].checked=false;document.all['p6'].checked=false;}else{document.all['p1'].checked=true;document.all['p2'].checked=true;document.all['p3'].checked=true;}"></td>
                                <td class="main"><input id="p5" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_10;value=10" property="value" outputString="checked"/> value="10" onclick="if(this.checked==false){document.all['p6'].checked=false;}else{document.all['p1'].checked=true;document.all['p2'].checked=true;document.all['p3'].checked=true;document.all['p4'].checked=true;}"></td>
                                <td class="main"><input id="p6" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_12;value=12" property="value" outputString="checked"/> value="12" onclick="if(this.checked==false){}else{document.all['p1'].checked=true;document.all['p2'].checked=true;document.all['p3'].checked=true;document.all['p4'].checked=true;document.all['p5'].checked=true;}"></td>
                            </tr>
                            <tr>
                                <td>&nbsp;</td>
                                <td align="center">2</td>
                                <td align="center">4</td>
                                <td align="center">6</td>
                                <td align="center">8</td>
                                <td align="center">10</td>
                                <td align="center">12</td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="admin"><%=getTran("web.occup","medwan.healthrecord.ophtalmology.correction",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" id="mom_r1" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_MESOPIC_CORRECTION")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_CORRECTION;value=medwan.healthrecord.ophtalmology.avec-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.avec-correction"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.avec-correction",sWebLanguage,"mom_r1")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="mom_r2" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_MESOPIC_CORRECTION")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_CORRECTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_CORRECTION;value=medwan.healthrecord.ophtalmology.sans-correction" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.sans-correction"><%=getLabel("web.occup","medwan.healthrecord.ophtalmology.sans-correction",sWebLanguage,"mom_r2")%>
                    </td>
                </tr>

                <tr>
                    <td class="admin"><%=getTran("web.occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
                    <td class="admin"></td>
                    <td class="admin2">
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_REMARK")%> cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_REMARK" property="value"/></textarea>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<p align="right">
    <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onClick="doSubmit();">
    <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
    <%=writeResetButton("transactionForm",sWebLanguage,activeUser)%>
</p>

<script>
  <%-- DO SUBMIT --%>
  function doSubmit(){
    transactionForm.saveButton.disabled = true;
    transactionForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value='/healthrecord/editTransaction.do'/>"+
                             "?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>"+
                             "&be.mxs.healthrecord.transaction_id=currentTransaction"+
                             "&ts=<%=getTs()%>";
    }
  }
   
  document.all["visus-ras"].onclick();

  if(document.all["m1"].checked==true) document.all["m1"].onclick();
  if(document.all["m2"].checked==true) document.all["m2"].onclick();
  if(document.all["m3"].checked==true) document.all["m3"].onclick();
  if(document.all["m4"].checked==true) document.all["m4"].onclick();
  if(document.all["m5"].checked==true) document.all["m5"].onclick();
  if(document.all["m6"].checked==true) document.all["m6"].onclick();
  if(document.all["p1"].checked==true) document.all["p1"].onclick();
  if(document.all["p2"].checked==true) document.all["p2"].onclick();
  if(document.all["p3"].checked==true) document.all["p3"].onclick();
  if(document.all["p4"].checked==true) document.all["p4"].onclick();
  if(document.all["p5"].checked==true) document.all["p5"].onclick();
  if(document.all["p6"].checked==true) document.all["p6"].onclick();
</script>

</form>
<%=writeJSButtons("transactionForm", "document.all['saveButton']")%>