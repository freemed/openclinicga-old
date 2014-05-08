<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    int iNb = ((checkString(request.getParameter("nb")).length()>0)?Integer.parseInt(checkString(request.getParameter("nb"))):0);
    String sTransaction = checkString(request.getParameter("trans"));

    //SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy '"+getTranNoLink("web.occup"," - ",sWebLanguage)+"' HH:mm:ss");
    List lAccesses = AccessLog.getLastAccess(sTransaction,iNb);
    String s = "";
    int i = 0;
    Timestamp tAccessTime;
    Hashtable userData;
    
    if(lAccesses.size() > 1){
        Iterator accessIter = lAccesses.iterator();
        while(accessIter.hasNext()){
            Object[] ss = (Object[])accessIter.next();
            tAccessTime = (Timestamp)ss[0];
            userData = User.getUserName((String)ss[1]);
            s+= "\n<li style=\"width:100%;\" "+((i%2==0)?"class='odd'":"")+"><div> "+ScreenHelper.fullDateFormat.format(tAccessTime)+" "+getTranNoLink("web","by",sWebLanguage)+" "+userData.get("firstname")+" "+userData.get("lastname")+"</div></li>";
            i++;
        }
    }

    if(iNb>0 && lAccesses.size()>20){
        %><div style="width:100%;text-align:right;"><a href="javascript:void(0)" onclick="getAccessHistory(0);" class="link"><%=getTranNoLink("web","expand_all",sWebLanguage)%> » </a></div><%
    }
%>

<ul class="items" style="width:380px;"><%=s%></ul>