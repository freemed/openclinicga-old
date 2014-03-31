package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.pdf.util.CustomXYLabelGenerator;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;
import com.itextpdf.text.Image;

import java.util.*;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;
import java.awt.*;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;

import org.jfree.data.time.*;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.axis.DateAxis;
import org.jfree.chart.axis.DateTickUnit;
import org.jfree.chart.renderer.xy.DefaultXYItemRenderer;
import org.jfree.chart.plot.XYPlot;

/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFDiabetesFollowup extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                table = new PdfPTable(5);
                
                addGlycemy();
                addGlucosurieAndHba1c();

                // add table to transaction
                if(table.size() > 0){
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    tranTable.addCell(createContentCell(contentTable));
                }
                
                addInsuline();                
                addDiet();
                
                addTransactionToDoc();

                addGraphs();
                addTransactionToDoc();

                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //### PRIVATE METHODS #########################################################################

    //--- ADD GLYCEMY -----------------------------------------------------------------------------
    private void addGlycemy(){
        Vector list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_MORNING");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_NOON");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_2_HOURS_AFTER_BREAKFAST");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_EVENING");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_REMARK");

        if(verifyList(list)){
            // title
            table.addCell(createTitleCell(getTran("web.occup","glycemy"),5));

            //*** glucometer ***
            PdfPTable glucometerTable = new PdfPTable(5);
            String sGlycemyUnit = MedwanQuery.getInstance().getConfigString("glycemyUnit","mg / dl");

            // morning_sober
            cell = createItemNameCell(getTran("diabetes","morning_sober"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucometerTable.addCell(cell);
            
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_MORNING");
            if(itemValue.length() > 0) itemValue+= " "+sGlycemyUnit;
            glucometerTable.addCell(createValueCell(itemValue,3));

            // noon
            cell = createItemNameCell(getTran("Web","noon"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucometerTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_NOON");
            if(itemValue.length() > 0) itemValue+= " "+sGlycemyUnit;
            glucometerTable.addCell(createValueCell(itemValue,3));

            // 2hours_after_morning
            cell = createItemNameCell(getTran("diabetes","2hours_after_morning"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucometerTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_2_HOURS_AFTER_BREAKFAST");
            if(itemValue.length() > 0) itemValue+= " "+sGlycemyUnit;
            glucometerTable.addCell(createValueCell(itemValue,3));

            // evening
            cell = createItemNameCell(getTran("Web","evening"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucometerTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_SHOT_EVENING");
            if(itemValue.length() > 0) itemValue+= " "+sGlycemyUnit;
            glucometerTable.addCell(createValueCell(itemValue,3));

            // add glucometer table
            if(glucometerTable.size() > 0){
                table.addCell(createItemNameCell(getTran("diabetes","glucometer"),2));
                table.addCell(createCell(new PdfPCell(glucometerTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            }

            //*** remark ***
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCEMY_REMARK");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("web","remark"),itemValue);
            }
        }
    }

    //--- ADD GLUCOSURIE AND HBA 1 C --------------------------------------------------------------
    private void addGlucosurieAndHba1c(){
        Vector list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_MORNING");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_NOON");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_EVENING");

        if(verifyList(list)){
            PdfPTable glucosurieTable = new PdfPTable(5);

            //*** glucosurie ***
            // morning_sober
            cell = createItemNameCell(getTran("diabetes","morning_sober"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucosurieTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_MORNING");
            glucosurieTable.addCell(createValueCell(itemValue,3));

            // noon
            cell = createItemNameCell(getTran("web","noon"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucosurieTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_NOON");
            glucosurieTable.addCell(createValueCell(itemValue,3));

            // evening
            cell = createItemNameCell(getTran("web","evening"),2);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            glucosurieTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_GLYCOSERIE_EVENING");
            glucosurieTable.addCell(createValueCell(itemValue,3));

            // add glucosurie table
            if(glucosurieTable.size() > 0){
                table.addCell(createItemNameCell(getTran("diabetes","glucosurie"),2));
                table.addCell(createCell(new PdfPCell(glucosurieTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            }

            //*** hba 1c ***
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_HBA1C");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("diabetes","hba1c"),itemValue+" "+getTran("units","ml"));
            }
        }
    }

    //--- ADD INSULINE ----------------------------------------------------------------------------
    private void addInsuline(){
        Vector list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_FAST");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_INTERMEDIAIR");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_MIXTE");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_FAST");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_INTERMEDIAIR");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_MIXTE");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_FAST");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_INTERMEDIAIR");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_MIXTE");

        if(verifyList(list)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createItemNameCell(getTran("web.occup","insuline"),2));

            PdfPTable insulineTable = new PdfPTable(4);
            String sInsulineUnit = MedwanQuery.getInstance().getConfigString("insulineUnit","lU");

            // table header
            insulineTable.addCell(emptyCell(1));
            insulineTable.addCell(createHeaderCell(getTran("web","rapide"),1));
            insulineTable.addCell(createHeaderCell(getTran("web","intermediair"),1));
            insulineTable.addCell(createHeaderCell(getTran("web","mixte"),1));

            //*** MORNING ***
            cell = createItemNameCell(getTran("web","morning"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            insulineTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_FAST");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_INTERMEDIAIR");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_MORNING_MIXTE");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));

            //*** NOON ***
            cell = createItemNameCell(getTran("web","noon"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            insulineTable.addCell(cell);

            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_FAST");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_INTERMEDIAIR");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_NOON_MIXTE");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));

            //*** EVENING ***
            cell = createItemNameCell(getTran("web","evening"),1);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            insulineTable.addCell(cell);
            
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_FAST");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_INTERMEDIAIR");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_INSULINE_SHOT_EVENING_MIXTE");
            insulineTable.addCell(createValueCell((itemValue.length()>0?itemValue+" "+sInsulineUnit:""),1));

            // add insuline table
            cell = new PdfPCell(insulineTable);
            cell.setColspan(3);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD DIET --------------------------------------------------------------------------------
    private void addDiet(){
        Vector list = new Vector();
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_07");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_10");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_12");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_15");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_17");
        list.add(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_OTHER");

        if(verifyList(list)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // title
            table.addCell(createItemNameCell(getTran("diabetes","diet"),2));

            PdfPTable dietTable = new PdfPTable(10);

            // 07h00 : repas
            cell = createItemNameCell("07h00",1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            dietTable.addCell(cell);

            cell = new PdfPCell(new Paragraph(getTran("diabetes","repas"), FontFactory.getFont(FontFactory.HELVETICA,7,com.itextpdf.text.Font.ITALIC)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            dietTable.addCell(cell);

            dietTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_07"),7));

            // 10h00 : collation
            cell = createItemNameCell("10h00",1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            dietTable.addCell(cell);

            cell = new PdfPCell(new Paragraph(getTran("diabetes","collation"), FontFactory.getFont(FontFactory.HELVETICA,7,com.itextpdf.text.Font.ITALIC)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            dietTable.addCell(cell);

            dietTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_10"),7));

            // 12h00 : repas
            cell = createItemNameCell("12h00",1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            dietTable.addCell(cell);

            cell = new PdfPCell(new Paragraph(getTran("diabetes","repas"), FontFactory.getFont(FontFactory.HELVETICA,7,com.itextpdf.text.Font.ITALIC)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            dietTable.addCell(cell);

            dietTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_12"),7));

            // 15h00 : collation
            cell = createItemNameCell("15h00",1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            dietTable.addCell(cell);

            cell = new PdfPCell(new Paragraph(getTran("diabetes","collation"), FontFactory.getFont(FontFactory.HELVETICA,7,com.itextpdf.text.Font.ITALIC)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            dietTable.addCell(cell);

            dietTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_15"),7));

            // 17h00 : collation
            cell = createItemNameCell("17h00",1);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BGCOLOR_LIGHT);
            dietTable.addCell(cell);

            cell = new PdfPCell(new Paragraph(getTran("diabetes","repas"), FontFactory.getFont(FontFactory.HELVETICA,7,com.itextpdf.text.Font.ITALIC)));
            cell.setColspan(2);
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
            dietTable.addCell(cell);

            dietTable.addCell(createValueCell(getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_17"),7));

            // other
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DIABETES_FOLLOWUP_DIET_OTHER");
            if(itemValue.length() > 0){
                dietTable.addCell(createItemNameCell(getTran("openclinic.chuk","other"),3));
                dietTable.addCell(createValueCell(itemValue,7));
            }

            // add diet table
            cell = new PdfPCell(dietTable);
            cell.setColspan(3);
            table.addCell(cell);

            // add table to transaction
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD GRAPHS ------------------------------------------------------------------------------
    private void addGraphs(){
        ItemVO itemVO = transactionVO.getItem("diabetesGraphsArePrinted");
        if(itemVO != null){
            try{
                // units
                String sGlycemyUnit  = MedwanQuery.getInstance().getConfigString("glycemyUnit","mg / dl"),
                       sInsulineUnit = MedwanQuery.getInstance().getConfigString("insulineUnit","lU");

                // begin date
                Calendar defaultBeginDate = new GregorianCalendar();
                defaultBeginDate.add(Calendar.MONTH,-1); // from : default one month ago

                boolean titleShown = false;

                //*** GLYCEMY GRAPH ***
                // get data from one month ago untill now
                Calendar now = new GregorianCalendar(); // until
                Hashtable glyDatesAndValues = MedwanQuery.getGlycemyShots(patient.personid,defaultBeginDate.getTime(),now.getTime());

                if(glyDatesAndValues.size() > 0){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);

                    // title ?
                    if(!titleShown){
                        // main title
                        table.addCell(createTitleCell(getTran("web","graphs"),5));
                        addItemRow(table,getTran("web","begindate"),new SimpleDateFormat("dd/MM/yyyy").format(defaultBeginDate.getTime()));

                        titleShown = true;
                    }
                    else{
                        // spacer
                        table.addCell(emptyCell(5));
                    }

                    // graph title
                    table.addCell(createHeaderCell(getTran("web.occup","glycemy"),5));

                    // graph
                    cell = createCell(new PdfPCell(getGraph(glyDatesAndValues,sGlycemyUnit)),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                    table.addCell(cell);

                    // add table
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                //*** 1st INSULINE GRAPH - RAPID ***
                // get data from one month ago untill now
                Hashtable insDatesAndValues = MedwanQuery.getInsulineShots(patient.personid,"RAPID",defaultBeginDate.getTime(),now.getTime());

                if(insDatesAndValues.size() > 0){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);

                    // title ?
                    if(!titleShown){
                        // main title
                        table.addCell(createTitleCell(getTran("web","graphs"),5));
                        addItemRow(table,getTran("web","begindate"),new SimpleDateFormat("dd/MM/yyyy").format(defaultBeginDate.getTime()));

                        titleShown = true;
                    }

                    // graph title
                    table.addCell(createHeaderCell(getTran("web.occup","insuline")+" "+getTran("web","rapid"),5));

                    // graph
                    cell = createCell(new PdfPCell(getGraph(insDatesAndValues,sInsulineUnit)),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                    table.addCell(cell);

                    // add table
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                //*** 2nd INSULINE GRAPH - SEMI RAPID ***
                // get data from one month ago untill now
                insDatesAndValues = MedwanQuery.getInsulineShots(patient.personid,"SEMIRAPID",defaultBeginDate.getTime(),now.getTime());

                if(insDatesAndValues.size() > 0){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);

                    // title ?
                    if(!titleShown){
                        // main title
                        table.addCell(createTitleCell(getTran("web","graphs"),5));
                        addItemRow(table,getTran("web","begindate"),new SimpleDateFormat("dd/MM/yyyy").format(defaultBeginDate.getTime()));

                        titleShown = true;
                    }

                    // graph title
                    table.addCell(createHeaderCell(getTran("web.occup","insuline")+" "+getTran("web","semirapid"),5));

                    // graph
                    cell = createCell(new PdfPCell(getGraph(insDatesAndValues,sInsulineUnit)),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                    table.addCell(cell);

                    // add table
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }

                //*** 3rd INSULINE GRAPH - SLOW ***
                // get data from one month ago untill now
                insDatesAndValues = MedwanQuery.getInsulineShots(patient.personid,"SLOW",defaultBeginDate.getTime(),now.getTime());

                if(insDatesAndValues.size() > 0){
                    contentTable = new PdfPTable(1);
                    table = new PdfPTable(5);

                    // title ?
                    if(!titleShown){
                        // main title
                        table.addCell(createTitleCell(getTran("web","graphs"),5));
                        addItemRow(table,getTran("web","begindate"),new SimpleDateFormat("dd/MM/yyyy").format(defaultBeginDate.getTime()));

                        titleShown = true;
                    }

                    // graph title
                    table.addCell(createHeaderCell(getTran("web.occup","insuline")+" "+getTran("web","slow"),5));

                    // graph
                    cell = createCell(new PdfPCell(getGraph(insDatesAndValues,sInsulineUnit)),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
                    table.addCell(cell);

                    // add table
                    contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tranTable.addCell(createContentCell(contentTable));
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- GET GRAPH -------------------------------------------------------------------------------
    private PdfPTable getGraph(Hashtable graphData, String unit){
        // sort hash on dates (DB only sorted them on day, not on hour)
        Vector dates = new Vector(graphData.keySet());
        Collections.sort(dates);

        String sGlyBeginDate = "", sGlyEndDate;
        SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
        java.util.Date date;
        String value;

        Vector aDates  = new Vector(),
               aValues = new Vector();

        // concatenate vector-content to use in JS below
        for(int i=0; i<dates.size(); i++){
            date = (java.util.Date)dates.get(i);
            value = (String)graphData.get(date);
            sGlyEndDate = checkString(fullDateFormat.format(date));

            // keep notice of the earlyest date
            if(sGlyBeginDate.trim().length()==0){
                sGlyBeginDate = sGlyEndDate;
            }

            aDates.add(date);
            aValues.add(new Double(value));
        }

        PdfPTable graphTable = new PdfPTable(1);

        try{
            // create dataset
            TimeSeries series1 = new TimeSeries("Series1",Hour.class);
            TimeSeriesCollection dataset = new TimeSeriesCollection();
            dataset.addSeries(series1);

            Date dDate;
            double dValue;
            for(int i=0; i<aDates.size(); i++){
                dDate = (Date)aDates.get(i);
                dValue = ((Double)aValues.get(i)).doubleValue();

                series1.add(new Hour(dDate),dValue);
            }

            // create chart
            final JFreeChart chart = ChartFactory.createTimeSeriesChart(
                "", // chart title
                "", // domain axis label
                unit, // range axis label
                dataset, // data
                false, // legend
                true, // tooltips
                false // urls
            );

            // customize chart
            XYPlot plot = chart.getXYPlot();
            DateAxis axis = (DateAxis)plot.getDomainAxis();
            int intervalInDays = (int)Math.round((double)aValues.size()/4.0);
            axis.setTickUnit(new DateTickUnit(DateTickUnit.DAY,intervalInDays,new SimpleDateFormat("dd/MM/yy")));
            axis.setVerticalTickLabels(true);

            chart.setAntiAlias(true);
            chart.setBackgroundPaint(Color.WHITE);

            // values at graph-points
            DefaultXYItemRenderer renderer = new DefaultXYItemRenderer();
            renderer.setSeriesItemLabelGenerator(0,new CustomXYLabelGenerator("{1}",new DecimalFormat("0.0"),new DecimalFormat("0.0")));
            renderer.setSeriesItemLabelsVisible(0,true);
            plot.setRenderer(renderer);

            // round dots for the serie
            int dotSize = 4;
            renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
            plot.setRenderer(renderer);
            
            // value range
            ValueAxis rangeAxis = plot.getRangeAxis();
            rangeAxis.setUpperMargin(0.1);
            //double maxval = rangeAxis.getUpperBound();
            //if(maxval < 20){
            //    rangeAxis.setUpperMargin(20.0/maxval - 1.0);
            //}

            // save chart as image
            ByteArrayOutputStream os = new ByteArrayOutputStream();
            ChartUtilities.writeChartAsPNG(os,chart,420,336);

            // put image of chart in cell
            cell = createCell(new PdfPCell(),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX);
            cell.setImage(Image.getInstance(os.toByteArray()));
            cell.setPaddingTop(10);
            cell.setPaddingLeft(110);
            cell.setPaddingRight(125);
            cell.setPaddingBottom(5);
            graphTable.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return graphTable;
    }

}

