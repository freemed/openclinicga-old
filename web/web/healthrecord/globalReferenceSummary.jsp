<%@ page import="be.openclinic.adt.Reference, java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("reference","select",activeUser)%>
<%
    String sFindBegin = checkString(request.getParameter("FindBegin"));
    String sFindEnd = checkString(request.getParameter("FindEnd"));
    String sFindServiceID = "";
    Service service = activeUser.activeService;
    if (service!=null){
        sFindServiceID = service.code;
    }

    if ((sFindBegin.length()==0)&&(sFindEnd.length()==0)){
        sFindBegin = ScreenHelper.getDateAdd(getDate(),"-7");
        sFindEnd = getDate();
    }
%>
<form name="transactionForm" method="post">
    <%=writeTableHeader("Web","internal_references_summary",sWebLanguage," doBack();")%>
    <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){transactionForm.submit();}">
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        <%=ScreenHelper.setSearchFormButtonsStart()%>
            <input type="button" class="button" name="ButtonFind" value="<%=getTran("Web","Find",sWebLanguage)%>" onclick="transactionForm.submit()">&nbsp;
            <input type="button" class="button" name="ButtonClear" value="<%=getTran("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
            <input type="button" class="button" name="ButtonNew" value="<%=getTran("Web","New",sWebLanguage)%>" onclick="doNew()">&nbsp;
            <input class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack()">
        <%=ScreenHelper.setSearchFormButtonsStop()%>
    </table>
    <script>
        try{transactionForm.FindBegin.focus();
        }catch(e){}

        function clearFields(){
            transactionForm.FindBegin.value="";
            transactionForm.FindEnd.value="";
            transactionForm.FindBegin.focus();
        }

        function doNew(){
            window.location.href = "<c:url value='/main.do'/>?Page=healthrecord/referenceEdit.jsp&ts="+new Date().getTime();
        }

        function doBack(){
            window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts='+new Date().getTime();
        }
    </script>
</form>
<%
    if ((sFindServiceID.length()>0)&&((sFindBegin.length()>0)||(sFindEnd.length()>0))){
%>
    <table class="list" width="100%" cellspacing="1">
        <tr class="admin">
            <td colspan="7"><%=getTran("openclinic.chuk","reference.opinion.asked",sWebLanguage)%></td>
        </tr>
        <tr class="gray">
            <td width="45"/>
            <td width="200"><%=getTran("openclinic.chuk","reference.patient.name",sWebLanguage)%></td>
            <td width="100"><%=getTran("openclinic.chuk","reference.request.date",sWebLanguage)%></td>
            <td><%=getTran("openclinic.chuk","reference.request.service",sWebLanguage)%></td>
            <td width="200"><%=getTran("openclinic.chuk","reference.status",sWebLanguage)%></td>
            <td width="100"><%=getTran("openclinic.chuk","reference.execution.date",sWebLanguage)%></td>
            <td width="200"><%=getTran("openclinic.chuk","reference.createdby",sWebLanguage)%></td>
        </tr>
        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%
            Vector vReferences = Reference.searchByRequestServiceUID(sFindBegin,sFindEnd,sFindServiceID);
            String sClass = "", sPatientID, sPatientName, sServiceUID, sServiceName, sCreatedByUID, sCreatedByName;

            int iCounter = 0;

            Iterator iter = vReferences.iterator();
            Reference reference;
            while (iter.hasNext()) {
                iCounter++;

                reference = (Reference) iter.next();
                sPatientID = reference.getPatientUID();
               	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();

                if (sPatientID.length()>0){
                    sPatientName = ScreenHelper.getFullPersonName(sPatientID,ad_conn);
                }
                else {
                    sPatientName = "";
                }

                sServiceUID = checkString(reference.getCreationServiceUID());

                if (sServiceUID.length()>0){
                    sServiceName = getTran("service",sServiceUID,sWebLanguage);
                }
                else {
                    sServiceName = "";
                }

                sCreatedByUID = checkString(reference.getCreationUserUID());

                if (sCreatedByUID.length()>0){
                    sCreatedByName = ScreenHelper.getFullUserName(sCreatedByUID,ad_conn);
                }
                else {
                    sCreatedByName = "";
                }
				ad_conn.close();
                if (sClass.equals("")) {
                    sClass = "1";
                } else {
                    sClass = "";
                }
        %>
                <tr class='list<%=sClass%>' onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';">
                    <td>
                        <img src="<c:url value='/_img/icon_edit.gif'/>" alt="<%=getTran("web","edit",sWebLanguage)%>" onclick="doOpen('<%=reference.getUid()+"','"+sPatientID%>')"/>
                    </td>
                    <td><%=sPatientName%></td><td><%=ScreenHelper.getSQLDate(reference.getRequestDate())%></td><td><%=sServiceName%></td>
                    <td><%=checkString(reference.getStatus())%></td><td><%=ScreenHelper.getSQLDate(reference.getExecutionDate())%></td><td><%=sCreatedByName%></td>
                </tr>
        <%
        }
        %>
        </tbody>
    </table>
    <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iCounter%>
    <br/><br/>
    <table class="list" width="100%" cellspacing="1">
        <tr class="admin">
            <td colspan="7"><%=getTran("openclinic.chuk","reference.opinion.given",sWebLanguage)%></td>
        </tr>
        <tr class="gray">
            <td width="45"/>
            <td width="200"><%=getTran("openclinic.chuk","reference.patient.name",sWebLanguage)%></td>
            <td width="100"><%=getTran("openclinic.chuk","reference.request.date",sWebLanguage)%></td>
            <td><%=getTran("openclinic.chuk","reference.claimant.service",sWebLanguage)%></td>
            <td width="200"><%=getTran("openclinic.chuk","reference.status",sWebLanguage)%></td>
            <td width="100"><%=getTran("openclinic.chuk","reference.execution.date",sWebLanguage)%></td>
            <td width="200"><%=getTran("openclinic.chuk","reference.createdby",sWebLanguage)%></td>
        </tr>
        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%
            iCounter = 0;
            sClass = "";
            vReferences = Reference.searchByCreateServiceUID(sFindBegin,sFindEnd,sFindServiceID);

            iter = vReferences.iterator();
            while (iter.hasNext()) {
                iCounter++;

                reference = (Reference) iter.next();
                sPatientID = reference.getPatientUID();

               	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                if (sPatientID.length()>0){
                    sPatientName = ScreenHelper.getFullPersonName(sPatientID,ad_conn);
                }
                else {
                    sPatientName = "";
                }

                sServiceUID = checkString(reference.getRequestServiceUID());

                if (sServiceUID.length()>0){
                    sServiceName = getTran("service",sServiceUID,sWebLanguage);
                }
                else {
                    sServiceName = "";
                }

                sCreatedByUID = checkString(reference.getCreationUserUID());

                if (sCreatedByUID.length()>0){
                    sCreatedByName = ScreenHelper.getFullUserName(sCreatedByUID,ad_conn);
                }
                else {
                    sCreatedByName = "";
                }
				ad_conn.close();
                if (sClass.equals("")) {
                    sClass = "1";
                } else {
                    sClass = "";
                }
        %>
                <tr class='list<%=sClass%>' onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';">
                     <td>
                        <img src="<c:url value='/_img/icon_edit.gif'/>" alt="<%=getTran("web","edit",sWebLanguage)%>" onclick="doOpen('<%=reference.getUid()+"','"+sPatientID%>')"/>
                        <img src="<c:url value='/_img/icon_agenda.gif'/>" alt="<%=getTran("web","planning",sWebLanguage)%>" onclick="doAgenda('<%=ScreenHelper.getSQLDate(reference.getRequestDate())+"','"+sPatientID%>')"/>
                    </td>
                    <td><%=sPatientName%></td><td><%=ScreenHelper.getSQLDate(reference.getRequestDate())%></td><td><%=sServiceName%></td>
                    <td><%=checkString(reference.getStatus())%></td><td><%=ScreenHelper.getSQLDate(reference.getExecutionDate())%></td><td><%=sCreatedByName%></td>
                </tr>
        <%
        }
        %>
        </tbody>
    </table>
    <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iCounter%>
    <script>
        function doOpen(sUID, sPatientUID){
            window.location.href= "<c:url value='/main.do'/>?Page=healthrecord/referenceEdit.jsp&EditUID="+sUID+"&PersonID="+sPatientUID+"&ts="+new Date().getTime();
        }

        function doAgenda(sDate, sPatientUID){
            window.location.href= "<c:url value='/main.do'/>?Page=planning/editPlanning.jsp&FindDate="+sDate+"&FindPatientID="+sPatientUID+"&ts="+new Date().getTime();
        }
    </script>
<%
    }
%>
