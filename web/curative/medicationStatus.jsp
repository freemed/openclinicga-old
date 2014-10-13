<%@page import="be.openclinic.medical.Prescription,
                be.openclinic.medical.ChronicMedication,
                java.util.Vector,
                be.openclinic.medical.PaperPrescription,
                be.openclinic.pharmacy.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<div id="patientmedicationsummary"/>
<table width="100%" class="list" height="100%" cellspacing="0" cellpadding="0">
    <tr class="admin"><td colspan="4"><%=getTran("curative","medication.status.title",sWebLanguage)%></td></tr>
    <tr style="vertical-align:top;">
    <%
        //--- 1:CHRONIC ---------------------------------------------------------------------------
        String sProductUnit, timeUnitTran, sPrescrRule;
        Vector chronicMedications = ChronicMedication.find(activePatient.personid,"","","","OC_CHRONICMED_BEGIN","ASC");
        if(chronicMedications.size()>0){
            %>
                <td class="admin2" style="border-bottom:1px solid #fff;"><b><%=getTran("curative","medication.chronic",sWebLanguage)%></b></td>
                <td>
                    <table>
            <%
        }
        
        ChronicMedication chronicMedication;
        for(int n=0; n<chronicMedications.size(); n++){
            chronicMedication = (ChronicMedication)chronicMedications.elementAt(n);
            
            sPrescrRule = getTran("web.prescriptions","prescriptionrule",sWebLanguage);
            sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#",chronicMedication.getUnitsPerTimeUnit()+"");

            // productunits
            if(chronicMedication.getUnitsPerTimeUnit()==1){
                sProductUnit = getTran("product.unit",chronicMedication.getProduct().getUnit(),sWebLanguage);
            }
            else{
                sProductUnit = getTran("product.unit",chronicMedication.getProduct().getUnit(),sWebLanguage);
            }
            sPrescrRule = sPrescrRule.replaceAll("#productunit#",sProductUnit.toLowerCase());

            // timeunits
            if(chronicMedication.getTimeUnitCount()==1){
                sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#","");
                timeUnitTran = getTran("prescription.timeunit",chronicMedication.getTimeUnit(),sWebLanguage);
            }
            else{
                sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#",chronicMedication.getTimeUnitCount()+"");
                timeUnitTran = getTran("prescription.timeunits",chronicMedication.getTimeUnit(),sWebLanguage);
            }
            
            sPrescrRule = sPrescrRule.replaceAll("#timeunit#",timeUnitTran.toLowerCase());
            out.print("<tr><td><b><a href='javascript:showChronicPrescription("+chronicMedication.getUid()+");'>"+chronicMedication.getProduct().getName()+"</a></b><i> ("+sPrescrRule+")</i></td></tr>");
        }

        if(chronicMedications.size() > 0){
		    %>
		            </table>
		        </td>
		    <%
        }
        
        //--- 2:ACTIVE ----------------------------------------------------------------------------
        Vector activePrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
        if(activePrescriptions!=null && activePrescriptions.size()>0){
            long latencydays = 1000*MedwanQuery.getInstance().getConfigInt("activeMedicationLatency",60);
            latencydays*= 24*3600;
        	Timestamp ts = new Timestamp(ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new java.util.Date())).getTime()-latencydays);

		    %>
		        <td class="admin2" nowrap style="border-bottom:1px solid #fff;"><b><%=getTran("curative","medication.prescription",sWebLanguage)%><br>(<%=getTran("web","after",sWebLanguage)+" "+ScreenHelper.stdDateFormat.format(ts) %>)</b></td>
		        <td>
		            <table>
		    <%
		    
	        Prescription prescription;	    
	        for(int n=0; n<activePrescriptions.size(); n++){
	            prescription = (Prescription)activePrescriptions.elementAt(n);
	            
	            if(prescription!=null && prescription.getProduct()!=null){
	                sPrescrRule = getTran("web.prescriptions","prescriptionrule",sWebLanguage);
	                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#",prescription.getUnitsPerTimeUnit()+"");
	
	                // productunits
	                if(prescription.getUnitsPerTimeUnit()==1){
	                    sProductUnit = getTran("product.unit",prescription.getProduct().getUnit(),sWebLanguage);
	                }
	                else{
	                    sProductUnit = getTran("product.unit",prescription.getProduct().getUnit(),sWebLanguage);
	                }
	                sPrescrRule = sPrescrRule.replaceAll("#productunit#",sProductUnit.toLowerCase());
	
	                // timeunits
	                if(prescription.getTimeUnitCount()==1){
	                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#","");
	                    timeUnitTran = getTran("prescription.timeunit",prescription.getTimeUnit(),sWebLanguage);
	                }
	                else{
	                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#",prescription.getTimeUnitCount()+"");
	                    timeUnitTran = getTran("prescription.timeunits",prescription.getTimeUnit(),sWebLanguage);
	                }
	                
	                sPrescrRule = sPrescrRule.replaceAll("#timeunit#",timeUnitTran.toLowerCase());
	                out.print("<tr>"+
	                           "<td><b><a href='javascript:showPrescription(\""+prescription.getUid()+"\");'>"+prescription.getProduct().getName()+"</a></b><i> ("+sPrescrRule+")</i></td>"+
	                          "</tr>");
	            }
	        }
	        
    		%>
		            </table>
		        </td>
			<%
    	}
        
    //--- 3:PAPER ---------------------------------------------------------------------------------
    long time = new java.util.Date().getTime();
    long month = 30*24*3600;
    month *= 3000;
    time -= month;
    
    Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",ScreenHelper.stdDateFormat.format(new java.util.Date(time)),"","","DESC");
    if(paperprescriptions.size() > 0){
        %>
        <tr>
            <td class="admin2" style="vertical-align:top;border-bottom:1px solid #fff;"><b><%=getTran("curative","medication.paperprescriptions",sWebLanguage)%><br/> &lt;3 <%=getTran("web","months",sWebLanguage).toLowerCase()%></b></td>
            <td colspan="3">
                <table width="100%">
                    <%
                        String hiddenprescriptions = "";
                        String sClass = "";
                        
                        for(int n=0; n<paperprescriptions.size(); n++){
                        	// alternate row-style
                            if(sClass.length()==0) sClass = "1";
                            else                   sClass = "";
                            
                            PaperPrescription paperPrescription = (PaperPrescription)paperprescriptions.elementAt(n);
                            if(n < 3){
                                out.print("<tr class='list"+sClass+"' id='pp"+paperPrescription.getUid()+"'>"+
                                           "<td valign='top' width='90px'>"+
                                            "<img src='_img/icons/icon_delete.gif' class='link' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+ScreenHelper.stdDateFormat.format(paperPrescription.getBegin())+"</b>"+
                                           "</td>"+
                                           "<td><i>");
                                Vector products = paperPrescription.getProducts();
                                for(int i=0; i<products.size(); i++){
                                    out.print(products.elementAt(i)+"<br/>");
                                }
                                out.print("</i></td>"+
                                         "</tr>");
                            }
                            else {
                                hiddenprescriptions+= "<tr class='list"+sClass+"' id='pp"+paperPrescription.getUid()+"'>"+
                                                       "<td valign='top' width='90px'>"+
                                                        "<img src='_img/icons/icon_delete.gif' class='link' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+ScreenHelper.stdDateFormat.format(paperPrescription.getBegin())+"</b>"+
                                                       "</td>"+
                                                       "<td><i>";
                                Vector products = paperPrescription.getProducts();
                                for(int i=0; i<products.size(); i++){
                                    hiddenprescriptions+= products.elementAt(i)+"<br/>";
                                }
                                hiddenprescriptions+= "</i></td></tr>";
                            }
                        }
                    %>
                </table>
            </td>
        </tr>
        <%
        
        if(hiddenprescriptions.length() > 0){
            out.print("<tr>"+
                       "<td width='1%' valign='top' align='right'>"+
                        "<img src='"+sCONTEXTPATH+"/_img/icons/icon_plus.png' onclick='togglehiddenprescriptions();'/>"+
                       "</td>"+
                       "<td colspan='3'>"+
                        "<div id='hiddenprescriptions' style='display:none'>"+
                         "<table width='100%'>"+hiddenprescriptions+"</table>"+
                        "</div>"+
                       "</td>"+
                      "</tr>");
        }
    }
    
	//--- 4:DELIVERED -----------------------------------------------------------------------------
	long day=24*3600*1000;
	Vector medicationHistory = ProductStockOperation.getPatientDeliveries(activePatient.personid, new java.util.Date(new java.util.Date().getTime()-MedwanQuery.getInstance().getConfigInt("patientMedicationDeliveryHistoryDuration",14)*day), new java.util.Date(), "OC_OPERATION_DATE", "DESC");
	if(medicationHistory.size()>0){
		%>
        <tr>
            <td class="admin2" style="vertical-align:top;border-bottom:1px solid #fff;"><b><%=getTran("curative","medication.deliveries",sWebLanguage)%><br/> &lt;<%= MedwanQuery.getInstance().getConfigInt("patientMedicationDeliveryHistoryDuration",14)%> <%=getTran("web","days",sWebLanguage).toLowerCase()%></b></td>
            <td colspan="3">
                <table width="100%">
                    <% 
                        ProductStockOperation operation;
						for(int n=0;n<medicationHistory.size();n++){
							operation = (ProductStockOperation)medicationHistory.elementAt(n);
							
							String product = "";
							if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
								product = operation.getProductStock().getProduct().getName();
							}
							if(operation.getUnitsChanged()!=0){
								out.print("<tr><td>"+ScreenHelper.stdDateFormat.format(operation.getDate())+"</td><td>"+operation.getUnitsChanged()+" X "+product+"</td></tr>");		                    
							}
						}
                    %>
                </table>
            </td>
        </tr>
	    <%
	}
%>

        <tr height="99%"><td/></tr>
    </tr>
</table>

<script>
  function showPrescription(uid){
	var url = '<c:url value='/popup.jsp'/>?Page=medical/managePrescriptionsPopup.jsp&Action=showDetails&EditPrescrUid='+uid+"&ts=<%=getTs()%>&PopupWidth=800";
    window.open(url,'Popup','toolbar=no,status=no,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no').moveBy(2000,2000);
  }
  
  function showChronicPrescription(uid){
	url = '<c:url value='/popup.jsp'/>?Page=medical/manageChronicMedication.jsp&PopupWidth=800&Action=showDetails&EditMedicationUid='+uid;
    window.open(url,'Popup','toolbar=no,status=no,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no').moveBy(2000,2000);
  }
  
  function togglehiddenprescriptions(){
    if(document.getElementById('hiddenprescriptions').style.display=='none'){
       document.getElementById('hiddenprescriptions').style.display='block';
    }
    else{
      document.getElementById('hiddenprescriptions').style.display='none';
    }
  }
</script>