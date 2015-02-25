<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.util.Vector,
                java.util.StringTokenizer"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%
    String sReturn = "<font color=red>"+getTran("Web.PatientEdit", "DBError", sWebLanguage)+"</font><br><br>";
    boolean bReturn = true;

    String tab = checkString(request.getParameter("Tab"));
    if (tab.equals("")) tab = "Admin";

    if (activePatient != null && request.getParameter("SavePatientEditForm") != null) {
        // admin
        String sName = checkString(request.getParameter("Lastname")),
               sFirstname = checkString(request.getParameter("Firstname")),
               sDateOfBirth = checkString(request.getParameter("DateOfBirth")),
               sImmatNew = checkString(request.getParameter("ImmatNew")), // Bedrijfs nr
               sArchiveFileCode = checkString(request.getParameter("archiveFileCode")),
               sNatReg = checkString(request.getParameter("NatReg")),
               sLanguage = checkString(request.getParameter("Language")),
               sGender = checkString(request.getParameter("Gender")),
               sNativeCountry = checkString(request.getParameter("NativeCountry")),
               sNativeTown = checkString(request.getParameter("NativeTown")),
               sComment = checkString(request.getParameter("Comment")),
               sComment3 = checkString(request.getParameter("Comment3")),
               sComment4 = checkString(request.getParameter("Comment4")),
               sComment5 = checkString(request.getParameter("Comment5")),
               sMiddleName = checkString(request.getParameter("MiddleName")),
               sComment1 = checkString(request.getParameter("Comment1")),
               sCivilStatus = checkString(request.getParameter("CivilStatus")),
               sTracnetID = checkString(request.getParameter("TracnetID")),
               sVip = checkString(request.getParameter("Vip")),
               sFatherName = checkString(request.getParameter("FatherName")),
               sFatherProfession = checkString(request.getParameter("FatherProfession")),
               sFatherEmployer = checkString(request.getParameter("FatherEmployer")),
           	   sMotherName = checkString(request.getParameter("MotherName")),
  		       sMotherProfession = checkString(request.getParameter("MotherProfession")),
  			   sMotherEmployer = checkString(request.getParameter("MotherEmployer")), 				
          	   sSpouseName = checkString(request.getParameter("SpouseName")),
 			   sSpouseProfession = checkString(request.getParameter("SpouseProfession")),
 			   sSpouseEmployer = checkString(request.getParameter("SpouseEmployer")), 				
               sExport = checkString(request.getParameter("datacenterpatientexport")),
		       sDeathCertificateOn = checkString(request.getParameter("DeathCertificateOn")),
		       sUpdateTime = checkString(request.getParameter("UpdateTime")),
		       sDeathCertificateTo = checkString(request.getParameter("DeathCertificateTo"));
        
       String sCenterreasons="";
       String[] reasons = request.getParameterValues("centerreason");
       if(reasons!=null){
	       for(int n=0;n<reasons.length;n++){
	    	   if(n>0){
	    		   sCenterreasons+=";";
	    	   }
	    	   sCenterreasons+=reasons[n];
	       }
       }

        // private
        String sPBegin = checkString(request.getParameter("PBegin")),
               sPAddress = checkString(request.getParameter("PAddress")),
               sPZipcode = checkString(request.getParameter("PZipcode")),
               sPCity = checkString(request.getParameter("PCity")),
               sPCountry = checkString(request.getParameter("PCountry")),
               sPComment = checkString(request.getParameter("PComment")),
               sPTelephone = checkString(request.getParameter("PTelephone")),
               sPFax = checkString(request.getParameter("PFax")),
               sPEmail = checkString(request.getParameter("PEmail")),
               sPMobile = checkString(request.getParameter("PMobile")),
               sPDistrict = checkString(request.getParameter("PDistrict")),
               sPSanitaryDistrict = checkString(request.getParameter("PSanitaryDistrict")),
               sPProvince = checkString(request.getParameter("PProvince")),
               sPSector = checkString(request.getParameter("PSector")),
               sPCell = checkString(request.getParameter("PCell")),
               sPFunction = checkString(request.getParameter("PFunction")),
               sPBusiness = checkString(request.getParameter("PBusiness")),
               sPQuarter = checkString(request.getParameter("PQuarter"));

        // private
        String sSCovered = checkString(request.getParameter("SCovered")),
               sSEnterprise = checkString(request.getParameter("SEnterprise")),
               sSAssurancenumber = checkString(request.getParameter("SAssurancenumber")),
               sSAssurancetype = checkString(request.getParameter("SAssurancetype")),
               sSStart = checkString(request.getParameter("SStart")),
               sSStop = checkString(request.getParameter("SStop")),
               sSComment = checkString(request.getParameter("SComment"));

        // resource
        String sRCategory = checkString(request.getParameter("RCategory")),
               sRStatut = checkString(request.getParameter("RStatut")),
		       sRGroup = checkString(request.getParameter("RGroup"));
        
        /// DEBUG /////////////////////////////////////////////////////////////////////////////////
        if(Debug.enabled){
	        Debug.println("\n**************** _common/patient/patientEditSave.jsp ***************");
	        Debug.println("sName        : "+sName);
	        Debug.println("sFirstname   : "+sFirstname);
	        Debug.println("sDateOfBirth : "+sDateOfBirth);
	        Debug.println("sImmatNew    : "+sImmatNew);
	        Debug.println("sNatReg      : "+sNatReg+"\n");
        }
        ///////////////////////////////////////////////////////////////////////////////////////////          

        //--- SAVE ---------------------------------------------------------------------------------
        if (bReturn) {
			try{
            AdminPrivateContact apc = ScreenHelper.getActivePrivate(activePatient);
            if (apc == null) {
                apc = new AdminPrivateContact();
                apc.begin = getDate();
                apc.country = sDefaultCountry;
            }

            String sPersonID = activePatient.personid;

            activePatient = new AdminPerson();
            activePatient.lastname = sName.trim().toUpperCase();
            activePatient.firstname = sFirstname.trim().toUpperCase();
            activePatient.dateOfBirth = sDateOfBirth.trim();
            activePatient.updateuserid = activeUser.userid;
            activePatient.nativeCountry = sNativeCountry;
            activePatient.nativeTown = sNativeTown;
            AdminID aID;
			if(sUpdateTime.length()>0){
				try{
					activePatient.modifyTime=ScreenHelper.parseDate(sUpdateTime);
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
            if (sImmatNew.trim().length() > 0) {
                aID = new AdminID("ImmatNew", sImmatNew.toUpperCase());
                activePatient.ids.add(aID);
            }
            if (sArchiveFileCode.trim().length() > 0) {
                aID = new AdminID("archiveFileCode", sArchiveFileCode);
                activePatient.ids.add(aID);
            }
            if (sNatReg.trim().length() > 0) {
                aID = new AdminID("NatReg", sNatReg);
                activePatient.ids.add(aID);
            }
            if (sTracnetID.trim().length() > 0) {
                activePatient.adminextends.put("tracnetid", sTracnetID);
            }
            if(checkString(request.getParameter("FatherProfession")).length()>0){
                activePatient.adminextends.put("fatherprofession", request.getParameter("FatherProfession"));
            }
            if(checkString(request.getParameter("MotherProfession")).length()>0){
                activePatient.adminextends.put("motherprofession", request.getParameter("MotherProfession"));
            }
            if(checkString(request.getParameter("FatherStudy")).length()>0){
                activePatient.adminextends.put("fatherstudy", request.getParameter("FatherStudy"));
            }
            if(checkString(request.getParameter("MotherStudy")).length()>0){
                activePatient.adminextends.put("motherstudy", request.getParameter("MotherStudy"));
            }

            if (sDeathCertificateOn.trim().length() > 0) {
                activePatient.adminextends.put("deathcertificateon", sDeathCertificateOn);
            }

            if (sDeathCertificateTo.trim().length() > 0) {
                activePatient.adminextends.put("deathcertificateto", sDeathCertificateTo);
            }

            activePatient.language = sLanguage.toUpperCase();
            activePatient.gender = sGender.toUpperCase();
            activePatient.sourceid = sServiceSourceID;
            activePatient.comment = sComment;
            activePatient.comment1 = sComment1;
            activePatient.comment2 = sCivilStatus;
            activePatient.comment3 = sComment3;
            activePatient.comment4 = sComment4;
            activePatient.comment5 = sComment5;
            activePatient.adminextends.put("vip",sVip);
            activePatient.middlename=sMiddleName;
            if (sFatherName.trim().length() > 0) {
                activePatient.adminextends.put("fathername", sFatherName);
            }
            if (sFatherProfession.trim().length() > 0) {
                activePatient.adminextends.put("fatherprofession", sFatherProfession);
            }
            if (sFatherEmployer.trim().length() > 0) {
                activePatient.adminextends.put("fatheremployer", sFatherEmployer);
            }
            if (sMotherName.trim().length() > 0) {
                activePatient.adminextends.put("mothername", sMotherName);
            }
            if (sMotherProfession.trim().length() > 0) {
                activePatient.adminextends.put("motherprofession", sMotherProfession);
            }
            if (sMotherEmployer.trim().length() > 0) {
                activePatient.adminextends.put("motheremployer", sMotherEmployer);
            }
            if (sSpouseName.trim().length() > 0) {
                activePatient.adminextends.put("spousename", sSpouseName);
            }
            if (sSpouseProfession.trim().length() > 0) {
                activePatient.adminextends.put("spouseprofession", sSpouseProfession);
            }
            if (sSpouseEmployer.trim().length() > 0) {
                activePatient.adminextends.put("spouseemployer", sSpouseEmployer);
            }
            if (sCenterreasons.trim().length() > 0) {
                activePatient.adminextends.put("centerreasons", sCenterreasons);
            }

            //*** PRIVATE ***
            AdminPrivateContact apcNew = new AdminPrivateContact();
            apcNew.begin = sPBegin;
            apcNew.telephone = sPTelephone;
            apcNew.fax = sPFax;
            apcNew.email = sPEmail;
            apcNew.mobile = sPMobile;
            apcNew.address = sPAddress.toUpperCase();
            apcNew.zipcode = sPZipcode.toUpperCase();
            apcNew.city = sPCity.toUpperCase();
            apcNew.country = sPCountry.toUpperCase();
            apcNew.comment = sPComment;
            apcNew.district = sPDistrict;
            apcNew.sanitarydistrict = sPSanitaryDistrict;
            apcNew.province = sPProvince;
            apcNew.sector = sPSector;
            apcNew.cell = sPCell;
            apcNew.quarter = sPQuarter;
            apcNew.businessfunction = sPFunction;
            apcNew.business = sPBusiness;
            activePatient.privateContacts.add(apcNew);

            //*** FAMILY RELATION ***
            AdminFamilyRelation afrNew;
            String savedFamilyRelations = checkString(request.getParameter("familyRelations"));
            StringTokenizer tokenizer = new StringTokenizer(savedFamilyRelations, "$");

            String token;
            activePatient.familyRelations = new Vector(); // clear all relations
            while (tokenizer.hasMoreTokens()) {
                token = tokenizer.nextToken();

                afrNew = new AdminFamilyRelation();
                afrNew.sourceId = token.split("\\£")[0];
                afrNew.destinationId = token.split("\\£")[1];
                afrNew.relationType = token.split("\\£")[2];

                activePatient.familyRelations.add(afrNew);
            }

            //*** RESOURCE ***
            if (sRCategory.length()>0){
                activePatient.adminextends.put("category",sRCategory);
            }
            else {
                activePatient.adminextends.remove("category");
            }

            if (sRStatut.length()>0){
                activePatient.adminextends.put("statut",sRStatut);
            }
            else {
                activePatient.adminextends.remove("statut");
            }

            if (sRGroup.length()>0){
                activePatient.adminextends.put("usergroup",sRGroup);
            }
            else {
                activePatient.adminextends.remove("usergroup");
            }

            //################################ CREATE ##########################################
            if (sPersonID == null || sPersonID.trim().length()==0){
                if (activePatient.saveToDB(checkString((String)session.getAttribute("activeMedicalCenter")),
                		                   checkString((String)session.getAttribute("activeMD")),
                		                   checkString((String)session.getAttribute("activePara")))){
                    // nothing
                }
                else {
                    // error
                    bReturn = false;
                }
            }
            //################################ UPDATE ##########################################
            else{
                activePatient.personid = sPersonID;
                activePatient.updateuserid = activeUser.userid;

                if(activePatient.saveToDB(checkString((String)session.getAttribute("activeMedicalCenter")),
                		                  checkString((String)session.getAttribute("activeMD")),
                		                  checkString((String)session.getAttribute("activePara")))){
                    // update patient in session
                    activePatient = new AdminPerson();
                    activePatient.initialize(sPersonID);
                    session.setAttribute("activePatient", activePatient);
                }
                else {
                    // error
                    bReturn = false;
                }
            }
          	activePatient.setExportRequest(sExport.equalsIgnoreCase("1"));
			}
			catch(Exception e){
				e.printStackTrace();
			}
        }
    }
    
    //*** display saved data OR display errormessage ***********************************************
    if(bReturn){
        String sNextPage = checkString(request.getParameter("NextPage"));

        if(sNextPage.length()==0){
            out.print("<script>window.location.href='"+sCONTEXTPATH+"/patientdata.do?Tab="+tab+"&personid="+activePatient.personid+"&ts="+getTs()+"'</script>");
        }
        else{
            %><script>window.location.href="<c:url value='/main.do'/>?Page=<%=sNextPage%>&personid=<%=activePatient.personid%>";</script><%
        }
    }
    else{
        out.print(sReturn);
    }
%>