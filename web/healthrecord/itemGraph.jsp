<%@page import="java.util.*,
                be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc,
                be.mxs.common.model.vo.healthrecord.IConstants"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<html>
<script>var _PathToScript="<c:url value='/_common/_script/'/>";</script>
<%=sJSDIAGRAM2%>
<%=sCSSNORMAL%>
<HEAD><TITLE><%=getTran("Web.Occup","medwan.occupational-medicine.getgraph",sWebLanguage)%></TITLE></HEAD>
<body title="<%=getTran("Web.Occup","medwan.common.click-for-history",sWebLanguage)%>" onclick="window.location.href='<c:url value="/healthrecord/itemHistory.jsp"/>?itemType=<%=request.getParameter("itemType")%>';">
<script>
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
%>

<%
    long maxDate=0;
    long minDate=new java.util.Date().getTime();
    double maxVal=-999999999;
    double minVal=999999999;
    int vals=0;
    String sUnits="";
    String sVal="";
    String format="";
    if(request.getParameter("itemType").indexOf("MEDIDOC")>-1){
        format="MEDIDOC_";
    }
    Vector items=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),request.getParameter("itemType"));
    Vector items2=null;
    Hashtable itemsDouble=null;
    if(IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT.equalsIgnoreCase(request.getParameter("itemType"))){
        items2=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT);
    }
    else if(IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT.equalsIgnoreCase(request.getParameter("itemType"))){
        items2=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT);
    }
    else if(IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT.equalsIgnoreCase(request.getParameter("itemType"))){
        items2=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT);
    }
    else if(IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT.equalsIgnoreCase(request.getParameter("itemType"))){
        items2=MedwanQuery.getInstance().getItemHistory((SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() )).getHealthRecordVO().getHealthRecordId().intValue(),IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT);
    }
    if(items2!=null){
        itemsDouble=new Hashtable();
        for (int n=0;n<items2.size();n++){
            ItemVO item = (ItemVO)items2.get(n);
            itemsDouble.put(item.getDate(),item);
        }
    }

    MessageReader messageReader = new MessageReaderMedidoc();
    for (int n=0;n<items.size();n++){
        try {
            sVal=((ItemVO)items.get(n)).getValue();
            if(((ItemVO)items.get(n)).getType().startsWith("be.mxs.common.model.vo.healthrecord.IConstants.EXT_") && sVal.indexOf("|")>-1){
                //This is Lab information
                Item labItem = new Item();
                messageReader.lastline=sVal;
                labItem.type=messageReader.readField("|");
                if(labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
                    labItem.comment=messageReader.readField("|");
                }
                else if(labItem.type.equalsIgnoreCase("N")||labItem.type.equalsIgnoreCase("D")||labItem.type.equalsIgnoreCase("H")||labItem.type.equalsIgnoreCase("M")||labItem.type.equalsIgnoreCase("S")){
                    labItem.modifier=messageReader.readField("|");
                    labItem.result=messageReader.readField("|");
                    labItem.unit=messageReader.readField("|");
                    sUnits=labItem.unit;
                    labItem.normal=messageReader.readField("|");
                    labItem.time=messageReader.readField("|");
                    labItem.comment=messageReader.readField("|");
                }
                sVal = labItem.result;
            }
            double val = Double.parseDouble(sVal);
            if(val>maxVal){
                maxVal=val;
            }
            if(val<minVal){
                minVal=val;
            }
            if(itemsDouble!=null && itemsDouble.get(((ItemVO)items.get(n)).getDate())!=null){
                ItemVO item = (ItemVO)itemsDouble.get(((ItemVO)items.get(n)).getDate());
                val = Double.parseDouble(item.getValue());
                if(val>maxVal){
                    maxVal=val;
                }
                if(val<minVal){
                    minVal=val;
                }
            }
            long date = ((ItemVO)items.get(n)).getDate().getTime();
            if(date<minDate){
                minDate=date;
            }
            if(date>maxDate){
                maxDate=date;
            }
            vals++;
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }
    if(vals>1 && minDate!=maxDate){
        double minRef=0;
        double maxRef=0;
        if(minVal<0){
            minRef=-Math.pow(10,Math.ceil(Math.log(-minVal)/Math.log(10)));
        }
        else if(minVal>0){
            minRef=Math.pow(10,Math.floor(Math.log(minVal)/Math.log(10)));
        }
        else {
            minRef=0;
        }
        if(maxVal<0){
            maxRef=-Math.pow(10,Math.floor(Math.log(-maxVal)/Math.log(10)));
        }
        else if(maxVal>0){
            maxRef=Math.pow(10,Math.ceil(Math.log(maxVal)/Math.log(10)));
        }
        else {
            maxRef=0;
        }
        if(maxRef>0){
            while (maxRef>maxVal*2){
                maxRef/=2;
            }
        }
        else if(maxRef<0){
            while (maxRef>maxVal/2){
                maxRef*=2;
            }
        }
        if(minRef<0){
            while(minRef<minVal*2){
                minRef/=2;
            }
        }
    %>
    
function formMonth(millis){
    dDate=new Date(millis);
    return dDate.getDate()+"/"+(dDate.getMonth()+1)+"/"+new String(dDate.getFullYear()).substr(Math.min(new String(dDate.getFullYear()).length-2,2),2);
}
function formDay(millis){
    dDate=new Date(millis);
    return dDate.getDate()+"/"+(dDate.getMonth()+1);
}

interval=0;
var D=new Diagram();
D.SetFrame(40, 20, 360, 180);
D.SetBorder(new Date(<%=minDate%>),new Date(<%=maxDate%>),<%=minRef%>,<%=maxRef%>);
if(<%=maxDate-minDate%>>2678400000*3){
    D.XScale="function formMonth";
    interval=2678400000;
}
else if(<%=maxDate-minDate%>>86400000*3){
    D.XScale="function formMonth";
    interval=86400000;
}
else {
    D.XScale="2";
}
D.YScale="1";
<%
    if(sUnits.length()>0){
        out.print("D.SetText('','','"+getTran("TRANSACTION_TYPE_LAB_RESULT",request.getParameter("itemType"),sWebLanguage)+" ("+getTran("TRANSACTION_TYPE_LAB_RESULT","be.mxs.common.model.vo.healthrecord.IConstants.EXT_"+format+"UNIT_"+sUnits,sWebLanguage)+")')");
    }
    else if(itemsDouble!=null){
        out.print("D.SetText('','','"+getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)+" "+(request.getParameter("itemType").indexOf("RIGHT")>-1?getTran("Web.Occup","medwan.common.right",sWebLanguage):getTran("Web.Occup","medwan.common.left",sWebLanguage))+" (mmHg)')");
    }
%>
D.XSubGrids=1;
D.YSubGrids=1;
D.GetXGrid();
D.XGridDelta=<%=maxDate-minDate%>/Math.min(8,Math.floor(<%=maxDate-minDate%>/interval));
D.Font="font-family:arial;font-weight:normal;font-size:6pt;line-height:22pt;"
D.Draw("#FFFFFF", "#000000", false, "", "", "#DDDDFF","#CCCCCC");
    <%
        double oldval=0;
        long olddate=0;
        ItemVO oldItem=null;
        for (int n=0;n<items.size();n++){
            try {
                sVal=((ItemVO)items.get(n)).getValue();
                if(((ItemVO)items.get(n)).getType().startsWith("be.mxs.common.model.vo.healthrecord.IConstants.EXT_") && sVal.indexOf("|")>-1){
                    //This is Lab information
                    Item labItem = new Item();
                    messageReader.lastline=sVal;
                    labItem.type=messageReader.readField("|");
                    if(labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
                        labItem.comment=messageReader.readField("|");
                    }
                    else if(labItem.type.equalsIgnoreCase("N")||labItem.type.equalsIgnoreCase("D")||labItem.type.equalsIgnoreCase("H")||labItem.type.equalsIgnoreCase("M")||labItem.type.equalsIgnoreCase("S")){
                        labItem.modifier=messageReader.readField("|");
                        labItem.result=messageReader.readField("|");
                        labItem.unit=messageReader.readField("|");
                        labItem.normal=messageReader.readField("|");
                        labItem.time=messageReader.readField("|");
                        labItem.comment=messageReader.readField("|");
                    }
                    sVal = labItem.result;
                }
                double val = Double.parseDouble(sVal);
                long date = ((ItemVO)items.get(n)).getDate().getTime();
                out.print("new Dot(D.ScreenX(new Date("+date+")),D.ScreenY("+val+"),5,2,'black');");
                ItemVO doubleItem=null;
                if(itemsDouble!=null && itemsDouble.get(((ItemVO)items.get(n)).getDate())!=null){
                    doubleItem=(ItemVO)itemsDouble.get(((ItemVO)items.get(n)).getDate());
                }
                if(doubleItem!=null){
                    out.print("new Dot(D.ScreenX(new Date("+doubleItem.getDate().getTime()+")),D.ScreenY("+Double.parseDouble(doubleItem.getValue())+"),5,2,'black');");
                }
                if(olddate!=0){
                    out.print("new Line(D.ScreenX(new Date("+olddate+")),D.ScreenY("+oldval+"),D.ScreenX(new Date("+date+")),D.ScreenY("+val+"),'darkblue',2,'History');");
                    if(doubleItem!=null && oldItem!=null){
                        out.print(new StringBuffer().append("new Line(D.ScreenX(new Date(").append(oldItem.getDate().getTime()).append(")),D.ScreenY(").append(Double.parseDouble(oldItem.getValue())).append("),D.ScreenX(new Date(").append(doubleItem.getDate().getTime()).append(")),D.ScreenY(").append(new Double(doubleItem.getValue()).doubleValue()).append("),'darkred',2,'History');").toString());
                    }
                }
                if(doubleItem!=null){
                    oldItem=doubleItem;
                }
                olddate=date;
                oldval=val;
            }
            catch (Exception e){
                e.printStackTrace();
            }
        }
    }
    else {
        if(vals<=1){
            out.print("</script><div class='text'>"+getTran("Web.Occup","medwan.common.not-enough-measurements",sWebLanguage)+"</div><script>");
        }
        else {
            out.print("</script><div class='text'>"+getTran("Web.Occup","medwan.common.all-measurements-on-same-date",sWebLanguage)+"</div><script>");
        }
    }
%>

window.focus();
</script>
</body>
</html>