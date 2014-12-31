package be.mxs.common.util.pdf.general.oc.examinations;

import java.util.Vector;
import java.text.DecimalFormat;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Font;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


/**
 * User: Frank
 * Date: 2-mrt-2005
 */
public class PDFNurseExamination extends PDFGeneralBasic {

    // declarations
    protected Vector listCorrectie, listWithout, listWith, listUrine, listBio, listCardio;


    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public PDFNurseExamination(){
        super();

        // Correctie
        listCorrectie = new Vector();
        listCorrectie.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL");
        listCorrectie.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES");
        listCorrectie.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT");
        listCorrectie.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK");
        listCorrectie.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY");

            listWithout = new Vector();
            listWithout.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES");
            listWithout.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES");
            listWithout.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITHOUT_GLASSES");
            listWithout.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES");

            listWith = new Vector();
            listWith.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES");
            listWith.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES");
            listWith.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITH_GLASSES");
            listWith.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES");

        // Urineonderzoek
        listUrine = new Vector();
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_ALBUMINE");
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_GLUCOSE");
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_BLOOD");
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_PREGNANCY");

        // Biometrie
        listBio = new Vector();
        listBio.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
        listBio.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
        listBio.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE");
        listBio.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_FAT_TYPE");

        // Cardiaal
        listCardio = new Vector();
        listCardio.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
        listCardio.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH");
        listCardio.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT");
        listCardio.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT");
        listCardio.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
        listCardio.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
    }

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);

                addVisus();
                addUrine();
                addBiometrie();
                addCardial();

                // add content
                if(contentTable.size() > 0){
                    tranTable.addCell(createContentCell(contentTable));
                    addTransactionToDoc();
                }

                // diagnoses
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //##############################################################################################
    //### PRIVATE METHODS ##########################################################################
    //##############################################################################################

    //--- ADD VISUS --------------------------------------------------------------------------------
    private void addVisus(){
        if(verifyList(listCorrectie)){
            table = new PdfPTable(5);
            table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.acuite-visuelle"),5));

            // correction
            itemValue = printList(listCorrectie,false,", ");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_CORRECTION"),itemValue.toLowerCase());
            }

            PdfPTable zichtTable = new PdfPTable(5);

            //*** Scherptezicht ***
            boolean withListOK = verifyList(listWith);
            boolean withoutListOK = verifyList(listWithout);

            if(withListOK || withoutListOK){
                // borderless cell
                zichtTable.addCell(createBorderlessCell(1));

                // header
                zichtTable.addCell(createHeaderCell(getTran("medwan.common.right"),1));
                zichtTable.addCell(createHeaderCell(getTran("medwan.common.left"),1));
                zichtTable.addCell(createHeaderCell(getTran("medwan.common.binocular"),1));
                zichtTable.addCell(createHeaderCell(getTran("medwan.healthrecord.ophtalmology.Acuite-binoculaire-VP"),1));

                // Zonder correctie
                if(withoutListOK){
                    zichtTable.addCell(createHeaderCell(getTran("medwan.healthrecord.ophtalmology.SANS-verres-2"),1));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES")));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES")));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES")));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITHOUT_GLASSES")));
                }

                // Met correctie
                if(withListOK){
                    zichtTable.addCell(createHeaderCell(getTran("medwan.healthrecord.ophtalmology.AVEC-verres-2"),1));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES")));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES")));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES")));
                    zichtTable.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITH_GLASSES")));
                }

                table.addCell(createCell(new PdfPCell(zichtTable),5,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));
            }

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            }
        }
    }

    //--- ADD URINE --------------------------------------------------------------------------------
    private void addUrine(){
        if(verifyList(listUrine)){
            table = new PdfPTable(5);
            table.addCell(createTitleCell(getTran(IConstants_PREFIX+"TRANSACTION_TYPE_URINE_EXAMINATION"),5));

            // albumine
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_URINE_ALBUMINE");
            if(itemValue.length() > 0){
                if(itemValue.equalsIgnoreCase("medwan.common.positive")){
                    itemValue = getTran(itemValue)+" mg/dl";
                }
                else{
                    itemValue = getTran(itemValue);
                }

                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_URINE_ALBUMINE"),itemValue);
            }

            // glucose
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_URINE_GLUCOSE");
            if(itemValue.length() > 0){
                if(itemValue.equalsIgnoreCase("medwan.common.positive")){
                    itemValue = getTran(itemValue)+" mg/dl";
                }
                else{
                    itemValue = getTran(itemValue);
                }

                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_URINE_GLUCOSE"),itemValue);
            }

            // blood
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_URINE_BLOOD");
            if(itemValue.length() > 0){
                if(itemValue.equalsIgnoreCase("medwan.common.positive")){
                    itemValue = getTran(itemValue)+" ery/µl";
                }
                else{
                    itemValue = getTran(itemValue);
                }

                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_URINE_BLOOD"),itemValue);
            }

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            }
        }
    }

    //--- ADD BIOMETRIE ----------------------------------------------------------------------------
    private void addBiometrie(){
        if(verifyList(listBio)){
            table = new PdfPTable(5);
            table.addCell(createTitleCell(getTran(IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY"),5));
            int cellCount = 0;

            // WEIGHT
            String weight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
            if(weight.length() > 0){
                table.addCell(createValueCell(getTran(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT")+": "+weight+" "+getTran("units","kg"),1));
                cellCount++;
            }

            // HEIGHT
            String height = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
            if(height.length() > 0){
                table.addCell(createValueCell(getTran(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT")+": "+height+" "+getTran("units","cm"),1));
                cellCount++;
            }

            // BMI
            if(weight.length()>0 && height.length()>0){
                Float bmi = new Float(Float.parseFloat(weight.replaceAll(",","."))*10000 / (Float.parseFloat(height.replaceAll(",",".")) * Float.parseFloat(height.replaceAll(",","."))));
                table.addCell(createValueCell("BMI: "+new DecimalFormat("0.0").format(bmi),1));
                cellCount++;
            }

            // even out cells
            if(cellCount > 0){
            	table.addCell(emptyCell(5-cellCount));
            }
            
            // MUSCLE TYPE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE"),getTran(itemValue));
            }

            // FAT TYPE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_FAT_TYPE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_FAT_TYPE"),getTran(itemValue));
            }
            
            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            }
        }
    }

    //--- ADD CARDIAL ------------------------------------------------------------------------------
    private void addCardial(){
        if(verifyList(listCardio)){
            table = new PdfPTable(5);
            table.addCell(createTitleCell(getTran("medwan.healthrecord.anamnese.cardial"),5));

            // frequency & rythm
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
            if(itemValue.length() > 0){
                itemValue+= "/"+getTran("units","minute");

                String rythm = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH");
                if(rythm.length() > 0) itemValue+= "  ("+getTran(rythm).toLowerCase()+")";

                addItemRow(table,getTran("medwan.healthrecord.cardial.frequence-cardiaque"),itemValue);
            }

            // pressure right & left
            String sysRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
                   sysLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT"),
                   diaRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT"),
                   diaLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT");
            itemValue = "";

            if(sysRight.length() > 0 || sysLeft.length() > 0 || diaRight.length() > 0 || diaLeft.length() > 0){
                // right arm
                if(!sysRight.equals("")){
                    itemValue+= getTran("medwan.common.right")+": "+sysRight+"/"+diaRight+" mmHg";
                }

                // left arm
                if(!sysLeft.equals("")){
                    if(itemValue.length() > 0) itemValue+= ",  ";
                    itemValue+= getTran("medwan.common.left")+": "+sysLeft+"/"+diaLeft+" mmHg";
                }

                addItemRow(table,getTran("medwan.healthrecord.cardial.pression-arterielle"),itemValue);

                // add table
                if(table.size() > 1){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                }
            }
        }
    }

    //--- CREATE CONTENT CELL ----------------------------------------------------------------------
    protected PdfPCell createContentCell(String value){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER); // difference

        return cell;
    }

}