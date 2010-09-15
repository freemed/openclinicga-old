package be.mxs.common.util.pdf.general.oc.examinations;

import com.lowagie.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFIntradermo extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);

                // DATE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_DATE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_DATE"),itemValue);
                }

                // NEXT DATE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_NEXTDATE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_NEXTDATE"),itemValue);
                }

                // READ DATE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_READDATE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_READDATE"),itemValue);
                }

                // RESULT (dropdown)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESULT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESULT"),getTran(itemValue));
                }

                // INDURATION SIZE
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_INDURATION_SIZE");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_INDURATION_SIZE"),itemValue+" "+getTran("unit","mm"));
                }

                // ASSOCIATED REACTIONS (dropdown)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_ASSOCIATED_REACTIONS");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_ASSOCIATED_REACTIONS"),getTran(itemValue));
                }

                // INDURATION CONSISTENCE (dropdown)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_INDURATION_CONSISTENCY");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_INDURATION_CONSISTENCY"),getTran(itemValue));
                }

                //*** REACTION TYPES ***
                addReactionTypes();

                // COMMENT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_COMMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_COMMENT"),itemValue);
                }

                // RESULT RECEIVED
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_RESULTRECEIVED");
                if(itemValue.equalsIgnoreCase("on")){
                    addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_RESULTRECEIVED"),getTran("medwan.common.yes"));
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


    //### PRIVATE METHODS ##########################################################################

    //--- ADD REACTION TYPES -----------------------------------------------------------------------
    private void addReactionTypes(){
        StringBuffer reactions = new StringBuffer();

        // bubble
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_BUBBLE").equals("")){
            reactions.append(getTran(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_BUBBLE")).append(", ");
        }

        // blush
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_BLUSH").equals("")){
            reactions.append(getTran(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_BLUSH")).append(", ");
        }

        // oedeem
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_OEDEEM").equals("")){
            reactions.append(getTran(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_OEDEEM")).append(", ");
        }

        // lymphangitis
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_LYMPHANGITIS").equals("")){
            reactions.append(getTran(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_LYMPHANGITIS")).append(", ");
        }

        // bubble
        if(!getItemValue(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_ADENOPATHY").equals("")){
            reactions.append(getTran(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE_ADENOPATHY")).append(", ");
        }

        // add reactions row
        if(reactions.length() > 0){
            // remove last comma
            if(reactions.indexOf(",") > 0){
                reactions = reactions.deleteCharAt(reactions.length()-2);
            }

            addItemRow(table,getTran(IConstants_PREFIX+"ITEM_TYPE_REACTION_TYPE"),reactions.toString().toLowerCase());
        }
    }

}
