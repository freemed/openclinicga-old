<%@ page import="be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

	String encounteruid = checkString(request.getParameter("encounteruid"));
	String performeruid="";
    Enumeration e = request.getParameterNames();
    while(e.hasMoreElements()){
    	String parameterName = (String)e.nextElement();
    	if(parameterName.startsWith("PPC_")){
    		String sPrestationUid=parameterName.split("_")[1];
    	    if(sPrestationUid.length()>0){
    			Prestation prestation = Prestation.get(sPrestationUid);
    			if(prestation!=null){
    				performeruid=prestation.getPerformerUid();
    			}
    		}
    	}
    }

	if(performeruid.length()==0 && encounteruid.length()>0){
		Encounter encounter = Encounter.get(encounteruid);
		if(encounter != null){
			Service service = encounter.getService();
			if(service.performeruid!=null && performeruid.length()>0){
				performeruid=service.performeruid;
			}
			while(performeruid.length()==0 && service!=null && service.parentcode!=null && service.parentcode.length()>0){
				service= Service.getService(service.parentcode);
				if(service.performeruid!=null && service.performeruid.length()>0){
					performeruid=service.performeruid;
				}
			}
		}
	}

	if(performeruid.length()==0){
		performeruid=MedwanQuery.getInstance().getConfigString("defaultInvoicingCareProvider","");
	}

%>
{
	"performeruid":"<%=performeruid %>"
}