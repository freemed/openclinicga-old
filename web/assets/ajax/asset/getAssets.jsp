<%@page import="be.openclinic.assets.Asset,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../assets/includes/commonFunctions.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sCode                = checkString(request.getParameter("code")),
           sDescription         = checkString(request.getParameter("description")),
           sSerialnumber        = checkString(request.getParameter("serialnumber")),
           sAssetType           = checkString(request.getParameter("assetType")),
           sSupplierUID         = checkString(request.getParameter("supplierUID")),
           sPurchasePeriodBegin = checkString(request.getParameter("purchasePeriodBegin")),
           sPurchasePeriodEnd   = checkString(request.getParameter("purchasePeriodEnd"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** getAssets.jsp ******************");
        Debug.println("sCode         : "+sCode);
        Debug.println("sDescription  : "+sDescription);
        Debug.println("sSerialnumber : "+sSerialnumber);
        Debug.println("sAssetType    : "+sAssetType);
        Debug.println("sSupplierUID  : "+sSupplierUID);
        Debug.println("sPurchasePeriodBegin : "+sPurchasePeriodBegin);
        Debug.println("sPurchasePeriodEnd   : "+sPurchasePeriodEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Asset findObject = new Asset();
    findObject.code = sCode;
    findObject.description = sDescription;
    findObject.serialnumber = sSerialnumber;
    findObject.assetType = sAssetType;
    findObject.supplierUid = sSupplierUID;
    
    if(sPurchasePeriodBegin.length() > 0){
        findObject.purchasePeriodBegin = ScreenHelper.stdDateFormat.parse(sPurchasePeriodBegin);
    }

    if(sPurchasePeriodEnd.length() > 0){    
        findObject.purchasePeriodEnd = ScreenHelper.stdDateFormat.parse(sPurchasePeriodEnd);
    }
    
    List assets = Asset.getList(findObject);
    String sReturn = "";
    
    if(assets.size() > 0){
        Hashtable hSort = new Hashtable();
        Asset asset;
    
        // sort on asset.code
        for(int i=0; i<assets.size(); i++){
            asset = (Asset)assets.get(i);

            // shorten description
            sDescription = asset.description.replaceAll("<br>"," ");
            if(sDescription.length() > 50){
                sDescription = sDescription.substring(0,50)+"..";
            }
            
            hSort.put(asset.code+"="+asset.getUid(),
                      " onclick=\"displayAsset('"+asset.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+asset.code+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+sDescription+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getTran("assets.type",asset.assetType,sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(asset.purchaseDate)+"</td>"+
                     "</tr>");
        }
    
        Vector keys = new Vector(hSort.keySet());
        Collections.sort(keys);
        Iterator iter = keys.iterator();
        String sClass = "";
        
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
    if(assets.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">    
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web","code",sWebLanguage))%></asc></td>
        <td width="35%" nowrap><%=HTMLEntities.htmlentities(getTran("web","description",sWebLanguage))%></td>
        <td width="15%" nowrap><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web.assets","purchaseDate",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=assets.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>