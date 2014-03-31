<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%">
    <tr>
        <td width="1%"><img src="<c:url value='_img/HEALTHNETLOGO_small.jpg'/>"/></td>
        <td style="vertical-align:top;">
            <table width="100%">
                <tr>
                    <td class="admin2"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/networkstatus.jsp" target="healthnet"><%=getTran("healthnet","networkstatus",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td class="admin2"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/bedutilization.jsp" target="healthnet"><%=getTran("healthnet","bedutilization",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td class="admin2"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/adt.jsp" target="healthnet"><%=getTran("healthnet","adt",sWebLanguage)%></a></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <table width="100%">
                <tr>
                    <td class="admin"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/summary.jsp&source=hn.chuk" target="healthnet">CHUK</a></td>
                    <td class="admin"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/summary.jsp&source=hn.rutongo" target="healthnet">Rutongo</a></td>
                    <td class="admin">Nyamata</td>
                    <td class="admin">Muhima</td>
                    <td class="admin">Kibagabaga</td>
                    <td class="admin">Rwamagana</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan="2">
            <hr/>
        </td>
    </tr>
    <td colspan="2">
        <table width="100%">
            <tr>
                <td class="admin">Polyclinique du Carrefour</td>
                <td class="admin"><a href="<c:url value=''/>popup.jsp?PopupHeight=500&PopupWidth=600&Page=/healthnet/summary.jsp&source=hn.biennaitre" target="healthnet">Polyclinique Bien Naître</a></td>
                <td class="admin">Polyclinique la Médicale</td>
                <td class="admin">Polyclinique du Bon Samaritain</td>
                <td class="admin">Polyclinique Harmony</td>
                <td class="admin">Centre Biomédical</td>
                <td class="admin">Polyclinique du Croix du Sud</td>
            </tr>
        </table>
    </td>
</table>
