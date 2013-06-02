<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
	<tr class="admin">
		<td width='33%' colspan='2'><%= getTran("web","statistics.lab",sWebLanguage) %></td>
		<td width='33%' colspan='4'><%= getTran("web","from",sWebLanguage)+": "+ request.getParameter("start")%></td>
		<td width='33%' colspan='4'><%= getTran("web","to",sWebLanguage)+": "+ request.getParameter("end")%></td>
	</tr>
<%
	String sBegin = ScreenHelper.checkString(request.getParameter("start"));
	java.util.Date begin=null;
	try {
	    begin = new SimpleDateFormat("dd/MM/yyyy").parse(sBegin);
	}
	catch(Exception e){
	}
	String sEnd = ScreenHelper.checkString(request.getParameter("end"));
	java.util.Date end=null;
	try {
	    end = new SimpleDateFormat("dd/MM/yyyy").parse(sEnd);
	}
	catch(Exception e){
	}
	if(begin!=null && end!=null){
		//Eerst maken we een lijst van alle labanalyses die in de opgegeven periode werden uitgevoerd
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		String sQuery = "select distinct a.analysiscode,b.*,c.oc_label_value labgroupname from requestedlabanalyses a,labanalysis b,oc_labels c where c.oc_label_type='labanalysis.group' and c.oc_label_id=b.labgroup and c.oc_label_language=? and a.resultdate between ? and ? and a.analysiscode=b.labcode and a.finalvalidationdatetime is not null order by oc_label_value,analysiscode";
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
			double _labMinimum=0,_labMaximum=0,_labStandarddeviation=0,_labAverage=0;
			String _labEditor=rs.getString("editor");
			String _labEditorParameters=rs.getString("editorparameters");
			String _labCode=rs.getString("analysiscode");
			
			StringBuffer sResults=new StringBuffer("<table width='100%'>");

			if(_labEditor.equalsIgnoreCase("numeric")){
				sQuery="select count(*) total,avg(resultvalue*1) average,"+MedwanQuery.getInstance().getConfigString("stddevFunction","stdev")+"(resultvalue*1) standarddeviation,min(resultvalue*1) minimum,max(resultvalue*1) maximum from requestedlabanalyses where analysiscode=? and resultdate between ? and ? and finalvalidationdatetime is not null ";
				PreparedStatement ps2 =conn.prepareStatement(sQuery);
				ps2.setString(1,_labCode);
				ps2.setDate(2,new java.sql.Date(begin.getTime()));
				ps2.setDate(3,new java.sql.Date(end.getTime()+24*3600*1000));
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					_labCount=rs2.getInt("total");
					_labMinimum=rs2.getDouble("minimum");
					_labMaximum=rs2.getDouble("maximum");
					_labAverage=rs2.getDouble("average");
					_labStandarddeviation=rs2.getDouble("standarddeviation");
				}
				rs2.close();
				ps2.close();

				sResults.append("<tr>");
				sResults.append("<td class='admin2' width='50%' colspan='2'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='2'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</tr>");
				
				sResults.append("<tr>");
				sResults.append("<td nowrap class='text' width='25%'>"+getTran("web","minimum",sWebLanguage)+": <b>"+new DecimalFormat("0.00").format(_labMinimum)+"</b></td>");
				sResults.append("<td nowrap class='text' width='25%'>"+getTran("web","maximum",sWebLanguage)+": <b>"+new DecimalFormat("0.00").format(_labMaximum)+"</b></td>");
				sResults.append("<td nowrap class='text' width='25%'>"+getTran("web","mean",sWebLanguage)+": <b>"+new DecimalFormat("0.00").format(_labAverage)+"</b></td>");
				sResults.append("<td nowrap class='text' width='25%'>"+getTran("web","standarddeviation",sWebLanguage)+": <b>"+new DecimalFormat("0.00").format(_labStandarddeviation)+"</b></td>");
				sResults.append("</tr>");
			}
			else if(_labEditor.equalsIgnoreCase("listbox")){
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
				if(rs2.next()){
					int _resultCount=rs2.getInt("total");
					_labCount+=_resultCount;
					sResultValue=rs2.getString("resultvalue");
					hOptions.put(sResultValue, _resultCount);
				}
				rs2.close();
				ps2.close();
				Iterator iOptions = hOptions.keySet().iterator();
				int counter=0;
				String sResultValues="";
				while(iOptions.hasNext()){
					if(counter>0 && counter % 8==0){
						sResultValues+="</tr><tr>";
					}
					counter++;
					sResultValue=(String)iOptions.next();
					sResultValues+="<td class='text' width='12%'>"+sResultValue+": <b>"+hOptions.get(sResultValue)+"</b></td>";
				}
				for(int n=counter;n<8;n++){
					sResultValues+="<td class='admin2' width='12%'>&nbsp;</td>";
				}
				sResults.append("<tr>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='4'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</tr>");
				
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

				sResults.append("<tr>");
				sResults.append("<td class='admin2' width='50%' colspan='2'>LOINC: <b>"+rs.getString("medidoccode")+"</b></td>");
				sResults.append("<td class='admin2' width='50%' colspan='2'>"+getTran("Web.manage","labanalysis.cols.editor",sWebLanguage)+": <b>"+getTranNoLink("web",_labEditor,sWebLanguage)+"</b></td>");
				sResults.append("</tr>");
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
	}
%>
</table>