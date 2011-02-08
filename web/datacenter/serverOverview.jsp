<%@page import="be.openclinic.datacenter.DatacenterHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    public String getBack(){
        return "<a href=\""+sCONTEXTPATH+"/datacenter/datacenterHome.jsp?ts="+getTs()+"\" class=\"button\"><span class=\"title\">Retour a la page initiale</span></a>";
    }
%>
<%
	String serverid=checkString(request.getParameter("serverid"));
	String location=DatacenterHelper.getServerLocation(Integer.parseInt(serverid));
%>
<div style="width:100%;float:left;padding:0 0 3px 0"><%=getBack()%></div>

 <!-- Server identification -->
<div id="identification" class="container smallcontainer leftcontainer identification">
    <h3 id="identification_title"><span class="icon server"><%=getTranNoLink("datacenter","server.identification",sWebLanguage) %></span></h3>
    <div class="subcontent">
        <table width="100%" class="" cellpadding="0" cellspacing="0">


            <tr>
                <td class='admin2'><%=getTranNoLink("web","serverid",sWebLanguage) %></td>
                <td class='admin'><b><%=serverid %></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","servername",sWebLanguage) %></td>
                <td class='admin'><b><%=getTranNoLink("datacenterServer",serverid,sWebLanguage).toUpperCase() %></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","memberofservergroups",sWebLanguage) %></td>
                <td class='admin'><b><%=DatacenterHelper.getGroupsForServer(Integer.parseInt(serverid),sWebLanguage).toUpperCase() %></b></td>
            </tr>
            <tr class="last">
                <td class='admin2'><%=getTranNoLink("web","location",sWebLanguage) %></td>
                <td class='admin' colspan="5"><b><a href="http://maps.google.com/maps?iwloc=A&output=embed&q=<%=location%>" onclick="setMapInModal(this);return false;" title="<%=location %>"><%=location %></a></b></td>
            </tr>
        </table>
    </div>
</div>

<!-- Server information -->
<div id="information" class="container smallcontainer information">
    <h3 id="information_title"><span class="icon system"><%=getTranNoLink("datacenter","server.information",sWebLanguage) %></span></h3>

    <div class="subcontent">
        <table width="100%" class="" cellpadding="0" cellspacing="0">
            <tr>
                <td class='admin2'><%=getTranNoLink("web","os",sWebLanguage) %></td>
                <td class='admin'><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.1") %></b></td>
             </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","javaversion",sWebLanguage) %></td>
                <td class='admin' colspan="3"><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.2") %></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","diskspace",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","system.3");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.3").equals("?")?"?":new java.text.DecimalFormat("#,###").format(Long.parseLong(DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.3"))/1048576)%> Mb</a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","processors",sWebLanguage) %></td>
                <td class='admin'><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.4") %></b></td>
            </tr>
            <tr class="last">
                <td class='admin2'><%=getTranNoLink("web","runtimememory",sWebLanguage) %></td>
                <td class='admin'><b><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.5").equals("?")?"?":new java.text.DecimalFormat("#,###").format(Long.parseLong(DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"system.5"))/1048576)%> Mb</b></td>
            </tr>
        </table>
    </div>
</div>

<!-- Table sizes -->
<div id="tables" class="container tables">
    <h3 id="tables_title"><span class="icon lists"><%=getTranNoLink("datacenter","server.table.sizes",sWebLanguage) %></span></h3>

    <div class="subcontent">
        <table width="100%" class="" cellpadding="0" cellspacing="0">

            <tr>
                <td class='admin2'><%=getTranNoLink("web","patients",sWebLanguage) %></td>
                <%
                    String totalPatients = DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1");
                %>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1");'><%=totalPatients %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","users",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.2") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","services",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.3");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.3") %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","encounters",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.4");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.4") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","admissions",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.4.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.4.1") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","consultations",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.4.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.4.2") %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","diagnoses",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.8");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.8") %></a></b></td>
                <td class='admin2'>ICD-10</td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.8.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.8.1") %></a></b></td>
                <td class='admin2'>ICPC-2</td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.8.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.8.2") %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","rfes",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.9");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.9") %></a></b></td>
                <td class='admin2'>ICD-10</td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.9.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.9.1") %></a></b></td>
                <td class='admin2'>ICPC-2</td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.9.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.9.2") %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","transactions",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.6");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.6") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","items",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.7");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.7") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","problems",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.10");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.10") %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","insurars",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.14");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.14") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","insurarpayments",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.15");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.15") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","insurarinvoices",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.12");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.12") %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","debets",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.5");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.5") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","patientinvoices",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.11");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.11") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","patientpayments",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.13");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.13") %></a></b></td>
            </tr>
            <tr class="last">
                <td class='admin2'><%=getTranNoLink("web","labanalyses",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.16");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.16") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","requestedlabanalyses",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.17");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.17") %></a></b></td>
                <td class='admin2'><%=getTranNoLink("web","labprofiles",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.18");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.18") %></a></b></td>
            </tr>
        </table>
    </div>
</div>

 <!-- Demographics -->
<div id="demographics" class="container smallcontainer leftcontainer demographics">
    <h3 id="demographics_title"><span class="icon geo"><%=getTranNoLink("datacenter","server.demographics",sWebLanguage) %></span></h3>
    <div class="subcontent">
        <table width="100%" class="" cellpadding="0" cellspacing="0">

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
                <td class='admin2'><%=getTranNoLink("web","men",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1.1");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.1")+malepct %></a></b></td>
            </tr>
            <tr>
                <td class='admin2'><%=getTranNoLink("web","women",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1.2");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.2")+femalepct %></a></b></td>
             </tr>
            <tr class="last">
                <td class='admin2'><%=getTranNoLink("web","childrenyoungerthan5",sWebLanguage) %></td>
                <td class='admin'><b><a href='javascript:simpleValueGraph("<%=serverid%>","core.1.3");'><%=DatacenterHelper.getLastSimpleValue(Integer.parseInt(serverid),"core.1.3")+childrenpct %></a></b></td>
            </tr>
        </table>
    </div>
</div>

<!-- financial -->
<%
		StringBuffer sb = new StringBuffer("");
		String financial;
		Vector financials = DatacenterHelper.getFinancialMonths(Integer.parseInt(serverid));
		for(int n=0;n<financials.size();n++){
			financial=(String)financials.elementAt(n);
			sb.append("<option value='"+financial+"'>"+financial+"</option>");
		}
%>
   <div id="financial" class="container smallcontainer financial">
   <h3 id="financial_title">
       <span class="icon financial"><%=getTranNoLink("datacenter","server.financial",sWebLanguage) %></span>
   </h3>

   <div class="subcontent">
       <a class="togglecontent" href="javascript:void(0)" onclick="togglecontent(this,'financial')"><span class="icon down">&nbsp;</span></a>
       <select name="financialmonth" id="financialmonth" class="text" onchange="loadFinancials('<%=serverid %>',this.value);"><%=sb.toString() %></select>
       <div id="financial_ajax" style="display:none;"></div>
   </div>
   </div>



 <!-- Diagnostics -->
<div id="diagnostics" class="container smallcontainer leftcontainer diagnostics">
    <h3 id="diagnostics_title">
        <span class="icon diagnostics"><%=getTranNoLink("datacenter","server.diagnostics",sWebLanguage) %></span>
    </h3>
    <%
            sb = new StringBuffer("");
            String diag;
            Vector diags = DatacenterHelper.getDiagnosticMonths(Integer.parseInt(serverid));
            for(int n=0;n<diags.size();n++){
                diag=(String)diags.elementAt(n);
                sb.append("<option value='"+diag+"'>"+diag+"</option>");
            }
        %>
    <div class="subcontent">
        <a class="togglecontent" href="javascript:void(0)" onclick="togglecontent(this,'diagnostics')"><span class="icon down">&nbsp;</span></a>
        <select name="diagtype" id="diagtype" class="text" onchange="loadDiagnoses('<%=serverid %>',document.getElementById('diagmonth').value);">
            <option value='ALL'><%=getTranNoLink("web","all",sWebLanguage) %></option>
            <%
                if(DatacenterHelper.hasEncounterDiagnosticMonths(Integer.parseInt(serverid),"admission")){
            %>
            <option value='admission'><%=getTranNoLink("web","admissions",sWebLanguage) %></option>
            <%
                }
                if(DatacenterHelper.hasEncounterDiagnosticMonths(Integer.parseInt(serverid),"visit")){
            %>
            <option value='visit'><%=getTranNoLink("web","consultations",sWebLanguage) %></option>
            <%
                }
            %>
        </select>
        &nbsp;
        <select name="diagmonth" id="diagmonth" class="text" onchange="loadDiagnoses('<%=serverid %>',this.value);"><%=sb.toString() %></select>

        <div id="diagnostics_ajax" style="display:none;"></div>
    </div>
</div>

<!-- bedoccupancy -->
<div id="bedoccupancy" class="container smallcontainer bedoccupancy">
    <h3 id="bedoccupancy_title">
        <span class="icon bedoccupancy" ><%=getTranNoLink("datacenter","server.bedoccupancy",sWebLanguage) %></span>
    </h3>

    <div class="subcontent">
        <a class="togglecontent" href="javascript:void(0)" onclick="togglecontent(this,'bedoccupancy')"><span class="icon down">&nbsp;</span></a>
        <!--<a class="expandcontent" href="javascript:void(0)" onclick="expandOrReduceContent(this,'bedoccupancy')"><span class="icon expand">&nbsp;</span></a>-->

        <span class="important"><%=DatacenterHelper.getGlobalBedoccupancy(Integer.parseInt(serverid))+"%" %></span>
        <div style="display:none;width:100%;float:left;clear:left;" id="bedoccupancy_ajax"></div>

    </div>

</div>

<script>
<%-- OPEN POPUP --%>
	function showlocation(url){
	    window.open(url, "Datacenter Map", "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no").resizeTo(800, 600).moveTo((screen.width - 800) / 2, (screen.height - 600) / 2);
	}

    function simpleValueGraph(serverid,parameterid){
        openPopupWindow("/datacenter/simpleValueGraph.jsp?serverid="+serverid+"&parameterid="+parameterid+"&ts=<%=getTs()%>");
    }
    

    function loadDiagnoses(serverid,period){
        if($("diagtype").options[document.getElementById("diagtype").selectedIndex].value=="ALL"){
            $('diagnostics_ajax').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
	        var params = 'serverid=' + serverid
	                +"&period="+ period;
	        var url= '<c:url value="/datacenter/loadDiagnoses.jsp"/>?ts=' + new Date();
	        new Ajax.Request(url,{
	                method: "GET",
	                parameters: params,
	                onSuccess: function(resp){
	                    $('diagnostics_ajax').innerHTML=resp.responseText;
	                },
	                onFailure: function(){
	                }
	            }
	        );
        }
        else {
            $('diagnostics_ajax').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
            var params = 'serverid=' + serverid
	        +"&encountertype="+ document.getElementById("diagtype").options[document.getElementById("diagtype").selectedIndex].value
	        +"&period="+ period;
		    var url= '<c:url value="/datacenter/loadEncounterDiagnoses.jsp"/>?ts=' + new Date();
		    new Ajax.Request(url,{
		            method: "GET",
		            parameters: params,
		            onSuccess: function(resp){
		                $('diagnostics_ajax').innerHTML=resp.responseText;
		            },
		            onFailure: function(){
		            }
		        }
		    );
        }
    }

    function loadFinancials(serverid,period){
        $('financial_ajax').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
        var params = 'serverid=' + serverid
                +"&period="+ period;
        var url= '<c:url value="/datacenter/loadFinancials.jsp"/>?ts=' + new Date();
        new Ajax.Request(url,{
                method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    $('financial_ajax').innerHTML=resp.responseText;
                },
                onFailure: function(){
                }
            }
        );
    }

    function loadBedoccupancy(serverid){
        document.getElementById('bedoccupancy_ajax').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/>";
        var params = 'serverid=' + serverid;
        var url= '<c:url value="/datacenter/loadBedoccupancy.jsp"/>?ts=' + new Date();
        new Ajax.Request(url,{
                method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    $('bedoccupancy_ajax').innerHTML=resp.responseText;
                },
                onFailure: function(){
                }
            }
        );
    }

    function diagnosisGraph(code){
        openPopupWindow("/datacenter/diagnosisGraph.jsp?serverid=<%=serverid%>&diagnosiscode="+code+"&ts=<%=getTs()%>");
    }

    Event.observe(window, 'load', function() {
        loadDiagnoses('<%=serverid%>',$('diagmonth').value);
       loadBedoccupancy('<%=serverid%>');
        window.setTimeout("loadFinancials('<%=serverid%>',$('financialmonth').value);",500);

    });
   function encounterDiagnosisGraph(code,type){
        openPopupWindow("/datacenter/encounterDiagnosisGraph.jsp?serverid=<%=serverid%>&diagnosiscode="+code+"&type="+type+"&ts=<%=getTs()%>");
    }

    function togglecontent(obj,el){
        var spanElement = obj.firstChild;
        if(Element.hasClassName(spanElement,"up")){
            Element.removeClassName(spanElement,"up");
            Element.addClassName(spanElement,"down");
            Effect.SlideUp($(el+"_ajax"));
        }else{
            Element.removeClassName(spanElement,"down");
            Element.addClassName(spanElement,"up");
            Effect.SlideDown($(el+"_ajax"));
            Effect.ScrollTo(el);
        }
    }
    function expandOrReduceContent(obj,el){
   /*     var spanElement = obj.cleanWhitespace().firstChild;
        Element.removeClassName($(el),"smallcontainer");
        if(!$(el+"_ajax").visible()){
            Effect.SlideDown($(el+"_ajax"));
            Effect.ScrollTo('bedoccupancy');
        }
        Element.removeClassName(spanElement,"expand");
        Element.addClassName(spanElement,"reduction");
     */   //Effect.ScrollTo(el+"_title");
        //Element.removeClassName($(el),"leftcontainer");
    }
    function setMapInModal(obj){
    Modalbox.show('<iframe src="'+obj.href+'" width="580" height="400"><p>Your browser does not support iframes.</p></iframe>',{title: obj.title, width: 600});
    }
	
</script>