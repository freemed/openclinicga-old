<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%=sJSSORTTABLE%>

<%!
    //--- ADD FAMILY RELATION ------------------------------------------------------------------------------------------
    private String addFR(int iTotal, String sourceId, String destinationId, String relationType, String sWebLanguage, AdminPerson activePatient){
        // alternate row-style
        String sClass;
        if(iTotal%2==0) sClass = "list1";
        else            sClass = "list";

        // get names
        String sSourceFullName      = ScreenHelper.getFullPersonName(sourceId+""),
               sDestinationFullName = ScreenHelper.getFullPersonName(destinationId+""),
               sRelationType        = getTran("admin.familyrelation",relationType,sWebLanguage);

        String detailsTran = getTran("web","showdetails",sWebLanguage);
        StringBuffer buf = new StringBuffer();
        buf.append("<tr id='rowFR"+iTotal+"' class='"+sClass+"'>")
            .append("<td align='center'>");

        if(sourceId.equals(activePatient.personid)){
        	buf.append("<a href='#' onclick=\"deleteFR(rowFR"+iTotal+");\">")
                .append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' alt='").append(getTran("Web","delete",sWebLanguage)).append("' border='0'>")
               .append("</a>");
        }        
             
        buf.append("</td>")
            .append("<td>&nbsp;"+sSourceFullName+"</td>")
            .append("<td title='"+detailsTran+"'>&nbsp;<a href=\"javascipt:showDossier('"+destinationId+"');\"'>"+sDestinationFullName+"</a></td>")
            .append("<td>&nbsp;"+sRelationType+"</td>")
           .append("</tr>");

        return buf.toString();
    }
%>
<script>var relationsArray = new Array();</script>

<%
    if(activePatient!=null){
        // variables
        String sTmpSourceId, sTmpDestinationId, sTmpRelationtype;
        AdminFamilyRelation relation;
        String sFR = "", sDivFR = "";
        int iTotal = 1;

        // get saved relations from DB
        for(int i=0; i<activePatient.familyRelations.size(); i++){
            relation = (AdminFamilyRelation)activePatient.familyRelations.get(i);

            sTmpSourceId      = relation.sourceId;
            sTmpDestinationId = relation.destinationId;
            sTmpRelationtype  = relation.relationType;

            // compose sLA
            sFR+= "rowFR"+iTotal+"="+sTmpSourceId+"£"+sTmpDestinationId+"£"+sTmpRelationtype+"$";
            sDivFR+= addFR(iTotal,sTmpSourceId,sTmpDestinationId,sTmpRelationtype,sWebLanguage,activePatient);
            iTotal++;
        }

        %>
            <%-- RELATIONS ----------------------------------------------------------------------%>
            <table id="tblFR" width="100%" cellspacing="0" class="sortable" style="border-top:none;">
                <%-- HEADER --%>
                <tr class="admin">
                    <td width="25" nowrap/>
                    <td width="20%"><%=getTran("web.admin","sourceperson",sWebLanguage)%></td>
                    <td width="20%"><%=getTran("web.admin","destinationperson",sWebLanguage)%></td>
                    <td width="60%"><%=getTran("web.admin","relationtype",sWebLanguage)%></td>
                </tr>
                <%-- chosen relations --%>
                <%=sDivFR%>
            </table>
            <%
                if(sDivFR.length() > 0){
                    %>
                        <br>
                        <div id="msg"/>
                    <%
                }
                else{
                    %><div id="msg"><%=getTran("web","nofamilyrelationsfound",sWebLanguage)%></div><%
                }
            %>
            <br>
            
            <%-- ADD ROW ------------------------------------------------------------------------%>
            <table width="100%" cellspacing="1" class="list">
                <%-- HEADER --%>
                <tr class="admin">
                    <td colspan="2">&nbsp;<%=getTran("web.admin","addfamilyrelation",sWebLanguage)%></td>
                </tr>
                
                <%-- source id --%>
                <input type="hidden" name="RSourceId" value="<%=activePatient.personid%>">
                
                <%-- destination id --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.admin","destinationperson",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input type="hidden" name="RDestinationId" value="">
                        <input class="text" type="text" name="RDestinationFullName" readonly size="<%=sTextWidth%>" value="">

                        <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="doSearchPatient('RDestinationId','RDestinationFullName');">
                        <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="PatientEditForm.RDestinationId.value='';PatientEditForm.RDestinationFullName.value='';">
                    </td>
                </tr>
                
                <%-- relation type --%>
                <tr>
                    <td class="admin"><%=getTran("Web.admin","relationType",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <select class="text" name="RRelationType">
                            <option><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                            <%=ScreenHelper.writeSelect("admin.familyrelation","",sWebLanguage)%>
                        </select>
                    </td>
                </tr>
                
                <%-- BUTTONS --%>
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                        <input type="button" class="button" value="<%=getTranNoLink("web","add",sWebLanguage)%>" name="addButton" onClick="addFR();"/>&nbsp;
                        <input type="button" class="button" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" name="clearButton" onClick="clearAddFields();"/>
                    </td>
                </tr>
            </table>
            
            <input type="hidden" name="familyRelations" value="">
            
            <i><%=getTran("web","familyRelationInfo",sWebLanguage)%></i>
            
            <script>
              var iIndexFR = <%=iTotal%>;
              var sFR = "<%=sFR%>";

              <%-- check submit --%>
              function checkSubmitAdminFamilyRelation(){
                <%-- remove row id --%>
                while(sFR.indexOf("rowFR") > -1){
                  var sTmpBegin = sFR.substring(sFR.indexOf("rowFR"));
                  var sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
                  sFR = sFR.substring(0,sFR.indexOf("rowFR"))+sTmpEnd;
                }
                PatientEditForm.familyRelations.value = sFR;
                return true;
              }

              <%-- clear add fields --%>
              function clearAddFields(){
                PatientEditForm.RDestinationFullName.value = "";
                PatientEditForm.RDestinationId.value = "";

                PatientEditForm.RRelationType.selectedIndex = 0;
              }

              <%-- ADD FAMILY RELATION --%>
              function addFR(){
                var sourceId      = PatientEditForm.RSourceId.value;
                var destinationId = PatientEditForm.RDestinationId.value;
                var relationType  = PatientEditForm.RRelationType.value;

                if(destinationId.length > 0 && relationType.length > 0){
                  if(destinationId=="<%=activePatient.personid%>"){                    
                    alertDialog("web.manage","destinationpersonmaynotequalpatient");

                    PatientEditForm.RDestinationId.value = "";
                    PatientEditForm.RDestinationFullName.value = "";
                    PatientEditForm.RDestinationFullName.focus();
                  }
                  else if(sourceId==destinationId){
                    alertDialog("web.manage","identicalpersonsnotallowed");
                    PatientEditForm.RSourceFullName.focus();
                  }
                  // add
                  else if(!allreadySelected(sourceId,destinationId,relationType)){
                      document.getElementById("msg").style.visibility = "hidden";

                      sFR+= "rowFR"+iIndexFR+"="+sourceId+"£"+destinationId+"£"+relationType+"$";
                      var row = tblFR.insertRow(tblFR.rows.length);
                      row.id = "rowFR"+iIndexFR;

                      if((tblFR.rows.length-1)%2==0) row.className = "list1";
                      else                           row.className = "list";

                      <%-- insert cells in row --%>
                      for(var i=0; i<4; i++){
                        row.insertCell(i);
                      }

                      row.cells[0].innerHTML = "<center><a href='javascript:deleteFR(rowFR"+iIndexFR+");'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' border='0'></a></center>";

                      <%-- default data --%>
                      row.cells[1].innerHTML = "<%=activePatient.firstname+" "+activePatient.lastname%>";
                      row.cells[2].innerHTML = PatientEditForm.RDestinationFullName.value;

                      <%-- translate gender --%>
                      if(relationType == "childparent"){
                        row.cells[3].innerHTML = "<%=getTran("admin.familyrelation","childparent",sWebLanguage)%>";
                      }
                      else if(relationType == "brothersister"){
                        row.cells[3].innerHTML = "<%=getTran("admin.familyrelation","brothersister",sWebLanguage)%>";
                      }
                      else if(relationType == "husbandwife"){
                        row.cells[3].innerHTML = "<%=getTran("admin.familyrelation","husbandwife",sWebLanguage)%>";
                      }
                      else{
                        row.cells[3].innerHTML = "";
                      }

                      iIndexFR++;
                      relationsArray[relationsArray.length] = new Array(sourceId,destinationId,relationType);
                      PatientEditForm.familyRelations.value = sFR;
                      clearAddFields();
                  }
                }
                // data missing
                else{                    
                  alertDialog("web.manage","datamissing");

                  if(PatientEditForm.RDestinationId.value.length==0){
                    PatientEditForm.RDestinationFullName.focus();
                  }
                  else if(PatientEditForm.RRelationType.value.length==0){
                    PatientEditForm.RRelationType.focus();
                  }
                }
              }

              <%-- INIT RELATIONS ARRAY --%>
              function initRelationsArray(sArray){
                relationsArray = new Array();

                if(sArray!=""){
                  var sOneFR;
                  for(var i=0; i<iIndexFR-1; i++){
                    sOneFR = getRowFromArrayString(sFR,"rowFR"+(i+1));
                    if(sOneFR!=""){
                      var oneFR = sOneFR.split("£");
                      relationsArray.push(oneFR);
                    }
                  }
                }
              }

              <%-- ALLREADY SELECTED --%>
              function allreadySelected(sourceId,destinationId,relationType){
                for(var i=0; i<relationsArray.length; i++){
                  if(relationsArray[i][0] == sourceId &&
                     relationsArray[i][1] == destinationId &&
                     relationsArray[i][2] == relationType){
                    return true;
                  }
                }
                return false;
              }

              <%-- GET ROW FROM ARRAY STRING --%>
              function getRowFromArrayString(sArray,rowid){
                var array = sArray.split("$");
                var row = "";
                for(var i=0; i<array.length; i++){
                  if(array[i].indexOf(rowid)>-1){
                    row = array[i].substring(array[i].indexOf("=")+1);
                    break;
                  }
                }
                return row;
              }

              <%-- DELETE ROW FROM ARRAY STRING --%>
              function deleteRowFromArrayString(sArray,rowid){
                var array = sArray.split("$");
                for(var i=0; i<array.length; i++){
                  if(array[i].indexOf(rowid) > -1){
                    array.splice(i,1);
                  }
                }
                return array.join("$");
              }

              <%-- DELETE ALL FAMILY RELATIONS --%>
              function deleteAllFR(){
                if(tblFR.rows.length > 1){
                  if(yesnoDialog("Web","areYouSureToDelete")){
                    deleteAllFRNoConfirm();
                  }
                }
              }

              <%-- CLEAR ALL FAMILY RELATIONS --%>
              function deleteAllFRNoConfirm(){
                if(tblFR.rows.length > 1){
                  var len = tblFR.rows.length;
                  for(var i=len-1; i!=0; i--){
                    tblFR.deleteRow(i);
                  }

                  sFR = "";
                  initRelationsArray("");
                }
              }

              <%-- UPDATE ROW STYLES (especially after sorting) --%>
              function updateRowStyles(){
                for(var i=1; i<tblFR.rows.length; i++){
                  tblFR.rows[i].style.cursor = "hand";

                  if(i%2>0) tblFR.rows[i].className = "list";
                  else      tblFR.rows[i].className = "list1";
                }
              }

              initRelationsArray(sFR);

              <%-- DELETE FAMILY RELATION --%>
              function deleteFR(rowid){
            	if(yesnoDialog("Web","areYouSureToDelete")){
                  sFR = deleteRowFromArrayString(sFR,rowid.id);
                  initRelationsArray(sFR);
                  tblFR.deleteRow(rowid.rowIndex);
                  updateRowStyles();
                }
              }

              <%-- popup : search patient --%>
              function doSearchPatient(patientUidField,patientNameField){
                openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+patientUidField+"&ReturnName="+patientNameField+"&displayImmatNew=no&isUser=no");
              }

              <%-- SHOW DOSSIER --%>
              function showDossier(personid){
                document.location.href = "<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID="+personid+"&ts=<%=getTs()%>";
              }
            </script>
        <%
    }
%>