<%@page import="be.mxs.common.util.io.UpdateService,
                be.mxs.common.util.io.LabelSyncService,
                be.mxs.common.util.io.TransactionItemSyncService"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCheckService = checkString(request.getParameter("CheckService"));

    StringBuffer requestURL = request.getRequestURL();

    //--- check for program updates ---------------------------------------------------------------

    // only perform program update if on localhost
    if(requestURL.indexOf("://localhost") > -1){
        UpdateService updService = UpdateService.getInstance();
        boolean updateCheckNeeded = updService.isUpdateCheckNeeded();

        if(updateCheckNeeded){
            %>
              <script>
                window.status='<%=getTran("web.manage","checkingForUpdate",sWebLanguage)%>';
              </script>
            <%
            out.flush();

            if(Debug.enabled) Debug.println("\n*** Checking for updates ***");

            try{
                boolean updateNeeded = updService.isUpdateNeeded("openclinic");

                if(updateNeeded){
                    if(Debug.enabled) Debug.println("\nUpdate needed to version "+updService.getNewVersionId());
                    String msg = getTran("web.manage","doyouwantotupdateprogram",sWebLanguage);
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
                    if(Debug.enabled) Debug.println("\nNo update needed or available");
                    out.flush();
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }

            if(Debug.enabled) Debug.println("*********** done ***********\n");
        }
    }

    //--- sync ini files --------------------------------------------------------------------------
    if(requestURL.indexOf("://localhost") > -1){
        //--- sync labels file ---
        LabelSyncService labelSyncService = LabelSyncService.getInstance();
        labelSyncService.setDebug(true);
        labelSyncService.setOut(out);

        TransactionItemSyncService itemSyncService = TransactionItemSyncService.getInstance();
        itemSyncService.setDebug(true);
        itemSyncService.setOut(out);

        boolean syncNeeded = itemSyncService.isSyncNeeded();

        if(syncNeeded){
            labelSyncService.updateDB();       // INI >> DB
            //labelSyncService.updateINIFiles(); // DB >> INI

            itemSyncService.updateDB();      // INI >> DB
            //itemSyncService.updateINIFile(); // DB >> INI
        }

        // update done, no need to do it again until configString "autoSyncIniFiles" is set to "1"
        itemSyncService.updateAutoSyncIniFileValue("0");
    }

    // controls DOB of user and shows happy birthday
    if ((activeUser.person.dateOfBirth!=null)&&(activeUser.person.dateOfBirth.trim().length()>0)){
        String sDOB = activeUser.person.dateOfBirth;
        sDOB = sDOB.substring(0,sDOB.lastIndexOf("/"));
        String sNow = getDate();
        sNow = sNow.substring(0,sNow.lastIndexOf("/"));

        if (sDOB.equals(sNow)){
            %><script>alert("Happy birthday!");</script><%
        }
    }

    // user must select a service when he works in more than one services
    if(!"datacenter".equalsIgnoreCase((String)session.getAttribute("edition"))){
	    if ((activeUser.vServices.size()>1)&&(sCheckService.trim().equals("true"))){
	        ScreenHelper.setIncludePage("startChangeService.jsp?NextPage=_common/start.jsp", pageContext);
	    }
        out.print("<center><h4>"+getTran("Web","welcome",sWebLanguage)+" "+activeUser.person.firstname+" "+activeUser.person.lastname+"</h4></center>");
        session.setAttribute("activeMedicalCenter",activeUser.activeService.code);
    }
    else {
    	ScreenHelper.setIncludePage("../datacenterstatistics/index.jsp",pageContext);
    }
%>
