<%@page import="be.openclinic.assets.MaintenancePlan,
                be.openclinic.assets.Asset,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../assets/includes/commonFunctions.jsp"%>

<%!
    private Hashtable assetCodes = new Hashtable();

    //--- GET ASSETCODE ---------------------------------------------------------------------------
    private String getAssetCode(String sAssetUID){
        String sAssetCode = ScreenHelper.checkString((String)assetCodes.get(sAssetUID));
        
        if(sAssetCode.length()==0){
            sAssetCode = getAssetCodeFromDB(sAssetUID); 
                    
            // add to hash for future use
            assetCodes.put(sAssetUID,sAssetCode);
        }
        
        return sAssetCode;
    }
    
    //--- GET ASSETCODE FROM DB -------------------------------------------------------------------
    private String getAssetCodeFromDB(String sAssetUID){
        return ScreenHelper.checkString(Asset.getCode(sAssetUID));
    }
%>

<%
    // search-criteria
    String sName     = checkString(request.getParameter("name")),
           sAssetUID = checkString(request.getParameter("assetUID")),
           sOperator = checkString(request.getParameter("operator"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** assets/ajax/maintenancePlan/getMaintenancePlans.jsp *********");
        Debug.println("sName     : "+sName);
        Debug.println("sAssetUID : "+sAssetUID);
        Debug.println("sOperator : "+sOperator+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    MaintenancePlan findObject = new MaintenancePlan();
    findObject.name = sName;
    findObject.assetUID = sAssetUID;
    findObject.operator = sOperator;

    List plans = MaintenancePlan.getList(findObject);
    String sReturn = "";
    
    if(plans.size() > 0){
        Hashtable hSort = new Hashtable();
        MaintenancePlan plan;
    
        // sort on plans.code
        for(int i=0; i<plans.size(); i++){
            plan = (MaintenancePlan)plans.get(i);

            hSort.put(plan.name+"="+plan.getUid(),
                      " onclick=\"displayMaintenancePlan('"+plan.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+checkString(plan.name)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getAssetCode(plan.assetUID)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+(plan.startDate!=null?ScreenHelper.stdDateFormat.format(plan.startDate):"")+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+plan.frequency+"&nbsp;"+getTran("web","days",sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+checkString(plan.operator)+"</td>"+
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
        sReturn = "<td colspan='6'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(plans.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">    
        <td width="25%" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","name",sWebLanguage))%></td>
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web.assets","asset",sWebLanguage))%></asc></td>
        <td width="7%" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","startDate",sWebLanguage))%></td>
        <td width="7%" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","frequency",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","operator",sWebLanguage))%></td>
    </tr>
    
    <tbody class="hand"><%=sReturn%></tbody>
</table> 

&nbsp;<i><%=plans.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>