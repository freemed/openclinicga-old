package be.dpms.medwan.webapp.wl.struts.actions.healthrecord;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.model.vo.healthrecord.*;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactory;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryException;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.services.healthrecord.exceptions.TransactionNotFoundException;

public class ManageClinicalExaminationAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        // By default our action should be successfull...
        ActionForward actionForward = mapping.findForward( "success" );

        SessionContainerWO sessionContainerWO = null;
        TransactionVO transactionVO = null;
        String factoryClass = "be.mxs.common.model.vo.healthrecord.util.TransactionFactoryClinicalExamination";
        String _param_activeDepartment = request.getParameter("be.medwan.context.department");
        String _param_activeContext = request.getParameter("be.medwan.context.context");

        try {

            sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );

            //BEGIN SET CONTEXT DATA
            if (_param_activeContext==null){
                _param_activeContext=sessionContainerWO.getFlags().getContext();
            }
            if (_param_activeDepartment==null){
                _param_activeDepartment=sessionContainerWO.getFlags().getDepartment();
            }
            //END SET CONTEXT DATA

            //Debug.println("Active context in Clinical Examination= "+sessionContainerWO.getFlags().getDepartment()+" - "+sessionContainerWO.getFlags().getContext());


            String _param_transactionId = request.getParameter("be.mxs.healthrecord.transaction_id");
            String _param_serverId = request.getParameter("be.mxs.healthrecord.server_id");
            if (_param_transactionId == null) throw new TransactionNotFoundException();

            TransactionVO existingTransactionVO;
            try {
                if (_param_transactionId.equals("currentTransaction")){
                    existingTransactionVO = sessionContainerWO.getCurrentTransactionVO();
                }
                else
                {
                    existingTransactionVO = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(_param_serverId),Integer.parseInt(_param_transactionId));
                }

            } catch (NumberFormatException e) {

                throw new TransactionNotFoundException();
            }


            TransactionFactory factory = TransactionFactory.createTransactionFactory(factoryClass);
            factory.setContext(_param_activeDepartment,_param_activeContext,"");
            transactionVO = factory.createTransactionVO( existingTransactionVO );


        } catch (SessionContainerFactoryException e) {
            e.printStackTrace();
        } catch (TransactionNotFoundException e) {

            try {

                TransactionFactory factory = TransactionFactory.createTransactionFactory(factoryClass);
                factory.setContext(_param_activeDepartment,_param_activeContext,"");

                transactionVO = factory.createTransactionVO( sessionContainerWO.getUserVO() );
                MedwanQuery.getInstance().fillTransactionItems(transactionVO);

                //Add code to fill-up empty transaction with case-specific default values here
                //transactionVO = factory.updateTransactionVOfromXML(transactionVO,"");

            } catch (TransactionFactoryException e1) {
                e1.printStackTrace();
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
        } catch (TransactionFactoryException e) {
            e.printStackTrace();
        }

        sessionContainerWO.setCurrentTransactionVO(transactionVO);

        return actionForward;
    }

}
