package be.dpms.medwan.webapp.wl.servlets.filters;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.services.exceptions.InternalServiceException;
import be.dpms.medwan.services.administration.exceptions.PersonNotFoundException;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.session.SessionKeyFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.util.db.MedwanQuery;

import javax.servlet.Filter;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

public class ContextInitializationFilter implements Filter {

    public void init(javax.servlet.FilterConfig config) throws ServletException {

    }

    public void destroy(){

    }

    //--- DO FILTER -------------------------------------------------------------------------------
    public void doFilter(ServletRequest request, ServletResponse response,
                         javax.servlet.FilterChain filterChain) throws java.io.IOException, ServletException {

        try {
            initializeContext(request);
            filterChain.doFilter(request, response);
        }
        catch (Exception e) {
            throw new ServletException(e.getMessage());
        }
    }

    //--- INITIALIZE CONTEXT ----------------------------------------------------------------------
    private void initializeContext(ServletRequest request) 
        throws SessionContainerFactoryException, InternalServiceException, PersonNotFoundException {
    	
        try {
        	//*** USER ***
            String userId = request.getParameter("UserID");
            SessionContainerWO sessionContainerWO  = (be.dpms.medwan.webapp.wo.common.system.SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO((HttpServletRequest)request, SessionContainerWO.class.getName());

            if ( ( userId != null) && ( sessionContainerWO.getUserVO() == null ) ) {
                UserVO userVO = MedwanQuery.getInstance().getUser(userId);
                sessionContainerWO.setUserVO(userVO);
                sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());
            }
            else if ( ( userId != null) && ( sessionContainerWO.getUserVO() != null ) ) {
                if ( ! sessionContainerWO.getUserVO().getUserId().toString().equals(userId) ) {
                    UserVO userVO = MedwanQuery.getInstance().getUser(userId);
                    sessionContainerWO.setUserVO(userVO);
                    sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());
                }
            }

        	//*** PERSON ***
            String personId = request.getParameter("PersonID");

            if ( ( personId != null) && ( sessionContainerWO.getPersonVO() == null ) ) {
                PersonVO personVO = MedwanQuery.getInstance().getPerson(personId);
                sessionContainerWO.setPersonVO(personVO);
                sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());
            } 
            else if ( ( personId != null) && ( sessionContainerWO.getPersonVO() != null ) ) {
                if ( ! sessionContainerWO.getPersonVO().getPersonId().toString().equals(personId) ) {
                    PersonVO personVO = MedwanQuery.getInstance().getPerson(personId);
                    sessionContainerWO.setPersonVO(personVO);
                    sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());
                    sessionContainerWO.setHealthRecordVO(MedwanQuery.getInstance().loadHealthRecord(personVO,"",sessionContainerWO));
                }
            }
        }
        catch (SessionContainerFactoryException e) {
            e.printStackTrace();
        }
    }
    
}
