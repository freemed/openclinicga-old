package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.EndPageCard;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Vector;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFUserCardGeneratorNew extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;
    int red=-1;
    int green=-1;
    int blue=-1;

    public int getRed() {
		return red;
	}
	public void setRed(int red) {
		this.red = red;
	}
	public int getGreen() {
		return green;
	}
	public void setGreen(int green) {
		this.green = green;
	}
	public int getBlue() {
		return blue;
	}
	public void setBlue(int blue) {
		this.blue = blue;
	}
	public void addHeader(){
    }
    public void addContent(){
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFUserCardGeneratorNew(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, AdminPerson person) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
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

        docWriter.setPageEvent(new EndPageCard(url,contextPath,projectDir,red,green,blue));
        
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
            table = new PdfPTable(1000);
            table.setWidthPercentage(pageWidth);
            
            /*
            //Logo
            Image image =Image.getInstance(new URL(Helper.translate("http://localhost/cnom",session)+"/_common/_img/cardheader3.png"));
            image.scaleToFit(260*200/254,260);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setColspan(1000);
            cell.setPadding(0);
            table.addCell(cell);
            */
 
            PdfPTable table2 = new PdfPTable(1000);

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
            cell=createLabel(ScreenHelper.getTranNoLink("web","lastname",user.person.language)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            cell=createLabel(person.lastname.toUpperCase(),8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            //FirstName
            cell=createLabel(ScreenHelper.getTranNoLink("web","firstname",user.person.language)+":",6,1,Font.ITALIC);
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
            
            /*
            //Date of birth
            cell=createLabel(ScreenHelper.getTranNoLink("web","dateofbirthshort",user.person.language)+":",6,1,Font.ITALIC);
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
            
            //Place of birth
            cell=createLabel(ScreenHelper.getTranNoLink("web","placeofbirth",user.person.language)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            String placeofbirth=person.nativeTown;
            cell=createLabel(placeofbirth,8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            */
            //Specialty
            cell=createLabel(ScreenHelper.getTranNoLink("web","specialty",user.person.language)+":",6,1,Font.ITALIC);
            cell.setColspan(300);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            String specialty="";
            try {
            	specialty=ScreenHelper.getTranNoLink("web",person.getActivePrivate().businessfunction,user.person.language);
            }
            catch(Exception e){}
            cell=createLabel(specialty,8,1,Font.BOLD);
            cell.setColspan(700);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPadding(1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table2.addCell(cell);
            
            if(MedwanQuery.getInstance().getConfigInt("enableHMKCardModel")==1){
	            //ID number
	            cell=createLabel(ScreenHelper.getTranNoLink("web","ID",user.person.language)+":",6,1,Font.ITALIC);
	            cell.setColspan(300);
	            cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            cell.setPadding(1);
	            table2.addCell(cell);
	            cell=createLabel(ScreenHelper.checkString(person.personid),8,1,Font.BOLD);
	            cell.setColspan(700);
	            cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setPadding(1);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table2.addCell(cell);
	            //ID number
	            cell=createLabel(ScreenHelper.getTranNoLink("web","natreg.short",user.person.language)+":",6,1,Font.ITALIC);
	            cell.setColspan(300);
	            cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            cell.setPadding(1);
	            table2.addCell(cell);
	            cell=createLabel(ScreenHelper.checkString(person.getID("natreg")),8,1,Font.BOLD);
	            cell.setColspan(700);
	            cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setPadding(1);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table2.addCell(cell);
            }
            else {
	            //Registration number
	            cell=createLabel(ScreenHelper.getTranNoLink("web","regnumber",user.person.language)+":",6,1,Font.ITALIC);
	            cell.setColspan(300);
	            cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            cell.setPadding(1);
	            table2.addCell(cell);
	            cell=createLabel(ScreenHelper.checkString(person.getID("immatnew")),8,1,Font.BOLD);
	            cell.setColspan(700);
	            cell.setBorder(PdfPCell.NO_BORDER);
	            cell.setPadding(1);
	            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	            table2.addCell(cell);
	            table2.addCell(createBorderlessCell("\n", 1000));
            }

            
            //Barcode
            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("0"+person.personid);
            barcode39.setAltText("");
            barcode39.setSize(1);
            barcode39.setBaseline(0);
            barcode39.setBarHeight(10);
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
            Picture picture = new Picture(Integer.parseInt(person.personid));
            image=picture.getImage();
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
            cell=createLabel(ScreenHelper.getTranNoLink("web","deliverydate",user.person.language),6,1,Font.ITALIC);
            cell.setColspan(550);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPaddingRight(5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            cell=createLabel(ScreenHelper.stdDateFormat.format(new java.util.Date()),6,1,Font.BOLD);
            cell.setColspan(450);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setPadding(0);
            table2.addCell(cell);

            //Expiry data
            cell=createLabel(ScreenHelper.getTranNoLink("web","expirydate",user.person.language),6,1,Font.ITALIC);
            cell.setColspan(550);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPaddingRight(5);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            table2.addCell(cell);
            long day = 24*3600*1000;
            long year = 365*day;
            long period = Integer.parseInt(MedwanQuery.getInstance().getConfigString("cardvalidityperiod", "3")) * year - day;
            cell=createLabel(ScreenHelper.stdDateFormat.format(new java.util.Date(new java.util.Date().getTime()+period)),6,1,Font.BOLD);
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

            cell=createLabel(ScreenHelper.getTranNoLink("web","cardfooter2",user.person.language),6,1,Font.ITALIC);
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
