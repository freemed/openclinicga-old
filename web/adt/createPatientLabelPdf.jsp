<%@page import="java.io.ByteArrayOutputStream,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter,
                be.mxs.common.util.pdf.general.PDFPatientLabelGenerator,
                be.mxs.common.util.pdf.general.PDFArchiveLabelGenerator"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    String sLabelCount = checkString(request.getParameter("labelcount")),
           sLabelType  = checkString(request.getParameter("type"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* adt/createPatientLabel.jsp **********************");
    	Debug.println("sLabelCount : "+sLabelCount);
    	Debug.println("sLabelType  : "+sLabelType+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    if(sLabelCount.length() > 0){
        ByteArrayOutputStream baosPDF = null;

        try{
            if("3".equalsIgnoreCase(sLabelType)){
                PDFArchiveLabelGenerator pdfArchiveLabelGenerator = new PDFArchiveLabelGenerator(activeUser,sProject);
                baosPDF = pdfArchiveLabelGenerator.generatePDFDocumentBytes(request,activePatient,Integer.parseInt(request.getParameter("labelcount")),request.getParameter("type"));
            }
            else{
                // PDF generator
                PDFPatientLabelGenerator pdfPatientLabelGenerator = new PDFPatientLabelGenerator(activeUser,sProject);
                baosPDF = pdfPatientLabelGenerator.generatePDFDocumentBytes(request,activePatient,Integer.parseInt(request.getParameter("labelcount")),request.getParameter("type"));
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
	        writer.println(this.getClass().getName()+" caught an exception: "+dex.getClass().getName()+"<br>");
	        writer.println("<pre>");
	        dex.printStackTrace(writer);
	        writer.println("</pre>");
	    }
	    finally{
	        if(baosPDF!=null) baosPDF.reset();
	    }
	}
	else{
%>
    <head>
        <%=sCSSNORMAL%>
        <title><%=getTranNoLink("web","printlabels",sWebLanguage)%></title>
    </head>
    
    <form method="post" style="padding:3px;">
        <table cellspacing="0" cellpadding="0" width="100%" class="list">
            <%-- NUMBER OF COPIES --%>
            <tr>
                <td class="admin2" style="border-bottom:1px solid #ccc">
                    <%=getTran("web","labelcount",sWebLanguage)%>&nbsp;
                    <input class="text" size="2" type="text" name="labelcount" value="<%=MedwanQuery.getInstance().getConfigString("defaultLabelCount","1")%>"/>
                    <input class="button" type="submit" name="submit" value="<%=getTranNoLink("web","print",sWebLanguage)%>"/>
                </td>
            </tr>
            
            <%-- FORMAT --%>
            <tr>
                <td style="padding:3px;">
                    <input type="radio" name="type" id="r1" value="1" checked/><%=getLabel("web","labeltype1",sWebLanguage,"r1")%><br>
                    <input type="radio" name="type" id="r2" value="2"/><%=getLabel("web","labeltype2",sWebLanguage,"r2")%><br>
                    <input type="radio" name="type" id="r3" value="3"/><%=getLabel("web","labeltype3",sWebLanguage,"r3")%>
                </td>
            </tr>
        </table>
    </form>
<%
    }
%>

<script>
  window.open("<c:url value='/'/>/util/setprinter.jsp?printer=labelprinter","Popup"+new Date().getTime(),"toolbar=no,status=no,scrollbars=no,resizable=no,width=1,height=1,menubar=no").moveBy(-1000,-1000);
</script>