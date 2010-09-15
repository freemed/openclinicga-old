package be.dpms.medwan.webapp.wl.struts.actions.occupationalmedicine;

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
import be.mxs.services.healthrecord.exceptions.TransactionNotFoundException;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactory;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryException;
import be.mxs.common.util.db.MedwanQuery;

public class ManageAlertsPageAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        // By default our action should be successfull...
        ActionForward actionForward = mapping.findForward( "success" );

        SessionContainerWO sessionContainerWO = null;
        TransactionVO transactionVO = null;
        String factoryClass = "be.mxs.common.model.vo.healthrecord.util.TransactionFactoryAlerts";
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

            String _param_transactionId = request.getParameter("be.mxs.healthrecord.transaction_id");
            String _param_serverId = request.getParameter("be.mxs.healthrecord.server_id");
            String _version = request.getParameter("be.mxs.healthrecord.version");
            String _version_server_id = request.getParameter("be.mxs.healthrecord.version_server_id");

            if (_param_transactionId == null) throw new TransactionNotFoundException();

            TransactionVO existingTransactionVO;
            try {
                existingTransactionVO = MedwanQuery.getInstance().loadTransaction(_param_serverId,_param_transactionId,_version,_version_server_id);
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

                transactionVO = factory.createTransactionVO(sessionContainerWO.getUserVO());
                MedwanQuery.getInstance().fillTransactionItems(transactionVO);

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
