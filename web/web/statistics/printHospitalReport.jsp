<%@include file="/includes/validateUser.jsp"%><%@page errorPage="/includes/error.jsp"%><%@page import="java.io.ByteArrayOutputStream,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter
                ,be.mxs.common.util.pdf.general.PDFHospitalReportGenerator
                ,java.util.*,
                be.openclinic.medical.LabRequest,be.openclinic.medical.LabSample" %><%@ page import="be.chuk.Article" %><%@ page import="be.mxs.common.util.pdf.general.PDFImmoLabelGenerator" %><%
    ByteArrayOutputStream baosPDF = null;
    try {
        // PDF generator
		java.util.Date begin = new SimpleDateFormat("dd/MM/yyyy").parse("01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date()));
		java.util.Date end = new java.util.Date();
		if(request.getParameter("start")!=null){
			begin=new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("start"));
		}
		if(request.getParameter("end")!=null){
			end=new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("end"));
		}
		HashSet chapters = new HashSet();
		Enumeration parameters = request.getParameterNames();
		while (parameters.hasMoreElements()){
			String name = (String)parameters.nextElement();
			if(name.startsWith("chapter")){
				chapters.add(name.replaceAll("chapter",""));
			}
		}
        PDFHospitalReportGenerator pdfHospitalReportGenerator = new PDFHospitalReportGenerator(activeUser, sProject,sWebLanguage,begin,end,chapters);
        baosPDF = pdfHospitalReportGenerator.generatePDFDocumentBytes(request);
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
    catch (Exception dex) {
    	dex.printStackTrace();
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