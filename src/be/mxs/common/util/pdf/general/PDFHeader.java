package be.mxs.common.util.pdf.general;

import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.*;

import javax.servlet.http.HttpServletRequest;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Miscelaneous;

public class PDFHeader {
    protected int fontSizePercentage = MedwanQuery.getInstance().getConfigInt("fontSizePercentage",100);
    
    //--- PRINT ------------------------------------------------------------------------------------
    public PdfPTable print(HttpServletRequest request, String sPrintLanguage, String sContextPath){
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        PdfPCell cell = null;

        // logo
        String sURL = request.getRequestURL().toString();
        sURL = sURL.substring(0,sURL.indexOf("openclinic",10));
        try{
            Image img = Miscelaneous.getImage("logo_pdf.jpg","");
            img.scaleToFit(100,100);
            cell = new PdfPCell(img);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            table.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // address
        Paragraph par = null;
        if(sPrintLanguage.equalsIgnoreCase("N")){
            par = new Paragraph("OpenClinic ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD));
            par.add(new Chunk(", Nr ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("ABC123\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD)));
            par.add(new Chunk("Pastoriestraat 58, 3370 Boutersem\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("Tel. (016) 72 10 47",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
        }
        else if(sPrintLanguage.equalsIgnoreCase("F")){
            par = new Paragraph("OpenClinic ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD));
            par.add(new Chunk(", "+ScreenHelper.getTran("pdf","header.knownas",sPrintLanguage)+" ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("ABC123\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD)));
            par.add(new Chunk("Pastoriestraat 58, 3370 Boutersem\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("Tél. (016) 72 10 47",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
        }

        cell = new PdfPCell(par);
        cell.setBorder(PdfPCell.NO_BORDER);
        table.addCell(cell);

        return table;
    }

    //--- PRINT (project) -------------------------------------------------------------------------
    public PdfPTable print(HttpServletRequest request, String sPrintLanguage, String sContextPath, String sProject){
        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        PdfPCell cell = null;

        // logo
        String sURL = request.getRequestURL().toString();
        sURL = sURL.substring(0,sURL.indexOf("openclinic",10));
        try{
            Image img = Miscelaneous.getImage("logo_pdf.jpg",sProject);
            img.scaleToFit(90,90);
            cell = new PdfPCell(img);
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            table.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // address
        Paragraph par = null;
        if(sPrintLanguage.equalsIgnoreCase("N")){
            par = new Paragraph("OpenClinic ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD));
            par.add(new Chunk(", Nr ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("ABC123\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD)));
            par.add(new Chunk("Pastoriestraat 58, 3370 Boutersem\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("Tel. (016) 72 10 47",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
        }
        else if(sPrintLanguage.equalsIgnoreCase("F")){
            par = new Paragraph("OpenClinic ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD));
            par.add(new Chunk(", "+ScreenHelper.getTran("pdf","header.knownas",sPrintLanguage)+" ",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("ABC123\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.BOLD)));
            par.add(new Chunk("Pastoriestraat 58, 3370 Boutersem\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
            par.add(new Chunk("Tél. (016) 72 10 47",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.NORMAL)));
        }

        cell = new PdfPCell(par);
        cell.setBorder(PdfPCell.NO_BORDER);
        table.addCell(cell);

        return table;
    }
    
}