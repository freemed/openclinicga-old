<%@ page import="be.openclinic.id.FingerPrint,
be.mxs.common.util.system.ScreenHelper,
sun.misc.BASE64Decoder,sun.misc.BASE64Encoder,
com.griaule.grfingerjava.Template,be.mxs.common.util.db.MedwanQuery,java.awt.*,
javax.imageio.ImageIO,java.awt.image.BufferedImage,java.io.File" %>
<%@include file="/includes/SingletonContainer.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
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
%>
<head>
    <link href='<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/_common/_css/web.css' rel='stylesheet' type='text/css'>
    <link href='<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/"<%=checkString((String) session.getAttribute("activeProjectDir"))%>"/_common/_css/web.css' rel='stylesheet' type='text/css'>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <META HTTP-EQUIV="Expires" CONTENT="-1"/>
</head>
<%
    if (request.getParameter("template") != null) {
        //todo: store template in central database
        FingerPrint.close();
        FingerPrint.getFingerPrint().setTemplate(new Template());
        FingerPrint.getFingerPrint().getTemplate().setData(decode(request.getParameter("template")));
        FingerPrint.getFingerPrint().setPersonid(Integer.parseInt(activePatient.personid));
        FingerPrint.getFingerPrint().setFinger(request.getParameter("rightleft")+request.getParameter("finger"));
        if (FingerPrint.getFingerPrint().enroll()) {
            FingerPrint.close();
            //We gaan de ingelezen vingerafdruk ook tonen
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/checkmark.jpg'/>" + getTran("web","enrollment_succeeded",request.getParameter("language"))+"</br>");
            out.print("<img src='http://localhost/openclinic/documents/" + activeUser.userid+".fingerprint.jpg'/>");
            out.print("<script>window.setTimeout('window.close()',5000);</script>");
        } else {
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>" + getTran("web","enrollment_failed",request.getParameter("language")));
            out.print("<script>window.setTimeout('window.close()',15000);</script>");
        }
    } else if (request.getParameter("start") != null) {
        Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
        if(langHashtable == null || langHashtable.size()==0){
            reloadSingleton(session);
        }
        out.print("<img src='" + request.getParameter("referringServer") + "/_img/animatedclock.gif'/>" + getTran("web", "waiting_for_fingerprint", request.getParameter("language")) + "</br>");
        out.flush();
        byte[] templatedata = FingerPrint.getFingerPrint().getFingerPrint(15000);
        if (templatedata != null) {
            Image fingerprintImage = FingerPrint.getFingerPrint().getBiometricimage();
            int w=fingerprintImage.getWidth(null);
            int h=fingerprintImage.getHeight(null);
            BufferedImage bi = new BufferedImage(w,h,BufferedImage.TYPE_INT_RGB);
            Graphics2D g2 =bi.createGraphics();
            g2.drawImage(fingerprintImage,0,0,null);
            g2.dispose();
            String filename=MedwanQuery.getInstance().getConfigString("imageDirectory","c:/temp")+"/"+request.getParameter("userid")+".fingerprint.jpg";
            try{
                ImageIO.write(bi, "jpg", new File(filename));
            }
            catch(Exception e){
                e.printStackTrace();
            }
            String template = encode(templatedata);
%>
            <form name="frmFingerPrint" method="post" action="<%=request.getParameter("referringServer")%>/popup.jsp?Page=_common/enrollFingerPrint.jsp">
                <input type="hidden" name="language" value="<%=request.getParameter("language")%>"/>
                <input type="hidden" name="template" value="<%=template%>"/>
                <input type="hidden" name="referringServer" value="<%=request.getParameter("referringServer")%>"/>
                <input type="hidden" name="rightleft" value="<%=request.getParameter("rightleft")%>"/>
                <input type="hidden" name="finger" value="<%=request.getParameter("finger")%>"/>
            </form>
            <script type="text/javascript">frmFingerPrint.submit();</script>
            <%
        }
        else {
            out.print("<img src='" + request.getParameter("referringServer") + "/_img/error.jpg'/>" + getTran("web","timeout_reading_fingerprint",request.getParameter("language")));
            out.print("<script>window.setTimeout('window.close()',15000);</script>");
        }
        FingerPrint.close();
    } else {
        //Lanceer de jsp-pagina op de locale server
        %>
        <form name="frmFingerPrint" method="post" action="http://localhost/openclinic/_common/enrollFingerPrint.jsp">
            <input type="hidden" name="language" value="<%=sWebLanguage%>"/>
            <input type="hidden" name="start" value="<%=ScreenHelper.getTs()%>"/>
            <input type="hidden" name="userid" value="<%=activeUser.userid%>"/>
            <input type="hidden" name="referringServer" value="<%=request.getParameter("referringServer")%>"/>

            <%=writeTableHeader("web","enrollFingerPrint",sWebLanguage,"")%>
            <table width="100%" class="list">
                <tr>
                    <td>
                        <input type="radio" name="rightleft" value="R" checked/><%=getTran("web","right",sWebLanguage)%>
                        <input type="radio" name="rightleft" value="L"/><%=getTran("web","left",sWebLanguage)%>
                    </td>
                    <td>
                        <select name="finger" class="text">
                            <option value="0"><%=getTran("web","thumb",sWebLanguage)%></option>
                            <option selected value="1"><%=getTran("web","index",sWebLanguage)%></option>
                            <option value="2"><%=getTran("web","middlefinger",sWebLanguage)%></option>
                            <option value="3"><%=getTran("web","ringfinger",sWebLanguage)%></option>
                            <option value="4"><%=getTran("web","littlefinger",sWebLanguage)%></option>
                        </select>
                    </td>
                </tr>
            </table>
            <br>
            <center>
                <input type="submit" class="button" name="buttonSubmit" value="<%=getTran("web","read",sWebLanguage)%>"/>
                <input type="button" class="button" name="buttonClose" value="<%=getTran("web","close",sWebLanguage)%>" onclick="doClose()"/>
            </center>
        </form>
        <script>
            function doClose(){
                window.close();
            }
        </script>
        <%
    }
%>