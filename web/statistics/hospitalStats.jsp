<%@page import="be.openclinic.statistics.ServiceStats,
                java.text.SimpleDateFormat,
                java.util.Vector,
                be.openclinic.statistics.ServicePeriodStats,
                be.mxs.common.util.system.ScreenHelper,
                webcab.lib.statistics.correlation.Correlation,
                java.text.DecimalFormat,
                be.openclinic.statistics.HospitalStats,
                be.openclinic.system.Examination,
                java.util.Enumeration"%>
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

    //--- SUM VALUES ------------------------------------------------------------------------------
    private double sumValues(double[] values){
        double sum = 0;
        for(int n=0; n<values.length; n++){
            sum+= values[n];
        }
        return sum;
    }
%>

<%
    String begin = checkString(request.getParameter("begin")),
           end   = checkString(request.getParameter("end"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********************* statistics/hospitalStats.jsp ********************");
		Debug.println("begin : "+begin);
		Debug.println("end   : "+end+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    if(begin.length()==0){
        begin = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    if(end.length()==0){
        end = ScreenHelper.stdDateFormat.format(new java.util.Date());
    }
    
    DecimalFormat deciLong  = new DecimalFormat("####,###,###,###,##0"),
    		      deciComma = new DecimalFormat("#0.00");
    
    if(request.getParameter("calculate")==null){
	    //*** search fields *************************************************************
		%>
		<form name="diagstats" id="diagstats" method="post" action="<c:url value='/'/>statistics/hospitalStats.jsp" target="_new">
		    <%=writeTableHeader("Web","statistics.hospitalstats.global",sWebLanguage," doBack();")%>
		    
		    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
		        <%-- PERIOD --%>
		        <tr>
		            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","period",sWebLanguage)%>&nbsp;</td>
		            <td class="admin2">
		                <%=getTran("web","from",sWebLanguage)%>&nbsp;<%=writeDateField("begin","diagstats",begin,sWebLanguage)%>&nbsp;
		                <%=getTran("web","to",sWebLanguage)%>&nbsp;<%=writeDateField("end","diagstats",end,sWebLanguage)%>&nbsp;
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
	      function doBack(){
	        window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
	      }
	    </script>
		<%
	}
	else{
		out.print("<body style='padding:3px;'>"); 
		
	    //*** new window showing stats ************************************************************
	    ServiceStats serviceStats = new ServiceStats("",ScreenHelper.parseDate(begin),ScreenHelper.parseDate(end));
	    
	    // header-title
	    out.print("<table width='100%' cellpadding='0' cellspacing='1' class='menu'>"+
	               "<tr>"+
	    		    "<td class='admin'><center>"+getTran("web","contact.statistics.for",sWebLanguage)+" "+getTran("web","hospitalname",sWebLanguage)+" "+getTran("web","between",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getEnd())+"<center></td>"+
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
        <table class="menu" width="100%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deciComma.format(correlation.mean(serviceStats.getPeriodPatientsY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deciComma.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodPatientsY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>patients = <%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodPatientsY())[0])%> x weeks+<%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodPatientsY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
    
    <table height='214'><tr><td>&nbsp;</td></tr></table>
        
    <%-- ADMISSIONS --%>
    <center>
        <table class="menu" width="100%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deciComma.format(correlation.mean(serviceStats.getPeriodAdmissionsY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deciComma.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodAdmissionsY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>admissions = <%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY())[0])%> x weeks+<%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
        
    <table height='214'><tr><td>&nbsp;</td></tr></table>
    
    <%-- ADMISSION DAYS --%>
    <center>
        <table class="menu" width="100%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deciComma.format(correlation.mean(serviceStats.getPeriodAdmissionDaysY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deciComma.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>admission days = <%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY())[0])%> x weeks+<%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
    
    <%
        if(serviceStats.nonPeriodVisitsZero()){
    %>
    	<table height='214'><tr><td>&nbsp;</td></tr></table>
    	
        <%-- VISITS --%>
        <center>
            <table class="menu" width="100%">
                <tr>
                    <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=deciComma.format(correlation.mean(serviceStats.getPeriodVisitsY()))%></b></td>
                    <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=deciComma.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodVisitsY()))%></b></td>
                    <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>visits = <%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodVisitsY())[0])%> x weeks+<%=deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodVisitsY())[1])%></b></td>
                </tr>
                <tr>
                    <td>+Y1: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+52))%></b></td>
                    <td>+Y2: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+104))%></b></td>
                    <td>+Y3: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+156))%></b></td>
                    <td>+Y5: <b><%=deciComma.format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+260))%></b></td>
                </tr>
            </table>
        </center>

    <%
        }
    
	    // footer-title
	    out.print("<table width='100%' cellpadding='0' cellspacing='1' class='menu' style='border-top:none;'>"+
	               "<tr>"+
	    		    "<td class='admin'><center>"+getTran("web","activity.statistics.for",sWebLanguage)+" "+getTran("web","hospitalname",sWebLanguage)+" "+getTran("web","between",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ScreenHelper.stdDateFormat.format(serviceStats.getEnd())+"<center></td>"+
	               "</tr>"+
	    		  "</table>");
	        		
	    out.print("<script>");
	    		    		
	    String sComments = "";
	    Enumeration transactionTypes = serviceStats.getPeriodTransactionTypes().keys();
	    int n = 4;
	    int jump = 200;
	    double _periodCost = 0, _costY1 = 0, _costY2 = 0, _costY3 = 0, _costY4 = 0, _costY5 = 0, _costY10 = 0;
	    while(transactionTypes.hasMoreElements()){
	        String transactionType = (String)transactionTypes.nextElement();
	        double[] values = serviceStats.getPeriodTransactions(transactionType);
	        drawGraph(values,n,out,sWebLanguage,getTran("web","examinations",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web.occup",transactionType, sWebLanguage)+"</b>",n,0,correlation.estimateY(serviceStats.getX(),values,0),correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length));
	        n++;
	
	        Examination examination = new Examination(transactionType);
	        _periodCost+= examination.getCost()*sumValues(values);
	        _costY1+=  correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+52)*examination.getCost()*serviceStats.getX().length;
	        _costY2+=  correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+104)*examination.getCost()*serviceStats.getX().length;
	        _costY3+=  correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+156)*examination.getCost()*serviceStats.getX().length;
	        _costY4+=  correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+208)*examination.getCost()*serviceStats.getX().length;
	        _costY5+=  correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+260)*examination.getCost()*serviceStats.getX().length;
	        _costY10+= correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+520)*examination.getCost()*serviceStats.getX().length;
	        
	        sComments+= "<table height='"+jump+"'><tr><td>&nbsp;</td></tr></table>";
	            
	        sComments+= "<center>"+
	                    "<table class='menu' width='100%'>"+
	                     "<tr>"+
	                      "<td>"+getTran("web","mean.value",sWebLanguage)+": <b>"+deciComma.format(correlation.mean(values))+"</b></td>\n"+
		                  "<td>"+getTran("web","pearsson",sWebLanguage)+": <b>"+deciComma.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(), values))+"</b></td>\n"+
		                  "<td colspan=\"2\">"+getTran("web","linear.regression", sWebLanguage)+": <b>"+getTran("web", "examinations", sWebLanguage)+" = "+deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),values)[0])+" x "+getTran("web", "weeks",sWebLanguage)+"+"+deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),values)[1])+"</b></td>"+
		                  "<td>"+getTran("web","unit.cost",sWebLanguage)+": <b>"+examination.getCost()+"</b></td>"+
		                  "<td>"+getTran("web","period.cost",sWebLanguage)+": <b>"+deciLong.format(examination.getCost()*sumValues(values))+"</b></td>"+
		                "</tr>"+
		                "<tr>"+
		                 "<td>+Y1: <b>"+deciComma.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+52))+" ("+deciLong.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+52)*examination.getCost()*serviceStats.getX().length)+")</b></td>"+
		                 "<td>+Y2: <b>"+deciComma.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+104))+" ("+deciLong.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+104)*examination.getCost()*serviceStats.getX().length)+")</b></td>"+
		                 "<td>+Y3: <b>"+deciComma.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+156))+" ("+deciLong.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+156)*examination.getCost()*serviceStats.getX().length)+")</b></td>"+
		                 "<td>+Y4: <b>"+deciComma.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+208))+" ("+deciLong.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+208)*examination.getCost()*serviceStats.getX().length)+")</b></td>"+
		                 "<td>+Y5: <b>"+deciComma.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+260))+" ("+deciLong.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+260)*examination.getCost()*serviceStats.getX().length)+")</b></td>"+
		                 "<td>+Y10: <b>"+deciComma.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+520))+" ("+deciLong.format(correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length+520)*examination.getCost()*serviceStats.getX().length)+")</b></td>"+
		                "</tr>"+
		               "</table>"+
		               "</center>";
	        jump = 214;
	    }
	        
	    out.print("</script>");
        
        double overhead = HospitalStats.getOverheadCosts();
        sComments+= "<p/>"+
                    "<center>"+
                     "<table class='menu' width='100%'>"+
                      "<tr><td colspan='7'><b>"+getTran("web","costtotals",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                      "<tr><td colspan='7'><b>"+getTran("web","costtotals.overhead",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                      "<tr>"+
                       "<td colspan='7'>"+getTran("web","period",sWebLanguage)+": <b>"+deciLong.format(overhead)+"</b></td>"+
                      "</tr>"+
                      "<tr><td colspan='7'><b>"+getTran("web","costtotals.specific",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                      "<tr>"+
                       "<td>"+getTran("web","period",sWebLanguage)+": <b>"+deciLong.format(_periodCost)+"</b></td>"+
                       "<td>+Y1: <b>"+deciLong.format(_costY1)+"</b></td>"+
                       "<td>+Y2: <b>"+deciLong.format(_costY2)+"</b></td>"+
                       "<td>+Y3: <b>"+deciLong.format(_costY3)+"</b></td>"+
                       "<td>+Y4: <b>"+deciLong.format(_costY4)+"</b></td>"+
                       "<td>+Y5: <b>"+deciLong.format(_costY5)+"</b></td>"+
                       "<td>+Y10: <b>"+deciLong.format(_costY10)+"</b></td>"+
                      "</tr>"+
                      "<tr><td colspan='7'><b>"+getTran("web","costtotals.total",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                      "<tr>"+
                       "<td>"+getTran("web","period",sWebLanguage)+": <b>"+deciLong.format(overhead+_periodCost)+"</b></td>"+
                       "<td>+Y1: <b>"+deciLong.format(overhead+_costY1)+"</b></td>"+
                       "<td>+Y2: <b>"+deciLong.format(overhead+_costY2)+"</b></td>"+
                       "<td>+Y3: <b>"+deciLong.format(overhead+_costY3)+"</b></td>"+
                       "<td>+Y4: <b>"+deciLong.format(overhead+_costY4)+"</b></td>"+
                       "<td>+Y5: <b>"+deciLong.format(overhead+_costY5)+"</b></td>"+
                       "<td>+Y10: <b>"+deciLong.format(overhead+_costY10)+"</b></td>"+
                      "</tr>"+
                     "</table>"+
                    "</center>";
        out.print(sComments);
        
        %>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="closeWindow();"/>
            <%=ScreenHelper.alignButtonsStop()%>
        <%
        
		out.print("</body>"); 
    }
%>

<script>
  function closeWindow(){
    window.opener = null;
    window.close();
  }
</script>