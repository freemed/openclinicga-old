<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.riskprofile","select",activeUser)%>
<bean:define id="riskProfileb" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO"/>

<table width='100%' align='center' class="menu" cellspacing="0">
    <%-- RISKPROFILE HEADER ----------------------------------------------------------------------%>
    <tr class="admin">
        <td width="50%">
            <%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile",sWebLanguage)%>
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;<mxs:propertyAccessorI18N name="riskProfileb" scope="page" property="dateBegin" formatType="date" format="dd-mm-yyyy"/>
        </td>
        <td align="right" style="vertical-align:top;">
            <%
                if(activeUser.getAccessRight("occup.riskprofile.add") || activeUser.getAccessRight("occup.riskprofile.edit")){
                    %>
                        <a href="<c:url value='/healthrecord/manageRiskProfileContext.do'/>?ts=<%=getTs()%>&webLanguage=<%=sWebLanguage%>" class="underlined" title="<%=getTran("Web.Occup","medwan.common.update",sWebLanguage)%>"><%=getTran("Web.Occup","medwan.common.update",sWebLanguage)%></a>
                    <%
                }
            %>
            <a href='#' class="previousButton" onClick="doBack();"><img src='<c:url value="/_img/arrow.jpg"/>' style="vertical-align:middle" border="0"></a>
        </td>
    </tr>
    <%-- workplace & categories & groups --%>
    <tr>
        <td colspan="2">
            <table class="menu" width="100%" cellspacing="0">
                <%-- HEADER --%>
                <tr class="label2">
                    <td width="33%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.workplace",sWebLanguage)%></td>
                    <td width="33%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.funtion-categories",sWebLanguage)%></td>
                    <td width="*"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.funtion-groups",sWebLanguage)%></td>
                </tr>

                <tr>
                    <%-- CELL 1 --%>
                    <td style="vertical-align:top;" height="100%">
                        <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO">
                            <table class="list" width="100%" height="100%">
                                <%-- Workplaces --%>
                                <logic:iterate id="riskProfileWorkplaces" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO.riskProfileWorkplaces">
                                    <tr>
                                        <td style="vertical-align:top;">
                                            &nbsp;<mxs:propertyAccessorI18N name="riskProfileWorkplaces" scope="page" property="messageKeyExtended" translate="false"/>
                                        </td>
                                    </tr>
                                </logic:iterate>

                                <tr><td height="99%"></td></tr>
                            </table>
                        </logic:present>
                    </td>

                    <%-- CELL 2 --%>
                    <td style="vertical-align:top;" height="100%">
                        <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO">
                            <table class="list" width="100%" height="100%">
                                <%-- FunctionCategories --%>
                                <logic:iterate id="riskProfileFunctionCategories" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO.riskProfileFunctionCategories">
                                    <tr>
                                        <td style="vertical-align:top;">
                                            &nbsp;<mxs:propertyAccessorI18N name="riskProfileFunctionCategories" scope="page" property="messageKeyExtended" translate="false"/>
                                        </td>
                                    </tr>
                                </logic:iterate>

                                <tr><td height="99%"></td></tr>
                            </table>
                        </logic:present>
                    </td>

                    <%-- CELL 3 --%>
                    <td style="vertical-align:top;" height="100%">
                        <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO">
                            <table class="list" width="100%" height="100%">
                                <%-- FunctionGroups --%>
                                <logic:iterate id="riskProfileFunctionGroups" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO.riskProfileFunctionGroups">
                                    <tr>
                                        <td style="vertical-align:top;">
                                            &nbsp;<mxs:propertyAccessorI18N name="riskProfileFunctionGroups" scope="page" property="messageKey" translate="false"/>
                                        </td>
                                    </tr>
                                </logic:iterate>

                                <tr><td height="99%"></td></tr>
                            </table>
                        </logic:present>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <%-- EMPLOYEE RISK LIST HEADER ---------------------------------------------------------------%>
    <tr class="admin">
        <td width="30%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.risk-list-for-the-employee",sWebLanguage)%></td>
        <td align="right" style="vertical-align:top;">
            <%
                if (activeUser.getAccessRight("occup.riskprofile.add") || activeUser.getAccessRight("occup.riskprofile.edit")){
                    %>
                        <a href="<c:url value='/healthrecord/manageRiskProfileRisks.do?ts='/><%=getTs()%>" class="underlined" title="<%=getTran("Web.Occup","medwan.common.update",sWebLanguage)%>"><%=getTran("Web.Occup","medwan.common.update",sWebLanguage)%></a>
                    <%
                }
            %>
            <a href='#' class="previousButton" onClick="doBack();"><img src='<c:url value="/_img/arrow.jpg"/>' style="vertical-align:middle" border="0"></a>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <table class="list" width="100%" cellspacing="0">
                <%-- HEADER --%>
                <tr class="label2">
                    <td width="*"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.name",sWebLanguage)%></td>
                    <td width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.code",sWebLanguage)%></td>
                    <td width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.type",sWebLanguage)%></td>
                    <td width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.status",sWebLanguage)%></td>
                </tr>

                <%-- RISKS --%>
                <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskCodesVO">
                    <logic:iterate id="riskProfileRiskCode" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskCodesVO">
                        <tr>
                            <td style="vertical-align:top;"><mxs:propertyAccessorI18N name="riskProfileRiskCode.riskCodeVO" scope="page" property="label" translate="false"/></td>
                            <td style="vertical-align:top;"><mxs:propertyAccessorI18N name="riskProfileRiskCode.riskProfileRiskCodeVO" scope="page" property="code" translate="false"/></td>
                            <td style="vertical-align:top;"><mxs:propertyAccessorI18N name="riskProfileRiskCode.riskProfileRiskCodeVO" scope="page" property="type"/></td>
                            <td style="vertical-align:top;"><mxs:propertyAccessorI18N name="riskProfileRiskCode.riskProfileRiskCodeVO" scope="page" property="statusMessageKey"/></td>
                        </tr>
                    </logic:iterate>
                </logic:present>
            </table>
        </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <%-- EMPLOYEE EXAMINATION LIST HEADER --------------------------------------------------------%>
    <tr class="admin">
        <td width="30%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.examination-list-for-the-employee",sWebLanguage)%></td>
        <td align="right" style="vertical-align:top;">
            <%
                if (activeUser.getAccessRight("occup.riskprofile.add") || activeUser.getAccessRight("occup.riskprofile.edit")){
                    %>
                        <a href="<c:url value='/healthrecord/manageRiskProfileExaminations.do?ts='/><%=getTs()%>" class="underlined" title="<%=getTran("Web.Occup","medwan.common.update",sWebLanguage)%>"><%=getTran("Web.Occup","medwan.common.update",sWebLanguage)%></a>
                    <%
                }
            %>
            <a href='#' class="previousButton" onClick="doBack();"><img src='<c:url value="/_img/arrow.jpg"/>' style="vertical-align:middle" border="0"></a>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <table class="list" width="100%" cellspacing="0">
                <%-- HEADER --%>
                <tr class="label2">
                    <td width="*"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.name",sWebLanguage)%></td>
                    <td colspan="2" width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.frequency",sWebLanguage)%></td>
                    <td colspan="2" width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.tolerance",sWebLanguage)%></td>
                    <td width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.type",sWebLanguage)%></td>
                    <td width="10%"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.status",sWebLanguage)%></td>
                </tr>
                <%-- SUB HEADER --%>
                <tr>
                    <td>&nbsp;</td>
                    <td class="admin2" style="text-align:center"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.syst",sWebLanguage)%></td>
                    <td class="admin2" style="text-align:center"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.pers",sWebLanguage)%></td>
                    <td class="admin2" style="text-align:center"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.syst",sWebLanguage)%></td>
                    <td class="admin2" style="text-align:center"><%=getTran("Web.Occup","medwan.occupational-medicine.risk-profile.pers",sWebLanguage)%></td>
                </tr>
                <%-- EXAMINATIONS --%>
                <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO">
                    <logic:iterate id="riskProfileExamination" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="riskProfileVO.riskProfileExaminations">
                        <tr>
                            <td><mxs:propertyAccessorI18N name="riskProfileExamination" scope="page" property="label" translate="false"/></td>
                            <td align="middle"><bean:write name="riskProfileExamination" property="defaultFrequency"/></td>
                            <td align="middle"><bean:write name="riskProfileExamination" property="personalFrequency"/></td>
                            <td align="middle"><bean:write name="riskProfileExamination" property="defaultTolerance"/></td>
                            <td align="middle"><bean:write name="riskProfileExamination" property="personalTolerance"/></td>
                            <td><mxs:propertyAccessorI18N name="riskProfileExamination" scope="page" property="type" translate="true"/></td>
                            <td><mxs:propertyAccessorI18N name="riskProfileExamination" scope="page" property="statusMessageKey" translate="true"/></td>
                        </tr>
                    </logic:iterate>
                </logic:present>
            </table>
        </td>
    </tr>
    <%-- SHORTCUTS -------------------------------------------------------------------------------%>
    <tr>
        <td colspan="3">
            <br>
            <img src='<c:url value="/_img/pijl.gif"/>'>
            <a href="<c:url value='/managePeriodicExaminations.do?ts='/><%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.healthrecord.periodic-examinations",sWebLanguage)%></a>
        </td>
    </tr>
    <tr>
        <td colspan="3">
            <img src='<c:url value="/_img/pijl.gif"/>'>
            <a href="<c:url value='/main.jsp'/>?Page=curative/index.jsp&ts=<%=getTs()%>"  onMouseOver="window.status='';return true;"><%=getTran("Web.Occup","medwan.recruitment.view-recruitment-examinations-summary",sWebLanguage)%></a>
        </td>
    </tr>
</table>

<%-- BUTTONS -------------------------------------------------------------------------------------%>
<%=ScreenHelper.alignButtonsStart()%>
   <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  function doBack(){
    window.location.href = '<c:url value='/healthrecord/showWelcomePage.do'/>?Tab=<%=checkString(request.getParameter("Tab"))%>&ts=<%=getTs()%>';
  }
</script>


