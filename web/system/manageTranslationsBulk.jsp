<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.managetranslations","all",activeUser)%>

<form name="EditForm" method="post" action="<c:url value='/main.do'/>?Page=system/manageTranslationsBulk.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web","ManageTranslationsBulk",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table width='100%' cellspacing="1" class="list" onkeydown='if(enterEvent(event,13)){doFind();}'>    
<%
    String sFindSourceLanguage = checkString(request.getParameter("FindSourceLanguage")).toLowerCase();
    String sFindDestinationLanguage = checkString(request.getParameter("FindDestinationLanguage")).toLowerCase();
    String sFindOnlyEmptyValues = checkString(request.getParameter("FindOnlyEmptyValues"));

    String sActionField = checkString(request.getParameter("ActionField"));
    String sFindNextValue = checkString(request.getParameter("FindNextValue"));
    final int iRANGE = 100;
    int iFrom = 0;
    int iUntil = iRANGE;
    //save

    if (sActionField.equals("Save")) {
        Enumeration e = request.getParameterNames();
        String sKey, sValue, sType, sId;
        Label label;

        while (e.hasMoreElements()) {
            sKey = (String) e.nextElement();

            if (sKey.startsWith("Edit")) {
                sValue = checkString(request.getParameter(sKey));

                if (sValue.length() > 0) {
                    sKey = sKey.substring(4);
                    sType = sKey.substring(0, sKey.indexOf(";"));
                    sId = sKey.substring(sKey.indexOf(";") + 1);

                    // create label object
                    label = new Label();
                    label.type = sType;
                    label.id = sId;
                    label.value = sValue;
                    label.language = sFindDestinationLanguage;
                    label.updateUserId = activeUser.userid;

                    label.saveToDB();
                }
            }
        }

        reloadSingleton(session);

        sActionField = "Next";
        int iTmp = Integer.parseInt(sFindNextValue);
        iTmp = iTmp - iRANGE;
        sFindNextValue = iTmp + "";
    }

    String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
    String[] aLanguages = sSupportedLanguages.split(",");
%>
     <tr>
        <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("web.translations.bulk","sourcelanguage",sWebLanguage)%></td>
        <td class="admin2">
            <select name="FindSourceLanguage" class="text">
                <%
                    String sSelected;

                    for (int i=0;i<aLanguages.length;i++){
                        if (aLanguages[i].equalsIgnoreCase(sFindSourceLanguage)){
                            sSelected = " selected";
                        }
                        else {
                            sSelected = "";
                        }
                        out.print("<option value='"+aLanguages[i]+"'"+sSelected+">"+aLanguages[i]+"</option>");
                    }
                %>
            </select>
        </td>
    </tr>
    <tr>
        <td class="admin2"><%=getTran("web.translations.bulk","destinationlanguage",sWebLanguage)%></td>
         <td class="admin2">
            <select name="FindDestinationLanguage" class="text">
                <%
                    for (int i=0;i<aLanguages.length;i++){
                        if (aLanguages[i].equalsIgnoreCase(sFindDestinationLanguage)){
                            sSelected = " selected";
                        }
                        else {
                            sSelected = "";
                        }
                        out.print("<option value='"+aLanguages[i]+"'"+sSelected+">"+aLanguages[i]+"</option>");
                    }
                %>
            </select>
        </td>
    </tr>
    <tr>
        <td class="admin2"><%=getTran("web.translations.bulk","show_only_empty_values",sWebLanguage)%></td>
        <td class="admin2">
            <input type="checkbox" name="FindOnlyEmptyValues" value="ok"<%if(sFindOnlyEmptyValues.equals("ok")){out.print(" checked");}%>>
        </td>
    </tr>
    <tr>
        <td class="admin2"/>
        <td class="admin2">
            <input type="button" class="button" name="ButtonSearch" value="<%=getTran("web","find",sWebLanguage)%>" onclick="doFind()"/>
            <input type="button" class="button" name="ButtonBack" value="<%=getTran("web","back",sWebLanguage)%>" onclick="doBack()"/>
        </td>
    </tr>
</table>
<br/>
    <%
    //resultscreen
    if ((sFindSourceLanguage.length() > 0) && (sFindDestinationLanguage.length() > 0)) {
        if (sActionField.equals("Next")){
            iFrom = Integer.parseInt(sFindNextValue);
            iUntil = iFrom +iRANGE;
        }

        if (sActionField.equals("Previous")){
            iUntil = Integer.parseInt(sFindNextValue) -iRANGE;
            iFrom = iUntil -iRANGE;
        }

        if (iFrom>0){
        %>
        <img class="link" src="<c:url value='/_img/arrow.jpg'/>" onclick="showResult('Previous')" alt="<%=getTran("web","previous",sWebLanguage)%>">
        <%
            }
            out.print("<table cellspacing='1' cellpadding='0' width='100%' class='list'>"
                    + "<tr class='admin'>"
                    + "<td>Key</td>"
                    + "<td width='50%'>" + getTran("web.translations.bulk", "sourcelanguage", sWebLanguage) + ": " + sFindSourceLanguage + "</td>"
                    + "<td>" + getTran("web.translations.bulk", "destinationlanguage", sWebLanguage) + ": " + sFindDestinationLanguage + "</td>"
                    + "</tr>"
            );
            Hashtable hLabels = MedwanQuery.getInstance().getLabels();

            Hashtable hSorted = new Hashtable();
            Hashtable hTypes, hIDs;
            String sKey, sType, sID, sLabel;
            Enumeration eTypes, eIDs;
            int iIndex = 0;
            Label label;

            hTypes = (Hashtable) hLabels.get(sFindSourceLanguage.toLowerCase());

            if (hTypes != null) {
                eTypes = hTypes.keys();

                while (eTypes.hasMoreElements()) {
                    sType = (String) eTypes.nextElement();
                    hIDs = (Hashtable) hTypes.get(sType);

                    if (hIDs != null) {
                        eIDs = hIDs.keys();

                        while (eIDs.hasMoreElements()) {
                            sID = (String) eIDs.nextElement();
                            label = (Label) hIDs.get(sID);

                            sKey = sType + ";" + sID;
                            sLabel = getTranNoLink(label.type, label.id, sFindDestinationLanguage);

                            if (sLabel.equals(label.id)) {
                                sLabel = "";
                            }else if(sLabel.toLowerCase().startsWith("<a href") && sLabel.indexOf("manageTranslations") > -1){
                                sLabel = "";
                            }

                            if ((sFindOnlyEmptyValues.length() == 0) || ((sFindOnlyEmptyValues.length() > 0) && (sLabel.length() == 0))) {
                                hSorted.put(sKey, "<tr class='list' ><td>" + sKey + "</td><td>" + getTran(label.type, label.id, label.language) + "</td>"
                                        + "<td><textarea class='normal' rows=\"2\" cols=\"80\" name='Edit" + sKey + "'>" + sLabel + "</textarea></td></tr>");
                            }
                        }
                    }
                }
            }

            Vector vSorted = new Vector(hSorted.keySet());
            Collections.sort(vSorted);
            Iterator it = vSorted.iterator();

            for (int i = 0; it.hasNext() && i < iFrom; i++) {
                it.next();
            }

            while ((it.hasNext()) && (iIndex < iRANGE)) {
                sKey = (String) it.next();
                out.print((String) hSorted.get(sKey));
                iIndex++;
            }

            out.print("</table>");

            if (iIndex == iRANGE) {
        %>
        <img class="link" src="<c:url value='/_img/next.jpg'/>" onclick="showResult('Next')" alt="<%=getTran("web","next",sWebLanguage)%>">
        <%
        }
        %>
        <input type="hidden" name="ActionField"/>
        <input type="hidden" name="FindNextValue" value="<%=iUntil%>"/>

        <input type="button" class="button" name="ButtonSave" value="<%=getTran("web","save",sWebLanguage)%>" onclick="doSave()"/>
        <%
    }
%>
</form>
<script>
    function doFind(){
         if (EditForm.FindSourceLanguage.selectedIndex!= EditForm.FindDestinationLanguage.selectedIndex){
            document.getElementsByName('ButtonSearch')[0].disabled = true;
            EditForm.submit();
        }
    }

    function doSave(){
        document.getElementsByName('ButtonSave')[0].disabled = true;
        EditForm.ActionField.value = "Save";
        EditForm.submit();
    }

    function showResult(sAction){
        EditForm.ActionField.value = sAction;
        EditForm.submit();
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=system/menu.jsp";
    }
</script>