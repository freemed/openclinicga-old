<%@ page import="be.openclinic.pharmacy.Product,
                 be.openclinic.pharmacy.ProductOrder,
                 be.openclinic.pharmacy.ProductStock,
                 be.openclinic.pharmacy.ServiceStock,
                 java.text.DecimalFormat,java.util.*,be.openclinic.medical.Prescription" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<%=checkPermission("pharmacy.productorder","edit",activeUser)%>
<%
    // TODO : THIS FILE NEEDS TO BE CLEANED UP, BUT PLEASE LEAVE ALL DEBUG-STATEMENTS UNTIL TESTED TOROUGHLY
%>
<%!
    //--- GET PROPOSAL AS HTML -----------------------------------------------------------------------
    private StringBuffer getProposalAsHtml(Hashtable proposal, int rowIdx, Hashtable calculationInfo, String sWebLanguage) {
        StringBuffer html = new StringBuffer();
        String sClass, proposalDescr;

        // alternate row-style
        if (rowIdx % 2 == 0) sClass = "1";
        else sClass = "";

        proposalDescr = getTran("web.manage", "orderProposalDescription", sWebLanguage);

        //*** display proposal in one row ***
        html.append("<tr onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\" class='list" + sClass + "' id='header_" + rowIdx + "' title='" + getTran("web.manage", "showCalculationInfo", sWebLanguage) + "'>")
                .append(" <input type='hidden' name='proposal_productstockuid_" + rowIdx + "' value='" + proposal.get("productstockuid") + "'>")
                .append(" <td align='center'><img id='img_" + rowIdx + "' src='" + sCONTEXTPATH + "/_img/plus.png' class='link' onClick=\"toggleCalculationInfo('" + rowIdx + "');\"></td>")
                .append(" <td align='center'><input type='checkbox' name='proposal_idx_" + rowIdx + "' value='" + rowIdx + "' checked></td>")
                .append(" <td><input type='text' class='text' name='proposal_description_" + rowIdx + "' value='" + proposalDescr + " " + proposal.get("productname") + "' size='40' maxLength='255'></td>")
                .append(" <td onClick=\"toggleCalculationInfo('" + rowIdx + "');\">" + proposal.get("productname") + "</td>")
                .append(" <td onClick=\"toggleCalculationInfo('" + rowIdx + "');\">" + proposal.get("supplier") + "</td>")
                .append(" <td><input type='text' class='text' name='proposal_packages_" + rowIdx + "' value='" + proposal.get("packages") + "' size='5' maxLength='5' onKeyUp=\"if(!isNumberLimited(this,1,99999)){this.value='';}\"></td>");

        // level
        int currentLevel = Integer.parseInt((String) proposal.get("level"));
        String sMinimumLevel = (String) proposal.get("minimumlevel"),
                sOrderLevel = (String) proposal.get("orderlevel");

        if (sMinimumLevel.length() > 0 && sOrderLevel.length() > 0) {
            int minimumLevel = Integer.parseInt(sMinimumLevel),
                    orderLevel = Integer.parseInt(sOrderLevel);

            // indicate level in orange or red
            if (currentLevel <= minimumLevel) {
                html.append("<td onClick=\"toggleCalculationInfo('" + rowIdx + "');\" align='right'><font color='red'>" + currentLevel + "</font>&nbsp;&nbsp;</td>");
            } else if (currentLevel <= orderLevel) {
                html.append("<td onClick=\"toggleCalculationInfo('" + rowIdx + "');\" align='right'><font color='orange'>" + currentLevel + "</font>&nbsp;&nbsp;</td>");
            } else {
                html.append("<td onClick=\"toggleCalculationInfo('" + rowIdx + "');\" align='right'>" + currentLevel + "&nbsp;&nbsp;</td>");
            }
        } else {
            html.append("<td onClick=\"toggleCalculationInfo('" + rowIdx + "');\" align='right'>" + currentLevel + "&nbsp;&nbsp;</td>");
        }

        //html.append(" <td align='right'>"+sMinimumLevel+"&nbsp;&nbsp;</td>")
        html.append(" <td onClick=\"toggleCalculationInfo('" + rowIdx + "');\" align='right'>" + sOrderLevel + "&nbsp;&nbsp;</td>")
                .append(" <td>")
                .append("  <select class='text' name='proposal_importance_" + rowIdx + "'>")
                .append(ScreenHelper.writeSelectUnsorted("productorder.importance", (String) proposal.get("importance"), sWebLanguage))
                .append("  </select>")
                .append(" </td>")
                .append("</tr>");

        //*****************************************************************************************
        //*** calculation-info div ****************************************************************
        //*****************************************************************************************
        DecimalFormat deci = new DecimalFormat("#.#");
        DecimalFormat deci2 = new DecimalFormat("0");

        html.append("<tr id='calculation_" + rowIdx + "' style='width:100%;height:25px;display:none;'>")
                .append(" <td colspan='9' style='padding:5px;'>")
                .append("  <table width='70%' cellpadding='0' cellspacing='1' class='list'\">");

        // info header
        html.append("<tr height='25'>")
                .append(" <td colspan='2' class='titleadmin'>&nbsp;" + getTran("web.manage", "calculationInfo", sWebLanguage) + " :</td>")
                .append("</tr>");

        // order period
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web.manage", "orderPeriod", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2' width='100%'>" + calculationInfo.get("orderBegin") + " - " + calculationInfo.get("orderEnd") + "</td>")
                .append("</tr>");

        //*** prescriptions ***
        String sPrescrRule = "", timeUnitTran = "", timeUnitTranSimple = "", sProductUnit = "",
                sTimeUnit, sTimeUnitCount, sUnitsPerTimeUnit, concurrentTimeUnits;
        ProductStock productStock;
        Product product;

        Hashtable prescrInfo;
        int prescriptionsUsingThisProduct = Integer.parseInt((String) calculationInfo.get("prescriptionsUsingThisProduct"));
        for (int i = 0; i < prescriptionsUsingThisProduct; i++) {
            prescrInfo = (Hashtable) calculationInfo.get("prescrInfo" + (i + 1));

            // open prescription table
            html.append("<tr>")
                    .append(" <td class='admin2' nowrap>" + getTran("web", "prescription", sWebLanguage) + " " + (i + 1) + "</td>")
                    .append(" <td class='admin2'>")
                    .append("  <table width='100%' cellpadding='0' cellspacing='1' class='list'>");

            // prescription period
            html.append("<tr height='18'>")
                    .append(" <td class='admin2' nowrap>" + getTran("web.manage", "prescriptionPeriod", sWebLanguage) + "&nbsp;</td>")
                    .append(" <td class='admin2' width='100%'>" + prescrInfo.get("prescrBegin") + " - " + prescrInfo.get("prescrEnd") + "</td>")
                    .append("</tr>");

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            sTimeUnit = checkString((String) prescrInfo.get("timeUnit"));
            sTimeUnitCount = checkString((String) prescrInfo.get("timeUnitCount"));
            sUnitsPerTimeUnit = checkString((String) prescrInfo.get("unitsPerTimeUnit"));

            // only compose prescription-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", deci.format(Double.parseDouble(sUnitsPerTimeUnit)));

                productStock = ProductStock.get((String) proposal.get("productstockuid"));
                product = productStock.getProduct();

                if (product != null) {
                    // productunits
                    if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                        sProductUnit = getTran("product.unit", product.getUnit(), sWebLanguage);
                    } else {
                        sProductUnit = getTran("product.unit", product.getUnit(), sWebLanguage);
                    }
                    sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                    // timeunits
                    if (Integer.parseInt(sTimeUnitCount) == 1) {
                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                        timeUnitTran = getTran("prescription.timeunit", sTimeUnit, sWebLanguage);
                    } else {
                        sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                        timeUnitTran = getTran("prescription.timeunits", sTimeUnit, sWebLanguage);
                    }
                    sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
                }
            }

            // concurrent time units
            concurrentTimeUnits = (String) prescrInfo.get("concurrentTimeUnits");
            if (concurrentTimeUnits.equals("1"))
                timeUnitTran = getTran("prescription.timeunit", sTimeUnit, sWebLanguage);
            else timeUnitTran = getTran("prescription.timeunits", sTimeUnit, sWebLanguage);
            concurrentTimeUnits = deci.format(Double.parseDouble(concurrentTimeUnits));

            html.append("<tr height='18'>")
                    .append(" <td class='admin2' nowrap>" + getTran("web.manage", "concurrentTimeUnits", sWebLanguage) + "&nbsp;</td>")
                    .append(" <td class='admin2'>" + concurrentTimeUnits + " " + timeUnitTran.toLowerCase() + "</td>")
                    .append("</tr>");

            // prescription rule
            double factor = Double.parseDouble(sUnitsPerTimeUnit) / Integer.parseInt(sTimeUnitCount);
            timeUnitTranSimple = getTran("prescription.timeunit", sTimeUnit, sWebLanguage);
            html.append("<tr height='18'>")
                    .append(" <td class='admin2' nowrap>" + getTran("web", "prescriptionrule", sWebLanguage) + "&nbsp;</td>")
                    .append(" <td class='admin2'>" + sPrescrRule + " (" + deci.format(factor) + " " + getTran("web", "per", sWebLanguage) + " " + timeUnitTranSimple.toLowerCase() + ")</td>")
                    .append("</tr>");

            // prescription need
            String prescrNeed = deci2.format(Double.parseDouble((String) prescrInfo.get("prescrNeed")));
            html.append("<tr height='18'>")
                    .append(" <td class='admin2' nowrap>" + getTran("web.manage", "prescriptionNeed", sWebLanguage) + "&nbsp;</td>")
                    .append(" <td class='admin2'>" + prescrNeed + " " + sProductUnit.toLowerCase() + " (" + concurrentTimeUnits + " * " + deci.format(factor) + ")</td>")
                    .append("</tr>");

            // close prescription table
            html.append("  </table>")
                    .append(" </td>")
                    .append("</tr>");
        }

        // total product need
        String productNeed = deci2.format(Double.parseDouble((String) calculationInfo.get("productNeed")));
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web.manage", "totalproductNeed", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + productNeed + " " + sProductUnit.toLowerCase() + "</td>")
                .append("</tr>");

        // units per package
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web.manage", "unitsPerPackage", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + calculationInfo.get("unitsPerPackage") + "</td>")
                .append("</tr>");

        // packages needed
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web.manage", "packagesNeeded", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + calculationInfo.get("packagesNeeded") + " (" + productNeed + "/" + calculationInfo.get("unitsPerPackage") + ")</td>")
                .append("</tr>");

        // currentLevel
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web.manage", "currentLevel", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + calculationInfo.get("currentLevel") + "</td>")
                .append("</tr>");

        // futureLevel
        int futureLevel = Integer.parseInt((String) calculationInfo.get("futureLevel"));
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web.manage", "futureLevel", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + (futureLevel < 0 ? "<font color='red'>" + futureLevel + "</font>" : futureLevel + "") + " (" + calculationInfo.get("currentLevel") + " - " + calculationInfo.get("packagesNeeded") + ")</td>")
                .append("</tr>");

        // orderLevel
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web", "orderLevel", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + calculationInfo.get("orderLevel") + "</td>")
                .append("</tr>");

        // packages needed
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web", "packagesToOrder", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'>" + calculationInfo.get("packagesToOrder") + " " + getTran("web", "packages", sWebLanguage).toLowerCase() + " (" + calculationInfo.get("orderLevel") + " " + (futureLevel < 0 ? "+" : "-") + " " + Math.abs(futureLevel) + ")</td>")
                .append("</tr>");

        // minimum order quantity
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web", "minOrderPackages", sWebLanguage) + "&nbsp;</td>");

        if (checkString((String) calculationInfo.get("minimumOrderQuantity")).equals("-1")) {
            html.append(" <td class='admin2'>" + getTran("web", "notspecified", sWebLanguage) + "</td>");
        } else {
            html.append(" <td class='admin2'>" + calculationInfo.get("minimumOrderQuantity") + "</td>");
        }
        html.append("</tr>");

        // packages to order
        html.append("<tr height='18'>")
                .append(" <td class='admin2' nowrap>" + getTran("web", "packagesToOrder", sWebLanguage) + "&nbsp;</td>")
                .append(" <td class='admin2'><b>" + calculationInfo.get("packagesToOrderBlistered") + " " + getTran("web", "packages", sWebLanguage).toLowerCase() + "</b>");

        if (checkString((String) calculationInfo.get("packagesAddedForBlister")).length() > 0) {
            html.append(" (" + calculationInfo.get("packagesAddedForBlister") + " " + getTran("web.manage", "roundedtoblister", sWebLanguage) + ")</td>");
        }

        html.append("</tr>");

        html.append("  </table>")
                .append(" </td>")
                .append("</tr>");

        return html;
    }
%>
<%
    String sDefaultSortCol = "OC_ORDER_DATEORDERED";

    String sAction = checkString(request.getParameter("Action"));

    // retreive form data
    String sServiceStockUid = checkString(request.getParameter("ServiceStockUid")),
            sUntilDate = checkString(request.getParameter("UntilDate")),
            sServiceStockName = checkString(request.getParameter("ServiceStockName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("################## sAction : " + sAction + " ################################");
        Debug.println("* sServiceStockUid  : " + sServiceStockUid);
        Debug.println("* sServiceStockName : " + sServiceStockName);
        Debug.println("* sUntilDate        : " + sUntilDate + "\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String msg = "";
    int proposalCount = 0;
    StringBuffer proposalsHtml = null;
    SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

    // displayOptions
    boolean displayOrderProposal = false;

    // set default untilDate
    String calculateOrderUntil = "";
    if (sUntilDate.length() == 0) {
        // get period-end from serviceStock
        ServiceStock serviceStock = ServiceStock.get(sServiceStockUid);
        int orderPeriodInMonths = serviceStock.getOrderPeriodInMonths();

        if (orderPeriodInMonths < 0) {
            // get period-end from configuration if not specified in serviceStock
            orderPeriodInMonths = Integer.parseInt(MedwanQuery.getInstance().getConfigParam("orderPeriodInMonths", "12"));
        }

        // add orderPeriodInMonths to now
        Calendar calculateOrderUntilDate = new GregorianCalendar();
        calculateOrderUntilDate.add(Calendar.MONTH, orderPeriodInMonths);
        calculateOrderUntil = stdDateFormat.format(calculateOrderUntilDate.getTime());
        sUntilDate = calculateOrderUntil;
    }

    // sortcol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if (sSortCol.length() == 0) sSortCol = sDefaultSortCol;

    //*********************************************************************************************
    //*** process actions *************************************************************************
    //*********************************************************************************************

    //--- CALCULATE ORDER -------------------------------------------------------------------------
    if (sAction.equals("order")) {
        ProductOrder order;
        String sElementName, sProposalID, sProposalDescr, sProposalPackages, sProposalImportance, sProposalProdStockUid;

        // retreive data of checked proposals
        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            sElementName = (String) e.nextElement();
            if (sElementName.startsWith("proposal_idx_")) {
                sProposalID = sElementName.split("_")[2];
                sProposalDescr = checkString(request.getParameter("proposal_description_" + sProposalID));
                sProposalPackages = checkString(request.getParameter("proposal_packages_" + sProposalID));
                sProposalImportance = checkString(request.getParameter("proposal_importance_" + sProposalID));
                sProposalProdStockUid = checkString(request.getParameter("proposal_productstockuid_" + sProposalID));

                if (Debug.enabled)
                    Debug.println("@@@ PROPOSAL " + sProposalID + " : " + sProposalDescr + "," + sProposalPackages + "," + sProposalImportance + "," + sProposalProdStockUid);

                // execute the proposal = order the product
                order = new ProductOrder();
                order.setUid("-1");
                order.setDescription(sProposalDescr);
                order.setProductStockUid(sProposalProdStockUid);
                order.setPackagesOrdered(Integer.parseInt(sProposalPackages));
                order.setDateOrdered(new java.util.Date());
                order.setImportance(sProposalImportance); // (native|high|low)
                order.setUpdateUser(activeUser.userid);

                String orderWithSameDataUid = order.exists();
                boolean orderWithSameDataExists = orderWithSameDataUid.length() > 0;

                //***** insert new order *****
                if (!orderWithSameDataExists) {
                    order.store();
                    msg = getTran("web.manage", "orderplaced", sWebLanguage);
                }
                //***** reject new addition *****
                else {
                    // show rejected data
                    sAction = "calculateOrder";
                    msg = "<font color='red'>" + getTran("web.manage", "orderexists", sWebLanguage) + "</font>";
                }
            }
        }
    }

    //--- CALCULATE ORDER -------------------------------------------------------------------------
    // get total-product-need based on prescriptions for all productstocks in specified serviceStock
    if (sAction.equals("calculateOrder") && sServiceStockUid.length() > 0) {
        displayOrderProposal = true;
        proposalsHtml = new StringBuffer();

        // variables
        ProductStock productStock = null;
        Hashtable calculationInfo,
                prescrInfo,
                prescrUidsPerProductStock = new Hashtable(),
                prescrInfos = new Hashtable(),
                productNeeds = new Hashtable();
        Calendar now = new GregorianCalendar(),
                untilDate = new GregorianCalendar();
        String timeUnit, importance = "", productName, prescribedProductUid, productStockUid, prescrUid;
        int timeUnitCount, packagesToOrder = 0;
        double unitsPerTimeUnit, concurrentTimeUnits, prescrNeed;
        java.sql.Date prescrBegin, prescrEnd;
        long concurrentTime = 0, millisInTimeUnit = 0;

        Vector productStocks = ServiceStock.getProductStocks(sServiceStockUid);

        untilDate.setTime(stdDateFormat.parse(sUntilDate));
        untilDate.set(untilDate.get(Calendar.YEAR), untilDate.get(Calendar.MONTH), untilDate.get(Calendar.DATE), 0, 0, 0);
        untilDate.setTimeInMillis(untilDate.getTimeInMillis() - (untilDate.getTimeInMillis() % 1000));

        Vector vPrescriptions = Prescription.getActivePrescriptionsByPeriodForStock(sServiceStockUid,untilDate);
        Iterator iter = vPrescriptions.iterator();

        Prescription prescr;
        while(iter.hasNext()){
            prescr = (Prescription)iter.next();
            prescrUid = prescr.getUid();

            prescrBegin = new java.sql.Date(prescr.getBegin().getTime());
            prescrEnd = new java.sql.Date(prescr.getEnd().getTime());
            if (prescrEnd == null) {
                prescrEnd = ScreenHelper.getSQLDate(calculateOrderUntil);
            }

            prescribedProductUid = prescr.getProductUid();

            Product prescribedProduct = Product.get(prescribedProductUid);
            if (prescribedProduct != null) {
                //*************************************************************************************
                // run thru productStocks in serviceStock :
                //  use the productStock that contains the prescribed product
                //  or create a new productStock for the prescribed product
                //*************************************************************************************
                boolean productStockFound = false;
                for (int i = 0; i < productStocks.size(); i++) {
                    productStock = (ProductStock) productStocks.get(i);

                    if (prescribedProductUid.equalsIgnoreCase(productStock.getProductUid())) {
                        productStockFound = true;
                        break;
                    }
                }

                if (!productStockFound) {
                    ServiceStock serviceStock = ServiceStock.get(sServiceStockUid);

                    // create productStock to order prescribed product for
                    productStock = new ProductStock();
                    productStock.setUid("-1");
                    productStock.setBegin(new java.util.Date()); // now
                    productStock.setLevel(0);
                    productStock.setMinimumLevel(0);
                    productStock.setOrderLevel(0);
                    productStock.setProduct(prescribedProduct);
                    productStock.setProductUid(prescribedProductUid);
                    productStock.setServiceStock(serviceStock);
                    productStock.setServiceStockUid(sServiceStockUid);
                    productStock.setSupplier(serviceStock.getService());
                    productStock.setSupplierUid(serviceStock.getUid());
                    productStock.setDefaultImportance("type1native");
                    productStock.setUpdateUser(activeUser.userid);

                    productStock.store();
                }

                productStockUid = productStock.getUid();

                //*************************************************************************************
                //*** calculate concurrent time between order and prescription ************************
                //*************************************************************************************
                // type 1 : prescr before and in order
                if ((prescrBegin.before(now.getTime()) || prescrBegin.getTime() == now.getTimeInMillis()) && (prescrEnd.before(untilDate.getTime()) || prescrEnd.getTime() == untilDate.getTimeInMillis())) {
                    //System.out.println("*** prescription type 1 ***");//////////// todo
                    //System.out.println("     oooooooooooooooooooooooooo");////////////  todo
                    //System.out.println("pppppppppppppppppppppppppp");////////////   todo
                    concurrentTime = prescrEnd.getTime() - now.getTimeInMillis();
                }
                // type 2 : prescr before and after order
                else
                if ((prescrBegin.before(now.getTime()) || prescrBegin.getTime() == now.getTimeInMillis()) && prescrEnd.after(untilDate.getTime())) {
                    //System.out.println("*** prescription type 2 ***");//////////// todo
                    //System.out.println("     oooooooooooooooooooooooooo");////////////    todo
                    //System.out.println("pppppppppppppppppppppppppppppppppppp");////////////   todo
                    concurrentTime = untilDate.getTimeInMillis() - now.getTimeInMillis(); // time of order
                }
                // type 3 : prescr in and after order
                else if (prescrBegin.after(now.getTime()) && prescrEnd.after(untilDate.getTime())) {
                    //System.out.println("*** prescription type 3 ***");//////////// todo
                    //System.out.println("oooooooooooooooooooooooooo");////////////       todo
                    //System.out.println("     pppppppppppppppppppppppppp");////////////     todo
                    concurrentTime = untilDate.getTimeInMillis() - prescrBegin.getTime();
                }
                // type 4 : prescr in order
                else
                if (prescrBegin.after(now.getTime()) && (prescrEnd.before(untilDate.getTime()) || prescrEnd.getTime() == untilDate.getTimeInMillis())) {
                    //System.out.println("*** prescription type 4 ***");//////////// todo
                    //System.out.println("oooooooooooooooooooooooooo");////////////  todo
                    //System.out.println("     pppppppppppppppp");////////////      todo
                    concurrentTime = prescrEnd.getTime() - prescrBegin.getTime(); // time of prescr
                }

                //*************************************************************************************
                //*** calculate product-need based on prescription-rule and concurrent time ***********
                //*************************************************************************************
                timeUnit = prescr.getTimeUnit();//checkString(rs.getString("OC_PRESCR_TIMEUNIT"));
                if (timeUnit.equals("type1hour")) millisInTimeUnit = 3600 * 1000;
                else if (timeUnit.equals("type2day")) millisInTimeUnit = 24 * 3600 * 1000;
                else if (timeUnit.equals("type3week")) millisInTimeUnit = 7 * 24 * 3600 * 1000;
                else if (timeUnit.equals("type4month"))
                    millisInTimeUnit = (long) 31 * 24 * 3600 * 1000; // 31 days to be sure

                concurrentTimeUnits = (double) concurrentTime / (double) millisInTimeUnit;

                timeUnitCount = prescr.getTimeUnitCount();
                unitsPerTimeUnit = prescr.getUnitsPerTimeUnit();

                prescrNeed = (concurrentTimeUnits * unitsPerTimeUnit) / (double) timeUnitCount;

                // keep track of need per product
                if (productNeeds.get(productStockUid) != null) {
                    double totalProductNeed = ((Double) productNeeds.get(productStockUid)).doubleValue();
                    totalProductNeed += prescrNeed;
                    productNeeds.put(productStockUid, new Double(totalProductNeed));
                } else {
                    productNeeds.put(productStockUid, new Double(prescrNeed));
                }

                // keep track of prescriptionUids per product
                if (prescrUidsPerProductStock.get(productStockUid) != null) {
                    Vector prescrUids = (Vector) (prescrUidsPerProductStock.get(productStockUid));
                    prescrUids.add(prescrUid);
                    prescrUidsPerProductStock.put(productStockUid, prescrUids);
                } else {
                    Vector prescrUids = new Vector();
                    prescrUids.add(prescrUid);
                    prescrUidsPerProductStock.put(productStockUid, prescrUids);
                }

                // info about this prescription to display later on
                prescrInfo = new Hashtable();
                prescrInfo.put("timeUnit", timeUnit);
                prescrInfo.put("timeUnitCount", timeUnitCount + "");
                prescrInfo.put("unitsPerTimeUnit", unitsPerTimeUnit + "");
                prescrInfo.put("concurrentTimeUnits", concurrentTimeUnits + "");
                prescrInfo.put("prescrNeed", prescrNeed + "");
                prescrInfo.put("prescrBegin", stdDateFormat.format(prescrBegin));
                prescrInfo.put("prescrEnd", stdDateFormat.format(prescrEnd));
                prescrInfos.put(prescrUid, prescrInfo);
            }
        }

        //*****************************************************************************************
        // run thru prescribed products and the need for them
        //*****************************************************************************************
        Enumeration usedProductStockUids = productNeeds.keys();
        while (usedProductStockUids.hasMoreElements()) {
            productStockUid = (String) usedProductStockUids.nextElement();
            productStock = ProductStock.get(productStockUid);
            prescribedProductUid = productStock.getProductUid();
            double productNeed = ((Double) productNeeds.get(productStockUid)).doubleValue();

            if (productStock.getProduct() != null) {
                // convert need in units to packages
                int orderLevel = productStock.getOrderLevel();
                int unitsPerPackage = productStock.getProduct().getPackageUnits();
                int packagesNeeded = (int) Math.ceil(productNeed / unitsPerPackage); // round up
                int futureLevel = productStock.getLevelIncludingOpenCommands() - packagesNeeded;
                int minimumOrderQuantity = productStock.getProduct().getMinimumOrderPackages();

                int requiredAmountToFullfillOrderLevel = 0;
                if (futureLevel < orderLevel) {
                    requiredAmountToFullfillOrderLevel = Math.abs(orderLevel - futureLevel);
                }

                calculationInfo = new Hashtable();

                Vector prescrUids = (Vector) prescrUidsPerProductStock.get(productStockUid);
                for (int i = 0; i < prescrUids.size(); i++) {
                    calculationInfo.put("prescrInfo" + (i + 1), prescrInfos.get(prescrUids.get(i)));
                }
                calculationInfo.put("prescriptionsUsingThisProduct", prescrUids.size() + "");
                calculationInfo.put("productNeed", ((Double) productNeeds.get(productStockUid)).doubleValue() + "");
                calculationInfo.put("unitsPerPackage", unitsPerPackage + "");
                calculationInfo.put("packagesNeeded", packagesNeeded + "");
                calculationInfo.put("currentLevel", productStock.getLevelIncludingOpenCommands() + "");
                calculationInfo.put("futureLevel", futureLevel + "");
                calculationInfo.put("orderLevel", orderLevel + "");
                calculationInfo.put("minimumOrderQuantity", minimumOrderQuantity + "");
                calculationInfo.put("packagesAddedForBlister", "");
                calculationInfo.put("orderBegin", stdDateFormat.format(new java.util.Date()));
                calculationInfo.put("orderEnd", sUntilDate);

                //*** propose order if levels will be in short in the future **************************
                if (futureLevel < orderLevel) {
                    // importance
                    importance = "type1native";
                    if (futureLevel < productStock.getMinimumLevel()) {
                        importance = "type3high";
                    }
                    // set packagesToOrder to be even with minimumOrderQuantity
                    packagesToOrder = requiredAmountToFullfillOrderLevel;
                    calculationInfo.put("packagesToOrder", packagesToOrder + "");
                    if ((packagesToOrder % minimumOrderQuantity) > 1) {
                        packagesToOrder += (minimumOrderQuantity - (packagesToOrder % minimumOrderQuantity));
                        calculationInfo.put("packagesAddedForBlister", (minimumOrderQuantity - (requiredAmountToFullfillOrderLevel % minimumOrderQuantity)) + "");
                    }
                } else {
                    packagesToOrder=0;

                }

                calculationInfo.put("packagesToOrderBlistered", packagesToOrder + "");

                //*************************************************************************************
                //*** DISPLAY ORDER PROPOSAL **********************************************************
                //*************************************************************************************
                if (packagesToOrder > 0) {
                    // get product name
                    Product product = Product.get(prescribedProductUid);
                    if (product != null) {
                        productName = product.getName();
                    } else {
                        productName = "<font color='red'>" + getTran("web", "nonexistingproduct", sWebLanguage) + "</font>";
                    }

                    //*** determine supplier ***
                    // productstock supplier
                    String supplier = productStock.getSupplierUid();
                    if (supplier.length() > 0) {
                        supplier = getTran("service", supplier, sWebLanguage);
                    } else {
                        // product supplier
                        if (productStock.getProduct() != null) {
                            supplier = productStock.getProduct().getSupplierUid();
                            if (supplier.length() > 0) {
                                supplier = getTran("service", supplier, sWebLanguage);
                            }
                        }
                    }

                    // service stock default supplier
                    if (supplier.length() == 0) {
                        supplier = productStock.getServiceStock().getDefaultSupplierUid();
                        if (supplier.length() > 0) {
                            supplier = getTran("service", supplier, sWebLanguage);
                        }
                    }

                    // create proposal
                    Hashtable proposal = new Hashtable();
                    proposal.put("productname", productName);
                    proposal.put("productstockuid", productStockUid);
                    proposal.put("packages", packagesToOrder + "");
                    proposal.put("supplier", supplier);
                    proposal.put("importance", importance);
                    proposal.put("level", productStock.getLevelIncludingOpenCommands() + "");
                    proposal.put("orderlevel", (productStock.getOrderLevel() > 0 ? productStock.getOrderLevel() + "" : ""));
                    proposal.put("minimumlevel", (productStock.getMinimumLevel() > 0 ? productStock.getMinimumLevel() + "" : ""));

                    // get proposal in html
                    proposalsHtml.append(getProposalAsHtml(proposal, proposalCount++, calculationInfo, sWebLanguage));
                }
            }
        }

        if (sUntilDate.equals(calculateOrderUntil)) sUntilDate = "";
    }
%>
<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:360px;top:220px;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
              <%=getTran("web","calculationInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>
<%-- End Floating layer -------------------------------------------------------------------------%>
<form name="transactionForm" id="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doCalculateOrder();}" onClick="clearMessage();">
    <%-- title --%>
    <table width="100%" cellspacing="0">
        <tr class="admin">
            <td>&nbsp;&nbsp;<%=getTran("Web.manage","calculateorderforservicestock",sWebLanguage)%>&nbsp;:&nbsp;<%=sServiceStockName%></td>
        </tr>
    </table>

    <table class="list" width="100%" cellspacing="1">
        <%-- Until Date --%>
        <tr height="26">
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","foreseeuntil",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=ScreenHelper.writeDateField("UntilDate","transactionForm",sUntilDate,false,true,sWebLanguage,sCONTEXTPATH)%>&nbsp;&nbsp;

                <%-- CALCULATE BUTTON --%>
                <input class="button" type="button" name="calculateButton" value='<%=getTranNoLink("Web.manage","calculateorder",sWebLanguage)%>' onclick="doCalculateOrder();">

                <%-- display message --%>
                <span id="msgArea">&nbsp;<%=msg%></span>
            </td>
        </tr>
    </table>
    <%
        //--- DISPLAY ORDER PROPOSAL --------------------------------------------------------------
        if(displayOrderProposal){
            if(proposalCount > 0){
                %>
                    <br>

                    <div class="search" style="width:100%;height:480px">
                        <table width="100%" cellspacing="0" cellpadding="0" class="list">
                            <%-- clickable header --%>
                            <tr class="admin">
                                <td width="18" nowrap>&nbsp;</td>
                                <td width="18" nowrap>&nbsp;</td>
                                <td width="25%"><%=getTran("Web","description",sWebLanguage)%></td>
                                <td width="20%"><%=getTran("Web","product",sWebLanguage)%></td>
                                <td width="20%"><%=getTran("Web","supplier",sWebLanguage)%></td>
                                <td width="15%"><%=getTran("Web","packagestoorder",sWebLanguage)%></td>
                                <td width="8%" align="right"><%=getTran("Web","level",sWebLanguage)%>&nbsp;&nbsp;</td>
                                <td width="12%" align="right"><%=getTran("Web","orderlevel",sWebLanguage)%>&nbsp;&nbsp;</td>
                                <td width="*"><%=getTran("Web","importance",sWebLanguage)%></td>
                            </tr>

                            <%=proposalsHtml%>
                        </table>

                        <%-- number of records found --%>
                        <%=proposalCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                    </div>

                    <%-- CHECK ALL --%>
                    <a href="javascript:checkAll(true);"><%=getTran("web.manage.checkdb","CheckAll",sWebLanguage)%></a>
                    <a href="javascript:checkAll(false);"><%=getTran("web.manage.checkdb","UncheckAll",sWebLanguage)%></a>
                <%
            }
            else{
                // no records found
                %>
                    &nbsp;<%=getTran("web.manage","noneedtoorderanyproduct",sWebLanguage)%>
                <%
            }
        }
    %>

    <br>

    <%-- BUTTONS --%>
    <center>
        <%
            if(proposalCount > 0){
                %><input type="button" class="button" name="orderButton" value='<%=getTran("Web","order",sWebLanguage)%>' onclick="doOrder();">&nbsp;<%
            }
        %>

        <input type="button" class="button" name="closeButton" value='<%=getTran("Web","close",sWebLanguage)%>' onclick="window.close();">
    </center>

    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ServiceStockUid" value="<%=sServiceStockUid%>">
</form>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>

  <%-- CALCULATE ORDER --%>
  function doCalculateOrder(){
    if(transactionForm.UntilDate.value.length>0){
      if(checkUntilDate()){
        transactionForm.Action.value = "calculateOrder";
        transactionForm.calculateButton.disabled = true;
        transactionForm.closeButton.disabled = true;
        if(transactionForm.orderButton!=undefined) transactionForm.orderButton.disabled = true;

        //ToggleFloatingLayer('FloatingLayer',1);
        transactionForm.submit();
      }
      else{
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=untildatemustbeinthefuture";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","untildatemustbeinthefuture",sWebLanguage)%>");

        transactionForm.UntilDate.focus();
      }
    }
    else{
      transactionForm.UntilDate.focus();

      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }
  }

  <%-- CHECK UNTILL DATE --%>
  function checkUntilDate(){
    if(transactionForm.UntilDate.value.length > 0){
      var untilDate = makeDate(transactionForm.UntilDate.value);
      var now = new Date();

      if(untilDate < now){
        return false;
      }
    }
    return true;
  }

  <%-- ORDER --%>
  function doOrder(){
    if(atLeastOneProposalChecked()){
      var maySubmit = checkFieldsOfCheckedProposals();

      if(maySubmit){
        transactionForm.orderButton.disabled = true;
        transactionForm.closeButton.disabled = true;
        transactionForm.calculateButton.disabled = true;

        transactionForm.Action.value = "order";
        transactionForm.submit();
      }
    }
    else{
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=selectatleastoneorderproposal";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","selectatleastoneorderproposal",sWebLanguage)%>");
    }
  }

  <%-- CHECK FIELDS OF CHECKED PROPOSALS --%>
  function checkFieldsOfCheckedProposals(){
    var stop = false;
    var inputs = document.getElementsByTagName('input');
    var checkBoxIdx = 0;

    for(var i=0; i<inputs.length && !stop; i++){
      if(inputs[i].type=='checkbox'){
        if(inputs[i].checked){
          var descrField = eval("transactionForm.proposal_description_"+checkBoxIdx);
          var packagesField = eval("transactionForm.proposal_packages_"+checkBoxIdx);
          var importanceField = eval("transactionForm.proposal_importance_"+checkBoxIdx);

          if(descrField.value.length==0 || packagesField.value.length==0 || importanceField.value.length==0){
            stop = true;

                 if(descrField.value.length==0)    descrField.focus();
            else if(packagesField.value.length==0) packagesField.focus();
            else                                   importanceField.focus();

            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");

            return false;
          }
        }

        checkBoxIdx++;
      }
    }

    return true;
  }

  <%-- AT LEAST ONE PROPOSAL CHECKED --%>
  function atLeastOneProposalChecked(){
    var inputs = document.getElementsByTagName('input');

    for(var i=0; i<inputs.length; i++){
      if(inputs[i].type=='checkbox'){
        if(inputs[i].checked){
          return true;
        }
      }
    }

    return false;
  }

  <%-- CLEAR MESSAGE --%>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById('msgArea').innerHTML = "";<%
        }
    %>
  }

  <%-- CHECK ALL --%>
  function checkAll(setchecked){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        transactionForm.elements[i].checked = setchecked;
      }
    }
  }

  <%-- TOGGLE CALCULATION INFO --%>
  <%
      String showCalculationTran = getTranNoLink("web.manage","showCalculationInfo",sWebLanguage),
             hideCalculationTran = getTranNoLink("web.manage","hideCalculationInfo",sWebLanguage);
  %>
  function toggleCalculationInfo(rowIdx){
    hideAllInfos(rowIdx);

    var headerObj = document.getElementById('header_'+rowIdx);
    var divObj = document.getElementById('calculation_'+rowIdx);
    var imgObj = document.getElementById('img_'+rowIdx);

    if(divObj.style.display == 'none'){
      divObj.style.display = 'block';
      headerObj.title = "<%=hideCalculationTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/minus.png";
    }
    else{
      divObj.style.display = 'none';
      headerObj.title = "<%=showCalculationTran%>";
      imgObj.src = "<%=sCONTEXTPATH%>/_img/plus.png";
    }
  }

  <%-- HIDE ALL INFOS --%>
  function hideAllInfos(clickedInfoIdx){
    var tables = document.getElementsByTagName('tr');
    for(var i=0; i<tables.length; i++){
      if(tables[i].id.indexOf('calculation_') > -1){
        if(tables[i].id != ('calculation_'+clickedInfoIdx)){
          var rowIdx = tables[i].id.substring('calculation_'.length);

          var headerObj = document.getElementById('header_'+rowIdx);
          var divObj = document.getElementById('calculation_'+rowIdx);
          var imgObj = document.getElementById('img_'+rowIdx);

          divObj.style.display = 'none';
          headerObj.title = "<%=showCalculationTran%>";
          imgObj.src = "<%=sCONTEXTPATH%>/_img/plus.png";
        }
      }
    }
  }

  <%-- The following script is used to hide the calendar whenever you click the document. --%>
  <%-- When using it you should set the name of popup button or image to "popcal", otherwise the calendar won't show up. --%>
  document.onmousedown = function(e){
    var n=!e?self.event.srcElement.name:e.target.name;

    if (document.layers) {
  	  with (gfPop) var l=pageX, t=pageY, r=l+clip.width, b=t+clip.height;
	  if (n!="popcal"&&(e.pageX>r||e.pageX<l||e.pageY>b||e.pageY<t)){
        gfPop1.fHideCal();
        gfPop2.fHideCal();
        gfPop3.fHideCal();
      }
	  return routeEvent(e);
    }
    else if (n!="popcal"){
      gfPop1.fHideCal();
      gfPop2.fHideCal();
      gfPop3.fHideCal();
    }
  }

  if (document.layers) document.captureEvents(Event.MOUSEDOWN);
</script>
