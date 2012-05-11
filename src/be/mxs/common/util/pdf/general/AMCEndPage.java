package be.mxs.common.util.pdf.general;

import java.net.URL;

import javax.servlet.http.HttpSession;

import be.mxs.common.util.db.MedwanQuery;

import com.itextpdf.text.Document;
import com.itextpdf.text.ExceptionConverter;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;


public class AMCEndPage extends PdfPageEventHelper {

    //--- ON END PAGE -----------------------------------------------------------------------------
    // add "duplicata" in background of each page of the PDF document.
    //---------------------------------------------------------------------------------------------
    public void onEndPage(PdfWriter writer, Document document) {
        try{
            // load image
            Image watermarkImg = Image.getInstance(new URL(MedwanQuery.getInstance().getConfigString("imageSource","http://localhost/openclinic")+"/_img/amccardheader.gif"));
            watermarkImg.scaleToFit(310*200/254,310);
            //watermarkImg.setRotationDegrees(30);
            int[] transparencyValues = {100,100};
            //watermarkImg.setTransparency(transparencyValues);
            watermarkImg.setAbsolutePosition(0,109);

			// these are the canvases we are going to use
            PdfContentByte under = writer.getDirectContentUnder();
            under.addImage(watermarkImg);
        }
        catch(Exception e) {
        	e.printStackTrace();
            throw new ExceptionConverter(e);
        }
    }

}
