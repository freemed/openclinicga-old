<%@page import="be.openclinic.adt.Encounter,
                be.openclinic.adt.Bed,java.util.*,be.openclinic.finance.Prestation,be.openclinic.finance.Debet,be.openclinic.finance.Insurance,java.util.Date" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("adt.encounter","all",activeUser)%>
<%!
    //--- GET DATE HOUR ---------------------------------------------------------------------------
    public java.util.Date getDateHour(String sDate, String sHour) {
        String sTmpHour[] = sHour.split(":");
        java.util.Date d=null;
        try{
        	d=new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(sDate+" "+sHour);
        }
        catch(Exception e){};
		return d;
    }
%>
<%
    Encounter tmpEncounter = null;

    boolean bActiveEncounterStatus;

    String sEditEncounterUID = checkString(request.getParameter("EditEncounterUID"));
    String sEditEncounterType = checkString(request.getParameter("EditEncounterType"));
    String sEditEncounterBegin = checkString(request.getParameter("EditEncounterBegin"));
    String sEditEncounterBeginHour = checkString(request.getParameter("EditEncounterBeginHour"));
    String sEditEncounterEnd = checkString(request.getParameter("EditEncounterEnd"));
    String sEditEncounterEndHour = checkString(request.getParameter("EditEncounterEndHour"));

    String sEditEncounterService = checkString(request.getParameter("EditEncounterService"));
    String sEditEncounterServiceName = checkString(request.getParameter("EditEncounterServiceName"));

    String sEditEncounterOrigin = checkString(request.getParameter("EditEncounterOrigin"));
    if(sEditEncounterOrigin.length()==0){
    	sEditEncounterOrigin=MedwanQuery.getInstance().getConfigString("defaultEncounterOrigin","");
    }
    String sEditEncounterDestination = checkString(request.getParameter("EditEncounterDestination"));
    String sEditEncounterDestinationName = checkString(request.getParameter("EditEncounterDestinationName"));

    String sEditEncounterBed = checkString(request.getParameter("EditEncounterBed"));
    String sEditEncounterBedName = checkString(request.getParameter("EditEncounterBedName"));

    String sEditEncounterPatient = checkString(request.getParameter("EditEncounterPatient"));
    String sEditEncounterPatientName = checkString(request.getParameter("EditEncounterPatientName"));

    String sEditEncounterManager = checkString(request.getParameter("EditEncounterManager"));
    String sEditEncounterManagerName = checkString(request.getParameter("EditEncounterManagerName"));
    String sEditEncounterOutcome = checkString(request.getParameter("EditEncounterOutcome"));
    String sEditEncounterSituation = checkString(request.getParameter("EditEncounterSituation"));
    String sEditEncounterAccomodationPrestation = checkString(request.getParameter("EditEncounterAccomodationPrestation"));
    String sEditEncounterTransferDate = checkString(request.getParameter("EditEncounterTransferDate"));
    String sEditEncounterTransferHour = checkString(request.getParameter("EditEncounterTransferHour"));
    String sMaxTransferDate="";

    String sAction = checkString(request.getParameter("Action"));
    String sPopup = checkString(request.getParameter("Popup"));
    String sReadOnly = checkString(request.getParameter("ReadOnly"));

    String sAccountAccomodationDays = checkString(request.getParameter("AccountAccomodationDays"));
    if(sEditEncounterUID.length()==0 && sEditEncounterService.length()==0){
        sEditEncounterService=MedwanQuery.getInstance().getConfigString("defaultAdmissionService","");
        if(sEditEncounterService.length()>0){
            Service service = Service.getService(sEditEncounterService);
            sEditEncounterServiceName=service.getLabel(sWebLanguage);
        }
        sEditEncounterManager=MedwanQuery.getInstance().getConfigString("defaultAdmissionManager","");
        if(sEditEncounterManager.length()>0){
            UserVO user = MedwanQuery.getInstance().getUser(sEditEncounterManager);
            sEditEncounterManagerName=user.personVO.firstname.toUpperCase()+" "+user.personVO.lastname.toUpperCase();
        }
        sEditEncounterManager=MedwanQuery.getInstance().getConfigString("defaultAdmissionManager","");
    }

    if (Debug.enabled) {
        Debug.println("\n####################### EDIT PARAMS ###########################" +
                "\nEditEncounterUID     : " + sEditEncounterUID +
                "\nEncounterType        : " + sEditEncounterType +
                "\nEncounterBegin       : " + sEditEncounterBegin +
                "\nEncounterBeginHour   : " + sEditEncounterBeginHour +
                "\nEncounterEnd         : " + sEditEncounterEnd +
                "\nEncounterEndHour     : " + sEditEncounterEndHour +
                "\nEncounterPatient     : " + sEditEncounterPatient +
                "\nEncounterPatientName : " + sEditEncounterPatientName +
                "\nEncounterManager     : " + sEditEncounterManager +
                "\nEncounterManagerName : " + sEditEncounterManagerName +
                "\nEncounterService     : " + sEditEncounterService +
                "\nEncounterServiceName : " + sEditEncounterServiceName +
                "\nEncounterDestination     : " + sEditEncounterDestination +
                "\nEncounterDestinationName : " + sEditEncounterDestinationName +
                "\nEncounterBed         : " + sEditEncounterBed +
                "\nEncounterBedName     : " + sEditEncounterBedName +
                "\nAccountAccomodationDays     : " + sAccountAccomodationDays +
                "\n###############################################################"
        );
    }
    if (sAction.equals("SAVE")) {

        String sCloseActiveEncounter = checkString(request.getParameter("CloseActiveEncounter"));

        if (sCloseActiveEncounter.equals("CLOSE")) {
            if (Debug.enabled) {
                Debug.println("Closing active encounter!");
            }
            Encounter eActiveEncounter = Encounter.getActiveEncounter(activePatient.personid);
            eActiveEncounter.setEnd(ScreenHelper.getSQLDate(sEditEncounterBegin));
            eActiveEncounter.storeWithoutServiceHistory();
        }

        tmpEncounter = new Encounter();

        if (sEditEncounterUID.length() > 0) {//update
            tmpEncounter = Encounter.get(sEditEncounterUID);
        } else {//insert
            tmpEncounter.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }
        tmpEncounter.setType(sEditEncounterType);


        tmpEncounter.setBegin(getDateHour(sEditEncounterBegin, sEditEncounterBeginHour));
        if (sEditEncounterEnd.length() > 0) {
            tmpEncounter.setEnd(getDateHour(sEditEncounterEnd, sEditEncounterEndHour));
        } else {
            tmpEncounter.setEnd(null);
        }
        tmpEncounter.setOutcome(sEditEncounterOutcome);
        tmpEncounter.setSituation(sEditEncounterSituation);

        Service tmpService ;
        Service tmpDestination;
        Bed tmpBed = null;
        AdminPerson tmpPatient;
        tmpService = Service.getService(sEditEncounterService);

        if (sEditEncounterType.equals("admission")) {
            tmpBed = Bed.get(sEditEncounterBed);
        }
        tmpDestination = Service.getService(sEditEncounterDestination);

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        tmpPatient = AdminPerson.getAdminPerson(ad_conn, sEditEncounterPatient);
        ad_conn.close();
        //AdminPerson tmpManager = AdminPerson.getAdminPerson(dbConnection,sEditEncounterManager);

        User tmpManager = new User();
        if (sEditEncounterManager.length() > 0) {
            tmpManager.initialize(Integer.parseInt(sEditEncounterManager));
        }

        if (tmpService == null) {
            tmpService = new Service();
        }
        if (tmpDestination == null) {
            tmpDestination = new Service();
        }
        if (tmpBed == null || sEditEncounterType.equalsIgnoreCase("visit")) {
            tmpBed = new Bed();
        }
        if (tmpPatient == null) {
            tmpPatient = new AdminPerson();
        }
        if (tmpManager == null) {
            tmpManager = new User();
        }

        tmpEncounter.setService(tmpService);
        tmpEncounter.setDestination(tmpDestination);
        tmpEncounter.setBed(tmpBed);
        tmpEncounter.setOrigin(sEditEncounterOrigin);

        tmpEncounter.setPatient(tmpPatient);
        tmpEncounter.setManager(tmpManager);
        tmpEncounter.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        tmpEncounter.setUpdateUser(activeUser.userid);
        tmpEncounter.storeWithoutServiceHistory();


        sEditEncounterUID = checkString(tmpEncounter.getUid());
        if (sPopup.equalsIgnoreCase("yes")) {
%>
            <script>
                var o = window.opener;
                o.location.reload();
                window.close();
            </script>
            <%
        }
        %>
            <script>
                window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
            </script>
        <%
    }
    if(sEditEncounterUID.length() > 0){

        tmpEncounter = Encounter.get(sEditEncounterUID);
		if(tmpEncounter!=null && tmpEncounter.getMaxTransferDate()!=null){
			sMaxTransferDate=ScreenHelper.formatDate(tmpEncounter.getMaxTransferDate());
		}
        sEditEncounterType            = checkString(tmpEncounter.getType());
        sEditEncounterBegin           = checkString(ScreenHelper.formatDate(tmpEncounter.getBegin()));
        sEditEncounterBeginHour           = checkString(new SimpleDateFormat("HH:mm").format(tmpEncounter.getBegin()));

        if(tmpEncounter.getEnd() == null){
            sEditEncounterEnd         = "";
        }else{
            sEditEncounterEnd         = checkString(ScreenHelper.formatDate(tmpEncounter.getEnd()));
            sEditEncounterEndHour     = checkString(new SimpleDateFormat("HH:mm").format(tmpEncounter.getEnd()));
        }

        if(tmpEncounter.getService() == null){
            sEditEncounterService     = "";
            sEditEncounterServiceName = "";
        }else {
            sEditEncounterService     = checkString(tmpEncounter.getService().code);
            sEditEncounterServiceName = checkString(getTran("Service",tmpEncounter.getService().code,sWebLanguage));
        }

        sEditEncounterPatient         = checkString(tmpEncounter.getPatient().personid);
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        sEditEncounterPatientName     = checkString(ScreenHelper.getFullPersonName(tmpEncounter.getPatient().personid,ad_conn));
        ad_conn.close();

        sEditEncounterUID             = checkString(tmpEncounter.getUid());
        if(Debug.enabled){
            Debug.println("####### TEST #######");
            Debug.println(" ServiceUID: " + sEditEncounterService);
            Debug.println(" ServiceName: " + sEditEncounterServiceName);
            Debug.println(" BedUID: " + sEditEncounterBed);
            Debug.println(" BedName: " + sEditEncounterBedName);
        }
    }
    else {
        sEditEncounterType = MedwanQuery.getInstance().getConfigString("defaultEncounterType","visit");
    }

    if(!(sEditEncounterPatient.length() > 0)){
        sEditEncounterPatient         = checkString(activePatient.personid);
    }
    if(!(sEditEncounterBegin.length() >0)){
        sEditEncounterBegin           = getDate();
    }
    if(!(sEditEncounterBeginHour.length() >0)){
        sEditEncounterBeginHour           = new SimpleDateFormat("HH:mm").format(new java.util.Date());
    }
%>
<%
    if(sPopup.equalsIgnoreCase("yes")){
%>
<form name='EditEncounterForm' id="EditEncounterForm" method='POST' action='<c:url value="/adt/template.jsp"/>?Page=editEncounter.jsp&ts=<%=getTs()%>'>
<%
    }else{
%>
<form name='EditEncounterForm' id="EditEncounterForm" method='POST' action='<c:url value="/main.do"/>?Page=adt/editEncounter.jsp&ts=<%=getTs()%>'>
<%
    }
%>
    <%
        String sOther = "";
        if(!sPopup.equalsIgnoreCase("yes")){
            sOther = " doBack();";
        }
    %>
    <%=writeTableHeader("Web.manage","manageEncounters",sWebLanguage,sOther)%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- type --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","type",sWebLanguage)%> *</td>
            <td class='admin2'>
                <select class='text' id='EditEncounterType' name='EditEncounterType' onchange="checkEncounterType();">
                    <%
                        String encountertypes=MedwanQuery.getInstance().getConfigString("encountertypes","admission,visit,coverage");
                        String sOptions[] = encountertypes.split(",");

                        for(int i=0;i<sOptions.length;i++){
                        	if(!sOptions[i].equalsIgnoreCase("coverage")){
	                            out.print("<option value='" + sOptions[i] + "' ");
	                            if(sEditEncounterType.equalsIgnoreCase(sOptions[i])){
	                                out.print(" selected");
	                            }
	                            out.print(">" + getTran("web",sOptions[i],sWebLanguage) + "</option>");
                        	}
                        }

                    %>

                </select>
            </td>
        </tr>
        <%-- date begin --%>
        <tr>
            <td class="admin"><%=getTran("Web","begindate",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeDateField("EditEncounterBegin","EditEncounterForm",sEditEncounterBegin,sWebLanguage)%>
                <input class="text" name="EditEncounterBeginHour" value="<%=sEditEncounterBeginHour%>" size="5" onblur="checkTime(this)" onkeypress="keypressTime(this)">
            </td>
        </tr>
        <%-- date end --%>
        <tr>
            <td class="admin"><%=getTran("Web","enddate",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeDateField("EditEncounterEnd","EditEncounterForm",sEditEncounterEnd,sWebLanguage)%>
                <input class="text" name="EditEncounterEndHour" value="<%=sEditEncounterEndHour%>" size="5" onblur="checkTime(this)" onkeypress="keypressTime(this)">
            </td>
        </tr>
        <script type="text/javascript">
            function setTime(field){
                document.getElementsByName(field)[0].value=new Date().getHours()+":"+new Date().getMinutes();
            }
        </script>
        <input type='hidden' name='EditEncounterPatient' value='<%=sEditEncounterPatient%>'>
        <%-- service --%>
       <tr id="Service">
           <td class="admin"><%=getTran("Web","service",sWebLanguage)%> *</td>
           <td class='admin2'>
               <input type="hidden" name="EditEncounterService" value="<%=sEditEncounterService%>"/>
               <input class="text" type="text" name="EditEncounterServiceName" id="EditEncounterServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditEncounterServiceName%>" onblur="">
               <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('EditEncounterService','EditEncounterServiceName');">
               <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditEncounterForm.EditEncounterService.value='';EditEncounterForm.EditEncounterServiceName.value='';">
           </td>
       </tr>

        <%=ScreenHelper.setFormButtonsStart()%>
            <%
                if(!sReadOnly.equalsIgnoreCase("yes")){
            %>
            <input class='button' type="button" id="saveButton" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <%
                }
                if(!sPopup.equalsIgnoreCase("yes") && !sReadOnly.equalsIgnoreCase("yes")){
            %>
                <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
            <%
                }else{
            %>
                <input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close()'>
            <%
                }
            %>
        <%=ScreenHelper.setFormButtonsStop()%>
        <%-- action, uid --%>
        <input type='hidden' name='Action' value=''>
        <input type='hidden' name='CloseActiveEncounter' value=''>
        <input type='hidden' name='Popup' value='<%=sPopup%>'>
        <input type='hidden' name='EditEncounterUID' value='<%=sEditEncounterUID%>'>
    </table>
    <%-- indication of obligated fields --%>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
</form>
<%
    if (sEditEncounterUID.length()==0){
        Encounter activeEncounter=Encounter.getActiveEncounter(activePatient.personid);
    	if(activeEncounter != null && activeEncounter.getEnd()==null){
            bActiveEncounterStatus = true;
        }else{
            bActiveEncounterStatus = false;
        }

        if(bActiveEncounterStatus){
            %>
                <script>
                    function closeActiveEncounter(){
                        EditEncounterForm.CloseActiveEncounter.value = "CLOSE";
                    }

                    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=adt.encounter&labelID=encounter_close";
                    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("adt.encounter","encounter_close",sWebLanguage)%>");


                    if(answer){
                        window.location.href='<c:url value="/main.do?Page=adt/editEncounter.jsp&EditEncounterUID="/><%=activeEncounter.getUid()%>';
                    }
                    else {
                        history.back();
                    }
                </script>
            <%
        }
    }
%>
<script>
  if(EditEncounterForm.EditEncounterService.value==""){
    EditEncounterForm.SearchBedButton.disabled = true;
  }
  else{
    EditEncounterForm.SearchBedButton.disabled = false;
  }
  checkEncounterType();

  function searchService(serviceUidField,serviceNameField){
    var sNeedsBeds="";
    if(serviceNameField != 'EditEncounterDestinationName'){
      if(document.getElementById("EditEncounterType").value=='admission'){
        sNeedsBeds="&needsbeds=1";
	  }
	  else{
	    sNeedsBeds="&needsvisits=1";
	  }
    }
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField+sNeedsBeds);
    document.getElementById(serviceNameField).focus();
  }

    function doSave(){
		if(EditEncounterForm.EditEncounterBegin.value == ""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_begindate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_begindate",sWebLanguage)%>");
        }else if(ParseDate(EditEncounterForm.EditEncounterBegin.value)>new Date()){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_future_begindate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_future_begindate",sWebLanguage)%>");
        }else if(EditEncounterForm.EditEncounterBeginHour.value == ""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_beginhour";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_beginhour",sWebLanguage)%>");
    <%
      	if (sEditEncounterUID.length()>0){
    %>
        }else if(EditEncounterForm.EditEncounterEnd.value != "" && ParseDate(EditEncounterForm.EditEncounterEnd.value)<ParseDate('<%=sMaxTransferDate%>')){
                var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_wrong_enddate";
                var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_future_begindate",sWebLanguage)%>");
    <%
       	}
    %>        	        
        }else if(EditEncounterForm.EditEncounterEnd.value != "" && EditEncounterForm.EditEncounterEndHour.value == ""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_endhour";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_endhour",sWebLanguage)%>");
        }else if(!checkDates()){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=encounter_invalid_enddate";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","encounter_invalid_enddate",sWebLanguage)%>");
        }else if (EditEncounterForm.EditEncounterServiceName.value==""){
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=no_encounter_service";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","no_encounter_service",sWebLanguage)%>");
        }else{
            EditEncounterForm.saveButton.disabled = true;
            EditEncounterForm.Action.value = "SAVE";
            EditEncounterForm.submit();
        }
        EditEncounterTransferDate
    }

    <%-- back --%>
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
    }

    <%-- check if enddate is after begindate --%>
    function checkDates(){
        if(EditEncounterForm.EditEncounterEnd.value == ""){
            return true;
        }else{
            var end = ParseDate(EditEncounterForm.EditEncounterEnd.value);
            var begin = ParseDate(EditEncounterForm.EditEncounterBegin.value);
            if(end < begin || end>new Date()){
                return false;
            }else{
                return true;
            }
        }
    }

    function ParseDate( str1 ){
      // Parse the string in DD/MM/YYYY format
      re = /(\d{1,2})\/(\d{1,2})\/(\d{4})/
      var arr = re.exec( str1 );
      if(dateFormat=="dd/MM/yyyy"){
        return new Date( parseInt(arr[3]), parseInt(arr[2], 10) - 1, parseInt(arr[1], 10) ); // YYYY/mm/dd
      }
      else{
        return new Date( parseInt(arr[3]), parseInt(arr[1], 10) - 1, parseInt(arr[2], 10) ); // YYYY/dd/mm
      }
    }

    <%-- check type and display right inputfields --%>
    function checkEncounterType(){
    }

    function deleteService(sID){
        if(yesnoDeleteDialog()){
        var params = '';
        var today = new Date();
        var url= '<c:url value="/adt/ajaxActions/editEncounterDeleteService.jsp"/>?EncounterUID=<%=sEditEncounterUID%>&ServiceUID='+sID+'&ts='+today;
        document.getElementById('divServices').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
        new Ajax.Request(url,{
          method: "GET",
          parameters: params,
          onSuccess: function(resp){
            $('divServices').innerHTML=resp.responseText;
          },
          onFailure: function(){
          }
        });
      }
    }
</script>