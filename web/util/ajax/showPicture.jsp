<%@ page import="be.mxs.common.util.system.Picture,be.mxs.common.util.db.MedwanQuery,java.io.*" %>
<%@include file="/includes/validateUser.jsp"%>

<%
    if (request.getParameter("personid") != null && Picture.exists(Integer.parseInt(request.getParameter("personid")))) {
        Picture picture = new Picture(Integer.parseInt(request.getParameter("personid")));
        File file = new File(MedwanQuery.getInstance().getConfigString("DocumentsFolder", "c:/projects/openclinic/documents") + "/" + activeUser.userid + ".jpg");
            FileOutputStream fileOutputStream = new FileOutputStream(file);
            fileOutputStream.write(picture.getPicture());
            fileOutputStream.close();
        %>
<table width="100%" style="background-color:white">
    <tr>
        <td class="image" valign="top" width="143px">
            <img border='0' src='<c:url value="/" />documents/<%=activeUser.userid%>.jpg'/>
            <img border='0'  src='<c:url value="/_img/photo.gif"/>'/>
        </td>
    </tr>
</table>

    <%} else {
        %>
        <table width='100%'>
            <tr>
                <td align="center"><%=MedwanQuery.getInstance().getLabel("web", "picturedoesnotexist", sWebLanguage)%></td>
            </tr>
            <tr>
                <td align="center" style="line-height:30px;"><a href="javascript:void(0)" onclick="storePicture()"><img src="<c:url value="/_img/icon_takephoto.png" />" border="0" alt="<%=getTranNoLink("web", "loadPicture", sWebLanguage)%>" title="<%=getTranNoLink("web", "loadPicture", sWebLanguage)%>" />  <%=getTranNoLink("web", "loadPicture", sWebLanguage)%></a></td>
            </tr>
        </table>
        <%
    }
%>
<br/>
<center>
    <input type="button" class="button" value="<%=getTran("web","close",sWebLanguage)%>" onclick="Modalbox.hide()"/>
</center>