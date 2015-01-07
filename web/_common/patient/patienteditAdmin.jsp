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
            <table border='0' width='100%' class="list" cellspacing="1" style="border-top:none;">
        <%
		boolean bCanModifyCore=true;
        if(checkString(activePatient.personid).length()>0 && MedwanQuery.getInstance().getConfigInt("canmodifyexistingcoreadmindata",1)==0 && !activeUser.getAccessRight("patient.modifyexistingcoreadminrecord.select")){
        	bCanModifyCore=false;
        }
        out.print(
    			(bCanModifyCore?inputRow("Web","begindate","UpdateTime","Admin",ScreenHelper.formatDate(new java.util.Date()),"Dp",true,false,sWebLanguage):
    	            inputRow("Web","begindate","UpdateTime","Admin",ScreenHelper.formatDate(new java.util.Date()),"T",bCanModifyCore,true,sWebLanguage)
    				)
        	+inputRow("Web","Lastname","Lastname","Admin",activePatient.lastname,"T",bCanModifyCore,true,sWebLanguage)
            +inputRow("Web","Firstname","Firstname","Admin",activePatient.firstname,"T",bCanModifyCore,true,sWebLanguage)
			+(bCanModifyCore?inputRow("Web","Dateofbirth","DateOfBirth","Admin",activePatient.dateOfBirth,"Dp",true,false,sWebLanguage):
            inputRow("Web","Dateofbirth","DateOfBirth","Admin",activePatient.dateOfBirth,"T",bCanModifyCore,true,sWebLanguage)
			)
            +inputRow("Web","NativeTown","NativeTown","Admin",activePatient.nativeTown,"T",true,true,sWebLanguage)
            +writeCountry(activePatient.nativeCountry, "NativeCountry","Admin","NativeCountryDescription",true,"NativeCountry",sWebLanguage)
            +"<tr><td class='admin'>"+getTran("web","personid",sWebLanguage)+"</td><td class='admin2'>"+activePatient.personid+"</td></tr>"
            +inputRow("Web","immatnew","ImmatNew","Admin",activePatient.getID("immatnew"),"T",true,true,sWebLanguage)
            +"<tr><td class='admin'>"+getTran("web","archiveFileCode",sWebLanguage)+"</td><td class='admin2'><input type='hidden' name='archiveFileCode' value='"+activePatient.getID("archiveFileCode")+"'/>"
            +activePatient.getID("archiveFileCode").toUpperCase()+"</td></tr>");

        // natreg (max 11 chars)
        String sNatRegHtml = normalRow("Web","natreg","NatReg","Admin",sWebLanguage)+
                             "<input class='text' type='text' name='NatReg' value=\""+activePatient.getID("natreg").trim()+"\""+
                             " size='"+sTextWidth+"' maxLength='250'>";
        out.print(sNatRegHtml);

        //language
        String sLanguage = "<select name='Language' select-one class='text'";
        sLanguage+=">";
        sLanguage+="<option value='' SELECTED>"+getTran("web","choose",sWebLanguage)+"</option>";

        String sPatientLanguages = MedwanQuery.getInstance().getConfigString("PatientLanguages");

        if(sPatientLanguages.length()==0){
            sPatientLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");

            if(sPatientLanguages.length()==0){
                sPatientLanguages = sWebLanguage;
            }
        }

        String[] aPatientLanguages = sPatientLanguages.split(",");
        for(int i=0;i<aPatientLanguages.length;i++){
            sLanguage += "<option value='"+aPatientLanguages[i]+"'>"+getTran("Web.Language",aPatientLanguages[i],sWebLanguage)+"</option>";
        }

        String sDefaultLanguage = MedwanQuery.getInstance().getConfigString("DefaultLanguage");

        if(sDefaultLanguage.length()==0){
            sDefaultLanguage = sWebLanguage;
        }

        sLanguage = setOption(sLanguage,activePatient.language.toLowerCase(),sDefaultLanguage.toLowerCase(),3);
        out.print(normalRow("Web","language","Language","Admin",sWebLanguage)+sLanguage+"</select></td></tr>");

      // gender
      String sGender = "<select name='Gender' select-one class='text'";
      sGender+="><option value='' SELECTED>"+getTran("web","choose",sWebLanguage)+"</option>";
      sGender+="<option value='M'>"+getTran("Web.Occup","Male",sWebLanguage)+"</option>"+
               "<option value='F'>"+getTran("Web.Occup","Female",sWebLanguage)+"</option>";
      sGender = setOption(sGender,activePatient.gender.toUpperCase(),MedwanQuery.getInstance().getConfigString("defaultGender","F"),3);

      // status
      String sCivilStatus = "<select name='CivilStatus' select-one class='text'><option value=''/>"
            +ScreenHelper.writeSelect("civil.status",activePatient.comment2,sWebLanguage)+"</select>";

      out.print(normalRow("Web","gender","Gender","Admin",sWebLanguage)+sGender+"</select></td></tr>"
          +inputRow("Web","tracnetid","TracnetID","Admin",checkString((String)activePatient.adminextends.get("tracnetid")),"T",true,false,sWebLanguage)
          +inputRow("Web","treating-physician","Comment1","Admin",activePatient.comment1,"T",true,false,sWebLanguage)
          +normalRow("Web","civilstatus","CivilStatus","Admin",sWebLanguage)+sCivilStatus+"</td></tr>"
          +inputRow("Web","comment3","Comment3","Admin",activePatient.comment3,"T",true, false,sWebLanguage) 
          +inputRow("Web","comment5","Comment5","Admin",activePatient.comment5,"T",true, false,sWebLanguage) 
          +(activePatient.isDead()!=null?inputRow("Web","deathcertificateon","DeathCertificateOn","Admin",checkString((String)activePatient.adminextends.get("deathcertificateon")),"T",true,false,sWebLanguage)
          +inputRow("Web","deathcertificateto","DeathCertificateTo","Admin",checkString((String)activePatient.adminextends.get("deathcertificateto")),"T",true,false,sWebLanguage):"")
	      +inputRow("Web","comment","Comment","Admin",activePatient.comment,"T",true, false,sWebLanguage)
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
function checkSubmitAdmin(){
  var maySubmit = true;
  displayGenericAlert = true;

  var sObligatoryFields = "<%=MedwanQuery.getInstance().getConfigString("ObligatoryFields_Admin")%>";
  var aObligatoryFields = sObligatoryFields.split(",");

  for(var i=0; i<aObligatoryFields.length; i++){
    var obligatoryField = document.all(aObligatoryFields[i]);

    if(obligatoryField != null){
      if(obligatoryField.type==undefined){
        if(obligatoryField.innerHTML==""){
          maySubmit = false;
          break;
        }
      }
      else{
    	if(obligatoryField.value==""){
          if(obligatoryField.type != "hidden"){
            activateTab('Admin');
            obligatoryField.focus();
          }
          maySubmit = false;
          break;
        }
    	else{
    	  // selected option should be 1 or 2 (preventing data-input through "Inspect element")
          if(obligatoryField.name=="Gender"){
          	if(document.all("Gender").value.length > 0){
          	  if(document.all("Gender").selectedIndex!=1 && document.all("Gender").selectedIndex!=2){
                if(obligatoryField.type != "hidden"){
                  activateTab('Admin');
                  obligatoryField.focus();
                }
          	    maySubmit = false;
                break;
          	  }    
          	}
          }
    	}
      }
    }
  }
  
  return maySubmit;
}

function checkBeginAdmin(sObject,sBegin){
  checkDate(sObject);
  var sdate = sObject.value;

  if(sdate.length==10){
    var iDayBegin = sBegin.substring(1,2);
	var iMonthBegin = sBegin.substring(4,5);
	var iYearBegin = sBegin.substring(7,10);
    var iBegin = new Date(iYearBegin,iMonthBegin,iDayBegin);

	var iDayObject = sdate.substring(1,2);
	var iMonthObject = sdate.substring(1,2);
	var iYearObject = sdate.substring(1,2);
	var iObject = new Date(iYearObject,iMonthObject,iDayObject);

    var difference = iBegin.getTime() - iObject.getTime();

    if(difference>0){
	  sObject.value = sBegin;
	}
  }
  else{
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