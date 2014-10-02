<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String action = checkString(request.getParameter("action")).trim();
    String activityCode = checkString(request.getParameter("activityCode"));
    String labelTran = getTran("web.translations","label",sWebLanguage);
    String labelnl = "", labelfr = "", labelen = "";

    //--- NO ACTION -------------------------------------------------------------------------------
   	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    if(action.equals("")){
        // get current values for specified label
        PreparedStatement ps = ad_conn.prepareStatement("SELECT labelnl,labelfr,labelen FROM Labels WHERE labeltype = 'activitycodes' AND labelid = ?");
        ResultSet rs;
        ps.setString(1,activityCode);
        rs = ps.executeQuery();

        if(rs.next()){
            labelnl = checkString(rs.getString(1));
            labelfr = checkString(rs.getString(2));
            labelen = checkString(rs.getString(3));
        }

        rs.close();
        ps.close();
    }
    //--- EDIT ACTIVITY ---------------------------------------------------------------------------
    else if(action.equals("editActivity")){
        labelnl = checkString(request.getParameter("labelnl"));
        labelfr = checkString(request.getParameter("labelfr"));
        labelen = checkString(request.getParameter("labelen"));

        // edit activity (in labels)
        String sQuery = "UPDATE Labels SET labelnl=?, labelfr=?, labelen=?"+
                        " WHERE labeltype = 'activitycodes' AND labelid = ?";
        PreparedStatement ps = ad_conn.prepareStatement(sQuery);
        ps.setString(1,labelnl);
        ps.setString(2,labelfr);
        ps.setString(3,labelen);
        ps.setString(4,activityCode);
        ps.executeUpdate();
        ps.close();

        // message to user
        %>
          <script>
            window.opener.location.reload();
            alertDialog("web.manage","activityupdated");
            window.close();
          </script>
        <%
    }
    ad_conn.close();
%>

<head>
    <title><%=sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
</head>

<body>
<form name="editForm" method="POST">
    <input type="hidden" name="action" value=""/>

    <table width='100%' border='0' cellspacing='1' cellpadding='0'>
        <%-- PAGE TITLE --%>
        <tr class="admin">
            <td colspan="2"><%=getTran("web.manage","editActivity",sWebLanguage)%></td>
        </tr>

        <%-- INPUTFIELDS --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%></td>
            <td class="admin2"><input class="text" type="text" name="activityCode" value="<%=activityCode%>" size="10" READONLY/></td>
        </tr>

        <tr>
            <td class="admin"><%=labelTran%> NL</td>
            <td class="admin2"><input class="text" type="text" name="labelnl" value="<%=labelnl%>" size="50"></td>
        </tr>

        <tr>
            <td class="admin"><%=labelTran%> FR</td>
            <td class="admin2"><input class="text" type="text" name="labelfr" value="<%=labelfr%>" size="50"></td>
        </tr>

        <tr>
            <td class="admin"><%=labelTran%> EN</td>
            <td class="admin2"><input class="text" type="text" name="labelen" value="<%=labelen%>" size="50"></td>
        </tr>
    </table>

    <script>
      function editActivity(){
        if(editForm.activityCode.value.length==0 || editForm.labelnl.value.length==0 ||
           editForm.labelfr.value.length==0 || editForm.labelen.value.length==0){
          alertDialog("web","somefieldsareempty");

               if(editForm.activityCode.value == ''){ editForm.activityCode.focus(); }
          else if(editForm.labelnl.value == ''){ editForm.labelnl.focus(); }
          else if(editForm.labelfr.value == ''){ editForm.labelfr.focus(); }
          else if(editForm.labelen.value == ''){ editForm.labelen.focus(); }
        }
        else{
          editForm.action.value = 'editActivity';
          editForm.submit();
        }
      }

      function clearForm(){
        editForm.activityCode.value = '';
        editForm.labelnl.value = '';
        editForm.labelfr.value = '';
        editForm.labelen.value = '';
        editForm.activityCode.focus();
      }

      window.resizeTo(500,210);
      editForm.activityCode.focus();
    </script>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="button" name="EditButton"  value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="editActivity();">&nbsp;
        <input class="button" type="button" name="ClearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearForm();">&nbsp;
        <input class="button" type="button" name="buttonclose" value='<%=getTranNoLink("Web","close",sWebLanguage)%>' onclick='window.close();'>
    <%=ScreenHelper.alignButtonsStop()%>
</form>
</body>