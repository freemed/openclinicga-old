package be.mxs.common.util.pdf.official;

import com.lowagie.text.pdf.*;
import com.lowagie.text.*;
import com.lowagie.text.Image;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.db.MedwanQuery;

public class EndPage extends PdfPageEventHelper {

    //--- ON END PAGE -----------------------------------------------------------------------------
    // add "duplicata" in background of each page of the PDF document.
    //---------------------------------------------------------------------------------------------
    public void onEndPage(PdfWriter writer, Document document) {
        try{
            // load image
            Image watermarkImg = Miscelaneous.getImage("chukwatermark.gif",MedwanQuery.getInstance().getConfigString("defaultProject",""));
            watermarkImg.setRotationDegrees(30);
            int[] transparencyValues = {100,100};
            watermarkImg.setTransparency(transparencyValues);
            watermarkImg.setAbsolutePosition(document.leftMargin()+ MedwanQuery.getInstance().getConfigInt("cardWatermarkLeftMargin",7),MedwanQuery.getInstance().getConfigInt("cardWatermarkTopMargin",10));

            /*
            java.awt.Image awtImage = Miscelaneous.getImage("duplicata.gif");
            Image pdfImage = Image.getInstance(awtImage,new Color(220,220,220));
            pdfImage.setRotationDegrees(45);
            pdfImage.setAbsolutePosition(document.leftMargin()+7,150);
            */

			// these are the canvases we are going to use
            PdfContentByte under = writer.getDirectContentUnder();
            under.addImage(watermarkImg);
        }
        catch(Exception e) {
            throw new ExceptionConverter(e);
        }
    }

}
