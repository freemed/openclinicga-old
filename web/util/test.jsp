<%@ page import="be.mxs.common.util.system.Picture" %>
<%
	Picture picture = new Picture(9966);
System.out.println("Picture size="+picture.getPicture().length);
System.out.println("Picture ="+new String(picture.getPicture()));
	String s = javax.mail.internet.MimeUtility.encodeText(new String(picture.getPicture()));
	System.out.println(s);
	String s2=javax.mail.internet.MimeUtility.decodeText(s);
	System.out.println("recovered picture length="+s2.length());
	System.out.println("recovered picture ="+s2);
%>