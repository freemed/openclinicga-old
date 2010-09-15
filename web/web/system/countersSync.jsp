<%@ page import="java.util.*"%>
<%@ page import="java.io.StringReader"%>
<%@ page import="org.dom4j.DocumentException"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.manageservices", "all",
							activeUser)%>
<%!public String updateCounters(HttpSession session,HttpServletRequest request) {
        String sOut= "";
        try{
        SAXReader xmlReader = new SAXReader();
        String sMenu = checkString((String) session.getAttribute("countersXml"));
        Document document;
        if (sMenu.length() > 0 && 1 > 1) {
            document = xmlReader.read(new StringReader(sMenu));
        } else {
            String sMenuXML = MedwanQuery.getInstance().getConfigString("countersXMLFile");
            if (sMenuXML.length() == 0) {
                sMenuXML = "counters.xml";
            }
            String sMenuXMLUrl = "http://" + request.getServerName() + request.getRequestURI().replaceAll(request.getServletPath(), "") + "/_common/xml/" + sMenuXML;
            // Check if menu file exists, else use file at templateSource location.
            try {
                document = xmlReader.read(new URL(sMenuXMLUrl));
            }
            catch (DocumentException e) {
                sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + "/" + sMenuXML;
                document = xmlReader.read(new URL(sMenuXMLUrl));
            }
            session.setAttribute("countersXml", document.asXML());
        }
        if (document != null) {
            Element root = document.getRootElement();
            if (root != null) {
                Iterator elements = root.elementIterator("counter");
                while (elements.hasNext()) {
                    Element e = (Element) elements.next();
                    String f = MedwanQuery.getInstance().setSynchroniseCounters(e.attributeValue("name"), e.attributeValue("table"), e.attributeValue("field"), e.attributeValue("bd"));
                    if(f.length()>0){
                        sOut+=("<li>"+e.attributeValue("name")+"<ul><li>"+f+"</li></ul></li>");
                    }
                }
            }
        }
        }catch (Exception e){
            sOut+=" ERROR : "+e.getMessage();
        }
        //Patients archiveFileCode
        String s="select max(archivefilecode) as maxcode from adminview where len(archivefilecode)=(select max(len(archivefilecode)) from adminview)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	PreparedStatement ps=oc_conn.prepareStatement(s);
        	ResultSet rs = ps.executeQuery();
        	if(rs.next()){
        		String maxcode=rs.getString("maxcode");
            	rs.close();
            	ps.close();
				s="update OC_COUNTERS set OC_COUNTER_VALUE=? where OC_COUNTER_NAME=?";
				ps=oc_conn.prepareStatement(s);
				ps.setInt(1,ScreenHelper.convertFromAlfabeticalCode(maxcode)+1);
				ps.setString(2,"ArchiveFileId");
				ps.executeUpdate();
				ps.close();
        	}
        	else{
	        	rs.close();
	        	ps.close();

        	}
        }
        catch(Exception e){
        	e.printStackTrace();
		}
        try{
        	oc_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        if(sOut.length()>0){
            sOut="<ul class='normallist'>"+sOut+"</ul>";
        }else{
            sOut="no modifications";
        }
        return sOut;
    }%>
<%
	boolean sAction = checkString(request.getParameter("Action"))
			.length() > 0;
%>
<%=writeTableHeader("Web.Manage",
							"synchronization.of.counters", sWebLanguage,
							" doBack();")%>
<%-- SELECT SERVER --------------------------------------------------------------------------%>
<table width="100%" cellspacing="0" cellpadding="0" class="list">
	<tr>
		<td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td>
		<td class="admin2"><%=(sAction) ? updateCounters(session, request) : ""%>
		<form id="transactionForm" name="transactionForm" method="post">

		<input type="hidden" name="Action" id="action"> <input
			class="button" type="button" name="backbutton"
			value="<%=getTranNoLink("Web.Occup", "medwan.common.execute",
							sWebLanguage)%>"
			onclick="$('action').value='start';$('transactionForm').submit()">
		<input class="button" type="button" name="cancel"
			value='<%=getTran("Web", "Back", sWebLanguage)%>'
			OnClick='javascript:window.location.href="main.do?Page=system/menu.jsp"'>

		</form>

		</td>
	</tr>
</table>
