package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFHealthcenterContact extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){                     
                // biometrics
                addBiometrics();
                addTransactionToDoc();
                
                // keywords
                addKeywords();
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


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################
    
    //--- ADD BIOMETRICS --------------------------------------------------------------------------
    private void addBiometrics(){
        contentTable = new PdfPTable(1);
        PdfPTable bioMetricsTable = new PdfPTable(10);
        bioMetricsTable.setWidthPercentage(100);
    	
		// title
        bioMetricsTable.addCell(createTitleCell(getTran("web","biometrics"),10));

        int cellCount = 0;
        
        //*** bloodPressure : R + L ***
        String sBP_SYS_R = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
               sBP_DIA_R = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
        
        String sBP_SYS_L = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
               sBP_DIA_L = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
         
        if(sBP_SYS_R.length() > 0 || sBP_DIA_R.length() > 0 || sBP_SYS_L.length() > 0 || sBP_DIA_L.length() > 0){
	        bioMetricsTable.addCell(createItemNameCell(getTran("web.occup","medwan.healthrecord.cardial.pression-arterielle"),2));
	    	itemValue = "";
	
	        // bp R
	        if(sBP_SYS_R.length() > 0 || sBP_DIA_R.length() > 0){
	        	itemValue+= getTran("web.occup","medwan.healthrecord.cardial.bras-droit")+": "+sBP_SYS_R+" / "+sBP_DIA_R+" mmHg";
	        }
	     	
	        // bp L
	        if(sBP_SYS_L.length() > 0 || sBP_DIA_L.length() > 0){
	        	if(itemValue.length() > 0) itemValue+= "\n";
	        	itemValue+= getTran("web.occup","medwan.healthrecord.cardial.bras-gauche")+": "+sBP_SYS_L+" / "+sBP_DIA_L+" mmHg";
	        }
	        
	        bioMetricsTable.addCell(createValueCell(itemValue,8));
	        cellCount++;
        }
        
        // weight
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
        if(itemValue.length() > 0){
            addItemRow(bioMetricsTable,getTran("web.occup","medwan.healthrecord.biometry.weight"),itemValue+" kg");
            cellCount++;
        }

        // height
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
        if(itemValue.length() > 0){
            addItemRow(bioMetricsTable,getTran("openclinic.chuk","height"),itemValue+" cm");
            cellCount++;
        }
        
        // temperature
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_TEMPERATURE");
        if(itemValue.length() > 0){
            addItemRow(bioMetricsTable,getTran("openclinic.chuk","temperature"),itemValue+" °C");
            cellCount++;
        }

        // heartfrequency
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEARTFREQUENCY");
        if(itemValue.length() > 0){
            addItemRow(bioMetricsTable,getTran("openclinic.chuk","heartfrequency"),itemValue+" /min");
            cellCount++;
        }
        
        // even out cells with empty cell
        if(cellCount%2==1){
            addItemRow(bioMetricsTable,"","");
        }
        
        // add bioMetricsTable to table 
        if(bioMetricsTable.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(bioMetricsTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
        }
    }
    
    //--- ADD KEYWORDS ----------------------------------------------------------------------------
    private void addKeywords(){
        contentTable = new PdfPTable(1);
        PdfPTable keywordsTable = new PdfPTable(10);
        keywordsTable.setWidthPercentage(100);
    	
		// title
        keywordsTable.addCell(createTitleCell(getTran("web","keywords"),10));
        
        //*** Functional signs ******************
        String sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_FUNCTIONALSIGNS_IDS"),
    	       sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_FUNCTIONALSIGNS_COMMENT");
        
        if(sKeywords.length() > 0 || sComment.length() > 0){
	        keywordsTable.addCell(createItemNameCell(getTran("web","functional.signs"),2));
	        
	        keywordsTable.addCell(createValueCell(sKeywords,4));
            keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
        }        

     	//*** Inspection ************************
        sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_INSPECTION_IDS");
    	sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_INSPECTION_COMMENT");
        
        if(sKeywords.length() > 0 || sComment.length() > 0){
	        keywordsTable.addCell(createItemNameCell(getTran("web","inspection"),2));
	        
	        keywordsTable.addCell(createValueCell(sKeywords,4));
            keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
        }       
        
     	//*** Palpation *************************
        sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PALPATION_IDS");
    	sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PALPATION_COMMENT");
        
        if(sKeywords.length() > 0 || sComment.length() > 0){
	        keywordsTable.addCell(createItemNameCell(getTran("web","palpation"),2));
	        
	        keywordsTable.addCell(createValueCell(sKeywords,4));
            keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
        }       
                
        //*** Heart ausculation ***************** 
        sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_HEARTAUSCULTATION_IDS");
    	sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_HEARTAUSCULTATION_COMMENT");
        
        if(sKeywords.length() > 0 || sComment.length() > 0){
	        keywordsTable.addCell(createItemNameCell(getTran("web","heart.auscultation"),2));
	        
	        keywordsTable.addCell(createValueCell(sKeywords,4));
            keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
        }        

     	//*** Lung ausculation ****************** 
		sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_LUNGAUSCULTATION_IDS");
		sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LUNGAUSCULTATION_COMMENT");
		
		if(sKeywords.length() > 0 || sComment.length() > 0){
		    keywordsTable.addCell(createItemNameCell(getTran("web","lung.auscultation"),2));
		    
		    keywordsTable.addCell(createValueCell(sKeywords,4));
		    keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
		} 
  
     	//*** Reference *************************
		sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_REFERENCE_IDS");
		sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_COMMENT");
		
		if(sKeywords.length() > 0 || sComment.length() > 0){
		    keywordsTable.addCell(createItemNameCell(getTran("web","reference"),2));
		    
		    keywordsTable.addCell(createValueCell(sKeywords,4));
		    keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
		} 

     	//*** Evacuation ************************
		sKeywords = getKeywords(transactionVO,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_EVACUATION_IDS");
		sComment  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EVACUATION_COMMENT");
		
		if(sKeywords.length() > 0 || sComment.length() > 0){
		    keywordsTable.addCell(createItemNameCell(getTran("web","evacuation"),2));
		    
		    keywordsTable.addCell(createValueCell(sKeywords,4));
		    keywordsTable.addCell(createValueCell(sComment.replaceAll("<br>","\n"),4));
		} 	
        
        // add keywordsTable to table 
        if(keywordsTable.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(keywordsTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
            tranTable.addCell(createContentCell(contentTable));
        }
    }
    
    //--- GET KEYWORDS ----------------------------------------------------------------------------
	private String getKeywords(TransactionVO transaction, String itemId){
		String sKeywords = "";
		
		// list keywords
		String sItemValue = transaction.getItemValue(itemId);
		if(sItemValue.length() > 0){
			String[] ids = sItemValue.split(";");
			String keyword = "";
			
			for(int n=0; n<ids.length; n++){
				if(ids[n].split("\\$").length==2){
					keyword = getTran(ids[n].split("\\$")[0],ids[n].split("\\$")[1]);					
					sKeywords+= keyword+", ";
				}
			}
			
			// trim
			if(sKeywords.endsWith(", ")){
				sKeywords = sKeywords.substring(0,sKeywords.lastIndexOf(", "));
			}
		}
		
		return sKeywords;
	}
	
}
