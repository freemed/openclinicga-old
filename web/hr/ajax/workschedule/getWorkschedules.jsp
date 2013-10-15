<%@page import="be.openclinic.hr.Workschedule,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sPatientId = checkString(request.getParameter("PatientId"));

    // search-criteria
    String sBegin = checkString(request.getParameter("begin")),
            sEnd   = checkString(request.getParameter("end"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** getWorkschedules.jsp **************");
        Debug.println("sPatientId : "+sPatientId);
        Debug.println("sBegin     : "+sBegin);
        Debug.println("sEnd       : "+sEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Workschedule findObject = new Workschedule();
    findObject.personId = Integer.parseInt(sPatientId); // required
    /*
    if(sBegin.length() > 0){
        findObject.begin = ScreenHelper.stdDateFormat.parse(sBegin);
    }
    if(sEnd.length() > 0){
        findObject.end = ScreenHelper.stdDateFormat.parse(sEnd);
    }
    */
    
    List workschedules = Workschedule.getList(findObject);
    String sReturn = "";
    
    if(workschedules.size() > 0){
        Hashtable hSort = new Hashtable();
        Workschedule workschedule;
    
        // sort on workschedule.getUid
        for(int i=0; i<workschedules.size(); i++){
            workschedule = (Workschedule)workschedules.get(i);

            // parse xml
            String sXML = checkString(workschedule.scheduleXml);
            String sScheduleType = "", sScheduleHours = "";
                        
            if(sXML.length() > 0){
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sXML));

                // fetch type and hours
                Element workScheduleElem = document.getRootElement();
                if(workScheduleElem!=null){
                    Element scheduleElem = workScheduleElem.element("Schedule");
                    if(scheduleElem!=null){
                        sScheduleType = checkString(scheduleElem.attributeValue("type"));
        
                        if(sScheduleType.equalsIgnoreCase("day")){
                            sScheduleHours = checkString(scheduleElem.elementText("HoursPerDay"));
                        }
                        else if(sScheduleType.equalsIgnoreCase("week")){
                            Element weekSchedule = scheduleElem.element("WeekSchedule");
                            if(weekSchedule!=null){
                                sScheduleHours = checkString(weekSchedule.elementText("HoursPerWeek"));
                            }
                        }
                        else if(sScheduleType.equalsIgnoreCase("month")){
                            sScheduleHours = checkString(scheduleElem.elementText("HoursPerMonth"));
                        }
                    }
                }
            }

            // sort on workschedule.getUid
            hSort.put(workschedule.getUid()+"="+workschedule.getUid(),
                      (workschedule.isActive()?"style='background:#99cccc;'":"")+  
                      " onclick=\"displayWorkschedule('"+workschedule.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(workschedule.begin)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+ScreenHelper.getSQLDate(workschedule.end)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+workschedule.fte+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+getTran("web.hr",sScheduleType+"Schedule",sWebLanguage)+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+sScheduleHours+"</td>"+
                     "</tr>");
            
            %><script>addSchedulePeriod('<%=workschedule.getUid()%>','<%=(workschedule.begin==null?"":ScreenHelper.getSQLDate(workschedule.begin))%>_<%=(workschedule.end==null?"":ScreenHelper.getSQLDate(workschedule.end))%>');</script><%
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
    if(workschedules.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border-bottom:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left: 1px;">
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","begin",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","end",sWebLanguage))%></td>
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","fte",sWebLanguage))%></td>
        <td width="20%" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","type",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web.hr","hours",sWebLanguage))%></td>
    </tr>
    
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=workschedules.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>