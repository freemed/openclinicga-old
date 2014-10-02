<%@page import="be.openclinic.assets.MaintenancePlan,
                be.openclinic.assets.MaintenanceOperation,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../assets/includes/commonFunctions.jsp"%>

<%!
    private Hashtable planNames = new Hashtable();

    //--- GET PLANNAME ----------------------------------------------------------------------------
    private String getPlanName(String sPlanUID){
        String sPlanName = "";
        
        sPlanName = ScreenHelper.checkString((String)planNames.get(sPlanUID));
        if(sPlanName.length()==0){
            sPlanName = getPlanNameFromDB(sPlanUID); 
                    
            // add to hash for future use
            planNames.put(sPlanUID,sPlanName);
        }
        
        return sPlanName;
    }
    
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
    // search-criteria
    String sPlanUID  = checkString(request.getParameter("planUID")), // to obtain plan-name
           sOperator = checkString(request.getParameter("operator")),
           sResult   = checkString(request.getParameter("result"));

    // extra searchcriteria
    String sPeriodPerformedBegin = ScreenHelper.checkString(request.getParameter("periodPerformedBegin")),
           sPeriodPerformedEnd   = ScreenHelper.checkString(request.getParameter("periodPerformedEnd"));


    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** assets/ajax/getMaintenanceOperations.jsp **********");
        Debug.println("sPlanUID  : "+sPlanUID);
        Debug.println("sOperator : "+sOperator);
        Debug.println("sResult   : "+sResult+"\n");

        // extra searchcriteria
        Debug.println("sPeriodPerformedBegin : "+sPeriodPerformedBegin);
        Debug.println("sPeriodPerformedEnd   : "+sPeriodPerformedEnd+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    MaintenanceOperation findObject = new MaintenanceOperation();
    findObject.maintenanceplanUID = sPlanUID;
    findObject.operator = sOperator;
    findObject.result = sResult;

    List operations = MaintenanceOperation.getList(findObject);
    String sReturn = "";
    
    if(operations.size() > 0){
        Hashtable hSort = new Hashtable();
        MaintenanceOperation operation;
    
        // sort on supplier.code
        for(int i=0; i<operations.size(); i++){
            operation = (MaintenanceOperation)operations.get(i);

            String sPlanName = getPlanName(operation.maintenanceplanUID);
            
            hSort.put(operation.maintenanceplanUID+"="+operation.getUid(),
                      " onclick=\"displayMaintenanceOperation('"+operation.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+sPlanName+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.stdDateFormat.format(operation.date)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+operation.operator+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getTranNoLink("assets.maintenanceoperations.result",operation.result,sWebLanguage)+"</td>"+
                     "</tr>");
        }
    
        Vector keys = new Vector(hSort.keySet());
        Collections.sort(keys);
        Iterator iter = keys.iterator();
        String sClass = "1";
        
        while(iter.hasNext()){
            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            sReturn+= "<tr class='list"+sClass+"' "+hSort.get(iter.next());
        }
    }
    else{
        sReturn = "<td colspan='4'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(operations.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">    
        <td width="25%" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","maintenancePlan",sWebLanguage))%></td>
        <td width="7%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web.assets","date",sWebLanguage))%></asc></td>
        <td width="25%" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","operator",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","result",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=operations.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>