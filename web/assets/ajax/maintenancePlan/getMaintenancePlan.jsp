<%@page import="be.openclinic.assets.MaintenancePlan,
                be.openclinic.assets.Asset,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- GET ASSETCODE FROM DB -------------------------------------------------------------------
    private String getAssetCodeFromDB(String sAssetUID){
        return ScreenHelper.checkString(Asset.getCode(sAssetUID));
    }
%>

<%
    String sPlanUID = checkString(request.getParameter("planUID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** assets/ajax/maintenancePlan/getMaintenancePlan.jsp **********");
        Debug.println("sPlanUID : "+sPlanUID+"\n");
    }
    //////////////////////////////////////////////////////////////////////////////////////////////

    MaintenancePlan plan = MaintenancePlan.get(sPlanUID);
    
    if(plan!=null){
        %>    
{    
  "planUID":"<%=plan.getUid()%>",
  "name":"<%=HTMLEntities.htmlentities(plan.name)%>",
  "assetUID":"<%=HTMLEntities.htmlentities(plan.assetUID)%>",
  "assetCode":"<%=HTMLEntities.htmlentities(getAssetCodeFromDB(plan.assetUID))%>",
  <%
      if(plan.startDate!=null){
          %>"startDate":"<%=ScreenHelper.stdDateFormat.format(plan.startDate)%>",<%        
      }
      else{
          %>"startDate":"",<% // empty
      }
  %>  
  "frequency":"<%=plan.frequency%>",
  "operator":"<%=HTMLEntities.htmlentities(plan.operator)%>",
  "planManager":"<%=HTMLEntities.htmlentities(plan.planManager)%>",
  "instructions":"<%=HTMLEntities.htmlentities(plan.instructions.replaceAll("\r\n","<br>"))%>"
}
        <%
    }
    else{
        %>            
{
  "planUID":"-1",
  "name":"",
  "assetUID":"",
  "assetCode":"",
  "startDate":"",
  "frequency":"",
  "operator":"",
  "planManager":"",
  "instructions":""
}
        <%
    }
%>