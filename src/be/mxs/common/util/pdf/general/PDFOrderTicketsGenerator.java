package be.mxs.common.util.pdf.general;

import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.*;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.text.DecimalFormat;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.pharmacy.ProductOrder;
import be.openclinic.pharmacy.Product;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFOrderTicketsGenerator extends PDFBasic {

    // declarations
    private final int pageWidth = 90;


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

            // run thru all different companies
            Service company;
            for(int i=0; i<companyUids.size(); i++){
                companyUid = (String)companyUids.get(i);

                company = Service.getService(companyUid);
                if(company!=null){
                    this.sPrintLanguage = company.language;
                    addPageHeader();
                    
                    //*** SIGNATURE OF ONE COMPANY ************************************************
                    table = new PdfPTable(6);
                    table.setWidthPercentage(pageWidth);
                    
                    String companyName = ScreenHelper.getTranNoLink("service",companyUid,sPrintLanguage);
                    cell = createHeaderCell(companyUid+" - "+companyName,6);
                    cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
                    table.addCell(cell);

                    // address
                    String address = company.address+"\n"+
                                     company.zipcode+" "+company.city+"\n"+
                                     ScreenHelper.getTranNoLink("country",company.country,sPrintLanguage);
                    table.addCell(createItemNameCell(ScreenHelper.getTranNoLink("web","address",sPrintLanguage),1));
                    table.addCell(createValueCell(address,5));

                    // telephone
                    table.addCell(createItemNameCell(ScreenHelper.getTranNoLink("web","telephone",sPrintLanguage),1));
                    table.addCell(createValueCell(company.telephone,5));

                    //*** ORDERS OF ONE COMPANY ***************************************************
                    // header
                    table.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","product",sPrintLanguage),3));
                    table.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","packagePrice",sPrintLanguage),1));
                    table.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","packageUnits",sPrintLanguage),1));
                    table.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","orderedquantity",sPrintLanguage),1));

                    // group internal orders of the same product to one external order
                    ProductOrder order = null;
                    String orderedProductUid;
                    int totalPackagesOrdered = 0;
                    orderUidsOfOneCompany = (Vector)orderUidsPerCompany.get(companyUid);
                    Hashtable orderedProducts = new Hashtable();
                    for(int j=0; j<orderUidsOfOneCompany.size(); j++){
                        orderUid = (String)orderUidsOfOneCompany.get(j);
                        order = ProductOrder.get(orderUid);
                        orderedProductUid = order.getProductStock().getProductUid();
                        Integer packagesOrderedSoFar = (Integer)orderedProducts.get(orderedProductUid);
                        if(packagesOrderedSoFar!=null){
                            totalPackagesOrdered = packagesOrderedSoFar.intValue();
                            totalPackagesOrdered+= order.getPackagesOrdered();
                        }
                        else{
                            totalPackagesOrdered = order.getPackagesOrdered();
                        }

                        orderedProducts.put(orderedProductUid,new Integer(totalPackagesOrdered));
                    }

                    // print grouped orders as one order
                    int packagesOrdered = 0;
                    Enumeration orderEnum = orderedProducts.keys();
                    while(orderEnum.hasMoreElements()){
                        orderedProductUid = (String)orderEnum.nextElement();
                        packagesOrdered = ((Integer)orderedProducts.get(orderedProductUid)).intValue();

                        printOrder(table,orderedProductUid,packagesOrdered);
                    }

                    doc.add(table);
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

    //### PRIVATE METHODS #########################################################################

    //--- PRINT ORDER -----------------------------------------------------------------------------
    private void printOrder(PdfPTable companyTable, String orderedProductUid, int packagesOrdered){
        Product orderedProduct = Product.get(orderedProductUid);

        double unitPrice = orderedProduct.getUnitPrice();
        int packageUnits = orderedProduct.getPackageUnits();
        double packagePrice = unitPrice*packageUnits;
        DecimalFormat doubleFormat = new DecimalFormat("#.00");
        String sCurrency = getConfigParam("currencyPdf","€");

        companyTable.addCell(createValueCell(orderedProduct.getName(),3));
        companyTable.addCell(createNumberCell(doubleFormat.format(packagePrice)+" "+sCurrency,1));
        companyTable.addCell(createNumberCell(packageUnits+"",1));
        companyTable.addCell(createNumberCell(packagesOrdered+"",1));
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

}