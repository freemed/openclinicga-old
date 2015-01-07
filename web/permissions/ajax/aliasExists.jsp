<%@page import="be.openclinic.finance.*,
                org.dom4j.DocumentException,
                java.sql.Connection,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!    	
    //--- ALIAS EXISTS ----------------------------------------------------------------------------
    public boolean aliasExists(String sAlias, String sUserId){	    
	    boolean aliasExists = false;
	    String sUsingUserId = "";
	    
	    if(sAlias.length() > 0){	
	    	boolean isNumber = false;
	    
	    	// can not be a number
	    	try{
	    		Integer.parseInt(sAlias);
	    		isNumber = true;
	    	}
	    	catch(Exception e){
	    		// OK !
	    	}
	    	
	    	if(!isNumber){
		    	Connection conn = null;
		    	PreparedStatement ps = null;
		    	ResultSet rs = null;
		    	
		    	try{
			    	// check existence of alias
			    	conn = MedwanQuery.getInstance().getAdminConnection();
			    	int psIdx = 1;
			    	
			    	if(sUserId.length() > 0){
			    		// exclude existing user
				    	ps = conn.prepareStatement("select userid from userparameters where userid<>? and parameter='alias' and value=?");
				    	ps.setInt(psIdx++,Integer.parseInt(sUserId));
			    	}
			    	else{
			    		// check any and all users (current user does not exist yet)
			    		ps = conn.prepareStatement("select userid from userparameters where parameter='alias' and value=?");			    	
			    	}
			    	ps.setString(psIdx,sAlias);
			    	
			    	rs = ps.executeQuery();
			    	if(rs.next()){
			    		sUsingUserId = checkString(rs.getString(1));
			    	    aliasExists = true;	
			    	}
		    	}
		    	catch(Exception e){
		    		Debug.printStackTrace(e);
		    	}
		    	finally{
		    		try{
			    		if(rs!=null) rs.close();
			    		if(ps!=null) ps.close();
				    	if(conn!=null) conn.close();
		    		}
		    		catch(Exception e){
		    			Debug.printStackTrace(e);
		    		}
		    	}
	    	}
	    }

	    if(aliasExists){
	    	Debug.println("--> sUsingUserId : "+sUsingUserId);
	    }
	    
	    return aliasExists;
    }
%>
    	
<%   	
    String sAlias  = checkString(request.getParameter("Alias")),
           sUserId = checkString(request.getParameter("UserId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** permissions/ajax/aliasExists.jsp ******************");
    	Debug.println("sAlias  : "+sAlias);
    	Debug.println("sUserId : "+sUserId);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
            
    if(aliasExists(sAlias,sUserId)){
    	Debug.println("--> true\n");
       %>true<%	
    }   	
    else{
    	Debug.println("--> false\n");
    	%>false<%
    }
%>    