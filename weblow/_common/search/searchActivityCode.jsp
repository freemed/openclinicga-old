<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    PreparedStatement ps;
    ResultSet rs;

    String sFindCode = checkString(request.getParameter("FindCode"));
    String sFindText = checkString(request.getParameter("FindText"));

    String label = "labelnl";
    if(sWebLanguage.equalsIgnoreCase("F")){
        label = "labelfr";
    }
%>
<form name="searchForm" method="POST" onSubmit="doFind();">
  <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
    <%-- SEARCH INPUTS --%>
    <tr>
      <td width='100%' height='25'>
        &nbsp;<%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindCode" value="<%=sFindCode%>" size="16">
        &nbsp;<%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindText" value="<%=sFindText%>" size="32">
        &nbsp;<input class="button" type="submit" name="FindButton"  value="<%=getTran("Web","find",sWebLanguage)%>">
        &nbsp;<input class="button" type="button" name="ClearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onClick="clearForm();">
        &nbsp;<input class="button" type="button" name="NewButton"   value="<%=getTran("Web","new",sWebLanguage)%>" onClick="newActivity();">
      </td>
    </tr>

    <script>
      function newActivity(){
        openPopup("/healthrecord/createActivity.jsp&ts=<%=getTs()%>");
      }

      function clearForm(){
        searchForm.FindCode.value = '';
        searchForm.FindText.value = '';
        searchForm.FindCode.focus();
      }

      function doFind(){
        ToggleFloatingLayer('FloatingLayer',1);
        searchForm.FindButton.disabled = true;
        searchForm.submit();
      }
    </script>

    <%-- SEARCH RESULTS --%>
    <tr>
      <td class="white" valign="top">
        <div class="search" style="width:570">
          <table width="100%" cellspacing="0" cellpadding="0">
            <%
                int iIndex = 1;
                String sSelect = "SELECT * FROM Labels WHERE labeltype = 'activitycodes'";
                if(sFindCode.length() > 0){
                    sSelect += " AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare","labelid")+" like ?";
                    iIndex++;
                }

                if(sFindText.length() > 0){
                    sSelect += " AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare",label)+" like ? ";
                }

            	Connection lad_conn = MedwanQuery.getInstance().getAdminConnection();
                ps = lad_conn.prepareStatement(sSelect+" ORDER BY labelid");
                if (sFindCode.length() > 0){
                    ps.setString(1,"%"+sFindCode.toLowerCase()+"%");
                }

                if(sFindText.length() > 0){
                    ps.setString(iIndex,"%"+sFindText.toLowerCase()+"%");
                }

                rs = ps.executeQuery();
                String labelid, sClass = "";
                boolean recsFound = false;
                while (rs.next()){
                    recsFound = true;
                    labelid = rs.getString("labelid");

                    if (sClass.equals("")) sClass = "1";
                    else                   sClass = "";

                    %>
                      <tr class='list<%=sClass%>'>
                        <td onMouseOver="this.style.cursor='hand'" onMouseOut="this.style.cursor='default'">
                          <img src='<c:url value="/_img/plus.png"/>' onclick="addActivity('<%=labelid%>')" title="<%=getTran("web","add",sWebLanguage)%>"/>
                          <img src='<c:url value="/_img/icon_edit.gif"/>' onclick="editActivity('<%=labelid%>')" title="<%=getTran("web","edit",sWebLanguage)%>"/>
                        </td>
                        <td><%=labelid%></td>
                        <td><%=rs.getString(label)%></td>
                      </tr>
                    <%
                }

                if(!recsFound){
                    // display 'no results' message
                    %>
                      <tr>
                        <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                      </tr>
                    <%
                }

                %>
                  <tr>
                    <td width="40"></td>
                    <td width="60"></td>
                    <td width="*"></td>
                  </tr>
                <%
                    rs.close();
                    ps.close();
                    lad_conn.close();
                %>
          </table>
        </div>
      </td>
    </tr>
  </table>

  <br>

  <%-- CLOSE BUTTON --%>
  <center>
    <input type="button" name="buttonclose" class="button" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
  </center>

  <script>
    function addActivity(labelid){
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.occup&labelID=CodeAdded";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.occup","CodeAdded",sWebLanguage)%>");
      window.location.href = "<c:url value="/healthrecord/addActivity.jsp"/>?activityCode="+labelid;
      window.opener.location.reload();
    }

    function editActivity(labelid){
      openPopup("/healthrecord/editActivity.jsp&ts=<%=getTs()%>&activityCode="+labelid);
    }

    window.resizeTo(582,484);
    searchForm.FindCode.focus();
  </script>
</form>
