package be.mxs.common.util.pdf.general.oc.examinations;

import java.awt.Color;
import java.awt.geom.Ellipse2D;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Hashtable;
import java.util.Vector;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.annotations.XYTextAnnotation;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.labels.StandardXYItemLabelGenerator;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.xy.XYDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.ui.TextAnchor;

import com.itextpdf.text.Font;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.Debug;


public class PDFBiometry extends PDFGeneralBasic {
    protected Hashtable patientHeights, patientWeights, patientSkullCircumferences;

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(1);
                PdfPTable biometryTable = new PdfPTable(7);

                String sBio = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER");
                if(sBio.indexOf("£")>-1){
                    StringBuffer sTmpBio = new StringBuffer(sBio);
                    String sTmpDate, sTmpWeight, sTmpHeight, sTmpSkull, sTmpArm, sTmpFood;

                    while(sTmpBio.toString().toLowerCase().indexOf("$")>-1){
                        sTmpDate = "";
                        if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpDate = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpWeight = "";
                        if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpWeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpHeight = "";
                        if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpHeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpSkull = "";
                        if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpSkull = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpArm = "";
                        if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                            sTmpArm = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                        }
                        
                        sTmpFood = "";
                        if(sTmpBio.toString().toLowerCase().indexOf("$")>-1){
                            sTmpFood = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("$"));
                            sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("$")+1));
                        }

                        // add biometry record
                        biometryTable = addBiometryToPDFTable(biometryTable,sTmpDate,sTmpWeight,sTmpHeight,sTmpSkull,sTmpArm,sTmpFood);
                    }
                }

                // add table to transaction
                if(biometryTable.size() > 0){
                    cell = new PdfPCell(biometryTable);
                    cell.setPadding(3);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(innerBorderColor);
                    
                    tranTable.addCell(cell);
                }

                // add transaction to doc
                addTransactionToDoc();
                
                /*
                //*************************************************************
                //***** GROWTH CHARTS *****************************************
                //*************************************************************
                float iAgeInYears = MedwanQuery.getInstance().getAgeDecimal(Integer.parseInt(patient.personid));
                double iAgeInMonths = iAgeInYears * 12.0;

                if(iAgeInMonths >= 0 && iAgeInMonths <= 12){
                    tranTable.addCell(createContentCell(getGrowthGraphs0To1Year()));
                    addTransactionToDoc();
                }
                else if(iAgeInMonths > 12 && iAgeInMonths <= 60){
                    tranTable.addCell(createContentCell(getGrowthGraphs1To5Year()));
                    addTransactionToDoc();
                }
                else if(iAgeInMonths > 60 && iAgeInMonths <= 240){
                    tranTable.addCell(createContentCell(getGrowthGraphs5To20Year()));
                    addTransactionToDoc();
                }
                */                
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################

    //--- ADD BIOMETRY TO PDF TABLE ---------------------------------------------------------------
    private PdfPTable addBiometryToPDFTable(PdfPTable pdfTable, String sDate, String sWeight, String sHeight,
                                            String sSkull, String sArm, String sFood){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.common.date"),1));
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.weight"),1));
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.healthrecord.biometry.length"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","skull"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","arm.circumference"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","food"),2));
        }

        pdfTable.addCell(createValueCell(sDate,1));
        pdfTable.addCell(createValueCell(sWeight,1));
        pdfTable.addCell(createValueCell(sHeight,1));
        pdfTable.addCell(createValueCell(sSkull,1));
        pdfTable.addCell(createValueCell(sArm,1));
        pdfTable.addCell(createValueCell(getTran("biometry_food",sFood),2));

        return pdfTable;
    }

    //#############################################################################################
    //### GROWTH GRAPHS ###########################################################################
    //#############################################################################################

    //--- GET DATA SET ----------------------------------------------------------------------------
    public XYSeriesCollection getDataSet(int displayGender,String sourceFileName){
        XYSeriesCollection result = new XYSeriesCollection();

        try {
            XYSeries s3  = new XYSeries("P3",true,false),
                     s5  = new XYSeries("P5",true,false),
                     s25 = new XYSeries("P25",true,false),
                     s50 = new XYSeries("P50",true,false),
                     s75 = new XYSeries("P75",true,false),
                     s95 = new XYSeries("P95",true,false),
                     s97 = new XYSeries("P97",true,false);

            String fullFilePath = MedwanQuery.getInstance().getConfigString("templateSource")+"/growthchartdata/"+sourceFileName;
            Debug.println("Growthgraph : reading file '"+fullFilePath+"' ..");
            BufferedReader in = new BufferedReader(new InputStreamReader(new URL(fullFilePath).openStream()));
            String data = in.readLine(); // ignore first line = header
            data = in.readLine();

            float age, p3, p5, p25, p50, p75, p95, p97;
            while (data != null) {
                int sex = Integer.parseInt(data.substring(0,1).trim()); // part after comma is ignored to obain integer ages ! (60 ipv 60.5)

                if(sex == displayGender) {
                    age = Float.parseFloat(data.substring(4,7).trim().replaceAll(",","."));

                    p3 = Float.parseFloat(data.substring(40,48).trim().replaceAll(",","."));    s3.add(age,p3);
                    p5 = Float.parseFloat(data.substring(49,57).trim().replaceAll(",","."));    s5.add(age,p5);
                    p25 = Float.parseFloat(data.substring(67,75).trim().replaceAll(",","."));   s25.add(age,p25);
                    p50 = Float.parseFloat(data.substring(76,84).trim().replaceAll(",","."));   s50.add(age,p50);
                    p75 = Float.parseFloat(data.substring(85,93).trim().replaceAll(",","."));   s75.add(age,p75);
                    p95 = Float.parseFloat(data.substring(103,111).trim().replaceAll(",",".")); s95.add(age,p95);
                    p97 = Float.parseFloat(data.substring(112).trim().replaceAll(",","."));     s97.add(age,p97);
                }

                data = in.readLine();
            }

            // add series to result
            result.addSeries(s3);
            result.addSeries(s5);
            result.addSeries(s25);
            result.addSeries(s50);
            result.addSeries(s75);
            result.addSeries(s95);
            result.addSeries(s97);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return result;
    }

    //--- CREATE CHART ----------------------------------------------------------------------------
    protected JFreeChart createChart(XYDataset dataset, String subtitle, String yTitle) {
        JFreeChart chart = ChartFactory.createXYLineChart(
            null,
            getTran("web","ageInMonth"),
            yTitle,
            dataset,
            PlotOrientation.VERTICAL,
            false,
            true,
            false
        );
                                         
        // gender to use in title
        String sGender = checkString(req.getParameter("gender"));
        String sGenderTran;
        if(sGender.equalsIgnoreCase("m")) sGenderTran = getTran("web","boy");
        else                              sGenderTran = getTran("web","girl");

        // add titles
        TextTitle t1 = new TextTitle(getTran("web","growthChart"),new java.awt.Font("SansSerif",Font.BOLD,15));
        TextTitle t2 = new TextTitle(subtitle+" : "+sGenderTran,new java.awt.Font("SansSerif",Font.NORMAL,12));
        chart.addSubtitle(t1);
        chart.addSubtitle(t2);

        // setup axises
        XYPlot plot = chart.getXYPlot();

        // y
        NumberAxis domainAxis = (NumberAxis)plot.getDomainAxis();
        domainAxis.setUpperMargin(0.30);
        domainAxis.setLowerMargin(0.30);
        domainAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());
        domainAxis.setAutoRangeIncludesZero(false);

        // x
        NumberAxis rangeAxis = (NumberAxis)plot.getRangeAxis();
        domainAxis.setUpperMargin(0.08);
        domainAxis.setLowerMargin(0.01);
        rangeAxis.setAutoRangeIncludesZero(false);

        return chart;
    }

    //--- GET PATIENT HEIGHT FOR AGE --------------------------------------------------------------
    protected double getPatientHeightForAge(int ageInMonths){
        // init on first call
        if(patientHeights==null){
            patientHeights = loadPatientHeights();
        }

        double height = 0;
        try{
            height = Double.parseDouble((String)patientHeights.get(""+ageInMonths));
        }
        catch(Exception e){
            // empty
        }

        return height;
    }

    //--- GET PATIENT WEIGHT FOR AGE --------------------------------------------------------------
    protected double getPatientWeightForAge(int ageInMonths){
        // init on first call
        if(patientWeights==null){
            patientWeights = loadPatientWeights();
        }

        double weight = 0;
        try{
            weight = Double.parseDouble((String)patientWeights.get(""+ageInMonths));
        }
        catch(Exception e){
            // empty
        }

        return weight;
    }

    //--- GET PATIENT SKULL CIRCUMFERENCE FOR AGE -------------------------------------------------
    protected double getPatientSkullCircumferenceForAge(int ageInMonths){
        // init on first call
        if(patientSkullCircumferences==null){
            patientSkullCircumferences = loadPatientSkullCircumferences();
        }

        double circumference = 0;
        try{
            circumference = Double.parseDouble((String)patientSkullCircumferences.get(""+ageInMonths));
        }
        catch(Exception e){
            // empty
        }

        return circumference;
    }

    //--- LOAD PATIENT HEIGHTS --------------------------------------------------------------------
    // run thru all biometry examinations in this persons healthrecord,
    // extracting all height-data and the belonging dates.
    //---------------------------------------------------------------------------------------------
    protected Hashtable loadPatientHeights(){
        String tranType = IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY";
        Vector allBiometryTrans = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(patient.personid),tranType);
        Hashtable patientHeights = new Hashtable();

        try{
            TransactionVO tran;
            for(int i=0; i<allBiometryTrans.size(); i++){
                tran = (TransactionVO)allBiometryTrans.get(i);
                patientHeights = extractBiometricValuesFromTransaction("HEIGHT",tran,patientHeights);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        return patientHeights;
    }

    //--- LOAD PATIENT WEIGHTS --------------------------------------------------------------------
    // run thru all biometry examinations in this persons healthrecord,
    // extracting all weight-data and the belonging dates.
    //---------------------------------------------------------------------------------------------
    protected Hashtable loadPatientWeights(){
        String tranType = IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY";
        Vector allBiometryTrans = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(patient.personid),tranType);
        Hashtable patientWeights = new Hashtable();

        try{
            TransactionVO tran;
            for(int i=0; i<allBiometryTrans.size(); i++){
                tran = (TransactionVO)allBiometryTrans.get(i);
                patientWeights = extractBiometricValuesFromTransaction("WEIGHT",tran,patientWeights);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return patientWeights;
    }

    //--- LOAD PATIENT SKULL CIRCUMFERENCES -------------------------------------------------------
    // run thru all biometry examinations in this persons healthrecord,
    // extracting all skull-data and the belonging dates.
    //---------------------------------------------------------------------------------------------
    protected Hashtable loadPatientSkullCircumferences(){
        String tranType = IConstants_PREFIX+"TRANSACTION_TYPE_BIOMETRY";
        Vector allBiometryTrans = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(patient.personid),tranType);
        Hashtable patientSkullCircumferences = new Hashtable();

        try{
            TransactionVO tran;
            for(int i=0; i<allBiometryTrans.size(); i++){
                tran = (TransactionVO)allBiometryTrans.get(i);
                patientSkullCircumferences = extractBiometricValuesFromTransaction("SKULL",tran,patientSkullCircumferences);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return patientSkullCircumferences;
    }

    //--- EXTRACT BIOMETRIC VALUES FROM TRANSACTION -----------------------------------------------
    // heights are stored in a tokenized string, extract the height value and the according date.
    // Hashtable-key is the patients "age in months" at the time the value was registered.
    //---------------------------------------------------------------------------------------------
    private Hashtable extractBiometricValuesFromTransaction(String valueType, TransactionVO tran, Hashtable biometricValues) throws Exception {
        StringBuffer sBioValues = new StringBuffer();
        sBioValues.append(getItemType(tran.getItems(),IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER1"));
        sBioValues.append(getItemType(tran.getItems(),IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER2"));
        sBioValues.append(getItemType(tran.getItems(),IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER3"));
        sBioValues.append(getItemType(tran.getItems(),IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER4"));
        sBioValues.append(getItemType(tran.getItems(),IConstants_PREFIX+"ITEM_TYPE_BIOMETRY_PARAMETER5"));

        if(sBioValues.indexOf("£")>-1){
            StringBuffer sTmpBio = sBioValues;
            String sTmpDate, sTmpHeight, sTmpWeight, sTmpSkull;

            while (sTmpBio.toString().toLowerCase().indexOf("$")>-1) {
                // date
                sTmpDate = "";
                if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDate = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // weight
                sTmpWeight = "";
                if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpWeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£")); 
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // height
                sTmpHeight = "";
                if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // skull
                sTmpSkull = "";
                if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSkull = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // (skip) arm
                if(sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // (skip) food
                if(sTmpBio.toString().toLowerCase().indexOf("$")>-1){
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("$")+1));
                }

                // calculate patient's age in months at the given date
                java.util.Date regDate   = new SimpleDateFormat("dd/MM/yyyy").parse(sTmpDate),
                               birthDate = new SimpleDateFormat("dd/MM/yyyy").parse(patient.dateOfBirth);

                float iAgeInYears = MedwanQuery.getInstance().getNrYears(birthDate,regDate);
                double iAgeInMonths = iAgeInYears * 12.0;

                     if(valueType.equals("HEIGHT")) biometricValues.put(""+(int)iAgeInMonths,sTmpHeight);
                else if(valueType.equals("WEIGHT")) biometricValues.put(""+(int)iAgeInMonths,sTmpWeight);
                else if(valueType.equals("SKULL"))  biometricValues.put(""+(int)iAgeInMonths,sTmpSkull);
            }
        }

        return biometricValues;
    }

    //--- GET ITEM TYPE ---------------------------------------------------------------------------
    public String getItemType(Collection collection, String sItemType){
        String sText = "";
        ItemVO item;
        Object[] aItems = collection.toArray();
        int i, y;

        for(i=1; i<6; i++){
            for(y=0; y<aItems.length; y++){
                item = (ItemVO)aItems[y];
                if(item.getType().toLowerCase().equals(sItemType.toLowerCase() + i)){
                    sText+= checkString(item.getValue());
                }
            }
        }

        if(sText.trim().length() == 0){
            for(y=0; y<aItems.length; y++){
                item = (ItemVO)aItems[y];
                if(item.getType().toLowerCase().equals(sItemType.toLowerCase())){
                    sText+= checkString(item.getValue());
                }
            }
        }

        return sText;
    }

    //--- ADD ANNOTATION --------------------------------------------------------------------------
    protected void addAnnotation(String label, java.awt.Font font, XYPlot plot, double xPos, double yPos){                
        XYTextAnnotation annotation = new XYTextAnnotation(label,xPos,yPos);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        plot.addAnnotation(annotation);
    }
    
    
    //-----------------------------------------------------------------------------------------------------------------
    //--- GET GROWTH GRAPHS 0 TO 1 YEAR -------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------------------
    protected PdfPTable getGrowthGraphs0To1Year() throws Exception {
        PdfPTable growthTable = new PdfPTable(1);
        growthTable.setWidthPercentage(100);

        //*** height graph ****************************************************
        ByteArrayOutputStream osHeight = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHeight,getHeightGraph0To1Year(),680,350);

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
        ChartUtilities.writeChartAsPNG(osWeight,getWeightGraph0To1Year(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.itextpdf.text.Image.getInstance(osWeight.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        // spacer
        growthTable.addCell(createBorderlessCell("",30,1));

        //*** skull graph *****************************************************
        ByteArrayOutputStream osSkull = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osSkull,getSkullGraph0To1Year(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.itextpdf.text.Image.getInstance(osSkull.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        return growthTable;
    }

    //--- GET HEIGHT GRAPH 0 TO 1 YEAR ------------------------------------------------------------
    private JFreeChart getHeightGraph0To1Year() throws Exception {
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
        chart.setBackgroundPaint(Color.WHITE);

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

    //--- GET WEIGHT GRAPH 0 TO 1 YEAR ------------------------------------------------------------
    private JFreeChart getWeightGraph0To1Year() throws Exception {
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
        chart.setBackgroundPaint(Color.WHITE);

        // add annotations
        XYPlot plot = chart.getXYPlot();
        XYTextAnnotation annotation;
        java.awt.Font font = new java.awt.Font("SansSerif",Font.NORMAL,9);

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

    //--- GET SKULL GRAPH 0 TO 1 YEAR -------------------------------------------------------------
    private JFreeChart getSkullGraph0To1Year() throws Exception {
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
        chart.setBackgroundPaint(Color.WHITE);

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
    

    //---------------------------------------------------------------------------------------------
    //--- GET GROWTH GRAPHS 1 TO 5 YEAR -----------------------------------------------------------
    //---------------------------------------------------------------------------------------------
    protected PdfPTable getGrowthGraphs1To5Year() throws Exception {
        PdfPTable growthTable = new PdfPTable(1);
        growthTable.setWidthPercentage(100);

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
        ChartUtilities.writeChartAsPNG(osWeight,getWeightGraph1To5Year(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.itextpdf.text.Image.getInstance(osWeight.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        return growthTable;
    }

    //--- GET HEIGTH GRAPH 1 TO 5 YEAR ------------------------------------------------------------
    private JFreeChart getHeightGraph() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"height-age-01-05.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double height, lastPatientHeight = 0;
        float age;
        for(int i=12; i<60; i++){
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
        chart.setBackgroundPaint(Color.WHITE);

        // add annotations
        XYPlot plot = chart.getXYPlot();
        XYTextAnnotation annotation;
        java.awt.Font font = new java.awt.Font("SansSerif",Font.NORMAL,9);

        int xPosAnnotation = 61;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 101.20);
            addAnnotation("5th",font,plot,xPosAnnotation, 102.55);
            addAnnotation("25th",font,plot,xPosAnnotation,107.00);
            addAnnotation("50th",font,plot,xPosAnnotation,110.00);
            addAnnotation("75th",font,plot,xPosAnnotation,113.80);
            addAnnotation("95th",font,plot,xPosAnnotation,118.00);
            addAnnotation("97th",font,plot,xPosAnnotation,119.35);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 100.90);
            addAnnotation("5th",font,plot,xPosAnnotation, 102.55);
            addAnnotation("25th",font,plot,xPosAnnotation,107.00);
            addAnnotation("50th",font,plot,xPosAnnotation,110.00);
            addAnnotation("75th",font,plot,xPosAnnotation,112.90);
            addAnnotation("95th",font,plot,xPosAnnotation,117.70);
            addAnnotation("97th",font,plot,xPosAnnotation,119.30);
        }

        // patient annotation
        annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientHeight);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        annotation.setPaint(Color.BLUE);
        plot.addAnnotation(annotation);
        
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

    //--- GET WEIGTH GRAPH 1 TO 5 YEAR ------------------------------------------------------------
    private JFreeChart getWeightGraph1To5Year() throws Exception {
        // get dataset
        String sGender = checkString(req.getParameter("gender"));
        final XYSeriesCollection dataset = getDataSet((sGender.equalsIgnoreCase("m")?1:2),"weight-age-01-05.txt");

        // add patient data
        XYSeries patientSeries = new XYSeries("Patient",true,false);
        double weight, lastPatientWeight = 0;
        float age;
        for(int i=12; i<60; i++){
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
        chart.setBackgroundPaint(Color.WHITE);

        // add annotations
        XYPlot plot = chart.getXYPlot();
        XYTextAnnotation annotation;
        java.awt.Font font = new java.awt.Font("SansSerif",Font.NORMAL,9);

        int xPosAnnotation = 61;
        if(sGender.equalsIgnoreCase("m")){
            //*** male ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 14.30);
            addAnnotation("5th",font,plot,xPosAnnotation, 14.95);
            addAnnotation("25th",font,plot,xPosAnnotation,16.80);
            addAnnotation("50th",font,plot,xPosAnnotation,18.50);
            addAnnotation("75th",font,plot,xPosAnnotation,20.15);
            addAnnotation("95th",font,plot,xPosAnnotation,23.05);
            addAnnotation("97th",font,plot,xPosAnnotation,24.00);
        }
        else{
            //*** female ***
            addAnnotation("3rd",font,plot,xPosAnnotation, 14.10);
            addAnnotation("5th",font,plot,xPosAnnotation, 14.75);
            addAnnotation("25th",font,plot,xPosAnnotation,16.70);
            addAnnotation("50th",font,plot,xPosAnnotation,18.30);
            addAnnotation("75th",font,plot,xPosAnnotation,20.20);
            addAnnotation("95th",font,plot,xPosAnnotation,23.55);
            addAnnotation("97th",font,plot,xPosAnnotation,24.50);
        }
       
        // patient annotation
        annotation = new XYTextAnnotation("Patient",xPosAnnotation,lastPatientWeight);
        annotation.setFont(font);
        annotation.setTextAnchor(TextAnchor.HALF_ASCENT_LEFT);
        annotation.setPaint(Color.BLUE);
        plot.addAnnotation(annotation);

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

    
    //-----------------------------------------------------------------------------------------------------------------
    //--- GET GROWTH GRAPHS 5 TO 20 YEAR ------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------------------------
    protected PdfPTable getGrowthGraphs5To20Year() throws Exception {
        PdfPTable growthTable = new PdfPTable(1);
        growthTable.setWidthPercentage(100);

        //*** height graph ****************************************************
        ByteArrayOutputStream osHeight = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(osHeight,getHeightGraph5To20Year(),680,350);

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
        ChartUtilities.writeChartAsPNG(osWeight,getWeightGraph5To20Year(),680,350);

        // put image in cell
        cell = new PdfPCell();
        cell.setImage(com.itextpdf.text.Image.getInstance(osWeight.toByteArray()));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingRight(10);
        growthTable.addCell(cell);

        return growthTable;
    }

    //--- GET HEIGTH GRAPH 5 TO 20 YEAR -----------------------------------------------------------
    private JFreeChart getHeightGraph5To20Year() throws Exception {
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
        chart.setBackgroundPaint(Color.WHITE);

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

    //--- GET WEIGTH GRAPH 5 TO 20 YEAR -----------------------------------------------------------
    private JFreeChart getWeightGraph5To20Year() throws Exception {
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
        chart.setBackgroundPaint(Color.WHITE);

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