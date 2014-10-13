<%@page import="net.admin.Service,
                java.text.SimpleDateFormat,
                be.openclinic.statistics.ServiceStats,
                be.mxs.common.util.system.ScreenHelper,
                java.util.Vector,
                java.util.Enumeration,
                be.openclinic.statistics.ServicePeriodTransactionStats,
                webcab.lib.statistics.correlation.Correlation,
                java.text.DecimalFormat,
                be.openclinic.system.Examination"%>
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
	
	if(begin.length()==0){
	    begin = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
	}
	if(end.length()==0){
	    end = ScreenHelper.stdDateFormat.format(new java.util.Date());
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
	
	DecimalFormat deciComma = new DecimalFormat("#0.00"),
	              deciLong  = new DecimalFormat("####,###,###,###,##0");
	

	if(request.getParameter("calculate")==null){
	    //*** search fields *************************************************************
		%>
		<form name="diagstats" id="diagstats" method="post" action="<c:url value='/'/>statistics/serviceTransactionStats.jsp" target="_new">
		    <%=writeTableHeader("Web","statistics.servicetransactions",sWebLanguage," doBack();")%>
		    
		    <table width="100%" class="menu" cellspacing="1" cellpadding="0">
		        <%-- PERIOD --%>
		        <tr>
		            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","period",sWebLanguage)%>&nbsp;</td>
		            <td class="admin2">
		                <%=writeDateField("begin","diagstats",begin,sWebLanguage)%>&nbsp;
		                <%=getTran("web","to",sWebLanguage)%>&nbsp;
		                <%=writeDateField("end","diagstats",end,sWebLanguage)%>&nbsp;
		            </td>
		        </tr>
		        
		        <%-- SERVICE --%>
		        <tr>
		            <td class="admin"><%=getTran("Web","service",sWebLanguage)%></td>
		            <td class="admin2" colspan='2'>
		                <input type="hidden" name="ServiceID" value="<%=service%>">
		                <input class="text" type="text" name="ServiceName" readonly size="<%=sTextWidth%>" value="<%=serviceName%>" >
		              
		                <img src="<c:url value='/_img/icons/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('ServiceID','ServiceName');"/>
		                <img src="<c:url value='/_img/icons/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="ServiceID.value='';ServiceName.value='';"/>
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
        ServiceStats serviceStats = new ServiceStats(service, ScreenHelper.parseDate(begin), ScreenHelper.parseDate(end));
        
        // header
        out.print("<table width='100%' class='list' cellpadding='0' cellspacing='1'>"+
                   "<tr>"+
        		    "<td class='admin'><center>"+getTran("web","statistics.for",sWebLanguage)+" "+(myservice!=null?myservice.getLabel(sWebLanguage):getTran("web","hospitalname",sWebLanguage))+" "+getTran("web","between",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getEnd())+"<center></td>"+
                   "</tr>"+
        		  "</table>");
        
        %>
        <br/>
        
        <script src="<c:url value='/_common/_script/diagram2.js'/>"></script>
        <script>
          document.open();
          _BFont = "font-family:arial;font-weight:bold;font-size:8pt;line-height:8pt;";
          window.moveTo(0,0);
          window.resizeTo(screen.width,screen.height);
       
        <%
            String sComments = "";
            Correlation correlation = new Correlation();
            Enumeration transactionTypes = serviceStats.getPeriodTransactionTypes().keys();
            int n = 0;
            int jump = 200;
            double _periodCost = 0, _costY1 = 0, _costY2 = 0, _costY3 = 0, _costY4 = 0, _costY5 = 0, _costY10 = 0;
              
            while(transactionTypes.hasMoreElements()){
                String transactionType = (String)transactionTypes.nextElement();
                double[] values = serviceStats.getPeriodTransactions(transactionType);
                drawGraph(values,n,out,sWebLanguage,getTran("web","examinations",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web.occup",transactionType,sWebLanguage)+"</b>",n,0,correlation.estimateY(serviceStats.getX(),values,0),correlation.estimateY(serviceStats.getX(),values,serviceStats.getX().length));
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
                              "<td>"+getTran("web","pearsson",sWebLanguage)+": <b>"+deciComma.format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),values))+"</b></td>\n"+
                              "<td colspan=\"2\">"+getTran("web","linear.regression",sWebLanguage)+": <b>"+getTran("web","examinations",sWebLanguage)+" = "+deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),values)[0])+" x "+getTran("web","weeks",sWebLanguage)+"+ "+deciComma.format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),values)[1])+"</b></td>"+
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
        %>
        </script>
        
        <%     
        
        sComments+= "<p/>"+
                    "<center>"+
                     "<table class=\"menu\" width=\"100%\">"+
                      "<tr><td colspan='7'><b>"+getTran("web","costtotals",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                      "<tr>"+
                       "<td>"+getTran("web","period",sWebLanguage)+": <b>"+deciLong.format(_periodCost)+"</b></td>"+
                       "<td>+Y1: <b>"+deciLong.format(_costY1)+"</b></td>"+
                       "<td>+Y2: <b>"+deciLong.format(_costY2)+"</b></td>"+
                       "<td>+Y3: <b>"+deciLong.format(_costY3)+"</b></td>"+
                       "<td>+Y4: <b>"+deciLong.format(_costY4)+"</b></td>"+
                       "<td>+Y5: <b>"+deciLong.format(_costY5)+"</b></td>"+
                       "<td>+Y10: <b>"+deciLong.format(_costY10)+"</b></td>"+
                      "</tr>"+
                     "</table>"+
                    "</center>";
        out.print(sComments);
    	 
        out.print("</body>"); 
	    
	    %>	
	        <%=ScreenHelper.alignButtonsStart()%>
		        <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="closeWindow();"/>
	        <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>

<script>
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
  
  <%-- CLOSE WINDOW --%>
  function closeWindow(){
	window.opener = null;
    window.close();
  }
</script>