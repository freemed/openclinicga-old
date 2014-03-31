package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFNeuropsyInpatientSummary extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);
                
                // subtitle
                table.addCell(createSubtitleCell(getTran("web","short.analysis.actual.admission"),5));

                // clinical.admission.summary
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_CLINICALADMISSIONSUMMARY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","clinical.admission.summary"),itemValue);
                }

                // psychiatric.and.somatic.history
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_PSYSOMHISTORY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","psychiatric.and.somatic.history"),itemValue);
                }

                // complentary.exams
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_COMPLEMENTARYEXAMS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","complentary.exams"),itemValue);
                }

                // evolution.and.treatment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_EVOLUTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","evolution.and.treatment"),itemValue);
                }
                
                // social.summary
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_SOCIALSUMMARY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","social.summary"),itemValue);
                }
                
                // psychological.status
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_PSYCHOLOGICALSTATUS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","psychological.status"),itemValue);
                }
                
                // diagnostic.discussion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_DIAGNOSTICDISCUSSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","diagnostic.discussion"),itemValue);
                }
                
                // discharge.treatment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_DISCHARGETREATMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","discharge.treatment"),itemValue);
                }
                
                // specific.reccommendations
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NPIS_RECCOMMENDATIONS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","specific.reccommendations"),itemValue);
                }

                /*
                // diagnoses
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                if(itemValue.length() > 0){
                    addEncounterDiagnosticsRow(table, itemValue);
                    addBlankRow();
                }
                */
                
                // add table
                if(table.size() > 1){
                    tranTable.addCell(createContentCell(table));
                    addTransactionToDoc();
                }
                
                // diagnoses
                addDiagnosisEncoding(true,true,true);
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}

