<%@page import="java.util.*,
                be.openclinic.system.Screen,
                be.openclinic.system.TransactionItem,
                be.openclinic.system.ScreenTransactionItem"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE%>
<%=sJSDATE%>

<%=checkPermission("occup.customexamination","select",activeUser)%>

<%!
    //--- ROW CONTAINS ITEMS ----------------------------------------------------------------------
    private boolean rowContainsItems(Hashtable row){
        boolean allCellsAreEmpty = false;
        Vector cells = (Vector)row.get("Cells");
        
        if(cells==null || cells.size()==0){
            allCellsAreEmpty = true;
        }	
        else{
        	// contains cells (which may be empty)
        	// --> check cells
        	Hashtable cell = null;
        	LinkedHashMap items;
        	allCellsAreEmpty = true;
        	
            for(int i=0; i<cells.size() && allCellsAreEmpty==true; i++){
            	cell = (Hashtable)cells.get(i);

            	if(cell!=null){
	                items = (LinkedHashMap)cell.get("Items");
	                
	                if(items!=null){
		            	if(items.size() > 0){
		            		allCellsAreEmpty = false;
		            	}
	                }
            	}
            }
        }

        return !allCellsAreEmpty;
    }

    //--- DISPLAY SCREEN --------------------------------------------------------------------------
    private String displayScreen(Screen screen, TransactionVO transaction, String sWebLanguage){
        String sNewLineChar = "\n";
        StringBuffer sHtml = new StringBuffer();

        Debug.println("\n################## transaction ("+transaction.getServerId()+"."+transaction.getTransactionId()+") ################");
                
        sHtml.append("<table class='list' style='border-top:none;' cellpadding='0' cellspacing='1' width='100%'>")
             .append(sNewLineChar);

        Hashtable row, cell, prevCell;
        Iterator rowAttrKeyIter;
        Enumeration cellAttrEnum;
        String sJS = "<script>";
        
        for(int r=0; r<screen.getRows().size(); r++){
            row = (Hashtable)screen.getRows().get(r);
            if(!rowContainsItems(row)){
            	continue;
            }
            
            sHtml.append("<tr");
        
            // sort attributes
            Vector rowAttrKeys = new Vector(row.keySet());
            Collections.sort(rowAttrKeys);
            rowAttrKeyIter = rowAttrKeys.iterator(); 
            
            //***** 1 - tr-attributes *****
            String key;
            while(rowAttrKeyIter.hasNext()){
                key = (String)rowAttrKeyIter.next();
                
                if(key.startsWith("Attr_")){
                    Debug.println("row attributes ("+r+") key : "+key+" = "+ScreenHelper.checkString((String)row.get(key)));
                    sHtml.append(""+key.substring(key.indexOf("_")+1)+"='"+(String)row.get(key)+"'");
                }
            }
            
            sHtml.append(">"+sNewLineChar);
            
            //***** 2 - cells *****
            prevCell = null;
            Vector cells = (Vector)row.get("Cells");
            Iterator cellIter = cells.iterator(); 
            String sCellId;
            
            while(cellIter.hasNext()){
                cell = (Hashtable)cellIter.next();
                sCellId = screen.getCellAttribute(cell,"id");
                
                // skip cell when previous cell has colspan
                if(prevCell!=null && screen.getColspan(prevCell)>1){
                    continue;                    
                }             

                sHtml.append("<td ");
                
                //*** cell attributes *******************************
                cellAttrEnum = cell.keys();
                while(cellAttrEnum.hasMoreElements()){
                    key = (String)cellAttrEnum.nextElement();
                    
                    if(key.startsWith("Attr_")){
                        sHtml.append(""+key.substring(key.indexOf("_")+1)+"='"+ScreenHelper.checkString((String)cell.get(key))+"'");                                
                    }
                }
                
                sHtml.append(">");
                                
                //*** cell items ************************************
                LinkedHashMap items = (LinkedHashMap)cell.get("Items");
                if(items!=null){
                    Iterator itemIter = items.keySet().iterator();
                    ScreenTransactionItem screenItem;

                    if(items.keySet().size() > 0){
	                    while(itemIter.hasNext()){
	                        key = (String)itemIter.next();
	
	                        screenItem = (ScreenTransactionItem)items.get(key);
	                        if(screenItem!=null){	
		                        String sShortTranType = transaction.getTransactionType().substring(ScreenHelper.ITEM_PREFIX.length());
		                        
		                        ItemVO itemVO = ((ItemVO)transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CUSTOMEXAM_"+sCellId+"_"+screenItem.getItemTypeId()));
		                        if(itemVO!=null){
			                        Debug.println("ITEM "+ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CUSTOMEXAM_"+sCellId+"_"+screenItem.getItemTypeId()+" : "+itemVO.getItemId()); /////////  
	
		                        	String sValue = "";
		                        	if(transaction.isNew()) sValue = checkString(screenItem.getDefaultValue());
		                        	else               		sValue = itemVO.getValue();
			                        	
			                        //*** label *******************************
			                        if(screenItem.getHtmlElement().equals("label")){
			                            String sTran = screenItem.getDefaultValue(); // consider default value as label, if any
			                            if(screenItem.getDefaultValue().length()==0){
			                                sTran = ScreenHelper.getTran("web",screenItem.getItemTypeId(),sWebLanguage);
			                            }
			                            
			                            sTran = sTran.replaceAll("\"","");
			                            sTran = sTran.replaceAll("\\\"","'");
			                            sHtml.append(sTran); 
			                            
			                            /*
			                            // add hidden item to comply labels with the logic of items
			                            sHtml.append("<input type='hidden' id='item_"+screenItem.getItemTypeId()+"'")
			                                 .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("value='"+checkString(itemVO.getValue())+"'>");
			                            */
			                        }
			                        //*** text ********************************
			                        else if(screenItem.getHtmlElement().equals("text")){
			                            sHtml.append("<input type='text' class='text' "+setRightClick(sShortTranType))
			                            	 .append("id='item_"+screenItem.getItemTypeId()+"'")
			                                 .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("value='"+sValue+"'")
			                                 .append("size='"+screenItem.getAttribute("Attr_size","20")+"' maxLength='255'>");
			                        }
			                        //*** text:only-integer *******************
			                        else if(screenItem.getHtmlElement().equals("integer")){		                        	
			                            sHtml.append("<input type='text' class='text'")
			                                 .append("id='item_"+screenItem.getItemTypeId()+"'")
			                                 .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("value='"+sValue+"'")
			                                 .append("size='"+screenItem.getAttribute("Attr_size","20")+"' maxLength='255'")
			                                 .append("onBlur='checkIntegerField(this);'>");
			                        }
			                        //*** date ********************************
			                        else if(screenItem.getHtmlElement().equals("date")){
			                            sHtml.append("<input type='text' class='text' "+setRightClick(sShortTranType))
			                            	 .append("id='item_"+screenItem.getItemTypeId()+"'")
			                                 .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("value='"+sValue+"'")
			                                 .append("size='11' maxLength='10'")
			                                 .append("onblur='checkDate(this);'")
			                                 .append(">");
			                            
			                            sHtml.append("<script>writeMyDate('item_"+screenItem.getItemTypeId()+"');</script>");
			                        }
			                        //*** select ******************************
			                        else if(screenItem.getHtmlElement().equals("select")){	
			                            sHtml.append("<select class='text' id='item_"+screenItem.getItemTypeId()+"'")	
	    	                                  .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'>")	                           
			                                  .append("<option value='noChoiseMade'>").append(ScreenHelper.getTranNoLink("web","choose",sWebLanguage)).append("</option>")
			                                  .append(ScreenHelper.writeSelect("CUSTOMEXAMINATION"+screen.getExamId()+"."+screenItem.getItemTypeId(),sValue,sWebLanguage,false,false))
			                                 .append("</select>");
			                        }
			                        //*** textArea ****************************
			                        else if(screenItem.getHtmlElement().equals("textArea")){
			                            sHtml.append("<textArea rows='"+screenItem.getAttribute("Attr_rows","3")+"'");
	
			                            String sSize = screenItem.getAttribute("Attr_size");
			                            if(sSize.length() > 0){
			                                sHtml.append("cols='"+sSize+"'");
			                            }
	     	                            
			                            sHtml.append("class='text'")
			                                 .append("id='item_"+screenItem.getItemTypeId()+"'")
			                                 .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("onKeyup='resizeTextarea(this,10);limitChars(this,255)'")
			                                 .append(">")
			                                 .append(sValue)
			                                 .append("</textArea>");
			                        }
			                        //*** radio (yes/no) **********************
			                        else if(screenItem.getHtmlElement().equals("radio")){
			                        	// visible-item : yes
			                            sHtml.append("<input type='radio' name='r_"+screenItem.getItemTypeId()+"' onBlur=\"this.style.border = 'none'\" style='vertical-align:-2px'")
			                                 .append("id='radio_"+screenItem.getItemTypeId()+"_yes'")
			                                 .append("value='yes' "+(sValue.equalsIgnoreCase("yes")?"checked":""))
			                                 .append(" onClick=\"document.getElementById('radio_"+screenItem.getItemTypeId()+"').value = this.value;this.style.border = 'none';document.getElementById('radio_"+screenItem.getItemTypeId()+"_no').style.border = 'none'\"")
			                                 .append(" onDblClick=\"this.checked=false;document.getElementById('radio_"+screenItem.getItemTypeId()+"').value = 'none';\"")
			                                 .append(">")
			                                 .append("<label for='radio_"+screenItem.getItemTypeId()+"_yes'>"+getTran("web","yes",sWebLanguage)+"</label>");
	
				                        // followedBy
				                        if(screenItem.getAttribute("Attr_followedBy").equals("newline")){
				                            sHtml.append("</br>");
				                        }
				                        else if(screenItem.getAttribute("Attr_followedBy").equals("space")){
				                            sHtml.append("&nbsp;");
				                        }
				                        
			                            // visible-item : no
			                            sHtml.append("<input type='radio' name='r_"+screenItem.getItemTypeId()+"' onBlur=\"this.style.border = 'none'\" style='vertical-align:-2px'")
			                                 .append("id='radio_"+screenItem.getItemTypeId()+"_no'")
			                                 .append("value='no' "+(sValue.equalsIgnoreCase("no")?"checked":""))
			                                 .append(" onClick=\"document.getElementById('radio_"+screenItem.getItemTypeId()+"').value = this.value;this.style.border = 'none';document.getElementById('radio_"+screenItem.getItemTypeId()+"_yes').style.border = 'none'\"")
			                                 .append(" onDblClick=\"this.checked=false;document.getElementById('radio_"+screenItem.getItemTypeId()+"').value = 'none';\"")
			                                 .append(">")
			                                 .append("<label for='radio_"+screenItem.getItemTypeId()+"_no'>"+getTran("web","no",sWebLanguage)+"</label>");
				                        
			                            // hidden-item
			                            sHtml.append("<input type='hidden' id='radio_"+screenItem.getItemTypeId()+"'")
			                                 .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("value='"+sValue+"'>");
			                        }
			                        //*** checkBox ****************************
			                        else if(screenItem.getHtmlElement().equals("checkBox")){
			                            sHtml.append("<input type='checkbox' style='vertical-align:-2px'")
		                                     .append("name='currentTransactionVO.items.<ItemVO[hashCode="+itemVO.getItemId()+"]>.value'")
			                                 .append("id='cb_"+screenItem.getItemTypeId()+"'")
			                                 .append("value='"+screenItem.getItemTypeId()+"' "+(sValue.equalsIgnoreCase(screenItem.getItemTypeId())?"checked":"")+">")
			                                 .append("<label for='cb_"+screenItem.getItemTypeId()+"'>"+getTran("CUSTOMEXAMINATION"+screen.getExamId(),screenItem.getItemTypeId(),sWebLanguage)+"</label>");	                            
			                        }
	
			                        // required ? --> asterisk
			                        boolean requiredField = ScreenHelper.checkString((String)screenItem.getAttribute("Attr_required")).equalsIgnoreCase("true");
			                        if(requiredField){
			                        	sHtml.append("<span style='vertical-align:top'>&nbsp;*&nbsp;</span>");
			                        }
	
			                        // followedBy
			                        if(screenItem.getAttribute("Attr_followedBy").equals("newline")){
			                            sHtml.append("</br>");
			                        }
			                        else if(screenItem.getAttribute("Attr_followedBy").equals("space")){
			                            sHtml.append("&nbsp;");
			                        }
		                        }
	                        }
                        }
                    }
                }
                
                sHtml.append("</td>"+sNewLineChar);
                
                prevCell = cell;
            }
            
            //***** 4 - close row *****
            sHtml.append("</tr>"+sNewLineChar);
        }
        
        sHtml.append("</table>"+sNewLineChar);
        
        sJS+= "</script>";
        sHtml.append(sJS);
        
        return sHtml.toString();
    }
%>

<%
    String sCustomExamType = checkString(request.getParameter("CustomExamType"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############## healthrecord/customExamination.jsp #############");
        Debug.println("sCustomExamType : "+sCustomExamType+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <%
        TransactionVO tran = (TransactionVO)transaction;
        //tran = MedwanQuery.getInstance().loadTransaction(tran.getServerId(),tran.getTransactionId());
    %>
    
    <%=checkPrestationToday(activePatient.personid,false,activeUser,tran)%>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(tran.getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE (required) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("web.occup","history",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("web.occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="5">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- configured items --%>
        <%
            Screen screen = Screen.getByExamId(sCustomExamType,tran.getUpdateTime());
            if(Debug.enabled) tran.displayItems();
            
            out.print(displayScreen(screen,tran,sWebLanguage));
        %>            
    </table>
    
	<%
	    Vector requiredFields = screen.getRequiredFields();
	
	    if(requiredFields.size() > 0){
	    	%>&nbsp;<%=getTran("web","asterisk_fields_are_obligate",sWebLanguage)%><%
	    }
	%>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.customexamination",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>
</form>

Transaction '<%=tran.getServerId()+"."+tran.getTransactionId()%>' saved at <%=ScreenHelper.fullDateFormat.format(tran.getTimestamp())%><br/>
Displayed using template '<%=screen.getUid()%>' saved at <%=ScreenHelper.stdDateFormat.format(screen.getUpdateDateTime())%>

<%=ScreenHelper.contextFooter(request)%>

<script>
  <%
      if(requiredFields.size() > 0){
          %>var requiredFields = "<%=ScreenHelper.vectorToString(requiredFields,",",false)%>".split(",");<%
      }
      else{
          %>var requiredFields = new Array();<%
      }
  %>  

  <%-- SUBMIT FORM --%>
  function submitForm(){
	if(requiredFieldsComplete()){
      transactionForm.submit();
	}
	else{
      focusFirstEmptyRequiredField();
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
	}
  }
  
  <%-- REQUIRED FIELDS COMPLETE --%>
  function requiredFieldsComplete(){
	var requiredFieldsOK = true;
	
	for(var i=0; i<requiredFields.length; i++){
      requiredField = document.getElementById("item_"+requiredFields[i]);
      if(!requiredField) requiredField = document.getElementById("radio_"+requiredFields[i]+"_yes");
      if(!requiredField) requiredField = document.getElementById("radio_"+requiredFields[i]+"_no");
      if(!requiredField) requiredField = document.getElementById("cb_"+requiredFields[i]);
      
      if(requiredField.value.length==0 || requiredField.value=="noChoiseMade"){
        requiredFieldsOK = false;
        break;
      }
      else if(requiredField.id.startsWith("radio_")){
        var baseName = requiredField.id.substring(0,requiredField.id.lastIndexOf("_"));
        var yesRadio = document.getElementById(baseName+"_yes"),
            noRadio = document.getElementById(baseName+"_no");
        
        if(yesRadio.checked==false && noRadio.checked==false){
          requiredFieldsOK = false;
          break;
        }
      }
	}
	
	return requiredFieldsOK;
  }
  
  <%-- FOCUS FIRST EMPTY REQUIRED FIELD --%>
  function focusFirstEmptyRequiredField(){	
	for(var i=0; i<requiredFields.length; i++){
      requiredField = document.getElementById("item_"+requiredFields[i]);
      if(!requiredField) requiredField = document.getElementById("radio_"+requiredFields[i]+"_yes");
      if(!requiredField) requiredField = document.getElementById("radio_"+requiredFields[i]+"_no");
      if(!requiredField) requiredField = document.getElementById("cb_"+requiredFields[i]);
      
      if(requiredField.value.length==0 || requiredField.value=="noChoiseMade"){
    	requiredField.focus();
        break;
      }
      else if(requiredField.id.startsWith("radio_")){
        var baseName = requiredField.id.substring(0,requiredField.id.lastIndexOf("_"));
        var yesRadio = document.getElementById(baseName+"_yes"),
            noRadio = document.getElementById(baseName+"_no");
        
        if(yesRadio.checked==false && noRadio.checked==false){
          requiredField.style.border = "1px solid red";
          break;
        }
      }
	}
  }
    
  <%-- CHECK INTEGER FIELD --%>
  function checkIntegerField(integerField){
    if(integerField.value.length>0 && !isNumber(integerField)){
      alertDialog("web","notNumeric");
      integerField.value = "";
      integerField.focus();
    }
  }
</script>

<%=writeJSButtons("transactionForm","backButton")%>