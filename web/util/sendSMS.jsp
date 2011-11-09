<%@ page import="be.openclinic.datacenter.*,be.openclinic.util.*" %>
<%
	//CommTest.main(null);
	SendSMS sendSMS = new SendSMS();
	sendSMS.send("modem.com7", "COM7", 9600, "Nokia", "6100", "8821");
%>