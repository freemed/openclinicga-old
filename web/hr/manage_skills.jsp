<%@page import="be.openclinic.hr.Skill,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.skill.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<script src="<%=sCONTEXTPATH%>/hr/includes/commonFunctions.js"></script>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** manage_skills.jsp ****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>  

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditSkillUid" name="EditSkillUid" value="-1">
    
    <%=writeTableHeader("web","skills",sWebLanguage,"")%>
                    
    <table class="list" border="0" width="100%" cellspacing="1">   
        <%-- *** languages (multi-add) *** --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","languages",sWebLanguage)%></td>
            <td class="admin2" style="padding:10px;padding-left:5px;">
                <input type="hidden" id="languages" name="languages" value="">
                                        
                <table width="100%" class="sortable" id="tblLS" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - language --%>
                        <td style="padding-left:0px;">
                            <%=getTran("web.hr","languages.language",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>
                        <%-- 2 - spoken --%>
                        <td style="padding-left:0px;">
                            <%=getTran("web.hr","languages.spoken",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 3 - reading --%>
                        <td style="padding-left:0px;">
                            <%=getTran("web.hr","languages.reading",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 4 - writing --%>
                        <td style="padding-left:0px;">
                            <%=getTran("web.hr","languages.writing",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 5 - empty --%>
                        <td nowrap/>    
                    </tr>
                                        
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - language --%>
                        <td class="admin">
                            <select class="text" id="lsLanguage" name="lsLanguage">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.skills.languages","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>
                        <%-- 2 - spoken --%>
                        <td class="admin">
                            <select class="text" id=lsSpoken name="lsSpoken">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.skills.range1","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>    
                        <%-- 3 - reading --%>
                        <td class="admin">
                            <select class="text" id="lsReading" name="lsReading">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.skills.range1","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>    
                        <%-- 4 - writing --%>
                        <td class="admin">
                            <select class="text" id="lsWriting" name="lsWriting">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.skills.range1","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>
                        <%-- 5 - buttons --%>
                        <td class="admin" nowrap>
                            <input type="button" class="button" name="ButtonAddLS" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addLS();">
                            <input type="button" class="button" name="ButtonUpdateLS" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateLS();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                
            </td>
        </tr>
                                            
        <%-- drivingLicense --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","drivingLicense",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="drivingLicense" name="drivingLicense">
                    <option/>
                    <%=ScreenHelper.writeSelectUnsorted("hr.skills.drivinglicense","",sWebLanguage)%>
                </select>
            </td>
        </tr>
                                            
        <%-- *** computerSkills *** --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","computerSkills",sWebLanguage)%></td>
            <td class="admin2" style="padding:10px;padding-left:5px;">
                <table class="list" cellpadding="0" cellspacing="1">
                    <%-- 1 : Office applications --%>
                    <tr>
                        <td class="admin"><%=getTran("web.hr","itOffice",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" id="itOffice" name="itOffice">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.skills.range1","",sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    
                    <%-- 2 : Internet and e-mail --%>
                    <tr>
                        <td class="admin"><%=getTran("web.hr","itInternet",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <select class="text" id="itInternet" name="itInternet">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.skills.range1","",sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    
                    <%-- 3 : Other applications --%>
                    <tr>
                        <td class="admin"><%=getTran("web.hr","itOther",sWebLanguage)%>&nbsp;</td>
                        <td class="admin2">
                            <textarea class="text" id="itOther" name="itOther" cols="60" rows="3" onKeyup="resizeTextarea(this,8);"></textarea>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
                                            
        <%-- communicationSkills --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","communicationSkills",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="communicationSkills" name="communicationSkills">
                    <option/>
                    <%=ScreenHelper.writeSelectUnsorted("hr.skills.range2","",sWebLanguage)%>
                </select>
            </td>
        </tr>
                                            
        <%-- stressResistance --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","stressResistance",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="stressResistance" name="stressResistance">
                    <option/>
                    <%=ScreenHelper.writeSelectUnsorted("hr.skills.range2","",sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- comment --%>                    
        <tr>
            <td class="admin"><%=getTran("web.hr","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment" id="comment" cols="82" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveSkill();">&nbsp;
                <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSkill();">
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE SKILL --%>
  function saveSkill(){
    var maySubmit = true;
    if(maySubmit && EditForm.lsLanguage.value.length > 0){
      if(!addLS()){
        maySubmit = false;
      }
    }
    if(maySubmit){
      <%-- compose string containing language skills --%>
      var sTmpBegin, sTmpEnd;
      while(sLS.indexOf("rowLS") > -1){
        sTmpBegin = sLS.substring(sLS.indexOf("rowLS"));
        sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
        sLS = sLS.substring(0,sLS.indexOf("rowLS"))+sTmpEnd;
      }
      document.getElementById("languages").value = sLS.substring(0,255);
       
      document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
      var url = "<c:url value='/hr/ajax/skills/saveSkill.jsp'/>?ts="+new Date().getTime();
      
      <%-- disable buttons --%>
      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonClear").disabled = true;
      
      new Ajax.Request(url,
        {
          method: "POST",
          postBody: "EditSkillUid="+(EditForm.EditSkillUid.value.length > 0?EditForm.EditSkillUid.value:"-1")+
                    "&PersonId=<%=activePatient.personid%>"+                        
                    "&languages="+document.getElementById("languages").value+
                    "&drivingLicense="+document.getElementById("drivingLicense").value+
                    "&itOffice="+document.getElementById("itOffice").value+
                    "&itInternet="+document.getElementById("itInternet").value+
                    "&itOther="+document.getElementById("itOther").value+
                    "&communicationSkills="+document.getElementById("communicationSkills").value+
                    "&stressResistance="+document.getElementById("stressResistance").value+
                    "&comment="+document.getElementById("comment").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;
                      
            EditForm.EditSkillUid.value = data.newUid;
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonClear").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/skills/saveSkill.jsp' : "+resp.responseText.trim();
          }
        }
      );
    }
  }
    
  <%-- DISPLAY SKILL --%>
  function displaySkill(){          
    var url = "<c:url value='/hr/ajax/skills/getSkill.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "PersonId=<%=activePatient.personid%>",
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");

          $("EditSkillUid").value = data.skillUid;
          $("languages").value = data.languages.unhtmlEntities();
          displayLanguageSkills();
          
          $("drivingLicense").value = data.drivingLicense.unhtmlEntities();
          $("itOffice").value = data.itOffice;
          $("itInternet").value = data.itInternet;
          $("itOther").value = replaceAll(data.itOther,"<br>","\n");
          $("communicationSkills").value = data.communicationSkills.unhtmlEntities();
          $("stressResistance").value = data.stressResistance;
          $("comment").value = replaceAll(data.comment.unhtmlEntities(),"<br>","\n");
                        
          document.getElementById("divMessage").innerHTML = ""; 
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonSave").style.visibility = "visible";
          document.getElementById("buttonClear").style.visibility = "visible";
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/skills/getSkill.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- CLEAR SKILL --%>
  function clearSkill(){
    var answer = confirmDialog("web","areYouSureToClear");
    if(answer==1){                 
      $("languages").value = "";
      $("drivingLicense").value = "";
      $("itOffice").value = "";
      $("itInternet").value = "";
      $("itOther").value = "";
      $("communicationSkills").value = "";
      $("stressResistance").value = "";
      $("comment").value = "";
    
      resizeAllTextareas(8);
    }
  }

  EditForm.ButtonUpdateLS.disabled = true;
  
  displaySkill();
  resizeAllTextareas(8);

  <%-- LANGUAGE SKILL FUNCTIONS -----------------------------------------%>
  var editLSRowid = "", iLSIndex = 1, sLS = "";

  <%-- DISPLAY LANGUAGE SKILLS --%>
  function displayLanguageSkills(){
    sLS = EditForm.languages.value;

    if(sLS.indexOf("|") > -1){
      var sTmpLS = sLS;
      sLS = "";
      
      var sTmpLang, sTmpSpoken, sTmpReading, sTmpWriting;

      while(sTmpLS.indexOf("$") > -1){
        sTmpLang = "";
        sTmpSpoken = "";
        sTmpReading = "";
        sTmpWriting = "";
        
        if(sTmpLS.indexOf("|") > -1){
          sTmpLang = sTmpLS.substring(0,sTmpLS.indexOf("|"));
          sTmpLS = sTmpLS.substring(sTmpLS.indexOf("|")+1);
        }
            
        if(sTmpLS.indexOf("|") > -1){
          sTmpSpoken = sTmpLS.substring(0,sTmpLS.indexOf("|"));
          sTmpLS = sTmpLS.substring(sTmpLS.indexOf("|")+1);
        }
            
        if(sTmpLS.indexOf("|") > -1){
          sTmpReading = sTmpLS.substring(0,sTmpLS.indexOf("|"));
          sTmpLS = sTmpLS.substring(sTmpLS.indexOf("|")+1);
        }

        if(sTmpLS.indexOf("$") > -1){
          sTmpWriting = sTmpLS.substring(0,sTmpLS.indexOf("$"));
          sTmpLS = sTmpLS.substring(sTmpLS.indexOf("$")+1);
        }

        sLS+="rowLS"+iLSIndex+"="+sTmpLang+"|"+
                                  sTmpSpoken+"|"+
                                  sTmpReading+"|"+
                                  sTmpWriting+"$";
        displayLanguageSkill(iLSIndex++,sTmpLang,sTmpSpoken,sTmpReading,sTmpWriting);
      }
    }
  }
  
  <%-- DISPLAY LANGUAGE SKILL --%>
  function displayLanguageSkill(iLSIndex,sTmpLang,sTmpSpoken,sTmpReading,sTmpWriting){
    var tblLS = document.getElementById("tblLS"); // FF
    var tr = tblLS.insertRow(tblLS.rows.length);
    tr.id = "rowLS"+iLSIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteLS(rowLS"+iLSIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editLS(rowLS"+iLSIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
         if(sTmpLang=="lang1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang1",sWebLanguage)%>";
    else if(sTmpLang=="lang2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang2",sWebLanguage)%>";
    else if(sTmpLang=="lang3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang3",sWebLanguage)%>";
    else if(sTmpLang=="lang4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang4",sWebLanguage)%>";
    else if(sTmpLang=="lang5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang5",sWebLanguage)%>";
    else if(sTmpLang=="lang6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang6",sWebLanguage)%>";
    else if(sTmpLang=="lang7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang7",sWebLanguage)%>";
    tr.appendChild(td);

    td = tr.insertCell(2);
         if(sTmpSpoken=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
    else if(sTmpSpoken=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
    else if(sTmpSpoken=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
    else if(sTmpSpoken=="type4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
    else if(sTmpSpoken=="type5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
    else if(sTmpSpoken=="type6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
    else if(sTmpSpoken=="type7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
    tr.appendChild(td);

    td = tr.insertCell(3);
         if(sTmpReading=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
    else if(sTmpReading=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
    else if(sTmpReading=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
    else if(sTmpReading=="type4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
    else if(sTmpReading=="type5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
    else if(sTmpReading=="type6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
    else if(sTmpReading=="type7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
    tr.appendChild(td);

    td = tr.insertCell(4);
         if(sTmpWriting=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
    else if(sTmpWriting=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
    else if(sTmpWriting=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
    else if(sTmpWriting=="type4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
    else if(sTmpWriting=="type5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
    else if(sTmpWriting=="type6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
    else if(sTmpWriting=="type7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
    tr.appendChild(td);
      
    <%-- empty cell --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iLSIndex);
  }
  
  <%-- ADD LANGUAGE SKILL --%>
  function addLS(){
    if(isAtLeastOneLSFieldFilled() && EditForm.lsLanguage.value.length > 0){
      if(sLS.indexOf(EditForm.lsLanguage.value) > -1){
        alertDialog("web.hr","languageAlreadySelected");            
        EditForm.lsLanguage.focus();
      }
      else{
        iLSIndex++;

        <%-- update arrayString --%>
        sLS+="rowLS"+iLSIndex+"="+EditForm.lsLanguage.value+"|"+
                                  EditForm.lsSpoken.value+"|"+
                                  EditForm.lsReading.value+"|"+
                                  EditForm.lsWriting.value+"$";

        var tblLS = document.getElementById("tblLS"); // FF
        var tr = tblLS.insertRow(tblLS.rows.length);
        tr.id = "rowLS"+iLSIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteLS(rowLS"+iLSIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editLS(rowLS"+iLSIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
             if(EditForm.lsLanguage.value=="lang1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang1",sWebLanguage)%>";
        else if(EditForm.lsLanguage.value=="lang2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang2",sWebLanguage)%>";
        else if(EditForm.lsLanguage.value=="lang3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang3",sWebLanguage)%>";
        else if(EditForm.lsLanguage.value=="lang4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang4",sWebLanguage)%>";
        else if(EditForm.lsLanguage.value=="lang5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang5",sWebLanguage)%>";
        else if(EditForm.lsLanguage.value=="lang6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang6",sWebLanguage)%>";
        else if(EditForm.lsLanguage.value=="lang7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang7",sWebLanguage)%>";
        tr.appendChild(td);

        td = tr.insertCell(2);
             if(EditForm.lsSpoken.value=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
        else if(EditForm.lsSpoken.value=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
        else if(EditForm.lsSpoken.value=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
        else if(EditForm.lsSpoken.value=="type4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
        else if(EditForm.lsSpoken.value=="type5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
        else if(EditForm.lsSpoken.value=="type6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
        else if(EditForm.lsSpoken.value=="type7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
        tr.appendChild(td);

        td = tr.insertCell(3);
             if(EditForm.lsReading.value=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
        else if(EditForm.lsReading.value=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
        else if(EditForm.lsReading.value=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
        else if(EditForm.lsReading.value=="type4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
        else if(EditForm.lsReading.value=="type5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
        else if(EditForm.lsReading.value=="type6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
        else if(EditForm.lsReading.value=="type7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
        tr.appendChild(td);

        td = tr.insertCell(4);
             if(EditForm.lsWriting.value=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
        else if(EditForm.lsWriting.value=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
        else if(EditForm.lsWriting.value=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
        else if(EditForm.lsWriting.value=="type4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
        else if(EditForm.lsWriting.value=="type5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
        else if(EditForm.lsWriting.value=="type6") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
        else if(EditForm.lsWriting.value=="type7") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
        tr.appendChild(td);
      
        <%-- empty cell --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iLSIndex);
      
        <%-- reset --%>
        clearLSFields()
        EditForm.ButtonUpdateLS.disabled = true;
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
   
      if(EditForm.lsLanguage.value.length==0) EditForm.lsLanguage.focus();
      else                                    EditForm.lsSpoken.focus();
    }
    
    return true;
  }

  <%-- UPDATE LANGUAGE SKILL --%>
  function updateLS(){
    if(isAtLeastOneLSFieldFilled() && EditForm.lsLanguage.value.length > 0){
      <%-- update arrayString --%>
      var newRow = editLSRowid.id+"="+EditForm.lsLanguage.value+"|"+
                                      EditForm.lsSpoken.value+"|"+
                                      EditForm.lsReading.value+"|"+
                                      EditForm.lsWriting.value;

      sLS = replaceRowInArrayString(sLS,newRow,editLSRowid.id);

      <%-- update table object --%>
      var tblLS = document.getElementById("tblLS"); // FF
      var row = tblLS.rows[editLSRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='javascript:deleteLS("+editLSRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                               "</a> "+
                               "<a href='javascript:editLS("+editLSRowid.id+")'>"+
                                "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                               "</a>";

           if(EditForm.lsLanguage.value=="lang1") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang1",sWebLanguage)%>";
      else if(EditForm.lsLanguage.value=="lang2") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang2",sWebLanguage)%>";
      else if(EditForm.lsLanguage.value=="lang3") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang3",sWebLanguage)%>";
      else if(EditForm.lsLanguage.value=="lang4") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang4",sWebLanguage)%>";
      else if(EditForm.lsLanguage.value=="lang5") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang5",sWebLanguage)%>";
      else if(EditForm.lsLanguage.value=="lang6") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang6",sWebLanguage)%>";
      else if(EditForm.lsLanguage.value=="lang7") row.cells[1].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.languages","lang7",sWebLanguage)%>";
      
           if(EditForm.lsSpoken.value=="type1")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value=="type2")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value=="type3")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value=="type4")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value=="type5")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value=="type6")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value=="type7")  row.cells[2].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
      else if(EditForm.lsSpoken.value.length==0) row.cells[2].innerHTML = "&nbsp;";
     
           if(EditForm.lsReading.value=="type1")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
      else if(EditForm.lsReading.value=="type2")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
      else if(EditForm.lsReading.value=="type3")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
      else if(EditForm.lsReading.value=="type4")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
      else if(EditForm.lsReading.value=="type5")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
      else if(EditForm.lsReading.value=="type6")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>";
      else if(EditForm.lsReading.value=="type7")  row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>";
      else if(EditForm.lsReading.value.length==0) row.cells[3].innerHTML = "&nbsp;";

           if(EditForm.lsWriting.value=="type1")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type1",sWebLanguage)%>";
      else if(EditForm.lsWriting.value=="type2")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type2",sWebLanguage)%>";
      else if(EditForm.lsWriting.value=="type3")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type3",sWebLanguage)%>";
      else if(EditForm.lsWriting.value=="type4")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type4",sWebLanguage)%>";
      else if(EditForm.lsWriting.value=="type5")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type5",sWebLanguage)%>";
      else if(EditForm.lsWriting.value=="type6")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type6",sWebLanguage)%>"; 
      else if(EditForm.lsWriting.value=="type7")  row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.skills.range1","type7",sWebLanguage)%>"; 
      else if(EditForm.lsWriting.value.length==0) row.cells[4].innerHTML = "&nbsp;";

      <%-- empty cell --%>
      row.cells[5].innerHTML = "&nbsp;";

      <%-- reset --%>
      clearLSFields();
      EditForm.ButtonUpdateLS.disabled = true;
    }
    else{
      alertDialog("web.manage","dataMissing");

      if(EditForm.lsLanguage.value.length==0) EditForm.lsLanguage.focus();
      else                                    EditForm.lsSpoken.focus();
    }
  }

  <%-- IS AT LEAST ONE LS FIELD FILLED --%>
  function isAtLeastOneLSFieldFilled(){
    //if(EditForm.lsLanguage.value.length > 0) return true;
    if(EditForm.lsSpoken.value.length > 0) return true;
    if(EditForm.lsReading.value.length > 0) return true;
    if(EditForm.lsWriting.value.length > 0) return true;
    
    return false;
  }

  <%-- CLEAR LS FIELDS --%>
  function clearLSFields(){
    EditForm.lsLanguage.value = "";
    EditForm.lsSpoken.value = "";
    EditForm.lsReading.value = "";
    EditForm.lsWriting.value = "";
  }

  <%-- DELETE LANGUAGE SKILL --%>
  function deleteLS(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete"); 
    if(answer==1){
      sLS = deleteRowFromArrayString(sLS,rowid.id);
      tblLS.deleteRow(rowid.rowIndex);
      clearLSFields();
    }
  }

  <%-- EDIT LANGUAGE SKILL --%>
  function editLS(rowid){
    var row = getRowFromArrayString(sLS,rowid.id);
    
    EditForm.lsLanguage.value = getCelFromRowString(row,0);
    EditForm.lsSpoken.value   = getCelFromRowString(row,1);
    EditForm.lsReading.value  = getCelFromRowString(row,2);
    EditForm.lsWriting.value  = getCelFromRowString(row,3);

    editLSRowid = rowid;
    EditForm.ButtonUpdateLS.disabled = false;
  }
</script>