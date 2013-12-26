
<%@page import="be.mxs.common.util.pdf.general.*"%><%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.*"%>

<%
    String sInvoiceUid    = checkString(request.getParameter("InvoiceUid")),
            sPrintLanguage = checkString(request.getParameter("PrintLanguage")),
            sPrintType = checkString(request.getParameter("PrintType")),
            sPrintModel = checkString(request.getParameter("PrintModel"));
    ByteArrayOutputStream baosPDF = null;

    try{
        // PDF generator
        sProject = checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase();
        PDFInvoiceGenerator pdfGenerator;
        if(sPrintModel.equalsIgnoreCase("rama")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorRAMA(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("ramanew")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorRAMANew(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("ctams")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorCTAMS(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("mfp")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorMFP(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("hmk")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorHMK(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("ascoma")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorASCOMA(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("brarudi")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorBRARUDI(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else if(sPrintModel.equalsIgnoreCase("ambusa")){
        	pdfGenerator = new PDFInsurarInvoiceGeneratorAMBUSA(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        else{
        	pdfGenerator = new PDFInsurarInvoiceGenerator(activeUser,sProject,sPrintLanguage,sPrintType);
        }
        baosPDF = pdfGenerator.generatePDFDocumentBytes(request,sInvoiceUid);

        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=")
                          .append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control","max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition",sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch(DocumentException dex){
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName()+ " caught an exception: "+ dex.getClass().getName()+ "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally{
        if(baosPDF != null) {
            baosPDF.reset();
        }
    }
%>