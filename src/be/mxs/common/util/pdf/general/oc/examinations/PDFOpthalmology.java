package be.mxs.common.util.pdf.general.oc.examinations;

import java.util.Vector;
import java.awt.*;
import java.awt.image.BufferedImage;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;
import com.lowagie.text.Font;
import com.lowagie.text.Paragraph;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Image;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Miscelaneous;


public class PDFOpthalmology extends PDFGeneralBasic {

    // declarations
    protected Vector list;
    protected String item;


    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_VISUS_AV_RAS").equalsIgnoreCase("medwan.common.false")){
                printGezichtsscherpte();
            }
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_VISUS_STEREO_RAS").equalsIgnoreCase("medwan.common.false")){
                printStereoscopie();
            }
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_VISUS_COLOR_RAS").equalsIgnoreCase("medwan.common.false")){
                printKleurenzicht();
            }
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_VISUS_PERI_RAS").equalsIgnoreCase("medwan.common.false")){
                printGezichtsveld();
            }
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_VISUS_MESO_RAS").equalsIgnoreCase("medwan.common.false")){
                printMesoEnFoto();
            }
            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_VISUS_SCREEN_RAS").equalsIgnoreCase("medwan.common.false")){
                printBeeldschermwerkers();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // PRINT GEZICHTSSCHERPTE //////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void printGezichtsscherpte() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.acuite-visuelle"),5));

        //--- aanbevolen correctie -----------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY");

        if(verifyList(list)){
            String sOut = printList(list,false,", ");
            if(sOut.length() > 0){
                table.addCell(createItemNameCell(getTran("healthrecord.ophtalmology.correction-prescribe"),2));
                table.addCell(createValueCell(sOut.toLowerCase(),3));
            }
        }

        //--- table --------------------------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITHOUT_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES");

        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITH_GLASSES");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES");

        if(verifyList(list)){
            // spacer row
            table.addCell(createBorderlessCell(5));

            // borderless corner cell
            table.addCell(emptyCell(1));

            // header
            table.addCell(createHeaderCell(getTran("medwan.common.right"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.left"),1));
            table.addCell(createHeaderCell(getTran("medwan.common.binocular"),1));
            table.addCell(createHeaderCell(getTran("medwan.healthrecord.ophtalmology.acuite-binoculaire-VP"),1));

            // Zonder correctie
            if(verifyList(list,IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES",IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES")){
                table.addCell(createHeaderCell(getTran("medwan.healthrecord.ophtalmology.SANS-verres-2"),1));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES")));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES")));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES")));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITHOUT_GLASSES")));
            }

            // Met correctie
            if(verifyList(list,IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES",IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES")){
                table.addCell(createHeaderCell(getTran("medwan.healthrecord.ophtalmology.AVEC-verres-2"),1));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES")));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES")));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES")));
                table.addCell(createContentCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_P_WITH_GLASSES")));
            }
        }

        //--- remark -------------------------------------------------------------------------------
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_REMARK");
        if(itemValue.length() > 0){
            // spacer row
            table.addCell(createBorderlessCell(5));

            addItemRow(table,getTran("medwan.common.remark"),itemValue);
        }

        // add content
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // PRINT STEREOSCOPIE //////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void printStereoscopie() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.stereoscopie"),5));

        //--- tests table --------------------------------------------------------------------------
        PdfPTable testsTable = new PdfPTable(5);

        // construct tests table
        for(int i=1; i<=5; i++){
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_LINE_"+i);
            for(int j=1; j<=5; j++){
                if(itemValue.equals(j+"")) testsTable.addCell(createGreenCell(j+""));
                else                       testsTable.addCell(createContentCell(j+""));
            }
        }

        // add tests table is any content
        if(testsTable.size() > 0){
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.ophtalmology.stereoscopie")));

            // [cell 1] close / far
            itemValue = "\n"+
                        getTran("medwan.healthrecord.ophtalmology.plus-pres")+
                        "\n\n\n\n\n"+
                        getTran("medwan.healthrecord.ophtalmology.plus-loin");
            table.addCell(createValueCell(itemValue,1));

            // [cell 2] 5*5 cells
            table.addCell(testsTable);

            // [cell 3] normal / abnormal
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_NORMAL");
            table.addCell(createValueCell(getTran(itemValue),1));
        }

        //------------------------------------------------------------------------------------------

        // correction
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_CORRECTION"),getTran(itemValue));
        }

        // remark
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_STEREOSCOPY_REMARK"),itemValue);
        }

        // add content
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // PRINT KLEURENZICHT //////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void printKleurenzicht() throws Exception {
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_REMARK");

        if(verifyList(list)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.couleurs"),5));

            //--- COLORS (on one row) --------------------------------------------------------------
            // ESSILOR
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_ESSILOR");
            if(itemValue.length() > 0) table.addCell(createValueCell("Essilor: "+getTran(itemValue),1));
            else                       table.addCell(createValueCell("Essilor: /",1));

            // FARNSWORTH
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_FARNSWORTH");
            if(itemValue.length() > 0) table.addCell(createValueCell("Farnsworth: "+getTran(itemValue),1));
            else                       table.addCell(createValueCell("Farnsworth: /",1));

            // ISHIHARA
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_ISHIHARA");
            if(itemValue.length() > 0) table.addCell(createValueCell("Ishihara: "+getTran(itemValue),1));
            else                       table.addCell(createValueCell("Ishihara: /",1));

            // CARTECOULEUR
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_CARTECOULEUR");
            if(itemValue.length() > 0) table.addCell(createValueCell("Carte de couleur: "+getTran(itemValue),1));
            else                       table.addCell(createValueCell("Carte de couleur: /",1));

            // 5th empty cell
            table.addCell(emptyCell());

            // correction
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_CORRECTION"),getTran(itemValue));
            }

            // remark
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_COLOR_REMARK");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("medwan.common.remark"),itemValue);
            }

            // add content
            if(table.size() > 1){
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }

            // add transaction to doc
            addTransactionToDoc();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // PRINT GEZICHTSVELD //////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void printGezichtsveld() throws Exception {
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_22");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_1");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_5");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_11");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_7");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_3");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_22");

        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_22");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_3");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_7");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_5");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_11");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_1");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_REMARK");

        if(verifyList(list)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.vision-peripherique"),5));

            // prepare images
            MediaTracker mediaTracker = new MediaTracker(new Container());

            java.awt.Image OD = Miscelaneous.getImage("OD_pdf.gif");
            mediaTracker.addImage(OD,0);
            mediaTracker.waitForID(0);

            java.awt.Image OG = Miscelaneous.getImage("OG_pdf.gif");
            mediaTracker.addImage(OG,1);
            mediaTracker.waitForID(1);

            //*** Rechter oog **********************************************************************
            BufferedImage rightImg = new BufferedImage(OD.getWidth(null),OD.getHeight(null),BufferedImage.TYPE_INT_RGB);
            Graphics2D graphics = rightImg.createGraphics();
            graphics.drawImage(OD,0,0,Color.WHITE,null);

            // Hier de vakjes tekenen in functie van het feit of ze 'aan' of 'af' staan
            String sRechts = "", sKomma = "";
            int counter = 0;

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_2").equals("")){
                drawRectangle(graphics,0.15*rightImg.getWidth(),0.20*rightImg.getHeight(),Color.BLACK,10,"2");
                sRechts = "2";
                counter++;
            }
            else{
                drawRectangle(graphics,0.15*rightImg.getWidth(),0.20*rightImg.getHeight(),Color.WHITE,10,"2");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_3").equals("")){
                drawRectangle(graphics,0.90*rightImg.getWidth(),0.20*rightImg.getHeight(),Color.BLACK,10,"3");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"3";
                counter++;
            }
            else{
                drawRectangle(graphics,0.90*rightImg.getWidth(),0.20*rightImg.getHeight(),Color.WHITE,10,"3");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_22").equals("")){
                drawRectangle(graphics,0.0001*rightImg.getWidth(),0.50*rightImg.getHeight(),Color.BLACK,10,"22");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"22";
                counter++;
            }
            else{
                drawRectangle(graphics,0.0001*rightImg.getWidth(),0.50*rightImg.getHeight(),Color.WHITE,10,"22");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_6").equals("")){
                drawRectangle(graphics,0.45*rightImg.getWidth(),0.40*rightImg.getHeight(),Color.BLACK,10,"6");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"6";
                counter++;
            }
            else{
                drawRectangle(graphics,0.45*rightImg.getWidth(),0.40*rightImg.getHeight(),Color.WHITE,10,"6");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_8").equals("")){
                drawRectangle(graphics,0.65*rightImg.getWidth(),0.40*rightImg.getHeight(),Color.BLACK,10,"8");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"8";
                counter++;
            }
            else{
                drawRectangle(graphics,0.65*rightImg.getWidth(),0.40*rightImg.getHeight(),Color.WHITE,10,"8");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_5").equals("")){
                drawRectangle(graphics,0.45*rightImg.getWidth(),0.53*rightImg.getHeight(),Color.BLACK,10,"5");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"5";
                counter++;
            }
            else{
                drawRectangle(graphics,0.45*rightImg.getWidth(),0.53*rightImg.getHeight(),Color.WHITE,10,"5");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_7").equals("")){
                drawRectangle(graphics,0.65*rightImg.getWidth(),0.53*rightImg.getHeight(),Color.BLACK,10,"7");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"7";
                counter++;
            }
            else{
                drawRectangle(graphics,0.65*rightImg.getWidth(),0.53*rightImg.getHeight(),Color.WHITE,10,"7");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_4").equals("")){
                drawRectangle(graphics,0.90*rightImg.getWidth(),0.65*rightImg.getHeight(),Color.BLACK,10,"4");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"4";
                counter++;
            }
            else{
                drawRectangle(graphics,0.90*rightImg.getWidth(),0.65*rightImg.getHeight(),Color.WHITE,10,"4");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_1").equals("")){
                drawRectangle(graphics,0.25*rightImg.getWidth(),0.75*rightImg.getHeight(),Color.BLACK,10,"1");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"1";
                counter++;
            }
            else{
                drawRectangle(graphics,0.25*rightImg.getWidth(),0.75*rightImg.getHeight(),Color.WHITE,10,"1");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OD_11").equals("")){
                drawRectangle(graphics,0.47*rightImg.getWidth(),0.75*rightImg.getHeight(),Color.BLACK,10,"11");
                if(counter > 0) sKomma = ", ";
                sRechts+= sKomma+"11";
            }
            else{
                drawRectangle(graphics,0.47*rightImg.getWidth(),0.75*rightImg.getHeight(),Color.WHITE,10,"11");
            }

            //*** Linker oog ***********************************************************************
            BufferedImage leftImg = new BufferedImage(OG.getWidth(null),OG.getHeight(null), BufferedImage.TYPE_INT_RGB);
            graphics = leftImg.createGraphics();
            graphics.drawImage(OG,0,0,Color.WHITE,null);

            // Hier de vakjes tekenen in functie van het feit of ze 'aan' of 'af' staan
            String sLinks = ""; sKomma = "";
            counter = 0;

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_2").equals("")){
                drawRectangle(graphics,(1-0.20)*leftImg.getWidth(),0.20*leftImg.getHeight(),Color.BLACK,10,"2");
                sLinks= "2";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.20)*leftImg.getWidth(),0.20*leftImg.getHeight(),Color.WHITE,10,"2");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_3").equals("")){
                drawRectangle(graphics,(1-0.96)*leftImg.getWidth(),0.20*leftImg.getHeight(),Color.BLACK,10,"3");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"3";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.96)*leftImg.getWidth(),0.20*leftImg.getHeight(),Color.WHITE,10,"3");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_22").equals("")){
                drawRectangle(graphics,(1-0.07)*leftImg.getWidth(),0.50*leftImg.getHeight(),Color.BLACK,10,"22");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"22";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.07)*leftImg.getWidth(),0.50*leftImg.getHeight(),Color.WHITE,10,"22");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_6").equals("")){
                drawRectangle(graphics,(1-0.50)*leftImg.getWidth(),0.40*leftImg.getHeight(),Color.BLACK,10,"6");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"6";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.50)*leftImg.getWidth(),0.40*leftImg.getHeight(),Color.WHITE,10,"6");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_8").equals("")){
                drawRectangle(graphics,(1-0.70)*leftImg.getWidth(),0.40*leftImg.getHeight(),Color.BLACK,10,"8");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"8";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.70)*leftImg.getWidth(),0.40*leftImg.getHeight(),Color.WHITE,10,"8");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_5").equals("")){
                drawRectangle(graphics,(1-0.50)*leftImg.getWidth(),0.53*leftImg.getHeight(),Color.BLACK,10,"5");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"5";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.50)*leftImg.getWidth(),0.53*leftImg.getHeight(),Color.WHITE,10,"5");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_7").equals("")){
                drawRectangle(graphics,(1-0.70)*leftImg.getWidth(),0.53*leftImg.getHeight(),Color.BLACK,10,"7");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma +"7";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.70)*leftImg.getWidth(),0.53*leftImg.getHeight(),Color.WHITE,10,"7");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_4").equals("")){
                drawRectangle(graphics,(1-0.96)*leftImg.getWidth(),0.65*leftImg.getHeight(),Color.BLACK,10,"4");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"4";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.96)*leftImg.getWidth(),0.65*leftImg.getHeight(),Color.WHITE,10,"4");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_1").equals("")){
                drawRectangle(graphics,(1-0.30)*leftImg.getWidth(),0.75*leftImg.getHeight(),Color.BLACK,10,"1");
                if(counter > 0) sKomma = ", ";
                sLinks+= sKomma+"1";
                counter++;
            }
            else{
                drawRectangle(graphics,(1-0.30)*leftImg.getWidth(),0.75*leftImg.getHeight(),Color.WHITE,10,"1");
            }

            if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_OG_11").equals("")){
                drawRectangle(graphics,(1-0.55)*leftImg.getWidth(),0.75*leftImg.getHeight(),Color.BLACK,10,"11");
                if(counter > 0) { sKomma = ", "; }else{ sKomma = "";}
                sLinks+= sKomma+"11";
            }
            else{
               drawRectangle(graphics,(1-0.55)*leftImg.getWidth(),0.75*leftImg.getHeight(),Color.WHITE,10,"11");
            }

            //*** BUILD OUTPUT *********************************************************************
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.vision.erreur-champs-vision"),2));

            PdfPTable imgsTable = new PdfPTable(2);

            // [row 1] numbers
            cell = createHeaderCell(getTran("medwan.common.right")+": "+sRechts,1);
            cell.setBorder(Cell.BOX);
            imgsTable.addCell(cell);

            cell = createHeaderCell(getTran("medwan.common.left")+": "+sLinks,1);
            cell.setBorder(Cell.BOX);
            imgsTable.addCell(cell);

            // [row 2] add images
            cell = new PdfPCell();
            cell.setImage(Image.getInstance(rightImg,null));
            cell.setColspan(1);
            cell.setPaddingLeft(15);
            cell.setBorder(Cell.NO_BORDER);
            cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
            imgsTable.addCell(cell);

            cell = new PdfPCell();
            cell.setImage(Image.getInstance(leftImg,null));
            cell.setColspan(1);
            cell.setPaddingRight(15);
            cell.setBorder(Cell.NO_BORDER);
            cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
            imgsTable.addCell(cell);

            table.addCell(createCell(new PdfPCell(imgsTable),3,Cell.ALIGN_MIDDLE,Cell.BOX)); // 3=2+emptyCell

            // correction
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_CORRECTION");
            if(itemValue.length() > 0){
                addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_CORRECTION"),getTran(itemValue));
            }

            // remark
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PERIPHERIC_REMARK");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("medwan.common.remark"),itemValue);
            }

            // add content
            if(table.size() > 1){
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }

            // add transaction to doc
            addTransactionToDoc();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // PRINT MESO & FOTO ///////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void printMesoEnFoto() throws Exception {
        // count saved meso items
        int mesosize = 0;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_2").equals(""))  mesosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_4").equals(""))  mesosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_6").equals(""))  mesosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_8").equals(""))  mesosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_10").equals("")) mesosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_12").equals("")) mesosize++;

        // count saved foto items
        int fotosize = 0;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_2").equals(""))  fotosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_4").equals(""))  fotosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_6").equals(""))  fotosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_8").equals(""))  fotosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_10").equals("")) fotosize++;
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_PHOTOPIC_12").equals("")) fotosize++;

        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.vision-mesopique"),5));

        // Mesopische visus
        if(mesosize > 0){
            String mesoValue = "";
                 if(mesosize == 1) mesoValue = "2";
            else if(mesosize == 2) mesoValue = "4";
            else if(mesosize == 3) mesoValue = "6";
            else if(mesosize == 4) mesoValue = "8";
            else if(mesosize == 5) mesoValue = "10";
            else if(mesosize == 6) mesoValue = "12";

            addItemRow(table,getTran("medwan.healthrecord.ophtalmology.acuite-mesopique"),mesoValue);
        }

        // Fotopische visus
        if(fotosize > 0){
           String fotoValue = "";
                 if(fotosize == 1) fotoValue = "2";
            else if(fotosize == 2) fotoValue = "4";
            else if(fotosize == 3) fotoValue = "6";
            else if(fotosize == 4) fotoValue = "8";
            else if(fotosize == 5) fotoValue = "10";
            else if(fotosize == 6) fotoValue = "12";

            addItemRow(table,getTran("medwan.healthrecord.ophtalmology.acuite-photopique"),fotoValue);
        }

        // correction
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_CORRECTION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_CORRECTION"),getTran(itemValue));
        }

        // remark
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_VISION_MESOPIC_REMARK");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("medwan.common.remark"),itemValue);
        }

        // add content
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // PRINT BEELDSCHERMWERKERS ////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    private void printBeeldschermwerkers() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        String visusTran = getTran("medwan.common.vision");

        // title
        table.addCell(createTitleCell(getTran("medwan.healthrecord.ophtalmology.workers-on-screen"),5));

        // common used translations
        String odTran = getTran("medwan.healthrecord.ophtalmology.OD");
        String ogTran = getTran("medwan.healthrecord.ophtalmology.OG");

        //### VISUS Loin ###########################################################################

        //--- VISION VL OD -------------------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_10");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OD_12");
        String itemOD = getItemWithContent(list);

        //--- VISION VL OG -------------------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_10");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_VL_OG_12");
        String itemOG = getItemWithContent(list);

        if(itemOD.length() > 0 || itemOG.length() > 0){
            // row title
            table.addCell(createItemNameCell(visusTran+" "+getTran("medwan.healthrecord.ophtalmology.far")));

            // OD
            if(itemOD.length() > 0) table.addCell(createValueCell(odTran+": "+getItemValue(itemOD),1));
            else                    table.addCell(emptyCell(1));

            // OG
            if(itemOG.length() > 0) table.addCell(createValueCell(ogTran+": "+getItemValue(itemOG),2));
            else                    table.addCell(emptyCell(2));
        }

        //### bonnette + 1D ########################################################################
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_EQUAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_LESS_GOOD");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_EQUAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_LESS_GOOD");

        if(verifyList(list)){
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.ophtalmology.workers-on-screen-bonnette")));

            //--- OD -------------------------------------------------------------------------------
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_EQUAL");
            if(itemValue.length() > 0){
                table.addCell(createValueCell(odTran+": "+getTran(itemValue),1));
            }
            else{
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OD_LESS_GOOD");
                if(!itemValue.equals("")) table.addCell(createValueCell(odTran+": "+getTran(itemValue),1));
                else                      table.addCell(emptyCell(1));
            }

            //--- OG -------------------------------------------------------------------------------
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_EQUAL");
            if(itemValue.length() > 0){
                table.addCell(createValueCell(ogTran+": "+getTran(itemValue),2));
            }
            else{
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONNETTE_OG_LESS_GOOD");
                if(!itemValue.equals("")) table.addCell(createValueCell(ogTran+": "+getTran(itemValue),2));
                else                      table.addCell(emptyCell(2));
            }
        }

        //### rood + groen #########################################################################
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_EQUAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_RED");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_GREEN");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_EQUAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_RED");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_GREEN");

        if(verifyList(list)){
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.ophtalmology.workers-on-screen-RED-GREEN")));

            // OD
            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_EQUAL").equals("")){
                table.addCell(createValueCell(odTran+": "+getTran(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_EQUAL")),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_RED").equals("")){
                table.addCell(createValueCell(odTran+": "+getTran(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_RED")),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_GREEN").equals("")){
                table.addCell(createValueCell(odTran+": "+getTran(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OD_GREEN")),1));
            }
            else{
                table.addCell(emptyCell(1));
            }

            // OG
            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_EQUAL").equals("")){
                table.addCell(createValueCell(ogTran+": "+getTran(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_EQUAL")),2));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_RED").equals("")){
                table.addCell(createValueCell(ogTran+": "+getTran(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_RED")),2));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_GREEN").equals("")){
                table.addCell(createValueCell(ogTran+": "+getTran(getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_RED_GREEN_OG_GREEN")),2));
            }
            else{
                table.addCell(emptyCell(2));
            }
        }

        //### ASTIGMATISME #########################################################################
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_1");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_3");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_5");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_7");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_EQUAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_BLACK");

        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_1");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_3");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_5");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_7");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_EQUAL");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_BLACK");

        if(verifyList(list)){
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.ophtalmology.workers-on-screen-astigmatisme")));

            PdfPTable astigmaTable = new PdfPTable(2);

            // labels
            astigmaTable.addCell(createHeaderCell(getTran("medwan.common.right"),1));
            astigmaTable.addCell(createHeaderCell(getTran("medwan.common.left"),1));

            // prepare images
            MediaTracker mediaTracker = new MediaTracker(new Container());

            java.awt.Image OD_lines = Miscelaneous.getImage("lines_pdf.gif");
            mediaTracker.addImage(OD_lines, 0);
            mediaTracker.waitForID(0);

            java.awt.Image OG_lines = Miscelaneous.getImage("lines_pdf.gif");
            mediaTracker.addImage(OG_lines, 1);
            mediaTracker.waitForID(1);

            // Rechter oog
            BufferedImage img = new BufferedImage(OD_lines.getWidth(null),OD_lines.getHeight(null), BufferedImage.TYPE_INT_RGB);
            Graphics2D graphics = img.createGraphics();
            graphics.drawImage(OD_lines,0,0,Color.WHITE,null);

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_1").equals("")){
                drawRectangle(graphics,0.15*img.getWidth(),0.82*img.getHeight(),Color.BLACK,10,"1");
            }
            else{
                drawRectangle(graphics,0.15*img.getWidth(),0.82*img.getHeight(),Color.WHITE,10,"1");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_7").equals("")){
                drawRectangle(graphics,0.82*img.getWidth(),0.82*img.getHeight(),Color.BLACK,10,"7");
            }
            else{
                drawRectangle(graphics,0.82*img.getWidth(),0.82*img.getHeight(),Color.WHITE,10,"7");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_2").equals("")){
                drawRectangle(graphics,0.16*img.getWidth(),0.50*img.getHeight(),Color.BLACK,10,"2");
            }
            else{
                drawRectangle(graphics,0.16*img.getWidth(),0.50*img.getHeight(),Color.WHITE,10,"2");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_6").equals("")){
                drawRectangle(graphics,0.80*img.getWidth(),0.50*img.getHeight(),Color.BLACK,10,"6");
            }
            else{
                drawRectangle(graphics,0.80*img.getWidth(),0.50*img.getHeight(),Color.WHITE,10,"6");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_3").equals("")){
                drawRectangle(graphics,0.30*img.getWidth(),0.25*img.getHeight(),Color.BLACK,10,"3");
            }
            else{
                drawRectangle(graphics,0.30*img.getWidth(),0.25*img.getHeight(),Color.WHITE,10,"3");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_5").equals("")){
                drawRectangle(graphics,0.68*img.getWidth(),0.25*img.getHeight(),Color.BLACK,10,"5");
            }
            else{
                drawRectangle(graphics,0.68*img.getWidth(),0.25*img.getHeight(),Color.WHITE,10,"5");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_4").equals("")){
                drawRectangle(graphics,0.49*img.getWidth(),0.15*img.getHeight(),Color.BLACK,10,"4");
            }
            else{
                drawRectangle(graphics,0.49*img.getWidth(),0.15*img.getHeight(),Color.WHITE,10,"4");
            }

            // right image
            cell = new PdfPCell();
            cell.setImage(Image.getInstance(img,null));
            cell.setColspan(1);
            cell.setPaddingTop(2);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
            astigmaTable.addCell(cell);

            //--- Linker oog -----------------------------------------------------------------------
            img = new BufferedImage(OG_lines.getWidth(null),OG_lines.getHeight(null), BufferedImage.TYPE_INT_RGB);
            graphics = img.createGraphics();
            graphics.drawImage(OG_lines,0,0,Color.WHITE,null);

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_1").equals("")){
                drawRectangle(graphics,(1-0.85)*img.getWidth(),0.82*img.getHeight(),Color.BLACK,10,"1");
            }
            else{
                drawRectangle(graphics,(1-0.85)*img.getWidth(),0.82*img.getHeight(),Color.WHITE,10,"1");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_7").equals("")){
                drawRectangle(graphics,(1-0.18)*img.getWidth(),0.82*img.getHeight(),Color.BLACK,10,"7");
            }
            else{
                drawRectangle(graphics,(1-0.18)*img.getWidth(),0.82*img.getHeight(),Color.WHITE,10,"7");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_2").equals("")){
                drawRectangle(graphics,(1-0.84)*img.getWidth(),0.50*img.getHeight(),Color.BLACK,10,"2");
            }
            else{
                drawRectangle(graphics,(1-0.84)*img.getWidth(),0.50*img.getHeight(),Color.WHITE,10,"2");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_6").equals("")){
                drawRectangle(graphics,(1-0.21)*img.getWidth(),0.50*img.getHeight(),Color.BLACK,10,"6");
            }
            else{
                drawRectangle(graphics,(1-0.21)*img.getWidth(),0.50*img.getHeight(),Color.WHITE,10,"6");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_3").equals("")){
                drawRectangle(graphics,(1-0.71)*img.getWidth(),0.25*img.getHeight(),Color.BLACK,10,"3");
            }
            else{
                drawRectangle(graphics,(1-0.71)*img.getWidth(),0.25*img.getHeight(),Color.WHITE,10,"3");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_5").equals("")){
                drawRectangle(graphics,(1-0.33)*img.getWidth(),0.25*img.getHeight(),Color.BLACK,10,"5");
            }
            else{
                drawRectangle(graphics,(1-0.33)*img.getWidth(),0.25*img.getHeight(),Color.WHITE,10,"5");
            }

            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_4").equals("")){
                drawRectangle(graphics,(1-0.52)*img.getWidth(),0.15*img.getHeight(),Color.BLACK,10,"4");
            }
            else{
                drawRectangle(graphics,(1-0.52)*img.getWidth(),0.15*img.getHeight(),Color.WHITE,10,"4");
            }

            // left image
            cell = new PdfPCell();
            cell.setImage(Image.getInstance(img,null));
            cell.setColspan(1);
            cell.setPaddingTop(2);
            cell.setBorderColor(innerBorderColor);
            cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
            astigmaTable.addCell(cell);

            //--- equal or black R -----------------------------------------------------------------
            String sEqual = "", sBlack = "";

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_EQUAL");
            if(itemValue.length() > 0){
                sEqual = getTran(itemValue)+"  ";
            }

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OD_BLACK");
            if(itemValue.length() > 0){
                sBlack = getTran(itemValue);
            }

            astigmaTable.addCell(createContentCell((sEqual+sBlack).toLowerCase()));

            //--- equal or black L -----------------------------------------------------------------
            sEqual = ""; sBlack = "";

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_EQUAL");
            if(itemValue.length() > 0){
                sEqual = getTran(itemValue)+"  ";
            }

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_ASTIGMATISME_OG_BLACK");
            if(itemValue.length() > 0){
                sBlack = getTran(itemValue);
            }

            astigmaTable.addCell(createContentCell((sEqual+sBlack).toLowerCase()));

            // add astigmatisme table
            table.addCell(createCell(new PdfPCell(astigmaTable),3,Cell.ALIGN_LEFT,Cell.NO_BORDER));
        }

        //### VISUS BINOCULAR ######################################################################

        //--- Proche -------------------------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_10");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VP_12");

        item = getItemWithContent(list);
        if(item.length() > 0){
            table.addCell(createItemNameCell(visusTran+" "+getTran("medwan.healthrecord.ophtalmology.close")));
            table.addCell(createValueCell(getTran("medwan.common.binocular")+": "+getItemValue(item)));
        }

        //--- Intermediaire ------------------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_10");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VI_12");

        item = getItemWithContent(list);
        if(item.length() > 0){
            table.addCell(createItemNameCell(visusTran+" "+getTran("medwan.healthrecord.ophtalmology.intermediate")));
            table.addCell(createValueCell(getTran("medwan.common.binocular")+": "+getItemValue(item)));
        }

        //--- Loin ---------------------------------------------------------------------------------
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_6");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_8");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_10");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_BONI_VL_12");

        item = getItemWithContent(list);
        if(item.length() > 0){
            table.addCell(createItemNameCell(visusTran+" "+getTran("medwan.healthrecord.ophtalmology.far")));
            table.addCell(createValueCell(getTran("medwan.common.binocular")+": "+getItemValue(item)));
        }

        //### VERMOEIDHEID #########################################################################
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5");

        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5");

        if(verifyList(list)){
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.ophtalmology.fatigue")));

            //--- time span ------------------------------------------------------------------------
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_TIME_SPAN");
            if(itemValue.length() > 0){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.time-span")+": "+itemValue,1));
            }
            else{
                table.addCell(emptyCell(1));
            }

            //--- fatigue LOIN ---------------------------------------------------------------------
            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.far")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_1"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.far")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_2"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.far")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_3"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.far")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_4"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.far")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VL_5"),1));
            }
            else{
                table.addCell(emptyCell(1));
            }

            //--- fatigue PROCHE -------------------------------------------------------------------
            if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.close")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_1"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.close")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_2"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.close")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_3"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.close")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_4"),1));
            }
            else if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5").equals("")){
                table.addCell(createValueCell(getTran("medwan.healthrecord.ophtalmology.close")+": "+getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_FATIGUE_VP_5"),1));
            }
            else{
                table.addCell(emptyCell(1));
            }
        }

        //### CONTRASTEN ###########################################################################
        list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02");

        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02");

        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04");
        list.add(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02");

        if(verifyList(list)){
            // row title
            table.addCell(createItemNameCell(getTran("medwan.healthrecord.ophtalmology.workers-on-screen-vision-contrast")));

            PdfPTable contrastTable = new PdfPTable(4);

            // borderless corner cell
            contrastTable.addCell(createBorderlessCell(1));

            // header
            contrastTable.addCell(createHeaderCell("0,6",1));
            contrastTable.addCell(createHeaderCell("0,4",1));
            contrastTable.addCell(createHeaderCell("0,2",1));

            //*** row 1 ****************************************************************************
            String cross = "x";
            contrastTable.addCell(createHeaderCell("4",1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_06");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_04");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_4_02");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            //*** row 2 ****************************************************************************
            contrastTable.addCell(createHeaderCell("6",1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_06");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_04");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_6_02");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            //*** row 3 ****************************************************************************
            contrastTable.addCell(createHeaderCell("8",1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_06");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_04");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_VISION_CONTRAST_8_02");
            if(itemValue.length() > 0) contrastTable.addCell(createContentCell(cross));
            else                       contrastTable.addCell(createBorderlessCell(1));

            // add contrast table
            table.addCell(createCell(new PdfPCell(contrastTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));

            // spacer cell
            table.addCell(emptyCell(1));

            // spacer cell
            cell.setBorder(Cell.RIGHT);
            table.addCell(cell);
        }

        // correction
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_CORRECTION"),getTran(itemValue));
        }

        // screenworkers remark
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OPTHALMOLOGY_SCREEN_REMARK");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("medwan.common.remark"),itemValue);
        }

        // add content
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }


    //### VARIOUS METHODS ##########################################################################

    //--- GET ITEM WITH CONTENT --------------------------------------------------------------------
    private String getItemWithContent(Vector list){
        String item;

        for(int i=0; i<list.size(); i++){
            item = (String)list.get(i);
            if(getItemValue(item).length() > 0){
                return item;
            }
        }

        return "";
    }

    //--- DRAW RECTANGLE ---------------------------------------------------------------------------
    protected void drawRectangle(Graphics2D graphics, double x, double y, Color color, int size, String label){
        graphics.setColor(color);
        graphics.fillRect(new Double(x).intValue(),new Double(y).intValue(),size,size);
        graphics.setColor(Color.BLACK);
        graphics.drawRect(new Double(x).intValue(),new Double(y).intValue(),size,size);

        if(label!=null){
            graphics.setFont(new java.awt.Font(FontFactory.HELVETICA,Font.ITALIC,10));
            graphics.drawString(label,new Double(x).intValue(),new Double(y).intValue()-1);
        }
    }

    //--- DRAW TEXT --------------------------------------------------------------------------------
    protected void drawText(Graphics2D graphics, double x, double y, Color color, String label){
        graphics.setColor(color);
        graphics.setFont(new java.awt.Font(FontFactory.HELVETICA,Font.ITALIC,10));
        graphics.drawString(label,(float)x,(float)y);
    }

    //--- CREATE CONTENT CELL ----------------------------------------------------------------------
    protected PdfPCell createContentCell(String value, int colSpan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colSpan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER); // difference

        return cell;
    }

    protected PdfPCell createContentCell(String value){
        return this.createContentCell(value,1);
    }

}
