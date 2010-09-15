package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

import java.awt.*;
import java.sql.Connection;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFOphtalmologyOperationProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // start hour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_STARTHOUR");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","start"),itemValue);
                }

                // end hour
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_ENDHOUR");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","end"),itemValue);
                }

                // surgeon
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_SURGEON");
                if(itemValue.length() > 0){
                	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    itemValue = ScreenHelper.getFullUserName(itemValue,ad_conn);
                    ad_conn.close();
                    addItemRow(table,getTran("openclinic.chuk","surgeon"),itemValue);
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                //*** EYE-REMARKS *********************************************
                contentTable = new PdfPTable(1);
                PdfPTable eyesTable = new PdfPTable(7);
                String itemValueRight, itemValueLeft;

                // header
                cell = createBorderlessCell("",1);
                cell.setBorder(Cell.BOX);
                cell.setBorderColor(Color.WHITE);
                eyesTable.addCell(cell);
                eyesTable.addCell(createTitleCell(getTran("openclinic.chuk","right.eye"),3));
                eyesTable.addCell(createTitleCell(getTran("openclinic.chuk","left.eye"),3));

                // diagnosis
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","diagnosis"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_DIAGNOSIS_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // vision_preop
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","vision_preop"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_VISION_PREOP_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_VISION_PREOP_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // intervention
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","intervention"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_INTERVENTION_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // vision_postop
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","vision_postop"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_VISION_POSTOP_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_VISION_POSTOP_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // complications
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","complications"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_COMPLICATIONS_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // care.post.op
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","care.post.op"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CARE_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // conclusion
                eyesTable.addCell(createItemNameCell(getTran("openclinic.chuk","conclusion"),1));
                itemValueRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_RIGHT");
                itemValueLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_OPERATION_PROTOCOL_CONCLUSION_LEFT");
                if(itemValueRight.length() > 0 || itemValueLeft.length() > 0){
                    eyesTable.addCell(createValueCell(itemValueRight,3));
                    eyesTable.addCell(createValueCell(itemValueLeft,3));
                }

                // add eyes table
                if(eyesTable.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(eyesTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
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

}
