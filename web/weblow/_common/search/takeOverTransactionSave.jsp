<%@page import="be.dpms.medwan.common.model.vo.authentication.UserVO"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    UserVO user = MedwanQuery.getInstance().getUser(activeUser.userid);
    sessionContainerWO.setUserVO(user);

    TransactionVO tran = sessionContainerWO.getCurrentTransactionVO();
    tran.setUser(user);
    sessionContainerWO.setCurrentTransactionVO(tran);
%>
<script>window.close();</script>
