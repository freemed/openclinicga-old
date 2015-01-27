<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%//=checkPermission("occupmanagelabanalysis","select",activeUser)%>

<%!
    //--- PROCESS EXPORT SPECIFICATION FOR ANALYSIS -----------------------------------------------
    private void processExportSpecificationForAnalysis(Connection conn, String elementType, String exportCode, String elementContent) throws Exception {
        // check if an exportSpecification exists for the specified prestation (=analysis-request)
        boolean exportSpecificationFound = false;
        String query = "SELECT 1 FROM exportSpecifications WHERE elementType = ?";
        PreparedStatement ps = conn.prepareStatement(query);
        ps.setString(1,elementType);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) exportSpecificationFound = true;
        if(rs!=null) rs.close();
        if(ps!=null) ps.close();

        // add exportSpecification if no exportCode exists for the specified prestation
        if(!exportSpecificationFound){
            query = "INSERT INTO exportSpecifications VALUES(?,?,?,?)";
            ps = conn.prepareStatement(query);
            ps.setString(1,elementType);
            ps.setString(2,exportCode);
            ps.setString(3,elementContent);
            ps.setTimestamp(4,getSQLTime());
            ps.executeUpdate();
            if(ps!=null) ps.close();
        }
        // update exportSpecification if an exportCode was found
        else{
            query = "UPDATE exportSpecifications SET elementType=?, exportCode=?, elementContent=?, updatetime=?"+
                    " WHERE elementType=?";
            ps = conn.prepareStatement(query);
            ps.setString(1,elementType);
            ps.setString(2,exportCode);
            ps.setString(3,elementContent);
            ps.setTimestamp(4,getSQLTime());
            ps.setString(5,elementType);
            ps.executeUpdate();
            if(ps!=null) ps.close();
        }
    }
%>

<%
    final String sLabLabelType = "labanalysis";
    PreparedStatement ps;
    ResultSet Occuprs;
    ResultSet rs;
    String sSelect;

    String action        = checkString(request.getParameter("Action"));
    String sLabID        = checkString(request.getParameter("LabID"));
    String sLabType      = checkString(request.getParameter("LabType"));
    String sLabCodeOther = checkString(request.getParameter("LabCodeOther"));
    String sFindLabCode  = checkString(request.getParameter("FindLabCode")).toLowerCase();
    String sEditLabCode  = checkString(request.getParameter("EditLabCode")).toLowerCase();

    String sMonster = "",
           sBiomonitoring = "",
           sMedidoccode = "",
           sComment = "",
           sLimitValue = "",
           sShortTimeValue = "",
           sPrestationCode = "",
           sPrestationType = "",
           sNL = "",
           sFR = "";

    if(!sLabCodeOther.equals("1")) sLabCodeOther = "0";
    boolean recordExists = false;
%>

<%-- SEARCHFORM ---------------------------------------------------------------------------------%>
<form name="searchForm" method="post">
  <input type="hidden" name="Action" value="find"/>
  <input type="hidden" name="LabID" value="<%=sLabID%>"/>

<table width="100%" class="menu" cellspacing="0">
  <tr>
      <td colspan="2"><%=writeTableHeader("Web.Occup","medwan.system-related-actions.manage-labAnalysis",sWebLanguage,"showWelcomePage.do?Tab=Actions&ts="+getTs())%></td>
  </tr>

  <%-- INPUT & BUTTONS --%>
  <tr>
    <td class="menu" colspan="2">
      &nbsp;<%=getTran("Web.manage","labanalysis.cols.code_name",sWebLanguage)%>&nbsp;
      <input class="text" type="text" name="FindLabCode" size="18" value="<%=(action.equals("details")?"":sFindLabCode)%>" onblur="limitLength(this);">
      <input class="button" type="submit" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onclick="searchForm.Action.value='find';"/>&nbsp;
      <input class="button" type="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClear();">&nbsp;
      <input class="button" type="submit" name="createButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
      <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
    </td>
  </tr>
</table>

<script>
  searchForm.FindLabCode.focus();

  function doClear(){
    searchForm.FindLabCode.value = '';
    searchForm.FindLabCode.focus();
  }

  function doNew(){
    searchForm.FindLabCode.value = '';
    searchForm.LabID.value = '';
    searchForm.Action.value = 'new';
  }

  function doBack(){
    window.location.href = '<c:url value="/healthrecord/showWelcomePage.do"/>?Tab=Actions&ts=<%=getTs()%>';
  }
</script>
</form>

<%
    //--- SAVE ------------------------------------------------------------------------------------
    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    if(action.equals("save") || action.equals("new")){
        if(sEditLabCode.length() > 0){
            sMonster        = checkString(request.getParameter("EditMonster"));
            sBiomonitoring  = checkString(request.getParameter("EditBiomonitoring"));
            sMedidoccode    = checkString(request.getParameter("EditMedidoccode"));
            sComment        = checkString(request.getParameter("EditComment"));
            sLimitValue     = checkString(request.getParameter("EditLimitValue"));
            sShortTimeValue = checkString(request.getParameter("EditShortTimeValue"));
            sPrestationCode = checkString(request.getParameter("EditPrestationcode"));
            sPrestationType = "LABCODE."+sEditLabCode;

            //--- SAVE ANALYSIS -------------------------------------------------------------------
            boolean labelMustBeInserted = false;
            boolean labelMustBeUpdated = false;

            // check if labcode exists
            boolean deletedRecordFound = false;
            boolean unDeletedRecordFound = false;

            // when saving a new analysis, LabID is empty
            if(action.equals("new")){
                sSelect = "SELECT deletetime FROM LabAnalysis WHERE labcode = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,sEditLabCode);
            }
            else{
                sSelect = "SELECT deletetime FROM LabAnalysis WHERE labID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sLabID));
            }

            Occuprs = ps.executeQuery();

            while(Occuprs.next()){
                if(Occuprs.getDate(1)!=null) deletedRecordFound = true;
                else                         unDeletedRecordFound = true;
            }

            if(Occuprs!=null) Occuprs.close();
            if(ps!=null) ps.close();

            //--- NEW LABANALYSIS ---
            if((!deletedRecordFound && !unDeletedRecordFound) || (deletedRecordFound && !unDeletedRecordFound)){
                sSelect = "INSERT INTO LabAnalysis(labID,labcode,labtype,monster,biomonitoring,"+
                          "  medidoccode,comment,updateuserid,updatetime,deletetime,labcodeother,"+
                          "  limitvalue,shorttimevalue)"+
                          " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);
                sLabID = MedwanQuery.getInstance().getOpenclinicCounter("LabProfileID")+"";

                labelMustBeInserted = true;
            }
            //--- NEW ANALYSIS BUT IT ALLREADY EXISTS ---
            else if(unDeletedRecordFound && action.equals("new")){
                recordExists = true;
                //sLabType = "0";
            }
            //--- UPDATE LABANALYSIS ---
            else{
                sSelect = "UPDATE LabAnalysis SET"+
                          "  labID=?, labcode=?, labtype=?, monster=?, biomonitoring=?, medidoccode=?,"+
                          "  comment=?, updateuserid=?, updatetime=?, deletetime=?, labcodeother=?,"+
                          "  limitvalue=?, shorttimevalue=?"+
                          " WHERE labID = ? and deletetime is null";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(14,Integer.parseInt(sLabID));

                labelMustBeUpdated = true;
            }

            if(!recordExists){
                ps.setInt(1,Integer.parseInt(sLabID));
                ps.setString(2,sEditLabCode);
                ps.setString(3,sLabType);
                ps.setString(4,sMonster);
                ps.setString(5,sBiomonitoring);
                ps.setString(6,sMedidoccode);
                ps.setString(7,setSQLString(sComment));
                ps.setInt(8,Integer.parseInt(activeUser.userid)); // updateuserid
                ps.setTimestamp(9,getSQLTime());
                ps.setTimestamp(10,null);
                ps.setString(11,sLabCodeOther);
                ps.setString(12,sLimitValue);
                ps.setString(13,sShortTimeValue);

                ps.executeUpdate();
            }

            if(ps!=null) ps.close();

            //--- SAVE LABEL ----------------------------------------------------------------------
            sNL = checkString(request.getParameter("EditNL"));
            sFR = checkString(request.getParameter("EditFR"));

            //--- INSERT LABEL ---
          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            if(labelMustBeInserted){
                // check if labcode exists
                boolean labelFound = false;
                sSelect = "SELECT 1 FROM Labels WHERE labeltype = ? AND labelid = ?";
                ps = ad_conn.prepareStatement(sSelect);
                ps.setString(1,sLabLabelType);
                ps.setString(2,sLabID);
                rs = ps.executeQuery();
                if(rs.next()) labelFound = true;
                rs.close();
                ps.close();

                if(!labelFound){
                    sSelect = "INSERT INTO Labels(labeltype,labelid,labelnl,labelfr,"+/*labelen,*/
                              "  updatetime,doNotShowLink,updateuserid)"+
                              " VALUES(?,?,?,?,?,?,?)";

                    ps = ad_conn.prepareStatement(sSelect);

                    ps.setString(1,sLabLabelType); // labeltype
                    ps.setString(2,sLabID); // labelid
                    ps.setString(3,sNL);
                    ps.setString(4,sFR);
                    ps.setTimestamp(5,getSQLTime());
                    ps.setBoolean(6,false); // doNotShowLink
                    ps.setInt(7,Integer.parseInt(activeUser.userid));

                    ps.executeUpdate();
                    ps.close();

                    reloadSingleton(session);
                }
            }
            //--- UPDATE LABEL ---
            else if(labelMustBeUpdated){
                sSelect = "UPDATE Labels"+
                          " SET labeltype=?, labelid=?, labelnl=?, labelfr=?,"+ // labelen=?,
                          "  updatetime=?, doNotShowLink=?, updateuserid=?"+
                          " WHERE labeltype = ? AND labelid = ?";

                ps = ad_conn.prepareStatement(sSelect);

                ps.setString(1,sLabLabelType); // labeltype
                ps.setString(2,sLabID); // labelid
                ps.setString(3,sNL);
                ps.setString(4,sFR);
                //ps.setString(5,sEN); // todo ?
                ps.setTimestamp(5,getSQLTime());
                ps.setBoolean(6,false); // doNotShowLink
                ps.setInt(7,Integer.parseInt(activeUser.userid));
                ps.setString(8,sLabLabelType);
                ps.setString(9,sLabID);

                ps.executeUpdate();
                ps.close();

                reloadSingleton(session);
            }
			ad_conn.close();
            // save prestationcode if needed
            if(!recordExists && sPrestationCode.length() > 0){
                processExportSpecificationForAnalysis(oc_conn,sPrestationType,sPrestationCode,"");
            }

            // message
            if(recordExists){
                out.print("<span style='color:red;'>"+getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sEditLabCode+"' "+getTran("Web","exists",sWebLanguage)+"</span>");
            }
            else{
                out.print(getTran("Web","dataissaved",sWebLanguage));
                action = "save";
            }
        }
    }

    //--- DELETE ----------------------------------------------------------------------------------
    if(action.equals("delete")){

        // first delete LabAnalysis
        sSelect = "UPDATE LabAnalysis SET deletetime = ?,updatetime = ? WHERE labID = ? and deletetime is null";
        ps = oc_conn.prepareStatement(sSelect);
        ps.setTimestamp(1,getSQLTime());
        ps.setTimestamp(2,getSQLTime());
        ps.setInt(3,Integer.parseInt(sLabID));
        ps.executeUpdate();
        if(ps!=null) ps.close();

        // message
        out.print(getTran("Web.Occup","labanalysis.analysis",sWebLanguage)+" '"+sEditLabCode+"' "+getTran("Web","deleted",sWebLanguage));
    }

    //--- SEARCH ----------------------------------------------------------------------------------
    int iTotal = 0;
    if(action.equals("find")){
        //--- FIND HEADER ---
        %>
        <table width="100%" cellspacing="1" cellpadding="0" class="list" onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
            <tr>
                <td class='titleadmin' width='6%'>&nbsp;<%=getTran("Web.manage","labanalysis.cols.code",sWebLanguage)%></td>
                <td class='titleadmin' width='7%'>&nbsp;<%=getTran("Web.manage","labanalysis.cols.other",sWebLanguage)%></td>
                <td class='titleadmin' width='7%'>&nbsp;<%=getTran("Web.manage","labanalysis.cols.type",sWebLanguage)%></td>
                <td class='titleadmin' width='25%'>
                <%
                    String descr = getTran("Web","description",sWebLanguage);
                    if(sWebLanguage.equalsIgnoreCase("n")){
                        %>&nbsp;<%=descr%>&nbsp;<%=getTran("Web.manage","labanalysis.cols.NL",sWebLanguage)%><%
                    }
                    else if(sWebLanguage.equalsIgnoreCase("f")){
                        %>&nbsp;<%=descr%>&nbsp;<%=getTran("Web.manage","labanalysis.cols.FR",sWebLanguage)%><%
                    }
                %>
                </td>
                <td class='titleadmin' width='15%'>&nbsp;<%=getTran("Web.manage","labanalysis.cols.monster",sWebLanguage)%></td>
                <td class='titleadmin' width='10%'>&nbsp;<%=getTran("Web.manage","labanalysis.cols.biomonitoring",sWebLanguage)%></td>
                <td class='titleadmin' width='*%'>&nbsp;<%=getTran("Web.manage","labanalysis.cols.medidoccode",sWebLanguage)%></td>
            </tr>
        <%

        //--- compose search-select ---
        String labcodeCompare = MedwanQuery.getInstance().getConfigParam("lowerCompare","labcode");
        sSelect = "SELECT labID,labtype,labcode,monster,biomonitoring,medidoccode,labcodeother,limitvalue,shorttimevalue"+
                  " FROM LabAnalysis a,LabelsView b"+
                  " WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","a.labID")+"=b.labelid"+
                  "  AND b.labeltype='labanalysis'"+
                  "  AND (label"+(sWebLanguage.equalsIgnoreCase("N")?"nl":"fr")+" LIKE ? OR "+labcodeCompare+" LIKE ?) "+
                  "  AND deletetime IS NULL"+
                  " ORDER BY "+labcodeCompare;

        ps = oc_conn.prepareStatement(sSelect);
        ps.setString(1,"%"+sFindLabCode+"%");
        ps.setString(2,"%"+sFindLabCode+"%");
        Occuprs = ps.executeQuery();
        String sClass;

        //--- display found records ---
        while(Occuprs.next()){
            iTotal++;

            // get data from RS
            sLabID         = checkString(""+Occuprs.getInt(1));
            sLabType       = checkString(Occuprs.getString(2));
            sEditLabCode   = checkString(Occuprs.getString(3));
            sMonster       = checkString(Occuprs.getString(4));
            sBiomonitoring = checkString(Occuprs.getString(5));
            sMedidoccode   = checkString(Occuprs.getString(6));
            sLabCodeOther  = checkString(Occuprs.getString(7));

            // translate labtype
                 if(sLabType.equals("1")) sLabType = getTran("Web.occup","labanalysis.type.blood",sWebLanguage);
            else if(sLabType.equals("2")) sLabType = getTran("Web.occup","labanalysis.type.urine",sWebLanguage);
            else if(sLabType.equals("3")) sLabType = getTran("Web.occup","labanalysis.type.other",sWebLanguage);
            else if(sLabType.equals("4")) sLabType = getTran("Web.occup","labanalysis.type.stool",sWebLanguage);
            else if(sLabType.equals("5")) sLabType = getTran("Web.occup","labanalysis.type.sputum",sWebLanguage);
            else if(sLabType.equals("6")) sLabType = getTran("Web.occup","labanalysis.type.smear",sWebLanguage);
            else if(sLabType.equals("7")) sLabType = getTran("Web.occup","labanalysis.type.liquid",sWebLanguage);

            // translate biomonitoring
                 if(sBiomonitoring.equals("0")) sBiomonitoring = getTran("Web","no",sWebLanguage);
            else if(sBiomonitoring.equals("1")) sBiomonitoring = getTran("Web","yes",sWebLanguage);

            // translate labcodeother
                 if(sLabCodeOther.equals("0")) sLabCodeOther = "";
            else if(sLabCodeOther.equals("1")) sLabCodeOther = getTran("web.occup","labanalysis.labCodeOther",sWebLanguage);

            // alternate row-style
            if((iTotal%2)==0) sClass = "1";
	        else              sClass = "";

            %>
                <tr class="list<%=sClass%>"   onClick="showDetails('<%=sEditLabCode%>','<%=sLabID%>');">
                    <td>&nbsp;<%=sEditLabCode%></td>
                    <td>&nbsp;<%=sLabCodeOther%></td>
                    <td>&nbsp;<%=sLabType%></td>
                    <td>&nbsp;<%=getTran(sLabLabelType,sLabID,sWebLanguage)%></td>
                    <td>&nbsp;<%=sMonster%></td>
                    <td>&nbsp;<%=sBiomonitoring%></td>
                    <td>&nbsp;<%=sMedidoccode%></td>
                </tr>
            <%
        }

        out.print("</table>");

        if(Occuprs!=null) Occuprs.close();
        if(ps!=null) ps.close();

        // message
        %>
          <table border="0" width="100%">
              <tr height="30">
                  <td><%=iTotal%> <%=getTran("Web","recordsFound",sWebLanguage)%></td>
                  <td align="right">
                      <img src='<c:url value="/_img/themes/default/pijl.gif"/>'>
                      <a  href="<c:url value='/main.do'/>?Page=healthrecord/manageLabProfiles_view.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.system-related-actions.manage-labProfiles",sWebLanguage)%></a>&nbsp;
                  </td>
              </tr>
          </table>
        <%
    }

    %>
        <script>
          function showDetails(code,id){
            searchForm.Action.value = 'details';
            searchForm.FindLabCode.value = code;
            searchForm.LabID.value = id;
            searchForm.submit();
          }
        </script>
    <%

    if(action.equals("save")){
        sFindLabCode = sEditLabCode;
    }

    //--- EDIT/ADD FIELDS -------------------------------------------------------------------------
    if(action.equals("new") || action.equals("details") || action.equals("save")){
        iTotal = 0;

        //--- check if labcode exists; details are shown if it exists, else values will be blank ---
        if(sFindLabCode.length() > 0){
            sSelect = "SELECT labcode,labtype,monster,biomonitoring,medidoccode,comment,labcodeother,limitvalue,shorttimevalue"+
                      " FROM LabAnalysis"+
                      " WHERE labID = ?";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sLabID));
            Occuprs = ps.executeQuery();

            if(Occuprs.next()){
                iTotal++;

                // get data from RS
                sEditLabCode    = checkString(Occuprs.getString(1));
                sLabType        = checkString(Occuprs.getString(2));
                sMonster        = checkString(Occuprs.getString(3));
                sBiomonitoring  = checkString(Occuprs.getString(4));
                sMedidoccode    = checkString(Occuprs.getString(5));
                sComment        = checkString(Occuprs.getString(6));
                sLabCodeOther   = checkString(Occuprs.getString(7));
                sLimitValue     = checkString(Occuprs.getString(8));
                sShortTimeValue = checkString(Occuprs.getString(9));

                // get labels
                if(action.equals("details")){
                    sNL = getTran(sLabLabelType,sLabID,"n");
                    sFR = getTran(sLabLabelType,sLabID,"f");
                }
            }

            if(Occuprs!=null) Occuprs.close();
            if(ps!=null) ps.close();

            // get prestation code is one exists
            if(sEditLabCode.length() > 0){
                sSelect = "SELECT exportCode FROM exportSpecifications WHERE elementType = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,"LABCODE."+sEditLabCode);
                Occuprs = ps.executeQuery();

                if(Occuprs.next()){
                    sPrestationCode = checkString(Occuprs.getString(1));
                }

                if(Occuprs!=null) Occuprs.close();
                if(ps!=null) ps.close();
            }
        }
    %>

<%-- EDIT/ADD FROM ------------------------------------------------------------------------------%>
<form name="editForm" method="post" onclick="setSaveButton();" onkeyup="setSaveButton();">
  <input type="hidden" name="Action" value="<%=(action.equals("new")?action:"save")%>"/>
  <input type="hidden" name="LabID" value="<%=sLabID%>"/>

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

  <%-- CODE --%>
  <tr>
    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labanalysis.cols.code",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditLabCode" class="text" value="<%=sEditLabCode%>" size="20" onblur="limitLength(this);">
      <input type="checkbox" id="LabCodeOther" value="1" name="LabCodeOther" <%=(sLabCodeOther.equals("1")?"checked":"")%>><%=getLabel("web.occup","labanalysis.labCodeOther",sWebLanguage,"LabCodeOther")%>
    </td>
  </tr>

  <%-- TYPE --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.type",sWebLanguage)%></td>
    <td class="admin2">
      <select name="LabType" class="text">
        <option value="0"></option>
        <option value="1" <%=(sLabType.equals("1")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.blood",sWebLanguage)%></option>
        <option value="2" <%=(sLabType.equals("2")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.urine",sWebLanguage)%></option>
        <option value="3" <%=(sLabType.equals("3")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.other",sWebLanguage)%></option>
        <option value="4" <%=(sLabType.equals("4")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.stool",sWebLanguage)%></option>
        <option value="5" <%=(sLabType.equals("5")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.sputum",sWebLanguage)%></option>
        <option value="6" <%=(sLabType.equals("6")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.smear",sWebLanguage)%></option>
        <option value="7" <%=(sLabType.equals("7")?"selected":"")%>><%=getTran("web.occup","labanalysis.type.liquid",sWebLanguage)%></option>
      </select>
    </td>
  </tr>

  <%-- NL --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.NL",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditNL" class="text" value="<%=sNL%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- FR --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.FR",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditFR" class="text" value="<%=sFR%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- MONSTER --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.monster",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditMonster" class="text" value="<%=sMonster%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- BIOMONITORING --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.biomonitoring",sWebLanguage)%></td>
    <td class="admin2">
      <input type="radio" onDblClick="uncheckRadio(this);hideBiomonOptions();" onClick="showBiomonOptions();" id="bioYes" name="EditBiomonitoring" value="1" <%=(sBiomonitoring.equals("1")?"checked":"")%>><%=getLabel("Web","yes",sWebLanguage,"bioYes")%>
      <input type="radio" onDblClick="uncheckRadio(this);" onClick="hideBiomonOptions();" id="bioNo"  name="EditBiomonitoring" value="0" <%=(sBiomonitoring.equals("0")?"checked":"")%>><%=getLabel("Web","no",sWebLanguage,"bioNo")%>
    </td>
  </tr>

  <%-- limitValue --%>
  <tr id="biomonOption1" style="display:none;">
    <td class="admin">&nbsp;-&nbsp;<%=getTran("Web.manage","labanalysis.cols.limitvalue",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditLimitValue" class="text" id="limitValue" value="<%=sLimitValue%>" size="10" onBlur="isNumber(this);">
    </td>
  </tr>

  <%-- shortTimeValue --%>
  <tr id="biomonOption2" style="display:none;">
    <td class="admin">&nbsp;-&nbsp;<%=getTran("Web.manage","labanalysis.cols.shorttimevalue",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditShortTimeValue" id="shortTimeValue" class="text" value="<%=sShortTimeValue%>" size="10" onBlur="isNumber(this);">
    </td>
  </tr>

  <script>
    editForm.EditLabCode.focus();

    <%
        if(sBiomonitoring.equals("1")){
            %>showBiomonOptions();<%
        }
    %>

    function showBiomonOptions(){
      document.getElementById("biomonOption1").style.display = "";
      document.getElementById("biomonOption2").style.display = "";
    }

    function hideBiomonOptions(){
      document.getElementById("limitValue").value = "";
      document.getElementById("shortTimeValue").value = "";

      document.getElementById("biomonOption1").style.display = "none";
      document.getElementById("biomonOption2").style.display = "none";
    }
  </script>

  <%-- MEDIDOC CODE --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.medidoccode",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditMedidoccode" class="text" value="<%=sMedidoccode%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- PRESTATION CODE --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.prestationcode",sWebLanguage)%></td>
    <td class="admin2">
      <input type="text" name="EditPrestationcode" class="text" value="<%=sPrestationCode%>" size="50" onblur="limitLength(this);">
    </td>
  </tr>

  <%-- COMMENT --%>
  <tr>
    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.comment",sWebLanguage)%></td>
    <td class="admin2">
      <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" cols="80" rows="2" name="EditComment"><%=sComment%></textarea>
    </td>
  </tr>
</table>

<script>
  editForm.EditLabCode.focus();
</script>

<%-- EDIT BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
<%
    //if((String)activeUser.accessRights.get("occupmanagelabanalysis.add")!=null ||
    //   (String)activeUser.accessRights.get("occupmanagelabanalysis.edit")!=null){
    %>
      <input class="button" type="button" name="SaveButton" value="<%=getTranNoLink("web","record",sWebLanguage)%>" onClick="checkSave();"/>&nbsp;
      <script>
        function checkSave(){
          if(editForm.EditLabCode.value.length == 0 || editForm.LabType.selectedIndex == 0 ||
             editForm.EditNL.value == "" || editForm.EditFR.value == ""){
                      alertDialog("web.manage","dataMissing");

                 if(editForm.EditLabCode.value.length == 0){ editForm.EditLabCode.focus(); }
            else if(editForm.LabType.selectedIndex == 0){ editForm.LabType.focus(); }
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
          <input class="button" type="button" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onClick="checkDelete();"/>&nbsp;
          <script>
            function checkDelete(){
              if(editForm.EditLabCode.value.length == 0){
                editForm.EditLabCode.focus();
              }
              else if(editForm.LabType.selectedIndex == 0){
                editForm.LabType.focus();
              }
              else{
                  if(yesnoDeleteDialog()){
                  editForm.Action.value = 'delete';
                  editForm.submit();
                }
              }
            }
          </script>
        <%
    }
%>
  <input class="button" type="button" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick="reset();">&nbsp;
  <input class="button" type="button" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="showOverview();">&nbsp;

  <br><br>

  <%-- link to labprofiles --%>
  <img src='<c:url value="/_img/themes/default/pijl.gif"/>'>
  <a  href="<c:url value='/main.do'/>?Page=healthrecord/manageLabProfiles_view.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.system-related-actions.manage-labProfiles",sWebLanguage)%></a>&nbsp;
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function showOverview(){
    window.location.href = '<c:url value="/main.do"/>?Page=healthrecord/manageLabAnalysis_view.jsp&ts=<%=getTs()%>';
  }
</script>

</form>
<%-- END EDIT FROM ------------------------------------------------------------------------------%>

        <%=writeJSButtons("editForm","document.getElementsByName('SaveButton')[0]")%>
        <%
    }
    oc_conn.close();
%>