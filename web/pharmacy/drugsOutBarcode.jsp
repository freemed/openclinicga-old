<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********************* pharmacy/drugsOutBarcode.jsp ********************");
        Debug.println("no parameters");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<form name="drugsOutForm" method="post">
    <%=writeTableHeader("web","drugsoutbarcode",sWebLanguage," window.close();")%>

    <table width="100%" class="list" cellpadding="0" cellspacing="1">        
        <%-- SERVICE STOCK --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","servicestock",sWebLanguage)%></td>
            <td class="admin2">
                <select name="servicestock" id="servicestock">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        String defaultPharmacy = MedwanQuery.getInstance().getConfigString("defaultPharmacy","");
                        Vector servicestocks = ServiceStock.getStocksByUser(activeUser.userid);
                        
                        ServiceStock stock;
                        for(int n=0; n<servicestocks.size(); n++){
                            stock = (ServiceStock)servicestocks.elementAt(n);
                            out.print("<option value='"+stock.getUid()+"' "+(stock.getUid().equals(defaultPharmacy)?"selected":"")+">"+stock.getName().toUpperCase()+"</option>");
                        }
                    %>
                </select>
            </td>
        </tr>
        
        <%-- PRODUCT --%>
        <tr>
            <td class='admin'><%=getTran("web","product",sWebLanguage)%></td>
            <td class='admin2'><input type='text' class='text' name='drugbarcode' id='drugbarcode' size='20' onkeyup='if(enterEvent(event,13)){doAdd("");}'/></td>
        </tr>
        
        <%-- QUANTITY --%>
        <tr>
            <td class='admin'><%=getTran("web","quantity",sWebLanguage)%></td>
            <td class='admin2'><input type='text' class='text' name='quantity' id='quantity' size='5' value='1'/></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class='admin'>&nbsp;</td>
            <td class='admin'>
                <input type='button' class="button" name='addbutton' id='addbutton' value='<%=getTranNoLink("web","add",sWebLanguage)%>' onclick="doAdd('');"/>&nbsp;&nbsp;&nbsp;
                <input type='button' class="button" name='deliverbutton' id='deliverbutton' value='<%=getTranNoLink("web","deliver",sWebLanguage)%>' onclick="doDeliver('');"/>
                <input type='button' class="button" name='invoicebutton' id='invoicebutton' value='<%=getTranNoLink("web","invoice",sWebLanguage)%>' onclick='window.opener.location.href="<c:url value="main.do?Page=financial/patientInvoiceEdit.jsp"/>";window.close();'/>
            </td>
        </tr>
    </table>    
</form>

<%-- SEARCH RESULTS (ajax) --%>
<div name="divDrugsOut" id="divDrugsOut"></div>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>
            
<script>
  <%-- DO ADD --%>
  function doAdd(loadonly){
    var url = "<c:url value='/pharmacy/addDrugsOutBarcode.jsp'/>?loadonly="+loadonly+
              "&ServiceStock="+document.getElementById("servicestock").value+
              "&DrugBarcode="+document.getElementById("drugbarcode").value+
              "&Quantity="+document.getElementById("quantity").value+
              "&ts="+new Date();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        if(label.message && label.message.length>0){
          $("divDrugsOut").innerHTML = "<font color='red'>"+label.message+"</font>";
        }
        else{
          if(label.drugs.length > 0){
            $("divDrugsOut").innerHTML = label.drugs;
          }
          document.getElementById("drugbarcode").value = "";
        }
      }
    });
    document.getElementById('drugbarcode').focus();  
  }

  <%-- DO DELETE --%>
  function doDelete(listuid){
    var url = '<c:url value="/pharmacy/deleteDrugsOutBarcode.jsp"/>?listuid='+listuid+'&ts='+new Date();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        if(label.message && label.message.length>0){
          $("divDrugsOut").innerHTML = "<font color='red'>"+label.message+"</font>";
        }
        else{
          if(label.drugs.length > 0){
            $('divDrugsOut').innerHTML = label.drugs;
          }
        }
      }
    });
    document.getElementById('drugbarcode').focus();
  }

  <%-- DO DELIVER --%>
  function doDeliver(listuid){
    var url = '<c:url value="/pharmacy/deliverDrugsOutBarcode.jsp"/>?listuid='+listuid+'&ts='+new Date();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "",
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        if(label.message && label.message.length>0){
          $("divDrugsOut").innerHTML = "<font color='red'>"+label.message+"</font>";
        }
        else{
          if(label.drugs.length > 0){
            $('divDrugsOut').innerHTML = label.drugs;
          }
        }
      }
    });
  }
    
  doAdd('yes');
  document.getElementById('drugbarcode').focus();
</script>