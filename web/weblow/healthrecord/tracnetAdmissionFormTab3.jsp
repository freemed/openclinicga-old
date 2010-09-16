<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%

%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

<table class="list" cellspacing="1" cellpadding="0" width="100%">
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","weigth",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>" onblur="isNumber(this);"/>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","heigth",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>" onblur="isNumber(this);"/>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.rr",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_RR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_RR" property="value"/>" onblur="isNumber(this);"/>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.temp",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_TEMPERATURE" property="value"/>" onblur="isNumber(this);"/>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.ta",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_DBP" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_DBP" property="value"/>" onblur="isNumber(this);"/>
            /
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_SBP" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_SBP" property="value"/>" onblur="isNumber(this);"/>
            mmHg
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.hr",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_HR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_HR" property="value"/>" onblur="isNumber(this);"/>
        </td>
    </tr>
</table>
<br>
<table class="list" cellspacing="1" cellpadding="0" width="100%">
    <tr class="admin">
        <td width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","tracnet.admission.form.system",sWebLanguage)%></td>
        <td><%=getTran("openclinic.chuk","tracnet.admission.form.description",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.orl",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_ORL")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_ORL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_ORL" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.skin",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_SKIN")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_SKIN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_SKIN" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.cardio",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_CARDIO")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_CARDIO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_CARDIO" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.pulmonaire",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_PULMONAIRE")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_PULMONAIRE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_PULMONAIRE" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.abdominal",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_ABDOMINAL")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_ABDOMINAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_ABDOMINAL" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.neuro",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_NEURO")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_NEURO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_NEURO" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.rhumato",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_RHUMATO")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_RHUMATO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_RHUMATO" property="value"/></textarea>
        </td>
    </tr>
    <tr>
        <td class="admin"><%=getTran("openclinic.chuk","tracnet.admission.form.uro",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ADMISSION_FORM_EXAMINATION_URO")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_URO" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_URO" property="value"/></textarea>
        </td>
    </tr>
</table>