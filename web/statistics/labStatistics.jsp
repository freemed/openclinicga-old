<%@ page import="webcab.lib.statistics.statistics.*"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
	<tr class="admin">
		<td width='20%' colspan='2'><%= getTran("web","statistics.lab",sWebLanguage) %></td>
		<td width='40%' colspan='4'><%= getTran("web","from",sWebLanguage)+": "+ request.getParameter("start")%></td>
		<td width='40%' colspan='4'><%= getTran("web","to",sWebLanguage)+": "+ request.getParameter("end")%></td>
	</tr>
<%
	String sBegin = ScreenHelper.checkString(request.getParameter("start"));
	java.util.Date begin=null;
	try {
	    begin = ScreenHelper.parseDate(sBegin);
	}
	catch(Exception e){
	}
	String sEnd = ScreenHelper.checkString(request.getParameter("end"));
	java.util.Date end=null;
	try {
	    end = ScreenHelper.parseDate(sEnd);
	}
	catch(Exception e){
	}
	if(begin!=null && end!=null){
		//Eerst maken we een lijst van alle labanalyses die in de opgegeven periode werden uitgevoerd
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		String sQuery = "select distinct a.analysiscode,b.*,c.oc_label_value labgroupname from requestedlabanalyses a,labanalysis b,oc_labels c where b.deletetime is null and c.oc_label_type='labanalysis.group' and c.oc_label_id=b.labgroup and c.oc_label_language=? and a.resultdate between ? and ? and a.analysiscode=b.labcode and a.finalvalidationdatetime is not null order by oc_label_value,analysiscode";
		PreparedStatement ps =conn.prepareStatement(sQuery);
		ps.setString(1,sWebLanguage);
		ps.setDate(2,new java.sql.Date(begin.getTime()));
		ps.setDate(3,new java.sql.Date(end.getTime()+24*3600*1000));
		ResultSet rs = ps.executeQuery();
		String activelabgroup="";
		while(rs.next()){
			String labgroup=rs.getString("labgroupname");
			if(!activelabgroup.equalsIgnoreCase(labgroup)){
				activelabgroup=labgroup;
				out.println("<tr><td class='titleadmin' colspan='10'>"+labgroup.toUpperCase()+"</td></tr>");
			}
			String labcode=rs.getString("labid");
			//We maken alle individuele berekeningen voor deze analyse
			int _labCount=0;
			String _labEditor=ScreenHelper.checkString(rs.getString("editor"));
			String _labEditorParameters=ScreenHelper.checkString(rs.getString("editorparameters"));
			String _labCode=ScreenHelper.checkString(rs.getString("analysiscode"));
			
			StringBuffer sResults=new StringBuffer("<table width='100%'>");

			if(_labEditor.equalsIgnoreCase("numeric")){
				sQuery="select * from requestedlabanalyses where analysiscode=? and resultdate between ? and ? and finalvalidationdatetime is not null ";
				PreparedStatement ps2 =conn.prepareStatement(sQuery);
				ps2.setString(1,_labCode);
				ps2.setDate(2,new java.sql.Date(begin.getTime()));
				ps2.setDate(3,new java.sql.Date(end.getTime()+24*3600*1000));
				ResultSet rs2 = ps2.executeQuery();
				Vector v = new Vector();
				while(rs2.next()){
					_labCount++;
					try {
						v.add(Double.parseDouble(rs2.getString("resultvalue")));
					}
					catch(Exception e){
						e.printStackTrace();
					}
				}
				rs2.close();
				ps2.close();
				double[] data = new double[v.size()];
				for(int n=0;n<v.size();n++){
					data[n]=((Double)v.elementAt(n)).doubleValue();
				}
				BasicStatistics basicStatistics = new BasicStatistics(data);
				sResults.append("<tr><td colspan='8'><table width='100%'><tr>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</table></td></tr>");
				
				sResults.append("<tr>");
				sResults.append("<td nowrap class='"+(data.length>2 && basicStatistics.percentile(0)<basicStatistics.arithmeticMean()-basicStatistics.sampleStdDeviation()*3?"red' style='cursor: pointer' onclick='showlowerthan(\""+_labCode+"\","+(basicStatistics.arithmeticMean()-basicStatistics.sampleStdDeviation()*3)+");":"text")+"' width='20%'>"+getTran("web","minimum",sWebLanguage)+": <b>"+(data.length<1?"?":new DecimalFormat("0.00").format(basicStatistics.percentile(0)))+"</b></td>");
				sResults.append("<td nowrap class='"+(data.length>2 && basicStatistics.percentile(100)>basicStatistics.arithmeticMean()+basicStatistics.sampleStdDeviation()*3?"red' style='cursor: pointer'  onclick='showgreaterthan(\""+_labCode+"\","+(basicStatistics.arithmeticMean()+basicStatistics.sampleStdDeviation()*3)+");":"text")+"' width='20%'>"+getTran("web","maximum",sWebLanguage)+": <b>"+(data.length<1?"?":new DecimalFormat("0.00").format(basicStatistics.percentile(100)))+"</b></td>");
				sResults.append("<td nowrap class='text' width='20%'>"+getTran("web","mean",sWebLanguage)+": <b>"+new DecimalFormat("0.00").format(basicStatistics.arithmeticMean())+"</b></td>");
				sResults.append("<td nowrap class='text' width='20%'>"+getTran("web","median",sWebLanguage)+": <b>"+(data.length<1?"?":new DecimalFormat("0.00").format(basicStatistics.median()))+"</b></td>");
				sResults.append("<td nowrap class='text' width='20%'>"+getTran("web","standarddeviation",sWebLanguage)+": <b>"+new DecimalFormat("0.00").format(basicStatistics.sampleStdDeviation())+"</b></td>");
				sResults.append("</tr>");
			}
			else if(_labEditor.equalsIgnoreCase("listbox") || _labEditor.equalsIgnoreCase("radiobutton")||_labEditor.equalsIgnoreCase("listboxcomment") || _labEditor.equalsIgnoreCase("radiobuttoncomment")){
				String[] options = new String[0];
				try {
					options=_labEditorParameters.split(":")[1].split(","); 
				}
				catch(Exception e){
					
				}
				SortedMap hOptions = new TreeMap();
				for(int n=0;n<options.length;n++){
					if(options[n].trim().length()>0){
						hOptions.put(options[n],0);
					}
				}
				sQuery="select count(*) total,resultvalue from requestedlabanalyses where analysiscode=? and resultdate between ? and ?  and finalvalidationdatetime is not null group by resultvalue";
				PreparedStatement ps2 =conn.prepareStatement(sQuery);
				ps2.setString(1,_labCode);
				ps2.setDate(2,new java.sql.Date(begin.getTime()));
				ps2.setDate(3,new java.sql.Date(end.getTime()+24*3600*1000));
				ResultSet rs2 = ps2.executeQuery();
				String sResultValue;
				while(rs2.next()){
					int _resultCount=rs2.getInt("total");
					_labCount+=_resultCount;
					sResultValue=rs2.getString("resultvalue");
					hOptions.put(sResultValue, _resultCount);
				}
				rs2.close();
				ps2.close();
				Iterator iOptions = hOptions.keySet().iterator();
				int counter=0;
				String sResultValues="<td colspan='8'><table width='100%'><tr>";
				int width=12;
				if(hOptions.size()>0 && hOptions.size()<8){
					width=100/hOptions.size();
				}
				while(iOptions.hasNext()){
					if(counter>0 && counter % 8==0){
						sResultValues+="</tr><tr>";
					}
					counter++;
					sResultValue=(String)iOptions.next();
					sResultValues+="<td class='text' width='"+width+"%'>"+sResultValue+": <b>"+hOptions.get(sResultValue)+"</b></td>";
				}
				sResultValues+="</tr></table></td>";
				sResults.append("<tr><td colspan='8'><table width='100%'><tr>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</table></td></tr>");
				
				sResults.append("<tr>");
				sResults.append(sResultValues);
				sResults.append("</tr>");
			}
			else if(_labEditor.equalsIgnoreCase("checkbox")||_labEditor.equalsIgnoreCase("checkboxcomment") ){
				String[] options = new String[0];
				try {
					options=_labEditorParameters.split(":")[1].split(","); 
				}
				catch(Exception e){
					
				}
				SortedMap hOptions = new TreeMap();
				for(int n=0;n<options.length;n++){
					if(options[n].trim().length()>0){
						hOptions.put(options[n],0);
					}
				}
				sQuery="select count(*) total,resultvalue from requestedlabanalyses where analysiscode=? and resultdate between ? and ?  and finalvalidationdatetime is not null group by resultvalue";
				PreparedStatement ps2 =conn.prepareStatement(sQuery);
				ps2.setString(1,_labCode);
				ps2.setDate(2,new java.sql.Date(begin.getTime()));
				ps2.setDate(3,new java.sql.Date(end.getTime()+24*3600*1000));
				ResultSet rs2 = ps2.executeQuery();
				String[] sResultValue;
				while(rs2.next()){
					int _resultCount=rs2.getInt("total");
					_labCount+=_resultCount;
					sResultValue=checkString(rs2.getString("resultvalue")).split(",");
					for(int n=0;n<sResultValue.length;n++){
						if(hOptions.get(sResultValue[n])==null){
							hOptions.put(sResultValue[n],_resultCount);
						}
						else {
							hOptions.put(sResultValue[n],(Integer)hOptions.get(sResultValue[n])+_resultCount);
						}
					}
				}
				rs2.close();
				ps2.close();
				Iterator iOptions = hOptions.keySet().iterator();
				int counter=0;
				String sResultValues="<td colspan='8'><table width='100%'><tr>";
				String s;
				int width=12;
				if(hOptions.size()>0 && hOptions.size()<8){
					width=100/hOptions.size();
				}
				while(iOptions.hasNext()){
					if(counter>0 && counter % 8==0){
						sResultValues+="</tr><tr>";
					}
					counter++;
					s=(String)iOptions.next();
					sResultValues+="<td class='text' width='"+width+"%'>"+s+": <b>"+hOptions.get(s)+"</b></td>";
				}
				sResultValues+="</tr></table></td>";
				sResults.append("<tr><td colspan='8'><table width='100%'><tr>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</table></td></tr>");
				
				sResults.append("<tr>");
				sResults.append(sResultValues);
				sResults.append("</tr>");
			}
			else {
				sQuery="select count(*) total from requestedlabanalyses where analysiscode=? and resultdate between ? and ? and finalvalidationdatetime is not null ";
				PreparedStatement ps2 =conn.prepareStatement(sQuery);
				ps2.setString(1,_labCode);
				ps2.setDate(2,new java.sql.Date(begin.getTime()));
				ps2.setDate(3,new java.sql.Date(end.getTime()+24*3600*1000));
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					_labCount=rs2.getInt("total");
				}
				rs2.close();
				ps2.close();

				sResults.append("<tr><td colspan='8'><table width='100%'><tr>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</table></td></tr>");
			}

		
			
			sResults.append("</table>");
			//Nu gaan we voor elke labanalyse een lijn wegschrijven met een reeks basisparameters en hyperlinks
			out.println("<tr>");
			out.println("<td class='admin'>"+_labCode+"</td>");
			out.println("<td class='admin'>"+getTran("labanalysis",labcode,sWebLanguage)+"</td>");
			out.println("<td class='admin' width='5%'>"+_labCount+"</td>");
			out.println("<td class='admin2' colspan='7'>"+sResults.toString()+"</td>");
			out.println("</tr>");
			
		}
		rs.close();
		ps.close();
		conn.close();
	}
%>
</table>
<script>
	function showgreaterthan(labcode,limitvalue){
		var URL = "statistics/labShowAberrantValues.jsp&labcode="+labcode+"&greaterthan="+limitvalue+"&start=<%=request.getParameter("start")%>&end=<%=request.getParameter("end")%>&ts=<%=getTs()%>";
		openPopup(URL,600,400,"OpenClinic Lab");
	}
	function showlowerthan(labcode,limitvalue){
		var URL = "statistics/labShowAberrantValues.jsp&labcode="+labcode+"&lowerthan="+limitvalue+"&start=<%=request.getParameter("start")%>&end=<%=request.getParameter("end")%>&ts=<%=getTs()%>";
		openPopup(URL,600,400,"OpenClinic Lab");
	}
</script>