package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.chuk.Article;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;
import net.admin.User;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.util.Vector;
import java.util.Hashtable;
import java.util.Enumeration;

public class PDFImmoLabelGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;
    
    public void addHeader(){
    }
    public void addContent(){
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFImmoLabelGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Vector articles) throws Exception {
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

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            
			Rectangle rectangle = new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("immoLabelWidth",450)*72/254).floatValue(),new Float(MedwanQuery.getInstance().getConfigInt("immoLabelHeight",220)*72/254).floatValue());
            doc.setPageSize(rectangle);
            doc.setMargins(2,2,2,2);
            doc.setJavaScript_onLoad("print();\r");
            doc.open();
            
            printImmoLabels(articles);
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

    //--- PRINT IMMO LABELS -----------------------------------------------------------------------
    protected void printImmoLabels(Vector articles){
        try{
        	Article article;
            for(int n=0; n<articles.size(); n++){
            	article = (Article)articles.elementAt(n);
            	
            	// barcode
                PdfContentByte cb = docWriter.getDirectContent();
                Barcode39 barcode39 = new Barcode39();
                String id = article.id;
                barcode39.setCode(id);
                barcode39.setFont(null);                
                Image image = barcode39.createImageWithBarcode(cb, null, null);
                image.scaleAbsoluteHeight((new Float(MedwanQuery.getInstance().getConfigInt("immoLabelHeigth",220)*72/254).floatValue()-doc.topMargin()-doc.bottomMargin())*1/2);
                image.scaleAbsoluteWidth((new Float(MedwanQuery.getInstance().getConfigInt("immoLabelWidth",450)*72/254).floatValue()-doc.leftMargin()-doc.rightMargin())*4/5);
                table = new PdfPTable(1);
                table.setWidthPercentage(100);
                cell=new PdfPCell(image);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setColspan(1);
                cell.setPadding(0);
                table.addCell(cell);
                
                // part 1 : service/location
                cell = new PdfPCell(new Paragraph(article.name.split("_")[0],FontFactory.getFont(FontFactory.COURIER,MedwanQuery.getInstance().getConfigInt("immofontsize",8),Font.BOLD)));
                cell.setColspan(1);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setPadding(0);
                table.addCell(cell);
                
                // part 2 : code/buyer
                cell = new PdfPCell(new Paragraph(article.name.split("_")[1],FontFactory.getFont(FontFactory.COURIER,MedwanQuery.getInstance().getConfigInt("immofontsize",8),Font.BOLD)));
                cell.setColspan(1);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setPadding(0);
                table.addCell(cell);
                
                doc.add(table);
                doc.newPage();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}