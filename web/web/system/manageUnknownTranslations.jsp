<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("sa","",activeUser)%>

<%!
    //--- UPDATE UNKNOWN LABEL --------------------------------------------------------------------
    private boolean updateUnknownLabel(Connection conn, User user, String sLabelType, String sLabelID, String sLabelLang){
        boolean updated = false;

        try{
            String sSelect = "UPDATE OC_UNKNOWNLABELS"+
                             " SET OC_LABEL_UPDATUSERID = ?, OC_LABEL_UPDATETIME = ?"+
                             " WHERE OC_LABEL_TYPE = ? AND OC_LABEL_ID = ? AND OC_LABEL_LANGUAGE = ?";
            PreparedStatement ps = conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(user.userid));
            ps.setTimestamp(2,getSQLTime()); // NOW
            ps.setString(3,sLabelType.toLowerCase());
            ps.setString(4,sLabelID.toLowerCase());
            ps.setString(5,sLabelLang.toLowerCase());

            ps.executeUpdate();
            if(ps!=null) ps.close();
            updated = true;
        }
        catch(Exception e){
            if(Debug.enabled) Debug.println(e.getMessage());
        }

        return updated;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // get data from form
    String sEditLabelType = checkString(request.getParameter("EditLabelType")).toLowerCase(),
           sEditLabelID   = checkString(request.getParameter("EditLabelID")).toLowerCase(),
           sEditLabelLang = checkString(request.getParameter("EditLabelLang")).toLowerCase();

    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

    //--- DELETE ----------------------------------------------------------------------------------
    if(sAction.equals("delete")){
        try{
            String sSelect = "DELETE FROM OC_UNKNOWNLABELS"+
                             " WHERE OC_LABEL_TYPE = ? AND OC_LABEL_ID = ? AND OC_LABEL_LANGUAGE = ?";
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sEditLabelType);
            ps.setString(2,sEditLabelID);
            ps.setString(3,sEditLabelLang);

            ps.executeUpdate();
            if(ps!=null) ps.close();
        }
        catch(Exception e){
            if(Debug.enabled) Debug.println(e.getMessage());
        }
    }
%>

<form name="transactionForm" method="post">
    <table width='100%' cellspacing="0" cellpadding="1" class="list">
        <%-- TITLE --%>
        <tr>
            <td colspan="4"><%=writeTableHeader("Web.manage","UnknownLabels",sWebLanguage," doBack();")%></td>
        </tr>

        <%
            String sTmpLabelType, sTmpLabelID, sTmpLabelLang, sClass = "";
            PreparedStatement ps, controlPs;
            ResultSet controlRs = null;
            boolean labelExists = false;
            int iTotal = 0;

            String sSelect = "SELECT OC_LABEL_TYPE, OC_LABEL_ID, OC_LABEL_LANGUAGE"+
                             " FROM OC_UNKNOWNLABELS"+
                             " ORDER BY OC_LABEL_TYPE, OC_LABEL_ID";
            ps = oc_conn.prepareStatement(sSelect);
            ResultSet rs = ps.executeQuery();

            while(rs.next()){
                sTmpLabelType = checkString(rs.getString("OC_LABEL_TYPE"));
                sTmpLabelID   = checkString(rs.getString("OC_LABEL_ID"));
                sTmpLabelLang = checkString(rs.getString("OC_LABEL_LANGUAGE"));

                // check if translation exists
                if(sAction.equals("control")){
                    sSelect = "SELECT OC_LABEL_TYPE FROM OC_UNKNOWNLABELS"+
                              " WHERE "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_TYPE")+" = ?"+
                              "   AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_ID")+" = ?"+
                              "   AND "+MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" = ?";

                    controlPs = oc_conn.prepareStatement(sSelect);
                    controlPs.setString(1,sTmpLabelType.toLowerCase());
                    controlPs.setString(2,sTmpLabelID.toLowerCase());
                    controlPs.setString(3,sTmpLabelLang.toLowerCase());
                    controlRs = controlPs.executeQuery();

                    if(controlRs.next()){
                        labelExists = checkString(controlRs.getString("labeltype")).length() > 0;
                    }

                    if(controlRs!=null) controlRs.close();
                    if(controlPs!=null) controlPs.close();

                    if(labelExists){
                        updateUnknownLabel(oc_conn,activeUser,sTmpLabelType,sTmpLabelID,sTmpLabelLang);
                    }
                }

                // display labels
                if(!labelExists){
                    iTotal ++;

                    // alternate row styles
                    if (sClass.equals("")) sClass = "1";
                    else                   sClass = "";

                    sTmpLabelID = sTmpLabelID.replaceAll("\r\n"," ");
                    %>
                        <tr class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';">
                            <td width="8%">
                                <input type="button" class="button" onclick="deleteLabel('<%=sTmpLabelType%>','<%=sTmpLabelID%>','<%=sTmpLabelLang%>');" value="<%=getTran("Web","Delete",sWebLanguage)%>">
                            </td>
                            <td width="30%">
                                <a href="<c:url value="/main.do"/>?Page=system/manageTranslations.jsp&EditLabelType=<%=sTmpLabelType%>&EditLabelID=<%=sTmpLabelID%>&EditLabelLang=<%=sTmpLabelLang%>"><%=sTmpLabelType%></a>
                            </td>
                            <td width="*"><%=sTmpLabelID%></td>
                            <td width="5%"><%=sTmpLabelLang%></td>
                        </tr>
                    <%
                }
            }

            // close DB-stuff
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
            oc_conn.close();
        %>

        <%-- spacer --%>
        <tr height="1">
            <td width="<%=sTDAdminWidth%>"></td>
        </tr>
    </table>

    <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iTotal%>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input type="button" name="ButtonControl" class="button" value="<%=getTran("Web.Manage","ControlUnknownTranslations",sWebLanguage)%>" onclick="controlLabels();">
        <input type="button" name="ButtonBack" class="button" value="<%=getTran("web","back",sWebLanguage)%>" onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>

    <%-- hidden fields --%>
    <input type="hidden" name="EditLabelType">
    <input type="hidden" name="EditLabelID">
    <input type="hidden" name="EditLabelLang">
    <input type="hidden" name="Action">

    <script>
      function deleteLabel(sLabelType, sLabelID, sLabelLang){
        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var answer = window.showModalDialog(popupUrl,'',modalities);

        if(answer==1){
          transactionForm.EditLabelType.value = sLabelType;
          transactionForm.EditLabelID.value = sLabelID;
          transactionForm.EditLabelLang.value = sLabelLang;
          transactionForm.Action.value = "delete";

          transactionForm.submit();
        }
      }

      function controlLabels(){
        transactionForm.Action.value = "control";
        transactionForm.submit();
      }

      function doBack(){
        window.location.href = '<c:url value="/main.do"/>?Page=system/menu.jsp';
      }
    </script>
</form>
