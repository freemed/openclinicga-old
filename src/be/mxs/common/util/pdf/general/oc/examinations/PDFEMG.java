package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFEMG extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_CLINICALDATA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","emg.clinicaldata"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_STUDY_MODALITY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","emg.studymodality"),itemValue.equalsIgnoreCase("medwan.common.not-executed")?getTran("web.occup","medwan.common.not-executed"):getTran("web",itemValue));
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_RESULTS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","results"),itemValue.equalsIgnoreCase("medwan.results.normal")?getTran("web","medwan.results.normal"):getTran("web","medwan.results.abnormal"));
                }

                cell = createHeaderCell(getTran("web.occup","medwan.healthrecord.description"), 5);
                table.addCell(cell);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_TECHNICAL_REPORT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","technical.report"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_RESULTS_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","results"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_STUDIED_MUSCLES");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","studied.muscles"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EMG_CONCLUSION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","conclusion"),itemValue);
                }

                // add table
                if(table.size() > 0){
                    tranTable.addCell(createContentCell(table));
                }

                // add transaction to doc
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}

