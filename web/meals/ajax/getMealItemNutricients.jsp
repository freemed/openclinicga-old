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
        DecimalFormat deci = new DecimalFormat("#0.00");
        
        for(int i=0; i<mealitems.length; i++){
            String[] values = mealitems[i].split("-");
            mealitem = new MealItem(values[0]);
            mealitem.quantity = Float.parseFloat(values[1].replace(",","."));
            
            Iterator iter = MealItem.get(mealitem).nutricientItems.iterator();
            while(iter.hasNext()){
                NutricientItem nutricient = (NutricientItem)iter.next();

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
		%><div style="height:25px;padding-top:10px;"><i><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%></i></div><%
	}
%>
    
<script>Modalbox.resizeToContent();</script>