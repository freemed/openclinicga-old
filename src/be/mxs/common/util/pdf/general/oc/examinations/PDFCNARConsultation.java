package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFCNARConsultation extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                // ANAMNESIS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_ANAMNESIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","anamnesis"),itemValue);
                }

                // CONSULTATION BY
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_SOCIALASSISTANT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("Web","consultation.by"),getTran("encounter.socialservice.manager",itemValue));
                }   

                // FORESEEN TREATMENT
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO").equals("medwan.common.true") ||
               	   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE").equals("medwan.common.true") ||
              	   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY").equals("medwan.common.true") ||
               	   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH").equals("medwan.common.true") || 
                   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY").equals("medwan.common.true")){
                    String sSelectedOptions = "";

                    // 1 - orthopedics
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_ORTHO");
	                if(itemValue.equals("medwan.common.true")){
	                	sSelectedOptions+= getTran("web","cnar.orthopedics")+", ";
	                }
                    // 2 - kine
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_KINE");
	                if(itemValue.equals("medwan.common.true")){
	                	sSelectedOptions+= getTran("web","cnar.kine")+", ";
	                }
                    // 3 - surgery
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SURGERY");
	                if(itemValue.equals("medwan.common.true")){
	                	sSelectedOptions+= getTran("web","cnar.surgery")+", ";
	                }
                    // 4 - tech
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_TECH");
	                if(itemValue.equals("medwan.common.true")){
	                	sSelectedOptions+= getTran("web","cnar.tech")+", ";
	                }
                    // 5 - xray
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_XRAY");
	                if(itemValue.equals("medwan.common.true")){
	                	sSelectedOptions+= getTran("web","cnar.xray")+", ";
	                }
	                
	                if(sSelectedOptions.length() > 0){
	                	if(sSelectedOptions.endsWith(", ")){
	                		sSelectedOptions = sSelectedOptions.substring(0,sSelectedOptions.length()-2);
	                	}
	                	
	                    addItemRow(table,getTran("openclinic.chuk","foreseen.treatment"),sSelectedOptions);
	                }
                }

                // NUMBER OF MEETINGS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_TREATMENT_SCEANCE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","sceances"),itemValue);
                }

                // FREQUENCY (day/week)
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY").length() > 0 ||
               	   getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK").length() > 0){                	
                	String sFrequency = "";
                	
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_DAY");
	                if(itemValue.length() > 0){
	                	sFrequency+= itemValue+" /"+getTran("openclinic.chuk","day").toLowerCase()+", ";
	                }
	                
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_FREQUENCY_WEEK");
	                if(itemValue.length() > 0){
	                	sFrequency+= itemValue+" /"+getTran("openclinic.chuk","week").toLowerCase()+", ";
	                }
	                
	                if(sFrequency.length() > 0){
	                	if(sFrequency.endsWith(", ")){
	                		sFrequency = sFrequency.substring(0,sFrequency.length()-2);
	                	}
	                	
	                    addItemRow(table,getTran("openclinic.chuk","frequency"),sFrequency);
	                }
                }
                
                // REMARKS
                itemValue = getItemSeriesValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue.replaceAll("<br>","\r\n"));
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();

                // diagnoses
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}