<%@page import="be.openclinic.archiving.ScanDirectoryMonitor"%>

<%
    System.out.println("11111111111111111111111111111111111111111111111111111111"); //////////
    ScanDirectoryMonitor scanDirMon = new ScanDirectoryMonitor();
    scanDirMon.activate();
    System.out.println("22222222222222222222222222222222222222222222222222222222"); //////////
%>