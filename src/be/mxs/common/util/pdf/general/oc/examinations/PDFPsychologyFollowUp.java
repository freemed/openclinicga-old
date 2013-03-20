package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFPsychologyFollowUp extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // REFERENCEPERSON
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYFU_REFERENCEPERSON");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","referenceperson"),itemValue);
                }

                // PSYCHOLOGIST
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYFU_PSYCHOLOGIST");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","psychologist"),itemValue);
                }

                // FAMILY HISTORY
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYFU_FAMILYHISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","familyhistory"),itemValue);
                }

                // PERSONAL HISTORY
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYFU_PERSONALHISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","personalhistory.and.cisiscontext"),itemValue);
                }
                

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYCHOLOGY_OBSERVATION1");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYCHOLOGY_OBSERVATION2");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYCHOLOGY_OBSERVATION3");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYCHOLOGY_OBSERVATION4");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_PSYCHOLOGY_OBSERVATION5");
                String[] lines = itemValue.split("\\$");
                if(lines.length>0){
                    cell = createHeaderCell(getTran("web","followup.chart"), 5);
                    table.addCell(cell);
                    //Now add titles
                    cell = createHeaderCell(getTran("web","date"), 1);
                    table.addCell(cell);
                    cell = createHeaderCell(getTran("web","session.report"), 2);
                    table.addCell(cell);
                    cell = createHeaderCell(getTran("web","conclusion"), 2);
                    table.addCell(cell);
                	for(int n=0;n<lines.length;n++){
                		String[] items = lines[n].split("£");
                		if(items.length>=4){
                			cell=createValueCell(items[0]+" "+items[1], 1);
                            table.addCell(cell);
                			cell=createValueCell(items[2], 2);
                            table.addCell(cell);
                			cell=createValueCell(items[3], 2);
                            table.addCell(cell);
                		}
                	}
                }
                
                // add table
                if(table.size() > 0){
                    tranTable.addCell(createContentCell(table));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}

