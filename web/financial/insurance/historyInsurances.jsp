<%@ page import="be.openclinic.finance.Insurance,java.util.Vector,be.openclinic.finance.Insurar" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.insurancehistory","select",activeUser)%>
<%=sJSSORTTABLE%>
<%
    String sFindSortColumn = checkString(request.getParameter("SortColumn"));

    StringBuffer sbResults = new StringBuffer();

    if (sFindSortColumn.length() > 0) {
        sFindSortColumn += " DESC";
    } else {
        sFindSortColumn = " OC_INSURANCE_STOP";
    }

    Vector vInsurances = Insurance.selectInsurances(activePatient.personid, sFindSortColumn);

    Iterator iter = vInsurances.iterator();
    Insurance insurance;
    Insurar insurar;

    boolean bFinished = false;
    String sClass = "",sInactive = "",sInactiveSelect = "";
    String sStart = "", sStop = "", sCompanyName = "", sNumber = "", sType = "", sComment = "";

    while (iter.hasNext()) {
        insurance = (Insurance) iter.next();

        if (insurance.getStop() == null || insurance.getStop().after(ScreenHelper.getSQLDate(getDate()))) {
            bFinished = false;
        } else {
            bFinished = true;
        }

        if (insurance.getStart() != null) {
            sStart = ScreenHelper.stdDateFormat.format(insurance.getStart());
        } else {
            sStart = "";
        }

        if (insurance.getStop() != null) {
            sStop = ScreenHelper.stdDateFormat.format(insurance.getStop());
        } else {
            sStop = "";
        }

        insurar = insurance.getInsurar();

        if (insurar!=null){
            sCompanyName = ScreenHelper.checkString(insurar.getName());
        }
        else {
            sCompanyName = "";
        }
        sNumber = ScreenHelper.checkString(insurance.getInsuranceNr());
        sType = ScreenHelper.checkString(insurance.getType());
        sComment = insurance.getComment().toString();

        if (bFinished) {
            sInactive = "Text";
            sInactiveSelect = "";
        } else {
            sInactive = "bold";
            sInactiveSelect = "bold";
        }

        if (sClass.equals("")) {
            sClass = "1";
        } else {
            sClass = "";
        }

        sbResults.append("<tr " + (bFinished ? "" : "id='active'") + " class='list" + sInactive + sClass + "' " +
                " onmouseover=\"this.style.cursor='hand';\" " +
                " onmouseout=\"this.style.cursor='default';\" " +
                " onclick=\"doSelect('" + insurance.getUid() + "');\">" +
                "<td height='20'>" + sStart + "</td>" +
                "<td>" + sStop + "</td>" +
                "<td>" + sNumber + "</td>" +
                "<td>" + sType + "</td>" +
                "<td>" + sCompanyName + "</td>" +
                "<td>" + sComment + "</td>"
        );
    }

    String sTitle1 = getTran("Web", "begindate", sWebLanguage);
    String sTitle2 = getTran("Web", "enddate", sWebLanguage);

    if (sFindSortColumn.length() > 0) {
        sTitle1 = "<i>" + sTitle1 + "</i>";
    } else {
        sTitle2 = "<i>" + sTitle2 + "</i>";
    }
%>
<form name='HistoryInsuranceForm' method='post'>
    <input type='hidden' name='SortColumn' value=''>
    <%=writeTableHeader("web","historyinsurances",sWebLanguage," doBack();")%>
    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
        <%-- header --%>
        <tr class="gray">
            <td width="10%"><a href="#" class="underlined" onClick="doSearch('OC_INSURANCE_START');"><%=sTitle1%></a></td>
            <td width="10%"><a href="#" class="underlined" onClick="doSearch('OC_INSURANCE_STOP');"><%=sTitle2%></a></td>
            <td width='20%'><%=getTran("insurance","insurancenr",sWebLanguage)%></td>
            <td width='20%'><%=getTran("Web","type",sWebLanguage)%></td>
            <td width='15%'><%=getTran("Web","company",sWebLanguage)%></td>
            <td width='25%'><%=getTran("Web","comment",sWebLanguage)%></td>
        </tr>
        <%=sbResults%>
    </table>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
    function doSearch(sortCol){
       HistoryInsuranceForm.SortColumn.value = sortCol;
       HistoryInsuranceForm.submit();
    }

    function doSelect(id){
        window.location.href="<c:url value='/main.do'/>?Page=financial/insurance/editInsurance.jsp&EditInsuranceUID=" + id + "&ts=<%=getTs()%>";
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

  function updateRowStyles(){
    var sClassName;

    for(var i=1; i<searchresults.rows.length; i++){
      searchresults.rows[i].style.cursor = "hand";
      sClassName = searchresults.rows[i].className;

      if(sClassName.indexOf("bold") > -1){
        searchresults.rows[i].className = "listbold";
      }
      else{
        searchresults.rows[i].className = "listText";
      }

      if(i%2>0){
        searchresults.rows[i].className+= "1";
      }

      if(i%2>0){
        searchresults.rows[i].onmouseout = function(){
          if(this.id.indexOf("active")==0){
            this.className = "listbold1";
          }
          else{
            this.className = "listText1";
          }
        }
      }
      else{
        searchresults.rows[i].onmouseout = function(){
          if(this.id.indexOf("active")==0){
            this.className = "listbold";
          }
          else{
            this.className = "listText";
          }
        }
      }
    }
  }
</script>