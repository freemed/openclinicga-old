<%@page import="be.openclinic.adt.Encounter"%>
<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID"));
    boolean forced = (checkString(request.getParameter("forced")).equals("1"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** adt/ajaxActions/deleteEncounter.jsp *****************");
    	Debug.println("sEditEncounterUID : "+sEditEncounterUID);
    	Debug.println("forced            : "+forced+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    if(sEditEncounterUID.length() > 0){
        if(forced || Encounter.checkExistance(sEditEncounterUID)){
            try{
                Encounter.deleteById(sEditEncounterUID);
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        else{
            %>
{
"Message":"exists"
}
            <%
        }
    }
    else{
        out.println("Parameter 'EditEncounterUID' missing");
    }
%>