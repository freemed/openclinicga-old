<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.*" %>

<%
    ByteArrayOutputStream baosPDF = null;

    try {
        // PDF generator
        String type = checkString(request.getParameter("cardtype"));
        if(type.equalsIgnoreCase("new")){
        	PDFUserCardGeneratorNew pdfUserCardGenerator = new PDFUserCardGeneratorNew(activeUser, sProject);
        	String[] colors = checkString((String)activePatient.adminextends.get("usergroup")).split("\\.");
        	System.out.println(activePatient.adminextends.get("usergroup"));
        	if(colors.length==3){
        		pdfUserCardGenerator.setRed(Integer.parseInt(colors[0]));
        		pdfUserCardGenerator.setGreen(Integer.parseInt(colors[1]));
        		pdfUserCardGenerator.setBlue(Integer.parseInt(colors[2]));
        	}
    		baosPDF = pdfUserCardGenerator.generatePDFDocumentBytes(request, activePatient);
        }
        else {
        	PDFUserCardGenerator pdfUserCardGenerator = new PDFUserCardGenerator(activeUser, sProject);
            baosPDF = pdfUserCardGenerator.generatePDFDocumentBytes(request, activePatient);
        }
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=")
                .append(sbFilename);

        // prepare response
        response.setHeader("Cache-Control", "max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition", sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        baosPDF.writeTo(sos);
        sos.flush();
    }
    catch (DocumentException dex) {
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName() + " caught an exception: " + dex.getClass().getName() + "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally {
        if (baosPDF != null) {
            baosPDF.reset();
        }
    }
%>