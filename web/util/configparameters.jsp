<%@page import="java.io.*,org.dom4j.*,org.dom4j.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSTOOLTIP%>

<%!
    //--- CONTAINS VISIBLE PARAMETERS -------------------------------------------------------------
    private boolean containsVisibleParameters(Element group, boolean advanced){
	    boolean containsVisibleParams = false;

		Iterator parameters = group.elementIterator("parameter");
		Element parameter;
		while(parameters.hasNext()){
			parameter = (Element)parameters.next();
			
			if(!advanced){
				if(!checkString(parameter.attributeValue("class")).equalsIgnoreCase("advanced")){
					containsVisibleParams = true;
					break;
				}
			}
			else{
				containsVisibleParams = true;
				break;
			}
		}
	    
	    
	    return containsVisibleParams;
    }
%>

<%
    //*** SAVE ***
	if(request.getParameter("save")!=null){
		Enumeration ePars = request.getParameterNames();
		
		while(ePars.hasMoreElements()){
			String parameter = (String)ePars.nextElement();
			
			if(parameter.startsWith("par_")){
				// only save when value differs
				if(!MedwanQuery.getInstance().getConfigString(parameter.replace("par_","")).equals(request.getParameter(parameter))){
					MedwanQuery.getInstance().setConfigString(parameter.replace("par_",""),request.getParameter(parameter));
				}
			}
		}
	}
%>
    
<form name='configForm' method='post'>
	<span style="width:50%;text-align:left">
		<input type='checkbox' class="hand" value='1' name='advanced' id="advanced" onclick='configForm.submit();' style="vertical-align:-3px;" <%=checkString(request.getParameter("advanced")).equalsIgnoreCase("1")?"checked":"" %>/><label for="advanced" class="hand"><%=getTran("web","advanced",sWebLanguage)%></label></label>&nbsp;
		<input type='submit' class="button" name='save' value='<%=getTranNoLink("web","save",sWebLanguage)%>'/>
	</span>
	
	<%-- LINK TO BOTTOM --%>
	<span style="width:50%;text-align:right">
	    <a href="#bottom" class="bottombutton">&nbsp;</a>
	</span>
	    
	<table width='100%' cellpadding="0" cellspacing="1" class="list">
		<%-- header --%>
		<tr>
			<td class='admin' width="120">
			    <img src='<%=sCONTEXTPATH%>/_img/icons/icon_plus.png' OnClick='expandAll();' class="link">
                <img src='<%=sCONTEXTPATH%>/_img/icons/icon_minus.png' OnClick='collapseAll();' class="link">&nbsp;<%=getTran("web","name",sWebLanguage)%>&nbsp;
            </td>
			<td class='admin' width="250"><%=getTran("web","value",sWebLanguage)%>&nbsp;</td>
			<td class='admin' width="200"><%=getTran("web","default",sWebLanguage)%>&nbsp;</td>
			<td class='admin' width="400"><%=getTran("web","description",sWebLanguage)%>&nbsp;</td>
		</tr>
		
	<%
	    boolean advanced = checkString(request.getParameter("advanced")).equals("1");
	
		SAXReader reader = new SAXReader(false);
		Document document = reader.read(new URL(MedwanQuery.getInstance().getConfigString("templateSource") + "/configparameters.xml"));
		Element root = document.getRootElement();
		
		Element group, parameter, descrEl;
		Iterator parameters, descrIter;
		String sGroupClass, sGroupShow;
		int infoIconCount = 0;

		Iterator groups = root.elementIterator("parametergroup");
		while(groups.hasNext()){
			group = (Element)groups.next();
			Debug.println("\n"+checkString("############# GROUP : "+group.attributeValue("name"))+" #############");
			
			sGroupShow = checkString(group.attributeValue("show"));
			if(sGroupShow.equalsIgnoreCase("false")) continue; // do not show group

			sGroupClass = checkString(group.attributeValue("class"));
			if(!sGroupClass.equals("advanced") || advanced){
				if(containsVisibleParameters(group,advanced)){
					// header for each group
					out.print("<tr class='admin'>"+
					           "<td colspan='4'>"+
				                "<img class='link' id='Input_"+group.attributeValue("id")+"_S' name='Input_"+group.attributeValue("id")+"_S' border='0' src='"+sCONTEXTPATH+"/_img/icons/icon_plus.png' OnClick='showD(\"gr_"+group.attributeValue("id")+"\",\"Input_"+group.attributeValue("id")+"_S\",\"Input_"+group.attributeValue("id")+"_H\")' style='display:none;vertical-align:-2px'>"+
				                "<img class='link' id='Input_"+group.attributeValue("id")+"_H' name='Input_"+group.attributeValue("id")+"_H' border='0' src='"+sCONTEXTPATH+"/_img/icons/icon_minus.png' OnClick='hideD(\"gr_"+group.attributeValue("id")+"\",\"Input_"+group.attributeValue("id")+"_S\", \"Input_"+group.attributeValue("id")+"_H\")' style='vertical-align:-2px'>&nbsp;"+
							     (sGroupClass.equalsIgnoreCase("advanced")?"<font color='#ff9933'>":"")+group.attributeValue("name")+(sGroupClass.equalsIgnoreCase("advanced")?"</font>":"")+"&nbsp;"+
							    "</td>"+
				              "</tr>");
					
					// config-values
					out.print("<tbody id='gr_"+group.attributeValue("id")+"' name='gr_"+group.attributeValue("id")+"'>");
					
					parameters = group.elementIterator("parameter");

					//*** order by parameter-name ***
					Hashtable parameterHash = new Hashtable();
					String sName;
					while(parameters.hasNext()){
						parameter = (Element)parameters.next();						
						sName = checkString(parameter.attributeValue("name"));
						if(sName.length()==0) continue; // do not display empty parameters
						parameterHash.put(sName,parameter);
					}
					
					Vector parameterVector = new Vector(parameterHash.keySet());
					Collections.sort(parameterVector);
						
					//*** display parameters ***
					parameters = parameterVector.iterator();
					while(parameters.hasNext()){
						sName = (String)parameters.next();												
						parameter = (Element)parameterHash.get(sName);
						Debug.println(" "+sName);
						
						String sType = checkString(parameter.attributeValue("type")),
							   sDefaultValue = checkString(parameter.attributeValue("default")),
							   sClass = checkString(parameter.attributeValue("class")),
							   sOptions = checkString(parameter.attributeValue("options"));
																		
						//*** interprete xml to html ***
						if(!sClass.equalsIgnoreCase("advanced") || advanced){
							//*** look for description in weblanguage ***
							descrIter = parameter.elementIterator("description");
							String sDescription = "", sDescrLang;
							
							while(descrIter.hasNext()){
								descrEl = (Element)descrIter.next();
								sDescrLang = checkString(descrEl.attributeValue("language"));
								
								if(sDescrLang.length() > 0){
									if(sDescrLang.equalsIgnoreCase(sWebLanguage)){
										sDescription = checkString(descrEl.getText());
										
										sDescription = sDescription.replaceAll("\r\n",""); // no white lines
										sDescription = sDescription.replaceAll("\n",""); // no white lines
										sDescription = sDescription.replaceAll("\t"," "); // tap to space
										sDescription = sDescription.replaceAll("  "," "); // single spaces only
										sDescription = sDescription.replaceAll("  "," "); // single spaces only (second time)
										
										break;
									}
								}
								else{
									Debug.println("--- WARNING : Tag 'description' without attribute 'language'. ("+sName+")");
								}
							}
							
							// unit
							String sUnit = checkString(parameter.attributeValue("unit")); // id
							sUnit = getTran("web",sUnit,sWebLanguage); // label

     						String sModus = checkString(parameter.attributeValue("modus"));
							
							// stored value 
							String sStoredValue = checkString(MedwanQuery.getInstance().getConfigString(sName));
														
							//*** generate html ***
							out.print("<tr>");
								out.print("<td class='admin'>"+(sClass.equalsIgnoreCase("advanced")?"<font color='#ff6600'>":"")+sName+(sClass.equalsIgnoreCase("advanced")?"</font>":"")+"&nbsp;</td>");	
								out.print("<td class='admin2'>");
								
								//*** integer ***
								if(sType.equalsIgnoreCase("integer")){
									out.print("<input type='text' name='par_"+sName+"' id='par_"+sName+"' size='10' value='"+sStoredValue+"' onKeyUp=\"if(!isInteger(this))this.value='';\" "+(sStoredValue.length()==0&&sDefaultValue.length()>0?"style='background-color:#ff9999'":"")+"/>");
									if(sUnit.length() > 0) out.print(" "+sUnit);
								}
								//*** textarea ***
								else if(sType.equalsIgnoreCase("textarea")){
									out.print("<textarea onKeyup='resizeTextarea(this,10);limitChars(this,255);' class='text' cols='60' name='par_"+sName+"' id='par_"+sName+"' "+(sStoredValue.length()==0&&sDefaultValue.length()>0?"style='background-color:#ff9999'":"")+" "+(sModus.equalsIgnoreCase("readonly")?"readonly":"")+">"+sStoredValue+"</textarea>");
									if(sUnit.length() > 0) out.print(" "+sUnit);
								}
								//*** select ***
								else if(sType.equalsIgnoreCase("select")){
									out.print("<select name='par_"+sName+"' id='par_"+sName+"' class='text'>");
									
									String[] options = checkString(sOptions).split(";");
									for(int n=0; n<options.length; n++){
										out.print("<option value='"+options[n]+"' "+(options[n].equalsIgnoreCase(MedwanQuery.getInstance().getConfigString(sName,sDefaultValue))?"selected":"")+">"+options[n]+"</option>");
									}
									
									out.print("</select>");
									if(sUnit.length() > 0) out.print(" "+sUnit);
								}
								//*** radio ***
								else if(sType.equalsIgnoreCase("radio")){
									String[] options = checkString(sOptions).split(";");
									
									for(int n=0; n<options.length; n++){																		
										out.print("<input type='radio' class='hand' name='par_"+sName+"' id='par_"+sName+"_"+n+"' value='"+options[n]+"' "+(options[n].equalsIgnoreCase(MedwanQuery.getInstance().getConfigString(sName,sDefaultValue))?"checked":"")+">"+
									              "<label class='hand' for='par_"+sName+"_"+n+"'>"+options[n]+"</label>&nbsp;");	
									}
									if(sUnit.length() > 0) out.print(" "+sUnit);
								}
								//*** text (default) ***
								else{
									out.print("<input type='text' class='text' size='60' name='par_"+sName+"' id='par_"+sName+"' value='"+sStoredValue+"' "+(sStoredValue.length()==0&&sDefaultValue.length()>0?"style='background:#ff9999'":"")+" "+(sModus.equalsIgnoreCase("readonly")?"readonly":"")+"/>");
									if(sUnit.length() > 0) out.print(" "+sUnit);
								}
								out.print("</td>");
								
								out.print("<td class='admin2'>"+sDefaultValue+"</td>");
								out.print("<td class='admin2'>");
								if(sDescription.length() > 0){
									infoIconCount++;
									sDescription = sDescription.replaceAll("'","´");
								    out.print("<img class='link' src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' id='info_"+infoIconCount+"' tooltiptext='"+sDescription+"'/>");
								}
								out.print("</td>");
							out.print("</tr>");
					    }
					}
				}
				
				out.print("</tbody>");
			}
		}
	%>
	</table>
        
    <%-- BUTTONS --%>
    <center style="padding-top:10px;">
        <input type="submit" name="save" class="button" value='<%=getTranNoLink("web","save",sWebLanguage)%>'/>	
        <input type="button" name="backButton" class="button" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();">
    </center>
    
    <%-- LINK TO TOP --%>
    <span style="width:100%;text-align:right">
        <a href="#topp" class="topbutton">&nbsp;</a>
    </span>
</form>

<a name="bottom">&nbsp;</a>

<script>
function expandAll(){
  for(n=0; n<document.all.length; n++){
    if((document.all[n].id+"").indexOf('gr_')==0){
      document.all[n].style.display = "";
			
      var groupName = document.all[n].id.substr(3); 
      document.getElementById("Input_"+groupName+"_S").style.display = "none";
      document.getElementById("Input_"+groupName+"_H").style.display = "";
    }
  }
}	

function collapseAll(){
  for(n=0; n<document.all.length; n++){
    if((document.all[n].id+"").indexOf('gr_')==0){
      document.all[n].style.display = 'none';
			
      var groupName = document.all[n].id.substr(3);
      document.getElementById("Input_"+groupName+"_S").style.display = "";
      document.getElementById("Input_"+groupName+"_H").style.display = "none";
    }
  }
}

<%-- enable tooltips on info-icons --%>
window.onload = function(){
  var imgs = document.getElementsByTagName("img");
  
  for(var i=0; i<imgs.length; i++){
    if(imgs[i].id!=null && imgs[i].id.startsWith("info_")){
      enableTooltip(imgs[i].id);
    }
  }
};

<%-- DO BACK --%>
function doBack(){
  window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
}
</script>