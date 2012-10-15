<%@ page import="be.openclinic.medical.LabAnalysis,java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<p align="center">One moment please...</p>
<%
    String sSearchCode = checkString(request.getParameter("SearchCode")).toLowerCase();
    String sVarID = checkString(request.getParameter("VarID"));
    String sVarType = checkString(request.getParameter("VarType"));
    String sVarCode = checkString(request.getParameter("VarCode"));
    String sVarText = checkString(request.getParameter("VarText"));

    String sID = "", sType = "", sCode = "", sText = "", sCodeOther = "";

    // compose select
    String lowerCode = MedwanQuery.getInstance().getConfigParam("lowerCompare", "la.labcode");

    Vector vResults = LabAnalysis.blurSelectLabAnalysis(lowerCode, sSearchCode);
    Iterator iter = vResults.iterator();

    int recCount = 0;

    while (iter.hasNext()) {
        recCount++;
        LabAnalysis objLA = (LabAnalysis) iter.next();

        sID = Integer.toString(objLA.getLabId());
        sType = objLA.getLabtype();
        sCode = objLA.getLabcode();
        sCodeOther = objLA.getLabcodeother();
        sText = getTran("labanalysis", sID, sWebLanguage);
    }

    // translate labtype
    if (sType.equals("1")) sType = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
    else if (sType.equals("2")) sType = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
    else if (sType.equals("3")) sType = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
    else if (sType.equals("4")) sType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
    else if (sType.equals("5")) sType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
    else if (sType.equals("6")) sType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
    else if (sType.equals("7")) sType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

    // multiple records found, open search-window, allowing the user to select a record.
    if (recCount > 1) {
%>
            <script>
              window.opener.document.getElementsByName('LabChooseButton')[0].click();
            </script>
        <%
    }
    // set data of the one found record in opener window
    else if(sText.trim().length() > 0){
        %>
            <script>
              window.opener.document.getElementsByName('<%=sVarID%>')[0].value = "<%=sID%>";
              window.opener.document.getElementsByName('<%=sVarType%>')[0].value = "<%=sType%>";
              window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = "<%=sCode%>";
              window.opener.document.getElementsByName('<%=sVarText%>')[0].value = "<%=sText%>";
              window.opener.document.getElementsByName('<%=sVarText%>')[0].title = "<%=sText%>";
              <%
                  if(sCodeOther.equals("1")){
                      %>
                        window.opener.document.getElementsByName('LabComment')[0].readOnly = false;
                        window.opener.document.getElementsByName('LabComment')[0].focus();
                        window.opener.document.getElementsByName('LabCodeOther')[0].value = "1";
                      <%
                  }
                  else{
                      %>
                        window.opener.document.getElementsByName('LabComment')[0].readOnly = true;
                        window.opener.document.getElementsByName('LabCodeOther')[0].value = "0";
                      <%
                  }
              %>

              window.close();
            </script>
        <%
    }
    // no record found, so no data
    else{
        %>
            <script>
              window.opener.document.getElementsByName('<%=sVarID%>')[0].value = "";
              window.opener.document.getElementsByName('<%=sVarType%>')[0].value = "";
              window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = "";
              window.opener.document.getElementsByName('<%=sVarText%>')[0].value = "";
              window.opener.document.getElementsByName('<%=sVarText%>')[0].title = "";
              window.opener.document.getElementsByName('LabComment')[0].value = "";
              window.opener.document.getElementsByName('LabComment')[0].readOnly = true;
              window.opener.document.getElementsByName('LabCodeOther')[0].value = "";

              window.opener.document.getElementsByName('<%=sVarCode%>')[0].focus();
              window.close();
            </script>
        <%
    }
%>