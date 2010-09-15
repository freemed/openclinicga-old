package be.dpms.medwan.webapp.wl.struts.actions;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import java.util.Locale;
import be.dpms.medwan.common.model.IConstants;
import net.admin.User;

public class ShowAuthenticationPageAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward( "success" );
        if (request.getSession().getAttribute("activeUser") !=null){

            String language = ((User)request.getSession().getAttribute("activeUser")).person.language;

            if ( language == null ) language = IConstants.LANGUAGE_FR;
            else {
                if ( language.equals("F") ) language = IConstants.LANGUAGE_FR;
                else language = IConstants.LANGUAGE_NL;
            }
            setLocale( request, new Locale(language, be.dpms.medwan.common.model.IConstants.COUNTRY_BE ) );
        }

        return actionForward;
    }

}
