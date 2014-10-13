<%@page import="be.openclinic.statistics.ServiceStats,
                java.text.SimpleDateFormat,
                java.util.Vector,
                be.openclinic.statistics.ServicePeriodStats,
                be.mxs.common.util.system.ScreenHelper,
                webcab.lib.statistics.correlation.Correlation,
                java.text.DecimalFormat,
                be.openclinic.statistics.HospitalStats"%>
<%@include file="../includes/validateUser.jsp"%>
<%=sCSSNORMAL%>

<%!
	//--- DRAW GRAPH ------------------------------------------------------------------------------
	private void drawGraph(double[] values, int a, javax.servlet.jsp.JspWriter out, String sWebLanguage,
			               String label, String titel, int graphcounter, int limit, double y0, double y1) 
	    throws Exception{
	    int n = a;
	
	    // Patients
	    if(values!=null && values.length>0){
	        double maxVal = 0;
	        for(int v=0; v<values.length; v++){
	            if(values[v] > maxVal){
	                maxVal = values[v];
	            }
	        }
	        
	        out.print("var D"+n+"_"+a+"=new Diagram();");
	        out.print("D"+n+"_"+a+".SetFrame((screen.availWidth-1050)/2+70, 50+"+graphcounter+"*250, (screen.availWidth-1050)/2+1020, "+graphcounter+"*250+200);");
	        out.print("var maxRef = Math.pow(10,Math.ceil(Math.log("+maxVal+")/Math.log(10)));");
	        out.print("if(maxRef>0){");
	         out.print("while(maxRef>"+maxVal+"*2){");
	          out.print("maxRef/=2;");
	         out.print("}");
	        out.println("}");
	        out.println("D"+n+"_"+a+".SetBorder(-1,"+(values.length+1)+",0,maxRef);");
	        out.println("D"+n+"_"+a+".SetText(\""+getTranNoLink("web","period",sWebLanguage)+"\",\""+getTranNoLink("web",label,sWebLanguage)+"\", \""+titel+(limit>0?" ("+getTranNoLink("web","limit",sWebLanguage)+"="+limit+")":"")+"\");");
	        out.println("D"+n+"_"+a+".SetGridColor('#44CC44');");
	        out.println("D"+n+"_"+a+".XScale = 0;");
	        out.println("D"+n+"_"+a+".Draw('#FFFF80','#004080',true);");
	        out.println("var i, j, y, w;");
	        
	        if(limit==0) limit = 9999999;
	
	        double mod = Math.ceil(values.length/52.0);
	        if(mod<=1) mod = 1;
	        else       mod*= 2;
	
	        for(int v=0; v<values.length; v++){
	            out.print("j=D"+n+"_"+a+".ScreenX("+v+"+0.5);");
	            if(v%mod==0){
	                out.print("new Bar(j-"+Math.min(10,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY(0), j+"+Math.min(10,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY(0), \""+(limit>0 && values[v]>limit?"red":limit<0 && v>0 && values[v]>-limit*values[v-1]?"red":"green")+"\", \""+ScreenHelper.padLeft(v+1+"","0",2)+"\", \"#FFFFFF\", \""+new DecimalFormat("#.00").format(values[v])+"\");");
	            }
	            out.print("new Bar(j-"+Math.min(5,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY("+values[v]+"), j+"+Math.min(5,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY(0), \""+(limit>0 && values[v]>limit?"red":limit<0 && v>0 && values[v]>-limit*values[v-1]?"red":"green")+"\", \"\", \"#FFFFFF\", \""+new DecimalFormat("#.00").format(values[v])+"\");");
	        }
	        out.print("new Line(D"+n+"_"+a+".ScreenX(0), D"+n+"_"+a+".ScreenY("+y0+"), D"+n+"_"+a+".ScreenX("+values.length+"), D"+n+"_"+a+".ScreenY("+y1+"), \"black\", 3, \"linear regression\");");
	    }
	}
%>
  
<%
    String begin = checkString(request.getParameter("begin")),
           end   = checkString(request.getParameter("end"));
    
    if(begin.length()==0){
        begin = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date()); // begin of year
    }
    if(end.length()==0){
        end = ScreenHelper.stdDateFormat.format(new java.util.Date()); // now
    }
    
	String service = checkString(request.getParameter("ServiceID"));
	String serviceName = "";
	if(service.length() > 0){
	    serviceName = getTran("service",service,sWebLanguage);
	}
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********************** statistics/serviceStats.jsp *********************");
		Debug.println("begin       : "+begin);
		Debug.println("end         : "+end);
		Debug.println("serviceName : "+serviceName+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	DecimalFormat deci = new DecimalFormat("#0.00");
	
	
    if(request.getParameter("calculate")==null){
	    //*** search fields *************************************************************
		%>
		<form name="diagstats" id="diagstats" method="post" action="<c:url value='/'/>statistics/serviceStats.jsp" target="_new">
		    <%=writeTableHeader("Web","statistics.servicestats.contacts",sWebLanguage," doBack();")%>
		    
		    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
		        <%-- PERIOD --%>
		        <tr>
		            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","period",sWebLanguage)%>&nbsp;</td>
		            <td class="admin2">
		                <%=getTran("web","from",sWebLanguage)%>&nbsp;<%=writeDateField("begin","diagstats",begin,sWebLanguage)%>&nbsp;
		                <%=getTran("web","to",sWebLanguage)%>&nbsp;<%=writeDateField("end","diagstats",end,sWebLanguage)%>&nbsp;
		            </td>
		        </tr>
		        
		        <%-- SERVICE --%>
		        <tr>
		            <td class="admin"><%=getTran("Web","service",sWebLanguage)%></td>
		            <td class="admin2" colspan='2'>
		                <input type="hidden" name="ServiceID" value="<%=service%>">
		                <input class="text" type="text" name="ServiceName" readonly size="<%=sTextWidth%>" value="<%=serviceName%>" >
		                
		                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('ServiceID','ServiceName');">
		                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="ServiceID.value='';ServiceName.value='';">
		            </td>
		        </tr>
		        
		        <%-- BUTTONS --%>
		        <tr>
		            <td class="admin">&nbsp;</td>
		            <td class="admin2">
		                <input type="submit" class="button" name="calculate" value="<%=getTranNoLink("web","calculate",sWebLanguage)%>"/>
		                <input type="button" class="button" name="backButton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
		            </td>
		        </tr>
		    </table>
		</form>
		    
	    <script>
	      function searchService(serviceUidField,serviceNameField){
	        openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	        document.getElementsByName(serviceNameField)[0].focus();
	      }
	      
	      function doBack(){
	        window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
	      }
	    </script>
		<%
	}
	else{
		out.print("<body style='padding:3px;'>"); 
		
	    //*** new window showing stats ************************************************************
	    Service myservice = Service.getService(service);
	    ServiceStats serviceStats = new ServiceStats(service,ScreenHelper.parseDate(begin),ScreenHelper.parseDate(end));
	    
	    // title
	    out.print("<table width='100%' class='menu' cellpadding='0' cellspacing='1'>"+
	               "<tr>"+
	    		    "<td class='admin'><center>"+getTran("web","statistics.for",sWebLanguage)+" "+(myservice!=null?myservice.getLabel(sWebLanguage):getTran("web","hospitalname",sWebLanguage))+" "+getTran("web","between",sWebLanguage)+" "+ScreenHelper.stdDateFormat.format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ScreenHelper.stdDateFormat.format(serviceStats.getEnd())+"<center></td>"+
	               "</tr>"+
	    		  "</table>");

%>
<script src="<c:url value='/_common/_script/diagram2.js'/>"></script>
<script>
  document.open();
  _BFont = "font-family:arial;font-weight:bold;font-size:8pt;line-height:8pt;";
  <%
      Correlation correlation = new Correlation();
      if(serviceStats.nonPeriodPatientsZero()){
    	drawGraph(serviceStats.getPeriodPatients(),0,out,sWebLanguage,getTran("web","patients",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","patients",sWebLanguage)+"<b>",0,HospitalStats.getBedCapacity(),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length));
      }
      if(serviceStats.nonPeriodAdmissionsZero()){
    	drawGraph(serviceStats.getPeriodAdmissions(),1,out,sWebLanguage,getTran("web","admissions.short",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","admissions",sWebLanguage)+"<b>",1,-2,correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length));
      }
      if(serviceStats.nonPeriodAdmissionDaysZero()){
    	drawGraph(serviceStats.getPeriodAdmissionDays(),2,out,sWebLanguage,getTran("web","admission.days.short",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","admission.days",sWebLanguage)+"<b>",2,-2,correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length));
      }
      if(serviceStats.nonPeriodVisitsZero()){
    	drawGraph(serviceStats.getPeriodVisits(),3,out,sWebLanguage,getTran("web","visits",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","visits",sWebLanguage)+"<b>",3,-2,correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length));
      }
  %>
  window.moveTo(0,0);
  window.resizeTo(screen.width,screen.height);
</script>

    <table height='200'><tr><td>&nbsp;</td></tr></table>
    
    <%-- PATIENTS --%>
    <center>
        <table class="menu" width="60%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deci.format(correlation.mean(serviceStats.getPeriodPatientsY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deci.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodPatientsY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>patients = <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodPatientsY())[0])%> x weeks + <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodPatientsY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
    
    <table height='214'><tr><td>&nbsp;</td></tr></table>
    
    <%-- ADMISSIONS --%>
    <center>
        <table class="menu" width="60%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deci.format(correlation.mean(serviceStats.getPeriodAdmissionsY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deci.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodAdmissionsY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>admissions = <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY())[0])%> x weeks + <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
        
    <table height='214'><tr><td>&nbsp;</td></tr></table>
    
    <%-- ADMISSION DAYS --%>
    <center>
        <table class="menu" width="60%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deci.format(correlation.mean(serviceStats.getPeriodAdmissionDaysY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deci.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>admission days = <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY())[0])%> x weeks + <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
    
    <%
        if(serviceStats.nonPeriodVisitsZero()){
	%>
	    <table height='214'><tr><td> </td></tr></table>
	    
        <%-- VISITS --%>
	    <center>
	        <table class="menu" width="60%">
	            <tr>
	                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deci.format(correlation.mean(serviceStats.getPeriodVisitsY()))%></b></td>
	                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deci.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodVisitsY()))%></b></td>
	                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>visits = <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodVisitsY())[0])%> x weeks + <%=deci.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodVisitsY())[1])%></b></td>
	            </tr>
	            <tr>
	                <td>+Y1: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+52))%></b></td>
	                <td>+Y2: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+104))%></b></td>
	                <td>+Y3: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+156))%></b></td>
	                <td>+Y5: <b><%=deci.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+260))%></b></td>
	            </tr>
	        </table>
	    </center>
	<%
       }
    
	   out.print("</body>"); 
       
	   %>
	       <%=ScreenHelper.alignButtonsStart()%>
		       <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="closeWindow();"/>
		   <%=ScreenHelper.alignButtonsStop()%>
	   <%
    }
%>

<script>
  function closeWindow(){
    window.opener = null;
    window.close();
  }
</script>