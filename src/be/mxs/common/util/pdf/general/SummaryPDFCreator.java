package be.mxs.common.util.pdf.general;

import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.pdf.general.oc.examinations.PDFVaccinationCard;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import java.io.ByteArrayOutputStream;
import java.util.Hashtable;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.awt.*;
import java.text.DecimalFormat;
import net.admin.AdminPerson;
import net.admin.User;
import javax.servlet.http.HttpServletRequest;

import org.jfree.chart.JFreeChart;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.labels.StandardCategoryItemLabelGenerator;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.renderer.category.LineAndShapeRenderer;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.CategoryPlot;

public class SummaryPDFCreator extends GeneralPDFCreator {
    protected int fontSizePercentage = MedwanQuery.getInstance().getConfigInt("fontSizePercentage",100);

    //--- CONSTRUCTOR ------------------------------------------------------------------------------
    public SummaryPDFCreator(SessionContainerWO sessionContainerWO, User user, AdminPerson patient, String sProject, String sProjectDir, String sPrintLanguage){
        super(sessionContainerWO, user, patient, sProject, sProjectDir, null, null, sPrintLanguage);
    }

    //--- GENERATE PDFDOCUMENT BYTES ---------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, int partsOfTransactionToPrint) throws DocumentException {
		ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter docWriter = null;
        this.req = req;
        sContextPath = req.getContextPath();

		try{
			docWriter = PdfWriter.getInstance(doc,baosPDF);

            //*** META TAGS ************************************************************************
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software for Hospital Management");
			doc.addTitle("Medical Record Data for "+patient.firstname+" "+patient.lastname);
			doc.addKeywords(patient.firstname+", "+patient.lastname);
            doc.setPageSize(PageSize.A4);

            //*** FOOTER ***************************************************************************
            PDFFooter footer = new PDFFooter("OpenClinic pdf engine (c)2007, MXS nv\n"+MedwanQuery.getInstance().getLabel("web.occup","medwan.common.patientrecord",sPrintLanguage)+" "+patient.firstname+" "+patient.lastname+"\n\n");
			docWriter.setPageEvent(footer);
            doc.open();

            //*** HEADER ***************************************************************************
            printDocumentHeader(req);

            //*** TITLE ****************************************************************************
            String title = getTran("web.userprofile","summary").toUpperCase();

            Paragraph par = new Paragraph(title,FontFactory.getFont(FontFactory.HELVETICA,12,Font.BOLD));
            par.setAlignment(Paragraph.ALIGN_CENTER);
            doc.add(par);

            //*** OTHER DOCUMENT ELEMENTS *********************************************************
            printAdminHeader(patient);
            //printKeyData(sessionContainerWO);
            printMedication(sessionContainerWO);
            printActiveDiagnosis(sessionContainerWO);
            printWarnings(sessionContainerWO);
            doc.add(new Paragraph(" "));

            //*** VACCINATION CARD ****************************************************************
            new PDFVaccinationCard().printCard(doc,sessionContainerWO,transactionVO,patient,req,sProject,sPrintLanguage,new Integer(partsOfTransactionToPrint));

            //*** TRANSACTIONS *********************************************************************
            printTransactions();
		}
		catch(DocumentException dex){
			baosPDF.reset();
			throw dex;
		}
        catch(Exception e){
            e.printStackTrace();
        }
		finally{
			if(doc != null) doc.close();
			if(docWriter != null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has " + baosPDF.size() + " bytes");
		}

		return baosPDF;
	}


    //#### PRIVATE METHODS #########################################################################

    //--- PRINT TRANSACTIONS -----------------------------------------------------------------------
    private void printTransactions() throws Exception {
        // audiometry
        transactionVO = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(patient.personid),IConstants_PREFIX+"TRANSACTION_TYPE_AUDIOMETRY");
        if(transactionVO!=null){
            transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(), transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFAudiometry",transactionVO,2);
        }

        // bloodpressure
        printBloodpressureGraph();

        // respiratory
        transactionVO = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(patient.personid),IConstants_PREFIX+"TRANSACTION_TYPE_RESP_FUNC_EX");
        if(transactionVO!=null){
            transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(), transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFRespiratoryFunctionExamination",transactionVO,2);
        }

        // MER
        transactionVO = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(patient.personid),IConstants_PREFIX+"TRANSACTION_TYPE_MER");
        if(transactionVO!=null){
            transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(), transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFMedicalExaminationReport",transactionVO,2);
        }
    }

    //--- PRINT BLOOD PRESSURE GRAPH ---------------------------------------------------------------
    private void printBloodpressureGraph(){
        String sSelect, sMinValue, sItemValue;
        int iMinValue, iItemValue;
        boolean drawWideGraph = false;
        int diastolicValueCount= 0, systolicValueCount = 0;
        Date dUpdate;

        try{
            //*** Diastolic BP values **************************************************************
            sSelect = "SELECT t.updateTime, i.value FROM Transactions t, Items i"+
                      " WHERE healthRecordId = ? AND i.transactionId = t.transactionId "+
                      "  AND i.type IN ('"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT', "+
                      "                 '"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT')"+
                      " ORDER BY t.updateTime ASC";

            Hashtable hDBPs = new Hashtable();
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue());
            ResultSet rs = ps.executeQuery();
            Date dateFirstDiastolicPressure = null;

            SortedSet ssDBP = new TreeSet();
            while(rs.next()){
                dUpdate = rs.getDate("updateTime");

                if(dateFirstDiastolicPressure==null){
                    dateFirstDiastolicPressure = dUpdate;
                }

                sItemValue = ScreenHelper.checkString(rs.getString("value"));
                if(sItemValue.indexOf(".") > -1){
                    sItemValue = sItemValue.substring(0,sItemValue.indexOf("."));
                }

                if(sItemValue.indexOf(",") > -1){
                    sItemValue = sItemValue.substring(0,sItemValue.indexOf(","));
                }

                sMinValue = ScreenHelper.checkString((String)hDBPs.get(dUpdate));
                if(sMinValue.length() > 0){
                    iItemValue = Integer.parseInt(sItemValue);
                    iMinValue = Integer.parseInt(sMinValue);

                    if(iItemValue < iMinValue){
                        hDBPs.put(dUpdate,sItemValue);
                        ssDBP.add(dUpdate);
                    }
                }
                else{
                    hDBPs.put(dUpdate,sItemValue);
                    ssDBP.add(dUpdate);
                }
            }
            rs.close();
            ps.close();

            //*** Systolic BP values ***************************************************************
            sSelect = "SELECT t.updateTime, i.value FROM Transactions t, Items i"+
                      " WHERE healthRecordId = ? AND i.transactionId = t.transactionId "+
                      "  AND i.type IN ('"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT', "+
                      "                 '"+IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT')"+
                      " ORDER BY t.updateTime ASC";

            Hashtable hSBPs = new Hashtable();
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue());
            rs = ps.executeQuery();
            Date dateFirstSystolicPressure = null;

            SortedSet ssSBP = new TreeSet();
            while(rs.next()){
                dUpdate = rs.getDate("updateTime");

                if(dateFirstSystolicPressure==null){
                    dateFirstSystolicPressure = dUpdate;
                }

                sItemValue = ScreenHelper.checkString(rs.getString("value"));
                if(sItemValue.indexOf(".") > -1){
                    sItemValue = sItemValue.substring(0,sItemValue.indexOf("."));
                }

                if(sItemValue.indexOf(",") > -1){
                    sItemValue = sItemValue.substring(0,sItemValue.indexOf(","));
                }

                sMinValue = ScreenHelper.checkString((String)hSBPs.get(dUpdate));
                if(sMinValue.length() > 0){
                    iItemValue = Integer.parseInt(sItemValue);
                    iMinValue = Integer.parseInt(sMinValue);

                    if(iItemValue < iMinValue){
                        hSBPs.put(dUpdate,sItemValue);
                        ssSBP.add(dUpdate);
                    }
                }
                else{
                    hSBPs.put(dUpdate,sItemValue);
                    ssSBP.add(dUpdate);
                }
            }
            rs.close();
            ps.close();
            oc_conn.close();

            //*** GRAPH ****************************************************************************
            if(hSBPs.size() > 0 || hDBPs.size() > 0){
                String sDBPTran = getTran("web.occup",IConstants_PREFIX+"item_type_recruitment_sce_dbp"),
                       sSBPTran = getTran("web.occup",IConstants_PREFIX+"item_type_recruitment_sce_sbp");

                // fill dataset
                DefaultCategoryDataset dataset = new DefaultCategoryDataset();
                java.util.Date pressureDate;
                double pressureValue;

                // diastolic pressure
                Iterator dbpIter = ssDBP.iterator();
                while(dbpIter.hasNext()){
                    diastolicValueCount++;
                    pressureDate  = (Date)dbpIter.next();
                    pressureValue = Double.parseDouble((String)hDBPs.get(pressureDate));
                    Debug.println("* DIA pressureValue ("+dateFormat.format(pressureDate)+") : "+pressureValue);
                    dataset.addValue(pressureValue,sDBPTran,dateFormat.format(pressureDate));
                }

                // systolic pressure
                Iterator sbpIter = ssSBP.iterator();
                while(sbpIter.hasNext()){
                    systolicValueCount++;
                    pressureDate  = (Date)sbpIter.next();
                    pressureValue = Double.parseDouble((String)hSBPs.get(pressureDate));
                    Debug.println("* SYS pressureValue ("+dateFormat.format(pressureDate)+") : "+pressureValue);
                    dataset.addValue(pressureValue,sSBPTran,dateFormat.format(pressureDate));
                }

                // create chart
                final JFreeChart chart = ChartFactory.createLineChart(
                    "",
                    "",
                    "mmHg", // range axis label
                    dataset,
                    PlotOrientation.VERTICAL,
                    false, // include legend
                    false, // tooltips
                    false // urls
                );

                // draw a small or a wide graph ?
                if(diastolicValueCount > systolicValueCount){
                    if(diastolicValueCount > 5) drawWideGraph = true;
                }
                else{
                    if(systolicValueCount > 5) drawWideGraph = true;
                }

                // values at graph-points
                CategoryPlot plot = chart.getCategoryPlot();
                LineAndShapeRenderer renderer = new LineAndShapeRenderer();
                renderer.setSeriesItemLabelGenerator(0,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0")));
                renderer.setSeriesItemLabelGenerator(1,new StandardCategoryItemLabelGenerator("{2}",new DecimalFormat("0")));
                renderer.setSeriesItemLabelsVisible(0,true);
                renderer.setSeriesItemLabelsVisible(1,true);
                plot.setRenderer(renderer);

                // fixed value range
                ValueAxis rangeAxis = plot.getRangeAxis();
                rangeAxis.setAutoRange(false);
                rangeAxis.setRange(25,300);
                rangeAxis.setTickLabelsVisible(true);
                rangeAxis.setAutoTickUnitSelection(true,false);

                // graph to image
                chart.setBackgroundPaint(java.awt.Color.WHITE);
                ByteArrayOutputStream os = new ByteArrayOutputStream();
                ChartUtilities.writeChartAsPNG(os,chart,(drawWideGraph?800:400),300);
                PdfPTable graphTable = new PdfPTable(1);

                // image
                PdfPCell cell = new PdfPCell();
                cell.setImage(Image.getInstance(os.toByteArray()));
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setPaddingTop(15);
                cell.setPaddingBottom(-10);
                cell.setPaddingLeft(10);
                cell.setPaddingRight(25);
                graphTable.addCell(cell);

                // legend
                Phrase phrase = new Phrase("-"+sSBPTran+"     ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,BaseColor.RED));
                phrase.add(new Chunk("-"+sDBPTran,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL,BaseColor.BLUE)));
                cell = new PdfPCell(phrase);
                cell.setPaddingBottom(10);
                cell.setBorder(PdfPCell.NO_BORDER);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
                graphTable.addCell(cell);

                //*** BLOODPRESSURE TABLE ***
                PdfPTable tParent = new PdfPTable(10);
                tParent.setWidthPercentage(100);

                // transaction date
                /*
                Date dateFirstPressure = null;
                if(dateFirstDiastolicPressure.before(dateFirstSystolicPressure)){
                    dateFirstPressure = dateFirstDiastolicPressure;
                }
                else{
                     dateFirstPressure = dateFirstSystolicPressure;
                }
                */

                cell = new PdfPCell(new Paragraph(dateFormat.format(new java.util.Date()),FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.ITALIC)));
                cell.setColspan(1);
                cell.setBorder(PdfPCell.BOX);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                tParent.addCell(cell);

                // transaction type
                cell = new PdfPCell(new Paragraph(getTran("web.occup","medwan.common.blood-pressure").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.ITALIC)));
                cell.setColspan(5);
                cell.setBorder(PdfPCell.BOX);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                tParent.addCell(cell);

                // transaction context
                cell = new PdfPCell();
                cell.setColspan(4);
                cell.setBorder(PdfPCell.BOX);
                cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                tParent.addCell(cell);

                // add graph + empty cell
                if(drawWideGraph){
                    tParent.addCell(createCell(new PdfPCell(graphTable),10,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }
                else{
                    tParent.addCell(createCell(new PdfPCell(graphTable),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                    tParent.addCell(createCell(new PdfPCell(),5,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }

                doc.add(new Paragraph(" "));
                addTableToDoc(tParent);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    //--- ADD TABLE TO DOC -------------------------------------------------------------------------
    // parameter-table has grey borders and is put in a surrounding table with black borders.
    //----------------------------------------------------------------------------------------------
    protected void addTableToDoc(PdfPTable table){
        try{
            PdfPTable outerTable = new PdfPTable(1);
            outerTable.setWidthPercentage(100);

            PdfPCell cell = new PdfPCell(table);
            cell.setBorder(PdfPCell.NO_BORDER);

            outerTable.addCell(cell);
            doc.add(outerTable);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- CREATE CELL ------------------------------------------------------------------------------
    protected PdfPCell createCell(PdfPCell childCell, int colspan, int alignment, int border){
        childCell.setColspan(colspan);
        childCell.setBorder(border);
        childCell.setHorizontalAlignment(alignment);
        childCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);

        return childCell;
    }

}