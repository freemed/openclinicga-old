<%@ page import="be.mxs.common.util.io.MessageReader,
                 be.mxs.common.util.io.MessageReaderMedidoc,
                 be.mxs.common.model.vo.healthrecord.TransactionVO,
                 be.mxs.common.util.db.MedwanQuery,
                 java.text.SimpleDateFormat,
                 be.mxs.common.model.vo.healthrecord.ItemVO,
                 java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%!
    private class Item{
        public String id="";
        public String type="";
        public String modifier="";
        public String result="";
        public String unit="";
        public String normal="";
        public String comment="";
        public String time;
        public Hashtable name=new Hashtable();
        public Hashtable unitname=new Hashtable();
    }

    private TransactionVO findTransaction(Vector transactions,String id){
        try{
            MessageReader messageReader = new MessageReaderMedidoc();
            messageReader.lastline=id;
            messageReader.readField(".");
            int serverId = new Integer(messageReader.readField(".")).intValue();
            int transactionId = Integer.parseInt(messageReader.readField("."));

            TransactionVO transactionVO;
            for(int n=0;n<transactions.size();n++){
                transactionVO = (TransactionVO)transactions.get(n);
                if (transactionVO.getServerId()==serverId && transactionVO.getTransactionId().intValue()==transactionId){
                    return transactionVO;
                }
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
        return null;
    }

%>
<table width='100%'>
<%
    String format="";

    Vector transactions = new Vector();
    MessageReader messageReader = new MessageReaderMedidoc();
    Enumeration enumeration = request.getParameterNames();
    SortedSet set = new TreeSet();
    String name;
    int serverId, transactionId;
    TransactionVO transaction;
    while (enumeration.hasMoreElements()){
        name=(String)enumeration.nextElement();
        if (name.startsWith("cb")){
            messageReader.lastline=request.getParameter(name);
            serverId= Integer.parseInt(messageReader.readField("."));
            transactionId= Integer.parseInt(messageReader.readField("."));
            transaction = MedwanQuery.getInstance().loadTransaction(serverId,transactionId);
            transactions.add(transaction);
            set.add(name+"."+request.getParameter(name));
        }
    }
    //Now create a results grid
    //First output the Dates
    out.print("<tr><td/><td width='1%'/>");
    Iterator iterator = set.iterator();
    TransactionVO transactionVO;
    while (iterator.hasNext()){
        transactionVO = (findTransaction(transactions,(String)iterator.next()));
        out.print("<td class='menuItem'><b>"+new SimpleDateFormat("dd/MM/yyyy").format(transactionVO.getUpdateTime())+"</b></td>");
    }
    out.print("<td/></tr>");
    //Then output the Users
    out.print("<tr><td/><td width='1%'/>");
    iterator = set.iterator();
    while (iterator.hasNext()){
        transactionVO = (findTransaction(transactions,(String)iterator.next()));
        out.print("<td class='menuItem'>"+transactionVO.getUser().getPersonVO().firstname+" "+transactionVO.getUser().getPersonVO().lastname+"</td>");
    }
    out.print("<td/></tr>");
    Hashtable headers=new Hashtable();
    Hashtable values = new Hashtable();
    Vector headerVector = new Vector();
    Iterator items;
    iterator = set.iterator();
    String activeGroup;
    ItemVO item;
    Item labItem;
    Hashtable group;
    while (iterator.hasNext()){
        transactionVO = (findTransaction(transactions,(String)iterator.next()));
        items = transactionVO.getItems().iterator();
        activeGroup="";
        while (items.hasNext()){
            item = (ItemVO)items.next();
            if (item.getType().startsWith("be.mxs.common.model.vo.healthrecord.IConstants.EXT_") && item.getType().indexOf("ITEM_TYPE_REF")==-1){
                messageReader.lastline=item.getValue();
                labItem = new Item();
                labItem.id=item.getType();
                labItem.type=messageReader.readField("|");
                if (labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
                    labItem.comment=messageReader.readField("|");
                    if (labItem.comment.trim().length()==0){
                        activeGroup=labItem.id;
                    }
                    else {
                        group = null;
                        if (headers.get(activeGroup)==null){
                            group = new Hashtable();
                            headers.put(activeGroup,group);
                            headers.put("Vector."+activeGroup,new Vector());
                            headerVector.add(activeGroup);
                        }
                        else {
                            group = (Hashtable)headers.get(activeGroup);
                        }
                        if (group.get(labItem.id)==null){
                            group.put(labItem.id,labItem);
                            ((Vector)headers.get("Vector."+activeGroup)).add(labItem);
                            values.put(labItem.id,new Hashtable());
                        }
                        ((Hashtable)values.get(labItem.id)).put(transactionVO.getServerId()+"."+transactionVO.getTransactionId(),labItem);
                    }
                }
                else if (labItem.type.equalsIgnoreCase("N")||labItem.type.equalsIgnoreCase("D")||labItem.type.equalsIgnoreCase("H")||labItem.type.equalsIgnoreCase("M")||labItem.type.equalsIgnoreCase("S")){
                    labItem.modifier=messageReader.readField("|");
                    labItem.result=messageReader.readField("|");
                    labItem.unit=messageReader.readField("|");
                    labItem.normal=messageReader.readField("|");
                    labItem.time=messageReader.readField("|");
                    labItem.comment=messageReader.readField("|");
                    group = null;
                    if (headers.get(activeGroup)==null){
                        group = new Hashtable();
                        headers.put(activeGroup,group);
                        headers.put("Vector."+activeGroup,new Vector());
                        headerVector.add(activeGroup);
                    }
                    else {
                        group = (Hashtable)headers.get(activeGroup);
                    }
                    if (group.get(labItem.id)==null){
                        group.put(labItem.id,labItem);
                        ((Vector)headers.get("Vector."+activeGroup)).add(labItem);
                        values.put(labItem.id,new Hashtable());
                    }
                    ((Hashtable)values.get(labItem.id)).put(transactionVO.getServerId()+"."+transactionVO.getTransactionId(),labItem);
                }
            }
        }
    }
    String sGroup;
    Vector groupVector;
    for (int n=0;n<headerVector.size();n++){
        sGroup = (String)headerVector.get(n);
        groupVector=(Vector)headers.get("Vector."+sGroup);
        out.print("<tr><td class='admin' colspan='"+(2+transactions.size())+"'>"+getTran("TRANSACTION_TYPE_LAB_RESULT",sGroup,sWebLanguage)+"</td>");
        for (int i=0;i<groupVector.size();i++){
            labItem = (Item)groupVector.get(i);
            out.print("<tr><td class='menuItem'>"+getTran("TRANSACTION_TYPE_LAB_RESULT",labItem.id,sWebLanguage)+"</td>");
            if (labItem.id.indexOf("MEDIDOC")>-1){
                format="MEDIDOC_";
            }
            if (labItem.unit.length()>0){
                out.print("<td class='text'>"+getTran("TRANSACTION_TYPE_LAB_RESULT","be.mxs.common.model.vo.healthrecord.IConstants.EXT_"+format+"UNIT_"+labItem.unit,sWebLanguage)+"</td>");
            }
            else {
                out.print("<td/>");
            }
            iterator = set.iterator();
            while (iterator.hasNext()){
                transactionVO = (findTransaction(transactions,(String)iterator.next()));
                if (((Hashtable)values.get(labItem.id)).get(transactionVO.getServerId()+"."+transactionVO.getTransactionId())!=null){
                    out.print("<td "+setRightClickMini(labItem.id.replaceAll("be.mxs.common.model.vo.healthrecord.IConstants.",""))+" class='"+(((Item)((Hashtable)values.get(labItem.id)).get(transactionVO.getServerId()+"."+transactionVO.getTransactionId())).normal.length()>0?"textRed":"text")+"'>"+((Item)((Hashtable)values.get(labItem.id)).get(transactionVO.getServerId()+"."+transactionVO.getTransactionId())).modifier.trim()+((Item)((Hashtable)values.get(labItem.id)).get(transactionVO.getServerId()+"."+transactionVO.getTransactionId())).result+" "+((Item)((Hashtable)values.get(labItem.id)).get(transactionVO.getServerId()+"."+transactionVO.getTransactionId())).normal+" "+((Item)((Hashtable)values.get(labItem.id)).get(transactionVO.getServerId()+"."+transactionVO.getTransactionId())).comment+"</td>");
                }
                else {
                    out.print("<td/>");
                }
            }
            out.print("</tr>");
        }
    }
%>
</table>
<INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="history.go(-1);return false;">
