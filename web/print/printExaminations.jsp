<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                java.io.PrintWriter,
                com.lowagie.text.*,
                be.mxs.common.util.pdf.general.GeneralPDFCreator,
                be.mxs.common.util.pdf.PDFCreator"%>
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
    String sAction = checkString(request.getParameter("Action"));

    String sSelectedFilter   = checkString(request.getParameter("filter")),
           sSelectedTranCtxt = checkString(request.getParameter("selectedTranCtxt"));
                               
    // select all contexts by default
    if(sSelectedTranCtxt.length()==0) sSelectedTranCtxt = "allContexts";

    StringBuffer sOut = new StringBuffer();
    int cbCounter = 0;

    // date-range
    String sDateFrom = checkString(request.getParameter("dateFrom")),
           sDateTo   = checkString(request.getParameter("dateTo"));

    // parse date from if any specified
    java.util.Date dateFrom;
    if(sDateFrom.length() > 0) dateFrom = ScreenHelper.stdDateFormat.parse(sDateFrom);
    else                       dateFrom = new java.util.Date(0); // 1970

    // parse date to if any specified
    java.util.Date dateTo;
    if(sDateTo.length() > 0) dateTo = ScreenHelper.stdDateFormat.parse(sDateTo);
    else                     dateTo = new java.util.Date(); // now


    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********************* print/printExaminations.jsp *********************");
        Debug.println("sAction           : "+sAction);
        Debug.println("sSelectedFilter   : "+sSelectedFilter);
        Debug.println("sSelectedTranCtxt : "+sSelectedTranCtxt);
        Debug.println("sDateFrom         : "+sDateFrom);
        Debug.println("sDateTo           : "+sDateTo+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////


    //--- PRINT PDF -------------------------------------------------------------------------------
    if(sAction.equals("print")){
        String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));

        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName() );
        sessionContainerWO.verifyPerson(activePatient.personid);
        sessionContainerWO.verifyHealthRecord(null);

        ByteArrayOutputStream origBaos = null;

        try{
            PDFCreator pdfCreator = new GeneralPDFCreator(sessionContainerWO,activeUser,activePatient,sAPPTITLE,sAPPDIR,dateFrom,dateTo,sPrintLanguage);
            origBaos = pdfCreator.generatePDFDocumentBytes(request,application,(sSelectedFilter.length()>0),1);
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
        catch(Exception e){
            Debug.printStackTrace(e);
        }
        finally{
            if(origBaos!=null) origBaos.reset();
        }
    }
    //--- APPLY FILTER ----------------------------------------------------------------------------
    else if(sAction.equals("applyFilter")){
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        Collection transactions = sessionContainerWO.getHealthRecordVO().getTransactions();
        Iterator tranIter = transactions.iterator();
        Hashtable hTrans = new Hashtable();
        TransactionVO transaction, newTransaction;
        String sTransTranslation;
        String sClass = "1", sList = "1";
        String tranID, serverID, tranType, tranUserName = "", tranCtxt, sExaminationName, sDocType;
        Timestamp tranDate;
        cbCounter = 1;
        ItemVO docTypeItem;

        //*****************************************************************************************
        //*** FILTER 1 ("Selecteer te printen onderzoeken.") **************************************
        //*****************************************************************************************
        if(sSelectedFilter.equals("select_trans")){
            // header
            sOut.append("<tr class='admin'>")
                 .append("<td width='30'>&nbsp;</td>")
                 .append("<td width='80'><DESC>"+getTran("web","date",sWebLanguage)+"</DESC></td>")
                 .append("<td width='45%'>"+getTran("web.occup","medwan.common.contacttype",sWebLanguage)+"</td>")
                 .append("<td width='250'>"+getTran("web.occup","medwan.common.context",sWebLanguage)+"</td>")
                 .append("<td width='200'>"+getTran("web.occup","medwan.common.user",sWebLanguage)+"</td>")
                .append("</tr>");

            // records
            sOut.append("<tbody style='cursor:pointer;'>");

            while(tranIter.hasNext()){
                transaction = (TransactionVO)tranIter.next();
                transaction.preload();
                
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                if(tranDate.getTime() >= dateFrom.getTime() && tranDate.getTime() <= dateTo.getTime()){
                    tranID   = String.valueOf(transaction.getTransactionId());
                    serverID = transaction.getServerId()+"";
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations and warnings
                    if(!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")){
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                        boolean privateInfo = false;
                        
                        if(transaction!=null){
                            tranUserName = transaction.getUser().getPersonVO().lastname+", "+transaction.getUser().getPersonVO().firstname;

	                        // private info ?
                            ItemVO privateInfoItem = transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if(privateInfoItem!=null){
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if(!privateInfo){
                            // get context
                            tranCtxt = "";
                            if(transaction!=null){
                                ItemVO itemVO = transaction.getContextItem();
                                if(itemVO!=null){
                                   tranCtxt = itemVO.getValue();
                                }
                            }

                            //*** DOCUMENT : retreive name of document ***
                            if(tranType.equals(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_DOCUMENT")){
                                docTypeItem = transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOCUMENT_TYPE");
                                if(docTypeItem!=null){
                                    sExaminationName = getTran("web.documents",docTypeItem.getValue(),sWebLanguage);
                                }
                                else{
                                    docTypeItem = transaction.getItem("documentId");
                                    if(docTypeItem!=null){
                                        sDocType = docTypeItem.getValue();
                                        sDocType = sDocType.substring(0,sDocType.indexOf("."));
                                        sExaminationName = getTran("web.documents",sDocType,sWebLanguage);
                                    }
                                    else{
                                        sExaminationName = getTran("web.occup",tranType,sWebLanguage); // just 'DOCUMENT'
                                    }
                                }
                            }
                            //*** ANY OTHER TYPE OF TRANSACTION ***
                            else{
                                sExaminationName = getTran("web.occup",tranType,sWebLanguage);
                            }
                            
        	                //*** italic when not part of active encounter ***
        	                String sTranContext  = transaction.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT"),
        	                	   sEncounterUid = transaction.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
        	                
        	                if(sEncounterUid.length() > 0){
        	                	Encounter encounter = Encounter.get(sEncounterUid);        	                
        	                    Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
        	                    sClass = "disabled";
        	
        	                    try{
        	                        if(activeEncounter!=null && transaction.getUpdateTime()!=null && activeEncounter!=null && !transaction.getUpdateTime().before(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(activeEncounter.getBegin()))) && (activeEncounter.getEnd() == null || !transaction.getUpdateTime().after(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(activeEncounter.getEnd()))))){
        	                            sClass = "bold";
        	                        }
        	                    }
        	                    catch(Exception e){
        	                        e.printStackTrace();
        	                    }
        	                }        	                    

                            //*** what context-modifier ***
                            if(sSelectedTranCtxt.equals("allContexts")){
                                // alternate row-style
                                if(sList.length()==0) sList = "1";
                                else                  sList = "";

                                sOut.append("<tr class=\"list"+sClass+sList+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+sList+"';\">")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+ScreenHelper.stdDateFormat.format(tranDate)+"</td>")
                                     .append("<td>&nbsp;<a href='#' onClick=\"showTransaction('"+transaction.getTransactionType()+"','"+transaction.getServerId()+"','"+transaction.getTransactionId()+"');\">"+sExaminationName+"</a></td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranCtxt,sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+tranUserName+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                            else if(sSelectedTranCtxt.equals("withoutContext")){
                                if(tranCtxt.length()==0){
                                    // alternate row-style
                                    if(sList.length()==0) sList = "1";
                                    else                  sList = "";

                                    sOut.append("<tr class=\"list"+sClass+sList+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+sList+"';\">")
                                         .append("<td align='center'>")
                                          .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                         .append("</td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+ScreenHelper.stdDateFormat.format(tranDate)+"</td>")
                                         .append("<td>&nbsp;<a href='#' onClick=\"showTransaction('"+transaction.getTransactionType()+"','"+transaction.getServerId()+"','"+transaction.getTransactionId()+"');\">"+sExaminationName+"</a></td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranCtxt,sWebLanguage)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+tranUserName+"</td>")
                                        .append("</tr>");

                                    cbCounter++;
                                }
                            }
                            else if(tranCtxt.equalsIgnoreCase(sSelectedTranCtxt)){
                                // alternate row-style
                                if(sList.length()==0) sList = "1";
                                else                  sList = "";

                                sOut.append("<tr class=\"list"+sClass+sList+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+sList+"';\">")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+ScreenHelper.stdDateFormat.format(tranDate)+"</td>")
                                     .append("<td>&nbsp;<a href='#' onClick=\"showTransaction('"+transaction.getTransactionType()+"','"+transaction.getServerId()+"','"+transaction.getTransactionId()+"');\">"+sExaminationName+"</a></td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranCtxt,sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+tranUserName+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                        }
                    }
                }
            }

            sOut.append("</tbody>");
        }
        //*****************************************************************************************
        //*** FILTER 2 (Selecteer te printen onderzoek-types.) ************************************
        //*****************************************************************************************
        else if(sSelectedFilter.equals("select_trantypes")){
            SortedSet set = new TreeSet();

            while(tranIter.hasNext()){
                transaction = (TransactionVO)tranIter.next();
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                if(tranDate.getTime() >= dateFrom.getTime() && tranDate.getTime() <= dateTo.getTime()){
                    sTransTranslation = getTran("web.occup",transaction.getTransactionType(),sWebLanguage);
                    newTransaction = (TransactionVO)hTrans.get(sTransTranslation);

                    if(newTransaction==null){
                        hTrans.put(sTransTranslation,transaction);
                        set.add(sTransTranslation);
                    }
                }
            }

            // header
            sOut.append("<tr class='admin'>")
                 .append("<td width='30'>&nbsp;</td>")
                 .append("<td width='*'>"+getTran("web.occup","medwan.common.contacttype",sWebLanguage)+"</td>")
                 .append("<td width='250'>"+getTran("web.occup","medwan.common.context",sWebLanguage)+"</td>")
                .append("</tr>");

            // records
            sOut.append("<tbody style='cursor:pointer;'>");

            if(hTrans!=null){
                Iterator setIter = set.iterator();

                while(setIter.hasNext()){
                    transaction = (TransactionVO)hTrans.get(setIter.next().toString());
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations and warnings
                    if(!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")){
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                        boolean privateInfo = false;
                        
                        if(transaction!=null){
	                        // private info ?
                            ItemVO privateInfoItem = transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if(privateInfoItem!=null){
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if(!privateInfo){ 
                            // context
                            tranCtxt = "";
                            ItemVO itemVO = transaction.getContextItem();
                            if(itemVO!=null){
                                tranCtxt = itemVO.getValue();
                            }

                            //*** what context-modifier ***
                            if(sSelectedTranCtxt.equals("allContexts")){
                                // alternate row-style
                                if(sClass.length()==0) sClass = "1";
                                else                   sClass = "";

                                sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranType,sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranCtxt,sWebLanguage)+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                            else if(sSelectedTranCtxt.equals("withoutContext")){
                                if(tranCtxt.length()==0){
                                    // alternate row-style
                                    if(sClass.length()==0) sClass = "1";
                                    else                   sClass = "";

                                    sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                         .append("<td align='center'>")
                                          .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                         .append("</td>")
                                         .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranType,sWebLanguage)+"</td>")
                                         .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranCtxt,sWebLanguage)+"</td>")
                                        .append("</tr>");

                                    cbCounter++;
                                }
                            }
                            else if(tranCtxt.equalsIgnoreCase(sSelectedTranCtxt)){
                                // alternate row-style
                                if(sClass.length()==0) sClass = "1";
                                else                   sClass = "";

                                sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                     .append("<td align='center'>")
                                      .append("<input type='checkbox' value='"+tranType+"' name='tranType_"+cbCounter+"'>")
                                     .append("</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranType,sWebLanguage)+"</td>")
                                     .append("<td onClick=\"clickCheckBox('tranType_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranCtxt,sWebLanguage)+"</td>")
                                    .append("</tr>");

                                cbCounter++;
                            }
                        }
                    }
                }
            }

            sOut.append("</tbody>");
        }
        //*****************************************************************************************
        //*** FILTER 3 (..types waarvan recentste onderzoek zal geprint worden.) ******************
        //*****************************************************************************************
        else if(sSelectedFilter.equals("select_trantypes_recent")){
            SortedSet set = new TreeSet();

            while(tranIter.hasNext()){
                transaction = (TransactionVO)tranIter.next();
                tranDate = new Timestamp(transaction.getUpdateTime().getTime());

                if(tranDate.getTime() >= dateFrom.getTime() && tranDate.getTime() <= dateTo.getTime()){
                    sTransTranslation = getTran("web.occup",transaction.getTransactionType(),sWebLanguage);
                    newTransaction = (TransactionVO)hTrans.get(sTransTranslation);

                    if(newTransaction==null){
                        hTrans.put(sTransTranslation,transaction);
                        set.add(sTransTranslation);
                    }
                    else if(newTransaction.getUpdateTime().compareTo(transaction.getUpdateTime()) < 0){
                        hTrans.put(sTransTranslation,transaction);
                        set.add(sTransTranslation);
                    }
                }
            }

            // header
            sOut.append("<tr class='admin'>")
                 .append("<td width='30'>&nbsp;</td>")
                 .append("<td width='80'>"+getTran("web","date",sWebLanguage)+"</td>")
                 .append("<td width='70%'>"+getTran("web.occup","medwan.common.contacttype",sWebLanguage)+"</td>")
                 .append("<td width='200'>"+getTran("web.occup","medwan.common.user",sWebLanguage)+"</td>")
                .append("</tr>");

            // records
            sOut.append("<tbody style='cursor:pointer;'>");

            if(hTrans!=null){
                Iterator setIter = set.iterator();

                while(setIter.hasNext()){
                    transaction = (TransactionVO)hTrans.get(setIter.next().toString());

                    tranID   = transaction.getTransactionId()+"";
                    serverID = transaction.getServerId()+"";
                    tranDate = new Timestamp(transaction.getUpdateTime().getTime());
                    tranType = transaction.getTransactionType();

                    // exclude vaccinations and warnings
                    if(!tranType.endsWith("TRANSACTION_TYPE_VACCINATION") && !tranType.endsWith("TRANSACTION_TYPE_ALERT")){
                        transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                        boolean privateInfo = false;
                        
                        if(transaction!=null){
                        	tranUserName = transaction.getUser().getPersonVO().lastname+", "+transaction.getUser().getPersonVO().firstname;

                            // private info ?
                            ItemVO privateInfoItem = transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PRIVATE_INFO");
                            if(privateInfoItem!=null){
                                privateInfo = checkString(privateInfoItem.getValue()).equalsIgnoreCase("medwan.common.true");
                            }
                        }

                        if(!privateInfo){
                            // alternate row-style
                            if(sClass.length()==0) sClass = "1";
                            else                   sClass = "";

                            sOut.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\">")
                                 .append("<td align='center'>")
                                  .append("<input type='checkbox' value='"+tranID+"_"+serverID+"' name='tranAndServerID_"+cbCounter+"'>")
                                 .append("</td>")
                                 .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+(tranDate==null?"":ScreenHelper.stdDateFormat.format(tranDate))+"</td>")
                                 .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+getTran("web.occup",tranType,sWebLanguage)+"</td>")
                                 .append("<td onClick=\"clickCheckBox('tranAndServerID_"+cbCounter+"')\">&nbsp;"+tranUserName+"</td>")
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
    if(sAction.length()==0 || sAction.equals("applyFilter")){
        String sSelect;
        PreparedStatement ps;
        ResultSet rs;
        
        if(sDateFrom.length()==0){
            // get date of oldest transaction of active patient (except vaccinations)
            sSelect = "SELECT t.updateTime FROM Healthrecord h, Transactions t"+
                      " WHERE h.personId = ?"+
                      "  AND t.healthRecordId = h.healthRecordId "+
                      "  AND t.transactionType <> '"+ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_VACCINATION'"+
                      " ORDER BY t.updateTime ASC";
            Connection conn = MedwanQuery.getInstance().getOpenclinicConnection(); 
            ps = conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(activePatient.personid)); 
            rs = ps.executeQuery();
            if(rs.next()){
                sDateFrom = ScreenHelper.stdDateFormat.format(new java.util.Date(rs.getDate(1).getTime()));
            } 

            // close DB-stuff
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
            conn.close();
        }

        if(sDateTo.length()==0){
            // get date of youngest transaction of active patient (except vaccinations)
            sSelect = "SELECT t.updateTime FROM Healthrecord h, Transactions t"+
                      " WHERE h.personId = ?"+
                      "  AND t.healthRecordId = h.healthRecordId "+
                      "  AND t.transactionType <> '"+ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_VACCINATION'"+
                      " ORDER BY t.updateTime DESC";
            Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
            ps = conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(activePatient.personid));
            rs = ps.executeQuery();
            if(rs.next()){
                sDateTo = ScreenHelper.stdDateFormat.format(new java.util.Date(rs.getDate(1).getTime()));
            }

            // close DB-stuff
            if(rs!=null) rs.close();
            if(ps!=null) ps.close();
        }

        %>
            <form name="printForm" id="printForm" method="POST">
                <input type="hidden" name="Action" value="print">

                <%=writeTableHeader("web","printExaminations",sWebLanguage)%>

                <table class="list" width="100%" cellspacing="1">
                    <%-- date from --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","begindate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%=writeDateField("dateFrom","printForm",sDateFrom,sWebLanguage)%>
                        </td>
                    </tr>

                    <%-- date to --%>
                    <tr>
                        <td class="admin"><%=getTran("web","enddate",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <%=writeDateField("dateTo","printForm",sDateTo,sWebLanguage)%>
                        </td>
                    </tr>

                    <%-- examination context selector (only for filter1 and filter2) --%>
                    <%
                        if(sAction.equals("applyFilter") && (sSelectedFilter.equals("select_trans") || sSelectedFilter.equals("select_trantypes"))){
                            %>
                                <tr>
                                    <td class="admin"><%=getTran("web","context",sWebLanguage)%>&nbsp;</td>
                                    <td class="admin2">
                                        <select name="selectedTranCtxt" class="text">
                                            <option value="allContexts" SELECTED><%=getTranNoLink("web.occup","allContexts",sWebLanguage)%></option>
                                            <option value="withoutContext" <%=(sSelectedTranCtxt.equals("withoutContext")?"SELECTED":"")%>><%=getTran("web.occup","withoutContext",sWebLanguage)%></option>
                                            <%
                                                String sContextsDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"contexts.xml";

                                                if(sContextsDoc.length() > 0){
                                                    SAXReader reader = new SAXReader(false);
                                                    Document document = reader.read(new URL(sContextsDoc));
                                                    Iterator ctxtIter = document.getRootElement().elementIterator("context");

                                                    Element ctxtElem;
                                                    String ctxtId;
                                                    while(ctxtIter.hasNext()){
                                                        ctxtElem = (Element)ctxtIter.next();
                                                        ctxtId = ctxtElem.attribute("id").getValue();

                                                        %>
                                                            <option value="<%=ctxtId%>" <%=(sSelectedTranCtxt.equalsIgnoreCase(ctxtId)?"SELECTED":"")%>>
                                                                <%=getTranNoLink("web.occup",ctxtId,sWebLanguage)%>
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

                    <%-- controls to show after filter is chosen  --%>
                    <%
                        if(sAction.equals("applyFilter")){
                            %>
                                <%-- BUTTONS (show, back, reset, print overview) --%>
                                <tr>
                                    <td class="admin">&nbsp;</td>
                                    <td class="admin2">
                                        <input type="button" class="button" name="showButton" value="<%=getTranNoLink("web","show",sWebLanguage)%>" onClick="doApplyFilter();">
                                        <input type="button" class="button" name="resetButton" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick="printForm.reset();checkAll(true);">
                                        <%
                                            if(cbCounter > 1){
                                                %><input type="button" class="button" name="printOverviewButton" value="<%=getTranNoLink("web","printOverview",sWebLanguage)%>" onClick="printOverview();">&nbsp;<%
                                            }

                                            // bakButton must refer to the right page
                                            if(sAction.length()==0){
                                                %><input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBackToMenu();"><%
                                            }
                                            else{
                                                %><input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();"><%
                                            }
                                        %>
                                    </td>
                                </tr>
                            <%
                        }
                    %>

                    <%-- SELECT A FILTER --------------------------------------------------------%>
                    <%
                        if(sAction.length()==0){
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
                                            <a href="#" onclick="checkAll(true);"><%=getTran("web.manage","CheckAll",sWebLanguage)%></a>
                                            <a href="#" onclick="checkAll(false);"><%=getTran("web.manage","UncheckAll",sWebLanguage)%></a>
                                        </td>
                                        <td align="right">
                                            <a href="#bottom"><img src="<c:url value='/_img'/>/bottom.jpg" class="link"></a>
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
                                            <a href="#" onclick="checkAll(true);"><%=getTran("web.manage","CheckAll",sWebLanguage)%></a>
                                            <a href="#" onclick="checkAll(false);"><%=getTran("web.manage","UncheckAll",sWebLanguage)%></a>
                                        </td>
                                        <td align="right">
                                            <a href="#top"><img src="<c:url value='/_img'/>/top.jpg" class="link"></a>
                                        </td>
                                    </tr>
                                </table>

                                <br>
                            <%
                        }
                        else{
                            %><p><%=getTran("web","noRecordsFound",sWebLanguage)%></p><%
                        }
                    }
                %>

                <%-- BUTTONS --%>
                <p align="right">
                    <%
                        if(cbCounter > 1 || sAction.length()==0){
                            String sPrintLanguage = activePatient.language;

                            // format language
                                 if(sPrintLanguage.equalsIgnoreCase("b"))  sPrintLanguage = activePatient.language;
                            else if(sPrintLanguage.equalsIgnoreCase("t"))  sPrintLanguage = activePatient.language;
                            else if(sPrintLanguage.equalsIgnoreCase("fr")) sPrintLanguage = "F";
                            else if(sPrintLanguage.equalsIgnoreCase("nl")) sPrintLanguage = "N";

                            %>
                                <%-- LANGUAGE SELECTOR --%>
                                <select class="text" name="PrintLanguage">
                                    <%  
	                                    // supported languages
	                                    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
	                                    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
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
                    
                                <input class="button" type="button" name="printButton" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onClick="doSubmit();">
                            <%

                            %><input class="button" type="button" name="resetButton" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick="<%=(sAction.length()==0?"doReset();":"printForm.reset();checkAll(true);")%>">&nbsp;<%
                        }

                        // bakButton must refer to the right page
                        if(sAction.length()==0){
                            %><input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBackToMenu();"><%
                        }
                        else{
                            %><input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();"><%
                        }
                    %>
                </p>
                
                <a name="bottom"/>
            </form>

            <%-- SCRIPTS --------------------------------------------------------------------%>
            <script>
              <%
                  if(sAction.length()==0){
                      %>
                          printForm.action = "<c:url value='print/printExaminations.jsp'/>?ts=<%=getTs()%>";
                          printForm.target = "_new";

                          if(printForm.filter1.checked || printForm.filter2.checked || printForm.filter3.checked){
                            enableProceed();
                          }
                          else{
                            enablePrint();
                          }
                      <%
                  }
                  else if(sAction.equals("applyFilter")){
                      %>
                          printForm.action = "<c:url value='print/printExaminations.jsp'/>?ts=<%=getTs()%>";
                          printForm.target = "_new";
                      <%
                  }
              %>

              checkAll(true);
              printForm.dateFrom.focus();

              <%-- ENABLE PRINT --%>
              function enablePrint(){
                document.printForm.Action.value = "print";
                setPrintButtonTextToPrint();
                displayLanguageSelect(true);

                printForm.action = "<c:url value='print/printExaminations.jsp'/>?ts=<%=getTs()%>";
                printForm.target = "_new";
              }

              <%-- ENABLE PROCEED --%>
              function enableProceed(){
                document.printForm.Action.value = "applyFilter";
                setPrintButtonTextToProceed();
                displayLanguageSelect(false);

                printForm.action = "<c:url value='main.jsp?Page=print/printExaminations.jsp'/>&ts=<%=getTs()%>&jsessionid=<%=request.getSession().getId()%>";
                printForm.target = "";
              }

              <%-- DISPLAY LANGUAGE SELECT --%>
              function displayLanguageSelect(displaySelect){
                if(displaySelect) printForm.PrintLanguage.style.display = "";
                else              printForm.PrintLanguage.style.display = "none";
              }

              <%-- SET PRINTBUTTON TO PROCEED --%>
              function setPrintButtonTextToProceed(){
                printForm.printButton.value = "<%=getTranNoLink("web","proceed",sWebLanguage)%>";
              }

              <%-- SET PRINTBUTTON TO PRINT --%>
              function setPrintButtonTextToPrint(){
                printForm.printButton.value = "<%=getTranNoLink("web","print",sWebLanguage)%>";
              }

              <%-- CLICK CHECKBOX --%>
              function clickCheckBox(cbName){
                var cb = eval("printForm."+cbName);
                cb.checked = !cb.checked
              }

              <%-- CHECK ALL --%>
              function checkAll(setchecked){
                for(var i=0; i<printForm.elements.length; i++){
                  if(printForm.elements[i].type=="checkbox"){
                    if(printForm.elements[i].name.indexOf("_") > 0){
                      printForm.elements[i].checked = setchecked;
                    }
                  }
                }
              }

              <%-- DO APPLY FILTER --%>
              function doApplyFilter(){
                printForm.Action.value = "applyFilter";
                printForm.action = "<c:url value='main.jsp?Page=print/printExaminations.jsp&ts='/><%=getTs()%>";
                printForm.target = "_self";
                printForm.submit();
              }
              
              <%-- DO SUBMIT --%>
              function doSubmit(){
                printForm.submit();
              }

              <%-- PRINT OVERVIEW --%>
              function printOverview(){
                var url = "<c:url value='main.jsp?Page=/print/printExaminations.jsp'/>"+
                          "?jsessionid=<%=request.getSession().getId()%>"+
                          "&Field=searchresults"+
                          "&DateFrom="+printForm.dateFrom.value+
                          "&DateTo="+printForm.dateTo.value+
                          "&ts=<%=getTs()%>";
                window.open(url,"Print");
              }

              <%-- DO RESET --%>
              function doReset(){
                printForm.reset();
                printForm.dateFrom.value = "<%=sDateFrom%>";
                printForm.dateTo.value = "<%=sDateTo%>";

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
                printForm.dateFrom.focus();
              }
              
              <%-- SHOW TRANSACTION (pdfs in a popup, real transactions in the same window) --%>
              function showTransaction(tranType,serverId,tranId){
                var url = "<%=sCONTEXTPATH%>/healthrecord/editTransaction.do"+
                          "?be.mxs.healthrecord.createTransaction.transactionType="+tranType+
                          "&be.mxs.healthrecord.transaction_id="+tranId+
                          "&be.mxs.healthrecord.server_id="+serverId+
                          "&ts=<%=getTs()%>";   
                 
                if(tranType.indexOf("TRANSACTION_TYPE_DOCUMENT") > -1){          
                  window.open(url,"Transaction");
                }
                else{
                  window.location.href = url;	
                }
              }

              <%-- DO BACK --%>
              function doBack(){
                window.location.href = "<c:url value='/main.jsp?Page=print/printExaminations.jsp'/>"+
                                       "&action=<%=sAction%>"+
                                       "&filter=<%=sSelectedFilter%>"+
                                       "&ts=<%=getTs()%>";
              }

              <%-- DO BACK TO MENU --%>
              function doBackToMenu(){
                window.location.href = "<c:url value='main.jsp?Page=curative/index.jsp'/>"+
                		               "&ts=<%=getTs()%>";
              }
            </script>
        <%
    }
%>