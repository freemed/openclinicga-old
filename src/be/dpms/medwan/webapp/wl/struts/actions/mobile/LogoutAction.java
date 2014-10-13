package be.dpms.medwan.webapp.wl.struts.actions.mobile;

import org.apache.struts.action.*;

import be.mxs.common.util.system.Debug;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LogoutAction extends Action{

    //--- PERFORM ---------------------------------------------------------------------------------
    public ActionForward perform(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response){

        HttpSession session = request.getSession();

        // invalidate session if it is still valid.
        if(session!=null) session.invalidate();

        Debug.println("###############################################################");
        Debug.println("### MobileLogout ##############################################");
        Debug.println("###############################################################"); 

        // go to "logged out" page
        return mapping.findForward("success");
    }

}