package be.dpms.medwan.webapp.wl.servlets.filters;

import be.dpms.medwan.common.model.IConstants;
import be.dpms.medwan.webapp.wo.authentication.AuthenticationTokenWO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.dpms.medwan.services.authentication.exceptions.AuthenticationRequiredException;
import be.mxs.webapp.wl.session.SessionKeyFactory;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.InvalidSessionKeyException;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;

import javax.servlet.Filter;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;

public class AuthenticationFilter implements Filter {

    public void init(javax.servlet.FilterConfig config) throws ServletException {

    }

    public void destroy(){

    }

    public void doFilter(javax.servlet.ServletRequest request, javax.servlet.ServletResponse response,
                         javax.servlet.FilterChain filterChain)
            throws java.io.IOException, javax.servlet.ServletException {

        try {

            verifyAuthentication(request);

            filterChain.doFilter(request, response);

        } catch (AuthenticationRequiredException e) {

            String contextPath = ((HttpServletRequest)request).getContextPath();
            String initialHTTPRequest = ( (HttpServletRequest)request ).getRequestURI().substring(contextPath.length()) + "?" + ( (HttpServletRequest)request ).getQueryString();

            AuthenticationTokenWO authenticationToken = new AuthenticationTokenWO();
            authenticationToken.setInitialHTTPRequest( initialHTTPRequest );

            SessionContainerWO sessionContainerWO;
            try {
                sessionContainerWO = (be.dpms.medwan.webapp.wo.common.system.SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO((HttpServletRequest)request, SessionContainerWO.class.getName());
            } catch (SessionContainerFactoryException e1) {
                throw new ServletException(e1.getMessage());
            }

            sessionContainerWO.setAuthenticationToken(authenticationToken);

            request.getRequestDispatcher(IConstants.MEDWAN_LOGIN_PAGE).forward(request, response);

        } catch (SessionContainerFactoryException e) {
            throw new ServletException(e.getMessage());
        }
    }

    private void verifyAuthentication(ServletRequest request) throws AuthenticationRequiredException, SessionContainerFactoryException {
        SessionContainerWO sessionContainerWO  = (be.dpms.medwan.webapp.wo.common.system.SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO((HttpServletRequest)request, SessionContainerWO.class.getName());

        if ( sessionContainerWO == null ) { // This will never happen

            throw new AuthenticationRequiredException();

        } else {

            try {

                String sessionKey = sessionContainerWO.getSessionKey();

                SessionKeyFactory.getInstance().isValid( sessionKey );

            }catch (InvalidSessionKeyException e) {

                throw new AuthenticationRequiredException(e.getMessage());
            }
        }
    }
}
