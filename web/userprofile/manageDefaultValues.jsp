<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sItemTypeAttributeId = checkString(request.getParameter("ItemTypeAttributeId"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************ userprofile/manageDefaultValues.jsp *************");
        Debug.println("sAction   : "+sAction); 
        Debug.println("sItemTypeAttributeId : "+sItemTypeAttributeId+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";

    //--- DELETE ----------------------------------------------------------------------------------
    if(sAction.equals("delete")){
    	Connection conn = null;
        PreparedStatement ps = null;
        
        try{
            String sSql = "DELETE FROM ItemTypeAttributes"+
                          " WHERE itemTypeAttributeId = ?";
            conn = MedwanQuery.getInstance().getOpenclinicConnection();
            ps = conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sItemTypeAttributeId));
            ps.execute();

            sMsg = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
    }
%>

<style>
 .padded {
  padding: 5px;
 }
</style>

<form id="transactionForm" name="transactionForm" method="post">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ItemTypeAttributeId" value="">

    <%-- TITLE --%>
    <%=writeTableHeader("web.userProfile","manageDefaultValues",sWebLanguage," doBack();")%>

    <%
        int counter = 0;

        // get default values for active user
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try{
            String sSql = "SELECT itemTypeAttributeId, itemType, value, updatetime"+
                          " FROM ItemTypeAttributes"+
                          "  WHERE name = 'DefaultValue'"+
                          "   AND userid = ?"+
                          " ORDER BY itemType DESC";
            conn = MedwanQuery.getInstance().getOpenclinicConnection();
            ps = conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(activeUser.userid));
            rs = ps.executeQuery();

            int itemTypeAttributeId;
            String sItemType, sItemValue, sItemTran, sClass = "";
            String sItemValueTran;
            java.util.Date dUpdateTime;
            
            if(rs.next()){
            	%>
                    <table class="sortable" id="searchresults" width="100%" cellspacing="1" cellpadding="0" style="border:1px solid #ccc;">
                
	                <%-- HEADER --%>
	                <tr class="gray">
	                    <td width="20"></td>  
	                    <td width="200"><%=getTran("web","name",sWebLanguage)%></td>
	                    <td width="*"><%=getTran("web","value",sWebLanguage)%></td>
	                    <td width="100"><%=getTran("web","updateTime",sWebLanguage)%></td>
	                </tr>
                <%
                
                rs.beforeFirst(); // rewind
            }
            
            while(rs.next()){
                counter++;

                itemTypeAttributeId = rs.getInt("itemTypeAttributeId");
                sItemType   = checkString(rs.getString("itemType"));
                sItemValue  = checkString(rs.getString("value"));
                dUpdateTime = rs.getTimestamp("updatetime");

                // try to translate item-name (field-name)
                if(activeUser.isAdmin()){
                    // show link when admin
                    sItemTran = getTran("web.occup",sItemType,sWebLanguage);
                }
                else{
                    sItemTran = getTranNoLink("web.occup",sItemType,sWebLanguage);                  	
                }

                // try to translate itemvalue too
                if(sItemValue.length() > 0){
                	// try "web.occup"
                	sItemValueTran = getTranNoLink("web.occup",sItemValue,sWebLanguage);
                    if(sItemValueTran.equalsIgnoreCase(sItemValue)){
                 	    // try "web"
                 	    sItemValueTran = getTranNoLink("web",sItemValue,sWebLanguage);
                    }
                 
                    if(sItemValueTran.length() > 0){
                 	    sItemValue = sItemValueTran;
                    }
                }      
                
                if(!activeUser.isAdmin()){
                    // shorten itemname when no admin (otherwise link is shown)
                    if(sItemTran.startsWith(ScreenHelper.ITEM_PREFIX)){
                        sItemTran = "<i>"+sItemTran.substring(ScreenHelper.ITEM_PREFIX.length())+"</i>";
                    }
                }
                
                // alternate row-style
                if(sClass.length()==0) sClass = "1";
                else                   sClass = "";

                %>
                    <tr height="18" class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';">
                        <td align="center">
                            <img src="<c:url value='/_img/icons/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("web","delete",sWebLanguage)%>" onClick="deleteDefaultValue('<%=itemTypeAttributeId%>');">
                        </td>
                        <td class="padded"><%=sItemTran%></td>
                        <td class="padded"><%=sItemValue%></td>
                        <td class="padded"><%=(dUpdateTime==null?"":ScreenHelper.fullDateFormat.format(dUpdateTime))%></td>
                    </tr>
                <%
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        
        // records found message
        if(counter > 0){            
            %>
	            </table>
	            <%=counter%> <%=getTran("web","recordsFound",sWebLanguage)%>
            <%
        }
        else{
          %><%=getTran("web","noRecordsFound",sWebLanguage)%><%
        }

        // action message
        if(sMsg.length() > 0){
            %><br><%=sMsg%><%
        }
    %>

	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <input type="button" name="backButton" class="button" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();">
	<%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  <%-- DELETE DEFAULT VALUE --%>
  function deleteDefaultValue(itemTypeAttributeId){
    if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.Action.value = "delete";
      transactionForm.ItemTypeAttributeId.value = itemTypeAttributeId;
      transactionForm.backButton.disabled = true;  
      transactionForm.submit();
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.jsp'/>?Page=userprofile/index.jsp";
  }
</script>