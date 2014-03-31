package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

public class PDFOesoPhagoGastroDuoDenoScopyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{        	
            if(transactionVO.getItems().size() >= minNumberOfItems){  
                //*** PART 1 ************************************************** 
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);

                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                }

                // premedication
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PREMEDICATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","premedication"),itemValue);
                }

                // endoscopy_type
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ENDOSCOPY_TYPE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endoscopy_type"),itemValue);
                }

                // oesophago
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_OESOPHAGO");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","oesophago"),itemValue);
                }

                // add table
                if(table.size() > 0){
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                }

                //*** PART 2 **************************************************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(10);

                // cardia (one whole row)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CARDIA");
                if(itemValue.length() > 0){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","cardia")));
                    
                    cell = createValueCell(itemValue);
                    cell.setColspan(8);
                    table.addCell(cell);
                }

                // stomach
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_STOMACH");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","stomach"),itemValue);
                }

                // pylorus
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PYLORUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","pylorus"),itemValue);
                }

                // liquide_quantity_aspect
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_LIQUIDE_QUANTITY_ASPECT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","liquide_quantity_aspect"),itemValue);
                }

                // bulb
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BULB");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","bulb"),itemValue);
                }

                // pH
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_PH");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","pH"),itemValue);
                }

                // duodenum
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_DUODENUM");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","duodenum"),itemValue);
                }

                // fundus
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_FUNDUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","fundus"),itemValue);
                }
                
                //*** investigations_done (BIOPSY) ***
                String investigations = "";

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_BIOSCOPY");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy");
                }
                
                if(investigations.length()==0) investigations = "/"; // none
                addItemRow(table,getTran("openclinic.chuk","investigations_done"),investigations);

                // antre
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_ANTRE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","antre"),itemValue);
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }

                //*** PART 3 **************************************************
                // remarks (one whole row)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OESOPHAGOGASTRODUODENOSCOPY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    table.addCell(createItemNameCell(getTran("openclinic.chuk","remarks")));
                    
                    cell = createValueCell(itemValue);
                    cell.setColspan(8);
                    table.addCell(cell);
                }

                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }
                
                //*** PART 4 **************************************************
                addDiagnosisEncoding();
                
                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}
