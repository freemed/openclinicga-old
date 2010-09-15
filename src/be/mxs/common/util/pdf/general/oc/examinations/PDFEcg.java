package be.mxs.common.util.pdf.general.oc.examinations;

import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFEcg extends PDFGeneralBasic {

    // declarations
    private final String ECG_PREFIX = "be.mxs.healthrecord.ecg.diagnosis.";
    private StringBuffer results;
    private PdfPTable resultsTable;


    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_RAS").equals("")){
                    //*** RESULTS ***
                    resultsTable = new PdfPTable(1);

                    // NORMAL - ABNORMAL
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_RESULT_NORMAL_ABNORMAL");

                    if(itemValue.equalsIgnoreCase("medwan.common.true")){
                        resultsTable.addCell(createValueCell(getTran("medwan.common.normal").toLowerCase()));
                    }
                    else if(itemValue.equalsIgnoreCase("medwan.common.false")){
                        resultsTable.addCell(createValueCell(getTran("medwan.common.anormal").toLowerCase()));
                    }

                    addRow1();
                    addRow2();
                    addRow3();
                    addRow4();

                    // add resultsTable
                    if(resultsTable.size() > 0){
                        // result title
                        cell = createItemNameCell(getTran("medwan.common.result"));
                        cell.setBorder(Cell.BOX);
                        table.addCell(cell);

                        table.addCell(createCell(new PdfPCell(resultsTable),3,Cell.ALIGN_CENTER,Cell.BOX));
                    }

                    //*** REMARK ***
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_REMARK");
                    if(itemValue.length() > 0){
                        addItemRow(table,getTran("Web.Occup","medwan.common.remark"),itemValue);
                    }
                }
                // "niets te melden" checked
                else{
                    table.addCell(createValueCell(getTran("medwan.common.ras"),5));
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


    //### PRIVATE METHODS ##########################################################################

    //--- ADD ROW 1 --------------------------------------------------------------------------------
    private void addRow1(){
        results = new StringBuffer();

        // ISCHEMIE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_ISCHEMIE").equals("")){
            results.append(getTran(ECG_PREFIX+"ischemia")).append(", ");
        }

        // OLD_STROKE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_OLD_STROKE").equals("")){
            results.append(getTran(ECG_PREFIX+"old_stroke")).append(", ");
        }

        // RECENT_STROKE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_RECENT_STROKE").equals("")){
            results.append(getTran(ECG_PREFIX+"recent_stroke")).append(", ");
        }

        // PRINZMETAL
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_PRINZMETAL").equals("")){
            results.append(getTran(ECG_PREFIX+"prinzmetal")).append(", ");
        }

        // add reactions row
        if(results.length() > 0){
            // remove last comma
            if(results.indexOf(",") > 0){
                results = results.deleteCharAt(results.length()-2);
            }

            resultsTable.addCell(createValueCell(results.toString().toLowerCase()));
        }
    }

    //--- ADD ROW 2 --------------------------------------------------------------------------------
    private void addRow2(){
        results = new StringBuffer();

        // PACEMAKER
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_PACEMAKER").equals("")){
            results.append(getTran(ECG_PREFIX+"pacemaker")).append(", ");
        }

        // JUNCTIONRYTHM
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_JUNCTIONRYTHM").equals("")){
            results.append(getTran(ECG_PREFIX+"junctionrythm")).append(", ");
        }

        // PAT
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_PAT").equals("")){
            results.append(getTran(ECG_PREFIX+"pat")).append(", ");
        }

        // AUR_FLUTTER
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_AUR_FLUTTER").equals("")){
            results.append(getTran(ECG_PREFIX+"aur_flutter")).append(", ");
        }

        // AUR_EXTRASYSTOLE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_AUR_EXTRASYSTOLE").equals("")){
            results.append(getTran(ECG_PREFIX+"aur_extrasystole")).append(", ");
        }

        // AUR_FIBRILLATION
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_AUR_FIBRILLATION").equals("")){
            results.append(getTran(ECG_PREFIX+"aur_fibrillation")).append(", ");
        }

        // SINUS_ARYTHMI
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_SINUS_ARYTHMI").equals("")){
            results.append(getTran(ECG_PREFIX+"sinus_arythmia")).append(", ");
        }

        // JUNC_EXTRASYSTOLE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_JUNC_EXTRASYSTOLE").equals("")){
            results.append(getTran(ECG_PREFIX+"junc_extrasystole")).append(", ");
        }

        // WANDERING_PACEMAKER
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_WANDERING_PACEMAKER").equals("")){
            results.append(getTran(ECG_PREFIX+"wandering_pacemaker")).append(", ");
        }

        // PJT
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_PJT").equals("")){
            results.append(getTran(ECG_PREFIX+"pjt")).append(", ");
        }

        // VBLOCK_1
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_VBLOCK_1").equals("")){
            results.append(getTran(ECG_PREFIX+"avblock_1")).append(", ");
        }

        // VBLOCK_2
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_VBLOCK_2").equals("")){
            results.append(getTran(ECG_PREFIX+"avblock_2")).append(", ");
        }

        // WENKEBACH
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_WENKEBACH").equals("")){
            results.append(getTran(ECG_PREFIX+"wenkebach")).append(", ");
        }

        // WPW
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_WPW").equals("")){
            results.append(getTran(ECG_PREFIX+"wpw")).append(", ");
        }

        // AVBLOCK_TOTAL
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_AVBLOCK_TOTAL").equals("")){
            results.append(getTran(ECG_PREFIX+"avblock_total")).append(", ");
        }

        // add reactions row
        if(results.length() > 0){
            // remove last comma
            if(results.indexOf(",") > 0){
                results = results.deleteCharAt(results.length()-2);
            }

            resultsTable.addCell(createValueCell(results.toString().toLowerCase()));
        }
    }

    //--- ADD ROW 3 --------------------------------------------------------------------------------
    private void addRow3(){
        results = new StringBuffer();

        // RVENTR_EXTRASYSTOLE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_RVENTR_EXTRASYSTOLE").equals("")){
            results.append(getTran(ECG_PREFIX+"rventr_extrasystole")).append(", ");
        }

        // LVENTR_EXTRASYSTOLE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_LVENTR_EXTRASYSTOLE").equals("")){
            results.append(getTran(ECG_PREFIX+"lventr_extrasystole")).append(", ");
        }

        // VENTR_PAROX_EXTRASYSTOLE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_VENTR_PAROX_EXTRASYSTOLE").equals("")){
            results.append(getTran(ECG_PREFIX+"ventr_parox_extrasystole")).append(", ");
        }

        // VENTR_FLUTTER
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_VENTR_FLUTTER").equals("")){
            results.append(getTran(ECG_PREFIX+"ventr_flutter")).append(", ");
        }

        // LBBB_INCOMPLETE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_LBBB_INCOMPLETE").equals("")){
            results.append(getTran(ECG_PREFIX+"lbbb_incomplete")).append(", ");
        }

        // LBBB_COMPLETE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_LBBB_COMPLETE").equals("")){
            results.append(getTran(ECG_PREFIX+"lbbb_complete")).append(", ");
        }

        // RBBB_INCOMPLETE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_RBBB_INCOMPLETE").equals("")){
            results.append(getTran(ECG_PREFIX+"rbbb_incomplete")).append(", ");
        }

        // RBBB_COMPLETE
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_RBBB_COMPLETE").equals("")){
            results.append(getTran(ECG_PREFIX+"rbbb_complete")).append(", ");
        }

        // add reactions row
        if(results.length() > 0){
            // remove last comma
            if(results.indexOf(",") > 0){
                results = results.deleteCharAt(results.length()-2);
            }

            resultsTable.addCell(createValueCell(results.toString().toLowerCase()));
        }
    }

    //--- ADD ROW 4 --------------------------------------------------------------------------------
    private void addRow4(){
        results = new StringBuffer();

        // HIS_REENTRY
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_HIS_REENTRY").equals("")){
            results.append(getTran(ECG_PREFIX+"his_reentry")).append(", ");
        }

        // LAHB
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_LAHB").equals("")){
            results.append(getTran(ECG_PREFIX+"lahb")).append(", ");
        }

        // RAHB
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_RAHB").equals("")){
            results.append(getTran(ECG_PREFIX+"rahb")).append(", ");
        }

        // LVENTR_HYPERTROPHY
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_LVENTR_HYPERTROPHY").equals("")){
            results.append(getTran(ECG_PREFIX+"lventr_hypertrophy")).append(", ");
        }

        // RVENTR_HYPERTROPHY
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_ECG_DIAGNOSIS_RVENTR_HYPERTROPHY").equals("")){
            results.append(getTran(ECG_PREFIX+"rventr_hypertrophy")).append(", ");
        }

        // add reactions row
        if(results.length() > 0){
            // remove last comma
            if(results.indexOf(",") > 0){
                results = results.deleteCharAt(results.length()-2);
            }

            resultsTable.addCell(createValueCell(results.toString().toLowerCase()));
        }
    }

}
