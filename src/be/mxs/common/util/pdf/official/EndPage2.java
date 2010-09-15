package be.mxs.common.util.pdf.official;

import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPageEventHelper;
import com.lowagie.text.*;
import be.mxs.common.util.db.MedwanQuery;

public class EndPage2 extends PdfPageEventHelper {
        public void onEndPage(PdfWriter writer, Document document) {
        try{
            Rectangle page = document.getPageSize();
            PdfPTable foot = new PdfPTable(1);
            PdfPCell cell= new PdfPCell(new Phrase("OpenClinic LIMS pdf engine (c)2006-2007, MXS nv    -     "+ MedwanQuery.getInstance().getLabel("labresult","footer","fr"), FontFactory.getFont(FontFactory.HELVETICA,6)));
            cell.setColspan(1);
            cell.setBorder(Cell.NO_BORDER);
            cell.setHorizontalAlignment(Cell.ALIGN_CENTER);
            foot.addCell(cell);
            foot.setTotalWidth(page.width() - document.leftMargin() - document.rightMargin());
            foot.writeSelectedRows(0, -1, document.leftMargin(), document.bottomMargin(),writer.getDirectContent());
        }
        catch(Exception e) {
            throw new ExceptionConverter(e);
        }
    }
}
