<%@page import="java.io.*,org.dom4j.*,org.dom4j.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    //*** SAVE ***
	if(request.getParameter("save")!=null){
		Enumeration ePars = request.getParameterNames();
		
		while(ePars.hasMoreElements()){
			String parameter = (String)ePars.nextElement();
			
			if(parameter.startsWith("par_")){
				// only save when value differs
				if(!MedwanQuery.getInstance().getConfigString(parameter.replace("par_", "")).equals(request.getParameter(parameter))){
					MedwanQuery.getInstance().setConfigString(parameter.replace("par_", ""), request.getParameter(parameter));
				}
			}
		}
	}
%>

<form name='configForm' method='post'>
	<input type='checkbox' value='1' name='advanced' id="advanced" onclick='configForm.submit();' style="vertical-align:-3px;" <%=checkString(request.getParameter("advanced")).equalsIgnoreCase("1")?"checked":"" %>/><%=getLabel("web","advanced",sWebLanguage,"advanced")%>&nbsp;
	<input type='submit' class="button" name='save' value='<%=getTran("web","save",sWebLanguage)%>'/>
	
	<table width='100%' cellpadding="0" cellspacing="1" class="admin">
		<%-- header --%>
		<tr class='admin'>
			<td width="120">
			    <a href='#'><img src='<%=sCONTEXTPATH%>/_img/plus.png' OnClick='expandAll();' class="link"></a>
                <a href='#'><img src='<%=sCONTEXTPATH%>/_img/minus.png' OnClick='collapseAll()' class="link"></a>&nbsp;<%=getTran("web","name",sWebLanguage)%>&nbsp;
            </td>
			<td width="250"><%=getTran("web","value",sWebLanguage)%>&nbsp;</td>
			<td width="250"><%=getTran("web","default",sWebLanguage)%>&nbsp;</td>
			<td width="50"><%=getTran("web","description",sWebLanguage)%>&nbsp;</td>
		</tr>
		
	<%
		SAXReader reader = new SAXReader(false);
		Document document = reader.read(new URL(MedwanQuery.getInstance().getConfigString("templateSource") + "/configparameters.xml"));
		Element root = document.getRootElement();
		Iterator groups = root.elementIterator("parametergroup");
		
		while(groups.hasNext()){
			Element group = (Element)groups.next();

			String sGroupClass = checkString(group.attributeValue("class"));
					
			if(!sGroupClass.equals("advanced") || checkString(request.getParameter("advanced")).equals("1")){
				// header for each config-value-group
				out.print("<tr class='admin'>"+
				           "<td colspan='4'>"+
			                "<a href='#'><img class='link' id='Input_"+group.attributeValue("id")+"_S' name='Input_"+group.attributeValue("id")+"_S' border='0' src='"+sCONTEXTPATH+"/_img/plus.png' OnClick='showD(\"gr_"+group.attributeValue("id")+"\",\"Input_"+group.attributeValue("id")+"_S\",\"Input_"+group.attributeValue("id")+"_H\")' style='display:none;vertical-align:-3px'></a>"+
			                "<a href='#'><img class='link' id='Input_"+group.attributeValue("id")+"_H' name='Input_"+group.attributeValue("id")+"_H' border='0' src='"+sCONTEXTPATH+"/_img/minus.png' OnClick='hideD(\"gr_"+group.attributeValue("id")+"\",\"Input_"+group.attributeValue("id")+"_S\", \"Input_"+group.attributeValue("id")+"_H\")' style='vertical-align:-3px'></a>&nbsp;"+
						     (sGroupClass.equalsIgnoreCase("advanced")?"<font color='#ff9933'>":"")+group.attributeValue("name")+(sGroupClass.equalsIgnoreCase("advanced")?"</font>":"")+"&nbsp;"+
						    "</td>"+
			              "</tr>");
				
				// config-values
				out.print("<tbody id='gr_"+group.attributeValue("id")+"' name='gr_"+group.attributeValue("id")+"'>");
				
				Iterator parameters = group.elementIterator("parameter");
				Element parameter;
				while(parameters.hasNext()){
					parameter = (Element)parameters.next();
					
					String sName = checkString(parameter.attributeValue("name")),
						   sType = checkString(parameter.attributeValue("type")),
						   sDefaultValue = checkString(parameter.attributeValue("default")),
						   sClass = checkString(parameter.attributeValue("class")),
						   sOptions = checkString(parameter.attributeValue("options"));
					
					// look for description in weblanguage
					Iterator descrIter = parameter.elementIterator("description");
					String sDescription = "";
					Element descrEl;
					
					while(descrIter.hasNext()){
						descrEl = (Element)descrIter.next();
						if(descrEl.attributeValue("language").equalsIgnoreCase(sWebLanguage)){
							sDescription = checkString(descrEl.getText());
							break;
						}
					}
					
					if(!sClass.equalsIgnoreCase("advanced") || checkString(request.getParameter("advanced")).equalsIgnoreCase("1")){
						out.print("<tr><td class='admin'>"+sName+"&nbsp;</td>");
	
						out.print("<td class='admin2'>");
						if(sType.equalsIgnoreCase("integer")){
							out.print("<input type='text' name='par_"+sName+"' id='par_"+sName+"' value='"+MedwanQuery.getInstance().getConfigString(sName,"")+"'/>");
						}
						else if(sType.equalsIgnoreCase("textarea")){
							out.print("<td class='admin2'><textarea onKeyup='resizeTextarea(this,10);limitChars(this,255);' cols='60' name='par_"+sName+"' id='par_"+sName+"'>"+MedwanQuery.getInstance().getConfigString(sName,"")+"</textarea>");
						}
						else if(sType.equalsIgnoreCase("select")){
							out.print("<select name='par_"+sName+"' id='par_"+sName+"'>"+MedwanQuery.getInstance().getConfigString(sName,"")+">");
							for(int n=0;n<checkString(sOptions).split(";").length;n++){
								out.print("<option value='"+checkString(sOptions).split(";")[n]+"' "+(checkString(sOptions).split(";")[n].equalsIgnoreCase(MedwanQuery.getInstance().getConfigString(sName,sDefaultValue))?"selected":"")+">"+checkString(sOptions).split(";")[n]+"</option>");
							}
							out.print("</select>");
						}
						else{
							out.print("<input type='text' size='80' name='par_"+sName+"' id='par_"+sName+"' value='"+MedwanQuery.getInstance().getConfigString(sName,"")+"'/>");
						}
						out.print("</td>");
						
						out.print("<td class='admin2'>"+sDefaultValue+"</td>");
						out.print("<td class='admin2'>");
						if(sDescription.length() > 0){
							sDescription = sDescription.replaceAll("'","´");
						    out.print("<img class='link' src='"+sCONTEXTPATH+"/_img/icon_info.gif' title='"+sDescription+"'/>");
						}
						out.print("</td></tr>");
					}	
				}
				
				out.println("</tbody>");
			}
		}
	%>
	</table>
        
    <%-- BUTTONS --%>
    <center style="padding-top:5px;">
        <input type="button" name="saveButton" class="button" value="<%=getTran("Web","save",sWebLanguage)%>" onClick="configForm.submit()">
        <input type="button" name="backButton" class="button" value="<%=getTran("Web","back",sWebLanguage)%>" onClick="doBack();">
    </center>
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

function doBack(){
  window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
}
</script>