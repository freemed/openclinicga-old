<%@page import="be.openclinic.accountancy.*,java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("accountancy.ledger","select",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
	String sEditAccountId=checkString(request.getParameter("EditAccountId"));
	String sEditAccountCode=checkString(request.getParameter("EditAccountCode"));
	String sEditAccountType=checkString(request.getParameter("EditAccountType"));
	String sEditAccountName=checkString(request.getParameter("EditAccountName"));

	int accountId=-1;
	try{
		accountId=Integer.parseInt(sEditAccountId);		
	}
	catch(Exception e){
	}
	Account account = new Account();
	if(accountId>0){
		account = Account.get(accountId);
	}

	if(checkString(request.getParameter("action")).equalsIgnoreCase("save")){
		account.setCode(sEditAccountCode);
		account.setType(sEditAccountType);
		account.setName(sEditAccountName);
		account.setUpdateUser(activeUser.userid);
		account.store();
		account=new Account();
	}
	
	if(checkString(request.getParameter("action")).equalsIgnoreCase("delete")){
		account.delete();
		account=new Account();
	}
	
%>

<%=writeTableHeader("web","ledger",sWebLanguage,"")%><br>
<div id="divAccounts" class="searchResults" style="height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditAccountId" name="EditAccountId" value="<%=account.getId()%>">
    <input type="hidden" id="action" name="action" value=""/>
    <table class="list" border="0" width="100%" cellspacing="1">
        <%-- code --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web","code",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="text" class="text" id="EditAccountCode" name="EditAccountCode" size="20" maxLength="20" value="<%=checkString(account.getCode())%>">
            </td>
        </tr>

        <%-- Type --%>
        <tr>
            <td class="admin" nowrap><%=getTran("web","type",sWebLanguage)%> *</td>
            <td class="admin2">
                <select class="text" id="EditAccountType" name="EditAccountType"> 
                    <%=ScreenHelper.writeSelect("account.type",checkString(account.getType()),sWebLanguage)%>
                </select>
            </td>                        
        </tr>
       
        <%-- name --%>                    
        <tr>
            <td class="admin" nowrap><%=getTran("web","name",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="text" class="text" name="EditAccountName" id="EditAccountName" size="80" maxLength="255" value="<%=checkString(account.getName())%>"/>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveItem();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteItem();">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newItem();">&nbsp;
                
                <%                    
                    if(account.getId()<0){
                        %>
                            <script>
                              document.getElementById("buttonDelete").style.visibility = "hidden";
                              document.getElementById("buttonNew").style.visibility = "hidden";
                            </script>
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
	function saveItem(){
		document.getElementById("action").value="save";
		document.getElementById("EditForm").submit();		
	}
	
	function deleteItem(){
		document.getElementById("action").value="delete";
		document.getElementById("EditForm").submit();		
	}
	
	function newItem(){
        $("EditAccountId").value = "";
        $("EditAccountCode").value = "";
        $("EditAccountType").value = "";
        $("EditAccountName").value = "";
        <%-- display delete button --%>
        if(document.getElementById("buttonDelete")){
      		document.getElementById("buttonDelete").style.visibility = "hidden";
        }
        <%-- display new button --%>
        if(document.getElementById("buttonNew")){
      		document.getElementById("buttonNew").style.visibility = "hidden";
        }
        document.getElementById("EditAccountCode").focus();
	}
	
    function displayItem(id){          
      var url= "<c:url value='/accountancy/ajax/getAccount.jsp'/>?ts="+new Date().getTime();
      
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "id="+id,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");

            $("EditAccountId").value = id;
            $("EditAccountCode").value = data.code;
            $("EditAccountType").value = data.type;
            $("EditAccountName").value = data.name;
            
            document.getElementById("divMessage").innerHTML = ""; 

            <%-- display delete button --%>
            if(document.getElementById("buttonDelete")){
          		document.getElementById("buttonDelete").style.visibility = "visible";
            }
            <%-- display new button --%>
            if(document.getElementById("buttonNew")){
          		document.getElementById("buttonNew").style.visibility = "visible";
            }
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'accountancy/ajax/getAccount.jsp' : "+resp.responseText.trim();
          }
        }
      );
    }
    
	
    <%-- LOAD ACCOUNTS --%>
    function loadAccounts(){
      document.getElementById("divAccounts").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading";            
      var url= "<c:url value='/accountancy/ajax/getAccounts.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "",
          onSuccess: function(resp){
            $("divAccounts").innerHTML = resp.responseText;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'accountancy/ajax/getAccounts.jsp' : "+resp.responseText.trim();
          }
        }
      );
    }

    loadAccounts();
    document.getElementById("EditAccountCode").focus();
</script>