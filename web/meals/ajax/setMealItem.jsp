<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.NutricientItem,
                be.openclinic.meals.MealItem,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("action"));

    String sMealItemId          = checkString(request.getParameter("mealItemId")),
           sMealItemUnit        = checkString(request.getParameter("mealItemUnit")),
           sMealItemDescription = checkString(request.getParameter("mealItemDescription")),
           sMealItemName        = checkString(request.getParameter("mealItemName")),
           sNutricientitems     = checkString(request.getParameter("nutricientItems"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********************** meals/ajax/setMealItem.jsp *********************");
    	Debug.println("sAction          : "+sAction);
    	Debug.println("sMealItemId      : "+sMealItemId);
    	Debug.println("sMealItemUnit    : "+sMealItemUnit);
    	Debug.println("sMealItemDescription : "+sMealItemDescription);
    	Debug.println("sMealItemName    : "+sMealItemName);
    	Debug.println("sNutricientitems : "+sNutricientitems+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    MealItem item = new MealItem(sMealItemId);
    if(sNutricientitems.length() > 0){
        item.nutricientItems = new LinkedList();
        
        String[] nutricientItems = sNutricientitems.split(",");
        NutricientItem nutricientItem = null;
        
        for(int i=0; i<nutricientItems.length; i++){
            String[] values = nutricientItems[i].split("-");
            nutricientItem = new NutricientItem(values[0]);
            nutricientItem.quantity = Float.parseFloat(values[1].replace(",","."));
            
            item.nutricientItems.add(nutricientItem);
        }
    }
    
    //*** SAVE ***
    if(sAction.equals("save")){
        item.name = sMealItemName;
        item.unit = sMealItemUnit;
        item.description = sMealItemDescription;
        item.updateOrInsert(activeUser.userid);
    }
    //*** DELETE ***
    else if(sAction.equals("delete")){
        item.delete();
    }
    
    out.write("<script>closeModalbox();searchMealItems();</script>");
%>