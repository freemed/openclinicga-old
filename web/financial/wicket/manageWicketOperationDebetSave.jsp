<%@page import="be.openclinic.finance.WicketDebet,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.finance.Wicket"%>
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
        Debug.println("\n********** financial/wicket/manageWicketOperationDebetSave.jsp *********");
        Debug.println("sEditWicketOperationUID     : "+sEditWicketOperationUID);
        Debug.println("sEditWicketOperationAmount  : "+sEditWicketOperationAmount);
        Debug.println("sEditWicketOperationType    : "+sEditWicketOperationType);
        Debug.println("sEditWicketOperationComment : "+sEditWicketOperationComment);
        Debug.println("sEditWicketOperationWicket  : "+sEditWicketOperationWicket);
        Debug.println("sEditWicketOperationDate    : "+sEditWicketOperationDate+"\n");
    }   
    ///////////////////////////////////////////////////////////////////////////////////////////////

    WicketDebet wicketOp = new WicketDebet();
    if(sEditWicketOperationUID.length() > 0){
        wicketOp = WicketDebet.get(sEditWicketOperationUID);
    }
    else{
        wicketOp.setCreateDateTime(getSQLTime());
    }
    wicketOp.setAmount(Double.parseDouble(sEditWicketOperationAmount));
    wicketOp.setComment(new StringBuffer(sEditWicketOperationComment));
    wicketOp.setOperationType(sEditWicketOperationType);
    wicketOp.setOperationDate(getSQLTime());
    try{
        wicketOp.setOperationDate(new Timestamp(ScreenHelper.parseDate(sEditWicketOperationDate).getTime()));
    }
    catch(Exception e){
    	// empty
    };
    
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