<%@ page import="be.openclinic.finance.Prestation,java.util.Vector,be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.finance.Insurance" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%
try{
	String sAction = checkString(request.getParameter("Action"));

    String sFindPrestationRefName = checkString(request.getParameter("FindPrestationRefName")),
            sFindPrestationCode = checkString(request.getParameter("FindPrestationCode")),
            sFindPrestationDescr = checkString(request.getParameter("FindPrestationDescr")),
            sFindPrestationType = checkString(request.getParameter("FindPrestationType")),
 		   sFindPrestationSort = request.getParameter("FindPrestationSort")!=null?request.getParameter("FindPrestationSort"):"OC_PRESTATION_CODE",
           sFindPrestationPrice = checkString(request.getParameter("FindPrestationPrice"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldUid")),
            sReturnFieldCode = checkString(request.getParameter("ReturnFieldCode")),
            sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr")),
            sReturnFieldType = checkString(request.getParameter("ReturnFieldType")),
            sReturnFieldPrice = checkString(request.getParameter("ReturnFieldPrice"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## searchPrestation : " + sAction + " ###############");
        System.out.println("* sFindPrestationRefName : " + sFindPrestationRefName);
        System.out.println("* sFindPrestationCode    : " + sFindPrestationCode);
        System.out.println("* sFindPrestationDescr   : " + sFindPrestationDescr);
        System.out.println("* sFindPrestationType    : " + sFindPrestationType);
        System.out.println("* sFindPrestationPrice   : " + sFindPrestationPrice);
        System.out.println("* sFunction              : " + sFunction + "\n");
        System.out.println("* sReturnFieldUid   : " + sReturnFieldUid);
        System.out.println("* sReturnFieldCode  : " + sReturnFieldCode);
        System.out.println("* sReturnFieldDescr : " + sReturnFieldDescr);
        System.out.println("* sReturnFieldType  : " + sReturnFieldType);
        System.out.println("* sReturnFieldPrice : " + sReturnFieldPrice + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
%>

<div class="search">
    <%
        if (sAction.equals("search")) {
            Vector foundPrestations = Prestation.searchPrestations(sFindPrestationCode, sFindPrestationDescr.replaceAll("e",MedwanQuery.getInstance().getConfigString("equivalentofe","[eéèê]")).replaceAll("a",MedwanQuery.getInstance().getConfigString("equivalentofa","[aàá]")),
                    sFindPrestationType, sFindPrestationPrice,"",sFindPrestationSort);
            Iterator prestationsIter = foundPrestations.iterator();

            String sClass = "", sUid, sCode, sDescr, sType, sTypeTran, sPrice;
            String sSelectTran = getTranNoLink("web", "select", sWebLanguage);
            boolean recsFound = false;
            StringBuffer sHtml = new StringBuffer();
            Prestation prestation;
            String category = "";
            Insurance insurance = activePatient!=null?Insurance.getMostInterestingInsuranceForPatient(checkString(activePatient.personid)):null;
            if (insurance != null) {
                category = insurance.getType();
            }

            while (prestationsIter.hasNext()) {
                prestation = (Prestation) prestationsIter.next();
                if(!prestation.getType().equalsIgnoreCase("con.openinsurance")){
	                recsFound = true;
	
	                // names
	                sUid = prestation.getUid();
	                sCode = checkString(prestation.getCode());
	                sDescr = checkString(prestation.getDescription());
	
	                // type
	                sType = checkString(prestation.getType());
	                sTypeTran = getTran("prestation.type", sType, sWebLanguage);
	
	                // price
	                double price = prestation.getPrice();
	                if (price == 0) sPrice = "";
	                else sPrice = price + "";
	
	                // alternate row-style
	                if (sClass.equals("")) sClass = "1";
	                else sClass = "";
					if(prestation.getVariablePrice()==1){
		                sHtml.append("<tr class='list" + sClass + "' title='" + sSelectTran + "' onclick=\"setPrestationVariable('" + sUid + "','" + sCode + "','" + sDescr + "','" + sType + "','" + sPrice + "');\">")
		                        .append(" <td width='60px'>" + prestation.getUid() + "</td>")
		                        .append(" <td>" + sCode + "</td>")
		                        .append(" <td>" + sDescr + "</td>")
		                        .append(" <td>" + sTypeTran + "</td>")
		                        .append(" <td >" + prestation.getPriceFormatted(category) + "</td>")
		                        .append(" <td>" + checkString(prestation.getCategoriesFormatted(category)) + "</td>")
		                        .append("</tr>");
					}
					else {
		                sHtml.append("<tr class='list" + sClass + "' title='" + sSelectTran + "' onclick=\"setPrestation('" + sUid + "','" + sCode + "','" + sDescr + "','" + sType + "','" + sPrice + "');\">")
		                        .append(" <td width='60px'>" + prestation.getUid() + "</td>")
		                        .append(" <td>" + sCode + "</td>")
		                        .append(" <td>" + sDescr + "</td>")
		                        .append(" <td>" + sTypeTran + "</td>")
		                        .append(" <td >" + prestation.getPriceFormatted(category) + "</td>")
		                        .append(" <td>" + checkString(prestation.getCategoriesFormatted(category)) + "</td>")
		                        .append("</tr>");
					}
                }
            }

            if (recsFound) {
    %>
    <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0"
           style="border:1px solid #cccccc;">
        <%-- header --%>
        <tr class="admin">
            <td><%=HTMLEntities.htmlentities(getTran("web", "id", sWebLanguage))%>
            </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "code", sWebLanguage))%>
            </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "description", sWebLanguage))%>
            </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "type", sWebLanguage))%>
            </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "price", sWebLanguage))%> <%=
                HTMLEntities.htmlentities(sCurrency)%> </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "categories", sWebLanguage))%>
            </td>
        </tr>

        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
            <%=HTMLEntities.htmlentities(sHtml.toString())%>
        </tbody>
    </table>
    <%
    } else {
        // display 'no results' message
    %><%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%><%
        }
    }
}
catch(Exception e){
	e.printStackTrace();
}
%>
</div>
