<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- GET NEW COUNTER VALUE --------------------------------------------------------------------
    public String getNewCounterValue(String sCounterName, Connection OccupdbConnection){
        String sValue = "";

        try{
            String sSelect = "SELECT counter+1 AS NewValue FROM counters WHERE name = ?";
            PreparedStatement ps = OccupdbConnection.prepareStatement(sSelect);
            ps.setString(1,sCounterName);

            ResultSet Occuprs = ps.executeQuery();
            if(Occuprs.next()){
                sValue = Occuprs.getString("NewValue");
                Occuprs.close();
                ps.close();

                sSelect = "UPDATE counters SET counter = (counter + 1) WHERE name = ?";
                ps = OccupdbConnection.prepareStatement(sSelect);
                ps.setString(1,sCounterName);
                ps.executeUpdate();
                ps.close();
            }
            else{
                ps.close();
                sValue = "1";

                sSelect = "SELECT max(rowid) + 1 AS MaxID FROM AgeGenderControl";
                Occuprs.close();
                ps.close();
                ps = OccupdbConnection.prepareStatement(sSelect);
                Occuprs = ps.executeQuery();
                if (Occuprs.next()) {
                    sValue = checkString(Occuprs.getString("MaxID"));
                }

                if(sValue.length() == 0) sValue = "1";

                sSelect = "INSERT INTO counters(name, counter) VALUES (?,?)";
                Occuprs.close();
                ps.close();
                ps = OccupdbConnection.prepareStatement(sSelect);
                ps.setString(1,sCounterName);
                ps.setString(2,sValue);
                ps.executeUpdate();
                ps.close();
            }
        }
        catch(SQLException e) {
            e.printStackTrace();
        }

        return checkString(sValue);
    }

    //--- STRINGVALUE TO INT -----------------------------------------------------------------------
    public int stringValueToInt(String sValue){
        int iReturn = 0;
        if (sValue.trim().length() > 0) {
            try{
                iReturn = Integer.parseInt(sValue);
            }
            catch (Exception e) {
                iReturn = 0;
            }
        }

        return iReturn;
    }
    public float stringValueToFloat(String sValue){
        float iReturn = 0;
        if (sValue.trim().length() > 0) {
            try{
                iReturn = Float.parseFloat(sValue);
            }
            catch (Exception e) {
                iReturn = 0;
            }
        }

        return iReturn;
    }
    public double stringValueToDouble(String sValue){
        double iReturn = 0;
        if (sValue.trim().length() > 0) {
            try{
                iReturn = Double.parseDouble(sValue);
            }
            catch (Exception e) {
                iReturn = 0;
            }
        }

        return iReturn;
    }
%>
<body onload="window.resizeTo(650,300).moveTo((screen.width-650)/2,(screen.height-300)/2);"/>
<%
    String sType = checkString(request.getParameter("Type")),
           sID   = checkString(request.getParameter("ID"));
    Connection OccupdbConnection = MedwanQuery.getInstance().getOpenclinicConnection();
    PreparedStatement ps;
    ResultSet Occuprs;
    String sSelect;

    //--- ADD --------------------------------------------------------------------------------------
    if (checkString(request.getParameter("Action")).equals("Add")){
         double iEditMaxAge = stringValueToDouble(checkString(request.getParameter("EditMaxAge"))),
             iEditMinAge = stringValueToDouble(checkString(request.getParameter("EditMinAge")));
         double iEditFreq   = stringValueToDouble(checkString(request.getParameter("EditFreq"))),
             iEditTol    = stringValueToDouble(checkString(request.getParameter("EditTol")));
         String sEditGender = checkString(request.getParameter("EditGender"));
         String sRowID = getNewCounterValue("AgeGenderControlID", OccupdbConnection);

         sSelect = "INSERT INTO AgeGenderControl (rowid, id, type, minage, maxage, gender, frequency, tolerance)"+
                   " VALUES (?,?,?,?,?,?,?,?)";

         ps = OccupdbConnection.prepareStatement(sSelect);
         ps.setInt(1,Integer.parseInt(sRowID));
         ps.setInt(2,Integer.parseInt(sID));
         ps.setString(3,sType);
         ps.setDouble(4,iEditMinAge);
         ps.setDouble(5,iEditMaxAge);
         ps.setString(6,sEditGender);
         ps.setDouble(7,iEditFreq);
         ps.setDouble(8,iEditTol);
         ps.executeUpdate();
         ps.close();
    }
    //--- DELETE -----------------------------------------------------------------------------------
    else if (checkString(request.getParameter("Action")).equals("Delete")){
        ps = OccupdbConnection.prepareStatement("DELETE FROM AgeGenderControl WHERE rowid = ?");
        ps.setInt(1,Integer.parseInt(checkString(request.getParameter("RecordID"))));
        ps.executeUpdate();
        ps.close();
    }

    if(sType.equalsIgnoreCase("RiskExaminations")){
        int ageGenderControl = 0;
        ps = OccupdbConnection.prepareStatement("SELECT * FROM AgeGenderControl WHERE id = ?");
        ps.setInt(1,Integer.parseInt(sID));
        ResultSet rs = ps.executeQuery();
        if (rs.next()){
            ageGenderControl = 1;
        }
        rs.close();
        ps.close();

        ps = OccupdbConnection.prepareStatement("UPDATE RiskExaminations SET ageGenderControl=? WHERE riskExaminationId=?");
        ps.setString(1,""+ageGenderControl);
        ps.setInt(2,Integer.parseInt(sID));
        ps.execute();
        ps.close();
    }
%>
<form name="AGCForm" method="post" onkeydown="if(enterEvent(event,13)){doAdd();}">
<input type="hidden" name="PopupHeight" value="<%=checkString(request.getParameter("PopupHeight"))%>">
<input type="hidden" name="PopupWidth" value="<%=checkString(request.getParameter("PopupWidth"))%>">
    <input type="hidden" name="Action"/>
    <input type="hidden" name="RecordID"/>

    <table width="100%" class="menu" cellspacing="0">
        <%-- HEADER --%>
        <tr class="admin">
            <td width="25" nowrap>&nbsp;</td>
            <td width="100" nowrap>Min <%=getTran("Web.Occup","medwan.recruitment.sce.age",sWebLanguage)%></td>
            <td width="100" nowrap>Max <%=getTran("Web.Occup","medwan.recruitment.sce.age",sWebLanguage)%></td>
            <td width="100" nowrap><%=getTran("Web","Gender",sWebLanguage)%></td>
            <td width="100" nowrap><%=getTran("web","minimum",sWebLanguage)%></td>
            <td width="100" nowrap><%=getTran("web","maximum",sWebLanguage)%></td>
            <td width="*">&nbsp;</td>
        </tr>

        <%-- ADD ROW --%>
        <tr>
            <td>&nbsp;</td>
            <td><input type="text" class="text" name="EditMinAge" id="EditMinAge" size="5" onBlur="isNumber(this);"></td>
            <td><input type="text" class="text" name="EditMaxAge" size="5" onBlur="isNumber(this);"></td>
            <td>
                <select class="text" name="EditGender">
                    <option/>
                    <option value="M"><%=getTran("Web.occup","Male",sWebLanguage)%></option>
                    <option value="F"><%=getTran("Web.occup","female",sWebLanguage)%></option>
                    <option value="MF">MF</option>
                </select>
            </td>
            <td><input type="text" class="text" name="EditFreq" size="5" onBlur="isNumber(this);"></td>
            <td><input type="text" class="text" name="EditTol" size="5" onBlur="isNumber(this);"></td>
            <td align="right">&nbsp;
                <input class="button" type="button" name="addButton" value="<%=getTran("Web","add",sWebLanguage)%>" onClick="doAdd();"/>
            </td>
        </tr>
    </table>

    <br>

    <table width="100%" class="menu" id="AGCTable" cellspacing="0">
        <%-- HEADER --%>
        <tr class="admin">
            <td width="25" nowrap>&nbsp;</td>
            <td width="100" nowrap>Min <%=getTran("Web.Occup","medwan.recruitment.sce.age",sWebLanguage)%></td>
            <td width="100" nowrap>Max <%=getTran("Web.Occup","medwan.recruitment.sce.age",sWebLanguage)%></td>
            <td width="100" nowrap><%=getTran("Web","Gender",sWebLanguage)%></td>
            <td width="100" nowrap><%=getTran("web","minimum",sWebLanguage)%></td>
            <td width="100" nowrap><%=getTran("web","maximum",sWebLanguage)%></td>
            <td width="*">&nbsp;</td>
        </tr>

        <%
            // display added AGCs
            if(sID.length() > 0 && sType.length() > 0){
                sSelect = "SELECT * FROM AgeGenderControl WHERE id = ? AND type = ? order by gender,minage";
                ps = OccupdbConnection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sID));
                ps.setString(2,sType);
                Occuprs = ps.executeQuery();

                String sClass = "";
                while(Occuprs.next()){
                    // alternate row-style
                    if(sClass.equals("")) sClass = "1";
                    else                  sClass = "";

                    %>
                        <input type="hidden" name="" value="<%=checkString(Occuprs.getString("id"))%>">
                        <tr class="list<%=sClass%>">
                            <td width="25"><a href="#"><img src="<%=sCONTEXTPATH%>/_img/icon_delete.gif" border="0" alt="<%=getTran("web","delete",sWebLanguage)%>" onClick="askDelete('<%=checkString(Occuprs.getString("rowid"))%>');"></a></td>
                            <td><%=checkString(Occuprs.getString("minage"))%></td>
                            <td><%=checkString(Occuprs.getString("maxage"))%></td>
                            <td>
                                <%
                                    String sGender = checkString(Occuprs.getString("gender"));
                                    if(sGender.equalsIgnoreCase("m")){
                                        %><%=getTran("Web.occup","Male",sWebLanguage)%><%
                                    }
                                    else if(sGender.equalsIgnoreCase("f")){
                                        %><%=getTran("Web.occup","Female",sWebLanguage)%><%
                                    }
                                    else{
                                        %><%=sGender%><%
                                    }
                                %>
                            </td>
                            <td><%=Occuprs.getFloat("frequency")%></td>
                            <td><%=Occuprs.getFloat("tolerance")%></td>
                            <td>&nbsp;</td>
                        </tr>
                    <%
                }

                Occuprs.close();
                ps.close();
            }
        OccupdbConnection.close();
        %>
    </table>

    <%-- CLOSE BUTTON --%>
    <div style="padding-top:10px;text-align:right;">
        <input class="button" type="button" name="closeButton" onClick="window.close();" value="<%=getTran("Web","close",sWebLanguage)%>"/>
    </div>

    <%-- hidden fields --%>
    <input type="hidden" name="Type" value="<%=sType%>">
    <input type="hidden" name="ID" value="<%=sID%>">
</form>

<script>
  AGCForm.EditMinAge.focus();

  <%-- DO ADD --%>
  function doAdd(){
    if(AGCForm.EditMinAge.value.length > 0 || AGCForm.EditMaxAge.value.length > 0 ||
       AGCForm.EditFreq.value.length > 0 || AGCForm.EditTol.value.length > 0 || AGCForm.EditGender.selectedIndex > 0){
      AGCForm.Action.value = "Add";
      AGCForm.addButton.disabled = true;
      AGCForm.submit();
    }
    else{
      AGCForm.EditMinAge.focus();
    }
  }

  <%-- ASK DELETE --%>
  function askDelete(sID){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete&PopupHeight=300&PopupWidth=600";
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    if(answer==1){
      AGCForm.Action.value = "Delete";
      AGCForm.RecordID.value = sID;
      AGCForm.submit();
    }
  }

    window.setTimeout("document.getElementById('EditMinAge').focus()",200);
</script>
