<%@include file="/includes/validateUser.jsp"%>
<%
    String lastname    = checkString(request.getParameter("lastname")),
           firstname   = checkString(request.getParameter("firstname")),
           dateofbirth = checkString(request.getParameter("dateofbirth"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** datacenterstatistics/verifypatient.jsp ***************");
    	Debug.println("lastname    : "+lastname);
    	Debug.println("firstname   : "+firstname);
    	Debug.println("dateofbirth : "+dateofbirth+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sQuery = "select count(*) as total from Admin where 1=1";
    if(lastname.length() > 0){
        sQuery+= " and lastname like '"+lastname+"%'";
    }
    if(firstname.length() > 0){
        sQuery+= " and firstname like '"+firstname+"%'";
    }
    if(dateofbirth.length() > 0){
        sQuery+= " and dateofbirth = ?";
    }
    
    Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    PreparedStatement ps = ad_conn.prepareStatement(sQuery);
    if(dateofbirth.length() > 0){
        ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(dateofbirth).getTime()));
    }
    
    ResultSet rs = ps.executeQuery();
    if(rs.next()){
	    if(rs.getInt("total") > 0){
	        %>
	        <script>
	          if(yesnoDialog("web","patientexists")){
	            window.opener.document.getElementsByName('newPatient')[0].value = "1";
	            window.opener.document.getElementsByName('EditPatientForm')[0].submit();
	          }
	          window.close();
	        </script>
	        <%
	    }
	    else{
	        out.print("<script>"+
	                   "window.opener.document.getElementsByName('newPatient')[0].value='1';"+
	                   "window.opener.document.getElementsByName('EditPatientForm')[0].submit();"+
	        		   "window.close();"+
	                  "</script>");
	    }
    }
    rs.close();
    ps.close();
    ad_conn.close();
%>