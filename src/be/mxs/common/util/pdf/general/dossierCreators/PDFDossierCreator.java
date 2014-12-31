package be.mxs.common.util.pdf.general.dossierCreators;

import java.io.ByteArrayOutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.Date;
import java.util.Iterator;
import java.util.Vector;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

import net.admin.AdminPerson;
import net.admin.AdminPrivateContact;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFCreator;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Picture;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Insurance;
import be.openclinic.finance.Insurar;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.Barcode39;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

public abstract class PDFDossierCreator extends PDFCreator {

    // declarations
	protected final int pageWidth = 100;
    protected boolean respGraphsArePrinted, diabetesGraphsArePrinted;
    protected PdfPCell cell;
    protected PdfPTable table;
    protected String url, contextPath, projectDir;
    protected PdfWriter docWriter = null;
    protected ByteArrayOutputStream baosPDF = null;
    
    protected final BaseColor innerBorderColor = BaseColor.LIGHT_GRAY;
    protected final BaseColor BGCOLOR_LIGHT = new BaseColor(240,240,240); // light gray
    protected int fontSizePercentage = MedwanQuery.getInstance().getConfigInt("fontSizePercentage",100);
    
    
    //--- PRINT DOCUMENT HEADER -------------------------------------------------------------------
    protected void printDocumentHeader(final HttpServletRequest req) throws Exception {
        Class cls = null;
        boolean bClassFound = false;

        // First search the projectclass
        try{
            cls = Class.forName("be.mxs.common.util.pdf.general."+sProject.toLowerCase()+"."+sProject.toLowerCase()+"PDFHeader");
            bClassFound = true;
        }
        catch(ClassNotFoundException e){
            Debug.println(e.getMessage());
        }

        // else search the normal class
        if(cls==null){
            try{
                cls = Class.forName("be.mxs.common.util.pdf.general.PDFHeader");
            }
            catch(ClassNotFoundException e){
                Debug.println(e.getMessage());
            }
        }

        if(cls!=null){
            Constructor[] cons  = cls.getConstructors();
            Object[] oParams = new Object[0];
            Object oConstructor = cons[0].newInstance(oParams);

            Class cParams[] = new Class[4];
            cParams[0] = HttpServletRequest.class;
            cParams[1] = String.class;
            cParams[2] = String.class;
            cParams[3] = String.class;

            Method mPrint = oConstructor.getClass().getMethod("print",cParams);
            oParams = new Object[4];
            oParams[0] = req;
            oParams[1] = this.sPrintLanguage;

            if(bClassFound){
                oParams[2] = this.sContextPath+"/"+this.sProjectPath;
            }
            else{
                oParams[2] = this.sContextPath;
            }
            oParams[3] = sProject.toLowerCase();

            PdfPTable tHeader = (PdfPTable)mPrint.invoke(oConstructor,oParams);
            if(tHeader!=null){
                doc.add(tHeader);
            }
        }
    }
    
    //--- PRINT DOCUMENT TITLE --------------------------------------------------------------------
    protected void printDocumentTitle(final HttpServletRequest req, String sTitle) throws Exception {
		// main title
	    Paragraph par = new Paragraph(sTitle,FontFactory.getFont(FontFactory.HELVETICA,15,Font.BOLD));
	    par.setAlignment(Paragraph.ALIGN_CENTER);
	    doc.add(par);
    
	    // add date as subtitle
	    String sSubTitle = ""+getTran("web","printdate")+": "+dateFormat.format(new Date());
	
	    if(dateFrom!=null && dateTo!=null){
	        if(dateFrom.getTime()==dateTo.getTime()){
	            sSubTitle+= "\n("+getTran("web","on")+" "+dateFormat.format(dateTo)+")";
	        }
	        else{
	            sSubTitle+= "\n("+getTran("pdf","date.from")+" "+dateFormat.format(dateFrom)+" "+getTran("pdf","date.to")+" "+dateFormat.format(dateTo)+")";
	        }
	    }
	    else if(dateFrom!=null){
	        sSubTitle+= "\n("+getTran("web","since")+" "+dateFormat.format(dateFrom)+")";
	    }
	    else if(dateTo!=null){
	        sSubTitle+= "\n("+getTran("pdf","date.to")+" "+dateFormat.format(dateTo)+")";
	    }
	
	    par = new Paragraph(sSubTitle,FontFactory.getFont(FontFactory.HELVETICA,10,Font.NORMAL));
	    par.setAlignment(Paragraph.ALIGN_CENTER);
	    doc.add(par);
	    
        doc.add(new Paragraph(" "));
    }
       
    //--- PRINT PATIENT CARD ----------------------------------------------------------------------
    protected void printPatientCard(AdminPerson person, boolean showPhoto) throws Exception {
        table = new PdfPTable(20);
        table.setWidthPercentage(pageWidth);
        
    	PdfPTable cardTable = new PdfPTable(2);
        cardTable.setWidthPercentage(pageWidth);
        
        //*** ROW 1 ***************************************
        // label : name + archive code                      
        cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardname",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);

        cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardArchiveCode",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);

        // data : name + archive code
        cell = createLabel(person.firstname+", "+person.lastname,12,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        cell = createLabel(person.getID("archiveFileCode").toUpperCase(),10,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        //*** ROW 2 ***************************************
        // label : date of birth & gender
        cell = createLabel(MedwanQuery.getInstance().getLabel("web","carddateofbirth",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardgender",sPrintLanguage),7,1,Font.ITALIC);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);

        // data : date of birth & gender
        cell = createLabel(person.dateOfBirth,10,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        cell = createLabel(person.gender,10,1,Font.BOLD);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cardTable.addCell(cell);
        
        //*** ROW 3 ***************************************
        if(MedwanQuery.getInstance().getConfigInt("patientCardModel",1)==2){
            cell = createLabel(MedwanQuery.getInstance().getLabel("web","cardInsuranceNumber",sPrintLanguage),7,2,Font.ITALIC);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cardTable.addCell(cell);

            cell = createLabel(person.comment5,10,2,Font.BOLD);
            cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
            cardTable.addCell(cell);
        }
        
        //*** Photo ***
        PdfPCell imgCell = new PdfPCell();
        
        if(showPhoto){
            if(Picture.exists(Integer.parseInt(person.personid))){
                Picture picture = new Picture(Integer.parseInt(person.personid));
                        
	            try{
	                Image image = Image.getInstance(picture.getPicture());
	                image.scaleToFit(130,72);
	                imgCell = new PdfPCell(image);
	            }
	            catch(Exception e){
	                e.printStackTrace();
	                
	                imgCell = new PdfPCell();
	            }
	            
	            imgCell.setBorder(PdfPCell.NO_BORDER);
	            imgCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
	            imgCell.setHorizontalAlignment(PdfPCell.ALIGN_JUSTIFIED);
	            imgCell.setPadding(2);
	            imgCell.setColspan(5);
            }
            else{                	
            	// no picture found
            	imgCell = createValueCell(getTran("web","noPictureFound"),1);  
            }
        }

        // cardTable in table
        cell = createBorderlessCell(12);
        cell.addElement(cardTable);
        cell.setPadding(0);
        table.addCell(cell);
        
        // imgCell in table              
        imgCell.setBorder(PdfPCell.NO_BORDER);
        imgCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        imgCell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        imgCell.setPadding(2);
        imgCell.setColspan(3);            
        table.addCell(imgCell);
        
        // barcode in table
        PdfContentByte contentByte = docWriter.getDirectContent();
        Barcode39 barcode39 = new Barcode39();
        barcode39.setCode("0"+person.personid);
        barcode39.setSize(8);
        barcode39.setBaseline(10);
        barcode39.setBarHeight(65);
        
        Image barcodeImg = barcode39.createImageWithBarcode(contentByte,null,null);            
        cell = new PdfPCell(barcodeImg);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(2);
        cell.setColspan(5);
        table.addCell(cell);
        
        // hospital ref (horizontal line)
        cell = createLabel(getTran("web","cardHospitalRef"),8,20,Font.NORMAL);
        cell.setBorder(PdfPCell.TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        table.addCell(cell);
                    
        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
            doc.add(new Paragraph(" "));
        }
        
        //doc.setJavaScript_onLoad(MedwanQuery.getInstance().getConfigString("cardJavaScriptOnLoad","document.print();"));
    }
        
    //--- PRINT ADMIN DATA ------------------------------------------------------------------------
    /*
        -   1 : Native country
        -   2 : Language
        -   3 : Gender
        -   4 : National registry number
        -   5 : CSLS-ARCAD ID
        -   6 : Treating physician
        -   7 : Civil/marital status
        -   8 : Responsible physician
        -   9 : Comment (Last record export)
        -  10 : VIP
        -  11 : Deathcertificate
    */
    protected void printAdminData(AdminPerson activePatient) throws Exception {            
        table = new PdfPTable(5);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","personalData"),5));

        // Native country
        if(activePatient.nativeCountry.length() > 0){
            table.addCell(createItemNameCell(getTran("web","nativeCountry").toUpperCase()));
            table.addCell(createItemValueCell(getTran("country",activePatient.nativeCountry)));
        }

        // Language
        if(activePatient.language.length() > 0){
            table.addCell(createItemNameCell(getTran("web","language").toUpperCase()));
            table.addCell(createItemValueCell(getTran("Web.language",activePatient.language)));
        }
        
        // Gender
        if(activePatient.gender.length() > 0){
        	String sGender = "";
            if(activePatient.gender.equalsIgnoreCase("m")){
                sGender = getTran("web.occup","male");
            }
            else if(activePatient.gender.equalsIgnoreCase("f")){
                sGender = getTran("web.occup","female");
            }
            
            table.addCell(createItemNameCell(getTran("web","gender").toUpperCase()));
            table.addCell(createItemValueCell(sGender));
        }
                        
        // National registry number
        if(activePatient.getID("natreg").length() > 0){
            table.addCell(createItemNameCell(getTran("web","natreg").toUpperCase()));
            table.addCell(createItemValueCell(activePatient.getID("natreg")));               
        }
        
        // CSLS-ARCAD ID
    	String sTracnetID = ScreenHelper.checkString((String)activePatient.adminextends.get("tracnetid"));
        if(sTracnetID.length() > 0){
            table.addCell(createItemNameCell(getTran("web","tracnetid").toUpperCase()));
            table.addCell(createItemValueCell(sTracnetID));               
        }
        
        // Treating physician
        if(activePatient.comment1.length() > 0){
            table.addCell(createItemNameCell(getTran("web","treating-physician").toUpperCase()));
            table.addCell(createItemValueCell(activePatient.comment));               
        }
        
        // Civil/marital status
        if(activePatient.comment2.length() > 0){            	
            table.addCell(createItemNameCell(getTran("web","civilstatus").toUpperCase()));
            table.addCell(createItemValueCell(getTran("civil.status",activePatient.comment2)));               
        }
        
        // Treating physician
        if(activePatient.comment1.length() > 0){
            table.addCell(createItemNameCell(getTran("web","treating-physician").toUpperCase()));
            table.addCell(createItemValueCell(activePatient.comment));               
        }
        
        // Last record export
        if(activePatient.comment.length() > 0){
            table.addCell(createItemNameCell(getTran("web","comment").toUpperCase()));
            table.addCell(createItemValueCell(activePatient.comment));               
        }

        // VIP
        if(MedwanQuery.getInstance().getConfigInt("enableVip",0)==1){
        	String sVip = "";
        	
        	if(ScreenHelper.checkString((String)activePatient.adminextends.get("vip")).length() > 0){
                sVip = ScreenHelper.checkString((String)activePatient.adminextends.get("vip"));
                if(sVip.length()==0) sVip = "0";
            }
        	
            if(sVip.length() > 0){
                table.addCell(createItemNameCell(getTran("web","vip").toUpperCase()));
                table.addCell(createItemValueCell(getTran("vipstatus",sVip)));               
            }
        }	 

        // death
        if(activePatient.isDead()!=null){
            String sDeathCertificateOn = ScreenHelper.checkString((String)activePatient.adminextends.get("deathcertificateon"));
            if(sDeathCertificateOn.length() > 0){
                table.addCell(createItemNameCell(getTran("web","deathCertificateon").toUpperCase()));
                table.addCell(createItemValueCell(sDeathCertificateOn));
            }

            String sDeathCertificateTo = ScreenHelper.checkString((String)activePatient.adminextends.get("deathcertificateto"));
            if(sDeathCertificateTo.length() > 0){
                table.addCell(createItemNameCell(getTran("web","deathCertificateto").toUpperCase()));
                table.addCell(createItemValueCell(sDeathCertificateTo));
            }
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }
    }

    //--- PRINT ADMIN PRIVATE DATA ----------------------------------------------------------------
    /*
        -  1 : Address modification on  
        -  2 : Country  
        -  3 : Department  
        -  4 : Administrative code 
        -  5 : Province   
        -  6 : Municipality 
        -  7 : Locality 
        -  8 : Cell  
        -  9 : Address  
        - 10 : Email  
        - 11 : Telephone 
        - 12 : Cellphone  
        - 13 : Position 
        - 14 : Company 
        - 15 : Comment
    */
    protected void printAdminPrivateData(AdminPerson activePatient) throws Exception {
        AdminPrivateContact privateData = activePatient.getActivePrivate();
        if(privateData!=null){                   
            table = new PdfPTable(5);
            table.setWidthPercentage(pageWidth);

            // title
            table.addCell(createTitleCell(getTran("web","privateData"),5));

            // Address modification on  
            if(privateData.begin.length() > 0){
                table.addCell(createItemNameCell(getTran("web.admin","addressChangeSince").toUpperCase()));
                table.addCell(createItemValueCell(privateData.begin));
            }

            // Country
            if(privateData.country.length() > 0){
                table.addCell(createItemNameCell(getTran("web","country").toUpperCase()));
                table.addCell(createItemValueCell(privateData.country));
            }
            
            // District/Department
            if(privateData.district.length() > 0){
                table.addCell(createItemNameCell(getTran("web","district").toUpperCase()));
                table.addCell(createItemValueCell(privateData.district));
            }
            
            // Zip code 
            if(privateData.zipcode.length() > 0){
                table.addCell(createItemNameCell(getTran("web","zipcode").toUpperCase()));
                table.addCell(createItemValueCell(privateData.zipcode));
            }
            
            // Province 
            if(privateData.province.length() > 0){
                table.addCell(createItemNameCell(getTran("web","province").toUpperCase()));
                table.addCell(createItemValueCell(privateData.province));
            }
            
            // City/Municipality
            if(privateData.city.length() > 0){
                table.addCell(createItemNameCell(getTran("web","city").toUpperCase()));
                table.addCell(createItemValueCell(privateData.city));
            }
            
            // Sector/Locality
            if(privateData.sector.length() > 0){
                table.addCell(createItemNameCell(getTran("web","sector").toUpperCase()));
                table.addCell(createItemValueCell(privateData.sector));
            }
            
            // Cell
            if(privateData.cell.length() > 0){
                table.addCell(createItemNameCell(getTran("web","cell").toUpperCase()));
                table.addCell(createItemValueCell(privateData.cell));
            }
            
            // Address
            if(privateData.address.length() > 0){
                table.addCell(createItemNameCell(getTran("web","address").toUpperCase()));
                table.addCell(createItemValueCell(privateData.address));
            }
            
            // Email
            if(privateData.email.length() > 0){
                table.addCell(createItemNameCell(getTran("web","email").toUpperCase()));
                table.addCell(createItemValueCell(privateData.email));
            }
            
            // Telephone
            if(privateData.telephone.length() > 0){
                table.addCell(createItemNameCell(getTran("web","telephone").toUpperCase()));
                table.addCell(createItemValueCell(privateData.telephone));
            }
            
            // Mobile/Cellphone
            if(privateData.mobile.length() > 0){
                table.addCell(createItemNameCell(getTran("web","mobile").toUpperCase()));
                table.addCell(createItemValueCell(privateData.mobile));
            }
            
            // Function/Position
            if(privateData.businessfunction.length() > 0){
                table.addCell(createItemNameCell(getTran("web","function").toUpperCase()));
                table.addCell(createItemValueCell(privateData.businessfunction));
            }
            
            // Business/Company
            if(privateData.business.length() > 0){
                table.addCell(createItemNameCell(getTran("web","business").toUpperCase()));
                table.addCell(createItemValueCell(privateData.business));
            }
            
            // Comment
            if(privateData.comment.length() > 0){
                table.addCell(createItemNameCell(getTran("web","comment").toUpperCase()));
                table.addCell(createItemValueCell(privateData.comment));               
            }

            // add transaction to doc
            if(table.size() > 0){
                doc.add(new Paragraph(" "));
                doc.add(table);
            }
        }
    }
    
    //--- PRINT ACTIVE INSURANCES -----------------------------------------------------------------
    protected void printActiveInsurances(AdminPerson activePatient) throws Exception {                    
        table = new PdfPTable(8);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","activeInsurances"),8));
        
        // list active insurances
        Vector activeInsurances = Insurance.getCurrentInsurances(activePatient.personid);
        if(activeInsurances.size() > 0){
            Iterator insuranceIter = activeInsurances.iterator();
            Insurance insurance;
            
            // header
            table.addCell(createHeaderCell(getTran("insurance","insuranceNr"),2));
            table.addCell(createHeaderCell(getTran("web","company"),3));
            table.addCell(createHeaderCell(getTran("web","begindate"),1));
            table.addCell(createHeaderCell(getTran("web","tariff"),2));
            
            while(insuranceIter.hasNext()){
                insurance = (Insurance)insuranceIter.next();

                // company
                String sCompany = "";
                if(insurance.getInsuranceCategoryLetter().length()>0 && insurance.getInsuranceCategory().getLabel().length()>0){
                    sCompany = ScreenHelper.checkString(insurance.getInsuranceCategory().getInsurar().getName());
                    sCompany+= " ("+insurance.getInsuranceCategory().getCategory()+": "+
                               insurance.getInsuranceCategory().getPatientShare()+"/"+(100-Integer.parseInt(insurance.getInsuranceCategory().getPatientShare()))+
                               ")";
                }
                
                table.addCell(createValueCell(ScreenHelper.checkString(insurance.getInsuranceNr()),2));
                table.addCell(createValueCell(ScreenHelper.checkString(sCompany),3));
                table.addCell(createValueCell(ScreenHelper.checkString(insurance.getStart()!=null?ScreenHelper.stdDateFormat.format(insurance.getStart()):""),1));
                table.addCell(createValueCell(ScreenHelper.checkString(getTran("insurance.types",insurance.getType())),2));
            }
        }
        else{
        	// no records found
        	table.addCell(createValueCell(getTran("web","noActiveInsurancesFound"),8));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }     
    }
    
    //--- PRINT INSURANCE HISTORY -----------------------------------------------------------------
    protected void printInsuranceHistory(AdminPerson activePatient) throws Exception {
        table = new PdfPTable(8);
        table.setWidthPercentage(pageWidth);

        // title
        table.addCell(createTitleCell(getTran("web","historyInsurances"),8));

        // list closed insurances
        Vector closedInsurances = Insurance.selectInsurances(activePatient.personid,"OC_INSURANCE_STOP",true); // closed                    
        if(closedInsurances.size() > 0){                
            // header
            table.addCell(createHeaderCell(getTran("insurance","insuranceNr"),1));
            table.addCell(createHeaderCell(getTran("web","company"),2));
            table.addCell(createHeaderCell(getTran("web","begindate"),1));
            table.addCell(createHeaderCell(getTran("web","enddate"),1));
            table.addCell(createHeaderCell(getTran("web","tariff"),1));
            table.addCell(createHeaderCell(getTran("web","comment"),2));

            Iterator insuranceIter = closedInsurances.iterator();
            String sStart = "", sStop = "", sCompanyName = "";
            Insurance insurance;
            Insurar insurar;
            
            while(insuranceIter.hasNext()){
                insurance = (Insurance)insuranceIter.next();

                // insurance
                if(insurance.getStart()!=null) sStart = ScreenHelper.stdDateFormat.format(insurance.getStart());
                else                           sStart = "";

                // stop
                if(insurance.getStop()!=null) sStop = ScreenHelper.stdDateFormat.format(insurance.getStop());
                else                          sStop = "";

                // insurer
                insurar = insurance.getInsurar();
                if(insurar!=null) sCompanyName = ScreenHelper.checkString(insurar.getName());
                else              sCompanyName = "";                    

                table.addCell(createValueCell(ScreenHelper.checkString(insurance.getInsuranceNr()),1));
                table.addCell(createValueCell(sCompanyName,2));
                table.addCell(createValueCell(sStart,1));
                table.addCell(createValueCell(sStop,1));
                table.addCell(createValueCell(ScreenHelper.checkString(getTran("insurance.types",insurance.getType())),1));
                table.addCell(createValueCell(insurance.getComment().toString().replaceAll("\r\n"," "),2));
            }
        }
        else{
        	// no records found
        	table.addCell(createValueCell(getTran("web","noRecordsFound"),8));  
        }

        // add transaction to doc
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }         
    }
    
    //--- PRINT SIGNATURE -------------------------------------------------------------------------
    protected void printSignature() throws Exception {             
        table = new PdfPTable(2);
        table.setWidthPercentage(100);
        
        cell = new PdfPCell();
        cell.setBorder(PdfPCell.NO_BORDER);
        table.addCell(cell);
        
        cell = new PdfPCell(new Paragraph(getTran("web","signature").toUpperCase()+"\n\n\n\n\n\n\n\n",FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.ITALIC)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        table.addCell(cell);

        // add table
        if(table.size() > 0){
            doc.add(new Paragraph(" "));
            doc.add(table);
        }      
    }
    
    
    //#############################################################################################
    //################################### UTILITY FUNCTIONS #######################################
    //#############################################################################################
    
    //--- CHECK STRING ----------------------------------------------------------------------------
    protected String checkString(String value){
        return ScreenHelper.checkString(value);
    }
    
    //**********************************************************************************************
    //*** CELLS ************************************************************************************
    //**********************************************************************************************

    //--- EMPTY CELL -------------------------------------------------------------------------------
    protected PdfPCell emptyCell(int colspan){
        cell = emptyCell();
        cell.setColspan(colspan);

        return cell;
    }

    protected PdfPCell emptyCell(){
        cell = new PdfPCell();
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);

        return cell;
    }

    //--- CREATE CELL ------------------------------------------------------------------------------
    protected PdfPCell createCell(PdfPCell childCell, int colspan, int alignment, int border){
        childCell.setColspan(colspan);
        childCell.setHorizontalAlignment(alignment);
        childCell.setBorder(border);
        childCell.setBorderColor(innerBorderColor);
        childCell.setVerticalAlignment(PdfPCell.TOP);

        return childCell;
    }

    //--- CREATE CONTENT CELL ----------------------------------------------------------------------
    protected PdfPCell createContentCell(PdfPTable contentTable){
        cell = new PdfPCell(contentTable);
        cell.setPadding(3);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL ---------------------------------------------------------------------
    protected PdfPCell createItemNameCell(String itemName, int colspan){
        cell = new PdfPCell(new Paragraph(itemName.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createItemNameCell(String itemName){
        return createItemNameCell(itemName,2);
    }

    //--- CREATE VALUE CELL ------------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createValueCell(String value){
        return createValueCell(value,3);
    }

    //--- CREATE TITLE CELL ------------------------------------------------------------------------
    protected PdfPCell createTitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);

        return cell;
    }

    //--- CREATE SUBTITLE CELL --------------------------------------------------------------------
    protected PdfPCell createSubtitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)8*fontSizePercentage/100.0),Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setBackgroundColor(BGCOLOR_LIGHT);

        return cell;
    }

    //--- CREATE HEADER CELL -----------------------------------------------------------------------
    protected PdfPCell createHeaderCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.BOLDITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(220,220,220)); // grey

        return cell;
    }

    //--- CREATE INVISIBLE CELL -------------------------------------------------------------------
    protected PdfPCell createInvisibleCell(){
        return createInvisibleCell(1);
    }

    protected PdfPCell createInvisibleCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createTitle(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,10,Font.UNDERLINE)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE TITLE ----------------------------------------------------------------------------
    protected PdfPCell createLabel(String msg, int fontsize, int colspan, int style){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontsize,style)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    protected PdfPCell createBorderlessCell(String value, int colspan){
        return createBorderlessCell(value,3,colspan);
    }

    protected PdfPCell createBorderlessCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMVALUE CELL -------------------------------------------------------------------
    protected PdfPCell createItemValueCell(String itemValue){
        return createItemValueCell(itemValue,3);         
    }
    
    protected PdfPCell createItemValueCell(String itemValue, int colspan){
        cell = new PdfPCell(new Paragraph(itemValue,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL))); // no uppercase
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE PADDED VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createPaddedValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setPaddingRight(5); // difference

        return cell;
    }

    //--- CREATE NUMBER VALUE CELL ----------------------------------------------------------------
    protected PdfPCell createNumberCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,Math.round((double)7*fontSizePercentage/100.0),Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);

        return cell;
    }

    //*********************************************************************************************
    //*** ABSTRACT ********************************************************************************
    //*********************************************************************************************    
    
    //--- GENERATE DOCUMENT BYTES (1) -------------------------------------------------------------
    public abstract ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application, 
                                                                   boolean filterApplied, int partsOfTransactionToPrint) 
            throws DocumentException;

    //--- GENERATE DOCUMENT BYTES (2) -------------------------------------------------------------
    public abstract ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application) 
            throws DocumentException;
    
}
