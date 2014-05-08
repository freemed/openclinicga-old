package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.pdf.official.EndPage;
import be.mxs.common.util.pdf.official.PDFOfficialBasic;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import com.itextpdf.text.*;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.pdf.*;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.*;
import java.awt.*;

import org.hnrw.report.Report_Identification;
import org.hnrw.report.Report_RFE;
import org.hnrw.report.Report_Transaction;
import org.dom4j.io.SAXReader;
import org.dom4j.*;
import org.dom4j.Element;

/**
 * User: stijn smets
 * Date: 21-nov-2006
 */
public class PDFMonthlyReportGenerator extends PDFOfficialBasic {

    // declarations
    private final int pageWidth = 100;
    PdfWriter docWriter=null;

    public void addHeader(){
    }
    public void addContent(){
    }

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public PDFMonthlyReportGenerator(User user, String sProject){
        this.user = user;
        this.sProject = sProject;

        doc = new Document();
    }

    //--- GENERATE PDF DOCUMENT BYTES -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, Date begin, Date end) throws Exception {
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
            doc.setPageSize(PageSize.A4.rotate());
            doc.open();

            // add content to document
            printIdentification(end);
            doc.newPage();
            printConsultationData(begin,end);
            doc.newPage();
            printAdmissionData(begin,end);
            doc.newPage();
            Report_Transaction report_transaction = new Report_Transaction(begin,end);
            printPVVData(begin,end,report_transaction);
            doc.newPage();
            printPrenatalData(begin,end,report_transaction);
            doc.newPage();
            printDeliveryData(begin,end,report_transaction);
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

    //---- ADD PAGE HEADER ------------------------------------------------------------------------
    private void addPageHeader() throws Exception {
    }

    protected void printDeliveryData(Date begin,Date end, Report_Transaction report_transaction){
        try {
            table = new PdfPTable(7);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","delivery.title",user.person.language),14,7,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,7));
            table.addCell(createBorderlessCell("",5,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.dyst",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.hivpos",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.referral",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.dead",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.healthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_TYPE,dystocy;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH,+;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithOutcomeNoLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs","reference")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithOutcomeNoLocation("F","be.mxs.common.model.vo.healthrecord.ICon" +
                    "stants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs","dead")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.outofhealthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","hors.cs")+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MERE_VIH,+;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,hors.cs")+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderlessCell("",5,7));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","delivery.geographic",user.person.language),8,3,Font.BOLD);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.healthcenter",user.person.language),8,3));
            int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT");
            int total=n;
            int a=n;
            table.addCell(createBorderCell(n+"",8,1));
            n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT");
            total+=n;
            table.addCell(createBorderCell(n+"",8,1));
            n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT");
            total+=n;
            table.addCell(createBorderCell(n+"",8,1));
            table.addCell(createBorderCell(total+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.coverage",user.person.language),8,6));
            Report_Identification report_identification = new Report_Identification(end);
            try{
                double expectedPregnant = Double.parseDouble(report_identification.getItem("OC_HC_POPULATION_PREG"));
                long d = end.getTime()-begin.getTime();
                d=d/(1000*3600*24);
                table.addCell(createBorderCell(a*100/(expectedPregnant*d/365)+"",8,1));
            }
            catch(Exception e2){
                e2.printStackTrace();
                table.addCell(createBorderCell("",8,1));
            }
            doc.add(table);
            table = new PdfPTable(8);
            table.addCell(createBorderlessCell("",5,8));
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","delivery.births",user.person.language),10,8,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(createBorderlessCell("",2));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.dead",user.person.language),8,3));
            table.addCell(createBorderlessCell("",2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.lt2.5",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.reference",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.total",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.atbirth",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.birth.inutero",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.healthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","cs")+"",8,1));
            table.addCell(createBorderCell(report_transaction.countSmallerWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_POIDS",2.5)+"",8,1));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_REFERENCE_HD,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs")+"",8,1));
            int mortnenaiss=0,mortneinutero=0;
            mortnenaiss=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,birth;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs");
            mortneinutero=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,inutero;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,cs");
            table.addCell(createBorderCell((mortneinutero+mortnenaiss)+"",8,1));
            table.addCell(createBorderCell(mortnenaiss+"",8,1));
            table.addCell(createBorderCell(mortneinutero+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","delivery.outofhealthcenter",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU","hors.cs")+"",8,1));
            table.addCell(createGreyCell("",1));
            table.addCell(createGreyCell("",1));
            mortnenaiss=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,birth;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,hors.cs");
            mortneinutero=report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_ACCOUCHEMENT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_MORT,inutero;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_ACCOUCHEMENT_LIEU,hors.cs");
            table.addCell(createBorderCell((mortneinutero+mortnenaiss)+"",8,1));
            table.addCell(createGreyCell("",1));
            table.addCell(createGreyCell("",1));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printPrenatalData(Date begin,Date end, Report_Transaction report_transaction){
        try {
            table = new PdfPTable(10);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","prenatal.title",user.person.language),14,10,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,10));
            table.addCell(createBorderCell("",8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,1));
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","prenatal.comment1",user.person.language),8,2));
            int a=addPrenatalRow(begin,end,report_transaction,"cpn.newinscriptions","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","nouvelle.inscription");
            Report_Identification report_identification = new Report_Identification(end);
            try{
                double expectedPregnant = Double.parseDouble(report_identification.getItem("OC_HC_POPULATION_PREG"));
                long d = end.getTime()-begin.getTime();
                d=d/(1000*3600*24);
                table.addCell(createBorderCell(a*100/(expectedPregnant*d/365)+"",8,2));
            }
            catch(Exception e2){
                table.addCell(createBorderCell("",8,2));
            }
            addPrenatalRow(begin,end,report_transaction,"cpn.1.trimestre","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","premier.trimestre");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.2.trimestre","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","deuxieme.trimestre");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.7.8.mois","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","7.8.mois");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.9.mois","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","9.mois");
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","prenatal.comment2",user.person.language),8,2));
            //todo
            int b=addPrenatalRow(begin,end,report_transaction,"cpn.4visits","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","4.visits");
            table.addCell(createBorderCell(b+"",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.othervisits","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TYPE_VISITE","autre");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.grossesse.risque.depistee","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE","true");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.grossesse.rsique.referee","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_GROSSESSE_RISQUE","true","reference");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.total","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.I","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI","I");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.II","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI","II");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.TPI.III","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_TPI","III");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.total","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.1","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","1");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.2","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","2");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.3","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","3");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.4","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","4");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.VAT.5","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_VAT","5");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.fer","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_FER_ACIDE_FOLIQUE","true");
            table.addCell(createBorderlessCell("",8,2));
            addPrenatalRow(begin,end,report_transaction,"cpn.moustiquaire","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_CPN_MOUSTIQUAIRE_IMPREGNEE","true");
            table.addCell(createBorderlessCell("",8,2));
            doc.add(table);

            //PMTCT
            table = new PdfPTable(8);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.title",user.person.language),14,10,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(createBorderCell("",8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,1));
            addPMTCTRow(begin,end,report_transaction,"pmtct.counseling","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_COUNSELLING","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct.vih.tested","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct.rpr.tested","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct..received.results","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RECUPERATION_RESULTATS","true");
            addPMTCTRow(begin,end,report_transaction,"pmtct.with.partner","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE","true");
            table.addCell(createBorderlessCell("",5,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.total.tested",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH","true")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.vihpos",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_VIH,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH,+")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.partner.tested",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE","true")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.vihpos",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_AVEC_PARTENAIRE,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_VIH,+")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.rpr.tested",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR","true")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.rprpos",user.person.language),8,2));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_TESTE_RPR,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_RPR,+")+"",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.eligible.tritherapy",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_ARV","true")+"",8,1));
            table.addCell(createBorderlessCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pmtct.eligible.prophylaxie",user.person.language),8,4));
            table.addCell(createBorderCell(report_transaction.countWithoutLocation("F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PMTCT_ELIGIBLE_PROPHYLAXIE","true")+"",8,1));
            table.addCell(createBorderlessCell("",8,3));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private int addPrenatalRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    private int addPrenatalRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype,String itemvalue){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    private int addPMTCTRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype,String itemvalue){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.count("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT",itemtype,itemvalue);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PMTCT",itemtype,itemvalue);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    private int addPrenatalRow(Date begin,Date end, Report_Transaction report_transaction,String label,String itemtype,String itemvalue,String outcome){
        table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly",label,user.person.language),8,4));
        int n=report_transaction.countWithOutcome("1","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue,outcome);
        int a=n;
        int tot=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.countWithOutcome("2","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue,outcome);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.countWithOutcome("3","F","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_CPN",itemtype,itemvalue,outcome);
        tot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(tot+"",8,1));
        return a;
    }

    protected void printPVVData(Date begin,Date end, Report_Transaction report_transaction){
        try {
            table = new PdfPTable(24);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title",user.person.language),14,24,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,24));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.depistage",user.person.language),8,24,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,24));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","pvv.categories",user.person.language),8,10));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt35y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.35to50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,10));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.individual",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECU_INDIVIDUELLEMENT","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.counseled",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_CONSEILLE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.tested",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TESTE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.couples.tested",user.person.language),8,10));
            addPVVRowTotalsOnly(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PARTENAIRE_TESTE,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TESTE,true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.retrievedresults",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECUPERATION_RESULTATS","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.testedvihpos",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH","+");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.testedvihposwithresult",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH,+;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_RECUPERATION_RESULTATS,true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.partners.tested",user.person.language),8,10));
            addPVVRowTotalsOnly(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PARTENAIRE_TESTE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.couples.serodiscordance",user.person.language),8,10));
            addPVVRowTotalsOnly(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SERODISCORDANCE","true");
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.clients.followup",user.person.language),8,10));
            addPVVRow(report_transaction,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_SUIVI_VIH,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_VIH,+");
            doc.add(table);

            //Suivi
            table = new PdfPTable(12);
            table.setWidthPercentage(pageWidth/2);
            table.setHorizontalAlignment(PdfPTable.ALIGN_LEFT);
            table.addCell(createBorderlessCell("",5,12));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.followup",user.person.language),8,12,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,12));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","pvv.followup",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt15y",user.person.language),8,6));
            addPVVFollowUpRow(report_transaction,0,5474);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt25y",user.person.language),8,6));
            addPVVFollowUpRow(report_transaction,5475,9124);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.adults",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt35y",user.person.language),8,3));
            addPVVFollowUpRow(report_transaction,9125,12774);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt50y",user.person.language),8,3));
            addPVVFollowUpRow(report_transaction,12775,18249);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.mt50y",user.person.language),8,3));
            addPVVFollowUpRow(report_transaction,18250,36500);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,6));
            addPVVFollowUpRow(report_transaction,0,36500);
            doc.add(table);

            //Prise en charge
            table = new PdfPTable(36);
            table.setWidthPercentage(pageWidth);
            table.addCell(createBorderlessCell("",5,36));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","pvv.title.care",user.person.language),8,36,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,36));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","pvv.patient.categories",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.underarv",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.iotreatment",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.isttreatment",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.bactrim",user.person.language),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.tbc",user.person.language),8,6));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.nc",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.ac",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt15y",user.person.language),8,6));
            addPVVCareRow(report_transaction,0,5474);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt25y",user.person.language),8,6));
            addPVVCareRow(report_transaction,5475,9124);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.adults",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt35y",user.person.language),8,3));
            addPVVCareRow(report_transaction,9125,12774);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.lt50y",user.person.language),8,3));
            addPVVCareRow(report_transaction,12775,18249);
            table.addCell(createBorderCell("",8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.mt50y",user.person.language),8,3));
            addPVVCareRow(report_transaction,18250,36500);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","pvv.total",user.person.language),8,6));
            addPVVCareRow(report_transaction,0,36500);
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    private void addPVVCareRow(Report_Transaction report_transaction,int minage,int maxage){
        int mtot=0,ftot=0,n=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_ARV,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IO,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_IST,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_PREVENTION_AU_BACTRIM,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_TRAITEMENT_TBC,true;be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS,no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
        mtot=0;
        ftot=0;
    }

    private void addPVVFollowUpRow(Report_Transaction report_transaction,int minage,int maxage){
        int mtot=0,ftot=0,n=0;
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","yes");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","yes");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"m","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","no");
        mtot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        n=report_transaction.count(minage,maxage,"f","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CS_PVV","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CS_PVV_NOUVEAU_CAS","no");
        ftot+=n;
        table.addCell(createBorderCell(n+"",8,1));
        table.addCell(createBorderCell(mtot+"",8,1));
        table.addCell(createBorderCell(ftot+"",8,1));
    }

    private void addPVVRow(Report_Transaction report_transaction,String transactionType,String itemType,String itemValue){
        table.addCell(createBorderCell(report_transaction.count(0,1824,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,1824,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"f",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,itemType,itemValue)+"",8,1));
    }

    private void addPVVRow(Report_Transaction report_transaction,String transactionType,String item){
        table.addCell(createBorderCell(report_transaction.count(0,1824,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,1824,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(1825,5474,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(5475,9124,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(9125,12774,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(12775,18249,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(18250,36500,"f",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,item)+"",8,1));
    }

    private void addPVVRowTotalsOnly(Report_Transaction report_transaction,String transactionType,String itemType,String itemValue){
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,itemType,itemValue)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,itemType,itemValue)+"",8,1));
    }

    private void addPVVRowTotalsOnly(Report_Transaction report_transaction,String transactionType,String item){
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createGreyCell(""));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"m",transactionType,item)+"",8,1));
        table.addCell(createBorderCell(report_transaction.count(0,36500,"f",transactionType,item)+"",8,1));
    }

    protected void printConsultationData(Date begin, Date end){
        try {
            table = new PdfPTable(24);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","consultation.title",user.person.language),14,24,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,24));
            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","consultation.newcases",user.person.language),8,8));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt30d",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt12m",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,2));
            table.addCell(createBorderCell("",8,8));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            Report_RFE report_rfe = new Report_RFE(begin,end,"visit");
            SAXReader saxReader = new SAXReader(false);
            org.dom4j.Document document = saxReader.read(MedwanQuery.getInstance().getConfigString("templateSource")+"/monthlyreport.consultations.xml");
            Element root = document.getRootElement();
            Element consultations = root.element("consultations");
            Iterator rfes = consultations.elementIterator("rfe");
            String language="fr";
            if(user.person.language.toLowerCase().startsWith("e")){
                language="en";
            }
            else if(user.person.language.toLowerCase().startsWith("n")){
                language="nl";
            }
            int counter=0;
            while(rfes.hasNext()){
                //First print disease label
                Element rfe = (Element)rfes.next();
                table.addCell(createBorderCell(rfe.attributeValue(language),8,8));
                String codes = rfe.attributeValue("codes");
                String flags = rfe.attributeValue("flags");
                Iterator cases = rfe.elementIterator("case");
                counter=0;
                while(cases.hasNext()){
                    counter++;
                    Element c = (Element)cases.next();
                    if(c.attributeCount()==0){
                        table.addCell(createGreyCell("",1));
                    }
                    else {
                        int minage = Integer.parseInt(c.attributeValue("minage"));
                        int maxage = Integer.parseInt(c.attributeValue("maxage"));
                        String gender = c.attributeValue("gender");
                        int count = report_rfe.count(codes,gender,minage,maxage,flags);
                        if(count==0){
                            cell=createBorderCell(count+"",8,1,BaseColor.LIGHT_GRAY);
                        }
                        else {
                            cell=createBorderCellBold(count+"",8,1);
                        }
                        table.addCell(cell);
                    }
                }
                if(counter<16){
                    table.addCell(emptyCell(16-counter));
                }
            }
            //nu nog de 'andere' ziekten uitlijsten
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.reasons",user.person.language),8,8));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            Element otherrfe = consultations.element("otherrfe");
            //Nu alle overblijvende RFE's opvragen
            Hashtable uncounted = report_rfe.getUncountedRFEs();
            Iterator i = uncounted.values().iterator();
            while(i.hasNext()){
                Report_RFE.RFE uncountedRfe = (Report_RFE.RFE)i.next();
                if(uncountedRfe.isNewcase()){
                    table.addCell(createBorderCell(MedwanQuery.getInstance().getCodeTran(uncountedRfe.getCodeType()+"code"+uncountedRfe.getCode(),language),8,8));
                    Iterator cases = otherrfe.elementIterator("case");
                    counter=0;
                    while(cases.hasNext()){
                        counter++;
                        Element c = (Element)cases.next();
                        if(c.attributeCount()==0){
                            table.addCell(createGreyCell("",1));
                        }
                        else {
                            int minage = Integer.parseInt(c.attributeValue("minage"));
                            int maxage = Integer.parseInt(c.attributeValue("maxage"));
                            String gender = c.attributeValue("gender");
                            int count = report_rfe.count(uncountedRfe.getCodeType()+":"+uncountedRfe.getCode(),gender,minage,maxage,"N");
                            if(count==0){
                                cell=createBorderCell(count+"",8,1,BaseColor.LIGHT_GRAY);
                            }
                            else {
                                cell=createBorderCellBold(count+"",8,1);
                            }
                            table.addCell(cell);
                        }
                    }
                }
            }
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,8));
            Iterator cases = otherrfe.elementIterator("case");
            counter=0;
            while(cases.hasNext()){
                counter++;
                Element c = (Element)cases.next();
                if(c.attributeCount()==0){
                    table.addCell(createGreyCell("",1));
                }
                else {
                    int minage = Integer.parseInt(c.attributeValue("minage"));
                    int maxage = Integer.parseInt(c.attributeValue("maxage"));
                    String gender = c.attributeValue("gender");
                    int count = report_rfe.count("ICPC:A-Z9999;ICD10:A-Z99.9",gender,minage,maxage,"N");
                    if(count==0){
                        cell=createBorderCell(count+"",8,1,BaseColor.GRAY);
                    }
                    else {
                        cell=createBorderCellBold(count+"",8,1);
                    }
                    table.addCell(cell);
                }
            }
            if(counter<16){
                table.addCell(emptyCell(16-counter));
            }
            doc.add(table);
            table = new PdfPTable(16);
            table.setWidthPercentage(pageWidth);
            cell=createLabel("\n"+MedwanQuery.getInstance().getLabel("report.monthly","consultation.synthetictable",user.person.language)+"\n",8,16,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.consultations",user.person.language),2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.insured",user.person.language),8,2));
            table.addCell(emptyCell(4));
            table.addCell(emptyCell(2));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(emptyCell(4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.newcases",user.person.language),8,2));
            table.addCell(createBorderCell(report_rfe.countLocations("1",true,"M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("1",true,"F")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("2",true,"M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("2",true,"F")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("3",true,"M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("3",true,"F")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countNewCases("M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countNewCases("F")+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.newcases.notpaying",user.person.language),8,2));
            table.addCell(createBorderCell("",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.oldcases",user.person.language),8,2));
            table.addCell(createGreyCell(""));
            table.addCell(createGreyCell(""));
            table.addCell(createGreyCell(""));
            table.addCell(createGreyCell(""));
            table.addCell(createGreyCell(""));
            table.addCell(createGreyCell(""));
            table.addCell(createBorderCell(report_rfe.countOldCases("M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countOldCases("F")+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.ofwhom",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,2));
            table.addCell(createBorderCell(report_rfe.countLocations("1","M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("1","F")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("2","M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("2","F")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("3","M")+"",8,1));
            table.addCell(createBorderCell(report_rfe.countLocations("3","F")+"",8,1));
            table.addCell(createBorderCell((report_rfe.countNewCases("M")+report_rfe.countOldCases("M"))+"",8,1));
            table.addCell(createBorderCell((report_rfe.countNewCases("F")+report_rfe.countOldCases("F"))+"",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.newcases.indigents",user.person.language),8,2));
            table.addCell(createBorderCell("",8,2));
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printAdmissionData(Date begin, Date end){
        try {
            Report_Identification report_identification = new Report_Identification(end);
            table = new PdfPTable(46);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","admission.title",user.person.language),14,46,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,46));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.numberofbeds",user.person.language),8,6));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_BEDS"),8,4));
            table.addCell(createBorderlessCell("",36));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.presentatstart",user.person.language),8,6));
            int presents=Encounter.getAdmittedOn(begin,"admission");
            table.addCell(createBorderCell(presents+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.zone",user.person.language),8,11));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofzone",user.person.language),8,11));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.outofdistrict",user.person.language),8,11));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.entries",user.person.language),8,6));
            int entrants=Encounter.getEnteredBetween(begin,end,"admission");
            table.addCell(createBorderCell(entrants+"",8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ofwhom",user.person.language),8,3));
            table.addCell(createBorderCell(Encounter.getEnteredBetween(begin,end,"1","admission")+"",8,11));
            table.addCell(createBorderCell(Encounter.getEnteredBetween(begin,end,"2","admission")+"",8,11));
            table.addCell(createBorderCell(Encounter.getEnteredBetween(begin,end,"3","admission")+"",8,11));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.discharges",user.person.language),8,6));
            int sortants=Encounter.getLeftBetween(begin,end,"admission");
            table.addCell(createBorderCell(sortants+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.entries.mutuelle",user.person.language),8,22));
            table.addCell(createBorderCell("",8,11));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.better",user.person.language),8,3));
            table.addCell(createBorderCell(Encounter.getLeftBetweenForOutcome(begin,end,"better","admission")+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.entries.potentialdays",user.person.language),8,22));
            long durationInDays = end.getTime()-begin.getTime();
            durationInDays=1+Math.round(durationInDays/(1000*3600*24));
            int beds = 0;
            try{                beds=Integer.parseInt(report_identification.getItem("OC_HC_BEDS"));
            }
            catch(Exception e){
                e.printStackTrace();
            }
            long potential=beds*durationInDays;
            table.addCell(createBorderCell(potential+"",8,11));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","ofwhom",user.person.language),8,3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.died",user.person.language),8,3));
            table.addCell(createBorderCell(Encounter.getLeftBetweenForOutcome(begin,end,"dead","admission")+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.entries.effectivedays",user.person.language),8,22));
            int days=Encounter.getDaysBetween(begin,end,"admission");
            table.addCell(createBorderCell(days+"",8,11));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.escaped",user.person.language),8,3));
            table.addCell(createBorderCell(Encounter.getLeftBetweenForOutcome(begin,end,"escape","admission")+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.entries.leavingdays",user.person.language),8,22));
            int leavingdays=Encounter.getLeavingDaysBetween(begin,end,"admission");
            table.addCell(createBorderCell(leavingdays+"",8,11));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.reference",user.person.language),8,3));
            table.addCell(createBorderCell(Encounter.getLeftBetweenForOutcome(begin,end,"reference","admission")+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.occupationlevel",user.person.language),8,22));
            table.addCell(createBorderCell(potential!=0?days*100/potential+"%":"?",8,11));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.presentatend",user.person.language),8,6));
            table.addCell(createBorderCell((presents+entrants-sortants)+"",8,4));
            table.addCell(createBorderlessCell("",3));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.meanduration",user.person.language),8,22));
            table.addCell(createBorderCell(sortants!=0?leavingdays/sortants+"":"?",8,11));
            table.addCell(createBorderlessCell("",5,46));

            table.addCell(createBorderCellBold(MedwanQuery.getInstance().getLabel("report.monthly","admission.reasonsforadmission",user.person.language),8,10));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt30d",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt12m",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt50y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.pregnantwomen",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.total",user.person.language),8,4));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.atdischarge",user.person.language),8,10));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("#",8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.days",user.person.language),8,2));
            table.addCell(createBorderCell("",8,10));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("F",8,2));
            table.addCell(createBorderCell("F",8,2));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            table.addCell(createBorderCell("M",8,1));
            table.addCell(createBorderCell("F",8,1));
            Report_RFE report_rfe = new Report_RFE(begin,end,"admission");
            SAXReader saxReader = new SAXReader(false);
            org.dom4j.Document document = saxReader.read(MedwanQuery.getInstance().getConfigString("templateSource")+"/monthlyreport.admissions.xml");
            Element root = document.getRootElement();
            Element consultations = root.element("admissions");
            Iterator rfes = consultations.elementIterator("rfe");
            String language="fr";
            if(user.person.language.toLowerCase().startsWith("e")){
                language="en";
            }
            else if(user.person.language.toLowerCase().startsWith("n")){
                language="nl";
            }
            int counter=0;
            while(rfes.hasNext()){
                //First print disease label
                Element rfe = (Element)rfes.next();
                table.addCell(createBorderCell(rfe.attributeValue(language),8,10));
                String codes = rfe.attributeValue("codes");
                String flags = rfe.attributeValue("flags");
                Iterator cases = rfe.elementIterator("case");
                counter=10;
                while(cases.hasNext()){
                    Element c = (Element)cases.next();
                    if(c.attributeCount()==0){
                        table.addCell(createGreyCell("",1));
                        counter++;
                    }
                    else {
                        int minage = Integer.parseInt(c.attributeValue("minage"));
                        int maxage = Integer.parseInt(c.attributeValue("maxage"));
                        String gender = c.attributeValue("gender");
                        int count;
                        if("yes".equalsIgnoreCase(c.attributeValue("days"))){
                            count = report_rfe.countDuration(codes,gender,minage,maxage,flags+("yes".equalsIgnoreCase(c.attributeValue("pregnant"))?"E":""));
                        }
                        else {
                            count = report_rfe.count(codes,gender,minage,maxage,flags+("yes".equalsIgnoreCase(c.attributeValue("pregnant"))?"E":""));
                        }
                        if(count==0){
                            cell=createBorderCell(count+"",7,(ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1),BaseColor.LIGHT_GRAY);
                        }
                        else {
                            cell=createBorderCellBold(count+"",7,(ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1));
                        }
                        table.addCell(cell);
                        counter+=(ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1);
                    }
                }
                if(counter<46){
                    table.addCell(emptyCell(46-counter));
                }
            }
            //nu nog de 'andere' ziekten uitlijsten
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","consultation.other.reasons",user.person.language),8,10));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,2));
            table.addCell(createBorderCell("",8,2));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            table.addCell(createBorderCell("",8,1));
            Element otherrfe = consultations.element("otherrfe");
            //Nu alle overblijvende RFE's opvragen
            Hashtable uncounted = report_rfe.getUncountedRFEs();
            Iterator i = uncounted.values().iterator();
            while(i.hasNext()){
                Report_RFE.RFE uncountedRfe = (Report_RFE.RFE)i.next();
                if(uncountedRfe.isNewcase()){
                    table.addCell(createBorderCell(MedwanQuery.getInstance().getCodeTran(uncountedRfe.getCodeType()+"code"+uncountedRfe.getCode(),language),8,10));
                    Iterator cases = otherrfe.elementIterator("case");
                    counter=10;
                    while(cases.hasNext()){
                        Element c = (Element)cases.next();
                        counter+=ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1;
                        if(c.attributeCount()==0){
                            table.addCell(createGreyCell("",1));
                        }
                        else {
                            int minage = Integer.parseInt(c.attributeValue("minage"));
                            int maxage = Integer.parseInt(c.attributeValue("maxage"));
                            String gender = c.attributeValue("gender");
                            int count;
                            if("yes".equalsIgnoreCase(c.attributeValue("days"))){
                                count = report_rfe.countDuration(uncountedRfe.getCodeType()+":"+uncountedRfe.getCode(),gender,minage,maxage,"N");
                            }
                            else {
                                count = report_rfe.count(uncountedRfe.getCodeType()+":"+uncountedRfe.getCode(),gender,minage,maxage,"N");
                            }
                            if(count==0){
                                cell=createBorderCell(count+"",8,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1,BaseColor.LIGHT_GRAY);
                            }
                            else {
                                cell=createBorderCellBold(count+"",8,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1);
                            }
                            table.addCell(cell);
                        }
                    }
                }
            }
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","admission.total",user.person.language),8,10));
            Iterator cases = otherrfe.elementIterator("case");
            counter=10;
            while(cases.hasNext()){
                Element c = (Element)cases.next();
                counter+=ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1;
                if(c.attributeCount()==0){
                    table.addCell(createGreyCell("",1));
                }
                else {
                    int minage = Integer.parseInt(c.attributeValue("minage"));
                    int maxage = Integer.parseInt(c.attributeValue("maxage"));
                    String gender = c.attributeValue("gender");
                    int count;
                    if("yes".equalsIgnoreCase(c.attributeValue("days"))){
                        count = report_rfe.countDuration("ICPC:A-Z9999;ICD10:A-Z99.9",gender,minage,maxage,"N");
                    }
                    else {
                        count = report_rfe.count("ICPC:A-Z9999;ICD10:A-Z99.9",gender,minage,maxage,"N");
                    }
                    if(count==0){
                        cell=createBorderCell(count+"",8,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1,BaseColor.GRAY);
                    }
                    else {
                        cell=createBorderCellBold(count+"",8,ScreenHelper.checkString(c.attributeValue("colspan")).length()>0?Integer.parseInt(c.attributeValue("colspan")):1);
                    }
                    table.addCell(cell);
                }
            }
            if(counter<46){
                table.addCell(emptyCell(46-counter));
            }
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void printIdentification(Date end){
        try {
            Report_Identification report_identification = new Report_Identification(end);
            table = new PdfPTable(16);
            table.setWidthPercentage(pageWidth);
            table.addCell(createLabel(MedwanQuery.getInstance().getLabel("report.monthly","title",user.person.language),14,16,Font.BOLD));
            table.addCell(createBorderlessCell("",5,16));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","identification.title",user.person.language),14,16,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderlessCell("",5,16));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","year",user.person.language),8,2));
            table.addCell(createBorderCell(new SimpleDateFormat("yyyy").format(end),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","month",user.person.language),8,2));
            table.addCell(createBorderCell(new SimpleDateFormat("MM").format(end),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","province",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_PROVINCE"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","district",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_DISTRICT"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","zone",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_ZONE"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","sector",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_SECTEUR"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","fosa",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_FOSA"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","cell",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_CELL"),8,6));
            table.addCell(emptyCell(16));
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","identification.remarks",user.person.language),8,16,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","epidemiology",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_EPIDEMIOLOGIE"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","drugs",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_DRUGS"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","vaccinations",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_VACCINATIONS"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","equipment",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_EQUIPMENT"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","building",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_BUILDING"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","transport",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_TRANSPORT"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","personnel",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_PERSONNEL"),8,12));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","other",user.person.language),8,4));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_REM_OTHER"),8,12));
            table.addCell(emptyCell(16));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","contactname",user.person.language),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_CONTACTNAME"),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datesent",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","qualification",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datereceived",user.person.language),8,2));
            table.addCell(createBorderCell("",8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datecreated",user.person.language),8,2));
            table.addCell(createBorderCell(ScreenHelper.stdDateFormat.format(new Date()),8,6));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","signature",user.person.language),8,2));
            table.addCell(createBorderCell("\n\n\n\n\n",8,6));
            table.addCell(emptyCell(8));
            doc.add(table);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","datecreated",user.person.language),8,2));

            table = new PdfPTable(12);
            table.setWidthPercentage(pageWidth);
            cell=createLabel(MedwanQuery.getInstance().getLabel("report.monthly","title.population",user.person.language),8,12,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            table.addCell(cell);
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.total.zone",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.total.insured",user.person.language),8,2));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt30d",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt12m",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt5y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt15y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt25y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.lt50y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.mt50y",user.person.language),8,1));
            table.addCell(createBorderCell(MedwanQuery.getInstance().getLabel("report.monthly","population.pregnant",user.person.language),8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_TOTAL"),8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_MUT")+"%",8,2));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT1M")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT1Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT5Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT25Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT25Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_LT50Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_MT50Y")+"%",8,1));
            table.addCell(createBorderCell(report_identification.getItem("OC_HC_POPULATION_PREG")+"/"+MedwanQuery.getInstance().getLabel("web","year",user.person.language),8,1));
            table.addCell(createBorderlessCell(MedwanQuery.getInstance().getLabel("report.monthly","population.source",user.person.language),12));
            table.addCell(emptyCell(12));
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

    protected PdfPCell createBorderCell(String value, int fontsize, int colspan, BaseColor color){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.NORMAL,color)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderCell(String value, int fontsize, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderCellBold(String value, int fontsize, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontsize,Font.BOLD)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
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