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
        	System.out.println("parametername="+parameterName);
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
        System.out.println("1");
        PDFImmoLabelGenerator pdfImmoLabelGenerator = new PDFImmoLabelGenerator(activeUser, sProject);
        System.out.println("2");
        baosPDF = pdfImmoLabelGenerator.generatePDFDocumentBytes(request, articles);
        System.out.println("3");
        StringBuffer sbFilename = new StringBuffer();
        sbFilename.append("filename_").append(System.currentTimeMillis()).append(".pdf");
        System.out.println("4");

        StringBuffer sbContentDispValue = new StringBuffer();
        sbContentDispValue.append("inline; filename=")
                .append(sbFilename);
        System.out.println("5");

        // prepare response
        response.setHeader("Cache-Control", "max-age=30");
        response.setContentType("application/pdf");
        response.setHeader("Content-disposition", sbContentDispValue.toString());
        response.setContentLength(baosPDF.size());
        System.out.println("6");

        // write PDF to servlet
        ServletOutputStream sos = response.getOutputStream();
        System.out.println("7");
        baosPDF.writeTo(sos);
        System.out.println("8");
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