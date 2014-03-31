package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;

public class PDFIntensiveCareDailyNote extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                int cellCount = 0;

                //################################## PART 1 #######################################            	
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                table.setWidthPercentage(100);

                //***********************************************************************
                //*** 1 - GENERAL INFO **************************************************
                //***********************************************************************
                PdfPTable sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","general"),10));
                
                // name
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_NAME");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","name"),itemValue);
                    cellCount++;
                }

                // firstname
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_FIRSTNAME");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","firstname"),itemValue);
                    cellCount++;
                }

                // day_hospitalized_usi
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_USI");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","day_hospitalized_usi"),itemValue);
                    cellCount++;
                }

                // day_hospitalized_hospital
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DAY_HOSPITALIZED_HOSPITAL");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","day_hospitalized_hospital"),itemValue);
                    cellCount++;
                }

                // date_hour_note
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DATE_HOUR_NOTE");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","date_hour_note"),itemValue);
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 2 - Admission Note ************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","admission_note"),10));
                
                // datetime_admission_hospitalized
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DATETIME_ADMISSION_HOSPITALIZED");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","datetime_admission_hospitalized"),itemValue);
                    cellCount++;
                }

                // coming_from
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_COMING_FROM");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","coming_from"),itemValue);
                    cellCount++;
                }

                // reason_admission
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_REASON_ADMISSION");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","reason_admission"),itemValue);
                    cellCount++;
                }

                // history
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_HISTORY");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","history"),itemValue);
                    cellCount++;
                }

                // atcd
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_ATCD");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","atcd"),itemValue);
                    cellCount++;
                }

                // physical_exam
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PHYSICAL_EXAM");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","physical_exam"),itemValue);
                    cellCount++;
                }

                // supplementary_exams
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_SUPPLEMENTARY_EXAM");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","supplementary_exams"),itemValue);
                    cellCount++;
                }

                // diff_diagnosis
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DIFF_DIAGNOSIS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","diff_diagnosis"),itemValue);
                    cellCount++;
                }

                // cat
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_CAT");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","cat"),itemValue);
                    cellCount++;
                }

                // treatment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TREATMENT");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","treatment"),itemValue);
                    cellCount++;
                }

                // todo
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","todo"),itemValue);
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 3 - Observation ***************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;

                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","observation"),10));
                
                // observation
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_OBSERVATION");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","observation"),itemValue);
                    cellCount++;
                }

                // opinion_specialists
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_OPINION_SPECIALISTS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","opinion_specialists"),itemValue);
                    cellCount++;
                }

                // labo_results
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_LABO_RESULTS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","labo_results"),itemValue);
                    cellCount++;
                }

                // other_results
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_OTHER_RESULTS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","other_results"),itemValue);
                    cellCount++;
                }
                                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 4 - Summary *******************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","summary"),10));
                
                // summary
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_SUMMARY");
                if(itemValue.length() > 0){
                	sectionTable.addCell(createItemNameCell(getTran("openclinic.chuk","summary"),2));
                	sectionTable.addCell(createValueCell(itemValue,8));
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 5 - Morning parameters ********************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","morning_parameters"),10));
                
                // parameter_t
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_T");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","parameter_t"),itemValue);
                    cellCount++;
                }

                // parameter_rc
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_RC");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","parameter_rc"),itemValue);
                    cellCount++;
                }

                // parameter_ta
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_TA");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","parameter_ta"),itemValue);
                    cellCount++;
                }

                // parameter_Sat
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_RR");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","parameter_rr"),itemValue);
                    cellCount++;
                }

                // parameter_Sat
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_SAT");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","parameter_Sat"),itemValue);
                    cellCount++;
                }

                // parameter_fio2
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_FIO2");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","parameter_fio2"),itemValue);
                    cellCount++;
                }
                
                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","remarks"),itemValue);
                    cellCount++;
                }
                
                // bilan in
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_IN");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","bilan_in"),itemValue);
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	//cell.setPaddingBottom(3);
                    table.addCell(cell);
                }
                
                
				// add table
				if(table.size() > 0){
					if(contentTable.size() > 0) contentTable.addCell(emptyCell());
					contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
					tranTable.addCell(createContentCell(contentTable));
					addTransactionToDoc();
				}
				
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                table.setWidthPercentage(100);

                
                //################################## PART 2 #######################################

                //***********************************************************************
                //*** 6 - Bilan out *****************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","bilan_out"),10));
                
                // diurese
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DIURESE");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","diurese"),itemValue);
                    cellCount++;
                }

                // bilan_drains
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_DRAINS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","bilan_drains"),itemValue);
                    cellCount++;
                }

                // bilan_sonde_nasogastrique
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_BILAN_SONDE_NASOGASTRIQUE");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","bilan_sonde_nasogastrique"),itemValue);
                    cellCount++;
                }

                // vomissements
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_VOMISSEMENTS");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","vomissements"),itemValue);
                    cellCount++;
                }

                // selles
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_SELLES");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","selles"),itemValue);
                    cellCount++;
                }

                // diarrhée
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_DIARRHEE");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","diarrhée"),itemValue);
                    cellCount++;
                }

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_PARAMETER_REMARKS2");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","remarks"),itemValue);
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 7 - Medical acts **************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","medical_acts"),10));
                
                // medical_acts
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_MEDICAL_ACTS");
                if(itemValue.length() > 0){
                	sectionTable.addCell(createItemNameCell(getTran("openclinic.chuk","medical_acts"),2));
                	sectionTable.addCell(createValueCell(itemValue,8));
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 8 - Adjustments / Check-up ****************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","adjustment"),10));
                
                // adjustment
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_ADJUSTMENT");
                if(itemValue.length() > 0){
                	sectionTable.addCell(createItemNameCell(getTran("openclinic.chuk","adjustment"),2));
                	sectionTable.addCell(createValueCell(itemValue,8));
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 9 - Attitude ******************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","conduite_a_tenir"),10));
                
                // conduite_a_tenir
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_CONDUITE_A_TENIR");
                if(itemValue.length() > 0){
                	sectionTable.addCell(createItemNameCell(getTran("openclinic.chuk","conduite_a_tenir"),2));
                	sectionTable.addCell(createValueCell(itemValue,8));
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }
                
                //***********************************************************************
                //*** 10 - To-do ********************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","todo"),10));

                // what
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_WHAT");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","what"),itemValue);
                    cellCount++;
                }
                
                // when
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_WHEN");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","when"),itemValue);
                    cellCount++;
                }
                
                // labo
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_LABO");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","labo"),itemValue);
                    cellCount++;
                }
                
                // imaginary
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_IMAGINARY");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","imaginary"),itemValue);
                    cellCount++;
                }
                
                // other
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_TODO_OTHER");
                if(itemValue.length() > 0){
                    addItemRow(sectionTable,getTran("openclinic.chuk","other"),itemValue);
                    cellCount++;
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                	cell.setPaddingBottom(3);
                    table.addCell(cell);
                }

                //***********************************************************************
                //*** 11 - Remarks ******************************************************
                //***********************************************************************
                sectionTable = new PdfPTable(10);
                sectionTable.setWidthPercentage(100);
                cellCount = 0;
                
                // title
                sectionTable.addCell(createTitleCell(getTran("openclinic.chuk","remarks"),10));
                
                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DAILY_NOTE_REMARKS");
                if(itemValue.length() > 0){
                	sectionTable.addCell(createItemNameCell(getTran("openclinic.chuk","remarks"),2));
                	sectionTable.addCell(createValueCell(itemValue,8));
                    cellCount++; 
                }
                
                // even-out cells
                if(cellCount > 0 && cellCount%2!=0){
                	sectionTable.addCell(emptyCell(5)); // add one 'cell'
                }

                // add section table
                if(sectionTable.size() > 0){
                	cell = new PdfPCell(sectionTable);
                	cell.setColspan(5);
                	cell.setBorder(PdfPCell.NO_BORDER);
                    table.addCell(cell);
                }
                                              
                
                // add table
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    tranTable.addCell(createContentCell(contentTable));
                    addTransactionToDoc();
                }

                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
}
