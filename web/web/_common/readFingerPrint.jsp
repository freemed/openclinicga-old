<%@ page import="be.openclinic.id.FingerPrint" %>
<%@ page import="be.mxs.common.util.system.ScreenHelper" %>
<%@ page import="sun.misc.BASE64Decoder" %>
<%@ page import="sun.misc.BASE64Encoder" %>
<%@ page import="be.mxs.common.util.system.Debug" %>
<%@ page import="com.griaule.grfingerjava.Template" %>
<%@ page import="be.mxs.common.util.db.MedwanQuery" %>
<%@ page import="net.admin.User" %>
<%@ page import="java.util.SortedMap" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="net.admin.AdminPerson" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Map" %>
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
        FingerPrint.getFingerPrint().stop();
        FingerPrint.getFingerPrint().setTemplate(new Template());
        FingerPrint.getFingerPrint().getTemplate().setData(decode(request.getParameter("template")));
        if(FingerPrint.getFingerPrint().identify()){
            if(FingerPrint.getFingerPrint().getMatches().size()==1){
                %>
                    <script type="text/javascript">
                        window.opener.location.href='<%=request.getParameter("referringServer")%>/main.do?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID=<%=FingerPrint.getFingerPrint().bestmatch()%>';
                        window.close();
                    </script>
                <%
            } else {
                //Maak lijst van alle overeenstemmende personen
                SortedMap matches = FingerPrint.getFingerPrint().getMatches();
                Iterator iterator = matches.entrySet().iterator();
                String list = "";
                while (iterator.hasNext()) {
                    Map.Entry v = (Map.Entry) iterator.next();
                    int score = ((Integer)v.getKey()).intValue();
                    int personid = ((Integer)v.getValue()).intValue();
                	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    AdminPerson person = AdminPerson.getAdminPerson(ad_conn, personid + "");
                    ad_conn.close();
                    list = "<tr><td><a href='javascript:openRecord(\""+personid+"\")'/>" + person.firstname + " " + person.lastname + "</a></td><td>" + person.dateOfBirth + "</td><td>" + score + "</td></tr>" + list;
                }
                out.println("<table width='100%'>" + list + "</table>");
                %>
                <script type="text/javascript">
                    function openRecord(personid){
                        window.opener.location.href='<%=request.getParameter("referringServer")%>/main.do?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID='+personid;
                        window.close();
                    }
                </script>
                <%
            }
        } else {
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>" + MedwanQuery.getInstance().getLabel("web", "no_match_found", request.getParameter("language")));
            out.print("<script>window.setTimeout('window.close()',3000);</script>");
        }
        FingerPrint.close();
    } else if (request.getParameter("start") != null) {
        Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
        if(langHashtable == null || langHashtable.size()==0){
            reloadSingleton(session);
        }
        out.print("<img src='" + request.getParameter("referringServer") + "/_img/animatedclock.gif'/>" + MedwanQuery.getInstance().getLabel("web", "waiting_for_fingerprint", request.getParameter("language")) + "</br>");
        out.flush();
        byte[] templatedata = FingerPrint.getFingerPrint().getFingerPrint(15000);
        if (templatedata != null) {
            String template = encode(templatedata);
            %>
            <form name="frmFingerPrint" method="post" action="<%=request.getParameter("referringServer")%>/popup.jsp?Page=_common/readFingerPrint.jsp">
                <input type="hidden" name="language" value="<%=request.getParameter("language")%>"/>
                <input type="hidden" name="template" value="<%=template%>"/>
                <input type="hidden" name="referringServer" value="<%=request.getParameter("referringServer")%>"/>
            </form>
            <script type="text/javascript">frmFingerPrint.submit();</script>
            <%
        }
        else {
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>" + MedwanQuery.getInstance().getLabel("web","timeout_reading_fingerprint",request.getParameter("language")));
            out.print("<script>window.setTimeout('window.close()',15000);</script>");
        }
        FingerPrint.close();
    } else {
        out.print("<img src='" + request.getParameter("referringServer") + "/_img/animatedclock.gif'/>"+MedwanQuery.getInstance().getLabel("web","waiting_for_fingerprint",((User)session.getAttribute("activeUser")).person.language)+"</br>");
        //Lanceer de jsp-pagina op de locale server
        %>
        <form name="frmFingerPrint" method="post" action="http://localhost/openclinic/_common/readFingerPrint.jsp">
            <input type="hidden" name="language" value="<%=((User)session.getAttribute("activeUser")).person.language%>"/>
            <input type="hidden" name="start" value="<%=ScreenHelper.getTs()%>"/>
            <input type="hidden" name="referringServer" value="<%=request.getParameter("referringServer")%>"/>
        </form>
        <%
        out.println("<script>window.setTimeout('frmFingerPrint.submit()',500);</script>");
    }
%>
</body>