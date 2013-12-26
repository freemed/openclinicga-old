package be.mxs.common.util.pdf.general;

import java.net.URL;

import javax.servlet.http.HttpSession;

import be.mxs.common.util.db.MedwanQuery;

import com.itextpdf.text.Document;
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


public class PDFFooter extends PdfPageEventHelper {
	String sFooterText="";
	int pagecount=0;
	
	public PDFFooter(String sFooterText){
		this.sFooterText=sFooterText;
	}
	
    //--- ON END PAGE -----------------------------------------------------------------------------
    public void onEndPage (PdfWriter writer, Document document) {
    	pagecount++;
        Rectangle rect = document.getPageSize();
        if(MedwanQuery.getInstance().getConfigInt("patientinvoicefootertop",0)==1){
	        ColumnText.showTextAligned(writer.getDirectContent(),
	                Element.ALIGN_CENTER, new Phrase(sFooterText,FontFactory.getFont(FontFactory.HELVETICA,6)),
	                (rect.getLeft() + rect.getRight()) / 2, rect.getTop() - 26, 0);
	        ColumnText.showTextAligned(writer.getDirectContent(),
	                Element.ALIGN_CENTER, new Phrase(pagecount+"",FontFactory.getFont(FontFactory.HELVETICA,6)),
	                (rect.getLeft() + rect.getRight()) / 2, rect.getTop() - 18, 0);
        }
        else{
	        ColumnText.showTextAligned(writer.getDirectContent(),
	                Element.ALIGN_CENTER, new Phrase(sFooterText,FontFactory.getFont(FontFactory.HELVETICA,6)),
	                (rect.getLeft() + rect.getRight()) / 2, rect.getBottom() + 26, 0);
	        ColumnText.showTextAligned(writer.getDirectContent(),
	                Element.ALIGN_CENTER, new Phrase(pagecount+"",FontFactory.getFont(FontFactory.HELVETICA,6)),
	                (rect.getLeft() + rect.getRight()) / 2, rect.getBottom() + 18, 0);
        }
    }

}
