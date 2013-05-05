<%@include file="/includes/validateUser.jsp"%>
<table>
	<tr><td class='admin'>Sessions</td><td class='admin2'><%=MedwanQuery.getInstance().getSessions().size() %></td></tr>
	<tr><td class='admin'>Activities</td><td class='admin2'><%=MedwanQuery.getInstance().getActivities().size() %></td></tr>
	<tr><td class='admin'>Config</td><td class='admin2'><%=MedwanQuery.getInstance().getConfig().size() %></td></tr>
	<tr><td class='admin'>Labels</td><td class='admin2'><%=MedwanQuery.getInstance().getLabels().size() %></td></tr>
	<tr><td class='admin'>LabelsCache</td><td class='admin2'><%=MedwanQuery.getInstance().getLabelsCache().size() %></td></tr>
	<tr><td class='admin'>LabelsCacheDates</td><td class='admin2'><%=MedwanQuery.getInstance().getLabelsCacheDates().size() %></td></tr>
	<tr><td class='admin'>SessionValues</td><td class='admin2'><%=MedwanQuery.getInstance().getSessionValues().size() %></td></tr>
	<tr><td class='admin'>ObjectCache</td><td class='admin2'><%=MedwanQuery.getInstance().getObjectCache().size() %></td></tr>
	<tr><td class='admin'>UsedCounters</td><td class='admin2'><%=MedwanQuery.getInstance().getUsedCounters().size() %></td></tr>
	<tr><td class='admin'>UsedCounters</td><td class='admin2'><%=MedwanQuery.getInstance().getUsedCounters().size() %></td></tr>
	<tr><td class='admin'>ProgressValues</td><td class='admin2'><%=MedwanQuery.getInstance().getProgressValues().size() %></td></tr>
	<tr><td class='admin'>ServiceExaminations</td><td class='admin2'><%=MedwanQuery.getInstance().getServiceexaminations().size() %></td></tr>
	<tr><td class='admin'>ServiceExaminationsIncludingParents</td><td class='admin2'><%=MedwanQuery.getInstance().getServiceexaminationsincludingparent().size() %></td></tr>
	<tr><td class='admin'>DatecenterParameterTypes</td><td class='admin2'><%=MedwanQuery.getInstance().getDatacenterparametertypes().size() %></td></tr>
	<tr><td class='admin'>CountersInUse</td><td class='admin2'><%=MedwanQuery.getInstance().getCountersInUse().size() %></td></tr>
</table>