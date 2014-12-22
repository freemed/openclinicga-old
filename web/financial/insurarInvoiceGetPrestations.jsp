<%@page import="be.openclinic.adt.Encounter,
                java.util.*,
                be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page import="java.util.Date,java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD DEBETS ------------------------------------------------------------------------------
    private String addDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked){
        StringBuffer sReturn = new StringBuffer();
		try{
	        if(vDebets!=null){
	            Debet debet;
	            Prestation prestation;
	            String sEncounterName, sPrestationDescription, sPatientName,sDate;
	            String oldname="",oldencounter="",olddate="";
	            Hashtable hSort = new Hashtable();
	
	            String sImage = "_img/themes/default/check.gif";
	            if(!bChecked){
	                sImage = " _img/themes/default/uncheck.gif";
	            }
	            int count=0,count2=0;
	
	            // sort the records
	            for(int i=0; i<vDebets.size(); i++){
	                debet = (Debet)vDebets.elementAt(i);
	                if(debet!=null){
	    				count2++;
	                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime()+"="+debet.getUid(),debet);
	                }
	            }
	            
	            Vector keys = new Vector(hSort.keySet());
	            Collections.sort(keys);
	            Iterator it = keys.iterator();
	            while(it.hasNext()){
	                debet = (Debet)hSort.get(it.next());
	                if(checkString(debet.getUid()).length() > 0){
	                	if(debet != null){
	                    	count++;
	                    	
	                        if(!oldname.equalsIgnoreCase(debet.getPatientName())){
	                            sPatientName = debet.getPatientName();
	                            oldname=sPatientName;
	                            if (debet.getEncounter()!=null){
	                                sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                            }
	                            else{
	                                sEncounterName=debet.getEncounterUid();
	                            }
	                            oldencounter=sEncounterName;
	                            sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                            olddate=sDate;
	                        }
	                        else {
	                            sPatientName="";
	                            
	                            if(!oldencounter.equalsIgnoreCase(debet.getEncounter().getEncounterDisplayNameService(sWebLanguage))){
	                                sPatientName = debet.getPatientName();
	                                oldname=sPatientName;
	                                if (debet.getEncounter()!=null){
	                                    sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                                }
	                                else{
	                                    sEncounterName=debet.getEncounterUid();
	                                }
	                                oldencounter=sEncounterName;
	                                sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                                olddate=sDate;
	                            }
	                            else {
	                                sEncounterName="";
	                                if(!olddate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(debet.getDate()))){
	                                    sPatientName = debet.getPatientName();
	                                    oldname=sPatientName;
	                                    if (debet.getEncounter()!=null){
	                                        sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
	                                    }
	                                    else{
	                                        sEncounterName=debet.getEncounterUid();
	                                    }
	                                    oldencounter=sEncounterName;
	                                    sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
	                                    olddate=sDate;
	                                }
	                                else {
	                                    sDate="";
	                                }
	                            }
	                        }
	
	                        sPrestationDescription = "";
	
	                        if (checkString(debet.getPrestationUid()).length() > 0) {
	                            prestation = debet.getPrestation();
	
	                            if (prestation != null) {
	                                sPrestationDescription = checkString(prestation.getDescription());
	                            }
	                        }
	
	                        // alternate row-style
	                        if(sClass.equals("")) sClass = "1";
	                        else                  sClass = "";

	                        sReturn.append("<tr class='list"+sClass+"'><td><img src='"+sImage+"' name='cbDebet"+debet.getUid()+"="+debet.getInsurarAmount()+"' onclick='doBalance(this, true)'></td>"
	                                       +"<td>"+HTMLEntities.htmlentities(sPatientName)+"</td>"
	                                       +"<td>"+HTMLEntities.htmlentities(sDate)+"</td>"
	                                       +"<td>"+HTMLEntities.htmlentities(sEncounterName)+"</td>"
	                                       +"<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription)+"</td>"
	                                       +"<td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","0.00")).format(debet.getInsurarAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency", "€")+"</td>"
	                                       +"</tr>");
	                    }
	                }
	            }
	
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
		
        return sReturn.toString();
    }

    //--- ADD PERIOD DEBETS -----------------------------------------------------------------------
    private String addPeriodDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked,
    		                       java.util.Date begin, java.util.Date end, String sServiceUid){
        StringBuffer sReturn = new StringBuffer();

        if (vDebets != null) {
            Debet debet;
            Prestation prestation;
            String sEncounterName, sPrestationDescription, sPatientName,sDate;
            Hashtable hSort = new Hashtable();

            String sImage = "_img/themes/default/check.gif";
            if (!bChecked) {
                sImage = " _img/themes/default/uncheck.gif";
            }
            String oldname="",oldencounter="",olddate="";
            
            // sort the records
            for (int i=0;i<vDebets.size(); i++){
                debet = (Debet) vDebets.elementAt(i);
                if(debet!=null){
                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime()+"="+debet.getUid(),debet);
                }
            }
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Iterator it = keys.iterator();

            while (it.hasNext()){
                debet = (Debet) hSort.get(it.next());

                if (checkString(debet.getUid()).length() > 0) {
                    if (debet != null) {
                        if(begin!=null & begin.after(debet.getDate())){
                            continue;
                        }
                        if(end!=null & end.before(debet.getDate())){
                            continue;
                        }
                        if(sServiceUid.length()>0){
                       		if(sServiceUid.indexOf("'"+debet.determineServiceUid()+"'")<0){
                       			continue;
                       		}
                        }
                        
                        if(!oldname.equalsIgnoreCase(debet.getPatientName())){
                            sPatientName = debet.getPatientName();
                            oldname=sPatientName;
                            if (debet.getEncounter()!=null){
                                sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
                            }
                            else{
                                sEncounterName=debet.getEncounterUid();
                            }
                            oldencounter=sEncounterName;
                            sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                            olddate=sDate;
                        }
                        else {
                            sPatientName="";
                            if(!oldencounter.equalsIgnoreCase(debet.getEncounter().getEncounterDisplayNameService(sWebLanguage))){
                                sPatientName = debet.getPatientName();
                                oldname=sPatientName;
                                if (debet.getEncounter()!=null){
                                    sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
                                }
                                else{
                                    sEncounterName=debet.getEncounterUid();
                                }
                                oldencounter=sEncounterName;
                                sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                                olddate=sDate;
                            }
                            else {
                                sEncounterName="";
                                if(!olddate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(debet.getDate()))){
                                    sPatientName = debet.getPatientName();
                                    oldname=sPatientName;
                                    if (debet.getEncounter()!=null){
                                        sEncounterName=debet.getEncounter().getEncounterDisplayNameService(sWebLanguage);
                                    }
                                    else{
                                        sEncounterName=debet.getEncounterUid();
                                    }
                                    oldencounter=sEncounterName;
                                    sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                                    olddate=sDate;
                                }
                                else {
                                    sDate="";
                                }
                            }
                        }

                        sPrestationDescription = "";

                        if (checkString(debet.getPrestationUid()).length() > 0) {
                            prestation = debet.getPrestation();

                            if (prestation != null) {
                                sPrestationDescription = checkString(prestation.getDescription());
                            }
                        }

                        // alternate row-style
                        if(sClass.equals("")) sClass = "1";
                        else                  sClass = "";

                        sReturn.append("<tr class='list"+sClass+"'><td><img src='"+sImage+"' name='cbDebet"+debet.getUid()+"="+debet.getInsurarAmount()+"' onclick='doBalance(this, true)'></td>"
                                       +"<td>"+HTMLEntities.htmlentities(sPatientName)+"</td>"
                                       +"<td>"+HTMLEntities.htmlentities(sDate)+"</td>"
                                       +"<td>"+HTMLEntities.htmlentities(sEncounterName)+"</td>"
                                       +"<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription)+"</td>"
                                       +"<td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","0.00")).format(debet.getInsurarAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency", "€")+"</td>"
                                       +"</tr>");
                    }
                }
            }
        }
        
        return sReturn.toString();
    }
%>
<table width="100%" cellspacing="1" cellpadding="0">
    <tr class="gray">
        <td width="50"/>
        <td width="200"><%=HTMLEntities.htmlentities(getTran("web.control","output_h_4",sWebLanguage))%></td>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web", "date", sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","prestation",sWebLanguage))%></td>
        <td width="100"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
    </tr>
<%
	String sWarning="";
	String sServiceUid = checkString(request.getParameter("EditInvoiceService"));
	if(sServiceUid.length()>0){
		sServiceUid = Service.getChildIdsAsString(sServiceUid);
	}
    String sEditInsurarInvoiceUID = checkString(request.getParameter("EditInsurarInvoiceUID"));
    String sEditBegin = checkString(request.getParameter("EditBegin"));
    String sEditEnd = checkString(request.getParameter("EditEnd"));
    String sClass = "";
    InsurarInvoice insurarInvoice = null;
    String s=""; 
    Vector vDebets=new Vector(),vUnassignedDebets=new Vector();
    if (sEditInsurarInvoiceUID.length() > 0) {
        insurarInvoice = InsurarInvoice.get(sEditInsurarInvoiceUID);
        vDebets = insurarInvoice.getDebets();
        s = addDebets(vDebets, sClass, sWebLanguage, true);
    }

    if (request.getParameter("ShowUnassigned").equalsIgnoreCase("true") && (insurarInvoice==null || (!insurarInvoice.getStatus().equalsIgnoreCase("closed") && !insurarInvoice.getStatus().equalsIgnoreCase("canceled")))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        Date begin=ScreenHelper.parseDate("01/01/1900");
        Date end=new Date();
        try{
            begin = ScreenHelper.parseDate(sEditBegin);
        }
        catch(Exception e){}
        try{
            end = ScreenHelper.parseDate(sEditEnd);
            end = new java.util.Date(end.getTime()+(24*3600*1000)-1);
        }
        catch(Exception e){}
		Insurar insurar = Insurar.get(sInsurarUid);
        if(insurar!=null && insurar.getRequireValidation()==1){
        	vUnassignedDebets = Debet.getUnassignedValidatedAndSignedInsurarDebets(sInsurarUid,begin,end,MedwanQuery.getInstance().getConfigInt("maximumUnassignedInsurerDebets",30000));
        }
        else {
            vUnassignedDebets = Debet.getUnassignedInsurarDebets(sInsurarUid,begin,end,MedwanQuery.getInstance().getConfigInt("maximumUnassignedInsurerDebets",30000));
        }
        
        if(vUnassignedDebets.size()>=MedwanQuery.getInstance().getConfigInt("maximumUnassignedInsurerDebets",30000)){
        	//The limit has been reached. Warn the user
        	sWarning = getTranNoLink("web","warn.maximum.unassignedinsurerdebets.reached",sWebLanguage);
        	sWarning = sWarning.replaceAll("#COUNT#", vUnassignedDebets.size()+"");
        	sWarning = sWarning.replaceAll("#FROM#", ScreenHelper.stdDateFormat.format(((Debet)vUnassignedDebets.elementAt(0)).getDate()));
        	sWarning = sWarning.replaceAll("#TO#", ScreenHelper.stdDateFormat.format(((Debet)vUnassignedDebets.elementAt(vUnassignedDebets.size()-1)).getDate()));
        	
        	s= "<tr><td bgcolor='black' colspan='6'><font style='color: white; font-size: 14px;'>"+sWarning+"</font></td></tr>"+s;
        }
        s += addPeriodDebets(vUnassignedDebets, sClass, sWebLanguage, false,begin,end,sServiceUid);
    }
    
   	s += "<tr><td colspan='6'>"+(vUnassignedDebets.size()+vDebets.size())+" "+getTranNoLink("web","records.loaded",sWebLanguage)+"</td></tr>";
    out.print(s);
%>
</table>