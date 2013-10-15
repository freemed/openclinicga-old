<%@page import="be.openclinic.hr.DisciplinaryRecord,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sDate        = checkString(request.getParameter("date")),
           sTitle       = checkString(request.getParameter("title")),
           sDescription = checkString(request.getParameter("description")),
           sDecision    = checkString(request.getParameter("decision")),
           sDuration    = checkString(request.getParameter("duration")),
           sDecisionBy  = checkString(request.getParameter("decisionBy")),
           sFollowUp    = checkString(request.getParameter("followUp"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************ getDisciplinaryRecords.jsp ***********");
        Debug.println("sPatientId   : "+sPatientId);
        Debug.println("sTitle       : "+sTitle);
        Debug.println("sDescription : "+sDescription);
        Debug.println("sDecision    : "+sDecision);
        Debug.println("sDuration    : "+sDuration);
        Debug.println("sDecisionBy  : "+sDecisionBy);
        Debug.println("sFollowUp    : "+sFollowUp+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    DisciplinaryRecord findObject = new DisciplinaryRecord();
    findObject.personId = Integer.parseInt(sPatientId); // required
    findObject.title = sTitle;
    findObject.description = sDescription;
    findObject.decision = sDecision;
    if(sDuration.length() > 0){
        findObject.duration = Integer.parseInt(sDuration);
    }
    findObject.decisionBy = sDecisionBy;
    findObject.followUp = sFollowUp;
    
    List disRecs = DisciplinaryRecord.getList(findObject);
    String sReturn = "";
    
    if(disRecs.size() > 0){
        Hashtable hSort = new Hashtable();
        DisciplinaryRecord disRec;
    
        // sort on disRec.date
        for(int i=0; i<disRecs.size(); i++){
            disRec = (DisciplinaryRecord)disRecs.get(i);

            hSort.put(disRec.date.getTime()+"="+disRec.getUid(),
                     (disRec.isActive()?"style='background:#99cccc;'":"")+ 
                      " onclick=\"displayDisrec('"+disRec.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(disRec.date)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+checkString(disRec.title)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getTran("hr.disrec.decision",disRec.decision,sWebLanguage)+"</td>"+
                      //"<td class='hand' style='padding-left:5px'>"+checkString(disRec.decisionBy)+"</td>"+
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
        sReturn = "<td colspan='3'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(disRecs.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="10%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web.hr","date",sWebLanguage))%></asc></td>
        <td width="30%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","title",sWebLanguage))%></td>
        <td width="60%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","decision",sWebLanguage))%></td>
        <%--<td width="40%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","decisionBy",sWebLanguage))%></td> --%>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table>

&nbsp;<i><%=disRecs.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>