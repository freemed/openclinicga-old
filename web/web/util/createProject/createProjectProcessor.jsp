<%@page import="java.util.*,
                be.mxs.common.util.system.*,
                java.io.*,
                java.text.SimpleDateFormat,java.util.Date" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="createProjectHelper.jsp"%>
<%!
    //--- COPY DIRECTORY --------------------------------------------------------------------------
    public static void copyDirectory(File srcDir, File dstDir) throws IOException {
        if (srcDir.isDirectory()) {
            if (!dstDir.exists()) {
                dstDir.mkdir();
            }

            String[] children = srcDir.list();
            for (int i=0; i<children.length; i++) {
                copyDirectory(new File(srcDir,children[i]),new File(dstDir,children[i]));
            }
        }
        else {
            copyFile(srcDir, dstDir);
        }
    }

    //--- COPY FILE -------------------------------------------------------------------------------
    public static void copyFile(File src, File dst) throws IOException {
        InputStream in = new FileInputStream(src);
        OutputStream out = new FileOutputStream(dst);

        byte[] buf = new byte[1024];
        int len;
        while ((len = in.read(buf)) > 0) {
            out.write(buf, 0, len);
        }

        in.close();
        out.close();
    }

    //--- DELETE DIR ------------------------------------------------------------------------------
    public static boolean deleteDir(File dir) throws IOException {
        if (dir.isDirectory()) {
            String[] children = dir.list();
            for (int i=0; i<children.length; i++) {
                boolean success = deleteDir(new File(dir, children[i]));
                if (!success) {
                    return false;
                }
            }
        }

        // The directory is now empty so delete it
        return dir.delete();
    }

    //--- DELETE FILE -----------------------------------------------------------------------------
    public static void deleteFile(File file){
        if(file.isFile()) file.delete();
    }

    //--- DELETE FILES NAME LIKE ------------------------------------------------------------------
    public static void deleteFilesNameLike(String substringName,File dir){
        File tmp;
        if(dir.isDirectory()){
            String[] children = dir.list();
            for(int i=0; i<children.length; i++){
                tmp = new File(dir, children[i]);
                if ((tmp.getName().toLowerCase().indexOf(substringName.toLowerCase())>-1)){
                    deleteFile(tmp);
                }
            }
        }
    }
%>
<%
    Date startTime = new Date(Calendar.getInstance().getTimeInMillis());
    String sProjectname = checkString(request.getParameter("projectName"));
    Hashtable hProjects = (Hashtable) session.getAttribute("ow_projects");

    String sDestDir;
    String sSrcDir;
    String sDeleteDirs;
    Vector vDeleteDirs;
    String sPoolMan;
    Project createProject;
    boolean create = true;
    StringBuffer output = new StringBuffer();

    if ((Project) hProjects.get(sProjectname) != null) {
        createProject = (Project) hProjects.get(sProjectname);
        sDestDir = checkString(createProject.getParam(Project.PARAM_DEST).getPath());
        sSrcDir = checkString(createProject.getParam(Project.PARAM_SRC).getPath());
        sDeleteDirs = checkString(createProject.getParam(Project.PARAM_DELETE).getPath());
        vDeleteDirs = pathDisplayer(sDeleteDirs, sSrcDir, sDestDir);
        sPoolMan = checkString(createProject.getParam(Project.PARAM_POOLMAN).getPath());

        try {
            File fSrcDir = null;
            File fDestDir = null;
            File fPoolMan = null;

            boolean bSrc = false;
            boolean bDest = false;
            boolean bPool = false;

            if (sSrcDir.length() > 0) {
                fSrcDir = new File(sSrcDir);
                if (!fSrcDir.isDirectory())
                    output.append("Source Directory is not valid.<br>");
                else
                    bSrc = true;
            } else {
                output.append("Source Directory is not given.<br>");
            }

            if (sDestDir.length() > 0) {
                fDestDir = new File(sDestDir);
                bDest = true;
            } else {
                output.append("Destination Directory is not given.<br>");
            }

            if (sPoolMan.length() > 0) {
                fPoolMan = new File(sPoolMan);
                if (!fPoolMan.isFile())
                    output.append("Poolman is not valid.<br>");
                else
                    bPool = true;
            } else {
                output.append("Poolman is not given.<br>");
            }

            if (bSrc && bDest && bPool) {
                copyDirectory(fSrcDir, fDestDir);
                Iterator iter = vDeleteDirs.iterator();
                File delete;
                String sTest;

                while (iter.hasNext()) {
                    sTest = (String) iter.next();
                    if (!(sTest == null)) {
                        delete = new File(sTest);
                        if (delete.exists())
                            deleteDir(delete);
                        else {
                            output.append(delete + " is not a valid dir or file to delete<br>");
                            if (create)
                                create = false;
                        }
                    } else {
                        output.append(sTest + " is not a valid dir or file to delete<br>");
                        if (create)
                            create = false;
                    }
                }

                File fNewPoolMan;
                String sNewPoolMan;
                sNewPoolMan = sDestDir + "\\" + sPoolMan.substring((sPoolMan.indexOf(sSrcDir) + sSrcDir.length()), sPoolMan.length());
                sNewPoolMan = sNewPoolMan.replaceAll("\\\\", "/").trim();
                sNewPoolMan = sNewPoolMan.replaceAll("//", "/");
                fNewPoolMan = new File(sNewPoolMan);
                String sPath = fNewPoolMan.getParent();

                deleteFilesNameLike("poolman", new File(sPath));
                copyFile(fPoolMan, fNewPoolMan);
                fNewPoolMan.renameTo(new File(sPath + "/poolman.xml"));
            } else {
                create = false;
            }
        }
        catch (FileNotFoundException fexc) {
            // Opvangen Destination Directory Fout
            output.append(sDestDir + " is not a valid destination dir.<br>");
            create = false;
        }
        catch (Exception e) {
            create = false;
            e.printStackTrace();
        }

        /*
        try{
            File fSrcDir = new File(sSrcDir);
            File fDestDir = new File(sDestDir);

            if(fSrcDir.isDirectory()){

                copyDirectory(fSrcDir,fDestDir);

                Iterator iter = vDeleteDirs.iterator();
                File delete;
                String sTest;

                while(iter.hasNext()){
                    sTest = (String)iter.next();
                    if(!(sTest == null)){
                        delete = new File(sTest);
                        if(delete.exists())
                            deleteDir(delete);
                        else{
                            output += delete + " is not a valid dir or file<br>";
                            if(create)
                                create = false;
                        }
                    }
                    else{
                        output += sTest + " is not a valid dir or file<br>";
                        if(create)
                            create = false;
                    }
                }
            }
            else{
                output += "Source is not valid<br>";
                create = false;
            }
        }
        catch(Exception e){
            create = false;
            e.printStackTrace();
        }

        if(sPoolMan.length()>0){
            File fPoolMan = new File(sPoolMan);
            File fNewPoolMan;
            String sNewPoolMan;
            if(fPoolMan.isFile()){
                sNewPoolMan = sDestDir + "\\" + sPoolMan.substring((sPoolMan.indexOf(sSrcDir) + sSrcDir.length()),sPoolMan.length());
                sNewPoolMan = sNewPoolMan.replaceAll("\\\\","/").trim();
                sNewPoolMan = sNewPoolMan.replaceAll("//","/");
                fNewPoolMan = new File(sNewPoolMan);
                String sPath = fNewPoolMan.getParent();

                deleteFilesNameLike("poolman",new File(sPath));
                copyFile(fPoolMan,fNewPoolMan);
                fNewPoolMan.renameTo(new File(sPath + "/poolman.xml"));
            }
            else{
                if(create){
                    create = false;
                    output += "Source Poolman is not a valid file.<br>";
                }
            }
        }
        else{
            if(create){
                create = false;
                output += "Source Poolman is not given.<br>";
            }
        }
        */
    } else {
        output.append("Error occured before processing<br>");
    }

    Date endTime = new Date(Calendar.getInstance().getTimeInMillis());
%>
<%=writeTableHeader("web.manage.project","processoverview",sWebLanguage,"doBack();")%>
<table border='0' width='100%' cellspacing='1' cellpadding='1'>
    <%-- STATUS --%>
    <tr class='admin'>
        <td class='admin' height='18' width='<%=sTDAdminWidth%>'>Status</td>
        <td class='admin2'>
            <%
                if(create) out.print("Project creation was succesfull");
                else       out.print("<font color='red'>Project creation was unsuccesfull</font>");
            %>
        </td>
    </tr>
    <%-- ERRORS --%>
    <tr>
        <td class='admin' height='18'>Errors</td>
        <td class='admin2'><%=output%></td>
    </tr>
    <%-- PROCESSING TIME --%>
    <tr>
        <td class='admin' height='18'>Processing Time</td>
        <td class='admin2'>
            <%
                out.print(new SimpleDateFormat("mm:ss").format(new Date(endTime.getTime()-startTime.getTime())));
            %>
        </td>
    </tr>
    <%-- BUTTONS --%>
    <tr>
        <td colspan="2" align="right">
            <input type="button" class="button" name="backButton" onClick="doBack();" value="<%=getTran("web","back",sWebLanguage)%>">
        </td>
    </tr>
</table>
<script>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=util/createProject/createProject.jsp&projectName=<%=sProjectname%>&ts=<%=getTs()%>";
  }
</script>