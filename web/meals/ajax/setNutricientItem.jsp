<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.NutricientItem,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("action"));

    String sNutricientItemId = checkString(request.getParameter("nutricientItemId")),
           sNutricientUnit   = checkString(request.getParameter("nutricientItemUnit")),
           sNutricientName   = checkString(request.getParameter("nutricientItemName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* meals/ajax/setNutricientItem.jsp *******************");
    	Debug.println("sAction           : "+sAction);
    	Debug.println("sNutricientItemId : "+sNutricientItemId);
    	Debug.println("sNutricientUnit   : "+sNutricientUnit);
    	Debug.println("sNutricientName   : "+sNutricientName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    NutricientItem item = new NutricientItem(sNutricientItemId);
    
    if(sAction.equals("save")){
        item.name = sNutricientName;
        item.unit = sNutricientUnit;
        item.updateOrInsert(activeUser.userid);        
    }
    else if(sAction.equals("delete")){
        item.delete();        
    }
    
    out.write("<script>closeModalbox();searchNutricientItems();</script>");
%>