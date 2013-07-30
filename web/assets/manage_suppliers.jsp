<%@page import="be.openclinic.assets.Supplier,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../assets/includes/commonFunctions.jsp"%>
<%=checkPermission("suppliers.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>
<%=sJSEMAIL%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** manage_suppliers.jsp ***************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<form name="SearchForm" id="SearchForm" method="POST">
    <%=writeTableHeader("web","suppliers",sWebLanguage,"doBack();")%>
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- search CODE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","code",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchCode" name="searchCode" size="20" maxLength="50" value="">
            </td>
        </tr>   
        
        <%-- search NAME --%>                
        <tr>
            <td class="admin"><%=getTran("web","name",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchName" name="searchName" size="50" maxLength="100" value="">
            </td>
        </tr>
        
        <%-- search VAT NUMBER --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","vatNumber",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" id="searchVatNumber" name="searchVatNumber" size="20" maxLength="50" value="">
            </td>
        </tr>     
                    
        <%-- search BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchSuppliers();">&nbsp;
                <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input class="button" type="button" name="buttonBack" id="buttonBack" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">&nbsp;
            </td>
        </tr>
    </table>
</form>

<script>
  SearchForm.searchCode.focus();

  <%-- SEARCH SUPPLIERS --%>
  function searchSuppliers(){
    document.getElementById("divSuppliers").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Searching";            
    var url = "<c:url value='/assets/ajax/supplier/getSuppliers.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "code="+SearchForm.searchCode.value+
                    "&name="+SearchForm.searchName.value+
                    "&vatNumber="+SearchForm.searchVatNumber.value,
        onSuccess: function(resp){
          $("divSuppliers").innerHTML = resp.responseText;
          sortables_init();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/supplier/getSuppliers.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchCode").value = "";
    document.getElementById("searchName").value = "";
    document.getElementById("searchVatNumber").value = "";
    
    document.getElementById("searchCode").focus();
    resizeAllTextareas(8);
  }
</script>

<div id="divSuppliers" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditSupplierUid" name="EditSupplierUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- code --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","code",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="code" name="code" size="20" maxLength="30" value="">
            </td>
        </tr>
        
        <%-- name (*) --%>
        <tr>
            <td class="admin"><%=getTran("web","name",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="name" name="name" size="80" maxLength="100" value="">
            </td>
        </tr>
             
        <%-- address --%>
        <tr>
            <td class="admin"><%=getTran("web","address",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="address" name="address" size="80" maxLength="100" value="">
            </td>
        </tr>   
             
        <%-- city --%>
        <tr>
            <td class="admin"><%=getTran("web","city",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="city" name="city" size="50" maxLength="100" value="">
            </td>
        </tr>  
             
        <%-- zipcode --%>
        <tr>
            <td class="admin"><%=getTran("web","zipcode",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="zipcode" name="zipcode" size="20" maxLength="20" value="">
            </td>
        </tr>  
             
        <%-- country --%>
        <tr>
            <td class="admin"><%=getTran("web","country",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="countryCode" id="countryCode" value="">
                <input type="text" class="text" id="country" name="country" size="40" value="" readonly>
                
                <%-- BUTTONS --%>
                <img src="<%=sCONTEXTPATH%>/_img/icon_search.gif" class="link" alt="<%=getTran("web","select",sWebLanguage)%>" onclick="openPopup('_common/search/searchScreen.jsp&LabelType=country&VarCode=countryCode&VarText=country&ShowID=false');">&nbsp;
                <img src="<%=sCONTEXTPATH%>/_img/icon_delete.gif" class="link" alt="<%=getTran("web","clear",sWebLanguage)%>" onclick="country.value='';countryCode.value='';">
            </td>
        </tr>  
       
        <%-- vatNumber --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","vatNumber",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="vatNumber" name="vatNumber" size="20" maxLength="30" value="">
            </td>
        </tr>  
             
        <%-- taxIDNumber --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","taxIDNumber",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="taxIDNumber" name="taxIDNumber" size="20" maxLength="30" value="">
            </td>
        </tr>  
             
        <%-- contactPerson --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","contactPerson",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="contactPerson" name="contactPerson" size="80" maxLength="100" value="">
            </td>
        </tr>  
             
        <%-- telephone --%>
        <tr>
            <td class="admin"><%=getTran("web","telephone",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="telephone" name="telephone" size="20" maxLength="30" value="">
            </td>
        </tr>  
             
        <%-- email --%>
        <tr>
            <td class="admin"><%=getTran("web","email",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="email" name="email" size="50" maxLength="50" value="">
            </td>
        </tr>  
             
        <%-- accountingCode --%>
        <tr>
            <td class="admin"><%=getTran("web.assets","accountingCode",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="accountingCode" name="accountingCode" size="30" maxLength="50" value="">
            </td>
        </tr>    
        
        <%-- comment --%>                
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment" id="comment" cols="80" rows="4" onKeyup="resizeTextarea(this,8);limitChars(this,255);"></textarea>
            </td>
        </tr>                       
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveSupplier();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteSupplier();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newSupplier();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE SUPPLIER --%>
  function saveSupplier(){
    var okToSubmit = true;
    
    <%-- check required fields --%>
    if(requiredFieldsProvided()){
      <%-- check email --%>
      if(okToSubmit==true){
        if(EditForm.email.value.length > 0){
          if(!validEmailAddress(EditForm.email.value)){
            okToSubmit = false;
            
            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web&labelID=invalidemailaddress";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","invalidEmailAddress",sWebLanguage)%>");

            EditForm.email.focus();
          }
        }
      }
    
      if(okToSubmit==true){
        document.getElementById("divMessage").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Saving";  
        disableButtons();
        
        var sParams = "EditSupplierUid="+EditForm.EditSupplierUid.value+
                      "&code="+EditForm.code.value+
                      "&name="+EditForm.name.value+
                      "&address="+EditForm.address.value+
                      "&city="+EditForm.city.value+
                      "&zipcode="+EditForm.zipcode.value+
                      "&country="+EditForm.countryCode.value+
                      "&vatNumber="+EditForm.vatNumber.value+
                      "&taxIDNumber="+EditForm.taxIDNumber.value+
                      "&contactPerson="+EditForm.contactPerson.value+
                      "&telephone="+EditForm.telephone.value+
                      "&email="+EditForm.email.value+
                      "&accountingCode="+EditForm.accountingCode.value+
                      "&comment="+EditForm.comment.value;

        var url = "<c:url value='/assets/ajax/supplier/saveSupplier.jsp'/>?ts="+new Date().getTime();
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: sParams,                   
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;

              //loadSuppliers();
              searchSuppliers();
              newSupplier();
              enableButtons();
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'assets/ajax/supplier/saveSupplier.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
      
      <%-- focus empty field --%>
      if(document.getElementById("name").value.length==0) document.getElementById("name").focus();          
    }
  }
  
  <%-- REQUIRED FIELDS PROVIDED --%>
  function requiredFieldsProvided(){
    return document.getElementById("name").value.length > 0;
  }
  
  <%-- LOAD SUPPLIERS --%>
  function loadSuppliers(){
    document.getElementById("divSuppliers").innerHTML = "<img src=\"<c:url value='/_img/ajax-loader.gif'/>\"/><br>Loading";            
    var url = "<c:url value='/assets/ajax/supplier/getSuppliers.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "",
        onSuccess: function(resp){
          $("divSuppliers").innerHTML = resp.responseText;
          sortables_init();
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/supplier/getSuppliers.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }

  <%-- DISPLAY SUPPLIER --%>
  function displaySupplier(supplierUid){
    var url = "<c:url value='/assets/ajax/supplier/getSupplier.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "SupplierUid="+supplierUid,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          
          $("EditSupplierUid").value = supplierUid.unhtmlEntities();
          $("code").value = data.code.unhtmlEntities();
          $("name").value = data.name.unhtmlEntities();
          $("address").value = data.address.unhtmlEntities();
          $("city").value = data.city.unhtmlEntities();
          $("zipcode").value = data.zipcode.unhtmlEntities();
          $("country").value = data.country.unhtmlEntities();
          $("countryCode").value = data.countryCode.unhtmlEntities();
          $("vatNumber").value = data.vatNumber.unhtmlEntities();
          $("taxIDNumber").value = data.taxIDNumber.unhtmlEntities();
          $("contactPerson").value = data.contactPerson.unhtmlEntities();
          $("telephone").value = data.telephone.unhtmlEntities();
          $("email").value = data.email.unhtmlEntities();
          $("accountingCode").value = data.accountingCode.unhtmlEntities();
          $("comment").value = replaceAll(data.comment.unhtmlEntities(),"<br>","\n");
          
          document.getElementById("divMessage").innerHTML = ""; 
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonDelete").style.visibility = "visible";
          document.getElementById("buttonNew").style.visibility = "visible";
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'assets/ajax/supplier/getSupplier.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- DELETE SUPPLIER --%>
  function deleteSupplier(){ 
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){                 
      disableButtons();
      
      var url = "<c:url value='/assets/ajax/supplier/deleteSupplier.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "SupplierUid="+document.getElementById("EditSupplierUid").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            newSupplier();
            //loadSuppliers();
            searchSuppliers();
            enableButtons();
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'assets/ajax/supplier/deleteSupplier.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }

  <%-- NEW SUPPLIER --%>
  function newSupplier(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditSupplierUid").value = "-1";    
    $("code").value = "";
    $("name").value = "";
    $("address").value = "";
    $("city").value = "";
    $("zipcode").value = "";
    $("country").value = "";
    $("countryCode").value = "";
    $("vatNumber").value = "";
    $("taxIDNumber").value = "";
    $("contactPerson").value = ""; 
    $("telephone").value = "";   
    $("email").value = "";   
    $("accountingCode").value = "";   
    $("comment").value = "";   
    
    $("code").focus();
    resizeAllTextareas(8);
  }
  
  <%-- DISABLE BUTTONS --%>
  function disableButtons(){
    document.getElementById("buttonSave").disabled = true;
    document.getElementById("buttonDelete").disabled = true;
    document.getElementById("buttonNew").disabled = true;
    document.getElementById("buttonBack").disabled = true;    
  }
  
  <%-- ENABLE BUTTONS --%>
  function enableButtons(){
    document.getElementById("buttonSave").disabled = false;
    document.getElementById("buttonDelete").disabled = false;
    document.getElementById("buttonNew").disabled = false;
    document.getElementById("buttonBack").disabled = false;
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href= "<c:url value='/main.do'/>?Page=system/menu.jsp&ts=<%=getTs()%>";
  }
            
  //EditForm.code.focus();
  //loadSuppliers();
  resizeAllTextareas(8);
</script>