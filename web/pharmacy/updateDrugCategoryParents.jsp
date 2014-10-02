<%@page import="be.mxs.common.util.system.*,
                be.openclinic.pharmacy.*,
                java.util.*"%>
<%
    String sCode = ScreenHelper.checkString(request.getParameter("code"));

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********** paharmacy/updateDrugCategoryParents.jsp *********");
    	Debug.println("sCode : "+sCode+"\n");
    }    
    /////////////////////////////////////////////////////////////////////////////////////

	try{		
		String parentsstring = "";
		Vector parents = DrugCategory.getParentIdsNoReverse(sCode);
		for(int n=0; n<parents.size(); n++){
			parentsstring+= (String)parents.elementAt(n)+" "+HTMLEntities.htmlentities(ScreenHelper.getTranNoLink("drug.category",(String)parents.elementAt(n),request.getParameter("language")))+"<br/>";
		}
		out.print(parentsstring);
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>