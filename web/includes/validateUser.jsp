<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%@page import="net.admin.system.AccessLog"%>
<%@include file="/includes/helper.jsp"%>
<%@include file="/includes/SingletonContainer.jsp"%>

<%
	if(request.getParameter("me")!=null){
		session.setAttribute("me",request.getParameter("me"));
	}   

	response.setHeader("Content-Type","text/html; charset=ISO-8859-1");

    String sProject = null;
    String sWebLanguage = null;
    User activeUser = null;
    AdminPerson activePatient = null;

    //***** session timed out *********************************************************************
    if(session==null || session.isNew()){
        //*** AutoUserName ***
        if(request.getParameter("AutoUserName")!=null){
            // active user
            activeUser = new User();
            byte[] aUserPassword = activeUser.encrypt(request.getParameter("AutoUserPassword"));
            activeUser.initialize(request.getParameter("AutoUserName"),aUserPassword);
            session.setAttribute("activeUser",activeUser);

            // reset lastPatient
            session.removeAttribute("lastPatient");
            
            // weblanguage
            session.setAttribute(sAPPTITLE+"WebLanguage",activeUser.person.language);
            sWebLanguage = activeUser.person.language;

            // active project title
            String sTmpProjectName = checkString((String)session.getAttribute("activeProjectTitle"));
            if(sTmpProjectName.length()==0){
                sTmpProjectName = "OpenClinic";
                session.setAttribute("activeProjectTitle",sTmpProjectName);
            }

            if((!activeUser.project.toLowerCase().equals("mxs") && (!sTmpProjectName.toLowerCase().equals(activeUser.project.toLowerCase())))) {
                sTmpProjectName = activeUser.project;
                session.setAttribute("activeProjectTitle",sTmpProjectName);

                // active project dir
                if(!sTmpProjectName.toLowerCase().equals("openclinic")){
                    session.setAttribute("activeProjectDir","projects/"+sTmpProjectName.toLowerCase()+"/");
                } 
                else{
                    session.setAttribute("activeProjectDir",sCONTEXTPATH+"/");
                }
            }

            // timeout
            String sTimeOutInSeconds = checkString(activeUser.getParameter("Timeout"));

            if(sTimeOutInSeconds.length()==0){
                String sDefaultTimeOutInSeconds = MedwanQuery.getInstance().getConfigString("DefaultTimeOutInSeconds");
                if(sDefaultTimeOutInSeconds.length()==0){
                    sDefaultTimeOutInSeconds = "3600";
                }
                sTimeOutInSeconds = sDefaultTimeOutInSeconds;
            }

            int iTimeOutInSeconds = 0;
            try{
                iTimeOutInSeconds = Integer.parseInt(sTimeOutInSeconds);
            }
            catch(Exception e){
                // nothing
            }

            session.setMaxInactiveInterval(iTimeOutInSeconds);
            reloadSingleton(session);
        }
        //*** no AutoUserName ***
        else{
            if(request.getRequestURI().indexOf("search") > -1){
                // close search-popup and let its opener-window redirect to the login page.
                out.print("<script>window.close();</script>");
                out.print("<script>window.opener.location.href = '"+sCONTEXTPATH+"/relogin.do';</script>");
                out.flush();
            }
            else{
                response.sendRedirect(sCONTEXTPATH+"/relogin.do");
            }
        }
    }
    //***** session still alive *******************************************************************
    else{
        activeUser = (User)session.getAttribute("activeUser");

        activePatient = (AdminPerson)session.getAttribute("activePatient");
        AdminPerson lastPatient = (AdminPerson)session.getAttribute("lastPatient");
        
        ///////////// CHANGE PATIENT ///////////
        if(lastPatient==null && activePatient!=null){
            session.setAttribute("lastPatient",activePatient);
            AccessLog.insert(activeUser.userid,"A."+activePatient.personid);
        }
        else if(activePatient!=null){
            if(!lastPatient.personid.equals(activePatient.personid)){
                session.setAttribute("lastPatient",activePatient);
                AccessLog.insert(activeUser.userid,"A."+activePatient.personid);
            }
        }
        sProject = "/"+MedwanQuery.getInstance().getConfigString("projectname","openclinic");

        // weblanguage
        sWebLanguage = checkString((String)session.getAttribute(sAPPTITLE+"WebLanguage"));

        if(activeUser!=null && ((sWebLanguage.trim().length()==0) || session.getAttribute(sAPPTITLE+"WebLanguage")==null)){
            sWebLanguage = activeUser.person.language;
            session.setAttribute(sAPPTITLE+"WebLanguage",sWebLanguage);
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
	        if(sessionContainerWO.getUserVO() == null || sessionContainerWO.getUserVO().getPersonVO() == null || !activeUser.userid.equalsIgnoreCase(sessionContainerWO.getUserVO().userId+"")) {
	            sessionContainerWO.setUserVO(MedwanQuery.getInstance().getUser(activeUser.userid));
	        }
        } 
        else if(sWebLanguage.trim().length()==0){
            sWebLanguage = "fr";
            session.setAttribute(sAPPTITLE+"WebLanguage",sWebLanguage);
        }       
    }
    
    if(activeUser==null){
        %><script>window.location.href="<c:url value='/relogin.do'/>?ts=<%=getTs()%>";</script><%
    }
%>