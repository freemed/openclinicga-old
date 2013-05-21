<%@page import="be.openclinic.hr.Training,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sBeginDate    = checkString(request.getParameter("beginDate")),
    	   sEndDate      = checkString(request.getParameter("endDate")),
    	   sInstitute    = checkString(request.getParameter("institute")),
    	   sType         = checkString(request.getParameter("type")),
    	   sLevel        = checkString(request.getParameter("level")),
    	   sDiploma      = checkString(request.getParameter("diploma")),
    	   sDiplomaDate  = checkString(request.getParameter("diplomaDate")),
    	   sDiplomaCode1 = checkString(request.getParameter("diplomaCode1")),
    	   sDiplomaCode2 = checkString(request.getParameter("diplomaCode2")),
    	   sDiplomaCode3 = checkString(request.getParameter("diplomaCode3")),
           sComment      = checkString(request.getParameter("comment"));
    
	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n****************** getTrainings.jsp ******************");
	    Debug.println("sPatientId   : "+sPatientId);
	    Debug.println("sBeginDate    : "+sBeginDate);
	    Debug.println("sEndDate      : "+sEndDate);
	    Debug.println("sInstitute    : "+sInstitute);
	    Debug.println("sType         : "+sType);
	    Debug.println("sLevel        : "+sLevel);
	    Debug.println("sDiploma      : "+sDiploma);
	    Debug.println("sDiplomaDate  : "+sDiplomaDate);
	    Debug.println("sDiplomaCode1 : "+sDiplomaCode1);
	    Debug.println("sDiplomaCode2 : "+sDiplomaCode2);
	    Debug.println("sDiplomaCode3 : "+sDiplomaCode3);
	    Debug.println("sComment      : "+sComment+"\n");
	 
	}
	///////////////////////////////////////////////////////////////////////////

	// compose object to pass search criteria with
	Training findObject = new Training();
	findObject.personId = Integer.parseInt(sPatientId); // required
	if(sBeginDate.length() > 0) findObject.begin = ScreenHelper.stdDateFormat.parse(sBeginDate);
	if(sEndDate.length() > 0) findObject.end = ScreenHelper.stdDateFormat.parse(sEndDate);
	findObject.institute = sInstitute;
	findObject.type = sType;
	findObject.level = sLevel;
	findObject.diploma = sDiploma;
	if(sDiplomaDate.length() > 0) findObject.diplomaDate = ScreenHelper.stdDateFormat.parse(sDiplomaDate);
	findObject.diploma = sDiploma;
	findObject.diplomaCode1 = sDiplomaCode1;
	findObject.diplomaCode2 = sDiplomaCode2;
	findObject.diplomaCode3 = sDiplomaCode3;
	findObject.comment = sComment;
	
    List trainings = Training.getList(findObject);
    String sReturn = "";
    
    if(trainings.size() > 0){
	    Hashtable hSort = new Hashtable();
	    Training training;
	
	    // sort on training.begin
	    for(int i=0; i<trainings.size(); i++){
	        training = (Training)trainings.get(i);

	        hSort.put(training.begin.getTime()+"="+training.getUid(),
	        		  " onclick=\"displayTraining('"+training.getUid()+"');\">"+
	                  "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(training.begin)+"</td>"+
	    	          "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(training.end)+"</td>"+
	    	    	  "<td class='hand' style='padding-left:5px'>"+training.diploma+"</td>"+
	                  "<td class='hand' style='padding-left:5px'>"+training.institute+"</td>"+
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
    if(trainings.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","begin",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","end",sWebLanguage))%></td>
        <td width="40%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","titleOrDiploma",sWebLanguage))%></td>
        <td width="40%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","institute",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=trainings.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
	}
    else{
        %><%=sReturn%><%
    }
%>