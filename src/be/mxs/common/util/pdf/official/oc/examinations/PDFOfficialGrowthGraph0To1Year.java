package be.mxs.common.util.pdf.official.oc.examinations;

import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Font;
import com.lowagie.text.Cell;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.data.xy.XYSeries;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.labels.StandardXYItemLabelGenerator;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.annotations.XYTextAnnotation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.ui.TextAnchor;

import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;

/**
 * User: ssm
 * Date: 16-jul-2007
 */
public class PDFOfficialGrowthGraph0To1Year extends PDFOfficialGrowthGraph {

    //--- GET GROWTH GRAPHS -----------------------------------------------------------------------
    protected PdfPTable getGrowthGraphs() throws Exception {
        PdfPTable growthTable = new PdfPTable(1);
        growthTable.setWidthPercentage(pageWidth);

        //*** height graph ****************************************************
        ByteArrayOutputStream osHeight = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHeight,getHeightGraph(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.lowagie.text.Image.getInstance(osHeight.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        // spacer
        growthTable.addCell(createBorderlessCell("",30,1));

        //*** weight graph ****************************************************
        ByteArrayOutputStream osWeight = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osWeight,getWeightGraph(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.lowagie.text.Image.getInstance(osWeight.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        // spacer
        growthTable.addCell(createBorderlessCell("",30,1));

        //*** skull graph *****************************************************
        ByteArrayOutputStream osSkull = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osSkull,getSkullGraph(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.lowagie.text.Image.getInstance(osSkull.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        return growthTable;
    }

    //--- GET HEIGHT GRAPH ------------------------------------------------------------------------
    private JFreeChart getHeightGraph() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"height-age-00-01.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double height, lastPatientHeight = 0;
        float age;
        for(int i=0; i<12; i++){
            height = getPatientHeightForAge(i);

            if(height > 0){
                age = new Float(i).floatValue();
                patientSeries.add(age,new Float(height).floatValue());
                lastPatientHeight = height;
            }
        }

        dataset.addSeries(patientSeries);

        // create chart
        final JFreeChart chart = createChart(dataset,getTran("web","heightForAgePercentiles"),getTran("web","heightInCentimeter"));

        // add annotations
        XYPlot plot = chart.getXYPlot();
        XYTextAnnotation annotation;
        java.awt.Font font = new java.awt.Font("SansSerif",Font.NORMAL,9);

        double xPosAnnotation = 12.25;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 71.40);
            addAnnotation("5th",font,plot,xPosAnnotation, 72.45);
            addAnnotation("25th",font,plot,xPosAnnotation,74.30);
            addAnnotation("50th",font,plot,xPosAnnotation,75.75);
            addAnnotation("75th",font,plot,xPosAnnotation,77.75);
            addAnnotation("95th",font,plot,xPosAnnotation,79.75);
            addAnnotation("97th",font,plot,xPosAnnotation,80.95);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 69.40);
            addAnnotation("5th",font,plot,xPosAnnotation, 70.50);
            addAnnotation("25th",font,plot,xPosAnnotation,72.35);
            addAnnotation("50th",font,plot,xPosAnnotation,73.85);
            addAnnotation("75th",font,plot,xPosAnnotation,75.80);
            addAnnotation("95th",font,plot,xPosAnnotation,78.30);
            addAnnotation("97th",font,plot,xPosAnnotation,79.35);
        }

        // patient annotation
        annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientHeight);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        annotation.setPaint(Color.BLUE);
        plot.addAnnotation(annotation);

        // visual customization
        chart.setBackgroundPaint(Color.WHITE);

        // series colors
        int idx = 0;
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
        renderer.setSeriesPaint(idx,Color.red);    //  3rd
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); //  5th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 25th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.green);  // 50th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 75th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 95th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.red);    // 97th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.blue);   // patient
        renderer.setSeriesShapesVisible(idx,true);

        // only dots for patient values
        renderer.setSeriesLinesVisible(idx,false); // no curve
        int dotSize = 3;
        renderer.setSeriesShape(idx,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));

        // labels
        renderer.setSeriesItemLabelGenerator(idx,new StandardXYItemLabelGenerator("{2}",new DecimalFormat("0.00"),new DecimalFormat("0.00")));
        renderer.setSeriesItemLabelsVisible(idx,true);
        plot.setRenderer(renderer);

        return chart;
    }

    //--- GET WEIGHT GRAPH ------------------------------------------------------------------------
    private JFreeChart getWeightGraph() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"weight-age-00-01.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double weight, lastPatientWeight = 0;
        float age;
        for(int i=0; i<12; i++){
            weight = getPatientWeightForAge(i);

            if(weight > 0){
                age = new Float(i).floatValue();
                patientSeries.add(age,new Float(weight).floatValue());
                lastPatientWeight = weight;
            }
        }

        dataset.addSeries(patientSeries);

        // create chart
        final JFreeChart chart = createChart(dataset,getTran("web","weightForAgePercentiles"),getTran("web","weightInKilo"));

        // add annotations
        XYPlot plot = chart.getXYPlot();
        XYTextAnnotation annotation;
        java.awt.Font font = new java.awt.Font("SansSerif", Font.NORMAL,9);

        double xPosAnnotation = 12.25;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation,  7.80);
            addAnnotation("5th",font,plot,xPosAnnotation,  8.20);
            addAnnotation("25th",font,plot,xPosAnnotation, 9.10);
            addAnnotation("50th",font,plot,xPosAnnotation, 9.65);
            addAnnotation("75th",font,plot,xPosAnnotation,10.55);
            addAnnotation("95th",font,plot,xPosAnnotation,11.60);
            addAnnotation("97th",font,plot,xPosAnnotation,11.90);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation,  7.10);
            addAnnotation("5th",font,plot,xPosAnnotation,  7.45);
            addAnnotation("25th",font,plot,xPosAnnotation, 8.20);
            addAnnotation("50th",font,plot,xPosAnnotation, 8.95);
            addAnnotation("75th",font,plot,xPosAnnotation, 9.80);
            addAnnotation("95th",font,plot,xPosAnnotation,11.00);
            addAnnotation("97th",font,plot,xPosAnnotation,11.35);
        }

        // patient annotation
        annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientWeight);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        annotation.setPaint(Color.BLUE);
        plot.addAnnotation(annotation);

        // visual customization
        chart.setBackgroundPaint(Color.WHITE);

        // series colors
        int idx = 0;
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
        renderer.setSeriesPaint(idx,Color.red);    //  3rd
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); //  5th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 25th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.green);  // 50th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 75th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 95th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.red);    // 97th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.blue);   // patient
        renderer.setSeriesShapesVisible(idx,true);

        // only dots for patient values
        renderer.setSeriesLinesVisible(idx,false); // no curve
        int dotSize = 3;
        renderer.setSeriesShape(idx,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));

        // labels
        renderer.setSeriesItemLabelGenerator(idx,new StandardXYItemLabelGenerator("{2}",new DecimalFormat("0.00"),new DecimalFormat("0.00")));
        renderer.setSeriesItemLabelsVisible(idx,true);
        plot.setRenderer(renderer);

        return chart;
    }

    //--- GET SKULL GRAPH -------------------------------------------------------------------------
    private JFreeChart getSkullGraph() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"skull-age-00-01.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double circumference, lastPatientCircumference = 0;
        float age;
        for(int i=0; i<12; i++){
            circumference = getPatientSkullCircumferenceForAge(i);

            if(circumference > 0){
                age = new Float(i).floatValue();
                patientSeries.add(age,new Float(circumference).floatValue());
                lastPatientCircumference = circumference;
            }
        }

        dataset.addSeries(patientSeries);

        // create chart
        final JFreeChart chart = createChart(dataset,getTran("web","skullForAgePercentiles"),getTran("web","circumferenceInCentimeter"));

        // add annotations
        XYPlot plot = chart.getXYPlot();
        XYTextAnnotation annotation;
        java.awt.Font font = new java.awt.Font("SansSerif", Font.NORMAL,9);

        double xPosAnnotation = 12.25;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 43.65);
            addAnnotation("5th",font,plot,xPosAnnotation, 44.20);
            addAnnotation("25th",font,plot,xPosAnnotation,45.15);
            addAnnotation("50th",font,plot,xPosAnnotation,46.25);
            addAnnotation("75th",font,plot,xPosAnnotation,47.05);
            addAnnotation("95th",font,plot,xPosAnnotation,48.20);
            addAnnotation("97th",font,plot,xPosAnnotation,48.70);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 42.45);
            addAnnotation("5th",font,plot,xPosAnnotation, 43.00);
            addAnnotation("25th",font,plot,xPosAnnotation,44.00);
            addAnnotation("50th",font,plot,xPosAnnotation,45.05);
            addAnnotation("75th",font,plot,xPosAnnotation,45.85);
            addAnnotation("95th",font,plot,xPosAnnotation,47.00);
            addAnnotation("97th",font,plot,xPosAnnotation,47.60);
        }

        // patient annotation
        annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientCircumference);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        annotation.setPaint(Color.BLUE);
        plot.addAnnotation(annotation);

        // visual customization
        chart.setBackgroundPaint(Color.WHITE);

        // series colors
        int idx = 0;
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
        renderer.setSeriesPaint(idx,Color.red);    //  3rd
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); //  5th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 25th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.green);  // 50th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 75th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.orange); // 95th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.red);    // 97th
        renderer.setSeriesShapesVisible(idx++,false);
        renderer.setSeriesPaint(idx,Color.blue);   // patient
        renderer.setSeriesShapesVisible(idx,true);

        // only dots for patient values
        renderer.setSeriesLinesVisible(idx,false); // no curve
        int dotSize = 3;
        renderer.setSeriesShape(idx,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));

        // labels
        renderer.setSeriesItemLabelGenerator(idx,new StandardXYItemLabelGenerator("{2}",new DecimalFormat("0.00"),new DecimalFormat("0.00")));
        renderer.setSeriesItemLabelsVisible(idx,true);
        plot.setRenderer(renderer);

        return chart;
    }
}
