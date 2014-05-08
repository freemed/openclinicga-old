package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.pharmacy.ProductStock;
import be.openclinic.pharmacy.Product;
import net.admin.User;
import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import javax.servlet.http.HttpServletRequest;
import java.io.ByteArrayOutputStream;
import java.util.*;
import java.awt.*;
import java.text.SimpleDateFormat;

/**
 * User: stijn smets
 * Date: 24-jan-2007
 */
public class PDFProductStockFicheGenerator extends PDFBasic {

    // declarations
    private final int pageWidth = 90;


    //--- CONSTRUCTOR --------------------------------------------------------------------------------------------------
    public PDFProductStockFicheGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES ----------------------------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String productStockUid,
                                                          String sFicheYear, String printLanguage) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;
        this.sPrintLanguage = printLanguage;

        try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);

            doc.open();

            // add content to document
            addPageHeader(productStockUid,sFicheYear);
            printFiche(productStockUid,sFicheYear);
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


    //############################################# PRIVATE METHODS ####################################################
    
    //--- ADD PAGE HEADER ----------------------------------------------------------------------------------------------
    private void addPageHeader(String productStockUid, String sFicheYear) throws Exception {
        table = new PdfPTable(4);
        table.setWidthPercentage(pageWidth);

        ProductStock productStock = ProductStock.get(productStockUid);
        String sProductStockName, sServiceStockName;
        if(productStock!=null){
            // service- and productStockname
            sServiceStockName = productStock.getServiceStock().getName();
            Product product = productStock.getProduct();
            if(product!=null){
                sProductStockName = product.getName();
            }
            else{
                sProductStockName = "<font color='red'>"+ScreenHelper.getTranNoLink("web","nonexistingProduct",sPrintLanguage)+"</font>";
            }

            // page title
            table.addCell(createTitle(ScreenHelper.getTranNoLink("web","productstockfiche",sPrintLanguage),4));

            // service stock
            cell = createValueCell(ScreenHelper.getTranNoLink("web","serviceStock",sPrintLanguage),1); 
            cell.setBackgroundColor(new BaseColor(245,245,245)); // light grey
            table.addCell(cell);
            table.addCell(createValueCell(sServiceStockName,3));

            // product stock
            cell = createValueCell(ScreenHelper.getTranNoLink("web","productStock",sPrintLanguage),1);
            cell.setBackgroundColor(new BaseColor(245,245,245)); // light grey
            table.addCell(cell);
            table.addCell(createValueCell(sProductStockName,3));

            // year
            cell = createValueCell(ScreenHelper.getTranNoLink("web","year",sPrintLanguage),1);          
            cell.setBackgroundColor(new BaseColor(245,245,245)); // light grey
            table.addCell(cell);
            table.addCell(createValueCell(sFicheYear,3));

            // print date
            cell = createValueCell(ScreenHelper.getTranNoLink("web","printdate",sPrintLanguage),1);
            cell.setBackgroundColor(new BaseColor(245,245,245)); // light grey
            table.addCell(cell);
            table.addCell(createValueCell(ScreenHelper.fullDateFormat.format(new java.util.Date()),3));

            doc.add(table);
            addBlankRow();
        }
    }

    //--- PRINT PRODUCT STOCK FICHE ------------------------------------------------------------------------------------
    private void printFiche(String productStockUid, String sFicheYear){
        try{
            ProductStock productStock = ProductStock.get(productStockUid);

            PdfPTable ficheTable = new PdfPTable(5);
            ficheTable.setWidthPercentage(pageWidth);

            //*** HEADER ***
            ficheTable.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","month",sPrintLanguage),1));
            ficheTable.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","in",sPrintLanguage),1));
            ficheTable.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","out",sPrintLanguage),1));
            ficheTable.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","netto",sPrintLanguage),1));
            ficheTable.addCell(createTitleCell(ScreenHelper.getTranNoLink("web","level",sPrintLanguage),1));

            //*** DISPLAY MONTHS ***
            Calendar calendar = new GregorianCalendar();
            calendar.set(Integer.parseInt(sFicheYear),0,0,0,0,0);

            String sClass = "1";
            int unitsIn, unitsOut, unitsDiff;
            for(int i=0; i<12; i++){
                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                calendar.add(Calendar.MONTH,1);

                // count units
                unitsIn   = productStock.getTotalUnitsInForMonth(calendar.getTime());
                unitsOut  = productStock.getTotalUnitsOutForMonth(calendar.getTime());
                unitsDiff = unitsIn - unitsOut;

                //*** one month (one row) ***     
                // month name
                cell = createHeaderCell(ScreenHelper.getTranNoLink("web","month"+(i+1),sPrintLanguage),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                ficheTable.addCell(cell);

                // units in
                cell = createValueCell(unitsIn+"",1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                ficheTable.addCell(cell);

                // units out
                cell = createValueCell(unitsOut+"",1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                ficheTable.addCell(cell);

                // unitsDiff
                cell = createValueCell((unitsDiff<0?unitsDiff+"":(unitsDiff==0?unitsDiff+"":"+"+unitsDiff)),1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                ficheTable.addCell(cell);

                // level
                cell = createValueCell(productStock.getLevel(calendar.getTime())+"",1);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
                ficheTable.addCell(cell);
            }

            //*** YEAR TOTAL ***
            // count units
            unitsIn   = productStock.getTotalUnitsInForYear(calendar.getTime());
            unitsOut  = productStock.getTotalUnitsOutForYear(calendar.getTime());
            unitsDiff = unitsIn - unitsOut;

            // total
            ficheTable.addCell(createHeaderCell(ScreenHelper.getTranNoLink("web","total",sPrintLanguage),1));

            // units in total
            cell = createHeaderCell(unitsIn+"",1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            ficheTable.addCell(cell);

            // units out total
            cell = createHeaderCell(unitsOut+"",1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            ficheTable.addCell(cell);

            // unitsDiff
            cell = createHeaderCell((unitsDiff<0?unitsDiff+"":(unitsDiff==0?unitsDiff+"":"+"+unitsDiff)),1);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
            ficheTable.addCell(cell);

            // empty cell (no total possible for level)
            ficheTable.addCell(createHeaderCell("",1));
                                         
            doc.add(ficheTable);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
    
    
    //################################### UTILITY FUNCTIONS ############################################################

    //--- CREATE TITLE -------------------------------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setPaddingBottom(20);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ---------------------------------------------------------------------------------------
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

}
