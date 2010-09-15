package be.dpms.medwan.webapp.wl.struts.actions;

import org.apache.struts.action.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Created by IntelliJ IDEA.
 * User: stijnsmets
 * Date: 20-jun-2005
 * Time: 9:33:15
 */

public class LogoutAction extends Action{

  //--- EXCECUTE ----------------------------------------------------------------------------------
  public ActionForward perform(
                     ActionMapping mapping,
                     ActionForm form,
                     HttpServletRequest request,
                     HttpServletResponse response){

    HttpSession session = request.getSession();

    // invalidate session if it is still valid.
    if(session != null) session.invalidate();

    // go to "logged out" page
    return mapping.findForward("success");
  }

}