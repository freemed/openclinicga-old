<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.text.DecimalFormat,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                be.openclinic.finance.*,
                java.util.*"%>
<%@page import="be.openclinic.medical.PaperPrescription"%>
<%@page import="be.openclinic.medical.ReasonForEncounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String activeEncounterUid = "", sRfe = "";
	SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
    
    ItemVO oldItemVO = curTran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
    if(oldItemVO!=null && oldItemVO.getValue().length()>0){
    	activeEncounterUid = oldItemVO.getValue();
    }
    else{
        Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(curTran.getUpdateTime().getTime()),activePatient.personid);
        if(activeEnc!=null){
        	activeEncounterUid = activeEnc.getUid();
        }
    }
    
    if(activeEncounterUid.length()>0){
        sRfe = ReasonForEncounter.getReasonsForEncounterAsHtml(activeEncounterUid,sWebLanguage,sCONTEXTPATH+"/_img/icons/icon_delete.gif","deleteRFE($serverid,$objectid)");
		
		%>
			<table class="list" width="100%" cellspacing="0" cellpadding="2">
		      <tr class="admin">
			    <td align="center"><a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=activeEncounterUid%>&ts=<%=getTs()%>',700,400)"><%=getTran("openclinic.chuk","rfe",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
			  </tr>
			  <tr>
			    <td id="rfe"><%=sRfe%></td>
			  </tr>
			</table>
            <div style="padding-top:3px;"></div>
		<%
    }
    if(MedwanQuery.getInstance().getConfigString("showRecentEchographies","").length()>0){
    	String sEchographies="";
    	int days = MedwanQuery.getInstance().getConfigInt("showRecentEchographiesPeriodInDays",270);
    	long period=days*24;
    	period = period*3600*1000;
    	String sDateBegin=ScreenHelper.getSQLDate(new java.util.Date(new java.util.Date().getTime()-period));
    	System.out.println("start="+sDateBegin);
    	Vector debets = Debet.getPatientDebetPrestations(MedwanQuery.getInstance().getConfigString("showRecentEchographies",""),activePatient.personid, sDateBegin, "", "", "");
		if(debets.size()>0){
	    	for(int n=0;n<debets.size();n++){
	    		sEchographies+=(String)debets.elementAt(n)+", ";
	    	}
			%>
				<table class="list" width="100%" cellspacing="1">
			      <tr class="admin">
				    <td align="center"><%=getTran("openclinic.chuk","echographies.in.last",sWebLanguage)+" "+MedwanQuery.getInstance().getConfigInt("showRecentEchographiesPeriodInDays",270)+" "+getTran("web","days",sWebLanguage)%></td>
				  </tr>
				  <tr>
				    <td id="echographies"><%=sEchographies%></td>
				  </tr>
				</table>
	            <div style="padding-top:3px;"></div>
			<%
		}			
    }
    
%>

<table class="list" width="100%" cellspacing="0" cellpadding="2">
  <tr class="admin">
    <td align="center"><a href="javascript:openPopup('healthrecord/findICPC.jsp&PopupWidth=700&PopupHeight=400&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>')"><%=getTran("openclinic.chuk","diagnostic.document",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
  </tr>
  <tr>
    <td id='icpccodes'>
	  <table width='100%' id="icpccodesTable" cellspacing="0" cellpadding="2">
	    <%
		    Iterator items = curTran.getItems().iterator();
		    ItemVO item;
			
		    String sReferenceUID = curTran.getServerId()+"."+curTran.getTransactionId();
		    String sReferenceType = "Transaction";
		    Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID,sReferenceType);
		    Hashtable hDiagnosisInfo;
		    String sCode, sGravity, sCertainty, POA, NC, serviceUid, flags;
	        String sClass = "1";
	        
		     while(items.hasNext()){
                 item = (ItemVO)items.next();
	            
                 if(item.getType().indexOf("ICPCCode")==0){
	                 sCode = item.getType().substring("ICPCCode".length(), item.getType().length());
			        
	                 hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
			         if(hDiagnosisInfo!=null){
			             sGravity = (String)hDiagnosisInfo.get("Gravity");
			             sCertainty = (String)hDiagnosisInfo.get("Certainty");
			             POA = (String) hDiagnosisInfo.get("POA");
			             NC = (String) hDiagnosisInfo.get("NC");
			             serviceUid = (String)hDiagnosisInfo.get("ServiceUid");
			             flags = (String)hDiagnosisInfo.get("Flags");
			          }
			          else{
	                      sGravity = "";
	                      sCertainty = "";
	                      POA = "";
	                      NC = "";
	                      serviceUid = "";
	                      flags = "";
			          }
		                
		              // alternate row-style
		              if(sClass.length()==0) sClass = "1";
		              else                   sClass = "";
			         
			     	  %>
			     	  <tr id="ICPCCode<%=item.getItemId()%>" class="list<%=sClass%>">
			     		<td width="16" nowrap><img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" onclick="deleteDiagnosis(ICPCCode<%=item.getItemId()%>);"/></td>
			            <td width="1%">ICPC</td>
			            <td width="1%"><b><%=item.getType().replaceAll("ICPCCode","")%></b></td>
			            <td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")"%></i></b>
			              <input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/>
			              <input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/>
			              <input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/>
			              <input type='hidden' name='POAICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=POA%>"/>
			              <input type='hidden' name='NCICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=NC%>"/>
			              <input type='hidden' name='ServiceICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=serviceUid%>"/>
			              <input type='hidden' name='FlagsICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=flags%>"/>
			            </td>
			          </tr>
			          <%
			      }
			      else if (item.getType().indexOf("ICD10Code")==0){
			          sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
			        
			          hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
			          if(hDiagnosisInfo!=null){
			              sGravity = (String)hDiagnosisInfo.get("Gravity");
			              sCertainty = (String)hDiagnosisInfo.get("Certainty");
			              POA = (String) hDiagnosisInfo.get("POA");
			              NC = (String) hDiagnosisInfo.get("NC");
			              serviceUid = (String)hDiagnosisInfo.get("ServiceUid");
			              flags = (String)hDiagnosisInfo.get("Flags");
			          } 
			          else{
			              sGravity = "";
			              sCertainty = "";
			              POA = "";
			              NC = "";
			              serviceUid = "";
			              flags = "";
			          }
		                
		              // alternate row-style
		              if(sClass.length()==0) sClass = "1";
		              else                   sClass = "";
			                 
			          %>
			          <tr id='ICD10Code<%=item.getItemId()%>' class="list<%=sClass%>">
			            <td width="16" nowrap><img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" onclick="deleteDiagnosis(ICD10Code<%=item.getItemId()%>);"/></td>
		                <td width="1%">ICD10</td>
		                <td width="1%"><b><%=item.getType().replaceAll("ICD10Code","")%></b></td>
		                <td><b><%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")"%></i></b>
			              <input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/>
			              <input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/>
			              <input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/>
			              <input type='hidden' name='POAICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=POA%>"/>
			              <input type='hidden' name='NCICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=NC%>"/>
			              <input type='hidden' name='ServiceICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=serviceUid%>"/>
			              <input type='hidden' name='FlagsICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=flags%>"/>			                   
			            </td>
			          </tr>
			          <%
		          }
              }
	      %>
	  </table>
	</td>
  </tr>
</table>
<div style="padding-top:3px;"></div>

<table class="list" width="100%" cellspacing="0" cellpadding="2">
  <tr class="admin">
    <td align="center"><%=getTran("openclinic.chuk","contact.diagnoses",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></td>
  </tr>
  <tr>
    <td>
      
	  <table width='100%'>
	    <%
		    if(activeEncounterUid.length() > 0){
		        items = curTran.getItems().iterator();
			
		        sReferenceUID = curTran.getServerId()+"."+curTran.getTransactionId();
		        Vector d = Diagnosis.selectDiagnoses("","",activeEncounterUid,"","","","","","","","","","");
		      
		        sClass = "1";
		        Diagnosis diag;
		        for(int n=0; n<d.size(); n++){
		            diag = (Diagnosis)d.elementAt(n);
		      	 
	                sGravity = diag.getGravity()+"";
	                sCertainty = diag.getCertainty()+"";
	                POA = diag.getPOA();
	                NC = diag.getNC();
	                flags = diag.getFlags();
	                
	                // alternate row-style
	                if(sClass.length()==0) sClass = "1";
	                else                   sClass = "";
	                    
			        if(diag.getCodeType().equalsIgnoreCase("icpc")){
		  			    %><tr class="list<%=sClass%>"><td width="1%">ICPC</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icpccode"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b></td></tr><%
		            }
		            else if (diag.getCodeType().equalsIgnoreCase("icd10")){
		    		    %><tr class="list<%=sClass%>"><td width="1%">ICD10</td><td width="1%"><b><%=diag.getCode()%></b></td><td><b><%=MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sWebLanguage)%> <%=diag.getLateralisation()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%><%=POA.length()>0?" POA":""%><%=NC.length()>0?" N":""%><%=flags.length()==0?"":" ("+flags+")" %></i></b></td></tr><%
		            }
		        }
		    }
	    %>
	  </table>
	</td>
  </tr>
</table>
<div style="padding-top:3px;"></div>

<table class="list" width="100%" cellspacing="0" cellpadding="2">
    <tr class="admin">
        <td align="center">SNOMED-CT</td>
    </tr>
    <tr>
        <td id='snomedcodes'></td>
    </tr>
</table>

<script>
  function readClipboard(){
    var txt = window.clipboardData.getData("Text");
    if(txt.length > 0){
      if(window.DOMParser){
        parser = new DOMParser();
        xmlDoc = parser.parseFromString(txt,"text/xml");
      }
      else{
        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = "false";
        xmlDoc.loadXML(txt);
        
        var concepts = xmlDoc.getElementsByTagName("concept");
        if(concepts.length > 0){
          var conceptId = concepts[0].getAttribute("id");
          var snomedId = concepts[0].getAttribute("snomedId");
          var ctv3id = concepts[0].getAttribute("ctv3id");
  
          var fullySpecifiedName = concepts[0].getAttribute("fullySpecifiedName");	
          document.getElementById("snomedcodes").innerHTML+= "<span id='SNOMEDITEM."+conceptId+"'>"+
                                                              "<input type='hidden' name='SNOMEDCONCEPT."+conceptId+"."+snomedId+"."+ctv3id+"' value='"+fullySpecifiedName+"'/>"+
                                                              conceptId+" <b>"+fullySpecifiedName+"</b><br/>"+
                                                             "</span>";
          window.clipboardData.setData("Text","");
        }  
      }
    }
  }

  window.setInterval("readClipboard();",1000);
</script>

<script>
  <%-- DELETE DIAGNOSIS --%>
  function deleteDiagnosis(itemid){
      if(yesnoDeleteDialog()){
      var index = itemid.parentNode.parentNode.rowIndex;
      document.getElementById("icpccodesTable").deleteRow(index);
    }  
  }

  function deleteRFE(serverid,objectid){
      if(yesnoDeleteDialog()){

      var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=activeEncounterUid%>&language=<%=sWebLanguage%>";
      var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          rfe.innerHTML=resp.responseText;
        }
      });
    }
  }
</script>