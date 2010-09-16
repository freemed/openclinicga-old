<%@ include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<html>
    <head>
        <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
        <%=sCSSNORMAL%>
    <head>
    <body>
        <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td class="white">
                    <table width="100%" class="list" cellspacing="0" cellpadding="5">
                        <tr>
                            <td><b><%=sAPPTITLE%></b></td>
                        </tr>
                        <tr>
                            <td><b>ICT-support, system administration</b></td>
                        </tr>
                    </table>
                    <br>
                    <b><u>Activity report</u></b>
                    <br><br>
                    <table width="100%" cellpadding="5" cellspacing="0" class="list" style="border-collapse:collapse">
                        <tr>
                            <td width="20%" class="list"><b>Name</b><br><br></td>
                            <td width="*" class="list" valign="top">&nbsp;<script>document.write(window.opener.transactionForm.EditName.value);</script></td>
                        </tr>
                        <tr>
                            <td width="20%" class="list"><b>Date</b><br><br></td>
                            <td width="*" class="list" valign="top">&nbsp;<script>document.write(window.opener.transactionForm.EditDate.value);</script></td>
                        </tr>
                        <tr>
                            <td width="20%" class="list"><b>Arrival</b><br><br></td>
                            <td width="*" class="list" valign="top">&nbsp;<script>document.write(window.opener.transactionForm.EditFrom.value);</script></td>
                        </tr>
                        <tr>
                            <td width="20%" class="list"><b>Departure</b><br><br></td>
                            <td width="*" class="list" valign="top">&nbsp;<script>document.write(window.opener.transactionForm.EditUntil.value);</script></td>
                        </tr>
                        <tr>
                            <td width="20%" class="list"><b>Location</b><br><br></td>
                            <td width="*" class="list" valign="top">&nbsp;<script>document.write(window.opener.transactionForm.WUnitDescription.value);</script></td>
                        </tr>
                    </table>
                    <br>
                    Executed tasks:
                    <br><br>
                    <table width="100%" height="300">
                        <tr>
                            <td valign="top" align="left"><script>document.write(window.opener.transactionForm.EditTask.value);</script>&nbsp;</td>
                        </tr>
                    </table>
                    <br>
                    Signatures:
                    <br><br>
                    <table width="100%" cellspacing="0" cellpadding="0">
                        <tr>
                            <td width="50%"><b>Support contractor</b></td>
                            <td><b><script>document.write(window.opener.transactionForm.WUnitDescription.value);</script>&nbsp;</b></td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td><script>document.write(window.opener.transactionForm.EditName.value);</script></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <script>
//            window.print();
        </script>
    </body>
</html>