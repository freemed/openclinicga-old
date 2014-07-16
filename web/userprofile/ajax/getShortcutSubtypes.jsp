<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Examination,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sShortcutType = checkString(request.getParameter("ShortcutType"));
    	
    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
	    Debug.println("\n******* userprofile/ajax/getShortcutSubtypes.jsp *******");
	    Debug.println("sShortcutType : "+sShortcutType+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////
    
    Hashtable shortcutSubtypes = new Hashtable();
    String sLabelType = "";

    //*** type = documents (transactions) ***
    if(sShortcutType.equals("hidden.clinicalDocuments")){    	
    	sLabelType = "web.occup";
    	
    	Vector examinations = Examination.SelectExaminations();
    	Examination examination;
    	for(int i=0; i<examinations.size(); i++){
    	    examination = (Examination)examinations.get(i);
    	    
    	    String sTranType = examination.getTransactionType();
    	    String sTranSubtype = "";
    	    if(sTranType.indexOf("&") > 0){
    	    	sTranSubtype = sTranType.substring(sTranType.indexOf("&")+1);
    	    	sTranType = sTranType.substring(0,sTranType.indexOf("&"));
    	    	
    	    	if(sTranSubtype.startsWith("vaccination=")){
    	    		sTranSubtype = sTranSubtype.substring("vaccination=".length());
    	    	}
    	    }
    	    
    	    String sTranLabel = "";
    	    if(sTranType.indexOf("_CUSTOMEXAMINATION") > -1){
    	    	String sTranTypeId = sTranType.substring(sTranType.indexOf("_CUSTOMEXAMINATION")+"_CUSTOMEXAMINATION".length());
    	        sTranLabel = getTranNoLink("examination",sTranTypeId,sWebLanguage);
    	    }
    	    else{
    	    	sTranLabel = getTranNoLink(sLabelType,sTranType,sWebLanguage);
    	    }
    	    
    	    if(sTranSubtype.length() > 0){
    	        sTranLabel+= " ["+getTranNoLink(sLabelType,sTranSubtype,sWebLanguage)+"]";	
    	    }
    	    
    	    shortcutSubtypes.put(sTranLabel,sTranType); // label is id
    	}
    }
    //*** other types ***
    /*
    else if(sShortcutType.equals(".......")){        
    	sLabelType = "web.occup";

        ...
    }
    */

    System.out.println("--> shortcutSubTypes : "+shortcutSubtypes.size());
    if(shortcutSubtypes.size() > 0){
    	%>	            
		    <select id="ShortcutSubtype" class="text">
		        <option value="-1"><%=HTMLEntities.htmlentities(getTran("web","choose",sWebLanguage))%></option>
                <%
                    Vector sortedLabels = new Vector(shortcutSubtypes.keySet());
                    Collections.sort(sortedLabels);
                    
    	            for(int i=0; i<sortedLabels.size(); i++){
	                    %><option value="<%=shortcutSubtypes.get(sortedLabels.get(i))%>"><%=HTMLEntities.htmlentities((String)sortedLabels.get(i))%></option><%
	                }
                %>
            </select>
        <% 
    }
%>