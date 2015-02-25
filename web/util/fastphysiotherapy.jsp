<%@page import="be.openclinic.finance.*,be.mxs.common.model.vo.healthrecord.ItemContextVO"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("fastphysiotherapy","select",activeUser)%>
<%
	if(request.getParameter("saveButton")!=null){
    	String origin=checkString(request.getParameter("EditEncounterOriginCNAR1"))+"$"+checkString(request.getParameter("EditEncounterOriginCNAR2"))+"$$$$$";
		java.util.Date cd = activePatient.getCreationDate();
		java.util.Date mindate=null;
		Enumeration parameters = request.getParameterNames();
		while(parameters.hasMoreElements()){
			String name = (String)parameters.nextElement();
			if(name.startsWith("prestationuid_")){
				String date=request.getParameter(name);
				if(mindate==null || ScreenHelper.getSQLDate(date).before(mindate)){
					mindate=ScreenHelper.getSQLDate(date);
				}
			}
		}
		parameters = request.getParameterNames();
		while(parameters.hasMoreElements()){
			String name = (String)parameters.nextElement();
			if(name.startsWith("prestationuid_")){
				String date=request.getParameter(name);
				String prestationuid = name.split("\\_")[1];
				//First check if a contact on this date exists
				Encounter prestationEncounter=Encounter.getActiveEncounterOnDateStrict(new Timestamp(ScreenHelper.getSQLDate(date).getTime()), activePatient.personid);
				if(prestationEncounter==null){
					//We must create a new encounter
					prestationEncounter = new Encounter();
					prestationEncounter.setBegin(ScreenHelper.getSQLDate(date));
					prestationEncounter.setEnd(ScreenHelper.getSQLDate(date));
					prestationEncounter.setCreateDateTime(ScreenHelper.getSQLDate(date));
					prestationEncounter.setPatientUID(activePatient.personid);
					prestationEncounter.setServiceUID(MedwanQuery.getInstance().getConfigString("fastPhysiotherapyServiceUID","CLI.KIN"));
					prestationEncounter.setType("visit");
					prestationEncounter.setEtiology(checkString(request.getParameter("prestation.etiology")));
					prestationEncounter.setOrigin(origin);
					prestationEncounter.setUpdateDateTime(new java.util.Date());
					prestationEncounter.setUpdateUser(activeUser.userid);
					prestationEncounter.setVersion(1);
					if(checkString(request.getParameter("prestation.newcase")).equalsIgnoreCase("1") &&  ScreenHelper.getSQLDate(date).equals(mindate)){
						prestationEncounter.setNewcase(1);
					}
					else {
						prestationEncounter.setNewcase(0);
					}
					prestationEncounter.store();
					
					if(cd==null){
		            	AccessLog.insert(activeUser.userid,"C."+activePatient.personid, prestationEncounter.getBegin());
		            	cd=prestationEncounter.getBegin();
					}
					else if (cd.after(prestationEncounter.getBegin())){
						activePatient.setCreationDate(prestationEncounter.getBegin());
						cd=prestationEncounter.getBegin();
					}
				}
				//Now check if the Kinesitherapydocument already exists
				TransactionVO prestationTransaction = null;
				String type=MedwanQuery.getInstance().getConfigString("fastPhysiotherapyTransactionType","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNAR_KINECONSULTATION");
				Vector transactions = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(activePatient.personid), type);
				long day = 24*3600*1000;
				for(int n=0;n<transactions.size();n++){
					TransactionVO tran = (TransactionVO)transactions.elementAt(n);
					MedwanQuery.getInstance().getObjectCache().removeObject("transaction", tran.getServerId()+"."+tran.getTransactionId());
					tran=MedwanQuery.getInstance().loadTransaction(tran.getServerId(), tran.getTransactionId());
					if(tran!=null && tran.getUpdateDateTime()!=null && (tran.getUpdateDateTime().getTime()-ScreenHelper.getSQLDate(date).getTime())>=0 &&  (tran.getUpdateDateTime().getTime()-ScreenHelper.getSQLDate(date).getTime())<=(day-1)){
						prestationTransaction=tran;
						break;
					}
				}
				if(prestationTransaction==null){
					//We must create a new transaction;
					prestationTransaction = new TransactionVO(-1,type,ScreenHelper.getSQLDate(date),ScreenHelper.getSQLDate(date),1,MedwanQuery.getInstance().getUser(activeUser.userid),new Vector());
					prestationTransaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
                            "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",
                            prestationEncounter.getUid(),new java.util.Date(),null));

					prestationTransaction = MedwanQuery.getInstance().updateTransaction(Integer.parseInt(activePatient.personid), prestationTransaction);
				}
				//Now check if the debet on this date already exists
				Vector debets = Debet.getPatientDebets(activePatient.personid, date, "");
				boolean bExists = false;
				for(int n=0;n<debets.size();n++){
					Debet debet = Debet.get((String)debets.elementAt(n));
					if(debet!=null && debet.getPrestationUid().equalsIgnoreCase(prestationuid) && debet.getDate().getTime()-ScreenHelper.getSQLDate(date).getTime()>=0 && debet.getDate().getTime()-ScreenHelper.getSQLDate(date).getTime()<=day-1){
						bExists=true;
						break;
					}
				}
				if(!bExists){
					//We must create a new debet
            		Debet.createAutomaticDebet("KIN."+prestationTransaction.getServerId()+"."+prestationTransaction.getTransactionId()+"."+prestationuid, activePatient.personid, prestationuid,ScreenHelper.getSQLDate(date),1, activeUser.userid,prestationEncounter);
				}
			}
		}
	}
%>
<script>
	var prestations = "";
	var counter=0;
</script>
<%
	if(Insurance.getMostInterestingInsuranceForPatient(activePatient.personid)==null){
		%>
			<script>
				alert('<%=getTranNoLink("web","patientinsurancedatamissing",sWebLanguage)%>');
			</script>
		<%
	}
	else {
%>
<form name='transactionForm' method='post'>
	<table>
		<tr>
			<td>
				<table>
					<tr class='admin'>
						<td colspan='3'><%=getTran("web","fastphysiotherapy",sWebLanguage) %></td>
					</tr>
			       <tr>
			           <td class="admin"><%=getTran("openclinic.chuk","urgency.origin",sWebLanguage)%> *</td>
			           <td class="admin2" colspan='2'>
			               <select class="text" name="EditEncounterOriginCNAR1" id="EditEncounterOriginCNAR1" onchange="loadSelect('cnar.origin.'+this.options[this.selectedIndex].value,document.getElementById('EditEncounterOriginCNAR2'))">
			                   <option/>
			                   <%
			                       out.print(ScreenHelper.writeSelect("urgency.origin","",sWebLanguage));
			                   %>
			               </select>
			               <select class='text' name='EditEncounterOriginCNAR2' id='EditEncounterOriginCNAR2'>
			                   <%
			                       out.print(ScreenHelper.writeSelect("cnar.origin.","",sWebLanguage));
			                   %>
			               </select>
			           </td>
			       </tr>
			       	<tr>
			            <td class="admin"><%=getTran("Web","etiology",sWebLanguage)%></td>
			            <td class='admin2' colspan='2'>
			            	<input type="checkbox" name="prestation.newcase" value="1"/><%=getTran("Web","newcase",sWebLanguage)%>
			                <select class="text" name="prestation.etiology" style="vertical-align:top;">
			                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
			                    <%=ScreenHelper.writeSelect("encounter.etiology","",sWebLanguage)%>
			                </select>
						</td>            
			       	</tr>
					<tr>
						<td class='admin'><%=getTran("web","date",sWebLanguage) %>: <%=writeDateField("date","transactionForm",ScreenHelper.getDate(),sWebLanguage) %></td>
						<td class='admin'><%=getTran("web","prestation",sWebLanguage) %>: 
							<select name='prestation' id ='prestation' class='text'>
								<%
									Vector kinedeliveries = Prestation.getPrestationsByClass(MedwanQuery.getInstance().getConfigString("kinePrestationClass","kine"));
									for(int n=0;n<kinedeliveries.size();n++){
										Prestation prestation = (Prestation)kinedeliveries.elementAt(n);
										out.println("<option value='"+prestation.getUid()+"'>"+prestation.getDescription()+"</option>");
									}
								%>
							</select>
						</td>
						<td class='admin'><input type='button' class='button' name='addButton' id='addButton' value='<%=getTran("web","add",sWebLanguage)%>' onclick='addPrestation();'/></td>
					</tr>
					<tr class='admin'>
						<td class='admin'><input type='submit' class='button' name='saveButton' id='saveButton' value='<%=getTran("web","save",sWebLanguage)%>'/></td>
						<td class='admin' colspan='2'/>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td>
				<div name='divPrestations' id='divPrestations'/>
			</td>
		</tr>
	</table>
</form>

<script>
	function addPrestation(){
		prestations+=counter+";"+document.getElementById('date').value+";"+document.getElementById('prestation').options[document.getElementById('prestation').selectedIndex].value+";"+document.getElementById('prestation').options[document.getElementById('prestation').selectedIndex].text+"|";
		counter++;
		listPrestations();
	}

	function listPrestations(){
		var tbl ="<table width='100%'>"
		var p=prestations.split("|");
		for(n=0;n<p.length;n++){
			if(p[n].length>0){
				tbl+="<tr><td width='1%' class='admin2'><img src='<c:url value="/_img/themes/default/erase.png"/>' onclick='deletePrestation("+p[n].split(";")[0]+");'/></td><td class='admin2' width='20%'>"+p[n].split(";")[1]+"</td><td class='admin2'><input type='hidden' name='prestationuid_"+p[n].split(";")[2]+"_"+p[n].split(";")[0]+"' value='"+p[n].split(";")[1]+"'/>"+p[n].split(";")[3]+"</td></tr>"
			}
		}
		tbl+="</table>";
		document.getElementById('divPrestations').innerHTML=tbl;
	}
	
	function deletePrestation(uid){
		var p=prestations.split("|");
		prestations="";
		for(n=0;n<p.length;n++){
			if(p[n].length>0 && p[n].split(";")[0]!=uid){
				prestations+=p[n]+"|";
			}
		}
		listPrestations();
	}
	function loadSelect(labeltype,select){
	    var today = new Date();
	    var url='<c:url value="/"/>/_common/search/searchByAjax/loadSelect.jsp?ts=' + today;
	    new Ajax.Request(url,{
	            method: "POST",
	            postBody: 'labeltype=' + labeltype,
	            onSuccess: function(resp){
	                var sOptions = resp.responseText;
	                if (sOptions.length>0){
	                    var aOptions = sOptions.split("$");
	                    select.options.length=0;
	                    for(var i=0; i<aOptions.length; i++){
	                    	aOptions[i] = aOptions[i].replace(/^\s+/,'');
	                    	aOptions[i] = aOptions[i].replace(/\s+$/,'');
	                        if ((aOptions[i].length>0)&&(aOptions[i]!=" ")){
	                        	select.options[i] = new Option(aOptions[i].split("£")[1], aOptions[i].split("£")[0]);
	                        }
	                    }
	                }
	            },
	            onFailure: function(){
	            }
	        }
	    );
	}

</script>
<%
}
%>