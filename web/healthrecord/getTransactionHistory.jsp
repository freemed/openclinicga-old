<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.system.*"%>

<form name='transactionForm' id='transactionForm' method='post'>
	<input type='hidden' name='transactionid' value='<%=checkString(request.getParameter("transactionid")) %>'/>
	<input type='hidden' name='depth' value='<%=checkString(request.getParameter("depth"))%>'/>
	<input type='hidden' name='transactionversion' id='transactionversion' value='<%=checkString(request.getParameter("transactionversion")) %>'/>
	<input type='hidden' name='nobuttons' value='1'/>
</form>

<table width='100%' class="list" cellpadding="0" cellspacing="1">
    <%-- header --%>
	<tr class='admin'>
		<td width="10%"><%=getTran("web","version",sWebLanguage)%></td>
		<td width="20%"><%=getTran("web","date",sWebLanguage)%></td>
		<td width="70%"><%=getTran("web","user",sWebLanguage)%></td>
	</tr>
<%
	String transactionid = checkString(request.getParameter("transactionid"));

	int depth=20;
	try{
		depth = Integer.parseInt(request.getParameter("depth"));
	}
	catch(Exception e){
		e.printStackTrace();
	}
	
	if(transactionid.split("\\.").length>2){
		int activeversion=0;
		try{
			TransactionVO tran = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(transactionid.split("\\.")[1]), Integer.parseInt(transactionid.split("\\.")[2]));
			if(tran!=null){
				if(request.getParameter("transactionversion")==null || request.getParameter("transactionversion").length()==0){
					activeversion=tran.getVersion();
				}
				else{
					activeversion=Integer.parseInt(request.getParameter("transactionversion"));
				}
				
				String sUserName="";
				for(int n=tran.getVersion();n>0 && n>tran.getVersion()-depth;n--){
					TransactionVO historytran=MedwanQuery.getInstance().loadTransaction(tran.getServerId()+"", tran.getTransactionId()+"", n+"", tran.getServerId()+"");
					if(historytran!=null){
						if(historytran.getVersion()==1){
							sUserName=User.getFullUserName(historytran.getUser().userId+"");
						}
						else {
							sUserName=User.getFullUserName(Pointer.getPointer("TU."+historytran.getServerId()+"."+historytran.getTransactionId()+"."+historytran.getVersion()));
						}
						
						out.println("<tr><td class='admin"+(activeversion==historytran.getVersion()?"":"2")+"'>"+historytran.getVersion()+"</td>"+
						                "<td class='admin"+(activeversion==historytran.getVersion()?"":"2")+"'><a href='javascript:openTransaction("+n+")'>"+ScreenHelper.getSQLTimeStamp(new java.sql.Timestamp(historytran.getTimestamp().getTime()))+"</a></td>"+
						                "<td class='admin"+(activeversion==historytran.getVersion()?"":"2")+"'>"+sUserName+"</td></tr>");
					}
				}
			}
			
			if(request.getParameter("transactionversion")!=null){
				%><tr><td colspan='3'><br><%
						
				SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
				TransactionVO curtran = sessionContainerWO.getCurrentTransactionVO();
				tran=MedwanQuery.getInstance().loadTransaction(tran.getServerId()+"", tran.getTransactionId()+"", request.getParameter("transactionversion"), tran.getServerId()+"");
				sessionContainerWO.setCurrentTransactionVO(tran);
				String sPage=MedwanQuery.getInstance().getForward(tran.getTransactionType());
				if(sPage.indexOf("Page=")>-1){
					sPage=sPage.substring(sPage.indexOf("Page=")+5);
				}
				ScreenHelper.setIncludePage(sPage+"?be.mxs.healthrecord.server_id="+tran.getServerId()+"&be.mxs.healthrecord.transaction_id="+tran.getTransactionId()+"&ts="+getTs(), pageContext);
				sessionContainerWO.setCurrentTransactionVO(curtran);
			}
		}
		catch(Exception e2){
			e2.printStackTrace();
		}
	}
%>
</td>
</tr>
</table>

<div style="text-align:center;padding:10px;">
    <input class="button" type="button" onclick="window.close();" value="<%=getTranNoLink("web","close",sWebLanguage)%>"/>
</div>        

<script>
	function openTransaction(version){
		document.getElementById('transactionversion').value=version;
		document.getElementById('transactionForm').submit();
	}
</script>