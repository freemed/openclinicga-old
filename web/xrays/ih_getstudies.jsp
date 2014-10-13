<%@ page import="java.util.*,org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,org.apache.commons.httpclient.methods.multipart.*,java.io.*,org.dom4j.*,org.dom4j.io.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<head>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSDATE%>
    <%=sJSPOPUPSEARCH%>
    <%=sJSDROPDOWNMENU%>
    <%=sJSPROTOTYPE%>
    <%=sJSNUMBER%>
    <%=sJSTOGGLE%>
</head>
<table width='100%'>
	<tr>
		<td class='imagehub' colspan='3'>&nbsp</td>
	</tr>
	<tr class='admin'>
		<td><%=getTran("web","date",sWebLanguage)%></td>
		<td><%=getTran("web","study.modality",sWebLanguage)%></td>
		<td><%=getTran("web","study.name",sWebLanguage)%></td>
	</tr>
<%
	//Eerst ImageHub contacteren en studielijst opvragen
	//PatientID = serverid + personid
	//Voor demo: comment5
	String patientId = activePatient.comment5;
	if(patientId.length()==0){
		patientId=MedwanQuery.getInstance().getConfigString("imageHubServerId","0")+"."+activePatient.personid;
	}
	String securityCode = MedwanQuery.getInstance().getConfigString("imageHubGetStudiesSecurityCode","1234");
	String imageHubURL = MedwanQuery.getInstance().getConfigString("imageHubGetStudiesURL","https://imagehub.aexist.nl/imagehub/rest/demo");

	HttpClient client = new HttpClient();
	PostMethod method = new PostMethod(imageHubURL);
	method.addRequestHeader("content-type", "application/xml");
	org.dom4j.Document document = DocumentHelper.createDocument();
	Element root = DocumentHelper.createElement("get_studies");
	root.addAttribute("xmlns", "imagehub");
	root.addAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
	document.setRootElement(root);
	Element element = root.addElement("security_code");
	element.setText(securityCode);
	element = root.addElement("patient_id");
	element.setText(patientId);
	element = root.addElement("user_id");
	element.setText("1234");
	method.setRequestBody(new ByteArrayInputStream(document.asXML().getBytes("UTF-8")));
	int statusCode = client.executeMethod(method);
	if(statusCode==200){
		String resp = method.getResponseBodyAsString();
		BufferedReader br = new BufferedReader(new StringReader(resp));
		SAXReader reader=new SAXReader(false);
		document=reader.read(br);
		root = document.getRootElement();
		Element studies = root.element("studies");
		if(studies!=null){
			Iterator iStudies = studies.elementIterator("study");
			while(iStudies.hasNext()){
				Element study = (Element)iStudies.next();
				out.println("<tr>");
				out.println("<td class='admin'>"+study.elementText("study_date")+" "+study.elementText("study_time")+"</td>");
				out.println("<td class='admin2'>"+study.elementText("modality")+"</td>");
				out.println("<td class='admin2'><a href='javascript:openstudy(\""+study.elementText("study_id")+"\")'>"+study.elementText("study_name")+"</a></td>");
				out.println("</tr>");
			}
		}
		else {
			out.println("<tr>");
			out.println("<td class='admin2' colspan='3'>"+root.elementText("return_description")+"</td>");
			out.println("</tr>");
		}
	}
	else {
		out.println("Error reading from ImageHub");
	}
%>
</table>
<form id='imageHubForm' target='hidden-form' method='POST' action='<%=MedwanQuery.getInstance().getConfigString("imageHubGetStudyURL","https://imagehub.aexist.nl/imagehub/view_study")%>'>
	<input type='hidden' name='security_code' value='<%=MedwanQuery.getInstance().getConfigString("imageHubGetStudySecurityCode","q48FfCyeuOy1oeR")%>'/>
	<input type='hidden' name='studyUID' id='studyUID' value=''/>
</form>
<IFRAME style="display:none" name="hidden-form"></IFRAME>
<script>
	function openstudy(studyid){
		document.getElementById('studyUID').value=studyid;
		document.getElementById('imageHubForm').submit();
	}
	
    window.moveTo((screen.width-w)/2,(screen.height-h)/2);

</script>
