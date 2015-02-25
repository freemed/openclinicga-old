<%@page import="be.openclinic.finance.*,java.util.Vector"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD TODAY WICKETS -----------------------------------------------------------------------
    private String addWaitingTransfers(Vector vWickets, String sWeblanguage, boolean bCanEdit){
        String sReturn = "";

        if(vWickets!=null){
            String sClass = "";
            WicketDebet wicketOps;
            for(int i=0; i<vWickets.size(); i++){
                wicketOps = (WicketDebet)vWickets.elementAt(i);

                if(wicketOps!=null){
                	// alternate row-style
                    if(sClass.equals("")) sClass = "1";
                    else                  sClass = "";
                	
                    sReturn+= "<tr class='list"+sClass+"' onclick=\"setWicketCredit('"+wicketOps.getUid()+"',"+wicketOps.getAmount()+",'"+wicketOps.getComment()+"');\">"+
                               "<td>"+ScreenHelper.stdDateFormat.format(wicketOps.getOperationDate())+"</td>"+
                               "<td>"+wicketOps.getUid()+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(getTran("service",Wicket.get(wicketOps.getWicketUID()).getServiceUID(),sWeblanguage))+"</td>"+
                               "<td>"+wicketOps.getAmount()+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(wicketOps.getComment().toString())+"</td>"+
                              "</tr>";
                }
            }
        }
        
        return sReturn;
    }
%>

<%
    String sEditWicketOperationWicket = checkString(request.getParameter("EditWicketOperationWicket"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*************** financial/wicket/todayWicketCredits.jsp ***************");
    	Debug.println("sEditWicketOperationWicket : "+sEditWicketOperationWicket+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
     
    
    Vector vWicketsToday = WicketCredit.selectWaitingTransfers(sEditWicketOperationWicket);
    Debug.println("--> vWicketsToday : "+vWicketsToday.size());
    
    if(vWicketsToday.size() > 0){
		%>
		<table width="100%" class="list" cellspacing="0" cellpadding="0">
			<tr class='admin'>
				<td colspan='5'><%=getTran("web","waitingWicketTransfers",sWebLanguage) %></td>
			</tr>
		    <tr class="admin">
		        <td><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
		        <td>ID</td>
		        <td><%=HTMLEntities.htmlentities(getTran("web","wicket",sWebLanguage))%></td>
		        <td width="200"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%></td>
		        <td><%=HTMLEntities.htmlentities(getTran("web", "comment", sWebLanguage))%></td>
		    </tr>
		    
		    <tbody class="hand">
				<%=addWaitingTransfers(vWicketsToday,sWebLanguage,activeUser.getAccessRight("financial.superuser.select"))%>
		    </tbody>
		</table>
        <%
    }
%>