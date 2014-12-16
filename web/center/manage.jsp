<%@page import="be.openclinic.system.Center,
                java.util.*,
                java.util.Date"%>
<%@include file="/includes/validateUser.jsp"%>

<script>
  function goToIndex(set){
    if(set){
      window.location.href = "<c:url value='/main.do'/>?Page=center/index.jsp&action=1&ts=<%=getTs()%>";
    }
    else{
      window.location.href = "<c:url value='/main.do'/>?Page=center/index.jsp&ts=<%=getTs()%>";
    }
  }
</script>

<%!
    //--- WRITE TAB -------------------------------------------------------------------------------
    public String writeTab(String sId, String sFocusField, String sLanguage){
        return "<script>sTabs+= ',"+sId+"';</script>"+
               "<td class='tabs'>&nbsp;</td>"+
               "<td class='tabunselected' width='1%' onclick='activateTab(\""+sId+"\")' id='tab"+sId+"' name='tab"+sId+"' nowrap><b>"+getTran("centerinfo",sId,sLanguage)+"</b></td>";
    }

    //--- WRITE TAB BEGIN -------------------------------------------------------------------------
    public String writeTabBegin(String sId){
        return "<tr id='tr"+sId+"' name='tr"+sId+"' style='display:none'><td>";
    }
    
    //--- WRITE TAB END ---------------------------------------------------------------------------
    public String writeTabEnd(){
        return "</td></tr>";
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));
    
    String sVersion   = checkString(request.getParameter("version")),
           sUid       = checkString(request.getParameter("uid")),
           sName      = checkString(request.getParameter("name")),
           sNumeroUid = checkString(request.getParameter("NumeroUid")),
           sProvince  = checkString(request.getParameter("province")),
           sDistrict  = checkString(request.getParameter("district")),
           sZone      = checkString(request.getParameter("zone")),
           sSector    = checkString(request.getParameter("sector")),
           sFosa      = checkString(request.getParameter("fosa")),
           sCell      = checkString(request.getParameter("cell")),
           sContactName     = checkString(request.getParameter("contactName")),
           sContactFunction = checkString(request.getParameter("contactFunction")),
           sRemEpidemiology = checkString(request.getParameter("remEpidemiology")),
           sRemDrugs        = checkString(request.getParameter("remDrugs")),
           sRemVaccinations = checkString(request.getParameter("remVaccinations")),
           sRemEquipment    = checkString(request.getParameter("remEquipment")),
           sRemBuilding     = checkString(request.getParameter("remBuilding")),
           sRemTransport    = checkString(request.getParameter("remTransport")),
           sRemPersonnel    = checkString(request.getParameter("remPersonnel")),
           sRemOther        = checkString(request.getParameter("remOther")),
           sPopulationTotal = checkString(request.getParameter("populationTotal")),
           sPopulationLt1m  = checkString(request.getParameter("populationLt1m")),
           sPopulationLt1y  = checkString(request.getParameter("populationLt1y")),
           sPopulationLt5y  = checkString(request.getParameter("populationLt5y")),
           sPopulationLt25y = checkString(request.getParameter("populationLt25y")),
           sPopulationLt50y = checkString(request.getParameter("populationLt50y")),
           sPopulationMt50y = checkString(request.getParameter("populationMt50y")),
           sPopulationPreg  = checkString(request.getParameter("populationPreg")),
           sPopulationMut   = checkString(request.getParameter("populationMut")),
           sBeds            = checkString(request.getParameter("beds")),
           sActive          = checkString(request.getParameter("active"));
    
    //// DEBUG ////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*************************** center/manage.jsp **************************");
    	Debug.println("sAction  : "+sAction);
    	Debug.println("sVersion : "+sVersion);
    	Debug.println("sUid     : "+sUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    boolean actual = false;
    Center center = new Center();
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        center = new Center();
        
        center.setUid(sUid);
        center.setName(sName);
        center.setNumeroUid(sNumeroUid);
        center.setProvince(sProvince);
        center.setDistrict(sDistrict);
        center.setZone(sZone);
        center.setSector(sSector);
        center.setFosa(sFosa);
        center.setCell(sCell);
        center.setContactName(sContactName);
        center.setContactFunction(sContactFunction);
        center.setCreateDateTime(new Date());
        center.setUpdateDateTime(new Date());
        center.setUpdateUser(activeUser.userid);
        center.setRemEpidemiology(sRemEpidemiology);
        center.setRemDrugs(sRemDrugs);
        center.setRemVaccinations(sRemVaccinations);
        center.setRemEquipment(sRemEquipment);
        center.setRemBuilding(sRemBuilding);
        center.setRemTransport(sRemTransport);
        center.setRemPersonnel(sRemPersonnel);
        center.setRemOther(sRemOther);
        center.setPopulationTotal(Integer.parseInt(sPopulationTotal));
        center.setPopulationLt1m(Float.parseFloat(sPopulationLt1m.replace(",",".")));
        center.setPopulationLt1y(Float.parseFloat(sPopulationLt1y.replace(",",".")));
        center.setPopulationLt25y(Float.parseFloat(sPopulationLt25y.replace(",",".")));
        center.setPopulationLt50y(Float.parseFloat(sPopulationLt50y.replace(",",".")));
        center.setPopulationLt5y(Float.parseFloat(sPopulationLt5y.replace(",",".")));
        center.setPopulationMt50y(Float.parseFloat(sPopulationMt50y.replace(",",".")));
        center.setPopulationPreg(Float.parseFloat(sPopulationPreg.replace(",",".")));
        center.setPopulationMut(Float.parseFloat(sPopulationMut.replace(",",".")));
        center.setActive(Integer.parseInt(sActive));
        center.setBeds(Integer.parseInt(sBeds));
        center.store();
        
        out.write("<script>goToIndex(1);</script>");
    } 
    //--- SET -------------------------------------------------------------------------------------
    else if(sAction.equals("set")){
        center = Center.get(Integer.parseInt(sVersion),false);
        
        if(center==null || sVersion.equals("0")){
            center = Center.get(Integer.parseInt(sVersion),true);
            if(center==null){
                center = new Center();
            }
            actual = true;
        }
    }
%>

<script>
  var sTabs = "";
  var activeTab = "";
</script>

<form name="centerForm" id="centerForm" method="post" action='<c:url value="/main.do"/>?Page=center/manage.jsp&Action=save&Tab=1&ts=<%=getTs()%>'>
    <input type="hidden" id="uid" name="uid" value="<%=checkString(center.getUid())%>"/>
   
    <%-- TABS --%>
	<table width="100%" cellspacing="0" cellpadding="0">
	    <tr>
	        <%=writeTab("identification","",sWebLanguage)%>
	        <%=writeTab("remarques","",sWebLanguage)%>
	        <%=writeTab("population","",sWebLanguage)%>
	        <%=writeTab("hospitalisation","",sWebLanguage)%>
	        <td class="tabs" width="100%">&nbsp;</td>
	    </tr>
	</table>
	
    <table width="100%" cellpadding="0" cellspacing="0">
        <%-- TAB 1 --%>
        <%=writeTabBegin("identification")%>
        <table width="100%" class="list" style="border-top:none;" cellspacing="1" onkeydown="if(enterEvent(event,13)){centerForm.submit();}">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo","denomination",sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="name" value="<%=checkString(center.getName())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","numero.identification",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="NumeroUid" value="<%=checkString(center.getNumeroUid())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("web","province",sWebLanguage)%></td>
                <td class="admin2">
                    <select class='text' name='province' id='Province'>
                        <option/>
                        <%=ScreenHelper.writeSelect("province",checkString(center.getProvince()),sWebLanguage,false,true)%>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("web","district",sWebLanguage)%></td>
                <td class="admin2">
                    <%
                        String sDistricts = "<select class='text' id='PDistrict' name='district' onchange='changeDistrict();'><option/>";
                        Vector vDistricts = Zipcode.getDistricts(MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
                        Collections.sort(vDistricts);
                        String sTmpDistrict;
                        boolean bDistrictSelected = false;
                       
                        for(int i=0; i<vDistricts.size(); i++){
                            sTmpDistrict = (String) vDistricts.elementAt(i);
                            sDistricts += "<option value='"+sTmpDistrict+"'";
                            if(sTmpDistrict.equalsIgnoreCase(checkString(center.getDistrict()))){
                                sDistricts+= " selected";
                                bDistrictSelected = true;
                            }
                            sDistricts+= ">"+sTmpDistrict+"</option>";
                        }
                        
                        sDistricts+= "</select>";%><%=sDistricts%>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","zone.rayonnement",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="zone" value="<%=checkString(center.getZone())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("web","sector",sWebLanguage)%></td>
                <td class="admin2">
                    <%
                        String sCities = "<select class='text' id='PSector' name='sector'>"+
                                          "<option/>";
                        Vector vCities = Zipcode.getCities(checkString(center.getDistrict()),MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
                        Collections.sort(vCities);
                        String sTmpCity;
                        boolean bCitySelected = false;
                        for(int i=0; i<vCities.size(); i++){
                            sTmpCity = (String)vCities.elementAt(i);
                            sCities+= "<option value='"+sTmpCity+"'";
                            if(sTmpCity.equalsIgnoreCase(checkString(center.getSector()))){
                                sCities += " selected";
                                bCitySelected = true;
                            }
                            sCities+= ">"+sTmpCity+"</option>";
                        }
                        sCities+= "</select>";%><%=sCities%>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","nom.fosa",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="fosa" value="<%=checkString(center.getFosa())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","cellule",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="cell" value="<%=checkString(center.getCell())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","nom.responsable",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="contactName" value="<%=checkString(center.getContactName())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","qualification.responsable",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="contactFunction" value="<%=checkString(center.getContactFunction())%>"/><br/>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%>
        
        <%-- TAB 2 --%>
        <%=writeTabBegin("remarques")%>        
        <table width="100%" class="list" style="border-top:none;" cellspacing="1">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo","epidemiologie",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remEpidemiology" class="text" name="remEpidemiology" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemEpidemiology())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","medicaments.consommables",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remDrugs" class="text" name="remDrugs" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemDrugs())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","vaccins.chaine.froid",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remVaccinations" class="text" name="remVaccinations" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemVaccinations())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","equipements",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remEquipment" class="text" name="remEquipment" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemEquipment())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","batiment",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remBuilding" class="text" name="remBuilding" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemBuilding())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","moyens.locomotion",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remTransport" class="text" name="remTransport" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemTransport())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo","personnel",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remPersonnel" class="text" name="remPersonnel" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemPersonnel())%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("web","other",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea id="remOther" class="text" name="remOther" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=checkString(center.getRemOther())%></textarea>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%>
        
        <%-- TAB 3 --%>
        <%=writeTabBegin("population")%>        
        <table width="100%" class="list" style="border-top:none;" cellspacing="1" onkeydown="if(enterEvent(event,13)){centerForm.submit();}">
            <%-- service --%>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo","population.totale.zone.rayonnement",sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationTotal" value="<%=center.getPopulationTotal()%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo", "moins.30.jours", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt1m" value="<%=center.getPopulationLt1m()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin">1-11 <%=getTran("web", "months", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt1y" value="<%=center.getPopulationLt1y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin">12-59 <%=getTran("web", "months", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt5y" value="<%=center.getPopulationLt5y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin">5-14 <%=getTran("web", "years", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt25y" value="<%=center.getPopulationLt25y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin">25-49 <%=getTran("web", "years", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt50y" value="<%=center.getPopulationLt50y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin">+50 <%=getTran("web", "years", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationMt50y" value="<%=center.getPopulationMt50y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo", "femmes.enceintes", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationPreg" value="<%=center.getPopulationPreg()%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("centerinfo", "population.mutuelles", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationMut" value="<%=center.getPopulationMut()%>"/> %<br/>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%>
        
        <%-- TAB 4 --%>
        <%=writeTabBegin("hospitalisation")%>        
        <table width="100%" class="list" style="border-top:none;" cellspacing="1" onkeydown="if(enterEvent(event,13)){centerForm.submit();}">
            <%-- service --%>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "nombre.lits", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="beds" value="<%=center.getBeds()%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin"><%=getTran("web", "active", sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="active" value="<%=center.getActive()%>"/><br/>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%>
    </table>
    
    <%-- BUTTONS --%>
    <%
        if(activeUser.getAccessRight("patient.administration.edit")){
            %>
	          <div id="saveMsg"><%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%></div>
	          
	          <%=ScreenHelper.alignButtonsStart()%>
	              <input <%=(!actual?"type='hidden'":"type='button'")%> class="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
	              <input class="button" type="button" name="cancel" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="goToIndex();"/>&nbsp;
	          <%=ScreenHelper.alignButtonsStop()%>
	        <%
        }
    %>
</form>

<script>
  var aTabs = sTabs.split(',');
  var path = "<c:url value=''/>";
    
  <%-- ACTIVATE TAB --%>
  function activateTab(sTab){
    for(var i=0; i<aTabs.length; i++){
      sTmp = aTabs[i];
      if(sTmp.length > 0){
        document.getElementsByName("tr"+sTmp)[0].style.display = "none";
        document.getElementsByName("tab"+sTmp)[0].className = "tabunselected";
      }
    }

    document.getElementsByName("tr"+sTab)[0].style.display = "";
    document.getElementsByName("tab"+sTab)[0].className = "tabselected";
  }
  
  <%-- DO SAVE --%>
  function doSave(){
    $("centerForm").submit();
  }
  
  <%-- CHANGE DISTRICT --%>
  function changeDistrict(){
    var url = path+"/_common/search/searchByAjax/getCitiesByDistrict.jsp?ts="+new Date();
    new Ajax.Request(url,{
      method: "POST",
      postBody: 'FindDistrict='+document.getElementById("PDistrict").value,
      onSuccess: function(resp){
        var sCities = resp.responseText;
        if(sCities.length > 0){
          var aCities = sCities.split("$");
          $('PSector').options.length = 1;
          for(var i=0; i<aCities.length; i++){
            aCities[i] = aCities[i].replace(/^\s+/,'');
            aCities[i] = aCities[i].replace(/\s+$/,'');
            if((aCities[i].length > 0) && (aCities[i]!=" ")){
              $("PSector").options[i] = new Option(aCities[i],aCities[i]);
            }
          }
        }
      }
    });
  }
    
  activateTab("identification");
</script>