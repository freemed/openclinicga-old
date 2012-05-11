package be.mxs.common.util.pdf;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.ByteArrayOutputStream;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import net.admin.User;
import net.admin.AdminPerson;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletContext;


/**
 * User: stijnsmets
 * Date: 5-jul-2006
 */

//#################################################################################################
// Provides some methods which are common for all PDFCreators.
//#################################################################################################
public abstract class PDFCreator {

    // declarations
    protected final String IConstants_PREFIX = "be.mxs.common.model.vo.healthrecord.IConstants.";
    protected String sPrintLanguage = null;
    protected Document doc = null;
    protected SessionContainerWO sessionContainerWO = null;
    protected User user = null;
    protected AdminPerson patient = null;
    protected String sProject = null;
    protected String sContextPath = "";
    protected String sProjectPath = "";
    protected Date dateFrom = null;
    protected Date dateTo = null;
    protected HttpServletRequest req = null;
    protected ServletContext application = null;
    protected SimpleDateFormat dateFormat;
    protected TransactionVO transactionVO;


    //--- GET TRAN --------------------------------------------------------------------------------
    protected String getTran(String type, String id){
        String sReturn = ScreenHelper.getTranNoLink(type,id,sPrintLanguage);
        sReturn = ScreenHelper.convertHtmlCodeToChar(sReturn);

        return sReturn;
    }

    //-- TRANSACTION IN INTERVAL ------------------------------------------------------------------
    protected boolean isTransactionInInterval(TransactionVO transactionVO, Date begin, Date end){
        if(begin!=null){
            if(begin.getTime() > transactionVO.getUpdateTime().getTime()){
                // trandate before begin of interval
                return false;
            }
        }

        if(end!=null){
            if(end.getTime() < transactionVO.getUpdateTime().getTime()){
                // trandate after end of interval
                return false;
            }
        }

        return true;
    }

    //--- GET CONFIGSTRING ------------------------------------------------------------------------
    protected String getConfigString(String key){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	String s= getConfigStringDB(key, oc_conn);
    	try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return s;
    }

    //--- GET CONFIGSTRINGDB ----------------------------------------------------------------------
    private String getConfigStringDB(String key, Connection conn){
        String cs = "";

        try{
            Statement st = conn.createStatement();
            ResultSet Configrs = st.executeQuery("SELECT oc_value FROM OC_Config WHERE oc_key like '"+key+"' AND deletetime is null ORDER BY oc_key");
            while (Configrs.next()){
                cs+= Configrs.getString("oc_value");
            }
            Configrs.close();
            st.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return ScreenHelper.checkString(cs);
    }

    //--- ABSTRACT --------------------------------------------------------------------------------
    public abstract ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application, boolean filterApplied, int partsOfTransactionToPrint) throws DocumentException;

}
