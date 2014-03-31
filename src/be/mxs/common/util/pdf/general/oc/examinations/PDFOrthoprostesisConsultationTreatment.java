package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFOrthoprostesisConsultationTreatment extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // ORTHO MANAGER
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CNAR_CONSULTATION_ORTHO_MANAGER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","ortho manager"),itemValue);
                }

                // MEDICAL HISTORY
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_MEDICAL_HISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","medical.history"),itemValue);
                }

                // PHYSIO THERAPY
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_PHYSIO_THERAPY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","ortho.therapy"),itemValue);
                }

                // NUMBER OF MEETINGS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","nr.of.meetings"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                }
                
                addPerformedActs();

                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                // CONCLUSION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }
                
                // REMARKS
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }

                // diagnoses
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################
    
    //--- ADD PERFORMED ACTS (seances) ------------------------------------------------------------
    private void addPerformedActs(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        PdfPTable actsTable = new PdfPTable(10);

        // title
        actsTable.addCell(createSubtitleCell(getTran("openclinic.chuk","orthesis.acts"),10));
        
        boolean actsFound = (getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE1").length() > 0 ||       
                          	 getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE2").length() > 0 ||
                           	 getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE3").length() > 0 ||
                           	 getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE4").length() > 0 ||
                           	 getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE5").length() > 0);
        
        if(actsFound){        
	        // header
	        actsTable.addCell(createHeaderCell(getTran("web","type"),2));
	        actsTable.addCell(createHeaderCell(getTran("web","detail"),2));
	        actsTable.addCell(createHeaderCell(getTran("web","precision"),2));
	        actsTable.addCell(createHeaderCell(getTran("openclinic.cnar","production"),2));
	        actsTable.addCell(createHeaderCell(getTran("openclinic.cnar","action"),1));
	        actsTable.addCell(createHeaderCell(getTran("web","quantity"),1));
	
	        for(int i=1; i<=5; i++){
		        String sType   = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE"+i),
		               sDetail = getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_DETAIL"+i);
		        
		    	actsTable.addCell(createValueCell(getTran("orthesis.type",sType),2));
		    	actsTable.addCell(createValueCell(getTran("orthesis.detail."+sType.toLowerCase(),sDetail),2));
		    	actsTable.addCell(createValueCell(getTran("cnar.detail."+sType+"."+sDetail,getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_PRECISION1")),2));
		    	actsTable.addCell(createValueCell(getTran("ortho.production",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_PRODUCTION1")),2));
		    	actsTable.addCell(createValueCell(getTran("ortho.action",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_ACTION1")),1));
		    	actsTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_QUANTITY1"),1));
	        }
	    }        
        
        // add table
        if(actsTable.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(actsTable));
            addTransactionToDoc();
        }
    }
    
     
}