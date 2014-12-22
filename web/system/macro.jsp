<%@ page import="be.openclinic.system.Macro,java.util.Vector,java.util.Hashtable" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sOldID    = checkString(request.getParameter("EditOldID"));
    String sNewID    = checkString(request.getParameter("EditNewID"));
    String sCategory = checkString(request.getParameter("EditCategory"));
    String sNL       = checkString(request.getParameter("EditNL"));
    String sFR       = checkString(request.getParameter("EditFR"));

    String sSelectedCategory = checkString(request.getParameter("SelectCategory"));


    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        // NEW
        if (sOldID.length()==0) {

            Macro objMacro = new Macro();
            objMacro.setId(sNewID);
            objMacro.setCategory(sCategory);
            objMacro.setNl(sNL);
            objMacro.setFr(sFR);

            Macro.addMacro(objMacro);
        }
        // UPDATE
        else {
            Macro objMacro = new Macro();
            objMacro.setId(sNewID);
            objMacro.setCategory(sCategory);
            objMacro.setNl(sNL);
            objMacro.setFr(sFR);

            Macro.saveMacro(objMacro,sOldID);
        }

        sAction = "showDetails";
        sSelectedCategory = sCategory;
        sCategory = "";
        sNL = "";
        sFR = "";
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){
        if(sOldID.length() > 0){
            Macro.deleteMacro(sOldID);
         }
    }
%>
<form name="MacroForm" id="MacroForm" method="post">
    <input type="hidden" name="Action">
    <%
        if(sAction.equals("search")){
            %><input type="hidden" name="EditNewID"><%
        }
    %>
    <%=writeTableHeader("Web.manage","macro",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table border="0" width="100%" align="center" cellspacing="0" class="menu">
        <%-- CATEGORY SELECTOR --%>
        <tr>
            <td>&nbsp;<%=getTran("web","category",sWebLanguage)%></td>
            <td>
                <select name="SelectCategory" class="text" onChange="doSearch();">
                    <option/>
                    <%
                        Vector vMacros = Macro.getDistinctCategoryFromMacros();
                        String sTmpCategory;

                        Iterator iter = vMacros.iterator();

                        while (iter.hasNext()) {
                            sTmpCategory = (String) iter.next();

                            if (sTmpCategory.equals(sSelectedCategory)) {
                                %><option value="<%=sTmpCategory%>" selected><%=getTranNoLink("web.macro",sTmpCategory,sWebLanguage)%></option><%
                            }
                            else {
                                %><option value="<%=sTmpCategory%>"><%=getTranNoLink("web.macro",sTmpCategory,sWebLanguage)%></option><%
                            }
                        }
                    %>
                </select>&nbsp;
                <%-- BUTTONS --%>
                <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
            </td>
        </tr>
    </table>
    <br>
    <%
        if(sAction.equals("search")){
            //*** LIST ALL FOUND MACROS ***
            %>
                <table width="100%" align="center" cellspacing="0" class="sortable" id="searchresults">
                    <%-- HEADER --%>
                    <tr class="admin">
                        <td width="25" nowrap>&nbsp;</td>
                        <td width="25%"><%=getTran("web","id",sWebLanguage)%></td>
                        <td width="73%"><%=getTran("web","name",sWebLanguage)%></td>
                    </tr>
                        
                    <tbody class="hand">
                    <%
                        String tranCol;
                        if (sWebLanguage.equalsIgnoreCase("N")) tranCol = "nl";
                        else tranCol = "fr";

                        Vector vMacro = Macro.getId_NameFromMacros(tranCol, sSelectedCategory);
                        Iterator iter2 = vMacro.iterator();
                        Hashtable hInfo;

                        String sClass = "";
                        int foundRecs = 0;

                        while (iter2.hasNext()) {
                            hInfo = (Hashtable) iter2.next();
                            foundRecs++;

                            if (sClass.equals("")) sClass = "1";
                            else sClass = "";

                            %>
                                <tr class="list<%=sClass%>" >
                                    <td>
                                        <a href="javascript:doDelete();"><img src='<c:url value="/_img/icons/icon_delete.gif"/>' border='0' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>'></a>
                                    </td>
                                    <td onClick="showDetails('<%=checkString((String)hInfo.get("id"))%>');"><%=checkString((String)hInfo.get("id"))%></td>
                                    <td onClick="showDetails('<%=checkString((String)hInfo.get("id"))%>');"><%=checkString((String)hInfo.get("name"))%></td>
                                </tr>
                            <%
                        }
                    %>
                    </tbody>
                    <%
                        // no records found
                        if(foundRecs==0){
                            %>
                           <tr>
                               <td colspan="2"><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                           </tr>
                            <%
                        }
                    %>
                </table>
            <%
        }
        else if(sAction.equals("showDetails") || sAction.equals("showNew")){
            //*** DISPLAY DETAILS OF ONE (new) MACRO ***
            if(sAction.equals("showDetails")){
                Macro singleObj;
                singleObj = Macro.getMacro(sNewID);
                if(singleObj!= null){
                    sCategory = singleObj.getCategory();
                    sNL       = singleObj.getNl();
                    sFR       = singleObj.getFr();
                }
            }

            if(sAction.equals("showNew")){
                sNewID = "";
                sCategory = "";
                sNL = "";
                sFR = "";
            }
            %>
                <table width="100%" class="list" cellspacing="1">
                    <%-- NAME/ID --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>">Macro</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditNewID" value="<%=sNewID%>" size="80">
                        </td>
                    </tr>
                    <%-- CATEGORY --%>
                    <tr>
                        <td class="admin"><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_CANDIDATE_CATEGORY",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditCategory" value="<%=sCategory%>" size="80">
                        </td>
                    </tr>
                    <%-- NL --%>
                    <tr>
                        <td class="admin">NL</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditNL" value="<%=sNL%>" size="80">
                        </td>
                    </tr>
                    <%-- FR --%>
                    <tr>
                        <td class="admin">FR</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditFR" value="<%=sFR%>" size="80">
                        </td>
                    </tr>
                </table>
                <script>
                  MacroForm.EditNewID.focus();
                  MacroForm.EditCategory.value = MacroForm.SelectCategory.value;
                </script>
            <%
        }
    %>
    <%-- BUTTONS ---------------------------------------------------------------------------------%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%
            // SAVE & DELETE BUTTON
            if(sAction.equals("showDetails")){
                %>
                <input class="button" type="button" name="saveButton" id="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();"/>
                <input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete();"/>
                <%
            }
            // ONLY SAVE BUTTON
            else if(sAction.equals("showNew")){
                %>
                <input class="button" type="button" name="saveButton" id="saveButton" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="doSave();"/>
                <%
            }
        %>
        <input class="button" type="button" name="backButton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' OnClick="doBack();"/>
    <%=ScreenHelper.alignButtonsStop()%>
    <input type="hidden" name="EditOldID" value="<%=sNewID%>">
</form>
<script>
  function doSave(){
    if(MacroForm.EditNewID.value.length > 0 && MacroForm.EditCategory.value.length > 0 &&
      MacroForm.EditNL.value.length > 0 && MacroForm.EditFR.value.length > 0){
      MacroForm.saveButton.disabled = true;
      MacroForm.Action.value = 'save';
      MacroForm.submit();
    }
    else{
           if(MacroForm.EditNewID.value.length == 0) { MacroForm.EditNewID.focus(); }
      else if(MacroForm.EditCategory.value.length == 0) { MacroForm.EditCategory.focus(); }
      else if(MacroForm.EditNL.value.length == 0) { MacroForm.EditNL.focus(); }
      else if(MacroForm.EditFR.value.length == 0) { MacroForm.EditFR.focus(); }

      alertDialog("web","somefieldsareempty");

    }
  }

  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=system/menu.jsp";
  }

  function doSearch(){
    MacroForm.newButton.disabled = true;
    MacroForm.Action.value = 'search';
    MacroForm.submit();
  }

  function doDelete(){
      if(yesnoDeleteDialog()){
      MacroForm.deleteButton.disabled = true;
      MacroForm.Action.value = 'delete';
      MacroForm.submit();
    }
  }

  function doNew(){
    //MacroForm.SelectCategory.selectedIndex = 0;
    MacroForm.newButton.disabled = true;
    MacroForm.Action.value = 'showNew';
    MacroForm.submit();
  }

  function showDetails(macroID){
    MacroForm.Action.value = 'showDetails';
    MacroForm.EditNewID.value = macroID;
    MacroForm.submit();
  }
</script>
<%=writeJSButtons("MacroForm","saveButton")%>