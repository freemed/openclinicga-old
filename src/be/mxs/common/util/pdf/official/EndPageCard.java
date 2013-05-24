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
	int red=-1;
	int green=-1;
	int blue=-1;
	
	public EndPageCard(String url,String contextPath,String projectDir){
		this.url=url;
		this.contextPath=contextPath;
		this.projectDir=projectDir;
	}

	public EndPageCard(String url,String contextPath,String projectDir,int red, int green,int blue){
		this.url=url;
		this.contextPath=contextPath;
		this.projectDir=projectDir;
		this.red=red;
		this.green=green;
		this.blue=blue;
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
            if(red>-1 && green>-1 && blue>-1){
            	//Add colored stripes left and right 
	            under.setRGBColorFill(red, green, blue);
            	if(MedwanQuery.getInstance().getConfigString("userCardColorShape","").equalsIgnoreCase("rectangle")){
		            under.rectangle(0, 0, 8, 109);
		            under.rectangle(310*200/254-9, 0, 8, 109);
            	}
            	else if(MedwanQuery.getInstance().getConfigString("userCardColorShape","").equalsIgnoreCase("circle")){
            		under.circle(MedwanQuery.getInstance().getConfigInt("userCardColorShapeX",115),MedwanQuery.getInstance().getConfigInt("userCardColorShapeY",60),MedwanQuery.getInstance().getConfigInt("userCardColorShapeSize",20));
            	}
            }
            under.fill();
            
        }
        catch(Exception e) {
            throw new ExceptionConverter(e);
        }
    }

}
