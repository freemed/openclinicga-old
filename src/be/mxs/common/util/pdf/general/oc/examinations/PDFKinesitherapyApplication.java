package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFKinesitherapyApplication extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                Vector itemList = new Vector();
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_DIAGNOSTIC");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_INTERVENTION");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_ACTS_ASKED");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_NR_MEETINGS");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_DAY");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_WEEK");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_REMARKS");

                if(verifyList(itemList)){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);

                    // diagnostic
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_DIAGNOSTIC");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","diagnostic"),itemValue);
                    }

                    // intervention
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_INTERVENTION");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","intervention"),itemValue);
                    }

                    // acts.asked
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_ACTS_ASKED");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","acts.asked"),itemValue);
                    }

                    // nr.meetings
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_NR_MEETINGS");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","nr.meetings"),itemValue);
                    }

                    //*** frequency ***
                    PdfPTable freqTable = new PdfPTable(1);

                    //* day *
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_DAY");
                    if(itemValue.length() > 0){
                        freqTable.addCell(createValueCell(itemValue+" /"+getTran("units","day")));
                    }

                    //* week *
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_FREQUENCY_WEEK");
                    if(itemValue.length() > 0){
                        freqTable.addCell(createValueCell(itemValue+" /"+getTran("units","week")));
                    }

                    if(freqTable.size() > 0){
                        table.addCell(createItemNameCell(getTran("openclinic.chuk","frequency"),2));
                        table.addCell(createCell(new PdfPCell(freqTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    }

                    // remarks
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_APPLICATION_REMARKS");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                    }

                    // add transaction to doc
                    if(table.size() > 0){
                        if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                        contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                        tranTable.addCell(createContentCell(contentTable));
                        addTransactionToDoc();
                    }
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

}

