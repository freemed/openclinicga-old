<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.openclinic.system.Config,java.util.Hashtable,java.util.Enumeration" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%!
	private String writeRow(String labtype,String labid){
		String sOut="<tr class='admin2'>";
		sOut+="<td valign='top'>"+labtype+"$"+labid+"</td><td><table width='100%'>";
		String supportedlanguages=MedwanQuery.getInstance().getConfigString("supportedLanguages","fr,en,nl");
		for(int n=0;n<supportedlanguages.split(",").length;n++){
			sOut+="<tr><td class='admin'>"+supportedlanguages.split(",")[n].toUpperCase()+" <textarea onKeyup='resizeTextarea(this,10);' class='text' cols='100', rows='1' name='"+labtype+"$"+labid+"$"+supportedlanguages.split(",")[n]+"'>"+getTranNoLink(labtype,labid,supportedlanguages.split(",")[n])+"</textarea></td></tr>";
		}
		sOut+="</table></td>";
		sOut+="</tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
	private String writeConfigRow(String labtype){
		String sOut="<tr class='admin2'>";
		sOut+="<td valign='top'>"+labtype+"</td><td><textarea onKeyup='resizeTextarea(this,10);' class='text' cols='100', rows='1' name='config$"+labtype+"'>"+MedwanQuery.getInstance().getConfigString(labtype)+"</textarea></td></tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
%>
<%
	boolean updated=false;
	if(request.getParameter("save")!=null){
		//Save configuration
		Enumeration e = request.getParameterNames();
		while(e.hasMoreElements()){
			String sParName=(String)e.nextElement();
			if(sParName.split("\\$").length==3){
				String sParValue=checkString(request.getParameter(sParName));
				if(!sParValue.equals(getTranNoLink(sParName.split("\\$")[0],sParName.split("\\$")[1],sParName.split("\\$")[2]))){
					updated=true;
	                boolean bExists=false;
					Label oldLabel = new Label();
	                oldLabel.type = sParName.split("\\$")[0];
	                oldLabel.id = sParName.split("\\$")[1];
	                oldLabel.language = sParName.split("\\$")[2];

	                if (oldLabel.exists()) bExists = true;

	                if (bExists) {
	                    Label label = new Label();
	                    label.type = sParName.split("\\$")[0];
	                    label.id = sParName.split("\\$")[1];
	                    label.language = sParName.split("\\$")[2];
	                    label.value = sParValue;
	                    label.updateUserId = activeUser.userid;
	                    label.showLink = "false";

	                    label.updateByTypeIdLanguage(sParName.split("\\$")[0], sParName.split("\\$")[1], sParName.split("\\$")[2]);

	                }
	                else {
	                	MedwanQuery.getInstance().storeLabel(sParName.split("\\$")[0],sParName.split("\\$")[1],sParName.split("\\$")[2],sParValue,Integer.parseInt(activeUser.userid));	
	                }
				}
			}
			else if(sParName.split("\\$").length==2 && sParName.split("\\$")[0].equalsIgnoreCase("config")){
				MedwanQuery.getInstance().setConfigString(sParName.split("\\$")[1],checkString(request.getParameter(sParName)));
			}
			
		}
	}
	if(updated){
        reloadSingleton(session);
	}
%>

<form name="searchForm" method="post">
  <%=writeTableHeader("web.manage","managesitelabels",sWebLanguage,"doBack();")%>
  <table width="100%" class="menu" cellspacing="0" cellpadding="1">
<%
	out.println(writeRow("labresult","personid"));
	out.println(writeRow("urgency.destination","admission"));
	out.println(writeRow("web","cardhospitalref"));
	out.println(writeRow("web.occup","invoicedirector"));
	out.println(writeRow("labresult","footer"));
	out.println(writeRow("web","hospitalname"));
	out.println(writeRow("web","hospitaladdress"));
	out.println(writeRow("web.occup","invoicefinancialmessagetitle"));
	out.println(writeRow("web.occup","invoicefinancialmessagetitle2"));
	out.println(writeRow("web","productionsystemwarning"));
	out.println(writeRow("web","testsystemredirection"));
	if(MedwanQuery.getInstance().getConfigString("edition").equalsIgnoreCase("openinsurance")){
		out.println(writeRow("web.occup","rbfinancialmessagetitle"));
		out.println(writeRow("web.occup","rbmessagetitle2"));
	}
	out.println(writeConfigRow("footer."+checkString((String)session.getAttribute("activeProjectTitle")).toLowerCase()));
	out.println(writeRow("web","javaposcentername"));
	out.println(writeRow("web","javaposcentersubtitle"));
	out.println(writeRow("web","javaposcenterphone"));
%>
  </table>
  <input type='submit' name='save' value='<%=getTran("web","save",sWebLanguage)%>'/>
</form>

