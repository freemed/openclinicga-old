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

public class PDFMinimalClinicalData extends PDFGeneralBasic {

    //--- ADD CONTENT ------------------------------------------------------------------------------
    protected void addContent(){
        try{
            if(transactionVO.getItems().size() >= minNumberOfItems){                                         
                // COMMENT
                table = new PdfPTable(5);
                itemValue = getItemSeriesValue(IConstants_PREFIX+"ITEM_TYPE_MCD_COMMENT");
                if(itemValue.length() > 0){
                    addItemRow(table,getTran("web","comment"),itemValue);
                    tranTable.addCell(new PdfPCell(table));
                }  
            	      	            	                         
                // add transaction to doc
                addTransactionToDoc(); 
                
                // DIAGNOSIS ENCODING
                addDiagnosisEncoding();
                addTransactionToDoc(); 
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
	
}
