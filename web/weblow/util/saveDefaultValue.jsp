<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory,be.openclinic.system.ItemTypeAttribute" %>
<%

%>
<head>
    <link href="<c:url value='/'/>_css/web.css" rel="stylesheet" type="text/css" media="screen">
    <link href="<c:url value='/'/>_css/printscreen.css" rel="stylesheet" type="text/css" media="print">
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
</head>
<%
    String sItemType = request.getParameter("itemType");
    String sItemValue = request.getParameter("itemValue");

    if (sItemType == null || sItemType.equals("null")) {
        sItemType = "";
    }

    if (sItemValue == null || sItemValue.equals("null")) {
        sItemValue = "";
    }

    // delete
    if(Debug.enabled){
        Debug.println("saveDefaultValue.jsp: DELETE");
    }
    ItemTypeAttribute objItemTypeAttr = new ItemTypeAttribute();
    objItemTypeAttr.setItemType(sItemType);
    objItemTypeAttr.setName("DefaultValue");
    objItemTypeAttr.setUserid(Integer.parseInt(activeUser.userid));
    int updatedRows = objItemTypeAttr.delete();

    if (Debug.enabled) {
        Debug.println(updatedRows);
        Debug.println("1 = " + sItemType);
    }
    // insert
    objItemTypeAttr = new ItemTypeAttribute();
    objItemTypeAttr.setItemType(sItemType);
    objItemTypeAttr.setName("DefaultValue");
    objItemTypeAttr.setValue(sItemValue);
    objItemTypeAttr.setUserid(Integer.parseInt(activeUser.userid));
    updatedRows = objItemTypeAttr.insert();

    if(Debug.enabled){
        Debug.println("saveDefaultValue.jsp: INSERT");
    }
    if (Debug.enabled) {
        Debug.println(updatedRows);
        Debug.println("2 = " + sItemValue);
    }

    // refresh values in session
    ((SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName())).loadItemDefaults();
%>
<script>
    history.go(-1);
    return false;
</script>