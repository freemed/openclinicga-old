<%@page import="be.openclinic.finance.Wicket,
                java.util.Vector,
                be.openclinic.finance.Insurar,
                be.openclinic.finance.InsuranceCategory,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindInsurarName = checkString(request.getParameter("FindInsurarName"));

    /// DEBUG //////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
	    Debug.println("\n******** _common/search/searchByAjax/searchCoveragePlanShow.jsp *********");
	    Debug.println("sFindInsurarName : "+sFindInsurarName+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
%>
<table class="list" width="100%" cellspacing="1" cellpadding="0">
    <%
        Vector vInsurars = Insurar.getInsurarsByName(sFindInsurarName);
        String sClass = "", sInsurarUID = "";
        StringBuffer results = new StringBuffer();
        int recCount = 0;

        if(vInsurars.size() > 0){
            Iterator iter = vInsurars.iterator();
            Insurar objInsurar;
            while(iter.hasNext()){
                recsFound = true;
                objInsurar = (Insurar)iter.next();

                if(objInsurar.getContact().equals("plan.openinsurance")){
                    String cats = "";
                    for(int n=0; n<objInsurar.getInsuraceCategories().size(); n++){
                        InsuranceCategory insCat = (InsuranceCategory)objInsurar.getInsuraceCategories().elementAt(n);
                        if(n>0){
                            cats+= "<br/>";
                        }
                        cats+= "<a href=\"javascript:setInsuranceCategory('"+insCat.getCategory()+"', '"+objInsurar.getUid()+"','"+objInsurar.getName().toUpperCase()+"','"+insCat.getCategory()+": "+insCat.getLabel()+"','"+objInsurar.getType()+"','"+getTranNoLink("insurance.types",objInsurar.getType(),sWebLanguage)+"');\">"+
                               insCat.getCategory()+" ("+insCat.getLabel()+" - "+insCat.getPatientShare()+"/"+(100-Integer.parseInt(insCat.getPatientShare()))+")</a>";
                    }
                    
                    // alternate row-style
                    if(sClass.equals("")) sClass = "1";
                    else                  sClass = "";

                    results.append("<tr class='list"+sClass+"'>")
                            .append("<td>"+objInsurar.getName().toUpperCase()+"</td>")
                            .append("<td>"+cats+"</td>")
                           .append("</tr>");
                } 
            }

            if(recCount > 0){
                %>
	            <tbody class="hand">
	                <tr class="admin">
	                    <td nowrap><%=HTMLEntities.htmlentities(getTran("Web","name",sWebLanguage))%></td>
	                    <td nowrap><%=HTMLEntities.htmlentities(getTran("Web","category",sWebLanguage))%></td>
	                </tr>
	
	                <%=HTMLEntities.htmlentities(results.toString())%>
	            </tbody>
	            
                <%=recCount%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
	            <%
            }
            else{
                // display 'no results' message
		        %>
		            <tr>
		                <td colspan='3'><%=HTMLEntities.htmlentities(getTran("web","norecordsfound",sWebLanguage))%></td>
		            </tr>
		        <%
            }
        }
    %>
</table>