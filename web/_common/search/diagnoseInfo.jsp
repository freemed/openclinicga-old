<%@ page import="java.util.Vector" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.medical.Diagnosis" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sReturnField = checkString(request.getParameter("returnField"));
    String sCode = checkString(request.getParameter("Code"));
    String sValue = checkString(request.getParameter("Value"));
    String sLabel = checkString(request.getParameter("Label"));
    String sType = checkString(request.getParameter("Type"));
    String sPatientUid = checkString(request.getParameter("patientuid"));
    String sServiceUid = checkString(request.getParameter("serviceUid"));
%>
<%=sJSSCRPTACULOUS%>
<form name="diagnoseInfoForm" action="" method="">
    <%=HTMLEntities.htmlentities(writeTableHeader("Web","diagnosegravityandcertainty",sWebLanguage,""))%>
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
                        out.print("<input type='hidden' id='alternativeCode' name='alternativeCode' value='"+alternatives.elementAt(0)+"'/>");
                        out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                    }
                    else if (alternatives.size()>1){
                        out.print("<select class='text' id='alternativeCode' name='alternativeCode' onclick=\"document.all['alternativeCodeLabel'].value=document.all['alternativeCode'].options[document.all['alternativeCode'].selectedIndex].text.substring(document.all['alternativeCode'].options[document.all['alternativeCode'].selectedIndex].text.indexOf(' ')+1);\">");
						out.print("<option vlaue=''></option>");
                        for(int n=0;n<alternatives.size();n++){
                            out.print("<option onclick='setGravity(this.value);' value='"+alternatives.elementAt(n)+"'>"+alternatives.elementAt(n)+" "+ScreenHelper.left(MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(n),sWebLanguage),80)+"</option>");
                        }
                        out.print("</select>");
                        out.print("<input type='hidden' name='alternativeCodeLabel' value='"+MedwanQuery.getInstance().getDiagnosisLabel(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC",(String)alternatives.elementAt(0),sWebLanguage)+"'/>");
                    }
                %>
            </td>
        </tr>
        <!-- certainty -->
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","certainty",sWebLanguage)%> *</td>
            <td class="admin2" style="height:35px;">
              
                <div id="DiagnosisCertainty_slider"  class="slider" style="margin-left:5px;width:560px;">
                    <div id="DiagnosisCertainty_handle" class="handle"><span style="width:30px">500</span></div>
                </div>
                <input type="hidden" name="DiagnosisCertainty" id="DiagnosisCertainty" value="" />
            </td>
        </tr>
        <!-- gravity -->
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("medical.diagnosis","gravity",sWebLanguage))%> *</td>
            <td class="admin2" style="height:35px;">
                 <div id="DiagnosisGravity_slider"  class="slider" style="margin-left:5px;width:560px;">
                    <div id="DiagnosisGravity_handle" class="handle"><span style="width:30px">500</span></div>
                </div>
                <input type="hidden" value="" name="DiagnosisGravity" id="DiagnosisGravity" />
            </td>
        </tr>
        <!-- present on admission -->
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("medical.diagnosis","present.on.admission",sWebLanguage))%></td>
            <td class="admin2">
                <table width="100%"><tr><td><input type="checkbox" name="DiagnosisPresentOnAdmission"/></td></tr></table>
            </td>
        </tr>
        <!-- new case -->
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("medical.diagnosis","newcase",sWebLanguage))%></td>
            <td class="admin2">
            	<table width="100%">
            		<tr>
		            	<%
		            		String checked="checked",altInfo="<table>";
		            		if(sPatientUid.length()>0){
			            		Vector oldKPGS=Diagnosis.getPatientKPGSDiagnosesByICPC(sCode,sType,sPatientUid,sWebLanguage);
			            		if(oldKPGS.size()>0){
			            			checked="";
			            			for(int n=0;n<oldKPGS.size();n++){
			            				altInfo+="<tr><td nowrap>"+((String)oldKPGS.elementAt(n)).split(":")[0]+"</td><td><b>"+((String)oldKPGS.elementAt(n)).split(":")[1]+"</b></td></tr>";
			            				if(n>8){
				            				altInfo+="<tr><td colspan='2'>...</td></tr>";
				            				break;
			            				}
			            			}
			            		}
		            		}
		            		altInfo+="</table>";
		            	%>
		                	<td><input type="checkbox" name="DiagnosisNewCase" <%=checked %>/></td>
		                <%
		                	if(checked.length()==0){
		                %>
							<td><%=altInfo %></td>	
		                <%
		                	}
		                %>
                	</tr>
                </table>
            </td>
        </tr>
        <!-- transfer to problem list -->
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("medical.diagnosis","transfer.problemlist",sWebLanguage))%></td>
            <td class="admin2">
                <table width="100%"><tr><td><input type="checkbox" name="DiagnosisTransferToProblemlist"/></td></tr></table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("web","service",sWebLanguage))%></td>
            <td class="admin2">
                <%
                	Hashtable<String,String> hServices = new Hashtable<String,String>();
                	//Make a list of acceptable services
	            	//1. The active encounter's service
                	Vector<String> services = new Vector<String>();
	            	SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
	                java.util.Date activeDate=new java.util.Date();
	            	TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
	            	String activetransaction="?";
	                if(curTran!=null && curTran.getUpdateTime()!=null){
	                	activetransaction=getTran("web.occup",curTran.getTransactionType(),sWebLanguage);
	                	activeDate=curTran.getUpdateTime();
	                }
	                Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(activeDate.getTime()),activePatient.personid);
					String activeEncParents="",activeService="";
	                if(activeEnc!=null && activeEnc.getService()!=null){
	                	activeEncParents=","+activeEnc.getServiceUID()+","+Service.getParentIds(activeEnc.getServiceUID())+",";
	                	activeService=activeEnc.getService().getLabel(sWebLanguage);
	                	if(hServices.get(activeEnc.getServiceUID())==null){
		            		services.add(activeEnc.getServiceUID()+";"+activeEnc.getService().getLabel(sWebLanguage));
		            		hServices.put(activeEnc.getServiceUID(),"1");
	                	}
	                }
					//2. The user's service
	            	if(activeUser.activeService!=null){
	            		services.add(activeUser.activeService.code+";"+activeUser.activeService.getLabel(sWebLanguage));
	            		hServices.put(activeUser.activeService.code,"1");
	            	}
	                //3. All services the current transactionType is available for
	                boolean bMatch=false;
	                if(curTran!=null && curTran.getTransactionType()!=null){
		                Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		                String sQuery="select distinct a.serviceid from serviceexaminations a,examinations b where a.examinationid=b.id and transactionType=?";
		                PreparedStatement ps = conn.prepareStatement(sQuery);
		                ps.setString(1,curTran.getTransactionType());
		                ResultSet rs = ps.executeQuery();
		                while(rs.next()){
		                	String serviceuid = rs.getString("serviceid");
	                		Service service = Service.getService(serviceuid);
	                		if(service!=null){
			                	if(activeEncParents.indexOf(","+serviceuid+",")>-1){
			                		bMatch=true;
			                	}
			                	if(serviceuid!=null && hServices.get(serviceuid)==null){
				            		services.add(serviceuid+";"+service.getLabel(sWebLanguage));
				            		hServices.put(serviceuid,"1");
		                		}
		                	}
		                }
		                rs.close();
		                ps.close();
		                conn.close();
	                }
	                if(services.size()>0){
	                	out.println("<select name='serviceUid' id='serviceUid' class='text'>");
	                	for(int n=0;n<services.size();n++){
	                		out.println("<option value='"+((String)services.elementAt(n)).split(";")[0]+"'>"+((String)services.elementAt(n)).split(";")[1]+"</option>");
	                	}
	                	out.println("</select>");
	                	if(!bMatch){
	                		out.println("<br/><font color='red'>"+getTran("web","diagnosis.servicemismatch",sWebLanguage).replaceAll("#activeservice#",activeService).replaceAll("#activetransaction#",activetransaction)+"</font>");
	                	}
	                }
                %>
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

	certainty = diagnoseInfoForm.DiagnosisCertainty.value;
    gravity = diagnoseInfoForm.DiagnosisGravity.value;

    if(certainty.length == 0){
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical.diagnosis&labelID=certainty_missing";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical.diagnosis","certainty_missing",sWebLanguage)%>");
    }else if(document.getElementById('alternativeCode') && document.getElementById('alternativeCode').value==''){
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical.diagnosis&labelID=diagnosis_missing";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical.diagnosis","diagnosis_missing",sWebLanguage)+" "+(sType.equalsIgnoreCase("icpc")?"ICD10":"ICPC")%>");
    }else if(gravity.length == 0){
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=medical.diagnosis&labelID=gravity_missing";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("medical.diagnosis","gravity_missing",sWebLanguage)%>");
    }else{
        var POA="",POAComment="", NC="",NCComment="",serviceUid="";
        varMyOpener = window.opener;
        varOpener = varMyOpener.opener;
        varAddon = "("+$F("DiagnosisCertainty")+","+$F("DiagnosisGravity")+")";
        if(diagnoseInfoForm.DiagnosisPresentOnAdmission.checked){
            POA="1";
            POAComment="POA";
        }
        if(diagnoseInfoForm.DiagnosisNewCase.checked){
            NC="1";
            NCComment="N";
        }
        serviceUid=document.getElementById("serviceUid").value;
        if("<%=sType%>" == "ICPC"){
            varOpener.document.getElementById('<%=sReturnField%>').innerHTML+= "<span id='ICPC<%=sCode%>'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' onclick='document.getElementById(\"ICPC<%=sCode%>\").innerHTML=\"\";'/> <input type='hidden' name='ICPCCode<%=sCode%>' value=\"<%=sValue%>  "   + "\"/><input type='hidden' name='GravityICPCCode<%=sCode%>' value=\"" + gravity + "\"/><input type='hidden' name='CertaintyICPCCode<%=sCode%>' value=\"" + certainty + "\"/><input type='hidden' name='POAICPCCode<%=sCode%>' value=\"" + POA + "\"/><input type='hidden' name='NCICPCCode<%=sCode%>' value=\"" + NC + "\"/><input type='hidden' name='ServiceICPCCode<%=sCode%>' value=\"" + serviceUid + "\"/><i><b>ICPC</b></i> <%=sCode%>&nbsp;<%=sLabel%>&nbsp;<%=sValue%>  " + varAddon + " "+POAComment+ " "+NCComment+"<br/></span>";
            if(document.all['alternativeCode']) varOpener.document.getElementById('<%=sReturnField%>').innerHTML+= "<span id='ICD10"+document.all['alternativeCode'].value+"'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' onclick='document.getElementById(\"ICD10"+document.all['alternativeCode'].value+"\").innerHTML=\"\";'/> <input type='hidden' name='ICD10Code"+document.all['alternativeCode'].value+"' value=\"<%=sValue%>  " + "\"/><input type='hidden' name='GravityICD10Code"+document.all['alternativeCode'].value+"' value=\"" + gravity + "\"/><input type='hidden' name='CertaintyICD10Code"+document.all['alternativeCode'].value+"' value=\"" + certainty + "\"/><input type='hidden' name='POAICD10Code"+document.all['alternativeCode'].value+"' value=\"" + POA + "\"/><input type='hidden' name='NCICD10Code"+document.all['alternativeCode'].value+"' value=\"" + NC + "\"/><input type='hidden' name='ServiceICD10Code"+document.all['alternativeCode'].value+"' value=\"" + serviceUid + "\"/><i><b>ICD10</b></i> "+document.all['alternativeCode'].value+"&nbsp;"+document.all['alternativeCodeLabel'].value+"&nbsp;<%=sValue%>  " + varAddon + " "+POAComment+ " "+NCComment+ "<br/></span>";
        }else if("<%=sType%>" == "ICD10"){
            varOpener.document.getElementById('<%=sReturnField%>').innerHTML+= "<span id='ICD10<%=sCode%>'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' onclick='document.getElementById(\"ICD10<%=sCode%>\").innerHTML=\"\";'/> <input type='hidden' name='ICD10Code<%=sCode%>' value=\"<%=sValue%>  " + "\"/><input type='hidden' name='GravityICD10Code<%=sCode%>' value=\"" + gravity + "\"/><input type='hidden' name='CertaintyICD10Code<%=sCode%>' value=\"" + certainty + "\"/><input type='hidden' name='POAICD10Code<%=sCode%>' value=\"" + POA + "\"/><input type='hidden' name='NCICD10Code<%=sCode%>' value=\"" + NC + "\"/><input type='hidden' name='ServiceICD10Code<%=sCode%>' value=\"" + serviceUid + "\"/><i><b>ICD10</b></i> <%=sCode%>&nbsp;<%=sLabel%>&nbsp;<%=sValue%>  " + varAddon + " "+POAComment+ " "+NCComment+ "<br/></span>";
            if(document.all['alternativeCode']) varOpener.document.getElementById('<%=sReturnField%>').innerHTML+= "<span id='ICPC"+document.all['alternativeCode'].value+"'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' onclick='document.getElementById(\"ICPC"+document.all['alternativeCode'].value+"\").innerHTML=\"\";'/> <input type='hidden' name='ICPCCode"+document.all['alternativeCode'].value+"' value=\"<%=sValue%>  "  + "\"/><input type='hidden' name='GravityICPCCode"+document.all['alternativeCode'].value+"' value=\"" + gravity + "\"/><input type='hidden' name='CertaintyICPCCode"+document.all['alternativeCode'].value+"' value=\"" + certainty + "\"/><input type='hidden' name='POAICPCCode"+document.all['alternativeCode'].value+"' value=\"" + POA + "\"/><input type='hidden' name='ServiceICPCCode"+document.all['alternativeCode'].value+"' value=\"" + serviceUid + "\"/><i><b>ICPC</b></i> "+document.all['alternativeCode'].value+"&nbsp;"+document.all['alternativeCodeLabel'].value+"&nbsp;<%=sValue%>  " + varAddon + " "+POAComment+ " "+NCComment+ "<br/></span>";
        }
        if(diagnoseInfoForm.DiagnosisTransferToProblemlist.checked){
            window.open("<c:url value='/'/>_common/search/transferToProblemlist.jsp?codetype=<%=sType%>&code=<%=sCode%>&certainty="+certainty+"&gravity="+gravity+"&patientuid=<%=sPatientUid%>");
        }
        window.close();
    }
  }

	var sliderCertainty,sliderGravity;
  setSliders = function() {

         sliderCertainty = new Control.Slider("DiagnosisCertainty_handle", "DiagnosisCertainty_slider", {
            range: $R(0, 1000),
            sliderValue: 500,
            values:[<%for(int i=0;i<=1000;i=i+5){out.write((i==0)?"0":","+i);}%>],
             onSlide: function(values){
             $("DiagnosisCertainty_handle").firstChild.innerHTML= values;
          },
            onChange: function(value) {
               $("DiagnosisCertainty").value = value;
            }
      });   

       sliderGravity = new Control.Slider("DiagnosisGravity_handle", "DiagnosisGravity_slider", {
          range: $R(0, 1000),
            values:[<%for(int i=0;i<=1000;i=i+5){out.write((i==0)?"0":","+i);}%>],
            sliderValue: 500,
          onSlide: function(values){
             $("DiagnosisGravity_handle").firstChild.innerHTML= values;
          },
            onChange: function(value) {
               $("DiagnosisGravity").value = value;
            }
      });

		//todo: set initial slider value to default for the selected disease      
		sliderCertainty.setValue(500);
		document.getElementById("DiagnosisCertainty_handle").innerHTML='<span style="width:30px">'+500+'</span>';
		<%
			if(alternatives.size()==0){
		%>
		sliderGravity.setValue(500);
		document.getElementById("DiagnosisGravity_handle").innerHTML='<span style="width:30px">'+500+'</span>';
		<%
			}
			else {
		%>
			setGravity('<%=sType.equalsIgnoreCase("ICD10")?sCode:(String)alternatives.elementAt(0)%>');
		<%
			}
		%>


     }
       setSliders();

       function setGravity(code){
			var codetype='ICD10';
		    var url = '<c:url value="/healthrecord/ajax/getDiagnosisGravity.jsp"/>?ts='  + <%=getTs()%>;
		    new Ajax.Request(url, {
		        method: "POST",
		        postBody: 'code=' + code
		                + '&codetype='+codetype,
		        onSuccess: function(resp) {
		    		$("DiagnosisGravity_handle").innerHTML='<span style="width:30px">'+resp.responseText+'</span>';
		            sliderGravity.setValue(resp.responseText);
		        },
		        onFailure: function() {
		        }
		    });
       }
       
       
  
</script>

