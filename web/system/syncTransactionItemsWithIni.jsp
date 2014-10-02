<%@page import="java.io.*,
                be.openclinic.system.TransactionItem,java.util.Enumeration,java.util.Properties,java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
  final String INIFILENAME = "/_common/xml/TransactionItems.ini";
  String action = checkString(request.getParameter("action"));
  String dataDirection = checkString(request.getParameter("dataDirection"));
%>
<a name="top"/>
<form name="transactionForm" method="POST">
<input type="hidden" name="action">
<%-- SELECT ACTION TABLE ---------------------------------------------------------------------------------------------%>
<%=writeTableHeader("Web.manage","SynchronizeTransactionItemsWithIni",sWebLanguage,"main.do?Page=system/menu.jsp")%>
<table width="100%" class="menu" cellspacing="1">
    <tr>
        <td>
            <input type="radio" name="dataDirection" id="dataDirection1" onDblClick="uncheckRadio(this);" value="dbToIni" <%if(dataDirection.equals("dbToIni")){out.print(" checked");}%>>
            <label for="dataDirection1">In Db, not in ini file (DB to INI)</label>
            &nbsp;&nbsp;
            <input type="radio" name="dataDirection" id="dataDirection2" onDblClick="uncheckRadio(this);" value="iniToDb" <%if(dataDirection.equals("iniToDb")){out.print(" checked");}%>>
            <label for="dataDirection2">In ini file, not in Db (INI to DB)</label>
            &nbsp;&nbsp;
            <input type="button" class="button" name="FindButton" value="<%=getTranNoLink("Web","Find",sWebLanguage)%>" onclick="doSubmit('find')">&nbsp;
            <input class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
        </td>
    </tr>
</table>
<%
    // db fields
    String tranId = null;
    String itemId = null;
    String defaultValue;
    String modifier;

    //####################################################################################################################
    //### INSERT #########################################################################################################
    //####################################################################################################################
    if (action.equals("insert")) {
        //*** In Db, not in ini (DB to INI) ********************************************************************************
        if (dataDirection.equals("dbToIni")) {
            // ADD TO INI FILE
            FileWriter csvWriter = new FileWriter(sAPPFULLDIR + INIFILENAME, true);
            FileWriter csvWriter2 = new FileWriter(sAPPFULLDIR+INIFILENAME+"new");
            String paramName;
            String paramValue;

            Enumeration e = request.getParameterNames();
            while (e.hasMoreElements()) {
                paramName = (String) e.nextElement();
                paramValue = checkString(request.getParameter(paramName));

                if (paramName.startsWith("checkbox$") && paramValue.equals("on")) {
                    paramName = paramName.substring(9);
                    tranId = paramName.substring(0, paramName.indexOf("$"));
                    itemId = paramName.substring(paramName.indexOf("$") + 1);

                    TransactionItem objTI = TransactionItem.selectTransactionItem(tranId, itemId);

                    if (objTI != null) {
                        defaultValue = checkString(objTI.getDefaultValue());
                        modifier = checkString(objTI.getModifier());

                        csvWriter.write(tranId + "$" + itemId + "=" + defaultValue + "$" + modifier + "\r\n");
                        csvWriter.flush();
                    }
                }
            }

            csvWriter.close();
            //Now clean the ini-file
            FileReader reader = new FileReader(sAPPFULLDIR+INIFILENAME);
            BufferedReader r = new BufferedReader(reader);
            SortedSet labels = new TreeSet();
			try{
                while(true){
					String line=r.readLine();
					if(line==null){
						break;
					}
					else if (line.indexOf("$")>0){
						labels.add(line.trim());
					}
                }
			}
			catch(IOException eio){
				eio.printStackTrace();	
			}
			r.close();
			Iterator i = labels.iterator();
			while(i.hasNext()){
				csvWriter2.write(i.next()+"\r\n");
			}
            csvWriter2.flush();
            csvWriter2.close();
            File original = new File(sAPPFULLDIR+INIFILENAME);
            original.delete();
            new File(sAPPFULLDIR+INIFILENAME+"new").renameTo(new File(sAPPFULLDIR+INIFILENAME));
        }
        //*** In ini, not in Db (INI to DB) ********************************************************************************
        else if (dataDirection.equals("iniToDb")) {
            // ADD TO DB
            FileInputStream iniIs = new FileInputStream(sAPPFULLDIR + INIFILENAME);
            Properties iniProps = new Properties();
            iniProps.load(iniIs);
            iniIs.close();

            String paramName, paramValue, iniValue;
            TransactionItem objTI;

            Enumeration e = request.getParameterNames();
            while (e.hasMoreElements()) {
                paramName = (String) e.nextElement();
                paramValue = checkString(request.getParameter(paramName));

                if (paramName.startsWith("checkbox$") && paramValue.equals("on")) {
                    paramName = paramName.substring(9);
                    tranId = paramName.substring(0, paramName.indexOf("$"));
                    itemId = paramName.substring(paramName.indexOf("$") + 1);

                    // check existence before inserting a new record

                    if (!TransactionItem.exists(tranId, itemId)) {
                        iniValue = iniProps.getProperty(tranId + "$" + itemId);
                        defaultValue = iniValue.substring(0, iniValue.indexOf("$"));
                        modifier = iniValue.substring(iniValue.indexOf("$") + 1, iniValue.length());

                        objTI = new TransactionItem();
                        objTI.setTransactionTypeId(tranId);
                        objTI.setItemTypeId(itemId);
                        objTI.setDefaultValue(defaultValue);
                        objTI.setModifier(modifier);

                        TransactionItem.addTransactionItem(objTI);
                    }
                }
            }
        }
%>
      <br>
      <%=getTran("Web","DataIsSaved",sWebLanguage)%>
    <%
    }
    //####################################################################################################################
    //### DELETE #########################################################################################################
    //####################################################################################################################
    else if (action.equals("delete")) {
        Vector recsToBeDeleted = new Vector();
        String paramName;
        String paramValue;
        String lineID;

        // PUT ASIDE RECORDS SPECIFIED FOR DELETION IN REQUEST
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            paramName = (String) e.nextElement();
            paramValue = checkString(request.getParameter(paramName));

            if (paramName.startsWith("checkbox$") && paramValue.equals("on")) {
                paramName = paramName.substring(9);
                tranId = paramName.substring(0, paramName.indexOf("$"));
                itemId = paramName.substring(paramName.indexOf("$") + 1);

                recsToBeDeleted.add(tranId + "$" + itemId);
            }
        }

        //*** In Db, not in ini (DB to INI) ********************************************************************************
        if (dataDirection.equals("dbToIni")) {
            // DELETE FROM DB
            TransactionItem.deleteTransactionItem(tranId, itemId);
            for (int i = 0; i < recsToBeDeleted.size(); i++) {
                lineID = (String) recsToBeDeleted.get(i);
                TransactionItem.deleteTransactionItem(lineID.substring(0, lineID.indexOf("$")), lineID.substring(lineID.indexOf("$") + 1));
            }
        }
        //*** In ini, not in Db (INI to DB) ********************************************************************************
        else if (dataDirection.equals("iniToDb")) {
            // DELETE FROM INI FILE
            FileInputStream iniIs = new FileInputStream(sAPPFULLDIR + INIFILENAME);
            Properties iniProps = new Properties();
            iniProps.load(iniIs);
            iniIs.close();

            FileWriter csvWriter = new FileWriter(sAPPFULLDIR + INIFILENAME, false); // first clear file, than append
            String lineValue;

            // REWRITE INIFILE but SKIP RECORDS SPECIFIED IN VECTOR
            Enumeration e3 = iniProps.propertyNames();
            while (e3.hasMoreElements()) {
                lineID = (String) e3.nextElement();
                lineValue = iniProps.getProperty(lineID);

                if (!recsToBeDeleted.contains(lineID)) {
                    csvWriter.write(lineID + "=" + lineValue + "\r\n");
                    csvWriter.flush();
                } else {
                    recsToBeDeleted.remove(lineID);
                }
            }

            csvWriter.close();
        }
    %>
      <br>
      <%=getTran("Web","DataIsDeleted",sWebLanguage)%>
    <%
  }
  //####################################################################################################################
  //### FIND (DISPLAY DIFFERENCES) #####################################################################################
  //####################################################################################################################
  else if(action.equals("find")){
    %>
    <br>
    <%-- BUTTONS at TOP ----------------------------------------------------------------------------------------------%>
    <table width="100%" cellspacing="1">
      <tr>
        <td>
          <a href="#" onclick="checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
          <a href="#" onclick="checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
        </td>
        <td align="right">
          <a href='#bottom'><img src='<c:url value='/_img/themes/default/bottom.gif'/>' class='link' border="0"></a>
        </td>
      </tr>
    </table>
    <%-- DISPLAY RECORDS (between buttons) ---------------------------------------------------------------------------%>
    <table width="100%" class="list" cellspacing="1" onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
      <tr><td width="16"></td><td></td><td width="99%"></td></tr>
    <%
        // load content of ini-file in props object, if file ini-file found.
        // If ini-file not found, new File is created in catch.
        FileInputStream iniIs;
        try {
            iniIs = new FileInputStream(sAPPFULLDIR + INIFILENAME);
            Properties iniProps = new Properties();
            iniProps.load(iniIs);
            iniIs.close();
            Debug.println("DataDirection=" + dataDirection);

            //*** In Db, not in ini (DB TO INI) ******************************************************************************
            if (dataDirection.equals("dbToIni")) {
                int counter = 0;
                String iniValue;
                String style;

                Vector vTI;
                vTI = TransactionItem.selectTransactionItems();
                Iterator iter = vTI.iterator();
                TransactionItem objTI;

                while (iter.hasNext()) {
                    objTI = (TransactionItem) iter.next();
                    tranId = checkString(objTI.getTransactionTypeId());
                    itemId = checkString(objTI.getItemTypeId());

                    // only list record if not in ini, so check existence in ini.
                    iniValue = checkString(iniProps.getProperty(tranId + "$" + itemId));

                    if (iniValue.equals("")) {
                        defaultValue = checkString(objTI.getDefaultValue());
                        modifier = checkString(objTI.getModifier());
                        counter++;

                        style = (counter % 2 == 0 ? "" : " class='list'");
    %>
              <tr<%=style%>>
                <td rowspan="4"><input type="checkbox" name="checkbox$<%=tranId+"$"+itemId%>"></td>
                <td><b>transactionTypeId&nbsp;</b></td><td><%=tranId%></td>
              </tr>
              <tr<%=style%>><td><b>itemTypeId</b></td><td><%=itemId%></td></tr>
              <tr<%=style%>><td><b>defaultValue</b></td><td><%=defaultValue%></td></tr>
              <tr<%=style%>><td><b>modifier</b></td><td><%=modifier%></td></tr>
            <%
          }
        }
      }
      //*** In ini, not in DB (INI TO DB) ******************************************************************************
      else if(dataDirection.equals("iniToDb")){
        String iniID;
        String iniValue;
        int counter = 0;
        String style;
		  Hashtable transactionItems = new Hashtable();
          Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
          PreparedStatement ps = oc_conn.prepareStatement("select transactionTypeID,ItemTypeID from TransactionItems");
          ResultSet rs = ps.executeQuery();
          while (rs.next()){
        	  transactionItems.put(rs.getString("transactionTypeID").toLowerCase()+"$"+rs.getString("itemTypeID").toLowerCase(),"1");
          }
          rs.close();
          ps.close();
          oc_conn.close();

        Enumeration e2 = iniProps.propertyNames();
        while(e2.hasMoreElements()){
          iniID = (String)e2.nextElement();
          tranId = iniID.substring(0,iniID.indexOf("$"));
          itemId = iniID.substring(iniID.indexOf("$")+1,iniID.length());

          // only list record if not in DB, so check existence in DB
          
          if(transactionItems.get(tranId.toLowerCase()+"$"+itemId.toLowerCase())==null){
            iniValue     = iniProps.getProperty(iniID);
            defaultValue = iniValue.substring(0,iniValue.indexOf("$"));
            modifier     = iniValue.substring(iniValue.indexOf("$")+1,iniValue.length());
            counter++;

            style = (counter%2==0?"":" class='list'");
            %>
              <tr<%=style%>>
                <td rowspan="4"><input type="checkbox" name="checkbox$<%=tranId+"$"+itemId%>"></td>
                <td><b>transactionTypeId&nbsp;</b></td><td><%=tranId%></td>
              </tr>
              <tr<%=style%>><td><b>itemTypeId</b></td><td><%=itemId%></td></tr>
              <tr<%=style%>><td><b>defaultValue</b></td><td><%=defaultValue%></td></tr>
              <tr<%=style%>><td><b>modifier</b></td><td><%=modifier%></td></tr>
            <%
          }
        }
      }
    %>
    </table>
    <%-- BUTTONS at BOTTOM -------------------------------------------------------------------------------------------%>
    <table width="100%" cellspacing="1">
      <tr>
        <td>
          <a href="#" onclick="checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
          <a href="#" onclick="checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
        </td>
        <td align="right">
          <a href='#top'><img src='<c:url value='/_img/themes/default/top.gif'/>' class='link' border="0"></a>
        </td>
      </tr>
      <tr>
        <td colspan="2">
          <input type="button" class="button" name="InsertButton" value="<%=getTranNoLink("Web","Add",sWebLanguage)%>" onclick="doSubmit('insert')">
          <input type="button" class="button" name="DeleteButton" value="<%=getTranNoLink("Web","Delete",sWebLanguage)%>" onclick="doSubmit('delete')">
        </td>
      </tr>
    </table>
    <%
    }
    catch(FileNotFoundException e){
      // create the file that isn't found
      new FileOutputStream(sAPPFULLDIR+INIFILENAME);
    }
  }
%>
</form>
<%-- link to manage transactionItems --%>
<%=ScreenHelper.alignButtonsStart()%>
  <img src='<c:url value="/_img/themes/default/pijl.gif"/>'>
  <a  href="<c:url value='/main.do'/>?Page=system/manageTransactionItems.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web","managetransactionitems",sWebLanguage)%></a>&nbsp;
<%=ScreenHelper.alignButtonsStop()%>
<a name="bottom"/>
<%-- SCRIPTS ---------------------------------------------------------------------------------------------------------%>
<script>
  if(document.getElementById('dataDirection1').checked ||
     document.getElementById('dataDirection2').checked){
    checkAll(true);
  }

  function doSubmit(action){
    if(action=="insert"){
        transactionForm.action.value = action;
        transactionForm.submit();
    }
    else if(action=="find"){
      if(document.getElementById('dataDirection1').checked ||
         document.getElementById('dataDirection2').checked){
        transactionForm.action.value = action;
        transactionForm.submit();
      }
      else{
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=Web.manage&labelID=chooseDataDirection";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","chooseDataDirection",sWebLanguage)%>");
      }
    }
    else if(action=="delete"){
      for(i=0; i<transactionForm.elements.length; i++){
        if(transactionForm.elements[i].type=="checkbox" && transactionForm.elements[i].name.indexOf("checkbox$")>-1){
          if(transactionForm.elements[i].checked){
            if(yesnoDialog("Web","areYouSureToDelete")){
              transactionForm.action.value = action;
              transactionForm.submit();
            }
            break;
          }
        }
      }
    }
    else{
      transactionForm.action.value = action;
      transactionForm.submit();
    }
  }

  function checkAll(setchecked){
    for(i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        transactionForm.elements[i].checked = setchecked;
      }
    }
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
</script>