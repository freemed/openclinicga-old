<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%=sJSEMAIL%>
<%
    if((activePatient!=null)&&(request.getParameter("SavePatientEditForm")==null)) {
    %>
<script>
    function changeDistrict(){
      var today = new Date();

      var url= path + '/_common/search/searchByAjax/getCitiesByDistrict.jsp?ts=' + today;
      new Ajax.Request(url,{
              method: "POST",
              postBody: 'FindDistrict=' + document.getElementById("PDistrict").value,
              onSuccess: function(resp){
                  var sCities = resp.responseText;

                  if (sCities.length>0){
                      var aCities = sCities.split("$");
                      $('PSector').options.length=1;
                      $('PZipcode').value = "";
                      for(var i=0; i<aCities.length; i++){
                          aCities[i] = aCities[i].replace(/^\s+/,'');
                          aCities[i] = aCities[i].replace(/\s+$/,'');

                          if ((aCities[i].length>0)&&(aCities[i]!=" ")){
                              $("PSector").options[i] = new Option(aCities[i], aCities[i]);
                          }
                      }
                  }
              }
          }
      );
    }

    function changeSector(){
        var today = new Date();

        var url= path + '/_common/search/searchByAjax/getZipcodeByCityAndDistrict.jsp?ts=' + today;
        new Ajax.Request(url,{
                method: "POST",
                postBody: 'FindDistrict=' + document.getElementById("PDistrict").value+'&FindCity='+ document.getElementById("PSector").value
            ,
                onSuccess: function(resp){
                    var zipcode = resp.responseText;
                    $("PZipcode").value = zipcode;
                    var prov=zipcode.substring(zipcode.indexOf("0"),zipcode.indexOf("0")+2);
                    if(prov=="01"){
                        setProvince("vk");
                    }
                    else if(prov=="02"){
                        setProvince("south");
                    }
                    else if(prov=="03"){
                        setProvince("west");
                    }
                    else if(prov=="04"){
                        setProvince("north");
                    }
                    else if(prov=="05"){
                        setProvince("east");
                    }
                }
            }
        );
    }

    function setProvince(prov){
        for(n=0;n<document.getElementById("PProvince").options.length;n++){
            if (document.getElementById("PProvince").options[n].value==prov){
                document.getElementById("PProvince").selectedIndex=n;
                break;
            }
        }
    }
</script>
        <table border='0' width='100%' class="list" cellspacing="1">
    <%
        AdminPrivateContact apc = ScreenHelper.getActivePrivate(activePatient);

        boolean bNew = false;
        String sStartDate;
        if (apc == null || apc.privateid==null || apc.privateid.length()==0 || Integer.parseInt(apc.privateid)<0) {
            apc = new AdminPrivateContact();
            apc.begin = getDate();
            apc.country = sDefaultCountry;
            bNew = true;
            sStartDate = "PatientEditForm.DateOfBirth.value";
        }
        else {
            sStartDate = "\""+apc.begin+"\"";
        }

        String sBeginDate = normalRow("Web.admin","addresschangesince","PBegin","AdminPrivate",sWebLanguage);
        sBeginDate+="<input class='text' type='text' name='PBegin' value=\""+apc.begin.trim()+"\"";

        /*if (bEditable) {
            sBeginDate+= sBackground;
        }*/

        sBeginDate+=(" size='12' onblur='checkBegin(this,"+sStartDate.trim()+")'>&nbsp;"
            +"<img class='link' name='popcal' onclick='gfPop1.fPopCalendar(document.getElementsByName(\"PBegin\")[0]);return false;' src='"+sCONTEXTPATH+"/_img/icons/icon_agenda.gif' alt='"+getTranNoLink("Web","Select",sWebLanguage)+"'>"
            +"&nbsp;<img class='link' src='"+sCONTEXTPATH+"/_img/icons/icon_compose.gif' alt='"+getTranNoLink("Web","PutToday",sWebLanguage)+"' onclick='getToday(PBegin);'>");

        if (!bNew){
            sBeginDate+= " <img src='"+sCONTEXTPATH+"/_img/icons/icon_new.gif' id='buttonNewAPC' class='link' alt='"+getTranNoLink("Web","new",sWebLanguage)+"' onclick='newAPC()'>";
//            sBeginDate+= "&nbsp;<input type='button' name='buttonNewAPC' class='button' onclick='newAPC()' value='"+getTran("Web","new",sWebLanguage)+"'>";
        }
        sBeginDate+= "</td></tr>";

        String sDistricts = "<select class='text' id='PDistrict' name='PDistrict' onchange='changeDistrict();'><option/>";
        Vector vDistricts = Zipcode.getDistricts(MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
        Collections.sort(vDistricts);
        String sTmpDistrict;
        boolean bDistrictSelected = false;
        for (int i=0;i<vDistricts.size();i++){
            sTmpDistrict = (String)vDistricts.elementAt(i);

            sDistricts += "<option value='"+sTmpDistrict+"'";

            if (sTmpDistrict.equalsIgnoreCase(apc.district)){
                sDistricts+=" selected";
                bDistrictSelected = true;
            }
            sDistricts += ">"+sTmpDistrict+"</option>";
        }

        if ((!bDistrictSelected)&&(checkString(apc.district).length()>0)){
            sDistricts += "<option value='"+checkString(apc.district)+"' selected>"+checkString(apc.district)+"</option>";
        }
        sDistricts += "</select>";

        String sCities = "<select class='text' id='PSector' name='PSector' onchange='changeSector()'><option/>";
        Vector vCities = Zipcode.getCities(apc.district,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
        Collections.sort(vCities);
        String sTmpCity;
        boolean bCitySelected = false;
        for (int i=0;i<vCities.size();i++){
            sTmpCity = (String)vCities.elementAt(i);

            sCities += "<option value='"+sTmpCity+"'";

            if (sTmpCity.equalsIgnoreCase(apc.sector)){
                sCities+=" selected";
                bCitySelected = true;
            }
            sCities += ">"+sTmpCity+"</option>";
        }

        if ((!bCitySelected)&&(checkString(apc.city).length()>0)){
            sCities += "<option value='"+checkString(apc.city)+"' selected>"+checkString(apc.city)+"</option>";
        }
        sCities += "</select>";

        out.print(sBeginDate
                +inputRow("Web","address","PAddress","AdminPrivate",apc.address,"T",true, true,sWebLanguage)
//              +inputRow("Web","district","PDistrict","AdminPrivate",apc.district,"T",true,false,sWebLanguage)
              +"<tr><td class='admin'>"+getTran("web","province",sWebLanguage)+"</td><td class='admin2'>"+sDistricts+"</td></tr>"
//              +inputRow("Web","city","PCity","AdminPrivate",apc.city,"T",true, true,sWebLanguage)
              +"<tr><td class='admin'>"+getTran("web","searchdistrict",sWebLanguage)+"</td><td class='admin2'>"+sCities+"</td></tr>"
              +inputRow("Web","zipcode","PZipcode","AdminPrivate",apc.zipcode,"T",true,false,sWebLanguage)
              +writeCountry(apc.country,"PCountry","AdminPrivate","PCountryDescription",true, "Country",sWebLanguage)
              +inputRow("Web","email","PEmail","AdminPrivate",apc.email,"T",true,false,sWebLanguage)
              +inputRow("Web","telephone","PTelephone","AdminPrivate",apc.telephone,"T",true,false,sWebLanguage)
              +inputRow("Web","mobile","PMobile","AdminPrivate",apc.mobile,"T",true,false,sWebLanguage)
              //+inputRow("Web","province","PProvince","AdminPrivate",apc.province,"T",true,false,sWebLanguage)
              //+"<tr><td class='admin'>"+getTran("web","province",sWebLanguage)+"</td><td class='admin2'><select class='text' name='PProvince' id='PProvince'><option/>"
              //    +ScreenHelper.writeSelect("province",apc.province,sWebLanguage,false,true)
              //    +"</select></td></tr>"
              +inputRow("Web","city","PCity","AdminPrivate",apc.city,"T",true,false,sWebLanguage)
              //+inputRow("Web","cell","PCell","AdminPrivate",apc.cell,"T",true,false,sWebLanguage)
              +inputRow("Web","function","PFunction","AdminPrivate",apc.businessfunction,"T",true,false,sWebLanguage)
              +inputRow("Web","business","PBusiness","AdminPrivate",apc.business,"T",true,false,sWebLanguage)
              +inputRow("Web","comment","PComment","AdminPrivate",apc.comment,"T",true,false,sWebLanguage));
    %>
    <%-- spacer --%>
    <tr height="0">
        <td width='<%=sTDAdminWidth%>'/><td width='*'/>
    </tr>
</table>
<script>
  function newAPC(){
    retVal = makeMsgBox("?","<%=getTran("Web.admin","recuperation_old_data",sWebLanguage)%>",32,3,0,4096);

    if (retVal==7){
      document.getElementsByName("PAddress")[0].value = "";
      document.getElementsByName("PZipcode")[0].value = "";
      document.getElementsByName("PCountry")[0].value = "<%=sDefaultCountry%>";
      document.getElementsByName("PEmail")[0].value = "";
      document.getElementsByName("PTelephone")[0].value = "";
      document.getElementsByName("PMobile")[0].value = "";
      document.getElementsByName("PProvince")[0].value = "";
      document.getElementById("PDistrict").value = "";
      document.getElementById("PSector").value = "";
      document.getElementsByName("PCell")[0].value = "";
      document.getElementsByName("PCity")[0].value = "";
      document.getElementsByName("PFunction")[0].value = "";
      document.getElementsByName("PBusiness")[0].value = "";
      document.getElementsByName("PComment")[0].value = "";
    }

    getToday(document.getElementsByName("PBegin")[0]);
    document.getElementsByName("PBegin")[0].focus();
  }

  <%-- check submit admin private --%>
  function checkSubmitAdminPrivate() {
    var maySubmit = true;

    var sObligatoryFields = "<%=MedwanQuery.getInstance().getConfigString("ObligatoryFields_AdminPrivate")%>";
    var aObligatoryFields = sObligatoryFields.split(",");

    <%-- check for valid email --%>
    if(PatientEditForm.PEmail.value.length > 0){
      if(!validEmailAddress(PatientEditForm.PEmail.value)){
        maySubmit = false;
        displayGenericAlert = false;
        alertDialog("web","invalidEmailaddress");
        activateTab('AdminPrivate');
        PatientEditForm.PEmail.focus();
      }
    }

    <%-- check obligatory field for content --%>
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
            activateTab('AdminPrivate');
            obligatoryField.focus();
          }
          maySubmit = false;
          break;
        }
      }
    }

    return maySubmit;
  }

  var path = '<c:url value="/"/>';

</script>
<%
    }
%>