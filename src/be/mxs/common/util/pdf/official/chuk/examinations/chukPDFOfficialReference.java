package be.mxs.common.util.pdf.official.chuk.examinations;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import net.admin.AdminPrivateContact;

import java.awt.*;
import java.text.SimpleDateFormat;

public class chukPDFOfficialReference extends PDFOfficialBasic {

    // declarations
    private int pageWidth = 100;


    //--- ADD HEADER ------------------------------------------------------------------------------
    protected void addHeader(){
        try{
            //*** TITLE *******************************************************
            PdfPTable titleTable = new PdfPTable(2);
            titleTable.setWidthPercentage(pageWidth);

            // page title
            cell = createTitle(getTran("ficheDeReference")+" / "+getTran("medwan.common.contre_reference"),Font.BOLD,12,1);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            cell.setPaddingBottom(10);
            titleTable.addCell(cell);

            // document number / year
            SimpleDateFormat stdDateFormat = new SimpleDateFormat("yyyy");
            cell = createValueCell("/"+stdDateFormat.format(new java.util.Date()),Font.NORMAL,10,1,false);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPaddingBottom(10);
            titleTable.addCell(cell);

            // add titleTable to document
            doc.add(titleTable);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        // 2 print buttons on the JSP..
        String tranSubType = checkString(req.getParameter("tranSubType"));

             if(tranSubType.equals("reference"))       addReferenceContent();
        else if(tranSubType.equals("contrareference")) addContraReferenceContent();
    }

    //--- ADD REFERENCE CONTENT -------------------------------------------------------------------
    private void addReferenceContent(){
        try{
            //*** title *******************************************************
            table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            table.addCell(createTitleCell(getTran("medwan.common.reference").toUpperCase(),1));
            table.addCell(emptyCell(10,1));
            doc.add(table);

            //*** patient data ************************************************
            // patient table title
            table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            table.addCell(createValueCell(getTran("patientidentity"),Font.BOLD,11,1,false));
            table.addCell(emptyCell(3,1));
            doc.add(table);

            // put patient-data in tables..
            AdminPrivateContact apc = ScreenHelper.getActivePrivate(patient);
            PdfPTable patientTable = new PdfPTable(6);
            patientTable.setWidthPercentage(pageWidth);

            // row 1 : lastname and file-number
            patientTable.addCell(createValueCell(getTran("web","lastname")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patient.lastname,Font.BOLD,9,2,false));

            patientTable.addCell(createValueCell(getTran("web","immatnew")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patient.getID("immatnew"),Font.NORMAL,9,2,false));

            // row 2 : firstname and cell
            patientTable.addCell(createValueCell(getTran("web","firstname")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patient.firstname,Font.NORMAL,9,2,false));

            patientTable.addCell(createValueCell(getTran("web","cell")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell((apc!=null?apc.cell:""),Font.NORMAL,9,2,false));

            // row 3 : age and sector
            int age = patient.getAge();
            String sAge = (age>-1?age+" "+getTran("web","years").toLowerCase():"");

            patientTable.addCell(createValueCell(getTran("web","age")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(sAge,Font.NORMAL,9,2,false));

            patientTable.addCell(createValueCell(getTran("web","sector")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell((apc!=null?apc.sector:""),Font.NORMAL,9,2,false));

            // row 4 : gender and district
            patientTable.addCell(createValueCell(getTran("web","gender")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patient.gender,Font.NORMAL,9,2,false));

            patientTable.addCell(createValueCell(getTran("web","district")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell((apc!=null?apc.district:""),Font.NORMAL,9,2,false));

            // row 5 : transfer reason and service
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RAISON_TRANSF");
            patientTable.addCell(createValueCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RAISON_TRANSF")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(itemValue,Font.NORMAL,9,2,false));

            // one large enclosing bordered cell
            PdfPTable borderTable = new PdfPTable(1);
            borderTable.setWidthPercentage(pageWidth);
            cell = createCell(new PdfPCell(patientTable),1,Cell.ALIGN_LEFT,Cell.BOX);
            cell.setBorderColor(new Color(0,0,0)); // black
            cell.setPadding(3);
            borderTable.addCell(cell);
            doc.add(borderTable);

            // spacer between bordered tables
            table = new PdfPTable(1);
            cell = new PdfPCell(new Phrase());
            cell.setBorder(Cell.NO_BORDER);
            cell.setPaddingTop(10);
            table.addCell(cell);
            doc.add(table);

            //*** data ********************************************************
            table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);
            
            // REFERENCE CENTER
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_REF_CENTR");
            String centerName = getTran("reference.referencecenter",itemValue);
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_REF_CENTR")+": ",1));
            table.addCell(textCell(centerName,1));

            // ANAMNESE
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ANAMNESE");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ANAMNESE")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(130);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // COMPLEMENTARY EXAMINATION
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_EXAM_COMPL");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_EXAM_COMPL")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(130);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // RECEIVED TREATEMENT
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(130);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // one large enclosing bordered cell
            borderTable = new PdfPTable(1);
            borderTable.setWidthPercentage(pageWidth);
            cell = createCell(new PdfPCell(table),1,Cell.ALIGN_LEFT,Cell.BOX);
            cell.setBorderColor(new Color(0,0,0)); // black
            cell.setPadding(3);
            borderTable.addCell(cell);
            doc.add(borderTable);
            
            //*** signature and date ******************************************
            table = new PdfPTable(2);
            table.setWidthPercentage(pageWidth);

            // signature
            table.addCell(emptyCell(5,2));
            table.addCell(createValueCell(getTran("referenceSignature"),Font.BOLD,11,1,false));
            table.addCell(createValueCell(getTran("web","date"),Font.BOLD,11,1,false));

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD CONTRA REFERENCE CONTENT ------------------------------------------------------------
    private void addContraReferenceContent(){
        try{
            //*** title *******************************************************
            table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);
            
            table.addCell(createTitleCell(getTran("medwan.common.contre_reference").toUpperCase(),1));
            table.addCell(emptyCell(15,1));
            doc.add(table);

            //*** 2 dates *****************************************************
            PdfPTable datesTable = new PdfPTable(2);
            datesTable.setWidthPercentage(pageWidth);

            datesTable.addCell(createValueCell(getTran("entranceDate")+": ",Font.BOLD,11,1,false));
            datesTable.addCell(createValueCell(getTran("exitDate")+": ",Font.BOLD,11,1,false));
            datesTable.addCell(emptyCell(8,2));
            doc.add(datesTable);

            //*** data ********************************************************
            table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // REFERENCE ID
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ID_REF")+": ",1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_ID_REF");
            table.addCell(textCell(itemValue,1));

            // SIGNIFICANT RESULTS
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RESULTS_SIGNIF");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RESULTS_SIGNIF")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(125);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // SIGNIFICANT DIAGNOSIS
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_DIAGN");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_DIAGN")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(125);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // RECEIVED TREATEMENT
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(125);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // RECOMMENDATIONS AND TREATMENT TO SUBJECT TO
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE")+": ",1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(125);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            table.addCell(cell);

            // one large enclosing bordered cell
            PdfPTable borderTable = new PdfPTable(1);
            borderTable.setWidthPercentage(pageWidth);
            cell = createCell(new PdfPCell(table),1,Cell.ALIGN_LEFT,Cell.BOX);
            cell.setBorderColor(new Color(0,0,0)); // black
            cell.setPadding(3);
            borderTable.addCell(cell);
            doc.add(borderTable);

            //*** signature and date ******************************************
            table = new PdfPTable(2);
            table.setWidthPercentage(pageWidth);

            // signature
            table.addCell(emptyCell(5,2));
            table.addCell(createValueCell(getTran("contraReferenceSignature"),Font.BOLD,11,1,false));
            table.addCell(createValueCell(getTran("web","date"),Font.BOLD,11,1,false));

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //******************************************* PRIVATE METHODS *********************************

    //--- CREATE TITLE CELL -----------------------------------------------------------------------
    protected PdfPCell createTitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg, FontFactory.getFont(FontFactory.HELVETICA,13,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setPaddingBottom(5);
        cell.setBorder(Cell.BOX);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);

        return cell;
    }

    //--- SUBTITLE CELL ---------------------------------------------------------------------------
    private PdfPCell subTitleCell(String title, int colspan){
        cell = new PdfPCell(new Paragraph(title,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setPaddingBottom(5);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }
    
    //--- TEXT CELL -------------------------------------------------------------------------------
    private PdfPCell textCell(String text, int colspan){
        cell = new PdfPCell(new Paragraph(text,FontFactory.getFont(FontFactory.HELVETICA,9,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setPaddingBottom(5);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }
}
