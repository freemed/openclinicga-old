<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO"%>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.system.Item" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <%
        TransactionVO tran = (TransactionVO)transaction;
        String sITEM_TYPE_OBREPORT_FETAL_POSITION = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_FETAL_POSITION"),
               sITEM_TYPE_OBREPORT_FETAL_SPINE = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_FETAL_SPINE"),
               sITEM_TYPE_OBREPORT_PLACENTA_GRADE = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_PLACENTA_GRADE"),
               sITEM_TYPE_OBREPORT_CORD_INSERTION = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_CORD_INSERTION"),
               sITEM_TYPE_OBREPORT_FETAL_HEAD = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_FETAL_HEAD"),
               sITEM_TYPE_OBREPORT_PLACENTA_LOCATION = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_PLACENTA_LOCATION"),
               sITEM_TYPE_OBREPORT_3V_CORD = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_3V_CORD"),
               sITEM_TYPE_OBREPORT_AMNIOTIC_FLUID = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID"),
               sITEM_TYPE_OBREPORT_FACE = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_FACE"),
               sITEM_TYPE_OBREPORT_LATERAL_VENTRICLES = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_LATERAL_VENTRICLES"),
               sITEM_TYPE_OBREPORT_CEREBELLUM = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_CEREBELLUM"),
               sITEM_TYPE_OBREPORT_CIST_MAGNA = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_CIST_MAGNA"),
               sITEM_TYPE_OBREPORT_ABDOMINAL_WALL = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_ABDOMINAL_WALL"),
               sITEM_TYPE_OBREPORT_STOMACH = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_STOMACH"),
               sITEM_TYPE_OBREPORT_RIGHT_KIDNEY = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_RIGHT_KIDNEY"),
               sITEM_TYPE_OBREPORT_UPPER_EXTREMITIES = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_UPPER_EXTREMITIES"),
               sITEM_TYPE_OBREPORT_COMMENTAIRE = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_COMMENTAIRE"),
               sITEM_TYPE_OBREPORT_UTERUS = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_UTERUS"),
               sITEM_TYPE_OBREPORT_LEFT_OVARY = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_LEFT_OVARY"),
               sITEM_TYPE_OBREPORT_KIDNEYS = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_KIDNEYS"),
               sITEM_TYPE_OBREPORT_RIGHT_OVARY = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_RIGHT_OVARY"),
               sITEM_TYPE_OBREPORT_ADNEXA = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_OBREPORT_ADNEXA");
    %>
<%----------------------------------------   TAB 1  ----------------------------------------------------------%>
       <%-- fetal description ----------------------------------------------------------------------%>

<table cellspacing="1" cellpadding="0" width="100%" border="0" id="fetalDescription" class="list">
   <tr class="admin">
        <td colspan="4"><%=getTran("openclinic.chuk","obreport.fetal.description",sWebLanguage).toUpperCase()%></td>
   </tr>
   <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","obreport.fetal.position",sWebLanguage)%></td>
        <td class="admin2" width="25%">
             <input id="ac_ITEM_TYPE_OBREPORT_FETAL_POSITION" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_POSITION")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_POSITION" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_POSITION%>" >
             <div id="ITEM_TYPE_OBREPORT_FETAL_POSITION_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","obreport.fetal.head",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_FETAL_HEAD" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_HEAD")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_HEAD" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_HEAD%>" >
             <div id="ITEM_TYPE_OBREPORT_FETAL_HEAD_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
   </tr>
   <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.fetal.spine",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_FETAL_SPINE" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_SPINE")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_SPINE" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FETAL_SPINE%>" >
             <div id="ITEM_TYPE_OBREPORT_FETAL_SPINE_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.placenta.location",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_PLACENTA_LOCATION" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_PLACENTA_LOCATION")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_PLACENTA_LOCATION" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_PLACENTA_LOCATION%>" >
             <div id="ITEM_TYPE_OBREPORT_PLACENTA_LOCATION_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
   </tr>
   <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.placenta.grade",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_PLACENTA_GRADE" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_PLACENTA_GRADE")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_PLACENTA_GRADE" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_PLACENTA_GRADE%>" onblur="isNumber(this);">
             <div id="ITEM_TYPE_OBREPORT_PLACENTA_GRADE_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.3v.cord",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_3V_CORD" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_3V_CORD")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_3V_CORD" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_3V_CORD%>" >
             <div id="ITEM_TYPE_OBREPORT_3V_CORD_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.cord.insertion",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_CORD_INSERTION" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CORD_INSERTION")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CORD_INSERTION" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CORD_INSERTION%>" >
             <div id="ITEM_TYPE_OBREPORT_CORD_INSERTION_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.amniotic.fluid",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_AMNIOTIC_FLUID%>" >
             <div id="ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.face",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_FACE" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_FACE")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FACE" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_FACE%>" >
             <div id="ITEM_TYPE_OBREPORT_FACE_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin2" colspan="2">
             <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
        </td>
    </tr>
   <%-- fetal BRAIN ----------------------------------------------------------------------%>
    <tr class="admin">
        <td colspan="4"><%=getTran("openclinic.chuk","obreport.fetal.brain",sWebLanguage).toUpperCase()%></td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.lateral.ventricles",sWebLanguage)%></td>
        <td class="admin2">
            <input id="ac_ITEM_TYPE_OBREPORT_LATERAL_VENTRICLES" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LATERAL_VENTRICLES")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LATERAL_VENTRICLES" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LATERAL_VENTRICLES%>" >
            <div id="ITEM_TYPE_OBREPORT_LATERAL_VENTRICLES_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.cerebellum",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_CEREBELLUM" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CEREBELLUM")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CEREBELLUM" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CEREBELLUM%>" >
             <div id="ITEM_TYPE_OBREPORT_CEREBELLUM_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.cist.magna",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_CIST_MAGNA" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_CIST_MAGNA")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_CIST_MAGNA" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_CIST_MAGNA%>" >
             <div id="ITEM_TYPE_OBREPORT_CIST_MAGNA_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin"/>
        <td class="admin2"/>
    </tr>
    <%-- fetal ABDOMEN ----------------------------------------------------------------------%>
    <tr class="admin">
        <td colspan="4"><%=getTran("openclinic.chuk","obreport.fetal.abdomen",sWebLanguage).toUpperCase()%></td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.abdominal.wall",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_ABDOMINAL_WALL" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_ABDOMINAL_WALL")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_ABDOMINAL_WALL" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_ABDOMINAL_WALL%>" >
             <div id="ITEM_TYPE_OBREPORT_ABDOMINAL_WALL_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.stomach",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_STOMACH" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_STOMACH")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_STOMACH" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_STOMACH%>" >
             <div id="ITEM_TYPE_OBREPORT_STOMACH_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.right.kidney",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_KIDNEY" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_KIDNEY")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_KIDNEY" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_KIDNEY%>" >
             <div id="ITEM_TYPE_OBREPORT_RIGHT_KIDNEY_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.upper.extremities",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_UPPER_EXTREMITIES" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_UPPER_EXTREMITIES")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_UPPER_EXTREMITIES" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_UPPER_EXTREMITIES%>" >
             <div id="ITEM_TYPE_OBREPORT_UPPER_EXTREMITIES_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.commentair",sWebLanguage)%></td>
        <td class="admin2">
             <textarea id="ac_ITEM_TYPE_OBREPORT_COMMENTAIRE" cols="50" rows="2" onKeyup="resizeTextarea(this,10);" <%=setRightClick("ITEM_TYPE_OBREPORT_COMMENTAIRE")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_COMMENTAIRE" property="itemId"/>]>.value"><%=sITEM_TYPE_OBREPORT_COMMENTAIRE%></textarea>
             <div id="ITEM_TYPE_OBREPORT_COMMENTAIRE_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin"/>
        <td class="admin2"/>
   </tr>
    <%-- BIOPHYSICAL PROFILE ----------------------------------------------------------------------%>
   <tr class="admin">
       <td colspan="4"><%=getTran("openclinic.chuk","obreport.biophysical.profile",sWebLanguage).toUpperCase()%></td>
   </tr>
   <tr>
       <td class="admin" ><%=getTran("openclinic.chuk","obreport.nonstress.test",sWebLanguage)%></td>
       <td class="admin2">
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_NONSTRESS_TEST")%> type="radio" onDblClick="uncheckRadio(this);" id="nonstress_r0" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_NONSTRESS_TEST" property="itemId"/>]>.value" value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_NONSTRESS_TEST;value=0" property="value" outputString="checked"/>><label for="nonstress_r0">0</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_NONSTRESS_TEST")%> type="radio" onDblClick="uncheckRadio(this);" id="nonstress_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_NONSTRESS_TEST" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_NONSTRESS_TEST;value=1" property="value" outputString="checked"/>><label for="nonstress_r1">1</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_NONSTRESS_TEST")%> type="radio" onDblClick="uncheckRadio(this);" id="nonstress_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_NONSTRESS_TEST" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_NONSTRESS_TEST;value=2" property="value" outputString="checked"/>><label for="nonstress_r2">2</label>
       </td>
       <td class="admin" ><%=getTran("openclinic.chuk","obreport.fetal.moves",sWebLanguage)%></td>
       <td class="admin2">
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_mov_r0" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS" property="itemId"/>]>.value" value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS;value=0" property="value" outputString="checked"/>><label for="fetal_mov_r0">0</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_mov_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS;value=1" property="value" outputString="checked"/>><label for="fetal_mov_r1">1</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_mov_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_MOVEMENTS;value=2" property="value" outputString="checked"/>><label for="fetal_mov_r2">2</label>
       </td>
       </tr>
       <tr>
       <td class="admin" ><%=getTran("openclinic.chuk","obreport.fetal.breath.moves",sWebLanguage)%></td>
       <td class="admin2">
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_breath_r0" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS" property="itemId"/>]>.value" value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS;value=0" property="value" outputString="checked"/>><label for="fetal_breath_r0">0</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_breath_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS;value=1" property="value" outputString="checked"/>><label for="fetal_breath_r1">1</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_breath_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_BREATHING_MOVEMENTS;value=2" property="value" outputString="checked"/>><label for="fetal_breath_r2">2</label>
       </td>
       <td class="admin" ><%=getTran("openclinic.chuk","obreport.fetal.tone",sWebLanguage)%></td>
       <td class="admin2">
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_TONE")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_tone_r0" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_TONE" property="itemId"/>]>.value" value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_TONE;value=0" property="value" outputString="checked"/>><label for="fetal_tone_r0">0</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_TONE")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_tone_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_TONE" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_TONE;value=1" property="value" outputString="checked"/>><label for="fetal_tone_r1">1</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_FETAL_TONE")%> type="radio" onDblClick="uncheckRadio(this);" id="fetal_tone_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_TONE" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_FETAL_TONE;value=2" property="value" outputString="checked"/>><label for="fetal_tone_r2">2</label>
       </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.amniotic.fluid",sWebLanguage)%></td>
        <td class="admin2">
            <input <%=setRightClick("ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME")%> type="radio" onDblClick="uncheckRadio(this);" id="amniotic_fluid_r0" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME" property="itemId"/>]>.value" value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME;value=0" property="value" outputString="checked"/>><label for="amniotic_fluid_r0">0</label>
            <input <%=setRightClick("ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME")%> type="radio" onDblClick="uncheckRadio(this);" id="amniotic_fluid_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME;value=1" property="value" outputString="checked"/>><label for="amniotic_fluid_r1">1</label>
            <input <%=setRightClick("ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME")%> type="radio" onDblClick="uncheckRadio(this);" id="amniotic_fluid_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_AMNIOTIC_FLUID_VOLUME;value=2" property="value" outputString="checked"/>><label for="amniotic_fluid_r2">2</label>
       </td>
       <td class="admin" ><%=getTran("openclinic.chuk","obreport.total",sWebLanguage)%></td>
       <td class="admin2">
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_TOTAL")%> type="radio" onDblClick="uncheckRadio(this);" id="total_r0" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_TOTAL" property="itemId"/>]>.value" value="0" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_TOTAL;value=0" property="value" outputString="checked"/>><label for="total_r0">0</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_TOTAL")%> type="radio" onDblClick="uncheckRadio(this);" id="total_r1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_TOTAL" property="itemId"/>]>.value" value="1" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_TOTAL;value=1" property="value" outputString="checked"/>><label for="total_r1">1</label>
           <input <%=setRightClick("ITEM_TYPE_OBREPORT_TOTAL")%> type="radio" onDblClick="uncheckRadio(this);" id="total_r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_TOTAL" property="itemId"/>]>.value" value="2" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_TOTAL;value=2" property="value" outputString="checked"/>><label for="total_r2">2</label>
       </td>
    </tr>
    <%-- MATERNAL SURVEY ----------------------------------------------------------------------%>
    <tr class="admin">
       <td colspan="4"><%=getTran("openclinic.chuk","obreport.maternal.survey",sWebLanguage).toUpperCase()%></td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.uterus",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_UTERUS" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_UTERUS")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_UTERUS" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_UTERUS%>">
             <div id="ITEM_TYPE_OBREPORT_UTERUS_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.left.ovary",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_LEFT_OVARY" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_LEFT_OVARY")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_LEFT_OVARY" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_LEFT_OVARY%>" >
             <div id="ITEM_TYPE_OBREPORT_LEFT_OVARY_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.kidneys",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_KIDNEYS" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_KIDNEYS")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_KIDNEYS" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_KIDNEYS%>">
             <div id="ITEM_TYPE_OBREPORT_KIDNEYS_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.right.ovary",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_RIGHT_OVARY" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_RIGHT_OVARY")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_RIGHT_OVARY" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_RIGHT_OVARY%>" >
             <div id="ITEM_TYPE_OBREPORT_RIGHT_OVARY_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
    </tr>
    <tr>
        <td class="admin" ><%=getTran("openclinic.chuk","obreport.adnexa",sWebLanguage)%></td>
        <td class="admin2">
             <input id="ac_ITEM_TYPE_OBREPORT_ADNEXA" size="20" <%=setRightClick("ITEM_TYPE_OBREPORT_ADNEXA")%> type="text" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBREPORT_ADNEXA" property="itemId"/>]>.value" value="<%=sITEM_TYPE_OBREPORT_ADNEXA%>" >
             <div id="ITEM_TYPE_OBREPORT_ADNEXA_update" style="display:none;border:1px solid black;background-color:white;"></div>
        </td>
        <td class="admin"/>
        <td class="admin2"/>
    </tr>
</table>