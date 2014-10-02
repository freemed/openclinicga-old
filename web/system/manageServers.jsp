<%@ page import="be.openclinic.system.Server,java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sAction         = checkString(request.getParameter("Action"));
    String sFindID         = checkString(request.getParameter("FindID"));
    String sEditServerID   = checkString(request.getParameter("EditServerID"));
    String sEditServerName = checkString(request.getParameter("EditServerName"));
    String sEditServerFrom = checkString(request.getParameter("EditServerFrom"));
    String sEditServerTo   = checkString(request.getParameter("EditServerTo"));

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditServerID!=null && sEditServerName.length()>0){
        // check existence
        boolean bServerExists = false;
        bServerExists = Server.exists(sEditServerName);

        // insert
        if (sFindID.equals("-1") && !bServerExists) {
            Server objServer = new Server();
            objServer.setServerId(sEditServerID);
            objServer.setServerName(sEditServerName);
            objServer.setFromServerDirectory(sEditServerFrom);
            objServer.setToServerDirectory(sEditServerTo);

            Server.addServer(objServer);
        }
        // update
        else {
            Server objServer = new Server();
            objServer.setServerId(sEditServerID);
            objServer.setServerName(sEditServerName);
            objServer.setFromServerDirectory(sEditServerFrom);
            objServer.setToServerDirectory(sEditServerTo);
            objServer.setUpdateuserid(Integer.parseInt(activeUser.userid));
            objServer.setUpdatetime(getSQLTime());

            Server.saveServer(objServer,sFindID);
        }

        sFindID = sEditServerID;
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditServerID!=null){
        Server.deleteServer(sFindID);

        sFindID = "-1";
    }
%>
<form name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.manage","ManageServers",sWebLanguage," doBack();")%>
    <%-- SELECT SERVER --------------------------------------------------------------------------%>
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","server",sWebLanguage)%></td>
            <td class="admin2">
                <select name="FindID" class="text" onchange="transactionForm.submit();">
                    <option value="-1"><%=getTran("Web.Occup","medwan.common.create-new",sWebLanguage)%></option>
                    <%
                        // list servers as options
                        String sServerID, sServerName, sSelected, sSelectedServerID = "", sSelectedServerName = "", sSelectedFrom = "", sSelectedTo = "";
                        Vector vSO = Server.selectServersAsOption();

                        Iterator iter = vSO.iterator();

                        Server objServer;

                        while (iter.hasNext()) {
                            objServer = (Server) iter.next();

                            sServerID = checkString(objServer.getServerId());
                            sServerName = checkString(objServer.getServerName());
                            sSelected = "";

                            if (sServerID.equals(sFindID)) {
                                sSelected = " selected";
                                sSelectedServerID = sServerID;
                                sSelectedServerName = sServerName;
                                sSelectedFrom = checkString(objServer.getFromServerDirectory());
                                sSelectedTo = checkString(objServer.getToServerDirectory());
                            }

                    %><option value="<%=sServerID%>"<%=sSelected%>><%=(sServerID+" "+sServerName)%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
    </table>
    <br>
    <%-- SERVER DETAILS -------------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%-- ServerID --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Manage","ServerID",sWebLanguage)%> *</td>
            <td class="admin2">
                <input class="text" type="text" name="EditServerID" value="<%=sSelectedServerID%>" size="50">
            </td>
        </tr>
        <%-- ServerName --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage","ServerName",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="text" class="text" name="EditServerName" value="<%=sSelectedServerName%>" size="50">
            </td>
        </tr>
        <%-- FromServerDirectory --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage","FromServerDirectory",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="EditServerFrom" value="<%=sSelectedFrom%>" size="50">
            </td>
        </tr>
        <%-- ToServerDirectory --%>
        <tr>
            <td class="admin"><%=getTran("Web.Manage","ToServerDirectory",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="EditServerTo" value="<%=sSelectedTo%>" size="50">
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%
                    // new server
                    // display saveButton with add-label + do not display delete button
                    if(sFindID.equals("-1") || sFindID.length()==0){
                        %>
                        <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="doSave();">
                        <%
                    }
                    else{
                        // existing server
                        // display saveButton with save-label
                        %>
                        <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();">
                        <input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete();">
                        <%
                    }
                %>
                <input class="button" type="button" name="backbutton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <%-- indication of obligated fields --%>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
    <script>
      transactionForm.EditServerID.focus();

      <%-- DO SAVE --%>
      function doSave(){
        if(!transactionForm.EditServerName.value.length==0 && !transactionForm.EditServerID.value.length==0){
          transactionForm.saveButton.disabled = true;
          transactionForm.Action.value = "save";
          transactionForm.submit();
        }
        else{
          alertDialog("web.manage","datamissing");

          if(transactionForm.EditServerID.value.length==0){
             transactionForm.EditServerID.focus();
          }
          else{
             transactionForm.EditServerName.focus();
          }
        }
      }

      <%-- DO DELETE --%>
      function doDelete() {
    	if(yesnoDialog("Web","areYouSureToDelete")){
          transactionForm.saveButton.disabled = true;
          transactionForm.deleteButton.disabled = true;
          transactionForm.Action.value = "delete";
          transactionForm.submit();
        }
      }

      <%-- DO BACK --%>
      function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
      }
    </script>
</form>