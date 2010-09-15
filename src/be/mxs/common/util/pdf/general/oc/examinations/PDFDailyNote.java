package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFDailyNote extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addVaria1();  
                addAdmission();
                addObservation();
                addMorning();
                addBilan();
                addVaria2();
                addTodo();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD VARIA1 ------------------------------------------------------------------------------
    private void addVaria1(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);
        int itemCount = 0;

        // name
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_NAME");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","name"),itemValue);
            itemCount++;
        }

        // firstname
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_FIRSTNAME");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","firstname"),itemValue);
            itemCount++;
        }

        // day_hospitalized_usi
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_USI");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","day_hospitalized_usi"),itemValue);
            itemCount++;
        }

        // day_hospitalized_hospital
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_HOSPITAL");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","day_hospitalized_hospital"),itemValue);
            itemCount++;
        }

        // date_hour_note
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DATE_HOUR_NOTE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","date_hour_note"),itemValue);
            itemCount++;
        }

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD ADMISSION ---------------------------------------------------------------------------
    private void addAdmission(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);
        int itemCount = 0;

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","admission_note"),10));

        // datetime_admission_hospitalized
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DATETIME_ADMISSION_HOSPITALIZED");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","datetime_admission_hospitalized"),itemValue);
            itemCount++;
        }

        // coming_from
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_COMING_FROM");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","coming_from"),itemValue);
            itemCount++;
        }

        // reason_admission
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_REASON_ADMISSION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","reason_admission"),itemValue);
            itemCount++;
        }

        // history
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_HISTORY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","history"),itemValue);
            itemCount++;
        }

        // atcd
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_ATCD");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","atcd"),itemValue);
            itemCount++;
        }

        // physical_exam
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PHYSICAL_EXAM");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","physical_exam"),itemValue);
            itemCount++;
        }

        // supplementary_exams
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_SUPPLEMENTARY_EXAM");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","supplementary_exams"),itemValue);
            itemCount++;
        }

        // diff_diagnosis
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DIFF_DIAGNOSIS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","diff_diagnosis"),itemValue);
            itemCount++;
        }

        // cat
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_CAT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","cat"),itemValue);
            itemCount++;
        }

        // treatment
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TREATMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","treatment"),itemValue);
            itemCount++;
        }

        // to do
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","todo"),itemValue);
            itemCount++;
        }

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD OBSERVATION -------------------------------------------------------------------------
    private void addObservation(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);
        int itemCount = 0;

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","observation"),10));

        // observation
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_OBSERVATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","observation"),itemValue);
            itemCount++;
        }

        // opinion_specialists
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_OPINION_SPECIALISTS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","opinion_specialists"),itemValue);
            itemCount++;
        }

        // labo_results
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_LABO_RESULTS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","labo_results"),itemValue);
            itemCount++;
        }

        // other_results
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_OTHER_RESULTS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","other_results"),itemValue);
            itemCount++;
        }

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        //*** summary ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_SUMMARY");
        if(itemValue.length() > 0){
            table.addCell(createSpacerCell(10));
            
            table.addCell(createItemNameCell(getTran("openclinic.chuk","summary"),4));
            table.addCell(createValueCell(itemValue,6));
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD MORNING -----------------------------------------------------------------------------
    private void addMorning(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);  
        int itemCount = 0;

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","morning_parameters"),10));

        // parameter_t
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_T");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","parameter_t"),itemValue);
            itemCount++;
        }

        // parameter_rc
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_RC");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","parameter_rc"),itemValue);
            itemCount++;
        }

        // parameter_ta
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_TA");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","parameter_ta"),itemValue);
            itemCount++;
        }

        // parameter_rr
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_RR");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","parameter_rr"),itemValue);
            itemCount++;
        }

        // parameter_sat
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_SAT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","parameter_sat"),itemValue);
            itemCount++;
        }

        // parameter_fio2
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_FIO2");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","parameter_fio2"),itemValue);
            itemCount++;
        }

        // remarks
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
            itemCount++;
        }

        // bilan_in
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_IN");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","bilan_in"),itemValue);
            itemCount++;
        }

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }


    //--- ADD BILAN -------------------------------------------------------------------------------
    private void addBilan(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);                                         
        int itemCount = 0;

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","bilan_out"),10));

        // diurese
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DIURESE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","diurese"),itemValue);
            itemCount++;
        }

        // bilan_drains
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_DRAINS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","bilan_drains"),itemValue);
            itemCount++;
        }

        // bilan_sonde_nasogastrique
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_SONDE_NASOGASTRIQUE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","bilan_sonde_nasogastrique"),itemValue);
            itemCount++;
        }

        // vomissements
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_VOMISSEMENTS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","vomissements"),itemValue);
            itemCount++;
        }

        // selles
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_SELLES");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","selles"),itemValue);
            itemCount++;
        }

        // diarrhée
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DIARRHEE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","diarrhée"),itemValue);
            itemCount++;
        }

        // remarks
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS2");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
            itemCount++;
        }

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD VARIA 2 -----------------------------------------------------------------------------
    private void addVaria2(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        //*** medical_acts ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_MEDICAL_ACTS");
        if(itemValue.length() > 0){
            table.addCell(createItemNameCell(getTran("openclinic.chuk","medical_acts")));
            table.addCell(createValueCell(itemValue));
        }

        //*** adjustment ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_ADJUSTMENT");
        if(itemValue.length() > 0){
            table.addCell(createItemNameCell(getTran("openclinic.chuk","adjustment")));
            table.addCell(createValueCell(itemValue));
        }

        //*** conduite_a_tenir ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_CONDUITE_A_TENIR");
        if(itemValue.length() > 0){
            table.addCell(createItemNameCell(getTran("openclinic.chuk","conduite_a_tenir")));
            table.addCell(createValueCell(itemValue));
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD TO DO -------------------------------------------------------------------------------
    private void addTodo(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(10);
        int itemCount = 0;

        // title
        table.addCell(createTitleCell(getTran("openclinic.chuk","todo"),10));

        // what
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_WHAT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","what"),itemValue);
            itemCount++;
        }

        // when
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_WHEN");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","when"),itemValue);
            itemCount++;
        }

        // labo
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_LABO");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","labo"),itemValue);
            itemCount++;
        }

        // imaginary
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_IMAGINARY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","imaginary"),itemValue);
            itemCount++;
        }

        // other
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_OTHER");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","other"),itemValue);
            itemCount++;
        }

        // add cell to achieve an even number of displayed cells
        if(itemCount%2==1){
            cell = new PdfPCell();
            cell.setColspan(5);
            cell.setBorder(Cell.NO_BORDER);
            table.addCell(cell);
        }

        //*** remarks ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_REMARKS");
        if(itemValue.length() > 0){
            table.addCell(createSpacerCell(10));

            table.addCell(createItemNameCell(getTran("openclinic.chuk","remarks"),4));
            table.addCell(createValueCell(itemValue,6));
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }
    
    //--- ADD ITEM ROW ----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        cell = createItemNameCell(itemName);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        table.addCell(cell);
        table.addCell(createValueCell(itemValue));
    }

    //--- CREATE SPACER CELL ----------------------------------------------------------------------
    private PdfPCell createSpacerCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        return cell;
    }

}

