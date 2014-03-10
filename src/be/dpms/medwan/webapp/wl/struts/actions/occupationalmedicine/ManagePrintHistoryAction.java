package be.dpms.medwan.webapp.wl.struts.actions.occupationalmedicine;

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
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;

public class ManagePrintHistoryAction extends org.apache.struts.action.Action {

	//--- PERFORM ---------------------------------------------------------------------------------
    public ActionForward perform(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward("success");

        SessionContainerWO sessionContainerWO;
        String transactionType = request.getParameter("transactionType");

        try{
            sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            sessionContainerWO.setFullRecord(MedwanQuery.getInstance().getHistory(sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue(),transactionType));
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return actionForward;
    }
    
}
