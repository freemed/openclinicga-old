<%@page import="be.openclinic.adt.Encounter" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    //------------  DELETE ENCOUNTER BY EditEncounterUID ----------//
    String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID"));
    if(!sEditEncounterUID.equals("")){
        if ("1".equalsIgnoreCase(request.getParameter("forced")) || Encounter.checkExistance(sEditEncounterUID)){

            try{
                Encounter.deleteById(sEditEncounterUID);
            }catch(Exception e){
                out.write("Sql error "+e.getMessage());
            }
        }
        else {
            %>
{
"Message":"exists"
}
            <%
        }
    }else{
        out.write("EditEncounterUID not valid !!");
    }
%>

