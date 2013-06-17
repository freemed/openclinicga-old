package be.mxs.common.util.pdf.general.oc.examinations;

import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;


public class PDFOphtalmologyCDO extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try {
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(100);

                //1. Complaints
                cell = createGreyCell(getTran("web","actual.complaints"),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_1");
                if(itemValue.length() > 0){
                    itemValue=itemValue.replaceAll("\\*\\*", ",").replaceAll("\\*", "");
                    String[] complaints = itemValue.split(",");
                    itemValue="";
                    for(int n=0;n<complaints.length;n++){
                    	if(itemValue.length()>0){
                    		itemValue+=", ";
                    	}
                    	itemValue+=getTran("cdo.1",complaints[n]).toUpperCase();
                    }
                }
                if(getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_1_COMMENT").length()>0){
                	if(itemValue.length()>0){
                		itemValue+=", ";
                	}
                	itemValue+=getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_1_COMMENT");
                }
                cell=createValueCell(itemValue,80);
                table.addCell(cell);

                //2. Localisation
                cell = createGreyCell(getTran("web","localisation"),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_2");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_2_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.2",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,80);
                table.addCell(cell);

                //3. Severity
                cell = createGreyCell(getTran("web","severity"),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_3_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.3",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,16);
                table.addCell(cell);

                //4. Duration
                cell = createGreyCell(getTran("web","cdo.duration"),16);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_4_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.4",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,16);
                table.addCell(cell);

                //5. Rythm
                cell = createGreyCell(getTran("web","cdo.rythm"),16);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_5_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.5",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,16);
                table.addCell(cell);

                //6. Antécédents médicaux
                cell = createGreyCell(getTran("web","cdo.history"),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_6");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_6_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.6",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,16);
                table.addCell(cell);

                //7. Médicaments
                cell = createGreyCell(getTran("web","cdo.meds"),16);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_7_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.7",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,16);
                table.addCell(cell);

                //8. Rythm
                cell = createGreyCell(getTran("web","cdo.allergy"),16);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_8_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.8",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,16);
                table.addCell(cell);

                //9. Antécédents familiaux
                cell = createGreyCell(getTran("web","cdo.history.family"),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_9_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.9",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,32);
                table.addCell(cell);

                //10. Antécédents chirurgicaux
                cell = createGreyCell(getTran("web","cdo.history.surgery"),16);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10");
                if(itemValue.equalsIgnoreCase("0")){
                    itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_10_COMMENT").toUpperCase();
                }
                else {
                	itemValue=getTran("cdo.10",itemValue).toUpperCase();
                }
                cell=createValueCell(itemValue,32);
                table.addCell(cell);

                //11. Antécédents médicaux oculaires
                cell = createGreyCell(getTran("web","cdo.history.eye"),20);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_11");
                cell=createValueCell(itemValue,32);
                table.addCell(cell);

                //12. Prise en charge
                cell = createGreyCell(getTran("web","cdo.intake"),16);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                table.addCell(cell);
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CDO_12");
                cell=createValueCell(itemValue,32);
                table.addCell(cell);

                
                
                
                
                
                
                
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
