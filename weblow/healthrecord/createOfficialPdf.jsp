<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.official.OfficialPDFCreator,
                be.mxs.common.util.pdf.PDFCreator"%>
<%
    String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));

    ByteArrayOutputStream baosPDF = null;

    SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
    if (activePatient!=null) sessionContainerWO.verifyPerson(activePatient.personid);
    sessionContainerWO.verifyHealthRecord(null);

    try {
        PDFCreator pdfCreator = new OfficialPDFCreator(sessionContainerWO,activeUser,activePatient,sAPPTITLE,"",sPrintLanguage);
        baosPDF = pdfCreator.generatePDFDocumentBytes(request,application,true,0); // filter applied (specific transaction id) AND show only header of requested transaction
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_")
                  .append(System.currentTimeMillis())
                  .append(".pdf");

        // It is important to set the HTTP response headers
        // before writing data to the servlet's OutputStream
        // Read the HTTP 1.1 specification for full details about the Cache-Control header
        response.setHeader("Cache-Control", "max-age=30");
        response.setContentType("application/pdf");

        // The Content-disposition value will be in one of two forms:
        //  1) inline; filename=foobar.pdf
        //  2) attachment; filename=foobar.pdf
        // (check "http://www.ietf.org/rfc/rfc2183.txt" for explanation.)
        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline");
        sbContentDispValue.append("; filename=");
        sbContentDispValue.append(sbFilename);

        response.setHeader("Content-disposition",sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        ServletOutputStream sos;
        sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch(DocumentException dex){
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.print(this.getClass().getName()+ " caught an exception: "+ dex.getClass().getName()+ "<br>");
        writer.print("<pre>");
        dex.printStackTrace(writer);
        writer.print("</pre>");
    }
    catch(Exception e){
        e.printStackTrace();
    }
    finally{
        if(baosPDF != null){
            baosPDF.reset();
        }
    }
%>