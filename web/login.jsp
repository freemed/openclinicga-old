<%@page import="org.dom4j.io.SAXReader,
                java.net.URL,
                org.dom4j.Document,
                org.dom4j.Element,
                be.mxs.common.util.db.MedwanQuery,
                org.dom4j.DocumentException,
                java.net.MalformedURLException,
                java.sql.PreparedStatement,
                java.sql.Connection,
                java.util.Iterator" %>
<%@page errorPage="/includes/error.jsp" %>
<%@include file="/includes/helper.jsp" %>
<%
    response.setHeader("Content-Type", "text/html; charset=ISO-8859-1");
%>
<html>
<head>
    <link rel="shortcut icon" href="http://localhost/openclinic/favourite.ico"/>
    <META HTTP-EQUIV="Refresh" CONTENT="300">
    <%=sCSSNORMAL%><%=sJSCHAR%><%=sJSPROTOTYPE%><%=sJSCOOKIE%><%=sJSDROPDOWNMENU%><%MedwanQuery.getInstance("http://" + request.getServerName() + request.getRequestURI().replaceAll(request.getServletPath(), "") + "/" + sAPPDIR);

    //*** retreive application version ***
    String version = "version unknown";
    try {
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "application.xml";
        SAXReader reader = new SAXReader(false);
        Document document = reader.read(new URL(sDoc));
        Element element = document.getRootElement().element("version");
        version = "v" + element.attribute("major").getValue() + "." + element.attribute("minor").getValue() + "." + element.attribute("bug").getValue() + " (" + element.attribute("date").getValue() + ")";
        session.setAttribute("ProjectVersion", version);
    }
    catch (Exception e) {
        // nothing
    }

    //*** process 'updatequeries.xml' containing queries that need to be executed at login ***
    Object updateQueriesProcessedDate = application.getAttribute("updateQueriesProcessedDateOC");
    boolean processUpdateQueries = (updateQueriesProcessedDate == null);
    if (processUpdateQueries) {
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "updatequeries.xml";
        if (Debug.enabled) Debug.println("login.jsp : processing update-queries file '" + sDoc + "'.");
        if (MedwanQuery.getInstance().getConfigInt("cacheDB") != 1) {
            // read xml file
            try {
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new URL(sDoc));
                Element queryElem;
                boolean queryIsExecuted;
                String sQuery;
                PreparedStatement ps = null;
                Connection conn = null;
                java.util.Iterator queriesIter = document.getRootElement().elementIterator("Query");
                while (queriesIter.hasNext()) {
                    queryElem = (Element) queriesIter.next();
                    try {
                        queryIsExecuted = MedwanQuery.getInstance().getConfigString(queryElem.attribute("id").getValue()).length() > 0;
                        if (!queryIsExecuted) {
                            // Select the right connection
                            if (queryElem.attribute("db").getValue().equalsIgnoreCase("ocadmin"))
                                conn = MedwanQuery.getInstance().getAdminConnection();
                            else if (queryElem.attribute("db").getValue().equalsIgnoreCase("openclinic"))
                                conn = MedwanQuery.getInstance().getOpenclinicConnection();

                            // execute query
                            if (conn != null) {
                                String sLocalDbType = conn.getMetaData().getDatabaseProductName();
                                if (queryElem.attribute("dbserver") == null || queryElem.attribute("dbserver").getValue().equalsIgnoreCase(sLocalDbType)) {
                                	sQuery = queryElem.getTextTrim().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin"));
	                                sQuery = queryElem.getTextTrim().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin"));
	                                if (sQuery.length() > 0) {
	                                    try {
	                                        ps = conn.prepareStatement(sQuery);
	                                        ps.execute();
	
	                                        // add configString query.id
	                                        MedwanQuery.getInstance().setConfigString(queryElem.attribute("id").getValue(), "executed : first time");
	                                        if (Debug.enabled)
	                                            Debug.println(queryElem.attribute("id").getValue() + " : executed");
	                                    }
	                                    catch (Exception e) {
	                                        if (e.getMessage().indexOf("There is already an object named") > -1) {
	                                            // table allready exists in DB, add configValue query.id
	                                            MedwanQuery.getInstance().setConfigString(queryElem.attribute("id").getValue(), "executed : table allready exists");
	                                            if (Debug.enabled)
	                                                Debug.println(queryElem.attribute("id").getValue() + " : table already exists");
	                                        } else {
	                                            // display query error
	                                            if (Debug.enabled)
	                                                Debug.println(queryElem.attribute("id").getValue() + " : ERROR : " + e.getMessage());
	                                        }
	                                    }
	                                    finally {
	                                        if (ps != null) ps.close();
	                                    }
	                                } else {
	                                    if (Debug.enabled) {
	                                        Debug.println(queryElem.attribute("id").getValue() + " : empty");
	                                    }
	                                }
                                }
                                conn.close();
                            } else {
                                if (Debug.enabled) {
                                    Debug.println("login.jsp : Query-element specifies an invalid database to use : " + queryElem.attribute("db").getValue());
                                }
                            }
                        } else {
                            if (Debug.enabled) {
                                Debug.println(queryElem.attribute("id").getValue() + " : allready executed");
                            }
                        }
                    }
                    catch (NullPointerException e) {
                        if (Debug.enabled)
                            Debug.println("login.jsp : Query-element does not have all required attributes.");
                    }
                }

                // tell application that update queries are processed
                application.setAttribute("updateQueriesProcessedDateOC", new java.util.Date());
            }
            catch (MalformedURLException me) {
                if (Debug.enabled) {
                    if (me.getMessage().indexOf("updatequeries.xml") > -1) {
                        Debug.println("login.jsp : Document '" + sDoc + "' not found.");
                    } else {
                        Debug.println("login.jsp : " + me.getMessage());
                        me.printStackTrace();
                    }
                }
            }
            catch (DocumentException de) {
                if (Debug.enabled) {
                    if (de.getMessage().indexOf("updatequeries.xml") > -1) {
                        Debug.println("login.jsp : Document '" + sDoc + "' not found.");
                    } else {
                        Debug.println("login.jsp : " + de.getMessage());
                        de.printStackTrace();
                    }
                }
            }
        }
    } else {
        // display last date of processing update queries
        if (updateQueriesProcessedDate != null && Debug.enabled) {
            SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
            Debug.println("INFO : UpdateQueries last processed at " + fullDateFormat.format(updateQueriesProcessedDate));
        }
    }

    //*** app-title and app-dir ***
    String sTmpAPPTITLE = checkString(request.getParameter("Title")),
            sTmpAPPDIR = checkString(request.getParameter("Dir"));
    if (sTmpAPPTITLE.length() > 0) {
        session.setAttribute("activeProjectDir", sTmpAPPDIR);
        session.setAttribute("activeProjectTitle", sTmpAPPTITLE);
    } else {
        sTmpAPPTITLE = checkString((String) session.getAttribute("activeProjectTitle"));
        sTmpAPPDIR = checkString((String) session.getAttribute("activeProjectDir"));
    }
    if (sTmpAPPTITLE.equals("")) {%>
    <script>
        var activeProjectDir = GetCookie('activeProjectDir');
        if (activeProjectDir == null) {
            activeProjectDir = "";
        }
            //window.location.href = activeProjectDir;
    </script>
    <%} else {%>
    <script>
        SetCookie('activeProjectDir', "<%=sTmpAPPDIR%>", exp);
        SetCookie('activeProjectTitle', "<%=sTmpAPPTITLE%>", exp);
    </script>
    <%}%>
    <script>
        if (window.history.forward(1) != null) {
            window.history.forward(1);
        }
    </script>
    <title><%=sWEBTITLE + " " + sTmpAPPTITLE%>
    </title>
</head>
<body class="Geenscroll login">
<div id="login">
    <div id="logo">
        <% if ("datacenter".equalsIgnoreCase(request.getParameter("edition"))) {
            session.setAttribute("edition", "datacenter");%>
        <img src="projects/datacenter/_img/logo.jpg" border="0">
        <% } else if ("openlab".equalsIgnoreCase(request.getParameter("edition"))) {
            session.setAttribute("edition", "openlab");%>
        <img src="projects/openlab/_img/logo.jpg" border="0">
        <% } else {
            session.setAttribute("edition", "openclinic");%>
        <img src="<%=sTmpAPPDIR%>_img/logo.jpg" border="0">
        <% }%>
    </div>
    <div id="version">
        <%=version%>&nbsp;
    </div>
    <div id="fields">
        <form name="entranceform" action="checkLogin.do?ts=<%=getTs()%>" method="post" id="entranceform">
            <div id="login_field">
                <input class="text" name="login" size="17" onblur='validateText(this);limitLength(this);'/></div>
            <div id="pwd_field">
                <input class="text" type="password" name="password" size="17" onblur='validateText(this);limitLength(this);'/>
            </div>
            <div id="submit_button"><input class="button" type="submit" name="Login" title="login" value="">
                <div id="finger_button">
                    <a href="javascript:void(0)" title="Logon using fingerprint" onclick="readFingerprint();" >&nbsp;</a>
                </div>
            </div>
            <div id="error_msg">
            <%
                String sMsg = checkString(request.getParameter("message"));
                if (sMsg.length() > 0) {
                    out.write("<div>"+sMsg+"</div>");
                }
            %>
                 </div>
        </form>
    </div>
    <div id="messages">

        <%
            if (MedwanQuery.getInstance().getConfigInt("enableProductionWarning", 0) == 1) {
        	out.print("<center>" + ScreenHelper.getTranDb("web", "productionsystemwarning", "EN") + "<br/></center>");
        	//out.print("<center>" + ScreenHelper.getTranDb("web", "testsystemredirection", "EN") + "</center>");
    	}
        %>
        <br/><center>GA Open Source Edition by:
        <% if (MedwanQuery.getInstance().getConfigString("mxsref", "rw").equalsIgnoreCase("rw")) { %>
        <img src="_img/rwandaflag.jpg" height="15px" width="30px" alt="Rwanda"/>
        <a href="http://mxs.rwandamed.org" target="_new"><b>MXS Central Africa SARL</b></a>
        <BR/> PO Box 3242 - Kigali Rwanda Tel +250 07884 32 435 -
        <a href="mailto:mxs@rwandamed.org">mxs@rwandamed.org</a>
        <% } else { %>
        <img src="_img/belgiumflag.jpg" height="10px" width="20px" alt="Belgium"/>
        <a href="http://www.mxs.be" target="_new"><b>MXS SA/NV</b></a>
        <BR/> Pastoriestraat 50, 3370 Boutersem Belgium Tel: +32 16 721047 -
        <a href="mailto:mxs@rwandamed.org">info@mxs.be</a>
        <% } %>
        </center>
    </div>
</div>
<script type="text/javascript">
    Event.observe(window, 'load', function() {
        changeInputColor();
        $("entranceform").login.focus();
       
    });
    function readFingerprint() {
    <%
    if(checkString(MedwanQuery.getInstance().getConfigString("referringServer")).length()==0){
    %>
        openPopup("_common/readUserFingerPrint.jsp?ts=<%=getTs()%>&referringServer=<%=request.getRequestURL().toString().substring(0,request.getRequestURL().toString().indexOf("/openclinic"))+sCONTEXTPATH%>", 400, 300);
    <%
    }
    else {
    %>
        openPopup("_common/readUserFingerPrint.jsp?ts=<%=getTs()%>&referringServer=<%=MedwanQuery.getInstance().getConfigString("referringServer")+sCONTEXTPATH%>", 400, 300);
    <%
    }
    %>
    }
    function openPopup(page, width, height) {
        var url = page;
        window.open(url, "Popup" + new Date().getTime(), "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=" + width + ", height=" + height + ", menubar=no").moveTo((screen.width - width) / 2, (screen.height - height) / 2);
    }
</script>
</body>
</html>