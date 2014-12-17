<%@page import="be.openclinic.finance.Debet,
                java.util.*,
                be.openclinic.finance.Prestation,
                be.openclinic.adt.Encounter,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD DEBETS ------------------------------------------------------------------------------
    private String addDebets(Vector vDebets, String sClass, String sWebLanguage){
        String sReturn = "";

        if(vDebets != null){
            Debet debet;
            Encounter encounter = null;
            Prestation prestation = null;
            String sEncounterName, sPrestationDescription, sDebetUID, sPatientName;
            String sCredited;
            Hashtable hSort = new Hashtable();

            for(int i=0; i<vDebets.size(); i++){
                sDebetUID = checkString((String)vDebets.elementAt(i));

                if(sDebetUID.length() > 0){
                    debet = Debet.get(sDebetUID);

                    if(debet!=null){
                        sEncounterName = "";
                        sPatientName = "";

                        if(checkString(debet.getEncounterUid()).length() > 0){
                            encounter = debet.getEncounter();

                            if(encounter != null){
                                sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
                                sPatientName = ScreenHelper.getFullPersonName(encounter.getPatientUID());
                            }
                        }

                        sPrestationDescription = "";

                        if(checkString(debet.getPrestationUid()).length() > 0){
                            prestation = debet.getPrestation();

                            if(prestation != null){
                                sPrestationDescription = checkString(prestation.getDescription());
                            }
                        }

                        sCredited = "";
                        if(debet.getCredited() > 0){
                            sCredited = getTran("web.occup","medwan.common.yes",sWebLanguage);
                        }
                        hSort.put(sPatientName.toUpperCase() + "=" + debet.getDate().getTime() + "=" + debet.getUid(), " onclick=\"setDebet('" + debet.getUid() + "');\">"
                                + "<td>" + ScreenHelper.getSQLDate(debet.getDate()) + "</td>"
                                + "<td>" + HTMLEntities.htmlentities(sEncounterName) + " ("+MedwanQuery.getInstance().getUser(debet.getUpdateUser()).getPersonVO().getFullName()+")</td>"
                                + "<td>" + debet.getQuantity()+" x "+HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                + "<td>" + (debet.getAmount()+debet.getInsurarAmount()+debet.getExtraInsurarAmount()) + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                + "<td "+(checkString(debet.getExtraInsurarUid2()).length()>0?"style='text-decoration: line-through'":"")+">" + debet.getAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                + "<td>" + debet.getInsurarAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                + "<td>" + debet.getExtraInsurarAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                + "<td>" + sCredited + "</td>"
                                + "</tr>");
                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            Iterator it = keys.iterator();

            while(it.hasNext()){
            	// alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                sReturn+= "<tr class='list"+sClass+"' "+hSort.get((String)it.next());
            }
        }
        
        return sReturn;
    }
%>

<%
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd   = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n**************** financial/debetGetUnassignedDebets.jsp ***************");
    	Debug.println("sFindDateBegin : "+sFindDateBegin);
    	Debug.println("sFindDateEnd   : "+sFindDateEnd);
    	Debug.println("sFindAmountMin : "+sFindAmountMin);
    	Debug.println("sFindAmountMax : "+sFindAmountMax);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
%>    
<table width="100%" cellspacing="0" cellpadding=0" id='debetsTable'>
    <tr class="admin">
        <td><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","prestation",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","total",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTranNoLink("web.finance","amount.insurar",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTranNoLink("web.finance","amount.complementaryinsurar",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","canceled",sWebLanguage))%></td>
    </tr>
    
	<%		
	    Vector vUnassignedDebets;
	    if(sFindDateBegin.length()==0 && sFindDateEnd.length()==0 && sFindAmountMin.length()==0 && sFindAmountMax.length()==0){
	    	// no search-criteria
	        vUnassignedDebets = Debet.getUnassignedPatientDebets(activePatient.personid);
	    }
	    else{
	        vUnassignedDebets = Debet.getPatientDebets(activePatient.personid,sFindDateBegin,sFindDateEnd,sFindAmountMin,sFindAmountMax);
	    }
	    
	    if(vUnassignedDebets.size() > 0){
	    	%>
	    	<tbody class="hand">
	    	   <%=addDebets(vUnassignedDebets,"",sWebLanguage)%>
	    	</tbody>
	    	<%	    	        
	    }
	    else{
	    	%><tr><td colspan="7"><%=getTran("web","noRecordsFound",sWebLanguage)%></td></tr><%
	    }
	%>
</table>