<%@ page import="be.openclinic.datacenter.*,be.openclinic.util.*" %>
<%
	//CommTest.main(null);
	SendSMS sendSMS = new SendSMS();
	sendSMS.send("COM15", "COM15", 115200, "Nokia", "2690", "2147", "+32475621569", "test");
%>