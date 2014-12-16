<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.NutricientItem,
                be.openclinic.meals.Meal"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sMeals = checkString(request.getParameter("meals"));
    boolean resizeModalbox = checkString(request.getParameter("resizeModalbox")).equals("true");

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n****************** meals/ajax/getProfileNutricients.jsp ****************");
		Debug.println("sMeals         : "+sMeals);
		Debug.println("resizeModalbox : "+resizeModalbox+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	
    Map nameUnitQuantity = new LinkedHashMap();

    if(sMeals.length() > 0){
	    String[] meals = sMeals.split("\\,");
        DecimalFormat deci = new DecimalFormat("#0.00");
	    Meal meal = null;
	    
	    for(int i=0; i<meals.length; i++){
	        meal = new Meal(meals[i]);
	        meal = Meal.get(meal);
	        
	        if(meal.mealItems.size() > 0){
	            Iterator iter = meal.mealItems.iterator();
	        	MealItem mealitem = null;
	        	
	            while(iter.hasNext()){
	                mealitem = (MealItem)iter.next();
	                
	                Iterator nutrItems = MealItem.get(mealitem).nutricientItems.iterator();
	                while(nutrItems.hasNext()){
	                    NutricientItem nutricient = (NutricientItem)nutrItems.next();

	                    if(nameUnitQuantity.keySet().contains(nutricient.name+"$"+nutricient.unit)){
	                    	String sTmp = (String)nameUnitQuantity.get(nutricient.name+"$"+nutricient.unit);
	                    	sTmp = sTmp.replaceAll(",",".");
	                        float tmp = Float.parseFloat(sTmp);
	                    }
	                    else{
	                    	nameUnitQuantity.put(nutricient.name+"$"+nutricient.unit,deci.format((nutricient.quantity*mealitem.quantity)));
	                    }
	                }
	            }
	        }
	    }
    }
    
    if(nameUnitQuantity.size() > 0){
	    Iterator iter = nameUnitQuantity.keySet().iterator();
	    int i = 3;
	    
	    while(iter.hasNext()){
	        String sNameUnitQuantity = (String)iter.next();
	        if(i > 9) i = 1;
	        
	        out.write("<li class='color"+i+"'>"+
	                   "<div style='width:200px;'>"+sNameUnitQuantity.split("\\$")[0]+"</div>"+
	                   "<div style='width:100px;text-align:right'>"+nameUnitQuantity.get(sNameUnitQuantity)+"</div>"+
	                   "<div style='width:40px'>"+sNameUnitQuantity.split("\\$")[1]+"</div>"+
	                  "</li>");
	        i++;
	    }
    }
	else{
		%><div style="height:25px;padding-top:10px;"><i><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%></i></div><%
	}
    
    if(resizeModalbox){
        %><script>Modalbox.resizeToContent();</script><%    	
    }
%>