package be.mxs.common.util.pdf.general.oc.examinations;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.model.vo.healthrecord.ItemVO;

import java.util.Vector;
import java.util.Iterator;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
      
/**
 * User: ssm
 * Date: 18-jul-2007
 */
public class PDFKinesitherapyConsultationTreatment extends PDFGeneralBasic {

    //--- ADD CONTENT -----------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                addVaria1();
                addSeances();
                addVaria2();
                addTransactionToDoc();

                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS #########################################################################

    //--- ADD VARIA 1 -----------------------------------------------------------------------------
    private void addVaria1(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // context
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONTEXT");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","context"),getTran("web.occup",itemValue).toLowerCase());
        }

        // medical.history
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_MEDICAL_HISTORY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","medical.history"),itemValue);
        }

        // physio.therapy
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_PHYSIO_THERAPY");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","physio.therapy"),itemValue);
        }

        //*** DIAGNOSTICS ***
        PdfPTable diagnosticsTable = new PdfPTable(1);

        try{
            Iterator items = transactionVO.getItems().iterator();
            String codeTran;
            ItemVO item;

            while(items.hasNext()){
                item = (ItemVO)items.next();

                // ICPC
                if(item.getType().startsWith("ICPCCode")){
                    codeTran = MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage);
                    diagnosticsTable.addCell(createValueCell(item.getType().replaceAll("ICPCCode","")+" "+codeTran+" "+item.getValue().trim()));
                }
                // ICD10
                else if(item.getType().startsWith("ICD10Code")){
                    codeTran = MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage);
                    diagnosticsTable.addCell(createValueCell(item.getType().replaceAll("ICD10Code","")+" "+codeTran+" "+item.getValue().trim()));
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // add diagnostics table
        if(diagnosticsTable.size() > 0){
            table.addCell(createItemNameCell(getTran("openclinic.chuk","diagnostic")+" "+getTran("Web.Occup","ICPC-2")+" / "+getTran("Web.Occup","ICD-10"),2));
            table.addCell(createCell(new PdfPCell(diagnosticsTable),3,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
        }

        // nr.of.meetings
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_NR_OF_MEETINGS");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","nr.of.meetings"),itemValue);
        }

        // startdate
        itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE");
        if(itemValue.length() > 0){
            addItemRow(table,getTran("openclinic.chuk","startdate"),itemValue);
        }

        // add table to transaction
        if(table.size() > 0){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(new PdfPCell(contentTable));
        }
    }

    //--- ADD SEANCES -----------------------------------------------------------------------------
    private void addSeances(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(1);
            
        PdfPTable seancesTable = new PdfPTable(12);
        String sSeances = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_SEANCE");
        if (sSeances.indexOf("£")>-1){
            StringBuffer sTmpSeances = new StringBuffer(sSeances);
            String sTmpDate, sTmpHeure, sTmpTreatment1, sTmpTreatment2, sTmpTreatment3;

            while (sTmpSeances.toString().toLowerCase().indexOf("$")>-1) {
                sTmpDate  = "";
                if (sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpDate = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpHeure = "";
                if (sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpHeure = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTreatment1 = "";
                if (sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTreatment1 = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTreatment2 = "";
                if (sTmpSeances.toString().toLowerCase().indexOf("£")>-1){
                    sTmpTreatment2 = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("£"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("£")+1));
                }

                sTmpTreatment3 = "";
                if (sTmpSeances.toString().toLowerCase().indexOf("$")>-1){
                    sTmpTreatment3 = sTmpSeances.substring(0,sTmpSeances.toString().toLowerCase().indexOf("$"));
                    sTmpSeances = new StringBuffer(sTmpSeances.substring(sTmpSeances.toString().toLowerCase().indexOf("$")+1));
                }

                // add seance record
                seancesTable = addSeanceToPDFTable(seancesTable,sTmpDate,sTmpHeure,sTmpTreatment1,sTmpTreatment2,sTmpTreatment3);
            }
        }

        if(seancesTable.size() > 0){
            table.addCell(createTitleCell(getTran("openclinic.chuk","date.seances"),1));
            table.addCell(createCell(new PdfPCell(seancesTable),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
        }

        // add table
        if(table.size() > 1){
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(new PdfPCell(contentTable));
        }
    }

    //--- ADD SEANCE TO PDF TABLE -----------------------------------------------------------------
    private PdfPTable addSeanceToPDFTable(PdfPTable pdfTable, String sDate, String sHour, String sTreatment1,
                                          String sTreatment2, String sTreatment3){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("Web.Occup","medwan.common.date"),2));
            pdfTable.addCell(createHeaderCell(getTran("Web.occup","medwan.common.hour"),1));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","treatment")+" 1",3));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","treatment")+" 2",3));
            pdfTable.addCell(createHeaderCell(getTran("openclinic.chuk","treatment")+" 3",3));
        }

        pdfTable.addCell(createValueCell(sDate,2));
        pdfTable.addCell(createValueCell(sHour,1));
        pdfTable.addCell(createValueCell(getTran("physiotherapy.act",sTreatment1),3));
        pdfTable.addCell(createValueCell(getTran("physiotherapy.act",sTreatment2),3));
        pdfTable.addCell(createValueCell(getTran("physiotherapy.act",sTreatment3),3));

        return pdfTable;
    }
    
    //--- ADD VARIA 2 -----------------------------------------------------------------------------
    private void addVaria2(){
        Vector itemList = new Vector();
        itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE");
        itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION");
        itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE");
        itemList.add(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS");

        if(verifyList(itemList)){
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // enddate
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","enddate"),itemValue);
            }

            // conclusion
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","conclusion"),itemValue);
            }

            // reference
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REFERENCE");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","reference"),getTran("web.occup",itemValue).toLowerCase());
            }

            // remarks
            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS");
            if(itemValue.length() > 0){
                addItemRow(table,getTran("openclinic.chuk","remarks"),itemValue);
            }

            // add table to transaction
            if(table.size() > 0){
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(new PdfPCell(contentTable));
            }
        }
    }

}

