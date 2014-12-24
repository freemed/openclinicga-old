<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String feetype   = checkString(request.getParameter("feetype")),
	       feeid     = checkString(request.getParameter("feeid")),
	       feeamount = checkString(request.getParameter("feeamount"));
 
    String userid = checkString(request.getParameter("EditCareProvider"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n****************** system/manageCareProviderFees.jsp ******************");
		Debug.println("feetype   : "+feetype);
		Debug.println("feeid     : "+feeid);
		Debug.println("feeamount : "+feeamount);
		Debug.println("userid    : "+userid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

	try{
		Float.parseFloat(feeamount.replace(",","."));
	}
	catch(Exception e){
		feeamount = "0";
	}
	
	if(request.getParameter("submit")!=null && userid.length()>0 && feetype.length()>0 && feeamount.length()>0 && (feetype.equals("prestation")||feetype.equals("prestationtype")||feetype.equals("invoicegroup")?feeid.length()>0:true)){
		// Save these fee data
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from OC_CAREPROVIDERFEES"+
		                                             " where OC_CAREPROVIDERFEE_USERID=? and OC_CAREPROVIDERFEE_TYPE=? and OC_CAREPROVIDERFEE_ID=?");
		ps.setString(1,userid);
		ps.setString(2,feetype);
		ps.setString(3,feeid);
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("insert into OC_CAREPROVIDERFEES(OC_CAREPROVIDERFEE_USERID,OC_CAREPROVIDERFEE_TYPE,OC_CAREPROVIDERFEE_ID,OC_CAREPROVIDERFEE_AMOUNT)"+
		                         " values(?,?,?,?)");
		ps.setString(1,userid);
		ps.setString(2,feetype);
		ps.setString(3,feeid);
		ps.setFloat(4,Float.parseFloat(feeamount.replace(",",".")));
		ps.execute();
		ps.close();
		conn.close();
	}
%>

<form name="transactionForm" method="post">
    <%=writeTableHeader("web.manage","manageCareProviderFees",sWebLanguage," doBack();")%>
    
	<table width="100%" class="list" celllpadding="0" cellspacing="1">
	    <%-- CARE PROVIDER --%>
	    <tr>
	        <td class='admin' width="<%=sTDAdminWidth%>" nowrap><%=getTran("web","invoicingCareprovider",sWebLanguage)%></td>
	        <td class='admin2'>
	        	<select class='text' name='EditCareProvider' id='EditCareProvider' onchange='listcareproviderfees()'>
	        		  <option value=''></option>
			          <%
			              Vector users = UserParameter.getUserIds("invoicingcareprovider","on");
			              SortedMap usernames = new TreeMap();
			              for(int n=0; n<users.size(); n++){
			                  User user = User.get(Integer.parseInt((String)users.elementAt(n)));
			          	      usernames.put(user.person.lastname.toUpperCase()+", "+user.person.firstname,user.userid);
			              }
			          	
			              String sSelectedValue = userid;
			              Iterator iter = usernames.keySet().iterator();
			              while(iter.hasNext()){
			         	      String username = (String)iter.next();
			         	      out.print("<option value='"+usernames.get(username)+"'"+(sSelectedValue.equals(usernames.get(username))?" selected":"")+">"+username+"</option>");
			              }
			          %>
	        	 </select>
	         </td>
	    </tr>	
	</table>
	
	<div style="padding-top:10px;"></div>	
	    
	<table width="100%" class="list" celllpadding="0" cellspacing="1">
	    <%-- TYPE --%>
	    <tr>
	        <td class='admin' width="<%=sTDAdminWidth%>"><%=getTran("web","type",sWebLanguage)%></td>
	        <td class='admin2'>
	        	<select name="feetype" id="feetype" class="text" onchange="setfeeselection();">
	        		<option value="prestation"><%=getTranNoLink("web","prestation",sWebLanguage)%></option>
	        		<option value="prestationtype"><%=getTranNoLink("web","type",sWebLanguage)%></option>
	        		<option value="invoicegroup"><%=getTranNoLink("web","invoicegroup",sWebLanguage)%></option>
	        		<option value="default"><%=getTranNoLink("web","default",sWebLanguage)%></option>
	        	</select>
	        </td>
	    </tr>
	    <%-- LABEL --%>
	    <tr>
	    	<td class='admin'><div name="typeselectionlabel" id="typeselectionlabel"></div></td>
	    	<td class='admin2'><div name="typeselection" id="typeselection"></div></td>
	    </tr>
	    <%-- AMOUNT --%>
	    <tr>
	    	<td class='admin'><%=getTran("web","amount",sWebLanguage)%></td>
	    	<td class='admin2'>
	    	    <table cellpadding="0" cellspacing="0">
	    	        <tr>
	    	            <td>
	    	                <input type='text' class='text' name='feeamount' id='feeamount' size='10'/>
	    	            </td>
	    	            <td style="padding-left:3px;">
	    	                <div name='feeamountmodifier' id='feeamountmodifier'></div>
	    	            </td>
	    	        </tr>
	    	    </table>
	    	</td>
	    </tr>
	    <%-- BUTTONS --%>
	    <tr>
	        <td class="admin">&nbsp;</td>
	        <td class="admin2">
	            <input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","save",sWebLanguage)%>"/>
	        </td>
	    </tr>
	</table>	

	<div name='careproviderfees' id='careproviderfees'></div>
	<div name='divMessage' id='divMessage'></div>
	
	<%=ScreenHelper.alignButtonsStart()%>
	    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" OnClick="doBack();">
	<%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  <%-- SET FEE SELECTION --%>
  function setfeeselection(){
	if(document.getElementById("feetype").selectedIndex==0){
	  document.getElementById("typeselectionlabel").innerHTML = "<%=getTranNoLink("web","prestation",sWebLanguage)%>";
	  document.getElementById("typeselection").innerHTML = "<input type='text' class='text' name='feeid' id='feeid' size='10' readonly/>"+
	                                                       "<input type='text' class='text' name='feename' id='feename' readonly size='50'/>"+
	                                                       "&nbsp;<img src='<c:url value="/_img/icons/icon_search.gif"/>' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick='searchPrestation();'>";
	  document.getElementById("feeamountmodifier").innerHTML = "<%=MedwanQuery.getInstance().getConfigString("currency","")%>";
	}
	else if(document.getElementById("feetype").selectedIndex==1){
	  document.getElementById("typeselectionlabel").innerHTML = "<%=getTranNoLink("web","type",sWebLanguage)%>";
	  document.getElementById("typeselection").innerHTML = "<select name='feeid' id='feeid' class='text'><%=ScreenHelper.writeSelectUnsorted("prestation.type",feetype,sWebLanguage)%></select>";
	  document.getElementById("feeamountmodifier").innerHTML = "%";
	}
	else if(document.getElementById("feetype").selectedIndex==2){
	  document.getElementById("typeselectionlabel").innerHTML = "<%=getTranNoLink("web","invoicegroup",sWebLanguage)%>";
	  <%
	 	String sHtml = "<select class='text' name='feeid' id='feeid'>";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("select distinct OC_PRESTATION_INVOICEGROUP from OC_PRESTATIONS"+
		                                             " order by OC_PRESTATION_INVOICEGROUP");
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String sGroup = checkString(rs.getString("OC_PRESTATION_INVOICEGROUP")).toUpperCase();
			sHtml+= "<option value='"+sGroup+"'>"+sGroup+"</option>";
		}

		rs.close();
		ps.close();
		conn.close();
			
		sHtml+= "</select>";
	  %>
	  
	  document.getElementById("typeselection").innerHTML="<%=sHtml%>";
	  document.getElementById("feeamountmodifier").innerHTML="%";
	}
	else if(document.getElementById("feetype").selectedIndex==3){
	  document.getElementById("typeselectionlabel").innerHTML="";
      document.getElementById("typeselection").innerHTML="";
	  document.getElementById("feeamountmodifier").innerHTML="%";
  	}
  }

  <%-- LIST CARE PROVIDER FEES --%>
  function listcareproviderfees(){
    var url = '<c:url value="/system/getCareProviderFees.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
	  method: "POST",
	  postBody: 'userid='+$("EditCareProvider").value,
	  onSuccess: function(resp){
	    $('careproviderfees').innerHTML = resp.responseText;
		$('divMessage').innerHTML = "";
	  },
	  onFailure: function(){
	    $('divMessage').innerHTML = "Error in function listcareproviderfees() => AJAX";
	  }
	});
  }

  <%-- SEARCH PRESTATION --%>
  function searchPrestation(){
    document.getElementById("feeid").value = "";
    document.getElementById("feename").value = "";
    
    openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=feeid&ReturnFieldDescr=feename");
  }

  <%-- EDIT LINE --%>
  function editline(feetype,feeid,feename,feeamount){
    document.getElementById("feetype").value=feetype;
    setfeeselection();
      
    if(document.getElementById("feeid")){document.getElementById("feeid").value=feeid};
    if(document.getElementById("feename")){document.getElementById("feename").value=feename};
    if(document.getElementById("feeamount")){document.getElementById("feeamount").value=feeamount};
  }
    
  <%-- DELETE LINE --%>
  function deleteline(feetype,feeid,userid){
    if(yesnoDeleteDialog()){
	  var url = '<c:url value="/system/deleteCareProviderFee.jsp"/>?ts='+new Date();
      new Ajax.Request(url,{
	    method: "POST",
	    postBody: 'userid='+userid+"&feetype="+feetype+"&feeid="+feeid,
	    onSuccess: function(resp){
		  listcareproviderfees();
		  $('divMessage').innerHTML = "";
			
	      if(document.getElementById("feeid")){document.getElementById("feeid").value=''};
	  	  if(document.getElementById("feename")){document.getElementById("feename").value=''};
	  	  if(document.getElementById("feeamount")){document.getElementById("feeamount").value=''};
        },
        onFailure: function(){
          $('divMessage').innerHTML = "Error in function deleteline() => AJAX";
        }
      });
    }
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }  
	
  setfeeselection();
  listcareproviderfees();
</script>