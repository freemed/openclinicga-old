<%@page import="be.mxs.common.util.system.Picture,
                be.mxs.common.util.db.MedwanQuery,
                java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sPersonId = checkString(request.getParameter("personid"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n********************** util/ajax/showPicture.jsp **********************");
	    Debug.println("sPersonId : "+sPersonId+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
    if(sPersonId.length() > 0){
        boolean pictureExists = Picture.exists(Integer.parseInt(sPersonId));
        Debug.println("pictureExists : "+pictureExists);
        
    	if(pictureExists){
	        Picture picture = new Picture(Integer.parseInt(sPersonId));
	        
	        String sDocumentsFolder = MedwanQuery.getInstance().getConfigString("DocumentsFolder","c:/projects/openclinic/documents");
	        Debug.println("sDocumentsFolder : "+sDocumentsFolder); 
	        File file = new File(sDocumentsFolder+"/"+activeUser.userid+".jpg");
	        Debug.println("file.exists : "+file.exists());
	        
            FileOutputStream fileOutputStream = new FileOutputStream(file);
            fileOutputStream.write(picture.getPicture());
            fileOutputStream.close();
            
	        %>
				<table width="100%">
				    <tr>
				        <td class="image" style="vertical-align:top;">
				            <img border='0' src='<c:url value="/"/>documents/<%=activeUser.userid%>.jpg'/>
				        </td>
				    </tr>
				</table>
	        <%
        }
        else{
            %>
				<table width="100%">
    	            <tr>
    	                <td align="center"><%=getTran("web","picturedoesnotexist",sWebLanguage)%></td>
    	            </tr>
    	            <tr>
    	                <td align="center" style="line-height:30px;"><a href="javascript:void(0)" onclick="storePicture()">
    	                    <img src="<c:url value='/_img/icons/icon_takephoto.png'/>" border="0" alt="<%=getTranNoLink("web","loadPicture",sWebLanguage)%>" title="<%=getTranNoLink("web", "loadPicture", sWebLanguage)%>" />  <%=getTranNoLink("web", "loadPicture", sWebLanguage)%></a>
    	                </td>
    	            </tr>
    	        </table>
            <%
        }
    }
%>
<br/>

<center>
    <input type="button" class="button" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="Modalbox.hide()"/>
</center>