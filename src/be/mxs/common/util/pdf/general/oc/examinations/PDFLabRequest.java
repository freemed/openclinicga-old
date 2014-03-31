package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import java.sql.SQLException;
import java.util.Hashtable;
import java.util.Vector;
import java.util.Collections;

import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.medical.Labo;

public class PDFLabRequest extends PDFGeneralBasic {

    // declarations
    private StringBuffer monsters;

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
	            contentTable = new PdfPTable(1);
	            monsters = new StringBuffer();
	
	            // CHOSEN LABANALYSES
	            PdfPTable chosenLabs = getChosenLabAnalyses();
	            if(chosenLabs.size() > 0){
	                contentTable.addCell(createCell(new PdfPCell(chosenLabs),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
	            }
	
	            table = new PdfPTable(5);
	
	            // MONSTERS (calculated)
	            if(monsters.length() > 0){
	                addItemRow(table,getTran("labrequest.monsters"),monsters.toString());
	            }
	
	            // MONSTER HOUR
	            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LAB_HOUR");
	            if(itemValue.length() > 0){
	                addItemRow(table,getTran("Web.Occup","labrequest.hour"),itemValue);
	            }
	
	            // COMMENT
	            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LAB_COMMENT");
	            if(itemValue.length() > 0){
	                addItemRow(table,getTran("Web","comment"),itemValue);
	            }
	
	            // URGENCY
	            itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_LAB_URGENCY");
	            if(itemValue.length() > 0){
	                addItemRow(table,getTran("Web.Occup","urgency"),getTran("labrequest.urgency",itemValue).toLowerCase());
	            }
	
	            // add table
	            if(table.size() > 0){
	                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
	                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
	                tranTable.addCell(new PdfPCell(contentTable));
	            }
	
	            // add transaction to doc
	            addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }


    //### PRIVATE METHODS ##########################################################################

    //--- GET CHOSEN LABANALYSES -------------------------------------------------------------------
    private PdfPTable getChosenLabAnalyses() throws SQLException {
        PdfPTable chosenAnalysesTable = new PdfPTable(14);
        String sTmpCode, sTmpComment, sTmpModifier, sTmpResult, sTmpResultUnit, sTmpResultValue,
               sTmpType = "", sTmpLabel = "", sTmpMonster = "";

        // get chosen labanalyses from existing transaction.
        Hashtable labAnalyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());

        // sort analysis-codes
        Vector codes = new Vector(labAnalyses.keySet());
        Collections.sort(codes);

        // run thru saved labanalysis
        RequestedLabAnalysis labAnalysis;
        for (int i=0; i<codes.size(); i++) {
            sTmpCode = (String)codes.get(i);
            labAnalysis = (RequestedLabAnalysis)labAnalyses.get(sTmpCode);

            sTmpComment = labAnalysis.getComment();
            sTmpModifier = labAnalysis.getResultModifier();

            // get resultvalue
            if(labAnalysis.getFinalvalidation()>0){
                sTmpResultValue = labAnalysis.getResultValue();
            }
            else {
                sTmpResultValue="";
            }
            sTmpResultUnit = getTran("labanalysis.resultunit",labAnalysis.getResultUnit());
            sTmpResult = sTmpResultValue + " " + sTmpResultUnit;

            // get default-data from DB
            Hashtable hLabRequestData = Labo.getLabRequestDefaultData(sTmpCode,sPrintLanguage);
            if (hLabRequestData != null) {
                sTmpType = (String) hLabRequestData.get("labtype");
                sTmpLabel = (String) hLabRequestData.get("OC_LABEL_VALUE");
                sTmpMonster = (String) hLabRequestData.get("monster");
            }

            // translate labtype
                 if(sTmpType.equals("1")) sTmpType = getTran("Web.occup","labanalysis.type.blood");
            else if(sTmpType.equals("2")) sTmpType = getTran("Web.occup","labanalysis.type.urine");
            else if(sTmpType.equals("3")) sTmpType = getTran("Web.occup","labanalysis.type.other");
            else if(sTmpType.equals("4")) sTmpType = getTran("Web.occup","labanalysis.type.stool");
            else if(sTmpType.equals("5")) sTmpType = getTran("Web.occup","labanalysis.type.sputum");
            else if(sTmpType.equals("6")) sTmpType = getTran("Web.occup","labanalysis.type.smear");
            else if(sTmpType.equals("7")) sTmpType = getTran("Web.occup","labanalysis.type.liquid");

            // add analysis to table
            chosenAnalysesTable = addLabAnalysisToPDFTable(chosenAnalysesTable,sTmpCode,sTmpType,sTmpLabel,sTmpComment,sTmpMonster,sTmpResult,sTmpModifier);

            // add monster if one is specified
            if(sTmpMonster.length() > 0){
                if(monsters.indexOf(sTmpMonster) < 0){
                    monsters.append(sTmpMonster).append(", ");
                }
            }
        }

        // remove last comma from monsters
        if(monsters.indexOf(",") > -1){
            monsters = monsters.deleteCharAt(monsters.length()-2);
        }

        return chosenAnalysesTable;
    }

    //--- ADD LABANALYSIS TO PDF TABLE -------------------------------------------------------------
    private PdfPTable addLabAnalysisToPDFTable(PdfPTable pdfTable, String code, String type, String label,
                                               String comment, String monster, String resultvalue, String resultmodifier){

        // add header if no header yet
        if(pdfTable.size() == 0){
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.code"),1));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.type"),1));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.name"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.comment"),3));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.monster"),3));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultvalue"),2));
            pdfTable.addCell(createHeaderCell(getTran("web.manage","labanalysis.cols.resultmodifier"),2));
        }

        pdfTable.addCell(createValueCell(code,1));
        pdfTable.addCell(createValueCell(type,1));
        pdfTable.addCell(createValueCell(label,2));
        pdfTable.addCell(createValueCell(comment,3));
        pdfTable.addCell(createValueCell(monster,3));
        pdfTable.addCell(createValueCell(resultvalue,2));
        pdfTable.addCell(createValueCell(resultmodifier,2));

        return pdfTable;
    }

}
