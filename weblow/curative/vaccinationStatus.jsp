<%@page import="be.mxs.common.model.vo.healthrecord.VaccinationInfoVO" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<% Debug.println("vaccin start"); %>
<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin">
        <td colspan="3"><%=getTran("curative","vaccination.status.title",sWebLanguage)%>
            &nbsp;<a href="<c:url value='/healthrecord/showVaccinationSummary.do'/>?ts=<%=getTs()%>"><img src="<c:url value='/_img/icon_edit.gif'/>" class="link" alt="<%=getTran("web","editVaccinations",sWebLanguage)%>" style="vertical-align:-4px;"></a>
        </td>
    </tr>

    <%
        try{
        if (activePatient != null) {
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
            sessionContainerWO.init(activePatient.personid);
            if(sessionContainerWO.getPersonVO()!=null){
                Iterator vaccinations = MedwanQuery.getInstance().getPersonalVaccinationsInfo(sessionContainerWO.getPersonVO(), sWebLanguage).getVaccinationsInfoVO().iterator();
                VaccinationInfoVO vaccinationsInfoVO;
                String nextDate;
                boolean bWarning;
                String sClass="";

                while (vaccinations.hasNext()) {
                    vaccinationsInfoVO = (VaccinationInfoVO) vaccinations.next();
                    Debug.println(vaccinationsInfoVO.getType());
                    nextDate = checkString(vaccinationsInfoVO.getTransactionVO().getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE").getValue());
                    if (sClass.equals("")){
                        sClass = "1";
                    }
                    else {
                        sClass = "";
                    }
                    bWarning = false;

                    try {
                        bWarning = new SimpleDateFormat("dd/MM/yyyy").parse(vaccinationsInfoVO.getTransactionVO().getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE").getValue()).before(new java.util.Date());
                    }
                    catch (Exception e) {
                        // nothing
                    }
                    out.print("<tr class='list"+sClass+"'>");

                    if (bWarning) {
                        %><td width="1"><img src="<c:url value='/_img/warning.gif'/>" alt=""></td><%
                    }
                    else{
                        %><td width="1"/><%
                    }

                    out.print("<td><b>"+getTran("web.occup",vaccinationsInfoVO.getType(),sWebLanguage)+" ("+checkString(vaccinationsInfoVO.getTransactionVO().getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE").getValue())+")</b></td><td>"+(nextDate.length()>0?"<img src='_img/pijl.gif'> ":"")+nextDate+"</td></tr>");
                }
            }
        }
    }
    catch(Exception e){
        e.printStackTrace();    
}
    %>
    <tr height="99%"><td/></tr>
</table>
<% Debug.println("vaccin stop"); %>