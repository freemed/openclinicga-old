package be.mxs.common.util.pdf.general;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Font;
import java.util.Iterator;
import java.awt.*;


/**
 * User: stijn smets
 * Date: 5-jan-2006
 */
public class PDFGenericTransaction extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try {
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            Iterator iterator = transactionVO.getItems().iterator();
            ItemVO item;
            while(iterator.hasNext()){
                item = (ItemVO)iterator.next();

                if(!item.getType().equalsIgnoreCase(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT") &&
                   !item.getType().equalsIgnoreCase(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_DEPARTMENT") &&
                   !item.getType().equalsIgnoreCase(IConstants_PREFIX+"ITEM_TYPE_TRANSACTION_RESULT") &&
                   !item.getType().equalsIgnoreCase(IConstants_PREFIX+"ITEM_TYPE_RECRUITMENT_CONVOCATION_ID")){

                    // itemType
                    cell = new PdfPCell(new Phrase(getTran("web.occup",item.getType()).toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                    cell.setColspan(2);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
                    table.addCell(cell);

                    // itemValue
                    cell = new PdfPCell(new Phrase(getTran("web.occup",item.getValue()),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                    cell.setColspan(13);
                    cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
                    cell.setBorder(PdfPCell.BOX);
                    cell.setBorderColor(BaseColor.LIGHT_GRAY);
                    table.addCell(cell);
                }
            }

            // add table
            if(table.size() > 1){
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }

            // add transaction to doc
            addTransactionToDoc();
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

}
