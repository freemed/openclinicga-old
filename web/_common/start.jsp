<%@page import="be.mxs.common.util.io.UpdateService,
                be.mxs.common.util.io.LabelSyncService,
                be.mxs.common.util.io.TransactionItemSyncService"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sCheckService = checkString(request.getParameter("CheckService"));

    StringBuffer requestURL = request.getRequestURL();

    //--- 1 - check for program updates -----------------------------------------------------------
    // only perform program update if on localhost
    if(requestURL.indexOf("://localhost") > -1){
        UpdateService updService = UpdateService.getInstance();
        boolean updateCheckNeeded = updService.isUpdateCheckNeeded();

        if(updateCheckNeeded){
            %><script>window.status='<%=getTranNoLink("web.manage","checkingForUpdate",sWebLanguage)%>';</script><%
            out.flush();

            Debug.println("\n*** Checking for updates ***");

            try{
                boolean updateNeeded = updService.isUpdateNeeded("openclinic");

                if(updateNeeded){
                    Debug.println("\nUpdate needed to version "+updService.getNewVersionId());
                    
                    String msg = getTranNoLink("web.manage","doyouwantotupdateprogram",sWebLanguage);
                    msg = msg.replaceAll("#version#","\""+updService.getNewVersionId()+"\"");

                    %>
                      <script>
                        if(confirm('<%=msg%>')){
                          window.location.href = '<%=updService.getPathToUpdateFile()%>';
                        }
                      </script>
                    <%
                }
                else{
                    Debug.println("\nNo update needed or available");
                    out.flush();
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }

            Debug.println("*********** done ***********\n");
        }
    }

    //--- 2 - sync ini files ----------------------------------------------------------------------
    // only on local machine
    if(requestURL.indexOf("://localhost") > -1){
        // sync labels file
        LabelSyncService labelSyncService = LabelSyncService.getInstance();
        labelSyncService.setDebug(true);
        labelSyncService.setOut(out);

        TransactionItemSyncService itemSyncService = TransactionItemSyncService.getInstance();
        itemSyncService.setDebug(true);
        itemSyncService.setOut(out);

        if(itemSyncService.isSyncNeeded()){
            labelSyncService.updateDB(); // INI >> DB
            itemSyncService.updateDB();
        }

        // update done, no need to do it again until configString "autoSyncIniFiles" is set to "1"
        itemSyncService.updateAutoSyncIniFileValue("0");
    }

    // controls DOB of user and shows happy birthday
    if(checkString(activeUser.person.dateOfBirth).length() > 0){
        String sDOB = activeUser.person.dateOfBirth;
        sDOB = sDOB.substring(0,sDOB.lastIndexOf("/"));
       
        String sNow = getDate();
        sNow = sNow.substring(0,sNow.lastIndexOf("/"));

        if(sDOB.equals(sNow)){
            %><script>alertDialogDirectText("Happy birthday!");</script><%
        }
    }

    // user must select a service when he works in more than one service
    if(!"datacenter".equalsIgnoreCase((String)session.getAttribute("edition"))){
	    if(activeUser.vServices.size() > 1 && sCheckService.equals("true")){
	        ScreenHelper.setIncludePage("startChangeService.jsp?NextPage=_common/start.jsp", pageContext);
	    }
	    
	    if(MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterCountry","").length()==0 ||
	       MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterCity","").length()==0){
	        out.println("<script>window.open('popup.jsp?Page=system/manageGlobalHealthBarometerData.jsp&PopupWidth=800&PopupHeight=600&AutoClose=1','GlobalHealthBarometer', 'toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no');</script>");
	    }
	    
	    // show welcome message
        out.print("<center><h4>"+getTran("Web","welcome",sWebLanguage)+" "+activeUser.person.firstname+" "+activeUser.person.lastname+"</h4></center>");
        session.setAttribute("activeMedicalCenter",activeUser.activeService.code);
    }
    else{
    	ScreenHelper.setIncludePage("../datacenterstatistics/index.jsp",pageContext);
    }
%>