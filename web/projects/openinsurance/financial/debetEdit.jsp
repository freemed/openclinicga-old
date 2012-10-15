<%@ page import="be.openclinic.adt.Encounter,be.openclinic.finance.Insurance,be.openclinic.finance.*,java.util.*" %>
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

    String sEditEncounterName = "", sEditSupplierName = "", sActiveEncounterDate="";
    PrestationDebet debet;

    Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
    if (encounter != null) {
    	sActiveEncounterDate=new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin());
    }
    
    if (sEditDebetUID.length() > 0) {
        debet = PrestationDebet.get(sEditDebetUID);
        Encounter debetencounter = debet.getEncounter();

        if (debetencounter != null) {
            sEditEncounterName = debetencounter.getEncounterDisplayNameService(sWebLanguage);
        }

    } else {
        sEditDebetUID = "-1";

        debet = new PrestationDebet();
        debet.setQuantity(1);
        debet.setUid(sEditDebetUID);
        debet.setDate(ScreenHelper.getSQLDate(getDate()));
        if (encounter != null) {
            debet.setDate(encounter.getBegin());
            sEditEncounterName = encounter.getEncounterDisplayNameService(sWebLanguage);
            debet.setEncounter(encounter);
            debet.setEncounterUid(checkString(encounter.getUid()));
        }
    }
	if(sActiveEncounterDate.length()==0){
		sActiveEncounterDate=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
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
                <input type="button" class="button" name="ButtonToday" value="<%=getTranNoLink("Web","today",sWebLanguage)%>" onclick="document.getElementById('FindDateBegin').value='<%=new SimpleDateFormat("dd/MM/yyyy").format(new Date())%>';loadUnassignedDebets()">&nbsp;
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
            <%
        		System.out.println("0");
            	Insurance ins = Insurance.getMostInterestingInsuranceForPatient(activePatient.personid);
                java.util.Date dValidity=Debet.getContributionValidity(ins!=null?ins.getMember():activePatient.personid);
           		String sValidity=getTran("web","none",sWebLanguage);
           		if(dValidity!=null){
           			sValidity=new SimpleDateFormat("dd/MM/yyyy").format(dValidity);
           		}
            	System.out.println("0.1");
            %>
            <td bgcolor="<%=dValidity==null || dValidity.before(new java.util.Date())?"red":"lightgreen" %>">
                <select class="text" id='EditInsuranceUID' name="EditInsuranceUID" onchange="changeInsurance()">
                    <%

                    //Find the applicable coverage plan based on active patient contributions
                    String sBestInsurance=Insurance.getBestActiveCoveragePlan(ins!=null?ins.getMember():activePatient.personid);
                    System.out.println("sBestInsurance="+sBestInsurance);
                    if(sBestInsurance!=null && sBestInsurance.length()>0){
                    	out.print("<option value='"+sBestInsurance+"'");
                        out.print("/>"+Insurar.get(sBestInsurance.split(";")[0]).getName()+" - "+sBestInsurance.split(";")[1]+"</option>");
                    }
                	System.out.println("0.2");

                    %>
                </select>&nbsp;<%=getTran("web","validity",sWebLanguage)%>: <%=sValidity %>
            </td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("web","prestation",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="tmpPrestationUID"/>
                <input type="hidden" name="tmpPrestationName"/>
                <input type="hidden" name="tmpPrestationPrice"/>
                <input type="hidden" name="EditPrestationUID" value="<%=debet.getPrestationUid()%>"/>

                <select class="text" name="EditPrestationName" id="EditPrestationName" onchange="changePrestation(false)">
                    <option/>
                    <%
                        Prestation prestation = debet.getPrestation();

                        if (prestation!=null){
                            out.print("<option selected value='"+checkString(prestation.getUid())+"'>"+checkString(prestation.getDescription())+"</option>");
                        }
                    	System.out.println("0.3");

                        Vector vPopularPrestations = activeUser.getTopPopularPrestations(10);
                    	System.out.println("0.3.1");
                        if (vPopularPrestations!=null){
                            String sPrestationUid;
                            for (int i=0;i<vPopularPrestations.size();i++){
                            	System.out.println("0.3.2");
                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
                                if (sPrestationUid.length()>0){
                                	System.out.println("0.3.3");
                                    prestation = Prestation.get(sPrestationUid);
                                	System.out.println("0.3.3a: "+prestation);
                                	System.out.println("0.3.3b: "+debet.getPrestation());
                                	System.out.println("0.3.3c: "+prestation.getType());
                                	System.out.println("0.3.3d: "+prestation.getDescription());
                                	System.out.println("0.3.3e: "+prestation.getUid());

                                    if (prestation!=null && prestation.getType()!=null && !prestation.getType().equalsIgnoreCase("con.openinsurance") && prestation.getDescription()!=null && prestation.getDescription().trim().length()>0 && !(debet!=null && debet.getPrestation()!=null && prestation.getUid().equals(debet.getPrestation().getUid()))){
                                    	System.out.println("0.3.4");
                                        out.print("<option value='"+checkString(prestation.getUid())+"'");

                                        if ((debet.getPrestationUid()!=null)&&(prestation!=null)&&(prestation.getUid()!=null)&&(prestation.getUid().equals(debet.getPrestationUid()))){
                                            out.print(" selected");
                                        }

                                        out.print(">"+checkString(prestation.getDescription())+"</option>");
                                    }
                                	System.out.println("0.3.5");
                                }
                            }
                        }
                    	System.out.println("0.4");
                    %>
                </select>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation();">
				&nbsp;
				<a href="javascript:openQuicklist();"><%=getTran("web","quicklist",sWebLanguage)%></a>
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
        	System.out.println("1");
        	if(sEditDebetUID.length() > 0 && debet!=null && debet.getPrestation()!=null){
                String prestationcontent ="<table width='100%'>";
                prestationcontent+="<tr><td width='50%'><b>"+getTran("web","prestation",sWebLanguage)+
                "</b></td><td width='25%'><b>"+getTran("web.finance","amount.patient",sWebLanguage)+
                "</b></td><td><b>"+getTran("web.finance","amount.insurar",sWebLanguage)+"</b></td></tr>";
                prestationcontent+="<tr>";
                prestationcontent+="<td><input type='hidden' name='PPC_"+debet.getPrestationUid()+"'/>"+debet.getPrestation().getDescription()+"</td>";
                prestationcontent+="<td "+(debet.getExtraInsurarUid()!=null && debet.getExtraInsurarUid().length()>0?"class='strikeonly'":"")+"><input type='hidden' name='PPP_"+debet.getPrestationUid()+"' value='"+(debet.getAmount()+debet.getExtraInsurarAmount())+"'/>"+(debet.getAmount()+debet.getExtraInsurarAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>";
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
            <td class='admin'><%=getTran("web.finance","paymentorder",sWebLanguage)%></td>
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
	function changeQuicklistPrestations(prestations){
        EditForm.EditPrestationName.style.backgroundColor='white';
        document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Calculating";
        var today = new Date();
        var url= '<c:url value="/financial/getOIPrestationAmount2.jsp"/>?ts='+today;
        new Ajax.Request(url,{
                method: "POST",
                postBody: 'PrestationUIDs=' + prestations +
	                '&EditInsuranceUID=' + EditForm.EditInsuranceUID.value+
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
        EditForm.EditPrestationUID.value = EditForm.EditPrestationName.value;
	}
	
	function changePrestation(bFirst){
	      if (EditForm.EditPrestationName.value.length==0){
	          EditForm.EditPrestationName.style.backgroundColor='#D1B589';
	          document.getElementById('prestationcontent').innerHTML='';
	      }
	      else {
	          EditForm.EditPrestationName.style.backgroundColor='white';
	          if (!bFirst){
	              document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Calculating";
	              var today = new Date();
	              var url= '<c:url value="/financial/getOIPrestationAmount2.jsp"/>?ts='+today;
	              new Ajax.Request(url,{
	                      method: "POST",
	                      postBody: 'PrestationUID=' + EditForm.EditPrestationName.value +
		                      '&EditInsuranceUID=' + EditForm.EditInsuranceUID.value+
		                      '&EditQuantity=' + EditForm.EditQuantity.value,
	                      onSuccess: function(resp){
	                          $('divMessage').innerHTML = "";
	                          var label = eval('('+resp.responseText+')');
	                          $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
	                          $('EditInsurarAmount').value=label.EditInsurarAmount;
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

	function changePrestationVariable(bFirst){
	      if (EditForm.EditPrestationName.value.length==0){
	          EditForm.EditPrestationName.style.backgroundColor='#D1B589';
	          document.getElementById('prestationcontent').innerHTML='';
	      }
	      else {
	          EditForm.EditPrestationName.style.backgroundColor='white';
	          if (!bFirst){
	              document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Calculating";
	              var today = new Date();
	              var url= '<c:url value="/financial/getOIPrestationAmount2.jsp"/>?ts='+today;
	              new Ajax.Request(url,{
	                      method: "POST",
	                      postBody: 'PrestationUID=' + EditForm.EditPrestationName.value +
		                      '&EditPrice=' + EditForm.tmpPrestationPrice.value+
		                      '&EditInsuranceUID=' + EditForm.EditInsuranceUID.value+
		                      '&EditQuantity=' + EditForm.EditQuantity.value,
	                      onSuccess: function(resp){
	                          $('divMessage').innerHTML = "";
	                          var label = eval('('+resp.responseText+')');
	                          $('EditAmount').value=label.EditAmount*EditForm.EditQuantity.value;
	                          $('EditInsurarAmount').value=label.EditInsurarAmount;
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
          var url= '<c:url value="/financial/getOIPrestationAmount2.jsp"/>?ts='+today;

          new Ajax.Request(url,{
                  method: "POST",
                  postBody: 'PrestationUID=' + EditForm.EditPrestationName.value
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
          &&(EditForm.EditPrestationUID.value.length>0 || document.getElementById('prestationcontent').innerHTML.trim().length>0)
          &&(EditForm.EditEncounterUID.value!="null" && EditForm.EditEncounterUID.value.length>0)){
          var sCredited = "0";
          var today = new Date();
          if (EditForm.EditCredit.checked){
              sCredited = "1";
          }
          var url= '<c:url value="/financial/prestationDebetSave2.jsp"/>?ts='+today;
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
                          +'&EditAmount=' + EditForm.EditAmount.value
                          +'&EditInsurarAmount=' + EditForm.EditInsurarAmount.value
                          +'&EditEncounterUID=' + EditForm.EditEncounterUID.value
                          +'&EditInsuranceInvoiceUID=' + EditForm.EditInsuranceInvoiceUID.value
                          +'&EditComment=' + EditForm.EditComment.value
                          +'&EditQuantity=' + EditForm.EditQuantity.value
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

	function openQuicklist(){
	    openPopup("/financial/quicklist.jsp&ts=<%=getTs()%>&EditInsuranceUID=&PopupHeight=600&PopupWidth=800");
	}
	
  	function searchEncounter(encounterUidField,encounterNameField){
	    openPopup("/_common/search/searchPrestationEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&FindEncounterPatient=<%=activePatient.personid%>");
	}

    function searchSupplier(supplierUidField,supplierNameField){
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+supplierUidField+"&VarText="+supplierNameField);
    }

    function searchPrestation(){
        EditForm.tmpPrestationName.value = "";
        EditForm.tmpPrestationUID.value = "";
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=tmpPrestationUID&ReturnFieldDescr=tmpPrestationName&ReturnFieldPrice=tmpPrestationPrice&doFunction=changeTmpPrestation()&doFunctionVariable=changeTmpPrestationVariable()");
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

    function changeTmpPrestationVariable(){
        if (EditForm.tmpPrestationUID.value.length>0){
            EditForm.EditPrestationUID.value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[0].text = EditForm.tmpPrestationName.value;
            EditForm.EditPrestationName.options[0].value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[0].selected = true;
            changePrestationVariable(false);
        }
    }

    function doNew(){
    	EditForm.EditDebetUID.value = "";
    	EditForm.EditDate.value="<%=sActiveEncounterDate%>";
        EditForm.EditPrestationUID.value = "";
        EditForm.EditPrestationName.selectedIndex = -1;
        document.getElementById('prestationcontent').innerHTML='';
        EditForm.EditAmount.value = "";
        EditForm.EditInsurarAmount.value = "";
        EditForm.EditComment.value = "";
        EditForm.EditCredit.checked = false;
        EditForm.EditInsuranceInvoiceUID.value = "";
        EditForm.EditQuantity.value = "1";
        EditForm.buttonSave.disabled=false;
        changePrestation(true);
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
        var url= '<c:url value="/financial/prestationDebetGetUnassignedDebets.jsp"/>?ts='+today;
		new Ajax.Request(url,{
				method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    $('divUnassignedDebets').innerHTML=resp.responseText;
                },
				onFailure: function(){
                    $('divUnassignedDebets').innerHTML=" Error in Ajax";
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

    EditForm.EditDate.focus();
    changePrestation(true);
    loadUnassignedDebets();
</script>