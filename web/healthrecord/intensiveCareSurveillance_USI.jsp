<%@ page import="java.util.*" %>
<%@ page import="java.text.ParseException" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
    private class USI_DataHolder implements Comparable {
        private int dataSetNr;
        private String date;
        private String time;
        private String updateuserid;
        private Hashtable data;

        public USI_DataHolder(int iDataSetNr){
            this.dataSetNr = iDataSetNr;
            this.data = new Hashtable();
        }

        public int compareTo(Object usi_dataholder) throws ClassCastException {
            if (!(usi_dataholder instanceof USI_DataHolder))
              throw new ClassCastException("An USI_DataHolder object expected.");
            Calendar registered = ((USI_DataHolder) usi_dataholder).getRegisteredOn();
            if(this.getRegisteredOn().before(registered)){
                return 1;
            }else if(this.getRegisteredOn().after(registered)){
                return -1;
            }
            return 0;
        }

        public int getDataSetNr(){
            return this.dataSetNr;
        }

        public Calendar getRegisteredOn(){
            Calendar calNow = Calendar.getInstance();
            String sDate;
            try {
                sDate=this.date.replaceAll("-","/");
                sDate=sDate + " " + this.time;
                calNow.setTime(new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(sDate).getTime()));
            } catch (ParseException e){
                e.printStackTrace();
            }
            return calNow;

        }

        public void setDate(String sDate){
            this.date = sDate;
        }

        public String getDate(){
            return this.date;
        }

        public String getTime(){
            return this.time;
        }

        public void setTime(String sTime){
            this.time = sTime;
        }

        public void setDataSetNr(int iDataSetNr){
            this.dataSetNr = iDataSetNr;
        }

        public void setUpdateUserId(String updateuserid){
            this.updateuserid = updateuserid;
        }

       public String getUpdateUser(){
           if(this.updateuserid!=null && !this.updateuserid.equals("")){
         	   	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
              	String s=ScreenHelper.getFullUserName(this.updateuserid,ad_conn);
              	try{
              		ad_conn.close();
              	}
              	catch(Exception e){
              		e.printStackTrace();
              	}
              	return s;
              
           }else{
              return "";
           }
       }

        public void addItem(String sKey,Object oValue){
            this.data.put(sKey,oValue);
        }

        public Object getItem(String sKey){
            return this.data.get(sKey);
        }

    }



    public USI_DataHolder getUSI_DataHolderFromList(int iDataSetNr,ArrayList data){

        USI_DataHolder tmpData;

        Iterator iter = data.iterator();

        while(iter.hasNext()){
            tmpData = (USI_DataHolder)iter.next();
            if(tmpData.getDataSetNr() == iDataSetNr){
                return tmpData;
            }
        }

        return null;
    }

    public void addItemToDataList(int iDataSetNr,ArrayList data,String sKey,Object oValue){
        USI_DataHolder tmpData;

        Iterator iter = data.iterator();

        while(iter.hasNext()){
            tmpData = (USI_DataHolder)iter.next();
            if(tmpData.getDataSetNr() == iDataSetNr){
                if(sKey.equals("DATE")){
                    tmpData.setDate((String)oValue);
                }else if(sKey.equals("TIME")){
                    tmpData.setTime((String)oValue);
                }else if(sKey.equals("UPDATEUSERID")){
                    tmpData.setUpdateUserId((String)oValue);
                }
                tmpData.addItem(sKey,oValue);
                break;
            }
        }
    }
%>
<%=checkPermission("occup.surveillance.USI","select",activeUser)%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
<%
    Hashtable hListing = new Hashtable();
    hListing.put("3","LACTATE");hListing.put("4","GLUCOSE");hListing.put("5","PHYSIOLOGY");hListing.put("6","SHAEM");
    hListing.put("7","TRANSFUSION");hListing.put("8","BLOOD");hListing.put("9","TOTAL_IN");hListing.put("10","POMPE_SYRINGE_TEXT1");hListing.put("11","POMPE_SYRINGE1");
    hListing.put("12","POMPE_SYRINGE_TEXT2");hListing.put("13","POMPE_SYRINGE2");hListing.put("14","POMPE_SYRINGE_TEXT3");hListing.put("15","POMPE_SYRINGE3");
    hListing.put("16","REMARKS1");hListing.put("17","GLYCEMIE");hListing.put("18","TEMPERATURE");hListing.put("19","GCS_Y");hListing.put("20","GCS_V");
    hListing.put("21","GCS_M");hListing.put("22","ISOCORIE");hListing.put("23","REACTION_LIGHT");hListing.put("24","RC");hListing.put("25","TAS");hListing.put("26","TAD");
    hListing.put("27","TAM");hListing.put("28","PVC");hListing.put("29","RR");hListing.put("30","SAT");hListing.put("31","FIO2");hListing.put("32","L_MIN");
    hListing.put("33","VOIE");hListing.put("34","NEBULISATION");hListing.put("35","CPAP");hListing.put("36","INTUBATION_USI");hListing.put("37","TUBE");hListing.put("38","DAYS_INTUBATION");
    hListing.put("39","TRACHEOSTOMIE");hListing.put("40","DAYS_TRACHEOSTOMIE");hListing.put("41","ASPIRATION");hListing.put("42","VC");hListing.put("43","PC");
    hListing.put("44","PA");hListing.put("45","DAYS_VENTILATION");hListing.put("46","FREQUENCY");hListing.put("47","TIDAL_VOL");hListing.put("48","MIN_VOLUME");
    hListing.put("49","MAX_PRESSION");hListing.put("50","DIURESE"); hListing.put("51","DRAIN_TEXT1");hListing.put("52","DRAIN1");hListing.put("53","DRAIN_TEXT2");
    hListing.put("54","DRAIN2");hListing.put("55","DRAIN_TEXT3"); hListing.put("56","DRAIN3");hListing.put("57","DRAIN_TEXT4");hListing.put("58","DRAIN4");
    hListing.put("59","DRAIN_TEXT5");hListing.put("60","DRAIN5");hListing.put("61","SNG");hListing.put("62","TOTAL_OUT");hListing.put("63","OUT");hListing.put("64","VOMISSEMENTS");
    hListing.put("65","SELLES");hListing.put("66","REMARKS2");hListing.put("67","BILAN_IN_OUT");hListing.put("68","NURSE_NOTES");hListing.put("69","REMARKS3");

    final int iVALUES = 69;

    Collection cItems = ((TransactionVO)transaction).getItems();
    Iterator iter = cItems.iterator();

    ItemVO item;

    Hashtable hShowValues = new Hashtable();

    String sKey;
    String sItemType;
    String sItemValue;
    String sInputNr;

    ArrayList usi_data_holders = new ArrayList();

    USI_DataHolder tmpData;

    while(iter.hasNext()){
        item = (ItemVO)iter.next();
        sItemType = checkString(item.getType());
        sItemValue = checkString(item.getValue());

        if(!(sItemType.lastIndexOf("-")== -1)){
            sInputNr = sItemType.substring(sItemType.lastIndexOf("-")+1,sItemType.length());

            sKey = sItemType.substring("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_".length(),sItemType.lastIndexOf("-"));
            if(sItemValue.length() > 0){
                tmpData = getUSI_DataHolderFromList(Integer.parseInt(sInputNr),usi_data_holders);
                if(tmpData==null){
                    usi_data_holders.add(new USI_DataHolder(Integer.parseInt(sInputNr)));
                }
                addItemToDataList(Integer.parseInt(sInputNr),usi_data_holders,sKey,sItemValue);

                hShowValues.put(sKey,Boolean.TRUE);
            }
        }
    }

    Collections.sort(usi_data_holders);
%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onkeyup="setSaveButton(event);">
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>" id="context_department"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>" id="context_context"/>

    <input type="hidden" name="Action" value="SAVE">
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <%-- DATE --%>
    <table class="list" width="100%" cellspacing="1">                        
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)' <%if(usi_data_holders.size() > 0) out.print("readonly");%>>
                <% if(usi_data_holders.size() == 0){%><script>writeTranDate();</script><%}%>
            </td>
        </tr>
    </table>
    <br/>
    
    <table class="list" cellpadding="0" cellspacing="1" border="0">
    <%
        if(usi_data_holders.size() > 0){
            String sKeyValue;
            String sValue;

            USI_DataHolder usiData;
            Iterator iterA;

            iterA = usi_data_holders.iterator();
            out.print("<tr>" +
                       "<td width='200px' align='center' valign='middle'>" + getTran("openclinic.chuk","usi_add_surveillance",sWebLanguage) +
                        " &nbsp;<img src='" + sCONTEXTPATH + "/_img/icon_new.gif' alt='" + getTranNoLink("web","new",sWebLanguage) + "' style='vertical-align:-3px;' onmouseout='this.style.cursor = \"default\";' onmouseover='this.style.cursor = \"pointer\";' onclick='addSurveillance();'>" +
                       "</td>"
                      );
            while(iterA.hasNext()){
                usiData =(USI_DataHolder)iterA.next();
                out.print("<td align='center'>" +
                           "<table cellpadding='0' cellspacing='0' style='border: 1px solid black;' width='100%' height='50'>" +
                            "<tr>" +
                             "<td align='center'>&nbsp;" + usiData.getDate() + "&nbsp;" + usiData.getTime()+"&nbsp;&nbsp;"+
                              "<img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' style='vertical-align:-3px;' alt='" + getTranNoLink("web","edit",sWebLanguage) + "' onmouseout='this.style.cursor = \"default\";' onmouseover='this.style.cursor = \"pointer\";' onclick='editSurveillance(" + usiData.getDataSetNr() + ");'>&nbsp;&nbsp;"+
                              "<img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' style='vertical-align:-3px;' alt='" + getTranNoLink("web","delete",sWebLanguage) + "' onmouseout='this.style.cursor = \"default\";' onmouseover='this.style.cursor = \"pointer\";' onclick='deleteSurveillance(" + usiData.getDataSetNr() + ");'>"+
                             "</td>" +
                            "</tr>" +
                            "<tr>" +
                             "<td align='center'>" + getTran("openclinic.chuk","edited_by",sWebLanguage) + ": " + usiData.getUpdateUser() + "</td>" +
                            "</tr>" +
                           "</table>" +
                          "</td>"
                         );
            }
            out.print("</tr>");

            for(int x = 1 ; x <= iVALUES ; x++){
                sKeyValue = checkString((String)hListing.get(Integer.toString(x)));
                
                if(hShowValues.get(sKeyValue)!=null && ((Boolean)hShowValues.get(sKeyValue)).booleanValue()){
                    out.print("<tr><td class='admin' width='200' nowrap>" + getTran("openclinic.chuk",sKeyValue.toLowerCase(),sWebLanguage) + "</td>");
                    
                    iterA = usi_data_holders.iterator();
                    while(iterA.hasNext()){
                        usiData =(USI_DataHolder)iterA.next();
                        sValue = checkString((String)usiData.getItem(sKeyValue));
                        if(sValue.startsWith("usi.surveillance.") || sValue.startsWith("medwan.common.")){
                            sValue = getTran("web.occup",sValue,sWebLanguage);
                        }
                        if(sValue.equals(""))sValue = "&nbsp;";
                        out.print("<td class='admin2' width='250px'>" + sValue + "</td>");
                    }
                    
                    out.print("</tr>");
                }
            }
        }
    %>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%
            if(activeUser.getAccessRight("occup.surveillance.USI.add") || activeUser.getAccessRight("occup.surveillance.USI.edit")) {
                if(usi_data_holders.size() == 0){
	                %>
		                <INPUT class="button" type="button" name="add_surveillance" value="<%=getTran("openclinic.chuk","usi_add_surveillance",sWebLanguage)%>" onclick="addSurveillance();"/>
		                <INPUT class="button" type="button" name="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="doSubmit();"/>
		            <%
                }
                else{
            	    %>
	            	    <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>&nbsp;
	            	    
	                    <select class="text" name="PrintLanguage">
	            	        <%
	            		        // print language
	            		        String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));
	            		        if(sPrintLanguage.length()==0){
	            		            sPrintLanguage = activePatient.language;
	            		        }
	
	            	            // supported languages
	            	            String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
	            	            if(supportedLanguages.length() == 0) supportedLanguages = "nl,fr";
	            	            supportedLanguages = supportedLanguages.toLowerCase();
	            	
	            	            // print language selector
	            	            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
	            	            String tmpLang;
	            	            while(tokenizer.hasMoreTokens()){
	            	                tmpLang = tokenizer.nextToken();
	            	                tmpLang = tmpLang.toUpperCase();
	            	
	            	                %><option value="<%=tmpLang%>" <%=(sPrintLanguage.equalsIgnoreCase(tmpLang)?"selected":"")%>><%=tmpLang%></option><%
	            	            }
	            	        %>
	            	    </select>
	            	        
	                    <INPUT class="button" type="button" value="<%=getTran("Web","print",sWebLanguage)%>" onclick="doPrint(transactionForm.PrintLanguage.options[transactionForm.PrintLanguage.selectedIndex].text);"/>&nbsp;
	                <%
                }
            }
        %>

        <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();"/>
    <%=ScreenHelper.alignButtonsStop()%>
    
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- DO PRINT --%>
  function doPrint(printLang){
	var url = '<%=sCONTEXTPATH%>/healthrecord/createPdf.jsp?actionField=print&tranAndServerID_1=<%=((TransactionVO)transaction).getTransactionId()%>_<%=((TransactionVO)transaction).getServerId()%>&PrintLanguage='+printLang+'&ts=<%=getTs()%>';
	window.open(url,'newwindow','height=600,width=850,toolbar=yes,status=yes,scrollbars=yes,resizable=yes,menubar=yes');
  }
      
  <%-- SUBMIT FORM --%>
  function submitForm(){
	document.getElementById('transactionForm').save.disabled = true;
	document.getElementById('transactionForm').save.disabled = true;
    document.getElementById('transactionForm').submit();
  }

  function addSurveillance(){
	var url = "<c:url value='/popup.jsp'/>?Page=/healthrecord/intensiveCareSurveillance_USI_add.jsp"+
              "&trandate="+document.getElementById('trandate').value+"&CONTEXT_CONTEXT="+document.getElementById('context_context').value+
              "&CONTEXT_DEPARTMENT="+document.getElementById('context_department').value;	
    window.open(url,"","toolbar=no, status=no, scrollbars=no, resizable=yes, menubar=no");
  }

  function deleteSurveillance(set){
    var popupUrl = "<%=sCONTEXTPATH%>/popup.jsp?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalitiesIE = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    var answer;
    if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,'',modalitiesIE);
    }
    else{
      answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }

    if(answer==1){
      window.open("<c:url value='/popup.jsp'/>?Page=/healthrecord/intensiveCareSurveillance_USI_add.jsp&trandate=<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>&CONTEXT_CONTEXT="+document.getElementById('context_context').value+"&CONTEXT_DEPARTMENT="+document.getElementById('context_department').value + "&DataSetNr="+set+"&Action=DELETE","","toolbar=no, status=no, scrollbars=no, resizable=no, menubar=no");
    }
  }

  function editSurveillance(set){
    window.open("<c:url value='/popup.jsp'/>?Page=/healthrecord/intensiveCareSurveillance_USI_add.jsp&trandate=<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>&CONTEXT_CONTEXT="+document.getElementById('context_context').value+"&CONTEXT_DEPARTMENT="+document.getElementById('context_department').value+"&DataSetNr="+set,""," toolbar=no, status=no, scrollbars=no, resizable=yes, menubar=no");
  }

  function doBack(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }
</script>