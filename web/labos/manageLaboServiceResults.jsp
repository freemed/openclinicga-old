<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.medical.RequestedLabAnalysis,
                java.util.*,
                be.openclinic.medical.LabRequest,java.util.Date"%>
<%=checkPermission("labos.servicelaboresults","select",activeUser)%>
<%!
    public class LabRow {
        int type;
        String tag;

        public LabRow(int type, String tag){
            this.type = type;
            this.tag = tag;
        }
    }
%>

<%
    String serviceId   = checkString(request.getParameter("serviceId")),
           serviceText = checkString(request.getParameter("serviceText"));
    if(serviceId.length()==0){
        serviceId = activeUser.activeService.code;
        serviceText = activeUser.activeService.getLabel(sWebLanguage);
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** labos/manageLaboServiceResults ********************");
    	Debug.println("serviceId   : "+serviceId);
    	Debug.println("serviceText : "+serviceText+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="samplesForm" method="post">
    <%=writeTableHeader("Web","serviceLaboResults",sWebLanguage," doBack();")%>
    
    <table width="100%" cellspacing="1" cellpadding="1" class="menu">
        <%-- SERVICE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input class='text' type="text" name="serviceText" readonly size="49" title="<%=serviceText%>" VALUE="<%=serviceText%>" onkeydown="window.event.keyCode = '';return true;">
                <%
                    if(serviceId.length()>0){
                        %><img src="<c:url value='/_img/icons/icon_info.gif'/>" class="link" alt="<%=getTranNoLink("Web","Information",sWebLanguage)%>" onclick='searchInfoService(samplesForm.serviceId)'/><%
                    }
                %>
                <%=ScreenHelper.writeServiceButton("buttonUnit", "serviceId", "serviceText", sWebLanguage, sCONTEXTPATH)%>                
                <input type="hidden" name="serviceId" value="<%=serviceId%>">
            </td>
        </tr>
        
        <%-- DATE --%>
        <tr> 
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","stardate",sWebLanguage)%></td>
            <td class="admin2">                
	            <input type="text" class="text" size="12" maxLength="10" name="startdate" value="<%=checkString(request.getParameter("startdate")).length()>0?checkString(request.getParameter("startdate")):ScreenHelper.formatDate(new Date())%>" id="trandate" OnBlur='checkDate(this)'>
	            <script>writeTranDate();</script>
	            &nbsp;<input class="button" type="submit" name="submit" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
</form>

<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=labos/index.jsp";
  }
</script>
<%
    if(request.getParameter("startdate")!=null && request.getParameter("serviceId")!=null){
        Date date = ScreenHelper.parseDate(request.getParameter("startdate"));
        SortedMap requestList = new TreeMap();
        Vector r = LabRequest.findServiceValidatedRequestsSince(serviceId,date,sWebLanguage,25);
        if(r.size() > 20){
            out.print("<script>alert('"+getTran("web","onlylast20resultsareshown",sWebLanguage)+"');</script>");
        }
        
        for(int n=0; n<r.size(); n++){
            if(n > r.size()-20){
                LabRequest labRequest = (LabRequest)r.elementAt(n);
                if(labRequest.getRequestdate()!=null){
                    requestList.put(new SimpleDateFormat("yyyyMMddHHmmss").format(labRequest.getRequestdate())+"."+labRequest.getServerid()+"."+labRequest.getTransactionid(),labRequest);
                }
            }
        }

        SortedMap groups = new TreeMap();
        Iterator iterator = requestList.keySet().iterator();
        while(iterator.hasNext()){
            LabRequest labRequest = (LabRequest)requestList.get(iterator.next());
            Enumeration enumeration = labRequest.getAnalyses().elements();
            while(enumeration.hasMoreElements()){
                RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)enumeration.nextElement();
                if(groups.get(requestedLabAnalysis.getLabgroup())==null){
                    groups.put(requestedLabAnalysis.getLabgroup(),new Hashtable());
                }
                ((Hashtable)groups.get(requestedLabAnalysis.getLabgroup())).put(requestedLabAnalysis.getAnalysisCode(),"1");
            }
        }

    %>
    <table class="list" width="100%">
        <tr>
            <td class="admin2"><%=getTran("web","analysis",sWebLanguage)%></td>
	        <%
	            Iterator requestsIterator = requestList.keySet().iterator();
	            while (requestsIterator.hasNext()) {
	                LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
	                out.print("<td><b>"+labRequest.getPatientname()+"</b><br/>"+ScreenHelper.formatDate(labRequest.getRequestdate(),ScreenHelper.fullDateFormat)+"<br/><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>"+labRequest.getTransactionid()+"</b></a></td>");
	            }
	        %>
        </tr>
        <%
            String abnormal = MedwanQuery.getInstance().getConfigString("abnormalModifiers","*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*");
            Iterator groupsIterator = groups.keySet().iterator();
            while(groupsIterator.hasNext()){
                String groupname = (String)groupsIterator.next();
                out.print("<tr class='admin'><td colspan='"+(requestList.size()+1)+"'><b>"+MedwanQuery.getInstance().getLabel("labanalysis.groups",groupname,sWebLanguage)+"</b></td></tr>");
                
                Hashtable analysisList = (Hashtable)groups.get(groupname);
                Enumeration analysisEnumeration = analysisList.keys();
                while(analysisEnumeration.hasMoreElements()){
                    String analysisCode = (String)analysisEnumeration.nextElement();
                    out.print("<tr bgcolor='#FFFCD6'><td><b>"+MedwanQuery.getInstance().getLabel("labanalysis",analysisCode,sWebLanguage)+"</b></td>");
                    
                    requestsIterator = requestList.keySet().iterator();
                    while(requestsIterator.hasNext()){
                        LabRequest labRequest = (LabRequest)requestList.get(requestsIterator.next());
                        RequestedLabAnalysis requestedLabAnalysis=(RequestedLabAnalysis)labRequest.getAnalyses().get(analysisCode);
                        String result = (requestedLabAnalysis!=null?(requestedLabAnalysis.getFinalvalidation()>0?requestedLabAnalysis.getResultValue():"?"):"");
                        
                        boolean bAbnormal = (result.length()>0 && !result.equalsIgnoreCase("?") && abnormal.toLowerCase().indexOf("*"+checkString(requestedLabAnalysis.getResultModifier()).toLowerCase()+"*")>-1);
                        boolean newResult = (requestedLabAnalysis!=null && requestedLabAnalysis.getFinalvalidationdatetime()!=null && !requestedLabAnalysis.getFinalvalidationdatetime().before(date));
                        out.println("<td"+(bAbnormal?" bgcolor='#FF8C68'":"")+">"+(newResult?"<b><u>":"")+result+(bAbnormal?" "+checkString(requestedLabAnalysis.getResultModifier().toUpperCase()):"")+(newResult?"</u></b>":"")+"</td>");
                    }
                    
                    out.print("</tr>");
                }
            }
        %>
    </table>
    </body>
    
    <script>
      function showRequest(serverid,transactionid){
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
      }
    </script>
<%
    }
%>