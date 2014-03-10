package be.mxs.common.util.pdf.official.oc.examinations;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.Font;
import java.util.Hashtable;
import java.util.Vector;
import java.util.Collection;
import java.text.SimpleDateFormat;
import java.io.*;
import java.net.URL;

import org.jfree.data.xy.XYSeriesCollection;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYDataset;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.annotations.XYTextAnnotation;
import org.jfree.chart.axis.NumberAxis;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.title.TextTitle;
import org.jfree.ui.TextAnchor;

/**
 * User: ssm
 * Date: 13-jul-2007
 */
public abstract class PDFOfficialGrowthGraph extends PDFOfficialBasic {
    protected Hashtable patientHeights, patientWeights, patientSkullCircumferences;
    protected int pageWidth = 100;

    //--- ADD HEADER ------------------------------------------------------------------------------
    protected void addHeader(){
        // empty                 
    }

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            tranTable.addCell(createContentCell(getGrowthGraphs()));
            addTransactionToDoc();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

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

                if (sex == displayGender) {
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
        catch (Exception e) {
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

        if (sBioValues.indexOf("£")>-1){
            StringBuffer sTmpBio = sBioValues;
            String sTmpDate, sTmpHeight, sTmpWeight, sTmpSkull;

            while (sTmpBio.toString().toLowerCase().indexOf("$")>-1) {
                // date
                sTmpDate = "";
                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDate = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // weight
                sTmpWeight = "";
                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpWeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£")); 
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // height
                sTmpHeight = "";
                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeight = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // skull
                sTmpSkull = "";
                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpSkull = sTmpBio.substring(0,sTmpBio.toString().toLowerCase().indexOf("£"));
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // (skip) arm
                if (sTmpBio.toString().toLowerCase().indexOf("£")>-1){
                    sTmpBio = new StringBuffer(sTmpBio.substring(sTmpBio.toString().toLowerCase().indexOf("£")+1));
                }

                // (skip) food
                if (sTmpBio.toString().toLowerCase().indexOf("$")>-1){
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

    //--- GET GROWTH GRAPHS -----------------------------------------------------------------------
    protected abstract PdfPTable getGrowthGraphs() throws Exception;

}
