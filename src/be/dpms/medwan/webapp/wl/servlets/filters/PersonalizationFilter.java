package be.dpms.medwan.webapp.wl.servlets.filters;

import be.dpms.medwan.webapp.wo.authentication.exceptions.UserParametersWONotFoundException;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.dpms.medwan.common.model.IConstants;
import be.dpms.medwan.common.model.vo.authentication.UserVO;

import javax.servlet.Filter;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.Locale;
import java.io.IOException;

import org.apache.struts.action.Action;

public class PersonalizationFilter implements Filter {

    public void init(javax.servlet.FilterConfig config) throws ServletException {

    }

    public void destroy(){

    }

    public void doFilter(ServletRequest request, ServletResponse response,
                         javax.servlet.FilterChain filterChain)
            throws IOException, ServletException {

        try {

            applyUserPreferences(request);

            ////Debug.println("=========================================================================PersonalizationFilter.filterChain.doFilter(request, response)");

            filterChain.doFilter(request, response);

            ////Debug.println("=========================================================================PersonalizationFilter.end");

        } catch (UserParametersWONotFoundException e) {
            e.printStackTrace();  //To change body of catch statement use Options | File Templates.
        }
    }

    private void applyUserPreferences(ServletRequest request) throws UserParametersWONotFoundException {

        try {
            HttpSession session = ((HttpServletRequest)request).getSession();

            SessionContainerWO sessionContainerWO  = (be.dpms.medwan.webapp.wo.common.system.SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO((HttpServletRequest)request, SessionContainerWO.class.getName());
            if (sessionContainerWO.getUserVO() != null){
                //Debug.println("UserV0: "+sessionContainerWO.getUserVO().getPersonVO());
            }
            String activeView = request.getParameter("medwan.content.activeView");

            ////Debug.println("\n\n\n::::::::::::::::::::::::: parameter activeView = " + activeView);

            if (activeView != null) {

                if (activeView.equals(SessionContainerWO.ACTIONS_VIEW)) sessionContainerWO.setActiveView(SessionContainerWO.ACTIONS_VIEW);
                else sessionContainerWO.setActiveView(SessionContainerWO.SUMMARY_VIEW);

            } else if (sessionContainerWO.getActiveView() == null) {

                ////Debug.println("::::::::::::::::::::::::: /// sessionContainerWO.getActiveView() = " + sessionContainerWO.getActiveView());
                sessionContainerWO.setActiveView(SessionContainerWO.SUMMARY_VIEW);
                ////Debug.println("::::::::::::::::::::::::: /// sessionContainerWO.getActiveView() = " + sessionContainerWO.getActiveView());
            }

            ////Debug.println("::::::::::::::::::::::::: sessionContainerWO.getActiveView() = " + sessionContainerWO.getActiveView());

            UserVO userVO = sessionContainerWO.getUserVO();

            if (userVO == null) {
                //Debug.println("applyUserPreferences - userContainerWO is null");
                Locale sessionLocale = (Locale)session.getAttribute(Action.LOCALE_KEY);
                Locale userLocale = new Locale(IConstants.LANGUAGE_FR, IConstants.COUNTRY_BE);
                session.setAttribute(Action.LOCALE_KEY, userLocale);
            } else {

                String country;
                String language = userVO.getPersonVO().getLanguage();
                //Debug.println("UserLanguage: "+language);

                if ( language == null ) language = IConstants.LANGUAGE_FR;
                else {
                    if ( language.equals("F") ) language = IConstants.LANGUAGE_FR;
                    else language = IConstants.LANGUAGE_NL;
                }
                country = IConstants.COUNTRY_BE;

                if ( country == null ) country = IConstants.COUNTRY_BE;
                if ( language == null ) language = IConstants.LANGUAGE_FR;

                Locale userLocale = new Locale(language, country);

                // Get the Locale (if any) that is stored in the user's session
                Locale sessionLocale = (Locale)session.getAttribute(Action.LOCALE_KEY);
                ////Debug.println(this.getClass()+".setUserPreferenceLanguage() - sessionLocale = " + sessionLocale);

                if ( (sessionLocale == null) || (!sessionLocale.equals(userLocale) ) ) {
                    session.setAttribute(Action.LOCALE_KEY, userLocale);
                    ////Debug.println(this.getClass()+".setUserPreferenceLanguage() - changing Locale (HttpSession.Action.LOCALE_KEY) to <country="+userLocale.getCountry()+"> and <language="+userLocale.getLanguage()+">");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new UserParametersWONotFoundException( e.getMessage() );
        }
    }
}
