<%@ page import="org.dom4j.DocumentException,java.util.*,be.openclinic.adt.Encounter,java.util.Date" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<%
    session.removeAttribute("activePatient");
    ScreenHelper.getSQLDate("");
    String simmatnew = checkString(request.getParameter("findimmatnew")).toUpperCase(),
            sArchiveFileCode = checkString(request.getParameter("findArchiveFileCode")).toUpperCase(),
            sPersonID = checkString(request.getParameter("findPersonID")).toUpperCase(),
            snatreg = checkString(request.getParameter("findnatreg")),
            sName = checkString(request.getParameter("findName")).toUpperCase(),
            sFirstname = checkString(request.getParameter("findFirstname")).toUpperCase(),
            sDateOfBirth = checkString(request.getParameter("findDateOfBirth")),
            sDistrict = checkString(request.getParameter("findDistrict")),
            sUnit = checkString(request.getParameter("findUnit"));

    String sAction = checkString(request.getParameter("Action"));
    String sRSIndex = checkString(request.getParameter("RSIndex"));
    List lResults = null;
    int iMaxResultSet = 100, iCounter = 0, iOverallCounter = 0;

    if (checkString(request.getParameter("ListAction")).length() > 0) {
        lResults = (List) session.getAttribute("searchResultsList");
    }
    if ((lResults == null) && (activeUser != null)) {
        if (sAction.equals("MY_HOSPITALIZED")) {
            lResults = AdminPerson.getUserHospitalized(activeUser.userid);
        } else if (sAction.equals("MY_VISITS")) {
            lResults = AdminPerson.getUserVisits(activeUser.userid);
        } else if (sUnit.length() > 0) {
            lResults = AdminPerson.getPatientsInEncounterServiceUID(simmatnew, sArchiveFileCode, snatreg, sName, sFirstname, sDateOfBirth, sUnit, sPersonID,sDistrict);
        } else {
            if((simmatnew+sArchiveFileCode+snatreg+sName+sFirstname+sDateOfBirth+sPersonID+sDistrict).length()>0){
            	lResults = AdminPerson.getAllPatients(simmatnew, sArchiveFileCode, snatreg, sName, sFirstname, sDateOfBirth, sPersonID,sDistrict,iMaxResultSet);
            }
            else {
            	lResults = new ArrayList();
            }
        }
        session.setAttribute("searchResultsList", lResults);
    }

    boolean bRS = false;

    if (lResults.size() > 0) {
        String sResult = "", sLink = "", sClass = "", sPage;
        sPage = activeUser.getParameter("DefaultPage");

        // put a new SessionContainerWO in het session when a patient is searched,
        // otherwise 'Previousvalue' has the content of the previous patient.
        // Keep the user !
        SessionContainerWO sessionContainerWO_old = (SessionContainerWO) session.getAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER");
        session.setAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER", null);
        SessionContainerWO sessionContainerWO_new = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
        sessionContainerWO_new.setUserVO(sessionContainerWO_old.getUserVO());
        session.setAttribute("be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER", sessionContainerWO_new);

        SAXReader xmlReader = new SAXReader();
        String sDefaultPageXML = MedwanQuery.getInstance().getConfigString("templateSource") + "defaultPages.xml";
        Document document;

        Hashtable hDefaultPages = new Hashtable();
        boolean bXMLDocumentError = false;
        try {
            document = xmlReader.read(new URL(sDefaultPageXML));
            if (document != null) {
                Element root = document.getRootElement();
                if (root != null) {
                    Element ePage;
                    Iterator elements = root.elementIterator("defaultPage");
                    String sType, sPageLink;
                    while (elements.hasNext()) {
                        ePage = (Element) elements.next();
                        sType = checkString(ePage.attributeValue("type")).toLowerCase();
                        sPageLink = checkString(ePage.elementText("page"));
                        hDefaultPages.put(sType, sPageLink);
                    }
                }
            }
        }
        catch (DocumentException e) {
            System.out.println("XML-Document Exception in patientslist.jsp");
            bXMLDocumentError = true;
        }

        if ((sPage == null) || (sPage.trim().length() == 0) || bXMLDocumentError && (activeUser.getAccessRight("patient.administration.select"))) {
            sPage = "patientdata.do?ts=" + getTs() + "&personid=";
        } else {
            String sType = checkString((String) hDefaultPages.get(sPage.toLowerCase()));
            if (sType.length() > 0) {
                if (sPage.equals("administration")) {
                    sPage = "patientdata.do?ts=" + getTs() + "&personid=";
                } else {
                    sPage = sType + "&ts=" + getTs() + "&PersonID=";
                }
            } else {
                sPage = "";
            }
        }

        if (sRSIndex.length() > 0) {
            iOverallCounter = Integer.parseInt(sRSIndex);
        }
        String sTmpServiceID, sInactive;
        AdminPerson tempPat;
        Encounter enc;

        while ((iOverallCounter + iCounter) < lResults.size() && iCounter < iMaxResultSet) {
            tempPat = (AdminPerson) lResults.get(iCounter + iOverallCounter);
            sTmpServiceID = "";

            enc = Encounter.getActiveEncounter(tempPat.personid);
            if (enc != null) {
                sInactive = "";
                sTmpServiceID = enc.getServiceUID();
            } else {
                sInactive = "Text";
            }
            if ("On".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("showServiceInPatientList"))) {
                if (sTmpServiceID.trim().length() > 0) {
                    String sHospDate = "<td>"+new SimpleDateFormat("dd/MM/yyyy").format(enc.getBegin())+"</td>";
                    long duration = (new Date().getTime() - enc.getBegin().getTime());
                    long days = 24 * 3600 * 1000;
                    days = days * 90;
                    if (duration > days || duration < 0) {
                        sHospDate = "<td style='color: red'>" + new SimpleDateFormat("dd/MM/yyyy").format(enc.getBegin()) + "</td>";
                    }
                    sTmpServiceID = "<td>" + sTmpServiceID + " " + getTran("Service", sTmpServiceID, sWebLanguage) + "</td>"+sHospDate;
                } else {
                    sTmpServiceID = "<td>&nbsp;</td><td>&nbsp;</td>";
                }
            }

            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            if (sPage.trim().length() > 0) {
                sLink = sPage + checkString(tempPat.personid);
                sResult += ("<tr onClick='window.location.href=\"" + sLink + "\";'");
            } else {
                sLink = "";
                sResult += ("<tr");
            }
            String sImmatNew = "";
            String sNatReg = "";
            Iterator iter = tempPat.ids.iterator();
            AdminID tempAdminID;

            while (iter.hasNext()) {
                tempAdminID = (AdminID) iter.next();
                if (tempAdminID.type.equals("ImmatNew")) {
                    sImmatNew = tempAdminID.value;
                } else if (tempAdminID.type.equals("NatReg")) {
                    sNatReg = tempAdminID.value;
                }
            }

            sResult += (" class=list" + sInactive + sClass + " onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sInactive + sClass + "';\">"
                    + "<td><img src='" + sCONTEXTPATH + "/_img/icon_view.gif' alt='" + getTran("Web", "view", sWebLanguage) + "'></td>"
                    + "<td>" + checkString(sImmatNew) + "</td>"
                    + "<td>" + checkString(sNatReg) + "</td>"
                    + "<td>" + checkString(tempPat.lastname) + "  " + checkString(tempPat.firstname) + "</td>"
                    + "<td>" + checkString(tempPat.gender.toUpperCase()) + "</td>"
                    + "<td>" + tempPat.dateOfBirth + "</td>" +
                    "" + sTmpServiceID
                    + "</tr>");

            iCounter++;
        }

        String sNext = "", sPrevious = "&nbsp;";
        if (iOverallCounter > 0) {
            sPrevious = "<A href='#' class='previousButton' title='" + getTran("Web", "Previous", sWebLanguage)
                    + "' OnClick=\"SF.RSIndex.value='" + (iOverallCounter - iCounter - (iMaxResultSet - iCounter)) + "';SF.ListAction.value='Previous';SF.submit();\">"
                    + "&nbsp;</a>";
        }
        if (lResults.size() > iOverallCounter + iCounter) {
            sNext = "<a href='#' title='" + getTran("Web", "Next", sWebLanguage) + "' OnClick=\"SF.RSIndex.value='"
                    + (iOverallCounter + iCounter) + "';SF.ListAction.value='Next';SF.submit();\"><img src='" + sCONTEXTPATH + "/_img/next.jpg' border='0'></a>";
        }
        if (iCounter == 0) {
            // display 'no results' message
%>
              <tr>
                  <td><%=getTran("web","nopatientsfound",sWebLanguage)%></td>
              </tr>
          <%
      }
      else if ((iOverallCounter + iCounter == 1)&&(!bRS)&&(sLink.length()>0)) {
          %>
              <script>window.location.href = "<c:url value=''/><%=sLink%>";</script>
          <%
      }
      else {

          %>
            <table width='100%' cellspacing='0' class="sortable" id="searchresults">
                <%-- header --%>
                <tr height='20' class='admin'>
                    <td width='20'><%=sPrevious%></td>
                    <td width='107'><%=getTran("Web","immatnew",sWebLanguage)%></td>
                    <td width='107'><%=getTran("Web","natreg.short",sWebLanguage)%></td>
                    <td width='*'><%=getTran("Web","name",sWebLanguage)%></td>
                    <td width='50'><%=getTran("Web","gender",sWebLanguage)%>&nbsp;</td>
                    <td width='110'><%=getTran("Web","dateofbirth",sWebLanguage)%></td>
                    <%
                        if ("On".equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("showServiceInPatientList"))){
                    %>
                        <td width='100'><%=getTran("Web","service",sWebLanguage)%></td>
                        <td width="80"><%=getTran("Web","date",sWebLanguage)%></td>
                    <%
                        }

                        if(sNext.trim().length()>0){
                            %><td width="1%" align="right"><%=sNext%></td><%
                        }
                    %>
                </tr>
                <tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'>
                    <%=sResult%>
                </tbody>
            </table>
            <table width='100%'>
                <%
                if ((sPrevious.trim().length()>0)||(sNext.trim().length()>0)) {
                    %>
                        <tr class='admin'>
                            <td align='right'> <a class="topButton" href='#topp'>&nbsp;</a><%=sNext%></td>
                        </tr>
                    <%
                }
            %>
                <tr class="'admin2">
                    <td align='right'><b><%=getTran("web","totalpatients",sWebLanguage)+" = "+lResults.size()%></b></td>
                </tr>
            </table>
            <%
        }
    }else{
        %>
        <%=getTran("web","nopatientsfound",sWebLanguage)%><br><br>
        <%
            if (((sName.length()>0)||(sFirstname.length()>0)||(sDateOfBirth.length()>0)||(simmatnew.length()>0)) && activeUser.getAccessRight("patient.administration.add")){
        %>
        <a href="<c:url value='/patientnew.do'/>?PatientNew=true&pLastname=<%=sName%>&pFirstname=<%=sFirstname%>&pImmatnew=<%=simmatnew%>&pArchiveCode=<%=sArchiveFileCode%>&pNatreg=<%=snatreg%>&pDateofbirth=<%=sDateOfBirth%>&pDistrict=<%=sDistrict%>"><%=getTran("web","new_patient",sWebLanguage)%></a><br><br>
        <a href="<c:url value='/_common/patient/patienteditSave.jsp'/>?Lastname=<%=sName%>&Firstname=<%=sFirstname%>&DateOfBirth=<%=sDateOfBirth%>&NatReg=<%=snatreg%>&ImmatNew=<%=simmatnew%>&PDistrict=<%=sDistrict%>&PBegin=<%=getDate()%>&NextPage=planning/findPlanning.jsp&SavePatientEditForm=ok"><%=getTran("web","create_person_and_go_to_agenda",sWebLanguage)%></a>
        <%
                }
    }
%>
