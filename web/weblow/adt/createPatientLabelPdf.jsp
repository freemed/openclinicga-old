<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.ByteArrayOutputStream,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter,be.mxs.common.util.pdf.general.PDFPatientLabelGenerator" %>
<%@ page import="be.mxs.common.util.pdf.general.PDFArchiveLabelGenerator" %>
<%
    if (request.getParameter("labelcount") != null) {

        ByteArrayOutputStream baosPDF = null;

        try {
            if ("3".equalsIgnoreCase(request.getParameter("type"))) {
                PDFArchiveLabelGenerator pdfArchiveLabelGenerator = new PDFArchiveLabelGenerator(activeUser, sProject);
                baosPDF = pdfArchiveLabelGenerator.generatePDFDocumentBytes(request, activePatient, Integer.parseInt(request.getParameter("labelcount")), request.getParameter("type"));
            } else {
                // PDF generator
                PDFPatientLabelGenerator pdfPatientLabelGenerator = new PDFPatientLabelGenerator(activeUser, sProject);
                baosPDF = pdfPatientLabelGenerator.generatePDFDocumentBytes(request, activePatient, Integer.parseInt(request.getParameter("labelcount")), request.getParameter("type"));
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
    catch
        (DocumentException
        dex
        )
    {
        response.setContentType("text/html");
        PrintWriter writer = response.getWriter();
        writer.println(this.getClass().getName() + " caught an exception: " + dex.getClass().getName() + "<br>");
        writer.println("<pre>");
        dex.printStackTrace(writer);
        writer.println("</pre>");
    }
    finally
    {
        if (baosPDF != null) {
            baosPDF.reset();
        }
    }
    }
    else
    {
%>
    <head>
        <%=sCSSNORMAL%>
    </head>
    <form method="post">
        <table>
            <tr>
                <td><%=getTran("web","labelcount",sWebLanguage)%></td>
                <td><input class="text" size="2" type="text" name="labelcount" value="<%=MedwanQuery.getInstance().getConfigString("defaultLabelCount","1")%>"/></td>
                <td><input class="button" type="submit" name="submit" value="<%=getTran("web","print",sWebLanguage)%>"/></td>
            </tr>
            <tr>
                <td colspan="3"><input type="radio" checked name="type" value="1"/><%=getTran("web","labeltype1",sWebLanguage)%></td>
            </tr>
            <tr>
                <td colspan="3"><input type="radio" name="type" value="2"/><%=getTran("web","labeltype2",sWebLanguage)%></td>
            </tr>
            <tr>
                <td colspan="3"><input type="radio" name="type" value="3"/><%=getTran("web","labeltype3",sWebLanguage)%></td>
            </tr>
        </table>
    </form>
<%
    }
%>
<script type="text/javascript">
    window.open("<c:url value='/'/>/util/setprinter.jsp?printer=labelprinter","Popup"+new Date().getTime(),"toolbar=no, status=no, scrollbars=no, resizable=no, width=1, height=1, menubar=no").moveBy(-1000,-1000);
</script>