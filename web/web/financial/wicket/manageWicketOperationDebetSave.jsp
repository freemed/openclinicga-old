<%@ page import="be.openclinic.finance.WicketDebet, be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.Wicket" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sEditWicketOperationUID = checkString(request.getParameter("EditWicketOperationUID"));
    String sEditWicketOperationAmount = checkString(request.getParameter("EditWicketOperationAmount"));
    String sEditWicketOperationType = checkString(request.getParameter("EditWicketOperationType"));
    String sEditWicketOperationComment = checkString(request.getParameter("EditWicketOperationComment"));
    String sEditWicketOperationWicket = checkString(request.getParameter("EditWicketOperationWicket"));
    String sEditWicketOperationDate = checkString(request.getParameter("EditWicketOperationDate"));

    WicketDebet wicketOp = new WicketDebet();

    if (sEditWicketOperationUID.length() > 0) {
        wicketOp = WicketDebet.get(sEditWicketOperationUID);
    } else {
        wicketOp.setCreateDateTime(getSQLTime());
    }
    wicketOp.setAmount(Double.parseDouble(sEditWicketOperationAmount));
    wicketOp.setComment(new StringBuffer(sEditWicketOperationComment));
    wicketOp.setOperationType(sEditWicketOperationType);
    wicketOp.setOperationDate(getSQLTime());
    try{
        wicketOp.setOperationDate(new Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(sEditWicketOperationDate).getTime()));
    }
    catch(Exception e){};
    wicketOp.setUserUID(Integer.parseInt(activeUser.userid));
    wicketOp.setWicketUID(sEditWicketOperationWicket);
    session.setAttribute("defaultwicket",sEditWicketOperationWicket);
    wicketOp.setUpdateDateTime(getSQLTime());
    wicketOp.setUpdateUser(activeUser.userid);
    wicketOp.store();
    Wicket wicket = Wicket.get(sEditWicketOperationWicket);
    wicket.recalculateBalance();

    String sMessage = HTMLEntities.htmlentities(getTran("web", "dataissaved", sWebLanguage));
%>
{
"Message":"<%=sMessage%>"
}