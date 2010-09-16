<H5>This connection request has been forbidden by the MedWAN network manager</H5>
<br>
If you feel this is incorrect, please contact the <a href="mailto:rik.lemmens@dpms.be">system administrator</a>.
<br><br>

<table>
    <tr><td colspan="2">Connection information:</td></tr>
    <tr><td>Client address</td><td><%=request.getParameter("clientaddr")%></td></tr>
    <tr><td>Client name</td><td><%=request.getParameter("clientname")%></td></tr>
    <tr><td>Client user</td><td><%=request.getParameter("clientuser")%></td></tr>
    <tr><td>Client group</td><td><%=request.getParameter("clientgroup")%></td></tr>
    <tr><td>URL</td><td><%=request.getParameter("url")%></td></tr>
</table>