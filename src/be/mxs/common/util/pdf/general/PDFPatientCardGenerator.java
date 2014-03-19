package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.Product;
import net.admin.User;
import net.admin.Service;
import net.admin.AdminPerson;
import com.itextpdf.text.*;
import com.itextpdf.text.html.HtmlTags;
import com.itextpdf.text.pdf.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.util.Hashtable;
import java.util.Vector;
import java.util.StringTokenizer;
import java.util.Enumeration;
import java.text.DecimalFormat;
import java.net.URL;

public class PDFPatientCardGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter = null;
    
    public void addHeader(){
    }
    
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientCardGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, AdminPerson person) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        docWriter.setPageEvent(new EndPage());
        this.req = req;

        String sURL = MedwanQuery.getInstance().getConfigString("imageSource","http://localhost/openclinic");

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL+"/";
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
            printPatientCard(person);
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
            table = new PdfPTable(4);
            table.setWidthPercentage(pageWidth);
            //Logo
            Image image = Miscelaneous.getImage("logo_patientcard.gif",sProject);
            image.scaleToFit(60*200/254,72);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setColspan(1);
            cell.setPaddingLeft(2);
            cell.setPaddingRight(2);
            table.addCell(cell);

            //Barcode + archiving code
            PdfPTable wrapperTable = new PdfPTable(3);
            wrapperTable.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("0"+person.personid);
            image = barcode39.createImageWithBarcode(cb, null, null);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setColspan(2);
            cell.setPadding(0);
            wrapperTable.addCell(cell);

            PdfPTable subTable = new PdfPTable(1);
            subTable.setWidthPercentage(100);
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardarchivecode",user.person.language),6,1,Font.ITALIC);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPadding(0);
            subTable.addCell(cell);
            cell=createLabel(person.getID("archiveFileCode").toUpperCase(),10,1,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPadding(0);
            subTable.addCell(cell);
            cell = createBorderlessCell(1);
            cell.addElement(subTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            wrapperTable.addCell(cell);

            cell = createBorderlessCell(3);
            cell.addElement(wrapperTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table.addCell(cell);

            //Name
            cell=createLabel(" ",6,4,Font.NORMAL);
            table.addCell(cell);
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardname",user.person.language),6,4,Font.ITALIC);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            cell=createLabel(person.firstname+" "+person.lastname,10,4,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);

            //Date of birth & gender
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","carddateofbirth",user.person.language),6,2,Font.ITALIC);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            if(MedwanQuery.getInstance().getConfigInt("patientCardModel",1)==2){
	            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardinsurancenumber",user.person.language),6,1,Font.ITALIC);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardgender",user.person.language),6,1,Font.ITALIC);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	            table.addCell(cell);
            }
            else {
	            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardgender",user.person.language),6,2,Font.ITALIC);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	            table.addCell(cell);
            }
            cell=createLabel(person.dateOfBirth,10,2,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            if(MedwanQuery.getInstance().getConfigInt("patientCardModel",1)==2){
	            cell=createLabel(person.comment5,10,1,Font.BOLD);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table.addCell(cell);
	            cell=createLabel(person.gender,10,1,Font.BOLD);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	            table.addCell(cell);
            }
            else {
	            cell=createLabel(person.gender,10,2,Font.BOLD);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
	            table.addCell(cell);
            }

            cell=createBorderlessCell(4);
            table.addCell(cell);

            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardhospitalref",user.person.language),6,4,Font.NORMAL);
            cell.setBorder(PdfPCell.TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            table.addCell(cell);

            doc.add(table);
            doc.setJavaScript_onLoad(MedwanQuery.getInstance().getConfigString("cardJavaScriptOnLoad","document.print();"));
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
