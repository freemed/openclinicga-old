<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%//=checkPermission("occupmanagelabprofiles","select",activeUser)%>

<%
    final String sLabeltype = "labprofiles";
    PreparedStatement ps;
    ResultSet Occuprs;
    ResultSet rs;
    String sSelect;
    boolean recordExists = false;

    String action           = checkString(request.getParameter("Action"));
    String sLabID           = checkString(request.getParameter("LabID")).trim();
    String sProfileID       = checkString(request.getParameter("ProfileID")).trim();
    String sFindProfileCode = checkString(request.getParameter("FindProfileCode")).trim();
    String sEditProfileCode = checkString(request.getParameter("EditProfileCode")).trim();
    String sOldProfileCode  = checkString(request.getParameter("OldProfileCode")).trim();

    if(sOldProfileCode.equals("")) sOldProfileCode = sFindProfileCode;

    String sComment = "", sNL = "", sFR = "";
%>

<%-- SEARCHFORM ---------------------------------------------------------------------------------%>
<form name="searchForm" method="post">
  <input type="hidden" name="Action" value="find"/>
  <input type="hidden" name="ProfileID" value="<%=sProfileID%>"/>

<table width="100%" class="menu" cellspacing="0">
  <tr>
      <td colspan="2"><%=writeTableHeader("Web.Occup","medwan.system-related-actions.manage-labProfiles",sWebLanguage,"showWelcomePage.do?Tab=Actions&ts="+getTs())%></td>
  </tr>

  <%-- INPUT & BUTTONS --%>
  <tr>
    <td class="menu" width="10%">
      <%=getTran("Web.manage","labprofiles.cols.code",sWebLanguage)%>&nbsp;
      <input type="text" name="FindProfileCode" class="text" size="20" value="<%=(action.equals("details")?"":sFindProfileCode)%>" onblur="limitLength(this);">
    </td>

    <td width="*">&nbsp;
      <input class="button" type="submit" name="findButton" value="<%=getTran("Web","find",sWebLanguage)%>" onclick="searchForm.Action.value='find';"/>&nbsp;
      <input class="button" type="button" name="clearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClear();">&nbsp;
      <input class="button" type="button" name="createButton" value="<%=getTran("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
      <input class="button" type="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
    </td>
  </tr>
</table>

<script>
  searchForm.FindProfileCode.focus();

  function doClear(){
    searchForm.FindProfileCode.value = '';
    searchForm.FindProfileCode.focus();
  }

  function doNew(){
    searchForm.FindProfileCode.value = '';
    searchForm.Action.value = 'new';
    searchForm.ProfileID.value = '';
    searchForm.submit();
  }

  function doBack(){
    window.location.href = '<c:url value="/healthrecord/showWelcomePage.do"/>?Tab=Actions&ts=<%=getTs()%>';
  }
</script>
</form>

<%
Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    //--- SAVE ------------------------------------------------------------------------------------
    if(action.equals("save") || action.equals("new")){
        if(sEditProfileCode.length() > 0){
            sComment = checkString(request.getParameter("EditComment"));
            sNL      = checkString(request.getParameter("EditNL"));
            sFR      = checkString(request.getParameter("EditFR"));

            boolean labelMustBeInserted = false;
            boolean labelMustBeUpdated = false;

            //--- NEW LAB PROFILE --------------------------------------------------
            if(action.equals("new")){
                // check if profileCode exists
                boolean deletedRecordFound = false;
                boolean unDeletedRecordFound = false;

                sSelect = "SELECT deletetime FROM LabProfiles WHERE profilecode = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sOldProfileCode);
                Occuprs = ps.executeQuery();

                // check delete time
                while(Occuprs.next()){
                    if(checkString(Occuprs.getString(1)).length() > 0) deletedRecordFound = true;
                    else                                               unDeletedRecordFound = true;
                }

                if(Occuprs!=null) Occuprs.close();
                if(ps!=null) ps.close();

                if((!deletedRecordFound && !unDeletedRecordFound) || (deletedRecordFound && !unDeletedRecordFound)){
                    sSelect = "INSERT INTO LabProfiles(profileID,profilecode,comment,updateuserid,updatetime,deletetime)"+
                              " VALUES (?,?,?,?,?,?)";

                    ps = oc_conn.prepareStatement(sSelect);
                    sProfileID = MedwanQuery.getInstance().getOpenclinicCounter("LabProfileID")+"";

                    labelMustBeInserted = true;
                }
                //--- NEW ANALYSIS BUT IT ALLREADY EXISTS ---
                else if(unDeletedRecordFound){
                    recordExists = true;
                }
            }
            //--- UPDATE LAB PROFILE -----------------------------------------------
            else{
                sSelect = "UPDATE LabProfiles SET"+
                          " profileID=?, profilecode=?, comment=?, updateuserid=?, updatetime=?, deletetime=?"+
                          " WHERE profileID = ?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(7,Integer.parseInt(sProfileID));

                labelMustBeUpdated = true;
            }

            // execute query
            if(!recordExists){
                ps.setInt(1,Integer.parseInt(sProfileID));
                ps.setString(2,sEditProfileCode);
                ps.setString(3,setSQLString(sComment));
                ps.setInt(4,Integer.parseInt(activeUser.userid)); // updateuserid
                ps.setTimestamp(5,getSQLTime());
                ps.setTimestamp(6,null);

                ps.executeUpdate();
                if(ps!=null) ps.close();
            }

            if(ps!=null) ps.close();

            //--- SAVE LABEL ----------------------------------------------------------------------

            //--- INSERT LABEL ---
            Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            if(labelMustBeInserted){
                // check if profilecode exists
                boolean labelFound = false;
                sSelect = "SELECT 1 FROM Labels WHERE labeltype = ? AND labelid = ?";
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sLabeltype);
                ps.setString(2,sProfileID);
                rs = ps.executeQuery();
                if(rs.next()) labelFound = true;
                rs.close();
                ps.close();

                if(!labelFound){
                    sSelect = "INSERT INTO Labels(labeltype,labelid,labelnl,labelfr,labelen,updatetime,doNotShowLink,updateuserid)"+
                              " VALUES(?,?,?,?,?,?,?,?)";

                    ps = ad_conn.prepareStatement(sSelect);

                    ps.setString(1,sLabeltype);
                    ps.setString(2,sProfileID);
                    ps.setString(3,sNL);
                    ps.setString(4,sFR);
                    ps.setString(5,""); // todo ?
                    ps.setTimestamp(6,getSQLTime());
                    ps.setBoolean(7,false); // doNotShowLink
                    ps.setInt(8,Integer.parseInt(activeUser.userid));

                    ps.executeUpdate();
                    ps.close();

                    reloadSingleton(session);
                }
            }
            //--- UPDATE LABEL ---
            else if(labelMustBeUpdated){
                sSelect = "UPDATE Labels"+
                          " SET labeltype=?, labelid=?, labelnl=?, labelfr=?,"+ // labelen=?,
                          "     updatetime=?, doNotShowLink=?, updateuserid=?"+
                          " WHERE labeltype = ? AND labelid = ?";

                ps = ad_conn.prepareStatement(sSelect);

                ps.setString(1,sLabeltype);
                ps.setString(2,sProfileID);
                ps.setString(3,sNL);
                ps.setString(4,sFR);
                //ps.setString(5,""); // todo ?
                ps.setTimestamp(5,getSQLTime());
                ps.setBoolean(6,false); // doNotShowLink
                ps.setInt(7,Integer.parseInt(activeUser.userid));
                ps.setString(8,sLabeltype);
                ps.setString(9,sProfileID);

                ps.executeUpdate();
                ps.close();

                reloadSingleton(session);
            }
			ad_conn.close();
            // message
            if(recordExists){
                out.print(getTran("Web.Occup","labprofiles.profile",sWebLanguage)+" '"+sEditProfileCode+"' "+getTran("Web","exists",sWebLanguage));
            }
            else{
                out.print(getTran("Web","dataissaved",sWebLanguage));
                action = "save";
            }
        }
    }

    //--- DELETE ----------------------------------------------------------------------------------
    if(action.equals("delete")){
        // set deletetime and updatetime of labprofile to now
        sSelect = "UPDATE LabProfiles SET deletetime = ?, updatetime = ? WHERE profileID = ?";
        ps = oc_conn.prepareStatement(sSelect);
        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime())); // now
        ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime())); // now
        ps.setInt(2,Integer.parseInt(sProfileID));
        ps.executeUpdate();
        if(ps!=null) ps.close();

        // also delete all records in LabprofileAnalysis
        sSelect = "DELETE FROM LabProfilesAnalysis WHERE profileID = ?";
        ps = oc_conn.prepareStatement(sSelect);
        ps.setInt(1,Integer.parseInt(sProfileID));
        ps.executeUpdate();
        if(ps!=null) ps.close();

        // message
        out.print(getTran("Web.Occup","labprofiles.profile",sWebLanguage)+" '"+sEditProfileCode+"' "+getTran("Web","deleted",sWebLanguage));
    }

    //--- ADD LABANALYSIS -------------------------------------------------------------------------
    if(action.equals("addLab")){
        // check if labprofile allready is connected with labanalysis
        boolean connected = false;

        // get values from request
        String sLabCode      = checkString(request.getParameter("LabCode"));
        String sLabCodeOther = checkString(request.getParameter("LabCodeOther"));
        String sLabComment   = checkString(request.getParameter("LabComment")).trim();

        // compose query
        sSelect = "SELECT 1 FROM LabAnalysis la, LabProfilesAnalysis lpa"+
                  " WHERE la.labID = lpa.labID"+
                  "  AND lpa.profileID = ?"+
                  "  AND la.labcode = ? and la.deletetime is null";

        if(sLabCodeOther.equals("1")){
            // check if labanalysis with this comment allready exists
            sSelect+= " AND lpa.comment = '"+sLabComment+"'";
        }
        else{
            // check if labanalysis with this labID allready exists
            sSelect+= " AND lpa.labID = "+sLabID;
        }

        ps = oc_conn.prepareStatement(sSelect);
        ps.setInt(1,Integer.parseInt(sProfileID));
        ps.setString(2,sLabCode);
        Occuprs = ps.executeQuery();
        if(Occuprs.next()) connected = true;
        if(Occuprs!=null) Occuprs.close();
        if(ps!=null) ps.close();

        if(!connected){
            sSelect = "INSERT INTO LabProfilesAnalysis(profileID,labID,updateuserid,updatetime,comment) VALUES(?,?,?,?,?)";
            ps = oc_conn.prepareStatement(sSelect);

            ps.setInt(1,Integer.parseInt(sProfileID));
            ps.setInt(2,Integer.parseInt(sLabID));
            ps.setInt(3,Integer.parseInt(activeUser.userid));
            ps.setTimestamp(4,getSQLTime());
            ps.setString(5,sLabComment);
            ps.executeUpdate();
            if(ps!=null) ps.close();

            // set updatetime of labprofile to now
            sSelect = "UPDATE LabProfiles SET updatetime = ? WHERE profileID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime())); // now
            ps.setInt(2,Integer.parseInt(sProfileID));
            ps.executeUpdate();
            if(ps!=null) ps.close();

            // message
            if(sLabCodeOther.equals("1")){
                out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sLabCode+" ("+sLabComment+")' "+getTran("Web","added",sWebLanguage));
            }
            else{
                out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sLabCode+"' "+getTran("Web","added",sWebLanguage));
            }
        }
        else{
            // message
            if(sLabCodeOther.equals("1")){
                out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sLabCode+" ("+sLabComment+")' "+getTran("Web","exists",sWebLanguage));
            }
            else{
                out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sLabCode+"' "+getTran("Web","exists",sWebLanguage));
            }
        }
    }

    //--- REMOVE LABANALYSIS ----------------------------------------------------------------------
    if(action.equals("remLab")){
        // get values from request
        String sLabCode      = checkString(request.getParameter("LabCode"));
        String sLabCodeOther = checkString(request.getParameter("LabCodeOther"));
        String sLabComment   = checkString(request.getParameter("LabComment")).trim();

        sSelect = "DELETE FROM LabProfilesAnalysis"+
                  " WHERE profileID = ? AND labID = ?";

        if(sLabCodeOther.equals("1")){
            // comment is part of the key if the analysis is of type 'other'.
            sSelect+= " AND comment = '"+sLabComment+"'";
        }

        ps = oc_conn.prepareStatement(sSelect);
        ps.setInt(1,Integer.parseInt(sProfileID));
        ps.setInt(2,Integer.parseInt(sLabID));
        ps.executeUpdate();
        if(ps!=null) ps.close();

        // set updatetime of labprofile to now
        sSelect = "UPDATE LabProfiles SET updatetime = ? WHERE profileID = ?";
        ps = oc_conn.prepareStatement(sSelect);
        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime())); // now
        ps.setInt(2,Integer.parseInt(sProfileID));
        ps.executeUpdate();
        if(ps!=null) ps.close();

        // message
        if(sLabCodeOther.equals("1")){
            out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sLabCode+" ("+sLabComment+")' "+getTran("Web","removed",sWebLanguage));
        }
        else{
            out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sLabCode+"' "+getTran("Web","removed",sWebLanguage));
        }
    }

    //--- SEARCH ----------------------------------------------------------------------------------
    int iTotal = 0;
    if(action.equals("find")){
        //--- FIND HEADER ---
        %>
        <table width="100%" cellspacing="1" cellpadding="0" class="list">
          <tr>
            <td class='titleadmin' width='15%'>&nbsp;<%=getTran("Web.manage","labprofiles.cols.code",sWebLanguage)%></td>
            <td class='titleadmin' width='30%'>
            <%
                String descr = getTran("Web","description",sWebLanguage);
                if(sWebLanguage.equalsIgnoreCase("n")){
                    %>&nbsp;<%=descr%>&nbsp;<%=getTran("Web.manage","labprofiles.cols.NL",sWebLanguage)%><%
                }
                else if(sWebLanguage.equalsIgnoreCase("f")){
                    %>&nbsp;<%=descr%>&nbsp;<%=getTran("Web.manage","labprofiles.cols.FR",sWebLanguage)%><%
                }
            %>
            </td>
            <td class='titleadmin' width='*%'>&nbsp;<%=getTran("Web.manage","labprofiles.cols.comment",sWebLanguage)%></td>
          </tr>

          <tbody onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
        <%

        //--- compose search-select ---
        String profilecode = MedwanQuery.getInstance().getConfigParam("lowerCompare","profilecode");
        sSelect = "SELECT profileID,profilecode,comment FROM LabProfiles"+
                  " WHERE "+profilecode+" LIKE ?  AND deletetime IS NULL ORDER BY "+profilecode;

        ps = oc_conn.prepareStatement(sSelect);
        ps.setString(1,"%"+sFindProfileCode.toLowerCase()+"%");
        Occuprs = ps.executeQuery();
        String sClass;

        //--- display found records ---
        while(Occuprs.next()){
            iTotal++;

            // get data from RS
            sProfileID       = checkString(""+Occuprs.getInt(1));
            sEditProfileCode = checkString(Occuprs.getString(2));
            sComment         = checkString(Occuprs.getString(3));

            // alternate rows
            if((iTotal%2)==0) sClass = "1";
	        else              sClass = "";

            %>
                <tr class="list<%=sClass%>"  onClick="showDetails('<%=sEditProfileCode%>','<%=sProfileID%>');">
                  <td>&nbsp;<%=sEditProfileCode%></td>
                  <td>&nbsp;<%=getTran(sLabeltype,sProfileID,sWebLanguage)%></td>
                  <td>&nbsp;<%=sComment%></td>
                </tr>
            <%
        }

        out.print("</table>");

        if(Occuprs!=null) Occuprs.close();
        if(ps!=null) ps.close();

        // message
        %>
          </tbody>

          <table border="0" width="100%">
            <tr height="30">
              <td><%=iTotal%> <%=getTran("Web","recordsFound",sWebLanguage)%></td>
              <td align="right">
                <img src='<c:url value="/_img/pijl.gif"/>'>
                <a  href="<c:url value='/main.do'/>?Page=healthrecord/manageLabAnalysis_view.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.system-related-actions.manage-labAnalysis",sWebLanguage)%></a>&nbsp;
              </td>
            </tr>
          </table>
        <%
    }
    %>

    <script>
      function showDetails(code,id){
        searchForm.Action.value = 'details';
        searchForm.FindProfileCode.value = code;
        searchForm.ProfileID.value = id;
        searchForm.submit();
      }
    </script>
    <%

    // show details after "save"
    if(action.equals("save") || action.equals("addLab") || action.equals("remLab")){
        action = "details";
        sFindProfileCode = sEditProfileCode;
    }

    //--- EDIT/ADD FIELDS -------------------------------------------------------------------------
    if(action.equals("new") || action.equals("details")){
        iTotal = 0;
        if(sFindProfileCode.equals("")) sFindProfileCode = sEditProfileCode;

        //--- check if ProfileCode exists; details are shown if it exists, else values will be blank ---
        if(sFindProfileCode.length() > 0){
            sSelect = "SELECT profilecode,comment FROM LabProfiles WHERE profilecode = ? AND profileID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sFindProfileCode);
            ps.setInt(2,Integer.parseInt(sProfileID));
            Occuprs = ps.executeQuery();

            if(Occuprs.next()){
                iTotal++;

                // get data from RS
                sEditProfileCode = checkString(Occuprs.getString(1));
                sComment         = checkString(Occuprs.getString(2));

                // get labels
                sNL = getTran(sLabeltype,sProfileID,"n");
                sFR = getTran(sLabeltype,sProfileID,"f");
            }

            if(Occuprs!=null) Occuprs.close();
            if(ps!=null) ps.close();
        }
        %>

<%-- EDIT/ADD FROM ------------------------------------------------------------------------------%>
<form name="editForm" method="post" onclick="setSaveButton();" onkeyup="setSaveButton();">
  <input type="hidden" name="Action" value="<%=(action.equals("new")?action:"save")%>"/>
  <input type="hidden" name="LabID" value="<%=sLabID%>"/>
  <input type="hidden" name="LabCodeOther" value=""/>
  <input type="hidden" name="ProfileID" value="<%=sProfileID%>"/>
  <input type="hidden" name="OldProfileCode" value="<%=sOldProfileCode%>"/>

<table border="0" width="100%" class="list" cellspacing="1">

  <%-- EDIT/ADD HEADER --%>
  <tr class="admin">
    <td colspan="2">
    <%
        if(iTotal > 0) out.print(getTran("Web","edit",sWebLanguage));
        else           out.print(getTran("Web","new",sWebLanguage));
    %>
    </td>
  </tr>

  <%-- PROFILE CODE --%>
  <tr>
    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labprofiles.cols.code",sWebLanguage)%></td>
    <td class="admin2">
        <input type="text" name="EditProfileCode" tabindex="1" class="text" value="<%=sEditProfileCode%>" size="20" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- LABEL NL --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labprofiles.cols.NL",sWebLanguage)%></td>
    <td class="admin2">
        <input type="text" name="EditNL" class="text" tabindex="2" value="<%=sNL%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- LABEL FR --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labprofiles.cols.FR",sWebLanguage)%></td>
    <td class="admin2">
        <input type="text" name="EditFR" class="text" tabindex="3" value="<%=sFR%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- LABANALYSIS LINKED TO THIS LABPROFILE ----------------------------------------------------%>
  <%
      if(!action.equals("new")){
          %>
            <tr>
              <td class="admin"><%=getTran("Web.manage","labprofiles.analyse",sWebLanguage)%></td>
              <td class="admin2">
                <table border="0" class="list" cellspacing="1">
                  <%-- HEADER --%>
                  <tr class="admin">
                    <td>&nbsp;<%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%></td>
                    <td>&nbsp;<%=getTran("web.manage","labanalysis.cols.type",sWebLanguage)%></td>
                    <td>&nbsp;<%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%></td>
                    <td>&nbsp;<%=getTran("web.manage","labanalysis.cols.comment",sWebLanguage)%></td>
                    <td width="16">&nbsp;</td>
                  </tr>

                  <%-- LABCODE CHOOSER --%>
                  <tr class="list1">
                    <td>
                      <input type="text" name="LabCode" tabindex="4" class="text" size="18" onBlur='blurLabAnalysis();'>
                    </td>
                    <td>
                      <input type="text" name="LabType" class="text" size="10" READONLY>
                    </td>
                    <td>
                      <input type="text" name="LabLabel" class="text" size="30" READONLY>
                    </td>
                    <td>
                      <input type="text" name="LabComment" class="text" size="20" onblur="limitLength(this);">
                    </td>
                    <td>
                      <input type="button" class="button" tabindex="5" name="LabChooseButton" value="<%=getTran("Web","choose",sWebLanguage)%>" onclick='searchLabAnalysis();'>&nbsp;
                      <input type="button" class="button" tabindex="6" name="LabAddButton"    value="<%=getTran("Web","add",sWebLanguage)%>" onClick="addLabAnalysis();">
                    </td>
                  </tr>

                  <%
                      // compose search-select
                      String labcodeLower = MedwanQuery.getInstance().getConfigParam("lowerCompare","la.labcode");
                      String commentLower = MedwanQuery.getInstance().getConfigParam("lowerCompare","lap.comment");

                      sSelect = "SELECT lap.labID,la.labcode,la.labtype,la.labcodeother,lap.comment"+
                                " FROM LabProfiles lp, LabProfilesAnalysis lap, LabAnalysis la"+
                                " WHERE lap.profileID = lp.profileID"+
                                "  AND lap.labID = la.labID"+
                                "  AND lp.profileID = ? and la.deletetime is null"+
                                " ORDER BY "+labcodeLower+","+commentLower;

                      ps = oc_conn.prepareStatement(sSelect);
                      ps.setInt(1,Integer.parseInt(sProfileID));
                      Occuprs = ps.executeQuery();
                      String sClass, sLabCode, sLabType, sLabCodeOther, sLabComment;
                      iTotal = 0;

                      //--- display found records ---
                      while(Occuprs.next()){
                          iTotal++;

                          // get data from RS
                          sLabID        = checkString(""+Occuprs.getInt(1));
                          sLabCode      = checkString(Occuprs.getString(2));
                          sLabType      = checkString(Occuprs.getString(3));
                          sLabCodeOther = checkString(Occuprs.getString(4));
                          sLabComment   = checkString(Occuprs.getString(5));

                          // translate labtype
                               if(sLabType.equals("1")) sLabType = getTran("Web.occup","labanalysis.type.blood",sWebLanguage);
                          else if(sLabType.equals("2")) sLabType = getTran("Web.occup","labanalysis.type.urine",sWebLanguage);
                          else if(sLabType.equals("3")) sLabType = getTran("Web.occup","labanalysis.type.other",sWebLanguage);
                          else if(sLabType.equals("4")) sLabType = getTran("Web.occup","labanalysis.type.stool",sWebLanguage);
                          else if(sLabType.equals("5")) sLabType = getTran("Web.occup","labanalysis.type.sputum",sWebLanguage);
                          else if(sLabType.equals("6")) sLabType = getTran("Web.occup","labanalysis.type.smear",sWebLanguage);
                          else if(sLabType.equals("7")) sLabType = getTran("Web.occup","labanalysis.type.liquid",sWebLanguage);

                          // alternate row-style
                          if((iTotal%2)==0) sClass = "1";
                          else              sClass = "";

                          %>
                              <tr class="list<%=sClass%>">
                                <td>&nbsp;<%=sLabCode%></td>
                                <td>&nbsp;<%=sLabType%></td>
                                <td>&nbsp;<%=getTran("labanalysis",sLabID,sWebLanguage)%></td>
                                <%
                                    if(sLabCodeOther.equals("1")){
                                        %><td>&nbsp;<%=sLabComment%></td><%
                                    }
                                    else{
                                        %><td>&nbsp;</td><%
                                    }
                                %>
                                <td>
                                  <img src='<c:url value="/_img/icon_delete.gif"/>' border='0' alt='<%=getTran("Web","delete",sWebLanguage)%>' onclick="removeLabAnalysis('<%=sLabID%>','<%=sLabComment%>','<%=sLabCodeOther%>','<%=sLabCode%>');" onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
                                </td>
                              </tr>
                          <%
                      }

                      if(Occuprs!=null) Occuprs.close();
                      if(ps!=null) ps.close();

                      // message if no records found
                      if(iTotal == 0){
                          %>
                              <tr class="list">
                                <td colspan="5"><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                              </tr>
                          <%
                      }
                    %>
                  </table>
                </td>
              </tr>

              <script>
                <%-- BLUR LABANALYSIS --%>
                function blurLabAnalysis(inputObj){
                  if(inputObj.value.length > 0){
                    openPopup("/_common/search/blurLabAnalysis.jsp&SearchCode="+this.value+"&VarID=LabID&VarType=LabType&VarCode=LabCode&VarText=LabLabel");
                  }
                }

                <%-- SEARCH LABANALYSIS --%>
                function searchLabAnalysis(){
                  openPopup("/_common/search/searchLabAnalysis.jsp&VarID=LabID&VarType=LabType&VarCode=LabCode&VarText=LabLabel");
                }

                <%-- ADD LABANALYSIS --%>
                function addLabAnalysis(){
                  if(editForm.LabCodeOther.value=="1"){
                    if(editForm.LabCode.value!="" && editForm.LabLabel.value!=""){
                      if(editForm.LabComment.value!=""){
                        editForm.Action.value = 'addLab';
                        editForm.submit();
                      }
                      else{
                        editForm.LabComment.focus();
                      }
                    }
                  }
                  else{
                    if(editForm.LabCode.value!="" && editForm.LabLabel.value!=""){
                      editForm.Action.value = 'addLab';
                      editForm.submit();
                    }
                    else{
                      editForm.LabCode.focus();
                    }
                  }
                }

                <%-- REMOVE LABANALYSIS --%>
                function removeLabAnalysis(labid,comment,labCodeOther,labCode){
                  if(yesnoDialog("Web","areYouSureToDelete")){
                    editForm.LabID.value = labid;
                    editForm.Action.value = 'remLab';
                    editForm.LabComment.value = comment;
                    editForm.LabCodeOther.value = labCodeOther;
                    editForm.LabCode.value = labCode;
                    editForm.submit();
                  }
                }
              </script>
          <%
      }
  %>

  <%-- COMMENT TEXTAREA --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labprofiles.cols.comment",sWebLanguage)%></td>
    <td class="admin2">
      <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" tabindex="7" class="text" cols="80" rows="2" name="EditComment"><%=sComment%></textarea>
    </td>
  </tr>
</table>

<%-- EDIT BUTTONS -------------------------------------------------------------------------------%>
<%=ScreenHelper.alignButtonsStart()%>
<%
    //if(activeUser.accessRights.get("occupmanagelabprofiles.add")!=null || activeUser.accessRights.get("occupmanagelabprofiles.edit")!=null){
    %>
      <input class="button" type="button" name="SaveButton" value="<%=getTran("web","record",sWebLanguage)%>" onClick="checkSave();"/>&nbsp;
      <script>
        function checkSave(){
          if(editForm.EditProfileCode.value.length == 0 || editForm.EditNL.value == "" || editForm.EditFR.value == ""){
            alertDialog("web.manage","datamissing");

                 if(editForm.EditProfileCode.value.length == 0){ editForm.EditProfileCode.focus(); }
            else if(editForm.EditNL.value == ""){ editForm.EditNL.focus(); }
            else if(editForm.EditFR.value == ""){ editForm.EditFR.focus(); }
          }
          else{
            editForm.submit();
          }
        }
      </script>
    <%
    //}
%>

<%
    if(!action.equals("new")){
        %>
          <input class="button" type="button" value="<%=getTran("web","delete",sWebLanguage)%>" onClick="checkDelete();"/>&nbsp;
          <script>
            function checkDelete(){
              if(editForm.EditProfileCode.value.length > 0){
                if(yesnoDialog("Web","areYouSureToDelete")){
                  editForm.Action.value = 'delete';
                  editForm.submit();
                }
              }
            }
          </script>
        <%
    }
%>
  <input class="button" type="button" value="<%=getTran("web","reset",sWebLanguage)%>" onclick="doReset();">&nbsp;
  <input class="button" type="button" value="<%=getTran("web","back",sWebLanguage)%>" onclick="showOverview();">&nbsp;

  <br><br>

  <%-- link to labanalyses --%>
  <img src='<c:url value="/_img/pijl.gif"/>'>
  <a  href="<c:url value='/main.do'/>?Page=healthrecord/manageLabAnalysis_view.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.system-related-actions.manage-labAnalysis",sWebLanguage)%></a>&nbsp;
<%=ScreenHelper.alignButtonsStop()%>

<script>
  editForm.EditProfileCode.focus();

  function showOverview(){
    window.location.href = '<c:url value='/main.do'/>?Page=healthrecord/manageLabProfiles_view.jsp&ts=<%=getTs()%>';
  }

  function doReset(){
    reset();
    editForm.EditProfileCode.focus();
  }
</script>

</form>
<%--END EDIT FROM -------------------------------------------------------------------------------%>

        <%=writeJSButtons("editForm","document.getElementsByName('SaveButton')[0]")%>
        <%
    }
    oc_conn.close();
%>