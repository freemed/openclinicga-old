package be.mxs.common.util.pdf.general.oc.examinations;

import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
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

import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFAudiometry extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            addGraphs();
            addVoorgeschiedenis();
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
        cell = createCell(new PdfPCell(getGraphTable()),1,Cell.ALIGN_CENTER,Cell.BOX);
        cell.setPadding(3);
        graphsTable.addCell(cell);

        // add table
        if(graphsTable.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(graphsTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

    //--- GET GRAPH TABLE -------------------------------------------------------------------------
    private PdfPTable getGraphTable() throws Exception {
        // series labels
        String rightAirTran  = getTran("Web.Occup","medwan.healthrecord.audiometry.OD"),
               leftAirTran   = getTran("Web.Occup","medwan.healthrecord.audiometry.OG"),
               normalTran    = getTran("Web.Occup","medwan.healthrecord.audiometry.normal"),
               rightBonyTran = getTran("openclinic.chuk","audiometry.bony.OD"),
               leftBonyTran  = getTran("openclinic.chuk","audiometry.bony.OG");

        // air right
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_0125")),rightAirTran,"0,125");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_025")),rightAirTran,"0,25");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_050")),rightAirTran,"0,5");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_1")),rightAirTran,"1");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_2")),rightAirTran,"2");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_4")),rightAirTran,"4");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_RIGHT_8")),rightAirTran,"8");

        // air left
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_0125")),leftAirTran,"0,125");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_025")),leftAirTran,"0,25");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_050")),leftAirTran,"0,5");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_1")),leftAirTran,"1");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_2")),leftAirTran,"2");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_4")),leftAirTran,"4");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_LEFT_8")),leftAirTran,"8");

        // normal
        dataset.addValue(0,normalTran,"0,125");
        dataset.addValue(0,normalTran,"0,25");
        dataset.addValue(0,normalTran,"0,5");
        dataset.addValue(0,normalTran,"1");
        dataset.addValue(0,normalTran,"2");
        dataset.addValue(0,normalTran,"4");
        dataset.addValue(0,normalTran,"8");

        // bony right
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_0125")),rightBonyTran,"0,125");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_025")),rightBonyTran,"0,25");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_050")),rightBonyTran,"0,5");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_1")),rightBonyTran,"1");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_2")),rightBonyTran,"2");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_4")),rightBonyTran,"4");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_RIGHT_8")),rightBonyTran,"8");

        // bony left
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_0125")),leftBonyTran,"0,125");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_025")),leftBonyTran,"0,25");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_050")),leftBonyTran,"0,5");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_1")),leftBonyTran,"1");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_2")),leftBonyTran,"2");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_4")),leftBonyTran,"4");
        dataset.addValue(-Double.parseDouble(getItemValue(IConstants_PREFIX+"ITEM_TYPE_AUDIOMETRY_BONY_LEFT_8")),leftBonyTran,"8");

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
        CategoryItemRenderer renderer = new DefaultCategoryItemRenderer();
        renderer.setSeriesPaint(0,Color.red); // right air
        renderer.setSeriesPaint(1,Color.blue); // left air
        renderer.setSeriesPaint(2,new Color(34,139,34)); // normal (green)
        renderer.setSeriesPaint(3,Color.BLACK); // right bony
        renderer.setSeriesPaint(4,new Color(153,50,204)); // left bony (purple)

        // round dots for all series
        int dotSize = 4;
        renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(1,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(2,new Ellipse2D.Double(0/2.0*(-1),0/2.0*(-1),0,0));
        renderer.setSeriesShape(3,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShape(4,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesVisible(5,new Boolean(false));
        renderer.setSeriesVisible(6,new Boolean(false));
        plot.setRenderer(renderer);

        /*
        // labels
        renderer.setSeriesItemLabelGenerator(0,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0.000"),new DecimalFormat("0")));
        renderer.setSeriesItemLabelsVisible(0,true);
        renderer.setSeriesItemLabelGenerator(1,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0.000"),new DecimalFormat("0")));
        renderer.setSeriesItemLabelsVisible(1,true);
        renderer.setSeriesItemLabelGenerator(2,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0.000"),new DecimalFormat("0")));
        renderer.setSeriesItemLabelsVisible(2,true);
        renderer.setSeriesItemLabelGenerator(3,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0.000"),new DecimalFormat("0")));
        renderer.setSeriesItemLabelsVisible(3,true);
        renderer.setSeriesItemLabelGenerator(4,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0.000"),new DecimalFormat("0")));
        renderer.setSeriesItemLabelsVisible(4,true);
        */

        // write graph to image
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,400,320);
        PdfPTable graphTable = new PdfPTable(1);

        // add image to table
        cell = new PdfPCell();
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(110);
        cell.setPaddingRight(125);
        graphTable.addCell(cell);

        // legend
        Phrase phrase = new Phrase(rightAirTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL,Color.RED));
               phrase.add(new Chunk(leftAirTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL,Color.BLUE)));
               phrase.add(new Chunk(normalTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL,new Color(34,139,34)))); // green
               phrase.add(new Chunk(rightBonyTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL,Color.BLACK)));
               phrase.add(new Chunk(leftBonyTran,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL,new Color(153,50,204)))); // purple
        cell = new PdfPCell(phrase);
        cell.setPaddingBottom(10);
        cell.setBorder(Cell.NO_BORDER);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
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
            contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }

        // add transaction to doc
        addTransactionToDoc();
    }

}
