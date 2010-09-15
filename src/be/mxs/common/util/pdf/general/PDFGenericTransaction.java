package be.mxs.common.util.pdf.general;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.Cell;
import com.lowagie.text.Phrase;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Font;
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
                    cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                    cell.setBorder(Cell.BOX);
                    cell.setBorderColor(Color.LIGHT_GRAY);
                    table.addCell(cell);

                    // itemValue
                    cell = new PdfPCell(new Phrase(getTran("web.occup",item.getValue()),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
                    cell.setColspan(13);
                    cell.setVerticalAlignment(Cell.ALIGN_MIDDLE);
                    cell.setBorder(Cell.BOX);
                    cell.setBorderColor(Color.LIGHT_GRAY);
                    table.addCell(cell);
                }
            }

            // add table
            if(table.size() > 1){
                contentTable.addCell(createCell(new PdfPCell(table),1,Cell.ALIGN_CENTER,Cell.NO_BORDER));
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
