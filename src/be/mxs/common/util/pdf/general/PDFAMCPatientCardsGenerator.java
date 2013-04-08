package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.datacenter.DatacenterHelper;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.Product;
import net.admin.User;
import net.admin.Service;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.Barcode39;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import java.io.ByteArrayOutputStream;
import java.util.Hashtable;
import java.util.Vector;
import java.util.StringTokenizer;
import java.util.Enumeration;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.net.URL;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFAMCPatientCardsGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFAMCPatientCardsGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, StringBuffer patientids, String printlanguage) throws Exception {
    	sPrintLanguage=printlanguage;
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        docWriter.setPageEvent(new AMCEndPage());
        this.req = req;

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic/") > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic/"));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            Rectangle rectangle = new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientCardWidth",540)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientCardHeight",860)*72/254).floatValue());
            doc.setPageSize(rectangle.rotate());
            doc.setMargins(10,10,10,10);
            doc.setJavaScript_onLoad("print();\r");
            doc.open();

            // add content to document
            String[] persons = patientids.toString().split(";");
            for(int n=0;n<persons.length;n++){
            	AdminPerson person=DatacenterHelper.getPatientRecord(persons[n]);
            	if(person!=null){
            		printPatientCard(person);
            		doc.newPage();
            	}
            }
		}
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			if(doc!=null) doc.close();
            if(docWriter!=null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
    }

    protected void printPatientCard(AdminPerson person){
        try {
            table = new PdfPTable(1000);
            table.setWidthPercentage(100);
            PdfPTable table2 = new PdfPTable(1000);
            table.setWidthPercentage(100);

            //Professional card
            cell=createLabel(" ",32,1,Font.BOLD);
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table2.addCell(cell);

            cell = new PdfPCell(table2);
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            cell = createValueCell(" ");
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(0);
            table.addCell(cell);
            
            table2 = new PdfPTable(1000);
            //Name
            cell=createLabel(ScreenHelper.getTranNoLink("web","lastname",sPrintLanguage)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createLabel(person.lastname,8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            //FirstName
            cell=createLabel(ScreenHelper.getTranNoLink("web","firstname",sPrintLanguage)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createLabel(person.firstname,8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);

            //Date of birth
            cell=createLabel(ScreenHelper.getTranNoLink("web","dateofbirth",sPrintLanguage)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createLabel(person.dateOfBirth,8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);

            //Registration number
            cell=createLabel(ScreenHelper.getTranNoLink("web","idcode",sPrintLanguage)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setPadding(1);
            table2.addCell(cell);
            cell=createLabel(person.comment,8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            
            //Barcode
            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("A"+person.comment);
            barcode39.setAltText("");
            barcode39.setSize(1);
            barcode39.setBaseline(0);
            barcode39.setBarHeight(20);
            Image image = barcode39.createImageWithBarcode(cb, null, null);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setColspan(1000);
            cell.setPadding(0);
            table2.addCell(cell);
            
            cell = new PdfPCell(table2);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            table.addCell(cell);
            
            //Photo
            image=null;
            try{
            	image =Image.getInstance(DatacenterHelper.getPatientPicture(person.comment));
            }
            catch(Exception e1){
            	e1.printStackTrace();
            }
            if(image!=null){
	            image.scaleToFit(130,72);
	            cell = new PdfPCell(image);
            }
            else {
            	cell = new PdfPCell();
            }
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(300);
            cell.setPadding(0);
            table.addCell(cell);
            
            //Horizontal line
            cell = new PdfPCell();
            cell.setBorder(PdfPCell.BOTTOM);
            cell.setColspan(1000);
            table.addCell(cell);

            table2 = new PdfPTable(2000);
            cell=createLabel(ScreenHelper.getTranNoLink("web","deliverydate",sPrintLanguage),6,1,Font.ITALIC);
            cell.setColspan(550);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPaddingRight(5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            cell=createLabel(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()),6,1,Font.BOLD);
            cell.setColspan(450);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setPadding(0);
            table2.addCell(cell);

            //Expiry data
            cell=createLabel(ScreenHelper.getTranNoLink("web","expirydate",sPrintLanguage),6,1,Font.ITALIC);
            cell.setColspan(550);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPaddingRight(5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            long day = 24*3600*1000;
            long year = 365*day;
            long period = MedwanQuery.getInstance().getConfigInt("cardvalidityperiod", 5) * year - day;
            cell=createLabel(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(new java.util.Date().getTime()+period)),6,1,Font.BOLD);
            cell.setColspan(450);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setPadding(0);
            table2.addCell(cell);

            cell=new PdfPCell(table2);
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(1);
            table.addCell(cell);

            cell=createLabel(ScreenHelper.getTranNoLink("web","cardfooter2",sPrintLanguage),6,1,Font.ITALIC);
            cell.setColspan(1000);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPadding(0);
            table.addCell(cell);
            
            doc.add(table);
            
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- PRINT VECTOR ----------------------------------------------------------------------------
    protected String printVector(Vector vector){
        StringBuffer buf = new StringBuffer();
        for(int i=0; i<vector.size(); i++){
            buf.append(vector.get(i)).append(", ");
        }

        // remove last comma
        if(buf.length() > 0) buf.deleteCharAt(buf.length()-2);

        return buf.toString();
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}
