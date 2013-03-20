package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFErgotherapyConsultation extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_REASON");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","reason"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_HISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","short.history"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_LIFEPERSPECTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","life.perspective"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_CAREPROBLEMS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","care.problems"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_OBJECTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","objective"),itemValue);
                }
                
                cell = createHeaderCell(getTran("web","activity.calendar"), 5);
                table.addCell(cell);
                
                PdfPTable table2 = new PdfPTable(6);
                cell = createHeaderCell(getTran("web","monday"), 1);
                table2.addCell(cell);
                cell = createHeaderCell(getTran("web","tuesday"), 1);
                table2.addCell(cell);
                cell = createHeaderCell(getTran("web","wednesday"), 1);
                table2.addCell(cell);
                cell = createHeaderCell(getTran("web","thursday"), 1);
                table2.addCell(cell);
                cell = createHeaderCell(getTran("web","friday"), 1);
                table2.addCell(cell);
                cell = createHeaderCell(getTran("web","saturday"), 1);
                table2.addCell(cell);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_MONDAY");
    			cell=createValueCell(getTran("ergotherapy.activity",itemValue), 1);
    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    			table2.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_TUESDAY");
    			cell=createValueCell(getTran("ergotherapy.activity",itemValue), 1);
    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    			table2.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_WEDNESDAY");
    			cell=createValueCell(getTran("ergotherapy.activity",itemValue), 1);
    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    			table2.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_THURSDAY");
    			cell=createValueCell(getTran("ergotherapy.activity",itemValue), 1);
    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    			table2.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_FRIDAY");
    			cell=createValueCell(getTran("ergotherapy.activity",itemValue), 1);
    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    			table2.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_SATURDAY");
    			cell=createValueCell(getTran("ergotherapy.activity",itemValue), 1);
    			cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
    			table2.addCell(cell);
    			cell=new PdfPCell(table2);
    			cell.setColspan(5);
    			table.addCell(cell);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_OBSERVATION1");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_OBSERVATION2");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_OBSERVATION3");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_OBSERVATION4");
                itemValue += getItemValue(IConstants_PREFIX+"ITEM_TYPE_ERGOTHERAPY_OBSERVATION5");
                String[] lines = itemValue.split("\\$");
                if(lines.length>0){
                    cell = createHeaderCell(getTran("web","observations"), 5);
                    table.addCell(cell);
                    //Now add titles
                    cell = createHeaderCell(getTran("web","date"), 1);
                    table.addCell(cell);
                    cell = createHeaderCell(getTran("web","observation"), 2);
                    table.addCell(cell);
                    cell = createHeaderCell(getTran("web","conclusion"), 2);
                    table.addCell(cell);
                	for(int n=0;n<lines.length;n++){
                		String[] items = lines[n].split("£");
                		if(items.length>=3){
                			cell=createValueCell(items[0], 1);
                            table.addCell(cell);
                			cell=createValueCell(items[1], 2);
                            table.addCell(cell);
                			cell=createValueCell(items[2], 2);
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

