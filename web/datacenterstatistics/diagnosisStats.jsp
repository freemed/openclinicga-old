<%@ page import="be.openclinic.statistics.DiagnosisStats,java.text.DecimalFormat,java.util.*" %>
<%@ page import="be.openclinic.statistics.DiagnosisGroupStats" %>
<%@ page import="be.openclinic.statistics.DStats" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics.globalpathologydistribution","select",activeUser)%>
<%
    int detail=5;
    if(request.getParameter("detail")!=null){
        try{
            detail=Integer.parseInt(request.getParameter("detail"));
        }
        catch(Exception e){

        }
    }
    String sortorder=checkString(request.getParameter("sortorder"));
    String contacttype="admission";
    if(request.getParameter("contacttype")!=null){
        contacttype=request.getParameter("contacttype");
    }
    if(sortorder.length()==0){
        sortorder="duration";
    }
    String todate=request.getParameter("todate");
    String fromdate=request.getParameter("fromdate");
    String service=checkString(request.getParameter("ServiceID"));
    String showCalculations=checkString(request.getParameter("showCalculations"));
    String serviceName = "";
    if(service.length()>0){
        serviceName=getTran("service",service,sWebLanguage);
    }
    if(todate==null){
        todate=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
    }
    if(fromdate==null){
        fromdate="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String codetype = checkString(request.getParameter("codetype"));
    Boolean bGroups=false;
    if(codetype.equalsIgnoreCase("icd10groups")){
        bGroups=true;
        codetype="icd10";
    }
    if(codetype.equalsIgnoreCase("icpcgroups")){
        bGroups=true;
        codetype="icpc";
    }
%>
<form name="diagstats" id="diagstats" method="post">
    <%=writeTableHeader("Web","statistics.globalpathology",sWebLanguage," doBack();")%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="0">
        <tr>
            <td><%=getTran("web","codetype",sWebLanguage)%></td>
            <td>
                <select name="codetype" class="text">
                    <option value="icpc" <%="icpc".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTran("web","icpc",sWebLanguage)%></option>
                    <option value="icd10" <%="icd10".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTran("web","icd10",sWebLanguage)%></option>
                    <option value="icpcgroups" <%="icpcgroups".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTran("web","icpcgroups",sWebLanguage)%></option>
                    <option value="icd10groups" <%="icd10groups".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTran("web","icd10groups",sWebLanguage)%></option>
                </select>
                <%=getTran("web","code",sWebLanguage)%>
                <input type="text" class="text" name="code" value="<%=checkString(request.getParameter("code"))%>"/>
                <input type="checkbox" name="codedetails" <%=request.getParameter("codedetails")!=null?"checked":""%>>
                <%=getTran("web","detail",sWebLanguage)%>
                <select name="detail" class="text">
                    <option value="1" <%=detail==1?"selected":""%>>1</option>
                    <option value="2" <%=detail==2?"selected":""%>>2</option>
                    <option value="3" <%=detail==3?"selected":""%>>3</option>
                    <option value="4" <%=detail==4?"selected":""%>>4</option>
                    <option value="5" <%=detail==5?"selected":""%>>5</option>
                </select>
                <select class="text" name="contacttype" id="contacttype" onchange="validateContactType();">
                    <%=ScreenHelper.writeSelect("encountertype",contacttype,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
            <td><%=getTran("web","from",sWebLanguage)%>&nbsp;</td>
            <td>
                <%=writeDateField("fromdate","diagstats",fromdate,sWebLanguage)%>&nbsp;
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%=writeDateField("todate","diagstats",todate,sWebLanguage)%>&nbsp;
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","service",sWebLanguage)%></td>
            <td colspan='2'>
                <input type="hidden" name="ServiceID" id="ServiceID" value="<%=service%>">
                <input class="text" type="text" name="ServiceName" id="ServiceName" readonly size="<%=sTextWidth%>" value="<%=serviceName%>" onblur="">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('ServiceID','ServiceName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="ServiceID.value='';ServiceName.value='';">
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","show.statistical.calculations",sWebLanguage)%></td>
            <td colspan='2'>
                <input id="showCalculations" type="checkbox" name="showCalculations" <%=showCalculations.length()>0?"checked":""%>>
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","sortorder",sWebLanguage)%></td>
            <td>
                <select name="sortorder" id="sortorder" class="text">
                    <option value="duration" <%="duration".equalsIgnoreCase(sortorder)?" selected":""%>><%=getTran("web","sortorder.duration",sWebLanguage)%></option>
                    <option value="count" <%="count".equalsIgnoreCase(sortorder)?" selected":""%>><%=getTran("web","sortorder.count",sWebLanguage)%></option>
                    <option value="dead" <%="dead".equalsIgnoreCase(sortorder)?" selected":""%>><%=getTran("web","sortorder.dead",sWebLanguage)%></option>
                </select>
            </td>
        </tr>
        <tr>
            <td/>
            <td>
                <input type="submit" class="button" name="calculate" value="<%=getTran("web","calculate",sWebLanguage)%>"/>
                <input type="button" class="button" name="backButton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    <%
    if (request.getParameter("calculate") != null) {
        java.util.SortedSet diags = new TreeSet();
        DStats mainStats=null;
        if(bGroups){
            mainStats = new DiagnosisGroupStats(codetype, checkString(request.getParameter("code"))+"%", new SimpleDateFormat("dd/MM/yyyy").parse(fromdate), new SimpleDateFormat("dd/MM/yyyy").parse(todate),service,sortorder,contacttype);
        }
        else {
            mainStats = new DiagnosisStats(codetype, checkString(request.getParameter("code"))+"%", new SimpleDateFormat("dd/MM/yyyy").parse(fromdate), new SimpleDateFormat("dd/MM/yyyy").parse(todate),service,sortorder,contacttype);
        }
        int totalDead=mainStats.calculateTotalDead(new SimpleDateFormat("dd/MM/yyyy").parse(fromdate), new SimpleDateFormat("dd/MM/yyyy").parse(todate));
        if(showCalculations.length()==0){
            %>
                <table width="100%" class='list' cellspacing="1" cellpadding="0">
                    <tr class="gray">
                        <td width="5%"><b><%=getTran("web","code",sWebLanguage)%></b></td>
                        <td width="35%"><b><%=getTran("web","codename",sWebLanguage)%></b></td>
                        <td width="10%"><b><%=getTran("web","numberofdiagnoses",sWebLanguage)%> (<%=getTran("web","numberofcases",sWebLanguage)%>=<%=mainStats.getTotalContacts()%>)</b></td><td width="5%"><b>%</b></td>
                        <td width="10%"><b><%=getTran("web","totalduration",sWebLanguage)%> (<%=getTran("web","durationofcases",sWebLanguage)%>=<%=mainStats.getTotalDuration()%>)</b></td><td width="5%"><b>%</b></td>
                        <td width="10%"><b><%=getTran("web","dead",sWebLanguage)%> (<%=getTran("web","numberofdead",sWebLanguage)%>=<%=totalDead%>=<%=new DecimalFormat("#0.00").format(new Double(totalDead).doubleValue()*100.0/mainStats.getTotalContacts())%>%)</b></td>
                        <td width="10%"><b><%=getTran("web","relativenumberofdead",sWebLanguage)%></b></td>
                        <td width="10%"><b><%=getTran("web","globalrelativenumberofdead",sWebLanguage)%></b></td>
                    </tr>
                <%
            }
        DStats diagnosisStats = null;
        if(request.getParameter("codedetails")!=null){
            if(bGroups){
                diags = DiagnosisGroupStats.calculateSubStats(codetype, checkString(request.getParameter("code"))+"%", new SimpleDateFormat("dd/MM/yyyy").parse(fromdate), new SimpleDateFormat("dd/MM/yyyy").parse(todate),service,sortorder,detail,contacttype);
            }
            else {
                diags = DiagnosisStats.calculateSubStats(codetype, checkString(request.getParameter("code"))+"%", new SimpleDateFormat("dd/MM/yyyy").parse(fromdate), new SimpleDateFormat("dd/MM/yyyy").parse(todate),service,sortorder,detail,contacttype);
            }
        }
        diags.add(mainStats);
        Vector d = new Vector(diags);
        Collections.reverse(d);
        Iterator iterator = d.iterator();
        while (iterator.hasNext()) {
            diagnosisStats = (DStats) iterator.next();
            if(showCalculations.length()>0){
            %>
                <br>
                <table width="100%" class='list' cellspacing="1" cellpadding="0">
                    <tr class="admin">
                        <td width="10%"><%=getTran("web","code",sWebLanguage)%></td>
                        <td width="30%"><%=getTran("web","codename",sWebLanguage)%></td>
                        <td width="30%"><%=getTran("web","numberofdiagnoses",sWebLanguage)%> (<%=getTran("web","numberofcases",sWebLanguage)%>=<%=mainStats.getTotalContacts()%>)</td>
                        <td width="30%"><%=getTran("web","totalduration",sWebLanguage)%> (<%=getTran("web","durationofcases",sWebLanguage)%>=<%=mainStats.getTotalDuration()%>)</td>
                    </tr>
                    <tr>
                        <td><%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%></td>
                        <%
                            String codeLabel=diagnosisStats.getCode().replaceAll("%","").length()<0?diagnosisStats.getCodeType().replaceAll("%","").toUpperCase()+" "+diagnosisStats.getCode().replaceAll("%",""):MedwanQuery.getInstance().getCodeTran(diagnosisStats.getCodeType()+"code"+(diagnosisStats.getCodeType().equalsIgnoreCase("icpc")?ScreenHelper.padRight(diagnosisStats.getCode().replaceAll("%",""),"0",5):diagnosisStats.getCode().replaceAll("%","")),sWebLanguage);
                            codeLabel=codeLabel.replaceAll(diagnosisStats.getCodeType()+"code","");
                        %>
                        <td><b><%=codeLabel%></b></td>
                        <td><a href="javascript:listcasesall('<%=diagnosisStats.getCodeType()%>','<%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%>','<%=codeLabel%>');">
                        <%=diagnosisStats.getDiagnosisAllCases() +(diagnosisStats.equals(mainStats)?"":" (" + new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisAllCases()).doubleValue()*100.0/diagnosisStats.getTotalContacts())+"%)")%>
                        </a></td>
                        <%
                            if(!diagnosisStats.equals(mainStats)){
                        %>
                                <td><%=diagnosisStats.getDiagnosisTotalDuration() + " (" + new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisTotalDuration().intValue()).doubleValue()*100.0/diagnosisStats.getTotalDuration())+"%)"%></td>
                        <%
                            }
                        %>
                    </tr>
                    <%
                        if(true || !diagnosisStats.equals(mainStats)){
                    %>
                        <tr>
                            <td colspan="4">
                                <table width="100%" cellspacing="1" cellpadding="0">
                                    <tr class="gray">
                                        <td>&nbsp;</td>
                                        <td><%=getTran("web","outcome",sWebLanguage)%></td>
                                        <td><%=getTran("web","numberofcases",sWebLanguage)%></td>
                                        <td><%=getTran("web","admissionduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","meanduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","medianduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","standarddeviationduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","minimumduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","maximumduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","comorbidity",sWebLanguage)%></td>
                                        <td><%=getTran("web","correctedtotalduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","correctedmeanduration",sWebLanguage)%></td>
                                        <td><%=getTran("web","correctedmedianduration",sWebLanguage)%></td>
                                    </tr>
                                    <%
                                        Iterator iterator2 = diagnosisStats.getOutcomeStats().iterator();
                                        while (iterator2.hasNext()) {
                                            DStats.OutcomeStat outcomeStat = (DStats.OutcomeStat) iterator2.next();
                                            double[] q;
                                            if(bGroups){
                                                q = DiagnosisGroupStats.getMedianDuration(diagnosisStats.getCode().replaceAll("%",""), diagnosisStats.getCodeType(), diagnosisStats.getStart(),diagnosisStats.getEnd(),outcomeStat.getOutcome(),service,contacttype);
                                            }
                                            else {
                                                q = DiagnosisStats.getMedianDuration(diagnosisStats.getCode().replaceAll("%",""), diagnosisStats.getCodeType(), diagnosisStats.getStart(),diagnosisStats.getEnd(),outcomeStat.getOutcome(),service,contacttype);
                                            }
                                            double median = q[1];
                                            double sd=outcomeStat.getStandardDeviationDuration();
                                            out.print("<tr><td width='2%'>&nbsp;</td><td width='9%'>"+getTran("outcome",outcomeStat.getOutcome(),sWebLanguage)+" ("+new DecimalFormat("#0.00").format(new Double(outcomeStat.getDiagnosisCases()).doubleValue()*100.0/diagnosisStats.getDiagnosisAllCases())+"%)</td>" +
                                                    "<td><a href=\"javascript:listcases('"+diagnosisStats.getCodeType()+"','"+diagnosisStats.getCode().replaceAll("%","").toUpperCase()+"','"+codeLabel+"','"+outcomeStat.getOutcome()+"');\">"+new DecimalFormat("#0").format(outcomeStat.getDiagnosisCases())+"</a></td>" +
                                                    "<td>"+new DecimalFormat("#0.00").format(new Double(outcomeStat.getMeanDuration()*outcomeStat.getDiagnosisCases()))+" "+getTran("web","days",sWebLanguage)+"</td>" +
                                                    "<td>"+new DecimalFormat("#0.00").format(outcomeStat.getMeanDuration())+" "+getTran("web","days",sWebLanguage)+"</td>" +
                                                    "<td><b>"+new DecimalFormat("#0.00").format(median)+" "+getTran("web","days",sWebLanguage)+"</b></br>" +
                                                    "(Q1="+q[0]+",Q3="+q[2]+")</td>" +
                                                    "<td>"+new DecimalFormat("#0.00").format(sd)+" "+getTran("web","days",sWebLanguage)+"</td>" +
                                                    "<td"+(outcomeStat.getMinDuration()<outcomeStat.getMeanDuration()-3*sd?" style='color: red'":"")+">"+new DecimalFormat("#0.00").format(outcomeStat.getMinDuration())+" "+getTran("web","days",sWebLanguage)+"</td>" +
                                                    "<td"+(outcomeStat.getMaxDuration()>outcomeStat.getMeanDuration()+3*sd?" style='color: red'":"")+">"+new DecimalFormat("#0.00").format(outcomeStat.getMaxDuration())+" "+getTran("web","days",sWebLanguage)+"</td>" +
                                                    "<td><a href=\"javascript:listcomorbidity('"+diagnosisStats.getCodeType()+"','"+diagnosisStats.getCode().replaceAll("%","").toUpperCase()+"','"+outcomeStat.getOutcome()+"','"+outcomeStat.getDiagnosisCases()+"');\">"+new DecimalFormat("#0.00").format(outcomeStat.getCoMorbidityScore())+"</a></td>" +
                                                    "<td>"+new DecimalFormat("#0.00").format(new Double(outcomeStat.getMeanDuration()*outcomeStat.getDiagnosisCases()/outcomeStat.getCoMorbidityScore()))+"</td>" +
                                                    "<td>"+new DecimalFormat("#0.00").format(outcomeStat.getMeanDuration()/outcomeStat.getCoMorbidityScore())+" (+-"+new DecimalFormat("#0.00").format(outcomeStat.getStandardDeviationDuration()/outcomeStat.getCoMorbidityScore())+") "+getTran("web","days",sWebLanguage)+"</td>" +
                                                    "<td><b>"+new DecimalFormat("#0.00").format(median/outcomeStat.getCoMorbidityScore())+" (+-"+new DecimalFormat("#0.00").format(outcomeStat.getStandardDeviationDuration()/outcomeStat.getCoMorbidityScore())+") "+getTran("web","days",sWebLanguage)+"</b></td>" +
                                                    "<tr>");
                                        }
                                    %>
                                </table>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                </table>
            <%
        }
        else {
            %>
                <tr>
                    <td><%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%></td>
                    <%
                        //if we have a full code, show the label, else only show the code
                        String codeLabel=diagnosisStats.getCode().replaceAll("%","").length()<0?diagnosisStats.getCodeType().replaceAll("%","").toUpperCase()+" "+diagnosisStats.getCode().replaceAll("%",""):MedwanQuery.getInstance().getCodeTran(diagnosisStats.getCodeType()+"code"+(diagnosisStats.getCodeType().equalsIgnoreCase("icpc")?ScreenHelper.padRight(diagnosisStats.getCode().replaceAll("%",""),"0",5):diagnosisStats.getCode().replaceAll("%","")),sWebLanguage);
                        codeLabel=codeLabel.replaceAll(diagnosisStats.getCodeType()+"code","");
                    %>
                    <td><b><%=codeLabel%></b></td>
                    <td><a href="javascript:listcasesall('<%=diagnosisStats.getCodeType()%>','<%=diagnosisStats.getCode().replaceAll("%","").toUpperCase()%>','<%=codeLabel%>');">
                    <%=diagnosisStats.getDiagnosisAllCases()%>
                    </a></td>
                    <%
                        if(!diagnosisStats.equals(mainStats)){
                    %>
                            <td><%=new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisAllCases()).doubleValue()*100.0/diagnosisStats.getTotalContacts())%>%</td>
                            <td><%=(contacttype.equalsIgnoreCase("visit")?"</td><td>":diagnosisStats.getDiagnosisTotalDuration() + "</td><td>" + new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisTotalDuration().intValue()).doubleValue()*100.0/diagnosisStats.getTotalDuration()))%>%</td>
                            <td><%=(contacttype.equalsIgnoreCase("visit")?"</td><td>":diagnosisStats.getDiagnosisDead()+"</td><td>"+new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisDead().intValue()).doubleValue()*100.0/diagnosisStats.getDiagnosisAllCases()) + "%</td><td>" + new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisDead().intValue()).doubleValue()*100.0/totalDead))%>%</td>
                    <%
                        }
                        else {
                    %>
                            <td colspan="3"></td>
                            <td><%=(contacttype.equalsIgnoreCase("visit")?"":diagnosisStats.getDiagnosisDead()+"</td><td>"+new DecimalFormat("#0.00").format(new Double(diagnosisStats.getDiagnosisDead().intValue()).doubleValue()*100.0/diagnosisStats.getDiagnosisAllCases()) )%>%</td>
                    <%
                        }
                    %>
                </tr>
            <%
        }
    }             }
%>
    <%
        if(showCalculations.length()==0){
    %>
    </table>
<%
    }
%>
</form>
<script type="text/javascript">
    function listcasesall(codeType,code,codeLabel){
        window.open("<c:url value='/popup.jsp'/>?Page=medical/manageDiagnosesPop.jsp&PopupHeight=600&ts=<%=getTs()%>&selectrecord=1&Action=SEARCH&FindDiagnosisFromDate=<%=fromdate%>&FindDiagnosisToDate=<%=todate%>&FindDiagnosisCode="+code+"&FindDiagnosisCodeType="+codeType+"&FindDiagnosisCodeLabel="+code+" "+codeLabel+"&ServiceID=<%=service%>&contacttype=<%=contacttype%>","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no").moveTo((screen.width-800)/2,(screen.height-600)/2);
    }
    function listcases(codeType,code,codeLabel,outcome){
        if (outcome=='') outcome='null';
        window.open("<c:url value='/popup.jsp'/>?Page=medical/manageDiagnosesPop.jsp&PopupHeight=600&ts=<%=getTs()%>&selectrecord=1&Action=SEARCH&FindDiagnosisFromDate=<%=fromdate%>&FindDiagnosisToDate=<%=todate%>&FindDiagnosisCode="+code+"&FindDiagnosisCodeType="+codeType+"&FindDiagnosisCodeLabel="+code+" "+codeLabel+"&FindEncounterOutcome="+outcome+"&ServiceID=<%=service%>&contacttype=<%=contacttype%>","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no").moveTo((screen.width-800)/2,(screen.height-600)/2);
    }
    function listcomorbidity(codeType,code,outcome,totalcases){
        if (outcome=='') outcome='null';
        window.open("<c:url value='/popup.jsp'/>?Page=statistics/showComorbidity.jsp&PopupHeight=600&ts=<%=getTs()%>&Start=<%=fromdate%>&End=<%=todate%>&DiagnosisCode="+code+"&DiagnosisCodeType="+codeType+"&Outcome="+outcome+"&TotalCases="+totalcases+"&ServiceID=<%=service%>&contacttype=<%=contacttype%>&PopupWidth=500&PopupHeight=500&groupcodes=<%=bGroups?"yes":"no"%>","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=300, height=400, menubar=no").moveTo((screen.width-300)/2,(screen.height-400)/2);
    }
    function searchService(serviceUidField,serviceNameField){
        openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.all[serviceNameField].focus();
    }
    function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
    }
    function validateContactType(){
        if(document.getElementById("contacttype").value=="visit"){
            document.getElementById("showCalculations").checked=false;
            document.getElementById("showCalculations").disabled=true;
        }
        else {
            document.getElementById("showCalculations").disabled=false;
        }
    }
    validateContactType();
</script>