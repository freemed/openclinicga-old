<%@page import="java.util.Hashtable,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="includes/helper.jsp"%>
<%@include file="includes/SingletonContainer.jsp"%>

<%!
    //--- CHECK FOR IP INTRUSION ------------------------------------------------------------------
    private int checkForIPIntrusion(Connection conn, HttpServletRequest req, String sIntrusionIP) throws Exception{
        IntrusionDetector.registerIntrusionOnIP(conn,req,req.getRemoteAddr());

        // check wether the intruder is blocked
        boolean blockedTemporarily;
        boolean blockedPermanently = IntrusionDetector.isIntruderBlockedPermanently(conn,sIntrusionIP);
        int remainingBlockDuration = -1; // all OK

        if(blockedPermanently){
            remainingBlockDuration = 0;
        }
        else{
            blockedTemporarily = IntrusionDetector.isIntruderBlockedTemporarily(conn,sIntrusionIP);
            if(blockedTemporarily){
                remainingBlockDuration = IntrusionDetector.getRemainingBlockDuration(conn,req.getRemoteAddr());
            }
        }

        return remainingBlockDuration;
    }

    //--- CHECK FOR LOGIN INTRUSION ---------------------------------------------------------------
    private int checkForLoginIntrusion(Connection conn, HttpServletRequest req, String sUserLogin) throws Exception{
        IntrusionDetector.registerIntrusionOnLogin(conn,req,sUserLogin);

        // check wether the intruder is blocked
        boolean blockedTemporarily;
        boolean blockedPermanently = IntrusionDetector.isIntruderBlockedPermanently(conn,sUserLogin);
        int remainingBlockDuration = -1; // all OK

        if(blockedPermanently){
            remainingBlockDuration = 0;
        }
        else{
            blockedTemporarily = IntrusionDetector.isIntruderBlockedTemporarily(conn,sUserLogin);
            if(blockedTemporarily){
                remainingBlockDuration = IntrusionDetector.getRemainingBlockDuration(conn,sUserLogin);
            }
        }

        return remainingBlockDuration;
    }
    
%>

<%
	
	String ag = request.getHeader("User-Agent"), browser="", version="";
	try{
		int tmpPos; 
		ag = ag.toLowerCase();
		if (ag.contains("msie")) {
			browser = "Internet Explorer";
		    String str = ag.substring(ag.indexOf("msie") + 5);
		    version = str.substring(0, str.indexOf(";"));
		}
		else if (ag.contains("opera")){
			browser = "Opera";
			ag=ag.substring(ag.indexOf("version"));
			String str="";
			if(ag.indexOf(" ")>-1){
				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
			    version = str.substring(0, str.indexOf(" "));
			}
			else{
				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
			}
		}
		else if (ag.contains("chrome")){
			browser = "Chrome";
			ag=ag.substring(ag.indexOf("chrome"));
			String str="";
			if(ag.indexOf(" ")>-1){
				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
			    version = str.substring(0, str.indexOf(" "));
			}
			else{
				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
			}
		}
		else if (ag.contains("firefox")){
			browser = "Firefox";
			ag=ag.substring(ag.indexOf("firefox"));
			String str="";
			if(ag.indexOf(" ")>-1){
				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
			    version = str.substring(0, str.indexOf(" "));
			}
			else{
				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
			}
		}
		else if (ag.contains("safari") && ag.contains("version")){
			browser = "Safari";
			ag=ag.substring(ag.indexOf("version"));
			String str="";
			if(ag.indexOf(" ")>-1){
				str = (ag.substring(tmpPos = (ag.indexOf("/")) + 1, tmpPos + ag.indexOf(" "))).trim();
			    version = str.substring(0, str.indexOf(" "));
			}
			else{
				version = (ag.substring(tmpPos = (ag.indexOf("/")) + 1)).trim();
			}
		}
	}
	catch(Exception e3){
		e3.printStackTrace();
	}
System.out.println(1);
// get formdata
  if (request.getParameter("Dir")!=null){
      sAPPDIR = request.getParameter("Dir");
  }

  MedwanQuery.getInstance("http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")+"/"+sAPPDIR);

  String sUserLogin    = checkString(request.getParameter("login"));
  String sUserPassword = checkString(request.getParameter("password"));
  String sAuto = request.getParameter("auto");

  session.setAttribute("password",sUserPassword);
  session.removeAttribute("activeUser");
  session.removeAttribute("activePatient");
  session.removeAttribute("Translations");
  session.removeAttribute("vUnits");
  session.removeAttribute("tsSessionStart");
  session.removeAttribute(sAPPTITLE+"WebLanguage");

  if(sUserLogin.length()==0 || sUserPassword.length()==0) {
      response.sendRedirect("login.jsp?message=Empty values!&ts="+getTs());
  }
  else{
      try {
          Integer.parseInt(sUserLogin);

          Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
          if(ad_conn != null) {
              User user = new User();
              byte[] aUserPassword = user.encrypt(sUserPassword);

              System.out.println(1.1);
              if ((sAuto!=null && sAuto.equalsIgnoreCase("true") && user.initializeAuto(ad_conn, sUserLogin, sUserPassword)) || user.initialize(ad_conn, sUserLogin, aUserPassword)) {
            	  System.out.println(1.2);
                  GregorianCalendar myDate = new GregorianCalendar();
                  String sDay, sMonth, sYear, sDate;
                  sDay = myDate.get(Calendar.DATE) + "";
                  sMonth = myDate.get(Calendar.MONTH) + 1 + "";
                  sYear = myDate.get(Calendar.YEAR) + "";
                  sDate = sMonth+"/"+sDay+"/"+sYear;
                  boolean bPermission;
                  bPermission = User.hasPermission(user.userid,sDate);
                  if(!bPermission){
                	  ad_conn.close();
                      response.sendRedirect("login.jsp?message=Permission stopped&ts="+getTs());
                  }
                  session.setAttribute("activeUser",user);
                  MedwanQuery.setSession(session,user);
                  //Add some session attributes for user connectivity monitoring
                  session.setAttribute("mon_ipaddress",request.getRemoteAddr());
                  session.setAttribute("mon_browser",browser+" "+version);
                  session.setAttribute("mon_start",new java.util.Date());
                  //*** set project name and dir **************************************************
                  String sTmpProjectName = checkString((String)session.getAttribute("activeProjectTitle"));
                  if (sTmpProjectName.length()==0) {
                      sTmpProjectName = "OpenClinic";
                      session.setAttribute("activeProjectTitle",sTmpProjectName);
                  }

                  if ((!user.project.toLowerCase().equals("mxs")&&(!sTmpProjectName.toLowerCase().equals(user.project.toLowerCase())))) {
                      sTmpProjectName = user.project;
                      session.setAttribute("activeProjectTitle",sTmpProjectName);
                      if (!sTmpProjectName.toLowerCase().equals("openwork")) {
                          session.setAttribute("activeProjectDir", "projects/"+sTmpProjectName.toLowerCase()+"/");
                      }
                      else {
                          session.setAttribute("activeProjectDir", sCONTEXTPATH+"/");
                      }
                  }

                  Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
                  if(langHashtable == null || langHashtable.size()==0){
                      reloadSingleton(session);
                  }

                  //*** log access ****************************************************************
                  AccessLog objAL = new AccessLog();
                  objAL.setUserid(Integer.parseInt(user.userid));
                  objAL.setAccesstime(getSQLTime());
                  AccessLog.logAccess(objAL);
                  //*** set timeout ***************************************************************
                  String sTimeOutInSeconds = checkString(user.getParameter("Timeout"));

                  if (sTimeOutInSeconds.length()==0) {
                      String sDefaultTimeOutInSeconds = MedwanQuery.getInstance().getConfigString("DefaultTimeOutInSeconds");
                      if (sDefaultTimeOutInSeconds.length()==0) {
                          sDefaultTimeOutInSeconds = "3600";
                      }
                      sTimeOutInSeconds = sDefaultTimeOutInSeconds;
                  }

                  // set timeout as int in session
                  int iDefaultTimeOutInSeconds;
                  try {
                      iDefaultTimeOutInSeconds = Integer.parseInt(sTimeOutInSeconds);
                  }
                  catch(Exception e) {
                      iDefaultTimeOutInSeconds = 3600;
                  }
                  session.setMaxInactiveInterval(iDefaultTimeOutInSeconds);

                  // clear intrusions for this user
                  IntrusionDetector.clearIntrusion(ad_conn,sUserLogin);
                  IntrusionDetector.clearIntrusion(ad_conn,request.getRemoteAddr());

                  //*** "change password"-reminder ************************************************
                  int availability = MedwanQuery.getInstance().getConfigInt("PasswordAvailability");
                  int noticeTime   = MedwanQuery.getInstance().getConfigInt("PasswordNoticeTime");

                  // only check to see if a reminder must be poppedup
                  // when both values above are not left empty.
                  long millisInDay = 24*3600*1000;
                  long now = System.currentTimeMillis();
                  long pwdChangeDate;
                  try{ pwdChangeDate = Long.parseLong(user.getParameter("pwdChangeDate")); }
                  catch(Exception e){ pwdChangeDate = 0; }

                  double daysLeftTillAvail = ((double)pwdChangeDate+((availability)*millisInDay)-now)/millisInDay;

                  if(availability > -1){
                      if(daysLeftTillAvail <= 0){
                    	  ad_conn.close();
                          response.sendRedirect("changePassword.do?ts="+getTs());
                      }
                  }

                  if(noticeTime > -1){
                      double daysLeftTillNotice = ((double)pwdChangeDate+((availability-noticeTime)*millisInDay)-now)/millisInDay;
                      if(daysLeftTillNotice <= 0){
                          // the user may perform all actions, but first sees the passwordscreen
                    	  ad_conn.close();
                          response.sendRedirect("main.do?Page=userprofile/changepassword.jsp&popup=yes&daysLeft="+(int)daysLeftTillAvail+"&ts="+getTs());
                      }
                  }

                  // redirect to other projectpage
                  if(request.getParameter("startPage")!=null){
                      if(Debug.enabled) Debug.println("Redirecting to "+request.getParameter("startPage"));
                	  ad_conn.close();
                      response.sendRedirect(request.getParameter("startPage"));
                  }
            	  ad_conn.close();
                  response.sendRedirect("main.do?CheckService=true&CheckMedicalCenter=true&ts="+getTs());
              }
              //--- wrong password or wrong login ---
              else {
                  // wrong password
                  if(user.userid.length() > 0){
                      if(!user.checkPassword(aUserPassword)){
                          int blockDuration = checkForLoginIntrusion(ad_conn,request,sUserLogin);
                          if(blockDuration >= 0 ){
                              // go to a page telling the user he has to wait
	                    	  ad_conn.close();
                              response.sendRedirect("blocked.jsp?duration="+blockDuration);
                          }
                          else{
                        	  ad_conn.close();
	                          response.sendRedirect("login.jsp?message=Password is wrong&ts="+getTs());
                          }
                      }
                  }
                  // login wrong
                  else{
                      int blockDuration = checkForIPIntrusion(ad_conn,request,request.getRemoteAddr());
                      if(blockDuration >= 0 ){
                          // go to a page telling the user he has to wait
                        	  ad_conn.close();
		                      response.sendRedirect("login.jsp");
                      }
                      else{
                    	  ad_conn.close();
		                  response.sendRedirect("login.jsp?message=Login is wrong&ts="+getTs());
                      }
                  }
              }
              ad_conn.close();
          }
          else{
        	  ad_conn.close();
		      response.sendRedirect("login.jsp?message=Connection error !&ts="+getTs());
          }

      }
      catch (NumberFormatException e) {
          // login wrong
		  Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
          int remainingBlockDuration = checkForIPIntrusion(ad_conn,request,request.getRemoteAddr());
          ad_conn.close();
          if(remainingBlockDuration >= 0 ){
              // go to a page telling the user he has to wait
              response.sendRedirect("login.jsp");
          }
          else{
              response.sendRedirect("login.jsp?message=Login is wrong&ts="+getTs());
          }
      }
      catch (Exception e) {
          response.sendRedirect("login.jsp?message=General error !&ts="+getTs());
          e.printStackTrace();
      }
  }
  System.out.println(2);

%>