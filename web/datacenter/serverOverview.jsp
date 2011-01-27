<%@page import="be.openclinic.datacenter.DatacenterHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String serverid=checkString(request.getParameter("serverid"));
	String colspan="6";
	String location=DatacenterHelper.getServerLocation(Integer.parseInt(serverid));
%>
<table width="100%">
	<!-- Server identification -->
	<tr class='admin'><td colspan="<%= colspan %>"><%=getTran("datacenter","server.identification",sWebLanguage) %></td></tr>
	<tr>
		<td class='admin2'><%=getTran("web","serverid",sWebLanguage) %></td>
		<td class='admin'><b><%=serverid %></b></td>
		<td class='admin2'><%=getTran("web","servername",sWebLanguage) %></td>
		<td class='admin'><b><%=getTran("datacenterServer",serverid,sWebLanguage).toUpperCase() %></b></td>
		<td class='admin2'><%=getTran("web","memberofservergroups",sWebLanguage) %></td>
		<td class='admin'><b><%=DatacenterHelper.getGroupsForServer(Integer.parseInt(serverid),sWebLanguage).toUpperCase() %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","location",sWebLanguage) %></td>
		<td class='admin' colspan="5"><b><a href="javascript:showlocation('http://maps.google.com/maps?iwloc=A&output=embed&q=<%=location %>');"><%=location %></a></b></td>
	</tr>
</table>
<table width="100%">
	<!-- Server information -->
	<tr class='admin'><td colspan="<%= colspan %>"><%=getTran("datacenter","server.information",sWebLanguage) %></td></tr>
	<tr>
		<td class='admin2'><%=getTran("web","os",sWebLanguage) %></td>
		<td class='admin'><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.1") %></b></td>
		<td class='admin2'><%=getTran("web","javaversion",sWebLanguage) %></td>
		<td class='admin' colspan="3"><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.2") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","diskspace",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","system.3");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.3").equals("?")?"?":new java.text.DecimalFormat("#,###").format(Long.parseLong(DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.3"))/1048576)%> Mb</a></b></td>
		<td class='admin2'><%=getTran("web","processors",sWebLanguage) %></td>
		<td class='admin'><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.4") %></b></td>
		<td class='admin2'><%=getTran("web","runtimememory",sWebLanguage) %></td>
		<td class='admin'><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.5").equals("?")?"?":new java.text.DecimalFormat("#,###").format(Long.parseLong(DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.5"))/1048576)%> Mb</b></td>
	</tr>
</table>
<table width="100%">
	<!-- Table sizes -->
	<tr class='admin'><td colspan="<%= colspan %>"><%=getTran("datacenter","server.table.sizes",sWebLanguage) %></td></tr>
	<tr>
		<td class='admin2'><%=getTran("web","patients",sWebLanguage) %></td>
		<%
			String totalPatients = DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1");
		%>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1");'><%=totalPatients %></b></td>
		<td class='admin2'><%=getTran("web","users",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.2") %></b></td>
		<td class='admin2'><%=getTran("web","services",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.3");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.3") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","encounters",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.4");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.4") %></b></td>
		<td class='admin2'><%=getTran("web","admissions",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.4.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.4.1") %></b></td>
		<td class='admin2'><%=getTran("web","consultations",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.4.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.4.2") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","diagnoses",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.8");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.8") %></b></td>
		<td class='admin2'>ICD-10</td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.8.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.8.1") %></b></td>
		<td class='admin2'>ICPC-2</td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.8.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.8.2") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","rfes",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.9");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.9") %></b></td>
		<td class='admin2'>ICD-10</td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.9.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.9.1") %></b></td>
		<td class='admin2'>ICPC-2</td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.9.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.9.2") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","transactions",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.6");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.6") %></b></td>
		<td class='admin2'><%=getTran("web","items",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.7");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.7") %></b></td>
		<td class='admin2'><%=getTran("web","problems",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.10");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.10") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","insurars",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.14");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.14") %></b></td>
		<td class='admin2'><%=getTran("web","insurarpayments",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.15");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.15") %></b></td>
		<td class='admin2'><%=getTran("web","insurarinvoices",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.12");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.12") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","debets",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.5");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.5") %></b></td>
		<td class='admin2'><%=getTran("web","patientinvoices",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.11");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.11") %></b></td>
		<td class='admin2'><%=getTran("web","patientpayments",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.13");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.13") %></b></td>
	</tr>
	<tr>
		<td class='admin2'><%=getTran("web","labanalyses",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.16");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.16") %></b></td>
		<td class='admin2'><%=getTran("web","requestedlabanalyses",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.17");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.17") %></b></td>
		<td class='admin2'><%=getTran("web","labprofiles",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.18");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.18") %></b></td>
	</tr>
	<!-- Demographics -->
	<tr class='admin'><td colspan="<%= colspan %>"><%=getTran("datacenter","server.demographics",sWebLanguage) %></td></tr>
	<tr>
		<%
			String malepct="",femalepct="",childrenpct="";
			String malePatients=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.1");
			String femalePatients=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.2");
			String childPatients=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.3");
			if(!totalPatients.equalsIgnoreCase("?")){
				if(!malePatients.equalsIgnoreCase("?")){
					try{
						malepct=" ("+new java.text.DecimalFormat("#.00").format(100*Double.parseDouble(malePatients)/Double.parseDouble(totalPatients))+"%)";
					}
					catch(Exception e){}
				}
				if(!femalePatients.equalsIgnoreCase("?")){
					try{
						femalepct=" ("+new java.text.DecimalFormat("#.00").format(100*Double.parseDouble(femalePatients)/Double.parseDouble(totalPatients))+"%)";
					}
					catch(Exception e){}
				}
				if(!childPatients.equalsIgnoreCase("?")){
					try{
						childrenpct=" ("+new java.text.DecimalFormat("#.00").format(100*Double.parseDouble(childPatients)/Double.parseDouble(totalPatients))+"%)";
					}
					catch(Exception e){}
				}
			}
		%>
		<td class='admin2'><%=getTran("web","men",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.1")+malepct %></b></td>
		<td class='admin2'><%=getTran("web","women",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.2")+femalepct %></b></td>
		<td class='admin2'><%=getTran("web","childrenyoungerthan5",sWebLanguage) %></td>
		<td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1.3");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.3")+childrenpct %></b></td>
	</tr>
	<!-- Diagnostics -->
	<%
		StringBuffer sb = new StringBuffer("");
		String diag;
		Vector diags = DatacenterHelper.getDiagnosticMonths(Integer.parseInt(serverid));
		for(int n=0;n<diags.size();n++){
			diag=(String)diags.elementAt(n);
			sb.append("<option value='"+diag+"'>"+diag+"</option>");
		}
	%>
	<tr class='admin'>
		<td colspan="<%= colspan %>">
			<img src="<c:url value="/_img/plus.jpg"/>" onclick="document.getElementById('divBedoccupancy').style.display='';"/>
			<img src="<c:url value="/_img/minus.jpg"/>" onclick="document.getElementById('divBedoccupancy').style.display='none';"/>
			<%=getTran("datacenter","server.bedoccupancy",sWebLanguage) %>&nbsp;
			<span style="font-size: 14"><%=DatacenterHelper.getGlobalBedoccupancy(Integer.parseInt(serverid))+"%" %></span>
		</td>
	</tr>
	<tr ><td colspan="<%= colspan%>"><div style="display: none" id="divBedoccupancy" name="divBedoccupancy"></div></td></tr>
	<tr class='admin'>
		<td colspan="1">
			<img src="<c:url value="/_img/plus.jpg"/>" onclick="document.getElementById('divDiagnoses').style.display='';"/>
			<img src="<c:url value="/_img/minus.jpg"/>" onclick="document.getElementById('divDiagnoses').style.display='none';"/>
			<%=getTran("datacenter","server.diagnostics",sWebLanguage) %>&nbsp;
		</td>
		<td colspan="<%= Integer.parseInt(colspan)-1+"" %>">
			<select name="diagtype" id="diagtype" class="text" onchange="loadDiagnoses('<%=serverid %>',document.getElementById('diagmonth').value);">
				<option value='ALL'><%=getTran("web","all",sWebLanguage) %></option>
				<%
					if(DatacenterHelper.hasEncounterDiagnosticMonths(Integer.parseInt(serverid),"admission")){
				%>
				<option value='admission'><%=getTran("web","admissions",sWebLanguage) %></option>
				<%
					}
					if(DatacenterHelper.hasEncounterDiagnosticMonths(Integer.parseInt(serverid),"visit")){
				%>
				<option value='visit'><%=getTran("web","consultations",sWebLanguage) %></option>
				<%
					}
				%>
			</select>
			&nbsp;
			<select name="diagmonth" id="diagmonth" class="text" onchange="loadDiagnoses('<%=serverid %>',this.value);"><%=sb.toString() %></select>
		</td>
	</tr>
	<tr ><td colspan="<%= colspan%>"><div style="display: none" id="divDiagnoses" name="divDiagnoses"></div></td></tr>
	<!-- Financial -->
	<%
		sb = new StringBuffer("");
		String financial;
		Vector financials = DatacenterHelper.getFinancialMonths(Integer.parseInt(serverid));
		for(int n=0;n<financials.size();n++){
			financial=(String)financials.elementAt(n);
			sb.append("<option value='"+financial+"'>"+financial+"</option>");
		}
	%>
	<tr class='admin'>
		<td colspan="1">
			<img src="<c:url value="/_img/plus.jpg"/>" onclick="document.getElementById('divFinancials').style.display='';"/>
			<img src="<c:url value="/_img/minus.jpg"/>" onclick="document.getElementById('divFinancials').style.display='none';"/>
			<%=getTran("datacenter","server.financial",sWebLanguage) %>&nbsp;
		</td>
		<td colspan="<%= Integer.parseInt(colspan)-1+"" %>">
			<select name="financialmonth" id="financialmonth" class="text" onchange="loadFinancials('<%=serverid %>',this.value);"><%=sb.toString() %></select>
		</td>
	</tr>
	<tr ><td colspan="<%= colspan%>"><div style="display: none" id="divFinancials" name="divFinancials"></div></td></tr>
</table>
	

<script>
<%-- OPEN POPUP --%>
	function showlocation(url){
	    window.open(url, "Datacenter Map", "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no").resizeTo(800, 600).moveTo((screen.width - 800) / 2, (screen.height - 600) / 2);
	}

    function simpleValueGraph(serverid,parameterid){
        openPopupWindow("/datacenter/simpleValueGraph.jsp&serverid="+serverid+"&parameterid="+parameterid+"&ts=<%=getTs()%>");
    }
    <%-- OPEN POPUP --%>
    function openPopupWindow(page, width, height, title) {
        var url = "<c:url value="/popup.jsp"/>?Page=" + page;
        if (width != undefined) url += "&PopupWidth=" + width;
        if (height != undefined) url += "&PopupHeight=" + height;
        if (title == undefined) {
            if (page.indexOf("&") < 0) {
                title = page.replace("/", "_");
                title = replaceAll(title, ".", "_");
            }
            else {
                title = replaceAll(page.substring(1, page.indexOf("&")), "/", "_");
                title = replaceAll(title, ".", "_");
            }
        }
        var w = window.open(url, title, "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no");
        w.moveBy(2000, 2000);
    }

    function loadDiagnoses(serverid,period){
        if(document.getElementById("diagtype").options[document.getElementById("diagtype").selectedIndex].value=="ALL"){
            document.getElementById('divDiagnoses').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
	        var params = 'serverid=' + serverid
	                +"&period="+ period;
	        var url= '<c:url value="/datacenter/loadDiagnoses.jsp"/>?ts=' + new Date();
	        new Ajax.Request(url,{
	                method: "GET",
	                parameters: params,
	                onSuccess: function(resp){
	                    $('divDiagnoses').innerHTML=resp.responseText;
	                },
	                onFailure: function(){
	                }
	            }
	        );
        }
        else {
            document.getElementById('divDiagnoses').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
            var params = 'serverid=' + serverid
	        +"&encountertype="+ document.getElementById("diagtype").options[document.getElementById("diagtype").selectedIndex].value
	        +"&period="+ period;
		    var url= '<c:url value="/datacenter/loadEncounterDiagnoses.jsp"/>?ts=' + new Date();
		    new Ajax.Request(url,{
		            method: "GET",
		            parameters: params,
		            onSuccess: function(resp){
		                $('divDiagnoses').innerHTML=resp.responseText;
		            },
		            onFailure: function(){
		            }
		        }
		    );
        }
    }

    function loadFinancials(serverid,period){
        document.getElementById('divFinancials').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
        var params = 'serverid=' + serverid
                +"&period="+ period;
        var url= '<c:url value="/datacenter/loadFinancials.jsp"/>?ts=' + new Date();
        new Ajax.Request(url,{
                method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    $('divFinancials').innerHTML=resp.responseText;
                },
                onFailure: function(){
                }
            }
        );
    }

    function loadBedoccupancy(serverid){
        document.getElementById('divBedoccupancy').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
        var params = 'serverid=' + serverid;
        var url= '<c:url value="/datacenter/loadBedoccupancy.jsp"/>?ts=' + new Date();
        new Ajax.Request(url,{
                method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    $('divBedoccupancy').innerHTML=resp.responseText;
                },
                onFailure: function(){
                }
            }
        );
    }

    function diagnosisGraph(code){
        openPopupWindow("/datacenter/diagnosisGraph.jsp&serverid=<%=serverid%>&diagnosiscode="+code+"&ts=<%=getTs()%>");
    }

    function encounterDiagnosisGraph(code,type){
        openPopupWindow("/datacenter/encounterDiagnosisGraph.jsp&serverid=<%=serverid%>&diagnosiscode="+code+"&type="+type+"&ts=<%=getTs()%>");
    }

    loadDiagnoses('<%=serverid%>',document.getElementById('diagmonth').options[document.getElementById('diagmonth').selectedIndex].value);
    loadBedoccupancy('<%=serverid%>');
	window.setTimeout("loadFinancials('<%=serverid%>',document.getElementById('financialmonth').options[document.getElementById('financialmonth').selectedIndex].value);",500);

	
</script>