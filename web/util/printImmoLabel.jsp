<%@include file="/includes/validateUser.jsp"%><%@page errorPage="/includes/error.jsp"%><%@page import="java.io.ByteArrayOutputStream,
                com.lowagie.text.DocumentException,
                java.io.PrintWriter
                ,be.mxs.common.util.pdf.general.PDFLabSampleLabelGenerator
                ,java.util.*,
                be.openclinic.medical.LabRequest,be.openclinic.medical.LabSample" %><%@ page import="be.chuk.Article" %><%@ page import="be.mxs.common.util.pdf.general.PDFImmoLabelGenerator" %><%
    ByteArrayOutputStream baosPDF = null;
    Vector articles=new Vector();
    Hashtable articlesh = new Hashtable();
    TreeSet an = new TreeSet();
    Enumeration parameters=request.getParameterNames();
    while(parameters.hasMoreElements()){
        String parameterName = (String)parameters.nextElement();
        if(parameterName.startsWith("article")){
            Article article = new Article();
            article.id=parameterName.replaceAll("article","");
            article.name=request.getParameter(parameterName);
            try{
                articlesh.put(article.id,article);
                an.add(article.id);
            }
            catch(Exception e){
                
            }
        }
    }
    Iterator i=an.iterator();
    while(i.hasNext()){
        articles.add(articlesh.get(i.next()));
    }
    try {
        // PDF generator
        PDFImmoLabelGenerator pdfImmoLabelGenerator = new PDFImmoLabelGenerator(activeUser, sProject);
        baosPDF = pdfImmoLabelGenerator.generatePDFDocumentBytes(request, articles);
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