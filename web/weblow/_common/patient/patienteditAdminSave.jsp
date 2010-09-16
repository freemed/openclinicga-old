<%@page errorPage="/includes/error.jsp"%>
<%@page import="be.mxs.common.util.system.Mail"%>
<%@ page import="java.util.Hashtable" %>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%
    String tab = checkString(request.getParameter("Tab"));
    if (tab.equals("")) tab = "Admin";

    if ((activePatient != null) && (request.getParameter("SavePatientEditForm") != null)) {
        String sName = checkString(request.getParameter("Name")),
                sFirstname = checkString(request.getParameter("Firstname")),
                sDateOfBirth = checkString(request.getParameter("DateOfBirth")),
                sImmatNew = checkString(request.getParameter("ImmatNew")),
                sImmatOld = checkString(request.getParameter("ImmatOld")),
                sArchiveFileCode = checkString(request.getParameter("archiveFileCode")),
                sNatReg = checkString(request.getParameter("NatReg")),
                sLanguage = checkString(request.getParameter("Language")),
                sGender = checkString(request.getParameter("Gender")),
                sStatute = checkString(request.getParameter("Statute")),
                sCandidate = checkString(request.getParameter("Candidate")),
                sEngagement = checkString(request.getParameter("Engagement")),
                sPension = checkString(request.getParameter("Pension")),
                sClaimant = checkString(request.getParameter("Claimant")),
                sClaimantExpiration = checkString(request.getParameter("ClaimantExpiration")),
                sNativeCountry = checkString(request.getParameter("NativeCountry")),
                sNativeTown = checkString(request.getParameter("NativeTown")),
                sComment = checkString(request.getParameter("Comment")),
                sComment1 = checkString(request.getParameter("Comment1")),
                sComment2 = checkString(request.getParameter("Comment2")),
                sComment3 = checkString(request.getParameter("Comment3")),
                sComment4 = checkString(request.getParameter("Comment4")),
                sComment5 = checkString(request.getParameter("Comment5"));

//SAVE
        String sPersonID = activePatient.personid;
        String sReturn = ("<font color=red>" + getTran("Web.PatientEdit", "DBError", sWebLanguage) + "</font><br><br>");
        boolean bReturn = true;
        //SOURCE=DPMS

        if (activePatient.sourceid.equals(sServiceSourceID)) {
            activePatient = new AdminPerson();
            activePatient.lastname = sName.trim().toUpperCase();
            activePatient.firstname = sFirstname.trim().toUpperCase();
            activePatient.dateOfBirth = sDateOfBirth.trim();
            activePatient.updateuserid = activeUser.userid;
            AdminID aID;

            if (sImmatNew.trim().length() > 0) {
                aID = new AdminID("ImmatNew", sImmatNew);
                activePatient.ids.add(aID);
            }
            if (sImmatOld.trim().length() > 0) {
                aID = new AdminID("ImmatOld", sImmatOld);
                activePatient.ids.add(aID);
            }
            if (sNatReg.trim().length() > 0) {
                aID = new AdminID("NatReg", sNatReg);
                activePatient.ids.add(aID);
            }
            if (sNatReg.trim().length() > 0) {
                aID = new AdminID("Candidate", sCandidate);
                activePatient.ids.add(aID);
            }
            if (sArchiveFileCode.trim().length() > 0) {
                aID = new AdminID("archiveFileCode", sArchiveFileCode);
                activePatient.ids.add(aID);
            }

            activePatient.language = sLanguage.toUpperCase();
            activePatient.gender = sGender.toUpperCase();
            activePatient.statute = sStatute.toUpperCase();
            if (sCandidate.trim().length() > 0) {
                aID = new AdminID("Candidate", sCandidate);
                activePatient.ids.add(aID);
            }

            activePatient.engagement = sEngagement.toUpperCase();
            activePatient.pension = sPension.toUpperCase();
            //activePatient.source = "DPMS";
            activePatient.sourceid = sServiceSourceID;
            activePatient.claimant = sClaimant.toUpperCase();
            activePatient.claimantExpiration = sClaimantExpiration.toUpperCase();
            activePatient.nativeCountry = sNativeCountry;
            activePatient.nativeTown = sNativeTown;
            activePatient.comment = sComment;
            activePatient.comment1 = sComment1;
            activePatient.comment2 = sComment2;
            activePatient.comment3 = sComment3;
            activePatient.comment4 = sComment4;
            activePatient.comment5 = sComment5;

            /*Enumeration eExtends = request.getParameterNames();
          String sParamName, sParamValue;
          while (eExtends.hasMoreElements()){
             sParamName = (String)eExtends.nextElement();
             if (sParamName.startsWith("Extend")){
                 sParamValue = checkString(request.getParameter(sParamName));
                 if (sParamValue.length()>0){
                     sParamName = sParamName.substring(6);
                     activePatient.adminextends.put(sParamName.toLowerCase(),sParamValue);
                 }
             }
          }  */
            if (activePatient.personid.length() > 0) {
                sReturn += ("<a href='" + sCONTEXTPATH + "patientdata.do?Tab=" + tab + "&ts=" + getTs() + "'>" +
                        getTran("Web.PatientEdit", "GoToPatientData", sWebLanguage) + "</a>");
            }
            if ((sPersonID == null) || (sPersonID.trim().length() == 0)) {
                //check doubles
                Hashtable hSelect = new Hashtable();

                if (sImmatNew.length() > 0) {
                    hSelect.put(" immatnew = ? OR", sImmatNew);
                }
                if (sNatReg.length() > 0) {
                    hSelect.put(" natreg = ? OR", sNatReg);
                }
                if (sImmatOld.length() > 0) {
                    hSelect.put(" immatold = ? OR", sImmatOld);
                }
                if (hSelect.size() > 0) {
                    Hashtable hResults = AdminPerson.checkDoublesByOR(hSelect, "");
                    if (((String) hResults.get("personid")).length() > 0) {
                        sReturn = (getTran("Web.PatientEdit", "PatientNumberExists.A", sWebLanguage)
                                + " <a href='" + sCONTEXTPATH + "/patientdata.do?Tab=" + tab + "&personid=" + ((String) hResults.get("personid")) + "&ts=" + getTs()
                                + "'>" + ((String) hResults.get("lastname")) + " " + ((String) hResults.get("firstname")) + ", "
                                + ((String) hResults.get("dateofbirth"))
                                + "</a>.  " + getTran("Web.PatientEdit", "PatientNumberExists.B", sWebLanguage) + ".");
                        bReturn = false;
                    }
                }
                if (bReturn) {
                    //not found so check name
                    hSelect = new Hashtable();
                    // lastname
                    if (sName.length() > 0) {
                        hSelect.put(" lastname = ? AND", sName);
                    }

                    if (sFirstname.length() > 0) {
                        hSelect.put(" firstname = ? AND", sFirstname);
                    }

                    if (sDateOfBirth.length() > 0) {
                        hSelect.put(" dateofbirth = ? AND", sDateOfBirth);
                    }

                    if (hSelect.size() > 0) {
                        Hashtable hResults = AdminPerson.checkDoublesByAND(hSelect);
                        if (((String) hResults.get("personid")).length() > 0) {
                            sReturn = (getTran("Web.PatientEdit", "PatientNameExists.A", sWebLanguage)
                                    + " <a href='" + sCONTEXTPATH + "/patientdata.do?Tab=" + tab + "&personid=" + ((String) hResults.get("personid")) + "&ts=" + getTs()
                                    + "'> " + getTran("Web.PatientEdit", "PatientNameExists.B", sWebLanguage)
                                    + "</a> " + getTran("Web.PatientEdit", "PatientNameExists.C", sWebLanguage));
                            bReturn = false;
                        } else {
                            //insert
					    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                            if (activePatient.saveToDB(ad_conn, checkString((String) session.getAttribute("activeMedicalCenter")), checkString((String) session.getAttribute("activeMD")), checkString((String) session.getAttribute("activePara")))) {
                                if (activePatient.workContacts.size() == 0) {
                                    AdminWorkContact awc = new AdminWorkContact();
                                    awc.begin = getDate();
                                    awc.updateuserid = activeUser.userid;
                                    awc.saveToDB(activePatient.personid, ad_conn, checkString((String) session.getAttribute("activeMedicalCenter")), checkString((String) session.getAttribute("activeMD")), checkString((String) session.getAttribute("activePara")));
                                }
                                out.print("<script>window.location.href='" + sCONTEXTPATH + "/patientdata.do?Tab=" + tab + "&personid=" + activePatient.personid + "&ts=" + getTs() + "'</script>");
                            } else {
                                //error
                                bReturn = false;
                            }
                            ad_conn.close();
                        }
                    } else {
                        //no name, firstname, dob
                        bReturn = false;
                    }
                } else {
                    //no immatnew, immatold, natreg
                    bReturn = false;
                }
            } else {
                //UPDATE
                //check doubles
                Hashtable hSelect = new Hashtable();
                // lastname
                if (sName.length() > 0) {
                    hSelect.put(" lastname = ? AND", sName);
                }
                if (sFirstname.length() > 0) {
                    hSelect.put(" firstname = ? AND", sFirstname);
                }

                if (sDateOfBirth.length() > 0) {
                    hSelect.put(" dateofbirth = ? AND", sDateOfBirth);
                }

                if (hSelect.size() > 0) {
                    Hashtable hResults = AdminPerson.checkDoublesByOR(hSelect, " AND personid <> " + sPersonID);
                    if (((String) hResults.get("personid")).length() > 0) {
                        sReturn = (getTran("Web.PatientEdit", "PatientNumberExists.A", sWebLanguage)
                                + " <a href='" + sCONTEXTPATH + "/patientdata.do?Tab=" + tab + "&personid=" + ((String) hResults.get("personid")) + "&ts=" + getTs()
                                + "'>" + ((String) hResults.get("lastname")) + " "
                                + ((String) hResults.get("firstname")) + ", "
                                + ((String) hResults.get("dateofbirth"))
                                + "</a>.  " + getTran("Web.PatientEdit", "PatientNumberExists.B", sWebLanguage) + ".");
                        bReturn = false;
                    }
                }
                if (bReturn) {
                    activePatient.personid = sPersonID;
                    activePatient.updateuserid = activeUser.userid;
                	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    if (activePatient.saveToDB(ad_conn, checkString((String) session.getAttribute("activeMedicalCenter")), checkString((String) session.getAttribute("activeMD")), checkString((String) session.getAttribute("activePara")))) {
                        if (activePatient.workContacts.size() == 0) {
                            AdminWorkContact awc = new AdminWorkContact();
                            awc.begin = getDate();
                            awc.updateuserid = activeUser.userid;
                            awc.saveToDB(activePatient.personid, ad_conn);
                        }
                        activePatient = new AdminPerson();
                        activePatient.initialize(ad_conn, sPersonID);
                        session.setAttribute("activePatient", activePatient);
                        out.print("<script>window.location.href='" + sCONTEXTPATH + "/patientdata.do?Tab=" + tab + "&personid=" + sPersonID + "&ts=" + getTs() + "'</script>");
                    } else {
                        //error
                        bReturn = false;
                    }
                    ad_conn.close();
                }
            }
            out.print(sReturn);
        } else {
            //other user
            //changes
            if (bReturn) {
                StringBuffer sChanges = new StringBuffer();
                StringBuffer sMail = new StringBuffer();

                addChange("Web", "Name", activePatient.lastname, sName, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "Firstname", activePatient.firstname, sFirstname, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "dateOfBirth", activePatient.dateOfBirth, sDateOfBirth, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "ImmatNew", activePatient.getID("immatnew"), sImmatNew, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "Immatold", activePatient.getID("immatold"), sImmatOld, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "natreg", activePatient.getID("natreg"), sNatReg, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "language", activePatient.language, sLanguage, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "gender", activePatient.gender, sGender, "", sWebLanguage, sChanges, sMail);

                if ((sStatute != null) && (sStatute.trim().length() > 0)) {
                    addChange("Web", "statute"
                            , getTran("Web", "Statute" + activePatient.statute, sWebLanguage)
                            , getTran("Web", "Statute" + sStatute, sWebLanguage), "", sWebLanguage, sChanges, sMail);
                }

                addChange("Web", "candidate", activePatient.getID("candidate"), sCandidate, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "engagement", activePatient.engagement, sEngagement, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "pension", activePatient.pension, sPension, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "claimant", activePatient.claimant, sClaimant, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "claimantexpiration", activePatient.claimantExpiration, sClaimantExpiration, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "nativecountry", activePatient.nativeCountry, sNativeCountry, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "nativetown", activePatient.nativeTown, sNativeTown, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "comment", activePatient.comment, sComment, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "comment1", activePatient.comment1, sComment1, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "comment2", activePatient.comment2, sComment2, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "comment3", activePatient.comment3, sComment3, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "comment4", activePatient.comment4, sComment4, "", sWebLanguage, sChanges, sMail);
                addChange("Web", "comment5", activePatient.comment5, sComment5, "", sWebLanguage, sChanges, sMail);

                if (sChanges.toString().trim().length() > 0) {
                    sChanges = new StringBuffer();
                    sChanges.append("<br><br>")
                            .append("<b>").append(getTran("Web", "DataSendForUpdate", sWebLanguage)).append(":</b>")
                            .append("<br><br>")
                            .append(sChanges);

                    sMail = new StringBuffer();
                    sMail.append(getTran("Web", "Name", sWebLanguage) + ": " + activePatient.lastname + "\r\n")
                            .append(getTran("Web", "Firstname", sWebLanguage) + ": " + activePatient.firstname + "\r\n")
                            .append(getTran("Web", "dateOfBirth", sWebLanguage) + ": " + activePatient.dateOfBirth + "\r\n")
                            .append(getTran("Web", "ImmatNew", sWebLanguage) + ": " + activePatient.getID("immatnew") + "\r\n")
                            .append(getTran("Web", "Immatold", sWebLanguage) + ": " + activePatient.getID("immatold") + "\r\n")
                            .append(getTran("Web", "natreg", sWebLanguage) + ": " + activePatient.getID("natreg") + "\r\n\r\n")
                            .append(sMail);
                    try {
                    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
                        Mail.sendMail(getConfigStringDB("PatientEdit.MailServer", co_conn)
                                , getConfigStringDB("PatientEdit.MailSender", co_conn)
                                , getConfigStringDB("PatientEdit.MailAddressee", co_conn), "Request Admin-update", sMail.toString());
                        co_conn.close();
                    }
                    catch (Exception e) {
                    }
                }
                activePatient = new AdminPerson();
            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                activePatient.initialize(ad_conn, sPersonID);
                ad_conn.close();
                session.setAttribute("activePatient", activePatient);

                out.print("<script>window.location.href='" + sCONTEXTPATH + "/patientdata.do?Tab=" + tab + "&personid=" + sPersonID + "&ts=" + getTs() + "'</script>");
            }
        }//source
    }
%>
