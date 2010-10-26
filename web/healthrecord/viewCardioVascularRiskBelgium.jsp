<%@page import="java.util.Iterator,
                org.dom4j.Element,
                be.mxs.common.util.cardio.CardiovascularRiskBelgium"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%%>

<%!
     boolean smoker;
%>

<html>
<head>
    <title>SCORE</title>
    <%=sCSSNORMAL%>

    <%-- meadco script --%>
    <object id="factory" style="display:none" viewastext
      classid="clsid:1663ed61-23eb-11d2-b92f-008048fdd814"
      codebase="<c:url value="/util/cab/"/>smsx.cab#Version=6,5,439,30">
    </object>

    <script defer>
      function window.onload(){
        factory.printing.header = "";
        factory.printing.footer = "";
        factory.printing.portrait = true;
        factory.printing.leftMargin = 10.0;
        factory.printing.topMargin = 10.0;
        factory.printing.rightMargin = 10.0;
        factory.printing.bottomMargin = 10.0;
      }
    </script>
</head>

<body style="padding:2px;">
<form name="cardioRiskForm">
    <%
        String sAction = checkString(request.getParameter("Action"));

        //--- DISPLAY GRAPHS ----------------------------------------------------------------------
        if(sAction.length()==0){
            %>
                <table width="100%" style="border:1px solid #ccc;" cellpadding="1" cellspacing="1">
                    <%-- PAGE TITLE --%>
                    <tr class="admin" height="22">
                        <td colspan="4">&nbsp;<%=getTran("web.occup","RiskOfCoronaryHeartDisease",sWebLanguage)%></td>
                    </tr>

                    <%-- PATIENT NAME & INFO --%>
                    <%
                        String sPatientInfo = activePatient.gender+", "+activePatient.dateOfBirth;

                        if(activePatient.getID("immatnew")!=null) sPatientInfo+= ", "+activePatient.getID("immatnew");

                    %>
                    <tr>
                        <td class="admin"><%=activePatient.firstname+" "+activePatient.lastname%></td>
                        <td class="admin" colspan="3"><%=sPatientInfo%></td>
                    </tr>

                    <tr>
                        <td>
                            <%
                                if(false){
                                }
                                else{
                                    %>
                                        <%-- TODO : here starts row 1 --%>
                                        <table width="220" cellspacing="1" cellpadding="0">
                                            <tr>
                                                <td align="center" class="admin2"><center>SYST mmHg</center></td>
                                                <td colspan="5"/>
                                            </tr>

                                            <%
                                                // todo: indien diagnose aanwezig: geen schema tonen
                                                smoker = checkString(request.getParameter("smoker")).equalsIgnoreCase("yes");
                                                boolean isChol = false, isSyst = false;
                                                double chol = 180;
                                                double syst = 120;

                                                int age = 60;
                                                if(request.getParameter("age")!=null && checkString(request.getParameter("age")).length()>0){
                                                    age = Integer.parseInt(request.getParameter("age"));
                                                }

                                                if(request.getParameter("chol")!=null && checkString(request.getParameter("chol")).length()>0){
                                                    chol = Double.parseDouble(request.getParameter("chol"));
                                                    isChol = true;
                                                }

                                                if(request.getParameter("syst")!=null && checkString(request.getParameter("syst")).length()>0){
                                                    syst = Double.parseDouble(request.getParameter("syst"));
                                                    isSyst = true;
                                                }

                                                String sTableContent = "";
                                                CardiovascularRiskBelgium risk = new CardiovascularRiskBelgium(activePatient.gender,age,smoker,syst,chol);
                                                Iterator levels = risk.getRiskClass().elementIterator("risk");
                                                String sTableRow;
                                                Element level;
                                                int counter = 0, position = 0;

                                                while(levels.hasNext()){
                                                    sTableRow = "<tr>";
                                                    counter++;

                                                    for(int n=0; n<5; n++){
                                                        if(n==0){
                                                            sTableRow+= "<td align='center' class='admin2'>";

                                                                 if(counter==1) sTableRow+= "&lt;130";
                                                            else if(counter==2) sTableRow+= "&ge;130";
                                                            else if(counter==3) sTableRow+= "&ge;150";
                                                            else if(counter==4) sTableRow+= "&ge;170";

                                                            sTableRow+= "</td>";
                                                        }
                                                        else{
                                                            position++;
                                                            sTableRow+= "<td width='30' align='center' bgcolor='";
                                                            level = (Element)levels.next();

                                                            if(Integer.parseInt(level.attributeValue("value"))<2){
                                                                sTableRow+= "lightgreen";
                                                            }
                                                            else if(Integer.parseInt(level.attributeValue("value"))<5){
                                                                sTableRow+= "yellow";
                                                            }
                                                            else if(Integer.parseInt(level.attributeValue("value"))<10){
                                                                sTableRow+= "orange";
                                                            }
                                                            else{
                                                                sTableRow+= "red";
                                                            }

                                                            if(position==risk.getRiskPosition()){
                                                                sTableRow+= "' ><b>&bull;"+level.attributeValue("value")+"</b></td>";
                                                                //sTableRow+="'><img src='../_img/check.gif'/></td>";
                                                            }
                                                            else{
                                                                sTableRow+= "'>"+level.attributeValue("value")+"</td>";
                                                            }
                                                        }
                                                    }

                                                    sTableRow+= "</tr>";
                                                    sTableContent = sTableRow+sTableContent;
                                                }

                                                sTableContent+= "<tr>"+
                                                                " <td/>"+
                                                                " <td align='center' class='admin2'>&lt;175</td>"+
                                                                " <td align='center' class='admin2'>&ge;175</td>"+
                                                                " <td align='center' class='admin2'>&ge;225</td>"+
                                                                " <td align='center' class='admin2'>&ge;275</td>"+
                                                                "</tr>"+
                                                                "<tr>"+
                                                                " <td/>"+
                                                                " <td colspan='4' align='center' class='admin2'><center>CHOLESTEROL mg/dl</center></td>"+
                                                                "</tr>";

                                                out.print(sTableContent);
                                            %>
                                        </table>
                                    </td>

                                    <td>
                                        <table width="150" cellspacing="1" cellpadding="0">
                                            <%
                                                int risklevel = risk.getRiskLevel();

                                                if(risklevel>=10){
                                                    out.print("<tr><td align='center' width='30' bgcolor='red'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&ge;10%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='red'>&nbsp;</td><td>&ge;10%</td></tr>");
                                                }

                                                if(risklevel<10 && risklevel>=5){
                                                    out.print("<tr><td align='center' width='30' bgcolor='orange'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>5-9%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='orange'>&nbsp;</td><td>5-9%</td></tr>");
                                                }

                                                if(risklevel<5 && risklevel>=2){
                                                    out.print("<tr><td align='center' width='30' bgcolor='yellow'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>2-4%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='yellow'>&nbsp;</td><td>2-4%</td></tr>");
                                                }

                                                if(risklevel<2){
                                                    out.print("<tr><td align='center' width='30' bgcolor='lightgreen'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&lt;2%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='lightgreen'>&nbsp;</td><td>&lt;2%</td></tr>");
                                                }
                                            %>
                                        </table>
                                    </td>

                                    <%
                                        // Indien de patient roker is, hiernaast de tabel voor een niet-roker weergeven
                                        if(smoker){
                                            %>
                                                <td>
                                                    <table width="220" cellspacing="1" cellpadding="0">
                                                        <tr>
                                                            <td align="center" class="admin2"><center>SYST mmHg</center></td>
                                                            <td colspan="5"><b><%=getTran("web.occup","healthrecord.ce.not_smoker",sWebLanguage)%></b></td>
                                                        </tr>

                                                        <%
                                                            sTableContent = "";
                                                            risk = new CardiovascularRiskBelgium(activePatient.gender,age,false,syst,chol);
                                                            levels = risk.getRiskClass().elementIterator("risk");
                                                            counter = 0;
                                                            position = 0;

                                                            while(levels.hasNext()){
                                                                sTableRow = "<tr>";
                                                                counter++;

                                                                for(int n=0; n<5; n++){
                                                                    if(n==0){
                                                                        sTableRow+= "<td align='center' class='admin2'>";
                                                                        if(counter==1){
                                                                            sTableRow+="&lt;130";
                                                                        }
                                                                        else if(counter==2){
                                                                            sTableRow+="&ge;130";
                                                                        }
                                                                        else if(counter==3){
                                                                            sTableRow+="&ge;150";
                                                                        }
                                                                        else if(counter==4){
                                                                            sTableRow+="&ge;170";
                                                                        }
                                                                        sTableRow+="</td>";
                                                                    }
                                                                    else{
                                                                        position++;
                                                                        sTableRow+= "<td width='30' align='center' bgcolor='";
                                                                        level = (Element)levels.next();
                                                                        if(Integer.parseInt(level.attributeValue("value"))<2){
                                                                            sTableRow+= "lightgreen";
                                                                        }
                                                                        else if(Integer.parseInt(level.attributeValue("value"))<5){
                                                                            sTableRow+= "yellow";
                                                                        }
                                                                        else if(Integer.parseInt(level.attributeValue("value"))<10){
                                                                            sTableRow+= "orange";
                                                                        }
                                                                        else{
                                                                            sTableRow+= "red";
                                                                        }
                                                                        if(position==risk.getRiskPosition()){
                                                                            sTableRow+= "' ><b>&bull;"+level.attributeValue("value")+"</b></td>";
                                                                        }
                                                                        else{
                                                                            sTableRow+= "'>"+level.attributeValue("value")+"</td>";
                                                                        }
                                                                    }
                                                                }

                                                                sTableRow+= "</tr>";
                                                                sTableContent = sTableRow+sTableContent;
                                                            }

                                                            sTableContent+= "<tr>"+
                                                                            " <td/>"+
                                                                            " <td align='center' class='admin2'>&lt;175</td>"+
                                                                            " <td align='center' class='admin2'>&ge;175</td>"+
                                                                            " <td align='center' class='admin2'>&ge;225</td>"+
                                                                            " <td align='center' class='admin2'>&ge;275</td>"+
                                                                            "</tr>"+
                                                                            "<tr>"+
                                                                            " <td/>"+
                                                                            " <td colspan='4' align='center' class='admin2'><center>CHOLESTEROL mg/dl</center></td>"+
                                                                            "</tr>";

                                                            out.print(sTableContent);
                                                        %>
                                                    </table>
                                                </td>

                                                <td>
                                                    <table width="150" cellspacing="1" cellpadding="0">
                                                        <%
                                                            risklevel = risk.getRiskLevel();

                                                            if(risklevel>=10){
                                                                out.print("<tr><td align='center' width='30' bgcolor='red'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&ge;10%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='red'>&nbsp;</td><td>&ge;10%</td></tr>");
                                                            }

                                                            if(risklevel<10 && risklevel>=5){
                                                                out.print("<tr><td align='center' width='30' bgcolor='orange'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>5-9%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='orange'>&nbsp;</td><td>5-9%</td></tr>");
                                                            }

                                                            if(risklevel<5 && risklevel>=2){
                                                                out.print("<tr><td align='center' width='30' bgcolor='yellow'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>2-4%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='yellow'>&nbsp;</td><td>2-4%</td></tr>");
                                                            }

                                                            if(risklevel<2){
                                                                out.print("<tr><td align='center' width='30' bgcolor='lightgreen'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&lt;2%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='lightgreen'>&nbsp;</td><td>&lt;2%</td></tr>");
                                                            }
                                                        %>
                                                    </table>
                                                </td>
                                            <%
                                        }
                                    %>
                                </tr>

                                <%-- AGE ROW 1 --%>
                                <tr>
                                    <td class="admin"><%=getTran("web.occup","medwan.recruitment.sce.age",sWebLanguage)%></td>
                                    <td class="admin" colspan="3"><%=age%> <%=getTran("web","years",sWebLanguage)%></td>
                                </tr>

                                <%-- TODO : here starts row 2 --%>
                                <tr>
                                    <td>
                                        <table width="220" cellspacing="1" cellpadding="0">
                                            <tr>
                                                <td align="center" class="admin2"><center>SYST mmHg</center></td><td colspan="5"/>
                                            </tr>

                                            <%
                                                age = MedwanQuery.getInstance().getAge(Integer.parseInt(activePatient.personid));
                                                if(request.getParameter("chol")!=null && checkString(request.getParameter("chol")).length()>0){
                                                    chol = Double.parseDouble(request.getParameter("chol"));
                                                    isChol = true;
                                                }

                                                if(request.getParameter("syst")!=null && checkString(request.getParameter("syst")).length()>0){
                                                    syst = Double.parseDouble(request.getParameter("syst"));
                                                    isSyst = true;
                                                }

                                                sTableContent = "";
                                                CardiovascularRiskBelgium risk2 = new CardiovascularRiskBelgium(activePatient.gender,age,smoker,syst,chol);
                                                levels = risk2.getRiskClass().elementIterator("risk");
                                                counter = 0;
                                                position = 0;

                                                while(levels.hasNext()){
                                                    sTableRow = "<tr>";
                                                    counter++;

                                                    for(int n=0; n<5; n++){
                                                        if(n==0){
                                                            sTableRow+="<td align='center' class='admin2'>";

                                                                 if(counter==1) sTableRow+= "&lt;130";
                                                            else if(counter==2) sTableRow+= "&ge;130";
                                                            else if(counter==3) sTableRow+= "&ge;150";
                                                            else if(counter==4) sTableRow+= "&ge;170";

                                                            sTableRow+="</td>";
                                                        }
                                                        else{
                                                            position++;
                                                            sTableRow+= "<td width='30' align='center' bgcolor='";
                                                            level = (Element)levels.next();

                                                            if(Integer.parseInt(level.attributeValue("value"))<2){
                                                                sTableRow+= "lightgreen";
                                                            }
                                                            else if(Integer.parseInt(level.attributeValue("value"))<5){
                                                                sTableRow+= "yellow";
                                                            }
                                                            else if(Integer.parseInt(level.attributeValue("value"))<10){
                                                                sTableRow+= "orange";
                                                            }
                                                            else{
                                                                sTableRow+= "red";
                                                            }

                                                            if(position==risk.getRiskPosition()){
                                                                sTableRow+= "' ><b>&bull;"+level.attributeValue("value")+"</b></td>";
                                                            }
                                                            else{
                                                                sTableRow+= "'>"+level.attributeValue("value")+"</td>";
                                                            }
                                                        }
                                                    }

                                                    sTableRow+= "</tr>";
                                                    sTableContent = sTableRow+sTableContent;
                                                }

                                                sTableContent+= "<tr>"+
                                                                "  <td/>"+
                                                                "  <td align='center' class='admin2'>&lt;175</td>"+
                                                                "  <td align='center' class='admin2'>&ge;175</td>"+
                                                                "  <td align='center' class='admin2'>&ge;225</td>"+
                                                                "  <td align='center' class='admin2'>&ge;275</td>"+
                                                                "</tr>"+
                                                                "<tr>"+
                                                                "  <td/>"+
                                                                "  <td colspan='4' align='center' class='admin2'><center>CHOLESTEROL mg/dl</center></td>"+
                                                                "</tr>";

                                                out.print(sTableContent);
                                            %>
                                        </table>
                                    </td>

                                    <td>
                                        <table width="150" cellspacing="1" cellpadding="0">
                                            <%
                                                risklevel = risk2.getRiskLevel();
                                                if(risklevel>=10){
                                                    out.print("<tr><td align='center' width='30' bgcolor='red'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&ge;10%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='red'>&nbsp;</td><td>&ge;10%</td></tr>");
                                                }

                                                if(risklevel<10 && risklevel>=5){
                                                    out.print("<tr><td align='center' width='30' bgcolor='orange'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>5-9%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='orange'>&nbsp;</td><td>5-9%</td></tr>");
                                                }

                                                if(risklevel<5 && risklevel>=2){
                                                    out.print("<tr><td align='center' width='30' bgcolor='yellow'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>2-4%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='yellow'>&nbsp;</td><td>2-4%</td></tr>");
                                                }

                                                if(risklevel<2){
                                                    out.print("<tr><td align='center' width='30' bgcolor='lightgreen'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&lt;2%</td></tr>");
                                                }
                                                else{
                                                    out.print("<tr><td width='30' bgcolor='lightgreen'>&nbsp;</td><td>&lt;2%</td></tr>");
                                                }
                                            %>
                                        </table>
                                    </td>

                                    <%
                                        if(smoker){
                                            %>
                                                <td>
                                                    <table width="220" cellspacing="1" cellpadding="0">
                                                        <tr>
                                                            <td align="center" class="admin2"><center>SYST mmHg</center></td>
                                                            <td colspan="5"><b><%=getTran("web.occup","healthrecord.ce.not_smoker",sWebLanguage)%></b></td>
                                                        </tr>

                                                        <%
                                                            sTableContent = "";
                                                            risk2 = new CardiovascularRiskBelgium(activePatient.gender,age,false,syst,chol);
                                                            levels = risk2.getRiskClass().elementIterator("risk");
                                                            counter = 0;
                                                            position = 0;

                                                            while(levels.hasNext()){
                                                                sTableRow = "<tr>";
                                                                counter++;

                                                                for(int n=0; n<5; n++){
                                                                    if(n==0){
                                                                        sTableRow+= "<td align='center' class='admin2'>";

                                                                             if(counter==1) sTableRow+= "&lt;130";
                                                                        else if(counter==2) sTableRow+= "&ge;130";
                                                                        else if(counter==3) sTableRow+= "&ge;150";
                                                                        else if(counter==4) sTableRow+= "&ge;170";

                                                                        sTableRow+= "</td>";
                                                                    }
                                                                    else{
                                                                        position++;
                                                                        sTableRow+= "<td width='30' align='center' bgcolor='";
                                                                        level = (Element)levels.next();

                                                                        if(Integer.parseInt(level.attributeValue("value"))<2){
                                                                            sTableRow+="lightgreen";
                                                                        }
                                                                        else if(Integer.parseInt(level.attributeValue("value"))<5){
                                                                            sTableRow+="yellow";
                                                                        }
                                                                        else if(Integer.parseInt(level.attributeValue("value"))<10){
                                                                            sTableRow+="orange";
                                                                        }
                                                                        else{
                                                                            sTableRow+="red";
                                                                        }

                                                                        if(position==risk.getRiskPosition()){
                                                                            sTableRow+="' ><b>&bull;"+level.attributeValue("value")+"</b></td>";
                                                                        }
                                                                        else{
                                                                            sTableRow+="'>"+level.attributeValue("value")+"</td>";
                                                                        }
                                                                    }
                                                                }

                                                                sTableRow+="</tr>";
                                                                sTableContent=sTableRow+sTableContent;
                                                            }

                                                            sTableContent+= "<tr>"+
                                                                            "  <td/>"+
                                                                            "  <td align='center' class='admin2'>&lt;175</td>"+
                                                                            "  <td align='center' class='admin2'>&ge;175</td>"+
                                                                            "  <td align='center' class='admin2'>&ge;225</td>"+
                                                                            "  <td align='center' class='admin2'>&ge;275</td>"+
                                                                            "</tr>"+
                                                                            "<tr>"+
                                                                            "  <td/>"+
                                                                            "  <td colspan='4' align='center' class='admin2'><center>CHOLESTEROL mg/dl</center></td>"+
                                                                            "</tr>";

                                                            out.print(sTableContent);
                                                        %>
                                                    </table>
                                                </td>

                                                <td>
                                                    <table width="150" cellspacing="1" cellpadding="0">
                                                        <%
                                                            risklevel = risk2.getRiskLevel();
                                                            if(risklevel>=10){
                                                                out.print("<tr><td align='center' width='30' bgcolor='red'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&ge;10%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='red'>&nbsp;</td><td>&ge;10%</td></tr>");
                                                            }

                                                            if(risklevel<10 && risklevel>=5){
                                                                out.print("<tr><td align='center' width='30' bgcolor='orange'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>5-9%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='orange'>&nbsp;</td><td>5-9%</td></tr>");
                                                            }

                                                            if(risklevel<5 && risklevel>=2){
                                                                out.print("<tr><td align='center' width='30' bgcolor='yellow'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>2-4%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='yellow'>&nbsp;</td><td>2-4%</td></tr>");
                                                            }

                                                            if(risklevel<2){
                                                                out.print("<tr><td align='center' width='30' bgcolor='lightgreen'><img src='"+sCONTEXTPATH+"/_img/check.gif'/></td><td>&lt;2%</td></tr>");
                                                            }
                                                            else{
                                                                out.print("<tr><td width='30' bgcolor='lightgreen'>&nbsp;</td><td>&lt;2%</td></tr>");
                                                            }
                                                        %>
                                                    </table>
                                                </td>
                                            <%
                                        }
                                    %>
                                </tr>

                                <%-- AGE ROW 2 --%>
                                <tr>
                                    <td class="admin"><%=getTran("web.occup","medwan.recruitment.sce.age",sWebLanguage)%></td>
                                    <td class="admin" colspan="3"><%=age%> <%=getTran("web","years",sWebLanguage)%></td>
                                </tr>

                                <%-- TODO : here ends row 2 --%>

                                <%-- PATIENT DATA --%>
                                <tr>
                                    <td class="admin"><%=getTran("web.occup","medwan.common.gender",sWebLanguage)%></td>
                                    <td class="admin" colspan="3"><%=getTran("web.occup",(activePatient.gender.equalsIgnoreCase("M")?"male":"female"),sWebLanguage)%></td>
                                </tr>

                                <tr>
                                    <td class="admin"><%=getTran("web.occup","healthrecord.ce.smoker",sWebLanguage)%></td>
                                    <td class="admin" colspan="3"><%=smoker?getTran("web.occup","medwan.common.true",sWebLanguage):getTran("web.occup","medwan.common.false",sWebLanguage)%></td>
                                </tr>

                                <tr>
                                    <td class="admin"><%=getTran("web.occup","be.mxs.common.model.vo.healthrecord.iconstants.item_type_recruitment_sce_sbp",sWebLanguage)%></td>
                                    <td class="admin" colspan="3"><%=(isSyst?syst+"":"?")%> mmHg</td>
                                </tr>

                                <tr>
                                    <td class="admin"><%=getTran("web.occup","medwan.healthrecord.laboratory-examinations.blood.totale-cholesterol",sWebLanguage)%></td>
                                    <td class="admin" colspan="3"><%=(isChol?chol+"":"?")%> mg/dl</td>
                                </tr>

                                <%-- INSTRUCTIONS --%>
                                <tr id="instructionsRow">
                                    <td class="admin2" colspan="4">
                                        <a href="javascript:recalculate('30');">30</a>
                                        <a href="javascript:recalculate('40');">40</a>
                                        <a href="javascript:recalculate('50');">50</a>
                                        <a href="javascript:recalculate('60');">60</a>
                                        <a href="javascript:recalculate('70');">70</a>
                                        <a href="#" onclick="doPrint();">Print</a>
                                    </td>
                                </tr>
                            </table>

                            <br>

                            <%-- WARNING (&& COMMENT) --%>
                            <div style="padding:3px;width:100%;border:1px solid #ccc;">
                                <table cellpadding="0" cellspacing="0" width="100%">
                                    <tr height="20">
                                        <td class="admin">
                                            <%=getTran("web.occup","medwan.cardiorisk.warning1",sWebLanguage)%>
                                        </td>
                                    </tr>

                                    <tr height="20">
                                        <td class="admin">
                                            <%=getTran("web.occup","medwan.cardiorisk.warning3",sWebLanguage)%><br>
                                            <%=getTran("web.occup","medwan.cardiorisk.warning4",sWebLanguage)%><br>
                                            <%=getTran("web.occup","medwan.cardiorisk.warning5",sWebLanguage)%><br>
                                            <%=getTran("web.occup","medwan.cardiorisk.warning6",sWebLanguage)%>
                                        </td>
                                    </tr>

                                    <tr height="20">
                                        <td class="admin">
                                            <%=getTran("web.occup","medwan.cardiorisk.ref",sWebLanguage)%>
                                        </td>
                                    </tr>

                                    <%
                                        String sComment = checkString(request.getParameter("comment"));

                                        if(sComment.length() > 0){
                                            %>
                                                <tr><td class="admin"><hr></td></tr>
                                                <tr><td class="admin" style="padding-bottom:5px;"><%=sComment%></td></tr>
                                            <%
                                        }
                                    %>
                                </table>
                            </div>

                            <%-- hidden fields --%>
                            <input type="hidden" name="comment" value="<%=checkString(request.getParameter("comment"))%>"/>
                            <input type="hidden" name="age" value="<%=age%>"/>
                            <input type="hidden" name="chol" value="<%=chol%>"/>
                            <input type="hidden" name="syst" value="<%=syst%>"/>
                            <input type="hidden" name="smoker" value="<%=checkString(request.getParameter("smoker"))%>"/>

                            <script>
                              window.resizeTo(<%=((smoker || sAction.length()>0)?"750":"410")%>,670);

                              function doShow(){
                                cardioRiskForm.submit();
                              }

                              function recalculate(age){
                                document.all["age"].value = age;
                                cardioRiskForm.submit();
                              }

                              function doPrint(){
                                document.getElementById("instructionsRow").style.display = "none";
                                factory.printing.Print(true);
                                document.getElementById("instructionsRow").style.display = "block";
                              }
                            </script>
                        <%
            }
        }
        //--- SHOW CARDIO WARNING -----------------------------------------------------------------
        else if(sAction.equals("ShowCardio")){
            %>
                <%-- hidden fields --%>
                <input type="hidden" name="comment" value="<%=checkString(request.getParameter("comment"))%>"/>
                <input type="hidden" name="age" value="<%=checkString(request.getParameter("age"))%>"/>
                <input type="hidden" name="chol" value="<%=checkString(request.getParameter("chol"))%>"/>
                <input type="hidden" name="syst" value="<%=checkString(request.getParameter("syst"))%>"/>
                <input type="hidden" name="smoker" value="<%=checkString(request.getParameter("smoker"))%>"/>

                <%-- cardio warning --%>
                <table width="100%" class="menu" cellspacing="0">
                    <tr>
                        <td style="padding:6px;">
                            <%=getTran("web.occup","medwan.cardiorisk.pathology1",sWebLanguage)%>
                            <%=getTran("web.occup","medwan.cardiorisk.pathology2",sWebLanguage)%>
                        </td>
                    </tr>
                </table>

                <%-- BUTTONS --%>
                <p align="center">
                    <input type="button" name="ButtonShow" class="button" value=" OK " onclick="doShow();">&nbsp;
                    <input type="button" name="ButtonCancel" class="button" value="<%=getTranNoLink("web","cancel",sWebLanguage)%>" onclick="window.close();">
                </p>

                <script>
                  window.resizeTo(410,240);

                  function doShow(){
                    cardioRiskForm.submit();
                  }
                </script>
            <%
        }
    %>
</form>
</body>
</html>