<%@ page import="java.util.Hashtable" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
    String sEditCareUid = checkString(request.getParameter("EditCareUid"));
    String sConfig = checkString(MedwanQuery.getInstance().getConfigString("CareType" + sEditCareUid));
    String sEditUnitsPerTimeUnit = "",sEditTimeUnitCount = "",sEditTimeUnit = "",sTime1 = "",sTime2 = "",sTime3 = "",sTime4 = "",
            sTime5 = "",sTime6 = "",sQuantity1 = "",sQuantity2 = "",sQuantity3 = "",sQuantity4 = "",sQuantity5 = "",sQuantity6 = "";

    if (sConfig.length() > 0) {
        Hashtable hConfig = new Hashtable();
        String[] aConfig = sConfig.split(",");
        String[] aValue;

        for (int i = 0; i < aConfig.length; i++) {
            aValue = aConfig[i].split("=");

            if (aValue.length > 1) {
                hConfig.put(aValue[0], aValue[1]);
            }
        }

        sEditUnitsPerTimeUnit = checkString((String) hConfig.get("UnitsPerTimeUnit"));
        sEditTimeUnitCount = checkString((String) hConfig.get("TimeUnitCount"));
        sEditTimeUnit = checkString((String) hConfig.get("TimeUnit"));
        sTime1 = checkString((String) hConfig.get("t1"));
        sTime2 = checkString((String) hConfig.get("t2"));
        sTime3 = checkString((String) hConfig.get("t3"));
        sTime4 = checkString((String) hConfig.get("t4"));
        sTime5 = checkString((String) hConfig.get("t5"));
        sTime6 = checkString((String) hConfig.get("t6"));
        sQuantity1 = checkString((String) hConfig.get("q1"));
        sQuantity2 = checkString((String) hConfig.get("q2"));
        sQuantity3 = checkString((String) hConfig.get("q3"));
        sQuantity4 = checkString((String) hConfig.get("q4"));
        sQuantity5 = checkString((String) hConfig.get("q5"));
        sQuantity6 = checkString((String) hConfig.get("q6"));
    }
%>
{
"EditUnitsPerTimeUnit":"<%=sEditUnitsPerTimeUnit%>",
"EditTimeUnitCount":"<%=sEditTimeUnitCount%>",
"EditTimeUnit":"<%=sEditTimeUnit%>",
"time1":"<%=sTime1%>",
"time2":"<%=sTime2%>",
"time3":"<%=sTime3%>",
"time4":"<%=sTime4%>",
"time5":"<%=sTime5%>",
"time6":"<%=sTime6%>",
"quantity1":"<%=sQuantity1%>",
"quantity2":"<%=sQuantity2%>",
"quantity3":"<%=sQuantity3%>",
"quantity4":"<%=sQuantity4%>",
"quantity5":"<%=sQuantity5%>",
"quantity6":"<%=sQuantity6%>"
}