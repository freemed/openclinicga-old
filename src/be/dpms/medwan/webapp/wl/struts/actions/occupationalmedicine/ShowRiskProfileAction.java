package be.dpms.medwan.webapp.wl.struts.actions.occupationalmedicine;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import java.util.Iterator;
import java.util.Vector;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileRiskCodeWO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.util.db.MedwanQuery;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileVO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.RiskProfileRiskCodeVO;
import be.dpms.medwan.common.model.vo.administration.PersonVO;

public class ShowRiskProfileAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        // By default our action should be successfull...
        ActionForward actionForward = mapping.findForward( "success" );

        RiskProfileVO riskProfileVO;

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );

            PersonVO personVO = sessionContainerWO.getPersonVO();

            //Debug.println("\n\n\n ***************** ShowRiskProfileAction => personVO = " + personVO);

            //riskProfileVO = MedwanBusinessDelegate.getInstance().getCurrentProfile( personVO );
            riskProfileVO = MedwanQuery.getInstance().getRiskProfileVO(new Long(personVO.getPersonId().longValue()),sessionContainerWO);

            Iterator iRiskCodes = riskProfileVO.getRiskCodes().iterator();
            Vector riskCodesVO = new Vector();
            while (iRiskCodes.hasNext()){
                riskCodesVO.add(new RiskProfileRiskCodeWO((RiskProfileRiskCodeVO)iRiskCodes.next(),sessionContainerWO.getUserVO().getPersonVO().getLanguage()));
            }
            sessionContainerWO.setRiskCodesVO(riskCodesVO);
            sessionContainerWO.setRiskProfileVO( riskProfileVO );

        } catch (SessionContainerFactoryException e) {
            actionForward = mapping.findForward( "failure.webapp.SessionContainerFactoryException" );
        }

        return actionForward;
    }
}
