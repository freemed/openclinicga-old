package be.mxs.common.util.pdf.calendar;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.*;

import java.text.SimpleDateFormat;
import java.io.ByteArrayOutputStream;
import java.util.Date;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.general.PDFFooter;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Planning;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import net.admin.AdminPerson;
import net.admin.User;
public class PDFCalendarGenerator extends PDFBasic {
    // declarations
    private PdfWriter docWriter;
    private User user;
    private final int pageWidth = 90;
    protected final int cellPadding = 3;
    protected String url, contextPath, projectDir;
    protected Image img;
    private int counter=0;
    
    public int getCounter() {
		return counter;
	}
	public void setCounter(int counter) {
		this.counter = counter;
	}
	//--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFCalendarGenerator(User user, String sProject, String sPrintLanguage) {
        this.user = user;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;
        this.table = new PdfPTable(1);
        this.table.setWidthPercentage(pageWidth);
        this.table.getDefaultCell().setBorder(PdfPCell.NO_BORDER);


        doc = new Document();
    }

    private SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String imageid, String trandate, AdminPerson activepatient) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
        docWriter = PdfWriter.getInstance(doc, baosPDF);
        this.req = req;
        String sURL = req.getRequestURL().toString();
        if (sURL.indexOf("openclinic", 10) > 0) {
            sURL = sURL.substring(0, sURL.indexOf("openclinic", 10));
        }
        String sContextPath = req.getContextPath() + "/";
        HttpSession session = req.getSession();
        String sProjectDir = (String) session.getAttribute("activeProjectDir");
        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;
        try {
            doc.addProducer();
            doc.addAuthor(user.person.firstname + " " + user.person.lastname);
            doc.addCreationDate();
            doc.addCreator("OpenClinic Software");
            doc.setPageSize(PageSize.A4);
            doc.setMargins(10, 10, 10, 10);
            doc.setJavaScript_onLoad("print();\r");
            doc.open();
            doc.add(this.table);
        }
        catch (Exception e) {
            baosPDF.reset();
            e.printStackTrace();
        }
        finally {
            if (doc != null) doc.close();
            if (docWriter != null) docWriter.close();
        }
        if (baosPDF.size() < 1) {
            throw new DocumentException("document has no bytes");
        }
        return baosPDF;
    }
    public void addHeader(String sHeader)throws Exception{
        //*** logo ***
        try {
            Image img = Miscelaneous.getImage("logo_" + sProject + ".gif", sProject);
             PdfPTable t = new PdfPTable(5);
            t.setWidthPercentage(pageWidth);
             cell = new PdfPCell();

            if (img != null) {

                cell.addElement(img);
            }
            cell.setBorder(PdfPCell.NO_BORDER);
            t.addCell(cell);
            
            t.addCell(createValueCell(sHeader,4,10,Font.BOLD));
         
            this.table.addCell(t);
        }
        catch (NullPointerException e) {
            Debug.println("WARNING : PDFCalendarGenerator --> IMAGE NOT FOUND : logo_" + sProject + ".gif");
            e.printStackTrace();
        }
    }
    //--- ADD FOOTER ------------------------------------------------------------------------------
    public void addFooter(PdfWriter writer) {
        PDFFooter footer = new PDFFooter(String.format("page %d", writer.getPageNumber()));
        docWriter.setPageEvent(footer);
    }
   
    public void addPrintedRow() {
        try {
            PdfPTable t = new PdfPTable(1);
            t.setWidthPercentage(pageWidth);
            String sPrintedBy = "\n\n\n"+getTran("web", "printedby") + " " + user.person.firstname + " " +user.person.lastname+" "+
                    getTran("web", "on") + " " + ScreenHelper.stdDateFormat.format(new java.util.Date());
            PdfPCell c = createValueCell(sPrintedBy, 1);
            c.setBorder(1);
            t.addCell(createValueCell(sPrintedBy, 1));
            table.addCell(t);
        } catch (Exception e) {
            Debug.printProjectErr(e, e.getStackTrace());
        }
    }
    public void addDateRow(Planning appointment) {
        try{
                PdfPTable t = new PdfPTable(3);
                t.setWidthPercentage(pageWidth);

                // DATE
                String sDate = getTran("web", "date") + " " + ScreenHelper.stdDateFormat.format(appointment.getPlannedDate()) + " " ;
                String sTime = timeFormat.format(appointment.getPlannedDate()) + " => "+timeFormat.format(appointment.getPlannedEndDate()) ;
                t.addCell(createGrayCell(sDate+" "+sTime, 1,8, Font.BOLD));

                t.addCell(this.createGrayCell("",1));
                //CONTEXT
                String sContext = "";
                if(appointment.getContextID().length()>0){
                    sContext += getTran("web","context")+": "+getTran("Web.Occup", appointment.getContextID());
                }
                t.addCell(this.createGrayCell(sContext, 1,8, Font.BOLD));

                table.addCell(t);
            } catch (Exception e) {
                //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
                e.printStackTrace();
            }
        }
    public void addCleanDateRow(Planning appointment) {
        try{
                PdfPTable t = new PdfPTable(3);
                t.setWidthPercentage(pageWidth);

                // DATE
                String sDate = getTran("web", "date") + " " + ScreenHelper.stdDateFormat.format(appointment.getPlannedDate()) + " " ;
                t.addCell(createGrayCell(sDate, 1,8, Font.BOLD));

                t.addCell(this.createGrayCell("",1));
                //CONTEXT
                String sContext = "";
                if(appointment.getContextID().length()>0){
                    sContext += getTran("web","context")+": "+getTran("Web.Occup", appointment.getContextID());
                }
                t.addCell(this.createGrayCell(sContext, 1,8, Font.BOLD));

                table.addCell(t);
            } catch (Exception e) {
                //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
                e.printStackTrace();
            }
        }
    public void addAppointmentRow(Planning appointment) {
        try {
            PdfPTable t = new PdfPTable(60);
            //t.setSpacingAfter(new Float(3.5));
            t.setWidthPercentage(pageWidth);

            t.addCell(this.createBorderlessCell(++counter+"",5));
            String sName =  appointment.getPatient().firstname+" "+appointment.getPatient().lastname;
            t.addCell(this.createBorderlessCell(sName,20));

            String sGender = appointment.getPatient().gender;
            t.addCell(this.createBorderlessCell(sGender,5));

            String sBirthdate = appointment.getPatient().dateOfBirth;
            t.addCell(this.createBorderlessCell(sBirthdate,10));

            String sPersonId = appointment.getPatient().personid;
            t.addCell(this.createBorderlessCell("ID: "+sPersonId,10));

            if(appointment.getPatient().getActivePrivate()!=null){
                t.addCell(this.createBorderlessCell("Tel: "+appointment.getPatient().getActivePrivate().telephone,10));
            }
            else {
            	t.addCell(createEmptyCell(10));
            }

            table.addCell(t);
           
        } catch (Exception e) {
            //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            e.printStackTrace();
        }
    }
    public void addTimedAppointmentRow(Planning appointment) {
        try {
            PdfPTable t = new PdfPTable(60);
            //t.setSpacingAfter(new Float(3.5));
            t.setWidthPercentage(pageWidth);

            t.addCell(this.createBorderlessCell(++counter+"",5));
            t.addCell(this.createBorderlessCell(new SimpleDateFormat("HH:mm").format(appointment.getPlannedDate()),5));
            String sName =  appointment.getPatient().firstname+" "+appointment.getPatient().lastname;
            t.addCell(this.createBorderlessCell(sName,20));

            String sGender = appointment.getPatient().gender;
            t.addCell(this.createBorderlessCell(sGender,5));

            String sBirthdate = appointment.getPatient().dateOfBirth;
            t.addCell(this.createBorderlessCell(sBirthdate,10));

            String sPersonId = appointment.getPatient().personid;
            t.addCell(this.createBorderlessCell("ID: "+sPersonId,5));

            if(appointment.getPatient().getActivePrivate()!=null){
                t.addCell(this.createBorderlessCell("Tel: "+appointment.getPatient().getActivePrivate().telephone,10));
            }
            else {
            	t.addCell(createEmptyCell(10));
            }

            table.addCell(t);
           
        } catch (Exception e) {
            //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            e.printStackTrace();
        }
    }
       public void addAppointmentRow(User user) {
        try {
            PdfPTable t = new PdfPTable(1);
            t.setWidthPercentage(pageWidth);

            String sName = MedwanQuery.getInstance().getLabel("web", "health.professional", sPrintLanguage)+": "+user.person.lastname+" "+user.person.firstname;
            t.addCell(this.createBorderlessCell(sName,1));


            table.addCell(t);
        } catch (Exception e) {
            //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            e.printStackTrace();
        }
    }
    //##################################### CELL FUNCTIONS ########################################

    //--- CREATE GRAY CELL (gray background) ------------------------------------------------------
    protected PdfPCell createGrayCell(String value, int colspan) {
        return createGrayCell(value, colspan, 7, Font.BOLD);
    }
    protected PdfPCell createGrayCell(String value, int colspan, int fontSize) {
        return createGrayCell(value, colspan, fontSize, Font.BOLD);
    }
    protected PdfPCell createGrayCell(String value, int colspan, int fontSize, int fontWeight) {
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA, fontSize, fontWeight)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorderColor(innerBorderColor);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(3);
        return cell;
    }
    //--- CREATE TITLE CELL (large, bold) ---------------------------------------------------------
    protected PdfPCell createTitleCell(String title, String subTitle, int colspan) {
        return createTitleCell(title, subTitle, colspan, 0);
    }
    protected PdfPCell createTitleCell(String title, String subTitle, int colspan, int height) {
        Paragraph paragraph = new Paragraph(title, FontFactory.getFont(FontFactory.HELVETICA, 11, Font.BOLD));

        // add subtitle, if any
        if (subTitle.length() > 0) {
            paragraph.add(new Chunk("\n\n" + subTitle, FontFactory.getFont(FontFactory.HELVETICA, 8, Font.NORMAL)));
        }
        cell = new PdfPCell(paragraph);
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        if (height > 0) {
            cell.setPadding(height / 2);
        }
        return cell;
    }
    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan) {
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA, 7, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOTTOM);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPadding(5);
        return cell;
    }
    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan, int size) {
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA, size, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOTTOM);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPadding(1);
        return cell;
    }
    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan) {
        return createValueCell(value, colspan, 7, Font.NORMAL);
    }
    protected PdfPCell createValueCell(String value, int colspan, int fontSize, int fontWeight) {
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA, fontSize, fontWeight)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        return cell;
    }
    //--- CREATE LABEL CELL (left align) ----------------------------------------------------------
    protected PdfPCell createLabelCell(String label, int colspan) {
        cell = new PdfPCell(new Paragraph(label, FontFactory.getFont(FontFactory.HELVETICA, 7, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        return cell;
    }
    protected PdfPCell createLabelCell(String label, int colspan, int size) {
        cell = new PdfPCell(new Paragraph(label, FontFactory.getFont(FontFactory.HELVETICA, size, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPadding(1);
        return cell;
    }
    //--- CREATE BOLD LABEL CELL (left align) -----------------------------------------------------
    protected PdfPCell createBoldLabelCell(String label, int colspan) {
        cell = new PdfPCell(new Paragraph(label, FontFactory.getFont(FontFactory.HELVETICA, 7, Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        return cell;
    }
    //--- CREATE EMPTY CELL -------------------------------------------------------------------------
    protected PdfPCell createEmptyCell(int colspan) {
        return createEmptyCell(5, colspan);
    }
    //--- CREATE EMPTY CELL -------------------------------------------------------------------------
    protected PdfPCell createEmptyCell(int height, int colspan) {
        cell = new PdfPCell(new Paragraph("", FontFactory.getFont(FontFactory.HELVETICA, 7, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setPaddingTop(height);
        cell.setBorder(PdfPCell.NO_BORDER);
        return cell;
    }
}