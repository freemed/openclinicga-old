<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%  
	if(request.getParameter("init")!=null){
		MedwanQuery.getInstance().setProgressValue(request.getParameter("id"),0);
	}
	else {
		out.println(MedwanQuery.getInstance().getProgressValue(request.getParameter("id"))+"");
	}
%>