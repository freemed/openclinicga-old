<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%!
    //--- SET OPTION ------------------------------------------------------------------------------
    private String setOption(String sList, String sOption, String sDefault, int iCounter) {
        int iIndex = 0;

        if(sOption!=null && sOption.trim().length()>0){
            iIndex = sList.indexOf("'"+sOption+"'");
            if (iIndex>0) {
                sList = sList.substring(0,iIndex)+"'"+sOption+"' selected "+sList.substring(iIndex+(sOption.length()-1)+iCounter,sList.length());
            }
        }

        if(iIndex==0 && sDefault.trim().length()>0){
            iIndex = sList.indexOf("'"+sDefault+"'");
            if (iIndex>0) {
                sList = sList.substring(0,iIndex)+"'"+sDefault+"' selected "+sList.substring(iIndex+(sDefault.length()-1)+iCounter,sList.length());
            }
        }

        return sList;
    }
%>
<%
    //--- SAVE ------------------------------------------------------------------------------------
    if((activePatient!=null)&&(request.getParameter("SavePatientEditForm")==null)) {
        %>
            <table border='0' width='100%' class="list" cellspacing="1">
        <%

        out.print(inputRow("Web","Lastname","Lastname","Admin",activePatient.lastname,"T",true, true,sWebLanguage)
            +inputRow("Web","Firstname","Firstname","Admin",activePatient.firstname,"T",true, true,sWebLanguage)
            +inputRow("Web","Dateofbirth","DateOfBirth","Admin",activePatient.dateOfBirth,"Dp",true,false,sWebLanguage)
            +writeCountry(activePatient.nativeCountry, "NativeCountry", "Admin", "NativeCountryDescription", true, "NativeCountry",sWebLanguage)
            +"<tr><td class='admin'>"+getTran("web","personid",sWebLanguage)+"</td><td class='admin2'>"+activePatient.personid+"</td></tr>"
            +"<tr><td class='admin'>"+getTran("web","archiveFileCode",sWebLanguage)+"</td><td class='admin2'><input type='hidden' name='archiveFileCode' value='"+activePatient.getID("archiveFileCode")+"'/>"
            +activePatient.getID("archiveFileCode").toUpperCase()+"</td></tr>");

        // natreg (max 11 chars)
        String sNatRegHtml = normalRow("Web","natreg","NatReg","Admin",sWebLanguage)+
                             "<input class='text' type='text' name='NatReg' value=\""+activePatient.getID("natreg").trim()+"\""+
                             " size='"+sTextWidth+"' onblur='validateText(this);' maxLength='250'>";
        out.print(sNatRegHtml);

        out.print("<input type='hidden' name='Language' value='fr'/></td></tr>");
        out.print("<input type='hidden' name='TreatingPhysician' value=''/></td></tr>");

      //gender
      String sGender = "<select name='Gender' select-one class='text'";
      sGender+="><option value='' SELECTED>"+getTran("web","choose",sWebLanguage)+"</option>";
      sGender+="<option value='M'>"+getTran("Web.Occup","Male",sWebLanguage)+"</option><option value='F'>"+getTran("Web.Occup","Female",sWebLanguage)+"</option>";
      sGender = setOption(sGender, activePatient.gender.toUpperCase(),MedwanQuery.getInstance().getConfigString("defaultGender","F"),3);

      //gender
      String sCivilStatus = "<select name='CivilStatus' select-one class='text'><option value=''/>"
            +ScreenHelper.writeSelect("civil.status",activePatient.comment2,sWebLanguage)+"</select>";
      AdminPrivateContact apc = ScreenHelper.getActivePrivate(activePatient);
      
      //center
	  String existingReasons=checkString((String)activePatient.adminextends.get("centerreasons"));
      String sCenter="<table><tr>";
      Hashtable reasons = (Hashtable)((Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase())).get("centerreasons");
      Set r = reasons.keySet();
      TreeSet rs = new TreeSet(r);
	  Iterator i = rs.iterator();
	  int counter=1;
	  while(i.hasNext()){
		  String reason = (String)i.next();
		  sCenter+="<td><input type='checkbox' name='centerreason' value='"+reason+"' "+(existingReasons.indexOf(reason)>-1?"checked":"")+"/>"+getTran("centerreasons",reason,sWebLanguage)+"</td>";
		  if(counter%5==0){
			  sCenter+="</tr><tr>";
		  }
		  counter++;
	  }
	  sCenter+="</tr></table>";
      out.print(normalRow("Web","gender","Gender","Admin",sWebLanguage)+sGender+"</select></td></tr>"
          +normalRow("Web","civilstatus","CivilStatus","Admin",sWebLanguage)+sCivilStatus+"</td></tr>"
          +inputRow("Web","tracnetid","TracnetID","Admin",checkString((String)activePatient.adminextends.get("tracnetid")),"T",true,false,sWebLanguage)
          +inputRow("Web","comment3","Comment3","Admin",activePatient.comment3,"T",true, false,sWebLanguage) 
          +(activePatient.isDead()!=null?inputRow("Web","deathcertificateon","DeathCertificateOn","Admin",checkString((String)activePatient.adminextends.get("deathcertificateon")),"T",true,false,sWebLanguage)
          +inputRow("Web","deathcertificateto","DeathCertificateTo","Admin",checkString((String)activePatient.adminextends.get("deathcertificateto")),"T",true,false,sWebLanguage):"")
	      +inputRow("Web","comment","Comment","Admin",activePatient.comment,"T",true, false,sWebLanguage)
          +inputRow("Web","function","PFunction","AdminPrivate",apc.businessfunction,"T",true,false,sWebLanguage)
          +inputRow("Web","business","PBusiness","AdminPrivate",apc.business,"T",true,false,sWebLanguage)
          +normalRow("Web","center","Center","Admin",sWebLanguage)+sCenter+"</td></tr>"
	      +(MedwanQuery.getInstance().getConfigInt("enableVip",0)==1 && activeUser.getAccessRight("vipaccess.select")?
	      normalRow("Web","vip","Vip","Admin",sWebLanguage)+"<input type='radio' name='Vip' id='Vip' value='0' "+(!"1".equalsIgnoreCase((String)activePatient.adminextends.get("vip"))?"checked":"")+">"+getTran("vipstatus","0",sWebLanguage)+" <input type='radio' name='Vip' id='Vip' value='1' "+("1".equalsIgnoreCase((String)activePatient.adminextends.get("vip"))?"checked":"")+">"+getTran("vipstatus","1",sWebLanguage)+"</td></tr>":
	      "<input type='hidden' name='Vip' id='Vip' value='"+checkString((String)activePatient.adminextends.get("vip"))+"'/>"	  
	      )
	      +(MedwanQuery.getInstance().getConfigInt("enableDatacenterPatientExport",0)==1 && activeUser.getAccessRight("datacenterpatientexport.select")?
	      normalRow("Web","datacenterpatientexport","datacenterpatientexport","Admin",sWebLanguage)+"<input type='radio' name='datacenterpatientexport' id='datacenterpatientexport' value='0' "+(!activePatient.hasPendingExportRequest() && activePatient.personid!=null && activePatient.personid.trim().length()>0?"checked":"")+">"+getTran("datacenterpatientexport","0",sWebLanguage)+" <input type='radio' name='datacenterpatientexport' id='datacenterpatientexport' value='1' "+(activePatient.hasPendingExportRequest() || activePatient.personid==null || activePatient.personid.trim().length()==0?"checked":"")+">"+getTran("datacenterpatientexport","1",sWebLanguage)+"</td></tr>":
	      "<input type='hidden' name='datacenterpatientexport' id='datacenterpatientexport' value='"+(activePatient.hasPendingExportRequest()?"1":"0")+"'/>"	  
	      )
	      );
    %>
    <tr height="0">
        <td width='<%=sTDAdminWidth%>'/><td width='*'/>
    </tr>
</table>

<script>
function checkSubmitAdmin() {
  var maySubmit = true;
  displayGenericAlert = true;

  var sObligatoryFields = "<%=MedwanQuery.getInstance().getConfigString("ObligatoryFields_Admin")%>";
  var aObligatoryFields = sObligatoryFields.split(",");

  for(var i=0; i<aObligatoryFields.length; i++){
    var obligatoryField = document.all(aObligatoryFields[i]);

    if(obligatoryField != null){
      if(obligatoryField.type == undefined){
        if(obligatoryField.innerHTML == ""){
          maySubmit = false;
          break;
        }
      }
      else if(obligatoryField.value == ""){
        if(obligatoryField.type != "hidden"){
          activateTab('Admin');
          obligatoryField.focus();
        }
        maySubmit = false;
        break;
      }
    }
  }
  if(maySubmit && document.getElementById('TracnetID').value.length==0 && document.getElementById("DateOfBirth").value.length>0){
	  //Make date from date of birth
	  var birth = makeDate(document.getElementById("DateOfBirth").value);
	  year=365*24*3600*1000;
	  maySubmit=(((new Date()-birth))/year>=5);
	  if(!maySubmit){
		  alert('<%=getTranNoLink("web","birthcertificatemandatory",sWebLanguage)%>');
	  }
  }
  return maySubmit;
}

function checkBeginAdmin(sObject, sBegin) {
  checkDate(sObject);
  var sdate = sObject.value;

  if(sdate.length==10) {
    var iDayBegin = sBegin.substring(1,2);
	var iMonthBegin  = sBegin.substring(4,5);
	var iYearBegin  = sBegin.substring(7,10);
    var iBegin = new Date(iYearBegin,iMonthBegin,iDayBegin);

	var iDayObject = sdate.substring(1,2);
	var iMonthObject = sdate.substring(1,2);
	var iYearObject = sdate.substring(1,2);
	var iObject = new Date(iYearObject,iMonthObject,iDayObject);

    var difference = iBegin.getTime() - iObject.getTime();

    if(difference>0) {
	  sObject.value = sBegin;
	}
  }
  else {
    sObject.value = sBegin;
  }
}

function checkDOB(oObject){
  checkDate(oObject);
  if(oObject.value.length>0){
    var dateDOB = makeDate(oObject.value);
    var today = new Date();

    var yearDOB = dateDOB.getYear();
    var yearToday = today.getYear();

    if(yearDOB < 100){
      yearDOB = 1900 + yearDOB;
    }

    if(yearToday - yearDOB < 14){
      return false;
    }
  }
  return true;
}
</script>
<%
    }
%>
