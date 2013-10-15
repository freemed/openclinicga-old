<%@page import="be.openclinic.hr.Contract,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sFunctionCode        = checkString(request.getParameter("functionCode")),
           sFunctionTitle       = checkString(request.getParameter("functionTitle")),
           sFunctionDescription = checkString(request.getParameter("functionDescripton"));

    String sRef1 = checkString(request.getParameter("ref1")),
           sRef2 = checkString(request.getParameter("ref2")),
           sRef3 = checkString(request.getParameter("ref3")),
           sRef4 = checkString(request.getParameter("ref4")),
           sRef5 = checkString(request.getParameter("ref5"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** getContracts.jsp *****************");
        Debug.println("sPatientId           : "+sPatientId);
        Debug.println("sFunctionCode        : "+sFunctionCode);
        Debug.println("sFunctionTitle       : "+sFunctionTitle);
        Debug.println("sFunctionDescription : "+sFunctionDescription);
        Debug.println("sRef1 : "+sRef1);
        Debug.println("sRef2 : "+sRef2);
        Debug.println("sRef3 : "+sRef3);
        Debug.println("sRef4 : "+sRef4);
        Debug.println("sRef5 : "+sRef5+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Contract findObject = new Contract();
    findObject.personId = Integer.parseInt(sPatientId); // required
    findObject.functionCode = sFunctionCode;
    findObject.functionTitle = sFunctionTitle;
    findObject.functionDescription = sFunctionDescription;
    findObject.ref1 = sRef1;
    findObject.ref2 = sRef2;
    findObject.ref3 = sRef3;
    findObject.ref4 = sRef4;
    findObject.ref5 = sRef5;
    
    List contracts = Contract.getList(findObject);
    String sReturn = "";
    
    if(contracts.size() > 0){
        Hashtable hSort = new Hashtable();
        Contract contract;
    
        // sort on contract.beginDate
        for(int i=0; i<contracts.size(); i++){
            contract = (Contract)contracts.get(i);
            
            hSort.put(contract.beginDate.getTime()+"="+contract.getUid(),
                     (contract.isActive()?"style='background:#99cccc;'":"")+  
                      " onclick=\"displayContract('"+contract.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+contract.objectId+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(contract.beginDate)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(contract.endDate)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+calculatePeriod(contract.beginDate,contract.endDate,sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getTranNoLink("hr.contract.functioncode",checkString(contract.functionCode),sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+checkString(contract.functionTitle)+"</td>"+
                     "</tr>");
        }

        Vector keys = new Vector(hSort.keySet());
        Collections.sort(keys);
        Collections.reverse(keys);
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
        sReturn = "<td colspan='6'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(contracts.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","contractId",sWebLanguage))%></td>
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web.hr","beginDate",sWebLanguage))%></asc></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","endDate",sWebLanguage))%></td>
        <td width="15%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","duration",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","functionCode",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","functionTitle",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=contracts.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>