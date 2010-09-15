<%@include file="/includes/validateUser.jsp"%>
<%@page import="com.adobe.fdf.FDFDoc,
                be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.io.OutputStream"%>
<%@page import="java.util.*"%>

<%!
    //--- GET FULL CONTEXT ------------------------------------------------------------------------
    public String getFullContext(javax.servlet.http.HttpServletRequest request){
        return (ScreenHelper.getConfigString("securePorts").indexOf(request.getServerPort() + "") > -1 ? "https://" : "http://") + request.getServerName() + (request.getServerPort() != 80 ? ":" + request.getServerPort() : "") + sCONTEXTPATH;
    }
%>

<%
    FDFDoc outFDF = new FDFDoc();
    TransactionVO transactionVO = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(request.getParameter("serverId")), Integer.parseInt(request.getParameter("transactionId")));
    Iterator itemIter = transactionVO.getItems().iterator();

    // put items in Hash to sort on their name
    java.util.Hashtable itemHash = new Hashtable();
    ItemVO itemVO;
    while (itemIter.hasNext()) {
        itemVO = (ItemVO) itemIter.next();
        itemHash.put(itemVO.getType(), itemVO);
    }

    // sort items on their name
    Vector itemNames = new Vector(itemHash.keySet());
    Collections.sort(itemNames);

    // run thru items alfabetically
    // concatenate values of items with same base-name in first item in that series.
    // As a result, no more sub-items will exist.
    String prevItemName = "", itemNameTmp, itemNameBase, prevItemNameBase;
    ItemVO itemVOFirst, itemVOTmp;
    for (int i = 0; i < itemNames.size(); i++) {
        itemNameTmp = (String) itemNames.get(i);

        if (prevItemName.indexOf("_#") > -1) {
            prevItemNameBase = prevItemName.substring(0, prevItemName.indexOf("_#"));

            if (itemNameTmp.startsWith(prevItemNameBase + "_#")) {
                itemVOTmp = (ItemVO) itemHash.get(itemNameTmp);
                itemNameBase = itemNameTmp.substring(0, itemNameTmp.indexOf("_#"));
                itemVOFirst = (ItemVO) itemHash.get(itemNameBase + "_#0");
                itemVOFirst.setValue(itemVOFirst.getValue() + itemVOTmp.getValue());
                itemHash.remove(itemNameTmp);
            }
        }

        prevItemName = itemNameTmp;
    }

    // run thru remaining items (no more sub-items in hash)
    Enumeration itemEnum = itemHash.keys();
    String itemName;
    while (itemEnum.hasMoreElements()) {
        itemName = (String) itemEnum.nextElement();
        itemVO = (ItemVO) itemHash.get(itemName);

        // chop off numbering
        if (itemName.endsWith("_#0")) {
            itemName = itemName.substring(0, itemName.indexOf("_#0"));
        }

        // set value in pdf
        if (itemName.equalsIgnoreCase("Remarks")) {
            outFDF.SetRichValue(itemName, itemVO.getValue());
        }
        else {
            outFDF.SetValue(itemName, itemVO.getValue());
        }
    }

    outFDF.SetValue("serverId", transactionVO.getServerId() + "");
    outFDF.SetValue("transactionId", transactionVO.getTransactionId() + "");
    outFDF.SetValue("p.title", getTran("web.userprofile", (activePatient.gender.equalsIgnoreCase("m") ? "male_title" : "female_title"), (request.getParameter("file").substring(5).startsWith("N") ? "N" : "F")));

    String sFileName = getFullContext(request) + ("/documents/" + request.getParameter("file")).replaceAll("//", "/");
    outFDF.SetFile(sFileName);
    response.setContentType("application/vnd.fdf");
    OutputStream outs = response.getOutputStream();
    outFDF.Save(outs);
    outs.close();
%>