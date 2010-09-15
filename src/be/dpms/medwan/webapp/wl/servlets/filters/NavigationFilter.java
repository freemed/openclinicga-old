package be.dpms.medwan.webapp.wl.servlets.filters;

import be.dpms.medwan.webapp.wo.common.navigation.URLHistoryHelper;
import be.dpms.medwan.webapp.wo.common.navigation.URLHistoryException;
import be.mxs.webapp.wl.exceptions.WebLogicException;

import javax.servlet.Filter;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;


/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 07-avr.-2003
 * Time: 15:49:50
 * To change this template use Options | File Templates.
 */
public class NavigationFilter implements Filter {

    public void init(javax.servlet.FilterConfig config) throws ServletException {

    }

    public void destroy(){

    }

    public void doFilter(ServletRequest request, ServletResponse response,
                         javax.servlet.FilterChain filterChain)
            throws IOException, ServletException {

        ////Debug.println("=======================================================================NavigationFilter.begin");

        ////Debug.println("getContextPath="+((HttpServletRequest)request).getContextPath());
        ////Debug.println("getRequestURI="+((HttpServletRequest)request).getRequestURI());
        ////Debug.println("getRequestURL="+((HttpServletRequest)request).getRequestURL());
        ////Debug.println("getPathInfo="+((HttpServletRequest)request).getPathInfo());
        ////Debug.println("getPathTranslated="+((HttpServletRequest)request).getPathTranslated());
        ////Debug.println("getQueryString="+((HttpServletRequest)request).getQueryString());

        try {
            manageNavigationHistory(request, response);
        } catch (WebLogicException e) {
            throw new ServletException(e.getMessage());
        }

        ////Debug.println("manageNavigationHistory() done");
        ////Debug.println("manageNavigationHistory() done, HttpSession.HISTORY="+((HttpServletRequest)request).getSession().getAttribute(IConstants.HISTORY));

        ////Debug.println("=========================================================================NavigationFilter.filterChain.doFilter(request, response)");

        filterChain.doFilter(request, response);

        ////Debug.println("=========================================================================NavigationFilter.end");
    }

    private void manageNavigationHistory(ServletRequest request, ServletResponse response) throws WebLogicException, ServletException {
        try {
            ////Debug.println("NavigationFilter.updateHistory() - start");
            String requestURI = ((HttpServletRequest)request).getRequestURI();

            URLHistoryHelper urlHistoryHelper = null;

            /*
            //Debug.println("getPathInfo() = " + ((HttpServletRequest)request).getPathInfo());
            //Debug.println("getPathTranslated() = " + ((HttpServletRequest)request).getPathTranslated());
            //Debug.println("getQueryString() = " + ((HttpServletRequest)request).getQueryString());
            //Debug.println("getServletPath() = " + ((HttpServletRequest)request).getServletPath());
            //Debug.println("getRequestURI() = " + ((HttpServletRequest)request).getRequestURI());
            //Debug.println("getRequestURL() = " + ((HttpServletRequest)request).getRequestURL());
            */

            if (requestURI.indexOf("/occupationalmedicine/") >= 0) {

                urlHistoryHelper = URLHistoryHelper.getInstance(getContextualPath(((HttpServletRequest)request), "/occupationalmedicine/showWelcomePage.do"), "Home");

            }  else if (requestURI.indexOf("/recruitment/") >= 0) {

                urlHistoryHelper = URLHistoryHelper.getInstance(getContextualPath(((HttpServletRequest)request), "/recruitment/showWelcomePage.do"), "Home");

            }  else if (requestURI.indexOf("/healthrecord/") >= 0) {

                urlHistoryHelper = URLHistoryHelper.getInstance(getContextualPath(((HttpServletRequest)request), "/occupationalmedicine/showWelcomePage.do"), "Home");
            }

            if (urlHistoryHelper == null) {

                urlHistoryHelper = URLHistoryHelper.getInstance(getContextualPath(((HttpServletRequest)request), "/showWelcomePage.do"), "Home");
            }


            ////Debug.println("NavigationFilter.updateHistory() - URLHistoryHelper.getInstance(); OK");
            urlHistoryHelper.updateHistory(request, response);
            ////Debug.println("NavigationFilter.updateHistory() - urlHistoryHelper.updateHistory(request, response); OK");
            //URLHistoryHelper.getInstance().updateHistory(request, response);
            ////Debug.println("NavigationFilter.updateHistory() - end");
        } catch (URLHistoryException e) {
            ////Debug.println("URLHistoryException -->> "+e.getMessage());
            //e.printStackTrace();
        }
    }

    private String getContextualPath(HttpServletRequest request, String target){

        String path = request.getRequestURI().substring( 0, request.getRequestURI().indexOf( request.getServletPath() ) );

        return path + target;
    }

}
