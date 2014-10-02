<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Screen,
                be.openclinic.system.TransactionItem,
                be.openclinic.system.ScreenTransactionItem"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- DISPLAY ITEM ----------------------------------------------------------------------------
    private String displayItem(ScreenTransactionItem item, String sWebLanguage, int itemIdx){
        Debug.println("\n****************************** displayItem **********************************");
        Debug.println("item    : "+item.getItemTypeId());
        Debug.println("itemIdx : "+itemIdx);
        
        // alternate row-style
        String sClass = "";
        if(itemIdx%2==0) sClass = "1";
        
        String sHtml = "<tr class='list"+sClass+"' id='row_"+itemIdx+"'>";
        
        // delete- and edit-icon
        sHtml+= "<td>"+
                 "<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' name='Item_"+item.getItemTypeId()+"'"+
                  " alt='"+getTranNoLink("web","delete",sWebLanguage)+"'"+
                  " onClick=\"deleteItem('row_"+itemIdx+"')\">&nbsp;"+
                 "<img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' class='link' style='vertical-align:-3px' name='Item_"+item.getItemTypeId()+"'"+
                  " alt='"+getTranNoLink("web","edit",sWebLanguage)+"'"+
                  " onClick=\"editItem('row_"+itemIdx+"')\">"+
                "</td>";

        // itemTypeId
        sHtml+= "<td>"+item.getItemTypeId()+"</td>";

        // htmlElement
        sHtml+= "<td>"+item.getHtmlElement()+"</td>";

        // size
        sHtml+= "<td>"+item.getAttribute("Attr_size")+"</td>";

        // defaultValue
        sHtml+= "<td>"+item.getDefaultValue()+"</td>";
           
        // required
        String sRequired = item.getAttribute("Attr_required");
        if(sRequired.length()==0) sRequired = "false";
        sHtml+= "<td>"+(sRequired.equals("true")?"<img src='"+sCONTEXTPATH+"/_img/check.gif' alt='true'>":"<img src='"+sCONTEXTPATH+"/_img/uncheck.gif' alt='false'>")+"</td>";

        // followedBy
        sHtml+= "<td>"+item.getAttribute("Attr_followedBy")+"</td>";
           
        // empty cell
        sHtml+= "<td></td>";
        
        sHtml+= "</tr>";
        
        if(Debug.enabled){
            System.out.println("\n"+sHtml+"\n");
        }
        
        return sHtml;
    }

	//--- GET PRINT-LABELS HTML -------------------------------------------------------------------
	private String getPrintlabelsHtml(String sWebLanguage){
	    String sHtml = "<table class='list' id='printlabelsTable' cellpadding='0' cellspacing='1'>";
	    
		// supported languages
		String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
		if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
		supportedLanguages = supportedLanguages.toLowerCase();
		
		// print language selector
		StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
		String tmpLang, sValue = "";
		
		while(tokenizer.hasMoreTokens()){
	    	tmpLang = tokenizer.nextToken().toUpperCase();
	     	    	
	        sHtml+= "<tr>"+
	                 "<td width='30' class='admin'>"+tmpLang+"</td>"+
	                 "<td>"+
	                  "<input type='text' size='30' maxLength='50' name='printLabel_"+tmpLang+"' id='printLabel_"+tmpLang+"' value=''/>"+
	                 "</td>"+
	                "</tr>";
	    }
	    
		sHtml+= "</table>";
		
		sHtml+= "<i>"+getTran("web.manage","printlabelsInfo",sWebLanguage)+"</i>";
		
	    return sHtml;
	}
%>

<%
    String sCellID = checkString(request.getParameter("CellID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############## system/ajax/screenDesigner/editCell.jsp #################");
        Debug.println("sCellID : "+sCellID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
          
    Screen screen = (Screen)session.getAttribute("screen");    
    Hashtable cell = screen.getCell(sCellID);    
%>

<form name="cellForm" method="post">
    <input type="hidden" name="EditTranTypeId" value="<%=screen.getTransactionType()%>">
    <input type="hidden" name="activeRowId" value="">
    <input type="hidden" name="activeCellId" value="<%=sCellID%>">

    <table cellpadding="0" cellspacing="1" class="list" width="98%">
        <%-- width --%>
        <tr>
            <td class="admin" width="80"><%=getTran("web","width",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="EditWidth" value="<%=screen.getCellAttribute(cell,"width")%>" size="4" maxLength="3"
                 onBlur="if(this.value.length>0 && !isNumberLimited(this,100,500)){alertDialogDirectText('<%=getTranNoLink("web.occup","out-of-bounds-value",sWebLanguage)%> (100~500px)');this.focus();}"> px
            </td>
        </tr>
        
        <%-- colspan --%>
        <tr>
            <td class="admin"><%=getTran("web","colspan",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="EditColspan" value="<%=screen.getCellAttribute(cell,"colspan")%>" size="4" maxLength="2"
                 onBlur="if(this.value.length>0 && !isNumberLimited(this,1,10)){alertDialogDirectText('<%=getTranNoLink("web.occup","out-of-bounds-value",sWebLanguage)%> (1~10)');this.focus();}">
             </td>
        </tr>
        
        <%-- class/style --%>
        <tr>
            <td class="admin"><%=getTran("web","style",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" style="padding:5px">
                <input type="hidden" name="EditClass" value="<%=screen.getCellAttribute(cell,"class")%>">
                
                <table cellpadding="0" cellspacing="1">
                    <tr>
                        <td width="50" class="admin" id="classSelector1" onClick="selectClass(this.id,'admin');" style="cursor:hand;border:1px solid #ccc">admin</td>
                        <td width="50" class="admin2" id="classSelector2" onClick="selectClass(this.id,'admin2');" style="cursor:hand;border:1px solid #ccc">admin2</td>
                    </tr>
                </table>
             </td>
        </tr>
                
        <%
            String sClass = screen.getCellAttribute(cell,"class"); 
            if(sClass.length() > 0){
            	if(sClass.equals("admin")){
            		%><script>document.getElementById("classSelector1").style.border = "1px solid red";</script><%
            	}
            	else if(sClass.equals("admin2")){
            		%><script>document.getElementById("classSelector2").style.border = "1px solid red";</script><%
            	} 
            }
        %>
        
        <%-- LIST ITEMS --%>
        <tr>
            <td class="admin"><%=getTran("web","items",sWebLanguage)%></td>
            <td class="admin2" style="padding:5px;">
                <table id="itemsTable" width="100%" cellpadding="0" cellspacing="1" class="list">
                    <%-- header --%>
                    <tr class="admin" style="padding-left:5px;">
                        <td width="50">&nbsp;</td>
                        <td width="200">itemTypeId / labelId&nbsp;*&nbsp;</td>
                        <td width="120"><%=getTranNoLink("web.manage","htmlElement",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td width="50"><%=getTranNoLink("web.manage","size",sWebLanguage)%></td>
                        <td width="150">defaultValue / label</td>
                        <td width="100"><%=getTranNoLink("web.manage","required",sWebLanguage)%></td>
                        <td width="100"><%=getTranNoLink("web.manage","followedBy",sWebLanguage)%></td>
                        <td width="150">&nbsp;</td>
                    </tr>
                    
                    <%-- add-row --%>
                    <tr>
                        <td class="admin">&nbsp;</td>
                        
                        <%-- itemTypeId (name) --%>
                        <td class="admin">
                            <input type="text" class="text" name="addItemTypeId" value="" size="30">
                        </td>
                        
                        <%-- htmlElement --%>
                        <td class="admin">
                            <select class="text" name="addHtmlElement" onChange="setAddRowOptions(this);">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <option value="label">label</option>
                                <option value="text">text</option>
                                <option value="date">date</option>
                                <option value="integer">integer</option>
                                <option value="select">select</option>
                                <option value="textArea">textArea</option>
                                <option value="radio">radio</option>
                                <option value="checkBox">checkBox</option>
                            </select>
                        </td>
                        
                        <%-- size --%>
                        <td class="admin">
                            <input type="text" class="text" name="addSize" value="" size="3" maxLength="3" onBlur="checkIntegerField(this);">
                        </td>
                        
                        <%-- defaultValue --%>
                        <td class="admin">
                            <input type="text" class="text" name="addDefaultValue" value="" size="20" maxLength="50">
                        </td>
                        
                        <%-- required --%>
                        <td class="admin">
                            <input type="checkbox" name="addRequired" value="true">
                        </td>
                        
				        <%-- followedBy --%>
                        <td class="admin">
			                <select class="text" name="addFollowedBy">
			                    <option value="nothing"><%=getTranNoLink("web.manage","nothing",sWebLanguage)%></option>
			                    <option value="newline"><%=getTranNoLink("web.manage","newLine",sWebLanguage)%></option>
			                    <option value="space"><%=getTranNoLink("web.manage","space",sWebLanguage)%></option>
			                </select>
			             </td>
				                        
                        <%-- BUTTONS --%>
                        <td class="admin">
                            <input type="button" name="addButton" class="button" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onClick="addItem();">
                            <input type="button" name="UpdateButton" class="button" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateItem();" disabled>
                        </td>
                    </tr>
                    
                    <%
	                    LinkedHashMap items = (LinkedHashMap)cell.get("Items");
	                    if(items==null) items = new LinkedHashMap();
	                    Debug.println("items in cell '"+sCellID+"' : "+items.size());
                    
                        Iterator itemIter = items.keySet().iterator();
                        ScreenTransactionItem item;
                        int itemIdx = 0;
                        String key;
                        
                        while(itemIter.hasNext()){
                            key = (String)itemIter.next();
                            item = (ScreenTransactionItem)items.get(key);   
                            
                            out.println(displayItem(item,sWebLanguage,itemIdx++));
                            %><script>rowIdx++;</script><%
                        }
                    %>
                </table>
                
                <font color="#999999"><%=getTran("web.manage","customExamCellEditInfo",sWebLanguage).replaceAll("\r\n","<br/>")%></font>
            </td>
        </tr>
        
        <%-- PRINT-LABELS --%>
        <tr id="printlabelsDiv" style="display:none">
            <td class="admin"><%=getTranNoLink("web","printLabels",sWebLanguage)%></td>
            <td class="admin2" style="padding:5px;">
                <%=getPrintlabelsHtml(sWebLanguage)%>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type="button" name="saveButton" class="button" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onClick="storeCell('<%=sCellID%>');">&nbsp;
            <input type="button" name="closeButton" class="button" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onClick="closeEditScreen();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
</form>

<script>
  <%-- copy state of form at load --%>
  registerFormState(cellForm);
</script>

<%-- Ajax loader --------------------------------------------------------------------------------%>
<center>
    <div id="ajaxLoader" style="position:absolute;top:100px;left:280px;visibility:hidden;width:280px;height:40px;border:1px solid #ccc;background:#eee;padding:30px;">
        <center><img src="<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif" style="vertical-align:-3px;"/>&nbsp;&nbsp;Loading..</center>
    </div>
</center>