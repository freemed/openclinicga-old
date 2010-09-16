<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<html>
    <head>
        <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
        <%=sCSSNORMAL%>
    <head>

    <body>
        <table cellspacing="0" cellpadding="0" style="padding:5px" width="100%">
            <tr>
                <td class="white">
                    <script>
                      window.resizeTo(800,500);

                      if(navigator.appName == "Netscape"){
                        document.write(window.opener.parent.document.getElementById("<%=request.getParameter("Field")%>").innerHTML);
                      }
                      else{
                        document.write(window.opener.<%=request.getParameter("Field")%>.innerHTML);
                      }

                      window.print();
                    </script>
                </td>
            </tr>
        </table>
    </body>
</html>