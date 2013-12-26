<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="be.mxs.common.util.pdf.general.*,be.openclinic.common.*,java.io.*,com.itextpdf.text.*"%>
<%
ByteArrayOutputStream baosPDF = null;
try {
	Hashtable values= new Hashtable();
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select gender, count(*) total from AdminView a,OC_ENCOUNTERS b where a.personid=b.oc_encounter_patientuid group by gender");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		String gender = checkString(rs.getString("gender"));
		if(gender.equalsIgnoreCase("m")){
			gender=getTranNoLink("web.occup", "male", sWebLanguage);
		}
		else if(gender.equalsIgnoreCase("f")){
			gender=getTranNoLink("web.occup", "female", sWebLanguage);
		}
		else {
			gender="?";
		}
		
		values.put(gender,rs.getString("total"));
	}
	rs.close();
	ps.close();
	conn.close();
	// PDF generator
    PDFGraphGenerator pdfGraphGenerator = new PDFGraphGenerator(activeUser, sProject);
    baosPDF = pdfGraphGenerator.generatePDFDocumentBytes(request, "piechart","test",values);
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