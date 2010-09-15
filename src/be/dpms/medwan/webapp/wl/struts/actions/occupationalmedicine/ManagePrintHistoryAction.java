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

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 13-okt-2003
 * Time: 17:37:50
 */
public class ManagePrintHistoryAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        // By default our action should be successfull...
        ActionForward actionForward = mapping.findForward( "success" );

        SessionContainerWO sessionContainerWO;
        String transactionType = request.getParameter("transactionType");

        try {

            sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            sessionContainerWO.setFullRecord(MedwanQuery.getInstance().getHistory(sessionContainerWO.getHealthRecordVO().getHealthRecordId().intValue(),transactionType));

        } catch (SessionContainerFactoryException e) {
            e.printStackTrace();
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        return actionForward;
    }
}
