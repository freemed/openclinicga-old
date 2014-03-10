<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                java.io.PrintWriter,
                com.lowagie.text.*,
                be.mxs.common.util.pdf.general.dossierCreators.FinancialDossierPDFCreator,
                be.mxs.common.util.system.Picture,
                be.mxs.common.util.pdf.PDFCreator"%>
                
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

    String sSection1 = checkString(request.getParameter("section_1")),
           sSection2 = checkString(request.getParameter("section_2")),
           sSection3 = checkString(request.getParameter("section_3")),
           sSection4 = checkString(request.getParameter("section_4")),
           sSection5 = checkString(request.getParameter("section_5")),
           sSection6 = checkString(request.getParameter("section_6")),
           sSection7 = checkString(request.getParameter("section_7")),
           sSection8 = checkString(request.getParameter("section_8"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** print/printFinancialDossier.jsp ******************");
        Debug.println("sAction   : "+sAction);
        Debug.println("sSection1 : "+sSection1);      // 1 : Administratie persoonlijk
        Debug.println("sSection2 : "+sSection2);      // 2 : foto
        Debug.println("sSection3 : "+sSection3);      // 3 : Administratie privé
        Debug.println("sSection4 : "+sSection4);      // 4 : Actieve verzekeringsgegevens
        Debug.println("sSection5 : "+sSection5);      // 5 : Historiek verzekeringsgegevens
        Debug.println("sSection6 : "+sSection6);      // 6 : Historiek van alle facturen met voor elke factuur de lijst van bijhorende prestaties
        Debug.println("sSection7 : "+sSection7);      // 7 : Historiek van alle betalingen verricht door de patiënt
        Debug.println("sSection8 : "+sSection8+"\n"); // 8 : signature 
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    StringBuffer sOut = new StringBuffer();
    

    //--- PRINT PDF -------------------------------------------------------------------------------
    if(sAction.equals("print")){
        String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));

        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName() );
        sessionContainerWO.verifyPerson(activePatient.personid);
        sessionContainerWO.verifyHealthRecord(null);

        ByteArrayOutputStream origBaos = null;

        try{
            PDFCreator pdfCreator = new FinancialDossierPDFCreator(sessionContainerWO,activeUser,activePatient,sAPPTITLE,sAPPDIR,sPrintLanguage);
            origBaos = pdfCreator.generatePDFDocumentBytes(request,application);
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
%>

<form name="printForm" id="printForm" method="POST">
    <input type="hidden" name="Action" value="print">

    <%=writeTableHeader("web","printFinancialDossier",sWebLanguage)%>

    <%-- SECTIONS -------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%-- 1 : administration personal --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_1" id="section_1" value="on" onClick="this.checked=true" <%=(sSection1.equals("on")?"CHECKED":"")%>><%=getLabel("web.occup","administrationPersonal",sWebLanguage,"section_1")%>
            </td>
        </tr>
        
        <%-- 2 : photo --%>
        <tr>
            <td class="admin">
		        <%
		            if(Picture.exists(Integer.parseInt(activePatient.personid))){
		           	    %><input type="checkbox" name="section_2" id="section_2" value="on" <%=(sSection2.equals("on")?"CHECKED":"")%>>&nbsp;<%=getLabel("pdf","photo",sWebLanguage,"section_2")%><%
		            }
		            else{
		                %><input type="checkbox" name="section_2" id="section_2" value="off" DISABLED>&nbsp;<%=getLabel("pdf","photo",sWebLanguage,"section_2")%><%
		            }
		        %>        
            </td>
        </tr>  

        <%-- 3 : administration private --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_3" id="section_3" value="on" <%=(sSection3.equals("on")?"CHECKED":"")%>><%=getLabel("pdf","administrationPrivate",sWebLanguage,"section_3")%>
            </td>
        </tr>
                 
        <%-- 4 : active insurance data --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_4" id="section_4" value="on" <%=(sSection4.equals("on")?"CHECKED":"")%>><%=getLabel("pdf","activeInsuranceData",sWebLanguage,"section_4")%>
            </td>
        </tr>
         
        <%-- 5 : historical insurance data --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_5" id="section_5" value="on" <%=(sSection6.equals("on")?"CHECKED":"")%>><%=getLabel("pdf","historicalInsuranceData",sWebLanguage,"section_5")%>
            </td>
        </tr>
         
        <%-- 6 : patient invoices --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_6" id="section_6" value="on" <%=(sSection6.equals("on")?"CHECKED":"")%>><%=getLabel("pdf","patientInvoices",sWebLanguage,"section_6")%>
            </td>
        </tr>
         
        <%-- 7 : patient payments --%>
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_7" id="section_7" value="on" <%=(sSection6.equals("on")?"CHECKED":"")%>><%=getLabel("pdf","patientPayments",sWebLanguage,"section_7")%>
            </td>
        </tr> 

        <%-- 8 : signature
        <tr>
            <td class="admin">
                <input type="checkbox" name="section_8" id="section_8" value="on" <%=(sSection7.equals("on")?"CHECKED":"")%>><%=getLabel("pdf","signature",sWebLanguage,"section_8")%>
            </td>
        </tr>
        --%> 
        <input type="hidden" name="section_8" value="on">
    </table>
            
    <%-- UN/CHECK ALL --%>
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

    <span style="text-align:right;width:100%;padding-top:5px;">
        <%-- LANGUAGE SELECTOR --%>
        <select class="text" name="PrintLanguage">
            <%
                String sPrintLanguage = activePatient.language;
            
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
    
        <%-- BUTTONS --%>
        <input class="button" type="button" name="printButton" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onClick="doPrint();">&nbsp;
        <input class="button" type="button" name="resetButton" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick="doReset();">&nbsp;
        <input class="button" type="button" name="backButton"  value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
    </span>
</form>

<%-- SCRIPTS --------------------------------------------------------------------%>
<script>
  checkAll(true);

  <%-- CHECK ALL --%>
  function checkAll(setchecked){
    var cbCount = 0;
	
    for(var i=0; i<printForm.elements.length; i++){
      if(printForm.elements[i].type=="checkbox"){
        cbCount++; // skip first section
  	
  	    if(cbCount > 1){
          if(printForm.elements[i].name.startsWith("section")){
            printForm.elements[i].checked = setchecked;
          }
  	    }
      }
    }

    document.getElementById("section_1").checked = true;

    <%
        // only show photo-option when a photo exists in this dossier
        if(!Picture.exists(Integer.parseInt(activePatient.personid))){
          %>document.getElementById("section_2").checked = false;<%
        }
    %>
  }

  <%-- DO PRINT --%>
  function doPrint(){
    printForm.Action.value = "print";
    printForm.target = "_new";
    printForm.action = "<c:url value='print/printFinancialDossier.jsp'/>?ts=<%=getTs()%>";
    printForm.submit();
  }

  <%-- DO RESET --%>
  function doReset(){
    printForm.reset();
    checkAll(true);
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='main.jsp?Page=curative/index.jsp'/>"+
                           "&ts=<%=getTs()%>";
  }
</script>