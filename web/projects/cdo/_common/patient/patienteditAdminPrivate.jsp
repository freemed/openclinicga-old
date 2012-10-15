<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%=sJSEMAIL%>
<%
    if((activePatient!=null)&&(request.getParameter("SavePatientEditForm")==null)) {
    %>
<script type="text/javascript">
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
                      for(var i=0; i<aCities.length; i++){
                          aCities[i] = aCities[i].replace(/^\s+/,'');
                          aCities[i] = aCities[i].replace(/\s+$/,'');

                          if ((aCities[i].length>0)&&(aCities[i]!=" ")){
                              $("PSector").options[i] = new Option(aCities[i], aCities[i]);
                          }
                      }
                  }
              },
              onFailure: function(){
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
                },
                onFailure: function(){
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

        String sBeginDate ="<input type='hidden' name='PBegin' value=\""+apc.begin.trim()+"\"/>";

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
            +"<tr><td class='admin'>"+getTran("web","province",sWebLanguage)+"</td><td class='admin2'>"+sDistricts+"</td></tr>"
            +"<tr><td class='admin'>"+getTran("web","community",sWebLanguage)+"</td><td class='admin2'>"+sCities+"</td></tr>"
            +writeCountry(apc.country,"PCountry","AdminPrivate","PCountryDescription",true, "Country",sWebLanguage)
            +inputRow("Web","telephone","PTelephone","AdminPrivate",apc.telephone,"T",true,false,sWebLanguage)
            +inputRow("Web","mobile","PMobile","AdminPrivate",apc.mobile,"T",true,false,sWebLanguage)
            +inputRow("Web","function","PFunction","AdminPrivate",apc.businessfunction,"T",true,false,sWebLanguage)
            +inputRow("Web","business","PBusiness","AdminPrivate",apc.business,"T",true,false,sWebLanguage));
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
      document.getElementsByName("PCountry")[0].value = "<%=sDefaultCountry%>";
      document.getElementsByName("PTelephone")[0].value = "";
      document.getElementsByName("PMobile")[0].value = "";
      document.getElementsByName("PProvince")[0].value = "";
      document.getElementById("PDistrict").value = "";
      document.getElementById("PSector").value = "";
      document.getElementsByName("PFunction")[0].value = "";
      document.getElementsByName("PBusiness")[0].value = "";
    }

    getToday(document.getElementsByName("PBegin")[0]);
  }

  <%-- check submit admin private --%>
  function checkSubmitAdminPrivate() {
    var maySubmit = true;

    var sObligatoryFields = "<%=MedwanQuery.getInstance().getConfigString("ObligatoryFields_AdminPrivate")%>";
    var aObligatoryFields = sObligatoryFields.split(",");


    <%-- check obligatory field for content --%>
    for(var i=0; i<aObligatoryFields.length; i++){
      var obligatoryField = document.all(aObligatoryFields[i]);

      if(obligatoryField != undefined){
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