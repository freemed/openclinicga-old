<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory,be.openclinic.system.ItemTypeAttribute" %>

<head>
    <link href="<c:url value='/'/>_css/web.css" rel="stylesheet" type="text/css" media="screen">
    <link href="<c:url value='/'/>_css/printscreen.css" rel="stylesheet" type="text/css" media="print">
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
</head>

<%
    String sItemType  = request.getParameter("itemType"),
           sItemValue = request.getParameter("itemValue");

    if(sItemType==null || sItemType.equals("null")){
        sItemType = "";
    }

    if(sItemValue==null || sItemValue.equals("null")){
        sItemValue = "";
    }

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** util/saveDefaultValue.jsp *****************");
    	Debug.println("sItemType  : "+sItemType);
    	Debug.println("sItemValue : "+sItemValue+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    // delete
    ItemTypeAttribute objItemTypeAttr = new ItemTypeAttribute();
    objItemTypeAttr.setItemType(sItemType);
    objItemTypeAttr.setName("DefaultValue");
    objItemTypeAttr.setUserid(Integer.parseInt(activeUser.userid));
    objItemTypeAttr.delete();

    // insert
    objItemTypeAttr = new ItemTypeAttribute();
    objItemTypeAttr.setItemType(sItemType);
    objItemTypeAttr.setName("DefaultValue");
    objItemTypeAttr.setValue(sItemValue);
    objItemTypeAttr.setUserid(Integer.parseInt(activeUser.userid));
    objItemTypeAttr.setUpdateTime(new java.util.Date()); // now
    objItemTypeAttr.insert();
	
    // refresh values in session
    ((SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName())).loadItemDefaults();
%>
<script>
  if(window.opener.document.getElementById('ie5menu')){
    window.opener.document.getElementById('ie5menu').style.visibility = 'hidden';
  }
  
  window.close();
</script>