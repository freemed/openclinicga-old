<%@page import="java.util.Hashtable,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>

<%!
    //--- GET ENCLOSED FILE ID (immatnew of dossier) ----------------------------------------------
    public String getEnclosedFileId(String superFileId){
        return AdminPerson.getEnclosedFileId(superFileId);
    }
%>

<%
    String msgNames = "", msgImmatNew = "", msgNatReg = "";
    String link1Names = "", link2Names = "";
    String link1ImmatNew = "", link2ImmatNew = "";
    String link1NatReg = "", link2NatReg = "";
    String focusField = "";

    boolean doubleNamesFound = false;
    boolean doubleImmatNewFound = false;
    boolean doubleNatRegFound = false;

    if (activePatient != null) {
        // data to check on for doubles
        String sPersonID = checkString(request.getParameter("PersonID")).toUpperCase(),
               sName = checkString(request.getParameter("Lastname")).toUpperCase(),
               sFirstname = checkString(request.getParameter("Firstname")).toUpperCase(),
               sDateOfBirth = checkString(request.getParameter("DateOfBirth")),
               sImmatNew = checkString(request.getParameter("ImmatNew")).toUpperCase(),
               sNatReg = checkString(request.getParameter("NatReg")).toUpperCase();

        //--- CHECK ON DOUBLES --------------------------------------------------------------------
        if(activePatient.sourceid.equals(sServiceSourceID)){
            //#####################################################################################
            //################################## CREATE ###########################################
            //#####################################################################################
            if (sPersonID == null || sPersonID.trim().length() == 0) {
                activePatient = new AdminPerson();
                activePatient.lastname = sName.toUpperCase();
                activePatient.firstname = sFirstname.toUpperCase();
                activePatient.dateOfBirth = sDateOfBirth;
                activePatient.updateuserid = activeUser.userid;

                //*** check double patients on IMMATNEW *******************************************
                if (sImmatNew.length() > 0) {
                    String sPersonId = AdminPerson.getPersonIdByImmatnew(sImmatNew);

                    if (sPersonId!=null) {
                        doubleImmatNewFound = true;

                        // double message
                        msgImmatNew = "<font color='red'>" +
                                getTran("Web.PatientEdit", "patient.exists", sWebLanguage) + " " + getTran("web", "immatnew", sWebLanguage) +
                                ". (" + sImmatNew + ")" +
                                "</font>" +
                                "<br><br>";

                        // click to open existing patient
                        link1ImmatNew = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:showExistingPatient(" + sPersonId + ");'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.open.fiche", sWebLanguage) + "<br><br>";

                        // click to open existing patient in new window
                        link1ImmatNew += getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:showExistingPatientInNewWindow(" + sPersonId + ");'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.open.fiche.innewwindow", sWebLanguage) + "<br><br>";

                        // creation impossible
                        link2ImmatNew = getTran("Web.PatientEdit", "patient.creation.impossible", sWebLanguage);
                    }
                }

                //*** check double patients on NATREG *********************************************
                if (sNatReg.length() > 0) {
                    String sPersonId = AdminPerson.getPersonIdByNatReg(sNatReg);

                    if (sPersonId!=null) {
                        doubleNatRegFound = true;

                        // double message
                        msgNatReg = "<font color='red'>" +
                                getTran("Web.PatientEdit", "patient.exists", sWebLanguage) + " " + getTran("web", "natreg", sWebLanguage) + "." +
                                "<br>(" + sNatReg + ")" +
                                "</font>" +
                                "<br><br>";

                        // click to open existing patient
                        link1NatReg = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:showExistingPatient(" + sPersonId + ");'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.open.fiche", sWebLanguage) + "<br><br>";

                        // click to open existing patient in new window
                        link1NatReg += getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:showExistingPatientinNewWindow(" + sPersonId + ");'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.open.fiche.innewwindow", sWebLanguage) + "<br><br>";

                        // click to create double patient
                        link2NatReg = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:doSave();'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.create.fiche", sWebLanguage);
                    }
                }

                //*** check names and birthdate ***************************************************
                Hashtable hSelect = new Hashtable();

                if (sName.length() > 0) hSelect.put(" searchname = ? AND", sName + "," + sFirstname);
                if (sDateOfBirth.length() > 0) hSelect.put(" dateofbirth = ? AND", sDateOfBirth);

                // prepare query
                if (hSelect.size() > 0) {
                    String sPersonId = AdminPerson.getPersonIdBySearchNameDateofBirth(hSelect);

                    if (sPersonId!=null) {
                        doubleNamesFound = true;

                        // double melding
                        msgNames = "<font color='red'>" +
                                getTran("Web.PatientEdit", "patient.exists.mv", sWebLanguage) + " " + getTran("Web", "lastname", sWebLanguage) + ", " + getTran("Web", "firstname", sWebLanguage) + ", " + getTran("Web", "dateofbirth", sWebLanguage) + "." +
                                "<br>(" + sName + ", " + sFirstname + ", " + sDateOfBirth + ")" +
                                "</font>" +
                                "<br><br>";

                        // click to open existing patient
                        link1Names = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:showExistingPatient(" + sPersonId + ");'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.open.fiche", sWebLanguage) + "<br><br>";

                        // click to open existing patient in new window
                        link1Names += getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:showExistingPatientInNewWindow(" + sPersonId + ");'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.open.fiche.innewwindow", sWebLanguage) + "<br><br>";

                        // click to create double patient
                        link2Names = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                " <a href='javascript:doSave();'> " +
                                getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                getTran("Web.PatientEdit", "patient.create.fiche", sWebLanguage);
                    }
                }
            }
            //#####################################################################################
            //#################################### UPDATE #########################################
            //#####################################################################################
            else {
                //*** check double patients on IMMATNEW *******************************************
                // only perform check when data to save different than saved data
                if (!sImmatNew.equals(activePatient.getID("ImmatNew"))) {
                    if (sImmatNew.length() > 0) {
                        // get ids of enclosed files
                        Vector enclosedFileIds = new Vector();
                        String fileId = getEnclosedFileId(sImmatNew);
                        while (fileId.length() > 0) {
                            enclosedFileIds.add(fileId);
                            fileId = getEnclosedFileId(fileId);
                        }

                        // get ids of double files
                        Vector vData = AdminPerson.getImmatNewPersonIdByImmatNew(sImmatNew);
                        Iterator vDataIterator = vData.iterator();

                        Vector doubleFileIds = new Vector();
                        Hashtable personIds = new Hashtable();
                        Hashtable hData;
                        while (vDataIterator.hasNext()) {
                            hData = (Hashtable)vDataIterator.next();
                            fileId = (String)hData.get("immatnew");
                            doubleFileIds.add(fileId);
                            personIds.put(fileId, hData.get("personid"));
                        }

                        // remove enclosedFiles from doubleFiles
                        if (doubleFileIds.size() > 0) {
                            doubleFileIds.removeAll(enclosedFileIds);
                        }

                        // run thru remaining doubles
                        int doubleCounter = 0;
                        for (int i = 0; i < doubleFileIds.size() && doubleCounter < 2; i++) {
                            doubleCounter++;

                            fileId = (String) doubleFileIds.get(i);
                            String existingPersonID = (String) personIds.get(fileId);
                            if (!sPersonID.equals(existingPersonID)) {
                                doubleImmatNewFound = true;

                                // double message
                                msgImmatNew = "<font color='red'>" +
                                        getTran("Web.PatientEdit", "patient.exists", sWebLanguage) + " " + getTran("Web", "immatnew", sWebLanguage) + "." +
                                        "<br>(" + fileId + ")" +
                                        "</font>" +
                                        "<br><br>";

                                // click to open existing patient
                                link1ImmatNew = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:showExistingPatient(" + existingPersonID + ");'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.open.fiche", sWebLanguage) + "<br><br>";

                                // click to open existing patient in new window
                                link1ImmatNew += getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:showExistingPatientInNewWindow(" + existingPersonID + ");'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.open.fiche.innewwindow", sWebLanguage) + "<br><br>";

                                // creation impossible
                                link2ImmatNew = getTran("Web.PatientEdit", "patient.creation.impossible", sWebLanguage);
                            }
                        }
                    }
                }

                //*** check double patients on NATREG *********************************************
                // only perform check when data to save different than saved data
                if (!sNatReg.equals(activePatient.getID("NatReg"))) {
                    if (sNatReg.length() > 0) {
                        // get ids of enclosed files
                        Vector enclosedFileIds = new Vector();
                        String fileId = getEnclosedFileId(sImmatNew);
                        while (fileId.length() > 0) {
                            enclosedFileIds.add(fileId);
                            fileId = getEnclosedFileId(fileId);
                        }

                        // get ids of double files
                        Vector vData = AdminPerson.getImmatNewPersonIdByNatReg(sNatReg);
                        Iterator vDataIterator = vData.iterator();

                        Vector doubleFileIds = new Vector();
                        Hashtable personIds = new Hashtable();
                        Hashtable hData;
                        while (vDataIterator.hasNext()) {
                            hData = (Hashtable)vDataIterator.next();
                            fileId = (String)hData.get("immatnew");
                            doubleFileIds.add(fileId);
                            personIds.put(fileId, hData.get("personid"));
                        }

                        // remove enclosedFiles from doubleFiles
                        if (doubleFileIds.size() > 0) {
                            doubleFileIds.removeAll(enclosedFileIds);
                        }

                        // run thru remaining doubles
                        int doubleCounter = 0;
                        for (int i = 0; i < doubleFileIds.size() && doubleCounter < 2; i++) {
                            doubleCounter++;

                            fileId = (String) doubleFileIds.get(i);
                            String existingPersonID = (String) personIds.get(fileId);
                            if (!sPersonID.equals(existingPersonID)) {
                                doubleNatRegFound = true;

                                // double message
                                msgNatReg = "<font color='red'>" +
                                        getTran("Web.PatientEdit", "patient.exists", sWebLanguage) + " " + getTran("Web", "natreg", sWebLanguage) + "." +
                                        "<br>(" + fileId + " : " + sNatReg + ")" +
                                        "</font>" +
                                        "<br><br>";

                                // click to open existing patient
                                link1NatReg = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:showExistingPatient(" + existingPersonID + ");'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.open.fiche", sWebLanguage) + "<br><br>";

                                // click to open existing patient in new window
                                link1NatReg += getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:showExistingPatientInNewWindow(" + existingPersonID + ");'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.open.fiche.innewwindow", sWebLanguage) + "<br><br>";

                                // click to update patient
                                link2NatReg = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:doSave();'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.update.fiche", sWebLanguage);
                            }
                        }
                    }
                }

                //*** check names and birthdate ***************************************************
                Hashtable hSelect = new Hashtable();

                // only perform check when data to save different than saved data
                if (!sName.equals(activePatient.lastname) && !sDateOfBirth.equals(activePatient.dateOfBirth)) {
                    if (sName.length() > 0) hSelect.put(" searchname = ? AND", sName + "," + sFirstname);
                    if (sDateOfBirth.length() > 0) hSelect.put(" dateofbirth = ? AND", sDateOfBirth);

                    // prepare query
                    if (hSelect.size() > 0) {
                        Vector vData = AdminPerson.getImmatNewPersonIdBySearchNameDateofBirth(hSelect);
                        Iterator vDataIterator = vData.iterator();

                        // get ids of enclosed files
                        Vector enclosedFileIds = new Vector();
                        String fileId = getEnclosedFileId(sImmatNew);
                        while (fileId.length() > 0) {
                            enclosedFileIds.add(fileId);
                            fileId = getEnclosedFileId(fileId);
                        }

                        Vector doubleFileIds = new Vector();
                        Hashtable personIds = new Hashtable();
                        Hashtable hData;
                        while (vDataIterator.hasNext()) {
                            hData = (Hashtable)vDataIterator.next();
                            fileId = (String)hData.get("immatnew");
                            doubleFileIds.add(fileId);
                            personIds.put(fileId, hData.get("personid"));
                        }

                        // close DB-stuff
                        //if (rs != null) rs.close();
                        //if (ps != null) ps.close();

                        // remove enclosedFiles from doubleFiles
                        if (doubleFileIds.size() > 0) {
                            doubleFileIds.removeAll(enclosedFileIds);
                        }

                        // run thru remaining doubles
                        int doubleCounter = 0;
                        for (int i = 0; i < doubleFileIds.size() && doubleCounter < 2; i++) {
                            doubleCounter++;

                            fileId = (String) doubleFileIds.get(i);
                            String existingPersonID = (String) personIds.get(fileId);
                            if (!sPersonID.equals(existingPersonID)) {
                                doubleNamesFound = true;

                                // double melding
                                msgNames = "<font color='red'>" +
                                        getTran("Web.PatientEdit", "patient.exists.mv", sWebLanguage) + " " + getTran("Web", "lastname", sWebLanguage) + ", " + getTran("Web", "firstname", sWebLanguage) + ", " + getTran("Web", "dateofbirth", sWebLanguage) + "." +
                                        "<br>(" + fileId + " : " + sName + ", " + sFirstname + ", " + sDateOfBirth + ")" +
                                        "</font>" +
                                        "<br><br>";

                                // click to open existing patient
                                link1Names = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:showExistingPatient(" + existingPersonID + ");'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.open.fiche", sWebLanguage) + "<br><br>";

                                // click to open existing patient in new window
                                link1Names += getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:showExistingPatientInNewWindow(" + existingPersonID + ");'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.open.fiche.innewwindow", sWebLanguage) + "<br><br>";

                                // click to update patient
                                link2Names = getTran("Web.PatientEdit", "click", sWebLanguage) +
                                        " <a href='javascript:doSave();'> " +
                                        getTran("Web.PatientEdit", "here", sWebLanguage) + "</a> " +
                                        getTran("Web.PatientEdit", "patient.update.fiche", sWebLanguage);
                            }
                        }
                    }
                }
            }
        }
    }
        // [display double-message] OR save data
        if (doubleNamesFound || doubleImmatNewFound || doubleNatRegFound){
            %>
                <p style='padding:15px;'>
                    <%
                        int popupHeight = 0;
                        if(doubleImmatNewFound){
                            popupHeight = 130;
                            focusField = "ImmatNew";
                            %>
                                <%=msgImmatNew%>
                                <%=link1ImmatNew%>
                                <%=link2ImmatNew%>
                                <br>
                            <%
                        }
                        else{
                            if(doubleNamesFound){
                                popupHeight = 145;
                                focusField = "Lastname";
                                %>
                                    <%=msgNames%>
                                    <%=link1Names%>
                                    <%=link2Names%>
                                    <br>
                                <%
                            }

                            if(doubleNatRegFound){
                                if(popupHeight==0){
                                    popupHeight = 130;
                                }
                                else{
                                    popupHeight+= 50;
                                    %><br><%
                                }
                                focusField = "NatReg";
                                %>
                                    <%=msgNatReg%>
                                    <%=link1NatReg%>
                                    <%=link2NatReg%>
                                    <br>
                                <%
                            }
                        }
                    %>

                    <%-- CLOSE BUTTON --%>
                    <div align="center">
                        <input type="button" class="button" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="closeWindow();">
                    </div>
                </p>

                <script>
                  window.resizeTo(550,<%=popupHeight%>+50);

                  function showExistingPatient(personID){
                    window.opener.location.href = "<c:url value='/patientdata.do'/>?personid="+personID+"&ts=<%=getTs()%>";
                    window.close();
                  }

                  function showExistingPatientInNewWindow(personID){
                    window.open("<c:url value='/patientdata.do'/>?personid="+personID+"&ts=<%=getTs()%>","details","toolbar=yes, status=yes, scrollbars=yes, resizable=yes, menubar=yes, width=850, height=650");
                    window.close();
                  }

                  function doSave(){
                    window.opener.doSubmit();
                    window.close();
                  }

                  function closeWindow(){
                    window.opener.activateTab("Admin");
                    window.opener.PatientEditForm.<%=focusField%>.focus();
                    window.close();
                  }
                </script>
            <%
        }
        // display double-message OR [save data]
        else {
            out.print("<script>window.opener.doSubmit();window.close();</script>");
            out.flush();
        }
    %>
