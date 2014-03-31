package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;

public class PDFMobileTechniqueSupport extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){                      
                // anamnesis
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_ANAMNESIS");
                if(itemValue.length() > 0){
                    table = new PdfPTable(5);     
                    addItemRow(table,getTran("openclinic.chuk","anamnesis"),itemValue);
                    tranTable.addCell(new PdfPCell(table));
                }   

                // seances / acts
                addSeances();
                                
                // conclusion
                table = new PdfPTable(5);   
                
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                } 
                
                // remarks
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }  
                
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
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
   

    //### PRIVATE METHODS #########################################################################

	//--- ADD SCEANCES --------------------------------------------------------------------------------
	private void addSeances() throws Exception {    
	    contentTable = new PdfPTable(1);
	    table = new PdfPTable(5);
		
		PdfPTable seancesTable = new PdfPTable(10);
		seancesTable.setWidthPercentage(100);

	    // title
	    seancesTable.addCell(createTitleCell(getTran("openclinic.chuk","orthesis.acts"),10));
	    
	    // header
		seancesTable.addCell(createHeaderCell(getTran("web","type"),2));
		seancesTable.addCell(createHeaderCell(getTran("web","precision"),2));
		seancesTable.addCell(createHeaderCell(getTran("openclinic.cnar","production"),3));
		seancesTable.addCell(createHeaderCell(getTran("openclinic.cnar","action"),1));
		seancesTable.addCell(createHeaderCell(getTran("web","quantity"),2));
	    
	    //*** part 1 ***
		//seancesTable.addCell(createSubtitleCell("1",10));
		
		seancesTable.addCell(createValueCell(getTran("mobile.type",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE1")),2));
		seancesTable.addCell(createValueCell(getTran("mobile.detail",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_DETAIL1")),2));
		seancesTable.addCell(createValueCell(getTran("ortho.production",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_PRODUCTION1")),3));
		seancesTable.addCell(createValueCell(getTran("ortho.action",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_ACTION1")),1));
		seancesTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_QUANTITY1"),2));
		
	    //*** part 2 ***
		//seancesTable.addCell(createSubtitleCell("2",10));
		
		seancesTable.addCell(createValueCell(getTran("mobile.type",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_TYPE2")),2));
		seancesTable.addCell(createValueCell(getTran("mobile.detail",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_DETAIL2")),2));
		seancesTable.addCell(createValueCell(getTran("ortho.production",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_PRODUCTION2")),3));
		seancesTable.addCell(createValueCell(getTran("ortho.action",getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_ACTION2")),1));
		seancesTable.addCell(createValueCell(getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORTHESIS_QUANTITY2"),2));
		
	    // add transaction to doc
	    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
	    contentTable.addCell(createCell(new PdfPCell(seancesTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
	    tranTable.addCell(createContentCell(contentTable));
	}
	
}
