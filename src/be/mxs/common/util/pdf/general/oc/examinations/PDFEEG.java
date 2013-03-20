package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFEEG extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EEG_CLINICALDATA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","eeg.clinicaldata"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EEG_STUDYMODALITY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","eeg.studymodality"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EEG_RESULTS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","results"),itemValue.equalsIgnoreCase("medwan.results.normal")?getTran("web","medwan.results.normal"):getTran("web","medwan.results.abnormal"));
                }

                cell = createHeaderCell(getTran("web.occup","medwan.healthrecord.description"), 5);
                table.addCell(cell);

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EEG_TECHNICAL_REPORT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","technical.report"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EEG_RESULTS_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","results"),itemValue);
                }

                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EEG_CONCLUSION");
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

