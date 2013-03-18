package be.mxs.common.util.pdf.official;

import com.itextpdf.text.Document;
import com.itextpdf.text.ExceptionConverter;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;
import java.net.URL;

import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.db.MedwanQuery;

public class EndPageCard extends PdfPageEventHelper {
	
	String url;
	String contextPath;
	String projectDir;
	
	public EndPageCard(String url,String contextPath,String projectDir){
		this.url=url;
		this.contextPath=contextPath;
		this.projectDir=projectDir;
	}

    //--- ON END PAGE -----------------------------------------------------------------------------
    // add "duplicata" in background of each page of the PDF document.
    //---------------------------------------------------------------------------------------------
    public void onEndPage(PdfWriter writer, Document document) {
        try{
            // load image
            Image watermarkImg =Image.getInstance(new URL(url+contextPath+projectDir+"/_img/cardheader3.png"));
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
            throw new ExceptionConverter(e);
        }
    }

}
