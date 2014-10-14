<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable,
                be.openclinic.medical.CarePrescriptionAdministrationSchema"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medication.medicationschema","all",activeUser)%>

<%
    int adminDays = MedwanQuery.getInstance().getConfigInt("administrationSchemaDays",5);

	// start date
	java.util.Date dStart = new java.util.Date(ScreenHelper.getDate(new java.util.Date()).getTime() - 2 * 24 * 3600 * 1000);
	String sStartDate = checkString(request.getParameter("startdate"));
	if(sStartDate.length() > 0){
	    dStart = new java.util.Date(ScreenHelper.parseDate(sStartDate).getTime() - 2 * 24 * 3600 * 1000);
	}
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* pharmacy/manageAdministrations.jsp *****************");
    	Debug.println("adminDays  : "+adminDays);
    	Debug.println("sStartDate : "+sStartDate+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    SimpleDateFormat compactDateFormat = new SimpleDateFormat("yyyyMMdd");
    String sMsg = "";
    
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(request.getParameter("saveButton")!=null){
    	//*** 1 - drugprescr *** 
        Hashtable requestParameters = RequestParameterParser.getInstance().parseRequestParameters(request,"drugprescr");
        String parameter, sDay, prescriptionUid, time, value;
        
        if(requestParameters.size() > 0){
            Iterator iterator = requestParameters.keySet().iterator();
	        while(iterator.hasNext()){
	            parameter = (String)iterator.next();
	            sDay = parameter.substring(10).split("_")[0];
	            prescriptionUid = parameter.substring(10).split("_")[1];
	            time = parameter.substring(10).split("_")[2];
	            value = (String) requestParameters.get(parameter);
	
	            AdministrationSchema.storeAdministration(prescriptionUid,compactDateFormat.parse(sDay),Integer.parseInt(time),
	            		                                 Integer.parseInt(value));
	        }
            sMsg = getTran("web","dataIsSaved",sWebLanguage);
        }
        
        //*** 2 - careprescr ***
        requestParameters = RequestParameterParser.getInstance().parseRequestParameters(request,"careprescr");
        if(requestParameters.size() > 0){
	        Iterator iterator = requestParameters.keySet().iterator();	                
	        while(iterator.hasNext()){
	            parameter = (String)iterator.next();
	            sDay = parameter.substring(10).split("_")[0];
	            prescriptionUid = parameter.substring(10).split("_")[1];
	            time = parameter.substring(10).split("_")[2];
	            value = (String)requestParameters.get(parameter);
	
	            CarePrescriptionAdministrationSchema.storeAdministration(prescriptionUid,compactDateFormat.parse(sDay),
	            		                                                 Integer.parseInt(time),Integer.parseInt(value));
	        }
            sMsg = getTran("web","dataIsSaved",sWebLanguage);
        }
    }
%>
<form name="formAdministrations" method="post">
    <%-- 1 - TREATMENT DIAGRAM ------------------------------------------------------------------%>
    <%=writeTableHeader("web","medicationschema",sWebLanguage,"")%>
    <table width="100%" cellspacing="1" class="list">
    <%
        AdministrationSchema schema = new AdministrationSchema(dStart,new java.util.Date(dStart.getTime()+adminDays * 24 * 3600 * 1000),activePatient.personid);
        if(schema.getPrescriptionSchemas().size() > 0){
            AdministrationSchema.AdministrationSchemaLine line = (AdministrationSchema.AdministrationSchemaLine)schema.getPrescriptionSchemas().elementAt(0);

            // Day header
            out.print("<tr>"+
                       "<td width='10%'/>");
            String hours = line.getTimeQuantities().size()+"";
            for(int d=0; d<adminDays; d++){
                %>
                    <td class="admin" colspan="<%=hours%>" width="<%=(120/adminDays)%>%">
                        <center><a href="<c:url value='/main.do'/>?Page=pharmacy/manageAdministrations.jsp&startdate=<%=ScreenHelper.formatDate(new java.util.Date(dStart.getTime()+d * 24 * 3600 * 1000))%>"><%=ScreenHelper.formatDate(new java.util.Date(dStart.getTime()+d * 24 * 3600 * 1000))%></a></center>
                    </td>
                <%
            }
            out.print("</tr>");

            // Hour header
            out.print("<tr>"+
                       "<td/>");
            for(int d=0; d<adminDays; d++){
                for(int i=0; i<line.getTimeQuantities().size(); i++){
                    out.print("<td class='admin'><center>"+((KeyValue)line.getTimeQuantities().elementAt(i)).getKey()+getTran("web","abbreviation.hour", sWebLanguage)+"</center></td>");
                }
            }
            out.print("</tr>");
        }

        java.util.Date day;
        int val, adminVal;
        String sClass;
        
        AdministrationSchema.AdministrationSchemaLine line;
        for(int n=0; n<schema.getPrescriptionSchemas().size(); n++){
            line = (AdministrationSchema.AdministrationSchemaLine)schema.getPrescriptionSchemas().elementAt(n);

            out.print("<tr bgcolor='lightgrey'>");
             out.print("<td>&nbsp;<b>"+(line.getPrescription().getProduct()!=null?line.getPrescription().getProduct().getName():"Unknown product")+"</b>&nbsp;</td>");

            // display days
            for(int d=0; d<adminDays; d++){
                day = new java.util.Date(dStart.getTime()+d * 24 * 3600 * 1000);

                for(int i=0; i<line.getTimeQuantities().size(); i++){
                    if(!line.getPrescription().getBegin().after(day) && !(line.getPrescription().getEnd()!=null && line.getPrescription().getEnd().before(day))){
                        val = ((KeyValue)line.getTimeQuantities().elementAt(i)).getValueInt();

                        out.print("<td>"+
                                   "<center>"+(val>0?val+"":"&nbsp;"));
                        if(val > 0){
                            try{
                                adminVal = Integer.parseInt(line.getTimeAdministration(compactDateFormat.format(day)+"."+((KeyValue)line.getTimeQuantities().elementAt(i)).getKey()));
                            }
                            catch(Exception e){
                                adminVal = 0;
                            }

                            sClass = "text";
                            if(adminVal < val){
                                sClass = "textred";
                            }
                            out.print("<input name='drugprescr"+compactDateFormat.format(day)+"_"+line.getPrescription().getUid()+"_"+((KeyValue)line.getTimeQuantities().elementAt(i)).getKey()+"' type='text' class='"+sClass+"' size='1' value='"+adminVal+"'/>");
                        }
                        out.print( "</center>"+
                                  "</td>");
                    }
                    else{
                        out.print("<td>&nbsp;</td>");
                    }
                }
            }
            out.print("</tr>");
        }
    %>
    </table>
    <br>
    
    <%-- 2 - CARE DIAGRAM -----------------------------------------------------------------------%>
    <%=writeTableHeader("web","careschema",sWebLanguage,"")%>
    <table width="100%" cellspacing="1" class="list">
    <%
        CarePrescriptionAdministrationSchema.AdministrationSchemaLine cLine;
        CarePrescriptionAdministrationSchema cSchema = new CarePrescriptionAdministrationSchema(dStart,new java.util.Date(dStart.getTime()+adminDays * 24 * 3600 * 1000),activePatient.personid);
        if(cSchema.getCarePrescriptionSchemas().size() > 0){
            cLine = (CarePrescriptionAdministrationSchema.AdministrationSchemaLine)cSchema.getCarePrescriptionSchemas().elementAt(0);

            // Day header
            out.print("<tr>"+
                       "<td width='10%'/>");
            String hours = cLine.getTimeQuantities().size()+"";
            for(int d=0; d<adminDays; d++){
                %>
                    <td class="admin" colspan="<%=hours%>" width="<%=(120/adminDays)%>%">
                        <center><a href="<c:url value='/main.do'/>?Page=pharmacy/manageAdministrations.jsp&startdate=<%=ScreenHelper.formatDate(new java.util.Date(dStart.getTime()+d * 24 * 3600 * 1000))%>"><%=ScreenHelper.formatDate(new java.util.Date(dStart.getTime()+d * 24 * 3600 * 1000))%></a></center>
                    </td>
                <%
            }
            out.print("</tr>");

            // Hour header
            out.print("<tr>"+
                       "<td/>");
            for(int d=0; d<adminDays; d++){
                for(int i=0; i<cLine.getTimeQuantities().size(); i++){
                    out.print("<td class='admin'><center>"+((KeyValue)cLine.getTimeQuantities().elementAt(i)).getKey()+getTran("web","abbreviation.hour",sWebLanguage)+"</center></td>");
                }
            }
            out.print("</tr>");
        }

        // display days
        for(int n=0; n<cSchema.getCarePrescriptionSchemas().size(); n++){
            cLine = (CarePrescriptionAdministrationSchema.AdministrationSchemaLine)cSchema.getCarePrescriptionSchemas().elementAt(n);

            out.print("<tr bgcolor='lightgrey'>");
             out.print("<td>&nbsp;<b>"+(cLine.getCarePrescription().getCareUid()!=null?getTran("care_type",cLine.getCarePrescription().getCareUid(),sWebLanguage):"Unknown care type")+"&nbsp;</b></td>");

            for(int d=0; d<adminDays; d++){
                day = new java.util.Date(dStart.getTime()+d * 24 * 3600 * 1000);
                
                for(int i=0; i<cLine.getTimeQuantities().size(); i++){
                    if(!cLine.getCarePrescription().getBegin().after(day) && !(cLine.getCarePrescription().getEnd()!=null && cLine.getCarePrescription().getEnd().before(day))){
                        val = ((KeyValue)cLine.getTimeQuantities().elementAt(i)).getValueInt();
                        out.print("<td>"+
                                   "<center>"+(val>0?val+"":"&nbsp;"));
                      
                        if(val > 0){
                            try{
                                adminVal = Integer.parseInt(cLine.getTimeAdministration(compactDateFormat.format(day)+"."+((KeyValue)cLine.getTimeQuantities().elementAt(i)).getKey()));
                            }
                            catch(Exception e){
                                adminVal = 0;
                            }

                            sClass = "text";
                            if(adminVal < val){
                                sClass = "textred";
                            }

                            out.print("<input name='careprescr"+compactDateFormat.format(day)+"_"+cLine.getCarePrescription().getUid()+"_"+((KeyValue)cLine.getTimeQuantities().elementAt(i)).getKey()+"' type='text' class='"+sClass+"' size='1' value='"+adminVal+"'/>");
                        }
                        
                        out.print(" </center>"+
                                  "</td>");
                    }
                    else{
                        out.print("<td>&nbsp;</td>");
                    }
                }
            }
            out.print("</tr>");
        }
    %>
    </table>
    <br/>
    
    <%
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }
    %>
    
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="submit" name="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>"/>
        <input class="button" type="button" name="todayButton" value="<%=getTranNoLink("Web","today",sWebLanguage)%>" onclick="doToday();"/>
    <%=ScreenHelper.alignButtonsStart()%>
</form>

<script>
  <%-- DO TODAY --%>
  function doToday(){
    window.location.href = "<c:url value='main.do'/>?Page=pharmacy/manageAdministrations.jsp&startdate=<%=ScreenHelper.formatDate(new java.util.Date())%>";
  }
</script>
