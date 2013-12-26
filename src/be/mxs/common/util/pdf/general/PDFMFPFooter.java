package be.mxs.common.util.pdf.general;

import java.net.URL;

import javax.servlet.http.HttpSession;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Miscelaneous;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.ExceptionConverter;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;


public class PDFMFPFooter extends PdfPageEventHelper {
	String sFooterText="";
	int pagecount=0;
	boolean validated;
	
	public PDFMFPFooter(String sFooterText,boolean validated){
		this.validated=validated;
		this.sFooterText=sFooterText;
	}
	
    //--- ON END PAGE -----------------------------------------------------------------------------
    // add "duplicata" in background of each page of the PDF document.
    //---------------------------------------------------------------------------------------------
    public void onEndPage (PdfWriter writer, Document document) {
    	pagecount++;
    	
    	if(validated){
	    	// load image
	        Image watermarkImg = Miscelaneous.getImage("validated.gif",MedwanQuery.getInstance().getConfigString("defaultProject",""));
	        watermarkImg.setRotationDegrees(30);
	        int[] transparencyValues = {100,100};
	        watermarkImg.setTransparency(transparencyValues);
	        watermarkImg.setAbsolutePosition(document.leftMargin()+ MedwanQuery.getInstance().getConfigInt("validateWatermarkLeftMargin",7),MedwanQuery.getInstance().getConfigInt("validateWatermarkTopMargin",10));
	
			// these are the canvases we are going to use
	        PdfContentByte under = writer.getDirectContentUnder();
	        try {
				under.addImage(watermarkImg);
			} catch (DocumentException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    	}
        Rectangle rect = document.getPageSize();
        ColumnText.showTextAligned(writer.getDirectContent(),
                Element.ALIGN_CENTER, new Phrase(sFooterText,FontFactory.getFont(FontFactory.HELVETICA,6)),
                (rect.getLeft() + rect.getRight()) / 2, rect.getBottom() + 26, 0);
        ColumnText.showTextAligned(writer.getDirectContent(),
                Element.ALIGN_CENTER, new Phrase(pagecount+"",FontFactory.getFont(FontFactory.HELVETICA,6)),
                (rect.getLeft() + rect.getRight()) / 2, rect.getBottom() + 18, 0);
    }

}
