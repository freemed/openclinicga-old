<%@ page import="be.openclinic.finance.Debet,be.openclinic.adt.Encounter
,be.openclinic.finance.Insurance,be.openclinic.finance.Prestation,java.util.*" %>
<%@ page import="java.util.Date" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.debet","edit",activeUser)%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<%

	String sEditDebetUID = checkString(request.getParameter("EditDebetUID"));
    String sFindDateBegin        = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd        = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin        = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax        = checkString(request.getParameter("FindAmountMax"));

    String sEditEncounterName = "", sEditSupplierName = "";
    Debet debet;

    if (sEditDebetUID.length() > 0) {
        debet = Debet.get(sEditDebetUID);
        Encounter encounter = debet.getEncounter();

        if (encounter != null) {
            sEditEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
        }

        if (debet.getSupplierUid()!=null && debet.getSupplierUid().length()>0){
            sEditSupplierName = getTranNoLink("service",debet.getSupplierUid(),sWebLanguage);
        }
    } else {
        sEditDebetUID = "-1";

        debet = new Debet();
        debet.setQuantity(1);
        debet.setUid(sEditDebetUID);
        debet.setDate(ScreenHelper.getSQLDate(getDate()));
        Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
        if (encounter != null) {
            sEditEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
            debet.setEncounter(encounter);
            debet.setEncounterUid(checkString(encounter.getUid()));
        }
    }

%>
<form name='EditForm' id="EditForm" method='POST'>
    <%=writeTableHeader("web","debetEdit",sWebLanguage,"")%>
    <table class="menu" width="100%" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web.occup","medwan.common.date",sWebLanguage)%></td>
            <td width="100"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td width="150"><%=writeDateField("FindDateBegin","EditForm",sFindDateBegin,sWebLanguage)%></td>
            <td width="100"><%=getTran("Web","end",sWebLanguage)%></td>
            <td><%=writeDateField("FindDateEnd","EditForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web","amount",sWebLanguage)%></td>
            <td><%=getTran("Web","min",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"></td>
            <td><%=getTran("Web","max",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"></td>
        </tr>
        <tr>
            <td/>
            <td colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadUnassignedDebets()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew()">&nbsp;
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("Web","today",sWebLanguage)%>" onclick="document.getElementById('FindDateBegin').value='<%=new SimpleDateFormat("dd/MM/yyyy").format(new Date())%>';loadUnassignedDebets()">&nbsp;
            </td>
        </tr>
    </table>
    <br>
    <div id="divUnassignedDebets" class="searchResults" style="height:120px;"><img src="<c:url value="/_img/ajax-loader.gif"/>"/><br/>Loading</div>
    <input class='text' readonly type='hidden' id='EditAmount' name='EditAmount' value='<%=debet.getAmount()+debet.getExtraInsurarAmount()%>' size='20'>
    <input class='text' readonly type='hidden' id='EditInsurarAmount' name='EditInsurarAmount' value='<%=debet.getInsurarAmount()%>' size='20'> 
    <br>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <tr>
            <td class='admin' width="<%=sTDAdminWidth%>"><%=getTran("Web","date",sWebLanguage)%> *</td>
            <td class='admin2'><%=writeDateField("EditDate","EditForm",ScreenHelper.getSQLDate(debet.getDate()),sWebLanguage)%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web","insurance",sWebLanguage)%> *</td>
            <td class='admin2'>
                <select class="text" id='EditInsuranceUID' name="EditInsuranceUID" onchange="changeInsurance()">
                    <option/>
                    <%

                        Vector vInsurances = Insurance.getCurrentInsurances(activePatient.personid);
                        if (vInsurances!=null){
                            boolean bInsuranceSelected = false;
                            Insurance insurance;

                            for (int i=0;i<vInsurances.size();i++){
                                insurance = (Insurance)vInsurances.elementAt(i);

                                if (insurance!=null && insurance.getInsurar()!=null && insurance.getInsurar().getName()!=null && insurance.getInsurar().getName().trim().length()>0){
                                    out.print("<option value='"+insurance.getUid()+"'");

                                    if (checkString(debet.getInsuranceUid()).equals(insurance.getUid())){
                                        out.print(" selected");
                                        bInsuranceSelected = true;
                                    }
                                    else if (!bInsuranceSelected){
                                        if(vInsurances.size()==1){
                                            out.print(" selected");
                                            bInsuranceSelected = true;
                                        }
                                        else if(insurance.getInsuranceCategory()!=null && insurance.getInsuranceCategory().getInsurarUid()!=null && !insurance.getInsuranceCategory().getInsurarUid().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("patientSelfIsurarUID","none"))){
                                            out.print(" selected");
                                            bInsuranceSelected = true;
                                        }
                                    }

                                    out.print("/>"+insurance.getInsurar().getName()+"</option>");
                                }
                            }
                        }
                    %>
                </select>&nbsp;
                <%=getTran("web","complementarycoverage",sWebLanguage)%>
                <select class="text" name="coverageinsurance" id="coverageinsurance" onchange="changeInsurance();checkCoverage();">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("patientsharecoverageinsurance",checkString(debet.getExtraInsurarUid()),sWebLanguage)%>
                </select>
              </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web","prestation",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="tmpPrestationUID">
                <input type="hidden" name="tmpPrestationName">
                <input type="hidden" name="EditPrestationUID" value="<%=debet.getPrestationUid()%>">

                <select class="text" name="EditPrestationName" id="EditPrestationName" onchange="document.getElementById('EditPrestationGroup').value='';changePrestation(false)">
                    <option/>
                    <%
                        Prestation prestation = debet.getPrestation();

                        if (prestation!=null){
                            out.print("<option selected value='"+checkString(prestation.getUid())+"'>"+checkString(prestation.getDescription())+"</option>");
                        }

                        Vector vPopularPrestations = activeUser.getTopPopularPrestations(10);
                        if (vPopularPrestations!=null){
                            String sPrestationUid;
                            for (int i=0;i<vPopularPrestations.size();i++){
                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
                                if (sPrestationUid.length()>0){
                                    prestation = Prestation.get(sPrestationUid);

                                    if (prestation!=null && prestation.getDescription()!=null && prestation.getDescription().trim().length()>0 && !(debet.getPrestation()!=null && prestation.getUid().equals(debet.getPrestation().getUid()))){
                                        out.print("<option value='"+checkString(prestation.getUid())+"'");

                                        if ((debet.getPrestationUid()!=null)&&(prestation!=null)&&(prestation.getUid()!=null)&&(prestation.getUid().equals(debet.getPrestationUid()))){
                                            out.print(" selected");
                                        }

                                        out.print(">"+checkString(prestation.getDescription())+"</option>");
                                    }
                                }
                            }
                        }
                    %>
                </select>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation();">
				<%=getTran("web","prestationgroups",sWebLanguage) %>
				<select class="text" name="EditPrestationGroup" id="EditPrestationGroup" onchange="document.getElementById('EditPrestationName').value='';changePrestation(false)">
                    <option/>
					<%
						String sSql="select * from oc_prestation_groups order by oc_group_description";
				        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
						PreparedStatement ps=oc_conn.prepareStatement(sSql);
						ResultSet rs = ps.executeQuery();
						while(rs.next()){
							out.println("<option value='"+rs.getInt("oc_group_serverid")+"."+rs.getInt("oc_group_objectid")+"'>"+rs.getString("oc_group_description")+"</option>");
						}
                        rs.close();
                        ps.close();
                        oc_conn.close();
					%>
				</select>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web","quantity",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditQuantity' value='<%=debet.getQuantity()%>' size='4' onkeyup='changePrestation(false);'>
            </td>
        </tr>
        <tr><td colspan='2' class='admin2' id='prestationcontent'>
        <%
        	if(sEditDebetUID.length() > 0 && debet!=null && debet.getPrestation()!=null){
                String prestationcontent ="<table width='100%'>";
                prestationcontent+="<tr><td width='50%'><b>"+getTran("web","prestation",sWebLanguage)+
                "</b></td><td width='25%'><b>"+getTran("web.finance","amount.patient",sWebLanguage)+
                "</b></td><td><b>"+getTran("web.finance","amount.insurar",sWebLanguage)+"</b></td></tr>";
                prestationcontent+="<tr>";
                prestationcontent+="<td><input type='hidden' name='PPC_"+debet.getPrestationUid()+"'/>"+debet.getPrestation().getDescription()+"</td>";
                prestationcontent+="<td "+(debet.getExtraInsurarUid().length()>0?"class='strikeonly'":"")+"><input type='hidden' name='PPP_"+debet.getPrestationUid()+"' value='"+(debet.getAmount()+debet.getExtraInsurarAmount())+"'/>"+(debet.getAmount()+debet.getExtraInsurarAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
                prestationcontent+="<td><input type='hidden' name='PPI_"+debet.getPrestationUid()+"' value='"+debet.getInsurarAmount()+"'/>"+debet.getInsurarAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
                prestationcontent+="</tr>";
                prestationcontent+="</table>";
       			out.print(prestationcontent);
        	}

        %>
        </td></tr>
        <tr>
            <td class='admin'><%=getTran("web","encounter",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="EditEncounterUID" value="<%=debet.getEncounterUid()%>">
                <input class="text" type="text" name="EditEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditEncounterUID','EditEncounterName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditEncounterUID.value='';EditForm.EditEncounterName.value='';">
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web","supplier",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="hidden" name="EditSupplierUID" value="<%=debet.getSupplierUid()%>">
                <input class="text" type="text" name="EditSupplierName" readonly size="<%=sTextWidth%>" value="<%=sEditSupplierName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchSupplier('EditSupplierUID','EditSupplierName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditForm.EditSupplierUID.value='';EditForm.EditSupplierName.value='';">
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web.finance","patientinvoice",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' readonly type='text' name='EditPatientInvoiceUID' value='<%=checkString(debet.getPatientInvoiceUid())%>' size='20'>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web.finance","insurarinvoice",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' readonly type='text' name='EditInsuranceInvoiceUID' value='<%=checkString(debet.getInsurarInvoiceUid())%>' size='20'>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web","comment",sWebLanguage)%></td>
            <td class='admin2'><%=writeTextarea("EditComment","","","",checkString(debet.getComment()))%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web","canceled",sWebLanguage)%></td>
            <td class='admin2'><input type="checkbox" name="EditCredit" <%if (debet.getCredited()>0){out.print(" checked");}%> onclick="doCredit()"></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class='button' type="button" name="buttonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            </td>
        </tr>
    </table>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>.
    <div id="divMessage" name="divMessage"></div>
    <input type='hidden' id="EditDebetUID" name='EditDebetUID' value='<%=sEditDebetUID%>'>
</form>
<script>

	function changePrestation(bFirst){
      if (EditForm.EditPrestationName.value.length==0 && EditForm.EditPrestationGroup.value.length==0){
          EditForm.EditPrestationName.style.backgroundColor='#D1B589';
          document.getElementById('prestationcontent').innerHTML='';
      }
      else {
            
          EditForm.EditPrestationName.style.backgroundColor='white';
          if (!bFirst){
              document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Calculating";
              var today = new Date();
              var url= '<c:url value="/financial/getPrestationAmount2.jsp"/>?ts='+today;
              new Ajax.Request(url,{
                      method: "POST",
                      postBody: 'PrestationUID=' + EditForm.EditPrestationName.value +
	                      '&PrestationGroupUID=' + EditForm.EditPrestationGroup.value+
	                      '&CoverageInsurance=' + EditForm.coverageinsurance.value+
	                      '&EditQuantity=' + EditForm.EditQuantity.value,
                      onSuccess: function(resp){
                          $('divMessage').innerHTML = "";
                          var label = eval('('+resp.responseText+')');
                          $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
                          $('EditInsurarAmount').value=label.EditInsurarAmount;
                          $('EditInsuranceUID').value=label.EditInsuranceUID;
                          document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
                      },
                      onFailure: function(){
                          $('divMessage').innerHTML = "Error in function changePrestation() => AJAX";
                      }
                  }
              );
          }
      }

      EditForm.EditPrestationUID.value = EditForm.EditPrestationName.value;
  }

  function changeInsurance(){
      if (EditForm.EditInsuranceUID.selectedIndex > 0){
          var today = new Date();
          var url= '<c:url value="/financial/getPrestationAmount2.jsp"/>?ts='+today;

          new Ajax.Request(url,{
                  method: "POST",
                  postBody: 'PrestationUID=' + EditForm.EditPrestationName.value
	                +'&CoverageInsurance=' + EditForm.coverageinsurance.value
                    +'&EditInsuranceUID=' + EditForm.EditInsuranceUID.value
                    +'&EditQuantity=' + EditForm.EditQuantity.value,
                  onSuccess: function(resp){
                      var label = eval('('+resp.responseText+')');
                      $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
                      $('EditInsurarAmount').value=label.EditInsurarAmount*EditForm.EditQuantity.value;
                      document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
                  },
                  onFailure: function(){
                      $('divMessage').innerHTML = "Error in function changeInsurance() => AJAX";
                  }
              }
          );
      }

      EditForm.EditPrestationUID.value = EditForm.EditPrestationName.value;
  }

  function doSave(){
      if((EditForm.EditDate.value.length>0)
          &&(EditForm.EditInsuranceUID.value.length>0)
          &&(EditForm.EditPrestationUID.value.length>0 || EditForm.EditPrestationGroup.value.length>0)
          &&(EditForm.EditEncounterUID.value!="null" && EditForm.EditEncounterUID.value.length>0)){
          var sCredited = "0";
          var today = new Date();
          if (EditForm.EditCredit.checked){
              sCredited = "1";
          }
          var url= '<c:url value="/financial/debetSave2.jsp"/>?ts='+today;
          document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
		  var prests="";
          pars=document.all;
          for(n=0;n<document.all.length;n++){
              if(document.all[n].name && document.all[n].name.indexOf("PP")>-1){
              	prests+="&"+document.all[n].name+"="+document.all[n].value;
              }
          }
          new Ajax.Request(url,{
                  method: "POST",
                  postBody: 'EditDate=' + EditForm.EditDate.value
                          +'&EditDebetUID=' + EditForm.EditDebetUID.value
                          +'&EditInsuranceUID=' + EditForm.EditInsuranceUID.value
                          +'&EditPrestationUID=' + EditForm.EditPrestationUID.value
                          +'&EditPrestationGroupUID=' + EditForm.EditPrestationGroup.value
                          +'&EditAmount=' + EditForm.EditAmount.value
                          +'&EditInsurarAmount=' + EditForm.EditInsurarAmount.value
                          +'&EditEncounterUID=' + EditForm.EditEncounterUID.value
                          +'&EditSupplierUID=' + EditForm.EditSupplierUID.value
                          +'&EditPatientInvoiceUID=' + EditForm.EditPatientInvoiceUID.value
                          +'&EditInsuranceInvoiceUID=' + EditForm.EditInsuranceInvoiceUID.value
                          +'&EditComment=' + EditForm.EditComment.value
                          +'&EditQuantity=' + EditForm.EditQuantity.value
                          +'&EditExtraInsurarUID=' + EditForm.coverageinsurance.value
                          +'&EditCredit=' + sCredited
                          + prests,
                  onSuccess: function(resp){
                      var label = eval('('+resp.responseText+')');
                      $('divMessage').innerHTML=label.Message;
                      $('EditDebetUID').value=label.EditDebetUID;
                      doNew();
                      loadUnassignedDebets();
                  },
                  onFailure: function(){
                      $('divMessage').innerHTML = "Error in function doSave() => AJAX";
                  }
              }
          );
      }
      else {
          var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
      }
  }

  function searchEncounter(encounterUidField,encounterNameField){
      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&FindEncounterPatient=<%=activePatient.personid%>");
  }

    function searchSupplier(supplierUidField,supplierNameField){
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+supplierUidField+"&VarText="+supplierNameField);
    }

    function searchPrestation(){
    	document.getElementById('EditPrestationGroup').value='';
        EditForm.tmpPrestationName.value = "";
        EditForm.tmpPrestationUID.value = "";
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=tmpPrestationUID&ReturnFieldDescr=tmpPrestationName&doFunction=changeTmpPrestation()");
    }

    function doCredit(){
        if (EditForm.EditCredit.checked){
            EditForm.EditAmount.value = "0";
            EditForm.EditInsurarAmount.value = "0";
        }
    }

    function changeTmpPrestation(){
        if (EditForm.tmpPrestationUID.value.length>0){
            EditForm.EditPrestationUID.value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[0].text = EditForm.tmpPrestationName.value;
            EditForm.EditPrestationName.options[0].value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[0].selected = true;
            changePrestation(false);
        }
    }

    function doNew(){
        EditForm.EditDebetUID.value = "";
        EditForm.EditPrestationUID.value = "";
        EditForm.EditPrestationGroup.selectedIndex=-1;
        EditForm.EditPrestationName.selectedIndex = -1;
        document.getElementById('prestationcontent').innerHTML='';
        EditForm.EditAmount.value = "";
        EditForm.EditInsurarAmount.value = "";
        EditForm.EditComment.value = "";
        EditForm.EditCredit.checked = false;
        EditForm.EditPatientInvoiceUID.value = "";
        EditForm.EditInsuranceInvoiceUID.value = "";
        EditForm.EditSupplierUID.value = "";
        EditForm.EditSupplierName.value = "";
        EditForm.EditQuantity.value = "1";
        EditForm.buttonSave.disabled=false;

        changePrestation(true);
//        loadUnassignedDebets();
    }

    function setDebet(sUid){
        EditForm.EditDebetUID.value = sUid;
        EditForm.submit();
    }

    function loadUnassignedDebets(){
        document.getElementById('divUnassignedDebets').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
        var params = 'FindDateBegin=' + EditForm.FindDateBegin.value
              +"&FindDateEnd="+EditForm.FindDateEnd.value
              +"&FindAmountMin="+EditForm.FindAmountMin.value
              +"&FindAmountMax="+EditForm.FindAmountMax.value;
        var today = new Date();
        var url= '<c:url value="/financial/debetGetUnassignedDebets.jsp"/>?ts='+today;
		new Ajax.Request(url,{
				method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    $('divUnassignedDebets').innerHTML=resp.responseText;
                },
				onFailure: function(){
                }
			}
		);
    }

    function clearFindFields(){
        EditForm.FindDateBegin.value = "";
        EditForm.FindDateEnd.value = "";
        EditForm.FindAmountMin.value = "";
        EditForm.FindAmountMax.value = "";
    }

    function checkCoverage(){
        if(document.getElementById("coverageinsurance").selectedIndex>0){
            document.getElementById("EditAmount").style.textDecoration="line-through";
        }
        else {
            document.getElementById("EditAmount").style.textDecoration="";
        }
    }

    checkCoverage();
    EditForm.EditDate.focus();
    changePrestation(true);
    loadUnassignedDebets();
</script>