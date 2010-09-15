package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;
import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFOphtalmologyConsultation extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addVaria1();
                addVisionAcuityAndPupil();
                addBioMicroscopyAndOcularTension();
                addVaria2();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD VARIA 1 -----------------------------------------------------------------------------
    private void addVaria1(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // context
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CONTEXT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","context"),getTran("web.occup",itemValue));
        }

        // anamnese
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_ANAMNESE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","anamnese"),itemValue);
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD VISION ACUITY AND PUPIL -------------------------------------------------------------
    private void addVisionAcuityAndPupil(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        
        PdfPTable visionTable = new PdfPTable(1);

        //*** current.glasses ****
        Vector currentGlassesItems = new Vector();
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD");
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D");
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX");
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG");
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D");
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX");
        currentGlassesItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_ADD");

        if(verifyList(currentGlassesItems)){
            PdfPTable odogTable = new PdfPTable(9);

            //--- title od ---
            cell = createItemNameCell(getTran("openclinic.chuk","od"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // od
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD");
            odogTable.addCell(createValueCell(itemValue,2));

            // od d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // od dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OD_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            //--- title og ---
            cell = createItemNameCell(getTran("openclinic.chuk","og"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // og
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG");
            odogTable.addCell(createValueCell(itemValue,2));

            // og d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // og dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CURRENT_GLASSES_OG_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            // add odog table
            if(odogTable.size() > 0){
                PdfPTable currentGlassesTable = new PdfPTable(16);

                // title
                cell = createItemNameCell(getTran("openclinic.chuk","current.glasses"),3);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                currentGlassesTable.addCell(cell);

                currentGlassesTable.addCell(createCell(new PdfPCell(odogTable),9,Cell.ALIGN_CENTER,Cell.BOX));

                // add
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD");
                cell = createValueCell("Add+ "+itemValue+" D",4); 
                cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                currentGlassesTable.addCell(cell);

                visionTable.addCell(createCell(new PdfPCell(currentGlassesTable),1,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        //*** autorefractor ***
        Vector autorefactorItems = new Vector();
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD");
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D");
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX");
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG");
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D");
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX");
        autorefactorItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD");

        if(verifyList(autorefactorItems)){
            PdfPTable odogTable = new PdfPTable(9);

            //--- title od ---
            cell = createItemNameCell(getTran("openclinic.chuk","od"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // od
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD");
            odogTable.addCell(createValueCell(itemValue,2));

            // od d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // od dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OD_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            //--- title og ---
            cell = createItemNameCell(getTran("openclinic.chuk","og"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // og
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG");
            odogTable.addCell(createValueCell(itemValue,2));

            // og d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // og dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_OG_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            // add refactor table
            if(odogTable.size() > 0){
                PdfPTable refactorTable = new PdfPTable(16);

                // title
                cell = createItemNameCell(getTran("openclinic.chuk","refactor"),3);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                refactorTable.addCell(cell);

                refactorTable.addCell(createCell(new PdfPCell(odogTable),9,Cell.ALIGN_CENTER,Cell.BOX));

                // add
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_AUTOREFRACTOR_ADD");
                cell = createValueCell("Add+ "+itemValue+" D",4);
                cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                refactorTable.addCell(cell);

                visionTable.addCell(createCell(new PdfPCell(refactorTable),1,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        //*** blurtest ***
        Vector blurTestItems = new Vector();
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD");
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D");
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX");
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG");
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D");
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX");
        blurTestItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_ADD");

        if(verifyList(blurTestItems)){
            PdfPTable odogTable = new PdfPTable(9);

            //--- title od ---
            cell = createItemNameCell(getTran("openclinic.chuk","od"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // od
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD");
            odogTable.addCell(createValueCell(itemValue,2));

            // od d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // od dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OD_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            //--- title og ---
            cell = createItemNameCell(getTran("openclinic.chuk","og"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // og
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG");
            odogTable.addCell(createValueCell(itemValue,2));

            // og d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // og dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_OG_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            // add tables
            if(odogTable.size() > 0){
                PdfPTable blurTable = new PdfPTable(16);

                // title
                cell = createItemNameCell(getTran("openclinic.chuk","autorefractor"),3);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                blurTable.addCell(cell);

                blurTable.addCell(createCell(new PdfPCell(odogTable),9,Cell.ALIGN_CENTER,Cell.BOX));

                // add
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_BLURTEST_ADD");
                cell = createValueCell("Add+ "+itemValue+" D",4);
                cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                blurTable.addCell(cell);

                visionTable.addCell(createCell(new PdfPCell(blurTable),1,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        // add vision table
        if(visionTable.size() > 0){
            // title
            cell = createItemNameCell(getTran("openclinic.chuk","vision.acuity"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            table.addCell(cell);
            
            table.addCell(createCell(new PdfPCell(visionTable),4,Cell.ALIGN_CENTER,Cell.BOX));
        }            

        // pupil
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PUPIL");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","pupil"),itemValue);
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD BIO MICROSCOPY AND OCULAR TENSION ---------------------------------------------------
    private void addBioMicroscopyAndOcularTension(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        //*** biomicroscopy ***************************************************
        Vector microscopyItems = new Vector();
        microscopyItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA");
        microscopyItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE");
        microscopyItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN");

        if(verifyList(microscopyItems)){
            PdfPTable microscopyTable = new PdfPTable(4);

            // cornea
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CORNEA");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","cornea"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
                microscopyTable.addCell(cell);

                microscopyTable.addCell(createValueCell(itemValue,3));
            }

            // chambre.anterieure
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CHAMBRE_ANTERIEURE");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","chambre.anterieure"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                microscopyTable.addCell(cell);

                microscopyTable.addCell(createValueCell(itemValue,3));
            }

            // cristallin
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_CRISTALLIN");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","cristallin"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                microscopyTable.addCell(cell);
                
                microscopyTable.addCell(createValueCell(itemValue,3));
            }

            // add microscopy table
            if(microscopyTable.size() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","biomicroscopy"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                table.addCell(cell);

                table.addCell(createCell(new PdfPCell(microscopyTable),4,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        //*** ocular.tension **************************************************
        Vector ocularItems = new Vector();
        ocularItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD");
        ocularItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG");

        if(verifyList(ocularItems)){
            PdfPTable tensionTable = new PdfPTable(4);

            // od
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OD");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","od"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                tensionTable.addCell(cell);

                tensionTable.addCell(createValueCell(itemValue+" mmHg",3));
            }

            // og
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OCULAR_TENSION_OG");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","og"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                tensionTable.addCell(cell);
                
                tensionTable.addCell(createValueCell(itemValue+" mmHg",3));
            }

            // add tension table
            if(tensionTable.size() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","ocular.tension"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                table.addCell(cell);
                
                table.addCell(createCell(new PdfPCell(tensionTable),4,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD VARIA 2 -----------------------------------------------------------------------------
    private void addVaria2(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        
        //*** retina **********************************************************
        Vector retinaItems = new Vector();
        retinaItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE");
        retinaItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_MACULA");
        retinaItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY");

        if(verifyList(retinaItems)){
            PdfPTable retinaTable = new PdfPTable(4);

            // optical.nerve
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_OPTIC_NERVE");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","optical.nerve"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                retinaTable.addCell(cell);
                
                retinaTable.addCell(createValueCell(itemValue,3));
            }

            // macula
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_MACULA");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","macula"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                retinaTable.addCell(cell);

                retinaTable.addCell(createValueCell(itemValue,3));
            }

            // periphery
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_PERIPHERY");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","periphery"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                retinaTable.addCell(cell);

                retinaTable.addCell(createValueCell(itemValue,3));
            }

            // add retina table
            if(retinaTable.size() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","retina"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                table.addCell(cell);
                
                table.addCell(createCell(new PdfPCell(retinaTable),4,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        //*** diagnosis *******************************************************
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_DIAGNOSIS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","diagnosis"),itemValue);
        }

        //*** treatment *******************************************************
        Vector treatmentItems = new Vector();
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D");
        treatmentItems.add(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX");

        if(verifyList(treatmentItems)){
            PdfPTable treatmentTable = new PdfPTable(1);

            // treatment
            PdfPTable treatmentTable2 = new PdfPTable(4);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_TREATMENT");
            if(itemValue.length() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","treatment"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                treatmentTable2.addCell(cell);

                treatmentTable2.addCell(createValueCell(itemValue,3));

                treatmentTable.addCell(createCell(new PdfPCell(treatmentTable2),1,Cell.ALIGN_CENTER,Cell.BOX));
            }

            PdfPTable odogTable = new PdfPTable(9);

            //--- title od ---
            cell = createItemNameCell(getTran("openclinic.chuk","od"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // od
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD");
            odogTable.addCell(createValueCell(itemValue,2));

            // od d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // od dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OD_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            //--- title og ---
            cell = createItemNameCell(getTran("openclinic.chuk","og"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            odogTable.addCell(cell);

            // og
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG");
            odogTable.addCell(createValueCell(itemValue,2));

            // og d
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_D");
            odogTable.addCell(createValueCell("D "+itemValue,3));

            // og dx
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_OG_DX");
            odogTable.addCell(createValueCell("Dx "+itemValue+" "+getTran("units","degrees"),3));

            // add odog table
            if(odogTable.size() > 0){
                PdfPTable newGlassesTable = new PdfPTable(16);

                // title
                cell = createItemNameCell(getTran("openclinic.chuk","new.glasses"),3);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                newGlassesTable.addCell(cell);

                newGlassesTable.addCell(createCell(new PdfPCell(odogTable),9,Cell.ALIGN_CENTER,Cell.BOX));

                // add
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_NEW_GLASSES_ADD");
                cell = createValueCell("Add+ "+itemValue+" D",4);
                cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                newGlassesTable.addCell(cell);

                treatmentTable.addCell(createCell(new PdfPCell(newGlassesTable),1,Cell.ALIGN_CENTER,Cell.BOX));
            }

            // add treatment table
            if(treatmentTable.size() > 0){
                // title
                cell = createItemNameCell(getTran("openclinic.chuk","treatment"),1);
                cell.setBackgroundColor(BGCOLOR_LIGHT);
                table.addCell(cell);

                table.addCell(createCell(new PdfPCell(treatmentTable),4,Cell.ALIGN_CENTER,Cell.BOX));
            }
        }

        //*** remarks *********************************************************
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPHTALMOLOGY_CONSULTATION_REMARKS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
        }

        // add transaction to doc
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1, Cell.ALIGN_CENTER,Cell.BOX));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

}

