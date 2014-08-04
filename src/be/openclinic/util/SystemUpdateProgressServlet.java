package be.openclinic.util;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.UpdateSystem;

public class SystemUpdateProgressServlet extends HttpServlet {
	
	//--- DO GET ---------------------------------------------------------------------------------- 
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
	    String processId = ScreenHelper.checkString(request.getParameter("processId"));
	    
	    UpdateSystem systemUpdate = (UpdateSystem)request.getSession().getAttribute(processId);
	    int progress = systemUpdate.getProgress();

	    response.setContentType("application/json");
	    response.setCharacterEncoding("UTF-8");
	    response.getWriter().write(String.valueOf(progress));
	}
	
}
