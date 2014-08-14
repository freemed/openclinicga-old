package be.mxs.webapp.wl.struts.actions.healthrecord;

import net.admin.AdminPerson;

import org.apache.struts.action.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.*;
import java.sql.Timestamp;
import java.util.Date;

import be.dpms.medwan.common.model.vo.system.ActiveContextVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.services.healthrecord.exceptions.TransactionNotFoundException;
import be.openclinic.adt.Encounter;
import be.openclinic.archiving.ArchiveDocument;

public class CreateTransactionAction extends Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward;

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            if (sessionContainerWO.getHealthRecordVO()!=null){
                sessionContainerWO.getHealthRecordVO().setUpdated(true);
            }

            String transactionType = request.getParameter("be.mxs.healthrecord.createTransaction.transactionType");
            String transactionId   = request.getParameter("be.mxs.healthrecord.transaction_id");
            String serverId        = request.getParameter("be.mxs.healthrecord.server_id");
            String context         = request.getParameter("be.mxs.healthrecord.createTransaction.context");
            
            if(context!=null){
                sessionContainerWO.getFlags().setContext(context);
            }

            if (transactionType.startsWith(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION)) {
                actionForward = new ActionForward("/healthrecord/manageVaccination.do?be.mxs.healthrecord.server_id="+serverId+"&be.mxs.healthrecord.transaction_id="+transactionId+"&vaccination="+request.getParameter("vaccination")+"&ts=" + new java.util.Date().hashCode(), true);
            }
            else {
                TransactionVO transactionVO = null;
                String _param_activeDepartment = request.getParameter("be.medwan.context.department");
                String _param_activeContext = request.getParameter("be.medwan.context.context");

                try {
                    //BEGIN SET CONTEXT DATA
                    if (_param_activeContext==null){
                        _param_activeContext=sessionContainerWO.getFlags().getContext();
                    }
                    if (_param_activeDepartment==null){
                        _param_activeDepartment=sessionContainerWO.getFlags().getDepartment();
                    }
                    //END SET CONTEXT DATA

                    if (transactionId == null) throw new TransactionNotFoundException();

                    TransactionVO existingTransaction;
                    if (transactionId.equalsIgnoreCase("currentTransaction")){
                        existingTransaction=sessionContainerWO.getCurrentTransactionVO();
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
                    factory.setContext(_param_activeDepartment,_param_activeContext,"");
                    transactionVO = factory.createTransactionVO( sessionContainerWO.getUserVO(),transactionType,false);
                    factory.populateTransaction(transactionVO,existingTransaction);
                }
                catch (TransactionNotFoundException e) {
                    TransactionFactoryGeneral factory = new TransactionFactoryGeneral();
                    factory.setContext(_param_activeDepartment,_param_activeContext,"");
                    
                    transactionVO = factory.createTransactionVO( sessionContainerWO.getUserVO(),transactionType,true);
                }
                catch (NumberFormatException e) {
                    e.printStackTrace();
                }

                String extraParameters = "";

                if(transactionType.indexOf("_CUSTOMEXAMINATION") > -1){
                    String sCustomExamType = transactionType.substring(transactionType.indexOf("_CUSTOMEXAMINATION")+"_CUSTOMEXAMINATION".length());
                    Debug.println("Loading CUSTOM EXAMINATION of type '"+sCustomExamType+"'");                                        
                    extraParameters+= "&CustomExamType="+sCustomExamType;               	

                    transactionType = transactionType.substring(0,transactionType.indexOf("_CUSTOMEXAMINATION")+"_CUSTOMEXAMINATION".length());
                    
                    // select active contact
                    String activeEncounterUid = "";
                    AdminPerson activePatient = (AdminPerson)request.getSession().getAttribute("activePatient");
                    Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(transactionVO.getUpdateTime().getTime()),activePatient.personid);
                    if(activeEnc!=null){
                    	activeEncounterUid=activeEnc.getUid();
                    }

                    ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                    ActiveContextVO activeContext = new ActiveContextVO("","","");
                    transactionVO.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
            							                    ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID",
            							                    activeContext.getContext(),
            							                    new Date(),
            							                    itemContextVO));
                }  
                
                sessionContainerWO.setCurrentTransactionVO(transactionVO);
                
                actionForward = new ActionForward(MedwanQuery.getInstance().getForward(transactionType)+"&ts=" + new java.util.Date().hashCode()+extraParameters, true);
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
