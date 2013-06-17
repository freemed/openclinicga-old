<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String feetype = checkString(request.getParameter("feetype"));
	String feeid = checkString(request.getParameter("feeid"));
	String feeamount = checkString(request.getParameter("feeamount"));
	try{
		Float.parseFloat(feeamount);
	}
	catch(Exception e){
		feeamount="0";
	}
	String userid = checkString(request.getParameter("EditCareProvider"));

	if(request.getParameter("submit")!=null && userid.length()>0 && feetype.length()>0 && feeamount.length()>0 && (feetype.equals("prestation")||feetype.equals("prestationtype")||feetype.equals("invoicegroup")?feeid.length()>0:true)){
		//Save these fee data
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from OC_CAREPROVIDERFEES where OC_CAREPROVIDERFEE_USERID=? and OC_CAREPROVIDERFEE_TYPE=? and OC_CAREPROVIDERFEE_ID=?");
		ps.setString(1,userid);
		ps.setString(2,feetype);
		ps.setString(3,feeid);
		ps.execute();
		ps.close();
		ps=conn.prepareStatement("insert into OC_CAREPROVIDERFEES(OC_CAREPROVIDERFEE_USERID,OC_CAREPROVIDERFEE_TYPE,OC_CAREPROVIDERFEE_ID,OC_CAREPROVIDERFEE_AMOUNT) values(?,?,?,?)");
		ps.setString(1,userid);
		ps.setString(2,feetype);
		ps.setString(3,feeid);
		ps.setFloat(4,Float.parseFloat(feeamount));
		ps.execute();
		ps.close();
		conn.close();
	}

%>

<form name="transactionForm" method="post">
	<table width="600px">
	    <tr>
	        <td class='admin' width="1%" nowrap><%=getTran("web","invoicingcareprovider",sWebLanguage)%></td>
	        <td class='admin2'>
	        	<select class='text' name='EditCareProvider' id='EditCareProvider' onchange='listcareproviderfees()'>
	        		<option value=''></option>
			          <%
			          	Vector users = UserParameter.getUserIds("invoicingcareprovider", "on");
			          	SortedMap usernames = new TreeMap();
			          	for(int n=0;n<users.size();n++){
			          		User user = User.get(Integer.parseInt((String)users.elementAt(n)));
			          		usernames.put(user.person.lastname.toUpperCase()+", "+user.person.firstname,user.userid);
			          	}
			         	String sSelectedValue=userid;
			          	Iterator i = usernames.keySet().iterator();
			          	while(i.hasNext()){
			          		String username=(String)i.next();
			          		out.println("<option value='"+usernames.get(username)+"'"+(sSelectedValue.equals(usernames.get(username))?" selected":"")+">"+username+"</option>");
			          	}
			          %>
	        	 </select>
	         </td>
	    </tr>
	    <tr><td colspan="2"><hr/></td></tr>
	    <tr>
	        <td class='admin'><%=getTran("web","type",sWebLanguage)%></td>
	        <td class='admin2'>
	        	<select name="feetype" id="feetype" class="text" onchange="setfeeselection();">
	        		<option value="prestation"><%=getTran("web","prestation",sWebLanguage)%></option>
	        		<option value="prestationtype"><%=getTran("web","type",sWebLanguage)%></option>
	        		<option value="invoicegroup"><%=getTran("web","invoicegroup",sWebLanguage)%></option>
	        		<option value="default"><%=getTran("web","default",sWebLanguage)%></option>
	        	</select>
	        </td>
	    </tr>
	    <tr>
	    	<td class='admin'><div name="typeselectionlabel" id="typeselectionlabel"></div></td>
	    	<td class='admin2'><div name="typeselection" id="typeselection"></div></td>
	    </tr>
	    <tr>
	    	<td class='admin'><%=getTran("web","amount",sWebLanguage)%></td>
	    	<td class='admin2'><table><tr><td><input type='text' class='text' name='feeamount' id='feeamount' size='10'/></td><td><div name='feeamountmodifier' id='feeamountmodifier'></div></td></tr></table></td>
	    </tr>
	    <tr><td colspan="2"><input type="submit" name="submit" value="<%=getTran("web","save",sWebLanguage) %>"/></td></tr>
	</table>
	
</form>
<div name='careproviderfees' id='careproviderfees'></div>
<div name='divMessage' id='divMessage'></div>

<script>
	function setfeeselection(){
		if(document.getElementById("feetype").selectedIndex==0){
			document.getElementById("typeselectionlabel").innerHTML="<%=getTran("web","prestation",sWebLanguage)%>";
			document.getElementById("typeselection").innerHTML="<input type='text' class='text' name='feeid' id='feeid' size='10' readonly/><input type='text' class='text' name='feename' id='feename' readonly size='50'/><img src='<c:url value="/_img/icon_search.gif"/>' class='link' alt='<%=getTran("Web","select",sWebLanguage)%>' onclick='searchPrestation();'>";
			document.getElementById("feeamountmodifier").innerHTML="<%=MedwanQuery.getInstance().getConfigString("currency","")%>";
		}
		else if(document.getElementById("feetype").selectedIndex==1){
			document.getElementById("typeselectionlabel").innerHTML="<%=getTran("web","type",sWebLanguage)%>";
			document.getElementById("typeselection").innerHTML="<select name='feeid' id='feeid' class='text'><%=ScreenHelper.writeSelectUnsorted("prestation.type",feetype,sWebLanguage)%></select>";
			document.getElementById("feeamountmodifier").innerHTML="%";
		}
		else if(document.getElementById("feetype").selectedIndex==2){
			document.getElementById("typeselectionlabel").innerHTML="<%=getTran("web","invoicegroup",sWebLanguage)%>";
			<%
				String s="<select class='text' name='feeid' id='feeid'>";
				Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
				PreparedStatement ps = conn.prepareStatement("select distinct OC_PRESTATION_INVOICEGROUP from OC_PRESTATIONS order by OC_PRESTATION_INVOICEGROUP");
				ResultSet rs=ps.executeQuery();
				while(rs.next()){
					String g=checkString(rs.getString("OC_PRESTATION_INVOICEGROUP")).toUpperCase();
					s+="<option value='"+g+"'>"+g+"</option>";
				}
				rs.close();
				ps.close();
				conn.close();
				s+="</select>";
			%>
			document.getElementById("typeselection").innerHTML="<%=s%>";
			document.getElementById("feeamountmodifier").innerHTML="%";
		}
		else if(document.getElementById("feetype").selectedIndex==3){
			document.getElementById("typeselectionlabel").innerHTML="";
			document.getElementById("typeselection").innerHTML="";
			document.getElementById("feeamountmodifier").innerHTML="%";
		}
	}

	function listcareproviderfees(){
	      var today = new Date();
	      var url= '<c:url value="/system/getCareProviderFees.jsp"/>?ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: 'userid=' + $(EditCareProvider).value,
	          onSuccess: function(resp){
				  $('careproviderfees').innerHTML=resp.responseText;
				  $('divMessage').innerHTML ="";
	          },
	          onFailure: function(){
	              $('divMessage').innerHTML = "Error in function listcareproviderfees() => AJAX";
	          }
	      }
		  );
	}

    function searchPrestation(){
    	document.getElementById("feeid").value = "";
        document.getElementById("feename").value = "";
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=feeid&ReturnFieldDescr=feename");
    }
    
    function editline(feetype,feeid,feename,feeamount){
    	document.getElementById("feetype").value=feetype;
    	setfeeselection();
    	if(document.getElementById("feeid")){document.getElementById("feeid").value=feeid};
    	if(document.getElementById("feename")){document.getElementById("feename").value=feename};
    	if(document.getElementById("feeamount")){document.getElementById("feeamount").value=feeamount};
    }
    
    function deleteline(feetype,feeid,userid){
        var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousure";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("adt.encounter","encounter_close",sWebLanguage)%>");


        if(answer){
	      var today = new Date();
	      var url= '<c:url value="/system/deleteCareProviderFee.jsp"/>?ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: 'userid=' + userid+"&feetype="+feetype+"&feeid="+feeid,
	          onSuccess: function(resp){
				  listcareproviderfees();
				  $('divMessage').innerHTML ="";
			    	if(document.getElementById("feeid")){document.getElementById("feeid").value=''};
			    	if(document.getElementById("feename")){document.getElementById("feename").value=''};
			    	if(document.getElementById("feeamount")){document.getElementById("feeamount").value=''};
	          },
	          onFailure: function(){
	              $('divMessage').innerHTML = "Error in function deleteline() => AJAX";
	          }
	      }
		  );
        }
    }
	
	setfeeselection();
	listcareproviderfees();
</script>
