<%@ page import="be.openclinic.adt.Bed,
                 net.admin.Service,
                 be.openclinic.adt.Encounter,java.util.*" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("adt.urgencybedoverview","select",activeUser)%>

<%!
    private String getItemValue(TransactionVO transaction, String sItemType){
        String sReturn = "";
        ItemVO item = transaction.getItem(sItemType);

        if (item!=null){
            sReturn = checkString(item.getValue());
        }

        return sReturn;
    }
%>

<%=writeTableHeader("web","urgencybedoverview",sWebLanguage,"")%>

<table class="list" width='100%' cellspacing='0' cellpadding="0">
    <%
        String sDivision = "URG";
        Vector vChildServices = Service.getChildIds(sDivision);
        String sServiceID, sServiceName;
        Hashtable hServices = new Hashtable();

        for (int i = 0; i < vChildServices.size(); i++) {
            sServiceID = (String) vChildServices.elementAt(i);
            sServiceName = getTranNoLink("service",sServiceID,sWebLanguage);
            hServices.put(sServiceName, sServiceID);
        }

        Vector vBedsInService;
        Iterator iter;
        Bed bed;
        Encounter encounter;
        Hashtable hOccupiedInfo, hEntrees;
        String sPatientUID,sEncounterUID,sClass, sBedDate, sEncounterOutcome, sOrigin, sProblem, sDestination;
        Vector v = new Vector(hServices.keySet());
        Collections.sort(v);
        Iterator it = v.iterator();
        TransactionVO transaction;

        while (it.hasNext()) {
            sServiceName = (String)it.next();
            sServiceID = (String) hServices.get(sServiceName);
    %>
    <tr class="gray">
        <td colspan="2" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' onclick="toggleDivisionOverview('<%=sServiceID%>');">
            <img id="img_<%=sServiceID%>" src='<c:url value="/"/>_img/minus.png' alt="" border="0"/>
            <%=sServiceName%>
        </td>
    </tr>
    <tr>
        <td width="20"></td>
        <td>
            <table class="menu" width="100%" cellspacing="0" cellpadding="0" id="<%=sServiceID%>">
                <tr class="admin" style="height:16px;">
                    <td><%=getTran("openclinic.chuk","urgency.number.bed",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.name.patient",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.date.hour.entrance",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.origin",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.problem",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.date.hour.leave",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.destination",sWebLanguage)%></td>
                    <td><%=getTran("openclinic.chuk","urgency.died",sWebLanguage)%></td>
                </tr>
                <%
                    vBedsInService = Bed.selectBedsInService(sServiceID);
                    iter = vBedsInService.iterator();
                    hEntrees = new Hashtable();
                    while (iter.hasNext()) {
                        bed = (Bed) iter.next();
                        hOccupiedInfo = bed.isOccupied();
                        sEncounterUID = (String)hOccupiedInfo.get("encounterUid");
                        encounter = Encounter.get(sEncounterUID);
                        if(encounter.getEnd()==null || encounter.getEnd().after(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date())))){
                            if(encounter.getBegin()!=null){
                                hEntrees.put(encounter.getBegin().getTime()+"",bed);
                            }
                            else {
                                hEntrees.put(bed.getUid(),bed);
                            }
                        }
                    }

                    v = new Vector(hEntrees.keySet());
                    Collections.sort(v);
                    iter = v.iterator();
                    sClass = "";

                    while (iter.hasNext()) {
                        if(sClass.equals("")){
                            sClass = "1";
                        }else{
                            sClass = "";
                        }
                        sBedDate = (String) iter.next();

                        bed = (Bed) hEntrees.get(sBedDate);
                        hOccupiedInfo = bed.isOccupied();

                        sPatientUID = (String)hOccupiedInfo.get("patientUid");
                        sEncounterUID = (String)hOccupiedInfo.get("encounterUid");

                        sOrigin = "";
                        sProblem = "";
                        sDestination = "";

                        if (sPatientUID.length()>0){
                            transaction = MedwanQuery.getInstance().getLastTransactionVO(Integer.parseInt(sPatientUID),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_URGENCE_CONSULTATION");

                            if (transaction!=null){
                                transaction = MedwanQuery.getInstance().loadTransaction(transaction.getServerId(),transaction.getTransactionId().intValue());
                                sProblem = getItemValue(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_EVALUATION");
                            }
                        }
                        encounter = Encounter.get(sEncounterUID);

                        if (((Boolean)hOccupiedInfo.get("status")).booleanValue()) {
                            %>
                            <tr style="height:16px;"  class="list<%=sClass%>">
                                <td><%=bed.getName()%></td>
                                <td>
                                    <a href="<c:url value="/main.do"/>?Page=curative/index.jsp&PersonID=<%=sPatientUID%>">
                                    <%
	                                    Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                                        out.print(ScreenHelper.getFullPersonName(sPatientUID,ad_conn));
                                        ad_conn.close();
                                    %>
                                    </a>
                                </td>
                                <td>
                                <%
                                    if(encounter.getBegin()!=null){
                                        out.print(new SimpleDateFormat("yyyy-MM-dd HH:mm").format(encounter.getBegin()));
                                    }
                                %>
                                </td>
                                <td><%=getTran("urgency.origin",encounter.getOrigin(),sWebLanguage)%></td>
                                <td><%=sProblem%></td>
                                <td>
                                <%
                                    if(encounter.getEnd()!=null){
                                        out.print(new SimpleDateFormat("yyyy-MM-dd HH:mm").format(encounter.getEnd()));
                                    }
                                %>
                                </td>
                                <td><%
                                    if(encounter.getDestination()!=null){
                                        out.print(encounter.getDestination().getLabel(sWebLanguage));
                                    }
                                    %>
                                </td>
                                <td>
                                <%
                                    sEncounterOutcome = checkString(encounter.getOutcome());
                                    if (sEncounterOutcome.equalsIgnoreCase("dead")){
                                        %>
                                    <img src="<c:url value='/_img/check.gif'/>"/> 
                                        <%
                                    }
                                %>
                                </td>
                            </tr>
                            <%
                        }
                    }
            %>
                <tr>
        </table>
        </td>
    </tr>
<%
    }
%>
</table>

<script type="text/javascript">
  <%-- TOGGLE DIVISION OVERVIEW --%>
  function toggleDivisionOverview(id){
    var obj    = document.getElementById(id);
    var imgObj = document.getElementById("img_"+id);

    if(obj.style.display == "none"){
      obj.style.display = "block";
      imgObj.src = "<c:url value='/_img/minus.png'/>";
    }
    else{
      obj.style.display = "none";
      imgObj.src = "<c:url value='/_img/plus.png'/>";
    }
  }
</script>