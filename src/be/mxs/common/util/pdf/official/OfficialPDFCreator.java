package be.mxs.common.util.pdf.official;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfWriter;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;

import java.text.SimpleDateFormat;
import java.io.ByteArrayOutputStream;
import java.util.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

import net.admin.AdminPerson;
import net.admin.User;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletContext;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.pdf.PDFCreator;


/*
    Check loadTransaction() for supported examinations !!
*/

//#################################################################################################
// Composes an official version of the OpenWork PDF with the same name.
//#################################################################################################
public class OfficialPDFCreator extends PDFCreator {

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public OfficialPDFCreator(SessionContainerWO sessionContainerWO, User user, AdminPerson patient,
    		                  String sProject, String sProjectDir, String sPrintLanguage){
        this.sessionContainerWO = sessionContainerWO;
        this.user = user;
        this.patient = patient;
        this.sProject = sProject;
        this.sProjectPath = sProjectDir;
        this.sPrintLanguage = sPrintLanguage;

        doc = new Document();

        dateFormat = ScreenHelper.stdDateFormat;
    }

    //--- GENERATE DOCUMENT BYTES (1) -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application)
    		throws DocumentException {
        return generatePDFDocumentBytes(req,application,false,2); // no filter, full transactions
    }
    
    //--- GENERATE DOCUMENT BYTES (2) -------------------------------------------------------------
    public ByteArrayOutputStream generatePDFDocumentBytes(final HttpServletRequest req, ServletContext application,
    		                                              boolean filterApplied, int partsOfTransactionToPrint)
    		throws DocumentException {
        ByteArrayOutputStream baosPDF = new ByteArrayOutputStream();
		PdfWriter docWriter = null;
        this.req = req;
        this.application = application;
        sContextPath = req.getContextPath();

		try{
			docWriter = PdfWriter.getInstance(doc,baosPDF);

            //*** META TAGS ***********************************************************************
            doc.addProducer();
            doc.addAuthor(user.person.firstname+" "+user.person.lastname);
			doc.addCreationDate();
			doc.addCreator("OpenClinic Software for Hospital Management");
			doc.setPageSize(PageSize.A4);
            doc.open();

            //*** TRANSACTIONS ********************************************************************
            Enumeration e = req.getParameterNames();
            String paramName;
            boolean printTransactions = false;

            while(e.hasMoreElements()){
                paramName = (String)e.nextElement();

                if(paramName.startsWith("tranAndServerID_")){
                    printTransactions = true;
                    break;
                }
            }

            // transactionIDs were specified as request-parameters
            if(printTransactions){
                printTransactions(filterApplied);
            }
            // no transactionIDs specified; data is not, as usual, retreived from a transaction.
            else{
                // go to the print-method of a class for which no real transaction exists.
                TransactionVO dummyTran = new TransactionVO(new Integer(0),req.getParameter("dummyTransactionType"),new java.util.Date(),new java.util.Date(),1,sessionContainerWO.getUserVO(),new Vector());
                loadTransaction(dummyTran);
            }
		}
		catch(DocumentException dex){
			baosPDF.reset();
			throw dex;
		}
        catch(Exception e){
            e.printStackTrace();
        }
		finally{
			if(doc != null) doc.close();
            if(docWriter != null) docWriter.close();
		}

		if(baosPDF.size() < 1){
			throw new DocumentException("document has " + baosPDF.size() + " bytes");
		}

		return baosPDF;
	}


    //### NON-PUBLIC METHODS ######################################################################

    //--- PRINT TRANSACTIONS ----------------------------------------------------------------------
    private void printTransactions(boolean filterApplied){
        // retrieve transaction-id OR transaction-type of transactions to be printed, from request
        int tranPropertyInVector = 0;
        Vector tranPropertiesToBePrinted = new Vector();

        if(filterApplied){
            Vector transactionIDsToBePrinted = new Vector();
            Vector transactionTypesToBePrinted = new Vector();
            Enumeration e = req.getParameterNames();
            String paramName;

            while(e.hasMoreElements()){
                paramName = (String)e.nextElement();

                if(paramName.startsWith("tranAndServerID_")){
                    transactionIDsToBePrinted.add(req.getParameter(paramName));
                }
                else if(paramName.startsWith("tranType_")){
                    transactionTypesToBePrinted.add(req.getParameter(paramName));
                }
            }

            // were transactions selected based on tranType or tranID ?
            if(transactionIDsToBePrinted.size() > 0){
                tranPropertyInVector = 1;
                tranPropertiesToBePrinted = transactionIDsToBePrinted;
            }
            else if(transactionTypesToBePrinted.size() > 0){
                tranPropertyInVector = 2;
                tranPropertiesToBePrinted = transactionTypesToBePrinted;
            }
        }

        // Get all transactions of active patient.
        // Print only transactions between the specified start- and enddate.
        String tranProperty = null;

        Iterator iTransactions = sessionContainerWO.getHealthRecordVO().getTransactions().iterator();
        while(iTransactions.hasNext()){
            transactionVO = (TransactionVO)iTransactions.next();

            // some transactions were selected
            if(tranPropertiesToBePrinted.size() > 0){
                     if(tranPropertyInVector == 1) tranProperty = transactionVO.getTransactionId()+"_"+transactionVO.getServerId();
                else if(tranPropertyInVector == 2) tranProperty = transactionVO.getTransactionType();

                // print the selected transaction complete
                if(tranPropertiesToBePrinted.contains(tranProperty)){
                    if(isTransactionInInterval(transactionVO,dateFrom,dateTo)){
                        if(transactionVO!=null){
                            loadTransaction(transactionVO);
                        }
                    }
                }
            }
            // no transactions selected, so print all
            else{
                if(isTransactionInInterval(transactionVO,dateFrom,dateTo)){
                    if(transactionVO!=null){
                        loadTransaction(transactionVO);
                    }
                }
            }
        }
    }

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

    //--- LOAD TRANSACTION ------------------------------------------------------------------------
    protected void loadTransaction(TransactionVO transactionVO){
        // LAB REQUEST
        if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_LAB_REQUEST")){
            this.transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFOfficialLabRequest",false);
        }
        // PHYSIO THERAPY - CONSULTATION
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PHYSIO_CONS")){
            this.transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFOfficialPhysioConsultation",false);
        }
        // PHYSIO THERAPY - REPORT
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_PHYSIO_REP")){
            this.transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFOfficialPhysioReport",false);
        }
        // REFERENCE (verwijsbrief)
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_REFERENCE")){
            this.transactionVO = MedwanQuery.getInstance().loadTransaction(transactionVO.getServerId(),transactionVO.getTransactionId().intValue());
            loadTransactionOfType("PDFOfficialReference",false);
        }
        // dummyTransactionType = GROWTH_GRAPH 0 TO 1 YEAR
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_GROWTH_GRAPH_0_TO_1_YEAR")){
            loadTransactionOfType("PDFOfficialGrowthGraph0To1Year",false);
        }
        // dummyTransactionType = GROWTH_GRAPH 1 TO 5 YEAR
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_GROWTH_GRAPH_1_TO_5_YEAR")){
            loadTransactionOfType("PDFOfficialGrowthGraph1To5Year",false);
        }
        // dummyTransactionType = GROWTH_GRAPH 5 TO 20 YEAR
        else if(transactionVO.getTransactionType().equalsIgnoreCase(IConstants_PREFIX+"TRANSACTION_TYPE_GROWTH_GRAPH_5_TO_20_YEAR")){
            loadTransactionOfType("PDFOfficialGrowthGraph5To20Year",false);
        }
        // generic transaction
        else {
        	Debug.println("Transaction of type '"+transactionVO.getTransactionType()+"' is not supported by OfficialPDFCreator");
            loadTransactionOfType("PDFGenericTransaction",false);
        }
    }

    //--- LOAD TRANSACTION OF TYPE ----------------------------------------------------------------
    protected void loadTransactionOfType(String sClassName, boolean useApplicationObject){
        Class cls = null;

        // First search the project official class
        try{
            cls = Class.forName("be.mxs.common.util.pdf.official."+sProject.toLowerCase()+".examinations."+sProject.toLowerCase()+sClassName);
        }
        catch(ClassNotFoundException e){
            Debug.println(e.getMessage());
        }

        // else search the normal official class
        if(cls==null){
            try{
                cls = Class.forName("be.mxs.common.util.pdf.official.oc.examinations."+sClassName);
            }
            catch(ClassNotFoundException e){
                Debug.println(e.getMessage());
                
                // re-enter this function, now as a generic transaction
                loadTransactionOfType("PDFGenericTransaction",useApplicationObject);
            }
        }

        if(cls!=null){
            try{
                Constructor[] cons = cls.getConstructors();
                Object[] oParams = new Object[0];
                Object oConstructor = cons[0].newInstance(oParams);

                // parameter types
                Class cParams[];
                if(useApplicationObject) cParams = new Class[9];
                else                     cParams = new Class[8];

                cParams[0] = Document.class;
                cParams[1] = SessionContainerWO.class;
                cParams[2] = TransactionVO.class;
                cParams[3] = User.class;
                cParams[4] = AdminPerson.class;
                cParams[5] = HttpServletRequest.class;
                cParams[6] = String.class;
                cParams[7] = String.class;
                if(useApplicationObject) cParams[8] = ServletContext.class;
                Method mPrint = oConstructor.getClass().getMethod("print",cParams);

                // parameter values
                if(useApplicationObject) oParams = new Object[9];
                else                     oParams = new Object[8];

                oParams[0] = doc;
                oParams[1] = sessionContainerWO;
                oParams[2] = transactionVO;
                oParams[3] = user;
                oParams[4] = patient;
                oParams[5] = req;
                oParams[6] = sProject;
                oParams[7] = sPrintLanguage;
                if(useApplicationObject) oParams[8] = application;
                mPrint.invoke(oConstructor,oParams);
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- GET CONFIGSTRING ------------------------------------------------------------------------
    protected String getConfigString(String key){
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        String s=getConfigStringDB(key, oc_conn);
        
        try {
			oc_conn.close();
		}
        catch (SQLException e) {
			e.printStackTrace();
		}
        
        return s;
    }

    //--- GET CONFIGSTRINGDB ----------------------------------------------------------------------
    private String getConfigStringDB(String key, Connection conn){
        String cs = "";

        try{
            Statement st = conn.createStatement();
            ResultSet Configrs = st.executeQuery("SELECT oc_value FROM OC_Config WHERE oc_key like '"+key+"'"+
                                                 " AND deletetime is null ORDER BY oc_key");
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

}