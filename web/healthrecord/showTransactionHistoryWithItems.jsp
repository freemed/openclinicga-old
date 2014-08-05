<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemContextVO,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSTOGGLE%>
<%=sJSPROTOTYPE%>

<%!
    /// INNER CLASS ItemAndLabel //////////////////////////////////////////////////////////////////
    private class ItemAndLabel implements Comparable {
        public ItemVO item;
        public String label;
        public int order = 9999; // undefined order
        
        public ItemAndLabel(ItemVO item, String sLabel, String sOrder){
            this.item = item;
            this.label = sLabel;  
            
            if(sOrder.length() > 0){
                this.order = Integer.parseInt(sOrder);
                if(this.order==0) this.order = 9999; // last position
            }          
        }
        
        //--- EQUALS ----------------------------------------------------------
        public boolean equals(Object o){
            if(this==o) return true;
            if(!(o instanceof ItemAndLabel)) return false;

            final ItemAndLabel itemAndLabel = (ItemAndLabel)o;

            if(!item.getType().equals(itemAndLabel.item.getType()) && !label.equals(itemAndLabel.label)) return false;

            return true;
        }

        //--- COMPARE TO (order) ----------------------------------------------
        public int compareTo(Object o){
            int comp;

            if(o.getClass().isInstance(this)){
                comp = this.order - ((ItemAndLabel)o).order;
            }
            else{
                throw new ClassCastException();
            }

            return comp;
        }

    }

    //--- GET USER SELECTED ITEMS -----------------------------------------------------------------
    public Vector getUserSelectedItems(int userId){
        return getUserSelectedItems(userId,""); // load items for any type of transaction       
    }
    
    public Vector getUserSelectedItems(int userId, String sTranTypeShort){
        Vector userSelectedItems = new Vector();

        ItemContextVO itemContextVO = new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),"","");
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try{
            conn = MedwanQuery.getInstance().getAdminConnection();
            String sSql = "SELECT value FROM userparameters"+
                          " WHERE parameter LIKE ?"+
                          "  AND userid = ?"+
                          "  AND active = 1"+
                          " ORDER BY parameter DESC, value DESC";
            ps = conn.prepareStatement(sSql);
            ps.setString(1,"HistoryItem."+sTranTypeShort+"%");
            ps.setInt(2,userId);
            rs = ps.executeQuery();
            
            String sValue, sItemTypeShort, sUserDefLabel, sOrder = "";
            ItemAndLabel itemAndLabel;
            String[] valueParts;
            ItemVO item;
            
            while(rs.next()){
                sValue = checkString(rs.getString("value"));
                
                if(sValue.length() > 0){
                    valueParts = sValue.split("\\$"); // sItemTypeShort $ user defined label $ user defined order
                    
                    sItemTypeShort = checkString(valueParts[0]);
                    sUserDefLabel  = checkString(valueParts[1]);
                    if(valueParts.length > 2) sOrder = checkString(valueParts[2]);
                    
                    item = new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
		                              ScreenHelper.ITEM_PREFIX+sItemTypeShort.toUpperCase(),
		                              "", // default value
		                              new java.util.Date(),
		                              itemContextVO);
                    
                    itemAndLabel = new ItemAndLabel(item,sUserDefLabel,sOrder);                    
                    userSelectedItems.add(itemAndLabel);    
                }                
            }
        }
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                if(conn!=null) conn.close();
            }
            catch(Exception e){
                Debug.printStackTrace(e);
            }
        }
        
        return userSelectedItems;
    }
    
    //--- TRY TO TRANSLATE ------------------------------------------------------------------------
    // return result-array : {Boolean translated, String translation}
    private String tryToTranslate(String sItemValue, String sItemType, String sWebLanguage){        
        // try 1 : web.occup
        String sLabelType = "web.occup";
        String sTranslatedValue = ScreenHelper.getTranNoLink(sLabelType,sItemValue,sWebLanguage);
        if(sTranslatedValue.equalsIgnoreCase(sItemValue)){
            // try 2 : web
            sLabelType = "web";
            sTranslatedValue = ScreenHelper.getTranNoLink(sLabelType,sItemValue,sWebLanguage);
        }
        
        // some hardcoded relations
        if(sTranslatedValue.equalsIgnoreCase(sItemValue)){  
	        //*** STRESS ***
	        if(sItemType.equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CE_ANAMNESE_STRESS")){
	            // convert values
	                 if(sItemValue.equals("0")) sTranslatedValue = "";
	            else if(sItemValue.equals("1")) sTranslatedValue = "+";
	            else if(sItemValue.equals("2")) sTranslatedValue = "++";
	            else if(sItemValue.equals("3")) sTranslatedValue = "+++";
	            else if(sItemValue.equals("4")) sTranslatedValue = "0";
	        }
	        //*** TOBACCO USAGE ***
	        else if(sItemType.equalsIgnoreCase(ScreenHelper.ITEM_PREFIX+"[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE")){
	            // convert values            
	                 if(sItemValue.equals("1")) sTranslatedValue = "0";
	            else if(sItemValue.equals("2")) sTranslatedValue = "0 - 5";
	            else if(sItemValue.equals("3")) sTranslatedValue = "5 - 10";
	            else if(sItemValue.equals("4")) sTranslatedValue = "10 - 15";
	            else if(sItemValue.equals("5")) sTranslatedValue = "15 - 25";
	            else if(sItemValue.equals("6")) sTranslatedValue = "&gt; 25";
	        }
        }
        
	    // display itemValue when no label found
        if(sTranslatedValue.length()==0){
        	sTranslatedValue = sItemValue;
        }
        
        return sTranslatedValue;    
    }
    
    //--- IS OPENED -------------------------------------------------------------------------------
    // did the user open this transaction in the current session ?
    private boolean isOpened(int serverId, int transactionId, HttpSession session){
    	return ScreenHelper.checkString((String)session.getAttribute("openedTran_"+serverId+"."+transactionId)).equals("true"); 
    }
%>

<%
    SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    
    String sSelectedContext = checkString(request.getParameter("SelectedContext"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* health/showTransactionHistoryWithItems.jsp ********");
        Debug.println("SelectedContext : "+sSelectedContext+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>

<html>
<head>
    <title><%=sAPPTITLE%></title>
    <%=sIcon%>
    <%=sCSSNORMAL%>
    <%=sJSSORTTABLE%>
    <%=sJSDATE%>
</head>

<body>
    <%-- page title --%>
    <table width="100%" cellspacing="0" cellpadding="0" class="list">
        <tr class="admin" height="20"><td><%=getTran("web","transactionHistoryWithItems",sWebLanguage)%></td></tr>
    </table>
    
    <%-- SPACER --%>
    <div style="padding-top:5px;"></div>
      
    <%-------------------------------------------------------------------------------------------%>
    <%-- 1 : EXAMINATIONS AND DOCUMENTS ---------------------------------------------------------%>
    <%-------------------------------------------------------------------------------------------%>
    <table width="100%" cellspacing="0" cellpadding="0" class="list">
        <%-- title --%>
        <tr class="admin" height="20"><td><%=getTran("web","examinationsAndDocuments",sWebLanguage)%></td></tr>

        <tr>
            <td class="white" valign="top">
                <table width="100%" class="list" cellspacing="0">
                    <%-- HEADER --%>
                    <tr height="20">
                        <td class="admin" width="20">&nbsp;</td>
                        <td class="admin" width="90" style="padding-left:4px;"><desc><%=getTran("web","date",sWebLanguage)%></desc></td>
                        <td class="admin" width="*" style="padding-left:4px;"><%=getTran("web.occup","medwan.common.contacttype",sWebLanguage)%></td>
                        <td class="admin" width="150" style="padding-left:4px;"><%=getTran("web","user",sWebLanguage)%></td>
                        <td class="admin" width="200" style="padding-left:4px;"><%=getTran("web","context",sWebLanguage)%></td>
                    </tr>
    <%
    
    // examinations and documents
    Collection transactions = sessionContainerWO.getHealthRecordVO().getTransactions();
    Iterator tranIter = transactions.iterator();
    Hashtable hTransOnDate = new Hashtable();
    java.util.Date tranDate;
    TransactionVO tran = null;

    // create hash with trandate as key, to sort on later on
    int dateDifferentiator = 0;
    while(tranIter.hasNext()){
        tran = (TransactionVO)tranIter.next();
        tranDate = tran.getUpdateTime();
        tranDate.setTime(tranDate.getTime()+(dateDifferentiator++));

        hTransOnDate.put(tranDate,tran);
    }

    String sClass = "", sForward, sFullUserName, sUrl, sContext = "", sTranName = "", sTranNameShort = "";
    Vector tranDates = new Vector(hTransOnDate.keySet());
    Collections.sort(tranDates);
    Collections.reverse(tranDates);
    tranIter = tranDates.iterator();
    
    boolean itemValuesFound = false;

    %><tbody style="cursor:pointer;"><%

    int tranCount = 0;
    while(tranIter.hasNext()){
        tranDate = (java.util.Date)tranIter.next();
        tran = (TransactionVO)hTransOnDate.get(tranDate);

        sForward = MedwanQuery.getInstance().getForward(tran.getTransactionType());

        if(sForward!=null){
            sForward = sForward.replaceAll("main.do","healthrecord/viewTransaction.jsp");

            if(sForward.indexOf("?") > -1){
            	// &
                sUrl = sCONTEXTPATH+sForward+"&be.mxs.healthrecord.createTransaction.transactionType="+tran.getTransactionType()+
                       "&be.mxs.healthrecord.transaction_id="+tran.getTransactionId()+
                       "&be.mxs.healthrecord.server_id="+tran.getServerId()+
                       "&useTemplate=no"+
                       "&ts="+getTs();
            }
            else{
            	// ?
                sUrl = sCONTEXTPATH+sForward+"?be.mxs.healthrecord.createTransaction.transactionType="+tran.getTransactionType()+
                       "&be.mxs.healthrecord.transaction_id="+tran.getTransactionId()+
                       "&be.mxs.healthrecord.server_id="+tran.getServerId()+
                       "&useTemplate=no"+
                       "&ts="+getTs();
            }

            sTranName = getTran("web.occup",tran.getTransactionType(),sWebLanguage);
            if(sTranName.length() > 52){
                sTranNameShort = sTranName.substring(0,50)+"...";
            }
            else{
                sTranNameShort = sTranName;
            }

            tran = MedwanQuery.getInstance().loadTransaction(tran.getServerId(),tran.getTransactionId().intValue());
            if(tran==null) continue;
            sFullUserName = tran.getUser().getPersonVO().getLastname()+" "+tran.getUser().getPersonVO().getFirstname();
            sContext = tran.getContextItemValue();

            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            itemValuesFound = false;

            %>
                <tr height="18" class="list<%=sClass%>" onmouseover='this.className="list_select";' onmouseout='this.className="list<%=sClass%>";window.status="";return true;' <%=(sTranName.length()>52?"title='"+sTranName+"'":"")%>>
                    <td onclick="toggleTranItems(<%=tranCount%>);">
                        <img id="trTran<%=tranCount%>Plus" src="<c:url value='/_img/plus.jpg'/>">
                        <img id="trTran<%=tranCount%>Min" src="<c:url value='/_img/minus.jpg'/>" style="display:none;">
                    </td>
                    <td onclick="toggleTranItems(<%=tranCount%>);">&nbsp;<%=ScreenHelper.stdDateFormat.format(tran.getUpdateTime())%></td>
                    <td>&nbsp;<a href="javascript:void();" onClick="showExamination('<%=sUrl%>');"><%=sTranNameShort%></a></td>
                    <td onclick="toggleTranItems(<%=tranCount%>);">&nbsp;<%=sFullUserName%></td>
                    <td onclick="toggleTranItems(<%=tranCount%>);">&nbsp;<%=getTran("web.occup",sContext,sWebLanguage)%></td>                  
                </tr>                                   

                <%-- HIDDEN TABLE --%>
                <tr id="trTran<%=tranCount%>" style="display:none;">
                    <td colspan="6">
                        <table class="list" width="100%" cellspacing="1">                                            
                            <%
                                // fetch user selected items (userprofile/manageHistoryItems)
                                String sTranTypeShort = tran.getTransactionType().substring(tran.getTransactionType().indexOf(ScreenHelper.ITEM_PREFIX)+ScreenHelper.ITEM_PREFIX.length());
                                Vector userSelectedItems = getUserSelectedItems(Integer.parseInt(activeUser.userid),sTranTypeShort);
                           
                                if(userSelectedItems.size() > 0){
                                    Collections.sort(userSelectedItems);
                                    
                                    String sItemType = "", sItemValue = "", sItemLabel = "";
                                    String sTransactionType = tran.getTransactionType();
                                    ItemAndLabel itemAndLabel;
                                    ItemVO item;

                                    for(int i=0; i<userSelectedItems.size(); i++){
                                        itemAndLabel = (ItemAndLabel)userSelectedItems.get(i);
                                        item = itemAndLabel.item;
                                        
                                        sItemType = item.getType();
                                        sItemValue = tran.getItemSeriesValue(sItemType);
                                        sItemValue = sItemValue.replaceAll("\r\n","<br>");

                                        // split concatenated values
                                        if(sItemValue.indexOf("£") > -1){
                                            if(sItemValue.endsWith("$")){
                                                sItemValue = sItemValue.substring(0,sItemValue.length()-1); // remove trailing $
                                            }

                                            if(sItemValue.startsWith("£")){
                                                sItemValue = sItemValue.replaceFirst("£",""); // remove first £    
                                            }
                                            sItemValue = sItemValue.replaceAll("£",", ");
                                        }
                                        
                                        sItemLabel = itemAndLabel.label;

                                        //--- LAB_RESULT --------------------------------------------------------------
                                        if(sTransactionType.indexOf("LAB_RESULT") > -1){
                                            sItemLabel = getTran("TRANSACTION_TYPE_LAB_RESULT",sItemType,sWebLanguage);
                                            MessageReader messageReader = new MessageReaderMedidoc();
                                            messageReader.lastline = sItemValue;
                        
                                            String type = messageReader.readField("|");
                                            if(type.equalsIgnoreCase("T") || type.equalsIgnoreCase("C")){
                                                sItemValue = messageReader.readField("|");
                                            }
                                            else if(type.equalsIgnoreCase("N") || type.equalsIgnoreCase("D") || type.equalsIgnoreCase("H") ||
                                                    type.equalsIgnoreCase("M") || type.equalsIgnoreCase("S")){
                                                sItemValue = messageReader.readField("|")+" ";
                                                sItemValue+= messageReader.readField("|")+" ";
                                            }
                                        }

                                        //--- MIR ---------------------------------------------------------------------
                                        // MIR Type is saved as a single number;
                                        // We must append labelid, otherwise only the number is displayed in the history.
                                        if(sTransactionType.equals(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_MIR") ||
                                           sTransactionType.equals(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_MIR_MOBILE_UNIT")){    
                                            if(sItemType.equals(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_MIR_TYPE")){
                                                sItemValue = getTran("web.occup","medwan.occupational-medicine.medical-imaging-request.type-"+sItemValue,sWebLanguage);
                                            }
                                            else{
                                                sItemValue = getTran("web.occup",sItemValue,sWebLanguage);
                                            }
                        
                                            if(sItemValue.length() > 0){
                                                %>
                                                    <tr>
                                                        <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                        <td class="admin2" width="*" nowrap><%=sItemValue%></td>
                                                    </tr>
                                                <%
                                            }
                                        }
                                        //--- LAB_REQUEST -------------------------------------------------------------
                                        // requested analysis are concatenated AND spread over multiple items.
                                        else if(sTransactionType.equals(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_LAB_REQUEST")){
                                            String allAnalysis = "";
                                            
                                            // concatenate the content of the (max 5) analysis-items
                                            if(sItemType.toLowerCase().indexOf(ScreenHelper.ITEM_PREFIX.toLowerCase()+"item_type_lab_analysis") > -1){    
                                                if(sItemType.equals(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_LAB_ANALYSIS1")){
                                                    allAnalysis = sItemValue;
                                                }
                                                else{
                                                    allAnalysis+= sItemValue;
                                                }
                        
                                                String analysisTran = getTran("web.occup","labanalysis.analysis",sWebLanguage);
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
                                                            <td class="admin2" width="*" nowrap>
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
                                                if(sItemValue.length() > 0){
                                                    %>
                                                        <tr>
                                                            <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                            <td class="admin2" width="*" nowrap><%=getTranNoLink("web.occup",sItemValue,sWebLanguage)%></td>
                                                        </tr>
                                                    <%
                                                }
                                            }
                                        }
                                        //--- OTHER TRANSACTIONS ------------------------------------------------------
                                        else{  
                                            if(sItemValue.length() > 0){  
                                                itemValuesFound = true;
                                                
                                                // checked icon
                                                if(sItemValue.equalsIgnoreCase("medwan.common.true")){
                                                    %>
                                                        <tr>
                                                            <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                            <td class="admin2" width="*" nowrap><img src="<c:url value="/_img/check.gif"/>"/></td>
                                                        </tr>
                                                    <%
                                                }
                                                // unchecked icon
                                                else if(sItemValue.equalsIgnoreCase("medwan.common.false")){
                                                    %>
                                                        <tr>
                                                            <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                            <td class="admin2" width="*" nowrap><img src="<c:url value="/_img/uncheck.gif"/>"/></td>
                                                        </tr>
                                                    <%
                                                }
                                                // text value
                                                else{
                                                    sItemValue = tryToTranslate(sItemValue,sItemType,sWebLanguage);
                                                    
                                                    %>
                                                        <tr>
                                                            <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                            <td class="admin2" width="*" nowrap><%=getTranNoLink("web.occup",sItemValue,sWebLanguage)%></td>
                                                        </tr>
                                                    <%
                                                }
                                            }
                                        }
                                    }                 

                                    if(!itemValuesFound){
                                        %>
                                            <tr>
                                                <td class="admin2"><%=getTran("web.occup","noItemValuesToShowFound",sWebLanguage)%></td>
                                            </tr>
                                        <%
                                    }
                                }
                                else{    
                                    %>
                                        <tr>
                                            <td class="admin2"><%=getTran("web.occup","noItemsToShowFound",sWebLanguage)%></td>
                                        </tr>
                                    <%
                                }
                            %>
                        </table>
                    </td>
                </tr>                                            
            <%
                
            tranCount++;
        }
    }
%>
                    </tbody>
                </table>
            </td>
        </tr>
    </table>
    
    <a href="javascript:void();" onclick="expandAllTransactions();"><%=getTran("web","expand_all",sWebLanguage)%></a>&nbsp;
    <a href="javascript:void();" onclick="collapseAllTransactions();"><%=getTran("web","close_all",sWebLanguage)%></a>
    
    <br><br>

    <%-------------------------------------------------------------------------------------------%>
    <%-- 2 : VACCINATIONS -----------------------------------------------------------------------%>
    <%-------------------------------------------------------------------------------------------%>
    <table width="100%" cellspacing="0" cellpadding="0" class="list">
        <tr class="admin" height="20"><td><%=getTran("web.occup","vaccinations",sWebLanguage)%></td></tr>

        <tr>
            <td class="white" valign="top">
                <table width="100%" class="list" cellspacing="0">
                    <%-- HEADER --%>
                    <tr height="20">
                        <td class="admin" width="20">&nbsp;</td>
                        <td class="admin" width="90" style="padding-left:4px;"><desc><%=getTran("web","date",sWebLanguage)%></desc></td>
                        <td class="admin" width="*" style="padding-left:4px;"><%=getTran("web.occup","medwan.common.contacttype",sWebLanguage)%></td>
                        <td class="admin" width="150" style="padding-left:4px;"><%=getTran("web","user",sWebLanguage)%></td>
                        <td class="admin" width="200">&nbsp;</td>
                        <td class="admin" width="90">&nbsp;</td>
                    </tr>
        <%
        
        // vaccinations
        Collection vaccinations = MedwanQuery.getInstance().getVaccinations(sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue());
        Iterator vaccIter = vaccinations.iterator();
        Hashtable hVaccsOnDate = new Hashtable();
        java.util.Date vaccDate;
        TransactionVO vacc;
        String sVaccType, sStatus;

        // create hash with trandate as key, to sort on later on
        dateDifferentiator = 0;
        while(vaccIter.hasNext()){
            vacc = (TransactionVO)vaccIter.next();
            vaccDate = vacc.getCreationDate();
            vaccDate.setTime(vaccDate.getTime()+(dateDifferentiator++));

            hVaccsOnDate.put(vaccDate,vacc);
        }

        Vector vaccDates = new Vector(hVaccsOnDate.keySet());
        Collections.sort(vaccDates);
        Collections.reverse(vaccDates);
        vaccIter = vaccDates.iterator();

        %><tbody style="cursor:pointer;"><%

        sClass = "";
        int vaccCount = 0;
        while(vaccIter.hasNext()){
            vaccDate = (java.util.Date)vaccIter.next();
            vacc = (TransactionVO)hVaccsOnDate.get(vaccDate);
            vacc = MedwanQuery.getInstance().loadTransaction(vacc.getServerId(),vacc.getTransactionId().intValue());
            sVaccType = vacc.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_TYPE").getValue();

            sForward = sCONTEXTPATH+"/healthrecord/viewTransaction.jsp"+
                       "?Page=manageVaccination_view.jsp"+
                       "?be.mxs.healthrecord.createTransaction.transactionType="+ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_VACCINATION"+
                       "&be.mxs.healthrecord.transaction_id="+vacc.getTransactionId()+
                       "&be.mxs.healthrecord.server_id="+vacc.getServerId()+
                       "&vaccinationType="+sVaccType+
                       "&useTemplate=no"+
                       "&loadVaccinationInfoVO=true"+
                       "&ts="+getTs();

            sFullUserName = vacc.getUser().getPersonVO().getLastname()+" "+vacc.getUser().getPersonVO().getFirstname();

            // vaccination status
            sStatus = vacc.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_STATUS");
            if(sStatus.length() > 0){
                sStatus = "&nbsp;["+getTranNoLink("web.occup",sStatus,sWebLanguage).toLowerCase()+"]";
            }
            
            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            itemValuesFound = false;

            %>
                <tr height="18" class="list<%=sClass%>" onclick="toggleVaccItems(<%=vaccCount%>);" onmouseover='this.className="list_select";' onmouseout='this.className="list<%=sClass%>";window.status="";return true;' <%=(sTranName.length()>52?"title='"+sTranName+"'":"")%>>                                    
                    <td>
                        <img id="trVacc<%=vaccCount%>Plus" src="<c:url value='/_img/plus.jpg'/>">
                        <img id="trVacc<%=vaccCount%>Min" src="<c:url value='/_img/minus.jpg'/>" style="display:none;">
                    </td>
                    <td>&nbsp;<%=ScreenHelper.stdDateFormat.format(vacc.getUpdateTime())%></td>
                    <td>&nbsp;<%=getTran("web.occup",sVaccType,sWebLanguage)+sStatus%></td>
                    <td>&nbsp;<%=sFullUserName%></td>
                    <td>&nbsp;</td> 
                    <td>&nbsp;</td> 
                </tr>           

                <%-- HIDDEN TABLE --%>
                <tr id="trVacc<%=vaccCount%>" style="display:none;">
                    <td colspan="6">
                        <table class="list" width="100%" cellspacing="1">   
                            <%
                                String sTranTypeShort = vacc.getTransactionType().substring(vacc.getTransactionType().indexOf(ScreenHelper.ITEM_PREFIX)+ScreenHelper.ITEM_PREFIX.length());
                                Vector userSelectedItems = getUserSelectedItems(Integer.parseInt(activeUser.userid),sTranTypeShort);
                                Collections.sort(userSelectedItems); 

                                if(userSelectedItems.size() > 0){
                                    String sItemType = "", sItemValue = "", sItemLabel = "";
                                    String sTransactionType = vacc.getTransactionType();
                                    ItemAndLabel itemAndLabel;
                                    ItemVO item;
                               
                                    for(int i=0; i<userSelectedItems.size(); i++){
                                        itemAndLabel = (ItemAndLabel)userSelectedItems.get(i);
                                        item = itemAndLabel.item;
                                        
                                        sItemType = item.getType();                                        
                                        sItemValue = vacc.getItemSeriesValue(sItemType);
                                        sItemValue = sItemValue.replaceAll("\r\n","<br>"); 
                                        sItemLabel = itemAndLabel.label;

                                        if(sItemValue.length() > 0){   
                                            itemValuesFound = true;
                                            
                                            // checked icon
                                            if(sItemValue.equalsIgnoreCase("medwan.common.true")){
                                                %>
                                                    <tr>
                                                        <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                        <td class="admin2" width="*" nowrap><img src="<c:url value="/_img/check.gif"/>"/></td>
                                                    </tr>
                                                <%
                                            }
                                            // unchecked icon
                                            else if(sItemValue.equalsIgnoreCase("medwan.common.false")){
                                                %>
                                                    <tr>
                                                        <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                        <td class="admin2" width="*" nowrap><img src="<c:url value="/_img/uncheck.gif"/>"/></td>
                                                    </tr>
                                                <%
                                            }
                                            // text value
                                            else{
                                                // first try "web.occup", then "web"
                                                String sTmpLabel = getTranNoLink("web.occup",sItemValue,sWebLanguage);
                                                if(sTmpLabel.equals(sItemValue)){
                                                    sTmpLabel = getTranNoLink("web",sItemValue,sWebLanguage);                                                        
                                                }
                                                sItemValue = sTmpLabel;
                                                
                                                %>
                                                    <tr>
                                                        <td class="admin" width="<%=sTDAdminWidth%>"><%=sItemLabel%></td>
                                                        <td class="admin2" width="*" nowrap><%=getTranNoLink("web.occup",sItemValue,sWebLanguage)%></td>
                                                    </tr>
                                                <%
                                            }
                                        }
                                    }
                                    
                                    if(!itemValuesFound){
                                        %>
                                            <tr>
                                                <td class="admin2"><%=getTran("web.occup","noItemValuesToShowFound",sWebLanguage)%></td>
                                            </tr>
                                        <%
                                    }
                                }
                                else{
                                    %>
                                        <tr>
                                            <td class="admin2"><%=getTran("web.occup","noItemsToShowFound",sWebLanguage)%></td>
                                        </tr>
                                    <%
                                }
                            %>
                        </table>
                    </td>
                </tr>                                            
            <%
                
            vaccCount++;
        }    
    %>
                    </tbody>
                </table>
            </td>
        </tr>
    </table>

<%-- BUTTONS --%>
<a href="javascript:void();" onclick="expandAllVaccinations();"><%=getTran("web","expand_all",sWebLanguage)%></a>&nbsp;
<a href="javascript:void();" onclick="collapseAllVaccinations();"><%=getTran("web","close_all",sWebLanguage)%></a>

<p align="center">
    <input class="button" type="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();">
</p>

<br>

<script>
  window.resizeTo(1000,600);
  var iTranCount = <%=tranCount%>;
  var iVaccCount = <%=vaccCount%>;

  <%-- SHOW EXAMINATION --%>
  function showExamination(sUrl){
    window.location.href = sUrl;
  }
  
  <%-- TOGGLE TRAN ITEMS --%>
  function toggleTranItems(tranCount){
    if(document.getElementById("trTran"+tranCount).style.display=="none"){
      showD("trTran"+tranCount,"trTran"+tranCount+"Plus","trTran"+tranCount+"Min");
    }
    else{
      hideD("trTran"+tranCount,"trTran"+tranCount+"Plus","trTran"+tranCount+"Min");
    }
  }

  <%-- TOGGLE VACC ITEMS --%>
  function toggleVaccItems(vaccCount){
    if(document.getElementById("trVacc"+vaccCount).style.display=="none"){
      showD("trVacc"+vaccCount,"trVacc"+vaccCount+"Plus","trVacc"+vaccCount+"Min");
    }
    else{
      hideD("trVacc"+vaccCount,"trVacc"+vaccCount+"Plus","trVacc"+vaccCount+"Min");
    }
  }

  <%-- EXPAND ALL TRANSACTIONS --%>
  function expandAllTransactions(){
    for(var i=0; i<iTranCount; i++){
      showD("trTran"+i,"trTran"+i+"Plus","trTran"+i+"Min");
    }
  }

  <%-- COLLAPSE ALL --%>
  function collapseAllTransactions(){
    for(var i=0; i<iTranCount; i++){
      hideD("trTran"+i,"trTran"+i+"Plus","trTran"+i+"Min");
    }
  }

  <%-- EXPAND ALL VACCINATIONS --%>
  function expandAllVaccinations(){
    for(var i=0; i<iVaccCount; i++){
      showD("trVacc"+i,"trVacc"+i+"Plus","trVacc"+i+"Min");
    }
  }

  <%-- COLLAPSE ALL VACCINATIONS --%>
  function collapseAllVaccinations(){
    for(var i=0; i<iVaccCount; i++){
      hideD("trVacc"+i,"trVacc"+i+"Plus","trVacc"+i+"Min");
    }
  }
</script>

    </body>
</html>
