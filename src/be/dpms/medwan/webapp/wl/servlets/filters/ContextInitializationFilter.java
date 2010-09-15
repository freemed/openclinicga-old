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

    public void doFilter(ServletRequest request, ServletResponse response,
                         javax.servlet.FilterChain filterChain)
            throws java.io.IOException, ServletException {

        try {

            ////Debug.println("=======================================================================ContextInitializationFilter.begin");

            initializeContext(request);

            ////Debug.println("=========================================================================ContextInitializationFilter.filterChain.doFilter(request, response)");

            filterChain.doFilter(request, response);

            ////Debug.println("=========================================================================ContextInitializationFilter.end");

        } catch (SessionContainerFactoryException e) {
            ////Debug.println("==> ContextInitializationFilter : SessionContainerFactoryException \n"+e.getMessage());
            throw new ServletException(e.getMessage());
        } catch (InternalServiceException e) {
            ////Debug.println("==> ContextInitializationFilter : InternalServiceException \n"+e.getMessage());
            throw new ServletException(e.getMessage());
        } catch (PersonNotFoundException e) {
            ////Debug.println("==> ContextInitializationFilter : PersonNotFoundException \n"+e.getMessage());
            throw new ServletException(e.getMessage());
        }
    }

    private void initializeContext(ServletRequest request) throws SessionContainerFactoryException, InternalServiceException, PersonNotFoundException {

        try {

            String userId = request.getParameter("UserID");
            //Debug.println("========================================================================= UserID = " + userId);
            SessionContainerWO sessionContainerWO  = (be.dpms.medwan.webapp.wo.common.system.SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO((HttpServletRequest)request, SessionContainerWO.class.getName());

            if ( ( userId != null) && ( sessionContainerWO.getUserVO() == null ) ) {

                UserVO userVO = MedwanQuery.getInstance().getUser(userId);
                sessionContainerWO.setUserVO(userVO);
                sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());

            } else if ( ( userId != null) && ( sessionContainerWO.getUserVO() != null ) ) {

                if ( ! sessionContainerWO.getUserVO().getUserId().toString().equals(userId) ) {

                    UserVO userVO = MedwanQuery.getInstance().getUser(userId);
                    sessionContainerWO.setUserVO(userVO);
                    sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());
                }
            }


            String personId = request.getParameter("PersonID");
            //Debug.println("========================================================================= PersonID = " + personId);

            if ( ( personId != null) && ( sessionContainerWO.getPersonVO() == null ) ) {

                PersonVO personVO = MedwanQuery.getInstance().getPerson(personId);
                sessionContainerWO.setPersonVO(personVO);
                sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());

            } else if ( ( personId != null) && ( sessionContainerWO.getPersonVO() != null ) ) {

                if ( ! sessionContainerWO.getPersonVO().getPersonId().toString().equals(personId) ) {

                    PersonVO personVO = MedwanQuery.getInstance().getPerson(personId);
                    //PersonVO personVO = MedwanQuery.getInstance().getPerson(personId);
                    sessionContainerWO.setPersonVO(personVO);
                    sessionContainerWO.setSessionKey(SessionKeyFactory.getInstance().createSessionKey());

                    //try {
                        //sessionContainerWO.setHealthRecordVO(HealthRecordBusinessDelegate.getInstance().findHealthRecord(personVO));
                        sessionContainerWO.setHealthRecordVO(MedwanQuery.getInstance().loadHealthRecord(personVO,"",sessionContainerWO));
/**                    } catch (PersonNotFoundException e) {
                        sessionContainerWO.setHealthRecordVO(null);
                    } catch (be.mxs.services.exceptions.InternalServiceException e) {
                        sessionContainerWO.setHealthRecordVO(null);
                    }**/
                }
            }


            //Debug.println(""+this.getClass().getName() + " ok");
            //Debug.println(this.getClass().getName() + " - sessionContainerWO.getCurrentTransactionVO() = " + sessionContainerWO.getCurrentTransactionVO());


        } catch (SessionContainerFactoryException e) {
            e.printStackTrace();
        }


    }
}
