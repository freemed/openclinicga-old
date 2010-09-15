package be.mxs.common.util.pdf.official.chuk.examinations;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import net.admin.AdminPrivateContact;

public class chukPDFOfficialPhysioConsultation extends PDFOfficialBasic {

    // declarations
    private int pageWidth = 100;


    //--- ADD HEADER ------------------------------------------------------------------------------
    protected void addHeader(){
        try{
            // get required data
            String sUnit = "", sFunction = "", sUnitCode = "";

            AdminPrivateContact apc = ScreenHelper.getActivePrivate(patient);
            String patientAddress = "";
            if (apc!=null){
                patientAddress = apc.address+", "+apc.zipcode+" "+apc.city;
            }

            // put data in tables..
            PdfPTable headerTable = new PdfPTable(4);
            headerTable.setWidthPercentage(pageWidth);

            // ROW 1 - cell 1,2 : left part of title
            cell = createTitle(getTran(transactionVO.getTransactionType()),Font.BOLD,10,2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            headerTable.addCell(cell);

            // ROW 1 - cell 3,4 : right part of title
            cell = createTitle(getTran("web","immatnew")+" "+checkString(patient.getID("immatnew")),Font.BOLD,10,2);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            headerTable.addCell(cell);

            table = new PdfPTable(5);

            // ROW 2.1 : werknemer - naam
            table.addCell(createValueCell(getTran("web","patient"),Font.NORMAL,8,1,false));
            table.addCell(createValueCell(getTran("web","name"),Font.NORMAL,8,1,false));
            String patientFullName = patient.lastname+" "+patient.firstname;
            table.addCell(createValueCell(patientFullName,Font.BOLD,8,3,false));

            // ROW 2.2 : werknemer - adres
            table.addCell(emptyCell(1));
            table.addCell(createValueCell(getTran("web","address"),Font.NORMAL,8,1,false));
            table.addCell(createValueCell(patientAddress,Font.NORMAL,8,3,false));

            // ROW 2.3 : onderzochte werknemer - date of birth
            table.addCell(emptyCell(1));
            table.addCell(createValueCell(getTran("web","dateofbirth"),Font.NORMAL,8,1,false));
            table.addCell(createValueCell(patient.dateOfBirth,Font.NORMAL,8,3,false));

            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // ROW 3 : werkgever nr
            table = new PdfPTable(5);
            table.addCell(createValueCell(getTran("web","service"),Font.NORMAL,8,2,false));
            table.addCell(createValueCell(sUnitCode,Font.NORMAL,8,3,false));
            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // ROW 4 : naam en adres werkgever
            table = new PdfPTable(5);
            table.addCell(createValueCell(getTran("web","serviceaddress"),Font.NORMAL,8,2,false));
            table.addCell(createValueCell(sUnit,Font.NORMAL,8,3,false));
            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // ROW 5 : omschrijving functie werkpost of activiteit
            table = new PdfPTable(5);
            table.addCell(createValueCell(getTran("web","function"),Font.NORMAL,8,2,false));
            table.addCell(createValueCell(sFunction,Font.NORMAL,8,3,false));
            headerTable.addCell(createCell(new PdfPCell(table),4,Cell.ALIGN_LEFT,Cell.BOX));

            // spacer below page-header
            headerTable.addCell(createBorderlessCell("",10,4));

            // add headertable to document
            doc.add(headerTable);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            table = new PdfPTable(5);
            table.setWidthPercentage(pageWidth);

            // MEDICAL DIAGNOSIS
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC"),itemValue);
            }

            // ANAMNESE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_ANAMNESE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_ANAMNESE"),itemValue);
            }

            // PHYSICAL EXAMINATION
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS"),itemValue);
            }

            // PHYSICAL DIAGNOSE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS"),itemValue);
            }

            // PHYSICAL TREATMENT PLAN
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS"),itemValue);
            }

            // RE-EVALUATION
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_REEVAL");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_REEVAL"),itemValue);
            }

            // END OF TREATMENT
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT"),itemValue);
            }
            
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
}
