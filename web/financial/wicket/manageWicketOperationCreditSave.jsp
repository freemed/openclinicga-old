<%@ page import="be.openclinic.finance.Wicket,be.openclinic.finance.WicketCredit,be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp"   %>
<%
    String sEditWicketOperationUID = checkString(request.getParameter("EditWicketOperationUID"));
    String sEditWicketOperationAmount = checkString(request.getParameter("EditWicketOperationAmount"));
    String sEditWicketOperationType = checkString(request.getParameter("EditWicketOperationType"));
    String sEditWicketOperationComment = checkString(request.getParameter("EditWicketOperationComment"));
    String sEditWicketOperationWicket = checkString(request.getParameter("EditWicketOperationWicket"));
    String sEditWicketOperationDate = checkString(request.getParameter("EditWicketOperationDate"));

    WicketCredit wicketOp = new WicketCredit();

    if (sEditWicketOperationUID.length() > 0) {
        wicketOp = WicketCredit.get(sEditWicketOperationUID);
    } else {
        wicketOp.setCreateDateTime(getSQLTime());
    }
    wicketOp.setOperationDate(getSQLTime());
    try{
        wicketOp.setOperationDate(new Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(sEditWicketOperationDate).getTime()));
    }
    catch(Exception e){};
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
//            sEditWicketOperationUID = wicketOp.getUid();

    String sMessage = HTMLEntities.htmlentities(getTran("web", "dataissaved", sWebLanguage));
%>
{
"Message":"<%=sMessage%>"
}