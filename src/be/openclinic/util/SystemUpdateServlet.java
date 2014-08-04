package be.openclinic.util;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.UpdateSystem;

public class SystemUpdateServlet extends HttpServlet {
	
	//--- DO GET ---------------------------------------------------------------------------------- 
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
	    
	    HttpSession session = (HttpSession)request.getSession();
	    UpdateSystem systemUpdate = new UpdateSystem();
	    
	    String sAPPFULLDIR = getServletContext().getRealPath("");
	    systemUpdate.setBasedir(sAPPFULLDIR);
	    
	    String sProcessID = "systemUpdate_"+System.currentTimeMillis();
	    session.setAttribute(sProcessID,systemUpdate);
	    systemUpdate.start();
		//session.removeAttribute(sProcessID);
	    
	    // forward to status-bar
	    RequestDispatcher dispatcher = request.getRequestDispatcher("/util/updateSystem.jsp?processId="+sProcessID);
	    dispatcher.forward(request,response);
	}
	
}
