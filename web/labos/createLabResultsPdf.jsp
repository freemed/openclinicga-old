<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,be.mxs.common.util.pdf.general.PDFLabResultGenerator,java.util.Vector,java.util.Enumeration" %>
<%
    java.util.Date startdate=ScreenHelper.parseDate(ScreenHelper.formatDate(new java.util.Date()));
    if(request.getParameter("startdate")!=null){
        startdate=ScreenHelper.parseDate(request.getParameter("startdate"));
    }
    Vector labrequestids = new Vector();
    Enumeration parameters = request.getParameterNames();
    while (parameters.hasMoreElements()) {
        String name = (String) parameters.nextElement();
        String fields[] = name.split("\\.");
        if (fields[0].equalsIgnoreCase("print")) {
            labrequestids.add(fields[1]+"."+fields[2]);
        }
    }
    if (labrequestids.size() > 0) {
        ByteArrayOutputStream baosPDF = null;

        try {
            // PDF generator
            PDFLabResultGenerator pdfLabResultGenerator = new PDFLabResultGenerator(activeUser, sProject,sWebLanguage);
            baosPDF = pdfLabResultGenerator.generatePDFDocumentBytes(request, labrequestids,startdate);
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
    } else {
%>
    <script>window.close();</script>
<%
    }
%>