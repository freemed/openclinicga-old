package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFUserCardGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;

    public void addHeader(){
    }
    public void addContent(){
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFUserCardGenerator(User user, String sProject){
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

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
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
            doc.open();

            // add content to document
            printUserCard(person);
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

    protected void printUserCard(AdminPerson person){
        try {
            table = new PdfPTable(4);
            table.setWidthPercentage(pageWidth);
            //Logo
            Picture picture = new Picture(Integer.parseInt(person.personid));
            Image image=picture.getImage();
            if(image!=null){
                image.scaleToFit(72*200/254,72);
                cell = new PdfPCell(image);
            }
            else {
                cell = new PdfPCell();
            }
            cell.setBorder(Cell.NO_BORDER);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            cell.setColspan(1);
            cell.setPadding(0);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            table.addCell(cell);

            //Barcode + archiving code
            PdfPTable wrapperTable = new PdfPTable(3);
            wrapperTable.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("0"+person.personid);
            image = barcode39.createImageWithBarcode(cb, null, null);
            cell = new PdfPCell(image);
            cell.setBorder(Cell.NO_BORDER);
            cell.setVerticalAlignment(Cell.ALIGN_TOP);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setColspan(2);
            cell.setPadding(0);
            wrapperTable.addCell(cell);

            PdfPTable subTable = new PdfPTable(1);
            subTable.setWidthPercentage(100);
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardarchivecode",user.person.language),6,1,Font.ITALIC);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPadding(0);
            subTable.addCell(cell);
            cell=createLabel(person.getID("archiveFileCode").toUpperCase(),10,1,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPadding(0);
            subTable.addCell(cell);
            cell = createBorderlessCell(1);
            cell.addElement(subTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            wrapperTable.addCell(cell);

            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardfunction",user.person.language),6,3,Font.ITALIC);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPadding(0);
            wrapperTable.addCell(cell);
            cell=createLabel(person.getActivePrivate().businessfunction,9,3,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPadding(0);
            wrapperTable.addCell(cell);
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardservice",user.person.language),6,3,Font.ITALIC);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPadding(0);
            wrapperTable.addCell(cell);
            cell=createLabel(person.getActivePrivate().business,9,3,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            cell.setPadding(0);
            wrapperTable.addCell(cell);

            cell = createBorderlessCell(3);
            cell.addElement(wrapperTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            table.addCell(cell);


            //Name
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardname",user.person.language),6,4,Font.ITALIC);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            table.addCell(cell);
            cell=createLabel(person.firstname+" "+person.lastname,10,4,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            table.addCell(cell);

            //Date of birth & gender
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","carddateofbirth",user.person.language),6,2,Font.ITALIC);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            table.addCell(cell);
            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardgender",user.person.language),6,2,Font.ITALIC);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            table.addCell(cell);
            cell=createLabel(person.dateOfBirth,10,2,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            table.addCell(cell);
            cell=createLabel(person.gender,10,2,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            table.addCell(cell);

            cell=createBorderlessCell(4);
            cell.setBorder(PdfCell.BOTTOM);
            table.addCell(cell);

            cell=createLabel(MedwanQuery.getInstance().getLabel("web","cardexpiration",user.person.language)+": "+new SimpleDateFormat("dd/MM/").format(new Date())+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new Date()))+3),6,4,Font.NORMAL);
            cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
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
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

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
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);

        return cell;
    }

}
