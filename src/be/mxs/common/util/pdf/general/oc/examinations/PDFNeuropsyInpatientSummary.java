package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFNeuropsyInpatientSummary extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                if(itemValue.length() > 0){
                    addEncounterDiagnosticsRow(table, itemValue);
                }
                
                addBlankRow();

                cell = createHeaderCell(getTran("web","short.analysis.actual.admission"), 5);
                table.addCell(cell);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_CLINICALADMISSIONSUMMARY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","clinical.admission.summary"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_PSYSOMHISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","psychiatric.and.somatic.history"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_COMPLEMENTARYEXAMS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","complentary.exams"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_EVOLUTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","evolution.and.treatment"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_SOCIALSUMMARY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","social.summary"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_PSYCHOLOGICALSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","psychological.status"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_DIAGNOSTICDISCUSSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","diagnostic.discussion"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_DISCHARGETREATMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","discharge.treatment"),itemValue);
                }
                
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_RECCOMMENDATIONS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","specific.reccommendations"),itemValue);
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

