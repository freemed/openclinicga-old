package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import net.admin.User;
import net.admin.AdminPerson;
import com.lowagie.text.*;
import com.lowagie.text.pdf.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.net.URL;
import java.util.Vector;
import java.text.SimpleDateFormat;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFPatientLabelGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFPatientLabelGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, AdminPerson person,int labelcount,String type) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;
        this.type=type;

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
            Rectangle rectangle=null;
            if(type.equalsIgnoreCase("1")){
                rectangle= new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientLabelWidth",360)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientLabelHeight",890)*72/254).floatValue());
            }
            else if(type.equalsIgnoreCase("2")){
                rectangle= new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("patientLabelWidth",280)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("patientLabelHeight",890)*72/254).floatValue());
            }
            doc.setPageSize(rectangle.rotate());
            doc.setMargins(20,20,10,10);
            doc.setJavaScript_onLoad("print();\r");
            doc.open();

            // add content to document
            for (int n=0;n<labelcount;n++){
                if(n>0){
                    doc.newPage();
                }
                printPatientCard(person);
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
            table = new PdfPTable(4);
            table.setWidthPercentage(pageWidth);
            Encounter encounter = Encounter.getActiveEncounter(person.personid);
            if(encounter!=null){
                Chunk chunk0 = new Chunk("ID "+person.personid+"\n\n",FontFactory.getFont(FontFactory.HELVETICA,9,Font.BOLD));
                Chunk chunk1 = new Chunk(new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin())+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD));
                Chunk chunk2 = new Chunk(encounter.getUid(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC));
                Paragraph paragraph = new Paragraph();
                paragraph.add(chunk0);
                paragraph.add(chunk1);
                paragraph.add(chunk2);
                cell = new PdfPCell(paragraph);
                cell.setBorder(Cell.BOX);
                cell.setPaddingLeft(5);
                cell.setPaddingRight(5);
            }
            else {
                cell=createLabel("",6,1,Font.NORMAL);
                cell.setBorder(Cell.NO_BORDER);
            }
            cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
            cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
            table.addCell(cell);

            //Barcode + archiving code
            PdfPTable wrapperTable = new PdfPTable(3);
            wrapperTable.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode("0"+person.personid);
            Image image = barcode39.createImageWithBarcode(cb, null, null);
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

            cell = createBorderlessCell(3);
            cell.addElement(wrapperTable);
            cell.setPadding(0);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            table.addCell(cell);

            //Name
            cell=createLabel(person.firstname+" "+person.lastname,10,4,Font.BOLD);
            cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
            table.addCell(cell);


            if(type.equalsIgnoreCase("1") && encounter!=null){
                //Date of birth & gender
                cell=createLabel(person.dateOfBirth,7,2,Font.NORMAL);
                cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
                table.addCell(cell);
                cell=createLabel(person.gender,7,2,Font.NORMAL);
                cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
                table.addCell(cell);
                //Service & Bed
                cell=createLabel(encounter.getService()!=null?encounter.getService().getLabel(user.person.language)+(encounter.getBed()!=null?" ("+encounter.getBed().getName()+")":""):"",7,4,Font.NORMAL);
                cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
                table.addCell(cell);
                cell=createLabel(encounter.getManager()!=null && User.getUserName(encounter.getManagerUID())!=null?User.getUserName(encounter.getManagerUID()).get("firstname")+" "+User.getUserName(encounter.getManagerUID()).get("lastname"):"",7,4,Font.NORMAL);
                cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
                table.addCell(cell);
            }
            else {
                //Date of birth & gender
                cell=createLabel(person.dateOfBirth+" "+person.gender,7,1,Font.NORMAL);
                cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
                table.addCell(cell);
                //Service & Bed
                cell=createLabel(encounter!=null && encounter.getService()!=null?encounter.getService().getLabel(user.person.language)+(encounter.getBed()!=null?" ("+encounter.getBed().getName()+")":""):"",7,3,Font.NORMAL);
                cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
                table.addCell(cell);
            }



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
