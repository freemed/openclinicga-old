<%@ page import="be.openclinic.medical.Prescription" %>
<%@ page import="be.openclinic.medical.ChronicMedication" %>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%@ page import="be.openclinic.pharmacy.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<div id="patientmedicationsummary"/>
<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin"><td colspan="4"><%=getTran("curative","medication.status.title",sWebLanguage)%></td></tr>
    <tr valign="top">
    <%
        String sProductUnit, timeUnitTran, sPrescrRule;
        Vector chronicMedications = ChronicMedication.find(activePatient.personid, "", "", "", "OC_CHRONICMED_BEGIN", "ASC");
        if(chronicMedications.size()>0){
                out.println("<td width='1'><table><tr><td>"+getTran("curative","medication.chronic",sWebLanguage)+"</td></tr></table></td>");
                out.println("<td><table>");
        }
        for (int n = 0; n < chronicMedications.size(); n++) {
            ChronicMedication chronicMedication = (ChronicMedication) chronicMedications.elementAt(n);
            sPrescrRule = getTran("web.prescriptions", "prescriptionrule", sWebLanguage);
            sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", chronicMedication.getUnitsPerTimeUnit() + "");

            // productunits
            if (chronicMedication.getUnitsPerTimeUnit() == 1) {
                sProductUnit = getTran("product.unit", chronicMedication.getProduct().getUnit(), sWebLanguage);
            } else {
                sProductUnit = getTran("product.unit", chronicMedication.getProduct().getUnit(), sWebLanguage);
            }
            sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

            // timeunits
            if (chronicMedication.getTimeUnitCount() == 1) {
                sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                timeUnitTran = getTran("prescription.timeunit", chronicMedication.getTimeUnit(), sWebLanguage);
            } else {
                sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", chronicMedication.getTimeUnitCount() + "");
                timeUnitTran = getTran("prescription.timeunits", chronicMedication.getTimeUnit(), sWebLanguage);
            }
            sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            out.print("<tr><td><b><a href='javascript:showChronicPrescription(" + chronicMedication.getUid() + ");'>" + chronicMedication.getProduct().getName() + "</a></b><i> (" + sPrescrRule + ")</i></td></tr>");
        }

        if(chronicMedications.size()>0){
    %>
        </table>
        </td>
    <%
        }
        Vector activePrescriptions = Prescription.getActivePrescriptions(activePatient.personid);
        if(activePrescriptions!=null && activePrescriptions.size()>0){
            long latencydays=1000*MedwanQuery.getInstance().getConfigInt("activeMedicationLatency",60);
            latencydays*=24*3600;
        	Timestamp ts = new Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())).getTime()-latencydays);

    %>
        <td width="1"><table><tr><td><b><%=getTran("curative","medication.prescription",sWebLanguage)%> (<%=getTran("web","after",sWebLanguage)+" "+new SimpleDateFormat("dd/MM/yyyy").format(ts) %>)</b></td></tr></table></td>
        <td><table>
    <%
        Prescription prescription;

        for(int n=0;n<activePrescriptions.size();n++){
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
                out.print("<tr><td><b><a href='javascript:showPrescription(\""+prescription.getUid()+"\");'>"+prescription.getProduct().getName()+"</a></b><i> ("+sPrescrRule+")</i></td></tr>");
            }
        }
    %>
        </table>
        </td>
<%
    }
    long time = new java.util.Date().getTime();
    long month = 30*24*3600;
    month *= 3000;
    time -= month;
    Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(time)),"","","DESC");
    if(paperprescriptions.size()>0){
%>
        <tr>
            <td valign="top"><b><%=getTran("curative","medication.paperprescriptions",sWebLanguage)%><br/> &lt;3 <%=getTran("web","months",sWebLanguage).toLowerCase()%></b></td>
            <td colspan="3">
                <table width="100%">
                    <%
                        String hiddenprescriptions ="";
                        String l="";
                        for(int n=0;n<paperprescriptions.size();n++){
                            if(l.length()==0){
                                l="1";
                            }
                            else{
                                l="";
                            }
                            PaperPrescription paperPrescription = (PaperPrescription)paperprescriptions.elementAt(n);
                            if(n<3){
                                out.println("<tr class='list"+l+"' id='pp"+paperPrescription.getUid()+"'><td valign='top' width='90px'><img src='_img/icon_delete.gif' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+new SimpleDateFormat("dd/MM/yyyy").format(paperPrescription.getBegin())+"</b></td><td><i>");
                                Vector products =paperPrescription.getProducts();
                                for(int i=0;i<products.size();i++){
                                    out.print(products.elementAt(i)+"<br/>");
                                }
                                out.println("</i></td></tr>");
                            }
                            else {
                                hiddenprescriptions+="<tr class='list"+l+"' id='pp"+paperPrescription.getUid()+"'><td valign='top' width='90px'><img src='_img/icon_delete.gif' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+new SimpleDateFormat("dd/MM/yyyy").format(paperPrescription.getBegin())+"</b></td><td><i>";
                                Vector products =paperPrescription.getProducts();
                                for(int i=0;i<products.size();i++){
                                    hiddenprescriptions+=products.elementAt(i)+"<br/>";
                                }
                                hiddenprescriptions+="</i></td></tr>";
                            }
                        }
                    %>
                </table>
            </td>
        </tr>
<%
        if(hiddenprescriptions.length()>0){
            out.println("<tr><td width='1%' valign='top' align='right'><img src='_img/plus.png' onclick='togglehiddenprescriptions();'/></td><td colspan='3'><div id='hiddenprescriptions' style='display: none'><table width='100%'>"+hiddenprescriptions+"</table></div></td></tr>");
        }
    }
	//Nu gaan we kijken of er geneesmiddelen geleverd zijn geworden in de laatste x dagen
	long day=24*3600*1000;
	Vector medicationHistory = ProductStockOperation.getPatientDeliveries(activePatient.personid, new java.util.Date(new java.util.Date().getTime()-MedwanQuery.getInstance().getConfigInt("patientMedicationDeliveryHistoryDuration",14)*day), new java.util.Date(), "OC_OPERATION_DATE", "DESC");
	if(medicationHistory.size()>0){
		%>
        <tr>
            <td valign="top"><b><%=getTran("curative","medication.deliveries",sWebLanguage)%><br/> &lt;<%= MedwanQuery.getInstance().getConfigInt("patientMedicationDeliveryHistoryDuration",14)%> <%=getTran("web","days",sWebLanguage).toLowerCase()%></b></td>
            <td colspan="3">
                <table width="100%">
                    <%
						for(int n=0;n<medicationHistory.size();n++){
							ProductStockOperation operation = (ProductStockOperation)medicationHistory.elementAt(n);
							String product="";
							if(operation.getProductStock()!=null && operation.getProductStock().getProduct()!=null){
								product=operation.getProductStock().getProduct().getName();
							}
							out.println("<tr><td>"+new SimpleDateFormat("dd/MM/yyyy").format(operation.getDate())+"</td><td>"+operation.getUnitsChanged()+" X "+product+"</td></tr>");		                    
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
<script type="text/javascript">
    function showPrescription(uid){
        window.open('<c:url value='/popup.jsp'/>?Page=medical/managePrescriptionsPopup.jsp&Action=showDetails&EditPrescrUid='+uid+"&ts=<%=getTs()%>&PopupWidth=800",'Popup','toolbar=no, status=no, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no').moveBy(2000,2000);
    }
    function showChronicPrescription(uid){
        window.open('<c:url value='/popup.jsp'/>?Page=medical/manageChronicMedication.jsp&PopupWidth=800&Action=showDetails&EditMedicationUid='+uid,'Popup','toolbar=no, status=no, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no').moveBy(2000,2000);
    }
    function togglehiddenprescriptions(){
        if(document.getElementById('hiddenprescriptions').style.display=='none'){
            document.getElementById('hiddenprescriptions').style.display='block';
        }
        else {
            document.getElementById('hiddenprescriptions').style.display='none';
        }
    }
</script>