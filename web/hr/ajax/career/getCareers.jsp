<%@page import="be.openclinic.hr.Career,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sContractUid = checkString(request.getParameter("contractUid")),
           sPosition    = checkString(request.getParameter("position")),
           sServiceUid  = checkString(request.getParameter("serviceUid")),
           sGrade       = checkString(request.getParameter("grade")),
           sStatus      = checkString(request.getParameter("status")),
           sComment     = checkString(request.getParameter("comment"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** getCareers.jsp ******************");
        Debug.println("sPatientId   : "+sPatientId);
        Debug.println("sContractUid : "+sContractUid);
        Debug.println("sPosition    : "+sPosition);
        Debug.println("sServiceUid  : "+sServiceUid);
        Debug.println("sGrade       : "+sGrade);
        Debug.println("sStatus      : "+sStatus);
        Debug.println("sComment     : "+sComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Career findObject = new Career();
    findObject.personId = Integer.parseInt(sPatientId); // required
    findObject.contractUid = sContractUid;
    findObject.position = sPosition;
    findObject.serviceUid = sServiceUid;
    findObject.grade = sGrade;
    findObject.status = sStatus;
    findObject.comment = sComment;
    
    List careers = Career.getList(findObject);
    String sReturn = "";
    
    if(careers.size() > 0){
        Hashtable hSort = new Hashtable();
        Career career;
    
        // sort on career.begin
        for(int i=0; i<careers.size(); i++){
            career = (Career)careers.get(i);

            String sServiceName = "";
            if(career.serviceUid.length() > 0){
                sServiceName = getTran("service",career.serviceUid,sWebLanguage);
            }
            
            hSort.put(career.begin.getTime()+"="+career.getUid(),
                      " onclick=\"displayCareer('"+career.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(career.begin)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(career.end)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+calculatePeriod(career.begin,career.end,sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+career.position+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+sServiceName+"</td>"+
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
        sReturn = "<td colspan='4'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(careers.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web.hr","begin",sWebLanguage))%></asc></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","end",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web","duration",sWebLanguage))%></td>
        <td width="20%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","position",sWebLanguage))%></td>
        <td width="30%" nowrap><%=HTMLEntities.htmlentities(getTran("web","department",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=careers.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>