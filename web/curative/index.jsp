<%@ page import="be.mxs.common.util.system.Picture,java.io.File,java.io.FileOutputStream" %>
<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private void conditionalInclude(String page,PageContext pageContext,String accessright,User user){
        if(user.getAccessRight(accessright)){
            ScreenHelper.setIncludePage(customerInclude(page),pageContext);
        }
    }
    private String getLastAccess(String patientId,String sWebLanguage,HttpServletRequest request){
        SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy '"+getTranNoLink("web.occup"," - ",sWebLanguage)+"' HH:mm:ss");
        List l =  AccessLog.getLastAccess(patientId,2);
        String s = "";
        if(l.size()>1){
        	try{
            Object[] ss = (Object[])l.get(1);
            Timestamp t = (Timestamp)ss[0];
            Hashtable u = User.getUserName((String)ss[1]);
            s+= "<div style='float:right'><span style='font-weight:normal'>"+getTranNoLink("web.occup","last.access",sWebLanguage)+"  "+ (t==null?"?":dateformat.format(t))+" "+getTranNoLink("web","by",sWebLanguage)+" <b>"+(u==null?"?":u.get("firstname")+" "+u.get("lastname"))+"</b></span>";
            s+=" | <a href='javascript:void(0)' onclick='getAccessHistory(20)' class='link history' title='"+getTranNoLink("web","history",sWebLanguage)+"' alt=\""+getTranNoLink("web","history",sWebLanguage)+"\">...</a><a href='javascript:void(0)' onclick='getAdminHistory(20)' class='link adminhistory' title='"+getTranNoLink("web","adminhistory",sWebLanguage)+"' alt=\""+getTranNoLink("web","history",sWebLanguage)+"\">...</a></div>";
        	}
        	catch(Exception e){
        		e.printStackTrace();
        	}
        }
        return s;
    }
%>
<%
	String sVip="";
	if ("1".equalsIgnoreCase((String)activePatient.adminextends.get("vip"))) {
	    sVip="<img border='0' src='_img/icon_vip.jpg' alt='"+getTranNoLink("web","vip",sWebLanguage)+"'/>";
	}

%>
<script type="text/javascript">
    window.document.title="<%=sWEBTITLE+" "+getWindowTitle(request, sWebLanguage)%>";
</script>
<%-- ADMINISTRATIVE DATA --%>
<table width="100%" class="list">
    <tr><td colspan="10" class="titleadmin"><div style="float:left;vertical-align: middle"><%=getTran("web","administrative.data",sWebLanguage)+" "+sVip%></div><%=getLastAccess("A."+activePatient.personid,sWebLanguage,request)%></td></tr>
<%
    boolean bPicture=Picture.exists(Integer.parseInt(activePatient.personid));
    if (bPicture) {
        Picture picture = new Picture(Integer.parseInt(activePatient.personid));
        try{
            File file = new File(MedwanQuery.getInstance().getConfigString("DocumentsFolder", "c:/projects/openclinic/documents") + "/" + activeUser.userid + ".jpg");
            FileOutputStream fileOutputStream = new FileOutputStream(file);
            fileOutputStream.write(picture.getPicture());
            fileOutputStream.close();
%>
        <tr >
            <td class="image" valign="top" width="143px"><img border='0'  width="100%" src='<c:url value="/"/>documents/<%=activeUser.userid%>.jpg?ts=<%=getTs()%>'/></td>
            <td valign="top">
                <table width="100%"  >
        <%
        }
        catch (Exception e){
            //picture.delete();
            bPicture = false;
        }
    }
%>
                <tr><td colspan="2"><%conditionalInclude("curative/encounterStatus.jsp",pageContext,"adt.encounter.select",activeUser);%></td><tr>

                <tr>
                    <td valign="top" height="100%" width="50%"><%conditionalInclude("curative/financialStatus.jsp",pageContext,"financial.balance.select",activeUser);%></td>
                    <td><%conditionalInclude("curative/insuranceStatus.jsp",pageContext,"financial.balance.select",activeUser);%></td>
                <tr>

                <tr><td colspan="2"><%conditionalInclude("curative/planningStatus.jsp",pageContext,"planning.select",activeUser);%></td><tr>

        <%
    if (bPicture){
        %>
                </table>
            </td>
        </tr>
        <%
    }
        %>
</table>
<div style="height:2px;"></div>
<%-- MEDICAL DATA --%>
<% if(activeUser.getAccessRight("medical.select")){%>
    <table width="100%" class="list">
        <tr><td colspan="6" class="titleadmin"><%=getTran("web","medical.data",sWebLanguage)%></td></tr>
        <tr>
        	<%
        		if(activeUser.getAccessRight("medication.medicationschema.select")){
        	%>
            	<td colspan="3" valign="top" height="100%" width="50%"><%conditionalInclude("curative/medicationStatus.jsp",pageContext,"medication.medicationschema.select",activeUser);%></td>
            <%
        		}
        		else {
            %>
            	<td colspan="3" valign="top" height="100%" width="50%"><table width='100%'><tr class='admin'><td>&nbsp;</td></tr></table></td>
            <%
        		}
            %>
        	<%
        		if(activeUser.getAccessRight("occup.vaccinations.select")){
        	%>
	            <td colspan="3"  valign="top" height="100%"><%conditionalInclude("curative/vaccinationStatus.jsp",pageContext,"occup.vaccinations.select",activeUser);%></td>
            <%
        		}
        		else {
            %>
            	<td colspan="3" valign="top" height="100%" width="50%"><table width='100%'><tr class='admin'><td>&nbsp;</td></tr></table></td>
            <%
        		}
            %>
        <tr>
        <tr>
            <td colspan="2"  valign="top" height="100%" width="30%"><%conditionalInclude("curative/warningStatus.jsp",pageContext,"occup.warning.select",activeUser);%></td>
            <td colspan="2"  valign="top" height="100%" width="30%"><%conditionalInclude("curative/activeDiagnosisStatus.jsp",pageContext,"problemlist.select",activeUser);%></td>
            <td colspan="2"  valign="top" height="100%"><%conditionalInclude("curative/rfeStatus.jsp",pageContext,"problemlist.select",activeUser);%></td>
        <tr>
        <tr><td colspan="6"><%conditionalInclude("curative/medicalHistoryStatus.jsp",pageContext,"examinations.select",activeUser);%></td><tr>
    </table>
<%
    }
%>
<div id="responseByAjax">&nbsp;</div>
<div id="weekSchedulerFormByAjax" style="display:none;position:absolute;background:white">&nbsp;</div>
<script>
	var getAccessHistory = function(nb){
	    var url = "<c:url value='/curative/ajax/getHistoryAccess.jsp'/>?nb="+nb+"&ts="+new Date().getTime();
	    Modalbox.show(url, {title: '<%=getTran("web", "history", sWebLanguage)%>', width: 420,height:370},{evalScripts: true} );
	}
    var getAdminHistory = function(nb){
        var url = "<c:url value='/curative/ajax/getHistoryAdmin.jsp'/>?nb="+nb+"&ts="+new Date().getTime();
        Modalbox.show(url, {title: '<%=getTran("web", "adminhistory", sWebLanguage)%>', width: 420,height:370},{evalScripts: true} );
    }
</script>