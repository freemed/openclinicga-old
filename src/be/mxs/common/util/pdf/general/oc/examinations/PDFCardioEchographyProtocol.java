package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;


/**
 * User: ssm
 * Date: 13-jul-2007
 */
public class PDFCardioEchographyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(10);
                int itemCount = 0;

                // motive/reason (1 whole row)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                	cell = createItemNameCell(getTran("openclinic.chuk","motive"),2);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);
                    table.addCell(createValueCell(itemValue,8));
                    itemCount++;
                }

                //*** LOOK FIRST **********************************************
                String lookFirst = "";                
                
                // lookFirst - Transthoracic
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_TRANS");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(lookFirst.length() > 0) lookFirst+=", ";
                    lookFirst+= getTran("openclinic.chuk","tm"); 
                }

                // lookFirst - Oesophagus 
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_LOOK_OESO");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(lookFirst.length() > 0) lookFirst+=", ";
                    lookFirst+= getTran("openclinic.chuk","2d"); 
                }

                if(lookFirst.length() > 0){
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","lookFirst"),2);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);
                    
                    table.addCell(createValueCell(lookFirst));
                    itemCount++;
                }
                
                //*** MODE ****************************************************
                String mode = "";
                
                // mode - tm
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_TM");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(mode.length() > 0) mode+=", ";
                    mode+= getTran("openclinic.chuk","tm"); 
                }

                // mode - 2d
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_2D");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(mode.length() > 0) mode+=", ";
                    mode+= getTran("openclinic.chuk","2d"); 
                }

                // mode - doppler
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MODE_DOPPLER");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(mode.length() > 0) mode+=", ";
                    mode+= getTran("openclinic.chuk","doppler"); 
                }
                
                if(mode.length() > 0){
                    // title
                    cell = createItemNameCell(getTran("openclinic.chuk","mode"),2);
                    cell.setBackgroundColor(BGCOLOR_LIGHT);
                    table.addCell(cell);
                    
                    table.addCell(createValueCell(mode));
                    itemCount++;
                }
                                                
                // ao
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_AO");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","ao"),itemValue);
                    itemCount++;
                }

                // septum
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_SEPTUM");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","septum"),itemValue);
                    itemCount++;
                }

                // og
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OG");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","og"),itemValue);
                    itemCount++;
                }

                // paroi_post
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PAROI_POST");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","paroi_post"),itemValue);
                    itemCount++;
                }

                // dtdvgA
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","dtdvg")+" A",itemValue);
                    itemCount++;
                }

                // fe
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_FE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","fe"),itemValue);
                    itemCount++;
                }

                // dtdvgB
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DTDVGB");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","dtdvg")+" B",itemValue);
                    itemCount++;
                }

                // raccouc
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_RACCOUC");
                if(itemValue.length() > 0){
                    addItemRow(table,"% "+getTran("openclinic.chuk","raccouc"),itemValue);
                    itemCount++;
                }

                // vd
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VD");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","vd"),itemValue);
                    itemCount++;
                }

                // pericardium
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_PERICARDIUM");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","pericardium"),itemValue);
                    itemCount++;
                }

                // mitral_valve
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_MITRAL_VALVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","mitral_valve"),itemValue);
                    itemCount++;
                }

                // valve_aort
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_AORT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","valve_aort"),itemValue);
                    itemCount++;
                }

                // valve_tric
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_TRIC");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","valve_tric"),itemValue);
                    itemCount++;
                }

                // valve_pulm
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_VALVE_PULM");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","valve_pulm"),itemValue);
                    itemCount++;
                }

                // other
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_OTHER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","other"),itemValue);
                    itemCount++;
                }

                // doppler
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_DOPPLER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","doppler"),itemValue);
                    itemCount++;
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                    itemCount++;
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIO_ECHOGRAPHY_PROTOCOL_REMARKS");
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
                    tranTable.addCell(new PdfPCell(table));
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
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }

}


