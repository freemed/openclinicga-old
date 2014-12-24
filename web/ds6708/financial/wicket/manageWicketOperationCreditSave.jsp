<%@page import="be.openclinic.finance.Wicket,
                be.openclinic.finance.WicketCredit,
                be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sEditWicketOperationUID     = checkString(request.getParameter("EditWicketOperationUID")),
           sEditWicketOperationAmount  = checkString(request.getParameter("EditWicketOperationAmount")),
           sEditWicketOperationType    = checkString(request.getParameter("EditWicketOperationType")),
           sEditWicketOperationComment = checkString(request.getParameter("EditWicketOperationComment")),
           sEditWicketOperationWicket  = checkString(request.getParameter("EditWicketOperationWicket")),
           sEditWicketOperationDate    = checkString(request.getParameter("EditWicketOperationDate"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******** financial/wicket/manageWicketOperationCreditSave.jsp *********"); 
    	Debug.println("sEditWicketOperationUID     : "+sEditWicketOperationUID); 
    	Debug.println("sEditWicketOperationDate    : "+sEditWicketOperationDate); 
    	Debug.println("sEditWicketOperationAmount  : "+sEditWicketOperationAmount); 
    	Debug.println("sEditWicketOperationType    : "+sEditWicketOperationType); 
    	Debug.println("sEditWicketOperationComment : "+sEditWicketOperationComment); 
    	Debug.println("sEditWicketOperationWicket  : "+sEditWicketOperationWicket+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    WicketCredit wicketOp = new WicketCredit();
    if(sEditWicketOperationUID.length() > 0){
        wicketOp = WicketCredit.get(sEditWicketOperationUID);
    }
    else{
        wicketOp.setCreateDateTime(getSQLTime());
    }
    wicketOp.setOperationDate(getSQLTime());
    try{
        wicketOp.setOperationDate(new Timestamp(ScreenHelper.parseDate(sEditWicketOperationDate).getTime()));
    }
    catch(Exception e){
    	// empty    	
    };
    
    wicketOp.setAmount(Double.parseDouble(sEditWicketOperationAmount));
    wicketOp.setComment(new StringBuffer(sEditWicketOperationComment));
    wicketOp.setOperationType(sEditWicketOperationType);
    wicketOp.setUserUID(Integer.parseInt(activeUser.userid));
    wicketOp.setWicketUID(sEditWicketOperationWicket);
    session.setAttribute("defaultwicket",sEditWicketOperationWicket);
    wicketOp.setUpdateDateTime(getSQLTime());
    wicketOp.setUpdateUser(activeUser.userid);
    wicketOp.store();

    Wicket wicket = Wicket.get(sEditWicketOperationWicket);
    wicket.recalculateBalance();

    String sMessage = HTMLEntities.htmlentities(getTran("web","dataissaved",sWebLanguage));
%>
{
"Message":"<%=sMessage%>"
}