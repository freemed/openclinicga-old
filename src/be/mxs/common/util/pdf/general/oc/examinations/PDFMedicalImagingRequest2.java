package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

import java.util.Vector;


public class PDFMedicalImagingRequest2 extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addMIR("",1);
                addMIR("2",2);
                addMIR("3",3);
                addMIR("4",4);
                addMIR("5",5);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD MIR ---------------------------------------------------------------------------------
    private void addMIR(String itemIdx, int realIdx){
        // above the first MIR : print the RX number
        if(realIdx == 1){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // indentification rx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_IDENTIFICATION_RX");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup",IConstants_PREFIX+"ITEM_TYPE_MIR_IDENTIFICATION_RX"),getTran("web.occup",itemValue));
            }

            // add transaction to doc
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
        
        Vector list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_TYPE"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_SPECIFICATION"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_EXAMINATIONREASON"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_ORIGINAL_MODIFIED"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_ORIGINAL_MODIFIED_REASON"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_PROTOCOL"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_MIR2_NOTHING_TO_MENTION"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_URGENT"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION_REASON"+itemIdx);
        list.add(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALIDATION"+itemIdx);

        int typeIdx = Integer.parseInt(getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_TYPE"+itemIdx));

        if(verifyList(list) && typeIdx > 0){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createTitleCell(getTran("web.occup","demand")+" "+realIdx,5));

            // type
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_TYPE"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup",IConstants_PREFIX+"ITEM_TYPE_MIR_TYPE"),getTran("mir_type",""+Integer.parseInt(itemValue)));
            }

            // specification
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_SPECIFICATION"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("web.occup","specification"),itemValue);
            }

            // urgency
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_URGENT"+itemIdx);
            if(itemValue.equals("medwan.common.true")){
                addItemRow(table,getTran("Web.Occup","urgency"),getTran("web.occup","medwan.common.yes").toLowerCase());
            }

            // examination reason
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_EXAMINATIONREASON"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup","examinationreason"),itemValue);
            }

            // original_modified
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_ORIGINAL_MODIFIED"+itemIdx);
            if(itemValue.equals("medwan.common.true")){
                addItemRow(table,getTran("Web.Occup","original_modified"),getTran("web.occup","medwan.common.yes").toLowerCase());
            }

            // modification reason
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_ORIGINAL_MODIFIED_REASON"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup","medwan.common.reason"),getTran("web.occup",itemValue));
            }

            // prestation received
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION"+itemIdx);
            if(itemValue.equals("medwan.common.true")){
                addItemRow(table,getTran("Web.Occup","medwan.healthrecord.executionby"),getTran("web.occup","medwan.common.yes").toLowerCase());
            }

            // prestation reason
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION_REASON"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup","medwan.common.reason"),getTran("web.occup",itemValue));
            }

            // prestation validated
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALIDATION"+itemIdx);
            if(itemValue.equals("medwan.common.true")){
                addItemRow(table,getTran("Web.Occup","medwan.healthrecord.validationby"),getTran("web.occup","medwan.common.yes").toLowerCase());
            }

            // protocol
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_PROTOCOL"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup",IConstants_PREFIX+"ITEM_TYPE_MIR_PROTOCOL"),itemValue);
            }

            // nothing to mention
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_MIR2_NOTHING_TO_MENTION"+itemIdx);
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup",IConstants_PREFIX+"ITEM_TYPE_MIR_NOTHING_TO_MENTION"),getTran("web.occup",itemValue));
            }

            // add transaction to doc
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }

        addTransactionToDoc();
    }

}
