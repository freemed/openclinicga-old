<%@ page import="be.openclinic.pharmacy.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<form name='drugsOutForm' method='post'>
	<table width='100%'>
		<%
			String defaultPharmacy = MedwanQuery.getInstance().getConfigString("defaultPharmacy","");
		%>
		<tr>
			<td class='admin'><%=getTran("web","servicestock",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='servicestock' id='servicestock'>
					<option value=''></option>
					<%
						Vector servicestocks = ServiceStock.getStocksByUser(activeUser.userid);
						for(int n=0;n<servicestocks.size();n++){
							ServiceStock stock = (ServiceStock)servicestocks.elementAt(n);
							out.println("<option value='"+stock.getUid()+"' "+(stock.getUid().equalsIgnoreCase(defaultPharmacy)?"selected":"")+">"+stock.getName().toUpperCase()+"</option>");
						}
					%>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","product",sWebLanguage) %></td>
			<td class='admin2'><input type='text' class='text' name='drugbarcode' id='drugbarcode' size='20' onkeyup='if(event.keyCode==13){doAdd("");}'/></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","quantity",sWebLanguage) %></td>
			<td class='admin2'><input type='text' class='text' name='quantity' id='quantity' size='5' value='1'/></td>
		</tr>
		<tr>
			<td class='admin'><input type='button' name='addbutton' id='addbutton' value='<%=getTran("web","add",sWebLanguage) %>' onclick='doAdd("");'/></td>
			<td class='admin'>
				<input type='button' name='deliverbutton' id='deliverbutton' value='<%=getTran("web","deliver",sWebLanguage) %>' onclick='doDeliver("");'/>
				<input type='button' name='invoicebutton' id='invoicebutton' value='<%=getTran("web","invoice",sWebLanguage) %>' onclick='window.opener.location.href="<c:url value="main.do?Page=financial/patientInvoiceEdit.jsp"/>";window.close();'/>
			</td>
		</tr>
		<tr>
			<td colspan='2'><div name='divDrugsOut' id='divDrugsOut'></div></td>
		</tr>
	</table>
	
</form>

<script>
	function doAdd(loadonly){
        var params = '';
        var today = new Date();
        var url= '<c:url value="/pharmacy/addDrugsOutBarcode.jsp"/>?loadonly='+loadonly+'&DrugBarcode='+document.getElementById('drugbarcode').value+'&ServiceStock='+document.getElementById('servicestock').value+'&Quantity='+document.getElementById('quantity').value+'&ts='+today;
        new Ajax.Request(url,{
			method: "GET",
            parameters: params,
            onSuccess: function(resp){
            	var label = eval('('+resp.responseText+')');
            	if(label.message && label.message.length>0){
                	alertDialogMessage(label.message);
                }
            	else {
            		$('divDrugsOut').innerHTML=label.drugs;
            		document.getElementById('drugbarcode').value='';
            	}
            }
        }
		);
    	document.getElementById('drugbarcode').focus();
	}
	
	function doDelete(listuid){
        var params = '';
        var today = new Date();
        var url= '<c:url value="/pharmacy/deleteDrugsOutBarcode.jsp"/>?listuid='+listuid+'&ts='+today;
        new Ajax.Request(url,{
			method: "GET",
            parameters: params,
            onSuccess: function(resp){
            	var label = eval('('+resp.responseText+')');
            	if(label.message && label.message.length>0){
            		alertDialogMessage(label.message);
                }
            	else {
            		$('divDrugsOut').innerHTML=label.drugs;
            	}
            }
        }
    	);
    	document.getElementById('drugbarcode').focus();
	}
	
	function doDeliver(listuid){
        var params = '';
        var today = new Date();
        var url= '<c:url value="/pharmacy/deliverDrugsOutBarcode.jsp"/>?listuid='+listuid+'&ts='+today;
        new Ajax.Request(url,{
			method: "GET",
            parameters: params,
            onSuccess: function(resp){
            	var label = eval('('+resp.responseText+')');
            	if(label.message && label.message.length>0){
            		alertDialogMessage(label.message);
                }
            	else {
            		$('divDrugsOut').innerHTML=label.drugs;
            	}
            }
        }
    	);
    	//Nu redirecten naar factuur?
	}
	
	doAdd('yes');
	document.getElementById('drugbarcode').focus();
</script>