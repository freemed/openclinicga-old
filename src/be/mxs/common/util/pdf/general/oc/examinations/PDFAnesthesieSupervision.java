package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;

/**
 * User: ssm
 * Date: 13-jul-2007
 */
public class PDFAnesthesieSupervision extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                contentTable = new PdfPTable(1);
                PdfPTable superVisionsTable = new PdfPTable(20);

                String sSuperVisions = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_ANESTHESIE_SUPERVISION");
                if (sSuperVisions.indexOf("£")>-1){
                    StringBuffer sTmpSuperVision = new StringBuffer(sSuperVisions);
                    String sTmpHeure, sTmpSys, sTmpDias, sTmpRythme, sTmpStage, sTmpFreq, sTmpSat, sTmpMedication;

                    while (sTmpSuperVision.toString().toLowerCase().indexOf("$")>-1) {
                        sTmpHeure = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpHeure = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpSys = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpSys = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpDias = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpDias = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpRythme = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpRythme = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpStage = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpStage = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpFreq = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpFreq = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpSat = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("£")>-1){
                            sTmpSat = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("£"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("£")+1));
                        }

                        sTmpMedication = "";
                        if (sTmpSuperVision.toString().toLowerCase().indexOf("$")>-1){
                            sTmpMedication = sTmpSuperVision.substring(0,sTmpSuperVision.toString().toLowerCase().indexOf("$"));
                            sTmpSuperVision = new StringBuffer(sTmpSuperVision.substring(sTmpSuperVision.toString().toLowerCase().indexOf("$")+1));
                        }

                        // add record
                        superVisionsTable = addSuperVisionToPDFTable(superVisionsTable,sTmpHeure,sTmpSys,sTmpDias,sTmpRythme,sTmpStage,sTmpFreq,sTmpSat,sTmpMedication);
                    }
                }

                // add table to transaction
                if(superVisionsTable.size() > 0){
                    if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                    contentTable.addCell(createCell(new PdfPCell(superVisionsTable),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
                    tranTable.addCell(createContentCell(contentTable));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD SUPERVISION TO PDF TABLE ------------------------------------------------------------
    private PdfPTable addSuperVisionToPDFTable(PdfPTable pdfTable, String sHeure, String sSys,
                                               String sDias, String sRythme, String sStage,
                                               String sFreq, String sSat, String sMedication){
                    
        // add double header if no header yet
        if(pdfTable.size() == 0){
            // main header
            pdfTable.addCell(createInvisibleCell(2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","ta"),2));
            pdfTable.addCell(createInvisibleCell(16));

            // sub header
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","sys"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","dias"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","heartfrequency"),2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","stage"),3));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","respiration"),2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","sa")+" O2",2));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","medication"),7));
        }

        pdfTable.addCell(createValueCell(sHeure,2));
        pdfTable.addCell(createValueCell(sSys,1));
        pdfTable.addCell(createValueCell(sDias,1));
        pdfTable.addCell(createValueCell(sRythme+" /"+getTran("units","minute"),2));
        pdfTable.addCell(createValueCell(getTran("anesthesie_stage",sStage),3));
        pdfTable.addCell(createValueCell(sFreq+" /"+getTran("units","minute"),2));
        pdfTable.addCell(createValueCell(sSat+" "+getTran("units","percentage"),2));
        pdfTable.addCell(createValueCell(sMedication,7));

        return pdfTable;
    }
}

