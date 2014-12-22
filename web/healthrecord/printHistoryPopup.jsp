<%@page import="be.dpms.medwan.common.model.vo.recruitment.RecordRowVO,
                be.dpms.medwan.common.model.vo.recruitment.FullRecordVO,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc,
                be.openclinic.system.Transaction,
                java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=sJSDATE %>
<script>var myForm = document;</script>

<%!
    //--- COUNT ITEMVIEW LIST ---------------------------------------------------------------------
    public int countItemViewList(String sTranType){
	    int itemCount = 0;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    
	    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
	    
	    try{
	        String sSql = "SELECT COUNT(*) FROM ItemViewList i, TransactionItems t"+
	                      " WHERE i.label = t.itemtypeid"+
	        		      "  AND t.transactiontypeid = ?";
	        ps = oc_conn.prepareStatement(sSql);	       
	        ps.setString(1,sTranType);
	
	        rs = ps.executeQuery();            
	        if(rs.next()){
	        	itemCount = rs.getInt(1);
	        }
	    }
	    catch(Exception e){
	    	if(Debug.enabled) e.printStackTrace();
	        Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
	    }
	    finally{
	        try{
	            if(rs!=null) rs.close();
	            if(ps!=null) ps.close();
	            oc_conn.close();
	        }
	        catch(SQLException se){
	            Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
	        }
	    }
    
        return itemCount;
    }
%>

<%
    String sClass = "", sUserName, sUserId, sItemValue, sTransactionType = "", allAnalysis = "";
    RecordRowVO record;
    int itemCount = 0;
%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************* healthrecord/printHistoryPopup.jsp ****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table width="100%" cellspacing="0" class="list">
    <%-- GENERAL TITLE --%>
    <tr class="admin" height="20">
        <td colspan="4">&nbsp;<%=getTran("Web.Occup","medwan.common.history",sWebLanguage)%></td>
    </tr>

    <%-- FULL RECORD --%>
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        FullRecordVO fullRecordRow = (FullRecordVO)sessionContainerWO.getObject(FullRecordVO.class.getName());

        if(fullRecordRow!=null){
            %>
		        <%-- GENERAL HEADER --%>
		        <tr class="list_select">
		            <td width="15">&nbsp;</td>
		            <td width="100"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
		            <td width="50%"><%=getTran("Web.Occup","medwan.common.contacttype",sWebLanguage)%></td>
		            <td width="35%"><%=getTran("Web.Occup","medwan.common.user",sWebLanguage)%></td>
		        </tr>
            <%
             
            RecordRowVO recordRow;
            for(int i=0; i<fullRecordRow.recordRows.size(); i++){
                recordRow = (RecordRowVO)fullRecordRow.recordRows.get(i);
                
                // indent = 0
                if(recordRow.getIndent()==0){
                    if(itemCount > 0){
                        %>
                                    </table>
                                    <br>
                                </td>
                            </tr>
                        <%
                    }
	                
                    itemCount++;
                    String context = "";
	
		            // alternate row-style
		            if(sClass.length()==0) sClass = "1";
		            else                   sClass = "";
	
		            record = (RecordRowVO)recordRow;
		            sUserName = "";
		            if(record != null){
		                // get user names
		                Transaction transaction = Transaction.getTransaction(record.getTransactionId(), record.getServerId());
		
		                if(transaction != null){
		                    sUserId = checkString(Integer.toString(transaction.getUserId()));
		                    sTransactionType = transaction.getTransactionType();
		
	                        Hashtable hName = User.getUserName(sUserId);
	                        if(hName!=null){
	                            sUserName = hName.get("lastname")+" "+hName.get("firstname");
	                        }
	                    }
		                        
		                String sContext = Transaction.getTransactionContext(record.getTransactionId(),record.getHealthrecordId(),record.getTransactionType());
		                if(sContext!=null){
		                    context = getTranNoLink("web.occup",sContext,sWebLanguage);
		                }
		            }
		
		            // forward
		            String sForward = MedwanQuery.getInstance().getForward(sTransactionType);
		            if(sForward!=null){
		                sForward = sForward.substring(0,sForward.indexOf("main.do")) + "medical/viewLastTransaction.jsp" + sForward.substring(sForward.indexOf("main.do") + 7);
		            }
		             
		            %>
	                    <%-- CLICKABLE RECORD HEADER (indent == 0) --%>
		                <tr class="list<%=sClass%>">
		                    <td>
		                        <img id="tr<%=itemCount%>S" name="tr<%=itemCount%>S" src="<c:url value='/_img/icons/icon_plus.png'/>" onclick="showD('tr<%=itemCount%>','tr<%=itemCount%>S','tr<%=itemCount%>H');">
		                        <img id="tr<%=itemCount%>H" name="tr<%=itemCount%>H" src="<c:url value='/_img/icons/icon_minus.png'/>" onclick="hideD('tr<%=itemCount%>','tr<%=itemCount%>S','tr<%=itemCount%>H');" style="display:none">
		                    </td>
		                    <td><%=recordRow.getResult()%></td>
		                    <td>
		                        <a href="<%=sCONTEXTPATH+sForward%>&be.mxs.healthrecord.createTransaction.transactionType=<%=recordRow.getTransactionType()%>&be.mxs.healthrecord.transaction_id=<%=recordRow.getTransactionId()%>&be.mxs.healthrecord.server_id=<%=recordRow.getServerId()%>&useTemplate=no" onMouseOver="window.status='';return true;">
		                            <%=getTranNoLink("web.occup",recordRow.getLabel(),sWebLanguage)%> <%=(context.length() > 0 ?"("+context+")":"")%>
		                        </a>
		                    </td>
		                    <td><%=sUserName%></td>
		                </tr>
	
		                <%-- HIDDEN TABLE --%>
		                <tr id="tr<%=itemCount%>" name="tr<%=itemCount%>" style="display:none">
		                    <td colspan="4">
		                        <table class="list" width="100%" cellspacing="1">
		            <%
	            }
            
                // indent = 1
                if(recordRow.getIndent()==1){
		            %>
		                <%-- subheader --%>
		                <tr class="list_select">
		                    <td colspan="2"><%=getTranNoLink("web.occup",recordRow.getLabel(),sWebLanguage)%></td>
		                </tr>
                    <%
                }

                if(recordRow.getResultWidth() > 0){
                    String sLabel  = recordRow.getLabel(),
                           sResult = recordRow.getResult();

                    //--- LAB_RESULT --------------------------------------------------------------
                    if(sTransactionType.indexOf("LAB_RESULT") > -1){
                        sLabel = getTranNoLink("TRANSACTION_TYPE_LAB_RESULT",sLabel,sWebLanguage);
                        MessageReader messageReader = new MessageReaderMedidoc();
                        messageReader.lastline = sResult;
                        String type = messageReader.readField("|");

                        if(type.equalsIgnoreCase("T") || type.equalsIgnoreCase("C")){
                            sResult=messageReader.readField("|");
                        }
                        else if(type.equalsIgnoreCase("N") || type.equalsIgnoreCase("D") || type.equalsIgnoreCase("H") || type.equalsIgnoreCase("M") || type.equalsIgnoreCase("S")){
                            sResult = messageReader.readField("|")+" ";
                            sResult+= messageReader.readField("|")+" ";
                        }
                    }
                    else{
                        sLabel = getTranNoLink("web.occup",sLabel,sWebLanguage);
                    }

                    //--- MIR ---------------------------------------------------------------------
                    // MIR Type is saved as a single number;
                    // We must append labelid, otherwise only the number is displayed in the history.
                    if(recordRow!=null
                       && (sTransactionType.equalsIgnoreCase(sPREFIX+"TRANSACTION_TYPE_MIR") || (sTransactionType.equalsIgnoreCase(sPREFIX+"TRANSACTION_TYPE_MIR_MOBILE_UNIT"))
                       && checkString(recordRow.getLabel()).equalsIgnoreCase(sPREFIX+"ITEM_TYPE_MIR_TYPE"))){
                        if(recordRow.getLabel().equalsIgnoreCase(sPREFIX+"ITEM_TYPE_MIR_TYPE")){
                            sItemValue = getTranNoLink("Web.Occup",checkString("medwan.occupational-medicine.medical-imaging-request.type-"+recordRow.getResult()),sWebLanguage);
                        }
                        else{
                            sItemValue = getTranNoLink("Web.Occup",checkString(recordRow.getResult()),sWebLanguage);
                        }
                        
                        %>
                            <tr>
                                <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                <td class="admin2" width="*"><%=sItemValue%></td>
                            </tr>
                        <%
                    }
                    //--- LAB_REQUEST -------------------------------------------------------------
                    // requested analysis are concatenated AND spread over multiple items.
                    else if(recordRow!=null && (sTransactionType.equalsIgnoreCase(sPREFIX+"TRANSACTION_TYPE_LAB_REQUEST"))){
                        // concatenate the content of the (max 5) analysis-items
                        if(checkString(recordRow.getLabel()).toLowerCase().indexOf(sPREFIX+"item_type_lab_analysis") > -1){
                            if(checkString(recordRow.getLabel()).equalsIgnoreCase(sPREFIX+"ITEM_TYPE_LAB_ANALYSIS1")){
                                allAnalysis = recordRow.getResult();
                            } 
                            else{
                                allAnalysis+= recordRow.getResult();
                            }

                            String analysisTran = getTranNoLink("web.occup", "labanalysis.analysis",sWebLanguage);
                            String oneAnalysis, analysisCode, analysisComm;

                            // split the total analysis-string into one analysis per row
                            StringTokenizer tokenizer = new StringTokenizer(allAnalysis,"$");
                            while(tokenizer.hasMoreTokens()){
                                oneAnalysis = tokenizer.nextToken();

                                if(oneAnalysis.indexOf("£") > -1){
                                    analysisCode = oneAnalysis.substring(0,oneAnalysis.indexOf("£"));
                                } 
                                else{
                                    analysisCode = oneAnalysis;
                                }

                                analysisComm = oneAnalysis.substring(oneAnalysis.indexOf("£")+1);

                                // trim comment
                                if(analysisComm.length() > 20){
                                    analysisComm = analysisComm.substring(0,20)+" ...";
                                }
                                
                                %>
                                    <tr>
                                        <td class="admin" width="<%=sTDAdminWidth%>"><%=analysisTran%> <%=analysisCode%></td>
                                        <td class="admin2" width="*">
                                            <%=getTran("labanalysis",analysisCode,sWebLanguage)%>
                                            <%
                                                // comment
                                                if(analysisComm.length() > 0){
                                                    %> (<%=analysisComm%>)<%
                                                }
                                            %>
                                        </td>
                                    </tr>
                                <%
                            }
                        }
                        else{
                            // process other items of LAB_REQUEST
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=sLabel%></td>
                                    <td class="admin2" width="*"><%=getTranNoLink("web.occup",sResult,sWebLanguage)%></td>
                                </tr>
                            <%
                        }
                    }
                    //--- OTHER TRANSACTIONS ------------------------------------------------------
                    else{
                        // checked icon
                        if(sResult.equalsIgnoreCase("medwan.common.true")){
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("web.occup",sLabel,sWebLanguage)%></td>
                                    <td class="admin2" width="*"><img src="<c:url value="/_img/themes/default/check.gif"/>"/></td>
                                </tr>
                            <%
                        }
                        // unchecked icon
                        else if(sResult.equalsIgnoreCase("medwan.common.false")){
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("web.occup",sLabel,sWebLanguage)%></td>
                                    <td class="admin2" width="*"><img src="<c:url value="/_img/themes/default/uncheck.gif"/>"/></td>
                                </tr>
                            <%
                        }
                        // textual value
                        else{
                            %>
                                <tr>
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTranNoLink("web.occup",sLabel,sWebLanguage)%></td>
                                    <td class="admin2" width="*"><%=getTranNoLink("web.occup",sResult,sWebLanguage)%></td>
                                </tr>
                            <%
                        }
                    }
                }
            }
        }
     
        if(itemCount > 0){
            %>
                        </table>
                    </td>
                </tr>
            <%
        }
    %>
</table>

<%-- BUTTONS --%>
<%
    if(itemCount > 0){
        %>
            <a href="javascript:expandAll();"><%=getTranNoLink("web","expand_all",sWebLanguage)%></a>&nbsp;
            <a href="javascript:collapseAll();"><%=getTranNoLink("web","close_all",sWebLanguage)%></a>
        <%
    }
    else{
    	if(countItemViewList(sTransactionType)==0){
            %><font color="red"><%=getTran("web","noItemsConfigured",sWebLanguage)%></font><%
    	}
    	else{
            %><%=getTran("web","noHistoryFound",sWebLanguage)%><%	
    	}
    }
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" value="<%=getTranNoLink("Web","close",sWebLanguage)%>" onClick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  window.resizeTo(800,570);
  var iTotal = <%=itemCount%>;

  function expandAll(){
	for(var i=1; i<=iTotal; i++){
      showD("tr"+i,"tr"+i+"S","tr"+i+"H");
	}
  }

  function collapseAll(){
	for(var i=1; i<iTotal+1; i++){
	  hideD("tr"+i,"tr"+i+"S","tr"+i+"H");
	}
  }
</script>
