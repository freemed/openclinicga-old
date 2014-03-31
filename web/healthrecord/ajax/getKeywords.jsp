<%@page import="java.util.*"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String labelType = checkString(request.getParameter("labeltype"));

	String destinationIdfield   = checkString(request.getParameter("destinationidfield")),
		   destinationTextfield = checkString(request.getParameter("destinationtextfield"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n****************** healthrecord/ajax/getKeywords.jsp ******************");
		Debug.println("labeltype            : "+labelType);
		Debug.println("destinationidfield   : "+destinationIdfield);
		Debug.println("destinationtextfield : "+destinationTextfield+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	int cols = MedwanQuery.getInstance().getConfigInt("keywordCols",2);
	int col = 1, prefixsize, linecounter = 0;
	int[] colsizes = new int[cols];	
	String line = "";
%>

<table width="100%">
	<tr><td class="admin" colspan="2"><%=getTran("web","keywords",sWebLanguage)%> <%=getTran("web","for",sWebLanguage)%> '<%=getTran("web",labelType,sWebLanguage)%>'</td></tr>

<%
	if(labelType.length() > 0){
		Hashtable labels = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
		
		SortedMap sortedSet = new TreeMap();
		String labelId;
		if(labels!=null){
			labels = (Hashtable)labels.get(labelType);
			
			Iterator labelIter = labels.keySet().iterator();
			while(labelIter.hasNext()){
				labelId = (String)labelIter.next();
				sortedSet.put(((Label)labels.get(labelId)).value,labelId);
			}
			
			if(sortedSet.size()<=17){
				cols = 1;
			}
			int totalsize = 0;
			for(int n=0; n<cols-1; n++){
				colsizes[n] = new Double(Math.ceil(new Double(sortedSet.size()).doubleValue()/cols)).intValue();
				totalsize+= colsizes[n];
			}
			
			colsizes[cols-1] = sortedSet.size()-totalsize;
			labelIter = sortedSet.keySet().iterator();
			Vector keywordsAndLabels = new Vector();			
			String sLabel;
			while(labelIter.hasNext()){
				labelId = (String)labelIter.next();
				sLabel = (String)sortedSet.get(labelId);
				keywordsAndLabels.add(sLabel+";"+labelId);
			}
			
			for(int n=0; n<keywordsAndLabels.size(); n++){
				prefixsize = 0;
				
				if(col==1) out.println("<tr>");
				for(int i=0; i<col-1; i++){
					prefixsize+= colsizes[i];
				}
				
				line = (String)keywordsAndLabels.elementAt(prefixsize+linecounter);
				labelId = line.split(";")[0];
				sLabel = line.split(";")[1];
				
				sLabel = sLabel.replaceAll("'","´");
				
				out.println("<td class='text'><a href='javascript:addKeyword(\""+labelType+"$"+labelId+"\",\""+HTMLEntities.htmlentities(sLabel)+"\",\""+destinationIdfield+"\",\""+destinationTextfield+"\");'/>"+HTMLEntities.htmlentities(sLabel)+"</a></td>");
				
				if(col==cols){
					out.println("</tr>");
					col = 1;
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