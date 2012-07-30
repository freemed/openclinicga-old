<%@page import="be.mxs.common.util.db.*, java.util.*"%>
<%@ page import="be.openclinic.adt.Encounter" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<form name="mergeForm" method="post">
    <%-- HIDDEN FIELDS --%>
    <input type="hidden" name="action" value="">
    <input type="hidden" name="pid1" value="">
    <input type="hidden" name="pid2" value="">

<%
	try{
//####################### THIS FILE SHOULD ONLY BE EXECUTED ON A SERVER #######################

    // get request parameters
    String sAction      = checkString(request.getParameter("action")),
           pid1         = checkString(request.getParameter("pid1")),
           pid2         = checkString(request.getParameter("pid2")),
           keepPersonId = checkString(request.getParameter("keepPerson"));

    boolean automaticProcessing = checkString(request.getParameter("automaticProcessing")).equals("true");

    //if(getConfigString("serverId").equals("1")){
        // default action
        if(sAction.length() == 0){
            sAction = "ShowSearch";
        }
    //}

    ///// DEBUG ///////////////////////////////////////////////////////////////
    /*
    if(Debug.enabled){
        Debug.println("\n*** MERGE PERSONS **********************");
        Debug.println("*** sAction      : "+sAction);
        Debug.println("*** pid1         : "+pid1);
        Debug.println("*** pid2         : "+pid2);
        Debug.println("*** keepPersonId : "+keepPersonId);
        Debug.println("*** automaticProcessing : "+automaticProcessing);
    }
    */
    ///////////////////////////////////////////////////////////////////////////

    StringBuffer sbQuery = new StringBuffer();
    PreparedStatement ps;


    //### NO ACTION : DISPLAY MESSAGE ##############################################################
    if(sAction.length()==100){
        %>This module may only be executed on a server<%
    }
    //##############################################################################################
    //### Show search fields #######################################################################
    //##############################################################################################
    else if(sAction.equals("ShowSearch") || sAction.equals("SearchDoubles") ||
            sAction.equals("MergeDoubles") || sAction.equals("ProcessDoubles")){

        int selectedFields = 0;
        if(checkString(request.getParameter("selectedFields")).length() > 0){
            selectedFields = Integer.parseInt(request.getParameter("selectedFields"));
        }

        %>
            <table width="100%" class="menu" cellspacing="1" cellpadding="0">
                <%-- TITLE --%>
                <tr>
                    <td colspan="3">
                        <%=writeTableHeader("Web.manage","merge_persons",sWebLanguage," doBack();")%>
                    </td>
                </tr>

                <%-- CHOOSE A QUERY --%>
                <tr>
                    <td>&nbsp;<%=getTran("web","searchon",sWebLanguage)%></td>
                    <td colspan="2">
                        <select class="text" name="selectedFields">
                            <option><%=getTran("web","choose",sWebLanguage)%></option>
                            <option value="1" <%=(selectedFields==1?"selected":"")%>><%=getTran("Web","immatnew",sWebLanguage)%></option>
                            <option value="2" <%=(selectedFields==2?"selected":"")%>><%=getTran("Web","name",sWebLanguage)%> + <%=getTran("Web","dateofbirth",sWebLanguage)%></option>
                        </select>

                        <%-- checkbox to indicate "automatic processing" --%>
                        &nbsp;<input type="checkbox" name="automaticProcessing" id="autoProc" value="true" onClick="setSearchButton();" <%=(automaticProcessing?"checked":"")%>><%=getLabel("web.manage","automaticProcessing",sWebLanguage,"autoProc")%>

                        <%-- SEARCH BUTTON --%>
                        &nbsp;<span id="searchButtonSpan"></span>
                    </td>
                </tr>

                <script>
                  setSearchButton();

                  <%-- SET SEARCH BUTTON --%>
                  function setSearchButton(){
                    if(!mergeForm.automaticProcessing.checked){
                      document.getElementById("searchButtonSpan").innerHTML = "<input type='button' class='button' name='searchButton' value='<%=getTranNoLink("web","search",sWebLanguage)%>' onClick=\"checkSelectedQuery('SearchDoubles');\">";
                    }
                    else{
                      document.getElementById("searchButtonSpan").innerHTML = "<input type='button' class='button' name='searchButton' value='<%=getTranNoLink("web.manage","merge",sWebLanguage)%>' onClick=\"checkSelectedQuery('ProcessDoubles');\">";
                    }
                  }
                </script>

                <tr><td colspan="3"><hr style="height:1px;"></td></tr>

                <%-- CHOOSE PERSON A --%>
                <tr>
                    <td>&nbsp;<%=getTran("web","person",sWebLanguage)%> A</td>
                    <td colspan="2">
                        <input type="text" class="text" name="personA" size="40" READONLY>
                        <input class="button" type="button" value="<%=getTran("Web","select",sWebLanguage)%>" onclick="showSearchPatientPopup('pid1','personA');">&nbsp;
                    </td>
                </tr>

                <%-- CHOOSE PERSON B --%>
                <tr>
                    <td width="80">&nbsp;<%=getTran("web","person",sWebLanguage)%> B</td>
                    <td width="300">
                        <input type="text" class="text" name="personB" size="40" READONLY>
                        <input class="button" type="button" value="<%=getTran("Web","select",sWebLanguage)%>" onclick="showSearchPatientPopup('pid2','personB');">&nbsp;
                    </td>

                    <%-- BUTTONS --%>
                    <td>
                        <input type="button" class="button" value="<%=getTran("web.manage","merge",sWebLanguage)%>" onclick="checkSelectedPersons();">&nbsp;
                        <input type="button" class="button" value="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearFields();">
                    </td>
                </tr>
            </table>

            <br>

            <script>
              <%-- CHECK SELECTED QUERY --%>
              function checkSelectedQuery(sAction){
                if(mergeForm.selectedFields.selectedIndex > 0){
                  mergeForm.action.value = sAction;
                  openSearchInProgressPopup();
                  mergeForm.submit();
                }
                else{
                  mergeForm.selectedFields.focus();
                }
              }

              <%-- CHECK SELECTED PERSONS --%>
              function checkSelectedPersons(){
                if(mergeForm.personA.value != "" && mergeForm.personB.value != ""){
                  if(mergeForm.pid1.value == mergeForm.pid2.value){
                    alert("<%=getTran("web.manage","selectdifferentpersons",sWebLanguage)%>");
                    mergeForm.personA.focus();
                  }
                  else{
                    mergeForm.action.value = "ShowDetails";
                    mergeForm.submit();
                  }
                }
                else{
                  if(mergeForm.personA.value == ""){
                    alert("<%=getTran("web","somefieldsareempty",sWebLanguage)%>");
                    mergeForm.personA.focus();
                  }
                  else if(mergeForm.personB.value == ""){
                    alert("<%=getTran("web","somefieldsareempty",sWebLanguage)%>");
                    mergeForm.personB.focus();
                  }
                }
              }

              <%-- CLEAR FIELDS --%>
              function clearFields(){
                mergeForm.pid1.value = "";
                mergeForm.pid2.value = "";
                mergeForm.personA.value = "";
                mergeForm.personB.value = "";
              }

              <%-- SHOW SEARCH PATIENT POPUP --%>
              function showSearchPatientPopup(pid,personName){
                window.open("<c:url value="/popup.jsp"/>?Page=_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+pid+"&ReturnName="+personName,"<%=getTran("Web","Find",sWebLanguage)%>","height=1, width=1, toolbar=no, status=no, scrollbars=no, resizable=no, menubar=no");
              }
            </script>
        <%
            }

            // todo : PROCESS DOUBLES
            //##############################################################################################
            //### Process doubles ##########################################################################
            //##############################################################################################
            if(sAction.equals("ProcessDoubles")){
                int processedDoublesCount = 0;
                String removePersonId;

                Vector personsToRemove = new Vector();
                Vector personsToKeep = new Vector();

                //*** search doubles **************************************************
                // what fields make a record "double"
                int selectedFields = Integer.parseInt(request.getParameter("selectedFields"));

                // compose query
                sbQuery.append("SELECT a1.personid, a2.personid, a1.immatnew, a2.immatnew")
                        .append(" FROM Admin a1, Admin a2 ");

                // search on immatnew
                if(selectedFields == 1){
                    sbQuery.append("WHERE a1.immatnew = a2.immatnew");
                }
                // search on searchname AND dateOfBirth
                else if(selectedFields == 2){
                    sbQuery.append("WHERE a1.searchname = a2.searchname")
                            .append(" AND a1.dateofbirth = a2.dateofbirth");
                }

                sbQuery.append(" AND a1.personid != a2.personid")
                        .append(" ORDER BY a1.searchname, a1.immatnew, a2.immatnew");

              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                ps = ad_conn.prepareStatement(sbQuery.toString());
                ResultSet rs = ps.executeQuery();

                //*** retrieve unique sets of double dossiers *************************
                String immatNew1, immatNew2, immatNewString;
                HashSet immatSet = new HashSet();
                Hashtable doubleRecords = new Hashtable();
                boolean processRow;
                Vector doubleData;

                while(rs.next()){
                    immatNew1 = checkString(rs.getString(3));
                    immatNew2 = checkString(rs.getString(4));

                    // when searching on double immatnew : immatnew's may not be empty
                    if(selectedFields == 1){
                        processRow = (immatNew1.length()>0 && immatNew2.length()>0) && immatNew1.equals(immatNew2);
                    }
                    else{
                        processRow = true;
                    }

                    if(processRow){
                        if(immatNew1.compareTo(immatNew2)<0) immatNewString = immatNew1 + "," + immatNew2;
                        else immatNewString = immatNew2 + "," + immatNew1;

                        pid1 = checkString(rs.getString(1));
                        pid2 = checkString(rs.getString(2));

                        // when searching on immatnew, personid must be added to the set-key
                        if(selectedFields == 1){
                            if(pid1.compareTo(pid2)<0) immatNewString += "," + pid1 + "," + pid2;
                            else immatNewString += "," + pid2 + "," + pid1;
                        }

                        immatSet.add(immatNewString);

                        doubleData = new Vector();
                        doubleData.add(pid1); // pid1
                        doubleData.add(pid2); // pid2

                        doubleRecords.put(immatNewString, doubleData);
                    }
                }
                rs.close();
                ps.close();
                ad_conn.close();

                //*** get unique set of double personids ******************************
                String immatString;
                Iterator immatIter = immatSet.iterator();
                while(immatIter.hasNext()){
                    immatString = (String)immatIter.next();
                    doubleData = (Vector)doubleRecords.get(immatString);

                    personsToKeep.add(doubleData.get(0)); // (String)
                    personsToRemove.add(doubleData.get(1)); // (String)
                }

                //*** process doubles *************************************************
                PersonMerger personMerger = new PersonMerger();

                for(int i = 0; i<personsToRemove.size(); i++){
                    keepPersonId = (String)personsToKeep.get(i);
                    removePersonId = (String)personsToRemove.get(i);

                    personMerger.merge(Integer.parseInt(keepPersonId), Integer.parseInt(removePersonId), true);
                    processedDoublesCount++;
                }

        %><%=processedDoublesCount%> <%=getTran("web.manage","doublesProcessed",sWebLanguage)%><%
    }
    // todo : MERGE DOUBLES
    //##############################################################################################
    //### Merge doubles (only on server) ###########################################################
    //##############################################################################################
    else if(sAction.equals("MergeDoubles")){
        PersonMerger personMerger = new PersonMerger();
        String removePersonId = (keepPersonId.equals(pid1)?pid2:pid1);
        personMerger.merge(Integer.parseInt(keepPersonId),Integer.parseInt(removePersonId),true);

        %><%=getTran("Web.manage","mergeCompleted",sWebLanguage)%><%
    }
    // todo : SEARCH DOUBLES
    //##############################################################################################
    //### Search doubles ###########################################################################
    //##############################################################################################
    else if(sAction.equals("SearchDoubles")){
        // what fields make a record "double"
        int selectedFields = Integer.parseInt(request.getParameter("selectedFields"));

        // compose query
        sbQuery.append("SELECT a1.personid, a2.personid, a1.lastname, a1.firstname, a1.dateofbirth, a1.immatnew, a2.immatnew,a1.archiveFileCode,a2.archiveFileCode")
               .append(" FROM Admin a1, Admin a2 ");

        // search on immatnew
        if(selectedFields==1){
            sbQuery.append("WHERE a1.immatnew = a2.immatnew");
        }
        // search on searchname AND dateOfBirth
        else if(selectedFields==2){
            sbQuery.append("WHERE a1.searchname = a2.searchname")
                   .append(" AND a1.dateofbirth = a2.dateofbirth");
        }

        sbQuery.append(" AND a1.personid != a2.personid")
               .append(" ORDER BY a1.searchname, a1.immatnew, a2.immatnew");

      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        ps = ad_conn.prepareStatement(sbQuery.toString());
        ResultSet rs = ps.executeQuery();

        // show double admins in html
        boolean doublesFound = false;

        %>
            <table width="100%" class="list" cellspacing="1" cellpadding="0" border="0">
                <%-- column headers --%>
                <tr class="admin">
                    <td><%=getTran("Web","name",sWebLanguage)%></td>
                    <td width="170"><%=getTran("Web","dateofbirth",sWebLanguage)%></td>
                    <td width="170"><%=getTran("Web","immatnew",sWebLanguage)%>&nbsp;<%=getTran("Web","person",sWebLanguage)%> 1</td>
                    <td width="170"><%=getTran("Web","immatnew",sWebLanguage)%>&nbsp;<%=getTran("Web","person",sWebLanguage)%> 2</td>
                </tr>

                <%-- admin records --%>
                <tbody onMouseOver='this.style.cursor="hand"' onMouseOut='this.style.cursor="default"'>
                    <%
                        //*** retrieve unique sets of double dossiers *********
                        int doubleCounter = 0;
                        String sClass = "", sLastname, sFirstname, immatNew1, immatNew2, immatNewString,arch1,arch2;
                        Hashtable doubleRecords = new Hashtable();
                        boolean processRow;
                        Vector doubleData;

                        while(rs.next()){
                            immatNew1 = checkString(rs.getString(6));
                            immatNew2 = checkString(rs.getString(7));
                            arch1=checkString(rs.getString(8));
                            if(arch1.length()>0){
                                immatNew1+=" ("+arch1+")";
                            }
                            arch2=checkString(rs.getString(9));
                            if(arch2.length()>0){
                                immatNew2+=" ("+arch2+")";
                            }

                            // when searching on double immatnew : immatnew's may not be empty
                            if(selectedFields==1){
                                processRow = (immatNew1.length() > 0 && immatNew2.length() > 0) && immatNew1.equals(immatNew2);
                            }
                            else{
                                processRow = true;
                            }

                            if(processRow){
                                if(immatNew1.compareTo(immatNew2) < 0) immatNewString = immatNew1+","+immatNew2;
                                else                                   immatNewString = immatNew2+","+immatNew1;

                                pid1 = checkString(rs.getString(1));
                                pid2 = checkString(rs.getString(2));

                                sLastname = checkString(rs.getString(3));
                                sFirstname = checkString(rs.getString(4));


                                // when searching on immatnew, personid must be added to the set-key
                                if(selectedFields==1){
                                    if(pid1.compareTo(pid2) < 0) immatNewString+= ","+pid1+","+pid2;
                                    else                         immatNewString+= ","+pid2+","+pid1;
                                }
                                else if(selectedFields==2){
                                    immatNewString+= ","+sLastname+","+sFirstname;
                                }

                                doubleData = new Vector();
                                doubleData.add(pid1);
                                doubleData.add(pid2);
                                doubleData.add(checkString(rs.getString(3))); // sLastname
                                doubleData.add(checkString(rs.getString(4))); // sFirstname
                                doubleData.add(ScreenHelper.getSQLDate(rs.getDate(5))); // sDateOfBirth
                                doubleData.add(immatNew1);
                                doubleData.add(immatNew2);

                                doubleRecords.put(immatNewString,doubleData);
                            }
                        }
                        rs.close();
                        ps.close();
                        ad_conn.close();

                        //*** display double dossiers *************************
                        String immatString;

                        // convert doubleRecords to doubleNames, to be able to sort on names
                        Vector names = new Vector();
                        HashMap immatStrings = new HashMap();

                        int nameCount = 0;
                        String key;
                        Enumeration doubleEnum = doubleRecords.keys();
                        while(doubleEnum.hasMoreElements()){
                            immatString = (String)doubleEnum.nextElement();
                            doubleData = (Vector)doubleRecords.get(immatString);

                            key = doubleData.get(2)+","+doubleData.get(3)+"_"+nameCount++;
                            names.add(key);
                            immatStrings.put(key,immatString);
                        }

                        // sort on names
                        Collections.sort(names);

                        String name;
                        for(int i=0; i<names.size(); i++){
                            doublesFound = true;

                            name = (String)names.get(i);
                            immatString = (String)immatStrings.get(name);
                            doubleData = (Vector)doubleRecords.get(immatString);

                            pid1       = checkString((String)doubleData.get(0));
                            pid2       = checkString((String)doubleData.get(1));
                            sLastname  = checkString((String)doubleData.get(2));
                            sFirstname = checkString((String)doubleData.get(3));

                            if(sFirstname.length()>0){
                                sLastname+= ", "+sFirstname;
                            }

                            // alternate row-style
                            if (sClass.equals("")) sClass = "1";
                            else                   sClass = "";

                            doubleCounter++;

                            %>
                                <tr class="list<%=sClass%>" onClick="showDetails('<%=pid1%>','<%=pid2%>');" >
                                    <td>&nbsp;<%=sLastname%></td>
                                    <td>&nbsp;<%=checkString((String)doubleData.get(4))%></td>
                                    <td>&nbsp;<%=checkString((String)doubleData.get(5))%></td>
                                    <td>&nbsp;<%=checkString((String)doubleData.get(6))%></td>
                                </tr>
                            <%
                        }
                    %>
                </tbody>

                <script>mergeForm.selectedFields.selectedIndex = <%=selectedFields%>;</script>

                <%-- no doubles found --%>
                <%
                    if(!doublesFound){
                        %>
                            <tr>
                                <td><%=getTran("web.manage","no_double_records_found",sWebLanguage)%></td>
                            </tr>
                        <%
                    }
                %>
            </table>

            <%-- info --%>
            <%
                if(doublesFound){
                    %>
                        <%=getTran("Web.manage","clickToSeePersonsDetails",sWebLanguage)%><br>
                        <%=(doubleCounter+" "+getTran("Web.manage","doublePersonsFound",sWebLanguage))%>
                    <%
                }
            %>

            <%-- BACK BUTTON --%>
            <p align="right">
                <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
            </p>

            <%
                if(doublesFound){
                    %>
                        <script>
                          function showDetails(pid1,pid2){
                            mergeForm.action.value = "ShowDetails";
                            mergeForm.pid1.value = pid1;
                            mergeForm.pid2.value = pid2;
                            mergeForm.submit();
                          }
                        </script>
                    <%
                }
            %>
        <%
        }
        // todo : SHOW DETAILS
        //##############################################################################################
        //### ShowDetails ##############################################################################
        //##############################################################################################
        else if (sAction.equals("ShowDetails")) {

            //*** add admin attribute names to array ***************************************************
            String[] personColumns = new String[40];

            personColumns[0] = getTran("web", "userid", sWebLanguage);
            personColumns[1] = getTran("web", "personid", sWebLanguage);
            personColumns[2] = getTran("web", "natreg", sWebLanguage);
            personColumns[3] = getTran("web", "immatold", sWebLanguage);
            personColumns[4] = getTran("web", "immatnew", sWebLanguage);
            personColumns[5] = getTran("web", "candidate", sWebLanguage);
            personColumns[6] = getTran("web", "lastname", sWebLanguage);
            personColumns[7] = getTran("web", "firstname", sWebLanguage);
            personColumns[8] = getTran("web", "gender", sWebLanguage);
            personColumns[9] = getTran("web", "dateofbirth", sWebLanguage);
            personColumns[10] = getTran("web", "comment", sWebLanguage);
            personColumns[11] = getTran("web", "sourceid", sWebLanguage);
            personColumns[12] = getTran("web", "language", sWebLanguage);
            personColumns[13] = getTran("web", "engagement", sWebLanguage);
            personColumns[14] = getTran("web", "pension", sWebLanguage);
            personColumns[15] = getTran("web", "statute", sWebLanguage);
            personColumns[16] = getTran("web", "claimant", sWebLanguage);
            personColumns[17] = getTran("web", "updatetime", sWebLanguage);
            personColumns[18] = getTran("web", "claimantexpiration", sWebLanguage);
            personColumns[19] = getTran("web", "nativecountry", sWebLanguage);
            personColumns[20] = getTran("web", "nativetown", sWebLanguage);
            personColumns[21] = getTran("web", "motiveendofservice", sWebLanguage);
            personColumns[22] = getTran("web", "startdateinactivity", sWebLanguage);
            personColumns[23] = getTran("web", "enddateinactivity", sWebLanguage);
            personColumns[24] = getTran("web", "codeinactivity", sWebLanguage);
            personColumns[25] = getTran("web", "updatestatus", sWebLanguage);
            personColumns[26] = getTran("web", "typeperson", sWebLanguage);
            personColumns[27] = getTran("web", "situationendofservice", sWebLanguage);
            personColumns[28] = getTran("web", "updateuserid", sWebLanguage);
            personColumns[29] = getTran("web", "comment1", sWebLanguage);
            personColumns[30] = getTran("web", "comment2", sWebLanguage);
            personColumns[31] = getTran("web", "comment3", sWebLanguage);
            personColumns[32] = getTran("web", "comment4", sWebLanguage);
            personColumns[33] = getTran("web", "comment5", sWebLanguage);
            personColumns[34] = getTran("web", "nativecountry", sWebLanguage);
            personColumns[35] = getTran("web", "middlename", sWebLanguage);
            personColumns[36] = getTran("web", "begindate", sWebLanguage);
            personColumns[37] = getTran("web", "enddate", sWebLanguage);
            personColumns[38] = getTran("web", "archivefilecode", sWebLanguage);
            personColumns[39] = getTran("web", "lastcontact", sWebLanguage);

            String[] person1Details = new String[personColumns.length];
            String[] person2Details = new String[personColumns.length];

            // get userid for person 1
            StringBuffer query = new StringBuffer();
            query.append("SELECT userid FROM Users WHERE personid = ?");
          	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            ps = ad_conn.prepareStatement(query.toString());

            ps.setInt(1, Integer.parseInt(pid1));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                person1Details[0] = checkString(rs.getString("userid"));
            } else {
                person1Details[0] = "&nbsp;";
            }
            rs.close();
            Vector encounters = Encounter.selectLastEncounters("","","","","","","","",pid1,"");
            if(encounters!=null && encounters.size()>0){
                person1Details[39] = new SimpleDateFormat("dd/MM/yyyy").format(((Encounter)encounters.elementAt(0)).getBegin());
            }
            else {
                person1Details[39]="";
            }
            encounters = Encounter.selectLastEncounters("","","","","","","","",pid2,"");
            if(encounters !=null && encounters.size()>0){
                person2Details[39] = new SimpleDateFormat("dd/MM/yyyy").format(((Encounter)encounters.elementAt(0)).getBegin());
            }
            else {
                person1Details[39]="";
            }
                    // get userid for person 2
                            ps.setInt(1, Integer.parseInt(pid2));
            rs = ps.executeQuery();
            if (rs.next()) {
                person2Details[0] = checkString(rs.getString("userid"));
            } else {
                person2Details[0] = "&nbsp;";
            }
            rs.close();
            ps.close();

            // prepare statement to get person details (every column except 'searchname')
            query = new StringBuffer();
            query.append("SELECT personid,natreg,immatold,immatnew,candidate,lastname,firstname,")
                    .append("  gender,dateofbirth,comment,sourceid,Admin.language,engagement,pension,")
                    .append("  statute,claimant,updatetime,claimant_expiration,native_country,native_town,")
                    .append("  motive_end_of_service,startdate_inactivity,enddate_inactivity,")
                    .append("  code_inactivity,update_status,person_type,situation_end_of_service,")
                    .append("  updateuserid,comment1,comment2,comment3,comment4,comment5,native_country,")
                    .append("  middlename,begindate,enddate,archivefilecode")
                    .append(" FROM Admin WHERE personid = ?");

            ps = ad_conn.prepareStatement(query.toString());

            //--- person 1 ---
            ps.setInt(1, Integer.parseInt(pid1));
            rs = ps.executeQuery();

            // add person attributes to array
            if (rs.next()) {
                for (int i = 1; i < person1Details.length; i++) {
                    if(i == 39){
                        //do nothing
                    }
                    // dates should be formatted
                    else if (i == 9 || i == 17 || i == 18 || i == 22 || i == 23 || i == 36 || i == 37) {
                        person1Details[i] = checkString(ScreenHelper.getSQLDate(rs.getDate(i)));
                    } else {
                        person1Details[i] = checkString(rs.getString(i));
                    }
                }
            }
            rs.close();

            //--- person 2 ---
            ps.setInt(1, Integer.parseInt(pid2));
            rs = ps.executeQuery();

            // add person attributes to array
            if (rs.next()) {
                for (int i = 1; i < person2Details.length; i++) {
                    if(i == 39){
                        //do nothing
                    }
                    // dates should be formatted
                    else if (i == 9 || i == 17 || i == 18 || i == 22 || i == 23 || i == 36 || i == 37) {
                        person2Details[i] = checkString(ScreenHelper.getSQLDate(rs.getDate(i)));
                    } else {
                        person2Details[i] = checkString(rs.getString(i));
                    }
                }
            }
            rs.close();
            ps.close();

            //*** add adminprivate attribute names to array ********************************************
            String value;
            String[] privateColumns = new String[15];

            privateColumns[0] = getTran("web", "privateid", sWebLanguage);
            privateColumns[1] = getTran("web", "start", sWebLanguage);
            privateColumns[2] = getTran("web", "stop", sWebLanguage);
            privateColumns[3] = getTran("web", "address", sWebLanguage);
            privateColumns[4] = getTran("web", "city", sWebLanguage);
            privateColumns[5] = getTran("web", "zipcode", sWebLanguage);
            privateColumns[6] = getTran("web", "country", sWebLanguage);
            privateColumns[7] = getTran("web", "telephone", sWebLanguage);
            privateColumns[8] = getTran("web", "fax", sWebLanguage);
            privateColumns[9] = getTran("web", "mobile", sWebLanguage);
            privateColumns[10] = getTran("web", "email", sWebLanguage);
            privateColumns[11] = getTran("web", "comment", sWebLanguage);
            privateColumns[12] = getTran("web", "updatetime", sWebLanguage);
            privateColumns[13] = getTran("web", "type", sWebLanguage);
            privateColumns[14] = getTran("web", "district", sWebLanguage);

            // prepare statement to get adminprivate details
            query = new StringBuffer();
            query.append("SELECT privateid, start, stop, address, city, zipcode, country, telephone, fax,")
                    .append("  mobile, email, comment, updatetime, type,district")
                    .append(" FROM AdminPrivate")
                    .append(" WHERE personid = ?")
                    .append("  AND stop IS NULL AND type = 'Official'");

            ps = ad_conn.prepareStatement(query.toString());

            //--- current main private of person 1 -----------------------------------------------------
            String[] private1Details = new String[privateColumns.length];
            for (int i = 0; i < private1Details.length; i++) {
                private1Details[i] = "&nbsp;";
            }
            ps.setInt(1, Integer.parseInt(pid1));
            rs = ps.executeQuery();

            // add private attributes to array
            if (rs.next()) {
                for (int i = 0; i < private1Details.length; i++) {
                    // dates should be formatted
                    if (i == 1 || i == 2 || i == 12) value = checkString(ScreenHelper.getSQLDate(rs.getDate((i + 1))));
                    else value = checkString(rs.getString((i + 1)));

                    if (value.length() > 0) private1Details[i] = value;
                }
            }
            rs.close();

            //--- current main private of person 2 -----------------------------------------------------
            String[] private2Details = new String[privateColumns.length];
            for (int i = 0; i < private2Details.length; i++) {
                private2Details[i] = "&nbsp;";
            }
            ps.setInt(1, Integer.parseInt(pid2));
            rs = ps.executeQuery();

            // add private attributes to array
            if (rs.next()) {
                for (int i = 0; i < private2Details.length; i++) {
                    // dates should be formatted
                    if (i == 1 || i == 2 || i == 12) value = checkString(ScreenHelper.getSQLDate(rs.getDate((i + 1))));
                    else value = checkString(rs.getString((i + 1)));

                    if (value.length() > 0) private2Details[i] = value;
                }
            }
            rs.close();
            ps.close();

            //*** add adminwork attribute names to array ***********************************************
            String[] workColumns = new String[15];

            workColumns[0] = getTran("web", "workid", sWebLanguage);
            workColumns[1] = getTran("web", "start", sWebLanguage);
            workColumns[2] = getTran("web", "stop", sWebLanguage);
            workColumns[3] = getTran("web", "rankid", sWebLanguage);
            workColumns[4] = getTran("web", "telephone", sWebLanguage);
            workColumns[5] = getTran("web", "fax", sWebLanguage);
            workColumns[6] = getTran("web", "email", sWebLanguage);
            workColumns[7] = getTran("web", "comment", sWebLanguage);
            workColumns[8] = getTran("web", "updatetime", sWebLanguage);
            workColumns[9] = getTran("web", "status", sWebLanguage);
            workColumns[10] = getTran("web", "statussituation", sWebLanguage);
            workColumns[11] = getTran("web", "category", sWebLanguage);
            workColumns[12] = getTran("web", "companyBegin", sWebLanguage);
            workColumns[13] = getTran("web", "companyEnd", sWebLanguage);
            workColumns[14] = getTran("web", "companyEndReason", sWebLanguage);

            // prepare statement to get adminprivate details
            query = new StringBuffer();
            query.append("SELECT workid,start,stop,rankid,telephone,fax,email,comment,updatetime,")
                    .append("  status,statussituation,category,companyBegin,companyEnd,companyEndReason")
                    .append(" FROM AdminWork")
                    .append(" WHERE personid = ? AND stop IS NULL");
            ps = ad_conn.prepareStatement(query.toString());

            //--- current work of person 1 -------------------------------------------------------------
            String[] work1Details = new String[workColumns.length];
            for (int i = 0; i < work1Details.length; i++) {
                work1Details[i] = "&nbsp;";
            }
            ps.setInt(1, Integer.parseInt(pid1));
            rs = ps.executeQuery();

            // add work attributes to array
            if (rs.next()) {
                for (int i = 0; i < work1Details.length; i++) {
                    // dates should be formatted
                    if (i == 1 || i == 2 || i == 8 || i == 12 || i == 13) {
                        value = checkString(ScreenHelper.getSQLDate(rs.getDate((i + 1))));
                    } else {
                        value = checkString(rs.getString((i + 1)));
                    }

                    if (value.length() > 0) work1Details[i] = value;
                }
            }
            rs.close();

            //--- current work of person 2 -------------------------------------------------------------
            String[] work2Details = new String[workColumns.length];
            for (int i = 0; i < work2Details.length; i++) {
                work2Details[i] = "&nbsp;";
            }
            ps.setInt(1, Integer.parseInt(pid2));
            rs = ps.executeQuery();

            // add work attributes to array
            if (rs.next()) {
                for (int i = 0; i < work2Details.length; i++) {
                    // dates should be formatted
                    if (i == 1 || i == 2 || i == 8 || i == 12 || i == 13) {
                        value = checkString(ScreenHelper.getSQLDate(rs.getDate((i + 1))));
                    } else {
                        value = checkString(rs.getString((i + 1)));
                    }

                    if (value.length() > 0) work2Details[i] = value;
                }
            }
            rs.close();
            ps.close();
            ad_conn.close();

        %>
            <%-- TITLE -------------------------------------------------------------------------------%>
            <table width="100%" class="menu" cellspacing="1" cellpadding="0" border="0">
                <tr>
                    <td><%=writeTableHeader("Web.manage","merge_persons",sWebLanguage,"main.jsp?Page=system/mergePersons.jsp")%></td>
                </tr>
            </table>

            <br>

            <%-- MAIN TABLE --------------------------------------------------------------------------%>
            <table width="100%" class="list" cellspacing="1" cellpadding="0" border="0">

                <%-- ADMIN DETAILS -------------------------------------------------------------------%>
                <tr class="admin">
                    <td colspan="3" height="21"><%=getTran("web.manage","admindetails",sWebLanguage)%></td>
                </tr>

                <%-- SELECT PERSON TO KEEP --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td>
                    <td class="admin" id="person1Header">
                        <input type="radio" name="keepPerson" id="r1" onDblClick="uncheckRadio(this);unsetSelectionColor();" value="<%=pid1%>" onClick="setSelectionColor('person1Header',this.id);"><%=getLabel("Web.manage","keepPerson",sWebLanguage,"r1")%>&nbsp;1
                    </td>
                    <td class="admin" id="person2Header">
                        <input type="radio" name="keepPerson" id="r2" onDblClick="uncheckRadio(this);unsetSelectionColor();" value="<%=pid2%>" onClick="setSelectionColor('person2Header',this.id);"><%=getLabel("Web.manage","keepPerson",sWebLanguage,"r2")%>&nbsp;2
                    </td>
                </tr>

                <%
                    for(int i=0; i<personColumns.length; i++){
                        %>
                            <tr>
                                <td class="admin"><%=personColumns[i]%></td>
                                    <%
                                    // show differences
                                    if(person1Details[i].equals(person2Details[i])){
                                        %>
                                            <td class="admin2"><%=person1Details[i]%></td>
                                            <td class="admin2"><%=person2Details[i]%></td>
                                        <%
                                    }
                                    else{
                                        %>
                                            <td class="admin2" style="color:red;"><%=person1Details[i]%></td>
                                            <td class="admin2" style="color:red;"><%=person2Details[i]%></td>
                                        <%
                                    }
                                %>
                            </tr>
                        <%
                    }
                %>

                <%-- spacer --%>
                <tr>
                    <td style="border-top:1px solid gray;border-bottom:1px solid gray;" colspan="3">&nbsp;</td>
                </tr>

                <%-- ADMINPRIVATE DETAILS ------------------------------------------------------------%>
                <tr class="admin">
                    <td colspan="3" height="21"><%=getTran("web.manage","adminprivatedetails",sWebLanguage)%></td>
                </tr>

                <%-- private columns --%>
                <% for(int i=0; i<privateColumns.length; i++){ %>
                    <tr>
                        <td class="admin" ><%=privateColumns[i]%></td>
                <%
                        if(private1Details[i].equals(private2Details[i])){
                          %>
                              <td class="admin2" ><%=private1Details[i]%></td>
                              <td class="admin2" ><%=private2Details[i]%></td>
                          <%
                        }
                        else{
                          %>
                              <td class="admin2" style="color:red;"><%=private1Details[i]%></td>
                              <td class="admin2" style="color:red;"><%=private2Details[i]%></td>
                          <%
                        }
                %>
                    </tr>
                <%
                    }
                %>

                <%-- spacer --%>
                <tr>
                    <td style="border-top:1px solid gray;border-bottom:1px solid gray;" colspan="3">&nbsp;</td>
                </tr>

                <%-- ADMINWORK DETAILS ---------------------------------------------------------------%>
                <tr class="admin">
                    <td colspan="3" height="21"><%=getTran("web.manage","adminworkdetails",sWebLanguage)%></td>
                </tr>

                    <%-- work columns --%>
                    <%
                        for(int i=0; i<workColumns.length; i++){
                            %>
                                <tr>
                                    <td class="admin"><%=workColumns[i]%></td>
                            <%
                            if(work1Details[i].equals(work2Details[i])){
                                %>
                                <td class="admin2"><%=work1Details[i]%></td>
                                <td class="admin2"><%=work2Details[i]%></td>
                                <%
                            }
                            else{
                                %>
                                <td class="admin2" style="color:red;"><%=work1Details[i]%></td>
                                <td class="admin2" style="color:red;"><%=work2Details[i]%></td>
                                <%
                            }
                            %>
                                </tr>
                            <%
                        }
                    %>
            </table>

            <%=getTran("Web.manage","datainreddiffers",sWebLanguage)%>

            <%-- BUTTONS AT BOTTOM --%>
            <p align="right">
                <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">&nbsp;
                <input class="button" type="button" value="<%=getTran("Web.manage","merge",sWebLanguage)%>" onClick="mergePersons('<%=pid1%>','<%=pid2%>');" >
            </p>

            <%-- SCRIPTS -----------------------------------------------------------------------------%>
            <script>
              <%-- UNSET SELECTION COLOR PERSONS --%>
              function unsetSelectionColor(){
                document.getElementById('person1Header').style.background = "#ddd";
                document.getElementById('person2Header').style.background = "#ddd";
              }

              <%-- SET SELECTION COLOR --%>
              function setSelectionColor(headerid,radioid){
                if(radioid=='r1'){
                  keepPerson = document.getElementById('person1Header');
                  delPerson  = document.getElementById('person2Header');
                }
                else{
                  keepPerson = document.getElementById('person2Header');
                  delPerson  = document.getElementById('person1Header');
                }

                keepPerson.style.background = "#99cc99"; // green
                delPerson.style.background  = "#ff9999"; // red
              }

              <%-- MERGE PERSONS --%>
              function mergePersons(pid1,pid2){
                var radio1 = document.getElementById('r1');
                var radio2 = document.getElementById('r2');

                if(radio1.checked || radio2.checked){
                  var keepName, delName, confirmMsg;
                  confirmMsg = '<%=getTran("Web.manage","willoverwrite",sWebLanguage)%>';

                  if(radio1.checked){
                    keepName = '<%=person1Details[4]%>';
                    delName  = '<%=person2Details[4]%>';
                  }
                  else{
                    keepName = '<%=person2Details[4]%>';
                    delName  = '<%=person1Details[4]%>';
                  }

                  <%-- set personID's --%>
                  confirmMsg = confirmMsg.replace('[personId1]','"'+pid1+'"');
                  confirmMsg = confirmMsg.replace('[personId2]','"'+pid2+'"');

                  <%-- set immatNew's --%>
                  confirmMsg = confirmMsg.replace('[immatnew1]','"'+delName+'"');
                  confirmMsg = confirmMsg.replace('[immatnew2]','"'+keepName+'"');

                  if(confirm(confirmMsg)){
                    mergeForm.action.value = "MergeDoubles";
                    mergeForm.pid1.value = pid1;
                    mergeForm.pid2.value = pid2;
                    mergeForm.submit();
                  }
                }
                else{
                  alert("<%=getTran("Web.manage","selectPersonToKeep",sWebLanguage)%>");
                }
              }
            </script>
        <%
    }
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
</form>

<script>
  <%-- close "search in progress"-popup that might still be open --%>
  var popup = window.open("","Searching","width=1,height=1");
  popup.close();

  <%-- DO CLOSE --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp&Tab=database&ts=<%=getTs()%>";
  }
</script>
