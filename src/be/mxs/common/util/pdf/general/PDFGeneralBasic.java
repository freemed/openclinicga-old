package be.mxs.common.util.pdf.general;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.PDFBasic;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.Diagnosis;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.Problem;
import be.openclinic.medical.ReasonForEncounter;
import be.openclinic.pharmacy.Product;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;

import java.util.Collection;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import net.admin.AdminPerson;
import net.admin.Service;
import net.admin.User;
import javax.servlet.http.HttpServletRequest;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;


/**
 * User: Frank
 * Date: 1-mrt-2005
 */
//##################################################################################################
// Contains code used by most of the specific examination classes.
//##################################################################################################
public abstract class PDFGeneralBasic extends PDFBasic {

    // declarations
    private final SimpleDateFormat dateFormat = ScreenHelper.stdDateFormat;
    protected final int minNumberOfItems = 2;
    

    //--- DISPLAY TRANSACTION ITEMS ---------------------------------------------------------------
    // for debugging purposes
    protected void displayTransactionItems(TransactionVO tran){
    	Debug.println("\n#### TRANSACTION ITEMS ("+tran.getServerId()+"."+tran.getTransactionId()+") ########################################"); 
    	
    	ItemVO item;
	    for(int i=0; i<tran.getItems().size(); i++){
	    	item = (ItemVO)((java.util.Vector)tran.getItems()).get(i);
	    	Debug.println("["+i+"] : "+item.getType()+" = "+item.getValue());
	    }
	                                            
	    Debug.println("########################################################################\n");
    }

    //--- GET ITEM TYPE ---------------------------------------------------------------------------
    public String getItemType(Collection collection, String sItemType){
        String sText = "";
        ItemVO item;
        Object[] aItems = collection.toArray();
        int i, j;

        for(i=1; i<6; i++){
            for(j=0; j<aItems.length; j++){
                item = (ItemVO)aItems[j];
                if(item.getType().toLowerCase().equals(sItemType.toLowerCase()+i)){
                    sText+= checkString(item.getValue());
                }
            }
        }

        if(sText.trim().length()==0){
            for(j=0; j<aItems.length; j++){
                item = (ItemVO) aItems[j];
                if (item.getType().toLowerCase().equals(sItemType.toLowerCase())){
                    sText+= checkString(item.getValue());
                }
            }
        }

        return sText;
    }
    
    //--- GET HEADER TABLE -------------------------------------------------------------------------
    protected PdfPTable getHeaderTable(TransactionVO transactionVO){
        PdfPTable headerTable = new PdfPTable(10);
        headerTable.setWidthPercentage(100);

        try {
            doc.add(new Paragraph(" "));

            // transaction date
            cell = new PdfPCell(new Paragraph(dateFormat.format(transactionVO.getUpdateTime()),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(1);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBorderColor(innerBorderColor);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            headerTable.addCell(cell);

            // transaction type
            cell = new PdfPCell(new Paragraph(getTran("Web.Occup",transactionVO.getTransactionType()).toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(5);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBorderColor(innerBorderColor);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            headerTable.addCell(cell);

            // transaction context
            ItemVO item = transactionVO.getItem(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
            Service service=null;
            if(item!=null){
            	Encounter encounter=Encounter.get(item.getValue());
            	if(encounter!=null){
            		service=encounter.getService();
            	}
            }
            cell = new PdfPCell(new Paragraph(service!=null?service.getLabel(sPrintLanguage):"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(4);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBorderColor(innerBorderColor);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            headerTable.addCell(cell);

            // name of user who registered the transaction
            cell = new PdfPCell(new Paragraph(getTran("web.occup","medwan.common.user").toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
            cell.setColspan(4);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorderColor(innerBorderColor);
            headerTable.addCell(cell);

            String username = "?";
            User registeringUser = User.get(transactionVO.user.getUserId().intValue());
            if(registeringUser!=null){
            	username = registeringUser.person.getFullName();
            }
            cell = new PdfPCell(new Paragraph(username,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
            cell.setColspan(6);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
            cell.setBorderColor(innerBorderColor);
            headerTable.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return headerTable;
    }

    //**********************************************************************************************
    //*** ROWS *************************************************************************************
    //**********************************************************************************************
    
    //--- ADD ITEM ROW -----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        table.addCell(createItemNameCell(itemName));
        table.addCell(createValueCell(itemValue));
    }

    //--- ADD BLANK ROW ----------------------------------------------------------------------------
    protected void addBlankRow(int height){
        try{
            PdfPTable table = new PdfPTable(1);
            table.setTotalWidth(100);
            cell = new PdfPCell(new Phrase());
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPaddingTop(height); //
            table.addCell(cell);
            doc.add(table);
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    protected void addBlankRow(){
        addBlankRow(5);
    }


    //**********************************************************************************************
    //*** CELLS ************************************************************************************
    //**********************************************************************************************

    //--- CHECKBOX CELL ---------------------------------------------------------------------------
    public PdfPCell checkBoxCell(boolean checked) throws Exception {
        return checkBoxCell(checked,1); // one cell wide
    }

    public PdfPCell checkBoxCell(boolean checked, int colspan) throws Exception {
        return checkBoxCell(checked,colspan,false); // no border
    }
    
    public PdfPCell checkBoxCell(boolean checked, int colspan, boolean drawBorder) throws Exception {
        Image img;
        if(checked) img = Miscelaneous.getImage("themes/default/check.gif","");
        else        img = Miscelaneous.getImage("themes/default/uncheck.gif","");

        img.scaleAbsolute(8,8);
        cell = new PdfPCell(img);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(drawBorder?PdfPCell.BOX:PdfPCell.NO_BORDER);
        if(drawBorder){
            cell.setBorderColor(innerBorderColor);
        }
        cell.setColspan(colspan);

        return cell;
    }
    
    //--- CHECKBOX CELL WITH LABEL ----------------------------------------------------------------
    public PdfPCell checkBoxCellWithLabel(boolean checked, String sLabel) throws Exception {
        return checkBoxCellWithLabel(checked,1,sLabel); // one cell wide
    }

    public PdfPCell checkBoxCellWithLabel(boolean checked, int colspan, String sLabel) throws Exception {
        return checkBoxCellWithLabel(checked,colspan,sLabel,true); // border
    }
    
    public PdfPCell checkBoxCellWithLabel(boolean checked, int colspan, String sLabel, boolean drawBorder) throws Exception {
        Image img;
        if(checked) img = Miscelaneous.getImage("themes/default/check.gif","");
        else        img = Miscelaneous.getImage("themes/default/uncheck.gif","");

        img.scaleAbsolute(8,8);
        
        PdfPTable miniTable = new PdfPTable(2);
        cell = new PdfPCell(img);
        cell.setPadding(4);
        cell.setPaddingRight(0);
        cell.setBorder(0);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        miniTable.addCell(cell);

        Paragraph par = new Paragraph(sLabel,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
        cell = new PdfPCell(par);
        cell.setPadding(3);
        cell.setBorder(0);
        miniTable.addCell(cell);

        cell = new PdfPCell(miniTable);  
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(drawBorder?PdfPCell.BOX:PdfPCell.NO_BORDER);
        if(drawBorder){
            cell.setBorderColor(innerBorderColor);
        }
        cell.setColspan(colspan);

        return cell;
    }
    
    //--- RADIO CELL ------------------------------------------------------------------------------
    public PdfPCell radioCell(boolean selected) throws Exception {
        return radioCell(selected,1); // one cell wide
    }

    public PdfPCell radioCell(boolean selected, int colspan) throws Exception {
        return radioCell(selected,colspan,true); // border
    }
    
    public PdfPCell radioCell(boolean selected, int colspan, boolean drawBorder) throws Exception {
        Image img;
        if(selected) img = Miscelaneous.getImage("themes/default/radioSelected.gif","");
        else         img = Miscelaneous.getImage("themes/default/radioNotSelected.gif","");

        img.scaleAbsolute(8,8);
        cell = new PdfPCell(img);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(drawBorder?PdfPCell.BOX:PdfPCell.NO_BORDER);
        if(drawBorder){
            cell.setBorderColor(innerBorderColor);
        }
        cell.setColspan(colspan);

        return cell;
    }
    
    //--- RADIO CELL WITH LABEL -------------------------------------------------------------------
    public PdfPCell radioCellWithLabel(boolean selected, String sLabel) throws Exception {
        return radioCellWithLabel(selected,1,sLabel,true); // border
    }
    
    public PdfPCell radioCellWithLabel(boolean selected, int colspan, String sLabel) throws Exception {
        return radioCellWithLabel(selected,colspan,sLabel,true); // border
    }
    
    public PdfPCell radioCellWithLabel(boolean selected, int colspan, String sLabel, boolean drawBorder) throws Exception {
        Image img;
        if(selected) img = Miscelaneous.getImage("themes/default/radioSelected.gif","");
        else         img = Miscelaneous.getImage("themes/default/radioNotSelected.gif","");

        img.scaleAbsolute(8,8);
        
        PdfPTable miniTable = new PdfPTable(2);
        cell = new PdfPCell(img);
        cell.setPadding(4);
        cell.setPaddingRight(0);
        cell.setBorder(0);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_RIGHT);
        miniTable.addCell(cell);

        Paragraph par = new Paragraph(sLabel,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL));
        cell = new PdfPCell(par);
        cell.setPadding(3);
        cell.setBorder(0);
        miniTable.addCell(cell);
        
        cell = new PdfPCell(miniTable);        
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBorder(drawBorder?PdfPCell.BOX:PdfPCell.NO_BORDER);
        if(drawBorder){
            cell.setBorderColor(innerBorderColor);
        }
        cell.setColspan(colspan);

        return cell;
    }

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
        cell = new PdfPCell(new Paragraph(itemName.toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
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

    //--- CREATE HEADER CELL -----------------------------------------------------------------------
    protected PdfPCell createHeaderCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(BGCOLOR_LIGHT);

        return cell;
    }

    //--- CREATE TITLE CELL ------------------------------------------------------------------------
    protected PdfPCell createTitleCell(String msg, int colspan){
    	return createTitleCell(msg,PdfPCell.ALIGN_CENTER,colspan); // default align = center
    }

    protected PdfPCell createTitleCell(String msg, int alignment, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(alignment);
        cell.setBackgroundColor(new BaseColor(220,220,220)); // grey

        return cell;
    }

    //--- CREATE SUBTITLE CELL --------------------------------------------------------------------
    protected PdfPCell createSubtitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(BaseColor.LIGHT_GRAY);
        cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
        cell.setBackgroundColor(BGCOLOR_LIGHT);

        return cell;
    }

    //--- CREATE VALUE CELL ------------------------------------------------------------------------
    protected PdfPCell createValueCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
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

    //--- CREATE BORDERLESS CELL -------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height); //
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX); //
        cell.setBorderColor(innerBorderColor);
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
        cell.setBorder(PdfPCell.NO_BORDER); //
        //was : cell.setBorder(PdfPCell.TOP+PdfPCell.BOTTOM); //
        cell.setBorderColor(innerBorderColor);

        return cell;
    }


    //*********************************************************************************************
    //*** COLOR CELLS *****************************************************************************
    //*********************************************************************************************
    
    //--- CREATE GREEN CELL -----------------------------------------------------------------------
    protected PdfPCell createGreenCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(60,220,60)); // light green

        return cell;
    }

    protected PdfPCell createGreenCell(String value){
        return createGreenCell(value,1);
    }

    //--- CREATE RED CELL -------------------------------------------------------------------------
    protected PdfPCell createRedCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(1);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(230,50,50)); // light red

        return cell;
    }

    protected PdfPCell createRedCell(String value){
        return createRedCell(value,1);
    }

    //--- CREATE GREY CELL ------------------------------------------------------------------------
    protected PdfPCell createGreyCell(String value, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(245,245,245)); // light gray

        return cell;
    }

    protected PdfPCell createGreyCell(String value){
        return createGreyCell(value,1);
    }
    
    //**********************************************************************************************
    //*** VARIA ************************************************************************************
    //**********************************************************************************************

    //--- GET PROVIDER NAME FROM CODE -------------------------------------------------------------
    // used in : PDFLabRequest, PDFMedicalImagingRequest, PDFOtherRequests
    //---------------------------------------------------------------------------------------------
    protected String getProviderNameFromCode(String code) throws SQLException {
        String name = "";

        // compose select
        String lowerCode = getConfigParam("lowerCompare","code");
        String sQuery = "SELECT name FROM Providers WHERE "+lowerCode+" = ?";
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps = ad_conn.prepareStatement(sQuery);
        ps.setString(1,code);
        ResultSet rs = ps.executeQuery();

        if(rs.next()){
            name = rs.getString("name");
        }

        rs.close();
        ps.close();
        ad_conn.close();

        return name;
    }

    //--- GET ITEM SERIES VALUE -------------------------------------------------------------------
    protected String getItemSeriesValue(String sItemType){
        return getItemSeriesValue(transactionVO,sItemType);
    }

    protected String getItemSeriesValue(TransactionVO transactionVO, String sItemType){
        StringBuffer sBuffer = new StringBuffer();

        // search for item with number-less name (the first item)
        sBuffer.append(checkString(getItemValue(transactionVO,sItemType)));

        // search for items with a number at the end of the name (proceding items)
        String itemValue;
        for(int i=1; i<=15; i++){
            itemValue = checkString(getItemValue(transactionVO,sItemType+i));
            if(itemValue.length()==0) break;
            sBuffer.append(itemValue);
        }

        return sBuffer.toString();
    }

    //--- ADD ENCOUNTER DIAGNOSTICS ROW -----------------------------------------------------------
    protected void addEncounterDiagnosticsRow(PdfPTable table, String encounterUid){
    	cell=createHeaderCell(getTran("web","diagnostic.codes").toUpperCase(),5);
    	cell.setBorder(PdfPCell.BOX);
    	table.addCell(cell);
    	
    	Vector diagnoses = Diagnosis.selectDiagnoses("","",encounterUid,"","","","","","","","","icd10","");
    	if(diagnoses.size()>0){
            table.addCell(createItemNameCell(getTran("Web.Occup","ICD-10")));
            PdfPTable table2 = new PdfPTable(3);
            table2.setWidthPercentage(100);
    		for(int n=0;n<diagnoses.size();n++){
    			Diagnosis diagnosis = (Diagnosis)diagnoses.elementAt(n);
    			table2.addCell(createValueCell(diagnosis.getCode()+": "+MedwanQuery.getInstance().getCodeTran("icd10code"+diagnosis.getCode(),sPrintLanguage) ));
    		}
    		cell=new PdfPCell(table2);
    		cell.setColspan(3);
    		table.addCell(cell);
    	}
    	
    	diagnoses = Diagnosis.selectDiagnoses("","",encounterUid,"","","","","","","","","icpc","");
    	if(diagnoses.size()>0){
            table.addCell(createItemNameCell(getTran("Web.Occup","ICPC-2")));
            PdfPTable table2 = new PdfPTable(3);
            table2.setWidthPercentage(100);
    		for(int n=0;n<diagnoses.size();n++){
    			Diagnosis diagnosis = (Diagnosis)diagnoses.elementAt(n);
    			table2.addCell(createValueCell(diagnosis.getCode()+": "+MedwanQuery.getInstance().getCodeTran("icpccode"+diagnosis.getCode(),sPrintLanguage) ));
    		}
    		cell=new PdfPCell(table2);
    		cell.setColspan(3);
    		table.addCell(cell);
    	}
    	
    	diagnoses = Diagnosis.selectDiagnoses("","",encounterUid,"","","","","","","","","dsm4","");
    	if(diagnoses.size()>0){
            table.addCell(createItemNameCell(getTran("Web.Occup","DSM-4")));
            PdfPTable table2 = new PdfPTable(3);
            table2.setWidthPercentage(100);
    		for(int n=0;n<diagnoses.size();n++){
    			Diagnosis diagnosis = (Diagnosis)diagnoses.elementAt(n);
    			table2.addCell(createValueCell(diagnosis.getCode()+": "+MedwanQuery.getInstance().getCodeTran("dsm4code"+diagnosis.getCode(),sPrintLanguage) ));
    		}
    		cell=new PdfPCell(table2);
    		cell.setColspan(3);
    		table.addCell(cell);
    	}
    }
        
    //--- ADD DIAGNOSIS ENCODING ------------------------------------------------------------------
    // Reasons for encounter 
    // Diagnoses of the actual document 
    // Contact diagnoses
    protected void addDiagnosisEncoding() throws Exception {
        addDiagnosisEncoding(false,true,false);    	
    }
    
    protected void addDiagnosisEncoding(boolean printPart1, boolean printPart2, boolean printPart3) throws Exception {
        contentTable = new PdfPTable(1);
        
        table = new PdfPTable(2);
        table.setWidthPercentage(100);

    	String sActiveEncounterUID = "";
        String sEncounterUID = transactionVO.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
        if(sEncounterUID.length() > 0){
        	sActiveEncounterUID = sEncounterUID;
        }
        else{
            Encounter activeEnc = Encounter.getActiveEncounterOnDate(new java.sql.Timestamp(transactionVO.getUpdateTime().getTime()),this.patient.personid);
            if(activeEnc!=null){
            	sActiveEncounterUID = activeEnc.getUid();
            }
        }
        
        //***** PART 1 - reasons for encounter ********************************
        if(printPart1==true){        
	        if(sActiveEncounterUID.length() > 0){
	            Vector rfeVector = ReasonForEncounter.getReasonsForEncounterByEncounterUid(sActiveEncounterUID);
	            
	            if(rfeVector.size() > 0){	                    
	                PdfPTable rfeTable = new PdfPTable(20);
	                rfeTable.setWidthPercentage(100);
	
	                // title
	                String sTitle = getTran("openclinic.chuk","rfe")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	                cell = createTitleCell(sTitle,20);
	                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	                rfeTable.addCell(cell);
	                
	                ReasonForEncounter rfe;
	                for(int i=0; i<rfeVector.size(); i++){
	                	rfe = (ReasonForEncounter)rfeVector.get(i);
	                	
	                    // one encounter
	                    rfeTable.addCell(createValueCell(rfe.getCodeType().toUpperCase(),2));
	                    rfeTable.addCell(createValueCell(rfe.getCode(),2));
	                    rfeTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(rfe.getCodeType()+"code"+rfe.getCode(),sPrintLanguage),16));
	                }
	                
	                // add to main table
	    	        if(rfeTable.size() > 1){
		                cell = createBorderlessCell(2);
		                cell.addElement(rfeTable);
		                table.addCell(cell);
	    	        }
	            }
	        }
        }
        
        //***** PART 2 - ICPC / ICD10 *****************************************
        if(printPart2==true){
	        PdfPTable icpcTable = new PdfPTable(20);
	        icpcTable.setWidthPercentage(100);
	        
	        // title
	        String sTitle = getTran("openclinic.chuk","diagnostic.document")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	        cell = createTitleCell(sTitle,20);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        icpcTable.addCell(cell);
	                        
	        // fetch diagnoses
	        String sReferenceUID = transactionVO.getServerId()+"."+transactionVO.getTransactionId();
	        Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID,"Transaction");	
	        Iterator itemIter = transactionVO.getItems().iterator();

	        String sCode, sGravity, sCertainty, sPOA, sNC, sServiceUid, sFlags;
	        Hashtable hDiagnosisInfo;
	        ItemVO item;
	        
	        while(itemIter.hasNext()){
	            item = (ItemVO)itemIter.next();
	             
	            //***** a : ICPC *****	             
	            if(item.getType().indexOf("ICPCCode")==0){
	                sCode = item.getType().substring("ICPCCode".length(),item.getType().length());
	
	                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
	                if(hDiagnosisInfo!=null){
	                    sGravity    = (String)hDiagnosisInfo.get("Gravity");
	                    sCertainty  = (String)hDiagnosisInfo.get("Certainty");
	                    sPOA        = (String)hDiagnosisInfo.get("POA");
	                    sNC         = (String)hDiagnosisInfo.get("NC");
	                    sServiceUid = (String)hDiagnosisInfo.get("ServiceUid");
	                    sFlags      = (String)hDiagnosisInfo.get("Flags");
	                }
	                else{
	                    sGravity = "";
	                    sCertainty = "";
	                    sPOA = "";
	                    sNC = "";
	                    sServiceUid = "";
	                    sFlags = "";
	                }
	
	                // one ICPC
	                icpcTable.addCell(createValueCell("ICPC",2));
	                icpcTable.addCell(createValueCell(item.getType().replaceAll("ICPCCode",""),2));
	                icpcTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage)+" "+item.getValue().trim(),11));
	                icpcTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));
	     	    }		      
	            //***** b : icd10 *****
	            else if(item.getType().indexOf("ICD10Code")==0){
	                sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
	
	                hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
	                if(hDiagnosisInfo!=null){
	                    sGravity    = (String)hDiagnosisInfo.get("Gravity");
	                    sCertainty  = (String)hDiagnosisInfo.get("Certainty");
	                    sPOA        = (String)hDiagnosisInfo.get("POA");
	                    sNC         = (String)hDiagnosisInfo.get("NC");
	                    sServiceUid = (String)hDiagnosisInfo.get("ServiceUid");
	                    sFlags      = (String)hDiagnosisInfo.get("Flags");
	                } 
	                else{
	                    sGravity = "";
	                    sCertainty = "";
	                    sPOA = "";
	                    sNC = "";
	                    sServiceUid = "";
	                    sFlags = "";
	                }
	
	                // one ICD10
	                icpcTable.addCell(createValueCell("ICD10",2));
	                icpcTable.addCell(createValueCell(item.getType().replaceAll("ICD10Code",""),2));
	                icpcTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sPrintLanguage)+" "+item.getValue().trim(),11));
	                icpcTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));		               
	            }
	        }
	        
	        // add to main table
	        if(icpcTable.size() > 1){
		        cell = createBorderlessCell(2);
		        cell.addElement(icpcTable);
		        table.addCell(cell);
	        }
        }
        
        //***** PART 3 - diagnoses ********************************************
        if(printPart3==true){
	        PdfPTable diagTable = new PdfPTable(20);
	        diagTable.setWidthPercentage(100);
	        
	        String sTitle = getTran("openclinic.chuk","contact.diagnoses")+" "+getTran("web.occup","ICPC-2")+" / "+getTran("web.occup","ICD-10");
	        cell = createTitleCell(sTitle,20);
	        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
	        diagTable.addCell(cell);
	  
	        if(sActiveEncounterUID.length() > 0){
		        String sCode, sGravity, sCertainty, sPOA, sNC, sServiceUid, sFlags;
		        
		        String sReferenceUID = transactionVO.getServerId()+"."+transactionVO.getTransactionId();
		        Vector diagnoses = Diagnosis.selectDiagnoses("","",sActiveEncounterUID,"","","","","","","","","","");
	
		        Diagnosis diag;
		        for(int n=0; n<diagnoses.size(); n++){
		       	 diag = (Diagnosis)diagnoses.get(n);
		        	 
	                sGravity   = diag.getGravity()+"";
	                sCertainty = diag.getCertainty()+"";
	                sPOA       = diag.getPOA();
	                sNC        = diag.getNC();
	                sFlags     = diag.getFlags();
	                 
	     	        if(diag.getCodeType().equalsIgnoreCase("icpc")){
		    		    // one ICPC
	                    diagTable.addCell(createValueCell("ICPC",2));
			            diagTable.addCell(createValueCell(diag.getCode(),2));
			            diagTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran("icpccode"+diag.getCode(),sPrintLanguage)+" "+diag.getLateralisation(),11));
			            diagTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));
		            }
		            else if(diag.getCodeType().equalsIgnoreCase("icd10")){
		                // one ICD10
		            	diagTable.addCell(createValueCell("ICD10",2));
			            diagTable.addCell(createValueCell(diag.getCode(),2));
			            diagTable.addCell(createValueCell(MedwanQuery.getInstance().getCodeTran("icd10code"+diag.getCode(),sPrintLanguage)+" "+diag.getLateralisation(),11));
			            diagTable.addCell(createValueCell("G:"+sGravity+"/C:"+sCertainty+(sPOA.length()>0?" POA":"")+(sNC.length()>0?" N":"")+(sFlags.length()==0?"":" ("+sFlags+")"),5));			             	 				     		 
		            }
		        }
	            
	            // add to main table
    	        if(diagTable.size() > 1){
		            cell = createBorderlessCell(2);
		            cell.addElement(diagTable);
		            table.addCell(cell);
    	        }
	        }
        }       
        
	    // add table
	    if(table.size() > 0){
	        cell = createBorderlessCell(1);
	        cell.addElement(table);
	        tranTable.addCell(cell); 
	    }
    }
    
    //--- ADD ICPC CODES --------------------------------------------------------------------------
    protected void addICPCCodes() throws Exception {
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createHeaderCell(getTran("ICPC-2")+" / "+getTran("ICD-10"),5));
        Collection items = transactionVO.getItems();

        if(items!=null){
            Iterator itemIter = items.iterator();
            String value, type;
            ItemVO item;

            while(itemIter.hasNext()){
                item = (ItemVO)itemIter.next();

                if(item.getType().indexOf("ICPCCode")==0){
                    value = item.getValue().trim();
                    type = item.getType().trim();
                    type = type.replaceAll("ICPCCode","")+" "+MedwanQuery.getInstance().getCodeTran(type,sPrintLanguage);
                    table.addCell(createValueCell(type+" ["+value+"]",5));
                }
                else if(item.getType().indexOf("ICD10Code")==0){
                    value = item.getValue().trim();
                    type = item.getType().trim();
                    type = type.replaceAll("ICD10Code","")+" "+MedwanQuery.getInstance().getCodeTran(type,sPrintLanguage);
                    table.addCell(createValueCell(type+" ["+value+"]",5));
                }
            }

            // add icpc codes table
            if(table.size() > 1){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
    }

    //--- ADD PROBLEMLIST -------------------------------------------------------------------------
    protected void addProblemList(){
        contentTable = new PdfPTable(1);
        table = new PdfPTable(5);

        // title
        table.addCell(createTitleCell(getTran("web.occup","medwan.common.problemlist"),5));

        Vector activeProblems = Problem.getActiveProblems(patient.personid);
        if(activeProblems.size() > 0){
            PdfPTable problemsTable = new PdfPTable(3);

            // header
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.description"),2));
            problemsTable.addCell(createHeaderCell(getTran("web.occup","medwan.common.datebegin"),1));

            Problem activeProblem;
            String comment, value;
            for(int n=0; n<activeProblems.size(); n++){
                activeProblem = (Problem)activeProblems.elementAt(n);

                value = activeProblem.getCode()+" "+ MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(),sPrintLanguage);
                Paragraph par = new Paragraph(value, FontFactory.getFont(FontFactory.HELVETICA,7, Font.NORMAL));

                // add comment if any
                if(activeProblem.getComment().trim().length() > 0){
                    comment = " : "+activeProblem.getComment().trim();
                    par.add(new Chunk(comment,FontFactory.getFont(FontFactory.HELVETICA,7,Font.ITALIC)));
                }

                cell = new PdfPCell(par);
                cell.setColspan(2);
                cell.setBorder(PdfPCell.BOX);
                cell.setBorderColor(innerBorderColor);
                cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
                cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);
                problemsTable.addCell(cell);

                // date
                problemsTable.addCell(createValueCell(ScreenHelper.stdDateFormat.format(activeProblem.getBegin()),1));
            }
        }

        // add table
        if(table.size() > 1){
            if(contentTable.size() > 0) contentTable.addCell(emptyCell());
            contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));
            tranTable.addCell(createContentCell(contentTable));
        }
    }
    
    //--- ADD ACTIVE PRESCRIPTIONS ----------------------------------------------------------------
    protected void addActivePrescriptions(){
        try{
            contentTable = new PdfPTable(1);
            table = new PdfPTable(5);

            // Active prescriptions
            Vector vActivePrescriptions = Prescription.findActive(patient.personid,transactionVO.user.getUserId()+"","","","","","","");
            StringBuffer prescriptions = new StringBuffer();
            Vector idsVector = getActivePrescriptionsFromRs(prescriptions,vActivePrescriptions);
            PdfPTable prescrTable = new PdfPTable(4);

            if(idsVector.size() > 0){
                // title
                prescrTable.addCell(createTitleCell(getTran("Web.Occup","medwan.healthrecord.medication"),4));

                // header
                prescrTable.addCell(createTitleCell(getTran("Web","product"),4));
                prescrTable.addCell(createTitleCell(getTran("Web","begindate"),4));
                prescrTable.addCell(createTitleCell(getTran("Web","enddate"),4));
                prescrTable.addCell(createTitleCell(getTran("Web","prescriptionrule"),4));

                // medicines
                itemValue = prescriptions.toString();
                prescrTable.addCell(createItemNameCell(getTran("openclinic.chuk","administer_medicines"),1));
                prescrTable.addCell(createValueCell(itemValue,3));

                // add prescriptions table
                if(prescrTable.size() > 0){
                    table.addCell(createCell(new PdfPCell(table),4,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                }
            }

            // add transaction to doc
            if(table.size() > 0){
                if(contentTable.size() > 0) contentTable.addCell(emptyCell());
                contentTable.addCell(createCell(new PdfPCell(table),1,PdfPCell.ALIGN_CENTER,PdfPCell.BOX));
                tranTable.addCell(createContentCell(contentTable));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }

    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions) throws SQLException {
        Vector idsVector = new Vector();
        Product product = null;
        String sClass = "1", sPrescriptionUid, sProductName = "", sProductUid, sPreviousProductUid = "",
               sTimeUnit, sTimeUnitCount,  sUnitsPerTimeUnit, sPrescrRule = "", sProductUnit, timeUnitTran;
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");

        // frequently used translations
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while(iter.hasNext()){
            prescription = (Prescription) iter.next();
            sPrescriptionUid = prescription.getUid();

            // alternate row-style
            if(sClass.equals("")) sClass = "1";
            else                  sClass = "";

            idsVector.add(sPrescriptionUid);

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if(!sProductUid.equals(sPreviousProductUid)){
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if(product!=null) sProductName = product.getName();
                else              sProductName = "";
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit         = prescription.getTimeUnit();
            sTimeUnitCount    = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran("web.prescriptions", "prescriptionrule");
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if(product != null) sProductUnit = product.getUnit();
                else                sProductUnit = "";

                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran("product.unit", sProductUnit);
                }
                else {
                    sProductUnit = getTran("product.units", sProductUnit);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran("prescription.timeunit", sTimeUnit);
                }
                else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran("prescription.timeunits", sTimeUnit);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append(sProductName+" ("+sPrescrRule.toLowerCase() + ")\n");
        }

        return idsVector;
    }

    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product;
        product = Product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }
    
    //--- PRINT (1) -------------------------------------------------------------------------------
    public void print(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                      AdminPerson adminPerson, HttpServletRequest req, String sProject, Date dateFrom,
                      Date dateTo, String sPrintLanguage, Integer partsOfTransactionToPrint){

        this.doc = doc;
        this.sessionContainerWO = sessionContainerWO;
        this.transactionVO = transactionVO;
        this.sPrintLanguage = sPrintLanguage;
        this.patient = adminPerson;
        this.req = req;
        this.sProject = sProject;
        this.dateFrom = dateFrom;
        this.dateTo = dateTo;

        // 0 = nothing, 1 = header, 2 = header + body
        if(partsOfTransactionToPrint.intValue() > 0){
            // put header and body in one table
            tranTable = new PdfPTable(1);
            tranTable.addCell(createCell(new PdfPCell(getHeaderTable(transactionVO)),1,PdfPCell.ALIGN_CENTER,PdfPCell.NO_BORDER));

            if(partsOfTransactionToPrint.intValue() > 1){
                addContent(); // contains addTableToDoc
            }
            else{
                // only header, no content
                addTransactionToDoc();
            }
        }
    }

    //--- PRINT (2) (overloader) ------------------------------------------------------------------
    public void print(Document doc, SessionContainerWO sessionContainerWO, TransactionVO transactionVO,
                      AdminPerson adminPerson, HttpServletRequest req, String sProject, String sPrintLanguage,
                      Integer partsOfTransactionToPrint){

        print(doc, sessionContainerWO, transactionVO, adminPerson, req, sProject, null, null,
              sPrintLanguage, partsOfTransactionToPrint);
    }

    //--- ABSTRACT --------------------------------------------------------------------------------
    protected abstract void addContent();

}
