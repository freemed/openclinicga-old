<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>

<%
    //--- SAVE ------------------------------------------------------------------------------------
    if((activePatient!=null)&&(request.getParameter("SavePatientEditForm")==null)) {
        %>
            <table border='0' width='100%' class="list" cellspacing="1">
        <%

      out.print(
    		  inputRow("web","fathername","FatherName","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("fathername")),"T",true,false,sWebLanguage)
    		  +inputRow("web","fatherprofession","FatherProfession","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("fatherprofession")),"T",true,false,sWebLanguage)
    		  +inputRow("web","fatheremployer","FatherEmployer","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("fatheremployer")),"T",true,false,sWebLanguage)
    		  +inputRow("web","mothername","MotherName","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("mothername")),"T",true,false,sWebLanguage)
    		  +inputRow("web","motherprofession","MotherProfession","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("motherprofession")),"T",true,false,sWebLanguage)
    		  +inputRow("web","motheremployer","MotherEmployer","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("motheremployer")),"T",true,false,sWebLanguage)
    		  +inputRow("web","spousename","SpouseName","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("spousename")),"T",true,false,sWebLanguage)
    		  +inputRow("web","spouseprofession","SpouseProfession","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("spouseprofession")),"T",true,false,sWebLanguage)
    		  +inputRow("web","spouseemployer","SpouseEmployer","AdminFamilyRelation",checkString((String)activePatient.adminextends.get("spouseemployer")),"T",true,false,sWebLanguage)
	      );
    %>
    <tr height="0">
        <td width='<%=sTDAdminWidth%>'/><td width='*'/>
    </tr>
</table>
<%-- check submit --%>
<script>
	function checkSubmitAdminFamilyRelation(){
	  maySubmit=true;
	  if(maySubmit && document.getElementById('FatherProfession').value.length==0 && document.getElementById("DateOfBirth").value.length>0){
		  //Make date from date of birth
		  var birth = makeDate(document.getElementById("DateOfBirth").value);
		  year=365*24*3600*1000;
		  maySubmit=(((new Date()-birth))/year>=16);
		  if(!maySubmit){
			  alert('<%=getTranNoLink("web","fatherprofessionmandatory",sWebLanguage)%>');
		  }
	  }
	  if(maySubmit && document.getElementById('MotherProfession').value.length==0 && document.getElementById("DateOfBirth").value.length>0){
		  //Make date from date of birth
		  var birth = makeDate(document.getElementById("DateOfBirth").value);
		  year=365*24*3600*1000;
		  maySubmit=(((new Date()-birth))/year>=16);
		  if(!maySubmit){
			  alert('<%=getTranNoLink("web","motherprofessionmandatory",sWebLanguage)%>');
		  }
	  }

	  return maySubmit;
	}
</script>
<%
    }
%>
