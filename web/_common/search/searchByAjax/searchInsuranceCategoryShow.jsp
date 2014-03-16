<%@ page import="be.openclinic.finance.Wicket,java.util.Vector" %>
<%@ page import="be.openclinic.finance.Insurar" %>
<%@ page import="be.openclinic.finance.InsuranceCategory,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
   String sFindInsurarName = checkString(request.getParameter("FindInsurarName"));


%>

                        <table border='0' width='100%' cellspacing="1" cellpadding="0">
                            <%
                                if(sFindInsurarName.length()>0){
                                    Vector vInsurars = Insurar.getInsurarsByName(sFindInsurarName);
                                    String sClass = "", sInsurarUID = "";
                                    boolean recsFound = false;
                                    StringBuffer results = new StringBuffer();

                                    if (vInsurars.size() > 0) {
                                        Iterator iter = vInsurars.iterator();
                                        Insurar objInsurar;
                                        while (iter.hasNext()) {
                                            objInsurar = (Insurar) iter.next();
                                            if(!checkString(request.getParameter("Active")).equalsIgnoreCase("1") || objInsurar.getInactive()==0){
	                                            recsFound = true;
	                                            if(objInsurar!=null && objInsurar.getInsuraceCategories()!=null && (objInsurar.getContact()==null || !objInsurar.getContact().equals("plan.openinsurance"))){
		                                            String cats = "";
		                                            for (int n = 0; n < objInsurar.getInsuraceCategories().size(); n++) {
		                                                InsuranceCategory insCat=(InsuranceCategory)objInsurar.getInsuraceCategories().elementAt(n);
		                                                if (n > 0) {
		                                                    cats += "<br/>";
		                                                }
		                                                cats += "<a href=\"javascript:setInsuranceCategory('" + insCat.getCategory() + "', '" + objInsurar.getUid()+"','" + objInsurar.getName().toUpperCase() + "','" +insCat.getCategory()+": "+insCat.getLabel()+"','"+objInsurar.getType()+"','"+getTran("insurance.types",objInsurar.getType(),sWebLanguage)+"');\">" +
		                                                        insCat.getCategory()+" ("+insCat.getLabel()+" - "+insCat.getPatientShare()+"/"+(100-Integer.parseInt(insCat.getPatientShare()))+")</a>";
		                                            }
		                                            
		                                            // alternate row-style
		                                            if (sClass.equals("")) sClass = "1";
		                                            else                   sClass = "";
	
		                                            results.append("<tr class='list" + sClass + "'>")
		                                                    .append("<td>" + objInsurar.getName().toUpperCase() + "</td>")
		                                                    .append("<td>" + cats + "</td>")
		                                                   .append("</tr>");
	                                            }
                                            }
                                        }

                                        if (recsFound) {
                                %>
                                                <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                                    <tr class="admin">
                                                        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web","name",sWebLanguage))%></td>
                                                        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web","category",sWebLanguage))%></td>
                                                    </tr>

                                                    <%=HTMLEntities.htmlentities(results.toString())%>
                                                </tbody>
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
                                }
                            %>
                        </table>
