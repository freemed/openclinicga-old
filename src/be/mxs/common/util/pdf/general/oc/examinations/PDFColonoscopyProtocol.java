package be.mxs.common.util.pdf.general.oc.examinations;

import java.sql.Timestamp;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.Diagnosis;
import be.openclinic.medical.ReasonForEncounter;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFColonoscopyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                //*********************************************************************************
                //*** PART 1 - REGULAR-ITEMS ******************************************************
                //*********************************************************************************
                
                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                }

                // premedication
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_PREMEDICATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","premedication"),itemValue);
                }

                // endoscopy_type
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_ENDOSCOPY_TYPE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","endoscopy_type"),itemValue);
                }

                // examination_description
                itemValue = getItemValue(IConstants_PREFIX+"v");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","examination_description"),itemValue);
                }

                //*** investigations_done (BIOSCOPY) ***
                String investigations = "";

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_BIOSCOPY");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy");
                }

                /*
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY2");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy2");
                }
                */

                if(investigations.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","investigations_done"),investigations);
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COLONOSCOPY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
                                
                //*********************************************************************************
                //*** PART 2 - CODE-ITEMS *********************************************************
                //*********************************************************************************
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

