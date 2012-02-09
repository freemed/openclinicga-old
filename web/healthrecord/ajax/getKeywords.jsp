<%@page import="java.util.*"%>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String labeltype=checkString(request.getParameter("labeltype"));
	String destinationidfield=checkString(request.getParameter("destinationidfield"));
	String destinationtextfield=checkString(request.getParameter("destinationtextfield"));
	String keyword="",label="",line="";
	int cols=MedwanQuery.getInstance().getConfigInt("keywordCols",2),col=1,prefixsize,linecounter=0;
	int[] colsizes = new int[cols];
	
%>
<table width="100%">
	<tr><td class="admin" colspan="2"><%=getTran("web","keywords",sWebLanguage) %> <%=getTran("web","for",sWebLanguage) %> '<%=getTran("web",labeltype,sWebLanguage) %>'</td></tr>
<%
	if(labeltype.length()>0){
		Hashtable h = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
		SortedMap sortedSet = new TreeMap();
		if(h!=null){
			h=(Hashtable)h.get(labeltype);
			Iterator keywords=h.keySet().iterator();
			while(keywords.hasNext()){
				keyword=(String)keywords.next();
				sortedSet.put(((Label)h.get(keyword)).value,keyword);
			}
			if(sortedSet.size()<=17){
				cols=1;
			}
			int totalsize=0;
			for (int n=0;n<cols-1;n++){
				colsizes[n]=new Double(Math.ceil(new Double(sortedSet.size()).doubleValue()/cols)).intValue();
				totalsize+=colsizes[n];
			}
			colsizes[cols-1]=sortedSet.size()-totalsize;
			keywords=sortedSet.keySet().iterator();
			Vector k = new Vector();
			while(keywords.hasNext()){
				label=(String)keywords.next();
				keyword=(String)sortedSet.get(label);
				k.add(keyword+";"+label);
			}
			for(int n=0;n<k.size();n++){
				prefixsize=0;
				if(col==1){
					out.println("<tr>");
				}
				for(int i=0;i<col-1;i++){
					prefixsize+=colsizes[i];
				}
				line=(String)k.elementAt(prefixsize+linecounter);
				keyword=line.split(";")[0];
				label=line.split(";")[1];
				out.println("<td class='text'><a href='javascript:selectKeyword(\""+labeltype+"$"+keyword+"\",\""+HTMLEntities.htmlentities(label)+"\",\""+destinationidfield+"\",\""+destinationtextfield+"\");'/>"+HTMLEntities.htmlentities(label)+"</a></td>");
				if(col==cols){
					out.println("</tr>");
					col=1;
					linecounter++;
				}
				else{
					col++;
				}
			}
		}
	}
%>
</table>
