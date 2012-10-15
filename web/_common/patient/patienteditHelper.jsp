<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
////////////////////////////////////////////////////////////////////////////////////////////////////
    private String inputRow(String sLabelType, String sLabelID, String sFieldName, String sTab, String sValue
    , String sTypeContent, boolean bEditable, boolean bUpperCase, String sWebLanguage) {
        String sReturn = normalRow(sLabelType,sLabelID,sFieldName,sTab,sWebLanguage);

        if (sTypeContent.toUpperCase().equals("T")) {
            sReturn+="<input class='text' type='text' name='"+sFieldName+"' id='"+sFieldName+"' value=\""+sValue.trim()+"\" size='"+sTextWidth+"' onblur='validateText(this);limitLength(this);'";
             if (!bEditable) {
                sReturn+=" readonly ";
            }

            if (bUpperCase) {
                sReturn+=" style='text-transform=uppercase' onKeyUp='denySpecialCharacters(this);' ";
            }
            sReturn += ">";
        }
        else if (sTypeContent.toUpperCase().equals("D")) {
            sReturn += writeDateField(sFieldName,"PatientEditForm",sValue, sWebLanguage);
        }
        // only allow future dates
        else if (sTypeContent.equalsIgnoreCase("Df")) {
            sReturn += ScreenHelper.writeDateField(sFieldName,"PatientEditForm",sValue,false,true,sWebLanguage,sCONTEXTPATH);
        }
        // only allow past dates
        else if (sTypeContent.equalsIgnoreCase("Dp")) {
            sReturn += ScreenHelper.writeDateField(sFieldName,"PatientEditForm",sValue,true,false,sWebLanguage,sCONTEXTPATH);
        }
        else if (sTypeContent.toUpperCase().equals("D-")) {
            sReturn += ScreenHelper.writeDateFieldWithoutToday(sFieldName,"PatientEditForm",sValue, true,true,sWebLanguage,sCONTEXTPATH);
        }
        // only allow future dates
        else if (sTypeContent.equalsIgnoreCase("Df-")) {
            sReturn += ScreenHelper.writeDateFieldWithoutToday(sFieldName,"PatientEditForm",sValue,false,true,sWebLanguage,sCONTEXTPATH);
        }
        // only allow past dates
        else if (sTypeContent.equalsIgnoreCase("Dp-")) {
            sReturn += ScreenHelper.writeDateFieldWithoutToday(sFieldName,"PatientEditForm",sValue,true,false,sWebLanguage,sCONTEXTPATH);
        }
        else if (sTypeContent.toUpperCase().equals("B")) {
            sReturn+=("<input class='text' type='text' name='"+sFieldName+"' id='"+sFieldName+"' value=\""+sValue.trim()+"\" size='12' onblur='checkBegin(this, \""+sValue.trim()+"\")'>"
                +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTPATH+"/_img/icon_agenda.gif' border='0' ALT='"
                +getTran("Web","Select",sWebLanguage)+"' onclick='gfPop.fPopCalendar(document.getElementsByName(\""+sFieldName+"\")[0]);return false;'>"
                +"&nbsp;<img class='link' src='"+sCONTEXTPATH+"/_img/compose.gif' ALT='"
                +getTran("Web","PutToday",sWebLanguage)+"' onclick=\"getToday("+sFieldName+");\">");
        }
        sReturn+="</td></tr>";

        return sReturn;
    }
/////////////////////////////////////////////////////////////////////////////////////////
    private String normalRow(String sLabelType, String sLabelID, String sFieldName, String sTab, String sWebLanguage) {
        String sObligatoryFields = MedwanQuery.getInstance().getConfigString("ObligatoryFields_"+sTab);
        boolean drawAsterix = false;
        if(sObligatoryFields.toLowerCase().indexOf(sFieldName.toLowerCase()+",")>-1){
            drawAsterix = true;
        }
        return "<tr><td class='admin'>"+getTran(sLabelType,sLabelID,sWebLanguage)+(drawAsterix?" *":"")+"</td><td class='admin2'>";
    }
/////////////////////////////////////////////////////////////////////////////////////////
    private String writeCountry(String sCode, String sFieldCode, String tab, String sFieldDescription
      , boolean bEditable, String sCodeDescription,String sWebLanguage) {
        String sdc="";
        if (sCode.trim().length()==0) {
            sdc = "";
        }
        else {
            sdc = getTranNoLink("country",sCode,sWebLanguage);
        }

        String sReturn = ("<input type='hidden' name='"+sFieldCode+"' value='"+sCode+"'>"
            +normalRow("Web",sCodeDescription,sFieldCode,tab,sWebLanguage)
            +"<input class='text' size='"+sTextWidth+"' readonly type='text' name='"+sFieldDescription+"' value='"+sdc+"'");

        if (!bEditable){
          sReturn += " readonly ";
        }

        sReturn += (">&nbsp;"
            +ScreenHelper.writeSearchButton("buttonCountry", "Country", sFieldCode, sFieldDescription, "",sWebLanguage,sCONTEXTPATH)
            +"</td></tr>");

        return sReturn;
    }
%>
<%
    String sServiceSourceID = MedwanQuery.getInstance().getConfigString("PatientEditSourceID");
    String sDefaultCountry = MedwanQuery.getInstance().getConfigString("DefaultCountry");

    if (activePatient==null) {
        activePatient = new AdminPerson();
        activePatient.nativeCountry = sDefaultCountry;
        activePatient.lastname = checkString(request.getParameter("pLastname"));
        activePatient.firstname = checkString(request.getParameter("pFirstname"));
        activePatient.dateOfBirth = checkString(request.getParameter("pDateofbirth"));
        activePatient.setID("archiveFileCode",checkString(request.getParameter("pArchiveCode")));
        activePatient.setID("natreg",checkString(request.getParameter("pNatreg")));
        activePatient.setID("immatnew",checkString(request.getParameter("pImmatnew")));
        AdminPrivateContact apc = new AdminPrivateContact();
        apc.district = checkString(request.getParameter("pDistrict"));

        activePatient.privateContacts.add(apc);

        // DPMS
        activePatient.sourceid = sServiceSourceID;
        session.setAttribute("activePatient",activePatient);
    }
%>
<script>
function checkBegin(sObject, sBegin) {
  checkDate(sObject);
  var sdate = sObject.value;
  if (sdate.length==10) {
    var iDayBegin = sBegin.substring(0,2);
	var iMonthBegin  = sBegin.substring(3,5);
	var iYearBegin  = sBegin.substring(6,10);
    var iBegin = (iYearBegin+""+iMonthBegin+""+iDayBegin+"")*1;

	var iDayObject = sdate.substring(0,2);
	var iMonthObject = sdate.substring(3,5);
	var iYearObject = sdate.substring(6,10);
    var iObject =(iYearObject+""+iMonthObject+""+iDayObject+"")*1;

    if (iBegin > iObject){
        sObject.value = sBegin;
    }
  }
  else {
    sObject.value = sBegin;
  }
}
</script>