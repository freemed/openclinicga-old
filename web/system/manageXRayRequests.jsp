<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","select",activeUser)%>

<%
    // variables
    String sFindResultDate    = checkString(request.getParameter("FindResultDate"));

    String msg = "";
    SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;

    // default search date : one month ago
    if(sFindResultDate.length()==0){
        String showLabResultsSinceDays = MedwanQuery.getInstance().getConfigString("showLabResultsSinceDays","7");
        java.util.Date now = new java.util.Date();
        java.util.Date since = new java.util.Date(now.getTime()-(Long.parseLong(showLabResultsSinceDays)*24*3600*1000));
        sFindResultDate = stdDateFormat.format(since);
    }

    String sResult="";
    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

    if(checkString(request.getParameter("open")).equalsIgnoreCase("true")){
        String sQuery="select t.*,a.firstname,a.lastname,a.personid from Transactions t, Healthrecord h, AdminView a" +
            " where " +
            " t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2'" +
            " and t.healthRecordId=h.healthRecordId" +
            " and h.personid=a.personid" +
            " and t.updateTime>=?" +
            " and not exists(" +
            " select * from Items i " +
            " where " +
            " i.serverid=t.serverid and " +
            " i.transactionId=t.transactionId and" +
            " i.type='be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir2_protocol'" +
            " )  order by t.updateTime DESC";
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sFindResultDate).getTime()));
        ResultSet rs=ps.executeQuery();
        while(rs.next()){
            PreparedStatement ps2=oc_conn.prepareStatement("select * from Items where serverid=? and transactionId=? and type=?");
            ps2.setInt(1,rs.getInt("serverid"));
            ps2.setInt(2,rs.getInt("transactionid"));
            ps2.setString(3,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE");
            ResultSet rs2=ps2.executeQuery();
            String sType="";
            if(rs2.next()){
                sType=getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-"+rs2.getString("value"),sWebLanguage);
            }
            rs2.close();
            ps2.close();
            sResult+="<tr class='list'  onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" onclick='selectTran(\""+rs.getInt("serverid")+"\",\""+rs.getInt("transactionId")+"\")'><td>"+ScreenHelper.stdDateFormat.format(rs.getDate("updateTime"))+"</td><td>"+sType+"</td><td>"+checkString(rs.getString("firstname"))+" "+checkString(rs.getString("lastname"))+"</td></tr>";
        }
        rs.close();
        ps.close();
    }
    else if(checkString(request.getParameter("resultsOnly")).equalsIgnoreCase("true")){
        String sQuery="select t.*,h.personid from Transactions t, Healthrecord h" +
            " where " +
            " t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2'" +
            " and t.healthRecordId=h.healthRecordId" +
            " and h.personid=?" +
            " and t.updateTime>=?" +
            " and exists(" +
            " select * from Items i " +
            " where " +
            " i.serverid=t.serverid and " +
            " i.transactionId=t.transactionId and" +
            " i.type='be.mxs.common.model.vo.healthrecord.iconstants.item_type_mir2_protocol'" +
            " )  order by t.updateTime DESC";
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ps.setInt(1,Integer.parseInt(activePatient.personid));
        ps.setDate(2,new java.sql.Date(ScreenHelper.parseDate(sFindResultDate).getTime()));
        ResultSet rs=ps.executeQuery();
        while(rs.next()){
            TransactionVO tran = MedwanQuery.getInstance().loadTransaction(rs.getInt("serverid"),rs.getInt("transactionid"));
            sResult+="<tr class='list'  onmouseover=\"this.style.cursor='hand';this.className='list_select';\" onmouseout=\"this.style.cursor='default';this.className='list';\" onclick='selectTran(\""+rs.getInt("serverid")+"\",\""+rs.getInt("transactionId")+"\")'><td width='10%'>"+ScreenHelper.stdDateFormat.format(rs.getDate("updateTime"))+"</td><td width='10%'>"+(tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.item_type_mir2_type")!=null?getTran("Web.Occup","medwan.occupational-medicine.medical-imaging-request.type-"+checkString(tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.item_type_mir2_type").getValue()),sWebLanguage):"")+"</td><td width='10%'>"+tran.getUser().getPersonVO().getFirstname()+" "+tran.getUser().getPersonVO().getLastname()+"</td><td>"+(tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.item_type_mir2_protocol")!=null?checkString(tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.item_type_mir2_protocol").getValue()):"")+"</td></tr>";
        }
        rs.close();
        ps.close();
    }
    oc_conn.close();

%>
<form name="searchForm" method="post">
<%-- search table --%>
<table width="100%" class="menu" cellspacing="0" cellpadding="1">
    <tr class="admin">
        <td colspan="4"><%=getTran("web","radiology",sWebLanguage)%></td>
    </tr>
    <tr>
        <td class="admin2" colspan="2" height="22">
            <%-- RESULT DATE --%>
            &nbsp;<%=getTran("Web.manage","labanalysis.cols.resultdate",sWebLanguage)%>&nbsp;
            <%=writeDateField("FindResultDate","transactionForm",sFindResultDate,sWebLanguage)%>&nbsp;

            <%-- buttons --%>
            &nbsp;&nbsp;
            <input class="button" type="button" name="findButton" value="<%=getTran("Web","find",sWebLanguage)%>" onclick="submit();">&nbsp;
            <input class="button" type="button" name="clearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
        </td>
    </tr>
</table>
</form>
<table width="100%">
    <tr class="admin">
        <td><%=getTran("web","date",sWebLanguage)%></td>
        <td><%=getTran("web","examinationtype",sWebLanguage)%></td>
        <td><%=getTran("web","user",sWebLanguage)%></td>
        <td><%=getTran("web","protocol",sWebLanguage)%></td>
    </tr>
    <%=sResult%>
</table>
<script>
    function selectTran(serverid,transactionid){
        window.location.href="<c:url value="/util/quickSelectTransaction.jsp"/>?serverid="+serverid+"&transactionid="+transactionid;
    }
</script>