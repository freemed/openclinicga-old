<%@ include file="/includes/validateUser.jsp" %>
<input type="hidden" name="prestationsVerified" value="0" id="prestationsVerified">
<%

	// prestations verified
    int prestationsVerified = 0;

    if(activePatient != null){
        if(activePatient.personid != null && activePatient.personid.length() > 0){
            if(MedwanQuery.getInstance().getConfigInt("exportEnabled") != 1 || !MedwanQuery.getInstance().hasUnvalidateActivities(Integer.parseInt(activePatient.personid))) {
                prestationsVerified = 1;
            }
        } 
        else{
            // invalid personid
            prestationsVerified = 1;
        }
    }
    else{
        // no active patient
        prestationsVerified = 1;
    }

    out.print("<script>"+
               "if(document.getElementById('prestationsVerified')!=undefined && document.getElementById('prestationsVerified').type.toLowerCase()=='hidden'){" +
                " document.getElementById('prestationsVerified').value = '"+prestationsVerified+"';"+
               "}"+
              "</script>");
%>
<script>
function dateError(field){
  alertDialog("Web.Occup","date.error");
  setTimeout('document.getElementById("'+field.id+'").focus();',100);
}  

String.prototype.trim = function(){
  return this.replace(/^\s+|\s+$/g,"");
}
String.prototype.ltrim = function(){
  return this.replace(/^\s+/,"");
}
String.prototype.rtrim = function(){
  return this.replace(/\s+$/,"");
}
	
var gk = window.Event?1:0;
function getClickedElement(e){
  return gk?e.target:window.event.srcElement;
}

function autocompletionItems(itemtype){
  if($('ac_'+itemtype) && $(itemtype+"_update")){
    var autocompleter = ItemsAutocompleter('ac_'+itemtype, itemtype+'_update', '_common/search/searchByAjax/autocompletionItemsValuesShow.jsp', 'item='+itemtype);
  }
}

function ItemsAutocompleter(inputId,divId,page,params){
  new Ajax.Autocompleter(inputId,divId,page,{parameters:params,tokens:'<%=MedwanQuery.getInstance().getConfigString("autocomplementTokens")%>',paramName:'itemValue'});
}

function testItemValue(type,value){
  var value = value.replace(/(^\s*)|(\s*$)/g,"");
  var type = "BE.MXS.COMMON.MODEL.VO.HEALTHRECORD.ICONSTANTS."+type;
  new Ajax.Request('_common/search/searchByAjax/autocompletionItemsValuesShow.jsp',{asynchronous:false,method:"POST",postBody:'&itemValue='+value+"&item="+type+"&testValue=1"});
}
<%

%>
<%-- CHECK SAVE BUTTON --%>
function checkSaveButton(){
  if(myForm!=null && myForm.name=="SF") return true;
  var discardFormData = true;
  var sFormCurrStatus = getFormData();
  <%-- alert(sFormBeginStatus+"\n\n"+sFormCurrStatus); --%>

  var alertAnyway = false;

  <%
      if(request.getQueryString()!=null && request.getQueryString().indexOf("manageMedicalDecisionComment.jsp") > -1){
          %>alertAnyway = true;<%
      }
  %>

  if(alertAnyway || (sFormBeginStatus!=sFormCurrStatus)){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm(sQuestion);
    discardFormData = (answer==1);
  }

  return discardFormData;
}
<%

%>

function verifyPrestationCheck(){
  if(document.getElementById('prestationsVerified').value=='0'){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web.occup&labelID=exported-activities-not-validated";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.occup","exported-activities-not-validated",sWebLanguage)%>");

    if(answer==1){
      showExportedActivities();
      return false;
    }
    else{
      return true;
    }
  }
  else{
    return true;
  }
}

function checkBefore(beforeId,afterObj){
  var beforeObj = document.getElementById(beforeId);
  if(beforeObj.value!="" && afterObj.value!=""){
    if(beforeObj.value!=afterObj.value){
      if(!before(beforeObj.value,afterObj.value)){
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=web&labelID=dateMustBeLater";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","dateMustBeLater",sWebLanguage)%>");

        afterObj.value = beforeObj.value;
        afterObj.select();
      }
      else{
        return true;
      }
    }
  }
  return false;
}

function checkAfter(afterId,beforeObj){
  var afterObj = document.getElementById(afterId);

  if(afterObj.value!="" && beforeObj.value!=""){
    if(afterObj.value != beforeObj.value){
      if(before(afterObj.value, beforeObj.value)){
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=web&labelID=dateMustBeSooner";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","dateMustBeSooner",sWebLanguage)%>");

        beforeObj.value = afterObj.value;
        beforeObj.select();
      }
    }
  }
}
</script>
<script>
  var myForm = document;
</script>
<%

%>
<% response.setHeader("Content-Type","text/html; charset=ISO-8859-1"); %>

<%=sJSSHORTCUTS%>
<%=sJSCHAR%>
<%=sJSDATE%>
<%=sJSCOOKIE%>
<%=sJSDROPDOWNMENU%>
<%=sJSPOPUPMENU%>
<%=sJSBUTTONS%>

<script>
  <%-- INIT BARCODE --%>
  function initBarcode(){
    document.getElementById("barcode").value = "";
    document.getElementById("barcode").style.visibility = "visible";
    document.getElementById("barcode").style.color = "black";
    document.getElementById("barcode").focus();
  }
 
  shortcut("F9",function(){initBarcode();});  
  shortcut("F8",function(){readFingerprint();});

  var _PathToScript = "<c:url value='/_common/_script/'/>";
  var gfPopType = "1";
  var dateType = "<%=MedwanQuery.getInstance().getConfigString("dateType","eu")%>";

  <%-- WRITE TRAN DATE --%>
  function writeTranDate(){
    return writeMyDate("trandate");
  }
     
  <%-- WRITE MY DATE --%>
  function writeMyDate(sObject,sImg,sText,allowPastDates,allowFutureDates){    
    if(sImg==undefined){
      sImg = "<c:url value='/_img/icon_agenda.gif'/>";
    }
    sDir = sImg.substring(0,sImg.lastIndexOf("/"))+"";
    
    if(sText==undefined){
      sText = "<%=getTranNoLink("Web","PutToday",sWebLanguage)%>";	
    }
    
    if(allowPastDates==undefined) allowPastDates = true;
    if(allowFutureDates==undefined) allowFutureDates = true;

    gfPopType = "1"; // default mode
    if(allowPastDates && allowFutureDates){
      gfPopType = "1";
    }
    else{
           if(allowFutureDates) gfPopType = "3";
      else if(allowPastDates) gfPopType = "2";
    }

    document.write("<a href='javascript:void(0);' onclick='if(self.gfPop"+gfPopType+")gfPop"+gfPopType+".fPopCalendar(document.getElementById(\""+sObject+"\"));return false;' HIDEFOCUS>" +
                   "<img name='popcal' class='link' src='"+sImg+"' alt='<%=getTranNoLink("web","Select",sWebLanguage)%>'></a>" +
                   "&nbsp;<a href='javascript:void(0);' onClick='getToday("+sObject+");'>" +
                   "<img class='link' src='"+sDir+"/icon_compose.gif' alt='<%=getTranNoLink("web","putToday",sWebLanguage)%>'></a>");
  } 
    
  <%-- GET MY DATE --%>
  function getMyDate(sObject,sImg,sText,allowPastDates,allowFutureDates){
    sDir = sImg.substring(0,sImg.lastIndexOf("/"))+"";
    gfPopType = "1"; // default mode
    
    if(allowPastDates==undefined) allowPastDates = true;
    if(allowFutureDates==undefined) allowFutureDates = true;

    if(allowPastDates && allowFutureDates){
      gfPopType = "1";
    }
    else{
      if(allowFutureDates) gfPopType = "3";
      else if(allowPastDates) gfPopType = "2";
    }

    return ("<a href='javascript:void(0);' onclick='if(self.gfPop"+gfPopType+")gfPop"+gfPopType+".fPopCalendar(document.getElementById(\""+sObject+"\"));return false;' HIDEFOCUS>" +
            "<img name='popcal' class='link' src='"+sImg+"' alt='<%=getTranNoLink("web","Select",sWebLanguage)%>'></a>" +
            "&nbsp;<a href='javascript:void(0);' onClick='getToday("+sObject+");'>" +
            "<img class='link' src='"+sDir+"/icon_compose.gif' alt='<%=getTranNoLink("web","putToday",sWebLanguage)%>'></a>");
  }

  <%-- FIND ZIPCODE --%>
  function findZipcode(oZipcode,oCity,oButton){
    if(oZipcode.value.length==0){
      oCity.value = "";
    }
    else{
      window.open("<c:url value='/popup.jsp'/>?Page=_common/search/blurZipcode.jsp&ZipcodeValue="+oZipcode.value
                 +"&CityName="+oCity.name+"&CityValue="+oCity.value
                 +"&VarButton="+oButton.name, "Zipcode", "toolbar=no, width=1, height=1, status=no, scrollbars=no, resizable=no, menubar=no, alwaysLowered=yes");
    }
  }

  <%-- The following script is used to hide the calendar whenever you click the document. --%>
  <%-- When using it you should set the name of popup button or image to "popcal", otherwise the calendar won't show up. --%>
  document.onmousedown = function(e){
    var n = !e?self.event.srcElement.name:e.target.name;

    if(document.layers){
      with(gfPop) var l = pageX, t = pageY, r = l+clip.width, b = t+clip.height;
      if(n!="popcal" && (e.pageX > r || e.pageX < l || e.pageY > b || e.pageY < t)){
        gfPop1.fHideCal();
        gfPop2.fHideCal();
        gfPop3.fHideCal();
      }
      return routeEvent(e);
    }
    else if(n!="popcal"){
      gfPop1.fHideCal();
      gfPop2.fHideCal();
      gfPop3.fHideCal();
    }
  }

  if(document.layers) document.captureEvents(Event.MOUSEDOWN);

  <%=getUserInterval(session,activeUser)%>

  window.document.title = "<%=sWEBTITLE+" "+getWindowTitle(request, sWebLanguage).toUpperCase()%>";
</script>

<%-- CALENDAR FRAMES --%>
<% String sDateType = MedwanQuery.getInstance().getConfigString("dateType","eu"); // eu/us %>

<iframe width=174 height=189 name="gToday:normal1_<%=sDateType%>:agenda.js:gfPop1" id="gToday:normal1_<%=sDateType%>:agenda.js:gfPop1"
  src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
  style="visibility:visible; z-index:9999999999; position:absolute; top:-500px; left:-500px;">
</iframe>

<iframe width=174 height=189 name="gToday:normal2_<%=sDateType%>:agenda.js:gfPop2" id="gToday:normal2_<%=sDateType%>:agenda.js:gfPop2"
  src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
  style="visibility:visible; z-index:9999999999; position:absolute; top:-500px; left:-500px;">
</iframe>

<iframe width=174 height=189 name="gToday:normal3_<%=sDateType%>:agenda.js:gfPop3" id="gToday:normal3_<%=sDateType%>:agenda.js:gfPop3"
  src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
  style="visibility:visible; z-index:9999999999; position:absolute; top:-500px; left:-500px;">
</iframe>

<%
    String sTmpPage = checkString(request.getParameter("Page"));

    if(sTmpPage.indexOf("healthrecord") > -1){
%>

<%-- popupmenu --%>
<div id="ie5menu" class="skin0" onMouseover="highlightie5(event)" onMouseout="lowlightie5(event)" onClick="jumptoie5(event)" style="position:absolute;display:none;">
    <%-- items van popupmenu. Met target komt de inhoud in een andere pagina --%>
    <!-- <div id="Antecedents" class="menuitems" url="/">getTran("Web.Occup","medwan.common.transfert-to-antecedents",sWebLanguage)</div> -->
    <div id="SetDefaultValue" class="menuitems" url="/"><%=getTran("Web.Occup","medwan.occupational-medicine.setdefaultvalue",sWebLanguage)%></div>
    <div id="GetHistory" class="menuitems" url="javascript:openPage(sHistoryURL,'<%=getTran("Web.Occup","medwan.occupational-medicine.gethistory",sWebLanguage)%>','directories=no,location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,width=400,height=250,top=100,left=100')"><%=getTran("Web.Occup","medwan.occupational-medicine.gethistory",sWebLanguage)%></div>
    <div id="GetGraph" class="menuitems" url="javascript:openPage(sGraphURL,'<%=getTran("Web.Occup","medwan.occupational-medicine.getgraph",sWebLanguage)%>','directories=no,location=no,menubar=no,status=no,toolbar=no,scrollbars=no,width=400,height=220,top=100,left=100')"><%=getTran("Web.Occup","medwan.occupational-medicine.getgraph",sWebLanguage)%></div>
    <div id="ShowLastTrans" class="menuitems" url="javascript:openPage(sLastTransURL,'LastTrans','directories=no,location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,width=1,height=1')"><%=getTran("Web.Occup","medwan.occupational-medicine.showLastTransactions",sWebLanguage)%></div>
    <hr id="Sep1"/>
    <div id="GetDefaultValue" class="menuitems" url="javascript:loadDefaults();"><%=getTran("Web.Occup","medwan.occupational-medicine.getdefaultvalues",sWebLanguage)%></div>
    <div id="GetPreviousValue" class="menuitems" url="javascript:loadPrevious();"><%=getTran("Web.Occup","medwan.occupational-medicine.getpreviousvalues",sWebLanguage)%></div>
    <div id="GetPreviousContextValue" class="menuitems" url="javascript:loadPreviousContext();"><%=getTran("Web.Occup","medwan.occupational-medicine.getpreviouscontextvalues",sWebLanguage)%></div>
    <hr/>
    <%-- <div id="RegisterDiagnosis" class="menuitems" url="/"><%=getTran("Web.Occup","medwan.common.register-as-diagnosis",sWebLanguage)%></div> --%>
    <div class="menuitems" url="null"><%=getTran("Web.Occup","medwan.common.close",sWebLanguage)%></div>
</div>

<script>
sHistoryURL = '';
sGraphURL = '';
sLastTransURL = '<c:url value="/healthrecord/showLastTransactions.jsp"/>';
activeItem = false;
activeMenu = false;

if(document.all && window.print){
  ie5menu.className = menuskin;
}

function setPopup(itemType){
  document.oncontextmenu = showmenuie5;
}

function setPopup(itemType,itemValue){
	  if(ie){
	    if(itemValue!=null){
	      document.getElementById("SetDefaultValue").url = "javascript:openPage('<c:url value='/util/saveDefaultValue.jsp'/>?itemType="+itemType+"&itemValue="+itemValue+"','')";
	    }
	    else{
	      document.getElementById("SetDefaultValue").url = "";
	    }
	  }
	  else{
	    if(itemValue!=null){
	      document.getElementById("SetDefaultValue").setAttribute("url","javascript:openPage('<c:url value='/util/saveDefaultValue.jsp'/>?itemType="+itemType+"&itemValue="+itemValue+"','')");
	    }
	    else{
	      document.getElementById("SetDefaultValue").setAttribute("url","");
	    }
	  }

  sHistoryURL = "<c:url value="healthrecord/itemHistory.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
  sGraphURL = "<c:url value="/healthrecord/itemGraph.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";

  document.oncontextmenu = showmenuie5;
}

function openPage(url,name,parameters){
  window.open(url,name,parameters);
}

function setItemsMenu(bSet){
  if(!activeMenu){
    if(bSet || activeItem){
      sDisp = 'list-item';
    }
    else{
      sDisp = 'none';
    }
    if(ie){
      if(SetDefaultValue.url.length > 0){
        SetDefaultValue.style.display = sDisp;
      }
      else{
        SetDefaultValue.style.display = 'none';
      }
    }
    else{
      if(document.getElementById("SetDefaultValue").getAttribute("url").length > 0){
        document.getElementById("SetDefaultValue").style.display = sDisp;
      }
      else{
        document.getElementById("SetDefaultValue").style.display = 'none';
      }
    }

    GetHistory.style.display = sDisp;
    GetGraph.style.display = sDisp;
    Sep1.style.display = sDisp;
  }
}

function checkNavigation(evt){
  if(window.myButton){
    var target;
    if(evt.target){
      target = evt.target.getAttribute("target");
    }
    else{
      target = evt.srcElement.target;
    }
    if(target.href!=null){
      if(checkSaveButton()){
        window.location.href = target;
      }
    }
  }
}

function checkDropdown(evt){
  if(!dropDownChecked){
    if(window.myButton){
      var target;
      if(evt.target){
        target = evt.target.getAttribute("targert");
      }
      else{
        target = evt.srcElement.target;
      }
      if((target.id.indexOf("menu") > -1) || (target.id.indexOf("ddIcon") > -1)){
        if(bSaveHasNotChanged == false) {
          dropDownChecked = true;
          if(checkSaveButton()){
            target.click();
          }
        }
      }
    }
  }
  else{
    if(evt.target){
      target = evt.target.click();
    }
    else{
      target = evt.srcElement.click();
    }
  }
}

<%-- PRINT GROWTH GRAPH automatically --%>
function printGrowthGraphAuto(printLang,ageInMonths,gender){
  if(ageInMonths >= 0 && ageInMonths <= 12){
    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp"+
                           "?PrintLanguage="+printLang+
                           "&dummyTransactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GROWTH_GRAPH_0_TO_1_YEAR"+
                           "&ageInMonths="+ageInMonths+
                           "&gender="+gender+
                           "&ts=<%=getTs()%>";
  }
  else if(ageInMonths > 12 && ageInMonths <= 60){
    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp"+
                           "?PrintLanguage="+printLang+
                           "&dummyTransactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GROWTH_GRAPH_1_TO_5_YEAR"+
                           "&ageInMonths="+ageInMonths+
                           "&gender="+gender +
                           "&ts=<%=getTs()%>";
  }
  else if (ageInMonths > 60 && ageInMonths <= 240){
    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp"+
                           "?PrintLanguage="+printLang+
                           "&dummyTransactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GROWTH_GRAPH_5_TO_20_YEAR"+
                           "&ageInMonths="+ageInMonths+
                           "&gender="+gender+
                           "&ts=<%=getTs()%>";
  }

  window.opener.document.transactionForm.printGraphButton.disabled = false;
  window.opener.document.transactionForm.saveAndPrintGraphButton.disabled = false;
  window.opener.bSaveHasNotChanged = true;
  window.opener.location.reload();
}

<%-- PRINT GROWTH GRAPH --%>
function printGrowthGraph(ageInMonths,gender){
  if(ageInMonths >= 0 && ageInMonths <= 12){
    printGrowthGraph0To1Year(ageInMonths,gender);
  }
  else if(ageInMonths > 12 && ageInMonths <= 60){
    printGrowthGraph1To5Year(ageInMonths,gender);
  }
  else{
    if(ageInMonths > 60 && ageInMonths <= 240){
      printGrowthGraph5To20Year(ageInMonths,gender);
    }
  }
}

<%-- PRINT GROWTH GRAPH 0 TO 1 YEAR --%>
function printGrowthGraph0To1Year(ageInMonths,gender){
  var printLang = transactionForm.PrintLanguage.value;

  var url = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp"+
            "?PrintLanguage="+transactionForm.PrintLanguage.value+
            "&dummyTransactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GROWTH_GRAPH_0_TO_1_YEAR"+
            "&ageInMonths="+ageInMonths+
            "&gender="+gender+
            "&ts=<%=getTs()%>";

  window.open(url,"printGrowthGraph0To1Year","height=600,width=845,toolbar=no,status=yes,scrollbars=no,resizable=yes,menubar=no");
}

<%-- PRINT GROWTH GRAPH 1 TO 5 YEAR --%>
function printGrowthGraph1To5Year(ageInMonths,gender){
  var printLang = transactionForm.PrintLanguage.value;

  var url = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp"+
            "?PrintLanguage="+transactionForm.PrintLanguage.value+
            "&dummyTransactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GROWTH_GRAPH_1_TO_5_YEAR"+
            "&ageInMonths="+ageInMonths+
            "&gender="+gender+
            "&ts=<%=getTs()%>";

  window.open(url,"printGrowthGraph1To5Year","height=600,width=845,toolbar=no,status=yes,scrollbars=no,resizable=yes,menubar=no");
}

<%-- PRINT GROWTH GRAPH 5 TO 20 YEAR --%>
function printGrowthGraph5To20Year(ageInMonths,gender){
  var printLang = transactionForm.PrintLanguage.value;

  var url = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp"+
            "?PrintLanguage="+transactionForm.PrintLanguage.value+
            "&dummyTransactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GROWTH_GRAPH_5_TO_20_YEAR"+
            "&ageInMonths="+ageInMonths+
            "&gender="+gender+
            "&ts=<%=getTs()%>";

  window.open(url,"printGrowthGraph5To20Year","height=600,width=845,toolbar=no,status=yes,scrollbars=no,resizable=yes,menubar=no");
}
</script>
<%
    }
%>


