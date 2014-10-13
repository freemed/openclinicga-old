<%@page import="java.util.*,
                java.util.Date,
                be.openclinic.adt.Encounter"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindBegin       = checkString(request.getParameter("FindBegin")),
           sFindEnd         = checkString(request.getParameter("FindEnd")),
           sFindServiceText = checkString(request.getParameter("FindServiceText")),
           sFindServiceCode = checkString(request.getParameter("FindServiceCode"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** statistics/hospitalizedPatients.jsp ****************");
    	Debug.println("sFindBegin       : "+sFindBegin);
    	Debug.println("sFindEnd         : "+sFindEnd);
    	Debug.println("sFindServiceText : "+sFindServiceText);
    	Debug.println("sFindServiceCode : "+sFindServiceCode+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("Web","statistics.hospitalizedpatients",sWebLanguage," doBack();")%>
    
    <table class="menu" width="100%" cellspacing="1" cellpadding="0">
        <%-- SERVICE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="FindServiceText" READONLY size="<%=sTextWidth%>" title="<%=sFindServiceText%>" value="<%=sFindServiceText%>">
                <%=ScreenHelper.writeServiceButton("ButtonService","FindServiceCode","FindServiceText",sWebLanguage,sCONTEXTPATH)%>
                <input type="hidden" name="FindServiceCode" value="<%=sFindServiceCode%>">&nbsp;
            </td>
        </tr>
         <tr>
            <td class="admin"><%=getTran("Web","begin",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web","end",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
                <input type="button" class="button" name="ButtonBack" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
</form>

<%
    if(sFindBegin.length() > 0 || sFindEnd.length() > 0){
        Hashtable hServices = Encounter.getHospitalizePatients(sFindBegin,sFindEnd,sFindServiceCode);
        String sServiceId;
        Hashtable hSortedServices = new Hashtable();

        Enumeration servEnum = hServices.keys();
        while(servEnum.hasMoreElements()){
            sServiceId = (String)servEnum.nextElement();
            hSortedServices.put(getTran("service",sServiceId,sWebLanguage).toLowerCase(),sServiceId);
        }

        Vector v = new Vector(hSortedServices.keySet());
        Collections.sort(v);
        Iterator it = v.iterator();
        Date dBegin, dEnd, dFindBegin, dFindEnd;
        int iBroughtForward, iNewPatients,  iSubtotal, iCarriedForward = -1;
        String sDate, sClass = "", sOutcome, sTmpFindBegin;
        Hashtable hRow;
        Vector vRows;

        if(sFindEnd.length()==0){
            sFindEnd = getDate();
        }

        // outcomes
        Hashtable hOutcomes = new Hashtable();
        Hashtable hOutcomesTotal = new Hashtable();
        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
        Iterator itOutcome = null;
        String sLabelValue, sLabelID;
        Vector vOutcome = new Vector();
        if(labelTypes!=null){
            Hashtable labelIds = (Hashtable)labelTypes.get("encounter.outcome");

            if(labelIds!=null){
                Enumeration idsEnum = labelIds.elements();
                Label label;
                while(idsEnum.hasMoreElements()){
                    label = (Label)idsEnum.nextElement();
                    hOutcomes.put(label.value,label.id);
                    hOutcomesTotal.put(label.id.toLowerCase(),new Integer(0));
                }
                vOutcome = new Vector(hOutcomes.keySet());
                Collections.sort(vOutcome);
            }
        }

        int rowsDisplayed = 0;
        while(it.hasNext()){
            sServiceId = (String)it.next();
            sServiceId = (String)hSortedServices.get(sServiceId);
            
            %>
            <%-- LINK TO BOTTOM AND TOP OF PAGE --%>
            <span style="width:100%;text-align:right;height:16px;">
                <a href="#bottom" class="bottombutton">&nbsp;</a>
                <a href="#topp" class="topbutton">&nbsp;</a>
            </span>

            <table class="list" width="100%" cellspacing="1" cellpadding="0">
                <tr class="admin"><td colspan="<%=hOutcomes.size()+5%>"><%=sServiceId%> - <%=getTran("service",sServiceId,sWebLanguage)%></td></tr>
                
                <%-- HEADING 1 --%>
                <tr>
                    <td class="admin" rowspan="2" width="60"><center><%=getTran("web","date",sWebLanguage)%>&nbsp;</center></td>
                    <td class="admin" rowspan="2"><center><%=getTran("web.statistics","brought.forward",sWebLanguage)%>&nbsp;</center></td>
                    <td class="admin" rowspan="2"><center><%=getTran("web.statistics","new.patients",sWebLanguage)%>&nbsp;</center></td>
                    <td class="admin" colspan="<%=hOutcomes.size()+1%>"><center><%=getTran("web.statistics","departures",sWebLanguage)%>&nbsp;</center></td>
                    <td class="admin" rowspan="2"><center><%=getTran("web","carried.forward",sWebLanguage)%>&nbsp;</center></td>
                </tr>
                
                <%-- HEADING 2 --%>
                <tr>
                    <%
	                    itOutcome = vOutcome.iterator();
	
	                    while(itOutcome.hasNext()){
	                        sLabelValue = (String)itOutcome.next();
	                        %><td class="admin2" width="90"><b><center><%=sLabelValue%></center></b></td><%
	                    }
                    %>
                    <td class="admin" width="100"><center><%=getTran("web.statistics","subtotal",sWebLanguage)%></center></td>
                </tr>
            <%
            
            vRows = (Vector)hServices.get(sServiceId);

            sTmpFindBegin = ScreenHelper.getDateAdd(sFindBegin,"-1");
            dFindBegin = ScreenHelper.getSQLDate(sTmpFindBegin);
            dFindEnd = ScreenHelper.getSQLDate(sFindEnd);
            if(dFindBegin!=null){
                while(dFindBegin.getTime() < dFindEnd.getTime()){
                    if(sTmpFindBegin.length() > 0){
                        iBroughtForward = Encounter.getHospitalizePatientsAtDate(sTmpFindBegin, sServiceId);
                        sTmpFindBegin = "";
                    }
                    else{
                        iBroughtForward = iCarriedForward;
                    }
                    iNewPatients = 0;
                    iSubtotal = 0;
                    iCarriedForward = 0;

                    sDate = ScreenHelper.getDateAdd(ScreenHelper.getSQLDate(dFindBegin),"1");
                    dFindBegin = ScreenHelper.getSQLDate(sDate);

                    for(int i=0; i<vRows.size(); i++){
                        hRow = (Hashtable)vRows.elementAt(i);
                        dBegin = (Date)hRow.get("begin");
                        dEnd = (Date)hRow.get("end");
                        sOutcome = (String) hRow.get("outcome");

                        if(ScreenHelper.getSQLDate(dBegin).equals(ScreenHelper.getSQLDate(dFindBegin))){
                            iNewPatients++;
                        }
                        else{
                            if(ScreenHelper.getSQLDate(dEnd).equals(ScreenHelper.getSQLDate(dFindBegin))){
                                hOutcomesTotal.put(sOutcome.toLowerCase(),new Integer(((Integer)hOutcomesTotal.get(sOutcome.toLowerCase())).intValue()+1));
                                iSubtotal++;
                            }
                        }
                    }

                    iCarriedForward = iBroughtForward + iNewPatients - iSubtotal;

                    // alternate row-style
                    if(sClass.equals("")) sClass ="1";
                    else                  sClass = "";

                    rowsDisplayed++;
                    
                    %>
	                    <tr class="list<%=sClass%>">
	                        <td><%=sDate%></td>
	                        <td align="right"><%=iBroughtForward%></td>
	                        <td align="right"><%=iNewPatients%></td>
	                        <%
	                            itOutcome = vOutcome.iterator();
	
	                            while(itOutcome.hasNext()){
	                                sLabelValue = (String)itOutcome.next();
	                                sLabelID = (String)hOutcomes.get(sLabelValue);
	
	                                %><td align="right"><%=((Integer)hOutcomesTotal.get(sLabelID)).intValue()%></td><%
	                                hOutcomesTotal.put(sLabelID,new Integer(0));
	                            }
	                        %>
	                        <td align="right"><%=iSubtotal%></td>
	                        <td align="right"><%=iCarriedForward%></td>
	                    </tr>
                    <%
                }
            }
            
            %>
            </table>
            <div style="padding-top:5px;"></div>
            <%
        }            

        if(hServices.size()==0){
            out.print(getTran("web","norecordsfound",sWebLanguage));
        }
        else{
            // link to top of page
            if(rowsDisplayed > 20){
                %>
                    <span style="width:100%;text-align:right;height:20px;">
                        <a href="#topp" class="topbutton">&nbsp;</a>
                    </span>
                <%
            }

            // print pdf button
            sFindBegin = checkString(request.getParameter("FindBegin")); // original posted value
            sFindEnd   = checkString(request.getParameter("FindEnd")); // original posted value
            
            if(sFindBegin.length() > 0 || sFindEnd.length() > 0){
                %>
                    <br>
                    <div style="width:100%;text-align:right;height:20;">
                        <input class="button" type="button" name="printPdfButton" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onclick="printPdf('<%=sFindServiceCode%>','<%=sFindBegin%>','<%=sFindEnd%>');">
                    </div>
                <%
            }
        }
    }
%>
<script>
  <%-- PRINT PDF --%>
  function printPdf(serviceCode,sBeginDate,sEndDate){
    var url = "<c:url value='/statistics/createHospitalizedPatientsPdf.jsp'/>"+
              "?ServiceCode="+serviceCode+
              "&BeginDate="+sBeginDate+
              "&EndDate="+sEndDate+
              "&ts=<%=getTs()%>";
    window.open(url,"HospitalizedPatientsPdf","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }

  <%-- CLEAR FIELDS --%>
  function clearFields(){
    document.getElementById("FindBegin").value = "";
    document.getElementById("FindEnd").value = "";
    document.getElementById("FindServiceText").value = "";
    document.getElementById("FindServiceCode").value = "";
  }

  <%-- DO FIND --%>
  function doFind(){
    if(document.getElementById("FindBegin").value.length > 0){
      transactionForm.submit();
    }
    else{
      document.getElementById("FindBegin").focus();
      alertDialog("web.manage","datamissing");
    }
  }

  document.getElementById("FindBegin").focus();
</script>

<a name="bottom">&nbsp;</a>