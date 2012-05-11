package be.mxs.common.util.pdf.general.oc.examinations;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Image;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Font;
import com.itextpdf.text.Chunk;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.renderer.category.LineAndShapeRenderer;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.CategoryPlot;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.util.CustomCategoryLabelGenerator;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.model.vo.healthrecord.ItemVO;


public class PDFRespiratoryFunctionExamination extends PDFGeneralBasic {

    // declarations
    private Vector aFEV1Dates, aFEV1Values, aFVCDates, aFVCValues;
    private SimpleDateFormat dateFormat;
    private int yearOfBirth;


    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public PDFRespiratoryFunctionExamination(){
        dateFormat = new SimpleDateFormat("dd/MM/yyyy");

        // create vectors
        aFEV1Dates  = new Vector();
        aFEV1Values = new Vector();
        aFVCDates   = new Vector();
        aFVCValues  = new Vector();
    }

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                // add transaction part 1 to doc
                addGraphs();
                if(tranTable.size() > 1){
                    addTransactionToDoc();
                }

                // add transaction part 2 to doc
                addVaria();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    //--- ADD GRAPHS -------------------------------------------------------------------------------
    private void addGraphs(){
        ItemVO itemVO = transactionVO.getItem("graphsArePrinted");
        if(itemVO != null){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(2);

            // year of birth
            yearOfBirth = 0;
            if(patient.dateOfBirth.trim().length() == 10){
                yearOfBirth = Integer.parseInt(patient.dateOfBirth.substring(6));
            }

            // left graph
            cell = createCell(new PdfPCell(getFEV1Graph(yearOfBirth)),1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX);
            cell.setPadding(3);
            table.addCell(cell);

            // right graph
            cell = createCell(new PdfPCell(getFVCGraph()),1,PdfPCell.ALIGN_LEFT,PdfPCell.BOX);
            cell.setPadding(3);
            table.addCell(cell);

            // add content to document
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD VARIA --------------------------------------------------------------------------------
    private void addVaria(){
        String itemValueA;

        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // FEV1
        itemValue  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FEV1");
        itemValueA = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FEV1_A");

        if(itemValue.length() > 0){
            itemValue+= " "+getTran("units","liter")+"/"+getTran("units","minute");
            if(!itemValueA.equals("")){
                itemValue+=" ("+itemValueA+"%)";
            }

            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FEV1"),itemValue);
        }

        // FVC
        itemValue  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FVC");
        itemValueA = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FVC_A");

        if(itemValue.length() > 0){
            itemValue+= " "+getTran("units","liter")+"/"+getTran("units","minute");
            if(!itemValueA.equals("")){
                itemValue+=" ("+itemValueA+"%)";
            }

            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FVC"),itemValue);
        }

        // VC
        itemValue  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_VC");
        itemValueA = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_VC_A");

        if(itemValue.length() > 0){
            itemValue+= " "+getTran("units","liter")+"/"+getTran("units","minute");
            if(!itemValueA.equals("")){
                itemValue+=" ("+itemValueA+"%)";
            }

            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_VC"),itemValue);
        }

        // Tiffeneau
        String sFEV1 = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FEV1").replace(',','.');
        String sVC   = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_VC").replace(',','.');

        try{
            double FEV1 = Double.parseDouble(sFEV1);
            double VC   = Double.parseDouble(sVC);

            DecimalFormat deci = new DecimalFormat("0.00");
            itemValue = deci.format((FEV1/VC))+"";
        }
        catch(Exception e){
            itemValue = "";
        }

        if(itemValue.length() > 0){
            addItemRow(table,"Tiffeneau",itemValue);
        }

        // PEV
        itemValue  = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_PEF");
        itemValueA = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_PEF_A");

        if(itemValue.length() > 0){
            itemValue+= " "+getTran("units","liter")+"/"+getTran("units","minute");
            if(!itemValueA.equals("")){
                itemValue+=" ("+itemValueA+"%)";
            }

            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_PEF"),itemValue);
        }

        // CAUSE OF FAILURE (dropdown)
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_RAISON_FAILURE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_RAISON_FAILURE"),getTran(itemValue));
        }

        // COMMENT
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_COMMENT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_COMMENT"),itemValue);
        }

        // OTHER_REQUESTS_PRESTATION
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION");
        if(itemValue.length() > 0){
            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION"),getTran("medwan.common.yes"));
        }

        // add content to document
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }

    //--- GET FEV1 GRAPH ---------------------------------------------------------------------------
    private PdfPTable getFEV1Graph(int yearOfBirth){
        PdfPTable fevTable = new PdfPTable(1);

        try{
            // create dataset
            DefaultCategoryDataset dataset = new DefaultCategoryDataset();
            String r1Tran = getTran("medwan.common.normal"),
                   r2Tran = getTran("medwan.recruitment.measurement");

            // init data vectors
            Date dFEV1Date;
            double dFEV1Value;
            aFEV1Dates  = new Vector();
            aFEV1Values = new Vector();
            getFEV1Data();

            //*** series 1 : FEV1 normal ***
            for(int i=0; i<aFEV1Dates.size(); i++){
                dFEV1Date = (Date)aFEV1Dates.get(i);
                dFEV1Value = getFEV1Normal(dateFormat.format(dFEV1Date),yearOfBirth);
                dataset.addValue(dFEV1Value,r1Tran,dateFormat.format(dFEV1Date));
            }

            //*** series 2 : FEV1 measurement ***
            for(int i=0; i<aFEV1Dates.size(); i++){
                dFEV1Date = (Date)aFEV1Dates.get(i);
                dFEV1Value = ((Double)aFEV1Values.get(i)).doubleValue();
                dataset.addValue(dFEV1Value,r2Tran,dateFormat.format(dFEV1Date));
            }

            // create chart
            final JFreeChart chart = ChartFactory.createLineChart(
                "         FEV1", // chart title
                "", // domain axis label
                "", // range axis label
                dataset, // data
                PlotOrientation.VERTICAL, // orientation
                false, // legend
                false, // tooltips
                false // urls
            );

            // customize chart
            chart.setAntiAlias(true);
            chart.setBackgroundPaint(Color.white);

            /*
            // standard legend
            StandardLegend legend = (StandardLegend)chart.getLegend();
            legend.setDisplaySeriesShapes(true);
            */

            // values at graph-points
            CategoryPlot plot = chart.getCategoryPlot();
            LineAndShapeRenderer renderer = new LineAndShapeRenderer();
            renderer.setSeriesItemLabelGenerator(0,new CustomCategoryLabelGenerator(new DecimalFormat("0.00")));
            renderer.setSeriesItemLabelsVisible(0,true);
            plot.setRenderer(renderer);

            // round dots for all series
            int dotSize = 4;
            renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
            renderer.setSeriesShape(1,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
            plot.setRenderer(renderer);

            // fixed value range
            ValueAxis rangeAxis = plot.getRangeAxis();
            rangeAxis.setLowerMargin(0);
            rangeAxis.setUpperMargin(0);
            double maxval = rangeAxis.getUpperBound();
            if(maxval < 20){
                rangeAxis.setUpperMargin(20.0/maxval - 1.0);
            }

            // save chart as image
            ByteArrayOutputStream os = new ByteArrayOutputStream();
            ChartUtilities.writeChartAsPNG(os,chart,400,300);

            // put image of chart in cell
            cell = new PdfPCell();
            cell.setImage(Image.getInstance(os.toByteArray()));
            cell.setColspan(1);
            cell.setPaddingLeft(10);
            cell.setPaddingRight(20);
            cell.setPaddingBottom(0);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_BOTTOM);
            fevTable.addCell(cell);

            // custom legend
            Phrase phrase = new Phrase("     "+r2Tran+"     ",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL,BaseColor.BLUE));
            phrase.add(new Chunk("("+r1Tran+")",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL,BaseColor.RED)));
            cell = new PdfPCell(phrase);
            cell.setColspan(1);
            cell.setPaddingBottom(5);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            fevTable.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return fevTable;
    }

    //--- GET FVC GRAPH ----------------------------------------------------------------------------
    private PdfPTable getFVCGraph(){
        PdfPTable fvcTable = new PdfPTable(1);

        try{
            // create dataset
            DefaultCategoryDataset dataset = new DefaultCategoryDataset();
            String r1Tran = getTran("medwan.common.normal"),
                   r2Tran = getTran("medwan.recruitment.measurement");

            // init data vectors
            Date dFVCDate;
            double dFVCValue;
            aFVCDates  = new Vector();
            aFVCValues = new Vector();
            getFVCData();

            //*** series 1 : FVC normal ***
            for(int i=0; i<aFVCDates.size(); i++){
                dFVCDate = (Date)aFVCDates.get(i);
                dFVCValue = getFVCNormal(dateFormat.format(dFVCDate),yearOfBirth);
                dataset.addValue(dFVCValue,r1Tran,dateFormat.format(dFVCDate));
            }

            //*** series 2 : FVC measurement ***
            for(int i=0; i<aFVCDates.size(); i++){
                dFVCDate = (Date)aFVCDates.get(i);
                dFVCValue = ((Double)aFVCValues.get(i)).doubleValue();
                dataset.addValue(dFVCValue,r2Tran,dateFormat.format(dFVCDate));
            }

            // create chart
            final JFreeChart chart = ChartFactory.createLineChart(
                "         FVC", // chart title
                "", // domain axis label
                "", // range axis label
                dataset, // data
                PlotOrientation.VERTICAL, // orientation
                false, // legend
                false, // tooltips
                false // urls
            );

            // customize chart
            chart.setAntiAlias(true);
            chart.setBackgroundPaint(Color.white);

            /*
            // standard legend
            StandardLegend legend = (StandardLegend)chart.getLegend();
            legend.setDisplaySeriesShapes(true);
            */

            // values at graph-points
            CategoryPlot plot = chart.getCategoryPlot();
            LineAndShapeRenderer renderer = new LineAndShapeRenderer();
            renderer.setSeriesItemLabelGenerator(0,new CustomCategoryLabelGenerator(new DecimalFormat("0.00")));
            renderer.setSeriesItemLabelsVisible(0,true);
            plot.setRenderer(renderer);

            // round dots for all series
            int dotSize = 4;
            renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
            renderer.setSeriesShape(1,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
            plot.setRenderer(renderer);
            
            // fixed value range
            ValueAxis rangeAxis = plot.getRangeAxis();
            rangeAxis.setLowerMargin(0);
            rangeAxis.setUpperMargin(0);
            double maxval = rangeAxis.getUpperBound();
            if(maxval < 20){
                rangeAxis.setUpperMargin(20.0/maxval - 1.0);
            }
                                               
            // save chart as image
            ByteArrayOutputStream os = new ByteArrayOutputStream();
            ChartUtilities.writeChartAsPNG(os,chart,400,300);

            // put image of chart in cell
            cell = new PdfPCell();
            cell.setImage(Image.getInstance(os.toByteArray()));
            cell.setColspan(1);
            cell.setPaddingLeft(10);
            cell.setPaddingRight(20);
            cell.setPaddingBottom(0);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_BOTTOM);
            fvcTable.addCell(cell);

            // custom legend
            Phrase phrase = new Phrase("     "+r2Tran+"     ",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL,BaseColor.BLUE));
            phrase.add(new Chunk("("+r1Tran+")",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL,BaseColor.RED)));
            cell = new PdfPCell(phrase);
            cell.setColspan(1);
            cell.setPaddingBottom(5);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
            fvcTable.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return fvcTable;
    }

    //--- GET FEV1 DATA ----------------------------------------------------------------------------
    private void getFEV1Data() throws Exception {
        StringBuffer sSelect = new StringBuffer();
        sSelect.append("SELECT t.updateTime AS ut, i."+MedwanQuery.getInstance().getConfigString("valueColumn")+"  AS ow_value")
               .append(" FROM Healthrecord h, Transactions t, Items i")
               .append("  WHERE h.personId = ? ")
               .append("   AND t.healthRecordId = h.healthRecordId")
               .append("   AND t.transactionType = '"+IConstants_PREFIX+"TRANSACTION_TYPE_RESP_FUNC_EX'")
               .append("   AND i.transactionId = t.transactionId")
               .append("   AND i.type = '"+IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FEV1'")
               .append(" ORDER BY t.updateTime ASC");

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sSelect.toString());
        ps.setInt(1,Integer.parseInt(patient.personid));
        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            aFEV1Dates.add(rs.getTimestamp("ut"));
            aFEV1Values.add(new Double(rs.getString("ow_value")));
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }

    //--- GET FVC DATA -----------------------------------------------------------------------------
    private void getFVCData() throws Exception {
        StringBuffer sSelect = new StringBuffer();
        sSelect.append("SELECT t.updateTime AS ut, i."+MedwanQuery.getInstance().getConfigString("valueColumn")+" AS ow_value")
               .append(" FROM Healthrecord h, Transactions t, Items i")
               .append("  WHERE h.personId = ? ")
               .append("   AND t.healthRecordId = h.healthRecordId")
               .append("   AND t.transactionType = '"+IConstants_PREFIX+"TRANSACTION_TYPE_RESP_FUNC_EX'")
               .append("   AND i.transactionId = t.transactionId")
               .append("   AND i.type = '"+IConstants_PREFIX+"ITEM_TYPE_RESP_FUNC_EX_FVC'")
               .append(" ORDER BY t.updateTime ASC");

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sSelect.toString());
        ps.setInt(1,Integer.parseInt(patient.personid));
        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            aFVCDates.add(rs.getTimestamp("ut"));
            aFVCValues.add(new Double(rs.getString("ow_value")));
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }

    //--- GET FEV1 NORMAL --------------------------------------------------------------------------
    private double getFEV1Normal(String sDate, int yearOfBirth) throws Exception {
        int age = Integer.parseInt(sDate.substring(sDate.lastIndexOf("/")+1)) - yearOfBirth;
        double normal;
        float rLength = getLength();

        if(patient.gender.equalsIgnoreCase("F")){
            normal = (1.08*(3.95*rLength - 0.025 * age - 2.6));
        }
        else {
            normal = (1.08*(4.3*rLength - 0.029 * age - 2.49));
        }

        if(normal < 0) normal = 0;

        return normal;
    }

    //--- GET FVC NORMAL ---------------------------------------------------------------------------
    private double getFVCNormal(String sDate, int yearOfBirth) throws Exception {
        int age = Integer.parseInt(sDate.substring(sDate.lastIndexOf("/")+1)) - yearOfBirth;
        double normal;
        float rLength = getLength();

        if(patient.gender.equalsIgnoreCase("F")){
          normal = (1.15*(4.43*rLength - 0.026 * age - 2.89));
        }
        else {
          normal = (1.1*(5.76*rLength - 0.026 * age - 4.34));
        }

        if(normal < 0) normal = 0;

        return normal;
    }

    //--- GET LENGTH -------------------------------------------------------------------------------
    private float getLength() throws SQLException {
        float rLength = 0;
        StringBuffer sSelect = new StringBuffer();
        sSelect.append("SELECT i."+MedwanQuery.getInstance().getConfigString("valueColumn")+" AS ow_value")
               .append(" FROM Healthrecord h, Transactions t, Items i WHERE personId = ?")
               .append("  AND t.healthRecordId = h.healthRecordId")
               .append("  AND i.transactionId = t.transactionId")
               .append("  AND i.type = '"+IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_HEIGHT'")
               .append(" ORDER BY t.updateTime DESC");

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sSelect.toString());
        ps.setInt(1,Integer.parseInt(patient.personid));
        ResultSet rs = ps.executeQuery();

        String sTmpLength;
        while(rs.next()){
            sTmpLength = rs.getString("ow_value");
            rLength = Float.parseFloat(sTmpLength.replaceAll(",","."));
            rLength = new Float(rLength/100.0).floatValue();
        }
        rs.close();
        ps.close();
        oc_conn.close();

        return rLength;
    }

}
