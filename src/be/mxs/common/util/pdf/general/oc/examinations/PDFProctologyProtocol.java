package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;
import com.itextpdf.text.Image;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.Vector;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFProctologyProtocol extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                //*** varia 1 *************************************************
                // motive
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_MOTIVE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","motive"),itemValue);
                }

                // external_examination
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_EXTERNAL_EXAMINATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","external_examination"),itemValue);
                }

                // touch_rectum
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_TOUCH_RECTUM");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","touch_rectum"),itemValue);
                }
                
                // add transaction to doc
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }

                //*** anuscopy ************************************************
                addAnuscopy();

                //*** varia 2 *************************************************
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                // rectosigmoidoscopy
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RECTOSIGMOIDOSCOPY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","rectosigmoidoscopy"),itemValue);
                }

                //*** investigations_done (BIOSCOPY) ***
                String investigations = "";

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy");
                }

                /*
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_BIOSCOPY2");
                if(itemValue.equalsIgnoreCase("medwan.common.true")){
                    if(investigations.length() > 0) investigations+= ", ";
                    investigations+= getTran("openclinic.chuk","bioscopy2");
                }
                */

                if(investigations.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","investigations_done"),investigations);
                }

                // conclusion
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
                }               

                // remarks
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_REMARKS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
                }

                // add transaction to doc
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }

                // diagnoses
                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################

    //--- DRAW DOT --------------------------------------------------------------------------------
    private void drawDot(Graphics2D graphics, double x, double y, Color color, int size){
    	System.out.println("DRAWDOT : x="+x+", y="+y+", s="+size); ///////////////////////////////////////////
        graphics.setColor(color);
        graphics.fillOval(new Double(x).intValue(),new Double(y).intValue(),size,size);
    }

    //--- ADD ANUSCOPY ---------------------------------------------------------------------------- 
    private void addAnuscopy(){
        Vector list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BACK");
        list.add(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BACK");
        list.add(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_IMAGE_COORDS");
        list.add(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BELLY");
        list.add(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BELLY");

        if(verifyList(list)){
            try{
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);

                PdfPTable anuscopyTable = new PdfPTable(8);

                // left back textarea
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BACK");
                anuscopyTable.addCell(createValueCell(itemValue,3));

                // back title
                cell = createValueCell(getTran("openclinic.chuk","back"),2);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_BOTTOM);
                cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.TOP); // no bottom
                anuscopyTable.addCell(cell);

                // right back textarea
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BACK");
                anuscopyTable.addCell(createValueCell(itemValue,3));

                //*** image ***
                // left
                cell = createValueCell(getTran("web.occup","medwan.common.left"),3);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBorder(PdfPCell.LEFT+PdfPCell.TOP+PdfPCell.BOTTOM); // no right
                anuscopyTable.addCell(cell);

                MediaTracker mediaTracker = new MediaTracker(new Container());
                java.awt.Image imgPointer = Miscelaneous.getImage("anuscopie.gif");
                mediaTracker.addImage(imgPointer,0);
                mediaTracker.waitForID(0);

                BufferedImage locationImg = new BufferedImage(imgPointer.getWidth(null),imgPointer.getHeight(null),BufferedImage.TYPE_INT_RGB);
                Graphics2D graphics = locationImg.createGraphics();
                graphics.drawImage(imgPointer,0,0,Color.WHITE,null);

                // get coordinates and visualize them with red dots
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_IMAGE_COORDS");
                Debug.println("coords : "+itemValue);
                
                String[] coords = itemValue.split(";");
                String[] oneCoord;
                int xPos, yPos;
                
                for(int i=0; i<coords.length; i++){
                    if(coords[i].length() > 0){
                        oneCoord = coords[i].split(",");
                        xPos = Integer.parseInt(oneCoord[0]);
                        yPos = Integer.parseInt(oneCoord[1]);

                        drawDot(graphics,xPos-344,yPos-388,Color.RED,5); // this correction because coords are relative to left-top corner of browser
                    }
                }

                // add image
                cell = new PdfPCell();
                cell.setImage(Image.getInstance(locationImg,null));
                cell.setHorizontalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setPadding(7);
                cell.setColspan(2);
                anuscopyTable.addCell(cell);

                // right
                cell = createValueCell(getTran("web.occup","medwan.common.right"),3);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBorder(PdfPCell.RIGHT+PdfPCell.TOP+PdfPCell.BOTTOM); // no left
                anuscopyTable.addCell(cell);

                // right back textarea
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_LEFT_BELLY");
                anuscopyTable.addCell(createValueCell(itemValue,3));

                // belly title
                cell = createValueCell(getTran("openclinic.chuk","belly"),2);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setBorder(PdfPCell.LEFT+PdfPCell.RIGHT+PdfPCell.BOTTOM); // no top
                anuscopyTable.addCell(cell);

                // right belly textarea
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_PROCOTOLOGY_PROTOCOL_RIGHT_BELLY");
                anuscopyTable.addCell(createValueCell(itemValue,3));

                // add anuscopy
                table.addCell(createItemNameCell(getTran("openclinic.chuk","anuscopy"),2));

                cell = new PdfPCell(anuscopyTable);
                cell.setColspan(3);
                table.addCell(cell);

                // add transaction to doc
                if(table.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(new PdfPCell(contentTable));
                    addTransactionToDoc();
                }         
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }
    
}
