package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import net.admin.User;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.util.Vector;

public class PDFArchiveDocumentBarcodeGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;
    
    public void addHeader(){
    }
    
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFArchiveDocumentBarcodeGenerator(User user, String sProject){
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
            sURL = sURL.substring(0,sURL.indexOf("openclinic",10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

        ///////////////////////////////////////////////////////////////////////////////////////////
    	String sBarcode = checkString(req.getParameter("barcodeValue"));
      	int numberOfPrints = Integer.parseInt(checkString(req.getParameter("numberOfPrints")));

    	Debug.println("\n****************** PDFArchiveDocumentBarcodeGenerator ******************");
    	Debug.println("sBarcode       : "+sBarcode);
    	Debug.println("numberOfPrints : "+numberOfPrints);
        ///////////////////////////////////////////////////////////////////////////////////////////
    	
		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");  
			
			Rectangle rectangle = new Rectangle(0,0,new Float(MedwanQuery.getInstance().getConfigInt("archiveDocumentBarcodeWidth",600)*72/254).floatValue(),
					                                new Float(MedwanQuery.getInstance().getConfigInt("archiveDocumentBarcodeHeight",100)*72/254).floatValue());
            doc.setPageSize(rectangle);
            doc.setMargins(0,0,0,0);
         
            doc.setJavaScript_onLoad(MedwanQuery.getInstance().getConfigString("cardJavaScriptOnLoad","document.print();"));
            doc.open();

            // add content to document            
            for(int n=0; n<numberOfPrints; n++){
                if(n>0){
                	doc.newPage();
                }
            	printBarcode(sBarcode);
                
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

    //--- PRINT BARCODE ---------------------------------------------------------------------------
    protected void printBarcode(String sCode){
        try {
            table = new PdfPTable(1);
            table.setWidthPercentage(100);

            PdfContentByte cb = docWriter.getDirectContent();
            Barcode39 barcode39 = new Barcode39();
            barcode39.setCode(sCode);
            Image image = barcode39.createImageWithBarcode(cb,null,null);
            cell = new PdfPCell(image);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setPaddingTop(0);
            cell.setPaddingBottom(0);

            table.addCell(cell);

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
}
