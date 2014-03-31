package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFPostPartumChild extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);
                int itemCount = 0;

                // liver
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ABDOMINAL_ECHOGRAPHY_PROTOCOL_LIVER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","liver"),itemValue);
                    itemCount++;
                }

                // weight
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_CHILD_WEIGHT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","weight"),itemValue+" "+getTran("units","gr"));
                    itemCount++;
                }

                // paleness.conjunctiva
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_CONJUNCTIVA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","paleness.conjunctiva"),itemValue);
                    itemCount++;
                }

                // umbilicus
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_UMBILICUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","umbilicus"),itemValue);
                    itemCount++;
                }

                // temperature
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_TEMPERATURE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("gynaeco","temperature"),itemValue+" "+getTran("unit","degreesCelcius"));
                    itemCount++;
                }

                // observation
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_OBSERVATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","observation"),itemValue);
                    itemCount++;
                }

                // treatment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_TREATMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","treatment"),itemValue);
                    itemCount++;
                }

                //*** alimentation ***
                String alimentation = "";
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_ALIMENTATION_MATERNELLE");
                if(itemValue.equals("medwan.common.true")){
                    alimentation+= getTran("gynaeco.alimentation","maternelle")+", ";
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_ALIMENTATION_ARTIFICIELLE");
                if(itemValue.equals("medwan.common.true")){
                    alimentation+= getTran("gynaeco.alimentation","artificielle")+", ";
                }

                if(alimentation.length() > 0){
                    // remove last comma
                    if(alimentation.indexOf(",") > -1){
                        alimentation = alimentation.substring(0,alimentation.length()-2).toLowerCase();
                    }

                    // regurgitation
                    String regurgitation = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_REGURGITATION");
                    if(regurgitation.length() > 0){
                        if(regurgitation.equals("medwan.common.yes") || regurgitation.equals("medwan.common.no")){
                            regurgitation = getTran("web.occup",regurgitation).toLowerCase();
                        }
                        
                        alimentation = alimentation+"\n"+getTran("gynaeco","regurgitation")+" : "+regurgitation;
                    }

                    addItemRow(table,getTran("gynaeco","alimentation").toLowerCase(),alimentation);
                    itemCount++;
                }

                // ictere
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PPC_ICTERE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("gynaeco","ictere"),getTran("web.occup",itemValue).toLowerCase());
                    itemCount++;
                }

                // add cell to achieve an even number of displayed cells
                if(itemCount%2==1){
                    cell = new PdfPCell();
                    cell.setColspan(5);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1, PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD ITEM ROW ----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        cell = createItemNameCell(itemName);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }
    
}
