package be.mxs.common.util.pdf.general.oc.examinations;

import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Iterator;
import java.util.Vector;

import com.itextpdf.text.Chunk;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPCell;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFGeneralBasic;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.Problem;
import be.openclinic.pharmacy.Product;

public class PDFFollowUpChildren extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){
                table = new PdfPTable(5);
                
                // TEST VIH (duration)
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_TEMPS");
                if(itemValue.length() > 0){
                         if(itemValue.equals("6.weeks"))    itemValue = itemValue.substring(0,itemValue.lastIndexOf("."))+" "+getTran("web","weeks").toLowerCase();
                	else if(itemValue.equals("7.5.months")) itemValue = itemValue.substring(0,itemValue.lastIndexOf("."))+" "+getTran("web","months").toLowerCase();
                	else if(itemValue.equals("9.months"))   itemValue = itemValue.substring(0,itemValue.lastIndexOf("."))+" "+getTran("web","months").toLowerCase();
                	else if(itemValue.equals("15.months"))  itemValue = itemValue.substring(0,itemValue.lastIndexOf("."))+" "+getTran("web","months").toLowerCase();
                	
                	addItemRow(table,getTran("cs.suivi.enfants","test.vih"),itemValue);
                }               	
                
                // RESULT
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_RESULTAT");
                if(itemValue.length() > 0){
                         if(itemValue.equals("+")) itemValue = getTran("web","positive");
                	else if(itemValue.equals("-")) itemValue = getTran("web","negative");
                	
                    addItemRow(table,getTran("web.occup","intradermo.result"),itemValue);
                }
                
                // DEATH
                itemValue = getItemValue(IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_DECES");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("cs.suivi.enfants","deces"),getTran("web",itemValue));
                }        
                
                // COMMENT
                //itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_0");
                itemValue = checkString(getItemValue(transactionVO,IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_0"))+
                		    checkString(getItemValue(transactionVO,IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_1"))+
                	        checkString(getItemValue(transactionVO,IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_2"))+
                		    checkString(getItemValue(transactionVO,IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_3"))+
                		    checkString(getItemValue(transactionVO,IConstants_PREFIX+"ITEM_TYPE_CS_SUIVI_ENFANTS_COMMENTAIRE_4"));
                		                    
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","comment"),itemValue);
                }
                
                if(table.size() > 0){
                    tranTable.addCell(new PdfPCell(table));
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
