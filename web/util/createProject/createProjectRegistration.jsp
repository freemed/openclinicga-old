<%@page import="java.util.Hashtable,
                java.util.Vector,
                be.mxs.common.util.system.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    Hashtable hProjects = (Hashtable)session.getAttribute("ow_projects");

    String sNew = checkString(request.getParameter("new"));
    String projectName = checkString(request.getParameter("projectName"));
    String oldProjectName = checkString(request.getParameter("oldprojectname"));
    String projectSrcDir = checkString(request.getParameter("projectsrcdir"));
    String oldProjectSrcDir = checkString(request.getParameter("oldprojectsrcdir"));
    String projectDestDir = checkString(request.getParameter("projectdestdir"));
    String oldProjectDestDir = checkString(request.getParameter("oldprojectdestdir"));
    String deletePaths = checkString(request.getParameter("deletepaths"));
    String oldPoolMan = checkString(request.getParameter("oldpoolman"));
    String poolMan = checkString(request.getParameter("poolman"));

    Project editProject = new Project();
    String sOutput = "";

    //Debug.println("############################################## + BEGIN + projectname = " + projectName + " new: " + sNew);
    if(sNew.equals("yes") && projectName.length()>0){
        //Debug.println("################################## " + (Project)hProjects.get(projectName));
        if(hProjects.get(projectName)==null){
            // bestaat nog niet
            //Debug.println("############################################## + 1" );
            Vector vParams = new Vector();
            editProject.setProjectName(projectName);
            vParams.addElement(new ProjectParam(Project.PARAM_DEST,projectDestDir));
            vParams.addElement(new ProjectParam(Project.PARAM_SRC,projectSrcDir));
            vParams.addElement(new ProjectParam(Project.PARAM_DELETE,deletePaths));
            vParams.addElement(new ProjectParam(Project.PARAM_POOLMAN,poolMan));
            editProject.setParams(vParams);
            hProjects.put(projectName, editProject);
            session.removeAttribute("ow_projects");
            session.setAttribute("ow_projects",hProjects);

            //Debug.println("########## Before write");
            Projects.writeXML(MedwanQuery.getInstance().getConfigString("templateDirectory")+"/projects.xml",hProjects);
            //Debug.println("########## After write");

            sNew = "no";

            oldProjectName = projectName;
            if(projectSrcDir.length()<=0)
                projectSrcDir = oldProjectSrcDir;
            if(projectDestDir.length()<=0)
                projectDestDir = oldProjectDestDir;
            if(poolMan.length()<=0)
                poolMan = oldPoolMan;

            oldProjectSrcDir = projectSrcDir;
            oldProjectDestDir = projectDestDir;
            oldPoolMan = poolMan;
        }
        else{
            // bestaat al (niet toegelaten)
            sOutput ="<font color='red'> Error: Projectname allready exists, project not saved</font>";
            //Debug.println("############################################## + 2" );
            if(projectSrcDir.length()<=0)
                projectSrcDir = oldProjectSrcDir;
            if(projectDestDir.length()<=0)
                projectDestDir = oldProjectDestDir;
            if(poolMan.length()<=0)
                poolMan = oldPoolMan;
            oldProjectSrcDir = projectSrcDir;
            oldProjectDestDir = projectDestDir;
            oldPoolMan = poolMan;
            projectName = oldProjectName;
         }
    }
    else if(sNew.equals("no") && projectName.length()>0){
        if(hProjects.get(projectName)==null){
            // bestaat nog niet (hernoemen en editering bestaand)
            //Debug.println("############################################## + 3" );
            editProject =(Project)hProjects.get(oldProjectName);
            editProject.setProjectName(projectName);

            if(projectSrcDir.length()>0){
                editProject.getParam(Project.PARAM_SRC).setPath(projectSrcDir);
                oldProjectSrcDir = projectSrcDir;
            }

            if(projectDestDir.length()>0){
                editProject.getParam(Project.PARAM_DEST).setPath(projectDestDir);
                oldProjectDestDir = projectDestDir;
            }

            if(poolMan.length()>0){
                editProject.getParam(Project.PARAM_POOLMAN).setPath(poolMan);
                oldPoolMan = poolMan;
            }

            if(deletePaths.length()>0){
                editProject.getParam(Project.PARAM_DELETE).setPath(deletePaths);
            }

            hProjects.remove(oldProjectName);
            hProjects.put(projectName,editProject);

            session.removeAttribute("ow_projects");
            session.setAttribute("ow_projects",hProjects);
            Projects.writeXML(MedwanQuery.getInstance().getConfigString("templateDirectory")+"/projects.xml",hProjects);
            sNew = "no";

            oldProjectName = projectName;
            projectDestDir = oldProjectDestDir;
            projectSrcDir = oldProjectSrcDir;
            poolMan = oldPoolMan;
        }
        else{
            // bestaat al
            if(oldProjectName.equals(projectName)){
                // editering bestaand project
                //Debug.println("############################################## + 4" );
                editProject =(Project)hProjects.get(projectName);
                if(projectSrcDir.length()>0){
                    editProject.getParam(Project.PARAM_SRC).setPath(projectSrcDir);
                    oldProjectSrcDir = projectSrcDir;
                }

                if(projectDestDir.length()>0){
                    editProject.getParam(Project.PARAM_DEST).setPath(projectDestDir);
                    oldProjectDestDir = projectDestDir;
                }

                if(poolMan.length()>0){
                    editProject.getParam(Project.PARAM_POOLMAN).setPath(poolMan);
                    oldPoolMan = poolMan;
                }
                editProject.getParam(Project.PARAM_DELETE).setPath(deletePaths);

                hProjects.remove(projectName);
                hProjects.put(projectName,editProject);

                session.removeAttribute("ow_projects");
                session.setAttribute("ow_projects",hProjects);
                Projects.writeXML(MedwanQuery.getInstance().getConfigString("templateDirectory")+"/projects.xml",hProjects);
                sNew = "no";

                projectDestDir = oldProjectDestDir;
                projectSrcDir = oldProjectSrcDir;
                poolMan = oldPoolMan;
            }
            else if(oldProjectName.equals("")){
                //Debug.println("############################################## + 5" );
                editProject = (Project)hProjects.get(projectName);
                projectSrcDir = editProject.getParam(Project.PARAM_SRC).getPath();
                oldProjectSrcDir = projectSrcDir;
                projectDestDir = editProject.getParam(Project.PARAM_DEST).getPath();
                oldProjectDestDir = projectDestDir;
                deletePaths = editProject.getParam(Project.PARAM_DELETE).getPath() + "\n";
                projectName = editProject.getProjectName();
                oldProjectName = projectName;
                poolMan = editProject.getParam(Project.PARAM_POOLMAN).getPath();
                oldPoolMan = poolMan;
            }
            else{
                // editering van een ander project (niet toegelaten)
                //Debug.println("############################################## + 6" );
                sOutput = "  ==> Error: Cant rename project, name allready exists. Project not saved";
                oldProjectSrcDir = projectSrcDir;
                oldProjectDestDir = projectDestDir;
                oldPoolMan = poolMan;
                projectName = oldProjectName;
            }
        }
    }
%>
<%=writeTableHeader("web.manage.project","projectinformation",sWebLanguage,"doBack();")%>
<table cellspacing='1' cellpadding='1' width='100%'>
    <form name='EditForm' method='POST' action='<c:url value='/main.do'/>?Page=util/createProject/createProjectRegistration.jsp&new=<%=sNew%>&ts=<%=getTs()%>'>
        <input type='hidden' name='oldprojectname' value='<%=oldProjectName%>'>

        <tr height='22'>
            <td class='admin'>Project</td>
            <td class='admin2' colspan='2'><%=projectName%> <%=sOutput%></td>
        </tr>
        <tr height='22'>
             <td class='admin'>New Project Name *</td>
             <td colspan='2' class='admin2'>
                <input type='text' class='text' name='projectName' value='<%=projectName%>' size='80'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>Source Directory</td>
             <td colspan='2' class='admin2'>
                <%=oldProjectSrcDir%><input type='hidden' name='oldprojectsrcdir' value='<%=oldProjectSrcDir%>'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>New Source Directory</td>
             <td colspan='2' class='admin2'>
                <input type='file' class='text' name='projectsrcdir' value='<%=projectSrcDir%>' size='80'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>Destination Directory</td>
             <td colspan='2' class='admin2'>
                <%=oldProjectDestDir%><input type='hidden' name='oldprojectdestdir' value='<%=oldProjectDestDir%>'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>New Destination Directory</td>
             <td colspan='2' class='admin2'>
                <input type='file' class='text' name='projectdestdir' value='<%=projectDestDir%>' size='80'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>Poolman</td>
             <td colspan='2' class='admin2'>
                <%=oldPoolMan%><input type='hidden' name='oldpoolman' value='<%=oldPoolMan%>'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>New Poolman</td>
             <td colspan='2' class='admin2'>
                <input type='file' class='text' name='poolman' value='<%=poolMan%>' size='80'>
             </td>
        </tr>
        <tr height='22'>
             <td class='admin'>New Dir or File to Delete</td>
             <td colspan='2' class='admin2'>
                <input type='file' class='text' name='filename' size='80'>
                <input type='button' class='button' name='addbutton' value='<%=getTranNoLink("web","add",sWebLanguage)%>' onclick="addToTextarea(document.EditForm.deletepaths.value,EditForm.filename.value)">
             </td>
        </tr>
        <tr height='22'>
            <td class='admin'>Dir or File Delete</td>
             <td colspan='2' class='admin2'>
             <TEXTAREA name='deletepaths' class ='text' cols='93' rows='15'><%=deletePaths%></TEXTAREA>
             </td>
        </tr>
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type='button' class='button' name='savebutton' value='<%=getTranNoLink("web","save",sWebLanguage)%>' onclick='doSave();'>
            <%
                if(sNew.equals("no")){
                    %>
                        <input type='button' class='button' name='deletebutton' value='<%=getTranNoLink("web","delete",sWebLanguage)%>' onclick='doDelete();'>
                    <%
                }
            %>
            <input type="button" class="button" name="backButton" onClick="doBack();" value="<%=getTranNoLink("web","back",sWebLanguage)%>">
        <%=ScreenHelper.setFormButtonsStop()%>
    </form>
</table>
<%=getTran("web","colored_fields_are_obligate",sWebLanguage)%>
<script>
  EditForm.projectName.focus();

  function doSave(){
    if(EditForm.projectName.value.length==0){
      alertDialog("web.manage.project","alertEmptyName");
    }
    else{
      EditForm.savebutton.disabled = true;
      EditForm.backButton.disabled = true;
      EditForm.submit()
    }
  }

  function addToTextarea(textarea,filename){
    if(filename == ""){
      alertDialog("web.manage.project","alertAddMessage");
    }
    else{
      textarea = textarea + filename + "\r";
      document.EditForm.deletepaths.value=textarea;
    }
  }

  function doDelete(){
    if(yesnoDeleteDialog()){
      window.location="<c:url value='/main.do'/>?Page=util/createProject/createProject.jsp&action=delete&projectName=<%=projectName%>&ts=<%=getTs()%>";
    }
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=util/createProject/createProject.jsp&projectName=<%=projectName%>&ts=<%=getTs()%>";
  }
</script>