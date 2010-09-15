<%@page isErrorPage="true"%>
<%@page import="java.util.GregorianCalendar,
                java.util.Calendar,
                net.admin.User"%>
<%!
    //--- SAVE ERROR ------------------------------------------------------------------------------
    public void saveError(String sError, String sPage, User user) {
        // error
        byte[] aError = sError.getBytes();

        // ts
        GregorianCalendar myDate = new GregorianCalendar();
        int iYear = new Integer(myDate.get(Calendar.YEAR)).intValue();
        int iMonth = new Integer(myDate.get(Calendar.MONTH)+1).intValue();
        int iDay = new Integer(myDate.get(Calendar.DATE)).intValue();
        int iHour = myDate.get(Calendar.HOUR_OF_DAY);
        int iMinute = myDate.get(Calendar.MINUTE);
        Calendar c = Calendar.getInstance();
        c.set(iYear, iMonth-1, iDay, iHour, iMinute);
        java.sql.Timestamp ts = new java.sql.Timestamp(c.getTimeInMillis());

        // page
        if (sPage==null){
            sPage="";
        }

        // userid
        int iUserid = 0;
        if (user!=null){
            iUserid = Integer.parseInt(user.userid);
        }

        // save
        be.openclinic.system.Error eError = new be.openclinic.system.Error();
        eError.setUpdatetime(ts);
        eError.setUpdateuserid(iUserid);
        eError.setErrorpage(sPage);
        eError.setErrortext(aError);

        eError.insert();
    }
%>

<%
    String sError = "fillInStackTrace: "+exception.fillInStackTrace()
                  +"<BR><BR>getLocalizedMessage: "+exception.getLocalizedMessage()
                  +"<BR><BR>getMessage: "+exception.getMessage()
                  +"<BR><BR>toString: "+exception;
    out.print(sError);
    exception.printStackTrace();
    User activeUser = (User)session.getAttribute("activeUser");
    String sPage = request.getParameter("Page");
    saveError(sError, sPage, activeUser);
%>

