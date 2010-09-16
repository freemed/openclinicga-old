<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCode = checkString(request.getParameter("Code"));
    String sLabel = checkString(request.getParameter("Label"));
    String sType = checkString(request.getParameter("Type"));
    String flags = ReasonForEncounter.getFlags(sType,sCode);
%>
<form name="RFEInfoForm" id="RFEInfoForm" action="" method="">
    <%=writeTableHeader("Web","diagnosegravityandcertainty",sWebLanguage,"")%>
    <table class="list" width="100%" cellspacing="1">
        <!-- Diagnose code -->
        <tr>
            <td class="admin" nowrap><%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%> *</td>
            <td class="admin2"><%=sCode%></td>
        </tr>
        <!-- Diagnose label-->
        <tr>
            <td class="admin"><%=sType%></td>
            <td class="admin2"><%=sLabel%></td>
        </tr>
        <!-- Diagnose label, equivalent-->
        <tr>
            <td class="admin"><%=sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC"%></td>
            <td class="admin2">
                <%
                    String sFindCode=sCode;
                    if(sType.equalsIgnoreCase("icpc")){
                        sFindCode=sCode.substring(0,3);
                    }
                    Vector alternatives = MedwanQuery.getInstance().getAlternativeDiagnosisCodes(sType,sFindCode);
                    if(alternatives.size()==1){
                        out.print(alternatives.elementAt(0)+" "+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage));
                        flags=ReasonForEncounter.getFlags(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),flags);
                        out.print("<input type='hidden' name='alternativeCode' id='alternativeCode' value='"+alternatives.elementAt(0)+"'/>");
                        out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                    }
                    else if (alternatives.size()>1){
                        out.print("<select class='text' name='alternativeCode' id='alternativeCode' onclick=\"document.all['alternativeCodeLabel'].value=document.all['alternativeCode'].options[document.all['alternativeCode'].selectedIndex].text.substring(document.all['alternativeCode'].options[document.all['alternativeCode'].selectedIndex].text.indexOf(' ')+1);\">");
                        for(int n=0;n<alternatives.size();n++){
                            out.print("<option value='"+alternatives.elementAt(n)+"'>"+alternatives.elementAt(n)+" "+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(n),sWebLanguage)+"</option>");
                            flags=ReasonForEncounter.getFlags(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(n),flags);
                        }
                        out.print("</select>");
                        out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                    }
                %>
            </td>
        </tr>
        <%
            if(flags.indexOf("C")>-1){
        %>
            <!-- confirmed -->
            <tr>
                <td class="admin"><%=getTran("medical.diagnosis","confirmed",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="confirmed" id="confirmed" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                    <input type="radio" name="confirmed" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("D")>-1){
        %>
            <!-- digestif -->
            <tr>
                <td class="admin"><%=getTran("medical.diagnosis","digestive.problems",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="digestive" id="digestive" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                    <input type="radio" name="digestive" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("E")>-1 && !activePatient.gender.equalsIgnoreCase("m") && activePatient.getAge()>14 && activePatient.getAge()<50){
        %>
            <!-- pregnant -->
            <tr>
                <td class="admin"><%=getTran("medical.diagnosis","pregnant",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="pregnant" id="pregnant" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                    <input type="radio" name="pregnant" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("B")>-1){
        %>
            <!-- bloody -->
            <tr>
                <td class="admin"><%=getTran("medical.diagnosis","bloody",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="bloody" id="bloody" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                    <input type="radio" name="bloody" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("R")>-1){
        %>
            <!-- chronic -->
            <tr>
                <td class="admin"><%=getTran("medical.diagnosis","chronic",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="chronic" id="chronic" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                    <input type="radio" name="chronic" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
            if(flags.indexOf("V")>-1){
        %>
            <!-- vaccination -->
            <tr>
                <td class="admin"><%=getTran("medical.diagnosis","vaccination",sWebLanguage)%> *</td>
                <td class="admin2">
                    <input type="radio" name="vaccination" id="vaccination" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                    <input type="radio" name="vaccination" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
                </td>
            </tr>
        <%
            }
        %>
        <!-- newcase -->
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","newcase",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="radio" name="newcase" id="newcase" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                <input type="radio" name="newcase" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
            </td>
        </tr>
        <!-- planned -->
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","planned",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="radio" name="planned" id="planned" value="medwan.common.true"/><%=getTran("web","yes",sWebLanguage)%>
                <input type="radio" name="planned" value="medwan.common.false"/><%=getTran("web","no",sWebLanguage)%>
            </td>
        </tr>
        <!-- transfer to problem list -->
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","transfer.problemlist",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" name="DiagnosisTransferToProblemlist"/>
            </td>
        </tr>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="EditAddButton" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="doAdd();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
</form>
<script>
    function doAdd(){
        var flags="";
        if(document.getElementById('newcase') && document.getElementById('newcase').checked){
            flags+="N";
        }
        else {
            flags+="n";
        }
        if(document.getElementById('digestive') && document.getElementById('digestive').checked){
            flags+="D";
        }
        else {
            flags+="d";
        }
        if(document.getElementById('bloody') && document.getElementById('bloody').checked){
            flags+="B";
        }
        else {
            flags+="b";
        }
        if(document.getElementById('chronic') && document.getElementById('chronic').checked){
            flags+="R";
        }
        else {
            flags+="r";
        }
        if(document.getElementById('planned') && document.getElementById('planned').checked){
            flags+="P";
        }
        else {
            flags+="p";
        }
        if(document.getElementById('vaccination') && document.getElementById('vaccination').checked){
            flags+="V";
        }
        else {
            flags+="v";
        }
        if(document.getElementById('confirmed') && document.getElementById('confirmed').checked){
            flags+="C";
        }
        else {
            flags+="c";
        }
        if(document.getElementById('pregnant') && document.getElementById('pregnant').checked){
            flags+="E";
        }
        else {
            flags+="e";
        }
        //Now we have to save the reason for encounter
        saveRFE(flags);
    }

    function saveRFE(flags){
        alt='';
        if(document.getElementById("alternativeCode")){
            alt=document.getElementById("alternativeCode").value;
        }
        var params = "encounterUid=<%=ScreenHelper.checkString(request.getParameter("encounterUid"))%>"+
                     "&trandate=<%=ScreenHelper.checkString(request.getParameter("trandate"))%>"+
                     "&codeType=<%=sType%>"+
                     "&code=<%=sCode%>"+
                     "&alternativeCodeType=<%=sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC"%>"+
                     "&alternativeCode="+alt+
                     "&language=<%=sWebLanguage%>"+
                     "&flags="+flags+
                     "&userUid=<%=activeUser.userid%>";
        var today = new Date();
        var url= '<c:url value="/healthrecord/storeRFE.jsp"/>?ts='+today;
		new Ajax.Request(url,{
				method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    window.opener.opener.document.getElementById('<%=ScreenHelper.checkString(request.getParameter("field"))%>').innerHTML=resp.responseText;
                    window.opener.close();
                    window.close();
                },
				onFailure: function(){
                }
			}
		);
    }
</script>

