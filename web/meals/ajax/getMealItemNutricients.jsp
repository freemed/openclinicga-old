<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.NutricientItem,
                be.openclinic.meals.Meal"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sItems = checkString(request.getParameter("items"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n***************** meals/ajax/getMealItemNutricients.jsp ***************");
		Debug.println("sItems : "+sItems+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////


    Map nameUnitQuantity = new LinkedHashMap();
	
    if(sItems.length() > 0){
        List mealItems = new LinkedList();
        String[] mealitems = sItems.split(",");
        MealItem mealitem = null;
        
        for(int i=0; i<mealitems.length; i++){
            String[] values = mealitems[i].split("-");
            mealitem = new MealItem(values[0]);
            mealitem.quantity = Float.parseFloat(values[1].replace(",","."));
            
            Iterator iter = MealItem.get(mealitem).nutricientItems.iterator();
            while(iter.hasNext()){
                NutricientItem nutricient = (NutricientItem)iter.next();
                
                if(nameUnitQuantity.keySet().contains(nutricient.name+"$"+nutricient.unit)){
                	float tmp = ((Float)nameUnitQuantity.get(nutricient.name+"$"+nutricient.unit)).floatValue();
                	nameUnitQuantity.put(nutricient.name+"$"+nutricient.unit,Float.valueOf(tmp+(nutricient.quantity * mealitem.quantity)));
                }
                else{
                	nameUnitQuantity.put(nutricient.name+"$"+nutricient.unit,Float.valueOf((nutricient.quantity * mealitem.quantity)));
                }
            }
        }
    }
    
    if(nameUnitQuantity.size() > 0){
	    Iterator iter = nameUnitQuantity.keySet().iterator();
	    int i = 3;
	    
	    while(iter.hasNext()){
	        String s = (String)iter.next();
	        if(i > 9) i = 1;
	        
	        out.write("<li class='color"+i+"'>"+
	                   "<div style='width:200px'>"+s.split("\\$")[0]+"</div>"+
	                   "<div style='width:100px;text-align:right'>"+nameUnitQuantity.get(s)+"</div>"+
	                   "<div style='width:40px'>"+s.split("\\$")[1]+"</div>"+
	                  "</li>");
	        i++;
	    }
    }
	else{
		%><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
	}
%>
    
<script>Modalbox.resizeToContent();</script>