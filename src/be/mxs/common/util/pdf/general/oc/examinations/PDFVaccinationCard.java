package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;
import com.itextpdf.text.Font;
import java.awt.*;
import java.util.Iterator;
import java.util.Date;
import java.text.SimpleDateFormat;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import net.admin.AdminPerson;

import javax.servlet.http.HttpServletRequest;

/**
 * User: Frank
 * Date: 1-mrt-2005
 */
public class PDFVaccinationCard extends PDFGeneralBasic {

    public void addContent(){} // to extend PDFBasic

    //--- PRINT CARD -------------------------------------------------------------------------------
    // Header not based on TransactionVO, but included in the content.
    // Print() in PDFBasic is not used.
    //----------------------------------------------------------------------------------------------
    public void printCard(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                          AdminPerson adminPerson, HttpServletRequest req, String sProject, String sPrintLanguage,
                          Integer partsOfTransactionToPrint){

        this.doc = doc;
        this.sessionContainerWO = sessionContainerWO;
        this.transactionVO = transactionVO;
        this.sPrintLanguage = sPrintLanguage;
        this.patient = adminPerson;
        this.req = req;
        this.sProject = sProject;

        tranTable = new PdfPTable(1);
        addContent(tranTable,sessionContainerWO);
        addTransactionToDoc();
    }

    //--- ADD CONTENT -----------------------------------------------------------------------------
    private void addContent(PdfPTable tranTable, SessionContainerWO sessionContainerWO){
        try{
            Iterator transactions = MedwanQuery.getInstance().getVaccinations(sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue()).iterator();
            if(transactions.hasNext()){
                table = new PdfPTable(5);

                // declarations
                String activeVaccination = "";
                TransactionVO tran;
                int border;
                boolean bShowNext;
                Paragraph par;

                // title
                cell = new PdfPCell(new Paragraph(getTran("Web.Occup","medwan.common.vaccination-card").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
                cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
                cell.setBorder(PdfPCell.BOX);
                tranTable.addCell(cell);

                boolean headerAdded = false;

                // list vaccinations
                while(transactions.hasNext()){
                    tran = (TransactionVO)transactions.next();

                    if(!headerAdded){
                        // header
                        table.addCell(createHeaderCell(getTran("web","type"),1));
                        table.addCell(createHeaderCell(getTran("web","date"),1));
                        table.addCell(createHeaderCell(getTran("web","status"),1));
                        table.addCell(createHeaderCell(getTran("web","comment"),1));
                        table.addCell(createHeaderCell(getTran("web.occup","be.mxs.healthrecord.vaccination.next"),1));

                        headerAdded = true;
                    }

                    // type
                    if(getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_TYPE).toUpperCase().indexOf("INTRADERMO")==-1){
                        border = PdfPCell.NO_BORDER;
                        bShowNext = false;

                        if(!activeVaccination.equalsIgnoreCase(getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_TYPE))){
                            // Set new vaccination title
                            cell = new PdfPCell(new Paragraph(getTran("Web.Occup",getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_TYPE)).toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD)));
                            activeVaccination = getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_TYPE);
                            border = PdfPCell.TOP;
                            bShowNext = true;
                        }
                        else{
                            cell = new PdfPCell();
                        }

                        if(!transactions.hasNext()){
                            border+= PdfPCell.BOTTOM;
                        }

                        cell.setBorder(border+PdfPCell.LEFT);
                        cell.setColspan(1);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                        cell.setBorderColor(BaseColor.LIGHT_GRAY);
                        table.addCell(cell);

                        // VACCINATION_DATE / VACCINATION_STATUS / COMMENT
                        table.addCell(createCell(new PdfPCell(new Paragraph(getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_DATE),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL))),1,PdfPCell.ALIGN_MIDDLE,border));
                        table.addCell(createCell(new PdfPCell(new Paragraph(getTran("Web.Occup",getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_STATUS)),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL))),1,PdfPCell.ALIGN_MIDDLE,border));
                        table.addCell(createCell(new PdfPCell(new Paragraph(getTran("Web.Occup",getItemValue(tran,IConstants.ITEM_TYPE_COMMENT)),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL))),1,PdfPCell.ALIGN_MIDDLE,border));

                        // NEXT DATE
                        if(bShowNext){
                            par = new Paragraph(getTran("Web.Occup","be.mxs.healthrecord.vaccination.next").toUpperCase()+": ",FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC));
                            try{
                                if(new SimpleDateFormat("dd/MM/yyyy").parse(getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE)).before(new Date())){
                                    par.add(new Chunk(getTran("Web.Occup",getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE)),FontFactory.getFont(FontFactory.HELVETICA,8,Font.BOLD,BaseColor.RED)));
                                }
                                else{
                                    par.add(new Chunk(getTran("Web.Occup",getItemValue(tran,IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE)),FontFactory.getFont(FontFactory.HELVETICA,8,Font.NORMAL)));
                                }
                            }
                            catch(Exception e){
                                e.printStackTrace();
                            }

                            cell = new PdfPCell(par);
                        }
                        else{
                            cell = new PdfPCell();
                        }

                        cell.setColspan(1);
                        cell.setBorder(border+PdfPCell.RIGHT);
                        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                        cell.setBorderColor(BaseColor.LIGHT_GRAY);
                        table.addCell(cell);
                    }
                }

                tranTable.addCell(createContentCell(table));
            }
        }
        catch(Exception e){
             e.printStackTrace();
        }
    }
}
