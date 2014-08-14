package be.mxs.webapp.wl.struts.actions.healthrecord;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.HealthRecordVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.services.healthrecord.exceptions.TransactionNotFoundException;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.openclinic.adt.Planning;
import be.openclinic.archiving.ArchiveDocument;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Date;

import net.admin.system.AccessLog;
public class EditTransactionAction extends Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward;// = new ActionForward("/occupationalmedicine/showWelcomePage.do", true);

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );

            // get parameters
            String transactionType = request.getParameter("be.mxs.healthrecord.createTransaction.transactionType"),
                   transactionId   = request.getParameter("be.mxs.healthrecord.transaction_id"),
                   serverId        = request.getParameter("be.mxs.healthrecord.server_id"),
                   personId        = request.getParameter("PersonID"),
                   printPDF        = request.getParameter("printPDF"),
                   printLang       = request.getParameter("PrintLanguage"),
                   tranSubType     = request.getParameter("tranSubType"),
                   sAction         = request.getParameter("Action"),
                   sReadOnly	   = request.getParameter("readonly"),
                   sContext        = request.getParameter("be.mxs.healthrecord.createTransaction.context");

            if(personId!=null){
                sessionContainerWO.verifyPerson(personId);
                sessionContainerWO.verifyHealthRecord("be.mxs.healthrecord.transactionVO.date");
            }
            if (sessionContainerWO.getHealthRecordVO()!=null){
                sessionContainerWO.getHealthRecordVO().setUpdated(true);
            }

            // put parameters in forwardkey
            String sParameters = "";
            sParameters+= "be.mxs.healthrecord.server_id="+serverId;
            sParameters+= "&be.mxs.healthrecord.transaction_id="+transactionId;
            sParameters+= "&ts="+new java.util.Date().hashCode();
            if((personId!=null)&&(personId.trim().length()>0))   sParameters+= "&PersonID="+personId;
            if((printPDF!=null)&&(printPDF.trim().length()>0))   sParameters+= "&printPDF="+printPDF;
            if((printLang!=null)&&(printLang.trim().length()>0)) sParameters+= "&PrintLanguage="+printLang;
            if((tranSubType!=null)&&(tranSubType.trim().length()>0)) sParameters+= "&tranSubType="+tranSubType;
            if((sAction!=null)&&(sAction.trim().length()>0))     sParameters+= "&Action="+sAction;
            if((sReadOnly!=null)&&(sReadOnly.trim().length()>0))     sParameters+= "&readonly="+sReadOnly;
            if((sContext!=null)&&(sContext.trim().length()>0))   sParameters+= "&be.mxs.healthrecord.createTransaction.context="+sContext;

            //--- save accesslog ------------------------------------------------
            AccessLog.insert(sessionContainerWO.getUserVO().getUserId()+"","T."+serverId+"."+transactionId);

            //--- HEALTHRECORD -----------------------------------------------------------------------------------------
            if (transactionType.startsWith(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION)) {
                actionForward = new ActionForward("/healthrecord/manageVaccination.do?"+sParameters, true);
            }
            //--- OCCUPATIONAL -----------------------------------------------------------------------------------------
            else if (transactionType.equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DOCUMENT)) {
                ItemVO item = MedwanQuery.getInstance().getItem(Integer.parseInt(serverId),Integer.parseInt(transactionId),"documentTemplateId");
                sParameters = sParameters.replaceAll("be.mxs.healthrecord.server_id","serverId");
                sParameters = sParameters.replaceAll("be.mxs.healthrecord.transaction_id","transactionId");
                actionForward = new ActionForward("/util/loadPDFFromDb.jsp?file=base/"+item.getValue()+"&"+sParameters, true);
            }

            //--- ALL OTHER TYPES OF TRANSACTIONS ---------------------------------------------------------------------
            else {                
                TransactionVO transactionVO = null;
                String _param_activeDepartment = request.getParameter("be.medwan.context.department");
                String _param_activeContext    = request.getParameter("be.medwan.context.context");

                try {
                    // BEGIN SET CONTEXT DATA
                    if(_param_activeContext==null){
                        _param_activeContext=sessionContainerWO.getFlags().getContext();
                    }
                    if(_param_activeDepartment==null){
                        _param_activeDepartment=sessionContainerWO.getFlags().getDepartment();
                    }
                    // END SET CONTEXT DATA

                    if (transactionId == null) throw new TransactionNotFoundException();

                    TransactionVO existingTransaction;
                    if (transactionId.equalsIgnoreCase("currentTransaction")){
                        existingTransaction = sessionContainerWO.getCurrentTransactionVO();
                    }
                    else {
                        try {
                            existingTransaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(serverId),Integer.parseInt(transactionId));
                        }
                        catch (NumberFormatException e) {
                            throw new TransactionNotFoundException();
                        }
                    }

                    TransactionFactoryGeneral factory = new TransactionFactoryGeneral();
                    transactionVO = factory.createTransactionVO( sessionContainerWO.getUserVO(),transactionType,false );
                    factory.populateTransaction(transactionVO,existingTransaction);
                }
                catch(TransactionNotFoundException e) {
                    TransactionFactoryGeneral factory = new TransactionFactoryGeneral();
                    transactionVO = factory.createTransactionVO( sessionContainerWO.getUserVO(),transactionType,true );
                }
                catch (NumberFormatException e) {
                    e.printStackTrace();
                }

                sessionContainerWO.setCurrentTransactionVO(transactionVO);
                
                //--- PLANNING ---
                if(request.getParameter("UpdatePlanning")!=null){
                    Planning planning = Planning.get(request.getParameter("UpdatePlanning"));
                    if(planning.getEffectiveDate()==null){
                        transactionVO=MedwanQuery.getInstance().updateTransaction(sessionContainerWO.getPersonVO().getPersonId().intValue(),transactionVO);
                        planning.setTransaction(transactionVO);
                        planning.setTransactionUID(transactionVO.getServerId()+"."+transactionVO.getTransactionId());
                        planning.setEffectiveDate(new Date());
                        planning.store();
                    }
                }
                
                //--- CUSTOM EXAMINATION ---
                if(transactionType.indexOf("_CUSTOMEXAMINATION") > -1){
                    String sCustomExamType = transactionType.substring(transactionType.indexOf("_CUSTOMEXAMINATION")+"_CUSTOMEXAMINATION".length());
                    Debug.println("Loading CUSTOM EXAMINATION of type '"+sCustomExamType+"'");                                        
                    sParameters+= "&CustomExamType="+sCustomExamType;               	

                    transactionType = transactionType.substring(0,transactionType.indexOf("_CUSTOMEXAMINATION")+"_CUSTOMEXAMINATION".length());
                }

                actionForward = new ActionForward(MedwanQuery.getInstance().getForward(transactionType)+"&"+sParameters, true);
            }
        }
        catch (Exception e) {
            try {
                e.printStackTrace();

                StringWriter writer = new StringWriter();
                e.printStackTrace(new PrintWriter(writer));

                SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
                sessionContainerWO.resetErrorMessage();
                sessionContainerWO.addErrorMessage(""+writer.getBuffer());
            }
            catch (SessionContainerFactoryException e1) {
                e1.printStackTrace();
            }

            actionForward = mapping.findForward("failure");
        }

        return actionForward;
    }
}
