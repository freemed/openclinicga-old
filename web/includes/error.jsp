<%@page isErrorPage="true"%>
<%@page import="java.util.Calendar,
                net.admin.User"%>

<%!
    //--- SAVE ERROR ------------------------------------------------------------------------------
    public void saveError(String sError, String sPage, User user){   
        be.openclinic.system.Error eError = new be.openclinic.system.Error();
        
        eError.setUpdatetime(new java.sql.Timestamp(Calendar.getInstance().getTimeInMillis()));
        eError.setUpdateuserid(((user!=null)?Integer.parseInt(user.userid):0));
        eError.setErrorpage((sPage==null?"":sPage));
        eError.setErrortext(sError.getBytes());

        eError.insert();
    }
%>

<%
    //*** display error ***
    String sError = "fillInStackTrace: "+exception.fillInStackTrace()+
                    "<BR><BR>getLocalizedMessage: "+exception.getLocalizedMessage()+
                    "<BR><BR>getMessage: "+exception.getMessage()+
                    "<BR><BR>toString: "+exception;
    out.print(sError);
    exception.printStackTrace();
    
    //*** save error ***
    User activeUser = (User)session.getAttribute("activeUser");
    String sPage = request.getParameter("Page");
    saveError(sError,sPage,activeUser);
%>

