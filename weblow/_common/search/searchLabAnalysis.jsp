<%@ page import="be.openclinic.medical.LabAnalysis" %>
<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- WRITE ROW -------------------------------------------------------------------------------
    private String writeRow(String sID, String sType, String sCode, String sLabel, String sWebLanguage){
        if (sLabel.startsWith("<")){
            sLabel = "";
        }

        // translate labtype
             if(sType.equals("1")) sType = getTran("Web.occup","labanalysis.type.blood",sWebLanguage);
        else if(sType.equals("2")) sType = getTran("Web.occup","labanalysis.type.urine",sWebLanguage);
        else if(sType.equals("3")) sType = getTran("Web.occup","labanalysis.type.other",sWebLanguage);
        else if (sType.equals("4")) sType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
        else if (sType.equals("5")) sType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
        else if (sType.equals("6")) sType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
        else if (sType.equals("7")) sType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

        return "<tr>"+
               " <td class='admin' width='60'><a href='#' onclick='selectLabAnalysis(\""+sID+"\",\""+sType+"\",\""+sCode+"\",\""+sLabel+"\")' title='"+getTran("web","select",sWebLanguage)+"'>"+sCode+"</a></td>"+
               " <td class='admin2' width='70'>"+sType+"</td>"+
               " <td class='admin2'>"+sLabel+"</td>"+
               "</tr>";
    }
%>
<%
    String sVarID = checkString(request.getParameter("VarID")),
            sVarCode = checkString(request.getParameter("VarCode")),
            sVarType = checkString(request.getParameter("VarType")),
            sVarText = checkString(request.getParameter("VarText")),
            sSearchCode = checkString(request.getParameter("FindCode")),
            sFindText = checkString(request.getParameter("FindText"));

    /*
    // DEBUG ////////////////////////////////////////////////////////////////////////////
    Debug.println("### DEBUG ##########################################");
    Debug.println("### sVarID      = "+sVarID);
    Debug.println("### sVarCode    = "+sVarCode);
    Debug.println("### sVarType    = "+sVarType);
    Debug.println("### sVarText    = "+sVarText);
    Debug.println("### sSearchCode = "+sSearchCode);
    Debug.println("### sFindText   = "+sFindText+"\n\n");
    /////////////////////////////////////////////////////////////////////////////////////
    */

    // sort col
    String sSortCol = checkString(request.getParameter("SortCol"));
    if (sSortCol.length() == 0) sSortCol = "name";

    // variables
    StringBuffer sOut = new StringBuffer();
    String sLabID, sLabType, sLabCode, sCodeOther = "", sLabel;
    boolean showMsg = false;
    int iTotal = 0;

    //--- search on LABCODE -----------------------------------------------------------------------
    if (sSearchCode.length() > 0) {
        sFindText = ""; // if searched on code, you can not search on name

        Vector hLabAnalysis = LabAnalysis.searchByLabCode(sSearchCode, sSortCol, sWebLanguage);

        LabAnalysis objLabAnalysis;
        for (int n=0;n<hLabAnalysis.size();n++) {
            objLabAnalysis = (LabAnalysis) hLabAnalysis.elementAt(n);
            iTotal++;
            sLabID = Integer.toString(objLabAnalysis.getLabId());
            sLabType = objLabAnalysis.getLabtype();
            sLabCode = objLabAnalysis.getLabcode();
            sCodeOther = objLabAnalysis.getLabcodeother();
            sLabel = objLabAnalysis.getMedidoccode();

            sOut.append(writeRow(sLabID, sLabType, sLabCode, sLabel, sWebLanguage));
        }

        showMsg = true;
    }
    //--- search on LABLABEL ----------------------------------------------------------------------
    else if (sFindText.length() > 0) {
        String lowerLabel = checkString(MedwanQuery.getInstance().getConfigParam("lowerCompare", "OC_LABEL_VALUE"));

        if (lowerLabel.length() > 0) {
            Hashtable hLabAnalysis = LabAnalysis.searchByLabLabel(sFindText, sSortCol, sWebLanguage);

            Enumeration e = hLabAnalysis.keys();
            String sKey;

            LabAnalysis objLabAnalysis;

            while (e.hasMoreElements()) {
                iTotal++;

                sKey = (String) e.nextElement();
                objLabAnalysis = (LabAnalysis) hLabAnalysis.get(sKey);
                sLabID = Integer.toString(objLabAnalysis.getLabId());
                sLabType = objLabAnalysis.getLabtype();
                sLabCode = objLabAnalysis.getLabcode();
                sCodeOther = objLabAnalysis.getLabcodeother();
                sLabel = sKey;

                sOut.append(writeRow(sLabID, sLabType, sLabCode, sLabel, sWebLanguage));
            }

            showMsg = true;
        }
    }
    //--- DISPLAY NOTHING OR ALL ANALYSES ---------------------------------------------------------
    else {
        if (MedwanQuery.getInstance().getConfigString("fillUpSearchScreens").equalsIgnoreCase("on")) {
            Vector hLabAnalysis = LabAnalysis.searchByLabCode("%", sSortCol, sWebLanguage);

            LabAnalysis objLabAnalysis;
            for (int n=0;n<hLabAnalysis.size();n++) {
                objLabAnalysis = (LabAnalysis) hLabAnalysis.elementAt(n);
                iTotal++;
                sLabID = Integer.toString(objLabAnalysis.getLabId());
                sLabType = objLabAnalysis.getLabtype();
                sLabCode = objLabAnalysis.getLabcode();
                sCodeOther = objLabAnalysis.getLabcodeother();
                sLabel = objLabAnalysis.getMedidoccode();

                sOut.append(writeRow(sLabID, sLabType, sLabCode, sLabel, sWebLanguage));
            }

            showMsg = true;
        }
    }
%>
<form name="searchForm" method="POST" onSubmit="doFind();">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="menu">
    <%-- SEARCH INPUTS --%>
    <tr>
      <td width='100%' height='25'>
        &nbsp;<%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindCode" value="<%=sSearchCode%>" size="16">
        &nbsp;<%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindText" value="<%=sFindText%>" size="32">

        <%-- BUTTONS --%>
        &nbsp;<input class="button" type="button" name="FindButton"  value="<%=getTran("Web","find",sWebLanguage)%>" onClick="doFind();">
        &nbsp;<input class="button" type="button" name="ClearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onClick="clearForm();">
      </td>
    </tr>

    <tr><td class="navigation_line" height="1"></td></tr>

    <script>
      function clearForm(){
        searchForm.FindCode.value = "";
        searchForm.FindText.value = "";
        searchForm.FindCode.focus();
      }

      function doFind(){
        ToggleFloatingLayer("FloatingLayer",1);
        searchForm.FindButton.disabled = true;
        searchForm.submit();
      }
    </script>

    <%-- SEARCH RESULTS --%>
    <tr>
      <td class="white" valign="top">
        <div class="search" style="overflow: auto;width:530px;height: 400px">
          <table width="100%" cellspacing="1" cellpadding="0">
            <%-- HEADER --%>
            <tr class="admin">
              <td width="60"><a class="underlined" href="#" onClick="searchForm.SortCol.value='labcode';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%></a></td>
              <td width="70"><a class="underlined" href="#" onClick="searchForm.SortCol.value='labtype';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.type",sWebLanguage)%></a></td>
              <td width="180"><a class="underlined" href="#" onClick="searchForm.SortCol.value='name';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%></a></td>
            </tr>

            <%=sOut%>

            <%
              if(showMsg){
                out.print("<tr><td colspan='3'><br>"+iTotal+" "+getTran("web","recordsfound",sWebLanguage)+"</td></tr>");
              }
            %>
          </table>
        </div>
      </td>
    </tr>
  </table>

  <br>

  <%-- CLOSE BUTTON --%>
  <center>
    <input type="button" name="buttonclose" class="button" value="<%=getTran("Web","Close",sWebLanguage)%>" onclick="window.close();">
  </center>

  <%-- HIDDEN FIELDS --%>
  <input type="hidden" name="VarCode" value="<%=sVarCode%>">
  <input type="hidden" name="VarText" value="<%=sVarText%>">
  <input type="hidden" name="SortCol" value="<%=sSortCol%>">

  <script>
    window.resizeTo(542,484);
    searchForm.FindCode.focus();

    <%-- select labanalysis --%>
    function selectLabAnalysis(sID,sType,sCode,sText){
      window.opener.document.all['<%=sVarID%>'].value = sID;
      window.opener.document.all['<%=sVarType%>'].value = sType;
      window.opener.document.all['<%=sVarCode%>'].value = sCode;
      window.opener.document.all['<%=sVarText%>'].value = sText;
      window.opener.document.all['<%=sVarText%>'].title = sText;

      <%
          if(sCodeOther.equals("1")){
              %>
                window.opener.document.all['LabComment'].readOnly = false;
                window.opener.document.all['LabComment'].focus();
                window.opener.document.all['LabCodeOther'].value = "1";
              <%
          }
          else{
              %>window.opener.document.all['LabComment'].readOnly = true;<%
          }
      %>

      window.close();
    }
  </script>
</form>
