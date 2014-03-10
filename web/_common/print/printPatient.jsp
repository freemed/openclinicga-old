<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sImmatNew = "", sGender = "", sLastname = "", sFirstname = "",
           sDateOfBirth = "", sNatReg = "", sActiveDivision = "";

    if (activePatient!=null) {
        sLastname = checkString(activePatient.lastname);
        sFirstname = checkString(activePatient.firstname);
        sDateOfBirth = checkString(activePatient.dateOfBirth);
        sNatReg = checkString(activePatient.getID("natreg"));

        sImmatNew = checkString(activePatient.getID("immatnew"));
        if ((sImmatNew.length()==9)&&(sImmatNew.startsWith("44"))) {
            sImmatNew = "44."+sImmatNew.substring(2,7)+"."+sImmatNew.substring(7);
        }

        if(activePatient.gender.equals("M")) {
            sGender = "<img src='"+sCONTEXTPATH+"/_img/mal.gif' width='9' height='10' border='0'>";
        }
        else if(activePatient.gender.equals("F")) {
            sGender = "<img src='"+sCONTEXTPATH+"/_img/fem.gif' width='9' height='10' border='0'>";
        }

        // patient's active division
        Service activeDivision = activePatient.getActiveDivision();
        if(activeDivision!=null) sActiveDivision = activeDivision.getLabel(sWebLanguage);
    }
%>

<html>
    <head>
        <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
        <%=sCSSNORMAL%>
        <%=sJSPOPUPMENU%>
        <%=sJSCHAR%>
        <%=sJSDATE%>
    <head>
    <body>
        <script>function noError(){return true;} window.onerror = noError;</script>

        <%
            // display patient info if any
            if((sLastname+" "+sFirstname).length() > 1){
                %>
                    <table class="list" width="100%">
                        <tr>
                            <td width="250" nowrap><b><%=(sLastname+" "+sFirstname)%></b></td>
                            <td width="100"><%=(sDateOfBirth+" "+sGender)%></td>
                            <td width="100"><b><%=sImmatNew%></b> <%=sNatReg%></td>
                            <td width="*"><%=sActiveDivision%></td>
                        </tr>
                    </table>

                    <br><br>
                <%
            }
        %>

        <table width="100%" cellspacing="0" cellpadding="0">
            <tr>
                <td class="white">
                    <script>
                     window.resizeTo(900,600);
                        if(navigator.appName == "Netscape"){
                            document.write(window.opener.parent.document.getElementById("<%=request.getParameter("Field")%>").innerHTML);
                        }else{
                            document.write(window.opener.<%=request.getParameter("Field")%>.innerHTML);
                        }
                        window.print();
                    </script>
                </td>
            </tr>
        </table>
    </body>
</html>
<script>
        var sfSelect = document.getElementsByTagName("SELECT");
        for (var i=0; i<sfSelect.length; i++){
            sfSelect[i].style.visibility = "visible";
        }
</script>
