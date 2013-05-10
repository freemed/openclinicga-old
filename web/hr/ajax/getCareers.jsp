<%@page import="be.openclinic.hr.Career,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sPatientId = checkString(request.getParameter("PatientId")),
	       sPosition  = checkString(request.getParameter("position")),
	       sServiceId = checkString(request.getParameter("serviceId")),
           sGrade     = checkString(request.getParameter("grade")),
           sStatus    = checkString(request.getParameter("status")),
           sComment   = checkString(request.getParameter("comment"));

	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("");
	    Debug.println("******************* getCareers.jsp *******************");
	    Debug.println("sPatientId : "+sPatientId);
	    Debug.println("sPosition  : "+sPosition);
	    Debug.println("sServiceId : "+sServiceId);
	    Debug.println("sGrade     : "+sGrade);
	    Debug.println("sStatus    : "+sStatus);
	    Debug.println("sComment   : "+sComment);
	    Debug.println("");
	}
	///////////////////////////////////////////////////////////////////////////

	// compose object to pass search criteria with
	Career findCareer = new Career();
	findCareer.position = sPosition;
	findCareer.serviceUid = sServiceId;
	findCareer.grade = sGrade;
	findCareer.status = sStatus;
	findCareer.comment = sComment;
	
    List careers = Career.getList(findCareer);
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
	                  "<td class='hand'>&nbsp;"+ScreenHelper.getSQLDate(career.begin)+"</td>"+
	                  "<td class='hand'>&nbsp;"+ScreenHelper.getSQLDate(career.end)+"</td>"+
	                  "<td class='hand'>&nbsp;"+career.position+"</td>"+
	                  "<td class='hand'>&nbsp;"+sServiceName+"</td>"+
	                  "<td class='hand'>&nbsp;"+career.grade+"</td>"+
	                  "<td class='hand'>&nbsp;"+career.status+"</td>"+
	                  "<td class='hand'>&nbsp;"+career.comment+"</td>"+
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
    	sReturn = "<td colspan='7'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="100" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","careerBegin",sWebLanguage))%></td>
        <td width="100" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","careerEnd",sWebLanguage))%></td>
        <td width="150" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","position",sWebLanguage))%></td>
        <td width="200" nowrap><%=HTMLEntities.htmlentities(getTran("web","service",sWebLanguage))%></td>
        <td width="80" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","grade",sWebLanguage))%></td>
        <td width="80" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","status",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","comment",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table>

<%
    if(careers.size() > 0){
        %>&nbsp;<i><%=careers.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i><%
    }
%>