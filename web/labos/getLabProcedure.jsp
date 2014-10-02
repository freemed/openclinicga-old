<%@ page import="be.openclinic.medical.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String name="",minbatchsize="",maxbatchsize="",maxdelayindays="",reagents="",reagentstable="";
	String uid = checkString(request.getParameter("FindLabProcedureUid"));
	if(uid.length()>0){
		LabProcedure procedure = LabProcedure.get(uid);
		if(procedure!=null){
			name=procedure.getName();
			minbatchsize=procedure.getMinBatchSize()+"";
			maxbatchsize=procedure.getMaxBatchSize()+"";
			maxdelayindays=procedure.getMaxDelayInDays()+"";
			for(int n=0;n<procedure.getReagents().size();n++){
				LabProcedureReagent reagent = (LabProcedureReagent)procedure.getReagents().elementAt(n);
				if(reagent.getReagent()!=null){
					if(reagents.length()>0){
						reagents+="$";
					}
					reagents+=reagent.getReagentuid()+"|"+reagent.getQuantity()+"|"+reagent.getReagent().getName()+"|"+reagent.getReagent().getUnit()+"|"+reagent.getConsumptionType();
					reagentstable+="<tr><td width='10%'><img src='_img/icons/icon_delete.gif' onclick='removeReagent(\\\""+reagent.getReagentuid()+"\\\")'/>"+reagent.getReagentuid()+"</td><td width='60%'>"+reagent.getReagent().getName()+"</td><td width='30%'>"+reagent.getQuantity()+" "+reagent.getReagent().getUnit()+" "+getTranNoLink("labprocedure.consumptiontype",checkString(reagent.getConsumptionType()),sWebLanguage)+"</td></tr>";
				}
			}
		}
	}
%>
{
"Name":"<%=name%>",
"MinBatchSize":"<%=minbatchsize%>",
"MaxBatchSize":"<%=maxbatchsize%>",
"MaxDelayInDays":"<%=maxdelayindays%>",
"Reagents":"<%=reagents%>",
"ReagentsTable":"<%=reagentstable%>"
}