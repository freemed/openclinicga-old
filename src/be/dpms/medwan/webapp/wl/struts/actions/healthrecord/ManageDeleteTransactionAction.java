package be.dpms.medwan.webapp.wl.struts.actions.healthrecord;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.webapp.wl.session.SessionContainerFactory;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 16-sep-2003
 * Time: 15:51:39
 * To change this template use Options | File Templates.
 */
public class ManageDeleteTransactionAction extends org.apache.struts.action.Action {
    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward( "success" );

        String transactionId = request.getParameter("transactionId");
        String serverId = request.getParameter("serverId");
        MedwanQuery.getInstance().deleteTransaction(transactionId,serverId);

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            sessionContainerWO.getHealthRecordVO().setUpdated(true);
            sessionContainerWO.setPersonalVaccinationsInfoVO(null);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        String actionForwardKey = request.getParameter("be.mxs.healthrecord.updateTransaction.actionForwardKey");
        if (actionForwardKey != null) {
            actionForward = new ActionForward(actionForwardKey, true);
        }

        return actionForward;
    }
}
