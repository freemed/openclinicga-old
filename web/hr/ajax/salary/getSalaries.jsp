<%@page import="be.openclinic.hr.Salary,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** getSalaries.jsp ****************");
        Debug.println("sPatientId : "+sPatientId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Salary findObject = new Salary();
    findObject.personId = Integer.parseInt(sPatientId); // required
    
    List salaries = Salary.getList(findObject);
    String sReturn = "";
    
    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigParam("priceFormat","0.00"));
    
    if(salaries.size() > 0){
        Hashtable hSort = new Hashtable();
        Salary salary;
    
        // sorted on salary.beginDate
        for(int i=0; i<salaries.size(); i++){
            salary = (Salary)salaries.get(i);

            // contractName == contractId (not uid)
            String sContractName = "";
            if(checkString(salary.contractUid).length() > 0){
                //sContractName = getTranNoLink("contract",salary.contractUid,sWebLanguage);
                sContractName = salary.contractUid.substring(salary.contractUid.indexOf(".")+1);
            }
            
            hSort.put(salary.begin.getTime()+"="+salary.getUid(),
                      " onclick=\"displaySalary('"+salary.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(salary.begin)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(salary.end)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+sContractName+"</td>"+
                      "<td class='hand' style='padding-right:5px;text-align:right;'>"+deci.format(salary.salary)+"&nbsp;"+MedwanQuery.getInstance().getConfigParam("currency","")+"</td>"+
                      "<td class='hand' style='padding-left:5px'>&nbsp;</td>"+
                     "</tr>");
            
            %><script>addSalaryPeriod('<%=salary.getUid()%>','<%=(salary.begin==null?"":ScreenHelper.getSQLDate(salary.begin))%>_<%=(salary.end==null?"":ScreenHelper.getSQLDate(salary.end))%>');</script><%
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
        sReturn = "<td colspan='5'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(salaries.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web.hr","begin",sWebLanguage))%></asc></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","end",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","contract",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","grossSalary",sWebLanguage))%></td>
        <td width="*" nowrap>&nbsp;</td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=salaries.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>