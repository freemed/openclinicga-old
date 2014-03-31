package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFNeuropsyOutpatientSummary extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
            	/*
            	//*** DIAGNOSTICS *********************************************
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                if(itemValue.length() > 0){
                    table = new PdfPTable(5);
                    addEncounterDiagnosticsRow(table, itemValue);
                    tranTable.addCell(createContentCell(table));
                }                
                */

                //*** MEDICAL SUMMARY *****************************************
                table = new PdfPTable(5);
                table.setWidthPercentage(100);
                
                cell = createHeaderCell(getTran("web","medicalsummary"),5);
                table.addCell(cell);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPOS_REASONFORENCOUNTER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","reason.for.encounter"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPOS_COMPLEMENTARYEXAMS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","complentary.exams"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPOS_MEASURESTAKEN");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","disease.evolution"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPOS_RECCOMMENDATIONS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","specific.reccommendations"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    tranTable.addCell(createContentCell(table));
                }

                // add transaction to doc
                addTransactionToDoc();

                // diagnoses
                addDiagnosisEncoding(true,true,true);
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}

