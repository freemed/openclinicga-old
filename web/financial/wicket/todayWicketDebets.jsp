<%@page import="be.openclinic.finance.WicketDebet,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.finance.Wicket"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD TODAY WICKETS -----------------------------------------------------------------------
    private String addTodayWickets(Vector vWickets, String sWeblanguage){
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
                	
                    sReturn+= "<tr class='list"+sClass+"' onclick=\"setWicket('"+wicketOps.getUid()+"');\">"+
                               "<td>"+ScreenHelper.stdDateFormat.format(wicketOps.getOperationDate())+"</td>"+
                               "<td>"+wicketOps.getUid()+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(getTran("service",Wicket.get(wicketOps.getWicketUID()).getServiceUID(),sWeblanguage))+"</td>"+
                               "<td>"+HTMLEntities.htmlentities(getTran("debet.type",wicketOps.getOperationType(),sWeblanguage))+"</td>"+
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
		Debug.println("\n*************** financial/wicket/todayWicketDebets.jsp ***************");
		Debug.println("sEditWicketOperationWicket : "+sEditWicketOperationWicket+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
 
	Vector vWicketsToday = WicketDebet.selectWicketOperations(getDate(), ScreenHelper.getDateAdd(getDate(),"1"),"","","",sEditWicketOperationWicket,"OC_WICKET_DEBET_OPERATIONDATE DESC,OC_WICKET_DEBET_OBJECTID DESC");
	Debug.println("--> vWicketsToday : "+vWicketsToday.size());
	
	if(vWicketsToday.size() > 0){
        %>     
		<div style="width:100%;height:250px;border: 0px solid #666666;overflow:auto;">
		    <table width="100%" class="list" cellspacing="0" cellpadding="0">
		        <tr class="admin">
		            <td><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
		            <td>ID</td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","wicket",sWebLanguage))%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("wicket","operation_type",sWebLanguage))%></td>
		            <td width="200"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%></td>
		            <td><%=HTMLEntities.htmlentities(getTran("web","comment",sWebLanguage))%></td>
		        </tr>
		        
		        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
			        <%=addTodayWickets(vWicketsToday,sWebLanguage)%>
		        </tbody>
		    </table>
		</div>
		<%		
	}
%>