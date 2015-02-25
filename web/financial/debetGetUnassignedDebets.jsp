<%@page import="be.openclinic.finance.Debet,
                java.util.*,
                be.openclinic.finance.Prestation,
                be.openclinic.adt.Encounter,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GROUP DEBETS ----------------------------------------------------------------------------
    // group type by type (prestation type)
    private Hashtable groupDebets(Vector vDebets){
	    Hashtable groupedDebets = new Hashtable();

        if(vDebets!=null){
            String sDebetUID;
            Debet debet;

            for(int i=0; i<vDebets.size(); i++){
                sDebetUID = checkString((String)vDebets.elementAt(i));

                if(sDebetUID.length() > 0){
                    debet = Debet.get(sDebetUID);
                   
                    if(debet!=null){
                        String sDebetType = debet.getPrestation().getType();
                        
                        Vector oneGroup = (Vector)groupedDebets.get(sDebetType);
                        if(oneGroup==null){
                        	oneGroup = new Vector();
                        }
                    	oneGroup.add(debet);
                    	groupedDebets.put(sDebetType,oneGroup);                        
                    }
                }
            }
            
        }
        
	    return groupedDebets;
    }

    //--- DEBETS TO HTML --------------------------------------------------------------------------
    // These are the vectors containing debets of the same prestation-type.
    // Only the most recent debet is initially shown.
    // On click the other debets of that group will be shown. 
    private String debetsToHtml(Hashtable hDebetGroups, String sClass, String sWebLanguage, String sGroupIdx){
        String sHtml = "", sJS = "";

        if(hDebetGroups!=null){
            Debet debet;
            Encounter encounter = null;
            Prestation prestation = null;
            String sEncounterName, sPrestationDescription, sDebetUID, sPatientName;
            String sCredited;
            Hashtable hSort = new Hashtable();

            Vector oneGroup;
            String sDebetType;
            int groupIdx = 0;
            
            Vector groupKeys = new Vector(hDebetGroups.keySet());
            Iterator groupKeysIter = groupKeys.iterator();
            while(groupKeysIter.hasNext()){
            	sDebetType = (String)groupKeysIter.next();
            	oneGroup = (Vector)hDebetGroups.get(sDebetType);
            	
            	Debet mostRecentDebet = (Debet)oneGroup.elementAt(0);
            	if(mostRecentDebet!=null){            	
	           	    // encounter and patient
	           	    sEncounterName = "";
	                sPatientName = "";
	
	                encounter = mostRecentDebet.getEncounter();
	                if(encounter!=null){
	                    sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
	                    sPatientName = ScreenHelper.getFullPersonName(encounter.getPatientUID());
	                }
                   
	            	// prestation
	            	sPrestationDescription = "";
	                if(checkString(mostRecentDebet.getPrestationUid()).length() > 0){
	                    prestation = mostRecentDebet.getPrestation();
	
	                    if(prestation!=null){
	                        sPrestationDescription = checkString(prestation.getDescription());
	                    }
	                }
		
	                // icons
	                String sIcons = "";
	                if(oneGroup.size() > 1){
	                    sIcons = "<img class='link' id='group"+groupIdx+"Plus' src='"+sCONTEXTPATH+"/_img/themes/default/plus.jpg' alt='"+getTranNoLink("Web.Occup","medwan.common.open",sWebLanguage)+"' style='display:block;'>"+
	                             "<img class='link' id='group"+groupIdx+"Min' src='"+sCONTEXTPATH+"/_img/themes/default/minus.jpg' alt='"+getTranNoLink("Web.Occup","medwan.common.close",sWebLanguage)+"' style='display:none;'>";
    	                
		                // open group by default (after click and page-submit)
		                if(sGroupIdx.equals(groupIdx+"")){
		                	sJS = "<script>toggleDebetGroup('"+sGroupIdx+"');</script>";
		                }
	                }
	                
	                Hashtable groupInfo = getGroupInfo(oneGroup,sWebLanguage);
	                
	                String sOnClick = "";
	                if(oneGroup.size()==1){
	                	// no content below, so the main-TR must be clickable
	                	sOnClick = "onClick=\"setDebet('"+mostRecentDebet.getUid()+"','"+groupIdx+"');\" style='cursor:hand;'";
	                }
	                else{
	                	// content below, so open hidden table
	                	sOnClick = "onClick=\"toggleDebetGroup('"+groupIdx+"');\" style='cursor:hand;'";
	                }
	                
	            	// main-row for group : info about 'mostRecentDebet' or summed info 
	            	sHtml+= "<tr class='list1' "+sOnClick+">"+
	            	         "<td width='17'>"+sIcons+"</td>"+
	            	         "<td>"+ScreenHelper.getSQLDate(mostRecentDebet.getDate())+"</td>"+
	            	         "<td>"+HTMLEntities.htmlentities(sEncounterName)+" ("+MedwanQuery.getInstance().getUser(mostRecentDebet.getUpdateUser()).getPersonVO().getFullName()+")</td>"+
	                         "<td>"+HTMLEntities.htmlentities(sPrestationDescription)+" ("+(String)groupInfo.get("quantity")+"x)</td>"+
	                         "<td style='text-align:right' "+(checkString(mostRecentDebet.getExtraInsurarUid2()).length()>0?"style='text-decoration:line-through'":"")+">"+(String)groupInfo.get("amount")+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"+
	                         "<td style='text-align:right' >"+(String)groupInfo.get("insurarAmount")+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"+
	                         "<td style='text-align:right' >"+(String)groupInfo.get("extraInsurarAmount")+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"+
	                         "<td>"+(String)groupInfo.get("credited")+"</td>"+
	                        "</tr>";

	                // hidden rows for group
	                if(oneGroup.size() > 1){
		            	sHtml+= "<tr id='groupTable_"+groupIdx+"' style='display:none'>"+
		                         "<td colspan='8'>"+
		                          "<table width='100%' cellpadding='0' cellspacing='0'>"+
		                           groupToHtml(sDebetType,oneGroup,sClass,sWebLanguage,groupIdx)+
		                          "</table>"+
		                         "</td>"+
		                        "</tr>";
	                }
	                
	            	groupIdx++;	                		
	            }
            }
        }
        
        return sHtml+sJS;
    }
    
    //--- GET GROUP INFO --------------------------------------------------------------------------
    private Hashtable getGroupInfo(Vector oneGroup, String sWebLanguage){
    	Hashtable info = new Hashtable(4);
    	
    	Debet debet;    	
    	int quantity = 0;
    	double credited = 0, amount = 0, insurarAmount = 0, extraInsurarAmount = 0;
    			
    	for(int i=0; i<oneGroup.size(); i++){
    		debet = (Debet)oneGroup.get(i);
    		
    		quantity+= debet.getQuantity(); 
    		credited+= debet.getCredited(); 
    		amount+= debet.getAmount(); 
    		insurarAmount+= debet.getInsurarAmount(); 
    		extraInsurarAmount+= debet.getExtraInsurarAmount(); 
    	}

    	// put sums in hash
    	info.put("quantity",Integer.toString(quantity));
    	info.put("amount",Double.toString(amount));
    	info.put("insurarAmount",Double.toString(insurarAmount));
    	info.put("extraInsurarAmount",Double.toString(extraInsurarAmount));
    	
    	if(credited > 0){
    	    info.put("credited",getTran("web.occup","medwan.common.yes",sWebLanguage));
    	}
    	else{
    	    info.put("credited",""); // empty string
    	}
    	
    	return info;
    }
    
    //--- GROUP TO HTML ---------------------------------------------------------------------------
    // These are the hidden debets, sorted per type of prestation.
    private String groupToHtml(String sDebetType, Vector debetGroup, String sClass, String sWebLanguage, int groupIdx){
    	if(debetGroup.size()==1) return ""; // do not group single debets
    	
    	String sHtml = "<table width='100%' cellspacing='0' cellpadding='0'>";

    	// column-width row
    	sHtml+= "<tr>"+
                 "<td width='17'></td>"+
                 "<td width='80'></td>"+
                 "<td width='*'></td>"+
                 "<td width='100'></td>"+
                 "<td width='80'></td>"+
                 "<td width='100'></td>"+
                 "<td width='100'></td>"+
                 "<td width='80'></td>"+
                "</tr>";
                        
        if(debetGroup!=null){
            sHtml+= "<tbody class='hand'>";
            
            Debet debet;
            Encounter encounter = null;
            Prestation prestation = null;
            String sEncounterName, sPrestationDescription, sDebetUID, sPatientName, sCredited;
            Hashtable hSorted = new Hashtable();

            for(int i=0; i<debetGroup.size(); i++){
            	debet = (Debet)debetGroup.elementAt(i);
                if(debet!=null){
	           	    // encounter and patient
	                sEncounterName = "";
	                sPatientName = "";
	
	                encounter = debet.getEncounter();	
	                if(encounter!=null){
	                    sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
	                    sPatientName = ScreenHelper.getFullPersonName(encounter.getPatientUID());
	                }
	
	                // prestation
	                sPrestationDescription = "";
	                if(checkString(debet.getPrestationUid()).length() > 0){
	                    prestation = debet.getPrestation();
	
	                    if(prestation != null){
	                        sPrestationDescription = checkString(prestation.getDescription());
	                    }
	                }
	
	                // credited ?
	                sCredited = "";
	                if(debet.getCredited() > 0){
	                    sCredited = getTran("web.occup","medwan.common.yes",sWebLanguage);
	                }
	                
	                // no TRs
	                hSorted.put(sPatientName.toUpperCase()+"="+debet.getDate().getTime()+"="+debet.getUid()," onclick=\"setDebet('"+debet.getUid()+"','"+groupIdx+"');\">"
	                        +"<td>&nbsp;<i>"+(i+1)+"</i></td>"
	                        +"<td style='padding-left:5px;'>"+ScreenHelper.getSQLDate(debet.getDate())+"</td>"
	                        +"<td style='padding-left:5px;'>"+HTMLEntities.htmlentities(sEncounterName)+" ("+MedwanQuery.getInstance().getUser(debet.getUpdateUser()).getPersonVO().getFullName()+")</td>"
	                        +"<td style='padding-left:7px;'>"+HTMLEntities.htmlentities(sPrestationDescription)+" ("+debet.getQuantity()+"x)</td>"
	                        +"<td style='text-align:right' "+(checkString(debet.getExtraInsurarUid2()).length()>0?"style='text-decoration:line-through'":"")+">"+debet.getAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"
	                        +"<td style='text-align:right'>"+debet.getInsurarAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"
	                        +"<td style='text-align:right'>"+debet.getExtraInsurarAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"
	                        +"<td>"+sCredited+"</td>");
                }
            }

            // sort and reverse order
            Vector keys = new Vector(hSorted.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            Iterator it = keys.iterator();

            while(it.hasNext()){
                sHtml+= "<tr "+hSorted.get((String)it.next())+"</tr>"; // class='list'
            }
            
            sHtml+= "</tbody>";
        }
        
        return sHtml;
    }
%>

<%    
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd   = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax")),
           sGroupIdx      = checkString(request.getParameter("GroupIdx"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n**************** financial/debetGetUnassignedDebets.jsp ***************");
    	Debug.println("sFindDateBegin : "+sFindDateBegin);
    	Debug.println("sFindDateEnd   : "+sFindDateEnd);
    	Debug.println("sFindAmountMin : "+sFindAmountMin);
    	Debug.println("sFindAmountMax : "+sFindAmountMax);
    	Debug.println("sGroupIdx      : "+sGroupIdx+"\n"); // this debet-group should be opened by default
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
%>    
<table width="100%" cellspacing="0" cellpadding="0" id="debetsTable" style="padding:1px;">
    <tr class="admin">
        <td width="17">&nbsp;</td>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td width="*"><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
        <td width="100"><%=HTMLEntities.htmlentities(getTran("web","prestation",sWebLanguage))%></td>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
        <td width="100"><%=HTMLEntities.htmlentities(getTranNoLink("web.finance","amount.insurar",sWebLanguage))%></td>
        <td width="100"><%=HTMLEntities.htmlentities(getTranNoLink("web.finance","amount.complementaryinsurar",sWebLanguage))%></td>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web","canceled",sWebLanguage))%></td>
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
	    	%><tbody><%=debetsToHtml(groupDebets(vUnassignedDebets),"",sWebLanguage,sGroupIdx)%></tbody><%	    	        
	    }
	    else{
	    	%><tr><td colspan="7"><%=getTran("web","noRecordsFound",sWebLanguage)%></td></tr><%
	    }
	%>
</table>