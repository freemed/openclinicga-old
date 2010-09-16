<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCity = "";

    String sZipcodeValue = checkString(request.getParameter("ZipcodeValue"));
    String sCityName = checkString(request.getParameter("CityName"));
    String sCityValue = checkString(request.getParameter("CityValue"));
    String sVarButton = checkString(request.getParameter("VarButton"));

    // what language to display data in
    String cityDisplayLang = checkString(request.getParameter("DisplayLang"));
    if (cityDisplayLang.length() == 0) {
        if (activePatient != null) cityDisplayLang = activePatient.language;
        else cityDisplayLang = activeUser.person.language;
    }

    // convert language
    if (cityDisplayLang.equalsIgnoreCase("F")) cityDisplayLang = "fr";
    else if (cityDisplayLang.equalsIgnoreCase("N")) cityDisplayLang = "nl";
    else if (cityDisplayLang.equalsIgnoreCase("E")) cityDisplayLang = "en";
    else if (cityDisplayLang.equalsIgnoreCase("D")) cityDisplayLang = "de";
    else {
        cityDisplayLang = "nl";
    }
    Vector vResults = Zipcode.blurSelectCityTranslation(cityDisplayLang, sZipcodeValue.toLowerCase(), "");
    Iterator iter = vResults.iterator();
    String sValue = "";

    int iTotal = 0;

    while (iter.hasNext()) {
        sValue = (String) iter.next();
        sCity = sValue;
        iTotal++;
    }

    //*** multiple matches ***
    if (iTotal > 1) {
        Vector vResults2 = new Vector();
        vResults2 = Zipcode.blurSelectCityTranslation(cityDisplayLang, sZipcodeValue.toLowerCase(), sCityValue.toLowerCase());
        Iterator iter2 = vResults2.iterator();

        while (iter2.hasNext()) {
            sValue = (String) iter2.next();
            sCity = sValue;
        }
    }

    if (sCity.length() > 0) {
%>
            <script>
              window.opener.document.all['<%=sCityName%>'].value = "<%=sCity%>";
              window.opener.document.all['<%=sCityName%>'].title = "<%=sCity%>";
              window.close();
            </script>
        <%
    }
    else{
        %>
            <script>
              if('<%=sVarButton%>'.length > 0){
                window.opener.document.all['<%=sVarButton%>'].click();
              }

              window.close();
            </script>
        <%
    }
%>