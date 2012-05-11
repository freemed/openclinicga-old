package be.mxs.common.util.pdf.official.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.data.xy.XYSeries;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.labels.StandardXYItemLabelGenerator;
import org.jfree.chart.annotations.XYTextAnnotation;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
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
public class PDFOfficialGrowthGraph5To20Year extends PDFOfficialGrowthGraph {

    //--- GET GROWTH GRAPHS -----------------------------------------------------------------------
    protected PdfPTable getGrowthGraphs() throws Exception {
        PdfPTable growthTable = new PdfPTable(1);
        growthTable.setWidthPercentage(pageWidth);

        //*** height graph ****************************************************
        ByteArrayOutputStream osHeight = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHeight,getHeightGraph(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.itextpdf.text.Image.getInstance(osHeight.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        // spacer
        growthTable.addCell(createBorderlessCell("",30,1));

        //*** weight graph ****************************************************
        ByteArrayOutputStream osWeight = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osWeight,getWeightGraph(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.itextpdf.text.Image.getInstance(osWeight.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        return growthTable;
    }

    //--- GET HEIGTH GRAPH ------------------------------------------------------------------------
    private JFreeChart getHeightGraph() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"height-age-05-20.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double height, lastPatientHeight = 0;
        float age;
        for(int i=60; i<240; i++){
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
        java.awt.Font font = new java.awt.Font("SansSerif",Font.NORMAL,9);

        int xPosAnnotation = 245;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 163.00);
            addAnnotation("5th",font,plot,xPosAnnotation, 166.00);
            addAnnotation("25th",font,plot,xPosAnnotation,172.00);
            addAnnotation("50th",font,plot,xPosAnnotation,177.00);
            addAnnotation("75th",font,plot,xPosAnnotation,182.00);
            addAnnotation("95th",font,plot,xPosAnnotation,188.00);
            addAnnotation("97th",font,plot,xPosAnnotation,191.00);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 151.00);
            addAnnotation("5th",font,plot,xPosAnnotation, 154.00);
            addAnnotation("25th",font,plot,xPosAnnotation,159.00);
            addAnnotation("50th",font,plot,xPosAnnotation,163.00);
            addAnnotation("75th",font,plot,xPosAnnotation,168.00);
            addAnnotation("95th",font,plot,xPosAnnotation,174.00);
            addAnnotation("97th",font,plot,xPosAnnotation,176.35);
        }
        
        // patient annotation
        XYTextAnnotation annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientHeight);
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

    //--- GET WEIGTH GRAPH ------------------------------------------------------------------------
    private JFreeChart getWeightGraph() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"weight-age-05-20.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double weight, lastPatientWeight = 0;
        float age;
        for(int i=60; i<240; i++){
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
        java.awt.Font font = new java.awt.Font("SansSerif",Font.NORMAL,9);

        double xPosAnnotation = 245;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation,  54.0);
            addAnnotation("5th",font,plot,xPosAnnotation,  57.0);
            addAnnotation("25th",font,plot,xPosAnnotation, 64.0);
            addAnnotation("50th",font,plot,xPosAnnotation, 71.0);
            addAnnotation("75th",font,plot,xPosAnnotation, 80.0);
            addAnnotation("95th",font,plot,xPosAnnotation, 96.0);
            addAnnotation("97th",font,plot,xPosAnnotation,102.0);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 44.9);
            addAnnotation("5th",font,plot,xPosAnnotation, 47.2);
            addAnnotation("25th",font,plot,xPosAnnotation,53.0);
            addAnnotation("50th",font,plot,xPosAnnotation,59.0);
            addAnnotation("75th",font,plot,xPosAnnotation,66.0);
            addAnnotation("95th",font,plot,xPosAnnotation,83.0);
            addAnnotation("97th",font,plot,xPosAnnotation,89.0);
        }

        // patient annotation
        XYTextAnnotation annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientWeight);
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
