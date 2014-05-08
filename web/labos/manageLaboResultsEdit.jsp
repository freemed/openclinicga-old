<%@ page import="be.openclinic.medical.RequestedLabAnalysis,java.util.*,be.openclinic.medical.LabRequest" %>
<%@ page import="be.openclinic.medical.LabAnalysis" %>
<%@include file="/includes/validateUser.jsp" %>
<head><%=sJSCHAR %></head>
<%=checkPermission("labos.openpatientlaboresults", "select", activeUser)%><%=checkPermission("labos.biologicvalidationbyrequest", "select", activeUser)%><%!
    public class LabRow {
        int type;
        String tag;
        public LabRow(int type, String tag) {
            this.type = type;
            this.tag = tag;
        }
    }
    public String getComplexResult(String id, Map map, String sWebLanguage,java.util.Date validationDate) {
        String sReturn = "<input type='hidden' name='result." + id + "' />";
        sReturn += "<input type='hidden' id='resultAntibio." + id + ".germ1' name='resultAntibio." + id + ".germ1' value='" + checkString((String) map.get("germ1")) + "'/>";
        sReturn += "<input type='hidden' id='resultAntibio." + id + ".germ2' name='resultAntibio." + id + ".germ2' value='" + checkString((String) map.get("germ2")) + "' />";
        sReturn += "<input type='hidden' id='resultAntibio." + id + ".germ3' name='resultAntibio." + id + ".germ3' value='" + checkString((String) map.get("germ3")) + "' />";
        sReturn += "<input type='hidden' id='resultAntibio." + id + ".antibio1' name='resultAntibio." + id + ".ANTIBIOGRAMME1' value='" + checkString((String) map.get("ANTIBIOGRAMME1")) + "' />";
        sReturn += "<input type='hidden' id='resultAntibio." + id + ".antibio2' name='resultAntibio." + id + ".ANTIBIOGRAMME2' value='" + checkString((String) map.get("ANTIBIOGRAMME2")) + "' />";
        sReturn += "<input type='hidden' id='resultAntibio." + id + ".antibio3' name='resultAntibio." + id + ".ANTIBIOGRAMME3' value='" + checkString((String) map.get("ANTIBIOGRAMME3")) + "' />";
        sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexResult(\"" + id + "\")'>" + getTranNoLink("web", "openAntibiogrameresult", sWebLanguage) + "</a>";
        sReturn += " "+getTran("web","resultcomplete",sWebLanguage)+" <input type='checkbox' "+(validationDate!=null?"checked":"")+" name='validateAntibio."+id+"'/>";
        return sReturn;
    }
%>
<%
    boolean bSaved = false;
    if (request.getParameter("submit") != null) {
        bSaved = true;
        Enumeration e = request.getParameterNames();
        Hashtable composedResults = new Hashtable();
        while (e.hasMoreElements()) {
            String name = (String) e.nextElement();
            if (name.startsWith("result.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                if(RequestedLabAnalysis.updateValue(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3], value,Integer.parseInt(activeUser.userid))>0){
                	RequestedLabAnalysis.setModifiedFinalValidation(Integer.parseInt(v[1]), Integer.parseInt(v[2]), Integer.parseInt(activeUser.userid), "'"+v[3]+"'",value);
                }
            } 
            else if (name.startsWith("resultmultiple.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                if(composedResults.get(v[1]+"."+v[2]+"."+v[3])==null){
                	composedResults.put(v[1]+"."+v[2]+"."+v[3],value);
                }
                else{
                	composedResults.put(v[1]+"."+v[2]+"."+v[3],(String)composedResults.get(v[1]+"."+v[2]+"."+v[3])+","+value);
                }
            } 
            else if (name.startsWith("resultcomment.")) {
                String[] v = name.split("\\.");
                String value = request.getParameter(name);
                RequestedLabAnalysis.updateResultComment(Integer.parseInt(v[1]), Integer.parseInt(v[2]), v[3], value);
            } 
            else if (name.startsWith("resultAntibio.")) {
                RequestedLabAnalysis.setAntibiogrammes(name, request.getParameter(name), activeUser.userid);
            } 
            else if (name.startsWith("validateAntibio.")) {
                String[] v = name.split("\\.");
                RequestedLabAnalysis.setForcedFinalValidation(Integer.parseInt(v[1]), Integer.parseInt(v[2]), Integer.parseInt(activeUser.userid), "'"+v[3]+"'");
            }
        }
        Enumeration cr = composedResults.keys();
        while(cr.hasMoreElements()){
            String name=(String)cr.nextElement();
        	String[] v = name.split("\\.");
            String value = (String)composedResults.get(name);
            RequestedLabAnalysis.updateValue(Integer.parseInt(v[0]), Integer.parseInt(v[1]), v[2], value);
            RequestedLabAnalysis.setFinalValidation(Integer.parseInt(v[0]), Integer.parseInt(v[1]), Integer.parseInt(activeUser.userid), "'"+v[2]+"'");
        }
    }
    SortedMap requestList = new TreeMap();
    Vector r = LabRequest.findUntreatedRequests(sWebLanguage, Integer.parseInt(activePatient.personid));
    for (int n = 0; n < r.size(); n++) {
        LabRequest labRequest = (LabRequest) r.elementAt(n);
        if (labRequest.getRequestdate() != null) {
            requestList.put(new SimpleDateFormat("yyyyMMddHHmmss").format(labRequest.getRequestdate()) + "." + labRequest.getServerid() + "." + labRequest.getTransactionid(), labRequest);
        }
    }
    SortedMap groups = new TreeMap();
    Iterator iterator = requestList.keySet().iterator();
    while (iterator.hasNext()) {
        LabRequest labRequest = (LabRequest) requestList.get(iterator.next());
        Enumeration enumeration = labRequest.getAnalyses().elements();
        while (enumeration.hasMoreElements()) {
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) enumeration.nextElement();
            if (groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group", requestedLabAnalysis.getLabgroup(), sWebLanguage)) == null) {
                groups.put(MedwanQuery.getInstance().getLabel("labanalysis.group", requestedLabAnalysis.getLabgroup(), sWebLanguage), new Hashtable());
            }
            ((Hashtable) groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group", requestedLabAnalysis.getLabgroup(), sWebLanguage))).put(requestedLabAnalysis.getAnalysisCode(), "1");
        }
    }%>
<%=writeTableHeader("Web", "openPatientLaboResults", sWebLanguage, " doBack();")%><form method='post' name='fastresults'>
    <table width="100%" cellspacing="3">
        <tr>
            <td/>
            <td width="1"/>
            <td><%=getTran("web", "analysis", sWebLanguage)%>
            </td>
            <%
                Iterator requestsIterator = requestList.keySet().iterator();
                while (requestsIterator.hasNext()) {
                    LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
                    out.print("<td>" + ScreenHelper.fullDateFormat.format(labRequest.getRequestdate()) + "&nbsp;&nbsp;&nbsp; &nbsp;<a href='javascript:showRequest(" + labRequest.getServerid() + "," + labRequest.getTransactionid() + ")'><b>" + labRequest.getTransactionid() + "</b></a></td>");
                }
            %>
        </tr>
        <%
            String abnormal = MedwanQuery.getInstance().getConfigString("abnormalModifiers", "*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*");
            boolean bEditable = activeUser.getAccessRight("labos.biologicvalidationbyrequest.edit");
            Iterator groupsIterator = groups.keySet().iterator();
            int i = 0;   // for colors
            while (groupsIterator.hasNext()) {
                i++;
                String groupname = (String) groupsIterator.next();
                Hashtable analysisList = (Hashtable) groups.get(groupname);
                out.print("<tr><td  class='color color" + i + "' rowspan='" + analysisList.size() + "'><b>" + MedwanQuery.getInstance().getLabel("labanalysis.groups", groupname, sWebLanguage).toUpperCase() + "</b></td>");
                SortedSet sortedSet = new TreeSet();
                sortedSet.addAll(analysisList.keySet());
                Iterator analysisEnumeration = sortedSet.iterator();
                while (analysisEnumeration.hasNext()) {
                    String analysisCode = (String) analysisEnumeration.next();
                    String c = analysisCode;
                    String u = "";
                    String refs="";
                    LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisCode);
                    if (analysis != null) {
                        c = analysis.getLabId() + "";
                        refs = analysis.getResultRefMin(activePatient.gender,new Double(activePatient.getAgeInMonths()).intValue())+" - "+analysis.getResultRefMax(activePatient.gender,new Double(activePatient.getAgeInMonths()).intValue());
                        if(refs.equalsIgnoreCase(" - ")){
                        	refs="";
                        }
                        u = " (" + refs+" "+analysis.getUnit() + ")";
                    }
                    out.print("<td class='color color" + i + "'>" + analysisCode + "</td><td class='color color" + i + "' width='*'><b>" + MedwanQuery.getInstance().getLabel("labanalysis", c, sWebLanguage) + " " + u + "</b></td>");
                    requestsIterator = requestList.keySet().iterator();
                    while (requestsIterator.hasNext()) {
                        LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
                        RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis) labRequest.getAnalyses().get(analysisCode);
                        // changed by emanuel@mxs.be
                        String result = "";
                        if(requestedLabAnalysis != null){
	                        if (analysis.getEditor().equals("text")){
								if(bEditable){
									result="<input class='text' type='text' size='"+analysis.getEditorparametersParameter("SZ")+"' maxlength='"+analysis.getEditorparametersParameter("SZ")+"'  name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + checkString(requestedLabAnalysis.getResultValue()) + "'/>" + u;
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
	                        else if (analysis.getEditor().equals("numeric")){
								if(bEditable){
									result="<input onKeyUp=\"if(this.value.length>0 && !isNumber(this)){alert('"+getTranNoLink("web","notnumeric",sWebLanguage)+"');this.value='';}\" class='text' size='"+analysis.getEditorparametersParameter("SZ")+"' maxlength='"+analysis.getEditorparametersParameter("SZ")+"' type='text' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + checkString(requestedLabAnalysis.getResultValue()) + "'/>" + u;
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
	                        else if (analysis.getEditor().equals("numericcomment")){
								if(bEditable){
									result="<input onKeyUp=\"if(this.value.length>0 && !isNumber(this)){alert('"+getTranNoLink("web","notnumeric",sWebLanguage)+"');this.value='';}\" class='text' size='"+analysis.getEditorparametersParameter("SZ")+"' maxlength='"+analysis.getEditorparametersParameter("SZ")+"' type='text' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + checkString(requestedLabAnalysis.getResultValue()) + "'/>" + u;
									result+="<br/><input type='text' name='resultcomment." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
	                        else if (analysis.getEditor().equals("listbox")){
								if(bEditable){
									result="<select class='text' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "'>";
									String[] options = analysis.getEditorparametersParameter("OP").split(",");
									for(int n=0;n<options.length;n++){
										String key=options[n];
										String label=key;
										if(key.split("\\|").length>1){
											label=key.split("\\|")[1];
											key=key.split("\\|")[0];
										}
										result+="<option value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"selected":"")+">"+label+"</option>";
									}
									result+="</select>"+u;
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
	                        else if (analysis.getEditor().equals("listboxcomment")){
								if(bEditable){
									result="<select class='text' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "'>";
									String[] options = analysis.getEditorparametersParameter("OP").split(",");
									for(int n=0;n<options.length;n++){
										String key=options[n];
										String label=key;
										if(key.split("\\|").length>1){
											label=key.split("\\|")[1];
											key=key.split("\\|")[0];
										}
										result+="<option value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"selected":"")+">"+label+"</option>";
									}
									result+="</select>"+u;
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
								result+="<br/><input type='text' name='resultcomment." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
	                        }
	                        else if (analysis.getEditor().equals("radiobutton")){
								if(bEditable){
									String[] options = analysis.getEditorparametersParameter("OP").split(",");
									for(int n=0;n<options.length;n++){
										String key=options[n];
										String label=key;
										if(key.split("\\|").length>1){
											label=key.split("\\|")[1];
											key=key.split("\\|")[0];
										}
										result+="<input type='radio' ondblclick='this.checked=!this.checked' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
									}
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
	                        else if (analysis.getEditor().equals("radiobuttoncomment")){
								if(bEditable){
									String[] options = analysis.getEditorparametersParameter("OP").split(",");
									for(int n=0;n<options.length;n++){
										String key=options[n];
										String label=key;
										if(key.split("\\|").length>1){
											label=key.split("\\|")[1];
											key=key.split("\\|")[0];
										}
										result+="<input type='radio' ondblclick='this.checked=!this.checked' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='"+key+"' "+(key.equals(requestedLabAnalysis.getResultValue())?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
									}
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
								result+="<br/><input type='text' name='resultcomment." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
	                        }
	                        else if (analysis.getEditor().equals("checkbox")){
								if(bEditable){
									String[] options = analysis.getEditorparametersParameter("OP").split(",");
									for(int n=0;n<options.length;n++){
										String key=options[n];
										String label=key;
										if(key.split("\\|").length>1){
											label=key.split("\\|")[1];
											key=key.split("\\|")[0];
										}
										result+="<input type='checkbox' ondblclick='this.checked=!this.checked' name='resultmultiple." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "."+n+ "' value='"+key+"' "+((","+requestedLabAnalysis.getResultValue()+",").contains(","+key+",")?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
									}
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
	                        else if (analysis.getEditor().equals("checkboxcomment")){
								if(bEditable){
									String[] options = analysis.getEditorparametersParameter("OP").split(",");
									for(int n=0;n<options.length;n++){
										String key=options[n];
										String label=key;
										if(key.split("\\|").length>1){
											label=key.split("\\|")[1];
											key=key.split("\\|")[0];
										}
										result+="<input type='checkbox' name='resultmultiple." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "."+n+ "' value='"+key+"' "+((","+requestedLabAnalysis.getResultValue()+",").contains(","+key+",")?"checked":"")+"/>"+(label.trim().length()>0?label:"?")+" ";
									}
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
								result+="<br/><input type='text' name='resultcomment." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()+"' value='"+requestedLabAnalysis.getResultComment()+"' class='text'/>";
	                        }
	                        else if(analysis.getEditor().equals("antibiogram")) {
	                        	result = getComplexResult(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()), sWebLanguage,requestedLabAnalysis.getFinalvalidationdatetime());                        	//result = getComplexResult(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()), sWebLanguage);
	                        }
	                        else {
								if(bEditable){
									result="<input class='text' type='text' name='result." + labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode() + "' value='" + checkString(requestedLabAnalysis.getResultValue()) + "'/>" + u;
								} else {
									result=requestedLabAnalysis.getResultValue();
								}
	                        }
                        }
                        boolean bAbnormal = (result.length() > 0 && !result.equalsIgnoreCase("?") && abnormal.toLowerCase().indexOf("*" + checkString(requestedLabAnalysis.getResultModifier()).toLowerCase() + "*") > -1);
                        out.print("<td   class='color color" + i + "'>" + result + (bAbnormal ? " " + checkString(requestedLabAnalysis.getResultModifier().toUpperCase()) : "") + "</td>");
                    }
                    out.print("</tr>");
                }
            }
        %>
    </table>
    <p/>
    <p style="width:100%;text-align:center;">
        <input class="button" type="submit" name="submit" value="<%=getTran("web","save",sWebLanguage)%>"/>
    </p>
</form>
<script>
    <%
        if(bSaved){
            out.write("closeModalbox('"+ getTranNoLink("web","saved",sWebLanguage)+"');");
        }
    %>
    function showRequest(serverid, transactionid) {
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show." + serverid + "." + transactionid + "=1", "Popup" + new Date().getTime(), "toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
    }
    function doBack() {
        window.location.href = "<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
    openComplexResult = function(id) {
        var params = "antibiogramuid=" + id + "&editable=<%=bEditable%>";
        var url = "<c:url value="/labos/ajax/getComplexResult.jsp" />?ts=" + new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("web","antibiogram",sWebLanguage)%>",params:params,width:600,height:600});
    }
    addObserversToAntibiogram = function(id) {
        $("germ1").value = $F("resultAntibio." + id + ".germ1");
        $("germ2").value = $F("resultAntibio." + id + ".germ2");
        $("germ3").value = $F("resultAntibio." + id + ".germ3");
        setCheckBoxValues(id, $F("resultAntibio." + id + ".antibio1").split(","), 1);
        setCheckBoxValues(id, $F("resultAntibio." + id + ".antibio2").split(","), 2);
        setCheckBoxValues(id, $F("resultAntibio." + id + ".antibio3").split(","), 3);
        $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
            e.parentNode.observe('click', function(event) {
                //alert(Event.element(event));
                var elem = Event.element(event);
                if (elem.tagName == "TD") {
                    if (elem.firstChild.checked) {
                        elem.firstChild.checked = false;
                    } else {
                        elem.firstChild.checked = true;
                        new Effect.Highlight(elem, { startcolor: '#FFE7DA'});
                    }
                } else {
                    new Effect.Highlight(elem.parentNode, { startcolor: '#FFE7DA'});
                }
            });
        });

    }
    setCheckBoxValues = function(id, tab, nb) {
        tab.each(function(anti) {
            if (anti.length > 0) {
                var tAnti = anti.split("=");
                try {
                    $(tAnti[0] + "_radio_" + nb + "_" + tAnti[1]).checked = true;
                } catch(e) {
                    alert(tAnti[0] + "_radio_" + nb + "_" + tAnti[1]);
                }
            }
        });
    }
    setAntibiogram = function (id) {
        var s = "";
        $("resultAntibio." + id + ".germ1").value = $F("germ1");
        $("resultAntibio." + id + ".germ2").value = $F("germ2");
        $("resultAntibio." + id + ".germ3").value = $F("germ3");
        $("resultAntibio." + id + ".antibio1").value = "";
        $("resultAntibio." + id + ".antibio2").value = "";
        $("resultAntibio." + id + ".antibio3").value = "";
        $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
            if (e.checked) {
                s += "\n" + e.name + " -  " + e.value;
                var tab = e.name.split("_");
                $("resultAntibio." + id + ".antibio" + tab[2]).value = $F("resultAntibio." + id + ".antibio" + tab[2]) + "," + tab[0] + "=" + e.value;
            }
        });
        Modalbox.hide();
    }
</script>
