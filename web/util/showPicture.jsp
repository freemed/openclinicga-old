<%@ page import="be.mxs.common.util.system.Picture,be.mxs.common.util.db.MedwanQuery,java.io.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n************************* util/showPicture.jsp ************************");
	    Debug.println("No parameters\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    if(request.getParameter("personid") != null && Picture.exists(Integer.parseInt(request.getParameter("personid")))) {
        Picture picture = new Picture(Integer.parseInt(request.getParameter("personid")));
        String sDocumentsFolder = MedwanQuery.getInstance().getConfigString("DocumentsFolder","c:/projects/openclinic/documents");
        File file = new File(sDocumentsFolder+"/"+activeUser.userid+".jpg");
        FileOutputStream fileOutputStream = new FileOutputStream(file);
        fileOutputStream.write(picture.getPicture());
        fileOutputStream.close();
        
        out.print("<img height='300' src='"+MedwanQuery.getInstance().getConfigString("DocumentsURL")+"/" + activeUser.userid + ".jpg"+"'/>");
    }
    else {
        %>
	        <table width='100%'>
	            <tr>
	                <td align="center"><%=MedwanQuery.getInstance().getLabel("web", "picturedoesnotexist", sWebLanguage)%></td>
	            </tr>
	            <tr>
	                <td align="center"><img border='0' src='<c:url value="/_img/nopicture.jpg"/>'/></td>
	            </tr>
	        </table>
        <%
    }
%>
<br/>

<center>
    <input type="button" class="button" value="<%=getTran("web","close",sWebLanguage)%>" onclick="window.close()"/>
</center>