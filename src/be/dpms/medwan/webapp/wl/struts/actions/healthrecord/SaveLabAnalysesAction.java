package be.dpms.medwan.webapp.wl.struts.actions.healthrecord;

import be.openclinic.finance.Debet;
import be.openclinic.medical.LabAnalysis;
import be.openclinic.medical.RequestedLabAnalysis;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.db.MedwanQuery;

import java.util.*;
import java.io.IOException;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;

/**
 * User: stijn smets
 * Date: 12-jan-2007
 */
public class SaveLabAnalysesAction extends Action {

    //--- PERFORM ---------------------------------------------------------------------------------
    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        // delete all labanalysis in the specified LabRequest, then insert all analysis to be saved
        String sServerId          = ScreenHelper.checkString(request.getParameter("be.mxs.healthrecord.server_id")),
               sTransactionId     = ScreenHelper.checkString(request.getParameter("be.mxs.healthrecord.transaction_id")),
               sPatientId         = ScreenHelper.checkString(request.getParameter("patientId")),
               sUserId         = ScreenHelper.checkString(request.getParameter("userId")),
               sLabAnalysesToSave = ScreenHelper.checkString(request.getParameter("labAnalysesToSave")),
               sSavedLabAnalyses  = ScreenHelper.checkString(request.getParameter("savedLabAnalyses"));

        /*
        Debug.println("// DEBUG ////////////////////////////////////////////////");
        Debug.println("*** sServerId          : "+sServerId);
        Debug.println("*** sTransactionId     : "+sTransactionId);
        Debug.println("*** sPatientId         : "+sPatientId);
        Debug.println("*** sLabAnalysesToSave : "+sLabAnalysesToSave);
        Debug.println("*** sSavedLabAnalyses  : "+sSavedLabAnalyses+"\n\n");
        */
        // put analysis-codes in a Hashtable, to be able to sort them
        String token, analysisCode, comment;
        RequestedLabAnalysis labAnalysis;
        Debug.println("SAVING LAB");
        Debug.println("sLabAnalysesToSave="+sLabAnalysesToSave);
        Debug.println("TransactionId="+sTransactionId);
        Debug.println("index="+sLabAnalysesToSave.indexOf("$"));
        Debug.println("parsed transactionid="+Integer.parseInt(sTransactionId));
        
        if(sLabAnalysesToSave.indexOf("$")>-1 && (Integer.parseInt(sTransactionId) > -1 || MedwanQuery.getInstance().getConfigInt("enableSlaveServer",0)==1)){
            Debug.println("1");
            // compose query, to use many times later on
            String sLowerLabelType = ScreenHelper.getConfigParam("lowerCompare","l.OC_LABEL_TYPE");
            StringBuffer sSelect = new StringBuffer();
            sSelect.append("SELECT la.labtype,la.monster,l.OC_LABEL_VALUE")
                   .append(" FROM LabAnalysis la, OC_LABELS l")
                   .append(" WHERE "+ MedwanQuery.getInstance().convert("varchar(255)","la.labID")+ " = l.OC_LABEL_ID")
                   .append("  AND "+sLowerLabelType+" = 'labanalysis'")
                   .append("  AND la.labcode = ? and deletetime is null");
            Debug.println("2");

            // tokenize savedLabAnalyses specified in parameter
            StringTokenizer tokenizer = new StringTokenizer(sSavedLabAnalyses,"$");
            Hashtable savedAnalyses = new Hashtable();
            while(tokenizer.hasMoreTokens()){
                token = tokenizer.nextToken();

                // data from parameter
                analysisCode = token.substring(0,token.indexOf("£"));
                comment      = token.substring(token.indexOf("£")+1);
                Debug.println("PUTTING saved analysis "+analysisCode);
                savedAnalyses.put(analysisCode,comment);
            }
            Debug.println("3");

            // tokenize labAnalysesToSave specified in parameter
            tokenizer = new StringTokenizer(sLabAnalysesToSave,"$");
            Hashtable analysesToSave = new Hashtable();
            while(tokenizer.hasMoreTokens()){
                token = tokenizer.nextToken();
                Debug.println("token="+token);
                // data from parameter
                analysisCode = token.substring(0,token.indexOf("£"));
                comment      = token.substring(token.indexOf("£")+1);
                Debug.println("PUTTING analysis to save "+analysisCode);

                analysesToSave.put(analysisCode,comment);
            }
            Debug.println("4");

            // Delete analyses that are in savedAnalyses but not in analysesToSave.
            // Also delete analyses with the same code of which the comment differs.
            HashSet analysesToDelete = new HashSet(); // unique entries
            boolean analysisFound = false;
            String savedCode, codeToSave;

            Enumeration savedAnalysesEnum = savedAnalyses.keys(),
                        analysesToSaveEnum;
            Debug.println("5");

            // saved -> toSave
            while(savedAnalysesEnum.hasMoreElements()){
                savedCode = (String)savedAnalysesEnum.nextElement();

                analysesToSaveEnum = analysesToSave.keys();
                while(analysesToSaveEnum.hasMoreElements()){
                    codeToSave = (String)analysesToSaveEnum.nextElement();
                    if(codeToSave.equals(savedCode) && analysesToSave.get(codeToSave).equals(savedAnalyses.get(savedCode))){
                        analysisFound = true;
                        break;
                    }
                }

                if(!analysisFound) analysesToDelete.add(savedCode);
                analysisFound = false;
            }
            Debug.println("6");

            // delete specified analyses
            String labCode;
            Iterator iterator = analysesToDelete.iterator();
            while(iterator.hasNext()){
                labCode = (String)iterator.next();
                RequestedLabAnalysis.delete(Integer.parseInt(sServerId),Integer.parseInt(sTransactionId),labCode);
                if(MedwanQuery.getInstance().getConfigInt("enableAutomaticLabInvoicing",0)==1){
                	Pointer.deletePointers("LAB."+sServerId+"."+sTransactionId+"."+labCode);
                }
            }

            TransactionVO transaction = null;
            try{
            	transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(sServerId), Integer.parseInt(sTransactionId));
            }
            catch(Exception e3){
            	e3.printStackTrace();
            }
            // save analyses to be saved
        	Hashtable allanalyses = LabAnalysis.getAllLabanalyses();
            Debug.println("Analysis 1005 exists: "+(allanalyses.get("1005")!=null));
        	
            analysesToSaveEnum = analysesToSave.keys();
            while(analysesToSaveEnum.hasMoreElements()){
                analysisCode = (String)analysesToSaveEnum.nextElement();
                comment      = (String)analysesToSave.get(analysisCode);
                Debug.println("Saving analysis *"+analysisCode+"*");

                LabAnalysis a = (LabAnalysis)allanalyses.get(analysisCode);
                Debug.println("Virtual editor = "+MedwanQuery.getInstance().getConfigString("virtualLabAnalysisEditors","virtual"));
                Debug.println("Analysis a = "+a);
                Debug.println("Analysis a editor = "+(a==null?"null":a.getEditor()));
                
            	if(a!=null && MedwanQuery.getInstance().getConfigString("virtualLabAnalysisEditors","virtual").indexOf(a.getEditor())<0){    
                    Debug.println("Editor not virtual");
	                if(!RequestedLabAnalysis.exists(Integer.parseInt(sServerId),Integer.parseInt(sTransactionId),analysisCode)){
	                    Debug.println("Analysis does not exist, saving");
	                    // labRequest not found : insert in DB
	                    labAnalysis = new RequestedLabAnalysis();
	                    labAnalysis.setServerId(sServerId);
	                    labAnalysis.setTransactionId(sTransactionId);
	                    labAnalysis.setPatientId(sPatientId);
	                    labAnalysis.setAnalysisCode(analysisCode);
	                    labAnalysis.setComment(comment);
	                    labAnalysis.store(false); // object does not exist, so insert
	                }
            	}
                if(MedwanQuery.getInstance().getConfigInt("enableAutomaticLabInvoicing",0)==1){
                	Debug.println("checking prestation save for "+a.getLabcode());
                    if(a!=null && a.getPrestationcode()!=null && a.getPrestationcode().length()>0 && a.getUnavailable()==0){
                    	Debug.println("saving prestation "+a.getPrestationcode());
                    	//Now check if the prestation was not coded yet in the past 24 hours
                    	if(!Debet.existsRecent(a.getPrestationcode(),sPatientId,24*3600*1000,transaction!=null?transaction.getUpdateTime():new java.util.Date())){
                        	Debug.println("no recent identical prestation, commiting");
                    		Debet.createAutomaticDebet("LAB."+sServerId+"."+sTransactionId+"."+analysisCode, sPatientId, a.getPrestationcode(), sUserId);
                    	}
        		    }
                }
            }
        }

        return mapping.findForward("examinationsOverview");
    }

}
