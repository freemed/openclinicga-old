<%@page import="be.openclinic.archiving.*"%>
<%
	StorageEngine engine = new StorageEngine();
	engine.storeFile(10000000,"Test".getBytes());
%>