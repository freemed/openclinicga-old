<%@page import="net.admin.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*,
                java.util.*,be.openclinic.adt.*,java.text.*,be.openclinic.medical.*,
                be.mxs.common.model.vo.healthrecord.*,java.sql.*,net.admin.system.AccessLog,
                be.openclinic.medical.Diagnosis"%>
<%!
    final static String sTABLE_WIDTH = "100%";


	//--- GET REASONS FOR ENCOUNTER AS HTML -------------------------------------------------------
	public static String getReasonsForEncounterAsHtml(String encounterUid, String sWebLanguage){
	    Vector reasonsForEncounter = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounterUid);
		String sHtml = "";
		
		if(reasonsForEncounter.size() > 0){
		    sHtml = "<table cellpadding='0' cellspacing='0' width='100%'>";
		    		
		    String sClass = "1", sReasonLabel;
		    ReasonForEncounter rfe;
		    for(int n=0; n<reasonsForEncounter.size(); n++){
		        rfe = (ReasonForEncounter)reasonsForEncounter.elementAt(n);
		
		        // alternate row-style
		        if(sClass.length()==0) sClass = "1";
		        else                   sClass = "";
		        
		        sReasonLabel = MedwanQuery.getInstance().getCodeTran(rfe.getCodeType()+"code"+rfe.getCode(),sWebLanguage);
		        if(sReasonLabel.length()==0){
		            sReasonLabel = "<font color='red'>"+rfe.getCode()+"</font>";	
		        }
		        
		        sHtml+= "<tr class='list"+sClass+"'>"+
		                 "<td width='40' nowrap style='vertical-align:top;padding-top:3px;padding-left:4px'><i>"+rfe.getCodeType().toUpperCase()+"</i></td>"+
		                 "<td width='40' nowrap style='vertical-align:top;padding-top:3px'>"+rfe.getCode()+"</td>"+
		                 "<td>"+sReasonLabel+"</td>"+
		                "</tr>";
		    }
		    sHtml+= "</table>";
		}
		else{
			sHtml = "&nbsp;<i>"+getTran("web","noData",sWebLanguage)+"</i>";
		}
	    
	    return sHtml;
	}
	
	//--- GET DIAGNOSES FOR ENCOUNTER AS HTML -------------------------------------------------------
	public static String getDiagnosesForEncounterAsHtml(String encounterUid, String sWebLanguage){
	    Vector diagnoses = Diagnosis.selectDiagnoses("","",encounterUid,"","","","","","","","","","","","");
	    String sHtml = "";
	    
		if(diagnoses.size() > 0){
		    sHtml = "<table cellpadding='0' cellspacing='0' width='100%'>";
		    	
		    String sClass = "1", sDiagLabel;
		    Diagnosis diagnose;
		  	for(int n=0; n<diagnoses.size(); n++){
				diagnose = (Diagnosis)diagnoses.elementAt(n);
	
		        // alternate row-style
		        if(sClass.length()==0) sClass = "1";
		        else                   sClass = "";
		        
				sDiagLabel = MedwanQuery.getInstance().getCodeTran(diagnose.getCodeType()+"code"+diagnose.getCode(),sWebLanguage);
				if(sDiagLabel.length()==0){
					sDiagLabel = "<font color='red'>"+diagnose.getCode()+"</font>";
				}
	
		        sHtml+= "<tr class='list"+sClass+"'>"+
				         "<td width='40' nowrap style='vertical-align:top;padding-top:3px;padding-left:4px'><i>"+diagnose.getCodeType().toUpperCase()+"</i></td>"+
				         "<td width='40' nowrap style='vertical-align:top;padding-top:3px'>"+diagnose.getCode()+"</td>"+
				         "<td style='vertical-align:top;padding-top:3px'>"+sDiagLabel+"</td>"+
				        "</tr>";
			}
		    sHtml+= "</table>";
		}
		else{
			sHtml = "&nbsp;<i>"+getTran("web","noData",sWebLanguage)+"</i>";
		}
		
	    return sHtml;
	}
	
	//--- GET PROBLEMS FOR ENCOUNTER AS HTML ------------------------------------------------------
	public static String getProblemsForEncounterAsHtml(String sPersonid, String sWebLanguage){
	    Vector activeProblems = Problem.getActiveProblems(sPersonid);
		String sHtml = "";
		
		if(activeProblems.size() > 0){
		    sHtml = "<table cellpadding='0' cellspacing='0' width='100%'>";
		    	
		    String sClass = "1", sProblemLabel;	
			if(activeProblems.size() >  0){	    
		    	Problem problem;
		        for(int n=0; n<activeProblems.size(); n++){		  		
		    		problem = (Problem)activeProblems.elementAt(n);
		    		
			        // alternate row-style
			        if(sClass.length()==0) sClass = "1";
			        else                   sClass = "";
			        
			        sProblemLabel = MedwanQuery.getInstance().getCodeTran(problem.getCodeType()+"code"+problem.getCode(),sWebLanguage);
					if(sProblemLabel.length()==0){
						sProblemLabel = "<font color='red'>"+problem.getCode()+"</font>";
					}
	
			        sHtml+= "<tr class='list"+sClass+"'>"+
					         "<td width='40' nowrap style='vertical-align:top;padding-top:3px;padding-left:4px'><i>"+problem.getCodeType().toUpperCase()+"</i></td>"+
					         "<td width='40' nowrap style='vertical-align:top;padding-top:3px'>"+problem.getCode()+"</td>"+
					         "<td width='*' nowrap>"+sProblemLabel+"</td>"+
					         "<td width='70' nowrap>"+problem.getBegin()+"</td>"+
					        "</tr>";	
		    	}
			    sHtml+= "</table>";
			}
		}
		else{
			sHtml = "&nbsp;<i>"+getTran("web","noData",sWebLanguage)+"</i>";
		}
		
	    return sHtml;
	}

	//--- GET TRAN --------------------------------------------------------------------------------
	public static String getTran(String labelType, String labelId, User activeUser){
		return MedwanQuery.getInstance().getLabel(labelType,labelId,activeUser.person.language);
	}
	public static String getTran(String labelType, String labelId, String sLanguage){
		return MedwanQuery.getInstance().getLabel(labelType,labelId,sLanguage);
	}
	
	//--- GET TRAN NO LINK ------------------------------------------------------------------------
	public static String getTranNoLink(String labelType, String labelId, User activeUser){
		String sLabel = MedwanQuery.getInstance().getLabel(labelType,labelId,activeUser.person.language);
		if(sLabel.length()==0){
			sLabel = labelId;
		}
		return sLabel;
	}
	
	public static String getTranNoLink(String labelType, String labelId, String sLanguage){
		String sLabel = MedwanQuery.getInstance().getLabel(labelType,labelId,sLanguage);
		if(sLabel.length()==0){
			sLabel = labelId;
		}
		return sLabel;
	}
	
    //--- GET SQL TIME ----------------------------------------------------------------------------
    public static java.sql.Timestamp getSQLTime(){
        return new java.sql.Timestamp(new java.util.Date().getTime()); // now
    }	

	//--- RELOAD SINGLETON ------------------------------------------------------------------------
	public static void reloadSingleton(HttpSession session){
	    Hashtable labelLanguages = new Hashtable();
	    Hashtable labelTypes = new Hashtable();
	    Hashtable labelIds;
	    net.admin.Label label;
	
	    // only load labels in memory that are service nor function.
	    Vector vLabels = net.admin.Label.getNonServiceFunctionLabels();
	    Iterator iter = vLabels.iterator();
	
	    while(iter.hasNext()){
	        label = (net.admin.Label)iter.next();
	        
	        // type
	        labelTypes = (Hashtable)labelLanguages.get(label.language);
	        if(labelTypes==null){
	            labelTypes = new Hashtable();
	            labelLanguages.put(label.language,labelTypes);
	        }
	
	        // id
	        labelIds = (Hashtable)labelTypes.get(label.type);
	        if(labelIds==null){
	            labelIds = new Hashtable();
	            labelTypes.put(label.type,labelIds);
	        }
	
	        labelIds.put(label.id,label);
	    }
	
	    MedwanQuery.getInstance().putLabels(labelLanguages);
	}

	//--- CHECK STRING ----------------------------------------------------------------------------
	public static String checkString(String sString){
	    return ScreenHelper.checkString(sString);
	}

	//--- ALIGN BUTTONS START ---------------------------------------------------------------------
	public static String alignButtonsStart(){
		return "<div class='buttons'>"; 
	}

	//--- ALIGN BUTTONS STOP ----------------------------------------------------------------------
	public static String alignButtonsStop(){
		return "</div>";
	}
	
	//--- GET TS ----------------------------------------------------------------------------------
	public static String getTs(){
		return ScreenHelper.getTs();
	}
%>

<%
    User activeUser = null;
    AdminPerson activePatient = null;

	String sUriPage = request.getRequestURI();
	if(!sUriPage.endsWith("sessionExpired.jsp") && !sUriPage.endsWith("login.jsp")){
		session = request.getSession();
		if(session==null){
			out.println("<script>window.location.href='sessionExpired.jsp';</script>");	
		    out.flush();
		}
		
		activeUser = (User)session.getAttribute("activeUser");	
		activePatient = (AdminPerson)session.getAttribute("activePatient");
	}
	
    // common stuff
    final SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    final String sAPPNAME = "OpenClinic Mobile",
                 sWEBTITLE = "MXS - "+sAPPNAME;  
    final String ITEM_PREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";
    final String sCONTEXTPATH = "http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"");
    
    final String sCSS = "<link href='"+sCONTEXTPATH+"/mobile/_css/web.css' rel='stylesheet' type='text/css'>";
    final String sSCRIPTS = "<script src='"+sCONTEXTPATH+"/mobile/_script/scripts.js'></script>";
    final String sJSPROTOTYPE = "<script src='"+sCONTEXTPATH+"/_common/_script/prototype.js'></script>";
    final String sFAVICON = "<link rel='shortcut icon' href='"+sCONTEXTPATH+"/_img/openclinic.ico'>\n"+
                            "<link rel='icon' type='image/x-icon' href='"+sCONTEXTPATH+"/_img/openclinic.ico'/>";

	final long dataFreshness = (7*24*3600*1000); // one week
%>