package be.mxs.common.util.pdf.official.oc.examinations;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import net.admin.AdminPrivateContact;

import java.text.SimpleDateFormat;

public class PDFOfficialPhysioReport extends PDFOfficialBasic {

    // declarations
    private int pageWidth = 100;


    //--- ADD HEADER ------------------------------------------------------------------------------
    protected void addHeader(){
        try{
            //*** HEADER ******************************************************
            PdfPTable headerTable = new PdfPTable(5);
            headerTable.setWidthPercentage(pageWidth);

            // address
            PdfPTable addressTable = new PdfPTable(1);
            addressTable.addCell(createTitle("ADEPR",Font.BOLD,12,1));
            addressTable.addCell(createTitle("NYAMATA HOSPITAL",Font.NORMAL,10,1));
            addressTable.addCell(createTitle("POBOX. 7112",Font.NORMAL,10,1));
            addressTable.addCell(createTitle("TEL: 561101",Font.NORMAL,10,1));
            cell = createTitle("PHYSIOTHERAPY DPT",Font.UNDERLINE,10,1);
            cell.setNoWrap(true);
            addressTable.addCell(cell);
            headerTable.addCell(createCell(new PdfPCell(addressTable),1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            // date
            SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
            cell = createValueCell(getTran("web","date")+": "+stdDateFormat.format(new java.util.Date()),Font.NORMAL,9,4,false);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            headerTable.addCell(cell);

            // add headertable to document
            doc.add(headerTable);

            //*** TITLE ******************************************************
            PdfPTable titleTable = new PdfPTable(1);
            titleTable.setWidthPercentage(pageWidth);

            // title
            cell = createTitle(getTran("physioreportpdftitle"),Font.UNDERLINE,13,1);
            cell.setPaddingTop(30);
            cell.setPaddingBottom(30);
            titleTable.addCell(cell);
 
            // add headertable to document
            doc.add(titleTable);

            //*** PATIENT DATA ************************************************
            // get required data
            AdminPrivateContact apc = ScreenHelper.getActivePrivate(patient);
            String patientAddress = "";
            if(apc!=null){
                patientAddress = apc.address+", "+apc.zipcode+" "+apc.city;
            }

            // put patient-data in tables..
            PdfPTable patientTable = new PdfPTable(6);
            patientTable.setWidthPercentage(pageWidth);

            // row 1 : name and nationality
            patientTable.addCell(subTitleCell(getTran("web","identity"),6));

            String patientFullName = patient.lastname+" "+patient.firstname;
            patientTable.addCell(createValueCell(getTran("web","name")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patientFullName,Font.BOLD,9,2,false));
 
            patientTable.addCell(createValueCell(getTran("web.admin","nationality")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patient.getID("nationality"),Font.NORMAL,9,2,false));

            // row 2 : age & gender and residence
            patientTable.addCell(createValueCell(getTran("web","dateofbirth")+" & "+getTran("web","gender")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patient.dateOfBirth+", "+patient.gender,Font.NORMAL,9,2,false));

            patientTable.addCell(createValueCell(getTran("web","residence")+": ",Font.NORMAL,9,1,false));
            patientTable.addCell(createValueCell(patientAddress,Font.NORMAL,9,2,false));

            // row 3 : others
            patientTable.addCell(createValueCell(getTran("web","other")+": ",Font.NORMAL,9,6,false));

            // spacer below page-header
            patientTable.addCell(createBorderlessCell("",10,6));

            // add headertable to document
            doc.add(patientTable);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            //*** CONTENT *****************************************************
            table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);

            // REPORT
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_REP_REPORT");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_REP_REPORT"),1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(220);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);

            // spacer
            table.addCell(emptyCell(10,1));

            // CONCLUSION
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_REP_CONCLUSION");
            table.addCell(subTitleCell(getTran(IConstants_PREFIX+"ITEM_TYPE_PHYSIO_REP_CONCLUSION"),1));
            cell = textCell(itemValue,1);
            cell.setFixedHeight(220);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            table.addCell(cell);

            doc.add(table);
            
            //*** FOOTER ******************************************************
            String sUnit = "", sUnitAddress = "";

            table = new PdfPTable(3);
            table.setWidthPercentage(pageWidth);

            table.addCell(emptyCell(2));
            table.addCell(createValueCell(sUnit,Font.NORMAL,10,1,false));

            table.addCell(emptyCell(2));
            table.addCell(createValueCell(sUnitAddress,Font.NORMAL,10,1,false));
            
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //************************************* PRIVATE METHODS ***************************************

    //--- SUBTITLE CELL ---------------------------------------------------------------------------
    private PdfPCell subTitleCell(String title, int colspan){
        cell = new PdfPCell(new Paragraph(title,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- TEXT CELL -------------------------------------------------------------------------------
    private PdfPCell textCell(String text, int colspan){
        cell = new PdfPCell(new Paragraph(text,FontFactory.getFont(FontFactory.HELVETICA,9,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }
}
