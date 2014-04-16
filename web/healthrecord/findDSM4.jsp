<%@page import="be.mxs.common.model.vo.healthrecord.ICPCCode, java.util.Vector"%>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.medical.UserDiagnosis" %>
<%@ page import="be.openclinic.medical.ServiceDiagnosis" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
String sShowPatientEncounters=checkString(request.getParameter("showpatientencounters"));
String sPatientUid=request.getParameter("patientuid");
	if(sPatientUid==null){
		sPatientUid=activePatient.personid;
	}
	
%>
<%=sJSPOPUPSEARCH%> 
<%=sJSCHAR%>
<%-- Start Floating Layer ------------------------------------------------------------------------%>

<%@page import="be.openclinic.medical.UserDiagnosis"%><div id="FloatingLayer" style="position:absolute;width:250px;left:225;top:170;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
              <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>
<%-- End Floating layer --------------------------------------------------------------------------%>
<form name="dsm4Form" method="post" onSubmit="doFind();">
    <table class='menu' width='100%' cellspacing="0">
        <tr>
            <td nowrap><%=HTMLEntities.htmlentities(getTran("Web","Keyword",sWebLanguage))%>&nbsp;&nbsp;</td>
            <td colspan='2'>
                <input type='text' class='text' name='keywords' size='40' value="<%=request.getParameter("keywords")!=null?request.getParameter("keywords"):""%>" onblur="limitLength(this);" onKeyDown='if(event.keyCode==13){doFind();}'/>
                <input class='button' type='button' name='findButton' onclick='doFind();' value='<%=getTran("Web","Find",sWebLanguage)%>'/>
                <input class='button' type='button' name='cancel' onclick='window.close()' value='<%=getTran("Web","Close",sWebLanguage)%>'/>
            </td>
        </tr>
        <tr><td class="navigation_line" height="1" colspan="3"></td></tr>
        <tr><td colspan='3'><span id='info'></span></td></tr>
        <%
            String keywords = checkString(request.getParameter("keywords"));
            int foundRecords = 0;

            // List the found -codes
            if (keywords.length() > 0) {
                Vector codes = MedwanQuery.getInstance().findDSM4Codes(keywords, sWebLanguage);
                ICPCCode code;

                // header
                if (codes.size() > 0) {
                    out.print("<tr class='admin'><td colspan='2'>" + getTran("Web.Occup", "DSM4", sWebLanguage) + " (<a href='javascript:addnewlocalcode(\""+keywords+"\")'>"+getTran("web","managelocalcodes",sWebLanguage)+"</a>)</td><td colspan='1'><a href='javascript:addnewkeyword()'>"+getTran("web","addDSM4code",sWebLanguage)+"</a></td></tr>");
                }

        %><tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'><%
                String oldcodelabel="";
                for (int n=0; n<codes.size(); n++){

                    code = (ICPCCode)codes.elementAt(n);
                    foundRecords++;
                    if(!oldcodelabel.equalsIgnoreCase(code.label)){
                        oldcodelabel=code.label;
                        // parent-codes end with xx00
                        if (code.code.split("\\.").length<2 || (code.code.split("\\.").length==2 && code.code.split("\\.")[1].equalsIgnoreCase("00")) || (code.code.split("\\.").length==2 && code.code.split("\\.")[1].equalsIgnoreCase("0"))){
                            out.print("<tr class='label2'>");
                        }
                        else {
                            out.print("<tr>");
                        }

                        out.print(" <td onclick='addDSM4(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                        out.print(" <td onclick='addDSM4(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
                        out.print(" <td><input type='text' class='text' name='DSM4Comment"+code.code+"' value='-' size='20'/></td>");
                        out.print("</tr>");
                    }
                }

                if (MedwanQuery.getInstance().getConfigInt("enableICD10")==1 || request.getParameter("enableICD10")!=null){
                    // Hier worden de geselecteerde ICD10-codes getoond
                    codes = MedwanQuery.getInstance().findICD10Codes(request.getParameter("keywords"),sWebLanguage);

                    // header
                    if(codes.size() > 0){
                        out.print("<tr class='admin'><td colspan='3'>"+getTran("Web.Occup","ICD-10",sWebLanguage)+"</td></tr>");
                    }

                    for (int n=0; n<codes.size(); n++){

                        code = (ICPCCode)codes.elementAt(n);
    					if("ABCDEFGHIJKLMNOPQRSTUVWXYZ".indexOf(code.code.substring(0,1).toUpperCase())<0){
    						continue;
    					}
                        foundRecords++;
                        if (code.code.length()<=3){
                            out.print("<tr class='label2'>");
                        }
                        else {
                            out.print("<tr>");
                        }

                        out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                        out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");' onmouseover='this.style.cursor=\"hand\"' onmouseout='this.style.cursor=\"default\"'>"+code.label+"</td>");
                        out.print(" <td><input type='text' class='text' name='ICD10Comment"+code.code+"' value='-' size='20'/></td>");
                        out.print("</tr>");
                    }
                }

                %></tbody><%
            }
            else {
                String label = "labelnl";
                if (sWebLanguage.toUpperCase().startsWith("F")) {
                    label = "labelfr";
                }
                if (sWebLanguage.toUpperCase().startsWith("E")) {
                    label = "labelen";
                }
            	Vector diagnoses=UserDiagnosis.selectUserDiagnoses(activeUser.userid,"","","OC_USERDIAGNOSIS_CODETYPE,OC_USERDIAGNOSIS_CODE");
                String oldcodelabel="";
                if (diagnoses.size() > 0) {
                    out.print("<tr class='admin'><td colspan='3'>" + getTran("Web", "manageuserdiagnoses", sWebLanguage) + "</td></tr>");
                }
                %><tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'><%
            	for(int n=0;n<diagnoses.size();n++){
            		UserDiagnosis d = (UserDiagnosis)diagnoses.elementAt(n);
            		if(d.getCodeType().equalsIgnoreCase("dsm4")){
            			ICPCCode code = new ICPCCode(d.getCode(),label,"dsm4");	
                        if(!oldcodelabel.equalsIgnoreCase(code.label)){
                            foundRecords++;
                            oldcodelabel=code.label;
                            // parent-codes end with xx00
	                        if (code.code.split("\\.").length<2 || (code.code.split("\\.").length==2 && code.code.split("\\.")[1].equalsIgnoreCase("00")) || (code.code.split("\\.").length==2 && code.code.split("\\.")[1].equalsIgnoreCase("0"))){
                                out.print("<tr class='label2'>");
                            }
                            else {
                                out.print("<tr>");
                            }

                            out.print(" <td onclick='addDSM4(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                            out.print(" <td onclick='addDSM4(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
                            out.print(" <td><input type='text' class='text' name='DSM4Comment"+code.code+"' value='-' size='20'/></td>");
                            out.print("</tr>");
                        }
            		}
            		else {
            			ICPCCode code = new ICPCCode(d.getCode(),label,"icd10");	
    					if("ABCDEFGHIJKLMNOPQRSTUVWXYZ".indexOf(code.code.substring(0,1).toUpperCase())<0){
    						continue;
    					}
                        foundRecords++;
                        if (code.code.length()<=3){
                            out.print("<tr class='label2'>");
                        }
                        else {
                            out.print("<tr>");
                        }

                        out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                        out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");' onmouseover='this.style.cursor=\"hand\"' onmouseout='this.style.cursor=\"default\"'>"+code.label+"</td>");
                        out.print(" <td><input type='text' class='text' name='ICD10Comment"+code.code+"' value='-' size='20'/></td>");
                        out.print("</tr>");
            		}
            	}
            	diagnoses=ServiceDiagnosis.selectServiceDiagnoses(activeUser.activeService.code,"","","OC_SERVICEDIAGNOSIS_CODETYPE,OC_SERVICEDIAGNOSIS_CODE");
                if (diagnoses.size() > 0) {
                    out.print("<tr class='admin'><td colspan='3'>" + getTran("Web", "manageserverdiagnoses", sWebLanguage) + "</td></tr>");
                }
            	for(int n=0;n<diagnoses.size();n++){
            		ServiceDiagnosis d = (ServiceDiagnosis)diagnoses.elementAt(n);
            		if(d.getCodeType().equalsIgnoreCase("dsm4")){
            			ICPCCode code = new ICPCCode(d.getCode(),label,"dsm4");	
                        if(!oldcodelabel.equalsIgnoreCase(code.label)){
                            foundRecords++;
                            oldcodelabel=code.label;
                            // parent-codes end with xx00
	                        if (code.code.split("\\.").length<2 || (code.code.split("\\.").length==2 && code.code.split("\\.")[1].equalsIgnoreCase("00")) || (code.code.split("\\.").length==2 && code.code.split("\\.")[1].equalsIgnoreCase("0"))){
                                out.print("<tr class='label2'>");
                            }
                            else {
                                out.print("<tr>");
                            }

                            out.print(" <td onclick='addDSM4(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                            out.print(" <td onclick='addDSM4(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
                            out.print(" <td><input type='text' class='text' name='DSM4Comment"+code.code+"' value='-' size='20'/></td>");
                            out.print("</tr>");
                        }
            		}
            		else {
                        foundRecords++;
            			ICPCCode code = new ICPCCode(d.getCode(),label,"icd10");	
                        if (code.code.length()<=3){
                            out.print("<tr class='label2'>");
                        }
                        else {
                            out.print("<tr>");
                        }

                        out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                        out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");' onmouseover='this.style.cursor=\"hand\"' onmouseout='this.style.cursor=\"default\"'>"+code.label+"</td>");
                        out.print(" <td><input type='text' class='text' name='ICD10Comment"+code.code+"' value='-' size='20'/></td>");
                        out.print("</tr>");
            		}
            	}
                %></tbody><%
            }

            if(foundRecords==0 && keywords.length() > 0){
                // display 'no results' message
                %>
                    <tr class="label2">
                                <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%> (<a href='javascript:addnewlocalcode("<%=keywords%>")'><%=getTran("web","managelocalcodes",sWebLanguage) %></a>)</td>
                                <td colspan='3'><a href='javascript:addnewkeyword()'><%=getTran("web","addDSM4code",sWebLanguage) %></a></td>
                    </tr>
                <%
            }
        %>
    </table>
</form>

<%
    String sReturnField = checkString(request.getParameter("returnField"));
    String sReturnField2 = checkString(request.getParameter("returnField2"));

    if (sReturnField.trim().length()==0){
        sReturnField = "dsm4codes";
    }
    else {
        if (sReturnField2.trim().length()==0){
            sReturnField2 = "dsm4codes";
        }
    }
%>

<script>
  window.resizeTo(700,470);
  document.getElementById('info').innerHTML='';

  function doFind(){
    ToggleFloatingLayer('FloatingLayer',1);
    dsm4Form.findButton.disabled = true;
    dsm4Form.submit();
  }

    function addDSM4(code,label){
        if (window.opener.document.getElementById('<%=sReturnField%>').innerHTML.search("DSM4Code"+code)==-1){
            if (document.getElementsByName("DSM4Comment"+code)[0].value.length==0){
                document.getElementsByName("DSM4Comment"+code)[0].value="-";
            }

            if (window.opener.document.getElementById('<%=sReturnField%>').type=="text" || window.opener.document.getElementById('<%=sReturnField%>').type=="textarea"){
                if (window.opener.document.getElementById('<%=sReturnField%>').value.indexOf(code) == -1){
                    if(document.getElementsByName("DSM4Comment"+code)[0].value != "-"){
                        window.opener.document.getElementById('<%=sReturnField%>').value+= (code+" "+label+" ("+document.getElementsByName("DSM4Comment"+code)[0].value+") ");
                    }
                    else{
                        window.opener.document.getElementById('<%=sReturnField%>').value+= (code+" "+label+" ");
                    }
                }
            }
            else{
                openPopup("/_common/search/diagnoseInfoDSM4.jsp&ts=<%=getTs()%>&showpatientencounters=<%=sShowPatientEncounters%>&Type=DSM4&Code="+code+"&Value="+document.getElementsByName('DSM4Comment'+code)[0].value+"&Label="+label+"&returnField=<%=sReturnField%>&returnField2=<%=sReturnField2%>&patientuid=<%=sPatientUid%>",800,600);
            }
        }
        else {
            alert("<%=getTranNoLink("web","code.already.selected",sWebLanguage)%>");
        }

    <%
        if (sReturnField2.trim().length()!=0){
            %>
              if (window.opener.document.getElementById('<%=sReturnField2%>').innerHTML.search("DSM4Code"+code)==-1){
                if (document.getElementsByName("DSM4Comment"+code)[0].value.length==0){
                  document.getElementsByName("DSM4Comment"+code)[0].value="-";
                }

                if ((window.opener.document.getElementById('<%=sReturnField2%>').type=="text")||(window.opener.document.getElementById('<%=sReturnField2%>').type=="textarea")){
                  if (window.opener.document.getElementById('<%=sReturnField2%>').value.indexOf(code)== -1){
                    window.opener.document.getElementById('<%=sReturnField2%>').value += (code+" "+label+" ");
                  }
                }
                else {
                  window.opener.document.getElementById('<%=sReturnField2%>').innerHTML += "<span id='DSM4"+code+"'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' onclick='document.getElementById(\"DSM4"+code+"\").innerHTML=\"\";'/> <input type='hidden' name='DSM4Code"+code+"' value='"+document.getElementsByName("DSM4Comment"+code)[0].value+"'/>"+code+"&nbsp;"+label+"&nbsp;["+document.getElementsByName("DSM4Comment"+code)[0].value+"]<br/></span>";
                }
              }
            <%
        }
    %>
  }

  function addICD10(code,label){
    if (window.opener.document.getElementById('<%=sReturnField%>').innerHTML.search("ICD10Code"+code)==-1){
      if (document.getElementsByName("ICD10Comment"+code)[0].value.length==0){
        document.getElementsByName("ICD10Comment"+code)[0].value="-";
      }

      if ((window.opener.document.getElementById('<%=sReturnField%>').type=="text")||(window.opener.document.getElementById('<%=sReturnField%>').type=="textarea")){
        if (window.opener.document.getElementById('<%=sReturnField%>').value.indexOf(code)== -1){
          window.opener.document.getElementById('<%=sReturnField%>').value += (code+" "+label+" ");
        }
      }
      else {
        openPopup('/_common/search/diagnoseInfoDSM4.jsp&ts=<%=getTs()%>&showpatientencounters=<%=sShowPatientEncounters%>&Type=ICD10&Code='+code+'&Value='+document.getElementsByName("ICD10Comment"+code)[0].value+'&Label='+label+'&returnField=<%=sReturnField%>&returnField2=<%=sReturnField2%>&patientuid=<%=sPatientUid%>',800,600);
      }
    }
    else {
        alert("<%=getTranNoLink("web","code.already.selected",sWebLanguage)%>");
    }

    <%
        if (sReturnField2.trim().length()!=0){
            %>
              if (window.opener.document.getElementById('<%=sReturnField2%>').innerHTML.search("ICD10Code"+code)==-1){
                if (document.getElementsByName("ICD10Comment"+code)[0].value.length==0){
                  document.getElementsByName("ICD10Comment"+code)[0].value="-";
                }

                if ((window.opener.document.getElementById('<%=sReturnField2%>').type=="text")||(window.opener.document.getElementById('<%=sReturnField2%>').type=="textarea")){
                  if (window.opener.document.getElementById('<%=sReturnField2%>').value.indexOf(code)== -1){
                    window.opener.document.getElementById('<%=sReturnField2%>').value += (code+" "+label+" ");
                  }
                }
                else {
                  window.opener.document.getElementById('<%=sReturnField2%>').innerHTML += "<span id='ICD10"+code+"'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' onclick='document.getElementById(\"ICD10"+code+"\").innerHTML=\"\";'/> <input type='hidden' name='ICD10Code"+code+"' value='"+document.getElementsByName("ICD10Comment"+code)[0].value+"'/>"+code+"&nbsp;"+label+"&nbsp;["+document.getElementsByName("ICD10Comment"+code)[0].value+"]<br/></span>";
                }
              }
            <%
        }
    %>
  }
  
  function addnewlocalcode(keywords){
	  	openPopup("/system/manageLocalCodes.jsp&ts=<%=getTs()%>&label<%=sWebLanguage.toLowerCase()%>="+keywords+"&action=edit&type=J&showlist=true",550,350);
	  }

  function addnewkeyword(){
	  	openPopup("/healthrecord/addDsm4Keyword.jsp&ts=<%=getTs()%>",850,350);
	  }

  var focusfield=document.getElementsByName('keywords')[0];
</script>