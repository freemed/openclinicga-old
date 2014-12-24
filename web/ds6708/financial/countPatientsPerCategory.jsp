<%@page import="be.openclinic.finance.Insurance,
                be.mxs.common.util.system.ScreenHelper,
                java.util.Hashtable,
                java.util.Enumeration"%>
<%
    String sInsurarUid = ScreenHelper.checkString(request.getParameter("InsurarUid"));
    Hashtable patientsPerCategory = Insurance.countPatientsPerCategory(sInsurarUid);

    String sPatientsPerCategory = "", catLetter, patCount;
    Enumeration catEnum = patientsPerCategory.keys();
    while(catEnum.hasMoreElements()){
        catLetter = (String)catEnum.nextElement();
        patCount = (String)patientsPerCategory.get(catLetter);
        sPatientsPerCategory+= catLetter+":"+patCount+"$";
    }
%>
<%=sPatientsPerCategory%>