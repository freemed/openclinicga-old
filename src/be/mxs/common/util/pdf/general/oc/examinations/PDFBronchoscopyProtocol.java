package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFBronchoscopyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);
                int itemCount = 0;

                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                    itemCount++;
                }

                // premedication
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_PREMEDICATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","premedication"),itemValue);
                    itemCount++;
                }

                // endoscopy_type
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_ENDOSCOPY_TYPE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endoscopy_type"),itemValue);
                    itemCount++;
                }

                // pharynx_glottis
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_PHARYNX_GLOTTIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","pharynx_glottis"),itemValue);
                    itemCount++;
                }

                // trachea
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_TRACHEA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","trachea"),itemValue);
                    itemCount++;
                }

                // carène_principale
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_CARENE_PRINCIPALE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","carène_principale"),itemValue);
                    itemCount++;
                }

                // left_bronchitis
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_LEFT_BRONCHITIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","left_bronchitis"),itemValue);
                    itemCount++;
                }

                // right_bronchitis
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_RIGHT_BRONCHITIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","right_bronchitis"),itemValue);
                    itemCount++;
                }

                // add cell to achieve an even number of displayed cells
                if(itemCount%2==1){
                    cell = new PdfPCell();
                    cell.setColspan(5);
                    cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                }

                //*** investigations_done row 1 (inhalation) **************************************
                PdfPTable invTable = new PdfPTable(1);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_INHALATION");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    String invRow1 = getTran("openclinic.chuk","inhalation");
                    invTable.addCell(createValueCell(invRow1));
                }

                //*** investigations_done row 2 (alvelolaire) *************************************
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_BRONCHO_ALVELOLAIRE");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    String invRow2 = getTran("openclinic.chuk","broncho_alvélolaire")+" : ";

                    String cc = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_PHYSIOLOGICAL_SERUM");
                    if(cc.length() > 0){
                        invRow2+= cc+"cc "+getTran("openclinic.chuk","physiological_serum")+", ";
                    }

                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_ZIEHL_COLOR");
                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        invRow2+= getTran("openclinic.chuk","Ziehl_color")+", ";
                    }

                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_GRAM_COLOR");
                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        invRow2+= getTran("openclinic.chuk","gram_color")+", ";
                    }

                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_BACTERIOLOGICAL_CULTURE");
                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        invRow2+= getTran("openclinic.chuk","bacteriological_culture")+", ";
                    }

                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_BK_CULTURE");
                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        invRow2+= getTran("openclinic.chuk","BK_culture")+", ";
                    }

                    if(invRow2.length() > 0){
                        // remove last comma
                        if(invRow2.indexOf(", ") > -1){
                            invRow2 = invRow2.substring(0,invRow2.length()-2);
                        }

                        invTable.addCell(createValueCell(invRow2));
                    }
                }

                //*** investigations_done row 3 (transbronchitis) *********************************
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_BIOPSIES_TRANSBRONCHITIS");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    String invRow3 = getTran("openclinic.chuk","biopsies_transbronchitis")+" : ";

                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_PERIPHERY");
                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        invRow3+= getTran("openclinic.chuk","peripheries")+", ";
                    }

                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_CENTRAL");
                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        invRow3+= getTran("openclinic.chuk","central")+", ";
                    }

                    if(invRow3.length() > 0){
                        // remove last comma
                        if(invRow3.indexOf(", ") > -1){
                            invRow3 = invRow3.substring(0,invRow3.length()-2);
                        }

                        invTable.addCell(createValueCell(invRow3));
                    }
                }

                // add investigations table
                if(invTable.size() > 0){
                    cell = createItemNameCell(getTran("openclinic.chuk","investigations_done"),2);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);

                    cell = createCell(new PdfPCell(invTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                    cell.setColspan(8);
                    table.addCell(cell);
                }               

                itemCount = 0;

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                    itemCount++;
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BRONCHOSCOPY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
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
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
                
                addDiagnosisEncoding();

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
        //cell.setFixedHeight(40); // difference
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }
    
}
