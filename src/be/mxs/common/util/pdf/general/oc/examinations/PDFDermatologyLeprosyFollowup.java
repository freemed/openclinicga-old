package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFDermatologyLeprosyFollowup extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addMuscularForce();
                addEyes();
                addCotidation();
                addVaria();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
                

    //### PRIVATE METHODS #########################################################################

    //--- ADD MUSCULAR FORCE ----------------------------------------------------------------------
    private void addMuscularForce(){
        Vector items = new Vector();
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_OCCLUSION_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_OCCLUSION_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_FENTE_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_FENTE_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_DOIGT_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_DOIGT_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_POUCE_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_POUCE_LEFT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_PIED_RIGHT");
        items.add(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_PIED_LEFT");

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
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_OCCLUSION_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_OCCLUSION_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            //***** row 2 : fente en mm *****
            cell = createHeaderCell(getTran("leprosy","fente"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_FENTE_RIGHT");
            muscleTable.addCell(createValueCell(itemValue+(itemValue.length()>0?" "+getTran("units","mm"):""),3)); // integer value
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_FENTE_LEFT");
            muscleTable.addCell(createValueCell(itemValue+(itemValue.length()>0?" "+getTran("units","mm"):""),3)); // integer value

            //***** row 3 : cinquième doigt *****
            cell = createHeaderCell(getTran("leprosy","cinquiemedoigt"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_DOIGT_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_DOIGT_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            //***** row 4 : pouce en haut *****
            cell = createHeaderCell(getTran("leprosy","pouceenhaut"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_POUCE_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_POUCE_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            //***** row 5 : pied en haut *****
            cell = createHeaderCell(getTran("leprosy","piedenhaut"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            muscleTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_PIED_RIGHT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_MUSCULARFORCE_PIED_LEFT");
            muscleTable.addCell(createValueCell((itemValue.length()>0?getTran("web",itemValue).toLowerCase():""),3));

            // add muscleTable
            cell = createCell(new PdfPCell(muscleTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setColspan(5);
            cell.setPadding(3);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(new PdfPCell(contentTable));
                addTransactionToDoc();
            }
        }
    }
    
    //--- ADD EYES --------------------------------------------------------------------------------
    private void addEyes(){
        // dedicated table
        PdfPTable yeuxTable = new PdfPTable(8);

        // header
        yeuxTable.addCell(emptyCell(2));
        yeuxTable.addCell(createHeaderCell(getTran("web","right"),3));
        yeuxTable.addCell(createHeaderCell(getTran("web","left"),3));

        //***** row 1 : acuité visuelle *****
        yeuxTable.addCell(createHeaderCell(getTran("leprosy","acuitevisuelle"),2));

        String rightValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_YEUX_AQUITEVISUELLE_RIGHT");
        yeuxTable.addCell(createValueCell((rightValue.length()>0?getTran("web",rightValue).toLowerCase():""),3));

        String leftValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_YEUX_AQUITEVISUELLE_LEFT");
        yeuxTable.addCell(createValueCell((leftValue.length()>0?getTran("web",leftValue).toLowerCase():""),3));

        // add yeuxTable
        if(rightValue.length() > 0 || leftValue.length() > 0){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createItemNameCell(getTran("leprosy","yeux"),2));

            cell = createCell(new PdfPCell(yeuxTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setColspan(5);
            cell.setPadding(3);
            table.addCell(cell);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(new PdfPCell(contentTable));
            addTransactionToDoc();
        }
    }

    //--- ADD COTIDATION --------------------------------------------------------------------------
    private void addCotidation(){
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
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_OEIL_RIGHT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","oeil_"+itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_OEIL_LEFT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","oeil_"+itemValue).toLowerCase():""),3));

            //***** row 2 : Main *****
            cell = createHeaderCell(getTran("leprosy","main"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_MAIN_RIGHT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","main_"+itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_MAIN_LEFT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","main_"+itemValue).toLowerCase():""),3));

            //***** row 3 : Pied *****
            cell = createHeaderCell(getTran("leprosy","pied"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_PIED_RIGHT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","pied_"+itemValue).toLowerCase():""),3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_PIED_LEFT");
            cotationTable.addCell(createValueCell((itemValue.length()>0?getTran("leprosy","pied_"+itemValue).toLowerCase():""),3));

            //***** row 4 : Totals *****
            cell = createHeaderCell(getTran("web","total"),2);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cotationTable.addCell(cell);
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_TOTAL_RIGHT");
            cotationTable.addCell(createValueCell(itemValue,3));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COTATION_TOTAL_LEFT");
            cotationTable.addCell(createValueCell(itemValue,3));

            // add cotationTable
            cell = createCell(new PdfPCell(cotationTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setColspan(5);
            cell.setPadding(3);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(new PdfPCell(contentTable));
                addTransactionToDoc();
            }
        }
    }

    //--- ADD VARIA -------------------------------------------------------------------------------
    private void addVaria(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // detoriation
        String detoriation = "";
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_DETORIATION");
        if(itemValue.length() > 0) detoriation+= getTran("web",itemValue);

        // detoriation.since
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_DETORIATION_SINCE");
        if(itemValue.length() > 0){
            detoriation+= ", "+getTran("web","since")+" "+itemValue+" "+getTran("web","months");
        }

        if(detoriation.length() > 0){
            addItemRow(table,getTran("leprosy","detoriation"),detoriation.toLowerCase());
        }

        // comment
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LEPROSYFOLLOWUP_COMMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("Web","comment"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(new PdfPCell(contentTable));
            addTransactionToDoc();
        }
    }

}
