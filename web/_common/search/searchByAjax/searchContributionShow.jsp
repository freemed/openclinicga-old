<%@page import="be.openclinic.finance.Prestation,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.finance.Insurance"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sAction = checkString(request.getParameter("Action"));

    String sFindPrestationRefName = checkString(request.getParameter("FindPrestationRefName")),
           sFindPrestationCode    = checkString(request.getParameter("FindPrestationCode")),
           sFindPrestationDescr   = checkString(request.getParameter("FindPrestationDescr")),
           sFindPrestationType    = checkString(request.getParameter("FindPrestationType")),
 		   sFindPrestationSort    = request.getParameter("FindPrestationSort")!=null?request.getParameter("FindPrestationSort"):"OC_PRESTATION_CODE",
           sFindPrestationPrice   = checkString(request.getParameter("FindPrestationPrice"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldUid   = checkString(request.getParameter("ReturnFieldUid")),
           sReturnFieldCode  = checkString(request.getParameter("ReturnFieldCode")),
           sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr")),
           sReturnFieldType  = checkString(request.getParameter("ReturnFieldType")),
           sReturnFieldPrice = checkString(request.getParameter("ReturnFieldPrice"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* _common/search/searchByAjax/searchContributionShow.jsp *************");
        Debug.println("sAction                : "+sAction);
        Debug.println("sFindPrestationRefName : "+sFindPrestationRefName);
        Debug.println("sFindPrestationCode    : "+sFindPrestationCode);
        Debug.println("sFindPrestationDescr   : "+sFindPrestationDescr);
        Debug.println("sFindPrestationType    : "+sFindPrestationType);
        Debug.println("sFindPrestationPrice   : "+sFindPrestationPrice);
        Debug.println("sFunction              : "+sFunction+"\n");
        
        Debug.println("sReturnFieldUid   : "+sReturnFieldUid);
        Debug.println("sReturnFieldCode  : "+sReturnFieldCode);
        Debug.println("sReturnFieldDescr : "+sReturnFieldDescr);
        Debug.println("sReturnFieldType  : "+sReturnFieldType);
        Debug.println("sReturnFieldPrice : "+sReturnFieldPrice+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////

    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
%>

<div class="search">
<%
    if(sAction.equals("search")){
        Vector foundPrestations = Prestation.searchPrestations(sFindPrestationCode,sFindPrestationDescr.replaceAll("e",MedwanQuery.getInstance().getConfigString("equivalentofe","[eéèê]")).replaceAll("a",MedwanQuery.getInstance().getConfigString("equivalentofa","[aàá]")),
                                                               sFindPrestationType,sFindPrestationPrice,"",sFindPrestationSort);
        Iterator prestationsIter = foundPrestations.iterator();

        String sClass = "", sUid, sCode, sDescr, sType, sTypeTran, sPrice;
        String sSelectTran = getTranNoLink("web","select",sWebLanguage);
        int recCount = 0;
        StringBuffer sHtml = new StringBuffer();
        Prestation prestation;
        
        String category = "";
        Insurance insurance = activePatient!=null?Insurance.getMostInterestingInsuranceForPatient(checkString(activePatient.personid)):null;
        if(insurance!=null){
            category = insurance.getType();
        }

        while(prestationsIter.hasNext()){
            prestation = (Prestation)prestationsIter.next();
            
            if(prestation.getType().equalsIgnoreCase("con.openinsurance")){
                recCount++;

                // names
                sUid = prestation.getUid();
                sCode = checkString(prestation.getCode());
                sDescr = checkString(prestation.getDescription());

                // type
                sType = checkString(prestation.getType());
                sTypeTran = getTran("prestation.type",sType,sWebLanguage);

                // price
                double price = prestation.getPrice();
                if(price==0) sPrice = "";
                else         sPrice = price+"";

                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                sHtml.append("<tr class='list"+sClass+"' title='"+sSelectTran+"' onclick=\"setPrestation('"+sUid+"','"+sCode+"','"+sDescr+"','"+sType+"','"+sPrice+"');\">")
                      .append("<td width='60px'>"+prestation.getUid()+"</td>")
                      .append("<td>"+sCode+"</td>")
                      .append("<td>"+sDescr+"</td>")
                      .append("<td>"+sTypeTran+"</td>")
                      .append("<td nowrap>"+prestation.getPriceFormatted(category)+"</td>")
                      .append("<td>"+checkString(prestation.getCategoriesFormatted(category))+"</td>")
                     .append("</tr>");
            }
        }

        if(recCount > 0){
	        %>
	        <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0" style="border:1px solid #ccc;">
		        <%-- header --%>
		        <tr class="admin">
		            <td><%=HTMLEntities.htmlentities(getTran("web","id",sWebLanguage))%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","code",sWebLanguage))%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","description",sWebLanguage))%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","price",sWebLanguage))%> <%=HTMLEntities.htmlentities(sCurrency)%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","categories",sWebLanguage))%></td>
		        </tr>
		
		        <tbody class="hand"><%=HTMLEntities.htmlentities(sHtml.toString())%></tbody>
	        </table>
            
            <%=recCount%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
		    
		    <script>sortables_init();</script>
	        <%
	    } 
	    else{
            %><%=HTMLEntities.htmlentities(getTran("web","norecordsfound",sWebLanguage))%><%
        }
    }
%>
</div>