<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.MaintenancePlan,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditPlanUID = checkString(request.getParameter("EditPlanUID"));

    String sName           = ScreenHelper.checkString(request.getParameter("name")),
           sAssetUID       = ScreenHelper.checkString(request.getParameter("assetUID")),
           sStartDate      = ScreenHelper.checkString(request.getParameter("startDate")),
           sFrequency      = ScreenHelper.checkString(request.getParameter("frequency")),
           sOperator       = ScreenHelper.checkString(request.getParameter("operator")),
           sPlanManager    = ScreenHelper.checkString(request.getParameter("planManager")),
           sInstructions   = ScreenHelper.checkString(request.getParameter("instructions"));

    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* saveMaintenanceplan.jsp *************");
        Debug.println("sEditPlanUID  : "+sEditPlanUID);
        Debug.println("sAssetUID     : "+sAssetUID);
        Debug.println("sStartDate    : "+sStartDate);
        Debug.println("sFrequency    : "+sFrequency);
        Debug.println("sOperator     : "+sOperator);
        Debug.println("sPlanManager  : "+sPlanManager);
        Debug.println("sInstructions : "+sInstructions+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    MaintenancePlan plan = new MaintenancePlan();
    String sMessage = "";
    
    if(sEditPlanUID.length() > 0){
        plan.setUid(sEditPlanUID);
    }
    else{
        plan.setUid("-1");
        plan.setCreateDateTime(getSQLTime());
    }

    plan.name = sName;
    plan.assetUID = sAssetUID;
    
    // startDate
    if(sStartDate.length() > 0){
        plan.startDate = ScreenHelper.stdDateFormat.parse(sStartDate);
    }

    // frequency
    if(sFrequency.length() > 0){
        plan.frequency = Integer.parseInt(sFrequency);
    }
    
    plan.operator = sOperator;
    plan.planManager = sPlanManager;
    plan.instructions = sInstructions;

    plan.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    plan.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = plan.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTran("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUID":"<%=plan.getUid()%>"
}