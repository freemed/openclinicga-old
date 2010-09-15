package be.mxs.common.util.pdf.general;

import com.lowagie.text.pdf.*;
import com.lowagie.text.*;

import java.text.AttributedString;
import java.text.DecimalFormat;
import java.util.*;
import java.awt.Color;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import javax.servlet.http.HttpServletRequest;

import org.hnrw.report.Report_Identification;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.block.BlockBorder;
import org.jfree.chart.labels.PieSectionLabelGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.chart.title.LegendTitle;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DefaultPieDataset;
import org.jfree.data.general.PieDataset;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.StatFunctions;
import be.openclinic.common.KeyValue;
import be.openclinic.finance.Prestation;
import be.openclinic.statistics.HospitalStats;
import net.admin.*;

public class PDFHospitalReportGenerator extends PDFOfficialBasic {
    Date begin;
    Date end;
    HashSet chapters;
    HospitalStats hospitalStats = null;
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;

    public void addHeader(){
    }
    public void addContent(){
    }
    
    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFHospitalReportGenerator(User user, String sProject, String sPrintLanguage, Date begin, Date end, HashSet chapters){
        this.user = user;
        this.sProject = sProject;
        this.sPrintLanguage = sPrintLanguage;
        this.begin=begin;
        this.end=end;
        this.chapters=chapters;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);

            doc.open();
            hospitalStats = new HospitalStats(begin,end);
            hospitalStats.loadEncounters("icd10");
            printReportHeader();
            if(chapters.contains("1") || chapters.contains("2")){
            	printBaseActivityInformation();
    	    	doc.newPage();
            }
            if(chapters.contains("3")){
		    	printPathologyProfile();
		    	doc.newPage();
            }
            if(chapters.contains("4")){
			    printComorbidityComortality();
		    	doc.newPage();
            }
            if(chapters.contains("5")){
		    	printHealthEconometrics();
		    	doc.newPage();
            }
            if(chapters.contains("6")){
		    	printInsuranceProfile();
		    	doc.newPage();
            }
        }
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			try{
				if(doc!=null) {
					if(baosPDF.size() < 1){
						doc.add(new Paragraph("The document has no pages"));
					}
					doc.close();
				}
	            if(docWriter!=null) docWriter.close();
			}
			catch(Exception e2){};
		}


		return baosPDF;
	}
    
    private void printInsuranceProfile(){
    	try{
			table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	cell=createBorderlessCell(ScreenHelper.getTranNoLink("hospital.statistics", "insurance.profile", sPrintLanguage), 5,100, 10);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	//Table
	    	KeyValue[] kv = hospitalStats.getInsuranceCases("admission");
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "insurar", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(70);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "admissions", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.admissions", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	for(int n=0;n<kv.length;n++){
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey(),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(70);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(new Double(kv[n].getValue()).intValue()+"",FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTA())+"%",FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "outpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	kv = hospitalStats.getInsuranceCases("visit");
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "insurar", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(70);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "visits", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.visits", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	for(int n=0;n<kv.length;n++){
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey(),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(70);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(new Double(kv[n].getValue()).intValue()+"",FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTV())+"%",FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	    	doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }

    private void printHealthEconometrics(){
    	try{
    		double redistributionfactor=1;
    		table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	cell=createBorderlessCell(ScreenHelper.getTranNoLink("hospital.statistics", "financial.profile", sPrintLanguage), 5,100, 10);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "total.income", sPrintLanguage), new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(hospitalStats.getTI())+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"", "", "");
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Table
	    	Hashtable deliveryIncomes = hospitalStats.getDeliveryincomes();
	    	KeyValue[] kv = StatFunctions.getTop(deliveryIncomes, deliveryIncomes.size());
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "delivery", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(70);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	for(int n=0;n<kv.length;n++){
	    		Prestation prestation = Prestation.getByCode(kv[n].getKey());
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey()+": "+prestation.getDescription(),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(70);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue()))+" "+MedwanQuery.getInstance().getConfigString("currency","EUR"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%",FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	cell=createPrestationFamilyPieChartCell(hospitalStats.getIDF(), "Fig 5.1 "+ScreenHelper.getTranNoLink("hospital.statistics", "income.per.delivery.family", sPrintLanguage));
	    	table.addCell(cell);
	    	cell=createPrestationPieChartCell(hospitalStats.getT10IDD(), "Fig 5.2 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.income.deliveries", sPrintLanguage));
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));

	    	//Table
	    	Hashtable departmentIncomes = hospitalStats.getTotalCostcenterIncomes();
	    	kv = StatFunctions.getTop(departmentIncomes, departmentIncomes.size());
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "costcenter", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(60);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(25);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	redistributionfactor = 1;
	    	for(int n=0;n<kv.length;n++){
	    		if(kv[n].getKey().trim().equalsIgnoreCase("") || kv[n].getKey().equalsIgnoreCase("?")){
	    			redistributionfactor=hospitalStats.getTI()/(hospitalStats.getTI()-Double.parseDouble(kv[n].getValue()));
	    			break;
	    		}
	    	}
	    	for(int n=0;n<kv.length;n++){
	    		String costcenter = ScreenHelper.getTranNoLink("costcenter", kv[n].getKey(), sPrintLanguage); 
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey()+(costcenter.equalsIgnoreCase(kv[n].getKey())?"":": "+costcenter),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(60);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue()))+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+(costcenter.equalsIgnoreCase(kv[n].getKey())?"":" ("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue())*redistributionfactor)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(25);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%"+(costcenter.equalsIgnoreCase(kv[n].getKey())?"":" ("+PERCENT_FORMAT.format(100*redistributionfactor*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%)"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	    	
	    	departmentIncomes = hospitalStats.getTotalDepartmentIncomes();
	    	kv = StatFunctions.getTop(departmentIncomes, departmentIncomes.size());
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "service", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(60);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(25);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	redistributionfactor = 1;
	    	for(int n=0;n<kv.length;n++){
	    		if(kv[n].getKey().trim().equalsIgnoreCase("") || kv[n].getKey().equalsIgnoreCase("?")){
	    			redistributionfactor=hospitalStats.getTI()/(hospitalStats.getTI()-Double.parseDouble(kv[n].getValue()));
	    			break;
	    		}
	    	}
	    	for(int n=0;n<kv.length;n++){
	    		Service service = Service.getService(kv[n].getKey());
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey()+(service==null?"":": "+service.getLabel(sPrintLanguage)),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(60);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue()))+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+(service==null?"":" ("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue())*redistributionfactor)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(25);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%"+(service==null?"":" ("+PERCENT_FORMAT.format(100*redistributionfactor*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%)"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	
	    	table.addCell(createBorderlessCell(" ",100));
	    	cell=createServicePieChartCell(hospitalStats.getT10IDS(), "Fig 5.3 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.income.departments", sPrintLanguage));
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",50));
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);

	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "distribution.hospital.departments.admissions", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	String[] incomedepartments = hospitalStats.getIncomeDepartments("admission",2);
	    	for(int n=0;n<incomedepartments.length;n++){
	    		Service service = Service.getService(incomedepartments[n]);
	    		String label=incomedepartments[n]+(service!=null?": "+service.getLabel(sPrintLanguage):"?");
		    	//Graphs
		    	cell=createPrestationMoneyFamilyPieChartCell(hospitalStats.getIDFSA(incomedepartments[n],2), "Fig 5.4."+n+".1 "+ScreenHelper.getTranNoLink("hospital.statistics", "department.income.per.delivery.family.admission", sPrintLanguage)+" ("+label+")");
		    	table.addCell(cell);
		    	cell=createPrestationMoneyPieChartCell(hospitalStats.getT10IDDSA(incomedepartments[n],2), "Fig 5.4."+n+".2 "+ScreenHelper.getTranNoLink("hospital.statistics", "department.top10.income.deliveries.admission", sPrintLanguage)+" ("+label+")");
		    	table.addCell(cell);
	    		
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "distribution.hospital.departments.visits", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	incomedepartments = hospitalStats.getIncomeDepartments("visit",2);
	    	for(int n=0;n<incomedepartments.length;n++){
	    		Service service = Service.getService(incomedepartments[n]);
	    		String label=incomedepartments[n]+(service!=null?": "+service.getLabel(sPrintLanguage):"");
		    	//Graphs
		    	cell=createPrestationMoneyFamilyPieChartCell(hospitalStats.getIDFSV(incomedepartments[n],2), "Fig 5.5."+n+".1 "+ScreenHelper.getTranNoLink("hospital.statistics", "department.income.per.delivery.family.visit", sPrintLanguage)+" ("+label+")");
		    	table.addCell(cell);
		    	cell=createPrestationMoneyPieChartCell(hospitalStats.getT10IDDSV(incomedepartments[n],2), "Fig 5.5."+n+".2 "+ScreenHelper.getTranNoLink("hospital.statistics", "department.top10.income.deliveries.visit", sPrintLanguage)+" ("+label+")");
		    	table.addCell(cell);
	    		
	    	}
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "clinical.condition.linked.resource.consumption", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	//Table
	    	kv = hospitalStats.getDRC("admission",0);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "clinical.condition", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(60);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(25);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	redistributionfactor = 1;
	    	for(int n=0;n<kv.length;n++){
	    		if(kv[n].getKey().equalsIgnoreCase("?")){
	    			redistributionfactor=hospitalStats.getTI()/(hospitalStats.getTI()-Double.parseDouble(kv[n].getValue()));
	    			break;
	    		}
	    	}
	    	for(int n=0;n<kv.length;n++){
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey()+(kv[n].getKey().equalsIgnoreCase("?")?"":": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(60);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	int numberOfCases=hospitalStats.getAdmissionWithDeliveriesDiagnosisCount(kv[n].getKey());
		    	cell = new PdfPCell(new Paragraph(new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue()))+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue())*redistributionfactor)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")"+
		    			"\n"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue())/numberOfCases)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue())*redistributionfactor/numberOfCases)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")")),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(25);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%"+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+PERCENT_FORMAT.format(100*redistributionfactor*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%)"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));	    	
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "outpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	//Table
	    	kv = hospitalStats.getDRC("visit",0);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "clinical.condition", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(60);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(25);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "total.income", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	redistributionfactor = 1;
	    	for(int n=0;n<kv.length;n++){
	    		if(kv[n].getKey().equalsIgnoreCase("?")){
	    			redistributionfactor=hospitalStats.getTI()/(hospitalStats.getTI()-Double.parseDouble(kv[n].getValue()));
	    			break;
	    		}
	    	}
	    	for(int n=0;n<kv.length;n++){
	    		cell = new PdfPCell(new Paragraph(kv[n].getKey()+(kv[n].getKey().equalsIgnoreCase("?")?"":": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(60);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue()))+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble(kv[n].getValue())*redistributionfactor)+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(25);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%"+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+PERCENT_FORMAT.format(100*redistributionfactor*Double.parseDouble(kv[n].getValue())/hospitalStats.getTI())+"%)"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));	    	
	    	//Graphs
	    	cell=createKPGSMoneyPieChartCell(hospitalStats.getT10DRA(), "Fig 5.6 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.resource.consuming.clinical.conditions.admissions", sPrintLanguage));
	    	table.addCell(cell);
	    	cell=createKPGSMoneyPieChartCell(hospitalStats.getT10DRV(), "Fig 5.7 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.resource.consuming.clinical.conditions.visits", sPrintLanguage));
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "top10.deliveries.for.top10.resource.consuming.kpgs", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	KeyValue[] kpgs=hospitalStats.getT10DRA();
	    	int counter=0;
	    	for(int n=0;n<kpgs.length;n++){
	    		if(!"?".equalsIgnoreCase(kpgs[n].getKey())){
	    			counter++;
	    			cell=createPrestationMoneyPieChartCell(hospitalStats.getT10DRAD(kpgs[n].getKey()), "Fig 5.8."+n+" "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.deliveries.for.kpgs", sPrintLanguage)+" ("+kpgs[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kpgs[n].getKey(), sPrintLanguage)+")");
			    	table.addCell(cell);
	    		}
	    	}
	    	if(counter%2!=0){
		    	table.addCell(createBorderlessCell(" ",50));
	    	}
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "outpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	kpgs=hospitalStats.getT10DRA();
	    	counter=0;
	    	for(int n=0;n<kpgs.length;n++){
	    		if(!"?".equalsIgnoreCase(kpgs[n].getKey())){
	    			counter++;
	    			cell=createPrestationMoneyPieChartCell(hospitalStats.getT10DRAD(kpgs[n].getKey()), "Fig 5.9."+n+" "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.deliveries.for.kpgs", sPrintLanguage)+" ("+kpgs[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kpgs[n].getKey(), sPrintLanguage)+")");
			    	table.addCell(cell);
	    		}
	    	}
	    	if(counter%2!=0){
		    	table.addCell(createBorderlessCell(" ",50));
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "weekly.income.evolution", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	cell=createLineChartCell(hospitalStats.getWI(),
	    			"Fig 5.10 "+ScreenHelper.getTranNoLink("hospital.statistics", "weekly.evolution.of.income", sPrintLanguage), //Title
	    			ScreenHelper.getTranNoLink("hospital.statistics", "week", sPrintLanguage), //XLabel
	    			ScreenHelper.getTranNoLink("hospital.statistics", "income", sPrintLanguage), //YLabel
	    			true); //regression
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",50));
	    	doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }

    private void printComorbidityComortality(){
       	try{
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	cell=createBorderlessCell("\n"+ScreenHelper.getTranNoLink("hospital.statistics", "comorbidity.profile", sPrintLanguage), 5,100, 10);
	    	table.addCell(cell);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.comorbidity.profiles", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	KeyValue[] kv = hospitalStats.getT10FCCA();
	    	int counter=0;
	    	for(int n=0;n<kv.length;n++){
	    		if(!"?".equalsIgnoreCase(kv[n].getKey())){
	    			counter++;
			    	cell=createKPGSBarChartCell(hospitalStats.getACP(kv[n].getKey()), "Fig 4.1."+counter+" "+kv[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)+ " (index: "+TWODIGIT_FORMAT.format(hospitalStats.getACPI(kv[n].getKey()))+")",
			    			ScreenHelper.getTranNoLink("hospital.statistics", "kpgs.code", sPrintLanguage),
			    			"% "+ScreenHelper.getTranNoLink("hospital.statistics", "association", sPrintLanguage));
			    	table.addCell(cell);
	    		}
	    	}
	    	if(counter%2!=0){
		    	table.addCell(createBorderlessCell(" ",50));
	    	}
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);

	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.weighed.comorbidity.profiles", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	kv = hospitalStats.getT10FCCA();
	    	counter=0;
	    	for(int n=0;n<kv.length;n++){
	    		if(!"?".equalsIgnoreCase(kv[n].getKey())){
	    			counter++;
			    	cell=createKPGSBarChartCell(hospitalStats.getACPW(kv[n].getKey()), "Fig 4.2."+counter+" "+kv[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)+ " (index: "+TWODIGIT_FORMAT.format(hospitalStats.getACPIW(kv[n].getKey()))+")",
			    			ScreenHelper.getTranNoLink("hospital.statistics", "kpgs.code", sPrintLanguage),
			    			ScreenHelper.getTranNoLink("hospital.statistics", "association.index", sPrintLanguage));
			    	table.addCell(cell);
	    		}
	    	}
	    	if(counter%2!=0){
		    	table.addCell(createBorderlessCell(" ",50));
	    	}
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);

	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.comortality.profiles", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	kv = hospitalStats.getT10FCCA();
	    	counter=0;
	    	for(int n=0;n<kv.length;n++){
	    		if(!"?".equalsIgnoreCase(kv[n].getKey())){
	    			counter++;
			    	cell=createKPGSBarChartCell(hospitalStats.getACMP(kv[n].getKey()), "Fig 4.3."+counter+" "+kv[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)+ " (index: "+TWODIGIT_FORMAT.format(hospitalStats.getACMPI(kv[n].getKey()))+")",
			    			ScreenHelper.getTranNoLink("hospital.statistics", "kpgs.code", sPrintLanguage),
			    			"% "+ScreenHelper.getTranNoLink("hospital.statistics", "association", sPrintLanguage));
			    	table.addCell(cell);
	    		}
	    	}
	    	if(counter%2!=0){
		    	table.addCell(createBorderlessCell(" ",50));
	    	}
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);

	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.weighed.comortality.profiles", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	kv = hospitalStats.getT10FCCA();
	    	counter=0;
	    	for(int n=0;n<kv.length;n++){
	    		if(!"?".equalsIgnoreCase(kv[n].getKey())){
	    			counter++;
			    	cell=createKPGSBarChartCell(hospitalStats.getACMPW(kv[n].getKey()), "Fig 4.4."+counter+" "+kv[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)+ " (index: "+TWODIGIT_FORMAT.format(hospitalStats.getACMPIW(kv[n].getKey()))+")",
			    			ScreenHelper.getTranNoLink("hospital.statistics", "kpgs.code", sPrintLanguage),
			    			ScreenHelper.getTranNoLink("hospital.statistics", "association.index", sPrintLanguage));
			    	table.addCell(cell);
	    		}
	    	}
	    	if(counter%2!=0){
		    	table.addCell(createBorderlessCell(" ",50));
	    	}
	    	doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	
    }
    
    private void printPathologyProfile(){
    	try{
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	cell=createBorderlessCell("\n"+ScreenHelper.getTranNoLink("hospital.statistics", "pathology.profile", sPrintLanguage), 5,100, 10);
	    	table.addCell(cell);
	        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Table
	    	Hashtable admissionDiagnosisFrequencies = hospitalStats.getAdmissiondiagnosisfrequencies();
	    	KeyValue[] kv = StatFunctions.getTop(admissionDiagnosisFrequencies, admissionDiagnosisFrequencies.size());
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "clinical.condition", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(70);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("# "+ScreenHelper.getTranNoLink("hospital.statistics", "admissions", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "admissions", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(15);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	double redistributionfactor = 1;
	    	for(int n=0;n<kv.length;n++){
	    		if(kv[n].getKey().equalsIgnoreCase("?")){
	    			redistributionfactor=hospitalStats.getTA()/(hospitalStats.getTA()-Double.parseDouble(kv[n].getValue()));
	    			break;
	    		}
	    	}
	    	for(int n=0;n<kv.length;n++){
		    	cell = new PdfPCell(new Paragraph(kv[n].getKey()+(kv[n].getKey().equalsIgnoreCase("?")?"":": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(70);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(kv[n].getValue()+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+new Double(Double.parseDouble(kv[n].getValue())*redistributionfactor).intValue()+")"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTA())+"%"+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+PERCENT_FORMAT.format(100*redistributionfactor*Double.parseDouble(kv[n].getValue())/hospitalStats.getTA())+"%)"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(15);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	cell=createKPGSPieChartCell(hospitalStats.getT10FCCA(), "Fig 3.1.1 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.admissions.admissions", sPrintLanguage));
	    	table.addCell(cell);
	    	cell=createKPGSPieChartCell(hospitalStats.getT10PFCCA(), "Fig 3.1.2 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.admissions.patients", sPrintLanguage));
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	cell=createKPGSPieChartCell2(hospitalStats.getT10ADA(), "Fig 3.1.3 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.mortal.kpgs.global.mortality", sPrintLanguage),hospitalStats.getAM());
	    	table.addCell(cell);
	    	cell=createKPGSPieChartCell3(hospitalStats.getT10ADAR(), "Fig 3.1.4 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.per.kpgs.mortality", sPrintLanguage));
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	doc.add(table);
	    	doc.newPage();
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "outpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
	        cell.setPaddingTop(5);
	        cell.setColspan(100);
	        cell.setBorder(Cell.NO_BORDER);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	    	table.addCell(cell);
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Table
	    	Hashtable visitDiagnosisFrequencies = hospitalStats.getVisitdiagnosisfrequencies();
	    	kv = StatFunctions.getTop(visitDiagnosisFrequencies, visitDiagnosisFrequencies.size());
	    	cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "clinical.condition", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(80);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("# "+ScreenHelper.getTranNoLink("hospital.statistics", "visits", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(10);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	cell = new PdfPCell(new Paragraph("% "+ScreenHelper.getTranNoLink("hospital.statistics", "visits", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
	        cell.setPaddingTop(5);
	        cell.setColspan(10);
	        cell.setBorder(Cell.BOX);
	        cell.setBorderColor(innerBorderColor);
	        cell.setVerticalAlignment(Cell.ALIGN_TOP);
	        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
	        cell.setBackgroundColor(Color.LIGHT_GRAY);
	    	table.addCell(cell);
	    	redistributionfactor = 1;
	    	for(int n=0;n<kv.length;n++){
	    		if(kv[n].getKey().equalsIgnoreCase("?")){
	    			redistributionfactor=hospitalStats.getTV()/(hospitalStats.getTV()-Double.parseDouble(kv[n].getValue()));
	    			break;
	    		}
	    	}
	    	for(int n=0;n<kv.length;n++){
		    	cell = new PdfPCell(new Paragraph(kv[n].getKey()+(kv[n].getKey().equalsIgnoreCase("?")?"":": "+MedwanQuery.getInstance().getCodeTran("icd10code"+kv[n].getKey(), sPrintLanguage)),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(80);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(kv[n].getValue()+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+new Double(Double.parseDouble(kv[n].getValue())*redistributionfactor).intValue()+")"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(10);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	cell = new PdfPCell(new Paragraph(PERCENT_FORMAT.format(100*Double.parseDouble(kv[n].getValue())/hospitalStats.getTV())+"%"+(kv[n].getKey().equalsIgnoreCase("?")?"":" ("+PERCENT_FORMAT.format(100*redistributionfactor*Double.parseDouble(kv[n].getValue())/hospitalStats.getTV())+"%)"),FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
		        cell.setPaddingTop(5);
		        cell.setColspan(10);
		        cell.setBorder(Cell.BOX);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
	    	}
	    	table.addCell(createBorderlessCell(" ",100));
	    	//Graphs
	    	cell=createKPGSPieChartCell(hospitalStats.getT10FCCV(), "Fig 3.2.1 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.visits.visits", sPrintLanguage));
	    	table.addCell(cell);
	    	cell=createKPGSPieChartCell(hospitalStats.getT10PFCCV(), "Fig 3.2.2 "+ScreenHelper.getTranNoLink("hospital.statistics", "top10.most.frequent.kpgs.visits.patients", sPrintLanguage));
	    	table.addCell(cell);
	    	doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    
    private void printBaseActivityInformation(){
    	try{
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	if(chapters.contains("1")){
		    	cell=createBorderlessCell("\n"+ScreenHelper.getTranNoLink("hospital.statistics", "base.activity.information", sPrintLanguage), 5,100, 10);
		    	table.addCell(cell);
		    	cell=createBorderlessCell(ScreenHelper.getTranNoLink("hospital.statistics", "period", sPrintLanguage), 5,20, 8);
		    	table.addCell(cell);
		    	cell=createBorderlessCell(DATE_FORMAT.format(begin)+" - "+DATE_FORMAT.format(end), 5,80, 8);
		    	table.addCell(cell);
		        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
		        cell.setPaddingTop(5);
		        cell.setColspan(50);
		        cell.setBorder(Cell.NO_BORDER);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "outpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
		        cell.setPaddingTop(5);
		        cell.setColspan(50);
		        cell.setBorder(Cell.NO_BORDER);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "total.inpatients", sPrintLanguage), hospitalStats.getTPA()+"", ScreenHelper.getTranNoLink("hospital.statistics", "total.outpatients", sPrintLanguage), hospitalStats.getTPV()+"");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "total.admissions", sPrintLanguage), hospitalStats.getTA()+"", ScreenHelper.getTranNoLink("hospital.statistics", "total.visits", sPrintLanguage), hospitalStats.getTV()+"");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "total.new.admissions", sPrintLanguage), hospitalStats.getTAN()+"", "","");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "total.admission.days", sPrintLanguage), hospitalStats.getTDA()+"", "", "");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "average.admission.days", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getTDA()/(double)hospitalStats.getTA())+"", "", "");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "median.admission.days", sPrintLanguage), hospitalStats.getMDA()+"", "", "");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "average.admission.days.per.patient", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getTDA()/(double)hospitalStats.getTPA())+"", "", "");
	    	}
	    	if(chapters.contains("2")){
		    	cell=createBorderlessCell("\n"+ScreenHelper.getTranNoLink("hospital.statistics", "base.outcome.information", sPrintLanguage), 5,100, 10);
		    	table.addCell(cell);
		        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "inpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
		        cell.setPaddingTop(5);
		        cell.setColspan(50);
		        cell.setBorder(Cell.NO_BORDER);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		        cell = new PdfPCell(new Paragraph(ScreenHelper.getTranNoLink("hospital.statistics", "outpatients", sPrintLanguage),FontFactory.getFont(FontFactory.HELVETICA,8,Font.UNDERLINE)));
		        cell.setPaddingTop(5);
		        cell.setColspan(50);
		        cell.setBorder(Cell.NO_BORDER);
		        cell.setBorderColor(innerBorderColor);
		        cell.setVerticalAlignment(Cell.ALIGN_TOP);
		        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
		    	table.addCell(cell);
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "6.months.readmission", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getRA6()*100/(double)hospitalStats.getTA())+"%", ScreenHelper.getTranNoLink("hospital.statistics", "6.months.revisit", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getRV6()*100/(double)hospitalStats.getTV())+"%");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "12.months.readmission", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getRA12()*100/(double)hospitalStats.getTA())+"%", ScreenHelper.getTranNoLink("hospital.statistics", "12.months.revisit", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getRV12()*100/(double)hospitalStats.getTV())+"%");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "period.readmission", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getRAP()*100/(double)hospitalStats.getTA())+"%", ScreenHelper.getTranNoLink("hospital.statistics", "period.revisit", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getRVP()*100/(double)hospitalStats.getTV())+"%");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "absolute.mortality", sPrintLanguage), hospitalStats.getAM()+"", "", "");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "relative.mortality", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getAM()*100/(double)hospitalStats.getTPA())+"%", "", "");
		    	printBaseActivityLine(ScreenHelper.getTranNoLink("hospital.statistics", "relative.admission.mortality", sPrintLanguage), PERCENT_FORMAT.format((double)hospitalStats.getAM()*100/(double)hospitalStats.getTA())+"%", "", "");
		    	table.addCell(createBorderlessCell(" ",100));
		    	//Graphs
		    	cell=createLineChartCell(hospitalStats.getWA(),
		    			"Fig 2.1 "+ScreenHelper.getTranNoLink("hospital.statistics", "weekly.evolution.of.admissions", sPrintLanguage), //Title
		    			ScreenHelper.getTranNoLink("hospital.statistics", "week", sPrintLanguage), //XLabel
		    			"# "+ScreenHelper.getTranNoLink("hospital.statistics", "admissions", sPrintLanguage), //YLabel
		    			true); //regression
		    	table.addCell(cell);
		    	cell=createLineChartCell(hospitalStats.getWV(),
		    			"Fig 2.2 "+ScreenHelper.getTranNoLink("hospital.statistics", "weekly.evolution.of.visits", sPrintLanguage), //Title
		    			ScreenHelper.getTranNoLink("hospital.statistics", "week", sPrintLanguage), //XLabel
		    			"# "+ScreenHelper.getTranNoLink("hospital.statistics", "visits", sPrintLanguage), //YLabel
		    			true); //regression
		    	table.addCell(cell);
		    	cell=createLineChartCell(hospitalStats.getDAP(),
		    			"Fig 2.3 "+ScreenHelper.getTranNoLink("hospital.statistics", "daily.evolution.of.admitted.patients", sPrintLanguage), //Title
		    			ScreenHelper.getTranNoLink("hospital.statistics", "day", sPrintLanguage), //XLabel
		    			"# "+ScreenHelper.getTranNoLink("hospital.statistics", "patients", sPrintLanguage), //YLabel
		    			true); //regression
		    	table.addCell(cell);
		    	cell=createLineChartCell(hospitalStats.getWD(),
		    			"Fig 2.4 "+ScreenHelper.getTranNoLink("hospital.statistics", "weekly.evolution.of.deaths", sPrintLanguage), //Title
		    			ScreenHelper.getTranNoLink("hospital.statistics", "week", sPrintLanguage), //XLabel
		    			"# "+ScreenHelper.getTranNoLink("hospital.statistics", "deaths", sPrintLanguage), //YLabel
		    			true); //regression
		    	table.addCell(cell);
	    	}
	    	doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }

    private PdfPCell createKPGSBarChartCell(KeyValue[] values,String title,String xlabel,String ylabel) throws IOException, BadElementException{
    	DefaultCategoryDataset dataset = new DefaultCategoryDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.addValue(new Double(values[n].getValue()).doubleValue(), values[n].getKey()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+values[n].getKey(), sPrintLanguage)+"                                                                           ", "");
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createBarChart(
            title, // chart title
            xlabel, // domain axis label
            ylabel, // range axis label
            dataset, // data
            PlotOrientation.VERTICAL, // orientation
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(Color.WHITE);
        plot.setRangeGridlinePaint(Color.GRAY);
        plot.setDomainGridlinePaint(Color.GRAY);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.barchartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.barchartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createBarChartCell(KeyValue[] values,String title,String xlabel,String ylabel) throws IOException, BadElementException{
    	DefaultCategoryDataset dataset = new DefaultCategoryDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.addValue(new Double(values[n].getValue()).doubleValue(), values[n].getKey()+"                                                                           ", "");
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createBarChart(
            title, // chart title
            xlabel, // domain axis label
            ylabel, // range axis label
            dataset, // data
            PlotOrientation.VERTICAL, // orientation
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(Color.WHITE);
        plot.setRangeGridlinePaint(Color.GRAY);
        plot.setDomainGridlinePaint(Color.GRAY);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.barchartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.barchartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createPrestationFamilyPieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new SimpleLegendGenerator());
        plot.setLabelGenerator(new PercentLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createPrestationMoneyFamilyPieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new SimpleLegendGenerator());
        plot.setLabelGenerator(new KPGSMoneyLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createPrestationMoneyPieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new PrestationLegendGenerator());
        plot.setLabelGenerator(new KPGSMoneyLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createPrestationPieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new PrestationLegendGenerator());
        plot.setLabelGenerator(new PercentLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createServicePieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new ServiceLegendGenerator());
        plot.setLabelGenerator(new PercentLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createKPGSMoneyPieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
	    plot.setLegendLabelGenerator(new KPGSLegendGenerator());
        plot.setLabelGenerator(new KPGSMoneyLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createKPGSPieChartCell(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new KPGSLegendGenerator());
        plot.setLabelGenerator(new KPGSLabelGenerator(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;

        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createKPGSPieChartCell2(KeyValue[] values,String title,double total) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new KPGSLegendGenerator());
        plot.setLabelGenerator(new KPGSLabelGenerator2(values,total));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createKPGSPieChartCell3(KeyValue[] values,String title) throws IOException, BadElementException{
    	DefaultPieDataset dataset = new DefaultPieDataset();
    	for(int n=0;n<values.length;n++){
    		dataset.setValue(values[n].getKey(), new Double(values[n].getValue()).doubleValue());
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createPieChart(
            title, // chart title
            dataset, // data
            true, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        PiePlot plot = (PiePlot)chart.getPlot();
        plot.setBackgroundPaint(Color.WHITE);
        if(values.length>0){
	        if(values[0].getKey().equalsIgnoreCase("?") && values.length>1){
	        	plot.setExplodePercent(values[1].getKey(), 0.2);
	        }
	        else {
	        	plot.setExplodePercent(values[0].getKey(), 0.2);
	        }
        }
        plot.setLegendLabelGenerator(new KPGSLegendGenerator());
        plot.setLabelGenerator(new KPGSLabelGenerator3(values));
        plot.setOutlineVisible(false);
        chart.setAntiAlias(true);
        LegendTitle legendTitle = (LegendTitle) chart.getSubtitle(0);
        legendTitle.setFrame(BlockBorder.NONE) ;
        legendTitle.setBackgroundPaint(null) ;
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,MedwanQuery.getInstance().getConfigInt("stats.piechartwidth",640),MedwanQuery.getInstance().getConfigInt("stats.piechartheight",480));
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private class PercentLabelGenerator implements PieSectionLabelGenerator {
    	double total=0;
    	Hashtable vals = new Hashtable();
    	
    	public PercentLabelGenerator(KeyValue[] values){
    		super();
    		for(int n=0;n<values.length;n++){
    			total+=new Double(values[n].getValue()).doubleValue();
    			vals.put(values[n].getKey(),values[n].getValue());
    		}
    	}
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase() + " ("+PERCENT_FORMAT.format(Double.parseDouble((String)vals.get(temp))*100/total)+"%)";
    		}
        	return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

    private class KPGSMoneyLabelGenerator implements PieSectionLabelGenerator {
    	double total=0;
    	Hashtable vals = new Hashtable();
    	
    	public KPGSMoneyLabelGenerator(KeyValue[] values){
    		super();
    		for(int n=0;n<values.length;n++){
    			total+=new Double(values[n].getValue()).doubleValue();
    			vals.put(values[n].getKey(),values[n].getValue());
    		}
    	}
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase() + " ("+new DecimalFormat(MedwanQuery.getInstance().getConfigString("reportPriceFormat","#,###.00")).format(Double.parseDouble((String)vals.get(temp)))+")";
    		}
        	return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

    private class KPGSLabelGenerator implements PieSectionLabelGenerator {
    	double total=0;
    	Hashtable vals = new Hashtable();
    	
    	public KPGSLabelGenerator(KeyValue[] values){
    		super();
    		for(int n=0;n<values.length;n++){
    			total+=new Double(values[n].getValue()).doubleValue();
    			vals.put(values[n].getKey(),values[n].getValue());
    		}
    	}
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase() + " ("+(int)Double.parseDouble((String)vals.get(temp))+" = "+PERCENT_FORMAT.format(Double.parseDouble((String)vals.get(temp))*100/total)+"%)";
    		}
        	return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

    private class KPGSLabelGenerator2 implements PieSectionLabelGenerator {
    	double total=0;
    	Hashtable vals = new Hashtable();
    	
    	public KPGSLabelGenerator2(KeyValue[] values, double total){
    		super();
    		for(int n=0;n<values.length;n++){
    			vals.put(values[n].getKey(),values[n].getValue());
    		}
    		this.total=total;
    	}

    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase() + " ("+(int)Double.parseDouble((String)vals.get(temp))+" = "+PERCENT_FORMAT.format(Double.parseDouble((String)vals.get(temp))*100/total)+"%)";
    		}
        	return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

    private class KPGSLabelGenerator3 implements PieSectionLabelGenerator {
    	Hashtable vals = new Hashtable();
    	
    	public KPGSLabelGenerator3(KeyValue[] values){
    		super();
    		for(int n=0;n<values.length;n++){
    			vals.put(values[n].getKey(),values[n].getValue());
    		}
    	}

    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
    			double dac = hospitalStats.getDeadAdmissionDiagnosisCount(temp);
    			double ac= hospitalStats.getAdmissionDiagnosisCount(temp);
    			temp = temp.toUpperCase() + " ("+hospitalStats.getDeadAdmissionDiagnosisCount(temp)+"/"+hospitalStats.getAdmissionDiagnosisCount(temp)+" = "+PERCENT_FORMAT.format(dac*100/ac)+"%)";
    		}
        	return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

	private class SimpleLegendGenerator implements PieSectionLabelGenerator {
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase() + "                                                                           ";
    		}
    		return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

	private class PrestationLegendGenerator implements PieSectionLabelGenerator {
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
    			Prestation prestation = Prestation.getByCode(temp);
    			if(prestation !=null && prestation.getDescription()!=null){
    				temp += ": "+prestation.getDescription();
    			}
   				temp = temp.toUpperCase() + "                                                                           ";
    		}
    		return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

	private class ServiceLegendGenerator implements PieSectionLabelGenerator {
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
    			Service service = Service.getService(temp);
    			if(service !=null && service.getLabel(sPrintLanguage)!=null){
    				temp += ": "+service.getLabel(sPrintLanguage);
    			}
   				temp = temp.toUpperCase() + "                                                                           ";
    		}
    		return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

	private class KPGSLegendGenerator implements PieSectionLabelGenerator {
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase() + (temp.equalsIgnoreCase("?")?"                                                  ":": "+MedwanQuery.getInstance().getCodeTran("icd10code"+temp, sPrintLanguage))+"                                                                           ";
    		}
    		return temp;
    	}
    	public AttributedString generateAttributedSectionLabel(PieDataset dataset, java.lang.Comparable key) {
    		return null;
    	}
    }

    private PdfPCell createLineChartCell(int[] yvalues,String title, String xlabel,String ylabel,boolean drawRegression) throws IOException, BadElementException{
    	XYSeries series = new XYSeries("data");
    	for(int n=0;n<yvalues.length;n++){
    		series.add(n,yvalues[n]);
    	}
    	XYSeriesCollection dataset = new XYSeriesCollection(series);
    	if(drawRegression){
	    	XYSeries regression = new XYSeries("regression");
	    	regression.add(0,StatFunctions.getSimpleRegression(yvalues, 0));
	    	regression.add(yvalues.length,StatFunctions.getSimpleRegression(yvalues, yvalues.length));
	    	dataset.addSeries(regression);
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createXYLineChart(
            title, // chart title
            xlabel, // domain axis label
            ylabel, // range axis label
            dataset, // data
            PlotOrientation.VERTICAL, // orientation
            false, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        chart.setAntiAlias(true);
        // round dots for all series
        XYPlot plot = chart.getXYPlot();
        plot.setBackgroundPaint(Color.WHITE);
        plot.setRangeGridlinePaint(Color.GRAY);
        plot.setDomainGridlinePaint(Color.GRAY);
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
        int dotSize = 4;
        renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShapesVisible(1, false);
        renderer.setSeriesPaint(0, Color.BLACK);
        renderer.setSeriesPaint(1, Color.RED);
        plot.setRenderer(renderer);
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,640,480);
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private PdfPCell createLineChartCell(double[] yvalues,String title, String xlabel,String ylabel,boolean drawRegression) throws IOException, BadElementException{
    	XYSeries series = new XYSeries("data");
    	for(int n=0;n<yvalues.length;n++){
    		series.add(n,yvalues[n]);
    	}
    	XYSeriesCollection dataset = new XYSeriesCollection(series);
    	if(drawRegression){
	    	XYSeries regression = new XYSeries("regression");
	    	regression.add(0,StatFunctions.getSimpleRegression(yvalues, 0));
	    	regression.add(yvalues.length,StatFunctions.getSimpleRegression(yvalues, yvalues.length));
	    	dataset.addSeries(regression);
    	}
    	// create chart
        final JFreeChart chart = ChartFactory.createXYLineChart(
            title, // chart title
            xlabel, // domain axis label
            ylabel, // range axis label
            dataset, // data
            PlotOrientation.VERTICAL, // orientation
            false, // legend
            false, // tooltips
            false // urls
        );
        // customize chart
        chart.setAntiAlias(true);
        // round dots for all series
        XYPlot plot = chart.getXYPlot();
        plot.setBackgroundPaint(Color.WHITE);
        plot.setRangeGridlinePaint(Color.GRAY);
        plot.setDomainGridlinePaint(Color.GRAY);
        XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
        int dotSize = 4;
        renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
        renderer.setSeriesShapesVisible(1, false);
        renderer.setSeriesPaint(0, Color.BLACK);
        renderer.setSeriesPaint(1, Color.RED);
        plot.setRenderer(renderer);
        ByteArrayOutputStream os = new ByteArrayOutputStream();
        ChartUtilities.writeChartAsPNG(os,chart,640,480);
        cell = new PdfPCell();
        cell.setColspan(50);
        cell.setImage(Image.getInstance(os.toByteArray()));
        cell.setBorder(Cell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }
    
    private void printBaseActivityLine(String label1, String result1, String label2, String result2){
        cell = new PdfPCell(new Paragraph(label1,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
        cell.setPaddingTop(5);
        cell.setColspan(30);
        cell.setBorder(Cell.NO_BORDER);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
    	table.addCell(cell);
        cell = new PdfPCell(new Paragraph(result1,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
        cell.setPaddingTop(5);
        cell.setColspan(20);
        cell.setBorder(Cell.NO_BORDER);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
    	table.addCell(cell);
        cell = new PdfPCell(new Paragraph(label2,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
        cell.setPaddingTop(5);
        cell.setColspan(30);
        cell.setBorder(Cell.NO_BORDER);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
    	table.addCell(cell);
        cell = new PdfPCell(new Paragraph(result2,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
        cell.setPaddingTop(5);
        cell.setColspan(20);
        cell.setBorder(Cell.NO_BORDER);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
    	table.addCell(cell);
    	
    }
    
    private void printReportHeader(){
    	try{
            Report_Identification report_identification = new Report_Identification(end);
	    	table =new PdfPTable(100);
	    	table.setWidthPercentage(100);
	    	cell=createBorderlessCell(ScreenHelper.getTranNoLink("hospital.statistics", "title", sPrintLanguage), 5,100, 10);
	    	table.addCell(cell);
	    	cell=createBorderlessCell(report_identification.getItem("OC_HC_FOSA"), 5,100, 10);
	    	table.addCell(cell);
	    	doc.add(table);
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
 
}