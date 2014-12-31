package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.renderer.category.CategoryItemRenderer;
import org.jfree.chart.renderer.category.DefaultCategoryItemRenderer;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.CategoryPlot;

import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Audiometry;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.HearingLoss;


public class PDFAudiometry extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            addGraphs();
            addVoorgeschiedenis();
            
            addDiagnosisEncoding();

            // add transaction to doc
            addTransactionToDoc();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    //--- ADD GRAPHS -------------------------------------------------------------------------------
    private void addGraphs() throws Exception {
        contentTable = new PdfPTable(1);
        PdfPTable graphsTable = new PdfPTable(1);

        // graph
        cell = createCell(new PdfPCell(getGraphTable()),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
        cell.setPadding(3);
        graphsTable.addCell(cell);

        // add table
        if(graphsTable.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(graphsTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

    //--- GET GRAPH TABLE -------------------------------------------------------------------------
    private PdfPTable getGraphTable() throws Exception {
        // series labels
        String rightEarTran  = getTran("Web.Occup","medwan.healthrecord.audiometry.OD"),
               leftEarTran   = getTran("Web.Occup","medwan.healthrecord.audiometry.OG"),
               normalTran    = getTran("Web.Occup","medwan.healthrecord.audiometry.normal"),
               rightBonyTran = getTran("openclinic.chuk","audiometry.bony.OD"),
               leftBonyTran  = getTran("openclinic.chuk","audiometry.bony.OG");

        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        
        //*** right ear ***        
        String sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_0125");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"0,125");
        }
        else{
            dataset.addValue(null,rightEarTran,"0,125");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_025");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"0,25");
        }
        else{
            dataset.addValue(null,rightEarTran,"0,25");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_050");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"0,5");
        }
        else{
            dataset.addValue(null,rightEarTran,"0,5");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_1");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"1");
        }
        else{
            dataset.addValue(null,rightEarTran,"1");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_2");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"2");
        }
        else{
            dataset.addValue(null,rightEarTran,"2");
        }

        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_4");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"4");
        }
        else{
            dataset.addValue(null,rightEarTran,"4");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_8");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightEarTran,"8");
        }
        else{
            dataset.addValue(null,rightEarTran,"8");
        }
        
        //*** left ear ***  
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_0125");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"0,125");
        }
        else{
            dataset.addValue(null,leftEarTran,"0,125");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_025");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"0,25");
        }
        else{
            dataset.addValue(null,leftEarTran,"0,25");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_050");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"0,5");
        }
        else{
            dataset.addValue(null,leftEarTran,"0,5");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_1");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"1");
        }
        else{
            dataset.addValue(null,leftEarTran,"1");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_2");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"2");
        }
        else{
            dataset.addValue(null,leftEarTran,"2");
        }

        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_4");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"4");
        }
        else{
            dataset.addValue(null,leftEarTran,"4");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_8");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftEarTran,"8");
        }
        else{
            dataset.addValue(null,leftEarTran,"8");
        }

        // normal
        int iAge = MedwanQuery.getInstance().getAge(Integer.parseInt(patient.personid));
        String sGender = checkString(patient.gender); 
        String sGenderLabelId = "";
             if(sGender.equalsIgnoreCase("m")) sGenderLabelId = "male";
        else if(sGender.equalsIgnoreCase("f")) sGenderLabelId = "female";
             
        HearingLoss hearingLoss = Audiometry.calculateHearingloss(iAge,sGender); 
        
        dataset.addValue(-Math.round(hearingLoss.getLoss0125()*1e3)/1e3,normalTran,"0,125");
        dataset.addValue(-Math.round(hearingLoss.getLoss0250()*1e3)/1e3,normalTran,"0,25");
        dataset.addValue(-Math.round(hearingLoss.getLoss0500()*1e3)/1e3,normalTran,"0,5");
        dataset.addValue(-Math.round(hearingLoss.getLoss1000()*1e3)/1e3,normalTran,"1");
        dataset.addValue(-Math.round(hearingLoss.getLoss2000()*1e3)/1e3,normalTran,"2");
        dataset.addValue(-Math.round(hearingLoss.getLoss4000()*1e3)/1e3,normalTran,"4");
        dataset.addValue(-Math.round(hearingLoss.getLoss8000()*1e3)/1e3,normalTran,"8");

        //*** bony right ***
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_0125");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"0,125");
        }
        else{
            dataset.addValue(null,rightBonyTran,"0,125");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_025");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"0,25");
        }
        else{
            dataset.addValue(null,rightBonyTran,"0,25");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_050");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"0,5");
        }
        else{
            dataset.addValue(null,rightBonyTran,"0,5");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_1");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"1");
        }
        else{
            dataset.addValue(null,rightBonyTran,"1");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_2");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"2");
        }
        else{
            dataset.addValue(null,rightBonyTran,"2");
        }

        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_4");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"4");
        }
        else{
            dataset.addValue(null,rightBonyTran,"4");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_8");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),rightBonyTran,"8");
        }
        else{
            dataset.addValue(null,rightBonyTran,"8");
        }

        //*** bony left ***
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_0125");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"0,125");
        }
        else{
            dataset.addValue(null,leftBonyTran,"0,125");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_025");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"0,25");
        }
        else{
            dataset.addValue(null,leftBonyTran,"0,25");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_050");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"0,5");
        }
        else{
            dataset.addValue(null,leftBonyTran,"0,5");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_1");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"1");
        }
        else{
            dataset.addValue(null,leftBonyTran,"1");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_2");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"2");
        }
        else{
            dataset.addValue(null,leftBonyTran,"2");
        }

        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_4");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"4");
        }
        else{
            dataset.addValue(null,leftBonyTran,"4");
        }
        
        sValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_8");
        if(sValue.length() > 0 && !sValue.equals("-")){
            dataset.addValue(-Double.parseDouble(sValue),leftBonyTran,"8");
        }
        else{
            dataset.addValue(null,leftBonyTran,"8");
        }

        // y-axis borders
        dataset.addValue(-100,"min","0,125");
        dataset.addValue(10,"max","0,125");

        // create chart
        final JFreeChart chart = ChartFactory.createLineChart(
            "", // chart title
            "kHz", // domain axis label
            "dB", // range axis label
            dataset, // data
            PlotOrientation.VERTICAL, // orientation
            false, // include legend
            false, // tooltips
            false // urls
        );

        // customize looks
        chart.setBackgroundPaint(Color.WHITE);

        // series colors
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(new Color(230,230,230));
        
        CategoryItemRenderer renderer = new DefaultCategoryItemRenderer();
        renderer.setSeriesPaint(0,Color.red); // right ear
        renderer.setSeriesPaint(1,Color.blue); // left ear
        renderer.setSeriesPaint(2,new Color(34,139,34)); // normal (green)
        renderer.setSeriesPaint(3,Color.BLACK); // right bony
        renderer.setSeriesPaint(4,new Color(153,50,204)); // left bony (purple)

        // round dots for all series
        int dotSize = 4;
        renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(1,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(2,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(3,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(4,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(5,new Ellipse2D.Double(0,0,0,0));
        renderer.setSeriesShape(6,new Ellipse2D.Double(0,0,0,0));
        plot.setRenderer(renderer);

        // write graph to image
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,600,360);
        PdfPTable graphTable = new PdfPTable(1);

        // add image to table
        cell = new PdfPCell();
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingLeft(110);
        cell.setPaddingRight(125);
        graphTable.addCell(cell);

        // legend
        Phrase phrase = new Phrase(rightEarTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,BaseColor.RED));
               phrase.add(new Chunk(leftEarTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,BaseColor.BLUE)));
               phrase.add(new Chunk(normalTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,new BaseColor(34,139,34)))); // green
               phrase.add(new Chunk(rightBonyTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,BaseColor.BLACK)));
               phrase.add(new Chunk(leftBonyTran,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,new BaseColor(153,50,204)))); // purple
        cell = new PdfPCell(phrase);
        cell.setPaddingBottom(10);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        graphTable.addCell(cell);

        return graphTable;
    }

    //--- ADD VOORGESCHIEDENIS --------------------------------------------------------------------
    private void addVoorgeschiedenis() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);                 

        // personal
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_PERSONAL_HISTORY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_PERSONAL_HISTORY"),itemValue);
        }

        // familial
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_FAMILY_HISTORY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_FAMILY_HISTORY"),itemValue);
        }

        // add table
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(new PdfPCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

}
