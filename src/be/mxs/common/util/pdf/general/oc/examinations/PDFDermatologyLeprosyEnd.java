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
public class PDFDermatologyLeprosyEnd extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addEyes();
                addMuscularForce();
                addNerves();
                addCotation();
                addVaria();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    
    //### PRIVATE METHODS #########################################################################

    //--- ADD EYES --------------------------------------------------------------------------------
    private void addEyes(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // dedicated table
        PdfPTable yeuxTable = new PdfPTable(8);

        // header
        yeuxTable.addCell(emptyCell(2));
        yeuxTable.addCell(createHeaderCell(getTran("web","right"),3));
        yeuxTable.addCell(createHeaderCell(getTran("web","left"),3));

        //***** row 1 : acuité visuelle *****
        yeuxTable.addCell(createHeaderCell(getTran("leprosy","acuitevisuelle"),2));

        String rightValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_RIGHT");
        yeuxTable.addCell(createValueCell((rightValue.length()>0?getTran("web",rightValue).toLowerCase():""),3));

        String leftValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_YEUX_AQUITEVISUELLE_LEFT");
        yeuxTable.addCell(createValueCell((leftValue.length()>0?getTran("web",leftValue).toLowerCase():""),3));

        // add yeuxTable
        if(rightValue.length() > 0 || leftValue.length() > 0){
            // title
            table.addCell(createItemNameCell(getTran("leprosy","yeux"),2));

            cell = createCell(new PdfPCell(yeuxTable),5,Cell.ALIGN_CENTER,Cell.BOX);
            cell.setColspan(5);
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


    //--- ADD MUSCULAR FORCE ----------------------------------------------------------------------
    private void addMuscularForce(){
        Vector items = new Vector();
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT");

        if(verifyList(items)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);
            
            // title
            table.addCell(createItemNameCell(getTran("leprosy","muscularforce"),2));

            // dedicated table
            PdfPTable muscleTable = new PdfPTable(8);

            // header
            muscleTable.addCell(emptyCell(2));
            muscleTable.addCell(createHeaderCell(getTran("web","right"),3));
            muscleTable.addCell(createHeaderCell(getTran("web","left"),3));

            //***** row 1 : occlusion occulaire *****
            cell = createHeaderCell(getTran("leprosy","occlusionocculaire"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_OCCLUSION_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            //***** row 2 : fente en mm *****
            cell = createHeaderCell(getTran("leprosy","fente"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_RIGHT");
            muscleTable.addCell(createValueCell(itemValue+" "+getTran("unit","mm"),3)); // integer value
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_FENTE_LEFT");
            muscleTable.addCell(createValueCell(itemValue+" "+getTran("unit","mm"),3)); // integer value

            //***** row 3 : cinquième doigt *****
            cell = createHeaderCell(getTran("leprosy","cinquiemedoigt"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_DOIGT_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            //***** row 4 : pouce en haut *****
            cell = createHeaderCell(getTran("leprosy","pouceenhaut"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_POUCE_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            //***** row 5 : pied en haut *****
            cell = createHeaderCell(getTran("leprosy","piedenhaut"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_MUSCULARFORCE_PIED_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            // add muscleTable
            cell = createCell(new PdfPCell(muscleTable),3,Cell.ALIGN_CENTER,Cell.BOX);
            cell.setColspan(5);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
                addTransactionToDoc();
            }
        }
    }

    //--- ADD NERVES ------------------------------------------------------------------------------
    private void addNerves(){
        Vector items = new Vector();
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_LEFT");

        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_LEFT");

        if(verifyList(items)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createItemNameCell(getTran("leprosy","nerves"),2));

            // dedicated table
            PdfPTable nervesTable = new PdfPTable(8);

            // header
            nervesTable.addCell(emptyCell(2));
            nervesTable.addCell(createHeaderCell(getTran("leprosy","median"),2));
            nervesTable.addCell(createHeaderCell(getTran("leprosy","cubital"),2));
            nervesTable.addCell(createHeaderCell(getTran("leprosy","sciatiquepopliteexterne"),2));

            // sub header
            nervesTable.addCell(emptyCell(2));
            nervesTable.addCell(createHeaderCell(getTran("web","right"),1));
            nervesTable.addCell(createHeaderCell(getTran("web","left"),1));
            nervesTable.addCell(createHeaderCell(getTran("web","right"),1));
            nervesTable.addCell(createHeaderCell(getTran("web","left"),1));
            nervesTable.addCell(createHeaderCell(getTran("web","right"),1));
            nervesTable.addCell(createHeaderCell(getTran("web","left"),1));

            //***** row 1 : epaissis *****
            cell = createHeaderCell(getTran("leprosy","epaissis"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            nervesTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_RIGHT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_MEDIAN_LEFT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_RIGHT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_CUBITAL_LEFT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_RIGHT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_EPAISSIS_SQIATIQUE_LEFT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));

            //***** row 2 : douloureux *****
            cell = createHeaderCell(getTran("leprosy","douloureux"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            nervesTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_RIGHT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_MEDIAN_LEFT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_RIGHT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_CUBITAL_LEFT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_RIGHT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_NERVES_DOULOUREUX_SQIATIQUE_LEFT");
            nervesTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),1));

            // add nervesTable
            cell = createCell(new PdfPCell(nervesTable),3,Cell.ALIGN_CENTER,Cell.BOX);
            cell.setColspan(5);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
                addTransactionToDoc();
            }
        }
    }

    //--- ADD COTATION ----------------------------------------------------------------------------
    private void addCotation(){
        Vector items = new Vector();
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_OEIL_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_OEIL_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_MAIN_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_MAIN_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_PIED_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_PIED_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_TOTAL_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_TOTAL_LEFT");

        if(verifyList(items)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createItemNameCell(getTran("leprosy","cotationdesinfirmites"),2));

            // dedicated table
            PdfPTable cotationTable = new PdfPTable(8);

            // header
            cotationTable.addCell(emptyCell(2));
            cotationTable.addCell(createHeaderCell(getTran("web","right"),3));
            cotationTable.addCell(createHeaderCell(getTran("web","left"),3));

            //***** row 1 : Oeil *****
            cell = createHeaderCell(getTran("leprosy","oeil"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_OEIL_RIGHT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","oeil_"+itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_OEIL_LEFT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","oeil_"+itemValue).toLowerCase():""),3));

            //***** row 2 : Main *****
            cell = createHeaderCell(getTran("leprosy","main"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_MAIN_RIGHT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","main_"+itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_MAIN_LEFT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","main_"+itemValue).toLowerCase():""),3));

            //***** row 3 : Pied *****
            cell = createHeaderCell(getTran("leprosy","pied"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_PIED_RIGHT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","pied_"+itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_PIED_LEFT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","pied_"+itemValue).toLowerCase():""),3));

            //***** row 4 : Totals *****
            cell = createHeaderCell(getTran("web","total"),2);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_TOTAL_RIGHT");
            cotationTable.addCell(createValueCell(itemValue,3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COTATION_TOTAL_LEFT");
            cotationTable.addCell(createValueCell(itemValue,3));

            // add cotationTable
            cell = createCell(new PdfPCell(cotationTable),3,Cell.ALIGN_CENTER,Cell.BOX);
            cell.setColspan(5);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
                addTransactionToDoc();
            }
        }
    }

    //--- ADD VARIA -------------------------------------------------------------------------------
    private void addVaria(){
        //*** TREATMENT RESULT ***
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);
        String result = "";

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_TT");
        if(itemValue.length() > 0) result+= getTran("leprosy","tt")+", ";

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_THT");
        if(itemValue.length() > 0) result+= getTran("leprosy","tht")+", ";

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_DCD");
        if(itemValue.length() > 0) result+= getTran("leprosy","dcd")+", ";

        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_TREATMENTRESULT_TRANSFUSION");
        if(itemValue.length() > 0) result+= getTran("leprosy","transfusion")+", ";

        if(result.length() > 0){
            // remove last comma
            if(result.indexOf(", ") > -1){
                result = result.substring(0,result.length()-2);
            }

            addItemRow(table,getTran("leprosy","treatmentresult"),result.toLowerCase());
        }

        //*** COMMENT ***
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYEND_COMMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web","comment"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
            addTransactionToDoc();
        }
    }

}
