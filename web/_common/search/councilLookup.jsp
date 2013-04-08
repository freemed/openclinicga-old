<%@ page import="java.io.*,sun.misc.*,be.mxs.common.util.io.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,be.openclinic.finance.*,be.openclinic.adt.*" %>
<%@ include file="/includes/validateUser.jsp" %>
<table width='100%'>
<%
	HttpClient client = new HttpClient();
	String language=request.getParameter("language");
	String lookupUrl=getTran("professional.council.url",request.getParameter("council"),language);
	PostMethod method = new PostMethod(lookupUrl);
	method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
	NameValuePair nvp1= new NameValuePair("regnr",request.getParameter("regnr"));
	NameValuePair nvp2= new NameValuePair("key",MedwanQuery.getInstance().getConfigString("councilLookupKey"));
	method.setQueryString(new NameValuePair[]{nvp1,nvp2});
	int userid = 0;
	if(request.getParameter("userid")!=null){
		userid=Integer.parseInt(request.getParameter("userid"));
	}
	try{
		int statusCode = client.executeMethod(method);
		System.out.println("status code = "+statusCode);
		if(statusCode==200){
			String xml = method.getResponseBodyAsString();
			org.dom4j.Document document=null;
			Element root=null;
			BufferedReader r = new BufferedReader(new StringReader(xml));
			SAXReader reader=new SAXReader(false);
			document=reader.read(r);
			System.out.println(document.asXML());
			root=document.getRootElement();
			if(root.getName().equalsIgnoreCase("registration")){
				out.println("<tr class='admin'><td colspan='2'>"+getTran("Web.UserProfile","organisationId",language)+"</td><td colspan='2'>"+root.attributeValue("id")+"</td></tr>");
				Element element = root.element("status");
				if(element!=null){
					User user = User.get(userid);
					if(user !=null && !user.getParameter("registrationstatus").equalsIgnoreCase(element.attributeValue("id"))){
						user.updateParameter(new Parameter("registrationstatus",element.attributeValue("id")));
						user.updateParameter(new Parameter("registrationstatusdate",new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())));
						
					}
					if(user !=null){
						user.updateParameter(new Parameter("registrationstatusupdatetime",new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())));
						user = User.get(userid);
						out.println("<script>window.opener.document.getElementById('registrationstatus').innerHTML='"+(user.getParameter("registrationstatus").equalsIgnoreCase("0")?"<img src=\""+sCONTEXTPATH+"/_img/checked.png\"/>":"<img src=\""+sCONTEXTPATH+"/_img/icon_error.jpg\"/>")+" <b>"+getTranNoLink("lookup","status."+user.getParameter("registrationstatus"),language)+" ("+user.getParameter("registrationstatusupdatetime")+")</b>';</script>");
					}
					if(element.attributeValue("id").equalsIgnoreCase("0")||element.attributeValue("id").equalsIgnoreCase("-2")){
						out.println("<tr><td class='admin'>"+getTran("lookup","status",language)+"</td><td bgcolor='"+(element.attributeValue("id").equalsIgnoreCase("-2")?"red":"lightgreen")+"'>"+getTran("lookup","status."+element.attributeValue("id"),language)+"</td>");
						out.println("<td class='admin'>"+getTran("web","nationality",language)+"</td><td class='admin2'>"+root.elementText("nationality").toUpperCase().replaceAll("COUNTRY.","")+"</td></tr>");
						out.println("<tr><td class='admin'>"+getTran("web","lastname",language)+(root.elementText("lastname").equalsIgnoreCase(activePatient.lastname)?"":" <img src='"+sCONTEXTPATH+"/_img/warning.gif'>")+"</td><td class='admin2'>"+root.elementText("lastname").toUpperCase()+"</td>");
						out.println("<td class='admin'>"+getTran("web","firstname",language)+(root.elementText("firstname").equalsIgnoreCase(activePatient.firstname)?"":" <img src='"+sCONTEXTPATH+"/_img/warning.gif'>")+"</td><td class='admin2'>"+root.elementText("firstname")+"</td></tr>");
						out.println("<tr><td class='admin'>"+getTran("web","gender",language)+"</td><td class='admin2'>"+root.elementText("gender").toUpperCase()+"</td>");
						out.println("<td class='admin'>"+getTran("web","dateofbirth",language)+"</td><td class='admin2'>"+root.elementText("dateofbirth")+"</td></tr>");
						if(element.attributeValue("id").equalsIgnoreCase("0")){
							element=root.element("contact");
							if(element!=null){
								out.println("<tr class='admin'><td colspan='4'>"+getTran("web","contact",language).toUpperCase()+"</td></tr>");
								out.println("<tr><td class='admin'>"+getTran("web","address",language)+"</td><td class='admin2'>"+element.elementText("address")+"</td>");
								out.println("<td class='admin'>"+getTran("web","pobox",language)+"</td><td class='admin2'>"+element.elementText("pobox")+"</td></tr>");
								out.println("<tr><td class='admin'>"+getTran("web","district",language)+"</td><td class='admin2'>"+element.elementText("district")+"</td>");
								out.println("<td class='admin'>"+getTran("web","province",language)+"</td><td class='admin2'>"+element.elementText("province")+"</td></tr>");
								out.println("<tr><td class='admin'>"+getTran("web","country",language)+"</td><td class='admin2'>"+element.elementText("country")+"</td>");
								out.println("<td class='admin'>"+getTran("web","email",language)+"</td><td class='admin2'>"+element.elementText("email")+"</td></tr>");
								out.println("<tr><td class='admin'>"+getTran("web","phone",language)+"</td><td class='admin2'>"+element.elementText("phone")+"</td>");
								out.println("<td class='admin'>"+getTran("web","cellphone",language)+"</td><td class='admin2'>"+element.elementText("cellphone")+"</td></tr>");
							}
							Iterator elements=root.elementIterator("work");
							if(elements.hasNext()){
								out.println("<tr class='admin'><td colspan='4'>"+getTran("lookup","work",language).toUpperCase()+"</td></tr>");
							}
							while(elements.hasNext()){
								element = (Element)elements.next();
								out.println("<tr class='admin'><td colspan='2'>"+getTran("web","period",language)+"</td><td colspan='2'>"+element.attributeValue("start")+" - "+checkString(element.attributeValue("end"))+"</td></tr>");
								out.println("<tr><td class='admin'> "+getTran("web","specialty",language)+"</td><td class='admin2'>"+element.elementText("specialty")+"</td>");
								out.println("<td class='admin'>"+getTran("web","function",language)+"</td><td class='admin2'>"+element.elementText("function")+"</td></tr>");
								out.println("<tr><td class='admin'> "+getTran("web","healthfacility",language)+"</td><td class='admin2'>"+element.elementText("healthfacility").toUpperCase()+"</td>");
								out.println("<td class='admin'> "+getTran("web","category",language)+"</td><td class='admin2'>"+element.elementText("category")+"</td></tr>");
							}
							elements=root.elementIterator("training");
							if(elements.hasNext()){
								out.println("<tr class='admin'><td colspan='4'>"+getTran("lookup","training",language).toUpperCase()+"</td></tr>");
							}
							while(elements.hasNext()){
								element = (Element)elements.next();
								out.println("<tr class='admin'><td colspan='2'>"+getTran("web","period",language)+"</td><td colspan='2'>"+element.attributeValue("start")+" - "+checkString(element.attributeValue("end"))+"</td></tr>");
								out.println("<tr><td class='admin'> "+getTran("lookup","center",language)+"</td><td class='admin2'>"+element.elementText("center")+"</td>");
								out.println("<td class='admin'>"+getTran("web","address",language)+"</td><td class='admin2'>"+element.elementText("address")+"</td></tr>");
								out.println("<tr><td class='admin'> "+getTran("web","country",language)+"</td><td class='admin2' colspan='3'>"+element.elementText("country").toUpperCase().replaceAll("COUNTRY.","")+"</td></tr>");
								out.println("<tr><td class='admin'> "+getTran("web","diploma",language)+"</td><td class='admin2'>"+element.elementText("diploma")+"</td>");
								out.println("<td class='admin'>"+getTran("web","diplomadate",language)+"</td><td class='admin2'>"+element.elementText("diplomadate")+"</td></tr>");
							}
							elements=root.elementIterator("cpd");
							if(elements.hasNext()){
								out.println("<tr class='admin'><td colspan='4'>"+getTran("lookup","cpd",language).toUpperCase()+"</td></tr>");
							}
							while(elements.hasNext()){
								element = (Element)elements.next();
								out.println("<tr><td class='admin'> "+getTran("web","year.and.category",language)+"</td><td class='admin2'>"+element.attributeValue("year")+" / "+element.attributeValue("category")+"</td>");
								out.println("<td class='admin'>"+getTran("web","credits",language)+"</td><td class='admin2'>"+element.attributeValue("credits")+"</td></tr>");
							}
						}
					}
					else{
						out.println("<tr><td class='admin'>"+getTran("lookup","status",language)+"</td><td colspan='3' bgcolor='red'>"+getTran("lookup","status."+element.attributeValue("id"),language)+"</td></tr>");
					}
				}
				else {
					out.println("<tr><td>"+root.getText()+"</td></tr>");
				}
			}
			else {
				out.println("<tr><td>"+xml+"</td></tr>");
			}
		}
		else {
			out.println("<tr><td>"+method.getStatusLine()+"</td></tr>");
		}
	}
	catch(Exception e){
		out.println("<tr><td>"+e.getMessage()+"</td></tr>");
	}
%>
</table>