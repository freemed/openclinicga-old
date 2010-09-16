<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.diagnostics.Diagnostic,
                be.mxs.common.util.diagnostics.Diagnosis,
                java.io.IOException,
                org.dom4j.io.SAXReader"%>
<%!
        //--- OPENER STATUS ---------------------------------------------------------------------------
    public void openerstatus(javax.servlet.jsp.JspWriter out, String message) throws IOException {
        out.print("<script>window.opener.status=\"" + message + "\";</script>");
        out.flush();
    }
    //--- RUN DIAGNOSTIC --------------------------------------------------------------------------
    private void runDiagnostic(Diagnostic diagnostic,javax.servlet.jsp.JspWriter out){
        try {
            openerstatus(out,"Cleaning "+diagnostic.getName()+"...");

            Diagnosis diagnosis = diagnostic.check();
            if (diagnosis.hasProblems){
                if (diagnostic.correct(diagnosis)){
                    openerstatus(out,diagnostic.getName()+" cleanup was OK");
                }
                else {
                    openerstatus(out,diagnostic.getName()+" ERROR: cleanup was not OK>");
                }
            }
            else {
                openerstatus(out,diagnostic.getName()+" had no problems");
            }
        }
        catch (IOException e) {
            e.printStackTrace();
        }
    }
%>

<script>
  window.resizeTo(5,5);
  window.moveTo(-100,-100);
</script>

<%
    out.flush();

    Iterator integrityChecks = new SAXReader(false).read(new URL(MedwanQuery.getInstance().getConfigString("templateSource") + "/application.xml")).getRootElement().element("integrityChecks").elements("integrityCheck").iterator();
    Diagnostic diagnostic;
    while (integrityChecks.hasNext()) {
        diagnostic = (Diagnostic) Class.forName(((Element) integrityChecks.next()).attributeValue("className")).newInstance();
        if (request.getParameter(diagnostic.getName()) != null) {
            runDiagnostic(diagnostic, out);
        }
    }
%>

<script>
  window.opener.location.reload();
  window.close();
</script>