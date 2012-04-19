package be.mxs.common.util.pdf.general;

import com.lowagie.text.pdf.Barcode39;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.*;

import java.util.*;
import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.pharmacy.OperationDocument;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.Product;
import be.openclinic.pharmacy.ProductStockOperation;
import be.openclinic.system.Center;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFOrderTicketsGenerator extends PDFOfficialBasic {

    // declarations
    protected PdfWriter docWriter;
    private final int pageWidth = 100;
    private String type;
    private SimpleDateFormat dateformat=new SimpleDateFormat("dd/MM/yyyy");


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFOrderTicketsGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String orderUids) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter docWriter = PdfWriter.getInstance(doc,baosPDF);;
        this.req = req;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);

            doc.open();

            // add content to document
            printOrderTickets(orderUids);
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
        //*** IMAGE HEADER ***
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        Image img = Miscelaneous.getImage("orderTicketsHeader.gif","openclinic");
        img.scalePercent(50);
        cell = new PdfPCell(img);
        cell.setBorder(Cell.NO_BORDER);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        table.addCell(cell);

        doc.add(table);
        addBlankRow();

        //*** DOCUMENT TITLE ***
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        cell = createValueCell(ScreenHelper.getTranNoLink("web","orders",sPrintLanguage).toUpperCase(),1);
        cell.setBorder(Cell.BOX);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        cell.setPadding(10);
        table.addCell(cell);

        doc.add(table);
        addBlankRow();
    }
    
    //--- PRINT ORDERTICKETS ----------------------------------------------------------------------
    protected void printOrderTickets(String orderUids){
        try {
            //*** SORT ORDERUIDS PER COMPANY ******************************************************
            String orderIdentifier = "", orderUid = "", companyUid = "", prevCompanyUid = "";
            Hashtable orderUidsPerCompany = new Hashtable();
            Vector orderUidsOfOneCompany;
            Vector companyUids = new Vector();

            StringTokenizer tokenizer = new StringTokenizer(orderUids,"$");
            while(tokenizer.hasMoreTokens()){
                orderIdentifier = tokenizer.nextToken();
                orderUid   = orderIdentifier.split("£")[0];
                companyUid = orderIdentifier.split("£")[1];

                orderUidsOfOneCompany = (Vector)orderUidsPerCompany.get(companyUid);
                if(orderUidsOfOneCompany==null){
                    orderUidsOfOneCompany = new Vector();
                    orderUidsPerCompany.put(companyUid,orderUidsOfOneCompany);
                }
                orderUidsOfOneCompany.add(orderUid);

                if(!companyUid.equals(prevCompanyUid)){
                    if(!companyUids.contains(companyUid)){
                        companyUids.add(companyUid);
                        prevCompanyUid = companyUid;
                    }
                }
            }
            if(!companyUids.contains(companyUid)){
                companyUids.add(companyUid);
            }

            // run thru all different companies
            Service company;
            for(int i=0; i<companyUids.size(); i++){
                companyUid = (String)companyUids.get(i);
                System.out.println("checking companyuid "+companyUid);
                company = Service.getService(companyUid);
                System.out.println("company= "+company);
                if(company!=null){
                    this.sPrintLanguage = company.language;
                    ProductOrder order=null;
                    String orderedProductUid="";
                    orderUidsOfOneCompany = (Vector)orderUidsPerCompany.get(companyUid);
                    addHeading(companyUid);
                    addOperations(orderUidsOfOneCompany);
                    addFooter();
                    doc.newPage(); // each company on a different page
                }
                else{
                    Debug.println("*** PDFTicketsGenerator : Service '"+companyUid+"' not found");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void addFooter() throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","name",sPrintLanguage),0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","grade",sPrintLanguage),0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","date",sPrintLanguage),0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","signature",sPrintLanguage),0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","requestor",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","distributor",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","companion",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","receiver",sPrintLanguage)+"\n \n ",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,40,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	cell=createValueCell("",0,6,15,true);
    	table.addCell(cell);
    	
    	doc.add(table);
    }

    private void addOperations(Vector productOrders) throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);
        //First print table header
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","serialnumber",sPrintLanguage),0,6,5,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","vtgnumber",sPrintLanguage),0,6,10,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","description",sPrintLanguage),0,6,38,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","autoriseddotation",sPrintLanguage),0,6,10,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","instock",sPrintLanguage),0,6,6,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","measurementunit",sPrintLanguage),0,6,10,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","quantityrequested",sPrintLanguage),0,6,7,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","quantitydelivered",sPrintLanguage),0,6,7,true);
    	table.addCell(cell);
    	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","reserved",sPrintLanguage),0,6,7,true);
    	table.addCell(cell);
        
    	//We voegen orders voor éénzelfde product samen
    	Hashtable mergedOrders = new Hashtable();
    	for (int n=0;n<productOrders.size();n++){
    		ProductOrder order = ProductOrder.get((String)productOrders.elementAt(n));
    		if(mergedOrders.get(order.getProductStock().getProduct().getUid())!=null){
    			//Productorder already exists, merge
    			ProductOrder existingOrder = (ProductOrder)mergedOrders.get(order.getProductStock().getProduct().getUid());
    			existingOrder.setPackagesOrdered(existingOrder.getPackagesOrdered()+order.getPackagesOrdered());
    		}
    		else {
    			mergedOrders.put(order.getProductStock().getProduct().getUid(), order);
    		}
    	}
    	Enumeration mo = mergedOrders.keys();
    	int n=0;
    	while(mo.hasMoreElements()){
    		ProductOrder order = (ProductOrder)mergedOrders.get(mo.nextElement());
        	cell=createValueCell((n+1)+"",0,6,5,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(order.getProductStock().getProduct().getName(),1,6,38,true);
        	table.addCell(cell);
        	cell=createValueCell(order.getProductStock().getMaximumLevel()+"",1,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(order.getProductStock().getLevel()+"",1,6,6,true);
        	table.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("product.units",order.getProductStock().getProduct().getUnit(),sPrintLanguage),1,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(order.getPackagesOrdered()+"",1,6,7,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,7,true);
        	table.addCell(cell);
        	cell=createValueCell("",0,6,7,true);
        	table.addCell(cell);
        	n++;
    	}
    	for(n=0;n<40-mergedOrders.size();n++){
        	cell=createValueCell(" ",0,6,5,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",1,6,38,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",1,6,6,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",1,6,10,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,7,true);
        	table.addCell(cell); 
        	cell=createValueCell(" ",1,6,7,true);
        	table.addCell(cell);
        	cell=createValueCell(" ",0,6,7,true);
        	table.addCell(cell);
    	}
    	PdfPTable table2 = new PdfPTable(1);
    	cell=createBorderlessCell("\n ",1);
    	cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
    	table2.addCell(cell);
    	cell=createBorderlessCell("\n ",1);
    	cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
    	table2.addCell(cell);
    	cell=new PdfPCell(table2);
    	cell.setColspan(100);
    	cell.setBorder(Cell.BOX);
    	table.addCell(cell);
    	
    	
    	doc.add(table);
    }

    //---- ADD HEADING (logo & barcode) -----------------------------------------------------------
    private void addHeading(String companyuid) throws Exception {
        table = new PdfPTable(100);
        table.setWidthPercentage(pageWidth);

        try {
        	cell= createHeaderCell(ScreenHelper.getTranNoLink("mdnac","orderform",sPrintLanguage).toUpperCase(), 80,20);
        	table.addCell(cell);
        	cell= createHeaderCell(dateformat.format(new java.util.Date()),20,10);
        	table.addCell(cell);
        	PdfPTable table2 = new PdfPTable(1);
        	cell=createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","requestor",sPrintLanguage),1);
        	cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        	table2.addCell(cell);
        	Center center = Center.get(0, true);
        	cell=createHeaderCell(center!=null && center.getName()!=null?center.getName():"UNKNOWN CENTER",1,12);
            cell.setBackgroundColor(Color.WHITE);
        	cell.setBorderColor(Color.BLACK);
        	cell.setBorder(Cell.BOX);
        	cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setBorderColor(Color.BLACK);
        	cell.setBorder(Cell.BOX);
        	cell.setColspan(50);
        	table.addCell(cell);
        	table2 = new PdfPTable(50);
        	PdfPTable table3  = new PdfPTable(1);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","ordernumber",sPrintLanguage)+"\n ");
        	cell.setColspan(1);
            cell.setBorder(Cell.NO_BORDER);
        	table3.addCell(cell);
            cell=createValueCell("\n ");
            cell.setBorder(Cell.NO_BORDER);
            table3.addCell(cell);
        	
        	cell=new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","visa.log1",sPrintLanguage)+"\n"+ScreenHelper.getTranNoLink("mdnac","visa.log2",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	table3 = new PdfPTable(10);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","distributiontype",sPrintLanguage));
        	cell.setColspan(10);
        	table3.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","purchase",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","blognumber",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(1);
        	cell=createBorderlessCell(ScreenHelper.getTranNoLink("mdnac","distributor",sPrintLanguage),1);
        	cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        	table2.addCell(cell);
        	String serviceName="";
        	Service service = Service.getService(companyuid);
        	if(service!=null && service.getLabel(sPrintLanguage)!=null){
        		serviceName=service.getLabel(sPrintLanguage);
        	}
        	cell=createHeaderCell(serviceName,1,12);
        	cell.setBorderColor(Color.BLACK);
        	cell.setBorder(Cell.BOX);
            cell.setBackgroundColor(Color.WHITE);
        	cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setBorder(Cell.BOX);
        	cell.setBorderColor(Color.BLACK);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
        	table2 = new PdfPTable(50);
        	table3 = new PdfPTable(10);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","initial",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","replacement",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","loan",sPrintLanguage));
        	cell.setColspan(7);
        	table3.addCell(cell);
        	cell=createValueCell("");
        	cell.setColspan(3);
        	table3.addCell(cell);
        	cell=new PdfPCell(table3);
        	cell.setColspan(20);
        	table2.addCell(cell);
        	cell=createValueCell(ScreenHelper.getTranNoLink("mdnac","approvalg4",sPrintLanguage));
        	cell.setColspan(30);
        	table2.addCell(cell);
        	cell=new PdfPCell(table2);
        	cell.setColspan(50);
        	table.addCell(cell);
        	
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }



    //################################### UTILITY FUNCTIONS #######################################

    //--- CREATE UNDERLINED CELL ------------------------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE))); // underlined
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

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
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);

        return cell;
    }

	@Override
	protected void addHeader() {
		// TODO Auto-generated method stub
		
	}

	@Override
	protected void addContent() {
		// TODO Auto-generated method stub
		
	}

}