package be.mxs.common.util.pdf.general.oc.examinations;

import java.util.Vector;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFEvokedPotentials extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // clinical data
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_CLINICALDATA");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","ep.clinicaldata"),itemValue);
                }

                // study modality
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_STUDY_MODALITY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","ep.studymodality"),itemValue.equalsIgnoreCase("medwan.common.not-executed")?getTran("web.occup","medwan.common.not-executed"):getTran("web",itemValue));
                }

                // results
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_RESULTS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","results"),itemValue.equalsIgnoreCase("medwan.results.normal")?getTran("web","medwan.results.normal"):getTran("web","medwan.results.abnormal"));
                }

                //*** DESCRIPTION ***
                Vector itemList = new Vector();
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_EP_TECHNICAL_REPORT");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_EP_RESULTS_DESCRIPTION");
                itemList.add(IConstants_PREFIX+"ITEM_TYPE_EP_CONCLUSION");
                
                if(verifyList(itemList)){
	                cell = createHeaderCell(getTran("web.occup","medwan.healthrecord.description"), 5);
	                table.addCell(cell);
	
	                // technical report
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_TECHNICAL_REPORT");
	                if(itemValue.length() > 0){
	                    addItemRow(table,getTran("web","technical.report"),itemValue);
	                }
	
	                // results description
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_RESULTS_DESCRIPTION");
	                if(itemValue.length() > 0){
	                    addItemRow(table,getTran("web","results"),itemValue);
	                }
	
	                // studied muscles
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_STUDIED_MUSCLES");
	                if(itemValue.length() > 0){
	                    addItemRow(table,getTran("web","studied.muscles"),itemValue);
	                }
	
	                // conclusion
	                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_EP_CONCLUSION");
	                if(itemValue.length() > 0){
	                    addItemRow(table,getTran("web","conclusion"),itemValue);
	                }
                }
            
                // add table
                if(table.size() > 0){
                    tranTable.addCell(createContentCell(table));
                }

                // add transaction to doc
                addTransactionToDoc();

                addDiagnosisEncoding();
                addTransactionToDoc();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}