<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr>
			<td class='admin'>
				<input type='radio' name='tabletype' value="singlelanguage"/><%=getTran("web","singlelanguage",sWebLanguage) %>
			</td>
			<td class='admin2'>
				<%
					String[] supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages").split(",");
					
					out.println(getTran("web","language",sWebLanguage)+": ");
					for(int n=0;n<supportedLanguages.length;n++){
						out.println("<input type='radio' name='singlelanguage_language' value='"+supportedLanguages[n]+"'/>"+getTran("web.language",supportedLanguages[n],sWebLanguage));
					}
				%>
			</td>
		</tr>
		<tr>
			<td class='admin'>
				<input type='radio' name='tabletype' value="multilanguage"/><%=getTran("web","multilanguage",sWebLanguage) %>
			</td>
			<td class='admin2'>
				<%
					out.println(getTran("web","languages",sWebLanguage)+": ");
					for(int n=0;n<supportedLanguages.length;n++){
						out.println("<input type='checkbox' name='singlelanguage_language_"+supportedLanguages[n]+"' value='"+supportedLanguages[n]+"'/>"+getTran("web.language",supportedLanguages[n],sWebLanguage));
					}
				%>
			</td>
		</tr>
		<tr>
			<td class='admin'>
				<input type='radio' name='tabletype' value="missinglabels"/><%=getTran("web","missinglabels",sWebLanguage) %>
			</td>
			<td class='admin2'>
				<%
					out.println(getTran("web","targetlanguage",sWebLanguage)+": ");
					for(int n=0;n<supportedLanguages.length;n++){
						out.println("<input type='radio' name='targetlanguage_language' value='"+supportedLanguages[n]+"'/>"+getTran("web.language",supportedLanguages[n],sWebLanguage));
					}
				%>
				<BR/>
				<%
					out.println(getTran("web","sourcelanguages",sWebLanguage)+": ");
					for(int n=0;n<supportedLanguages.length;n++){
						out.println("<input type='checkbox' name='sourcelanguage_language_"+supportedLanguages[n]+"' value='"+supportedLanguages[n]+"'/>"+getTran("web.language",supportedLanguages[n],sWebLanguage));
					}
				%>
			</td>
		</tr>
		<tr>
			<td colspan='2'><input type='button' name='button' value='<%=getTranNoLink("web","export",sWebLanguage)%>' onclick='exporttable();'/></td>
		</tr>
	</table>
</form>

<script>
	function exporttable(){
		if(getCheckedRadio(transactionForm.tabletype).checked){
			if(getCheckedRadio(transactionForm.tabletype).value=='singlelanguage'){
				window.open("<c:url value='/'/>util/csvStats.jsp?query=labels.list&db=openclinic&tabletype=singlelanguage&language="+getCheckedRadio(transactionForm.singlelanguage_language).value);
			}
			else if(getCheckedRadio(transactionForm.tabletype).value=='multilanguage'){
				var els = document.getElementsByTagName("*");
				var languages="";
				for(var n=0;n<els.length;n++){
					if(els[n].name && els[n].name.indexOf('singlelanguage_language_')>-1 && els[n].checked){
						if(languages.length>0){
							languages+=",";
						}
						languages+=els[n].value;
					}
				}
				window.open("<c:url value='/'/>util/csvStats.jsp?query=labels.list&db=openclinic&tabletype=multilanguage&language="+languages);
			}
			else if(getCheckedRadio(transactionForm.tabletype).value=='missinglabels'){
				var els = document.getElementsByTagName("*");
				var languages="";
				for(var n=0;n<els.length;n++){
					if(els[n].name && els[n].name.indexOf('sourcelanguage_language_')>-1 && els[n].checked){
						if(languages.length>0){
							languages+=",";
						}
						languages+=els[n].value;
					}
				}
				window.open("<c:url value='/'/>util/csvStats.jsp?query=labels.list&db=openclinic&tabletype=missinglabels&sourcelanguage="+languages+"&targetlanguage="+getCheckedRadio(transactionForm.targetlanguage_language).value);
			}
		}
	}
	function getCheckedRadio(radio_group) {
	    for (var i = 0; i < radio_group.length; i++) {
	        var button = radio_group[i];
	        if (button.checked) {
	            return button;
	        }
	    }
	    return undefined;
	}
</script>