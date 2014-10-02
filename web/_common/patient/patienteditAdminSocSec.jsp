<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<table border='0' width='100%' class="list" cellspacing="1" style="border-top:none;">
    <%
        AdminSocSec socsec;
        String srbSCYes = "", srbSCNo = "";
        if(activePatient!=null){
            socsec = activePatient.socsec;

            if (socsec.covered.equalsIgnoreCase("medwan.common.yes")){
                srbSCYes = " checked ";
            }
            else if (socsec.covered.equalsIgnoreCase("medwan.common.no")){
                srbSCNo = " checked ";
            }
        }
        else {
            socsec = new AdminSocSec();
        }

        out.print(
                normalRow("Web.socsec","covered","SCovered","AdminSocSec",sWebLanguage)
                    +"<input type='radio' name='SCovered' value='medwan.common.yes' id='rbSCYes' onDblClick='uncheckRadio(this)'"+srbSCYes+"/>"+getLabel("web.occup","medwan.common.yes",sWebLanguage,"rbSCYes")
                    +"<input type='radio' name='SCovered' value='medwan.common.no' id='rbSCNo' onDblClick='uncheckRadio(this)'"+srbSCNo+"/>"+getLabel("web.occup","medwan.common.no",sWebLanguage,"rbSCNo")
                    +"</td></tr>"
                +inputRow("Web.socsec","enterprise","SEnterprise","AdminSocSec",socsec.enterprise,"T",true, true,sWebLanguage)
                +inputRow("Web.socsec","assurancenumber","SAssurancenumber","AdminSocSec",socsec.assurancenumber,"T",true, true,sWebLanguage)
                +normalRow("Web.socsec","assurancetype","SAssurancetype","AdminSocSec",sWebLanguage)
                        +"<select class='text' name='SAssurancetype'></option>"
                        +ScreenHelper.writeSelect("assurancetype",socsec.assurancetype,sWebLanguage)
                        +"</select></td></tr>"
                +inputRow("Web","start","SStart","AdminSocSec",socsec.start,"D",true,false,sWebLanguage)
                +inputRow("Web","stop","SStop","AdminSocSec",socsec.stop,"D",true,false,sWebLanguage)
                +inputRow("Web","comment","SComment","AdminSocSec",socsec.comment,"T",true, true,sWebLanguage));
    %>
    <%-- spacer --%>
    <tr height="0">
        <td width='<%=sTDAdminWidth%>'/><td width='*'/>
    </tr>
</table>
