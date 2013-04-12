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
			sOut+="<tr><td class='admin'>"+supportedlanguages.split(",")[n].toUpperCase()+" <input type='text' class='text' size='100' name='"+labtype+"$"+labid+"$"+supportedlanguages.split(",")[n]+"' value='"+getTranNoLink(labtype,labid,supportedlanguages.split(",")[n])+"'/></td></tr>";
		}
		sOut+="</table></td>";
		sOut+="</tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
	private String writeConfigRow(String label,String value,String color){
		String sOut="<tr class='admin2'"+(color.length()>0?" bgcolor='"+color+"'":"")+">";
		sOut+="<td valign='top'><b>"+label+"</b></td><td><input type='text' class='text' size='100' name='config$"+value+"' value='"+MedwanQuery.getInstance().getConfigString(value)+"'/></td></tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
	private String writeConfigRowOnOff(String label,String value,String color,int defaultValue){
		String sOut="<tr class='admin2'"+(color.length()>0?" bgcolor='"+color+"'":"")+">";
		sOut+="<td valign='top'><b>"+label+"</b></td><td><input class='text' type='checkbox' name='config$"+value+"' "+(MedwanQuery.getInstance().getConfigInt(value,defaultValue)==1?"checked":"")+"/>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
	private String writeConfigRowSelect(String label,String value,String color,String options){
		String sOut="<tr class='admin2'"+(color.length()>0?" bgcolor='"+color+"'":"")+">";
		sOut+=	"<td valign='top'><b>"+label+"</b></td><td>"+
				"<select class='text' name='config$"+value+"'>"+
				options+
				"</select>"+
				"</td></tr>";
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
    MedwanQuery.getInstance().setConfigString("lastGlobalHealthBarometerMonitor","19000101");
	if(checkString(request.getParameter("AutoClose")).equalsIgnoreCase("1") && MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterCountry","").length()>0 && MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterCity","").length()>0){
		out.println("<script>window.close();</script>");
		out.flush();
	}
%>

<form name="searchForm" method="post">
  <%=writeTableHeader("web.manage","manageglobalhealthbarometerdata",sWebLanguage,"doBack();")%>
  <h4><%=getTran("web","globalhealthbarometerinfo",sWebLanguage) %> <%=getTran("web","redrowsaremandatory",sWebLanguage) %></h4><br/><hr/>
  <table width="100%" class="menu" cellspacing="0" cellpadding="1">
<%
	out.println(writeConfigRowSelect(getTran("web","centerCountry",sWebLanguage),"globalHealthBarometerCenterCountry","orange","<option value=''/>"+ScreenHelper.writeSelectUpperCase("country", MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterCountry"), sWebLanguage,false,true)));
	out.println(writeConfigRow(getTran("web","centerCity",sWebLanguage),"globalHealthBarometerCenterCity","orange"));
	out.println(writeConfigRow(getTran("web","centerName",sWebLanguage),"globalHealthBarometerCenterName",""));
	out.println(writeConfigRow(getTran("web","centerEmail",sWebLanguage),"globalHealthBarometerCenterEmail",""));
	out.println(writeConfigRow(getTran("web","centerContact",sWebLanguage),"globalHealthBarometerCenterContact",""));
	out.println(writeConfigRowSelect(getTran("web","centerType",sWebLanguage),"globalHealthBarometerCenterType","","<option value=''/>"+ScreenHelper.writeSelect("centerType", MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterType"), sWebLanguage)));
	out.println(writeConfigRowSelect(getTran("web","centerLevel",sWebLanguage),"globalHealthBarometerCenterLevel","","<option value=''/>"+ScreenHelper.writeSelect("centerLevel", MedwanQuery.getInstance().getConfigString("globalHealthBarometerCenterLevel"), sWebLanguage)));
	out.println(writeConfigRow(getTran("web","centerBeds",sWebLanguage),"globalHealthBarometerCenterBeds",""));
	out.println(writeConfigRowSelect(getTran("web","globalhealthbarometerEnabled",sWebLanguage),"globalhealthbarometerEnabled","",ScreenHelper.writeSelect("yesno", MedwanQuery.getInstance().getConfigString("globalhealthbarometerEnabled","1"), sWebLanguage)));
	
	
%>
  </table>
  <input type='submit' name='save' value='<%=getTran("web","save",sWebLanguage)%>'/>
</form>

