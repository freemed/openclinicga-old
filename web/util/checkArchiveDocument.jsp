<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=MedwanQuery.getInstance().getItem(Integer.parseInt(request.getParameter("tranid").split("\\.")[0]), Integer.parseInt(request.getParameter("tranid").split("\\.")[1]), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_STORAGENAME")!=null%>