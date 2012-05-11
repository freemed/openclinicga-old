package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.medical.Problem;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;

import java.util.Vector;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFNurseFollowup extends PDFGeneralBasic {

    // declarations
    protected Vector listProblems, listVitalSigns, listUrine, listBio, listOther;


    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public PDFNurseFollowup(){
        super();

        // Problems
        listProblems = new Vector();                      
        listProblems.add(IConstants_PREFIX+"ITEM_TYPE_NURSE_PROBLEMS");
        listProblems.add(IConstants_PREFIX+"ITEM_TYPE_NURSE_INTERVENTIONS");
        listProblems.add(IConstants_PREFIX+"ITEM_TYPE_NURSE_OBSERVATIONS");

        // Vital signs
        listVitalSigns = new Vector();
        listVitalSigns.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_TEMPERATURE");
        listVitalSigns.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT");
        listVitalSigns.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
        listVitalSigns.add(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
        listVitalSigns.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_RESPIRATION");
        listVitalSigns.add(IConstants_PREFIX+"ITEM_TYPE_SURV_SAO2");

        // Urineonderzoek
        listUrine = new Vector();
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_ALBUMINE");
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_GLUCOSE");
        listUrine.add(IConstants_PREFIX+"ITEM_TYPE_URINE_BLOOD");

        // Biometrie
        listBio = new Vector();
        listBio.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
        listBio.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");

        // Other
        listOther = new Vector();
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_NURSE_DIURESIS24");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_SURV_VOMITING");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_RESPIRATION");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_SURV_STOOL");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_NURSE_TUBEFEEDING");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_SURV_TOILET");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_SURV_SCARR");
        listOther.add(IConstants_PREFIX+"ITEM_TYPE_SURV_POSITION");  
    }

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addProblems();
                addProblemList();
                addTransactionToDoc();

                addVitalSigns();
                addUrine();
                addTransactionToDoc();
                
                addBiometrie();
                addOther();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD PROBLEMS ----------------------------------------------------------------------------
    private void addProblems(){
        if(verifyList(listProblems)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);
            
            // problems
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NURSE_PROBLEMS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","problems"),itemValue);
            }

            // interventions.attitude
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NURSE_INTERVENTIONS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","interventions.attitude"),itemValue);
            }

            // observations
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NURSE_OBSERVATIONS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","observations"),itemValue);
            }

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD PROBLEMLIST -------------------------------------------------------------------------
    private void addProblemList(){
        if(verifyList(listProblems)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createTitleCell(getTran("web.occup","medwan.common.problemlist"),5));

            Vector activeProblems = Problem.getActiveProblems(patient.personid);
            if(activeProblems.size()>0){
                PdfPTable problemsTable = new PdfPTable(3);

                // header
                problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),2));
                problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.datebegin"),1));

                Problem activeProblem;
                String comment, value;
                for(int n=0; n<activeProblems.size(); n++){
                    activeProblem = (Problem)activeProblems.elementAt(n);

                    value = activeProblem.getCode()+" "+ MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(),sPrintLanguage);
                    Paragraph par = new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));

                    // add comment if any
                    if(activeProblem.getComment().trim().length() > 0){
                        comment = " : "+activeProblem.getComment().trim();
                        par.add(new Chunk(comment,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
                    }

                    cell = new PdfPCell(par);
                    cell.setColspan(2);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(innerBorderColor);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                    cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                    problemsTable.addCell(cell);

                    // date
                    problemsTable.addCell(createValueCell(new SimpleDateFormat("dd/MM/yyyy").format(activeProblem.getBegin()),1));
                }
            }

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD VITAL SIGNS -------------------------------------------------------------------------
    private void addVitalSigns(){
        if(verifyList(listVitalSigns)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(10);
            int itemCount = 0;

            // title
            table.addCell(createTitleCell(getTran("openclinic.chuk","vital.signs"),10));

            // temperature
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_TEMPERATURE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","temperature"),itemValue+" "+getTran("unit","degreesCelcius"));
                itemCount++;
            }

            //*** bloodpressure ***
            String sysRight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT"),
                   sysLeft  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT");
            String bloodpressure = sysRight+" / "+sysLeft+" mmHg";

            if(sysRight.length() > 0 || sysLeft.length() > 0){
                addItemRow(table,getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle"),bloodpressure);
                itemCount++;
            }

            // heartfrequency
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","heartfrequency"),itemValue+"/"+getTran("units","minute"));
                itemCount++;
            }

            // respiration
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_RESPIRATION");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","respiration"),itemValue+"/"+getTran("units","minute"));
                itemCount++;
            }

            // sao2
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SURV_SAO2");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","sao2"),itemValue+" %");
                itemCount++;
            }

            // add cell to achieve an even number of displayed cells
            if(itemCount%2==1){
                cell = new PdfPCell();
                cell.setColspan(5);
                cell.setBorder(PdfPCell.NO_BORDER);
                table.addCell(cell);
            }

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD URINE --------------------------------------------------------------------------------
    private void addUrine(){
        if(verifyList(listUrine)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
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
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD BIOMETRIE ----------------------------------------------------------------------------
    private void addBiometrie(){
        if(verifyList(listBio)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createTitleCell(getTran(IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY"),5));

            table.addCell(createItemNameCell(getTran(IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY"),2));

            // WEIGHT (on one row)
            String weight = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT");
            if(weight.length() > 0){
                table.addCell(createValueCell(getTran(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_WEIGHT")+": "+weight+" "+getTran("unit","kg"),1));
            }

            // HEIGHT (on one row)
            String height = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT");
            if(height.length() > 0){
                table.addCell(createValueCell(getTran(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT")+": "+height+" "+getTran("unit","cm"),1));
            }

            // BMI (calculated) (on one row)
            if(weight.length()>0 && height.length()>0){
                DecimalFormat deci = new DecimalFormat("0.0");
                Float bmi = new Float(Float.parseFloat(weight)*10000 / (Float.parseFloat(height) * Float.parseFloat(height)));
                table.addCell(createValueCell("BMI: "+deci.format(bmi),1));
            }

            /*
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
            */

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD OTHER -------------------------------------------------------------------------------
    private void addOther(){
        if(verifyList(listOther)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(10);
            int itemCount = 0;

            // title
            table.addCell(createTitleCell(getTran("openclinic.chuk","other"),5));
            
            // diuresis.24h
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NURSE_DIURESIS24");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","diuresis.24h"),itemValue+" "+getTran("unit","ml"));
                itemCount++;
            }

            // vomiting
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SURV_VOMITING");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","vomiting"),itemValue+" "+getTran("unit","ml"));
                itemCount++;
            }

            // respiration
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_RESPIRATION");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","respiration"),itemValue);
                itemCount++;
            }

            // stool
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SURV_STOOL");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","stool"),itemValue);
                itemCount++;
            }

            // observation
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NURSE_TUBEFEEDING");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","tubefeeding"),itemValue);
                itemCount++;
            }

            // toilet
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SURV_TOILET");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","toilet"),itemValue);
                itemCount++;
            }

            // bedsore.prevention
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SURV_SCARR");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("Web.Occup","bedsore.prevention"),itemValue);
                itemCount++;
            }

            // position.change
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SURV_POSITION");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","position.change"),itemValue);
                itemCount++;
            }
            
            // add cell to achieve an even number of displayed cells
            if(itemCount%2==1){
                cell = new PdfPCell();
                cell.setColspan(5);
                cell.setBorder(PdfPCell.NO_BORDER);
                table.addCell(cell);
            }

            // add table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- CREATE CONTENT CELL ----------------------------------------------------------------------
    protected PdfPCell createContentCell(String value){
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA,7, Font.NORMAL)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER); // difference

        return cell;
    }

}
