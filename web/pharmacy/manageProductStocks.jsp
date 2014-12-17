<%@page import="be.openclinic.pharmacy.ServiceStock,
                be.openclinic.pharmacy.Product,
                be.openclinic.pharmacy.ProductStock,
                be.openclinic.pharmacy.ProductStockOperation,
                be.openclinic.medical.Prescription,
                java.util.Vector,be.mxs.common.util.system.*,
                be.openclinic.pharmacy.ProductOrder"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("pharmacy.manageproductstocks","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
	static Hashtable pumps = new Hashtable(),
	                 pumpcounts = new Hashtable();

public double getLastYearsAveragePrice(Product product){
	double price=0;
	if(pumps.get(product.getUid())!=null && pumpcounts.get(product.getUid())!=null){
		price=(Double)pumps.get(product.getUid())/(Double)pumpcounts.get(product.getUid());
	}
	return price;
}

	public double getLastYearsAveragePrice(String productuid){
		double price = 0;
		if(pumps.get(productuid)!=null && pumpcounts.get(productuid)!=null){
			price=(Double)pumps.get(productuid)/(Double)pumpcounts.get(productuid);
		}
		return price;
	}
%>

<%!
    //--- OBJECTS TO HTML (layout 1) --------------------------------------------------------------
    private StringBuffer objectsToHtml1(Vector objects, String sWebLanguage){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sStockUid = "", sServiceStockName = "", sProductName = "", sStockBegin = "",
               sOrderLevel = "", sMinimumLevel = "";
        Product product;
        int stockLevel;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
                deleteTran = getTranNoLink("Web","delete",sWebLanguage);

        // run thru found productstocks
        ProductStock productStock;
        for(int i=0; i<objects.size(); i++){
            productStock = (ProductStock)objects.get(i);
            sStockUid = productStock.getUid();

            // get service stock name
            ServiceStock serviceStock = productStock.getServiceStock();
            if(serviceStock!=null){
                sServiceStockName = serviceStock.getName();
            }
            else{
                sServiceStockName = "<font color='red'>"+getTran("web","nonexistingserviceStock",sWebLanguage)+"</font>";
            }

            // get product name
            product = productStock.getProduct();
            if(product!=null){
                sProductName = product.getName();
            }
            else{
                sProductName = "<font color='red'>"+getTran("web","nonexistingproduct",sWebLanguage)+"</font>";
            }

            // format begin date
            java.util.Date tmpDate = productStock.getBegin();
            if(tmpDate!=null) sStockBegin = ScreenHelper.formatDate(tmpDate);

            // levels
            stockLevel = productStock.getLevel();
            sOrderLevel = (productStock.getOrderLevel()<0?"":productStock.getOrderLevel()+"");
            sMinimumLevel = (productStock.getMinimumLevel()<0?"":productStock.getMinimumLevel()+"");

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else sClass = "";

            // display stock in one row
            html.append("<tr class='list"+sClass+"' onmouseover=\"this.style.cursor='pointer';\" onmouseout=\"this.style.cursor='default';\" title='"+detailsTran+"'>")
                 .append("<td onclick=\"doShowDetails('"+sStockUid+"');\" align='center'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' alt='"+deleteTran+"' onclick=\"doDelete('"+sStockUid+"');\"></td>")
                 .append("<td onclick=\"doShowDetails('"+sStockUid+"');\">"+sServiceStockName+"</td>")
                 .append("<td onclick=\"doShowDetails('"+sStockUid+"');\">"+sProductName+"</td>");

            if(sMinimumLevel.length() > 0 && sOrderLevel.length() > 0){
                int minimumLevel = Integer.parseInt(sMinimumLevel),
                        orderLevel = Integer.parseInt(sOrderLevel);

                // indicate level in orange or red
                if(stockLevel <= minimumLevel){
                    html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\"><font color='red'>"+stockLevel+"</font>&nbsp;&nbsp;</td>");
                }
                else if(stockLevel <= orderLevel){
                    html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\"><font color='orange'>"+stockLevel+"</font>&nbsp;&nbsp;</td>");
                }
                else {
                    html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+stockLevel+"&nbsp;&nbsp;</td>");
                }
            }
            else {
                html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+stockLevel+"&nbsp;&nbsp;</td>");
            }

            html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+sOrderLevel+"&nbsp;&nbsp;</td>")
                .append("<td onclick=\"doShowDetails('"+sStockUid+"');\">"+sStockBegin+"</td>")
                .append("</tr>");
}

        return html;
    }

    //--- OBJECTS TO HTML (layout 2) --------------------------------------------------------------
    private StringBuffer objectsToHtml2(Vector objects, String serviceUid, String sWebLanguage,User activeUser){
        StringBuffer html = new StringBuffer();
        String sClass = "1", sStockUid = "", sProductUid = "", sProductName = "", sStockBegin = "";
        Product product;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran = getTranNoLink("Web","delete",sWebLanguage),
               incomingTran = getTranNoLink("Web","incoming",sWebLanguage),
               orderTran = getTranNoLink("Web","order",sWebLanguage),
               batchesTran = getTranNoLink("web","batches",sWebLanguage),
               inTran = getTranNoLink("Web.manage","changeLevel.in",sWebLanguage),
               outTran = getTranNoLink("Web.manage","changeLevel.out",sWebLanguage),
               orderThisProductTran = getTranNoLink("Web.manage","orderthisproduct",sWebLanguage),
               changeLevelInTran = getTranNoLink("Web.manage","changeLevelIn",sWebLanguage),
               ficheTran = getTranNoLink("Web","productfiche",sWebLanguage),
               changeLevelOutTran = getTranNoLink("Web.manage","changeLevelOut",sWebLanguage);

        // run thru found productstocks
        HashSet opendeliveries = ProductStockOperation.getOpenProductStockDeliveries();
        Hashtable productnames = Product.getProductNames();
        Hashtable openquantities = ProductOrder.getOpenOrderedQuantity();
        ProductStock productStock;
        for (int i=0; i<objects.size(); i++){
            productStock = (ProductStock)objects.get(i);
            sStockUid = productStock.getUid();

            if(productnames.get(productStock.getProductUid()) != null) {
                sProductName = (String)productnames.get(productStock.getProductUid());
                sProductUid = productStock.getProductUid();
            } 
            else{
                sProductName = "<font color='red'>"+getTran("web","nonexistingproduct",sWebLanguage)+"</font>";
            }

            // format begin date
            java.util.Date tmpDate = productStock.getBegin();
            if(tmpDate!=null) sStockBegin = ScreenHelper.formatDate(tmpDate);

            double nPUMP = getLastYearsAveragePrice(productStock.getProductUid());
            int commandLevel = 0;
            if(openquantities.get(productStock.getUid())!=null){
            	commandLevel=(Integer)openquantities.get(productStock.getUid());
            }

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";
            
            //*** display stock in one row ***
            html.append("<tr class='list"+sClass+"'>")
                 .append("<td width='16'>"+(activeUser.getAccessRight("pharmacy.manageproductstocks.delete")?"<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' alt='"+deleteTran+"' onclick=\"doDelete('"+sStockUid+"');\" title='"+deleteTran+"'></td>":"<td/>"))
		         .append("<td width='16'>"+(activeUser.getAccessRight("pharmacy.viewproductstockfiches.select")?"<img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif' class='link' onclick=\"printFiche('"+sStockUid+"');\" title='"+ficheTran+"'></td>":"<td/>"));
            if(opendeliveries.contains(productStock.getServiceStockUid()+"$"+productStock.getProductUid())){
                html.append("<td width='16'><img src='"+sCONTEXTPATH+"/_img/icons/icon_incoming.gif' class='link' alt='"+incomingTran+"' onclick='javascript:receiveProduct(\""+sStockUid+"\",\""+sProductName+"\");'/>&nbsp;</td>");
            }
            else {
            	html.append("<td/>");
            }

            // non-existing productname in red
            if(sProductName.length() == 0) {
                html.append("<td onclick=\"doShowDetails('"+sStockUid+"');\"><font color='red'>"+getTran("web","nonexistingproduct",sWebLanguage)+"</font></td>");
            } 
            else {
                html.append("<td onclick=\"doShowDetails('"+sStockUid+"');\">"+sProductName+"</td>");
            }

            // level
            int stockLevel = productStock.getLevel();
            String sOrderLevel = (productStock.getOrderLevel()<0?"":productStock.getOrderLevel()+""),
                   sMinimumLevel = (productStock.getMinimumLevel()<0?"":productStock.getMinimumLevel()+""),
                   sMaximumLevel = (productStock.getMaximumLevel()<0?"":productStock.getMaximumLevel()+"");

            if(sMinimumLevel.length() > 0 && sOrderLevel.length() > 0){
                int minimumLevel = Integer.parseInt(sMinimumLevel),
                    orderLevel = Integer.parseInt(sOrderLevel);

                // indicate level in orange or red
                if(stockLevel <= minimumLevel){
                    html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\"><font color='red'>"+stockLevel+"</font>&nbsp;&nbsp;</td>");
                } 
                else if(stockLevel <= orderLevel){
                    html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\"><font color='orange'>"+stockLevel+"</font>&nbsp;&nbsp;</td>");
                } 
                else{
                    html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+stockLevel+"&nbsp;&nbsp;</td>");
                }
            }
            else{
                html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+stockLevel+"&nbsp;&nbsp;</td>");
            }

            html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+commandLevel+"&nbsp;&nbsp;</td>");
            html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+sMinimumLevel+"&nbsp;&nbsp;</td>");
            html.append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+sMaximumLevel+"&nbsp;&nbsp;</td>")
                 .append("<td align='right' onclick=\"doShowDetails('"+sStockUid+"');\">"+sOrderLevel+"&nbsp;&nbsp;</td>")
                 .append("<td onclick=\"doShowDetails('"+sStockUid+"');\">"+sStockBegin+"</td>")
                 .append("<td onclick=\"doShowDetails('"+sStockUid+"');\">"+(nPUMP>0?new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(nPUMP)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR"):"?")+"</td>");

            // 3 buttons
            html.append("<td style=\"text-align:right;\" nowrap>&nbsp;");

            // no buttons for unexisting product
            if(productnames.get(productStock.getProductUid()) != null){
                if(productStock.getLevel() > 0){
                    html.append("<input type='button' title='"+changeLevelOutTran+"' class='button' style='width:30px;' value=\""+outTran+"\" onclick=\"deliverProduct('"+sStockUid+"','"+sProductName+"','"+stockLevel+"');\">&nbsp;");
                }
                html.append("<input type='button' title='"+changeLevelInTran+"' class='button' style='width:30px;' value=\""+inTran+"\" onclick=\"receiveProduct('"+sStockUid+"','"+sProductName+"');\">&nbsp;");
                html.append("<input type='button' title='"+orderThisProductTran+"' class='button' value=\""+orderTran+"\" onclick=\"orderProduct('"+sStockUid+"','"+sProductName+"');\">&nbsp;");
                html.append("<input type='button' title='"+batchesTran+"' class='button' value=\""+batchesTran+"\" onclick=\"batchesList('"+sStockUid+"');\">&nbsp;");
            }

            html.append("</td>");

            html.append("</tr>");
        }

        return html;
    }
%>

<%
	long day = 24*3600*1000;
	long year = 365*day;
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = null;
	try{
		ps=conn.prepareStatement("select OC_POINTER_KEY,OC_POINTER_VALUE from OC_POINTERS"+
	                             " where OC_POINTER_KEY like 'drugprice.%'"+
				                 "  and OC_POINTER_UPDATETIME between ? and ?"+
	                             " order by OC_POINTER_VALUE");
		ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date(new java.util.Date().getTime()-year).getTime()));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String key = rs.getString("OC_POINTER_KEY");
			String value= rs.getString("OC_POINTER_VALUE");
			key = "1."+key.split("\\.")[2];
			double totalprice = Double.parseDouble(value.split(";")[0])*Double.parseDouble(value.split(";")[1]);
			double count=Double.parseDouble(value.split(";")[0]);
			if(pumps.get(key)==null){
				pumps.put(key,totalprice);
			}
			else {
				pumps.put(key,(Double)pumps.get(key)+totalprice);
			}
			if(pumpcounts.get(key)==null){
				pumpcounts.put(key,count);
			}
			else {
				pumpcounts.put(key,(Double)pumpcounts.get(key)+count);
			}
		}
		rs.close();
		ps.close();
		conn.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
  
    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sEditStockUid          = checkString(request.getParameter("EditStockUid")),
           sEditServiceStockUid   = checkString(request.getParameter("EditServiceStockUid")),
           sEditProductUid        = checkString(request.getParameter("EditProductUid")),
           sEditLevel             = checkString(request.getParameter("EditLevel")),
           sEditMinimumLevel      = checkString(request.getParameter("EditMinimumLevel")),
           sEditMaximumLevel      = checkString(request.getParameter("EditMaximumLevel")),
           sEditOrderLevel        = checkString(request.getParameter("EditOrderLevel")),
           sEditBegin             = checkString(request.getParameter("EditBegin")),
           sEditEnd               = checkString(request.getParameter("EditEnd")),
           sEditDefaultImportance = checkString(request.getParameter("EditDefaultImportance")),
           sEditSupplierUid       = checkString(request.getParameter("EditSupplierUid"));

    // afgeleide data
    String sEditServiceStockName = checkString(request.getParameter("EditServiceStockName")),
           sEditProductName      = checkString(request.getParameter("EditProductName")),
           sEditSupplierName     = checkString(request.getParameter("EditSupplierName"));

    // external data
    String sServiceId = checkString(request.getParameter("ServiceId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** pharacy/manageProductStocks.jsp *******************");
        Debug.println("sAction                : "+sAction);
        Debug.println("sEditStockUid          : "+sEditStockUid);
        Debug.println("sEditServiceStockUid   : "+sEditServiceStockUid);
        Debug.println("sEditProductUid        : "+sEditProductUid);
        Debug.println("sEditLevel             : "+sEditLevel);
        Debug.println("sEditMinimumLevel      : "+sEditMinimumLevel);
        Debug.println("sEditMaximumLevel      : "+sEditMaximumLevel);
        Debug.println("sEditOrderLevel        : "+sEditOrderLevel);
        Debug.println("sEditBegin             : "+sEditBegin);
        Debug.println("sEditEnd               : "+sEditEnd);
        Debug.println("sEditDefaultImportance : "+sEditDefaultImportance);
        Debug.println("sEditSupplierUid       : "+sEditSupplierUid);
        Debug.println("sEditServiceStockName  : "+sEditServiceStockName);
        Debug.println("sEditSupplierName      : "+sEditSupplierName);
        Debug.println("sEditProductName       : "+sEditProductName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String msg = "", sFindServiceStockUid = "", sFindProductUid = "", sFindLevel = "",
           sFindMinimumLevel = "", sFindMaximumLevel = "", sFindOrderLevel = "", sFindBegin = "",
           sFindEnd = "", sFindDefaultImportance = "", sSelectedServiceStockUid = "", sSelectedProductUid = "",
           sSelectedLevel = "", sSelectedMinimumLevel = "", sSelectedMaximumLevel = "", sSelectedOrderLevel = "",
           sSelectedBegin = "", sSelectedEnd = "", sSelectedServiceStockName = "",
           sSelectedProductName = "", sFindSupplierUid = "", sFindSupplierName = "",
           sSelectedSupplierUid = "", sSelectedSupplierName = "";
    
    String sSelectedDefaultImportance = MedwanQuery.getInstance().getConfigString("productStockDefaultImportance","type1native");

    int foundStockCount = 0;
    StringBuffer stocksHtml = null;

    // display options
    boolean displayEditFields = false, displayFoundRecordsLayout1 = false, displayFoundRecordsLayout2 = false;

    String sDisplaySearchFields = checkString(request.getParameter("DisplaySearchFields"));
    if(sDisplaySearchFields.length()==0) sDisplaySearchFields = "true"; // default
    boolean displaySearchFields = sDisplaySearchFields.equalsIgnoreCase("true");

    String sDisplayLowStocks = checkString(request.getParameter("DisplayLowStocks"));
    if(sDisplayLowStocks.length()==0) sDisplayLowStocks = "false"; // default
    boolean displayLowStocks = sDisplayLowStocks.equalsIgnoreCase("true");


    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save") && sEditStockUid.length()>0){    	
        // create productStock
        ProductStock stock = new ProductStock();
        stock.setUid(sEditStockUid);
        stock.setServiceStockUid(sEditServiceStockUid);
        stock.setProductUid(sEditProductUid);
        stock.setDefaultImportance(sEditDefaultImportance);
        stock.setSupplierUid(sEditSupplierUid);
        stock.setUpdateUser(activeUser.userid);

        if(sEditLevel.length() > 0)        stock.setLevel(Integer.parseInt(sEditLevel));
        if(sEditMinimumLevel.length() > 0) stock.setMinimumLevel(Integer.parseInt(sEditMinimumLevel));
        if(sEditMaximumLevel.length() > 0) stock.setMaximumLevel(Integer.parseInt(sEditMaximumLevel));
        if(sEditOrderLevel.length() > 0)   stock.setOrderLevel(Integer.parseInt(sEditOrderLevel));
        if(sEditBegin.length() > 0)        stock.setBegin(ScreenHelper.parseDate(sEditBegin));
        if(sEditEnd.length() > 0)          stock.setEnd(ScreenHelper.parseDate(sEditEnd));

        // does product exist ?
        String existingStockUid = stock.exists();
        boolean stockExists = (existingStockUid.length()>0 && Double.parseDouble(existingStockUid)>-1);
        Debug.println("stockExists : "+stockExists);

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
        ProductStock.delete(sEditStockUid);
        msg = getTran("web","dataisdeleted",sWebLanguage);
        sAction = "findShowOverview"; // display overview even if only one record remains
    }

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.startsWith("find")){
        if(sAction.equals("findShowOverview")){
            displayEditFields = false;
        }

        // get data from form
        sFindServiceStockUid   = checkString(request.getParameter("FindServiceStockUid"));
        sFindProductUid        = checkString(request.getParameter("FindProductUid"));
        sFindLevel             = checkString(request.getParameter("FindLevel"));
        sFindMinimumLevel      = checkString(request.getParameter("FindMinimumLevel"));
        sFindMaximumLevel      = checkString(request.getParameter("FindMaximumLevel"));
        sFindOrderLevel        = checkString(request.getParameter("FindOrderLevel"));
        sFindBegin             = checkString(request.getParameter("FindBegin"));
        sFindEnd               = checkString(request.getParameter("FindEnd"));
        sFindDefaultImportance = checkString(request.getParameter("FindDefaultImportance"));
        sFindSupplierUid       = checkString(request.getParameter("FindSupplierUid"));

        // get supplier name
        if(sFindSupplierUid.length() > 0) sFindSupplierName = getTran("service",sFindSupplierUid,sWebLanguage);
        else                              sFindSupplierName = "";

        // search all products for a specified productStock
        if(sServiceId.length() > 0) {
        	sFindServiceStockUid = sEditServiceStockUid;
        }
        else if(sEditServiceStockUid.length()>0){
        	ServiceStock serviceStock = ServiceStock.get(sEditServiceStockUid);
        	if(serviceStock!=null){
        		sServiceId=serviceStock.getServiceUid();
            	sFindServiceStockUid = sEditServiceStockUid;
        	}
        }

        Vector productStocks = ProductStock.find(sFindServiceStockUid,sFindProductUid,sFindLevel,sFindMinimumLevel,
                                                 sFindMaximumLevel,sFindOrderLevel,sFindBegin,sFindEnd,sFindDefaultImportance,
                                                 sFindSupplierUid,"","OC_PRODUCT_NAME","DESC");

        // display other layout if stocks of only one service are shown
        if(sServiceId.length()==0) stocksHtml = objectsToHtml1(productStocks,sWebLanguage);
        else                       stocksHtml = objectsToHtml2(productStocks,sServiceId,sWebLanguage,activeUser);

        foundStockCount = productStocks.size();

        // what layout to use
        if(sServiceId.length() > 0){
            displayFoundRecordsLayout1 = false;
            displayFoundRecordsLayout2 = true;
        }
        else{
            displayFoundRecordsLayout1 = true;
            displayFoundRecordsLayout2 = false;
        }
    }

    //--- SHOW DETAILS ----------------------------------------------------------------------------
    if(sAction.startsWith("showDetails")){
        displayEditFields = true;
        displaySearchFields = false;

        // get specified record
        if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
            ProductStock productStock = ProductStock.get(sEditStockUid);

            if(productStock!=null){
                sSelectedServiceStockUid   = checkString(productStock.getServiceStockUid());
                sSelectedProductUid        = checkString(productStock.getProduct().getUid());
                sSelectedLevel             = (productStock.getLevel()<0?"":productStock.getLevel()+"");
                sSelectedMinimumLevel      = (productStock.getMinimumLevel()<0?"":productStock.getMinimumLevel()+"");
                sSelectedMaximumLevel      = (productStock.getMaximumLevel()<0?"":productStock.getMaximumLevel()+"");
                sSelectedOrderLevel        = (productStock.getOrderLevel()<0?"":productStock.getOrderLevel()+"");
                sSelectedDefaultImportance = checkString(productStock.getDefaultImportance());
                sSelectedSupplierUid       = checkString(productStock.getSupplierUid());

                // format begin date
                java.util.Date tmpDate = productStock.getBegin();
                if(tmpDate!=null) sSelectedBegin = ScreenHelper.formatDate(tmpDate);

                // format end date
                tmpDate = productStock.getEnd();
                if(tmpDate!=null) sSelectedEnd = ScreenHelper.formatDate(tmpDate);

                // afgeleide data
                sSelectedServiceStockName = productStock.getServiceStock().getName();

                // productname
                Product product = productStock.getProduct();
                if(product!=null) sSelectedProductName = product.getName();
                else              sSelectedProductName = productStock.getProductUid();

                // supplier
                if(sSelectedSupplierUid.length() > 0){
                    sSelectedSupplierName = getTranNoLink("service",sSelectedSupplierUid,sWebLanguage);
                }
            }
        }
        else if(sAction.equals("showDetailsAfterAddReject")){
            // do not get data from DB, but show data that were allready on form
            sSelectedServiceStockUid   = sEditServiceStockUid;
            sSelectedProductUid        = sEditProductUid;
            sSelectedLevel             = sEditLevel;
            sSelectedMinimumLevel      = sEditMinimumLevel;
            sSelectedMaximumLevel      = sEditMaximumLevel;
            sSelectedOrderLevel        = sEditOrderLevel;
            sSelectedBegin             = sEditBegin;
            sSelectedEnd               = sEditEnd;
            sSelectedDefaultImportance = sEditDefaultImportance;
            sSelectedSupplierUid       = sEditSupplierUid;

            // afgeleide data
            sSelectedServiceStockName = sEditServiceStockName;
            sSelectedProductName      = sEditProductName;
            sSelectedSupplierName     = sEditSupplierName;
        }
    }

    // compose form action
    String sFormActionParams = "";
    if(sServiceId.length() > 0){
        sFormActionParams+= "&ServiceId="+sServiceId;
    }

    if(sEditServiceStockUid.length() > 0){
        sFormActionParams+= "&EditServiceStockUid="+sEditServiceStockUid;
    }

    // onclick : when editing, save, else search when pressing 'enter'
    String sOnKeyDown = "";
    if(sAction.startsWith("showDetails")){
        sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSave();}\"";
    }
    else{
        if(!sAction.equals("findShowOverview")){
            sOnKeyDown = "onKeyDown=\"if(enterEvent(event,13)){doSearch();}\"";
        }
    }
%>
<form name="transactionForm" id="transactionForm" method="post" action='<c:url value="/main.do"/>?Page=pharmacy/manageProductStocks.jsp<%=sFormActionParams%>&ts=<%=getTs()%>' <%=sOnKeyDown%> <%=(displaySearchFields||sAction.equals("findShowOverview")?"onClick=\"clearMessage();\"":"onclick=\"setSaveButton(event);clearMessage();\" onkeyup=\"setSaveButton(event);\"")%>>
    <%=writeTableHeader("Web.manage","ManageProductStocks",sWebLanguage,(sAction.equals("findShowOverview")?"":"doBack();"))%>
    
    <%-- display servicename and servicestockname --%>
    <%
        String sServiceName = "", sServiceStockName = "";
        if(sServiceId.length() > 0 || sEditServiceStockUid.length() > 0){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%
                        // Servicename
                        if(sServiceId.length() > 0){
                            sServiceName = getTran("Service",sServiceId,sWebLanguage);
                        }

                        if(sServiceName.length() > 0){
	                        %>
		                        <tr>
		                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","service",sWebLanguage)%>&nbsp;</td>
		                            <td class="admin2"><%=sServiceName%></td>
		                        </tr>
	                        <%
                        }

                        // ServicestockName
                        ServiceStock serviceStock = new ServiceStock();
                        serviceStock = serviceStock.get(sEditServiceStockUid);
                        if(serviceStock!=null) sServiceStockName = serviceStock.getName();

                        if(sServiceStockName.length() > 0){
	                        %>
		                        <tr>
		                            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","servicestock",sWebLanguage)%>&nbsp;</td>
		                            <td class="admin2"><%=sServiceStockName%></td>
		                        </tr>
	                        <%
                        }
                    %>
                    
                    <tr id="filtersection">
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","productstock",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2"><input type='text' class='text' name='filter' id='filter' onkeyup='showSearchResults(this.value)' value='' size='10'/></td>
                    </tr>
                </table>
                
                <%-- display message --%>
                <%
                    if(sAction.equals("findShowOverview")){
                        %><span id="msgArea"><%=msg%></span><%
                        if(msg.length()>0){
                            %><br><%
                        }
                    }
                %>
                <br>
            <%
        }
    %>

    <%
        //*****************************************************************************************
        //*** process display options *************************************************************
        //*****************************************************************************************

        //--- SEARCH FIELDS -----------------------------------------------------------------------
        if(displaySearchFields){
            // afgeleide data
            String sFindServiceStockName = checkString(request.getParameter("FindServiceStockName")),
                   sFindProductName      = checkString(request.getParameter("FindProductName"));

            %>
                <table width="100%" class="list" cellspacing="1" onClick="transactionForm.onkeydown='if(enterEvent(event,13)){doSearch();}';" onKeyDown="if(enterEvent(event,13)){doSearch();}">
                    <%-- Service Stock --%>
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","servicestock",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="hidden" name="FindServiceStockUid" value="<%=sFindServiceStockUid%>">
                            <input class="text" type="text" name="FindServiceStockName" readonly size="<%=sTextWidth%>" value="<%=sFindServiceStockName%>">

                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('FindServiceStockUid','FindServiceStockName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindServiceStockUid.value='';transactionForm.FindServiceStockName.value='';">
                        </td>
                    </tr>
                    <%-- Product --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","product",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="hidden" name="FindProductUid" value="<%=sFindProductUid%>">
                            <input class="text" type="text" name="FindProductName" readonly size="<%=sTextWidth%>" value="<%=sFindProductName%>">
                           
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProduct('FindProductUid','FindProductName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindProductUid.value='';transactionForm.FindProductName.value='';">
                        </td>
                    </tr>
                    <%-- Level --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","Level",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindLevel" size="5" maxLength="5" value="<%=sFindLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- MinimumLevel --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","MinimumLevel",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindMinimumLevel" size="5" maxLength="5" value="<%=sFindMinimumLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- MaximumLevel --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","MaximumLevel",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindMaximumLevel" size="5" maxLength="5" value="<%=sFindMaximumLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- OrderLevel --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","OrderLevel",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="FindOrderLevel" size="5" maxLength="5" value="<%=sFindOrderLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    <%-- Begin --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","begindate",sWebLanguage)%></td>
                        <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
                    </tr>
                    <%-- End --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","enddate",sWebLanguage)%></td>
                        <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
                    </tr>
                    <%-- DefaultImportance (dropdown : native|low|high) --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","DefaultImportance",sWebLanguage)%></td>
                        <td class="admin2">
                            <select class="text" name="FindDefaultImportance">
                                <option value=""></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstock.defaultimportance",sFindDefaultImportance,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- supplier --%>
                    <tr>
                        <td class="admin2" nowrap><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="FindSupplierUid" value="<%=sFindSupplierUid%>">
                            <input class="text" type="text" name="FindSupplierName" readonly size="<%=sTextWidth%>" value="<%=sFindSupplierName%>">
                           
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('FindSupplierUid','FindSupplierName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.FindSupplierUid.value='';transactionForm.FindSupplierName.value='';">
                        </td>
                    </tr>
                    
                    <%-- SEARCH BUTTONS --%>
                    <tr>
                        <td class="admin2">&nbsp;</td>
                        <td class="admin2">
                            <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearch();">
                            <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                            <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
                           
                            <%-- display message --%>
                            <span id="msgArea"><%=msg%></span>
                        </td>
                    </tr>
                </table>
                <br>
            <%
        }

        //--- SEARCH RESULTS (layout 1) -----------------------------------------------------------
        if(displayFoundRecordsLayout1){
            if(foundStockCount > 0){
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- header --%>
                        <tr class="admin">
                            <td/>
                            <td><%=getTran("Web","servicestock",sWebLanguage)%></td>
                            <td><%=getTran("Web","productName",sWebLanguage)%></td>
                            <td align="right"><%=getTran("Web","level",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td align="right"><%=getTran("Web","orderlevel",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td><SORTTYPE:DATE><%=getTran("Web","begindate",sWebLanguage)%></SORTTYPE:DATE></td>
                        </tr>
                        <tbody class="hand"><%=stocksHtml%></tbody>
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
                    <br><br>
                <%
            }
            else{
	            // no records found
	            %><%=getTran("web","norecordsfound",sWebLanguage)%><br><br><%
            }
        }

        //--- SEARCH RESULTS (layout 2) -----------------------------------------------------------
        // used for showing productStocks in one serviceStock
        if(displayFoundRecordsLayout2){
            if(foundStockCount > 0){
                %>
                    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
                        <%-- header --%>
                        <tr class="admin">
                            <td/>
                            <td/>
                            <td/>
                            <td><%=getTran("Web","productName",sWebLanguage)%></td>
                            <td style="text-align:right"><%=getTran("Web","level",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td style="text-align:right"><%=getTran("Web","openorders",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td style="text-align:right"><%=getTran("Web","minimumlevel",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td style="text-align:right"><%=getTran("Web","maximumlevel",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td style="text-align:right"><%=getTran("Web","orderlevel",sWebLanguage)%>&nbsp;&nbsp;</td>
                            <td><SORTTYPE:DATE><%=getTran("Web","begindate",sWebLanguage)%></SORTTYPE:DATE></td>
                            <td><%=getTran("Web.manage","PUMP",sWebLanguage)%></td>
                            <td/>
                        </tr>
                        <tbody class="hand"><%=stocksHtml%></tbody>
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
                    
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.alignButtonsStart()%>
                        <input class="button" type="button" name="calculateButton" value='<%=getTranNoLink("Web.manage","calculateOrder",sWebLanguage)%>' onclick="doCalculateOrder('<%=sEditServiceStockUid%>','<%=sServiceStockName%>');">
                        <input class="button" type="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                        <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web.manage","manageservicestocks",sWebLanguage)%>' onclick="doBackToPrevModule();">
                    <%=ScreenHelper.alignButtonsStop()%>
                <%
            }
            else{
                // no records found
                %>
                    <%=getTran("web.manage","noproductsfound",sWebLanguage)%>
                    
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.alignButtonsStart()%>
                        <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                        <input type="button" class="button" name="returnButton" value='<%=getTranNoLink("Web.manage","manageservicestocks",sWebLanguage)%>' onclick="doBackToPrevModule();">
                    <%=ScreenHelper.alignButtonsStop()%>
                <%
            }
        }
        
        // do not show service-stock-selector if serviceStock is yet specified
        if(sEditServiceStockUid.length()==0){
	        %>
	            <input type="hidden" name="EditServiceStockUid" id="EditServiceStockUid" value="<%=sSelectedServiceStockUid%>">
	            <input type="hidden" name="ServiceId" id="ServiceId" value="<%=sServiceId%>">
	        <%
        }
        else{
	        %>
	            <input type="hidden" name="EditServiceStockUid" id="EditServiceStockUid" value="<%=sEditServiceStockUid%>">
	            <input type="hidden" name="ServiceId" id="ServiceId" value="<%=sServiceId%>">
	        <%
        }
        
        //--- EDIT FIELDS -------------------------------------------------------------------------
        if(displayEditFields){
            %>
                <table class="list" width="100%" cellspacing="1">
                    <%
                        // do not show service-stock-selector if serviceStock is yet specified
                        if(sEditServiceStockUid.length()==0){
	                        %>
	                        <%-- Service Stock --%>
	                        <tr>
	                            <td class="admin" nowrap><%=getTran("Web","servicestock",sWebLanguage)%> *</td>
	                            <td class="admin2">
	                                <input class="text" type="text" name="EditServiceStockName" readonly size="<%=sTextWidth%>" value="<%=sSelectedServiceStockName%>">
	
	                                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchServiceStock('EditServiceStockUid','EditServiceStockName');">
	                                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditServiceStockUid.value='';transactionForm.EditServiceStockName.value='';">
	                            </td>
	                        </tr>
	                        <%
                        }
                        else{
                            %><%-- hidden Service Stock --%><%
                        }
                    %>
                    
                    <%-- Product --%>
	                <tr class="gray">
                        <td colspan="2">&nbsp;<%=getTran("Web","productstockid",sWebLanguage)%>: <%=sEditStockUid %></td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>" nowrap><%=getTran("Web","product",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="hidden" name="EditProductUid" id="EditProductUid" value="<%=sSelectedProductUid%>">
                            <input class="text" type="text" name="EditProductName" id="EditProductName" readonly size="<%=sTextWidth%>" value="<%=sSelectedProductName%>">

                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchProduct('EditProductUid','EditProductName','EditSupplierUid','EditSupplierName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditProductUid.value='';transactionForm.EditProductName.value='';">
                        </td>
                    </tr>
                    
                    <%-- Level (required) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","Level",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" <%=(sAction.equals("showDetailsNew")?"":"style='color:#999;'")%> name="EditLevel" <%=(sAction.equals("showDetailsNew")?"":"readonly")%> size="10" maxLength="10" value="<%=sSelectedLevel%>" <%=(sAction.equals("showDetailsNew")?"onKeyUp='isNumber(this);'":"")%>>
                        </td>
                    </tr>
                    
                    <%-- MinimumLevel (required) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","MinimumLevel",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditMinimumLevel" size="10" maxLength="10" value="<%=sSelectedMinimumLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    
                    <%-- MaximumLevel (implied) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","MaximumLevel",sWebLanguage)%></td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditMaximumLevel" size="10" maxLength="10" value="<%=sSelectedMaximumLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    
                    <%-- OrderLevel (required) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","OrderLevel",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <input class="text" type="text" name="EditOrderLevel" size="10" maxLength="10" value="<%=sSelectedOrderLevel%>" onKeyUp="isNumber(this);">
                        </td>
                    </tr>
                    
                    <%-- Begin --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2"><%=writeDateField("EditBegin","transactionForm",sSelectedBegin,sWebLanguage)%>
                            <%
                                // if new productstock : set today as default value for begindate
                                if(sAction.equals("showDetailsNew")){
                                    %><script>getToday(document.getElementsByName('EditBegin')[0]);</script><%
                                }
                            %>
                        </td>
                    </tr>
                    
                    <%-- End --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","enddate",sWebLanguage)%></td>
                        <td class="admin2"><%=writeDateField("EditEnd","transactionForm",sSelectedEnd,sWebLanguage)%></td>
                    </tr>
                    
                    <%-- DefaultImportance (dropdown : native|low|high) --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","DefaultImportance",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <select class="text" name="EditDefaultImportance">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelectUnsorted("productstock.defaultimportance",sSelectedDefaultImportance,sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    
                    <%-- supplier --%>
                    <tr>
                        <td class="admin" nowrap><%=getTran("Web","supplier",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <input type="hidden" name="EditSupplierUid" id="EditSupplierUid" value="<%=sSelectedSupplierUid%>">
                            <input class="text" type="text" name="EditSupplierName" id="EditSupplierName" readonly size="<%=sTextWidth%>" value="<%=sSelectedSupplierName%>">
                           
                            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchSupplier('EditSupplierUid','EditSupplierName');">
                            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="transactionForm.EditSupplierUid.value='';transactionForm.EditSupplierName.value='';">
                        </td>
                    </tr>
                    
                    <%-- EDIT BUTTONS --%>
                    <tr>
                        <td class="admin">&nbsp;</td>
                        <td class="admin2">
                            <%
                                if(sAction.equals("showDetails") || sAction.equals("showDetailsAfterUpdateReject")){
                                    // existing productStock : display saveButton with save-label
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                                        <input class="button" type="button" name="deleteButton" value='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick="doDelete('<%=sEditStockUid%>');">
                                    <%
                                }
                                else if(sAction.equals("showDetailsNew") || sAction.equals("showDetailsAfterAddReject")){
                                    // new productStock : display saveButton with add-label
                                    %>
                                        <input class="button" type="button" name="saveButton" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doAdd();">
                                    <%
                                }
                            %>
                            <%-- BACK TO OVERVIEW --%>
                            <input class="button" type="button" name="returnButton" value='<%=getTranNoLink("Web","backtooverview",sWebLanguage)%>' onclick="doBackToOverview();">
                            <%-- display message --%>
                            <span id="msgArea"><%=msg%></span>
                        </td>
                    </tr>
                </table>
                
                <%-- indication of obligated fields --%>
                <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
                <br><br>
                
                <table>
                	<tr>
                		<td class='text'><a href="javascript:printFiche('<%=sEditStockUid %>','<%=sSelectedProductName %>')"><%=getTran("web","productstockfile.interactive",sWebLanguage)%></a></td>
                		<td class='text'><a href="javascript:printPDFFiche('<%=sEditStockUid %>')"><%=getTran("web","productstockfile.pdf",sWebLanguage)%></a></td>
                	</tr>
                </table>
            <%
        }
    %>
    
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditStockUid" value="<%=sEditStockUid%>">
    <input type="hidden" name="DisplaySearchFields" value="<%=displaySearchFields%>">
    <input type="hidden" name="DisplayLowStocks" value="<%=displayLowStocks%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>  
  <%
      // default focus field
      if(displayEditFields){
          if(sEditServiceStockUid.length() == 0){
              %>transactionForm.EditServiceStockName.focus();<%
          }
          else{
              %>transactionForm.EditProductName.focus();<%
          }
      }
      else{
          if(displaySearchFields){
              %>transactionForm.FindServiceStockName.focus();<%
          }
      }
  %>

  <%-- DO ADD --%>
  function doAdd(){
    transactionForm.EditStockUid.value = "-1";
    doSave();
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(checkStockFields()){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "save";
      transactionForm.submit();
    }
    else{
      if(transactionForm.EditServiceStockUid.value.length==0){
    	  transactionForm.EditServiceStockName.focus();
      }
      else if(transactionForm.EditProductUid.value.length==0){
        transactionForm.EditProductName.focus();
      }
      else if(transactionForm.EditLevel.value.length==0){
        transactionForm.EditLevel.focus();
      }
      else if(transactionForm.EditMinimumLevel.value.length==0){
        transactionForm.EditMinimumLevel.focus();
      }
      else if(transactionForm.EditBegin.value.length==0){
        transactionForm.EditBegin.focus();
      }
      else if(transactionForm.EditOrderLevel.value.length==0){
        transactionForm.EditOrderLevel.focus();
      }
      else if(transactionForm.EditDefaultImportance.value.length==0){
        transactionForm.EditDefaultImportance.focus();
      }
    }
  }

  <%-- CHECK STOCK FIELDS --%>
  function checkStockFields(){
    var maySubmit = true;
    <%-- required fields --%>
    if(!transactionForm.EditServiceStockUid.value.length>0 ||
       !transactionForm.EditProductUid.value.length>0 ||
       !transactionForm.EditLevel.value.length>0 ||
       !transactionForm.EditMinimumLevel.value.length>0 ||
       !transactionForm.EditOrderLevel.value.length>0 ||
       !transactionForm.EditBegin.value.length>0 ||
       !transactionForm.EditDefaultImportance.value.length>0){
      maySubmit = false;
      alertDialog("web.manage","datamissing");
    }
    else{
      <%-- check levels --%>
      if(maySubmit){
        if(transactionForm.EditMaximumLevel.value.length>0 && transactionForm.EditMinimumLevel.value.length>0){
          var maxLevel = parseInt(transactionForm.EditMaximumLevel.value),
              minLevel = parseInt(transactionForm.EditMinimumLevel.value);

          if(maxLevel >= minLevel){
            maySubmit = true;
          }
          else{
            alertDialog("web","maxmustbelargerthanmin");
            transactionForm.EditMaximumLevel.focus();
            maySubmit = false;
          }
        }
      }

      <%-- check dates --%>
      if(maySubmit){
        if(transactionForm.EditBegin.value.length>0 && transactionForm.EditEnd.value.length>0){
          var dateBegin = transactionForm.EditBegin.value,
              dateEnd   = transactionForm.EditEnd.value;

          if(before(dateBegin,dateEnd)){
            maySubmit = true;
          }
          else{
            alertDialog("web.occup","endMustComeAfterBegin");
            transactionForm.EditEnd.focus();
            maySubmit = false;
          }
        }
      }
    }

    return maySubmit;
  }

  <%-- DO DELETE --%>
  function doDelete(stockUid){
    if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.EditStockUid.value = stockUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- DO NEW --%>
  function doNew(){
    <%
    	if(displayEditFields){
            %>clearEditFields();<%
        }

        if(displaySearchFields){
            %>clearSearchFields();<%
        }
    %>

    if(transactionForm.searchButton!=undefined) transactionForm.searchButton.disabled = true;
    if(transactionForm.clearButton!=undefined) transactionForm.clearButton.disabled = true;
    if(transactionForm.newButton!=undefined) transactionForm.newButton.disabled = true;

    transactionForm.Action.value = "showDetailsNew";
    transactionForm.submit();
  }

  <%-- DO SHOW DETAILS --%>
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
    transactionForm.FindServiceStockUid.value = "";
    transactionForm.FindServiceStockName.value = "";

    transactionForm.FindProductUid.value = "";
    transactionForm.FindProductName.value = "";

    transactionForm.FindLevel.value = "";
    transactionForm.FindMinimumLevel.value = "";
    transactionForm.FindMaximumLevel.value = "";
    transactionForm.FindOrderLevel.value = "";
    transactionForm.FindBegin.value = "";
    transactionForm.FindEnd.value = "";
    transactionForm.FindDefaultImportance.value = "";

    transactionForm.FindSupplierUid.value = "";
    transactionForm.FindSupplierName.value = "";
  }

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
	<% if(sEditServiceStockUid.length() == 0){ %>
		transactionForm.EditServiceStockUid.value = "";
	    transactionForm.EditServiceStockName.value = "";
	<% } %>
    transactionForm.EditProductUid.value = "";
    transactionForm.EditProductName.value = "";

    transactionForm.EditLevel.value = "";
    transactionForm.EditMinimumLevel.value = "";
    transactionForm.EditMaximumLevel.value = "";
    transactionForm.EditOrderLevel.value = "";
    transactionForm.EditBegin.value = "";
    transactionForm.EditEnd.value = "";
    transactionForm.EditDefaultImportance.value = "";

    transactionForm.EditSupplierUid.value = "";
    transactionForm.EditDefaultSupplierName.value = "";
  }
  
  <%-- DO SEARCH --%>
  function doSearch(){
    if(transactionForm.FindServiceStockUid.value.length>0 ||
       transactionForm.FindProductUid.value.length>0 ||
       transactionForm.FindLevel.value.length>0 ||
       transactionForm.FindMinimumLevel.value.length>0 ||
       transactionForm.FindMaximumLevel.value.length>0 ||
       transactionForm.FindOrderLevel.value.length>0 ||
       transactionForm.FindSupplierUid.value.length>0 ||
       transactionForm.FindDefaultImportance.value.length>0){
      transactionForm.searchButton.disabled = true;
      transactionForm.clearButton.disabled = true;
      transactionForm.newButton.disabled = true;

      transactionForm.Action.value = "find";
      openSearchInProgressPopup();
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","datamissing");
    }
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,supplierUidField,supplierNameField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>&ReturnProductUidField="+productUidField+"&ReturnProductNameField="+productNameField+"&DisplayProductsOfService=true&resetServiceStockUid=false";

    if(supplierUidField!=undefined){
      url+= "&ReturnSupplierUidField="+supplierUidField;
    }

    if(supplierNameField!=undefined){
      url+= "&ReturnSupplierNameField="+supplierNameField;
    }

    openPopup(url);
  }

  <%-- popup : search service stock --%>
  function searchServiceStock(serviceStockUidField,serviceStockNameField){
    openPopup("/_common/search/searchServiceStock.jsp&ts=<%=getTs()%>&ReturnServiceStockUidField="+serviceStockUidField+"&ReturnServiceStockNameField="+serviceStockNameField);
  }

  <%-- popup : order product --%>
  function orderProduct(productStockUid,productName){
    openPopup("pharmacy/popups/orderProduct.jsp&EditProductStockUid="+productStockUid+"&EditProductName="+productName+"&ts=<%=getTs()%>");
  }

  <%-- popup : order product --%>
  function batchesList(productStockUid){
    openPopup("pharmacy/popups/batchList.jsp&EditProductStockUid="+productStockUid+"&ts=<%=getTs()%>",400,500);
  }

  <%-- popup : receive product --%>
  function receiveProduct(productStockUid,productName){
    openPopup("pharmacy/medication/popups/receiveMedicationPopup.jsp&EditProductStockUid="+productStockUid+"&EditProductName="+productName+"&ts=<%=getTs()%>",750,400);
  }

  <%-- popup : deliver product --%>
  function deliverProduct(productStockUid,productName,stockLevel){
    if(stockLevel <= 0){
      alertDialog("web.manage","insufficientStock");
    }
    else{
      openPopup("pharmacy/medication/popups/deliverMedicationPopup.jsp&EditProductStockUid="+productStockUid+"&EditProductName="+productName+"&ts=<%=getTs()%>",750,400);
    }
  }

  <%-- popup : search supplier --%>
  function searchSupplier(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&SearchExternalServices=true&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- popup : search supplier --%>
  function printFiche(productStockUid,productStockName){
	openPopup("pharmacy/viewProductStockFiches.jsp&ts=<%=getTs()%>&Action=find&FindProductStockUid="+productStockUid+"&GetYear=<%=new SimpleDateFormat("yyyy").format(new java.util.Date())%>&FindServiceStockName=<%=sServiceStockName%>",700,500);
  }

  function printPDFFiche(productStockUid){
	openPopup("statistics/pharmacy/getProductStockFile.jsp&ts=<%=getTs()%>&ProductStockUid="+productStockUid,200,200);
  }

  <%-- popup : CALCULATE ORDER --%>
  function doCalculateOrder(serviceStockUid,serviceStockName){
    openPopup("pharmacy/popups/calculateOrder.jsp&ServiceStockUid="+serviceStockUid+"&ServiceStockName="+serviceStockName+"&ts=<%=getTs()%>",700,400);
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
    if(checkSaveButton()){
      transactionForm.Action.value = "findShowOverview";
      transactionForm.DisplaySearchFields.value = "false";
      transactionForm.returnButton.disabled = true;
      transactionForm.submit();
    }
  }

  <%-- SHOW SEARCH RESULTS --%>
  function showSearchResults(s){
	table = document.getElementById("searchresults");
	rows = table.rows;
	for(var n=1;n<rows.length;n++){
	  cell = rows[n].cells[3];
	  if(cell.firstChild.nodeValue.toLowerCase().indexOf(s.toLowerCase())>=0){
		 rows[n].style.display = "";
      }
	  else{
	    rows[n].style.display = "none";
	  }
	}
  }
  
  <%-- DO BACK TO PREVious MODULE --%>
  function doBackToPrevModule(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageServiceStocks.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=pharmacy/manageProductStocks.jsp&DisplaySearchFields=true&ts=<%=getTs()%>";
  }

  if('<%=sAction%>'=='findShowOverview' || '<%=sAction%>'=='find'){
    if(document.getElementById('filtersection')!=null){
      document.getElementById('filtersection').style.display = '';
    }
     
	<%-- close "search in progress"-popup that might still be open --%>
	var popup = window.open("","Searching","width=1,height=1");
	popup.close();
	if(document.getElementById("filter")){
      window.setTimeout("document.getElementById('filter').focus()",500);
    }
  }
  else{
	if(document.getElementById('filtersection')!=null){
      document.getElementById('filtersection').style.display = 'none';
	}
  }

  <%-- popup : search product --%>
  function searchProduct(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,
		                 unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchProduct.jsp&ts=<%=getTs()%>"+
              "&loadschema=true&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField!=undefined){
      url+= "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
  }
  
  <%-- popup : search userProduct --%>
  function searchUserProduct(productUidField,productNameField,productUnitField,
		                     unitsPerTimeUnitField,unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchUserProduct.jsp&ts=<%=getTs()%>"+
    		  "&loadschema=true"+
    		  "&ReturnProductUidField="+productUidField+
    		  "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField!=undefined){
      url+= "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
  }

  <%-- popup : search product in service stock --%>
  function searchProductInServiceStock(productUidField,productNameField,productUnitField,unitsPerTimeUnitField,
		                               unitsPerPackageField,productStockUidField,serviceStockUidField){
    var url = "/_common/search/searchProductInStock.jsp&ts=<%=getTs()%>"+
              "&loadschema=true"+
              "&DisplayProductsOfPatientService=true"+
              "&ReturnProductUidField="+productUidField+
              "&ReturnProductNameField="+productNameField;

    if(productUnitField!=undefined){
      url+= "&ReturnProductUnitField="+productUnitField;
    }

    if(unitsPerTimeUnitField!=undefined){
      url+= "&ReturnUnitsPerTimeUnitField="+unitsPerTimeUnitField;
    }

    if(unitsPerPackageField!=undefined){
      url+= "&ReturnUnitsPerPackageField="+unitsPerPackageField;
    }

    if(productStockUidField!=undefined){
      url+= "&ReturnProductStockUidField="+productStockUidField;
    }

    if(serviceStockUidField!=undefined){
      url+= "&ReturnServiceStockUidField="+serviceStockUidField;
    }

    openPopup(url);
  }
</script>
