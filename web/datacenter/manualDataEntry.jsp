<%@include file="/includes/validateUser.jsp"%>
<%!
	public void storeSimpleValue(String serverid,String parameterid,String value,String date){
		Connection stats_conn = MedwanQuery.getInstance().getStatsConnection();
		try{
			PreparedStatement ps = stats_conn.prepareStatement("insert into DC_SIMPLEVALUES(DC_SIMPLEVALUE_SERVERID,DC_SIMPLEVALUE_OBJECTID,DC_SIMPLEVALUE_PARAMETERID,DC_SIMPLEVALUE_CREATEDATETIME,DC_SIMPLEVALUE_SENTDATETIME,DC_SIMPLEVALUE_RECEIVEDATETIME,DC_SIMPLEVALUE_IMPORTDATETIME,DC_SIMPLEVALUE_DATA) values(?,-9,?,?,?,?,?,?)");
			ps.setInt(1,Integer.parseInt(serverid));
			ps.setString(2,parameterid);
			ps.setDate(3,new java.sql.Date(ScreenHelper.parseDate(date).getTime()));
			ps.setDate(4,new java.sql.Date(new java.util.Date().getTime()));
			ps.setDate(5,new java.sql.Date(new java.util.Date().getTime()));
			ps.setDate(6,new java.sql.Date(new java.util.Date().getTime()));
			ps.setString(7,value);
			ps.execute();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				stats_conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
	}
    public String getBack(){
        return "<a href=\""+sCONTEXTPATH+"/datacenter/datacenterHome.jsp?ts="+getTs()+"\" class=\"button\"><span class=\"title\">Retour a la page initiale</span></a>";
    }
%>
<%
	String serverid = checkString(request.getParameter("serverid"));
	if(request.getParameter("action")!=null){
		Enumeration parameters = request.getParameterNames();
		while(parameters.hasMoreElements()){
			String parameter = (String)parameters.nextElement();
            if(parameter.startsWith("core.") && request.getParameter(parameter)!=null && request.getParameter(parameter).length()>0){
                storeSimpleValue(serverid,parameter,request.getParameter(parameter),request.getParameter("date.core"));
			}
		}
        out.write("<script>window.location = \""+sCONTEXTPATH+"/datacenter/datacenterHome.jsp?ts="+getTs()+"\";</script>");
    }
%>
<div style="width:100%;float:left;padding:0 0 3px 0"><%=getBack()%></div>

<div class='landlist' >
    <h3><%=getTran("datacenter","manual.data.entry",sWebLanguage) %></h3>

    <form name='transactionForm' id="transactionForm" method='POST'>
        <input type="hidden" name="serverid" value="<%=serverid %>"/>
       <input type="hidden" name="action" value="save"/>
       <div class='subcontent'>
        <table width="100%" class="content" cellpadding="0" cellspacing="0">
            <tr>
                <td class='admin' colspan='2'><%=getTran("datacenter","core",sWebLanguage) %></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","date.core",sWebLanguage) %></td>
                <td class='admin2'><%=writeDateField("date.core","transactionForm",ScreenHelper.stdDateFormat.format(new java.util.Date()),sWebLanguage)%></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.1",sWebLanguage) %></td>
                <td class='admin2'><input name='core.1' id='core.1' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.1.1",sWebLanguage) %></td>
                <td class='admin2'><input name='core.1.1' id='core.1.1' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.1.2",sWebLanguage) %></td>
                <td class='admin2'><input name='core.1.2' id='core.1.2' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.1.3",sWebLanguage) %></td>
                <td class='admin2'><input name='core.1.3' id='core.1.3' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.2",sWebLanguage) %></td>
                <td class='admin2'><input name='core.2' id='core.2' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.3",sWebLanguage) %></td>
                <td class='admin2'><input name='core.3' id='core.3' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.4",sWebLanguage) %></td>
                <td class='admin2'><input name='core.4' id='core.4' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.4.1",sWebLanguage) %></td>
                <td class='admin2'><input name='core.4.1' id='core.4.1' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.4.2",sWebLanguage) %></td>
                <td class='admin2'><input name='core.4.2' id='core.4.2' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.5",sWebLanguage) %></td>
                <td class='admin2'><input name='core.5' id='core.5' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.6",sWebLanguage) %></td>
                <td class='admin2'><input name='core.6' id='core.6' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.7",sWebLanguage) %></td>
                <td class='admin2'><input name='core.7' id='core.7' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.8",sWebLanguage) %></td>
                <td class='admin2'><input name='core.8' id='core.8' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.8.1",sWebLanguage) %></td>
                <td class='admin2'><input name='core.8.1' id='core.8.1' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.8.2",sWebLanguage) %></td>
                <td class='admin2'><input name='core.8.2' id='core.8.2' size='10' class='text' type='text'></td>
            </tr>
            <tr>
                <td class='admin'><%=getTran("datacenter","core.9",sWebLanguage) %></td>
                <td class='admin2'><input name='core.9' id='core.9' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.9.1",sWebLanguage) %></td>
                <td class='admin2'><input name='core.9.1' id='core.9.1' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.9.2",sWebLanguage) %></td>
                <td class='admin2'><input name='core.9.2' id='core.9.2' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.10",sWebLanguage) %></td>
                <td class='admin2'><input name='core.10' id='core.10' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.11",sWebLanguage) %></td>
                <td class='admin2'><input name='core.11' id='core.11' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.12",sWebLanguage) %></td>
                <td class='admin2'><input name='core.12' id='core.12' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.13",sWebLanguage) %></td>
                <td class='admin2'><input name='core.13' id='core.13' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.14",sWebLanguage) %></td>
                <td class='admin2'><input name='core.14' id='core.14' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.15",sWebLanguage) %></td>
                <td class='admin2'><input name='core.15' id='core.15' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.16",sWebLanguage) %></td>
                <td class='admin2'><input name='core.16' id='core.16' size='10' class='text' type='text'></td>
            </tr>
                <tr>
                <td class='admin'><%=getTran("datacenter","core.17",sWebLanguage) %></td>
                <td class='admin2'><input name='core.17' id='core.17' size='10' class='text' type='text'></td>
            </tr>
                <tr class="last">
                <td class='admin'><%=getTran("datacenter","core.18",sWebLanguage) %></td>
                <td class='admin2'><input name='core.18' id='core.18' size='10' class='text' type='text'></td>
            </tr>
         </table>
        </div>
        <a href="javascript:submitForm();" class="button"><span class="title"><%= getTran("web","save",sWebLanguage)%></span></a>
    </form>
</div>
<script>
    function submitForm(){
        $("transactionForm").submit();
    }
</script>