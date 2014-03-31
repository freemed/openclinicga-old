<%@page import="java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- SET FOCUS -------------------------------------------------------------------------------
    private String setFocus(String sField, String sDefaultFocus) {
        if (sDefaultFocus.equalsIgnoreCase(sField)) {
            return "bold";
        }

        return "text";
    }
%>

<%
    String sNewimmat = checkString(request.getParameter("findimmatnew"));
    String sNatreg = checkString(request.getParameter("findnatreg"));
    String sName = checkString(request.getParameter("findName"));
    String sFirstname = checkString(request.getParameter("findFirstname"));
    String sDateOfBirth = checkString(request.getParameter("findDateOfBirth"));
    String sUnit = checkString(request.getParameter("findUnit"));
    String sUnitText = checkString(request.getParameter("findUnitText"));
    String sArchiveFileCode = checkString(request.getParameter("findArchiveFileCode"));
    String sPersonID = checkString(request.getParameter("findPersonID"));
    String sDistrict = checkString(request.getParameter("findDistrict"));
    String sScript = "";
    String sAction = checkString(request.getParameter("findSearchButtonClick"));

    // fedault focus
    String sDefaultFocus = checkString(activeUser.getParameter("DefaultFocus"));
    if (sDefaultFocus.length() == 0) sDefaultFocus = "Name";

    if (sAction.length() == 0 && activePatient != null) {
        sName = activePatient.lastname;
        sFirstname = activePatient.firstname;
        sDateOfBirth = activePatient.dateOfBirth;

        sNewimmat = activePatient.getID("immatnew").trim();
        sArchiveFileCode = activePatient.getID("archiveFileCode").trim();
        sNatreg = activePatient.getID("natreg").trim();
        sDistrict = activePatient.getActivePrivate().district.trim();
        sPersonID = activePatient.personid;

        // retreive service via Encounters, not via AdminWork
        Service as = ScreenHelper.getActiveDivision(activePatient.personid);
        if (as != null) sUnit = as.code;
        else            sUnit = "";
    } 
    else{
        sScript = "document.getElementById(\"SF\").find" + sDefaultFocus + ".focus();$(\"SF\").find" + sDefaultFocus + ".className=\"selected_bold\"";
    }

    // unitid and unitname
    if(checkString(sUnit).trim().length() > 0) {
        if(MedwanQuery.getInstance().getConfigString("showUnitID").equals("1")) {
            sUnitText = sUnit + " " + getTran("service", sUnit, sWebLanguage);
        } 
        else{
            sUnitText = getTran("service", sUnit, sWebLanguage);
        }
    }
%>

<table width="90%" onKeyDown='checkKeyDown(event);'>
    <form name="SF" method='post' action="<c:url value='/patientslist.do'/>?ts=<%=getTs()%>" id="SF">
        <input type="hidden" name="RSIndex">
        <input type="hidden" name="ListAction">
        <input type="hidden" name="findSearchButtonClick">
        
        <%-- row 1 --%>
        <tr>
            <td align="right" nowrap width="55"><%=getTran("Web","Name",sWebLanguage)%></td>
            <td>
                <input id="ac2" autocomplete="off" class='<%=setFocus("Name",sDefaultFocus)%>' TYPE='TEXT'
                       style='text-transform:uppercase' NAME='findName' VALUE="<%=sName%>" size='25'
                       onblur='validateText(this);limitLength(this);'>

                <div id="ac2update" style="display: none;border: 1px solid black;background-color: white; "></div>
            </td>
            <td align="right" nowrap><%=getTran("Web", "Firstname", sWebLanguage)%>&nbsp;
                <input id="ac1" autocomplete="off" class='<%=setFocus("Name",sDefaultFocus)%>' type='TEXT' style='text-transform:uppercase' name='findFirstname' value="<%=sFirstname%>" size='20' onblur='validateText(this);limitLength(this);'>
            </td>
            <div id="ac1update" style="display:none; border: 1px solid black;background-color: white;"></div>

            <td align="right" nowrap><%=getTran("Web","DateOfBirth", sWebLanguage)%>&nbsp;
                <input class='<%=setFocus("DateOfBirth",sDefaultFocus)%>' type='TEXT' name='findDateOfBirth' value="<%=sDateOfBirth%>" size='17' OnBlur='checkDate(this)' maxlength='10'>
            </td>
            <td width="1%" nowrap>
            <%	
            	if(activePatient!=null && activePatient.personid!=null && activePatient.personid.length()>0){
	            	java.util.Date death=activePatient.isDead();	
	            	if(death!=null){
						out.print("<img src='_img/warning.gif'/> <font style='{font-size: 12px; font-weight: bold; vertical-align: top}'>"+getTran("web","died",sWebLanguage)+" "+new SimpleDateFormat("dd/MM/yyyy").format(death)+"</font>");
	            	}
	            	else {
	            		out.print(" ("+(activePatient.gender.equalsIgnoreCase("M")?getTran("web.occup","male",sWebLanguage):getTran("web.occup","female",sWebLanguage))+" - "+activePatient.getAge()+" "+getTran("web","years",sWebLanguage).toLowerCase()+")");
	            	}
            	}
            %>
            </td>
            <td width="98%"/>
        </tr>
        
        <%-- row 2 --%>
        <tr>
            <td align="right" nowrap><%=getTran("Web", "natreg.short", sWebLanguage)%>
            </td>
            <td>
                <input class='<%=setFocus("natreg",sDefaultFocus)%>' TYPE='TEXT' NAME='findnatreg' VALUE="<%=sNatreg%>" size='25' onblur='validateText(this);limitLength(this);'>
            </td>
            <td align="right" nowrap><%=getTran("Web", "immatnew", sWebLanguage)%>&nbsp;<input class='<%=setFocus("immatnew",sDefaultFocus)%>' type='TEXT' style='text-transform:uppercase' name='findimmatnew' value="<%=sNewimmat%>" size='20' onblur='validateText(this);limitLength(this);'></td>
            <%
                if(activePatient != null && activePatient.getID("archiveFileCode").length() > 0){
            %>
            <td align="right" nowrap>
                <a href="javascript:showArchiveCode();"><%=getTran("Web","archiveFileCode",sWebLanguage)%></a>
                &nbsp;<input class='<%=setFocus("archiveFileCode",sDefaultFocus)%>' type='TEXT' style='text-transform:uppercase' name='findArchiveFileCode' value="<%=sArchiveFileCode%>" size='17' onblur='validateText(this);limitLength(this);'>
            </td>
            <%
	            }
	            else{
            %>
            <td align="right" nowrap>
                <%=getTran("Web", "archiveFileCode", sWebLanguage)%>
                &nbsp;<input class='<%=setFocus("archiveFileCode",sDefaultFocus)%>' type='TEXT'
                             style='<%=activePatient!=null?"background-color: #ff9999;":""%>text-transform:uppercase'
                             name='findArchiveFileCode' value="<%=sArchiveFileCode%>" size='17'
                             onblur='validateText(this);limitLength(this);'>
            </td>
            <%
                }
            %>
            <td align="right" nowrap><%=getTran("Web", "personid", sWebLanguage)%>&nbsp;<input
                    class='<%=setFocus("personid",sDefaultFocus)%>' type='TEXT' style='text-transform:uppercase'
                    name='findPersonID' value="<%=sPersonID%>" size='17' onblur='validateText(this);limitLength(this);'>
            </td>
        </tr>
        <%-- row 3 --%>
        <tr>
            <td align="right" nowrap><%=getTran("Web","service",sWebLanguage)%></td>
            <td colspan='2' nowrap>
                <input class='text' TYPE="text" NAME="findUnitText" readonly size="49" TITLE="<%=sUnitText%>" VALUE="<%=sUnitText%>" onkeydown="enterEvent(event,13)? window.event.keyCode='' : (window.which='');return true;">
                <%
                    if(sUnit.length() > 0){
                        %><img src="<c:url value='/_img/icon_info.gif'/>" class="link" alt="<%=getTran("Web","Information",sWebLanguage)%>" onclick='searchInfoService(SF.findUnit)'/><%
                    }
                %>
                <%=ScreenHelper.writeServiceButton("buttonUnit", "findUnit", "findUnitText", sWebLanguage, sCONTEXTPATH)%>
                <input TYPE="hidden" NAME="Action" VALUE="">
                <input TYPE="hidden" NAME="findUnit" VALUE="<%=sUnit%>">
            </td>
            <%-- BUTTONS --%>
            <td align="right" nowrap><%=getTran("Web", "district", sWebLanguage)%>&nbsp;
            <%
                String sDistricts = "<select class='text' name='findDistrict'><option/>";
                Vector vDistricts = Zipcode.getDistricts(MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
                Collections.sort(vDistricts);
                String sTmpDistrict;

                for(int i=0;i<vDistricts.size();i++){
                    sTmpDistrict = (String)vDistricts.elementAt(i);

                    sDistricts+= "<option value='"+sTmpDistrict+"'";

                    if(sTmpDistrict.equalsIgnoreCase(sDistrict)){
                        sDistricts+= " selected";
                    }
                    sDistricts+= ">"+sTmpDistrict+"</option>";
                }

                sDistricts+= "</select>";

                out.print(sDistricts);
            %>
            </td>
            <td align="right">
                <input class='button' type="button" name="findSearchPatient" id="findSearchPatient" onclick='doSPatient();' value='<%=getTran("Web","Find",sWebLanguage)%>'>&nbsp;
                <button accesskey="<%=ScreenHelper.getAccessKey(getTran("AccessKey","Clear",sWebLanguage))%>" class='button' name="clearButton" onClick='clearPatient();return false;'><%=getTran("AccessKey", "Clear", sWebLanguage)%></button>
            </td>
        </tr>
    </form>
</table>

<script>
  Event.observe(window,'load',function(){<%=sScript%>});
  
<%
    // red background for patients who are not hospitalized
    if(activePatient!=null){
        if(!activePatient.isHospitalized()){
            %>document.getElementById("SF").findUnitText.style.backgroundColor = '#ff9999';<%
        }
    }
%>

<%-- enlarge searchfields if pagewidth is large --%>
resizeSearchFields();

<%-- Autocompletion code ---%>     
function eventDateCallback(element, entry){
  var serialized = "";
  if(element.id=="ac1"){
    serialized = "findFirstname="+element.value;
    if($F("ac2").length>0){
      serialized+="&findName="+$F("ac2")+"&field=findFirstname";
    }
  }
  else if(element.id=="ac2"){
    serialized = "findName="+element.value;
    if($F("ac1").length>0){
      serialized+="&findFirstname="+$F("ac1")+"&field=findName";
    }
  }
  return serialized;
}

new Ajax.Autocompleter('ac2','ac2update','_common/search/searchByAjax/patientslistShow.jsp',{
  minChars: 1,
  method: 'post',
  afterUpdateElement: ac_return,
  callback:eventDateCallback
});

new Ajax.Autocompleter('ac1','ac1update','_common/search/searchByAjax/patientslistShow.jsp',{
  minChars: 1,
  method: 'post',
  afterUpdateElement: ac_return,
  callback:eventDateCallback
});

function ac_return(field,item){
  var regex = new RegExp('[0123456789]*-idcache', 'i');
  var nomimage = regex.exec(item.innerHTML);
  var id = nomimage[0].replace('-idcache', '');
  clearPatient();
  document.getElementById("SF").findPersonID.value = id;
  doSPatient();
}

function resizeSearchFields(){
  var width = 1000;
  if(document.body){
    width = (document.body.clientWidth);
  }
  else{
    width = (window.innerWidth);
  }
  var bigbigSize = 300;
  var bigSize = 150;
  var normalSize = 130;
  var smallSize = 75;
  if (width > 1100) {
    bigbigSize = 400;
    bigSize = 200;
    normalSize = 150;
    smallSize = 100;
  }

  $("SF").findName.style.width = bigSize+"px";
  $("SF").findFirstname.style.width = bigSize+"px";
  $("SF").findDateOfBirth.style.width = smallSize+"px";

  $("SF").findnatreg.style.width = bigSize+"px";
  $("SF").findimmatnew.style.width = bigSize+"px";
  $("SF").findArchiveFileCode.style.width = smallSize+"px";
  $("SF").findPersonID.style.width = smallSize+"px";
  $("SF").findDistrict.style.width = smallSize+"px";

  $("SF").findUnitText.style.width = bigbigSize+"px";
}

function showArchiveCode(){
  openPopup("util/showArchiveLabel.jsp&ts=<%=getTs()%>", 20, 370);
}

function checkKeyDown(evt){
  evt = evt || window.event;
  var kcode = evt.keyCode || evt.which;
  if(kcode && kcode==13){
    doSPatient();
    return true;
  } 
  else{
    return false;
  }
}

<%-- search patient --%>
function doSPatient(){
  if(checkSaveButton("<%=sCONTEXTPATH%>", "<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")) {
    if(document.getElementById("SF").findName.value.length > 0 ||
      document.getElementById("SF").findFirstname.value.length > 0 ||
      document.getElementById("SF").findDateOfBirth.value.length > 0 ||
      document.getElementById("SF").findnatreg.value.length > 0 ||
      document.getElementById("SF").findimmatnew.value.length > 0 ||
      document.getElementById("SF").findArchiveFileCode.value.length > 0 ||
      document.getElementById("SF").findPersonID.value.length > 0 ||
      document.getElementById("SF").findDistrict.selectedIndex>-1 ||
      document.getElementById("SF").findUnitText.value.length > 0) {
      document.getElementById("SF").findSearchButtonClick.value = "Find";
      document.getElementById("SF").findSearchPatient.disabled = true;
      document.getElementById("SF").submit();
    }
    else{
      document.getElementById("SF").find<%=sDefaultFocus%>.focus();
    }
  }
}

<%-- clear patient --%>
function clearPatient(){
  if(checkSaveButton("<%=sCONTEXTPATH%>", "<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")) {
    if(verifyPrestationCheck()){
      document.getElementById("SF").findimmatnew.value = "";
      document.getElementById("SF").findArchiveFileCode.value = "";
      document.getElementById("SF").findnatreg.value = "";
      document.getElementById("SF").findName.value = "";
      document.getElementById("SF").findFirstname.value = "";
      document.getElementById("SF").findDateOfBirth.value = "";
      document.getElementById("SF").findUnit.value = "";
      document.getElementById("SF").findUnitText.value = "";
      document.getElementById("SF").findPersonID.value = "";
      document.getElementById("SF").findDistrict.selectedIndex = -1;
      document.getElementById("SF").findUnitText.style.backgroundColor = "white";

      document.getElementById("SF").find<%=sDefaultFocus%>.focus();
    }
  }
}

<%-- search info service --%>
function searchInfoService(sObject){
  if(sObject.value.length > 0){
    openPopup("/_common/search/serviceInformation.jsp&ServiceID=" + sObject.value);
  }
}
</script>

<%=writeJSButtons("SF","findSearchPatient")%>