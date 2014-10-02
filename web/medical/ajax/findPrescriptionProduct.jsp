<%@include file="/includes/validateUser.jsp"%>

<table width="100%">
<%
    String sProductName = checkString(request.getParameter("productname"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************** medical/ajax/findPrescriptionProduct.jsp ****************");
    	Debug.println("sProductName : "+sProductName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    int recCount = 0;
    
    if(sProductName.length() > 0){    	
    	Connection oc_conn = null;
    	PreparedStatement ps = null;
    	ResultSet rs = null;
    	
    	try{
	        String sQuery = "select * from OC_PRODUCTS"+
	                        " where OC_PRODUCT_NAME like '%"+sProductName+"%'"+
	        		        "  order by OC_PRODUCT_NAME";
	        oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
	        ps = oc_conn.prepareStatement(sQuery);
	        rs = ps.executeQuery();
	        
	        String sClass = "";
	        while(rs.next()){
	        	// alternate row-style
	            if(sClass.length()==0) sClass = "1";
	            else                   sClass = "";
	            
	            out.print("<tr class='list"+sClass+"'>"+
	                       "<td valign='middle'>"+
	                        "<a href='javascript:copyproduct(\""+rs.getInt("OC_PRODUCT_SERVERID")+"."+rs.getInt("OC_PRODUCT_OBJECTID")+"\");'>");
	            
	            %><img src='<c:url value="/_img/arrow_right.gif"/>' class='link' alt='<%=getTranNoLink("web","right",sWebLanguage)%>'/></a>&nbsp;<%
	            
	            out.print(  "<a href='javascript:copycontent(\""+rs.getInt("OC_PRODUCT_SERVERID")+"."+rs.getInt("OC_PRODUCT_OBJECTID")+"\");'>"+rs.getString("OC_PRODUCT_NAME")+"</a>"+
	                       "</td>"+
	            		  "</tr>");
	            
	            recCount++;
	        }
    	}
    	catch(Exception e){
    		Debug.printStackTrace(e);
    	}
    	finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
            	Debug.printStackTrace(e);
            }
    	}
    }
%>
</table>

<%
    if(recCount > 0){
    	%><%=recCount%> <%=getTranNoLink("web","recordsFound",sWebLanguage)%><%
    }
    else{
    	%><%=getTranNoLink("web","noRecordsFound",sWebLanguage)%><%
    }
%>