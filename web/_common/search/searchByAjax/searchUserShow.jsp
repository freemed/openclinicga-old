<%@ page import="org.dom4j.DocumentException,
                 java.util.Vector,
                 java.util.Hashtable,
                 java.util.Enumeration,
                 be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%!
    //--- GET HTML --------------------------------------------------------------------------------
    private String getHtml(Vector users, String sWebLanguage) {
        String sClass = "1";
        StringBuffer html = new StringBuffer();
        Hashtable hServices = new Hashtable();
        String sServiceID, sServiceName;
        // run thru users
        Hashtable user;
        for (int i = 0; i < users.size(); i++) {
            user = (Hashtable) users.get(i);

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            sServiceID = (String) user.get("serviceId");
            sServiceName = checkString((String) hServices.get(sServiceID));

            if (sServiceName.length() == 0) {
                sServiceName = getTran("service", sServiceID, sWebLanguage);
                hServices.put(sServiceID, sServiceName);
            }
            // one row
            html.append("<tr class='list" + sClass + "' onclick=\"setPerson('" + user.get("personId") + "','" + user.get("userId") + "','" + user.get("lastName") + " " + user.get("firstName") + "');\">")
                    .append(" <td class='hand'>" + user.get("lastName") + " " + user.get("firstName") + " (" + user.get("userId") + ")</td>")
                    .append(" <td class='hand'>" + sServiceName + "</td>")
                    .append("</tr>");
        }

        return html.toString();
    }

    //--- GET SERVICE IDS FROM XML ----------------------------------------------------------------
    private Vector getServiceIdsFromXML(HttpServletRequest request) throws Exception {
        Vector ids = new Vector();
        Document document;

        SAXReader xmlReader = new SAXReader();
        String sXmlFile = MedwanQuery.getInstance().getConfigString("servicesXMLFile"), xmlFileUrl;

        if ((sXmlFile != null) && (sXmlFile.length() > 0)) {
            // Check if xmlFile exists, else use file at templateSource location.
            try {
                xmlFileUrl = "http://" + request.getServerName() + request.getRequestURI().replaceAll(request.getServletPath(), "") + "/" + sAPPDIR + "/_common/xml/" + sXmlFile;
                document = xmlReader.read(new URL(xmlFileUrl));
                if (Debug.enabled) Debug.println("Using custom services file : " + xmlFileUrl);
            }
            catch (DocumentException e) {
                xmlFileUrl = MedwanQuery.getInstance().getConfigString("templateSource") + "/" + sXmlFile;
                document = xmlReader.read(new URL(xmlFileUrl));
                if (Debug.enabled) Debug.println("Using default services file : " + xmlFileUrl);
            }

            if (document != null) {
                Element root = document.getRootElement();
                if (root != null) {
                    Iterator elements = root.elementIterator("ServiceId");

                    while (elements.hasNext()) {
                        ids.add(((Element) elements.next()).attributeValue("value"));
                    }
                }
            }
        }

        return ids;
    }
%>

<%
    String sFindLastname   = checkString(request.getParameter("FindLastname")),
           sFindFirstname  = checkString(request.getParameter("FindFirstname")),
           sReturnPersonID = checkString(request.getParameter("ReturnPersonID")),
           sReturnUserID   = checkString(request.getParameter("ReturnUserID")),
           sReturnName     = checkString(request.getParameter("ReturnName")),
           sSetGreenField  = checkString(request.getParameter("SetGreenField"));

    // options
    boolean displayImmatNew = !checkString(request.getParameter("displayImmatNew")).equalsIgnoreCase("no");

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("######################## searchByAjax/searchUserShow.jsp #################");
        Debug.println("sFindLastname   : " + sFindLastname);
        Debug.println("sFindFirstname  : " + sFindFirstname);
        Debug.println("sReturnPersonID : " + sReturnPersonID);
        Debug.println("sReturnUserID   : " + sReturnUserID);
        Debug.println("sReturnName     : " + sReturnName);
        Debug.println("sSetGreenField  : " + sSetGreenField);
        Debug.println("displayImmatNew : " + displayImmatNew);
    }
    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////

    String selectedTab = "", sLastname, sFirstname, sServiceID;
    Vector xmlServiceIds = getServiceIdsFromXML(request);

    // clean names
    String sSelectLastname = ScreenHelper.normalizeSpecialCharacters(sFindLastname);
    String sSelectFirstname = ScreenHelper.normalizeSpecialCharacters(sFindFirstname);

    Vector vResults;
    Hashtable hInfo;
    vResults = User.searchUsers(sSelectLastname, sSelectFirstname);
    Iterator iter = vResults.iterator();

    Hashtable usersPerDiv = new Hashtable();

    for (int i = 0; i < xmlServiceIds.size(); i++) {
        usersPerDiv.put(xmlServiceIds.get(i), new Vector());
    }
    usersPerDiv.put("varia", new Vector());
    // run thru found users
    Hashtable user;

    while (iter.hasNext()) {
        hInfo = (Hashtable) iter.next();
        // names
        sLastname = (String) hInfo.get("lastname");
        sFirstname = (String) hInfo.get("firstname");
        if (displayImmatNew) {
            sFirstname += " " + hInfo.get("immatnew");
        }
        sLastname = sLastname.replace('\'', '´');
        sFirstname = sFirstname.replace('\'', '´');

        // service
        sServiceID = checkString((String) hInfo.get("serviceid"));

        // assemble user
        user = new Hashtable();
        user.put("personId", hInfo.get("personid"));
        user.put("userId", hInfo.get("userid"));
        user.put("lastName", sLastname);
        user.put("firstName", sFirstname);
        user.put("serviceId", sServiceID);

        // add user to correct division-vector
        boolean bFound=false;
        for(int n=0;n<xmlServiceIds.size();n++){
        	if(sServiceID.startsWith((String)xmlServiceIds.elementAt(n))){
        		((Vector) (usersPerDiv.get(xmlServiceIds.elementAt(n)))).add(user);
        		bFound=true;
        	}
        }
        if(!bFound) ((Vector) (usersPerDiv.get("varia"))).add(user);
    }

    // default selected tab is the one with the most found records in
    Enumeration e = usersPerDiv.keys();
    Vector users = null;
    int mostUsers = 0;
    String key;

    while (e.hasMoreElements()) {
        key = (String) e.nextElement();
        users = (Vector) usersPerDiv.get(key);

        if (users.size() > mostUsers) {
            mostUsers = users.size();
            selectedTab = "tab_" + key;
        }
    }
%>

<div class="search">
    <%-- TABS ---------------------------------------------------------------%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <%
                // for each service a tab
                String serviceName, serviceNameFull;
                int charsPerTab;

                for (int i = 0; i < xmlServiceIds.size(); i++) {
                    serviceName = getTranNoLink("service", (String) xmlServiceIds.get(i), sWebLanguage);
                    serviceNameFull = serviceName;
                    charsPerTab = ((74 - (xmlServiceIds.size() * 2)) - getTranNoLink("web", "varia", sWebLanguage).length()) / xmlServiceIds.size();
                    if (serviceName.length() > charsPerTab) {
                        serviceName = serviceName.substring(0, charsPerTab).trim() + "..";
                    }

                    if (i > 0) {
            %>
            <td style="border-bottom:1px solid black;" width="5">&nbsp;</td>
            <%
                }

            %>
            <td style="cursor:pointer" class="tabunselected" width="1%" title="<%=HTMLEntities.htmlentities(serviceNameFull)%>"
                onclick="activateTab('tab_<%=xmlServiceIds.get(i)%>')" id="td<%=i%>"
                onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=
                HTMLEntities.htmlentities(serviceName)%>
            </b>&nbsp;</td>
            <%
                }
            %>
            <%-- varia division TR --%>
            <td style="border-bottom:1px solid black;" width="5">&nbsp;</td>
            <td style="cursor:pointer" class="tabunselected" width="1%" onclick="activateTab('tab_varia')" id="td<%=xmlServiceIds.size()%>"
                onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>
                &nbsp;<b><%=HTMLEntities.htmlentities(getTranNoLink("web", "varia", sWebLanguage))%>
            </b>&nbsp;</td>
            <td style="border-bottom:1px solid black;">&nbsp;</td>
        </tr>
    </table>
    <%-- TAB CONTENTS -------------------------------------------------------%>
    <table width="100%" cellspacing="0">
        <%
            int x;

            // for each service a TR
            for (x = 0; x < xmlServiceIds.size(); x++) {
        %>
        <%-- one division --%>
        <tr id="tr_tab<%=x%>" style="display:none">
            <td>
                <table width="100%" cellpadding="0" cellspacing="0" class="sortable"
                       id="searchresults<%=(x==0?"":""+x)%>">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="200"><%=HTMLEntities.htmlentities(getTran("Web", "name", sWebLanguage))%>
                        </td>
                        <td width="300"><%=HTMLEntities.htmlentities(getTran("Web", "service", sWebLanguage))%>
                        </td>
                    </tr>
                    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                        <%=
                            HTMLEntities.htmlentities(getHtml((Vector) (usersPerDiv.get(xmlServiceIds.get(x))), sWebLanguage))%>
                    </tbody>
                </table>

                <%
                    if (((Vector) usersPerDiv.get(xmlServiceIds.get(x))).size() == 0) {
                        // no records found message
                %>
                <div><%=HTMLEntities.htmlentities(getTran("web", "nousersFoundInDivision", sWebLanguage))%>
                </div>
                <%
                } else {
                    // X records found message
                %>
                <div><%=((Vector) usersPerDiv.get(xmlServiceIds.get(x))).size()%> <%=
                    HTMLEntities.htmlentities(getTran("web", "usersFoundInDivision", sWebLanguage))%>
                </div>
                <%
                    }
                %>
            </td>
        </tr>
        <%
            }
        %>
        <%-- varia division TR --%>
        <tr id="tr_tabvaria" style="display:none">
            <td>
                <table width="100%" cellpadding="0" cellspacing="0" class="sortable" id="searchresults<%=x%>">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="200"><%=HTMLEntities.htmlentities(getTran("Web", "name", sWebLanguage))%>
                        </td>
                        <td width="300"><%=HTMLEntities.htmlentities(getTran("Web", "service", sWebLanguage))%>
                        </td>
                    </tr>

                    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                        <%=HTMLEntities.htmlentities(getHtml((Vector) (usersPerDiv.get("varia")), sWebLanguage))%>
                    </tbody>
                </table>

                <%
                    if (((Vector) usersPerDiv.get("varia")).size() == 0) {
                        // no records found message
                %>
                <div><%=HTMLEntities.htmlentities(getTran("web", "nousersFoundInDivision", sWebLanguage))%>
                </div>
                <%
                } else {
                    // X records found message
                %>
                <div><%=((Vector) usersPerDiv.get("varia")).size()%> <%=
                    HTMLEntities.htmlentities(getTran("web", "usersFoundInDivision", sWebLanguage))%>
                </div>
                <%
                    }
                %>
            </td>
        </tr>
    </table>
</div>
<script>
    var showTab = activateTab('<%=selectedTab%>');

</script>