package be.mxs.common.util.pdf.general;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;

import java.text.SimpleDateFormat;
import java.io.ByteArrayOutputStream;
import java.awt.*;
import java.util.*;

import net.admin.User;
import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import javax.servlet.http.HttpServletRequest;

public class PDFHospitalizedPatientsGenerator extends PDFBasic {

    // declarations
    private final int pageWidth = 96;
    private SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;


    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFHospitalizedPatientsGenerator(User user, String sProject){
        this.user = user;
        this.patient = null;
        this.sProject = sProject;
        this.sPrintLanguage = user.person.language;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sServiceCode,
                                                          String sBeginDate, String sEndDate) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);
            addFooter(docWriter);

            doc.open();

            addHeading(sBeginDate,sEndDate);
            printOverview(sServiceCode,sBeginDate,sEndDate);
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

    //---- ADD HEADING ----------------------------------------------------------------------------
    private void addHeading(String sDateFrom, String sDateTo) throws Exception {
        //*** HEADER ***
        table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // logo
        try{
            Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
            img.scaleToFit(75, 75);
            cell = new PdfPCell(img);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setColspan(5);
            table.addCell(cell);
        }
        catch(NullPointerException e){
            Debug.println("WARNING : PDFPatientFlowOverviewGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
            e.printStackTrace();
        }

        doc.add(table);
        addBlankRow();

        //*** DOCUMENT TITLE ***
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);
        String sTitle = getTran("Web","statistics.hospitalizedpatients").toUpperCase();

        // date range if any
        String sSubTitle = "";
        if(sDateFrom.length() > 0 && sDateTo.length() > 0){
            sSubTitle = getTran("web","from")+" "+sDateFrom+" "+getTran("web","to")+" "+sDateTo;
        }
        else if(sDateFrom.length() > 0){
            sSubTitle = getTran("web","since")+" "+sDateFrom;
        }
        else if(sDateTo.length() > 0){
            sSubTitle = getTran("web","to")+" "+sDateTo;
        }

        cell = createTitleCell(sTitle,sSubTitle,10,10);
        table.addCell(createCell(cell,1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));

        doc.add(table);
        addBlankRow();
    }

    //--- PRINT OVERVIEW --------------------------------------------------------------------------
    private void printOverview(String sServiceCode, String sFromDate, String sToDate){
        try {
            PdfPTable table = new PdfPTable(1);
            table.setWidthPercentage(pageWidth);
            int rowsOnOnePage = 0;

            if(sFromDate.length() > 0 || sToDate.length() > 0){
                // get services containing patients in specified period
                Hashtable hServices = Encounter.getHospitalizePatients(sFromDate,sToDate,sServiceCode);

                // sort services alfabeticaly
                String sServiceId;
                Hashtable hSortedServices = new Hashtable();
                Enumeration enum2 = hServices.keys();
                while(enum2.hasMoreElements()){
                    sServiceId = (String)enum2.nextElement();
                    hSortedServices.put(ScreenHelper.getTran("service",sServiceId,sPrintLanguage).toLowerCase(),sServiceId);
                }

                if(sToDate.length() == 0){
                    sToDate = ScreenHelper.getDate(); // now
                }

                // outcomes
                Hashtable hOutcomes = new Hashtable();
                Hashtable hOutcomesTotal = new Hashtable();
                Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sPrintLanguage.toLowerCase());
                Iterator itOutcome;
                String sLabelValue;
                Vector vOutcome = new Vector();

                if (labelTypes!=null) {
                    Hashtable labelIds = (Hashtable)labelTypes.get("encounter.outcome");

                    if(labelIds!=null) {
                        Enumeration idsEnum = labelIds.elements();
                        net.admin.Label label;

                        while (idsEnum.hasMoreElements()) {
                            label = (net.admin.Label)idsEnum.nextElement();

                            hOutcomes.put(label.value,label.id);
                            hOutcomesTotal.put(label.id.toLowerCase(),new Integer(0));
                        }

                        vOutcome = new Vector(hOutcomes.keySet());
                        Collections.sort(vOutcome);
                    }
                }

                // add one row per day
                Vector sortedServices = new Vector(hSortedServices.keySet());
                Collections.sort(sortedServices);
                Iterator serviceIter = sortedServices.iterator();

                while (serviceIter.hasNext()) {
                    sServiceId = (String) serviceIter.next();
                    sServiceId = (String) hSortedServices.get(sServiceId);

                    // service-table
                    int colsPerRow = hOutcomes.size()+5;
                    PdfPTable serviceTable = new PdfPTable(colsPerRow);

                    // title
                    serviceTable.addCell(createGrayCell(getTran("service",sServiceId),colsPerRow));

                    // header
                    serviceTable.addCell(createHeaderCell(getTran("web","date"),1));
                    serviceTable.addCell(createHeaderCell(getTran("web.statistics","brought.forward"),1));
                    serviceTable.addCell(createHeaderCell(getTran("web.statistics","new.patients"),1));

                    // sub-header
                    PdfPTable outcomesTable = new PdfPTable(hOutcomes.size()+1);
                    outcomesTable.addCell(createHeaderCell(getTran("web.statistics","departures"),hOutcomes.size()+1));

                    itOutcome = vOutcome.iterator();
                    while (itOutcome.hasNext()) {
                        sLabelValue = (String)itOutcome.next();
                        outcomesTable.addCell(createHeaderCell(sLabelValue,1));
                    }
                    outcomesTable.addCell(createHeaderCell(getTran("web.statistics","subtotal"),1));
                    serviceTable.addCell(createCell(new PdfPCell(outcomesTable),hOutcomes.size()+1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

                    serviceTable.addCell(createHeaderCell(getTran("web","carried.forward"),1));

                    // add patients in service
                    Vector vRows = (Vector)hServices.get(sServiceId);

                    Date dBegin, dEnd, dFindBegin, dFindEnd;
                    int iBroughtForward, iNewPatients,  iSubtotal, iCarriedForward = -1;
                    String sDate, sLabelID, sOutcome, sTmpFindBegin;
                    Hashtable hRow;

                    sTmpFindBegin = ScreenHelper.getDateAdd(sFromDate,"-1");
                    dFindBegin = ScreenHelper.getSQLDate(sTmpFindBegin);
                    dFindEnd = ScreenHelper.getSQLDate(sToDate);

                    if (dFindBegin!=null){
                        while (dFindBegin.getTime() < dFindEnd.getTime()){
                            if (sTmpFindBegin.length()>0){
                                iBroughtForward = Encounter.getHospitalizePatientsAtDate(sTmpFindBegin,sServiceId);
                                sTmpFindBegin = "";
                            }
                            else {
                                iBroughtForward = iCarriedForward;
                            }

                            iNewPatients = 0;
                            iSubtotal = 0;

                            sDate = ScreenHelper.getDateAdd(ScreenHelper.getSQLDate(dFindBegin),"1");
                            dFindBegin = ScreenHelper.getSQLDate(sDate);

                            for (int i=0;i<vRows.size();i++){
                                hRow = (Hashtable)vRows.elementAt(i);
                                dBegin = (Date)hRow.get("begin");
                                dEnd = (Date)hRow.get("end");
                                sOutcome = (String) hRow.get("outcome");

                                if (ScreenHelper.getSQLDate(dBegin).equals(ScreenHelper.getSQLDate(dFindBegin))){
                                    iNewPatients++;
                                }
                                else {
                                    if (ScreenHelper.getSQLDate(dEnd).equals(ScreenHelper.getSQLDate(dFindBegin))){
                                        hOutcomesTotal.put(sOutcome.toLowerCase(),new Integer(((Integer)hOutcomesTotal.get(sOutcome.toLowerCase())).intValue()+1));
                                        iSubtotal++;
                                    }
                                }
                            }

                            iCarriedForward = iBroughtForward + iNewPatients - iSubtotal;

                            // draw one day-row
                            serviceTable.addCell(createValueCell(sDate,1));
                            serviceTable.addCell(createBoldValueCell(iBroughtForward,1));
                            serviceTable.addCell(createValueCell(iNewPatients,1));

                            itOutcome = vOutcome.iterator();
                            while (itOutcome.hasNext()) {
                                sLabelValue = (String)itOutcome.next();
                                sLabelID = (String)hOutcomes.get(sLabelValue);

                                serviceTable.addCell(createValueCell(((Integer)hOutcomesTotal.get(sLabelID)).intValue(),1));
                                hOutcomesTotal.put(sLabelID,new Integer(0));
                            }

                            serviceTable.addCell(createValueCell(iSubtotal,1));
                            serviceTable.addCell(createBoldValueCell(iCarriedForward,1));

                            rowsOnOnePage++;

                            // only allow 56 rows on one page
                            if(rowsOnOnePage==56){
                                table.addCell(createCell(new PdfPCell(serviceTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                                serviceTable = new PdfPTable(colsPerRow);
                                rowsOnOnePage = 0;
                            }
                        }
                    }

                    table.addCell(createCell(new PdfPCell(serviceTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                    table.addCell(createEmptyCell(1));
                }
            }

            // "printed by" info
            table.addCell(createCell(new PdfPCell(getPrintedByInfo()),1,PdfPCell.ALIGN_LEFT,PdfPCell.NO_BORDER));

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD FOOTER ------------------------------------------------------------------------------
    private void addFooter(PdfWriter docWriter){
        String sFooter = getConfigString("footer."+sProject)+"<br>Page ";
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");

        PDFFooter footer = new PDFFooter(sFooter);
        docWriter.setPageEvent(footer);
    }

    //### PRIVATE METHODS #########################################################################


    //--- GET "PRINTED BY" INFO -------------------------------------------------------------------
    // active user name and current date
    private PdfPTable getPrintedByInfo(){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        String sPrintedBy = getTran("web","printedby")+" "+user.person.lastname+" "+user.person.firstname+" "+
                            getTran("web","on")+" "+stdDateFormat.format(new Date());
        table.addCell(createBorderLessCell(sPrintedBy,1));

        return table;
    }


    //##################################### CELL FUNCTIONS ########################################

    //--- CREATE GRAY CELL (gray background) ------------------------------------------------------
    protected PdfPCell createGrayCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorderColor(innerBorderColor);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingTop(3);
        cell.setPaddingBottom(3);

        return cell;
    }

    //--- CREATE TITLE CELL (large, bold) ---------------------------------------------------------
    protected PdfPCell createTitleCell(String title, String subTitle, int colspan, int padding){
        Paragraph paragraph = new Paragraph(title,FontFactory.getFont(FontFactory.HELVETICA,11,Font.BOLD));

        // add subtitle, if any
        if(subTitle.length() > 0){
            paragraph.add(new Chunk("\n\n"+subTitle,FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
        }

        cell = new PdfPCell(paragraph);
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setPadding(padding);

        return cell;
    }

    //--- CREATE BOLD VALUE CELL ------------------------------------------------------------------
    protected PdfPCell createBoldValueCell(int value, int colspan){
        return createValueCell(Integer.toString(value),colspan,PdfPCell.ALIGN_RIGHT,Font.BOLD);
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCell(int value, int colspan){
        return createValueCell(Integer.toString(value),colspan,PdfPCell.ALIGN_RIGHT,Font.NORMAL); // default int alignment = right
    }

    protected PdfPCell createValueCell(String value, int colspan){
        return createValueCell(value,colspan,PdfPCell.ALIGN_LEFT,Font.NORMAL);
    }

    protected PdfPCell createValueCell(String value, int colspan, int fontWeight){
        return createValueCell(value,colspan,PdfPCell.ALIGN_LEFT,fontWeight);
    }

    protected PdfPCell createValueCell(String value, int colspan, int alignment, int fontWeight){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,fontWeight)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(alignment);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderLessCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE EMPTY CELL -------------------------------------------------------------------------
    protected PdfPCell createEmptyCell(int colspan){
        return createEmptyCell(5,colspan);
    }

    //--- CREATE EMPTY CELL -------------------------------------------------------------------------
    protected PdfPCell createEmptyCell(int height, int colspan){
        cell = new PdfPCell(new Paragraph("",FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setPaddingTop(height);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

}
