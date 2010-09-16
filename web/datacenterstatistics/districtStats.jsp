<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.statistics.DistrictStats" %>
<%@ page import="be.mxs.common.util.db.MedwanQuery" %>
<table width="100%">
    <tr class="admin">
        <td colspan="3"><%=getTran("web","distribution_admissions_per_service_per_district",sWebLanguage)%></td>
    </tr>
<%
    Vector admissionservicedistrictstats = DistrictStats.getAdmissionServiceDistrictStats();
    for (int n = 0; n < admissionservicedistrictstats.size(); n++) {
        DistrictStats.ServiceDistrictStat serviceDistrictStat = (DistrictStats.ServiceDistrictStat) admissionservicedistrictstats.elementAt(n);
        out.println("<tr class='list'><td colspan='3'><b>" +serviceDistrictStat.service+" - "+ (serviceDistrictStat.service.length() == 0 ? getTran("web","unknown",sWebLanguage) : getTran("service",serviceDistrictStat.service,sWebLanguage)).toUpperCase() + "</b></td></tr>");
        int total=0;
        for (int i = 0; i < serviceDistrictStat.districtstats.size(); i++) {
            DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) serviceDistrictStat.districtstats.elementAt(i);
            total +=districtStat.total;
        }
        for (int i = 0; i < serviceDistrictStat.districtstats.size(); i++) {
            DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) serviceDistrictStat.districtstats.elementAt(i);
            out.println("<tr class='list'><td width='1%'/><td width='1%' nowrap>" + (districtStat.district.length() == 0 ? getTran("web","unknown",sWebLanguage) : districtStat.district).toUpperCase() + "</td><td>" + districtStat.total +(total>0?" ("+districtStat.total*100/total+"%)":"")+ "</td></tr>");
        }
    }

%>
</table>
<table width="100%">
    <tr class="admin">
        <td colspan="2"><%=getTran("web","distribution_admissions_per_district",sWebLanguage)%></td>
    </tr>
<%
    Vector admissiondistrictstats = DistrictStats.getAdmissionDistrictStats();
    int total=0;
    for (int n = 0; n < admissiondistrictstats.size(); n++) {
        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) admissiondistrictstats.elementAt(n);
        total +=districtStat.total;
    }
    for (int n = 0; n < admissiondistrictstats.size(); n++) {
        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) admissiondistrictstats.elementAt(n);
        out.println("<tr class='list'><td width='1%' nowrap><b>" + (districtStat.district.length() == 0 ? getTran("web","unknown",sWebLanguage) : districtStat.district).toUpperCase() + "</b></td><td>" + districtStat.total +(total>0?" ("+districtStat.total*100/total+"%)":"") + "</td></tr>");
    }

%>
</table>
<table width="100%">
    <tr class="admin">
        <td colspan="2"><%=getTran("web","distribution_passive_per_district",sWebLanguage)%></td>
    </tr>
<%
    Vector passivedistrictstats = DistrictStats.getPassiveDistrictStats();
    for (int n = 0; n < passivedistrictstats.size(); n++) {
        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) passivedistrictstats.elementAt(n);
        total +=districtStat.total;
    }
    for (int n = 0; n < passivedistrictstats.size(); n++) {
        DistrictStats.DistrictStat districtStat = (DistrictStats.DistrictStat) passivedistrictstats.elementAt(n);
        out.println("<tr class='list'><td width='1%' nowrap><b>" + (districtStat.district.length() == 0 ? getTran("web","unknown",sWebLanguage) : districtStat.district).toUpperCase() + "</b></td><td>" + districtStat.total + (total>0?" ("+districtStat.total*100/total+"%)":"") +"</td></tr>");
    }

%>
</table>
