<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp" %>
<%!public String getRadios(String id, int nb) {
    String sReturn = "<td class='first col1'><input onDblClick='uncheckRadio(this);' type=\"radio\" value='1' name=\"" + nb + "_" + id + "_1\" id=\"" + nb + "_radio_1_1\"/></td>\n" +
            "        <td><input onDblClick='uncheckRadio(this);' type=\"radio\" value='2' name=\"" + nb + "_" + id + "_1\" id=\"" + nb + "_radio_1_2\"/></td>\n" +
            "        <td class='col2'><input onDblClick='uncheckRadio(this);' type=\"radio\" value='3' name=\"" + nb + "_" + id + "_1\" id=\"" + nb + "_radio_1_3\" /></td>\n" +
            "        <td class='first col1'><input onDblClick='uncheckRadio(this);' type=\"radio\" value='1' name=\"" + nb + "_" + id + "_2\" id=\"" + nb + "_radio_2_1\"/></td>\n" +
            "        <td><input onDblClick='uncheckRadio(this);' type=\"radio\" name=\"" + nb + "_" + id + "_2\" value='2' id=\"" + nb + "_radio_2_2\"/></td>\n" +
            "        <td class='col2'><input onDblClick='uncheckRadio(this);' type=\"radio\" value='3' name=\"" + nb + "_" + id + "_2\" id=\"" + nb + "_radio_2_3\"/></td>\n" +
            "        <td class='first col1'><input onDblClick='uncheckRadio(this);' type=\"radio\" value='1' name=\"" + nb + "_" + id + "_3\" id=\"" + nb + "_radio_3_1\"/></td>\n" +
            "        <td><input onDblClick='uncheckRadio(this);' type=\"radio\" name=\"" + nb + "_" + id + "_3\" value='2' id=\"" + nb + "_radio_3_2\"/></td>\n" +
            "        <td class='last col2'><input onDblClick='uncheckRadio(this);' type=\"radio\" value='3' name=\"" + nb + "_" + id + "_3\" id=\"" + nb + "_radio_3_3\"/></td>";
    return sReturn;
}%><%String sAntibiogramuid = checkString(request.getParameter("antibiogramuid"));
    boolean bEditable = checkString(request.getParameter("editable")).equals("true");
    String[] antibiogram = sAntibiogramuid.split("\\.");%>
<table width="580" class="data" cellpadding="0" cellspacing="0" id="antibiogramtable">
    <tr width="100%">
        <td rowspan="4" style="vertical-align:top;" class="top label nobottom"><%=getTran("web","germs",sWebLanguage) %></td>
    </tr>
    <tr>
        <td colspan="9" class='first nobottom last top'>1 -
            <input type="text" class="text" id="germ1" style="width:300px"/>

            <div id="autocomplete_germ1" class="autocomple"></div>
        </td>
    </tr>
    <tr>
        <td colspan="9" class='first nobottom last'>2 - <input type="text" class="text" id="germ2" style="width:300px"/>

            <div id="autocomplete_germ2" class="autocomple"></div>
        </td>
    </tr>
    <tr>
        <td colspan="9" class='first nobottom last'>3 - <input type="text" class="text" id="germ3" style="width:300px"/>

            <div id="autocomplete_germ3" class="autocomple"></div>
        </td>
    </tr>
    <tr style="padding-top:10px">
        <td class="label nobottom">&nbsp;</td>
        <td colspan="3" class="first nobottom"><b><%=getTran("web", "1germe", sWebLanguage)%>
        </b></td>
        <td colspan="3" class="first nobottom"><b><%=getTran("web", "2germe", sWebLanguage)%>
        </b></td>
        <td colspan="3" class='first last nobottom'><b><%=getTran("web", "3germe", sWebLanguage)%>
        </b></td>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("web", "antibiotic", sWebLanguage))%>
        </td>
        <td class='first col1'><i><b>S</b></i></td>
        <td><i><b>I</b></i></td>
        <td class='col2'><i><b>R</b></i></td>
        <td class='first col1'><i><b>S</b></i></td>
        <td><i><b>I</b></i></td>
        <td class='col2'><i><b>R</b></i></td>
        <td class='first col1'><i><b>S</b></i></td>
        <td><i><b>I</b></i></td>
        <td class='last col2'><i><b>R</b></i></td>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "pen", sWebLanguage))%>
        </td>
        <%=getRadios("penicillineg", 1)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "oxa", sWebLanguage))%>
        </td>
        <%=getRadios("oxacilline", 2)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "amp", sWebLanguage))%>
        </td>
        <%=getRadios("ampicilline", 3)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "amc", sWebLanguage))%>
        </td>
        <%=getRadios("amoxicacclavu", 4)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "czo", sWebLanguage))%>
        </td>
        <%=getRadios("cefalotine", 5)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "mec", sWebLanguage))%>
        </td>
        <%=getRadios("mecillinam", 6)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "ctx", sWebLanguage))%>
        </td>
        <%=getRadios("cefotaxime", 7)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "gen", sWebLanguage))%>
        </td>
        <%=getRadios("gentamicine", 8)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "amk", sWebLanguage))%>
        </td>
        <%=getRadios("amikacine", 9)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "chl", sWebLanguage))%>
        </td>
        <%=getRadios("chloramphenicol", 10)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "tcy", sWebLanguage))%>
        </td>
        <%=getRadios("tetracycline", 11)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "col", sWebLanguage))%>
        </td>
        <%=getRadios("colistine", 12)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "ery", sWebLanguage))%>
        </td>
        <%=getRadios("erythromycine", 13)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "lin", sWebLanguage))%>
        </td>
        <%=getRadios("lincomycine", 14)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "pri", sWebLanguage))%>
        </td>
        <%=getRadios("pristinamycine", 15)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "sxt", sWebLanguage))%>
        </td>
        <%=getRadios("cotrimoxazole", 16)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "nit", sWebLanguage))%>
        </td>
        <%=getRadios("nitrofurane", 17)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "nal", sWebLanguage))%>
        </td>
        <%=getRadios("acnalidixique", 18)%>
    </tr>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", "cip", sWebLanguage))%>
        </td>
        <%=getRadios("ciprofloxacine", 19)%>
    </tr>
    <tr>
    	<td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics","ipm",sWebLanguage))%>
    	</td>
         <%=getRadios("imipenem",20)%>
    </tr>
    <%
        // EXTRA AB RESULTS
        String[] extraAb = MedwanQuery.getInstance().getConfigString("extraAntibiotics","").split(";");
        for(int i=0;i<extraAb.length;i++){
            // IF AB HAS A TRADUCTION THEN SHOW IT
            if(getTran("antibiotics",extraAb[i],sWebLanguage).indexOf("<a")<0){
    %>
    <tr>
        <td class="label"><%=HTMLEntities.htmlentities(getTran("antibiotics", extraAb[i], sWebLanguage))%>
        </td>
        <%=getRadios(extraAb[i], 21+i)%>
    </tr>
    <%
            }
        }
    %>
  
    <tr>
        <td>&nbsp;</td>
        <td colspan="9" class="first last ">
            <input class="button" <%=(bEditable)?"":"style='display:none'"%> type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setAntibiogram('<%=sAntibiogramuid%>');"> &nbsp;<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
            <input type="hidden" id="antibiogramuid" value="<%=sAntibiogramuid%>"/>
        </td>
    </tr>
</table>
<script>
    addObserversToAntibiogram('<%=sAntibiogramuid%>');
    new Ajax.Autocompleter("germ1", "autocomplete_germ1", "<c:url value="/labos/ajax/getAutocompleteGerm.jsp" />", {paramName: "value", frequency: 0.1});
    new Ajax.Autocompleter("germ2", "autocomplete_germ2", "<c:url value="/labos/ajax/getAutocompleteGerm.jsp" />", {paramName: "value", frequency: 0.1});
    new Ajax.Autocompleter("germ3", "autocomplete_germ3", "<c:url value="/labos/ajax/getAutocompleteGerm.jsp" />", {paramName: "value", frequency: 0.1});
    changeInputColor();
</script>

