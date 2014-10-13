<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                java.io.PrintWriter,
                com.itextpdf.text.*,
                be.mxs.common.util.pdf.general.GeneralPDFCreator,
                be.mxs.common.util.pdf.PDFCreator"%>
<%@page import="java.util.*" %>

<%=sJSSORTTABLE%>

<%!
    //--- ADD FOOTER TO PDF -----------------------------------------------------------------------
    // Like PDFFooter-class but with total pagecount
    public ByteArrayOutputStream addFooterToPdf(ByteArrayOutputStream origBaos, HttpSession session) throws Exception {
	    com.itextpdf.text.pdf.PdfReader reader = new com.itextpdf.text.pdf.PdfReader(origBaos.toByteArray());
	    int totalPageCount = reader.getNumberOfPages(); 
	    
	    ByteArrayOutputStream newBaos = new ByteArrayOutputStream();
	    com.itextpdf.text.Document document = new com.itextpdf.text.Document();
	    com.itextpdf.text.pdf.PdfCopy copy = new com.itextpdf.text.pdf.PdfCopy(document,newBaos);
	    document.open();
	
	    String sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
	    String sFooterText = MedwanQuery.getInstance().getConfigString("footer."+sProject,"OpenClinic pdf engine (c)2007-"+new SimpleDateFormat("yyyy").format(new java.util.Date())+", MXS nv");
	    
	    // Loop over the pages of the baos
	    com.itextpdf.text.pdf.PdfImportedPage pdfPage;
	    com.itextpdf.text.pdf.PdfCopy.PageStamp stamp;
	    com.itextpdf.text.Phrase phrase;
	    
	    com.itextpdf.text.Rectangle rect = document.getPageSize();
	    for(int i=0; i<totalPageCount;){
	    	pdfPage = copy.getImportedPage(reader,++i);
	
	        //*** add footer with page numbers ***
	        stamp = copy.createPageStamp(pdfPage);
	        
	    	// footer text
	        phrase = com.itextpdf.text.Phrase.getInstance(0,sFooterText,com.itextpdf.text.FontFactory.getFont(FontFactory.HELVETICA,6));
            com.itextpdf.text.pdf.ColumnText.showTextAligned(stamp.getUnderContent(),1,phrase,(rect.getLeft()+rect.getRight())/2,rect.getBottom()+26,0);
	       
	        // page count
	        phrase = com.itextpdf.text.Phrase.getInstance(0,String.format("%d/%d",i,totalPageCount),com.itextpdf.text.FontFactory.getFont(FontFactory.HELVETICA,6));
            com.itextpdf.text.pdf.ColumnText.showTextAligned(stamp.getUnderContent(),1,phrase,(rect.getLeft()+rect.getRight())/2,rect.getBottom()+18,0);        
	   
	        stamp.alterContents();	
	        copy.addPage(pdfPage);
	    }
	
	    document.close();  
	    reader.close();
	    
	    return newBaos;
    }
%>

<%
    String sAction           = checkString(request.getParameter("actionField")),
           sSelectedFilter   = checkString(request.getParameter("filter")),
           sSelectedTranCtxt = checkString(request.getParameter("selectedTranCtxt"));

    String sDateFrom = checkString(request.getParameter("dateFrom")),
           sDateTo   = checkString(request.getParameter("dateTo"));

    if (sSelectedTranCtxt.length() == 0) sSelectedTranCtxt = "allContexts";
    SimpleDateFormat dateFormat = ScreenHelper.stdDateFormat;
    StringBuffer sOut = new StringBuffer();
    int cbCounter = 0;

    // parse date from if any specified
    java.util.Date dateFrom;
    if(sDateFrom.length() > 0) dateFrom = dateFormat.parse(sDateFrom);
    else                       dateFrom = new java.util.Date(0); // 1970

    // parse date to if any specified
    java.util.Date dateTo;
    if(sDateTo.length() > 0) dateTo = dateFormat.parse(sDateTo);
    else                     dateTo = new java.util.Date(); // now

    //--- PRINT PDF -------------------------------------------------------------------------------
    if(sAction.equals("print")){
        String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));

        ByteArrayOutputStream baosPDF = null;

        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
        sessionContainerWO.verifyPerson(activePatient.personid);
        sessionContainerWO.verifyHealthRecord(null);

        ByteArrayOutputStream origBaos = null;
        
        try{
            PDFCreator pdfCreator = new GeneralPDFCreator(sessionContainerWO, activeUser, activePatient, sAPPTITLE, sAPPDIR, null, null, sPrintLanguage);
            origBaos = pdfCreator.generatePDFDocumentBytes(request, application, (sSelectedFilter.length() > 0), (sSelectedFilter.equals("select_trantypes_recent") ? 0 : 1));
            ByteArrayOutputStream newBaos = addFooterToPdf(origBaos,session);

            // prevent caching
            response.setHeader("Expires","Sat, 6 May 1995 12:00:00 GMT");
            response.setHeader("Cache-Control","Cache=0, must-revalidate");
            response.addHeader("Cache-Control","post-check=0, pre-check=0");
            response.setContentType("application/pdf");

            String sFileName = "filename_"+System.currentTimeMillis()+".pdf";
            response.setHeader("Content-disposition","inline; filename="+sFileName);
            response.setContentLength(newBaos.size());

            ServletOutputStream sos = response.getOutputStream();
            newBaos.writeTo(sos);
            sos.flush();
        }
        catch(DocumentException dex){
            response.setContentType("text/html");
            PrintWriter writer = response.getWriter();
            writer.print(this.getClass().getName()+" caught an exception: "+dex.getClass().getName()+"<br>");
            writer.print("<pre>");
            dex.printStackTrace(writer);
            writer.print("</pre>");
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            if(origBaos!=null) origBaos.reset();
        }
    }
    //--- APPLY FILTER ----------------------------------------------------------------------------
    else if (sAction.equals("applyFilter")) {
        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
        Collection colTrans = sessionContainerWO.getHealthRecordVO().getTransactions();
        Iterator iterator = colTrans.iterator();
        Hashtable hTrans = new Hashtable();
        TransactionVO transaction, newTransaction;
        String sTransTranslation;
        String sClass = "1";
        String tranID, serverID, tranType, tranUser, tranCtxt, sExaminationName, sDocType;
        Timestamp tranDate;
        cbCounter = 1;
        ItemVO docTypeItem;

        // todo : FILTER 1
        //*****************************************************************************************
        //*** FILTER 1 ("Selecteer te printen onderzoeken.") **************************************
        //*****************************************************************************************
        if (sSelectedFilter.equals("select_trans")) {

            // header
            sOut.append("<tr class='admin'>")
                 .append("<td width='30'>&nbsp;</td>")
                 .append("<td width='80'><DESC>"+getTran("web", "date", sWebLanguage)+"</DESC></td>")
                 .append("<td width='45%'>"+getTran("web.occup", "medwan.common.contacttype", sWebLanguage)+"</td>")
                 .append("<td width='250'>"+getTran("web.occup", "medwan.common.context", sWebLanguage)+"</td>")
                 .append("<td width='200'>"+getTran("web.occup", "medwan.common.user", sWebLanguage)+"</td>")
                .append("</tr>");

            // records
            sOut.append("<tbody onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\">");

            while (iterator.hasNext()) {
                transaction = (TransactionVO) iterator.next();
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                if (tranDate.getTime() >= dateFrom.getTime() && tranDate.getTime() <= dateTo.getTime()) {
                    tranID = transaction.getTransactionId()+"";
                    serverID = transaction.getServerId()+"";
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations
                    if (!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")) {
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(), transaction.getTransactionId().intValue());
                        tranUser = transaction.getUser().getPersonVO().lastname+","+transaction.getUser().getPersonVO().firstname;

                        // private info ?
                        boolean privateInfo = false;
                        if (transaction != null) {
                            ItemVO privateInfoItem = transaction.getItem(sPREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if (privateInfoItem != null) {
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if (!privateInfo) {
                            // get context
                            tranCtxt = "";
                            if (transaction != null) {
                                ItemVO itemVO = transaction.getItem(sPREFIX+"ITEM_TYPE_CONTEXT_CONTEXT");
                                if (itemVO != null) {
                                    tranCtxt = itemVO.getValue();
                                }
                            }

                            // retreive name of document if transaction is a document
                            if (tranType.equals(sPREFIX+"TRANSACTION_TYPE_DOCUMENT")) {
                                docTypeItem = transaction.getItem(sPREFIX+"ITEM_TYPE_DOCUMENT_TYPE");
                                if (docTypeItem != null) {
                                    sExaminationName = getTran("web.documents", docTypeItem.getValue(), sWebLanguage);
                                }
                                else {
                                    docTypeItem = transaction.getItem("documentId");
                                    if (docTypeItem != null) {
                                        sDocType = docTypeItem.getValue();
                                        sDocType = sDocType.substring(0, sDocType.indexOf("."));
                                        sExaminationName = getTran("web.documents", sDocType, sWebLanguage);
                                    }
                                    else {
                                        sExaminationName = getTran("web.occup", tranType, sWebLanguage); // just 'DOCUMENT'
                                    }
                                }
                            }
                            else {
                                sExaminationName = getTran("web.occup", tranType, sWebLanguage);
                            }

                            //*** what context-modifier ***
                            if (sSelectedTranCtxt.equals("allContexts")) {
                                // alternate row-style
                                if(sClass.equals("")) sClass = "1";
                                else                  sClass = "";

                                sOut.append("<tr class=\"list"+sClass+"\" >")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+dateFormat.format(tranDate)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+sExaminationName+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+getTran("service", tranCtxt, sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+tranUser+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                            else if (sSelectedTranCtxt.equals("withoutContext")) {
                                if (tranCtxt.length() == 0) {
                                    // alternate row-style
                                    if (sClass.equals("")) sClass = "1";
                                    else sClass = "";

                                    sOut.append("<tr class=\"list"+sClass+"\" >")
                                         .append("<td align='center'>")
                                          .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                         .append("</td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+dateFormat.format(tranDate)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+getTran("web.occup", tranType, sWebLanguage)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+getTran("service", tranCtxt, sWebLanguage)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+tranUser+"</td>")
                                        .append("</tr>");

                                    cbCounter++;
                                }
                            }
                            else if (tranCtxt.equalsIgnoreCase(sSelectedTranCtxt)) {
                                // alternate row-style
                                if (sClass.equals("")) sClass = "1";
                                else sClass = "";

                                sOut.append("<tr class=\"list"+sClass+"\" >")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+dateFormat.format(tranDate)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+getTran("web.occup", tranType, sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+getTran("service", tranCtxt, sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+tranUser+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                        }
                    }
                }
            }

            sOut.append("</tbody>");
        }
        // todo : FILTER 2
        //*****************************************************************************************
        //*** FILTER 2 (Selecteer te printen onderzoek-types.) ************************************
        //*****************************************************************************************
        else if (sSelectedFilter.equals("select_trantypes")) {
            SortedSet set = new TreeSet();

            while (iterator.hasNext()) {
                transaction = (TransactionVO) iterator.next();
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                if (tranDate.getTime() >= dateFrom.getTime() && tranDate.getTime() <= dateTo.getTime()) {
                    sTransTranslation = getTran("Web.occup", transaction.getTransactionType(), sWebLanguage);
                    newTransaction = (TransactionVO) hTrans.get(sTransTranslation);

                    if (newTransaction == null) {
                        hTrans.put(sTransTranslation, transaction);
                        set.add(sTransTranslation);
                    }
                }
            }

            // header
            sOut.append("<tr class='admin'>")
                 .append("<td width='30'>&nbsp;</td>")
                 .append("<td width='*'>"+getTran("web.occup", "medwan.common.contacttype", sWebLanguage)+"</td>")
                 .append("<td width='250'>"+getTran("web.occup", "medwan.common.context", sWebLanguage)+"</td>")
                .append("</tr>");

            // records
            sOut.append("<tbody onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\">");

            if (hTrans != null) {
                Iterator setIter = set.iterator();

                while (setIter.hasNext()) {
                    transaction = (TransactionVO) hTrans.get(setIter.next().toString());
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations
                    if (!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")) {
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(), transaction.getTransactionId().intValue());

                        // private info ?
                        boolean privateInfo = false;
                        if (transaction != null) {
                            ItemVO privateInfoItem = transaction.getItem(sPREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if (privateInfoItem != null) {
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if (!privateInfo) {
                            // context
                            tranCtxt = "";
                            ItemVO itemVO = transaction.getItem(sPREFIX+"ITEM_TYPE_CONTEXT_CONTEXT");
                            if (itemVO != null) {
                                tranCtxt = itemVO.getValue();
                            }

                            //*** what context-modifier ***
                            if (sSelectedTranCtxt.equals("allContexts")) {
                                // alternate row-style
                                if (sClass.equals("")) sClass = "1";
                                else sClass = "";

                                sOut.append("<tr class=\"list"+sClass+"\" >")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">"+getTran("web.occup", tranType, sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">"+getTran("service", tranCtxt, sWebLanguage)+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                            else if (sSelectedTranCtxt.equals("withoutContext")) {
                                if (tranCtxt.length() == 0) {
                                    // alternate row-style
                                    if (sClass.equals("")) sClass = "1";
                                    else sClass = "";

                                    sOut.append("<tr class=\"list"+sClass+"\" >")
                                         .append("<td align='center'>")
                                          .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                         .append("</td>")
                                         .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">"+getTran("web.occup", tranType, sWebLanguage)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">"+getTran("service", tranCtxt, sWebLanguage)+"</td>")
                                        .append("</tr>");

                                    cbCounter++;
                                }
                            }
                            else if (tranCtxt.equalsIgnoreCase(sSelectedTranCtxt)) {
                                // alternate row-style
                                if (sClass.equals("")) sClass = "1";
                                else sClass = "";

                                sOut.append("<tr class=\"list"+sClass+"\" >")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">"+getTran("web.occup", tranType, sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">"+getTran("service", tranCtxt, sWebLanguage)+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                        }
                    }
                }
            }

            sOut.append("</tbody>");
        }
        // todo : FILTER 3
        //*****************************************************************************************
        //*** FILTER 3 (..types waarvan recentste onderzoek zal geprint worden.) ******************
        //*****************************************************************************************
        else if (sSelectedFilter.equals("select_trantypes_recent")) {
            SortedSet set = new TreeSet();

            while (iterator.hasNext()) {
                transaction = (TransactionVO) iterator.next();
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                if (tranDate.getTime() >= dateFrom.getTime() && tranDate.getTime() <= dateTo.getTime()) {
                    sTransTranslation = getTran("Web.occup", transaction.getTransactionType(), sWebLanguage);
                    newTransaction = (TransactionVO) hTrans.get(sTransTranslation);

                    if (newTransaction == null) {
                        hTrans.put(sTransTranslation, transaction);
                        set.add(sTransTranslation);
                    }
                    else if (newTransaction.getUpdateTime().compareTo(transaction.getUpdateTime()) < 0) {
                        hTrans.put(sTransTranslation, transaction);
                        set.add(sTransTranslation);
                    }
                }
            }

            // header
            sOut.append("<tr class='admin'>")
                 .append("<std width='30'>&nbsp;</td>")
                 .append("<td width='80'>"+getTran("web", "date", sWebLanguage)+"</td>")
                 .append("<td width='70%'>"+getTran("web.occup", "medwan.common.contacttype", sWebLanguage)+"</td>")
                 .append("<td width='200'>"+getTran("web.occup", "medwan.common.user", sWebLanguage)+"</td>")
                .append("</tr>");

            // records
            sOut.append("<tbody onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\">");

            if (hTrans != null) {
                Iterator setIter = set.iterator();

                while (setIter.hasNext()) {
                    transaction = (TransactionVO) hTrans.get(setIter.next().toString());

                    tranID = transaction.getTransactionId()+"";
                    serverID = transaction.getServerId()+"";
                    tranDate = new Timestamp(transaction.getUpdateTime().getTime());
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations
                    if (!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")) {
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(), transaction.getTransactionId().intValue());
                        tranUser = transaction.getUser().getPersonVO().lastname+","+transaction.getUser().getPersonVO().firstname;

                        // private info ?
                        boolean privateInfo = false;
                        if (transaction != null) {
                            ItemVO privateInfoItem = transaction.getItem(sPREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if (privateInfoItem != null) {
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if (!privateInfo) {
                            // alternate row-style
                            if (sClass.equals("")) sClass = "1";
                            else sClass = "";

                            sOut.append("<tr class=\"list"+sClass+"\" >")
                                 .append("<td align='center'>")
                                  .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                 .append("</td>")
                                 .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+(tranDate == null ? "" : dateFormat.format(tranDate))+"</td>")
                                 .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+getTran("web.occup", tranType, sWebLanguage)+"</td>")
                                 .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">"+tranUser+"</td>")
                                .append("</tr>");
                        }

                        cbCounter++;
                    }
                }
            }

            sOut.append("</tbody>");
        }
    }

    //#############################################################################################
    //###################################### DISPLAY HTML #########################################
    //#############################################################################################
    if (sAction.equals("") || sAction.equals("applyFilter")) {
        String sSelect;
        PreparedStatement ps;
        ResultSet rs;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        if (sDateFrom.length() == 0) {
            // get date of oldest transaction of active patient (except vaccinations and alerts)
            sSelect = "SELECT t.updateTime FROM Healthrecord h, Transactions t"+
                      " WHERE h.personId = ?"+
                      "  AND t.healthRecordId = h.healthRecordId "+
                      "  AND t.transactionType NOT IN ('be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION',"+
                                                      "'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ALERT')"+
                      " ORDER BY t.updateTime ASC";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(activePatient.personid));
            rs = ps.executeQuery();
            if(rs.next()){
                sDateFrom = dateFormat.format(new java.util.Date(rs.getDate(1).getTime()));
            }

            // close DB-stuff
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
        }

        if (sDateTo.length() == 0) {
            // get date of yougest transaction of active patient (except vaccinations and alerts)
            sSelect = "SELECT t.updateTime FROM Healthrecord h, Transactions t"+
                      " WHERE h.personId = ?"+
                      "  AND t.healthRecordId = h.healthRecordId "+
                      "  AND t.transactionType NOT IN ('be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION',"+
                                                      "'be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ALERT')"+
                      " ORDER BY t.updateTime DESC";

            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(activePatient.personid));
            rs = ps.executeQuery();
            if(rs.next()){
                sDateTo = dateFormat.format(new java.util.Date(rs.getDate(1).getTime()));
            }

            // close DB-stuff
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
        }
		oc_conn.close();
		
        %>
            <a name="top"></a>

            <form name="transactionForm" method="POST">
                <input type="hidden" name="actionField" value="print"/>

                <%=writeTableHeader("Web.Occup","medwan.common.print-patient-record",sWebLanguage,"showWelcomePage.do?Tab=Actions&ts="+getTs())%>

                <table class="list" width="100%" border="0" cellspacing="1">
                    <%-- date from --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","begindate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%=writeDateField("dateFrom","transactionForm",sDateFrom,sWebLanguage)%>
                        </td>
                    </tr>

                    <%-- date to --%>
                    <tr>
                        <td class="admin"><%=getTran("Web","enddate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%=writeDateField("dateTo","transactionForm",sDateTo,sWebLanguage)%>
                        </td>
                    </tr>

                    <%-- examination context selector (only for filter1 and filter2) --%>
                    <%
                        if(sAction.equals("applyFilter") && (sSelectedFilter.equals("select_trans") || sSelectedFilter.equals("select_trantypes"))){
                            %>
                                <tr>
                                    <td class="admin"><%=getTran("Web","context",sWebLanguage)%>&nbsp;</td>
                                    <td class="admin2">
                                        <select name="selectedTranCtxt" class="text">
                                            <option value="allContexts" SELECTED><%=getTran("web.occup","allContexts",sWebLanguage)%></option>
                                            <option value="withoutContext" <%=(sSelectedTranCtxt.equals("withoutContext")?"SELECTED":"")%>><%=getTran("web.occup","withoutContext",sWebLanguage)%></option>
                                            <%
                                                String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"contexts.xml";
                                                if (sDoc.length()>0){
                                                    SAXReader reader = new SAXReader(false);
                                                    Document document = reader.read(new URL(sDoc));
                                                    Iterator ctxtIter = document.getRootElement().elementIterator("context");

                                                    Element ctxtElem;
                                                    String ctxtId;
                                                    while(ctxtIter.hasNext()){
                                                        ctxtElem = (Element)ctxtIter.next();
                                                        ctxtId = ctxtElem.attribute("id").getValue();

                                                        %>
                                                            <option value="<%=ctxtId%>" <%=(sSelectedTranCtxt.equalsIgnoreCase(ctxtId)?"SELECTED":"")%>>
                                                                <%=getTran("Web.Occup",ctxtId,sWebLanguage)%>
                                                            </option>
                                                        <%
                                                    }
                                                }
                                            %>
                                        </select>
                                    </td>
                                </tr>
                            <%
                        }
                    %>

                    <%-- BUTTONS (show, reset) --%>
                    <%
                        if(sAction.equals("applyFilter")){
                            %>
                                <tr>
                                    <td class="admin">&nbsp;</td>
                                    <td class="admin2">
                                        <input type="button" class="button" value="<%=getTranNoLink("web","show",sWebLanguage)%>" onClick="doApplyFilter();">
                                        <input class="button" type="button" value="<%=getTranNoLink("Web","reset",sWebLanguage)%>" onclick="transactionForm.reset();checkAll(true);">

                                        <%
                                            if(!sAction.equals("")){
                                                %><input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.jsp?Page=healthrecord/createPdf.jsp'/>?ts=<%=getTs()%>&action=<%=sAction%>&filter=<%=sSelectedFilter%>'"><%
                                            }
                                        %>
                                    </td>
                                </tr>
                            <%
                        }
                    %>

                    <%-- SELECT A FILTER --------------------------------------------------------%>
                    <%
                        if(sAction.equals("")){
                            %>
                                <%-- print selected transactions --%>
                                <tr>
                                    <td class="admin" rowspan="3" width="<%=sTDAdminWidth%>"><%=getTran("web.occup","filter",sWebLanguage)%>&nbsp;</td>
                                    <td class="admin2">
                                        <input type="radio" class="radio" onClick="enableProceed();" onDblClick="enablePrint();uncheckRadio(this);" name="filter" id="filter1" value="select_trans" <%=(sSelectedFilter.equals("select_trans")? "CHECKED":"")%>><%=getLabel("web.occup","filter.select_trans",sWebLanguage,"filter1")%>
                                    </td>
                                </tr>

                                <%-- print selected transaction types --%>
                                <tr>
                                    <td class="admin2" colspan="2">
                                        <input type="radio" class="radio" onClick="enableProceed();" onDblClick="enablePrint();uncheckRadio(this);" name="filter" id="filter2" value="select_trantypes" <%=(sSelectedFilter.equals("select_trantypes")? "CHECKED":"")%>><%=getLabel("web.occup","filter.select_trantypes",sWebLanguage,"filter2")%>
                                    </td>
                                </tr>

                                <%-- print most recent transaction of the selected types --%>
                                <tr>
                                    <td class="admin2" colspan="2">
                                        <input type="radio" class="radio" onClick="enableProceed();" onDblClick="enablePrint();uncheckRadio(this);" name="filter" id="filter3" value="select_trantypes_recent" <%=(sSelectedFilter.equals("select_trantypes_recent")? "CHECKED":"")%>><%=getLabel("web.occup","filter.select_trantypes_recent",sWebLanguage,"filter3")%>
                                    </td>
                                </tr>
                            <%
                        }
                        else{
                            %><input type="hidden" name="filter" value="<%=sSelectedFilter%>"><%
                        }
                    %>
                </table>

                <%-- DISPLAY FILTER RESULTS -----------------------------------------------------%>
                <%
                    if(sAction.equals("applyFilter")){
                        if(cbCounter > 1){
                            %>
                                <br>
                                <br>

                                <%-- BUTTONS at TOP --%>
                                <table width="100%" cellspacing="1">
                                    <tr>
                                        <td>
                                            <a href="javascript:checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                                            <a href="javascript:checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
                                        </td>
                                        <td align="right">
                                            <a href="#bottom" class="top"><img src="<c:url value='/_img/themes/default/bottom.gif'/>" class="link" border="0"></a>
                                        </td>
                                    </tr>
                                </table>

                                <%-- FOUND RECORDS --%>
                                <table id="searchresults" width="100%" class="sortable" cellspacing="0" style="border:1px solid #ccc;">
                                    <%=sOut%>
                                </table>

                                <%-- BUTTONS at BOTTOM --%>
                                <table width="100%" cellspacing="1">
                                    <tr>
                                        <td>
                                            <a href="javascript:checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                                            <a href="javascript:checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
                                        </td>
                                        <td align="right">
                                            <a href="#top" class="topbutton">&nbsp;</a>
                                        </td>
                                    </tr>
                                </table>

                                <br>
                            <%
                        }
                        else{
                            %>
                                <p><%=getTran("web","noRecordsFound",sWebLanguage)%></p>
                            <%
                        }
                    }
                %>

                <%-- BUTTONS --------------------------------------------------------------------%>
                <p align="right">
                    <%
                        if(cbCounter > 1 || sAction.length() == 0){
                            String sPrintLanguage = activePatient.language;
                            if (sPrintLanguage.length()==0){
                                sPrintLanguage = sWebLanguage;
                            }

                            String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");

                            %>
                                <select class="text" name="PrintLanguage">
                                    <%
                                        String tmpLang;
                                        StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
                                        while (tokenizer.hasMoreTokens()) {
                                            tmpLang = tokenizer.nextToken();

                                            %><option value="<%=tmpLang%>"<%if (tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                                        }
                                    %>
                                </select>
                            
                                <input class="button" type="submit" name="printButton" value="<%=getTranNoLink("Web.Occup","medwan.common.print",sWebLanguage)%>">
                            <%
                        }

                        %>
                            <input class="button" type="button" name="resetButton" value="<%=getTranNoLink("Web","reset",sWebLanguage)%>" onclick="<%=(sAction.length()==0?"doReset();":"transactionForm.reset();checkAll(true);")%>">
                        <%

                        if(!sAction.equals("")){
                            %><input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.jsp?Page=healthrecord/createPdf.jsp'/>?ts=<%=getTs()%>&action=<%=sAction%>&filter=<%=sSelectedFilter%>'"><%
                        }
                    %>
                </p>

                <%-- SCRIPTS --------------------------------------------------------------------%>
                <script>
                  <%
                      if(sAction.equals("")){
                          %>
                              transactionForm.action = "<c:url value='/healthrecord/createPdf.jsp?ts='/><%=getTs()%>";
                              transactionForm.target = "_new";

                              if(transactionForm.filter1.checked || transactionForm.filter2.checked || transactionForm.filter3.checked){
                                enableProceed();
                              }
                              else{
                                enablePrint();
                              }
                          <%
                      }
                      else if(sAction.equals("applyFilter")){
                          %>
                              transactionForm.action = "<c:url value='/healthrecord/createPdf.jsp?ts='/><%=getTs()%>";
                              transactionForm.target = "_new";
                          <%
                      }
                  %>

                  checkAll(true);
                  transactionForm.dateFrom.focus();

                  <%-- ENABLE PRINT --%>
                  function enablePrint(){
                    document.transactionForm.actionField.value = "print";
                    setPrintButtonTextToPrint();
                    displayLanguageSelect(true);

                    transactionForm.action = "<c:url value='/healthrecord/createPdf.jsp?ts='/><%=getTs()%>";
                    transactionForm.target = "_new";
                  }

                  <%-- ENABLE PROCEED --%>
                  function enableProceed(){
                    document.transactionForm.actionField.value = "applyFilter";
                    setPrintButtonTextToProceed();
                    displayLanguageSelect(false);

                    transactionForm.action = "<c:url value='/main.jsp?Page=healthrecord/createPdf.jsp?ts='/><%=getTs()%>";
                    transactionForm.target = "";
                  }

                  <%-- DISPLAY LANGUAGE SELECT --%>
                  function displayLanguageSelect(bool){
                    if(bool){ transactionForm.PrintLanguage.style.display = ""; }
                    else    { transactionForm.PrintLanguage.style.display = "none"; }
                  }

                  <%-- SET PRINTBUTTON TO PROCEED --%>
                  function setPrintButtonTextToProceed(){
                    transactionForm.printButton.value = "<%=getTran("web","proceed",sWebLanguage)%>";
                  }

                  <%-- SET PRINTBUTTON TO PRINT --%>
                  function setPrintButtonTextToPrint(){
                    transactionForm.printButton.value = "<%=getTran("Web.Occup","medwan.common.print",sWebLanguage)%>";
                  }

                  <%-- CLICK CHECKBOX --%>
                  function clickCheckBox(cbName){
                    var cb = eval("transactionForm."+cbName);
                    cb.checked = !cb.checked
                  }

                  <%-- CHECK ALL --%>
                  function checkAll(setchecked){
                    for(var i=0; i<transactionForm.elements.length; i++){
                      if(transactionForm.elements[i].type=="checkbox"){
                        transactionForm.elements[i].checked = setchecked;
                      }
                    }
                  }

                  <%-- DO APPLY FILTER --%>
                  function doApplyFilter(){
                    transactionForm.actionField.value = "applyFilter";
                    transactionForm.action = "<c:url value='/main.jsp?Page=healthrecord/createPdf.jsp?ts='/><%=getTs()%>";
                    transactionForm.target = "_self";
                    transactionForm.submit();
                  }

                  <%-- DO RESET --%>
                  function doReset(){
                    transactionForm.dateFrom.value = "<%=sDateFrom%>";
                    transactionForm.dateTo.value = "<%=sDateTo%>";

                    <%
                        if(!sAction.equals("applyFilter")){
                            %>
                                document.getElementById("filter1").checked = false;
                                document.getElementById("filter2").checked = false;
                                document.getElementById("filter3").checked = false;
                            <%
                        }
                    %>

                    enablePrint();
                    transactionForm.dateFrom.focus();
                  }
                </script>

                <a name="bottom"></a>
            </form>
        <%
    }
%>