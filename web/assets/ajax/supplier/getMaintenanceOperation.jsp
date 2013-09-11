<%@page import="be.openclinic.assets.MaintenanceOperation,
                be.openclinic.assets.MaintenancePlan,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
	//--- GET PLANNAME FROM DB --------------------------------------------------------------------
	private String getPlanNameFromDB(String sPlanUID){
		if(sPlanUID.length() > 0){
	        return ScreenHelper.checkString(MaintenancePlan.getName(sPlanUID));
		}
		else{
			return "";
		}
	}
%>

<%
    String sOperationUID = checkString(request.getParameter("OperationUID"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** getMaintenanceOperation.jsp ************");
        Debug.println("sOperationUID : "+sOperationUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    MaintenanceOperation operation = MaintenanceOperation.get(sOperationUID);
    
    if(operation!=null){
        %>            
{    
  "operationUID":"<%=operation.getUid()%>",
  "maintenancePlanUID":"<%=HTMLEntities.htmlentities(operation.maintenanceplanUID)%>",
  "maintenancePlanName":"<%=HTMLEntities.htmlentities(getPlanNameFromDB(operation.maintenanceplanUID))%>",
  <%
      if(operation.date!=null){
          %>"date":"<%=ScreenHelper.stdDateFormat.format(operation.date)%>",<%        
      }
      else{
          %>"date":"",<% // empty
      }
  %>  
  "operator":"<%=HTMLEntities.htmlentities(operation.operator)%>",
  "result":"<%=HTMLEntities.htmlentities(operation.result)%>",
  "comment":"<%=HTMLEntities.htmlentities(operation.comment.replaceAll("\r\n","<br>"))%>",
  <%
      if(operation.nextDate!=null){
          %>"nextDate":"<%=ScreenHelper.stdDateFormat.format(operation.nextDate)%>"<%        
      }
      else{
          %>"nextDate":""<% // empty
      }
  %>  
}
        <%
    }
    else{
        %>
  "operationUID":"",
  "maintenancePlanUID":"",
  "maintenancePlanName":"",
  "date":"",  
  "operator":"",
  "result":"",
  "comment":"",
  "nextDate":"" 
        <%
    }
%>