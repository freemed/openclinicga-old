<%@page import="be.openclinic.hr.*,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("hr.career.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    String sEditCareerUid = checkString(request.getParameter("EditCareerUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("");
        Debug.println("***************** manage_career.jsp *****************");
        Debug.println("sEditCareerUid : "+sEditCareerUid);
        Debug.println("");
    }
    ///////////////////////////////////////////////////////////////////////////

    Career career;
    String sCareerID, sPatientId = "";

    if(sEditCareerUid.length() > 0){
        career = Career.get(sEditCareerUid);
        
        if(career!=null){
            sCareerID = checkString(career.getUid());
            sPatientId = career.personUid;
            
            if(request.getParameter("LoadPatientId")!=null && (activePatient==null || !sPatientId.equalsIgnoreCase(activePatient.personid))){
                if(activePatient==null){
                    activePatient = new AdminPerson();
                    session.setAttribute("activePatient",activePatient);
                }
                activePatient.initialize(sPatientId);
                
                %><script>window.location.href = "<c:url value='/main.do'/>?Page=hr/manage_career.jsp&ts=<%=getTs()%>&EditCareerUID=<%=sCareerID%>";</script><%
                out.flush();
            }
        }
        else{
            out.println(getTran("web","career.does.not.exist",sWebLanguage)+": "+sEditCareerUid);
        }
    }
    else{
        // blank career
        career = new Career();
        sPatientId = activePatient.personid;
    }
    
    if(career!=null){
%>            
	<%=writeTableHeader("web","career",sWebLanguage,"")%><br>
    <div id="divCareers" class="searchResults" style="height:160px;"></div>
    
    <form name="EditForm" id="EditForm" method="POST">
        <input type="hidden" id="EditCareerUid" name="EditCareerUid" value="<%=checkString(career.getUid())%>">
                    
        <table class="list" border="0" width="100%" cellspacing="1">
            <%-- begin & end date --%>
            <tr>
                <td class="admin" nowrap><%=getTran("web.hr","careerBegin",sWebLanguage)%>&nbsp;* - <%=getTran("web.hr","end",sWebLanguage)%></td>
                <td class="admin2">
                    <%=writeDateField("careerBegin","EditForm",ScreenHelper.getSQLDate(career.begin),sWebLanguage)%>&nbsp;&nbsp;<%=getTran("web","until",sWebLanguage)%>&nbsp;&nbsp; 
                    <%=writeDateField("careerEnd","EditForm",ScreenHelper.getSQLDate(career.begin),sWebLanguage)%>            
                </td>                        
            </tr>
            
            <%-- position --%>
            <tr>
                <td class="admin" nowrap><%=getTran("web.hr","position",sWebLanguage)%>&nbsp;*&nbsp;</td>
                <td class="admin2">
                    <input type="text" class="text" id="position" name="position" size="50" maxLength="255" value="<%=checkString(career.position)%>">
                </td>
            </tr>
                                    
            <%-- department (service) --%>
            <%
                String sServiceName = "";
                if(checkString(career.serviceUid).length() > 0){
                    getTran("service",checkString(career.serviceUid),sWebLanguage);                
                }
            %>
            <tr>
                <td class="admin"><%=getTran("web","service",sWebLanguage)%>&nbsp;*&nbsp;</td>
                <td class="admin2">
                       <input type="hidden" name="service" id="service" value="<%=checkString(career.serviceUid)%>">
                       <input type="text" class="text" name="serviceName" id="serviceName" readonly size="<%=sTextWidth%>" value="<%=sServiceName%>">
                       
                       <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("web","select",sWebLanguage)%>" onclick="searchService('service','serviceName');">
                       <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("web","clear",sWebLanguage)%>" onclick="document.getElementById('service').value='';document.getElementById('serviceName').value='';">
                </td>
            </tr>
            
            <%-- grade --%>
            <tr>
                <td class="admin" nowrap><%=getTran("web.hr","grade",sWebLanguage)%></td>
                <td class="admin2">
                    <select class="text" id="grade" name="grade">
                        <option/>
                        <%=ScreenHelper.writeSelect("hr.grade",checkString(career.grade),sWebLanguage)%>
                    </select>
                </td>
            </tr>
                
            <%-- status --%>
            <tr>
                <td class="admin" nowrap><%=getTran("web.hr","status",sWebLanguage)%></td>
                <td class="admin2">
                    <select class="text" id="status" name="status"> 
                        <option/>
                        <%=ScreenHelper.writeSelect("hr.status",checkString(career.status),sWebLanguage)%>
                    </select>
                </td>
            </tr>
            
            <%-- comment --%>                    
            <tr>
                <td class="admin" nowrap><%=getTran("web.hr","comment",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea class="text" name="comment" cols="55" rows="4"><%=checkString(career.comment)%></textarea>
                </td>
            </tr>
                
            <%-- BUTTONS --%>
            <tr>     
                <td class="admin"/>
                <td class="admin2" colspan="2">
                    <input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveCareer();">&nbsp;
                    <input class="button" type="button" name="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteCareer();">&nbsp;
                    <input class="button" type="button" name="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newCareer();">&nbsp;
                    
                    <%                    
                        // delete button for existing invoices
                        if(checkString(career.getUid()).length()==0){
                            %>
                                <script>
                                  document.getElementById("buttonDelete").style.visibility = "hidden";
                                  document.getElementById("buttonNew").style.visibility = "hidden";
                                </script>
                            <%
                        }
                    
                        // print button for existing invoices
                        if(checkString(career.getUid()).length() > 0){
                            String sPrintLanguage = activeUser.person.language;
                            if(sPrintLanguage.length()==0){
                                sPrintLanguage = sWebLanguage;
                            }
                            
                            %>
                                <%=getTran("web.occup","printLanguage",sWebLanguage)%>
                                <select class="text" name="PrintLanguage">
                                    <%
                                        String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
                                        StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages,",");
                                        String tmpLang;
                                        
                                        while(tokenizer.hasMoreTokens()){
                                            tmpLang = tokenizer.nextToken();                        
                                            %><option value="<%=tmpLang%>" <%=(tmpLang.equalsIgnoreCase(sPrintLanguage)?"selected":"")%>><%=getTran("web.language",tmpLang,sWebLanguage)%></option><%
                                        }
                                    %>
                                </select>
                        
                                <input class="button" type="button" name="buttonPrint" value="<%=getTranNoLink("web","print",sWebLanguage)%>" onclick="doPrintPdf('<%=career.getUid()%>');">
                            <%
                        } 
                    %>
                </td>
            </tr>
        </table>
        <%=getTran("web","colored_fields_are_obligate",sWebLanguage)%>
        
        <div id="divMessage" style="padding-top:10px;"></div>
    </form>
        
    <script>
      <%-- SAVE CAREER --%>
      function saveCareer(){
        var okToSubmit = true;
        
        if(document.getElementById("careerBegin").value.length > 8 &&
           document.getElementById("position").value.length > 0 &&
           document.getElementById("service").value.length > 0
           //document.getElementById("grade").selectedIndex > -1 &&
           //document.getElementById("status").selectedIndex > -1
          ){     
          <%-- careerBegin can not be after carreerEnd --%>
          if(document.getElementById("careerEnd").value.length > 0){
            var careerBegin = new Date(document.getElementById("careerBegin").value.substring(6)+"/"+document.getElementById("careerBegin").value.substring(3,5)+"/"+document.getElementById("careerBegin").value.substring(0,2));
            var careerEnd = new Date(document.getElementById("careerEnd").value.substring(6)+"/"+document.getElementById("careerEnd").value.substring(3,5)+"/"+document.getElementById("careerEnd").value.substring(0,2));
          
            if(careerBegin > careerEnd){
              okToSubmit = false;

              <%-- alert beginMustComeBeforeEnd --%>
              var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=beginMustComeBeforeEnd";
              var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
              (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","beginMustComeBeforeEnd",sWebLanguage)%>");
            }  
          }
          
          if(okToSubmit){
            document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Saving";  
            var url= "<c:url value='/hr/ajax/saveCareer.jsp'/>?ts="+new Date().getTime();

            document.getElementById("buttonSave").disabled = true;
            if(document.getElementById("buttonDelete")!=null) document.getElementById("buttonDelete").disabled = true;
            if(document.getElementById("buttonNew")!=null) document.getElementById("buttonNew").disabled = true;
            
            new Ajax.Request(url,
              {
                method: "POST",
                postBody: "EditCareerUid="+EditForm.EditCareerUid.value+
                          "&careerBegin="+document.getElementById("careerBegin").value+
                          "&careerEnd="+document.getElementById("careerEnd").value+
                          "&position="+document.getElementById("position").value+
                          "&serviceUid="+document.getElementById("service").value+
                          "&grade="+document.getElementById("grade").value+
                          "&status="+document.getElementById("status").value+
                          "&comment="+document.getElementById("comment").value,
                onSuccess: function(resp){
                  var data = eval("("+resp.responseText+")");
                  $("divMessage").innerHTML = data.message;
                  
                  loadCareers();
                  
                  EditForm.EditCareerUid.value = data.newUid;
                  document.getElementById("buttonSave").disabled = false;
                  if(document.getElementById("buttonDelete")!=null) document.getElementById("buttonDelete").disabled = false;
                  if(document.getElementById("buttonNew")!=null) document.getElementById("buttonNew").disabled = false;
                },
                onFailure: function(resp){
                  $("divMessage").innerHTML = "Error in 'hr/ajax/saveCareer.jsp' : "+resp.responseText.trim();
                }
              }
            );
          }
        }
        else{
          <%-- alert datamissing --%>
          var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=dataMissing";
          var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","dataMissing",sWebLanguage)%>");
        }
      }
        
      <%-- LOAD CAREERS --%>
      function loadCareers(){
        document.getElementById("divCareers").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";            
        var url= "<c:url value='/hr/ajax/getCareers.jsp'/>?ts="+new Date().getTime();
        new Ajax.Request(url,
          {
            method: "GET",
            parameters: "PatientId=<%=sPatientId%>"+
                        "&position=<%=career.position%>"+
                        "&serviceId=<%=career.serviceUid%>"+
                        "&grade=<%=career.grade%>"+
                        "&status=<%=career.status%>"+
                        "&comment=<%=career.comment%>",
            onSuccess: function(resp){
              $("divCareers").innerHTML = resp.responseText;
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/getCareers.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }

      <%-- DISPLAY CAREER --%>
      function displayCareer(careerUid){          
        var url= "<c:url value='/hr/ajax/getCareer.jsp'/>?ts="+new Date().getTime();
        
        new Ajax.Request(url,
          {
            method: "GET",
            parameters: "CareerUid="+careerUid,
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");

              $("EditCareerUid").value = careerUid;
              $("careerBegin").value = data.begin;
              $("careerEnd").value = data.end;
              $("position").value = data.position;
              $("service").value = data.serviceUid;
              $("serviceName").value = data.serviceName;
              $("grade").value = data.grade;
              $("status").value = data.status;
              $("comment").value = data.comment;
              
              document.getElementById("divMessage").innerHTML = ""; 

              <%-- display delete button --%>
              if(document.getElementById("buttonDelete")!=null){
            	document.getElementById("buttonDelete").style.visibility = "visible";
              }
              <%-- display new button --%>
              if(document.getElementById("buttonNew")!=null){
            	document.getElementById("buttonNew").style.visibility = "visible";
              }
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/getCareer.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
      
      <%-- DELETE CAREER --%>
      function deleteCareer(){  
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");

 	    if(answer==1){                 
          var url= "<c:url value='/hr/ajax/deleteCareer.jsp'/>?ts="+new Date().getTime();

          document.getElementById("buttonSave").disabled = true;
          if(document.getElementById("buttonDelete")!=null) document.getElementById("buttonDelete").disabled = true;
          if(document.getElementById("buttonNew")!=null) document.getElementById("buttonNew").disabled = true;
        
          new Ajax.Request(url,
            {
              method: "GET",
              parameters: "CareerUid="+document.getElementById("EditCareerUid").value,
              onSuccess: function(resp){
                var data = eval("("+resp.responseText+")");
                $("divMessage").innerHTML = data.message;

                loadCareers();
                newCareer();
              
                document.getElementById("buttonSave").disabled = false;
                if(document.getElementById("buttonDelete")!=null) document.getElementById("buttonDelete").disabled = false;
                if(document.getElementById("buttonNew")!=null) document.getElementById("buttonNew").disabled = false;
              },
              onFailure: function(resp){
                $("divMessage").innerHTML = "Error in 'hr/ajax/deleteCareer.jsp' : "+resp.responseText.trim();
              }  
            }
          );
        }
      }
      
      <%-- NEW CAREER --%>
      function newCareer(){                   
        <%-- hide irrelevant buttons --%>
        if(document.getElementById("buttonDelete")!=null) document.getElementById("buttonDelete").style.visibility = "hidden";
        if(document.getElementById("buttonNew")!=null) document.getElementById("buttonNew").style.visibility = "hidden";

        $("EditCareerUid").value = "-1";
        $("careerBegin").value = "";
        $("careerEnd").value = "";
        $("position").value = "";
        $("service").value = "";
        $("serviceName").value = "";
        $("grade").value = "";
        $("status").value = "";
        $("comment").value = "";   
        
        $("careerBegin").focus();
      }
        
      <%-- SEARCH SERVICE --%>
      function searchService(serviceUidField,serviceNameField){
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
        document.getElementById(serviceNameField).focus();
      }
        
      EditForm.careerBegin.focus();
      loadCareers();
    </script>
<%
    }
%>
