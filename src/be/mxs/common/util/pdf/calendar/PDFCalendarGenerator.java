package be.mxs.common.util.pdf.calendar;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.*;

import java.text.SimpleDateFormat;
import java.io.ByteArrayOutputStream;
import java.util.Date;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;


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
    private SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
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
            cell.setBorder(Cell.NO_BORDER);
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
    public void addFooter() {
        String sFooter = getConfigString("footer." + sProject);
        sFooter = sFooter.replaceAll("<br>", "\n").replaceAll("<BR>", "\n");
        Font font = FontFactory.getFont(FontFactory.HELVETICA, 7);
        HeaderFooter footer = new HeaderFooter(new Phrase(sFooter + "\n", font), true);
        footer.disableBorderSide(HeaderFooter.BOTTOM);
        footer.setAlignment(HeaderFooter.ALIGN_CENTER);
        doc.setFooter(footer);
    }
    public void addPrintedRow() {
        try {
            PdfPTable t = new PdfPTable(1);
            t.setWidthPercentage(pageWidth);
            String sPrintedBy = "\n\n\n"+getTran("web", "printedby") + " " + user.person.lastname + " " + user.person.firstname + " " +
                    getTran("web", "on") + " " + stdDateFormat.format(new java.util.Date());
            PdfPCell c = createValueCell(sPrintedBy, 1);
            c.setBorder(1);
            t.addCell(createValueCell(sPrintedBy, 1));
            table.addCell(t);
        } catch (Exception e) {
            Debug.printProjectErr(e, e.getStackTrace());
        }
    }
    public void addDateRow(Date dFrom) {
        try {
            PdfPTable t = new PdfPTable(1);
            t.setWidthPercentage(pageWidth);
            String sDate = getTran("web", "date") + " " + stdDateFormat.format(dFrom) + " " ;
            t.addCell(createGrayCell(sDate, 1,8, Font.BOLD));
            table.addCell(t);
        } catch (Exception e) {
            //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            e.printStackTrace();
        }
    }
     public void addAppointmentRow(Date dFrom,Date dTo, AdminPerson patient) {
        try {
            PdfPTable t = new PdfPTable(5);
            t.setWidthPercentage(pageWidth);
            String sDate = timeFormat.format(dFrom) + " => "+timeFormat.format(dTo) ;
            t.addCell(this.createBorderlessCell(sDate, 1));

            String sName = patient.lastname+" "+patient.firstname;
            t.addCell(this.createBorderlessCell(sName,1));

            String sGender = patient.gender;
            t.addCell(this.createBorderlessCell(sGender,1));

            String sBirthdate = patient.dateOfBirth;
            t.addCell(this.createBorderlessCell(sBirthdate,1));

            String sPersonId = patient.personid;
            t.addCell(this.createBorderlessCell(sPersonId,1));

            table.addCell(t);
        } catch (Exception e) {
            //  Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            e.printStackTrace();
        }
    }
       public void addAppointmentRow(Date dFrom,Date dTo, User user) {
        try {
            PdfPTable t = new PdfPTable(2);
            t.setWidthPercentage(pageWidth);
            String sDate = timeFormat.format(dFrom) + " => "+timeFormat.format(dTo) ;
            t.addCell(this.createBorderlessCell(sDate, 1));


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
        cell.setBorder(Cell.BOX);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setBorderColor(innerBorderColor);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
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
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        if (height > 0) {
            cell.setPadding(height / 2);
        }
        return cell;
    }
    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan) {
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA, 7, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOTTOM);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setPadding(5);
        return cell;
    }
    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan, int size) {
        cell = new PdfPCell(new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA, size, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOTTOM);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
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
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        return cell;
    }
    //--- CREATE LABEL CELL (left align) ----------------------------------------------------------
    protected PdfPCell createLabelCell(String label, int colspan) {
        cell = new PdfPCell(new Paragraph(label, FontFactory.getFont(FontFactory.HELVETICA, 7, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        return cell;
    }
    protected PdfPCell createLabelCell(String label, int colspan, int size) {
        cell = new PdfPCell(new Paragraph(label, FontFactory.getFont(FontFactory.HELVETICA, size, Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setPadding(1);
        return cell;
    }
    //--- CREATE BOLD LABEL CELL (left align) -----------------------------------------------------
    protected PdfPCell createBoldLabelCell(String label, int colspan) {
        cell = new PdfPCell(new Paragraph(label, FontFactory.getFont(FontFactory.HELVETICA, 7, Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
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
        cell.setBorder(Cell.NO_BORDER);
        return cell;
    }
}