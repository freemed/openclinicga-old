<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.text.DecimalFormat,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                java.util.*" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String activeEncounterUid="",sRfe="";
	SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
    TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
    ItemVO oldItemVO = curTran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
    if (oldItemVO != null && oldItemVO.getValue().length()>0) {
    	activeEncounterUid = oldItemVO.getValue();
    }
    else {
        Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(curTran.getUpdateTime().getTime()),activePatient.personid);
        if(activeEnc!=null){
        	activeEncounterUid=activeEnc.getUid();
        }
    }
%>
<table class="list" width="100%" cellspacing="1">
    <tr class="admin">
        <td align="center"><a href="javascript:openPopup('healthrecord/findICPC.jsp&PopupWidth=700&PopupHeight=400&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>')"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
    </tr>
    <tr>
        <td id='icpccodes'>
	        <table width='100%'>
			        <%
			         Iterator items = curTran.getItems().iterator();
			         ItemVO item;
			
			         String sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
			         String sReferenceType = "Transaction";
			         Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID, sReferenceType);
			         Hashtable hDiagnosisInfo;
			         String sCode, sGravity, sCertainty,POA,NC,serviceUid,flags;
			
			         while (items.hasNext()) {
			             item = (ItemVO) items.next();
			             if (item.getType().indexOf("ICPCCode") == 0) {
			                 sCode = item.getType().substring("ICPCCode".length(), item.getType().length());
			                 hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
			                 if (hDiagnosisInfo != null) {
			                     sGravity = (String) hDiagnosisInfo.get("Gravity");
			                     sCertainty = (String) hDiagnosisInfo.get("Certainty");
			                     POA = (String) hDiagnosisInfo.get("POA");
			                     NC = (String) hDiagnosisInfo.get("NC");
			                     serviceUid = (String) hDiagnosisInfo.get("ServiceUid");
			                     flags = (String) hDiagnosisInfo.get("Flags");
			                 } else {
			                     sGravity = "";
			                     sCertainty = "";
			                     POA = "";
			                     NC = "";
			                     serviceUid="";
			                     flags="";
			                 }
			     			%><tr id="ICPCCode<%=item.getItemId()%>"><td width="1%" nowrap>
			                         <img src="<c:url value='/_img/icon_delete.gif'/>" onclick="deleteDiagnosis('ICPCCode<%=item.getItemId()%>');"/>
			                         </td><td width="1%">ICPC</td><td width="1%"><b><%=item.getType().replaceAll("ICPCCode","")%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b>
			                         <input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/><input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/><input type='hidden' name='POAICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=POA%>"/><input type='hidden' name='NCICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=NC%>"/><input type='hidden' name='ServiceICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=serviceUid%>"/><input type='hidden' name='FlagsICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=flags%>"/>
			                   </td></tr>
			                 <%
			             }
			             else if (item.getType().indexOf("ICD10Code")==0){
			                 sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
			                 hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
			                 if (hDiagnosisInfo != null) {
			                     sGravity = (String) hDiagnosisInfo.get("Gravity");
			                     sCertainty = (String) hDiagnosisInfo.get("Certainty");
			                     POA = (String) hDiagnosisInfo.get("POA");
			                     NC = (String) hDiagnosisInfo.get("NC");
			                     serviceUid = (String) hDiagnosisInfo.get("ServiceUid");
			                     flags = (String) hDiagnosisInfo.get("Flags");
			                 } else {
			                     sGravity = "";
			                     sCertainty = "";
			                     POA = "";
			                     NC = "";
			                     serviceUid = "";
			                     flags = "";
			                 }
			                 %><tr id='ICD10Code<%=item.getItemId()%>'><td width="1%" nowrap>
			                         <img src='<c:url value="/_img/icon_delete.gif"/>' onclick="deleteDiagnosis('ICD10Code<%=item.getItemId()%>');"/>
			                         </td><td width="1%">ICD10</td><td width="1%"><b><%=item.getType().replaceAll("ICD10Code","")%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b>
			                         <input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/><input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/><input type='hidden' name='POAICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=POA%>"/><input type='hidden' name='NCICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=NC%>"/><input type='hidden' name='ServiceICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=serviceUid%>"/><input type='hidden' name='FlagsICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=flags%>"/>			                   
			                         </td></tr>
			                 <%
			             }
			         }

			        %>
	        </table>
	    </td>
    </tr>
</table>
<table class="list" width="100%" cellspacing="1">
    <tr class="admin">
        <td align="center"><%=getTran("openclinic.chuk","contact.diagnoses",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></td>
    </tr>
    <tr>
        <td>
	        <table width='100%'>
		        <%
		        if(activeEncounterUid.length()>0){
			         items = curTran.getItems().iterator();
			
			         sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
			         sReferenceType = "Transaction";
			         Vector d = Diagnosis.selectDiagnoses("","",activeEncounterUid,"","","","","","","","","","");
		
			         for (int n=0;n<d.size();n++) {
			        	 Diagnosis diag=(Diagnosis)d.elementAt(n);
	                     sGravity = diag.getGravity()+"";
	                     sCertainty = diag.getCertainty()+"";
	                     POA = diag.getPOA();
	                     NC = diag.getNC();
	                     flags = diag.getFlags();
		     		     if (diag.getCodeType().equalsIgnoreCase("icpc")){
			     			%>
		                         <tr><td width="1%">ICPC</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icpccode"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b></td></tr>
			                 <%
			             }
			             else if (diag.getCodeType().equalsIgnoreCase("icd10")){
				     			%>
		                         <tr><td width="1%">ICD10</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b></td></tr>
			                 <%
			             }
			         }
		        }
			     %>
	        </table>
	    </td>
    </tr>
</table>
<script>
  function deleteDiagnosis(itemid){
	  if(yesnoDialog("Web","areYouSureToDelete")){
    	  document.getElementById(itemid).innerHTML='';
      }
  }

  function deleteRFE(serverid,objectid){
	 if(yesnoDialog("Web","areYouSureToDelete")){
          var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=activeEncounterUid%>&language=<%=sWebLanguage%>";
          var today = new Date();
          var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+today;
          new Ajax.Request(url,{
                  method: "GET",
                  parameters: params,
                  onSuccess: function(resp){
                      rfe.innerHTML=resp.responseText;
                  }
              }
          );
      }
  }
</script>
