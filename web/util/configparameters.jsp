<%@ page import="java.io.*,org.dom4j.*,org.dom4j.io.*" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
	if(request.getParameter("save")!=null){
		Enumeration ePars = request.getParameterNames();
		while (ePars.hasMoreElements()){
			String parameter = (String)ePars.nextElement();
			if(parameter.startsWith("par_")){
				if(!MedwanQuery.getInstance().getConfigString(parameter.replace("par_", "")).equals(request.getParameter(parameter))){
					MedwanQuery.getInstance().setConfigString(parameter.replace("par_", ""), request.getParameter(parameter));
				}
			}
		}
	}
%>
<form name='configForm' method='post'>
	<input type='checkbox' value='1' name='advanced' onclick='configForm.submit();' <%=checkString(request.getParameter("advanced")).equalsIgnoreCase("1")?"checked":"" %>/><%=getTran("web","advanced",sWebLanguage) %>
	<input type='submit' name='save' value='<%=getTran("web","save",sWebLanguage) %>'/>
	<table width='100%'>
		<tr class='admin'>
			<td>
            <a href='#'><img src='<%=sCONTEXTPATH%>/_img/plus.png' OnClick='expandAll();' ></a>
            <a href='#'><img src='<%=sCONTEXTPATH%>/_img/minus.png' OnClick='collapseAll()'></a>
			Name</td>
			<td>Value</td>
			<td>Default value</td>
			<td>Description</td>
		</tr>
	<%
		SAXReader reader = new SAXReader(false);
		Document document = reader.read(new URL(MedwanQuery.getInstance().getConfigString("templateSource") + "/configparameters.xml"));
		Element root = document.getRootElement();
		Iterator groups = root.elementIterator("parametergroup");
		while (groups.hasNext()){
			Element group = (Element)groups.next();
			out.println("<tr class='admin'><td colspan='4'>"+
	                "<a href='#'><img id='Input_"+group.attributeValue("id")+"_S' name='Input_"+group.attributeValue("id")+"_S' border='0' src='"+sCONTEXTPATH+"/_img/plus.png' OnClick='showD(\"gr_"+group.attributeValue("id")+"\",\"Input_"+group.attributeValue("id")+"_S\",\"Input_"+group.attributeValue("id")+"_H\")' ></a>"+
	                "<a href='#'><img id='Input_"+group.attributeValue("id")+"_H' name='Input_"+group.attributeValue("id")+"_H' border='0' src='"+sCONTEXTPATH+"/_img/minus.png' OnClick='hideD(\"gr_"+group.attributeValue("id")+"\",\"Input_"+group.attributeValue("id")+"_S\", \"Input_"+group.attributeValue("id")+"_H\")' style='display:none'></a>"+
					group.attributeValue("name")+"</td></tr><tbody id='gr_"+group.attributeValue("id")+"' name='gr_"+group.attributeValue("id")+"'>");
			Iterator parameters = group.elementIterator("parameter");
			while(parameters.hasNext()){
				Element parameter = (Element)parameters.next();
				String name = parameter.attributeValue("name");
				String type = parameter.attributeValue("type");
				String defaultValue = parameter.attributeValue("default");
				String advanced=parameter.attributeValue("class");
				String options=parameter.attributeValue("options");
				if(advanced.equalsIgnoreCase("basic") || checkString(request.getParameter("advanced")).equalsIgnoreCase("1")){
					out.println("<tr><td class='admin'>"+name+"</td>");
					if(type.equalsIgnoreCase("integer")){
						out.println("<td class='admin2'><input type='text' name='par_"+name+"' id='par_"+name+"' value='"+MedwanQuery.getInstance().getConfigString(name,"")+"'/></td>");
					}
					else if(type.equalsIgnoreCase("textarea")){
						out.println("<td class='admin2'><textarea onKeyup='resizeTextarea(this,10);limitChars(this,255);' cols='60' name='par_"+name+"' id='par_"+name+"'>"+MedwanQuery.getInstance().getConfigString(name,"")+"</textarea></td>");
					}
					else if(type.equalsIgnoreCase("select")){
						out.println("<td class='admin2'><select name='par_"+name+"' id='par_"+name+"'>"+MedwanQuery.getInstance().getConfigString(name,"")+">");
						for(int n=0;n<checkString(options).split(";").length;n++){
							out.println("<option value='"+checkString(options).split(";")[n]+"' "+(checkString(options).split(";")[n].equalsIgnoreCase(MedwanQuery.getInstance().getConfigString(name,defaultValue))?"selected":"")+">"+checkString(options).split(";")[n]+"</option>");
						}
						out.println("</select></td>");
					}
					else {
						out.println("<td class='admin2'><input type='text' size='80' name='par_"+name+"' id='par_"+name+"' value='"+MedwanQuery.getInstance().getConfigString(name,"")+"'/></td>");
					}
					out.println("<td class='admin2'>"+defaultValue+"</td>");
					out.println("<td class='admin2'>"+getTran("config.description",name,sWebLanguage)+"</td></tr>");
				}	
			}
			out.println("</tbody>");
		}
	%>
	</table>
</form>

<script>
function expandAll(){
	for(n=0;n<document.all.length;n++){
		if((document.all[n].id+"").indexOf('gr_')>=0){
			document.all[n].style.display='';
		}
	}
}	
function collapseAll(){
	for(n=0;n<document.all.length;n++){
		if((document.all[n].id+"").indexOf('gr_')>=0){
			document.all[n].style.display='none';
		}
	}
}
</script>