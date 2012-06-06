package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.Insurance;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.Product;
import be.openclinic.system.Center;
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
import java.text.SimpleDateFormat;
import java.net.URL;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFOpeninsuranceCardGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFOpeninsuranceCardGenerator(User user, String sProject){
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
            doc.setMargins(0,0,0,0);
            doc.setJavaScript_onLoad("print();\r");
            doc.open();
            sPrintLanguage=user.person.language;
            patient=person;

            // add content to document
            printInsuranceCard(person);
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

    protected void printInsuranceCard(AdminPerson person){
        try {
            table = new PdfPTable(70);
            table.setWidthPercentage(pageWidth);
            //Logo
            if(url.indexOf("openinsurance",10) > 0){
            	url = url.substring(0,url.indexOf("openinsurance", 10));
            }
            Image image =Image.getInstance(new URL(url+contextPath+projectDir+"/_img/logo_insurancecard.gif"));
            image.scaleToFit(72*240/254,72);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(20);
            cell.setPadding(3);
            table.addCell(cell);

            PdfPTable subTable = new PdfPTable(1);
            subTable.setWidthPercentage(100);
            cell = createTitle(Center.get(0, true).getName().replace("<br>","\n"),1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            subTable.addCell(cell);
            cell = createRedTitle(ScreenHelper.getTranNoLink("jubilee","medicalcard",sPrintLanguage),1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            subTable.addCell(cell);
            
            cell=new PdfPCell(subTable);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(50);
            table.addCell(cell);
            
            Picture picture = new Picture(Integer.parseInt(person.personid));
            image=picture.getImage();
            if(image!=null){
                image.scaleToFit(72*260/254,72*300/254);
                cell = new PdfPCell(image);
            }
            else {
                cell = new PdfPCell();
            }
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(20);
            cell.setPaddingLeft(4);
            table.addCell(cell);

            subTable = new PdfPTable(200);
            subTable.setWidthPercentage(100);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","employeename",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            Insurance insurance=Insurance.getMostInterestingInsuranceForPatient(patient.personid);
            cell=createBorderlessCellWithStyle(insurance!=null?insurance.getMember():" ",110, Font.BOLD,7);
            cell.setPadding(1);
            subTable.addCell(cell);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","affiliatename",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            cell=createBorderlessCellWithStyle(patient.lastname.toUpperCase()+", "+patient.firstname,110, Font.BOLD,7);
            cell.setPadding(1);
            subTable.addCell(cell);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","membernumber",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            cell=createBorderlessCellWithStyle(insurance!=null?insurance.getInsuranceNr():" ",110, Font.BOLD,8);
            cell.setPadding(1);
            subTable.addCell(cell);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","dateofbirth",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            cell=createBorderlessCellWithStyle(patient.dateOfBirth,110, Font.BOLD,8);
            cell.setPadding(1);
            subTable.addCell(cell);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","identitynumber",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            cell=createBorderlessCellWithStyle(patient.getID("natreg")+" ",110, Font.BOLD,8);
            cell.setPadding(1);
            subTable.addCell(cell);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","employer",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            cell=createBorderlessCellWithStyle(insurance!=null?insurance.getInsurar().getName():" ",110, Font.BOLD,8);
            cell.setPadding(1);
            subTable.addCell(cell);

            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","validfrom",sPrintLanguage)+":", 90,Font.BOLD,7);
            cell.setPaddingLeft(8);
            cell.setPaddingRight(0);
            cell.setPaddingTop(1);
            cell.setPaddingBottom(1);
            subTable.addCell(cell);
            cell=createBorderlessCellWithStyle(insurance!=null?new SimpleDateFormat("dd/MM/yyyy").format(insurance.getStart()):" ",110, Font.BOLD,8);
            cell.setPadding(1);
            subTable.addCell(cell);
            
            cell=new PdfPCell(subTable);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setColspan(50);
            table.addCell(cell);
            
            cell=createBorderlessCell(" ",70);
            table.addCell(cell);
            cell=createBorderlessCellWithStyle(ScreenHelper.getTranNoLink("jubilee","emergencynumbers",sPrintLanguage)+": ", 35, Font.BOLD, 7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            cell.setPadding(1);
            table.addCell(cell);
            cell=createBorderlessCellWithStyle(patient.comment3, 35, FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD,BaseColor.RED), 7);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setPadding(1);
            table.addCell(cell);
            doc.add(table);
            doc.newPage();
            table= new PdfPTable(70);
            table.setWidthPercentage(pageWidth);
            image =Image.getInstance(new URL(url+contextPath+projectDir+"/_img/verso_insurancecard.gif"));
            if(image!=null){
                image.scaleToFit(new Float(MedwanQuery.getInstance().getConfigInt("patientCardWidth",860)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientCardWidth",540)*72/254).floatValue());
                cell = new PdfPCell(image);
            }
            else {
                cell = new PdfPCell();
            }
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setColspan(70);
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
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createRedTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,12,Font.BOLD,BaseColor.RED)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
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
    
    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCellWithStyle(String value, int colspan,int style,int size){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,size,style)));
        cell.setPaddingTop(3); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCellWithStyle(String value, int colspan,Font font,int size){
        cell = new PdfPCell(new Paragraph(value,font));
        cell.setPaddingTop(3); //
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
