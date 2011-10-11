package be.mxs.common.util.pdf.general;

import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.*;
import com.lowagie.text.Font;
import com.lowagie.text.Image;

import java.util.*;
import java.io.ByteArrayOutputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.awt.*;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.finance.*;
import net.admin.*;

import javax.servlet.http.HttpServletRequest;

public class PDFWicketOverViewGenerator extends PDFBasic {

    // declarations
    private final int pageWidth = 90;
    private double debetTotal = 0;
    private double creditTotal = 0;

    private SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");
    private SimpleDateFormat fullDateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    private String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
    private DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFWicketOverViewGenerator(User user, AdminPerson patient, String sProject){
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sPrintLanguage = patient.getActivePerson().language;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, String sWicketUid,
                                                          String sWicketFromDate, String sWicketToDate) throws Exception {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter docWriter = PdfWriter.getInstance(doc,baosPDF);
        this.req = req;

        // reset totals
        this.debetTotal = 0;
        this.creditTotal = 0;

		try{
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software");
			doc.setPageSize(PageSize.A4);
            addFooter();

            doc.open();

            // get specified wicket
            Wicket wicket = Wicket.get(sWicketUid);

            addHeading(wicket,sWicketFromDate,sWicketToDate);
            printWicket(wicket,sWicketFromDate,sWicketToDate);
        }
		catch(Exception e){
			e.printStackTrace();
			baosPDF.reset();
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

    private void ventilateIncome(Hashtable incomeVentilation, Hashtable incomeVentilation2,WicketCredit wicketCredit){
        //First try to find the invoice linked to this credit
        if(wicketCredit.getInvoiceUID()!=null && wicketCredit.getInvoiceUID().length()>0 && wicketCredit.getInvoice()!=null && wicketCredit.getInvoice().getUid()!=null && wicketCredit.getInvoice().getUid().length()>0){
            //Er is dus een factuur gelinked aan dit credit
            //Nu gaan we de prestaties opzoeken die aan deze factuur gelinked zijn
            Invoice invoice=wicketCredit.getInvoice();
            Vector prestations =invoice.getDebets();
            double totalAmount=0;
            //Eerst berekenen we het totaalbedrag
            for(int n=0; n<prestations.size();n++){
                Debet prestation = (Debet)prestations.elementAt(n);
                totalAmount+=prestation.getAmount();
            }
            double correctionfactor=1;
            if(totalAmount>Math.abs(wicketCredit.getAmount())){
                correctionfactor=wicketCredit.getAmount()/totalAmount;
            }
            else if(Math.abs(wicketCredit.getAmount())>=totalAmount){
                //First ventilate income based on prestation family
                if(incomeVentilation.get("OTHER")==null){
                    incomeVentilation.put("OTHER",new Double(wicketCredit.getAmount()-totalAmount));
                }
                else {
                    incomeVentilation.put("OTHER",new Double(((Double)incomeVentilation.get("OTHER")).doubleValue()+wicketCredit.getAmount()-totalAmount));
                }
                //Now ventilate income per service
                String ventilationService = "?";
                if(wicketCredit.getReferenceObject()!=null && wicketCredit.getReferenceObject().getObjectType()!=null && wicketCredit.getReferenceObject().getObjectType().equalsIgnoreCase("patientcredit")){
                    PatientCredit patientCredit = PatientCredit.get(wicketCredit.getReferenceObject().getObjectUid());
                    String su=patientCredit.getEncounter().getServiceUID(patientCredit.getDate());
                    if(patientCredit!=null && patientCredit.getEncounter()!=null && su!=null && su.length()>0){
                        ventilationService=su;
                    }
                }
                if(incomeVentilation2.get(ventilationService)==null){
                    incomeVentilation2.put(ventilationService,new Double(wicketCredit.getAmount()-totalAmount));
                }
                else {
                    incomeVentilation2.put(ventilationService,new Double(((Double)incomeVentilation2.get(ventilationService)).doubleValue()+wicketCredit.getAmount()-totalAmount));
                }
            }
            for(int n=0; n<prestations.size();n++){
                //First ventilate income based on prestation family
                Debet prestation = (Debet)prestations.elementAt(n);
                if(MedwanQuery.getInstance().getConfigString("wicketIncomeVentilation","prestationFamily").equalsIgnoreCase("prestationFamily") && prestation.getPrestation()!=null && prestation.getPrestation().getReferenceObject()!=null && prestation.getPrestation().getReferenceObject().getObjectType()!=null && prestation.getPrestation().getReferenceObject().getObjectType().length()>0){
                    if(incomeVentilation.get(prestation.getPrestation().getReferenceObject().getObjectType())==null){
                        incomeVentilation.put(prestation.getPrestation().getReferenceObject().getObjectType(),new Double(prestation.getAmount()*correctionfactor));
                    }
                    else {
                        incomeVentilation.put(prestation.getPrestation().getReferenceObject().getObjectType(),new Double(((Double)incomeVentilation.get(prestation.getPrestation().getReferenceObject().getObjectType())).doubleValue()+prestation.getAmount()*correctionfactor));
                    }
                }
                else if(MedwanQuery.getInstance().getConfigString("wicketIncomeVentilation","prestationFamily").equalsIgnoreCase("prestationGroup") && prestation.getPrestation()!=null && prestation.getPrestation().getInvoiceGroup()!=null && prestation.getPrestation().getInvoiceGroup().length()>0){
                    if(incomeVentilation.get(prestation.getPrestation().getInvoiceGroup())==null){
                        incomeVentilation.put(prestation.getPrestation().getInvoiceGroup(),new Double(prestation.getAmount()*correctionfactor));
                    }
                    else {
                        incomeVentilation.put(prestation.getPrestation().getInvoiceGroup(),new Double(((Double)incomeVentilation.get(prestation.getPrestation().getInvoiceGroup())).doubleValue()+prestation.getAmount()*correctionfactor));
                    }
                }
                else {
                    if(incomeVentilation.get("OTHER")==null){
                        incomeVentilation.put("OTHER",new Double(prestation.getAmount()*correctionfactor));
                    }
                    else {
                        incomeVentilation.put("OTHER",new Double(((Double)incomeVentilation.get("OTHER")).doubleValue()+prestation.getAmount()*correctionfactor));
                    }
                }
                //Now ventilate income per service
                String su=prestation.getEncounter().getServiceUID(prestation.getDate());
                if(prestation!=null && prestation.getEncounter()!=null && su!=null && su.length()>0){
                    if(incomeVentilation2.get(su)==null){
                        incomeVentilation2.put(su,new Double(prestation.getAmount()*correctionfactor));
                    }
                    else {
                        incomeVentilation2.put(su,new Double(((Double)incomeVentilation2.get(su)).doubleValue()+prestation.getAmount()*correctionfactor));
                    }
                }
                else {
                    if(incomeVentilation2.get("?")==null){
                        incomeVentilation2.put("?",new Double(prestation.getAmount()*correctionfactor));
                    }
                    else {
                        incomeVentilation2.put("?",new Double(((Double)incomeVentilation2.get("?")).doubleValue()+prestation.getAmount()*correctionfactor));
                    }
                }
            }
        }
        else {
            //First ventilate income based on prestation family
            if(incomeVentilation.get("OTHER")==null){
                incomeVentilation.put("OTHER",new Double(wicketCredit.getAmount()));
            }
            else {
                incomeVentilation.put("OTHER",new Double(((Double)incomeVentilation.get("OTHER")).doubleValue()+wicketCredit.getAmount()));
            }
            //Now ventilate income per service
            String ventilationService = "?";
            if(wicketCredit.getReferenceObject()!=null && wicketCredit.getReferenceObject().getObjectType()!=null && wicketCredit.getReferenceObject().getObjectType().equalsIgnoreCase("patientcredit")){
                PatientCredit patientCredit = PatientCredit.get(wicketCredit.getReferenceObject().getObjectUid());
                if(patientCredit!=null && patientCredit.getEncounter()!=null && patientCredit.getDate()!=null){
                    String su=patientCredit.getEncounter().getServiceUID(patientCredit.getDate());
                    if(su!=null && su.length()>0){
                        ventilationService=su;
                    }
                }
            }
            if(incomeVentilation2.get(ventilationService)==null){
                incomeVentilation2.put(ventilationService,new Double(wicketCredit.getAmount()));
            }
            else {
                incomeVentilation2.put(ventilationService,new Double(((Double)incomeVentilation2.get(ventilationService)).doubleValue()+wicketCredit.getAmount()));
            }
        }
    }


    //---- ADD HEADING ----------------------------------------------------------------------------
    private void addHeading(Wicket wicket, String sDateFrom, String sDateTo) throws Exception {
        //*** HEADER ***
        table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);

        // logo
        try{
            Image img = Miscelaneous.getImage("logo_"+sProject+".gif",sProject);
            img.scalePercent(50);
            cell = new PdfPCell(img);
            cell.setBorder(Cell.NO_BORDER);
            cell.setColspan(5);
            table.addCell(cell);
        }
        catch(NullPointerException e){
            Debug.println("WARNING : PDFWicketOverviewGenerator --> IMAGE NOT FOUND : logo_"+sProject+".gif");
            e.printStackTrace();
        }

        doc.add(table);
        addBlankRow();

        //*** DOCUMENT TITLE ***
        table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);
        String sWicketName = "";
        if(wicket.getService()!=null){
            sWicketName = " : "+checkString(wicket.getService().getLabel(sPrintLanguage));
        }
        String sTitle = getTran("Web.financial","wicketSituation").toUpperCase()+sWicketName;

        // date range if any
        String sSubTitle = "";
        if(sDateFrom.length() > 0 && sDateTo.length() > 0){
            sSubTitle = getTran("web","from")+" "+sDateFrom+"  "+getTran("web","to")+" "+sDateTo;
        }
        else if(sDateFrom.length() > 0){
            sSubTitle = getTran("web","since")+" "+sDateFrom;
        }
        else if(sDateTo.length() > 0){
            sSubTitle = getTran("web","to")+" "+sDateTo;
        }

        cell = createTitleCell(sTitle,sSubTitle,10,10);
        table.addCell(createCell(cell,1,Cell.ALIGN_CENTER,Cell.BOX));

        doc.add(table);
        addBlankRow();
    }

    //--- PRINT WICKET ----------------------------------------------------------------------------
    private void printWicket(Wicket wicket, String sWicketFromDate, String sWicketToDate){
        try {

            int cellPadding = 4;

            PdfPTable table = new PdfPTable(150);
            table.setWidthPercentage(pageWidth);

            // debets
            table.addCell(createGrayCell(getTran("web.financial","out").toUpperCase(),150));
            getDebets(wicket,sWicketFromDate,sWicketToDate,table);
            table.addCell(createEmptyCell(150));

            // credits
            table.addCell(createGrayCell(getTran("web.financial","in").toUpperCase(),150));
            getCredits(wicket,sWicketFromDate,sWicketToDate,table);
            table.addCell(createEmptyCell(150));

            // wicket situation (saldo and end-situation)
            table.addCell(createGrayCell(getTran("Web.financial","wicketSituation").toUpperCase(),150));
            getSaldo(wicket,sWicketFromDate,sWicketToDate,table);
            table.addCell(createEmptyCell(150));

            // "printed by" info
            table.addCell(createCell(new PdfPCell(getPrintedByInfo()),150,Cell.ALIGN_LEFT,Cell.NO_BORDER));

            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ADD FOOTER ------------------------------------------------------------------------------
    private void addFooter(){
        String sFooter = getConfigString("footer."+sProject);
        sFooter = sFooter.replaceAll("<br>","\n").replaceAll("<BR>","\n");

        Font font = FontFactory.getFont(FontFactory.HELVETICA,7);
        font.setColor(Color.GRAY);
        HeaderFooter footer = new HeaderFooter(new Phrase(sFooter,font),false);
        footer.disableBorderSide(HeaderFooter.BOTTOM);
        footer.setBorderColor(Color.GRAY);
        footer.setAlignment(HeaderFooter.ALIGN_CENTER);

        doc.setFooter(footer);
    }

    //### PRIVATE METHODS #########################################################################

    //--- GET DEBETS (prestations) ----------------------------------------------------------------
    private PdfPTable getDebets(Wicket wicket, String sFindWicketFromDate, String sFindWicketToDate,PdfPTable table){

        // get debets for specified wicket
        Vector vDebets = Wicket.getDebets(wicket.getUid(),sFindWicketFromDate,sFindWicketToDate,"OC_WICKET_DEBET_OPERATIONDATE","DESC");
        if(vDebets.size() > 0){
            double total = 0;

            // header
            table.addCell(createUnderlinedCell(getTran("web","date"),20));
            cell = createUnderlinedCell(getTran("wicket","amount"),20);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            table.addCell(cell);
            table.addCell(createUnderlinedCell(getTran("wicket","type"),30));
            table.addCell(createUnderlinedCell(getTran("wicket","user"),30));
            table.addCell(createUnderlinedCell(getTran("wicket","comment"),50));

            for(int i=0; i<vDebets.size(); i++){
                total+= printDebet(table,(WicketDebet)vDebets.get(i));
            }

            // spacer
            table.addCell(createEmptyCell(150));

            // display debet total
            table.addCell(createLabelCell(getTran("web","total"),20));
            table.addCell(createTotalPriceCell(total,20));
            table.addCell(createEmptyCell(110));

            this.debetTotal = total;
        }
        else{
            // no data available
            table.addCell(createValueCell(getTran("web","noDataAvailable"),150));
        }

        return table;
    }

    //--- GET CREDITS (payments) ------------------------------------------------------------------
    private PdfPTable getCredits(Wicket wicket, String sWicketFromDate, String sWicketToDate,PdfPTable table){

        // get credits for specified wicket
        Vector vCredits = Wicket.getCredits(wicket.getUid(),sWicketFromDate,sWicketToDate,"OC_WICKET_CREDIT_UPDATETIME","ASC");
        if(vCredits.size() > 0){
            double total = 0;

            // header
            table.addCell(createUnderlinedCell("#",5));
            table.addCell(createUnderlinedCell(getTran("web","date"),15));
            cell = createUnderlinedCell(getTran("wicket","amount"),20);
            cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);
            table.addCell(cell);
            table.addCell(createUnderlinedCell(getTran("wicket","type"),25));
            table.addCell(createUnderlinedCell(getTran("wicket","insurers"),45));
            table.addCell(createUnderlinedCell(getTran("wicket","comment"),40));

            Hashtable ventilatedIncome = new Hashtable();
            Hashtable ventilatedIncomePerService = new Hashtable();
            double totalinsurars=0;
            for(int i=0; i<vCredits.size(); i++){
                WicketCredit credit = (WicketCredit)vCredits.get(i);
                double[] amounts= printCredit(table,credit,i+1);
                total+= amounts[0];
                totalinsurars+= amounts[1];
                ventilateIncome(ventilatedIncome,ventilatedIncomePerService,credit);
            }

            // spacer
            table.addCell(createEmptyCell(150));

            // display credit total
            table.addCell(createLabelCell(getTran("web","total"),20));
            table.addCell(createTotalPriceCell(total,20));
            table.addCell(createEmptyCell(25));
            table.addCell(createTotalPriceCell(totalinsurars,45));
            table.addCell(createEmptyCell(40));

            table.addCell(createEmptyCell(150));
            table.addCell(createBoldLabelCell(getTran("web","credit.ventilation"),150));
            Enumeration incomes = ventilatedIncome.keys();
            while(incomes.hasMoreElements()){
                String category = (String)incomes.nextElement();
                table.addCell(createLabelCell(category,10));
                cell=createPriceCell(((Double)ventilatedIncome.get(category)).doubleValue(),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
            }
            table.addCell(createEmptyCell(10*(5-(ventilatedIncome.size() % 5))));
            table.addCell(createEmptyCell(150));

            this.creditTotal = total;

            table.addCell(createEmptyCell(150));
            table.addCell(createBoldLabelCell(getTran("web","credit.ventilation.perservice"),150));
            incomes = ventilatedIncomePerService.keys();
            Vector i = new Vector();
            while(incomes.hasMoreElements()){
                i.add(incomes.nextElement());
            }
            Collections.sort(i);
            for(int n=0;n<i.size();n++){
                String category = (String)i.elementAt(n);
                table.addCell(createLabelCell(category,30));
                table.addCell(createLabelCell(MedwanQuery.getInstance().getLabel("service",category,sPrintLanguage),70));
                cell=createPriceCell(((Double)ventilatedIncomePerService.get(category)).doubleValue(),30);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                table.addCell(createLabelCell(new DecimalFormat("#").format(Math.round(((Double)ventilatedIncomePerService.get(category)).doubleValue()*100/creditTotal))+"%",30));
            }
        }
        else{
            // no data available
            table.addCell(createValueCell(getTran("web","noDataAvailable"),150));
        }

        return table;
    }

    //--- PRINT DEBET (prestation) ----------------------------------------------------------------
    private double printDebet(PdfPTable wicketTable, WicketDebet debet){
        String sDebetDate = fullDateFormat.format(debet.getOperationDate());
        double debetAmount = debet.getAmount();
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        String sDebetType = ScreenHelper.getTranNoLink("debet.type",debet.getOperationType(),sPrintLanguage),
               sDebetUser = ScreenHelper.getFullUserName(debet.getUpdateUser(),ad_conn);
        try {
			ad_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        // comment
        String sDebetComment = "";
        if(debet.getComment()!=null){
            sDebetComment = debet.getComment().toString();
        }

        // row
        wicketTable.addCell(createValueCell(sDebetDate,20));
        wicketTable.addCell(createPriceCell(debetAmount,20));
        wicketTable.addCell(createValueCell(sDebetType,30));
        wicketTable.addCell(createValueCell(sDebetUser,30));
        wicketTable.addCell(createValueCell(sDebetComment,50));

        return debetAmount;
    }

    //--- PRINT CREDIT (payment) ------------------------------------------------------------------
    private double[] printCredit(PdfPTable wicketTable, WicketCredit credit,int counter){
    	double ti=0;
        String sCreditDate = stdDateFormat.format(credit.getOperationDate());
        double CreditAmount = credit.getAmount();
        String sCreditType = ScreenHelper.getTranNoLink("credit.type",credit.getOperationType(),sPrintLanguage),
               sCreditUser = "";
        // comment
        String sCreditComment = "";
        if(credit.getComment()!=null){
            sCreditComment = credit.getComment().toString();
            if(sCreditComment.split(" - ").length>1){
            	String sInvoiceUid = "1."+ScreenHelper.checkString(sCreditComment.split("-")[sCreditComment.split("-").length-1]).trim();
            	PatientInvoice patientInvoice = null;
            	try{
            		patientInvoice = PatientInvoice.get(sInvoiceUid);
            	}
            	catch(Exception e){
            		e.printStackTrace();
            	}
            	if(patientInvoice!=null && patientInvoice.getUid()!=null && patientInvoice.getUid().equals(sInvoiceUid)){
            		Hashtable insurarAmounts = patientInvoice.getInsurarAmounts();
            		Enumeration e = insurarAmounts.keys();
            		while(e.hasMoreElements()){
            			String ins = (String)e.nextElement();
	            		if(sCreditUser.length()>0){
	            			sCreditUser+="\n";
	            		}
	            		sCreditUser+=ins+": "+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormatInsurar","#")).format(insurarAmounts.get(ins));
	            		ti+=(Double)insurarAmounts.get(ins);
            		}
            		if(sCreditUser.length()==0){
            			sCreditUser="-";
            		}
            	}
            }
        }

        // row
        wicketTable.addCell(createValueCell(counter+"",5));
        wicketTable.addCell(createValueCell(sCreditDate,15));
        wicketTable.addCell(createPriceCell(CreditAmount,20));
        wicketTable.addCell(createMiniValueCell(sCreditType,25));
        wicketTable.addCell(createMiniValueCell(sCreditUser,45));
        wicketTable.addCell(createMiniValueCell(sCreditComment,40));
        double[] amounts =new double[2];
        amounts[0]=CreditAmount;
        amounts[1]=ti;
        return amounts;
    }

    //--- GET SALDO -------------------------------------------------------------------------------
    private PdfPTable getSaldo(Wicket wicket, String sFromDate, String sToDate,PdfPTable table){
        //*** ROW 1 ***
        // debets
        table.addCell(createLabelCell(getTran("web.financial","out"),20));
        table.addCell(createPriceCell(this.debetTotal,20,(this.debetTotal>0?"-":"")));
        table.addCell(createEmptyCell(20));

        // begin situation
        double beginBalance = 0;
        try {
            beginBalance = wicket.calculateBalance(new Date(new SimpleDateFormat("dd/MM/yyyy").parse(sFromDate).getTime()-1));
        } catch (ParseException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        table.addCell(createLabelCell(getTran("web.financial","beginSituation"),20));
        table.addCell(createPriceCell(beginBalance,20));
        table.addCell(createEmptyCell(50));

        //*** ROW 2 ***
        // credits
        table.addCell(createLabelCell(getTran("web.financial","in"),20));
        table.addCell(createPriceCell(this.creditTotal,20,(this.creditTotal>0?"+":"")));
        table.addCell(createEmptyCell(20));

        // saldo
        double saldo = -this.debetTotal + this.creditTotal;
        table.addCell(createLabelCell(getTran("web.financial","saldo"),20));
        table.addCell(createPriceCell(saldo,20,(saldo>0?"+":"")));
        table.addCell(createEmptyCell(50));

        // spacer
        table.addCell(createEmptyCell(3,150));

        //*** ROW 3 (totals) ***
        // saldo
        table.addCell(createBoldLabelCell(getTran("web.financial","saldo").toUpperCase(),20));
        table.addCell(createTotalPriceCell(saldo,20));
        table.addCell(createEmptyCell(20));

        // end situation (balance)
        double endBalance=0;
        if(sToDate.length()==0){
            sToDate=new SimpleDateFormat("dd/MM/yyyy").format(new Date());
        }
        try {
            endBalance = wicket.calculateBalance(new Date(new SimpleDateFormat("dd/MM/yyyy").parse(sToDate).getTime()+24*3600*1000-1)); // now
        } catch (ParseException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        table.addCell(createBoldLabelCell(getTran("web.financial","endSituation").toUpperCase(),20));
        table.addCell(createTotalPriceCell(endBalance,20));
        table.addCell(createEmptyCell(50));

        return table;
    }

    //--- GET "PRINTED BY" INFO -------------------------------------------------------------------
    // active user name and current date
    private PdfPTable getPrintedByInfo(){
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(pageWidth);

        String sPrintedBy = getTran("web","printedby")+" "+user.person.lastname+" "+user.person.firstname+" "+
                            getTran("web","on")+" "+stdDateFormat.format(new java.util.Date());
        table.addCell(createValueCell(sPrintedBy,1));

        return table;
    }


    //##################################### CELL FUNCTIONS ########################################

    //--- CREATE UNDERLINED CELL (font underline) -------------------------------------------------
    protected PdfPCell createUnderlinedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
        cell.setPaddingBottom(5);

        return cell;
    }

    //--- CREATE GRAY CELL (gray background) ------------------------------------------------------
    protected PdfPCell createGrayCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.BOX);
        cell.setBackgroundColor(BGCOLOR_LIGHT);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setBorderColor(innerBorderColor);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);
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
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
        cell.setPadding(padding);

        return cell;
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createMiniValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,6,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PRICE CELL (rigth align, currency) -----------------------------------------------
    protected PdfPCell createPriceCell(double price, int colspan){
        return createPriceCell(price,colspan,"");
    }

    protected PdfPCell createPriceCell(double price, int colspan, String sign){
        String sValue = priceFormat.format(price)+" "+sCurrency;
        if(sign.length() > 0){
            sValue = sign+" "+sValue;
        }

        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);

        return cell;
    }

    //--- CREATE TOTAL PRICE CELL (top border, right align, currency) -----------------------------
    protected PdfPCell createTotalPriceCell(double price, int colspan){
        return createTotalPriceCell(price,colspan,"");
    }

    protected PdfPCell createTotalPriceCell(double price, int colspan, String sign){
        String sValue = priceFormat.format(price)+" "+sCurrency;
        if(sign.length() > 0){
            sValue = sign+" "+sValue;
        }

        cell = new PdfPCell(new Paragraph(sValue,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.TOP);
        cell.setVerticalAlignment(Cell.ALIGN_TOP);
        cell.setHorizontalAlignment(Cell.ALIGN_RIGHT);

        return cell;
    }

    //--- CREATE LABEL CELL (left align) ----------------------------------------------------------
    protected PdfPCell createLabelCell(String label, int colspan){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE BOLD LABEL CELL (left align) -----------------------------------------------------
    protected PdfPCell createBoldLabelCell(String label, int colspan){
        cell = new PdfPCell(new Paragraph(label,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(Cell.NO_BORDER);
        cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(Cell.ALIGN_LEFT);

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
        cell.setBorder(Cell.NO_BORDER);

        return cell;
    }

}
