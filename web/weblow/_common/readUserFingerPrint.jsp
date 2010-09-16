<%@ page import="be.openclinic.id.FingerPrint" %>
<%@ page import="be.mxs.common.util.system.ScreenHelper" %>
<%@ page import="sun.misc.BASE64Decoder" %>
<%@ page import="sun.misc.BASE64Encoder" %>
<%@ page import="com.griaule.grfingerjava.Template" %>
<%@ page import="net.admin.User" %>
<%@ page import="java.util.Vector" %>
<%@include file="../includes/SingletonContainer.jsp"%>
<%!
    //--- ENCODE ----------------------------------------------------------------------------------
    public String encode(byte[] sValue) {
        BASE64Encoder encoder = new BASE64Encoder();
        return encoder.encodeBuffer(sValue);
    }

    //--- DECODE ----------------------------------------------------------------------------------
    public byte[] decode(String sValue) {
        byte[] sReturn = null;
        BASE64Decoder decoder = new BASE64Decoder();

        try {
            sReturn = decoder.decodeBuffer(sValue);
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        return sReturn;
    }
    static public String checkString(String sString) {
        // om geen 'null' weer te geven
        if ((sString==null)||(sString.toLowerCase().equals("null"))) {
            return "";
        }
        else {
            sString = sString.trim();
        }
        return sString;
    }
%>
<head>
    <link href='<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/_common/_css/web.css' rel='stylesheet' type='text/css'>
    <link href='<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/"<%=checkString((String) session.getAttribute("activeProjectDir"))%>"/_common/_css/web.css' rel='stylesheet' type='text/css'>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <META HTTP-EQUIV="Expires" CONTENT="-1"/>
</head>
<body onload="javascript:res();">
<script type="text/javascript">
    function res(){
        window.resizeTo(400,200);
        window.moveTo((self.screen.width-document.body.clientWidth)/2,(self.screen.height-document.body.clientHeight)/2);
    }
</script>
<%
    if (request.getParameter("template") != null) {
        //todo: identify template in central database
        FingerPrint.close();
        FingerPrint.getFingerPrint().setTemplate(new Template());
        FingerPrint.getFingerPrint().getTemplate().setData(decode(request.getParameter("template")));
        if (FingerPrint.getFingerPrint().identify()) {
            if (FingerPrint.getFingerPrint().getMatches().size() == 1) {
                //now we have to look if the person is a user
                Vector users = User.getUsersByPersonId(FingerPrint.getFingerPrint().bestmatch());
                if (users.size()==1){
                    User user = (User)users.elementAt(0);
                    %>
                        <script type="text/javascript">
                            window.opener.location.href='<%=request.getParameter("referringServer")%>/checkLogin.jsp?ts=<%=ScreenHelper.getTs()%>&login=<%=user.userid%>&auto=true&password=<%=User.hashPassword(user.password)%>';
                            window.close();
                        </script>
                    <%
                }
                else{
                    if (users.size()==0){
                        out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>No matching fingerprint found");
                        out.print("<script>window.setTimeout('window.close()',3000);</script>");
                    }
                    else {
                        out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>More than one matching fingerprint found, please contact the system administrator");
                        out.print("<script>window.setTimeout('window.close()',3000);</script>");
                    }
                }
            }
            else {
                out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>More than one matching fingerprint found, please contact the system administrator");
                out.print("<script>window.setTimeout('window.close()',10000);</script>");
            }
        } else {
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>No matching fingerprint found");
            out.print("<script>window.setTimeout('window.close()',3000);</script>");
        }
        FingerPrint.close();
    } else if (request.getParameter("start") != null) {
        Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
        if(langHashtable == null || langHashtable.size()==0){
            reloadSingleton(session);
        }
        out.flush();
        out.print("<img src='" + request.getParameter("referringServer") + "/_img/animatedclock.gif'/>Waiting for fingerprint...</br>");
        out.flush();
        byte[] templatedata = FingerPrint.getFingerPrint().getFingerPrint(15000);
        if (templatedata != null) {
            String template = encode(templatedata);
            %>
            <form name="frmFingerPrint" method="post" action="<%=request.getParameter("referringServer")%>/_common/readUserFingerPrint.jsp">
                <input type="hidden" name="template" value="<%=template%>"/>
                <input type="hidden" name="referringServer" value="<%=request.getParameter("referringServer")%>"/>
            </form>
            <script type="text/javascript">frmFingerPrint.submit();</script>
            <%
        }
        else {
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>Timeout reading fingerprint");
            out.print("<script>window.setTimeout('window.close()',15000);</script>");
        }
        FingerPrint.close();
    } else {
        out.print("<img src='" + request.getParameter("referringServer") + "/_img/animatedclock.gif'/>Waiting for fingerprint...</br>");
        //Lanceer de jsp-pagina op de locale server
        %>
        <form name="frmFingerPrint" method="post" action="http://localhost/openclinic/_common/readUserFingerPrint.jsp">
            <input type="hidden" name="start" value="<%=ScreenHelper.getTs()%>"/>
            <input type="hidden" name="referringServer" value="<%=request.getParameter("referringServer")%>"/>
        </form>
        <%
        out.println("<script>window.setTimeout('frmFingerPrint.submit()',500);</script>");
    }
%>
</body>