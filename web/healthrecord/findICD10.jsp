<%@page import="be.mxs.common.model.vo.healthrecord.ICPCCode, java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSPOPUPSEARCH%>
<%-- Start Floating Layer ------------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:225;top:170;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
              <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>
<%-- End Floating layer --------------------------------------------------------------------------%>

<form name="icd10Form" method="POST" onSubmit="doFind();">
    <table class='menu' width='100%' cellspacing="0">
        <tr>
            <td nowrap><%=getTran("Web","Keyword",sWebLanguage)%>&nbsp;&nbsp;</td>
            <td>
                <input type='text' class='text' name='keywords' size='40' value="<%=request.getParameter("keywords")!=null?request.getParameter("keywords"):""%>" onblur="limitLength(this);"/>
                <input class='button' type='button' name='findButton' onClick='doFind();' value='<%=getTranNoLink("Web","Find",sWebLanguage)%>'/>
                <input class='button' type='button' name='cancel' onclick='window.close()' value='<%=getTranNoLink("Web","Close",sWebLanguage)%>'/>
            </td>
        </tr>

        <tr><td class="navigation_line" height="1" colspan="3"></td></tr>

        <%
            String keywords = checkString(request.getParameter("keywords"));
            int foundRecords = 0;

            // Hier worden de geselecteerde ICPC-codes getoond
            if (keywords.length() > 0) {
                Vector codes = MedwanQuery.getInstance().findICD10Codes(request.getParameter("keywords"), sWebLanguage);
                ICPCCode code;

        %><tbody class="hand"><%

                for (int n=0; n<codes.size(); n++){
                    foundRecords++;
                    code = (ICPCCode)codes.elementAt(n);

                    if (code.code.length()==5 && code.code.substring(3,5).equalsIgnoreCase("00")){
                        out.print("<tr class='label2'");
                    }
                    else {
                        out.print("<tr");
                    }

                    out.print(" onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>");
                    out.print(" <td>"+code.code+"</td>");
                    out.print(" <td>"+code.label+"</td>");
                    out.print("</tr>");
                }

                %></tbody><%
            }

            if(foundRecords==0 && keywords.length() > 0){
                // display 'no results' message
                %>
                    <tr class='label2'>
                        <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                    </tr>
                <%
            }
        %>
    </table>
</form>
<script>
  window.resizeTo(700,470);

  function doFind(){
    ToggleFloatingLayer('FloatingLayer',1);
    icd10Form.findButton.disabled = true;
    icd10Form.submit();
  }

  function addICD10(code,label){
    window.opener.icpccodes.innerHTML = window.opener.icpccodes.innerHTML+"<span id='"+code+"'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' onclick='window."+code+".innerHTML=\"\";'/> <input type='hidden' name='ICD10Code"+code+"' value='medwan.common.true'/>"+code+"&nbsp;"+label+"<br/></span>";
  }

  document.getElementsByName('keywords')[0].focus();
</script>
