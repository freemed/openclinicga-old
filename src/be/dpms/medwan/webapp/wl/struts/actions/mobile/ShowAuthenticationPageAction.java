package be.dpms.medwan.webapp.wl.struts.actions.mobile;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import java.util.Locale;
import be.dpms.medwan.common.model.IConstants;
import be.mxs.common.util.system.Debug;
import net.admin.User;

public class ShowAuthenticationPageAction extends org.apache.struts.action.Action {

	//--- PERFORM ---------------------------------------------------------------------------------
    public ActionForward perform(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws IOException, ServletException {

        Debug.println("###############################################################");
        Debug.println("### MobileAuthentication ######################################");
        Debug.println("###############################################################");

        return mapping.findForward("success");
    }

}
