<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table class="list" cellspacing="1" cellpadding="0" width="100%">
    <tr class="admin">
        <td colspan="4"><%=getTran("openclinic.chuk","tracnet.admission.form.oms",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin" width="20"></td>
        <td class="admin" width="40%"><%=getTran("openclinic.chuk","tracnet.admission.form.oms1",sWebLanguage)%></td>
        <td class="admin" width="20"></td>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.oms4",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb1a" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.1a",sWebLanguage,"cb1a")%></td>
        <td class="admin2"><input type="checkbox" id="cb4a" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4a",sWebLanguage,"cb4a")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb1b" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.1b",sWebLanguage,"cb1b")%></td>
        <td class="admin2"><input type="checkbox" id="cb4b" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4b",sWebLanguage,"cb4b")%></td>
    </tr>
    <tr>
        <td class="admin"></td>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.oms2",sWebLanguage)%></td>
        <td class="admin2"><input type="checkbox" id="cb4c" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4c",sWebLanguage,"cb4c")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb2a" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.2a",sWebLanguage,"cb2a")%></td>
        <td class="admin2"><input type="checkbox" id="cb4d" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4d",sWebLanguage,"cb4d")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb2b" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.2b",sWebLanguage,"cb2b")%></td>
        <td class="admin2"><input type="checkbox" id="cb4e" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4e",sWebLanguage,"cb4e")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb2c" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.2c",sWebLanguage,"cb2c")%></td>
        <td class="admin2"><input type="checkbox" id="cb4f" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4f",sWebLanguage,"cb4f")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb2d" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.2d",sWebLanguage,"cb2d")%></td>
        <td class="admin2"><input type="checkbox" id="cb4g" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4g",sWebLanguage,"cb4g")%></td>
    </tr>
    <tr>
        <td class="admin"></td>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.oms3",sWebLanguage)%></td>
        <td class="admin2"><input type="checkbox" id="cb4h" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4h",sWebLanguage,"cb4h")%></td>

    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3a" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3a",sWebLanguage,"cb3a")%></td>
        <td class="admin2"><input type="checkbox" id="cb4i" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4i",sWebLanguage,"cb4i")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3b" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3b",sWebLanguage,"cb3b")%></td>
        <td class="admin2"><input type="checkbox" id="cb4j" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4j",sWebLanguage,"cb4j")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3c" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3c",sWebLanguage,"cb3c")%></td>
        <td class="admin2"><input type="checkbox" id="cb4k" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4k",sWebLanguage,"cb4k")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3d" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3d",sWebLanguage,"cb3d")%></td>
        <td class="admin2"><input type="checkbox" id="cb4l" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4l",sWebLanguage,"cb4l")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3e" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3e",sWebLanguage,"cb3e")%></td>
        <td class="admin2"><input type="checkbox" id="cb4m" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4m",sWebLanguage,"cb4m")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3f" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3f",sWebLanguage,"cb3f")%></td>
        <td class="admin2"><input type="checkbox" id="cb4n" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4n",sWebLanguage,"cb4n")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3g" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3g",sWebLanguage,"cb3g")%></td>
        <td class="admin2"><input type="checkbox" id="cb4o" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4o",sWebLanguage,"cb4o")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3h" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3h",sWebLanguage,"cb3h")%></td>
        <td class="admin2"><input type="checkbox" id="cb4p" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4p",sWebLanguage,"cb4p")%></td>
    </tr>
    <tr>
        <td class="admin2"><input type="checkbox" id="cb3i" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.3i",sWebLanguage,"cb3i")%></td>
        <td class="admin2"><input type="checkbox" id="cb4q" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4q",sWebLanguage,"cb4q")%></td>
    </tr>
    <tr>
        <td class="admin2"></td>
        <td class="admin2"></td>
        <td class="admin2"><input type="checkbox" id="cb4r" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4r",sWebLanguage,"cb4r")%></td>
    </tr>
    <tr>
        <td class="admin2"></td>
        <td class="admin2"></td>
        <td class="admin2"><input type="checkbox" id="cb4s" onclick="setScore(this)"></td>
        <td class="admin2"><%=getLabel("openclinic.chuk","tracnet.admission.form.4s",sWebLanguage,"cb4s")%></td>
    </tr>
    <tr>
        <td colspan="2" class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.stade.oms",sWebLanguage)%></td>
        <td colspan="2" class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.examen.demande",sWebLanguage)%></td>
    </tr>
    <tr>
        <td colspan="2" class="admin2">
            <input type="radio" readonly name="rbStade" value="1"> 1
            <input type="radio" readonly name="rbStade" value="2"> 2
            <input type="radio" readonly name="rbStade" value="3"> 3
            <input type="radio" readonly name="rbStade" value="4"> 4            
        </td>
        <td colspan="2" class="admin2">
            <input <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_OMS_CD4")%> id="cbcd4" type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_OMS_CD4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_OMS_CD4;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuk","tracnet.admission.form.cd4",sWebLanguage, "cbcd4")%>
        </td>
    </tr>
</table>
<input type="hidden" id="tscore" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_OMS_SCORE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_OMS_SCORE" property="value"/>">
<input type="hidden" id="tscoreoptions" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_OMS_SCORE_OPTIONS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_OMS_SCORE_OPTIONS" property="value"/>">
<script>
    function setScore(oObject){
        var iOldScore = transactionForm.tscore.value;
        var iScore = oObject.id.substring(2,3);

        if (oObject.checked){

            if (transactionForm.tscore.value.length==0){
               transactionForm.tscore.value = iScore+"";
            }
            else if (iOldScore < iScore){
                transactionForm.tscore.value = iScore+"";
            }

            transactionForm.tscoreoptions.value = transactionForm.tscoreoptions.value +","+oObject.id.substring(2);
            transactionForm.rbStade[transactionForm.tscore.value -1].checked = true;
            transactionForm.tscore.value = iScore;
        }
        else{
            var array = transactionForm.tscoreoptions.value.split(",");
            var iNewScore = 0;
            var iIndex = 0;
            
            for (var i=0;i<array.length;i++){
                if (array[i].indexOf(oObject.id.substring(2))>-1){
                    iIndex = i;
                }
                else if (array[i].length>0){
                    if(array[i].substring(0,1)>iNewScore){
                        iNewScore = array[i].substring(0,1);
                    }
                }
            }
            array.splice(iIndex,1);
            transactionForm.tscoreoptions.value = array.join(",");

            if (iNewScore>0){
                transactionForm.rbStade[iNewScore -1].checked = true;
                transactionForm.tscore.value = iNewScore;
            }
            else {
                transactionForm.tscore.value = "";
                transactionForm.rbStade[iScore -1].checked = false;
            }
        }
    }

    if (transactionForm.tscore.value.length>0){
        transactionForm.rbStade[transactionForm.tscore.value -1].checked = true;

        var array = transactionForm.tscoreoptions.value.split(",");

        for (var i=0;i<array.length;i++){
            if (array[i].length>0){
                document.all("cb"+array[i]).checked = true;
            }
        }
    }
</script>