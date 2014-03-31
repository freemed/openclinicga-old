package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Miscelaneous;

import java.awt.*;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.util.Hashtable;
import java.util.Vector;
import java.util.Collections;
import java.util.Enumeration;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;

/**
 * User: ssm
 * Date: 25-jul-2007
 */
public class PDFDentist extends PDFGeneralBasic {
    private final BaseColor aqua    = new BaseColor(0,191,255),
                        blue    = new BaseColor(0,0,205),
                        fuchsia = new BaseColor(218,112,214),
                        gray    = new BaseColor(166,166,166),
                        lime    = new BaseColor(50,205,50),
                        maroon  = new BaseColor(139,58,58),
                        gold    = new BaseColor(255,215,0),
                        red     = new BaseColor(238,44,44),
                        green   = new BaseColor(34,139,34);

    //--- INNER CLASS TOOTH -----------------------------------------------------------------------
    private class Tooth{
        private String date, toothNr, descr, treatment, status;

        //--- CONSTRUCTOR ---
        public Tooth(String sDate, String toothNr, String descr, String treatment, String status){
            this.date = sDate;
            this.toothNr = toothNr;
            this.descr = descr;
            this.treatment = treatment;
            this.status = status;
        }
    }


    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){

                // todo : get data
                //*** GET DATA FROM TRAN **************************************
                PdfPTable teethTable = new PdfPTable(16);
                Hashtable selectedTeeth = new Hashtable(),
                          teeth         = new Hashtable();

                String sTeeth = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_STOMATOLOGY_CONSULTATION_TEETH");
                if (sTeeth.indexOf("£")>-1){
                    StringBuffer sTmpTeeth = new StringBuffer(sTeeth);
                    String sTmpDate, sTmpToothNr, sTmpDescr, sTmpTreatment, sTmpStatus;

                    while (sTmpTeeth.toString().toLowerCase().indexOf("$")>-1) {
                        sTmpDate = "";
                        if (sTmpTeeth.toString().toLowerCase().indexOf("£")>-1){
                            sTmpDate = sTmpTeeth.substring(0,sTmpTeeth.toString().toLowerCase().indexOf("£"));
                            sTmpTeeth = new StringBuffer(sTmpTeeth.substring(sTmpTeeth.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpToothNr = "";
                        if (sTmpTeeth.toString().toLowerCase().indexOf("£")>-1){
                            sTmpToothNr = sTmpTeeth.substring(0,sTmpTeeth.toString().toLowerCase().indexOf("£"));
                            sTmpTeeth = new StringBuffer(sTmpTeeth.substring(sTmpTeeth.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpDescr = "";
                        if (sTmpTeeth.toString().toLowerCase().indexOf("£")>-1){
                            sTmpDescr = sTmpTeeth.substring(0,sTmpTeeth.toString().toLowerCase().indexOf("£"));
                            sTmpTeeth = new StringBuffer(sTmpTeeth.substring(sTmpTeeth.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpTreatment = "";
                        if (sTmpTeeth.toString().toLowerCase().indexOf("£")>-1){
                            sTmpTreatment = sTmpTeeth.substring(0,sTmpTeeth.toString().toLowerCase().indexOf("£"));
                            sTmpTeeth = new StringBuffer(sTmpTeeth.substring(sTmpTeeth.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpStatus = "";
                        if (sTmpTeeth.toString().toLowerCase().indexOf("$")>-1){
                            sTmpStatus = sTmpTeeth.substring(0,sTmpTeeth.toString().toLowerCase().indexOf("$"));
                            sTmpTeeth = new StringBuffer(sTmpTeeth.substring(sTmpTeeth.toString().toLowerCase().indexOf("$")+1));
                        }

                        // replace <br>
                        sTmpDescr = sTmpDescr.replaceAll("<br>","\n");
                        sTmpTreatment = sTmpTreatment.replaceAll("<br>","\n");

                        // add tooth
                        teeth.put(sTmpToothNr,new PDFDentist.Tooth(sTmpDate,sTmpToothNr,sTmpDescr,sTmpTreatment,sTmpStatus));
                    }
                }

                // sort teeth before displaying them
                Vector toothNrs = new Vector(teeth.keySet());
                Collections.sort(toothNrs);
                PDFDentist.Tooth tooth;
                String nr;

                for (int i=0; i<toothNrs.size(); i++) {
                    nr = (String)toothNrs.get(i);
                    tooth = (PDFDentist.Tooth)teeth.get(nr);

                    selectedTeeth.put(nr,tooth);
                    teethTable = addToothToPDFTable(teethTable,tooth.date,tooth.toothNr,tooth.descr,tooth.treatment,tooth.status);
                }

                // todo : image
                //*** IMAGE ***************************************************
                if(selectedTeeth.size() > 0){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);

                    MediaTracker mediaTracker = new MediaTracker(new Container());
                    Image imgPointer = Miscelaneous.getImage("img_gebit.gif");
                    mediaTracker.addImage(imgPointer,0);
                    mediaTracker.waitForID(0);

                    BufferedImage gebitImg = new BufferedImage(imgPointer.getWidth(null),imgPointer.getHeight(null),BufferedImage.TYPE_INT_RGB);
                    Graphics2D graphics = gebitImg.createGraphics();
                    graphics.drawImage(imgPointer,0,0,Color.WHITE,null);

                    // get coordinates and visualize them with coloured dots
                    Hashtable toothCoords = getToothCoords();
                    String toothNr;
                    int[] oneCoord;

                    Enumeration toothNrEnum = selectedTeeth.keys();
                    while(toothNrEnum.hasMoreElements()){
                        toothNr = (String)toothNrEnum.nextElement();
                        tooth = (PDFDentist.Tooth)selectedTeeth.get(toothNr);

                        oneCoord = (int[])toothCoords.get(toothNr);
                        drawDot(graphics,oneCoord[0],oneCoord[1],getToothColor(tooth.status),oneCoord[2]);
                    }

                    table.addCell(createItemNameCell(getTran("web","teeth")));

                    // add image
                    cell = new PdfPCell();
                    cell.setImage(com.itextpdf.text.Image.getInstance(gebitImg,null));
                    cell.setHorizontalAlignment(PdfPCell.ALIGN_MIDDLE);
                    cell.setPadding(10);
                    cell.setColspan(2);
                    cell.setBorder(PdfPCell.LEFT+PdfPCell.TOP+PdfPCell.BOTTOM); // no right
                    cell.setBorderColor(innerBorderColor);
                    table.addCell(cell);

                    // legend at right
                    Phrase phrase = new Phrase(getTran("openclinic.chuk","tooth.absent")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,aqua));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.fill")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,blue)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.unnerve")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,fuchsia)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.unnerve_fill")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,gray)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.fracturée")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,lime)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.impactée")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,maroon)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.incluse")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,gold)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.ectopique")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,red)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.surnuméraire")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,green)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.caries")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,BaseColor.BLACK)));
                    phrase.add(new Chunk(getTran("openclinic.chuk","tooth.other")+"\n",FontFactory.getFont(FontFactory.HELVETICA,8,com.itextpdf.text.Font.NORMAL,BaseColor.ORANGE)));
              
                    cell = new PdfPCell(phrase);
                    cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                    cell.setBorder(PdfPCell.RIGHT+PdfPCell.TOP+PdfPCell.BOTTOM); // no left
                    cell.setBorderColor(innerBorderColor);
                    table.addCell(cell);

                    // add table
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // todo : tooth records
                //*** TOOTH RECORDS *******************************************

                // add toothRecords to table
                if(teethTable.size() > 0){
                    tranTable.addCell(createContentCell(teethTable));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD TOOTH TO PDF TABLE ------------------------------------------------------------------
    private PdfPTable addToothToPDFTable(PdfPTable pdfTable, String date, String sToothNr, String sDescr,
                                         String sTreatment, String sStatus){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.date"),2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","tooth"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","problem description"),5));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","treatment"),5));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","status"),3));
        }

        pdfTable.addCell(createValueCell(date,2));
        pdfTable.addCell(createValueCell(sToothNr,1));
        pdfTable.addCell(createValueCell(sDescr,5));
        pdfTable.addCell(createValueCell(sTreatment,5));
        pdfTable.addCell(createValueCell(getTran("openclinic.chuk",sStatus),3));

        return pdfTable;
    }

    //--- DRAW DOT --------------------------------------------------------------------------------
    private void drawDot(Graphics2D graphics, double x, double y, BaseColor color, int size){
        graphics.setColor(new java.awt.Color(color.getRGB()));
        graphics.fillOval(new Double(x).intValue(),new Double(y).intValue(),size,size);
    }

    //--- GET TOOTH COLOR -------------------------------------------------------------------------
    private BaseColor getToothColor(String toothStatus){
        if(toothStatus.length() > 0){
                 if(toothStatus.equals("tooth.absent"))       return aqua;
            else if(toothStatus.equals("tooth.fill"))         return blue;
            else if(toothStatus.equals("tooth.unnerve"))      return fuchsia;
            else if(toothStatus.equals("tooth.unnerve_fill")) return gray;
            else if(toothStatus.equals("tooth.fracturée"))    return lime;
            else if(toothStatus.equals("tooth.impactée"))     return maroon;
            else if(toothStatus.equals("tooth.incluse"))      return gold;
            else if(toothStatus.equals("tooth.ectopique"))    return red;
            else if(toothStatus.equals("tooth.surnuméraire")) return green;
            else if(toothStatus.equals("tooth.caries")) 	  return BaseColor.BLACK;
            else if(toothStatus.equals("tooth.other")) 		  return BaseColor.ORANGE;
        }
        
        return BaseColor.WHITE;
    }

    //--- GET TOOTH COORDS ------------------------------------------------------------------------
    private Hashtable getToothCoords(){
        Hashtable coords = new Hashtable();
        int[] coord;

        coord = new int[]{75,21,10};   coords.put("11",coord); // quarter 1 (adult)
        coord = new int[]{57,28,10};   coords.put("12",coord);
        coord = new int[]{46,41,10};   coords.put("13",coord);
        coord = new int[]{38,57,10};   coords.put("14",coord);
        coord = new int[]{29,74,10};   coords.put("15",coord);
        coord = new int[]{23,92,10};   coords.put("16",coord);
        coord = new int[]{19,112,10};  coords.put("17",coord);
        coord = new int[]{21,132,10};  coords.put("18",coord);

        coord = new int[]{95,21,10};   coords.put("21",coord); // quarter 2 (adult)
        coord = new int[]{112,28,10};  coords.put("22",coord);
        coord = new int[]{124,40,10};  coords.put("23",coord);
        coord = new int[]{133,55,10};  coords.put("24",coord);
        coord = new int[]{141,74,10};  coords.put("25",coord);
        coord = new int[]{148,92,10};  coords.put("26",coord);
        coord = new int[]{151,112,10}; coords.put("27",coord);
        coord = new int[]{152,132,10}; coords.put("28",coord);

        coord = new int[]{92,276,7};   coords.put("31",coord); // quarter 3 (adult)
        coord = new int[]{106,272,7};  coords.put("32",coord);
        coord = new int[]{116,264,7};  coords.put("33",coord);
        coord = new int[]{125,250,10}; coords.put("34",coord);
        coord = new int[]{137,232,10}; coords.put("35",coord);
        coord = new int[]{145,212,10}; coords.put("36",coord);
        coord = new int[]{149,188,10}; coords.put("37",coord);
        coord = new int[]{149,165,10}; coords.put("38",coord);

        coord = new int[]{79,275,7};   coords.put("41",coord); // quarter 4 (adult)
        coord = new int[]{66,272,7};   coords.put("42",coord);
        coord = new int[]{56,264,7};   coords.put("43",coord);
        coord = new int[]{43,249,10};  coords.put("44",coord);
        coord = new int[]{31,230,10};  coords.put("45",coord);
        coord = new int[]{22,207,10};  coords.put("46",coord);
        coord = new int[]{19,186,10};  coords.put("47",coord);
        coord = new int[]{21,165,10};  coords.put("48",coord);

        coord = new int[]{225,69,10};  coords.put("51",coord); // quarter 5 (child)
        coord = new int[]{212,79,10};  coords.put("52",coord);
        coord = new int[]{203,94,10};  coords.put("53",coord);
        coord = new int[]{194,111,10}; coords.put("54",coord);
        coord = new int[]{193,132,10}; coords.put("55",coord);

        coord = new int[]{240,70,10};  coords.put("61",coord); // quarter 6 (child)
        coord = new int[]{253,79,10};  coords.put("62",coord);
        coord = new int[]{262,91,10};  coords.put("63",coord);
        coord = new int[]{272,110,10}; coords.put("64",coord);
        coord = new int[]{274,130,10}; coords.put("65",coord);

        coord = new int[]{242,226,7};  coords.put("71",coord); // quarter 7 (child)
        coord = new int[]{253,218,10}; coords.put("72",coord);
        coord = new int[]{265,207,10}; coords.put("73",coord);
        coord = new int[]{273,190,10}; coords.put("74",coord);
        coord = new int[]{275,169,10}; coords.put("75",coord);

        coord = new int[]{227,226,7};  coords.put("81",coord); // quarter 8 (child)
        coord = new int[]{212,219,10}; coords.put("82",coord);
        coord = new int[]{201,207,10}; coords.put("83",coord);
        coord = new int[]{192,190,10}; coords.put("84",coord);
        coord = new int[]{190,170,10}; coords.put("85",coord);

        return coords;
    }

}
