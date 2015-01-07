<%@ page import="be.openclinic.finance.*,java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<%
    Vector vCurrentInsurances;
    vCurrentInsurances = Insurance.getCurrentInsurances(activePatient.personid);
    Iterator iter = vCurrentInsurances.iterator();

    Insurance currentInsurance;
%>
<table class="list" width="100%" cellspacing="0">
    <tr class="admin">
        <td>
            <%=getTran("curative","insurance.status.title",sWebLanguage)%>&nbsp;
            <a href="<c:url value='/main.jsp'/>?Page=financial/insurance/historyInsurances.jsp&ts=<%=getTs()%>"><img src="<c:url value='/_img/icon_history2.gif'/>" class="link" alt="<%=getTranNoLink("web","historyinsurances",sWebLanguage)%>" style="vertical-align:-4px;"></a>
            <a href="<c:url value='/main.jsp'/>?Page=financial/insurance/editInsurance.jsp&ts=<%=getTs()%>"><img src="<c:url value='/_img/icons/icon_new.gif'/>" class="link" alt="<%=getTranNoLink("web","newinsurance",sWebLanguage)%>" style="vertical-align:-4px;"></a>
        </td>
    </tr>
    <%
        if(vCurrentInsurances.size() > 0){
    %>
    <tr>
        <td style="padding:0;">
            <table width="100%" class="sortable" cellpadding="0" cellspacing="0" id="searchresultsInsurance" style="border:0;">
                <tr class="gray">
                    <td><%=getTran("insurance","insurancenr",sWebLanguage)%></td>
                    <td><%=getTran("web","company",sWebLanguage)%></td>
                    <td><%=getTran("web","tariff",sWebLanguage)%></td>
                    <td><%=getTran("web","start",sWebLanguage)%></td>
                    <td><%=getTran("web","validity",sWebLanguage)%></td>
                </tr>
    <%
    		
    		String sClass ="";
            while(iter.hasNext()){
                currentInsurance = (Insurance)iter.next();
                java.util.Date dValidity=Debet.getContributionValidity(currentInsurance.getMember());
        		String sValidity=getTran("web","none",sWebLanguage);
        		if(dValidity!=null){
        			sValidity=new SimpleDateFormat("dd/MM/yyyy").format(dValidity);
        		}
                if(sClass.equals("")){
                    sClass = "1";
                }else{
                    sClass = "";
                }
    %>
                <tr class="list<%=sClass%>" onmouseover="this.style.cursor='hand';"
                                            onmouseout="this.style.cursor='default';"
                                            >
                    <td onclick="doSelect('<%=currentInsurance.getUid()%>');"><%=ScreenHelper.checkString(currentInsurance.getInsuranceNr())%></td>
                    <td onclick="doSelect('<%=currentInsurance.getUid()%>');"><%=ScreenHelper.checkString(currentInsurance.getInsuranceCategoryLetter()).length()>0 && currentInsurance.getInsuranceCategory().getLabel().length()>0?ScreenHelper.checkString(currentInsurance.getInsuranceCategory().getInsurar().getName())+ " ("+currentInsurance.getInsuranceCategory().getCategory()+": "+currentInsurance.getInsuranceCategory().getPatientShare()+"/"+(100-Integer.parseInt(currentInsurance.getInsuranceCategory().getPatientShare()))+")":""%></td>
                    <td onclick="doSelect('<%=currentInsurance.getUid()%>');"><%=ScreenHelper.checkString(getTran("insurance.types",currentInsurance.getType(),sWebLanguage))%></td>
                    <td onclick="doSelect('<%=currentInsurance.getUid()%>');"><%=ScreenHelper.checkString(currentInsurance.getStart()!=null?new SimpleDateFormat("dd/MM/yyyy").format(currentInsurance.getStart()):"")%></td>
					<td bgcolor="<%=dValidity==null || dValidity.before(new java.util.Date())?"red":"lightgreen" %>"><a href='javascript:showContributions(<%=currentInsurance.getMember()%>);'><%=sValidity %></a></td>                   
                </tr>
    <%
            }
    %>
            </table>
        </td>
    </tr>
    <%
        }
    %>
</table>
<script>
    function doSelect(id){
        window.location.href="<c:url value='/main.jsp'/>?Page=financial/insurance/editInsurance.jsp&EditInsuranceUID=" + id + "&ts=<%=getTs()%>";
    }
    
    function showContributions(personid){
    	openPopup("financial/showContributions.jsp&personid="+personid,600,400);
    }
</script>