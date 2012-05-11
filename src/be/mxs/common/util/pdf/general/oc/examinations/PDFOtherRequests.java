package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFOtherRequests extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // CONTACT DESCRIPTION
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_DESCRIPTION"),itemValue);
                }

                // SPECIALIST TYPE (select)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_SPECIALIST_TYPE");
                if(itemValue.length() > 0){
                    if(!itemValue.equals("0")){
                        addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_SPECIALIST_TYPE"),getTran("Web","medwan.occupational-medicine.medical-specialist.type-"+itemValue));
                    }
                }

                // ALS PRESTATIE HERNEMEN (checkbox)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_PRESTATION"),getTran("medwan.common.yes"));
                }

                // PROVIDER
                String providerCode = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_SUPPLIER");
                if(providerCode.length() > 0){
                    itemValue = providerCode;
                    String providerName = getProviderNameFromCode(providerCode);
                    if(providerName.length() > 0){
                        itemValue+= " : "+providerName;
                    }
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_SUPPLIER"),itemValue);
                }

                // VALUE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALUE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_OTHER_REQUESTS_VALUE"),itemValue);
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
