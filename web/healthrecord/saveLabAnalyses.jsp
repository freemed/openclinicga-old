<%@page import="be.openclinic.medical.*,be.mxs.common.util.system.*,be.openclinic.finance.*"%>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.medical.Labo" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    // delete all labanalysis in the specified LabRequest, then insert all analysis to be saved
    String sServerId          = checkString(request.getParameter("serverId")),
           sTransactionId     = checkString(request.getParameter("transactionId")),
           sLabAnalysesToSave = checkString(request.getParameter("labAnalysesToSave")),
           sSavedLabAnalyses  = checkString(request.getParameter("savedLabAnalyses"));

    /*
    Debug.println("// DEBUG ////////////////////////////////////////////////");
    Debug.println("** sServerId          : "+sServerId);
    Debug.println("** sTransactionId     : "+sTransactionId);
    Debug.println("** sLabAnalysesToSave : "+sLabAnalysesToSave);
    Debug.println("** sSavedLabAnalyses  : "+sSavedLabAnalyses+"\n\n");
    */

    // put analysis-codes in a Hashtable, to be able to sort them
    String token, analysisCode, comment;
    RequestedLabAnalysis labAnalysis;

    if(sLabAnalysesToSave.indexOf("$")>-1 && Integer.parseInt(sTransactionId) > 0){
        %><script>window.opener.deleteAllLANoConfirm();</script><%

    // compose query, to use many times later on
    
    // tokenize savedLabAnalyses specified in parameter
    StringTokenizer tokenizer = new StringTokenizer(sSavedLabAnalyses, "$");
    Vector savedAnalyses = new Vector();
    while (tokenizer.hasMoreTokens()) {
        token = tokenizer.nextToken();
        analysisCode = token.substring(0, token.indexOf("£"));
        savedAnalyses.add(analysisCode);
    }

    // tokenize labAnalysesToSave specified in parameter
    tokenizer = new StringTokenizer(sLabAnalysesToSave, "$");
    Vector analysesToSave = new Vector();
    HashMap labAnalysesToSave = new HashMap();
    while (tokenizer.hasMoreTokens()) {
        token = tokenizer.nextToken();

        // data from parameter
        analysisCode = token.substring(0, token.indexOf("£"));
        comment = token.substring(token.indexOf("£") + 1);

        labAnalysesToSave.put(analysisCode, comment);
        analysesToSave.add(analysisCode);
    }

    // delete analyses that are in savedAnalyses but not in analysesToSave
    HashSet analysesToDelete = new HashSet();
    String code;
    boolean codeFound = false;

    // saved -> toSave
    for (int i = 0; i < savedAnalyses.size(); i++) {
        code = (String) savedAnalyses.get(i);
        for (int j = 0; j < analysesToSave.size(); j++) {
            if (analysesToSave.get(j).equals(code)) {
                codeFound = true;
                break;
            }
        }

        if (!codeFound) analysesToDelete.add(code);
        codeFound = false;
    }

    // delete specified analyses
    Iterator iterator = analysesToDelete.iterator();
    while (iterator.hasNext()) {
		analysisCode=(String) iterator.next();
        RequestedLabAnalysis.delete(Integer.parseInt(sServerId), Integer.parseInt(sTransactionId), analysisCode);
        Pointer.deletePointers("LAB."+sServerId+"."+sTransactionId+"."+analysisCode);
    }

    // sort analysis-codes to be saved
    Vector codes = new Vector(labAnalysesToSave.keySet());
    Collections.sort(codes);
	Hashtable allanalyses = LabAnalysis.getAllLabanalyses();
    for (int i = 0; i < codes.size(); i++) {
        analysisCode = (String) codes.get(i);
        comment = (String) labAnalysesToSave.get(analysisCode);

        labAnalysis = RequestedLabAnalysis.get(Integer.parseInt(sServerId), Integer.parseInt(sTransactionId), analysisCode);
        if (labAnalysis == null) {
            // labRequest not found : insert in DB
            LabAnalysis a = (LabAnalysis)allanalyses.get(analysisCode);
			System.out.println("editor for "+a.getLabcode()+" = "+a.getEditor());
        	if(a!=null && MedwanQuery.getInstance().getConfigString("virtualLabAnalysisEditors","virtual").indexOf(a.getEditor())<0){    
	            labAnalysis = new RequestedLabAnalysis();
	            labAnalysis.setServerId(sServerId);
	            labAnalysis.setTransactionId(sTransactionId);
	            labAnalysis.setAnalysisCode(analysisCode);
	            labAnalysis.setComment(comment);
	            labAnalysis.store();
			}
            if(a!=null && a.getPrestationcode()!=null && a.getPrestationcode().length()>0 && Pointer.getPointer("LAB."+sServerId+"."+sTransactionId+"."+analysisCode).length()==0){
				Debet.createAutomaticDebet("LAB."+sServerId+"."+sTransactionId+"."+analysisCode, activePatient.personid, a.getPrestationcode(), activeUser.userid);
		    }
        }

        // get default-labanalysis-data from DB
        String type = "", label = "", monster = "";
        Hashtable hLabRequestData = Labo.getLabRequestDefaultData(analysisCode,sWebLanguage);

        if (hLabRequestData != null) {
            type = (String) hLabRequestData.get("labtype");
            label = (String) hLabRequestData.get("OC_LABEL_VALUE");
            monster = (String) hLabRequestData.get("monster");
        }

        // translate labtype
        if (type.equals("1")) type = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
        else if (type.equals("2")) type = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
        else if (type.equals("3")) type = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
        else if (type.equals("4")) type = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
        else if (type.equals("5")) type = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
        else if (type.equals("6")) type = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
        else if (type.equals("7")) type = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

        // add labanalysis to the table in the opener
%>
                <script>
                  window.opener.addLabAnalysis('<%=analysisCode%>','<%=type%>','<%=label%>','<%=comment%>','<%=monster%>');
                </script>
            <%
        }
    }
%>

<script>
  window.opener.sortLabAnalyses();
  window.opener.indicateLA();
  window.close();
</script>