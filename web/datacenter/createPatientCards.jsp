<%@include file="/includes/validateUser.jsp"%>
<%@page import="java.util.*,be.mxs.common.util.db.*,be.openclinic.datacenter.DatacenterHelper" %>
<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFAMCPatientCardsGenerator"%>
<%@page errorPage="/includes/error.jsp"%>
<%
		StringBuffer cardsToPrint = new StringBuffer();
		Enumeration pars = request.getParameterNames();
		String parameter="";
		while(pars.hasMoreElements()){
			parameter=(String)pars.nextElement();
			if(parameter.startsWith("cbp.")){
				if(cardsToPrint.length()>0){
					cardsToPrint.append(";");					
				}
				cardsToPrint.append(parameter.substring(4));
			}
		}
        ByteArrayOutputStream baosPDF = null;
	    try{
	        // PDF generator
	        if(MedwanQuery.getInstance().getConfigString("patientCardsGenerator."+request.getParameter("serverid")).equalsIgnoreCase("AMC")){
		        PDFAMCPatientCardsGenerator pdfGenerator = new PDFAMCPatientCardsGenerator(activeUser,sProject);
		        baosPDF = pdfGenerator.generatePDFDocumentBytes(request,cardsToPrint,sWebLanguage);
	        }

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
	            baosPDF=null;
	        }
	    }

%>