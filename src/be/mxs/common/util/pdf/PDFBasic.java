package be.mxs.common.util.pdf;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;

import java.util.Vector;
import java.util.Iterator;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;

import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletContext;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;

/**
 * User: Frank
 * Date: 1-mrt-2005
 */
//#################################################################################################
// Contains code used by the specific PDFBasic classes.
//#################################################################################################
public abstract class PDFBasic {

    // declarations
    private final SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
    protected final String IConstants_PREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";
    protected final BaseColor innerBorderColor = BaseColor.LIGHT_GRAY;
    protected final BaseColor BGCOLOR_LIGHT = new BaseColor(240,240,240); // light gray

    protected String sPrintLanguage;
    protected SessionContainerWO sessionContainerWO;
    protected Document doc;
    protected TransactionVO transactionVO;
    protected AdminPerson patient;
    protected User user;
    protected HttpServletRequest req;
    protected ServletContext application;
    protected String sProject;
    protected Date dateFrom, dateTo;
    protected PdfPTable table, contentTable, tranTable;
    protected PdfPCell cell;
    protected String itemValue;


    //--- GET HEADER TABLE ------------------------------------------------------------------------
    protected PdfPTable getHeaderTable(TransactionVO transactionVO){
        PdfPTable headerTable = new PdfPTable(10);
        headerTable.setWidthPercentage(100);

        try{
            // transaction date
            cell = new PdfPCell(new Paragraph(dateFormat.format(transactionVO.getUpdateTime()), FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(1);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            headerTable.addCell(cell);

            // transaction type
            cell = new PdfPCell(new Paragraph(getTran("Web.Occup",transactionVO.getTransactionType()).toUpperCase(),FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(5);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            headerTable.addCell(cell);

            // transaction context
            ItemVO item = transactionVO.getItem(IConstants_PREFIX+"ITEM_TYPE_CONTEXT_CONTEXT");
            cell = new PdfPCell(new Paragraph(item!=null?getTran("Web.Occup",item.getValue()):"",FontFactory.getFont(FontFactory.HELVETICA,8,Font.ITALIC)));
            cell.setColspan(4);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            headerTable.addCell(cell);

            // new row : name of user who registered the transaction
            User registeringUser = new User();
            registeringUser.initialize(transactionVO.user.getUserId().intValue());
            String username = registeringUser.person.lastname+" "+registeringUser.person.firstname;
            System.out.println("@@@@@@@@@@@@@@@@@@@@@@@@@ username : "+username); //////////////
            
            cell = new PdfPCell(new Paragraph(getTran("web.occup","medwan.common.user").toUpperCase()+" : "+username,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
            cell.setColspan(10);
            cell.setBorder(PdfPCell.BOX);
            cell.setVerticalAlignment(PdfPCell.ALIGN_LEFT);
            headerTable.addCell(cell);
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return headerTable;
    }

    //--- GET TRAN --------------------------------------------------------------------------------
    protected String getTran(String type, String id){
        String sReturn = ScreenHelper.getTranNoLink(type,id,sPrintLanguage);
        sReturn = ScreenHelper.convertHtmlCodeToChar(sReturn);

        return sReturn;
    }

    protected String getTran(String id){
        return getTran("Web.Occup",id);
    }

    //--- GET ITEM VALUE --------------------------------------------------------------------------
    protected String getItemValue(TransactionVO transactionVO, String itemType){
        if(transactionVO != null){
            ItemVO itemVO = transactionVO.getItem(itemType);
            if(itemVO != null){
                return itemVO.getValue();
            }
        }

        return "";
    }

    protected String getItemValue(String itemType){
        return getItemValue(transactionVO,itemType);
    }

    //--- GET LAST ITEM VALUE ---------------------------------------------------------------------
    protected String getLastItemValue(String itemType){
        return MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(patient.personid),itemType);
    }

    //--- VERIFY LIST -----------------------------------------------------------------------------
    // Check if at least one of the items specified in the list, exist in this transactionVO.
    //---------------------------------------------------------------------------------------------
    protected boolean verifyList(Vector list){
        Iterator iterator = list.iterator();
        while(iterator.hasNext()){
            if(transactionVO.getItem((String)iterator.next())!=null){
                return true;
            }
        }

        // no items found
        return false;
    }

    protected boolean verifyList(Vector list, String from, String to){
        Iterator iterator = list.iterator();
        boolean bStart = false;
        String type;

        while(iterator.hasNext()){
            type = (String)iterator.next();
            if(type.equalsIgnoreCase(from)){
                bStart = true;
            }

            if(bStart){
                if(transactionVO.getItem(type)!=null){
                    return true;
                }
            }

            if(type.equalsIgnoreCase(to)){
                break;
            }
        }

        return false;
    }

    //--- CHECK FOR ITEM CONTENT ------------------------------------------------------------------
    // Check if at least one of the items specified in the vector has a value.
    //---------------------------------------------------------------------------------------------
    protected boolean checkForItemContent(Vector itemList){
        Iterator iter = itemList.iterator();

        while(iter.hasNext()){
            if(getItemValue((String)iter.next()).length() > 0){
                return true;
            }
        }

        return false;
    }

    //--- PRINT LIST ------------------------------------------------------------------------------
    protected String printList(Vector list, boolean bValue, String separator){
        String sResult = "";
        Iterator iterator = list.iterator();
        ItemVO item;

        while(iterator.hasNext()){
            item = transactionVO.getItem((String)iterator.next());
            if(item != null){
                if(sResult.length()>0){
                    sResult+=separator;
                }
                sResult+=getTran(item.getType());
                if(bValue){
                    sResult+=getTran(item.getValue());
                }
            }
        }

        return sResult;
    }

    protected String printList(Vector list, boolean bValue){
        return printList(list,bValue,"\n");
    }

    //--- POPULATE TRANSACTION TYPES --------------------------------------------------------------
    protected Vector populateTransactionTypes(String sTransactionType){
        Vector list = new Vector();
        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT itemTypeId FROM TransactionItems WHERE transactionTypeId = ?";
            PreparedStatement ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,sTransactionType);
            ResultSet rs = ps.executeQuery();
            while(rs.next()){
                list.add(rs.getString("itemTypeId"));
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        try{
			loc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return list;
    }

    //*********************************************************************************************
    //*** ROWS ************************************************************************************
    //*********************************************************************************************

    //--- ADD ITEM ROW ----------------------------------------------------------------------------
    protected void addItemRow(PdfPTable table, String itemName, String itemValue){
        table.addCell(createItemNameCell(itemName));
        table.addCell(createValueCell(itemValue));
    }

    //--- ADD BLANK ROW ---------------------------------------------------------------------------
    protected void addBlankRow(int height){
        try{
            PdfPTable table = new PdfPTable(1);
            table.setTotalWidth(100);
            cell = new PdfPCell(new Phrase());
            cell.setBorder(PdfPCell.NO_BORDER);
            cell.setPaddingTop(height);
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

    //*********************************************************************************************
    //*** CELLS ***********************************************************************************
    //*********************************************************************************************

    //--- EMPTY CELL ------------------------------------------------------------------------------
    protected PdfPCell emptyCell(int colspan){
        cell = new PdfPCell();
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);

        return cell;
    }

    protected PdfPCell emptyCell(){
        cell = new PdfPCell();
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE CELL -----------------------------------------------------------------------------
    protected PdfPCell createCell(PdfPCell childCell, int colspan, int alignment, int border){
        childCell.setColspan(colspan);
        childCell.setHorizontalAlignment(alignment);
        childCell.setBorder(border);
        childCell.setBorderColor(innerBorderColor);
        childCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);

        return childCell;
    }

    //--- CREATE CONTENT CELL ---------------------------------------------------------------------
    protected PdfPCell createContentCell(PdfPTable contentTable){
        cell = new PdfPCell(contentTable);
        cell.setPadding(3);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setBorder(PdfPCell.NO_BORDER);

        return cell;
    }

    //--- CREATE ITEMNAME CELL --------------------------------------------------------------------
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

    //--- CREATE HEADER CELL ----------------------------------------------------------------------
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

    //--- CREATE HEADER CELL ----------------------------------------------------------------------
    protected PdfPCell createHeaderCell(String msg, int colspan, int fontSize){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.ITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(BGCOLOR_LIGHT);

        return cell;
    }

    //--- CREATE TITLE CELL -----------------------------------------------------------------------
    protected PdfPCell createTitleCell(String msg, int colspan){
        cell = new PdfPCell(new Paragraph(msg,FontFactory.getFont(FontFactory.HELVETICA,7,Font.BOLDITALIC)));
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.BOX);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(220,220,220)); // grey

        return cell;
    }

    //--- CREATE VALUE CELL -----------------------------------------------------------------------
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

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,7,Font.NORMAL)));
        cell.setPaddingTop(height);
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setBorderColor(innerBorderColor);
        cell.setVerticalAlignment(PdfPCell.ALIGN_TOP);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_LEFT);

        return cell;
    }

    //--- CREATE BORDERLESS CELL ------------------------------------------------------------------
    protected PdfPCell createBorderlessCell(String value, int height, int colspan,int fontSize){
        cell = new PdfPCell(new Paragraph(value,FontFactory.getFont(FontFactory.HELVETICA,fontSize,Font.NORMAL)));
        cell.setPaddingTop(height);
        cell.setColspan(colspan);
        cell.setBorder(PdfPCell.NO_BORDER);
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
        cell.setBorder(PdfPCell.NO_BORDER);
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
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(150,150,150)); // light gray

        return cell;
    }

    protected PdfPCell createGreyCell(String value){
        return createGreyCell(value,1);
    }


    //--- CHECK STRING ----------------------------------------------------------------------------
    protected String checkString(String string){
        return ScreenHelper.checkString(string);
    }

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

    //--- GET CONFIG PARAM ------------------------------------------------------------------------
    protected String getConfigParam(String key, String param){
        return getConfigString(key).replaceAll("<param>",param);
    }

    //--- GET CONFIG STRING -----------------------------------------------------------------------
    protected String getConfigString(String key){
        String configString = "";

        try{
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        	Statement st = oc_conn.createStatement();
            ResultSet Configrs = st.executeQuery("SELECT oc_value FROM OC_Config WHERE oc_key like '"+key+"'"+
        	                                     " AND deletetime is null ORDER BY oc_key");
            while (Configrs.next()){
                configString+= Configrs.getString("oc_value");
            }
            Configrs.close();
            st.close();
            oc_conn.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return checkString(configString);
    }

    //--- ADD TRANSACTION TO DOC ------------------------------------------------------------------
    protected void addTransactionToDoc(){
        if(tranTable.size() > 0){
            try{
                PdfPTable outerTable = new PdfPTable(1);
                outerTable.setWidthPercentage(100);

                cell = new PdfPCell(tranTable);
                cell.setVerticalAlignment(PdfPCell.TOP);
                cell.setBorderColor(innerBorderColor);

                outerTable.addCell(cell);
                doc.add(outerTable);
                
                // new transaction table
                tranTable = new PdfPTable(1);
                tranTable.setWidthPercentage(80);
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

}
