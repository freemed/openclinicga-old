<%@page import="net.admin.*,
                java.text.*,
                java.util.*,
                be.mxs.common.util.system.*,
                be.mxs.common.util.db.*"%>
<%
	String sMonth = new SimpleDateFormat("yyyyMM").format(new Date());	

	String personid   = request.getParameter("personid"),
           insuraruid = request.getParameter("insuraruid"),
           userid     = request.getParameter("userid"),
           language   = request.getParameter("language");
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************** financial/checkInsuranceAuthorisation.jsp **************");
		Debug.println("sMonth     : "+sMonth);
		Debug.println("personid   : "+personid);
		Debug.println("insuraruid : "+insuraruid);
		Debug.println("userid     : "+userid);
		Debug.println("language   : "+language+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	Vector pointers = Pointer.getPointers("AUTH."+insuraruid+"."+personid+"."+sMonth);
	boolean bValid = false;
	SimpleDateFormat deci = new SimpleDateFormat("yyyyMMddHHmmss");
	
	for(int n=0; n<pointers.size() && !bValid; n++){
		String pointer = (String)pointers.elementAt(n);
		
		Date dValidUntil = deci.parse(pointer.split(";")[0]);
		if(dValidUntil.after(new Date())){
			// Still valid
			User user = User.get(Integer.parseInt(pointer.split(";")[1]));
			String username = user!=null?user.person.getFullName():"?";
			
			out.print(HTMLEntities.htmlentities("<td class='admin'>"+ScreenHelper.getTran("web","insurance.agent.authorization",language)+"</td>"+
			                                    "<td class='admin2'>"+ScreenHelper.getTran("web","authorized.by",language)+": "+username+" "+ScreenHelper.getTran("web","until",language)+" <b>"+ScreenHelper.fullDateFormatSS.format(dValidUntil)+"</b></td>"));
			bValid = true;
		}
	}
	
	if(!bValid){
		if(MedwanQuery.getInstance().getConfigString("InsuranceAgentAuthorizationNeededFor","").indexOf("*"+insuraruid+"*")>-1){
			User user = User.get(Integer.parseInt(userid));
			if(user!=null && user.getParameter("insuranceagent")!=null && user.getParameter("insuranceagent").equalsIgnoreCase(insuraruid)){
				// This agent can give an authorization for performing prestation encoding
				out.print(HTMLEntities.htmlentities("<td class='admin'>"+ScreenHelper.getTran("web","insurance.agent.authorize",language)+"</td>"+
				                                    "<td class='admin2'><input type='checkbox' class='text' name='EditAuthorization' id='EditAuthorization' value='"+new SimpleDateFormat("yyyyMMddHHmmss").format(new Date())+";"+userid+"'>"+ScreenHelper.getTran("web","authorize.until",language)+" <b>"+ScreenHelper.fullDateFormatSS.format(new Date(new Date().getTime()+24*3600*1000))+"</b></td>"));
			}
		}
	}
%>