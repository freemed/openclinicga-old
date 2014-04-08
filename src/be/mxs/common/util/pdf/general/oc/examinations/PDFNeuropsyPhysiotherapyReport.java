package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFNeuropsyPhysiotherapyReport extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                //*********************************************************************************
                //*** SUBJECTIVE EXAMINATION ******************************************************
                //*********************************************************************************
            	contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                // title
                table.addCell(createHeaderCell(getTran("web","subjective.examination"),5));

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_REASONFORENCOUNTER");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","reason.for.encounter"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_DISEASEHISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","disease.history"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_DISEASEEVOLUTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","disease.evolution"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_ANTECEDENTS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","antecedents"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_PSYPROFILE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","psychological.profile"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
                    addTransactionToDoc();
                }
                
                //*********************************************************************************
                //*** OBJECTIVE EXAMINATION *******************************************************
                //*********************************************************************************
            	contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                // title
                table.addCell(createHeaderCell(getTran("web","objective.examination"),5));
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_INSPECTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","inspection"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_PALPATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","palpation"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_PAINSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","pain.status"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_JOINTSSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","joints.status"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_MUSCLESSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","muscles.status"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_NEUROLOGYSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","neurology.status"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_FUNCTIONALSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","functional.status"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_DIAGNOSIS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","diagnosis"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_TREATMENTGOAL");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","treatment.goal"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPPR_TREATMENTMEANS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","treatment.means"),itemValue);
                }
                
                // add table
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
                    addTransactionToDoc();
                }

                //*** diagnoses ***
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}

