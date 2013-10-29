<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sId = checkString(request.getParameter("Id")); // not used
 
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************** hr/getTreenMenuXML.jsp **************");
        Debug.println("sId : "+sId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////    

    // Create a structure like this iterating over a resultset
    String sXML = "<?xml version='1.0' encoding='iso-8859-1'?>"+
                  "<tree id=\"0\">"+
                   "<item text=\"Books\" id=\"books\" open=\"1\" call=\"1\" select=\"1\">"+
                  
                    // "MYSTERY"
                    "<item text=\"Mystery &amp; Thrillers\" id=\"mystery\" open=\"1\">"+
                     "<item text=\"Lawrence Block\" id=\"lb\" open=\"0\">"+
                    // changed : example of html in the content (needs to be escaped)
                              "<item text=\"&lt;a href='http://www.google.be'&gt;link to Google&lt;&#47;a&gt;\" id=\"lb_1\"/>"+
                              "<item text=\"&lt;font color='red'&gt;In red : The Burglar&lt;&#47;font&gt;\" id=\"lb_2\"/>"+
                      "<item text=\"The Plot Thickens\" id=\"lb_3\"/>"+
				      "<item text=\"Grifter's Game\" id=\"lb_4\"/>"+
				     "</item>"+ // Lawrence Block
                     "<item text=\"Ian Rankin\" id=\"ir\"></item>"+
			         "<item text=\"Nancy Atherton\" id=\"na\"></item>"+
				    "</item>"+
			        		 
                    // "HORROR"
			   	    "<item text=\"Horror\" id=\"horror\">"+
				     "<item text=\"Stephen King\" id=\"sk\"></item>"+
			         "<item text=\"Dan Brown\" id=\"db\">"+
				      "<item text=\"Angels &amp; Demons\" id=\"db_1\"/>"+
			          "<item text=\"Deception Point\" id=\"db_2\"/>"+
				      "<item text=\"Digital Fortress\" id=\"db_3\"/>"+
			         "</item>"+ // Dan Brown
                    "</item>"+
                    
	               "</item>"+ // Books
                  "</tree>";
                  
    Debug.println("\nsXML : "+sXML);
%>

<%=sXML%>
