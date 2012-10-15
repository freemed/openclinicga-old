<%@ page import="be.openclinic.system.Center" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp" %>
<script type="text/javascript">
    var goToIndex = function(set) {
        if (set) {
            window.location.href = "<c:url value="/main.do"/>?Page=center/index.jsp&action=1&ts=<%=getTs()%>";
        } else {
            window.location.href = "<c:url value="/main.do"/>?Page=center/index.jsp&ts=<%=getTs()%>";
        }
    }
</script>
<%!
    //--- WRITE TAB -------------------------------------------------------------------------------
    public String writeTab(String sId, String sFocusField, String sLanguage) {
        return "<script>sTabs+= '," + sId + "';</script>" +
                "<td style='border-bottom:1px solid #000;width:10px'>&nbsp;</td>" +
                "<td class='tabunselected' width='1%' style='padding:2px 4px;text-align:center;' onclick='activateTab(\"" + sId + "\")' id='tab" + sId + "' nowrap><b>" + getTran("centerinfo", sId, sLanguage) + "</b></td>";
    }
    //--- WRITE TAB BEGIN -------------------------------------------------------------------------
    public String writeTabBegin(String sId) {
        return "<tr id='tr" + sId + "' style='display:none'><td>";
    }
    //--- WRITE TAB END ---------------------------------------------------------------------------
    public String writeTabEnd() {
        return "</td></tr>";
    }
%><%String sVersion = checkString(request.getParameter("version"));
    String sUid = checkString(request.getParameter("uid"));
    String sAction = checkString(request.getParameter("action"));
    String sName = checkString(request.getParameter("name"));
    String sNumeroUid = checkString(request.getParameter("NumeroUid"));
    String sProvince = checkString(request.getParameter("province"));
    String sDistrict = checkString(request.getParameter("district"));
    String sZone = checkString(request.getParameter("zone"));
    String sSector = checkString(request.getParameter("sector"));
    String sFosa = checkString(request.getParameter("fosa"));
    String sCell = checkString(request.getParameter("cell"));
    String sContactName = checkString(request.getParameter("contactName"));
    String sContactFunction = checkString(request.getParameter("contactFunction"));
    String sRemEpidemiology = checkString(request.getParameter("remEpidemiology"));
    String sRemDrugs = checkString(request.getParameter("remDrugs"));
    String sRemVaccinations = checkString(request.getParameter("remVaccinations"));
    String sRemEquipment = checkString(request.getParameter("remEquipment"));
    String sRemBuilding = checkString(request.getParameter("remBuilding"));
    String sRemTransport = checkString(request.getParameter("remTransport"));
    String sRemPersonnel = checkString(request.getParameter("remPersonnel"));
    String sRemOther = checkString(request.getParameter("remOther"));
    String sPopulationTotal = checkString(request.getParameter("populationTotal"));
    String sPopulationLt1m = checkString(request.getParameter("populationLt1m"));
    String sPopulationLt1y = checkString(request.getParameter("populationLt1y"));
    String sPopulationLt5y = checkString(request.getParameter("populationLt5y"));
    String sPopulationLt25y = checkString(request.getParameter("populationLt25y"));
    String sPopulationLt50y = checkString(request.getParameter("populationLt50y"));
    String sPopulationMt50y = checkString(request.getParameter("populationMt50y"));
    String sPopulationPreg = checkString(request.getParameter("populationPreg"));
    String sPopulationMut = checkString(request.getParameter("populationMut"));
    String sBeds = checkString(request.getParameter("beds"));
    String sActive = checkString(request.getParameter("active"));
    boolean actual = false;
    Center center = new Center();
    if (sAction.equals("save")) {
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
        center.setPopulationLt1m(Float.parseFloat(sPopulationLt1m));
        center.setPopulationLt1y(Float.parseFloat(sPopulationLt1y));
        center.setPopulationLt25y(Float.parseFloat(sPopulationLt25y));
        center.setPopulationLt50y(Float.parseFloat(sPopulationLt50y));
        center.setPopulationLt5y(Float.parseFloat(sPopulationLt5y));
        center.setPopulationMt50y(Float.parseFloat(sPopulationMt50y));
        center.setPopulationPreg(Float.parseFloat(sPopulationPreg));
        center.setPopulationMut(Float.parseFloat(sPopulationMut));
        center.setActive(Integer.parseInt(sActive));
        center.setBeds(Integer.parseInt(sBeds));
        center.store();
        out.write("<script>goToIndex(1);</script>");
    } else if (sAction.equals("set")) {
        center = Center.get(Integer.parseInt(sVersion), false);
        if (center == null || sVersion.equals("0")) {
            center = Center.get(Integer.parseInt(sVersion), true);
            if (center == null) {
                center = new Center();
            }
            actual = true;
        }
    }%>
<script>
    var sTabs = "";
    var activeTab = "";
</script>
<table width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <%=writeTab("identification", "", sWebLanguage)%><%=writeTab("remarques", "", sWebLanguage)%><%=writeTab("population", "", sWebLanguage)%><%=writeTab("hospitalisation", "", sWebLanguage)%>
        <td style="border-bottom:1px solid #cccccc;" width="*">&nbsp;</td>
    </tr>
</table>
<form name="centerForm" id="centerForm" method="post" action='<c:url value="/main.do"/>?Page=center/manage.jsp&action=save&Tab=1&ts=<%=getTs()%>'>
    <input type="hidden" id="uid" name="uid" value="<%=checkString(center.getUid())%>"/>
    <table width="100%">
        <%=writeTabBegin("identification")%>
        <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){centerForm.submit();}">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "denomination", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="name" value="<%=checkString(center.getName())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "numero.identification", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="NumeroUid" value="<%=checkString(center.getNumeroUid())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web", "province", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <select class='text' name='province' id='Province'>
                        <option/>
                        <%=ScreenHelper.writeSelect("province", checkString(center.getProvince()), sWebLanguage, false, true)%>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web", "district", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <%String sDistricts = "<select class='text' id='PDistrict' name='district' onchange='changeDistrict();'><option/>";
                        Vector vDistricts = Zipcode.getDistricts(MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
                        Collections.sort(vDistricts);
                        String sTmpDistrict;
                        boolean bDistrictSelected = false;
                        for (int i = 0; i < vDistricts.size(); i++) {
                            sTmpDistrict = (String) vDistricts.elementAt(i);
                            sDistricts += "<option value='" + sTmpDistrict + "'";
                            if (sTmpDistrict.equalsIgnoreCase(checkString(center.getDistrict()))) {
                                sDistricts += " selected";
                                bDistrictSelected = true;
                            }
                            sDistricts += ">" + sTmpDistrict + "</option>";
                        }

                        /*     if ((!bDistrictSelected)&&(checkString(apc.district).length()>0)){
                      sDistricts += "<option value='"+checkString(apc.district)+"' selected>"+checkString(apc.district)+"</option>";
                  }      */
                        sDistricts += "</select>";%><%=sDistricts%>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "zone.rayonnement", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="zone" value="<%=checkString(center.getZone())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web", "sector", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <%String sCities = "<select class='text' id='PSector' name='sector' ><option/>";
                        Vector vCities = Zipcode.getCities(checkString(center.getDistrict()),MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
                        Collections.sort(vCities);
                        String sTmpCity;
                        boolean bCitySelected = false;
                        for (int i = 0; i < vCities.size(); i++) {
                            sTmpCity = (String) vCities.elementAt(i);
                            sCities += "<option value='" + sTmpCity + "'";
                            if (sTmpCity.equalsIgnoreCase(checkString(center.getSector()))) {
                                sCities += " selected";
                                bCitySelected = true;
                            }
                            sCities += ">" + sTmpCity + "</option>";
                        }

                        /*      if ((!bCitySelected)&&(checkString(apc.city).length()>0)){
                         sCities += "<option value='"+checkString(apc.city)+"' selected>"+checkString(apc.city)+"</option>";
                     }   */
                        sCities += "</select>";%><%=sCities%>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "nom.fosa", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="fosa" value="<%=checkString(center.getFosa())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "cellule", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="cell" value="<%=checkString(center.getCell())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "nom.responsable", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="contactName" value="<%=checkString(center.getContactName())%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "qualification.responsable", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" type="text" name="contactFunction" value="<%=checkString(center.getContactFunction())%>"/><br/>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%><%=writeTabBegin("remarques")%>
        <table width="100%" class="list" cellspacing="1">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "epidemiologie", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remEpidemiology" class="text" name="remEpidemiology" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemEpidemiology()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "medicaments.consommables", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remDrugs" class="text" name="remDrugs" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemDrugs()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "vaccins.chaine.froid", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remVaccinations" class="text" name="remVaccinations" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemVaccinations()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "equipements", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remEquipment" class="text" name="remEquipment" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemEquipment()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "batiment", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remBuilding" class="text" name="remBuilding" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemBuilding()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "moyens.locomotion", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remTransport" class="text" name="remTransport" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemTransport()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "personnel", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remPersonnel" class="text" name="remPersonnel" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemPersonnel()%></textarea>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web", "other", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <textarea id="remOther" class="text" name="remOther" cols="75" onkeyup="resizeTextarea(this,10);" rows="1"><%=center.getRemOther()%></textarea>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%><%=writeTabBegin("population")%>
        <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){centerForm.submit();}">
            <%-- service --%>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "population.totale.zone.rayonnement", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationTotal" value="<%=center.getPopulationTotal()%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "moins.30.jours", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt1m" value="<%=center.getPopulationLt1m()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>">1-11 <%=getTran("web", "months", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt1y" value="<%=center.getPopulationLt1y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>">12-59 <%=getTran("web", "months", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt5y" value="<%=center.getPopulationLt5y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>">5-14 <%=getTran("web", "years", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt25y" value="<%=center.getPopulationLt25y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>">25-49 <%=getTran("web", "years", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationLt50y" value="<%=center.getPopulationLt50y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>">+50 <%=getTran("web", "years", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationMt50y" value="<%=center.getPopulationMt50y()%>"/> %<br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "femmes.enceintes", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationPreg" value="<%=center.getPopulationPreg()%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "population.mutuelles", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="populationMut" value="<%=center.getPopulationMut()%>"/> %<br/>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%><%=writeTabBegin("hospitalisation")%>
        <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){centerForm.submit();}">
            <%-- service --%>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("centerinfo", "nombre.lits", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="beds" value="<%=center.getBeds()%>"/><br/>
                </td>
            </tr>
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web", "active", sWebLanguage)%>
                </td>
                <td class="admin2">
                    <input class="text" onblur="isNumber(this);" type="text" name="active" value="<%=center.getActive()%>"/><br/>
                </td>
            </tr>
        </table>
        <%=writeTabEnd()%>
    </table>
    <%-- SAVE BUTTONS ---------------------------------------------------------------------------%><%if (activeUser.getAccessRight("patient.administration.edit")) {%>
    <div id="saveMsg"><%=getTran("Web", "colored_fields_are_obligate", sWebLanguage)%>.</div>
    <%=ScreenHelper.alignButtonsStart()%>
    <input <%=(!actual)?"type='hidden'":"type='button'"%> class="button" name="centerForm" value="<%=getTran("Web","Save",sWebLanguage)%>" onclick="checkSubmit();">&nbsp;
    <input class="button" type="button" name="cancel" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="goToIndex();"/>&nbsp;<%=ScreenHelper.alignButtonsStop()%><%}%>
</form>
<script>
    var aTabs = sTabs.split(',');
    <%-- ACTIVATE TAB -----------------------------------------------------------------------------%>
    function activateTab(sTab) {
        for (var i = 0; i < aTabs.length; i++) {
            sTmp = aTabs[i];
            if (sTmp.length > 0) {
                document.getElementsByName("tr" + sTmp)[0].style.display = "none";
                document.getElementsByName("tab" + sTmp)[0].className = "tabunselected";
            }
        }

      //activeTab = sTab;
        document.getElementsByName("tr" + sTab)[0].style.display = "";
        document.getElementsByName("tab" + sTab)[0].className = "tabselected";
    }
    var checkSubmit = function() {
        $("centerForm").submit();
    }
    var path = '<c:url value="/"/>';
    function changeDistrict() {
        var today = new Date();
        var url = path + '/_common/search/searchByAjax/getCitiesByDistrict.jsp?ts=' + today;
        new Ajax.Request(url, {
            method: "POST",
            postBody: 'FindDistrict=' + document.getElementById("PDistrict").value,
            onSuccess: function(resp) {
                var sCities = resp.responseText;
                if (sCities.length > 0) {
                    var aCities = sCities.split("$");
                    $('PSector').options.length = 1;
                    for (var i = 0; i < aCities.length; i++) {
                        aCities[i] = aCities[i].replace(/^\s+/, '');
                        aCities[i] = aCities[i].replace(/\s+$/, '');
                        if ((aCities[i].length > 0) && (aCities[i] != " ")) {
                            $("PSector").options[i] = new Option(aCities[i], aCities[i]);
                        }
                    }
                }
            },
            onFailure: function() {
            }
        }
                );
    }
    activateTab("identification");
</script>
