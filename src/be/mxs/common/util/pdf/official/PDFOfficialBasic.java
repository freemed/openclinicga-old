package be.mxs.common.util.pdf.official;

import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;


import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletContext;

import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;


/**
 * User: Stijn Smets
 * Date: 05-07-2006
 */
//#################################################################################################
// Contains code used by official versions of examination classes.
// Provides a print function that delegates the printing of the header
// and body to the specific official examination classes.
//#################################################################################################
public abstract class PDFOfficialBasic extends PDFBasic {

    protected String url, contextPath, projectDir;
    protected Image img;
    protected SimpleDateFormat DATE_FORMAT=ScreenHelper.stdDateFormat;
    protected DecimalFormat PERCENT_FORMAT=new DecimalFormat("#.#");
    protected DecimalFormat TWODIGIT_FORMAT=new DecimalFormat("#.##");
    

    //--- PRINT (leave header and body to specific pdf) -------------------------------------------
    public void print(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                      User user, AdminPerson adminPerson, HttpServletRequest req, String sProject, String sPrintLanguage){

        print(doc,sessionContainerWO,transactionVO,user,adminPerson,req,sProject,null,null,sPrintLanguage);
    }

    public void print(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                      User user, AdminPerson adminPerson, HttpServletRequest req, String sProject,
                      String sPrintLanguage, ServletContext application){

        this.application = application;
        print(doc,sessionContainerWO,transactionVO,user,adminPerson,req,sProject,null,null,sPrintLanguage);
    }

    public void print(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                      User user, AdminPerson adminPerson, HttpServletRequest req, String sProject, Date dateFrom,
                      Date dateTo, String sPrintLanguage, ServletContext application){

        this.application = application;
        print(doc,sessionContainerWO,transactionVO,user,adminPerson,req,sProject,dateFrom,dateTo,sPrintLanguage);
    }

    public void print(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                      User user, AdminPerson adminPerson, HttpServletRequest req, String sProject, Date dateFrom,
                      Date dateTo, String sPrintLanguage){

        this.doc = doc;
        this.sessionContainerWO = sessionContainerWO;
        this.transactionVO = transactionVO;
        this.sPrintLanguage = sPrintLanguage;
        this.user = user;
        this.patient = adminPerson;
        this.req = req;
        this.sProject = sProject;
        this.dateFrom = dateFrom;
        this.dateTo = dateTo;

        // put header and body in one table
        tranTable = new PdfPTable(1);

        String sURL = req.getRequestURL().toString();
        if(sURL.indexOf("openclinic",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinic", 10));
        }
        if(sURL.indexOf("openclinictest",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openclinictest", 10));
        }
        if(sURL.indexOf("openinsurance",10) > 0){
            sURL = sURL.substring(0,sURL.indexOf("openinsurance", 10));
        }

        String sContextPath = req.getContextPath()+"/";
        HttpSession session = req.getSession();
        String sProjectDir = (String)session.getAttribute("activeProjectDir");

        // if request from Chuk, project = chuk
        if(sContextPath.indexOf("chuk") > -1){
            sContextPath = "openclinic/";
            sProjectDir = "projects/chuk/";
        }

        this.url = sURL;
        this.contextPath = sContextPath;
        this.projectDir = sProjectDir;

        // abstract method invocation
        addHeader();
        addContent();
    }

    //--- REPEAT ----------------------------------------------------------------------------------
    public String repeat(String sChar, int amount){
        String repetition = "";

        for(int i=0; i<amount; i++){
            repetition+= sChar;
        }

        return repetition;
    }


    //************************************ CELL METHODS *******************************************

    //--- CHECKBOX CELL ---------------------------------------------------------------------------
    protected PdfPCell checkBoxCell(boolean checked) throws Exception {
        if(checked) img = Miscelaneous.getImage("themes/default/check.gif","");
        else        img = Miscelaneous.getImage("themes/default/uncheck.gif","");

        img.scaleAbsolute(8,8);
        cell = new PdfPCell(img);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setColspan(1);

        return cell;
    }

    //--- EMPTY CELL ------------------------------------------------------------------------------
    protected PdfPCell emptyCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    protected PdfPCell emptyCell(){
        return emptyCell(1);
    }

    protected PdfPCell emptyCell(int height, int colspan){
        cell = emptyCell(colspan);
        cell.setPaddingTop(height);

        return cell;
    }
    
    protected PdfPCell emptyCell(int colspan, boolean setBorder){
    	cell = emptyCell(10,colspan);
    	
        if(setBorder){
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
        }
        else{
        	cell.setBorder(PdfPCell.NO_BORDER);
        }
        
        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int fontStyle, int fontSize, int colspan){
        switch(fontStyle){
            case 0 : cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.NORMAL))); break;
            case 1 : cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.BOLD))); break;
            case 2 : cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.ITALIC))); break;
            case 3 : cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.BOLDITALIC))); break;
            case 4 : cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.UNDERLINE))); break;
        }

        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int fontStyle, int fontSize, int colspan, boolean setBorder){
        switch(fontStyle){
            case 0 : cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.NORMAL))); break;
            case 1 : cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.BOLD))); break;
            case 2 : cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.ITALIC))); break;
            case 3 : cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.BOLDITALIC))); break;
            case 4 : cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.UNDERLINE))); break;
        }

        cell.setColspan(colspan);
        if(setBorder){
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
        }
        else{
        	cell.setBorder(PdfPCell.NO_BORDER);
        }
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);

        return cell;
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
    protected PdfPCell createValueCell(Phrase phrase, int fontStyle, int fontSize, int colspan, boolean setBorder){
        cell = new PdfPCell(phrase);

        cell.setColspan(colspan);
        if(setBorder){
            cell.setBorder(PdfPCell.BOX);
            cell.setBorderColor(innerBorderColor);
        }
        else{
        	cell.setBorder(PdfPCell.NO_BORDER);
        }
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);

        return cell;
    }

    //--- CREATE CHECKBOX VALUE CELL --------------------------------------------------------------
    protected PdfPCell createCheckBoxValueCell(String value, int fontStyle, int fontSize, int colspan, boolean border){
        cell = createValueCell(value,fontStyle,fontSize,colspan,border);
        cell.setPaddingBottom(2);

        return cell;
    }

    //--- ADD BLANK ROW ---------------------------------------------------------------------------
    protected void addBlankRow(int height){
        try{
            PdfPTable table = new PdfPTable(1);
            table.setTotalWidth(100);
            cell = new PdfPCell(new Phrase());
            cell.setBorder(PdfPCell.BOX);
            cell.setPaddingTop(height); //
            table.addCell(cell);
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- ABSTRACT --------------------------------------------------------------------------------
    protected abstract void addHeader();
    protected abstract void addContent();

}
