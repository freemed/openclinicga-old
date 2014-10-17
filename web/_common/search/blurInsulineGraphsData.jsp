<%@page import="java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String beginDateInsulineGraphs = checkString(request.getParameter("BeginDate"));
   
    // get data from one month ago untill now
    Calendar now = new GregorianCalendar();
    java.util.Date beginDate = ScreenHelper.parseDate(beginDateInsulineGraphs);

    //--- GET GRAPH DATA : INSULINE RAPID ---------------------------------------------------------
    Hashtable insDatesAndValues = MedwanQuery.getInstance().getInsulineShots(activePatient.personid,"RAPID",beginDate,now.getTime());

    // sort hash on dates (DB only sorted them on day, not on hour)
    Vector dates = new Vector(insDatesAndValues.keySet());
    Collections.sort(dates);

    String sInsBeginDate = "", sInsEndDate;
    StringBuffer sInsDates = new StringBuffer(),
                 sInsValues = new StringBuffer();

    // concatenate vector-content to use in JS below
    String value;
    java.util.Date date;
    for(int i=0; i<dates.size(); i++){
        date = (java.util.Date) dates.get(i);
        value = (String)insDatesAndValues.get(date);
        sInsEndDate = checkString(ScreenHelper.fullDateFormat.format(date));

        // keep notice of the earlyest date
        if(sInsBeginDate.trim().length()==0){
            sInsBeginDate = sInsEndDate;
        }

        // concatenate
        sInsDates.append("'"+sInsEndDate+"',");
        sInsValues.append("'"+value+"',");
    }

    // remove last commas from concatenate-strings
    if(sInsDates.length() > 0){
        sInsDates = sInsDates.deleteCharAt(sInsDates.length() - 1);
    }

    if(sInsValues.length() > 0){
        sInsValues = sInsValues.deleteCharAt(sInsValues.length() - 1);
    }
%>

<script>
  window.opener.aInsRValues = new Array(<%=sInsValues.toString()%>);
  window.opener.aInsRDates  = new Array(<%=sInsDates.toString()%>);

  <%-- redraw graph --%>
  window.opener.drawGraph_InsulineRapid("<%=beginDateInsulineGraphs%>",window.opener.document.getElementById('insulineRapidGraph'));

  window.close();
</script>