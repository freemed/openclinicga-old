package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.common.KeyValue;

import com.itextpdf.text.pdf.*;
import com.itextpdf.text.*;

import net.admin.User;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.block.BlockBorder;
import org.jfree.chart.labels.PieSectionLabelGenerator;
import org.jfree.chart.plot.PiePlot;
import org.jfree.chart.title.LegendTitle;
import org.jfree.data.general.DefaultPieDataset;
import org.jfree.data.general.PieDataset;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.AttributedString;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFGraphGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    private String type;
    PdfWriter docWriter=null;
    public void addHeader(){
    }
    public void addContent(){
    }


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFGraphGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String type, String title,Hashtable parameters) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
            Rectangle rectangle=null;
			doc.setPageSize(PageSize.A4);
            doc.setMargins(10,10,10,10);
            doc.setJavaScript_onLoad("print();\r");
            doc.open();
            
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(100);
            if(type.equalsIgnoreCase("piechart")){
            	KeyValue[] values = new KeyValue[parameters.size()];
            	Enumeration pars = parameters.keys();
            	int n=0;
            	while(pars.hasMoreElements()){
            		String parameterkey=(String)pars.nextElement();
            		values[n]=new KeyValue(parameterkey,(String)parameters.get(parameterkey));
            		n++;
            	}
            	table.addCell(createKPGSPieChartCell(values, ScreenHelper.getTranNoLink("web", title, sPrintLanguage)));
            }
            doc.add(table);
		}
		catch(Exception e){
			baosPDF.reset();
			e.printStackTrace();
		}
		finally{
			if(doc!=null) doc.close();
            if(docWriter!=null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has no bytes");
		}

		return baosPDF;
	}

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
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
        plot.setBackgroundPaint(java.awt.Color.WHITE);
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
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPaddingLeft(5);
        cell.setPaddingRight(5);
        return cell;
    }

	private class KPGSLegendGenerator implements PieSectionLabelGenerator {
    	public String generateSectionLabel(final PieDataset dataset, final Comparable key) {
    		String temp = null;
    		if (dataset != null) {
    			temp = key.toString();
   				temp = temp.toUpperCase();
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

    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- PRINT VECTOR ----------------------------------------------------------------------------
    protected String printVector(Vector vector){
        StringBuffer buf = new StringBuffer();
        for(int i=0; i<vector.size(); i++){
            buf.append(vector.get(i)).append(", ");
        }

        // remove last comma
        if(buf.length() > 0) buf.deleteCharAt(buf.length()-2);

        return buf.toString();
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan,int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

}
