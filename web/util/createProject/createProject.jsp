<%@page import="org.dom4j.io.SAXReader,
                java.net.URL,
                java.util.*,
                be.mxs.common.util.system.*,
                org.dom4j.*,
                java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="createProjectHelper.jsp"%>
<%
    String sFindProject = checkString(request.getParameter("projectName"));
    String sAction = checkString(request.getParameter("action"));
    Hashtable hProjects = new Hashtable();
    Document document;
    String sFilename;

    // create projects Hashtable
    if(session.getAttribute("ow_projects")==null){
        try{
            SAXReader xmlReader = new SAXReader();
            sFilename = "_common/xml/projects.xml";
            URL url = new URL("http://"+request.getServerName()+":"+request.getServerPort()+request.getRequestURI().replaceAll(request.getServletPath(),"")+"/"+sFilename);

            document = xmlReader.read(url);
            Element root = document.getRootElement();
            if(root != null){
                Iterator elements = root.elementIterator("project");
                Element eProject;
                Project project;

                while(elements.hasNext()){
                    eProject = (Element)elements.next();
                    project = new Project();
                    project.parse(eProject);
                    hProjects.put(project.getProjectName(),project);
                }
            }
        }
        catch(Exception e){
            try{
                File xmlFile = new File(MedwanQuery.getInstance().getConfigString("templateDirectory")+"/projects.xml");
                document = DocumentHelper.createDocument();
                document.addElement("projects");
                FileWriter fileWriter = new FileWriter(xmlFile);
                document.write(fileWriter);
                fileWriter.close();
                session.setAttribute("ow_projects",hProjects);
            }
            catch(Exception exc){
                exc.printStackTrace();
            }
        }

        session.setAttribute("ow_projects",hProjects);
    }
    // load projects Hashtable from session
    else{
        hProjects = (Hashtable)session.getAttribute("ow_projects");
    }

    //--- DELETE ----------------------------------------------------------------------------------
    if(sAction.equals("delete")){
        session.removeAttribute("ow_projects");
        hProjects.remove(checkString(request.getParameter("projectName")));
        session.setAttribute("ow_projects",hProjects);
        Projects.writeXML(MedwanQuery.getInstance().getConfigString("templateDirectory")+"/projects.xml",hProjects);
        sFindProject = "";
    }
%>
<%=writeTableHeader("web.manage.project","projecttitle",sWebLanguage," doBack();")%>
<table width="100%" class="menu" cellspacing="0" cellpadding="0">
    <form name='FindForm' method='POST' action='<c:url value='/main.do'/>?Page=util/createProject/createProject.jsp&ts=<%=getTs()%>'>
        <%-- PROJECT SELECTOR --%>
        <tr class='admin'>
            <td class='admin' width="<%=sTDAdminWidth%>">Project</td>
            <td class="admin2">
                <select name='projectName' class='text' onchange='FindForm.submit();'>
                    <option><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        if (hProjects!= null){
                            Vector v = new Vector(hProjects.keySet());
                            Collections.sort(v);

                            String sName;
                            Iterator iter = v.iterator();
                            while(iter.hasNext()){
                                sName = (String)iter.next();
                                out.print("<option value='"+sName+"'");

                                if(sName.equals(sFindProject)){
                                    out.print(" selected");
                                }

                                out.print(">"+sName+"</option>");
                            }
                        }
                    %>
                </select>
                <%-- BUTTON --%>
                <input type='button' class='button' name='newProjectButton' value='<%=getTranNoLink("web.occup","medwan.common.create-new",sWebLanguage)%>' onclick='doNew();'>
            </td>
        </tr>
    </form>
</table>
<%
    if(sFindProject.length() > 0){
        %>
            <br>
            <table width='100%' cellspacing='1' cellpadding='1'>
                <tr class='admin' height='18'>
                    <td colspan='2'>&nbsp;Project Parameters</td>
                </tr>
                 <%
                    // display parameters
                    if (hProjects!= null){
                        Project chosenProject = (Project)hProjects.get(sFindProject);

                        if (chosenProject!=null){
                            String sSRC     = checkString(chosenProject.getParam(Project.PARAM_SRC).getPath()),
                                   sDEST    = checkString(chosenProject.getParam(Project.PARAM_DEST).getPath()),
                                   sPoolMan = checkString(chosenProject.getParam(Project.PARAM_POOLMAN).getPath()),
                                   sDelete  = checkString(chosenProject.getParam(Project.PARAM_DELETE).getPath());

                            out.print("<tr class='admin' height='18'><td class='admin'>Source</td><td class='admin2' width='90%'>"+sSRC.replaceAll("\\\\","/").trim()+"</td></tr>");
                            out.print("<tr class='admin' height='18'><td class='admin'>Destination</td><td class='admin2'>"+sDEST.replaceAll("\\\\","/").trim()+"</td></tr>");
                            out.print("<tr class='admin' height='18'><td class='admin'>PoolMan</td><td class='admin2'>"+sPoolMan.replaceAll("\\\\","/").trim()+"</td></tr>");

                            Iterator iter = pathDisplayer(sDelete,sSRC,sDEST).iterator();
                            while(iter.hasNext()){
                                out.print("<tr class='admin'><td class='admin'>Delete</td><td class='admin2'>"+iter.next()+"</td></tr>");
                            }
                        }
                    }
                %>
                <%-- BUTTONS --%>
                <tr>
                    <td colspan='2' align='right'>
                        <input type='button' class='button' name='editButton' value='<%=getTranNoLink("web.occup","medwan.common.edit",sWebLanguage)%>' onclick='doEdit();'>
                        <input type='button' class='button' name='createButton' value='<%=getTranNoLink("web.occup","medwan.common.create",sWebLanguage)%>' onclick='doCreate();'>
                    </td>
                </tr>
            </table>
        <%
    }
%>
<script>
  function doNew(){
    window.location.href = "<c:url value='/main.do'/>?Page=util/createProject/createProjectRegistration.jsp&new=yes&ts=<%=getTs()%>";
  }

  function doEdit(){
    window.location.href = "<c:url value='/main.do'/>?Page=util/createProject/createProjectRegistration.jsp&new=no&projectName=<%=sFindProject%>&ts=<%=getTs()%>";
  }

  function doCreate(){
    window.location.href = "<c:url value='/main.do'/>?Page=util/createProject/createProjectProcessor.jsp&projectName=<%=sFindProject%>&ts=<%=getTs()%>";
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp&ts=<%=getTs()%>";
  }
</script>