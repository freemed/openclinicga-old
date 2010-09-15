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
import be.mxs.common.util.db.MedwanQuery;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 02-avr.-2003
 * Time: 8:54:50
 */
public class ShowVaccinationSummaryAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward( "success" );

        try {

            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );

            if (sessionContainerWO.getPersonalVaccinationsInfoVO()==null && sessionContainerWO.getPersonVO()!=null){
                PersonalVaccinationsInfoVO personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO() );
                sessionContainerWO.setPersonalVaccinationsInfoVO( personalVaccinationsInfoVO );
            }
            else if (sessionContainerWO.getPersonVO()!=null && !sessionContainerWO.getPersonalVaccinationsInfoVO().getPersonVO().getPersonId().equals(sessionContainerWO.getPersonVO().getPersonId())){
                PersonalVaccinationsInfoVO personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO());
                sessionContainerWO.setPersonalVaccinationsInfoVO( personalVaccinationsInfoVO );
            }

        } catch (SessionContainerFactoryException e) {
            actionForward = mapping.findForward( "failure" );
        }
        return actionForward;
    }
}
