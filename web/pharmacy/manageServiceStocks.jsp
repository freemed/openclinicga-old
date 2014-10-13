<%@page import="be.openclinic.pharmacy.ServiceStock,
                java.util.StringTokenizer,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("pharmacy.manageservicestocks","select",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- ADD AUTHORIZED USER ---------------------------------------------------------------------
    private String addAuthorizedUser(int userIdx, String userName, String sWebLanguage){
        StringBuffer html = new StringBuffer();

        html.append("<tr id='rowAuthorizedUsers"+userIdx+"'>")
             .append("<td width='18'>")
              .append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' onclick='deleteAuthorizedUser(rowAuthorizedUsers"+userIdx+");' class='link' alt='"+getTranNoLink("web","delete",sWebLanguage)+"'>")
             .append("</td>")
             .append("<td>"+userName+"</td>")
            .append("</tr>");

        return html.toString();
    }

    //--- OBJECTS TO HTML -------------------------------------------------------------------------
    private StringBuffer objectsToHtml(Vector objects, String sWebLanguage, User activeUser){
        StringBuffer html = new StringBuffer();
        Vector authorizedUserIds;
        String sClass = "1", sServiceStockUid = "", sServiceUid = "", sServiceName = "", sAuthorizedUserIds,
               sManagerUid = "", sPreviousManagerUid = "", sManagerName = "";
        StringTokenizer tokenizer;

        // frequently used translations
        String detailsTran        = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran         = getTranNoLink("Web","delete",sWebLanguage),
               productStockTran   = getTranNoLink("web.manage","productstockmanagement",sWebLanguage),
               calculateOrderTran = getTranNoLink("Web.manage","calculateOrder",sWebLanguage);

        // run thru found serviceStocks
        ServiceStock serviceStock;
        for(int i=0; i<objects.size(); i++){
            serviceStock = (ServiceStock) objects.get(i);
            sServiceStockUid = serviceStock.getUid();

            // translate service name
            sServiceUid = serviceStock.getServiceUid();
            sServiceName = getTranNoLink("Service",sServiceUid,sWebLanguage);

            // only search manager-name when different manager-UID
            sManagerUid = checkString(serviceStock.getStockManagerUid());
            if(sManagerUid.length() > 0){
                if(!sManagerUid.equals(sPreviousManagerUid)){
                    sPreviousManagerUid = sManagerUid;
                    sManagerName = ScreenHelper.getFullUserName(sManagerUid);
                }
            }

            // number of products in serviceStock
            int productCount = ServiceStock.getProductStockCount(sServiceStockUid);

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            //*** display stock in one row ***
            html.append("<tr class='list"+sClass+"' title='"+detailsTran+"'>")
                 .append("<td>");
            
            if((serviceStock.isAuthorizedUser(activeUser.userid) || activeUser.getAccessRight("sa")) && activeUser.getAccessRight("pharmacy.manageservicestocks.delete")){
                html.append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' onclick=\"doDelete('"+sServiceStockUid+"');\" title='"+deleteTran+"'/>").
                     append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' class='link' onclick=\"printFiche('"+sServiceStockUid+"','"+serviceStock.getName()+"');\" title='"+getTranNoLink("web","stockfiche",sWebLanguage)+"'/>");
            }
            
            if(serviceStock.getNosync()==0){
                html.append("&nbsp;<img src='"+sCONTEXTPATH+"/_img/icons/icon_sync.gif' class='link' alt='"+getTranNoLink("web","sync",sWebLanguage)+"'/>");
            }
            if(serviceStock.hasOpenDeliveries()){
                html.append("&nbsp;<img src='"+sCONTEXTPATH+"/_img/icons/icon_incoming.gif' class='link' alt='"+getTranNoLink("web","incoming",sWebLanguage)+"'' onclick='javascript:bulkReceive(\""+serviceStock.getUid()+"\");'/></a>");
            }
            html.append("</td>");
            
            html.append("<td onclick=\"doShowDetails('"+sServiceStockUid+"');\">"+serviceStock.getName()+"</td>")
                .append("<td onclick=\"doShowDetails('"+sServiceStockUid+"');\">"+sServiceName+"</td>")
                .append("<td onclick=\"doShowDetails('"+sServiceStockUid+"');\">"+sManagerName+"</td>")
                .append("<td onclick=\"doShowDetails('"+sServiceStockUid+"');\">"+productCount+"</td>");

            // display "manage product stocks"-button when user is authorized
            if(serviceStock.isAuthorizedUser(activeUser.userid)){
                html.append("<td>")
                     .append("<input type='button' class='button' value='"+calculateOrderTran+"' onclick=\"doCalculateOrder('"+sServiceStockUid+"','"+sServiceName+"');\">&nbsp;")
                     .append("<input type='button' class='button' value='"+productStockTran+"' onclick=\"displayProductStockManagement('"+sServiceStockUid+"','"+sServiceUid+"');\">&nbsp;")
                    .append("</td>");
            } 
            else{
                html.append("<td onclick=\"doShowDetails('"+sServiceStockUid+"');\">&nbsp;</td>");
            }

            html.append("</tr>");
        }

        return html;
    }
%>

<%
    String sDefaultSortCol = "OC_STOCK_NAME",
           sDefaultSortDir = "ASC",
           centralPharmacyCode = MedwanQuery.getInstance().getConfigString("centralPharmacyCode");

    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0){
    	sAction="find";
    }

    // retreive form data
    String sEditStockUid           = checkString(request.getParameter("EditStockUid")),
           sEditStockName          = checkString(request.getParameter("EditStockName")),
           sEditServiceUid         = checkString(request.getParameter("EditServiceUid")),
           sEditBegin              = checkString(request.getParameter("EditBegin")),
           sEditEnd                = checkString(request.getParameter("EditEnd")),
           sEditManagerUid         = checkString(request.getParameter("EditManagerUid")),
           sEditDefaultSupplierUid = checkString(request.getParameter("EditDefaultSupplierUid")),
           sEditOrderPeriod        = checkString(request.getParameter("EditOrderPeriodInMonths")),
    	   sEditNosync        	   = checkString(request.getParameter("EditNosync"));
    
    	   if(sEditNosync.equalsIgnoreCase("")){
    		   sEditNosync = "0";
    	   }
	
    // afgeleide data
    String sEditServiceName         = checkString(request.getParameter("EditServiceName")),
           sEditManagerName         = checkString(request.getParameter("EditManagerName")),
           sEditDefaultSupplierName = checkString(request.getParameter("EditDefaultSupplierName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************* pharmacy/manageServiceStocks.jsp *******************");
        Debug.println("sEditStockUid        : "+sEditStockUid);
        Debug.println("sEditStockName       : "+sEditStockName);
        Debug.println("sEditServiceUid      : "+sEditServiceUid);
        Debug.println("sEditBegin           : "+sEditBegin);
        Debug.println("sEditEnd             : "+sEditEnd);
        Debug.println("sEditManagerUi       : "+sEditManagerUid);
        Debug.println("sEditDefSupplierUid  : "+sEditDefaultSupplierUid);
        Debug.println("sEditOrderPeriod     : "+sEditOrderPeriod);
        Debug.println("sEditServiceName     : "+sEditServiceName);
        Debug.println("sEditManagerName     : "+sEditManagerName);
        Debug.println("sEditDefSupplierName : "+sEditDefaultSupplierName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String msg = "", sFindStockName = "", sFindServiceUid = "", sFindServiceName = "",
           sFindBegin = "", sFindEnd = "", sFindManagerUid = "", sSelectedStockName = "",
           sSelectedServiceUid = "", sSelectedBegin = "", sSelectedEnd = "", sSelectedManagerUid = "",
           sSelectedServiceName = "", sSelectedManagerName = "", authorizedUserId = "",
           authorizedUserName = "", sFindDefaultSupplierUid = "", sFindDefaultSupplierName = "",
           sSelectedDefaultSupplierUid = "", sSelectedDefaultSupplierName = "", sSelectedOrderPeriod = "", sSelectedNosync="";

    StringBuffer stocksHtml = null;
    int foundStockCount = 0, authorisedUsersIdx = 1;
    SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
    StringBuffer authorizedUsersHTML = new StringBuffer(),
                 authorizedUsersJS = new StringBuffer(),
                 authorizedUsersDB = new StringBuffer();

    // display options
    boolean displayEditFields = false, displayFoundRecords = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if(sDisplaySearchFields.length()==0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");
    Debug.println("@@@ displaySearchFields : "+displaySearchFields);

    String sDisplayActiveServiceStocks = checkString(request.getParameter("DisplayActiveServiceStocks"));
    if(sDisplayActiveServiceStocks.length()==0) sDisplayActiveServiceStocks = "true"; // default
    boolean displayActiveServiceStocks = sDisplayActiveServiceStocks.equalsIgnoreCase("true");
    Debug.println("@@@ displayActiveServiceStocks : "+displayActiveServiceStocks);

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = sDefaultSortCol;

    // sortDir
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length()==0) sSortDir = sDefaultSortDir;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditStockUid.length()>0){
        // create service stock
        ServiceStock stock = new ServiceStock();
        stock.setUid(sEditStockUid);
        stock.setName(sEditStockName);
        stock.setServiceUid(sEditServiceUid);
        if(sEditBegin.length() > 0)       stock.setBegin(ScreenHelper.parseDate(sEditBegin));
        if(sEditEnd.length() > 0)         stock.setEnd(ScreenHelper.parseDate(sEditEnd));
        if(sEditOrderPeriod.length() > 0) stock.setOrderPeriodInMonths(Integer.parseInt(sEditOrderPeriod));
        if(sEditNosync.length() > 0) stock.setNosync(Integer.parseInt(sEditNosync));
        stock.setStockManagerUid(sEditManagerUid);
        stock.setDefaultSupplierUid(sEditDefaultSupplierUid);

        // authorized users
        AdminPerson authorizedUserObj;
        String authorizedUserIds = checkString(request.getParameter("EditAuthorizedUsers"));
        if(authorizedUserIds.length() > 0){
            authorisedUsersIdx = 1;
            StringTokenizer idTokenizer = new StringTokenizer(authorizedUserIds,"$");
            while(idTokenizer.hasMoreTokens()){
                authorizedUserId = idTokenizer.nextToken();
                authorizedUserObj = AdminPerson.getAdminPerson(authorizedUserId);
                stock.addAuthorizedUser(authorizedUserObj);
            }
        }

        stock.setUpdateUser(activeUser.userid);

        // does stock exist ?
        String existingStockUid = stock.exists();
        boolean stockExists = existingStockUid.length()>0;

        if(sEditStockUid.equals("-1")){
            //***** insert new stock *****
            if(!stockExists){
                stock.store();

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web","dataissaved",sWebLanguage);
            }
            //***** reject new addition thru update *****
            else{
                // show rejected data
                sAction = "showDetailsAfterAddReject";
                msg = "<font color='red'>"+getTran("web.manage","stockexists",sWebLanguage)+"</font>";
            }
        }
        else{
            //***** update existing stock *****
            if(!stockExists){
                stock.store();

                // show saved data
                sAction = "findShowOverview"; // showDetails
                msg = getTran("web","dataissaved",sWebLanguage);
            }
            //***** reject double record thru update *****
            else{
                if(sEditStockUid.equals(existingStockUid)){
                    // nothing : just updating a record with its own data
                    if(stock.changed()){
                        stock.store();
                        msg = getTran("web","dataissaved",sWebLanguage);
                    }
                    sAction = "findShowOverview"; // showDetails
                }
                else{
                    // tried to update one stock with exact the same data as an other stock
                    // show rejected data
                    sAction = "showDetailsAfterUpdateReject";
                    msg = "<font color='red'>"+getTran("web.manage","stockexists",sWebLanguage)+"</font>";
                }
            }
        }

        sEditStockUid = stock.getUid();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete") && sEditStockUid.length()>0){
        ServiceStock.deleteProductStocks(sEditStockUid);
        ServiceStock.delete(sEditStockUid);
        msg = getTran("web","dataisdeleted",sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- SORT ------------------------------------------------------------------------------------
    if(sAction.equals("sort")){
        displayEditFields = false;
        sAction = "find";
    }

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.startsWith("find")){
        displayActiveServiceStocks = false;
        displayEditFields = false;
        displayFoundRecords = true;

        if(sAction.equals("findShowOverview")){
            displaySearchFields = true;
        }

        // get data from form
        sFindStockName          = checkString(request.getParameter("FindStockName"));
        sFindBegin              = checkString(request.getParameter("FindBegin"));
        sFindEnd                = checkString(request.getParameter("FindEnd"));
        sFindManagerUid         = checkString(request.getParameter("FindManagerUid"));
        sFindServiceUid         = checkString(request.getParameter("FindServiceUid"));
        sFindDefaultSupplierUid = checkString(request.getParameter("FindDefaultSupplierUid"));

        Vector serviceStocks = ServiceStock.find(sFindStockName,sFindServiceUid,sFindBegin,sFindEnd,
                                                 sFindManagerUid,sFindDefaultSupplierUid,sSortCol,sSortDir);
        stocksHtml = objectsToHtml(serviceStocks,sWebLanguage,activeUser);
        foundStockCount = serviceStocks.size();
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        displayEditFields = true;
        displaySearchFields = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            ServiceStock serviceStock = ServiceStock.get(sEditStockUid);

            if(serviceStock!=null){
                sSelectedStockName          = checkString(serviceStock.getName());
                sSelectedServiceUid         = checkString(serviceStock.getServiceUid());
                sSelectedManagerUid         = checkString(serviceStock.getStockManagerUid());
                sSelectedDefaultSupplierUid = checkString(serviceStock.getDefaultSupplierUid());
                sSelectedOrderPeriod        = (serviceStock.getOrderPeriodInMonths()<0?"":serviceStock.getOrderPeriodInMonths()+"");
				sSelectedNosync				= serviceStock.getNosync()+"";

                // format dates
                java.util.Date tmpDate = serviceStock.getBegin();
                if(tmpDate!=null) sSelectedBegin = ScreenHelper.formatDate(tmpDate);

                tmpDate = serviceStock.getEnd();
                if(tmpDate!=null) sSelectedEnd = ScreenHelper.formatDate(tmpDate);

                // authorized users
                String authorizedUserIds = checkString(serviceStock.getAuthorizedUserIds());
                if(authorizedUserIds.length() > 0){
                    authorisedUsersIdx = 1;
                    StringTokenizer idTokenizer = new StringTokenizer(authorizedUserIds,"$");
                    while(idTokenizer.hasMoreTokens()){
                        authorizedUserId = idTokenizer.nextToken();
                        authorizedUserName = ScreenHelper.getFullUserName(authorizedUserId);
                        authorisedUsersIdx++;

                        authorizedUsersJS.append("rowAuthorizedUsers"+authorisedUsersIdx+"="+authorizedUserId+"£"+authorizedUserName+"$");
                        authorizedUsersHTML.append(addAuthorizedUser(authorisedUsersIdx,authorizedUserName,sWebLanguage));
                        authorizedUsersDB.append(authorizedUserId+"$");
                    }
                }

                // afgeleide data
                if(sSelectedServiceUid.length() > 0){
                    sSelectedServiceName = getTranNoLink("service",sSelectedServiceUid,sWebLanguage);
                }

                if(sSelectedManagerUid.length() > 0){
                    sSelectedManagerName = ScreenHelper.getFullUserName(sSelectedManagerUid);
                }
                if(sSelectedDefaultSupplierUid.length() > 0){
                    sSelectedDefaultSupplierName = getTranNoLink("service",sSelectedDefaultSupplierUid,sWebLanguage);
                }
            }
        }
        else if(sAction.equals("showDetailsAfterAddReject")){
            // do not get data from DB, but show data that were allready on form
            sSelectedStockName          = sEditStockName;
            sSelectedServiceUid         = sEditServiceUid;
            sSelectedBegin              = sEditBegin;
            sSelectedEnd                = sEditEnd;
            sSelectedManagerUid         = sEditManagerUid;
            sSelectedDefaultSupplierUid = sEditDefaultSupplierUid;
            sSelectedOrderPeriod        = sEditOrderPeriod;
            sSelectedNosync				= sEditNosync;

            // afgeleide data
            sSelectedServiceName         = sEditServiceName;
            sSelectedManagerName         = sEditManagerName;
            sSelectedDefaultSupplierName = sEditDefaultSupplierName;
        }
        else if(sAction.equals("showDetailsNew")){
            // default defaultSupplier is centralPharmacy
            if(sEditDefaultSupplierUid.length()==0) sEditDefaultSupplierUid = centralPharmacyCode;

            // default orderPeriodInMonths
            if(sEditOrderPeriod.length()==0) sEditOrderPeriod = "12"; // todo : needed ?

            // default Nosync
            if(sEditNosync.length()==0) sEditNosync = "1"; // todo : needed ?

            // active user service as default service
            sSelectedServiceUid = activeUser.activeService.code;
            sSelectedServiceName = getTranNoLink("service",sSelectedServiceUid,sWebLanguage);

            // active user as default manager
            sSelectedManagerUid = activeUser.person.personid;
            sSelectedManagerName = ScreenHelper.getFullUserName(sSelectedManagerUid);

            // central pharmacy as default defaultSupplier
            sSelectedDefaultSupplierUid = centralPharmacyCode;
            if(sSelectedDefaultSupplierUid.length() > 0){
                sSelectedDefaultSupplierName = getTranNoLink("service",sSelectedDefaultSupplierUid,sWebLanguage);
            }
        }
    }

    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown = "";
    if(sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(checkKey13(event)){doSave();}\"";
    }
    else{
        sOnKeyDown = "onKeyDown=\"if(checkKey13(event)){doSearch('"+sDefaultSortCol+"');}\"";
    }
%>
<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/main.do"/>?Page=pharmacy/manageServiceStocks.jsp&ts=<%=getTs()%>' <%=sOnKeyDown%> <%=(displaySearchFields?"onClick=\"clearMessage();\"":"onclick=\"setSaveButton(event);clearMessage();\" onkeyup=\"setSaveButton(event);\"")%>>
    <%-- title --%>
    <%=writeTableHeader("Web.manage","ManageServiceStocks",sWebLanguage," doBack();")%>
    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH FIELDS -----------------------------------------------------------------------
        // afgeleide data
        String sFindManagerName         = checkString(request.getParameter("FindManagerName"));
               sFindServiceName         = checkString(request.getParameter("FindServiceName"));
               sFindDefaultSupplierName = checkString(request.getParameter("FindDefaultSupplierName"));

        if(displaySearchFields){
            // active service as default service to search on
            if(displayActiveServiceStocks){
                sFindServiceUid = activeUser.activeService.code;
                sFindServiceName = getTranNoLink("service",sFindServiceUid,sWebLanguage);
            }

            %>
                <table width="100%" class="list" cellspacing="1" onClick="transactionForm.onkeydown='if(checkKey13(event)){doSearch(\'<%=sDefaultSortCol%>\');}';" onKeyDown="if(checkKey13(event)){doSearch('<%=sDefaultSortCol%>');}">
                    <%-- Stock Name --%>
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","Name",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="FindStockName" size="<%=sTextWidth%>" maxLength="255" value="<%=sFindStockName%>">
                        </td>
                    </tr>
                    <%-- Service --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","service",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindServiceUid" value="<%=sFindServiceUid%>">
                            <input class="text" type="text" name="FindServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindServiceName%>">
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('FindServiceUid','FindServiceName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceUid.value='';transactionForm.FindServiceName.value='';">
                        </td>
                    </tr>
                    <%-- Begin --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
                    </tr>
                    <%-- End --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","enddate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
                    </tr>
                    <%-- Manager --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","manager",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindManagerUid" value="<%=sFindManagerUid%>">
                            <input class="text" type="text" name="FindManagerName" readonly size="<%=sTextWidth%>" value="<%=sFindManagerName%>">
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchManager('FindManagerUid','FindManagerName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindManagerUid.value='';transactionForm.FindManagerName.value='';">
                        </td>
                    </tr>
                    <%-- default supplier --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","defaultsupplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindDefaultSupplierUid" value="<%=sFindDefaultSupplierUid%>">
                            <input class="text" type="text" name="FindDefaultSupplierName" readonly size="<%=sTextWidth%>" value="<%=sFindDefaultSupplierName%>">
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('FindDefaultSupplierUid','FindDefaultSupplierName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindDefaultSupplierUid.value='';transactionForm.FindDefaultSupplierName.value='';">
                        </td>
                    </tr>
                    <%-- SEARCH BUTTONS --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch('<%=sDefaultSortCol%>');">
                            <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                            <%
                                if(activeUser.getAccessRight("pharmacy.manageservicestocks.add")){
                                    %><input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();"><%
                                }
                            %>
                            <%-- display message --%>
                            <span id="msgArea"><%=msg%></span>
                        </td>
                    </tr>
                </table>
                <br>
            <%
        }
        else{
            //*** search fields as hidden fields to be able to revert to the overview ***

            // get data from form
            sFindStockName          = checkString(request.getParameter("FindStockName"));
            sFindServiceUid         = checkString(request.getParameter("FindServiceUid"));
            sFindBegin              = checkString(request.getParameter("FindBegin"));
            sFindEnd                = checkString(request.getParameter("FindEnd"));
            sFindManagerUid         = checkString(request.getParameter("FindManagerUid"));
            sFindDefaultSupplierUid = checkString(request.getParameter("FindDefaultSupplierUid"));

            %>
                <input type="hidden" name="FindStockName" value="<%=sFindStockName%>">
                <input type="hidden" name="FindServiceUid" value="<%=sFindServiceUid%>">
                <input type="hidden" name="FindServiceName" value="<%=sFindServiceName%>">
                <input type="hidden" name="FindBegin" value="<%=sFindBegin%>">
                <input type="hidden" name="FindEnd" value="<%=sFindEnd%>">
                <input type="hidden" name="FindManagerUid" value="<%=sFindManagerUid%>">
                <input type="hidden" name="FindManagerName" value="<%=sFindManagerName%>">
                <input type="hidden" name="FindDefaultSupplierUid" value="<%=sFindDefaultSupplierUid%>">
                <input type="hidden" name="FindDefaultSupplierName" value="<%=sFindDefaultSupplierName%>">
            <%
        }

        //--- SEARCH RESULTS ----------------------------------------------------------------------
        if(displayFoundRecords){
            if(foundStockCount > 0){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="90" nowrap>&nbsp;</td>
                            <td><%=getTran("Web","name",sWebLanguage)%></td>
                            <td><%=getTran("Web","service",sWebLanguage)%></td>
                            <td><%=getTran("Web","manager",sWebLanguage)%></td>
                            <td><%=getTran("Web.manage","productstockcount",sWebLanguage)%></td>
                            <td/>
                        </tr>
                        <tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'>
                            <%=stocksHtml%>
                        </tbody>
                    </table>
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundStockCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </span>
                    <%
                        if(foundStockCount > 20){
                            // link to top of page
                            %>
                                <span style="width:51%;text-align:right;">
                                    <a href="#topp" class="topbutton">&nbsp;</a>
                                </span>
                                <br>
                            <%
                        }
                    %>
                <%
            }
            else{
                // no records found
                %>
                    <%=getTran("web","norecordsfound",sWebLanguage)%>
                    <br><br>
                <%
            }
        }

        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%-- Stock Name --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","ID",sWebLanguage)%></td>
                        <td class="admin2">
                            <%=sEditStockUid%>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","Name",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditStockName" size="<%=sTextWidth%>" maxLength="255" value="<%=sSelectedStockName%>">
                        </td>
                    </tr>
                    <%-- Service --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","service",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input type="hidden" name="EditServiceUid" value="<%=sSelectedServiceUid%>">
                            <input class="text" type="text" name="EditServiceName" readonly size="<%=sTextWidth%>" value="<%=sSelectedServiceName%>">
                         
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchService('EditServiceUid','EditServiceName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditServiceUid.value='';transactionForm.EditServiceName.value='';">
                        </td>
                    </tr>
                    <%-- Begin date --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2"><%=writeDateField("EditBegin","transactionForm",sSelectedBegin,sWebLanguage)%>
                            <%
                                // if new order : set today as default value for begindate
                                if(sAction.equals("showDetailsNew")){
                                    %><script>getToday(document.getElementsByName('EditBegin')[0]);</script><%
                                }
                            %>
                        </td>
                    </tr>
                    <%-- End date --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","enddate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><%=writeDateField("EditEnd","transactionForm",sSelectedEnd,sWebLanguage)%></td>
                    </tr>
                    <%-- Manager --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","manager",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditManagerUid" value="<%=sSelectedManagerUid%>">
                            <input class="text" type="text" name="EditManagerName" readonly size="<%=sTextWidth%>" value="<%=sSelectedManagerName%>">
                           
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchManager('EditManagerUid','EditManagerName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditManagerName.value='';transactionForm.EditManagerUid.value='';">
                        </td>
                    </tr>
                    <%-- Authorized users --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","Authorizedusers",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%-- add row --%>
                            <input type="hidden" name="AuthorizedUserIdAdd" value="">
                            <input class="text" type="text" name="AuthorizedUserNameAdd" size="<%=sTextWidth%>" value="" readonly>
                           
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAuthorizedUser('AuthorizedUserIdAdd','AuthorizedUserNameAdd');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.AuthorizedUserIdAdd.value='';transactionForm.AuthorizedUserNameAdd.value='';">
                            <img src="<c:url value="/_img/icons/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addAuthorizedUser();">
                            <table width="100%" cellspacing="1" id="tblAuthorizedUsers">
                                <%=authorizedUsersHTML%>
                            </table>
                            <input type="hidden" name="EditAuthorizedUsers" value="<%=authorizedUsersDB%>">
                        </td>
                    </tr>

                    <%-- default supplier --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","defaultsupplier",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditDefaultSupplierUid" value="<%=sSelectedDefaultSupplierUid%>">
                            <input class="text" type="text" name="EditDefaultSupplierName" readonly size="<%=sTextWidth%>" value="<%=sSelectedDefaultSupplierName%>">
                          
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('EditDefaultSupplierUid','EditDefaultSupplierName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditDefaultSupplierUid.value='';transactionForm.EditDefaultSupplierName.value='';">
                        </td>
                    </tr>
                    <%-- orderPeriodInMonths --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web.manage","orderPeriodInMonths",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditOrderPeriodInMonths" size="5" maxLength="5" value="<%=sSelectedOrderPeriod%>" onKeyUp="isInteger(this);">
                        </td>
                    </tr>
                    <%-- Nosync --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web.manage","nosync",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="checkbox" name="EditNosync" <%=sSelectedNosync!=null && sSelectedNosync.equalsIgnoreCase("1")?"checked":""%> value="1" onKeyUp="isInteger(this);">
                        </td>
                    </tr>
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                        <%
                            if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                // existing serviceStock : display saveButton with save-label
                                ServiceStock serviceStock = ServiceStock.get(sEditStockUid);
                                if(serviceStock.isAuthorizedUser(activeUser.userid) || activeUser.getAccessRight("sa")){
                                    if(activeUser.getAccessRight("pharmacy.manageservicestocks.edit")){
		                                %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();"><%
                                    }
                                    if(activeUser.getAccessRight("pharmacy.manageservicestocks.delete")){
		                                %><input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditStockUid%>');"><%
                                    }
                                }
                                %><input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();"><%
                            }
                            else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                // new serviceStock : display saveButton with add-label
                                if(activeUser.getAccessRight("pharmacy.manageservicestocks.add")){
                                    %><input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doAdd();"><%
                                }
                                %><input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onclick="doBack();"><%
                            }
                        %>
                        <%-- display message --%>
                        <span id="msgArea"><%=msg%></span>
                    </td>
                </tr>
            </table>
            
            <%-- indication of obligated fields --%>
            <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <br><br>
            
            <table width='100%'>
            	<tr>
            		<td class='text'><a href="javascript:printInventory('<%=sEditStockUid %>')"><%=getTran("web","servicestockinventory.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printInventorySummary('<%=sEditStockUid %>')"><%=getTran("web","servicestockinventorysummary.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printStockOperations('<%=sEditStockUid %>')"><%=getTran("web","servicestockoperations.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printOutgoingStockOperations('<%=sEditStockUid %>')"><%=getTran("web","serviceoutgoingstockoperations.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printOutgoingStockOperationsListing('<%=sEditStockUid %>')"><%=getTran("web","serviceoutgoingstockoperationslisting.pdf",sWebLanguage)%></a></td>
				</tr>
				<tr>
            		<td class='text'><a href="javascript:printOutgoingStockOperationsListingPerService('<%=sEditStockUid %>')"><%=getTran("web","serviceoutgoingstockoperationslistingperservice.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printMonthlyConsumption('<%=sEditStockUid %>')"><%=getTran("web","monthlyconsumption.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printExpiration('<%=sEditStockUid %>')"><%=getTran("web","expiration.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printStockOut('<%=sEditStockUid %>')"><%=getTran("web","stockout.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printIncomingStockOperations('<%=sEditStockUid %>')"><%=getTran("web","serviceincomingstockoperations.pdf",sWebLanguage)%></a></td>
            	</tr>
				<tr>
            		<td class='text'><a href="javascript:printIncomingStockOperationsPerOrder('<%=sEditStockUid %>')"><%=getTran("web","serviceincomingstockoperationsperorder.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printIncomingStockOperationsPerItem('<%=sEditStockUid %>')"><%=getTran("web","serviceincomingstockoperationsperitem.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printIncomingStockOperationsPerProvider('<%=sEditStockUid %>')"><%=getTran("web","serviceincomingstockoperationsperprovider.pdf",sWebLanguage)%></a></td>
            		<td class='text'><a href="javascript:printIncomingStockOperationsPerCategoryItem('<%=sEditStockUid %>')"><%=getTran("web","serviceincomingstockoperationspercategoryitem.pdf",sWebLanguage)%></a></td>
            	</tr>
            </table>
            <%
        }

        //--- DISPLAY ACTIVE SERVICE STOCKS -------------------------------------------------------
        if(displayActiveServiceStocks){
            // search stocks in service of active user by default
            sFindServiceUid = activeUser.activeService.code;
            sFindServiceName = getTranNoLink("service",sFindServiceUid,sWebLanguage);

            Vector serviceStocks = Service.getActiveServiceStocks(sFindServiceUid);
            stocksHtml = objectsToHtml(serviceStocks,sWebLanguage,activeUser);
            foundStockCount = serviceStocks.size();

            //*** display found records ***
            if(foundStockCount > 0){
                String sortTran = getTran("web","clicktosort",sWebLanguage);
                %>
                    <%-- title --%>
                    <table width="100%" cellspacing="0">
                        <tr>
                            <td class="titleadmin">&nbsp;<%=getTran("Web.manage","ActiveServiceStocks",sWebLanguage)%>&nbsp;(<%=sFindServiceName%>)</td>
                        </tr>
                    </table>
                    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- clickable header --%>
                        <tr class="admin">
                            <td width="22"/>
                            <td width="20%"><%=getTran("Web","name",sWebLanguage)%></td>
                            <td width="35%"><%=getTran("Web","service",sWebLanguage)%></td>
                            <td width="25%"><%=getTran("Web","manager",sWebLanguage)%></td>
                            <td width="15%"><%=getTran("Web.manage","productstockcount",sWebLanguage)%></td>
                            <td/>
                        </tr>
                        <tbody class="hand">
                            <%=stocksHtml%>
                        </tbody>
                    </table>
                    <%-- number of records found --%>
                    <span style="width:49%;text-align:left;">
                        <%=foundStockCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </span>
                    <%
                        if(foundStockCount > 20){
                            // link to top of page
                            %>
                                <span style="width:51%;text-align:right;">
                                    <a href="#topp" class="topbutton">&nbsp;</a>
                                </span>
                                <br>
                            <%
                        }
                    %>
                    <br>
                <%
            }
            else{
                // no records found
                %>
                    <%-- sub title --%>
                    <table width='100%' cellspacing='0'>
                        <tr class='admin'>
                            <td><%=getTran("Web.manage","ActiveServiceStocks",sWebLanguage)%>&nbsp;(<%=sFindServiceName%>)</td>
                        </tr>
                    </table>
                    <%=getTran("web.manage","noservicestocksfoundinactiveservice",sWebLanguage)%>
                    <br><br>
                <%
            }
        }
    %>
    
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    <input type="hidden" name="SortDir" value="<%=sSortDir%>">
    <input type="hidden" name="EditStockUid" value="<%=sEditStockUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
    <input type="hidden" name="DisplayActiveServiceStocks" value="<%=displayActiveServiceStocks%>">
</form>
<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
  <%
      // default focus field
      if(displayEditFields){
          %>transactionForm.EditStockName.focus();<%
      }

      if(displaySearchFields){
          %>transactionForm.FindStockName.focus();<%
      }
  %>

  <%-- AUTHORIZED USERS FUNCTIONS ---------------------------------------------------------------%>
  var iAuthorizedUsersIdx = <%=authorisedUsersIdx%>;
  var sAuthorizedUsers = "<%=authorizedUsersJS%>";


  function checkKey13(evt){
    evt = evt || window.event;
    var kcode = evt.keyCode || evt.which;
    if(kcode && kcode==13){
        return true;
    }else{
        return false;
    }
  }
  
  <%-- ADD AUTHORIZED USER --%>
  function addAuthorizedUser(){
    if(transactionForm.AuthorizedUserIdAdd.value.length > 0){
      iAuthorizedUsersIdx++;

      sAuthorizedUsers+= "rowAuthorizedUsers"+iAuthorizedUsersIdx+"£"+
                         transactionForm.AuthorizedUserIdAdd.value+"£"+
                         transactionForm.AuthorizedUserNameAdd.value+"$";
      var tr = tblAuthorizedUsers.insertRow(tblAuthorizedUsers);
      tr.id = "rowAuthorizedUsers"+iAuthorizedUsersIdx;

      var td = tr.insertCell(0);
      td.width = 16;
      td.innerHTML = "<a href='javascript:deleteAuthorizedUser(rowAuthorizedUsers"+iAuthorizedUsersIdx+")'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = transactionForm.AuthorizedUserNameAdd.value;
      tr.appendChild(td);

      <%-- update the hidden field containing just the userids --%>
      transactionForm.EditAuthorizedUsers.value = transactionForm.EditAuthorizedUsers.value+transactionForm.AuthorizedUserIdAdd.value+"$";

      clearAuthorizedUserFields();
    }
    else{
        alertDialog("web","firstselectaperson");
        transactionForm.AuthorizedUserNameAdd.focus();
    }
  }

  <%-- CLEAR AUTHORIZED USER FIELDS --%>
  function clearAuthorizedUserFields(){
    transactionForm.AuthorizedUserIdAdd.value = "";
    transactionForm.AuthorizedUserNameAdd.value = "";
  }

  <%-- DELETE AUTHORIZED USER --%>
  function deleteAuthorizedUser(rowid){
    if(yesnoDialog("Web","areYouSureToDelete")){
      sAuthorizedUsers = deleteRowFromArrayString(sAuthorizedUsers,rowid.id);

      <%-- update the hidden field containing just the userids --%>
      transactionForm.EditAuthorizedUsers.value = extractUserIds(sAuthorizedUsers);

      tblAuthorizedUsers.deleteRow(rowid.rowIndex);
      clearAuthorizedUserFields();
    }
  }

  <%-- EXTRACT USER IDS (between '=' and '£') --%>
  function extractUserIds(sourceString){
    var array = sourceString.split("$");
    for(var i=0;i<array.length;i++){
       array[i] = array[i].substring(array[i].indexOf("=")+1,array[i].indexOf("£"));
    }
    return array.join("$");
  }

  <%-- DELETE ROW FROM ARRAY STRING --%>
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for(var i=0;i<array.length;i++){
      if(array[i].indexOf(rowid)>-1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

  <%-- DO ADD SERVICE STOCK --%>
  function doAdd(){
    transactionForm.EditStockUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE SERVICE STOCK --%>
  function doSave(){
    if(transactionForm.AuthorizedUserIdAdd.value.length > 0){
      addAuthorizedUser();
    }

    if(checkStockFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditStockName.value.length==0){
        transactionForm.EditStockName.focus();
      }
      else if(transactionForm.EditServiceUid.value.length==0){
        transactionForm.EditServiceName.focus();
      }
      else if(transactionForm.EditDefaultSupplierName.value.length==0){
        transactionForm.EditDefaultSupplierName.focus();
      }
      else if(transactionForm.EditDefaultSupplierUid.value.length==0){
        transactionForm.EditDefaultSupplierUid.focus();
      }
      else if(transactionForm.EditBegin.value.length==0){
        transactionForm.EditBegin.focus();
      }
      else if(transactionForm.EditOrderPeriodInMonths.value.length==0){
        transactionForm.EditOrderPeriodInMonths.focus();
      }
    }
  }

  <%-- CHECK STOCK FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;

    <%-- required fields --%>
    if(!transactionForm.EditStockName.value.length>0 || !transactionForm.EditServiceUid.value.length>0 ||
       !transactionForm.EditDefaultSupplierUid.value.length>0 || !transactionForm.EditBegin.value.length>0 ||
       !transactionForm.EditOrderPeriodInMonths.value.length>0){
      maySubmit = false;

      alertDialog("web","datamissing");
    }
    else{
      <%-- check dates --%>
      if(transactionForm.EditBegin.value.length>0 && transactionForm.EditEnd.value.length>0){
        var dateBegin = transactionForm.EditBegin.value;
        var dateEnd   = transactionForm.EditEnd.value;

        if(before(dateBegin,dateEnd)){
          maySubmit = true;
        }
        else{
          alertDialog("web.Occup","endMustComeAfterBegin");
          transactionForm.EditEnd.focus();
          maySubmit = false;
        }
      }
    }

    return maySubmit;
  }

  <%-- DO DELETE SERVICE STOCK --%>
  function doDelete(stockUid){
    if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.EditStockUid.value = stockUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- DO NEW SERVICE STOCK --%>
  function doNew(){
    <%
        if(displayEditFields){
            %>clearEditFields();<%
        }

        if(displaySearchFields){
            %>clearSearchFields();<%
        }
    %>

    transactionForm.searchButton.disabled = true;
    transactionForm.clearButton.disabled = true;
    transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW SERVICE STOCK DETAILS --%>
  function doShowDetails(stockUid){
    if(transactionForm.searchButton!=undefined) transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;

    transactionForm.EditStockUid.value = stockUid;
    transactionForm.Action.value = "showDetails";
    transactionForm.submit();
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindStockName.value = "";

    transactionForm.FindServiceUid.value = "";
    transactionForm.FindServiceName.value = "";

    transactionForm.FindBegin.value = "";
    transactionForm.FindEnd.value = "";

    transactionForm.FindManagerUid.value = "";
    transactionForm.FindManagerName.value = "";

    transactionForm.FindDefaultSupplierUid.value = "";
    transactionForm.FindDefaultSupplierName.value = "";
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.FindStockName.value = "";

    transactionForm.EditServiceUid.value = "";
    transactionForm.EditServiceName.value = "";

    transactionForm.EditBegin.value = "";
    transactionForm.EditEnd.value = "";

    transactionForm.EditManagerUid.value = "";
    transactionForm.EditManagerName.value = "";

    transactionForm.EditDefaultSupplierUid.value = "";
    transactionForm.EditDefaultSupplierName.value = "";
    transactionForm.EditOrderPeriodInMonths.value = "";
  }

  <%-- DO SORT --%>
  function doSort(sortCol){
    transactionForm.Action.value = "sort";
    transactionForm.SortCol.value = sortCol;

    if(transactionForm.SortDir.value == "ASC") transactionForm.SortDir.value = "DESC";
    else                                       transactionForm.SortDir.value = "ASC";

    transactionForm.submit();
  }

  <%-- DO SEARCH SERVICE STOCK --%>
  function doSearch(sortCol){
    if(transactionForm.FindStockName.value.length>0 || transactionForm.FindServiceUid.value.length>0 ||
       transactionForm.FindBegin.value.length>0 || transactionForm.FindEnd.value.length>0 ||
       transactionForm.FindManagerUid.value.length>0 || transactionForm.FindDefaultSupplierUid.value.length>0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;
      transactionForm.newButton.disabled = true;

      transactionForm.Action.value = "find";
      transactionForm.SortCol.value = sortCol;
      openSearchInProgressPopup();
      transactionForm.submit();
    }
    else{
      alertDialog("web","datamissing");
    }
  }

  <%-- popup : search manager --%>
  function searchManager(managerUidField,managerNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no");
  }

  <%-- popup : search authorized user --%>
  function searchAuthorizedUser(userUidField,userNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+userUidField+"&ReturnName="+userNameField+"&displayImmatNew=no");
  }

  <%-- DISPLAY PRODUCT STOCK MANAGEMENT --%>
  function displayProductStockManagement(serviceStockUid,serviceId){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageProductStocks.jsp&Action=findShowOverview&EditServiceStockUid="+serviceStockUid+"&DisplaySearchFields=false&ServiceId="+serviceId+"&ts=<%=getTs()%>";
  }

  <%-- popup : search (external) supplier --%>
  function searchSupplier(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&SearchInternalServices=true&SearchExternalServices=true&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- DO BACK TO OVERVIEW --%>
  function doBackToOverview(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web","areyousuretodiscard",sWebLanguage)%>')){
      <%
          if(displayActiveServiceStocks){
              %>
                transactionForm.Action.value = "";
                transactionForm.DisplayActiveServiceStocks.value = "true";
              <%
          }
          else{
              %>
                transactionForm.Action.value = "findShowOverview";
                transactionForm.DisplayActiveServiceStocks.value = "false";
              <%
          }
      %>
      transactionForm.DisplaySearchFields.value = "true";
      transactionForm.submit();
    }
  }

  <%-- popup : CALCULATE ORDER --%>
  function doCalculateOrder(serviceStockUid,serviceStockName){
    openPopup("pharmacy/popups/calculateOrder.jsp&ServiceStockUid="+serviceStockUid+"&ServiceStockName="+serviceStockName+"&ts=<%=getTs()%>",700,400);
  }

  function printInventory(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceStockInventory.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printInventorySummary(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceStockInventorySummary.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printStockOperations(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceStockOperations.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printOutgoingStockOperations(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceOutgoingStockOperations.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printIncomingStockOperations(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceIncomingStockOperations.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printIncomingStockOperationsPerOrder(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceIncomingStockOperationsPerOrder.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printIncomingStockOperationsPerItem(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceIncomingStockOperationsPerItem.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printIncomingStockOperationsPerCategoryItem(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceIncomingStockOperationsPerCategoryItem.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printIncomingStockOperationsPerProvider(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceIncomingStockOperationsPerProvider.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printOutgoingStockOperationsListing(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceOutgoingStockOperationsListing.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printOutgoingStockOperationsListingPerService(serviceStockUid){
	openPopup("statistics/pharmacy/getServiceOutgoingStockOperationsListingPerService.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printMonthlyConsumption(serviceStockUid){
	openPopup("statistics/pharmacy/getMonthlyConsumption.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printExpiration(serviceStockUid){
	openPopup("statistics/pharmacy/getExpiration.jsp&ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid,200,200);
  }

  function printStockOut(serviceStockUid){
	window.open("pharmacy/printStockOut.jsp?ts=<%=getTs()%>&ServiceStockUid="+serviceStockUid);
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageServiceStocks.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  function bulkReceive(serviceStockUid){
    openPopup("pharmacy/popups/bulkReceive.jsp&ServiceStockUid="+serviceStockUid+"&ts=<%=getTs()%>",700,400);
  }

  function printFiche(serviceStockUid,serviceStockName){
	openPopup("pharmacy/viewServiceStockFiches.jsp&ts=<%=getTs()%>&Action=find&FindServiceStockUid="+serviceStockUid+"&GetYear=<%=new SimpleDateFormat("yyyy").format(new java.util.Date())%>&FindServiceStockName="+serviceStockName,800,500);
  }

  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();
</script>