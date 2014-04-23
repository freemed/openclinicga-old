<%@include file="/mobile/_common/head.jsp"%>
<form name="searchForm" method="post">
	
<%
	String sAction = checkString(request.getParameter("action"));

	String patientpersonid    = checkString(request.getParameter("patientpersonid")),
		   patientname        = checkString(request.getParameter("patientname")),
	       patientfirstname   = checkString(request.getParameter("patientfirstname")),
	       patientdateofbirth = checkString(request.getParameter("patientdateofbirth")),
           patientservice     = checkString(request.getParameter("patientservice"));

	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************ mobile/searchPatient.jsp *************");
		Debug.println("sAction            : "+sAction);
		Debug.println("patientpersonid    : "+patientpersonid);
		Debug.println("patientname        : "+patientname);
		Debug.println("patientfirstname   : "+patientfirstname);
		Debug.println("patientdateofbirth : "+patientdateofbirth);
		Debug.println("patientservice     : "+patientservice+"\n");
	}
	///////////////////////////////////////////////////////////////////////////
		
	List patients = new ArrayList();
	
	//--- SEARCH --------------------------------------------------------------
	if(sAction.equals("search")){
		if(patientservice.length()==0 || patientpersonid.length()>0){
			if(patientname.length()>0 || patientfirstname.length()>0 || patientpersonid.length()>0 ||
			   patientdateofbirth.length()>0 || patientservice.length()>0){
				patients = AdminPerson.getAllPatients("","","",patientname,patientfirstname,patientdateofbirth,patientpersonid,"",20);
			}
		}
		else{
			// search on service
			Vector servicepatients = AdminPerson.getPatientsAdmittedInService(patientservice);
			for(int n=0; n<servicepatients.size(); n++){
				AdminPerson patient = AdminPerson.getAdminPerson((String)servicepatients.elementAt(n));
				if(patientname.length()>0 && !patient.lastname.startsWith(patientname)){
					continue;
				}
				if(patientfirstname.length()>0 && !patient.firstname.startsWith(patientfirstname)){
					continue;
				}
				if(patientdateofbirth.length()>0 && !patient.dateOfBirth.equalsIgnoreCase(patientdateofbirth)){
					continue;
				}
				patients.add(patient);
			}
		}
	}
	
	// display found patient, list of patients or message
	if(patients.size()==1){
		AdminPerson patient = (AdminPerson)patients.get(0);
		out.print("<script>window.location.href='selectPatient.jsp?personid="+patient.personid+"';</script>");
		out.flush();
	}
	else if(patients.size() > 0){
		out.print("<table class='list' padding='0' cellspacing='1' width='"+sTABLE_WIDTH+"' style='border-bottom:none;'>");
		
		// title
		out.print("<tr class='admin'><td colspan='2'>"+getTran("mobile","patients",activeUser)+"</td></tr>");
		
		// Show list of patients
		Iterator patientlist = patients.iterator();
		AdminPerson patient;
		String sClass = "1";
		
		while(patientlist.hasNext()){
			patient = (AdminPerson)patientlist.next();

	  		// alternate row-style
	  		if(sClass.length()==0) sClass = "1";
	  		else                   sClass = "";
			
			out.print("<tr class='list"+sClass+"'>"+
			           "<td nowrap><a href='selectPatient.jsp?personid="+patient.personid+"'>"+patient.lastname+", "+patient.firstname+"</a></td>"+
			           "<td nowrap width='90%'>"+patient.dateOfBirth+"</td>"+
			          "</tr>");
		}
		
		out.print("</table>");
		
		%>
            <%-- BUTTONS --%>
		    <%=alignButtonsStart()%>
		        <input type="button" class="button" name="searchButton" value="<%=getTran("mobile","newSearch",activeUser)%>" onClick="doNewSearch();"%>
		    <%=alignButtonsStop()%>
		<%
	}
	else{		
		%>
		    <input type="hidden" name="action" value="">
		    
			<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
    		    <tr class="admin"><td colspan="2"><%=getTran("mobile","searchPatient",activeUser)%></td></tr>
    		
				<tr><td class="admin" nowrap width="70"><%=getTran("web","personid",activeUser)%></td><td><input name="patientpersonid" type="text" class="text" size="10" value="<%=patientpersonid%>"></td></tr>
				<tr><td class="admin" nowrap><%=getTran("web","name",activeUser)%></td><td><input name="patientname" type="text" class="text" size="20" value="<%=patientname%>"></td></tr>
				<tr><td class="admin" nowrap><%=getTran("web","firstname",activeUser)%></td><td><input name="patientfirstname" type="text" class="text" size="20" value="<%=patientfirstname%>"></td></tr>
				<tr><td class="admin" nowrap><%=getTran("web","dateofbirth",activeUser)%></td><td><input name="patientdateofbirth" type="text" class="text" size="10" value="<%=patientdateofbirth%>"></td></tr>
				<tr><td class="admin" nowrap><%=getTran("web","service",activeUser)%></td><td><input name="patientservice" type="text" class="text" size="20" value="<%=patientservice%>"></td></tr>
				
		        <%
					if(sAction.equals("search")){
						out.print("<tr><td colspan='2' style='text-align:center;'><div id='msgDiv'><font color='red'>"+getTran("web","noPatientsFound",activeUser)+"</font></div></td></tr>");
					}
				%>
			</table>
			
			<%-- BUTTONS --%>
			<%=alignButtonsStart()%>
			    <input type="submit" class="button" name="searchButton" onClick="doSearch();" value="<%=getTran("web","search",activeUser)%>">&nbsp;
			    <input type="button" class="button" name="clearButton" onclick="clearSearchFields();" value="<%=getTran("web","clear",activeUser)%>">
			<%=alignButtonsStop()%>
		</form>
		
		<script>
		  searchForm.patientpersonid.focus();

		  <%-- DO SEARCH --%>
		  function doSearch(){
			if(searchForm.patientpersonid.value.length > 0 ||
			   searchForm.patientname.value.length > 0 || 
			   searchForm.patientfirstname.value.length > 0 || 
			   searchForm.patientdateofbirth.value.length > 0 || 
			   searchForm.patientservice.value.length > 0){
			  searchForm.action.value = "search";
			  searchForm.submit();
			}
			else{
	          <%
				  if(sAction.equals("search")){
					  %>document.getElementById("msgDiv").innerHTML = "";<%
			      }
	          %>	
			  searchForm.patientpersonid.focus();
			}
		  }
		  
		  <%-- CLEAR SEARCH FIELDS --%>
		  function clearSearchFields(){
			searchForm.patientpersonid.value = "";
			searchForm.patientname.value = "";
			searchForm.patientfirstname.value = "";
			searchForm.patientdateofbirth.value = "";
			searchForm.patientservice.value = "";

	        <%
			    if(sAction.equals("search")){
					%>document.getElementById("msgDiv").innerHTML = "";<%
			    }
	        %>			
		    searchForm.patientpersonid.focus();
		  }
		</script>
		<%
	}
%>
<%@include file="/mobile/_common/footer.jsp"%>