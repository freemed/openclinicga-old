<%@page import="org.dom4j.DocumentException"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    if(request.getParameter("SaveUserProfile")==null){
    %>
    <form name='UserProfile' action='<c:url value='/main.do'/>?Page=userprofile/changedefaultpage.jsp&SaveUserProfile=ok&ts=<%=getTs()%>' method='Post'>
    <%=writeTableHeader("Web.UserProfile","ChangeDefaultPage",sWebLanguage,"main.do?Page=userprofile/index.jsp")%>
    
    <table border="0" width='100%' align='center' cellspacing="1" class="list">
        <%-- OPTIONS --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.UserProfile","ChangeDefaultPage",sWebLanguage)%></td>
            <td class="admin2">
                <select name='DefaultPage' class="text">
                <%
                    String sSelected = activeUser.getParameter("DefaultPage");

                    SAXReader xmlReader = new SAXReader();
                    String sDefaultPageXML = MedwanQuery.getInstance().getConfigString("templateSource")+"defaultPages.xml";
                    Document document;

                    String sType;
                    String setSelected = "";

                    try{
                        document = xmlReader.read(new URL(sDefaultPageXML));
                        if(document!=null){
                            Element root = document.getRootElement();
                            if(root!=null){
                                Element ePage;
                                Iterator elements = root.elementIterator("defaultPage");

                                while(elements.hasNext()){
                                    ePage = (Element)elements.next();
                                    sType = checkString(ePage.attributeValue("type")).toLowerCase();
                                    if(sType.equals(sSelected)){
                                        setSelected = " selected";
                                    }
                                    else{
                                        setSelected = "";
                                    }
                                    
                                    out.print("<option value=\""+sType+"\""+setSelected+">"+getTranNoLink("defaultPage",sType,sWebLanguage)+"</option>");
                                }
                            }
                        } 
                        else{
                            out.print("<option value='administration'"+setSelected+">"+getTranNoLink("defaultPage","administration",sWebLanguage)+"</option>");
                        }
                    } 
                    catch (DocumentException e){
                        out.print("<option value='administration'"+setSelected+">"+getTranNoLink("defaultPage","administration",sWebLanguage)+"</option>");
                    }
                %>
                </select>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type='submit' name='SaveUserProfile' class="button" value='<%=getTranNoLink("Web.UserProfile","Change",sWebLanguage)%>'>&nbsp;
            <input type='button' name='Cancel' class="button" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick='window.location.href="<c:url value='/main.do'/>?Page=userprofile/index.jsp"'>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
</form>
<%
    }
    else{
        String sDefaultPage = checkString(request.getParameter("DefaultPage"));
        Parameter parameter = new Parameter("DefaultPage",sDefaultPage);
        activeUser.removeParameter("DefaultPage");
        activeUser.updateParameter(parameter);
        activeUser.parameters.add(parameter);
        session.setAttribute("activeUser",activeUser);
        
        out.print("<script>window.location.href='main.do?Page=userprofile/index.jsp';</script>");
    }
%>