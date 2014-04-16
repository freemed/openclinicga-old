<%@page import="java.util.*,
                be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private class Item{
        public String id = "";
        public String type = "";
        public String modifier = "";
        public String result = "";
        public String unit = "";
        public String normal = "";
        public String comment = "";
        public String time;
        public Hashtable name = new Hashtable();
        public Hashtable unitname = new Hashtable();
    }
%>
<%=sCSSNORMAL%>

<body title="<%=getTran("Web.Occup","medwan.common.click-for-graph",sWebLanguage)%>" onclick="window.location.href='<c:url value="/healthrecord/itemGraph.jsp"/>?itemType=<%=request.getParameter("itemType")%>';">
<%
    String format = "";
    if (request.getParameter("itemType").indexOf("MEDIDOC")>-1){
        format = "MEDIDOC_";
    }

    Vector items=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),request.getParameter("itemType"));
    String sVal = "", sType = "", sUnits = "", sHTML = "";
    int vals = 0;

    MessageReader messageReader = new MessageReaderMedidoc();
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");

    for (int n=0; n<items.size(); n++){
        vals++;
        sVal  = ((ItemVO)items.get(n)).getValue();
        sType = ((ItemVO)items.get(n)).getType();

        if(sType.startsWith("be.mxs.common.model.vo.healthrecord.IConstants.EXT_") && sVal.indexOf("|")>-1){
            // This is Lab information
            Item labItem = new Item();
            messageReader.lastline = sVal;
            labItem.type = messageReader.readField("|");

            if (labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
                labItem.comment = messageReader.readField("|");
            }
            else if (labItem.type.equalsIgnoreCase("N") || labItem.type.equalsIgnoreCase("D") ||
                     labItem.type.equalsIgnoreCase("H") || labItem.type.equalsIgnoreCase("M") ||
                     labItem.type.equalsIgnoreCase("S")){
                labItem.modifier = messageReader.readField("|");
                labItem.result = messageReader.readField("|");
                labItem.unit = messageReader.readField("|");
                sUnits = labItem.unit;
                labItem.normal = messageReader.readField("|");
                labItem.time = messageReader.readField("|");
                labItem.comment = messageReader.readField("|");
            }

            sVal = labItem.result+"&nbsp;"+labItem.normal;
        }
        else if(sType.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ANAMNESE_STRESS")){
            // convert 0,1,2,3,4 to "","+","++","+++","0"
                 if(sVal.equals("0")) sVal = "";
            else if(sVal.equals("1")) sVal = "+";
            else if(sVal.equals("2")) sVal = "++";
            else if(sVal.equals("3")) sVal = "+++";
            else if(sVal.equals("4")) sVal = "0";
        }
        else {
            sVal = getTranNoLink("Web.Occup",sVal,sWebLanguage);
        }

        sHTML+="<tr class='list'><td width='70'>"+dateFormat.format(((ItemVO)items.get(n)).getDate())+"</td><td>"+sVal+"</td></tr>";
    }
%>

<%
    if (sUnits.length()>0){
        out.print(getTran("TRANSACTION_TYPE_LAB_RESULT",request.getParameter("itemType"),sWebLanguage)+" ("+getTran("TRANSACTION_TYPE_LAB_RESULT","be.mxs.common.model.vo.healthrecord.IConstants.EXT_"+format+"UNIT_"+sUnits,sWebLanguage)+")");
    }
    else if (vals<1){
        out.print("<div class='text'>"+getTran("Web.Occup","medwan.common.no-measurements",sWebLanguage)+"</div>");
    }
%>

<table class="list" width="100%" cellspacing="1" cellpadding="0">
    <tr class="admin"><td colspan="2"><%=getTran("web","history",sWebLanguage)%></td></tr>
    <%=sHTML%>
</table>
<br/>
<center>
    <input type="button" class="button" value="<%=getTran("web","close",sWebLanguage)%>" onclick="window.close()">
</center>
<script>
  window.focus();
</script>
</body>
