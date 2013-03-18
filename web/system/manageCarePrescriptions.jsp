<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%
    String sFindCareUID = checkString(request.getParameter("FindCareUID"));
    String sAction = checkString(request.getParameter("Action"));

    String sEditCareTypeID = "",sEditUnitsPerTimeUnit = "",sEditTimeUnitCount = "",sEditTimeUnit = "",sTime1 = "",sTime2 = "",sTime3 = "",sTime4 = "",
            sTime5 = "",sTime6 = "",sQuantity1 = "",sQuantity2 = "",sQuantity3 = "",sQuantity4 = "",sQuantity5 = "",sQuantity6 = "";

    String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages", "en,fr");
    String[] aLanguages = sSupportedLanguages.split(",");

    if (sAction.equalsIgnoreCase("save")) {
        sEditCareTypeID = checkString(request.getParameter("EditCareTypeID"));
        sEditUnitsPerTimeUnit = checkString(request.getParameter("EditUnitsPerTimeUnit"));
        sEditTimeUnitCount = checkString(request.getParameter("EditTimeUnitCount"));
        sEditTimeUnit = checkString(request.getParameter("EditTimeUnit"));
        sTime1 = checkString(request.getParameter("time1"));
        sTime2 = checkString(request.getParameter("time2"));
        sTime3 = checkString(request.getParameter("time3"));
        sTime4 = checkString(request.getParameter("time4"));
        sTime5 = checkString(request.getParameter("time5"));
        sTime6 = checkString(request.getParameter("time6"));
        sQuantity1 = checkString(request.getParameter("quantity1"));
        sQuantity2 = checkString(request.getParameter("quantity2"));
        sQuantity3 = checkString(request.getParameter("quantity3"));
        sQuantity4 = checkString(request.getParameter("quantity4"));
        sQuantity5 = checkString(request.getParameter("quantity5"));
        sQuantity6 = checkString(request.getParameter("quantity6"));

        Label label;

        for (int i = 0; i < aLanguages.length; i++) {
            Label.delete("care_type", sFindCareUID, aLanguages[i]);

            label = new Label();
            label.type = "care_type";
            label.id = sEditCareTypeID;
            label.language = aLanguages[i];
            label.value = checkString(request.getParameter("EditCareType" + aLanguages[i]));
            label.updateUserId = activeUser.userid;

            if (label.value.length() > 0) {
                label.saveToDB();
            }
        }
        reloadSingleton(session);

        MedwanQuery.getInstance().setConfigString("CareType" + sEditCareTypeID,
            "UnitsPerTimeUnit="+sEditUnitsPerTimeUnit+","
            +"TimeUnitCount="+sEditTimeUnitCount+","
            +"TimeUnit="+sEditTimeUnit+","
            +"t1="+sTime1+","
            +"t2="+sTime2+","
            +"t3="+sTime3+","
            +"t4="+sTime4+","
            +"t5="+sTime5+","
            +"t6="+sTime6+","
            +"q1="+sQuantity1+","
            +"q2="+sQuantity2+","
            +"q3="+sQuantity3+","
            +"q4="+sQuantity4+","
            +"q5="+sQuantity5+","
            +"q6="+sQuantity6
        );

        sFindCareUID = sEditCareTypeID;

    } else if (sAction.equalsIgnoreCase("find")) {
        String sConfig = checkString(MedwanQuery.getInstance().getConfigString("CareType" + sFindCareUID));

        if (sConfig.length() > 0) {
            Hashtable hConfig = new Hashtable();
            String[] aConfig = sConfig.split(",");
            String[] aValue;

            for (int i=0;i<aConfig.length;i++){
                aValue = aConfig[i].split("=");

                if (aValue.length>1){
                    hConfig.put(aValue[0],aValue[1]);
                }
            }

            sEditUnitsPerTimeUnit = checkString((String)hConfig.get("UnitsPerTimeUnit"));
            sEditTimeUnitCount = checkString((String)hConfig.get("TimeUnitCount"));
            sEditTimeUnit = checkString((String)hConfig.get("TimeUnit"));
            sTime1 = checkString((String)hConfig.get("t1"));
            sTime2 = checkString((String)hConfig.get("t2"));
            sTime3 = checkString((String)hConfig.get("t3"));
            sTime4 = checkString((String)hConfig.get("t4"));
            sTime5 = checkString((String)hConfig.get("t5"));
            sTime6 = checkString((String)hConfig.get("t6"));
            sQuantity1 = checkString((String)hConfig.get("q1"));
            sQuantity2 = checkString((String)hConfig.get("q2"));
            sQuantity3 = checkString((String)hConfig.get("q3"));
            sQuantity4 = checkString((String)hConfig.get("q4"));
            sQuantity5 = checkString((String)hConfig.get("q5"));
            sQuantity6 = checkString((String)hConfig.get("q6"));
        }
    }
%>
<form name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.manage","ManageCarePrescriptions",sWebLanguage,"doBack();")%>
    <table class="menu" width="100%">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web","care_type",sWebLanguage)%></td>
            <td>
                <select class="text" name="FindCareUID" onchange="doChange()">
                    <option/>
                    <%=ScreenHelper.writeSelect("care_type",sFindCareUID,sWebLanguage,true,true)%>
                </select>

                <input class="button" type="button" name="buttonNew" value="<%=getTran("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
            </td>
        </tr>
    </table>
    <script>
        function doNew(){
            transactionForm.FindCareUID.selectedIndex = -1;
            transactionForm.Action.value ="new";
            transactionForm.submit();
        }

        function doChange(){
            transactionForm.Action.value ="find";
            transactionForm.submit();
        }

        function doBack(){
          window.location.href = '<c:url value="/main.do"/>?Page=system/menu.jsp&ts=<%=getTs()%>';
        }
        
    </script>
    <br>
    <table width="100%" class="list" cellpadding="0" cellspacing="1">
         <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","care_type",sWebLanguage)%> ID *</td>
            <td class="admin2">
                <input type="text" class="text" name="EditCareTypeID" value="<%=sFindCareUID%>" size="80">
            </td>
        </tr>
        <%
            for (int i=0;i<aLanguages.length;i++){
            %>
        <tr>
           <td class="admin"><%=getTran("web","care_type",sWebLanguage)%> <%=aLanguages[i]%></td>
           <td class="admin2">
                <input type="text" class="text" name="EditCareType<%=aLanguages[i]%>" value="<%=getTranNoLink("care_type",sFindCareUID,aLanguages[i])%>" size="80"><br>
           </td>
       </tr>
            <%
            }
            %>
        <tr>
            <td class="admin"><%=getTran("Web","frequency",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <%-- Units Per Time Unit --%>
                <input type="text" class="text" name="EditUnitsPerTimeUnit" value="<%=sEditUnitsPerTimeUnit%>" size="5" maxLength="5" onKeyUp="isNumber(this);">
                <span id="EditUnitsPerTimeUnitLabel"></span>

                <%-- Time Unit Count --%>
                &nbsp;<%=getTran("web","per",sWebLanguage)%>
                <input type="text" class="text" name="EditTimeUnitCount" value="<%=sEditTimeUnitCount%>" size="5" maxLength="5">

                <%-- Time Unit (dropdown : Hour|Day|Week|Month) --%>
                <select class="text" name="EditTimeUnit">
                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelectUnsorted("prescription.timeunit",sEditTimeUnit,sWebLanguage)%>
                </select>

                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearDescriptionRule();">
            </td>
        </tr>
        <tr>
            <td class="admin" nowrap><%=getTran("Web","schema",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <table>
                    <tr>
                        <td><input class="text" type="text" name="time1" value="<%=sTime1%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                        <td><input class="text" type="text" name="time2" value="<%=sTime2%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                        <td><input class="text" type="text" name="time3" value="<%=sTime3%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                        <td><input class="text" type="text" name="time4" value="<%=sTime4%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                        <td><input class="text" type="text" name="time5" value="<%=sTime5%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                        <td><input class="text" type="text" name="time6" value="<%=sTime6%>" size="2"><%=getTran("web","abbreviation.hour",sWebLanguage)%></td>
                    </tr>
                    <tr>
                        <td><input class="text" type="text" name="quantity1" value="<%=sQuantity1%>" size="2">#</td>
                        <td><input class="text" type="text" name="quantity2" value="<%=sQuantity2%>" size="2">#</td>
                        <td><input class="text" type="text" name="quantity3" value="<%=sQuantity3%>" size="2">#</td>
                        <td><input class="text" type="text" name="quantity4" value="<%=sQuantity4%>" size="2">#</td>
                        <td><input class="text" type="text" name="quantity5" value="<%=sQuantity5%>" size="2">#</td>
                        <td><input class="text" type="text" name="quantity6" value="<%=sQuantity6%>" size="2">#</td>
                        <td/>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="button" name="ButtonSave" id="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                <input class="button" type="button" name="ButtonReturn" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
    <script>
        transactionForm.EditCareTypeID.focus();

        function doSave(){
            if(!transactionForm.EditTimeUnit.value.length==0 &&
               !transactionForm.EditTimeUnitCount.value.length==0 &&
               !transactionForm.EditUnitsPerTimeUnit.value.length==0 &&
               !transactionForm.EditCareTypeID.value.length==0){
                transactionForm.Action.value = "save";
                transactionForm.submit();
            }
            else {
                var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
                var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
            }
        }

        function clearDescriptionRule(){
            transactionForm.EditUnitsPerTimeUnit.value = '';
            transactionForm.EditTimeUnitCount.value = '';
            transactionForm.EditTimeUnit.value = '';
        }
    </script>
</form>
