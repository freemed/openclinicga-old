<%@page import="be.openclinic.system.Macro,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<html>
<head>
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <%=sCSSNORMAL%>
</head>

<body class="hand">
    <table class="list" width="100%" cellspacing="1" cellpadding="1">
        <%
            String sCategory = checkString(request.getParameter("category"));
            String sId = checkString(request.getParameter("id"));

            Vector vMacros;
            vMacros = Macro.selectMacrosByCatagoryAndId(sCategory, sId);
            Macro objMacro;

            Iterator iter = vMacros.iterator();
            String sLabel = "";
            while(iter.hasNext()){
                objMacro = (Macro)iter.next();
                if(sWebLanguage.equalsIgnoreCase("n")){
                    sLabel = objMacro.getNl();
                }
                else{
                    sLabel = objMacro.getFr();
                }

                %><tr class="list" onclick="selectMacro('<%=sLabel%>');"><td><%=sLabel%></td></tr><%
            }

            // no records found
            if(sLabel.length()==0){
                %><tr><td><%=getTran("web","norecordsfound",sWebLanguage)%></td></tr><%
            }
        %>
    </table>
    
    <script>
      window.resizeTo(450,220);

      <%-- SELECT MACRO --%>
      function selectMacro(sLabel){
        window.opener.document.getElementsByName('<%=request.getParameter("target")%>')[0].value = sLabel;
        window.close();
      }
    </script>
</body>
</html>