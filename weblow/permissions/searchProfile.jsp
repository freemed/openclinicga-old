<%@page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("permissions.usersPerProfile","select",activeUser)%>

<%
    String sFindProfileID   = checkString(request.getParameter("FindProfileID"));
    String sFindApplication = checkString(request.getParameter("FindApplication"));
    String sOrderField      = checkString(request.getParameter("OrderField"));

    String sTmpProfileID, sTmpProfileName, sProfiles = "", sProfileName = "";

    Vector vUserProfiles = UserProfile.getUserProfiles();
    Iterator iter = vUserProfiles.iterator();

    UserProfile userProfile;
    while(iter.hasNext()){
        userProfile = (UserProfile)iter.next();
        sTmpProfileID = Integer.toString(userProfile.getUserprofileid());
        sTmpProfileName = userProfile.getUserprofilename();

        sProfiles += "<option value='"+sTmpProfileID+"'";
        if (sFindProfileID.equals(sTmpProfileID)) {
            sProfiles += " selected";
            sProfileName = sTmpProfileName;
        }

        sProfiles += ">"+sTmpProfileName+"</option>";
    }
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="OrderField" value="">

    <%-- PAGE TITLE --%>
    <%=writeTableHeader("Web.UserProfile","usersPerProfile",sWebLanguage," doBack();")%>

    <table width="100%" class="menu">
        <%-- PROFILE --%>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web.UserProfile","UserProfile",sWebLanguage)%></td>
            <td>
                <select name="FindProfileID" class="text" onchange="transactionForm.FindApplication.selectedIndex = -1;transactionForm.submit();"><option/>
                    <%=sProfiles%>
                </select>
            </td>
        </tr>

        <%-- APPLICATION --%>
        <tr>
            <td><%=getTran("Web","Applications",sWebLanguage)%></td>
            <td>
                <select name="FindApplication" class="text" onChange="transactionForm.FindProfileID.selectedIndex = -1;transactionForm.submit();">
                    <option/>
                    <%
                        Hashtable hScreens = new Hashtable();
                        hScreens.put("administration", getTran("Web", "Administration", sWebLanguage));
                        hScreens.put("agenda", getTran("Web", "agenda", sWebLanguage));
                        hScreens.put("medicalrecord", getTran("Web", "medicalrecord", sWebLanguage));

                        String sScreen, sKey;
                        Enumeration e = hScreens.keys();
                        Hashtable hSorted = new Hashtable();
                        SortedSet set = new TreeSet();

                        // sort
                        while (e.hasMoreElements()) {
                            sKey = (String) e.nextElement();
                            sScreen = (String) hScreens.get(sKey);
                            set.add(sScreen);
                            hSorted.put(sScreen, sKey);
                        }

                        Iterator it = set.iterator();
                        while (it.hasNext()) {
                            sScreen = (String) it.next();
                            sKey = (String) hSorted.get(sScreen);

                    %><option value="<%=sKey%>"<%

                            if (sFindApplication.equals(sKey)) {
                                sProfileName = sScreen;
                                %> selected<%
                            }

                            %>><%=sScreen%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
    </table>
</form>

<%
    if (sFindProfileID.length()>0 || sFindApplication.length()>0) {
        %>
            <%-- PRINT BUTTON top --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" value="<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>" class="button" onclick="doPrint();">
            <%=ScreenHelper.alignButtonsStop()%>

            <span id="printtable">
                <span class="menu"><b><%=sProfileName%></b></span>

                <table width="100%" class="list" cellspacing="O">

                    <%-- HEADER : clickable --%>
                    <tr class="admin">
                        <td width="<%=sTDAdminWidth%>">
                            <span onMouseOver="this.style.cursor='hand'" onmouseout="this.style.cursor='default'" onClick="transactionForm.OrderField.value='searchname';transactionForm.submit();">
                                <u><%=getTran("Web","Name",sWebLanguage)%></u>
                            </span>
                        </td>

                        <td width="*">
                            <span onMouseOver="this.style.cursor='hand'" onmouseout="this.style.cursor='default'" onClick="transactionForm.OrderField.value='userid';transactionForm.submit();">
                               <u><%=getTran("Web.occup","medwan.authentication.login",sWebLanguage)%></u>
                            </span>
                        </td>
                    </tr>

                    <%
                        String sPersonID, sLastname, sFirstname, sLogin, sClass = "", sOldPersonID = "";
                        boolean bOK = false;
                        Vector vProfileOwners = new Vector();
                        if (sFindProfileID.length()>0) {
                            vProfileOwners = UserProfile.getProfileOwnersByProfileId(sFindProfileID,sOrderField);
                            bOK = true;
                        }
                        else if (sFindApplication.length()>0) {
                            vProfileOwners = UserProfile.getProfileOwnersByApplication(sFindApplication,sOrderField);
                            bOK = true;
                        }

                        if (bOK){
                            %><tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'><%
                            Iterator iterator = vProfileOwners.iterator();
                            Hashtable hOwnerProfile;
                            while(iterator.hasNext()){
                                hOwnerProfile = (Hashtable)iterator.next();
                                sPersonID  = (String)hOwnerProfile.get("personid");
                                sLastname  = (String)hOwnerProfile.get("lastname");
                                sFirstname = (String)hOwnerProfile.get("firstname");
                                sLogin     = (String)hOwnerProfile.get("userid");

                                if (!sPersonID.equals(sOldPersonID)) {
                                    sOldPersonID = sPersonID;
                                    sLastname+= " "+sFirstname;

                                    // alternate row styles
                                    if (sClass.equals("")) sClass = "1";
                                    else                   sClass = "";

                                    %>
                                        <tr class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';" onClick="window.location.href = '<%=sCONTEXTPATH%>/main.do?Page=/permissions/userpermission.jsp&PersonID=<%=sPersonID%>&ts=<%=getTs()%>';">
                                            <td><%=sLastname%></td>
                                            <td><%=sLogin%></td>
                                        </tr>
                                    <%
                                }
                            }
                            %></tbody><%
                        }
                    %>
                </table>
            </span>

            <%-- BUTTONS at bottom --%>
            <%=ScreenHelper.alignButtonsStart()%>
                <input type="button" class="button" name="printButtonBottom" value="<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>" onclick="doPrint();">
                <input type="button" class="button" name="backButton" Value='<%=getTran("Web","Back",sWebLanguage)%>' OnClick="doBack();">&nbsp;
            <%=ScreenHelper.alignButtonsStop()%>
        <%
    }
%>

<script>
  <%-- DO PRINT --%>
  function doPrint(){
    openPopup("/_common/print/print.jsp&Field=printtable&ts=<%=getTs()%>");
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=permissions/index.jsp";
  }
</script>

