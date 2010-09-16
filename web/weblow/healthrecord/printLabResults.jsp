<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                java.util.*,
                be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sDocLanguage = checkString(request.getParameter("DocLanguage"));
    String sTransID = checkString(request.getParameter("TransID"));
    String sServerID = checkString(request.getParameter("ServerID"));

    String [] aTrans = new String[21];
    if (sDocLanguage.toUpperCase().equals("N")) {
        aTrans[0] = "";
        aTrans[1] = "<b>Openwork</b>, erkend onder het nummer <b>12345</b>";
        aTrans[2] = "Pastoriestraat 58, 3370 BOUTERSEM";
        aTrans[3] = "Tel. (016) 72 10 47";
        aTrans[4] = "RESULTATEN LABORATORIUM ANALYSES";
        aTrans[5] = "Werknemer";
        aTrans[6] = "Naam";
        aTrans[7] = "Voornaam";
        aTrans[8] = "Geboortedatum";
        aTrans[9] = "Geslacht";
        aTrans[10] = "Adres";
        aTrans[11] = "Bedrijf";
        aTrans[12] = "Klinisch laboratorium dat de analyses uitvoerde:";
        aTrans[13] = "Referentienummer aanvraag:";
        aTrans[14] = "Aangevraagd door:";
        aTrans[15] = "Datum aanvraag:";
        aTrans[16] = "Naam Geneeskundige Dienst: <b>Openwork</b> ";
        aTrans[17] = "Erkenningsnummer Geneeskundige Dienst: <b>12345</b>";
        aTrans[18] = "Naam van de geneesheer: ";
        aTrans[19] = "Adres:";
        aTrans[20] = "Resultaten afgeleverd door:";


    }
    else {
        aTrans[0] = "";
        aTrans[1] = "<b>Openwork</b>, agréé sous le numéro <b>12345</b>";
        aTrans[2] = "Pastoriestraat 58, 3370 BOUTERSEM";
        aTrans[3] = "Tél. (016) 72 10 47";
        aTrans[4] = "RESULTAT LABORATOIRE";
        aTrans[5] = "Travailleur";
        aTrans[6] = "Nom";
        aTrans[7] = "Prénom";
        aTrans[8] = "Date de naissance";
        aTrans[9] = "Sexe";
        aTrans[10] = "Adresse";
        aTrans[11] = "Entreprise";
        aTrans[12] = "Laboratoire clinique qui a effectué les analyses:";
        aTrans[13] = "Numéro de référence:";
        aTrans[14] = "Demandé par:";
        aTrans[15] = "Date:";
        aTrans[16] = "Nom Service Médical: <b>Openwork</b> ";
        aTrans[17] = "Numéro d'agrément Service Médical: <b>12345</b>";
        aTrans[18] = "Nom du médecin: ";
        aTrans[19] = "Adresse:";
        aTrans[20] = "Résultats fournis par:";
    }
%>

<%
String sImmatNew = "", sGender = "", sLastname = "", sFirstname = "", sDateOfBirth = "", sNatReg = "", sUnit = "",sAddress = "";
if (activePatient!=null){
    sLastname = activePatient.lastname;
    sFirstname = activePatient.firstname;
    sDateOfBirth = activePatient.dateOfBirth;
    sNatReg = checkString(activePatient.getID("natreg").trim());

    AdminPrivateContact apc = ScreenHelper.getActivePrivate(activePatient);
    if (apc!=null){
      sAddress = apc.address+", "+apc.zipcode+" "+apc.city;
    }
    sImmatNew= checkString(activePatient.getID("immatnew").trim());
    if ((sImmatNew.trim().length()==9)&&(sImmatNew.startsWith("44"))) {
        sImmatNew = "44."+sImmatNew.substring(2,7)+"."+sImmatNew.substring(7);
    }

    if(activePatient.gender.equals("M")) {
        sGender = "M";
    }
    else if(activePatient.gender.equals("F")) {
        if(sDocLanguage.equals("N")){
           sGender = "V";
        }else if(sDocLanguage.equals("F")){
            sGender = "F";
        }else{
            sGender = "F";
        }
    }
}
%>

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
    TransactionVO transaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(sServerID), Integer.parseInt(sTransID));
    Vector analyses = new Vector();
    String refLab="";
    String refNum="";
    String format="";

    Iterator iterator = transaction.getItems().iterator();
    ItemVO item;
    while (iterator.hasNext()){
        item = (ItemVO)iterator.next();
        if (item.getType().indexOf("ITEM_TYPE_REFNUM")>-1){
            refNum=item.getValue();
        }
        else if (item.getType().indexOf("ITEM_TYPE_REFLAB")>-1){
            refLab=item.getValue();
        }
        else if (item.getType().indexOf("ITEM_TYPE_FORMAT")>-1){
            format=item.getValue();
        }
        else {
            //Debug.println(item.getPriority());
            analyses.add(item);
        }
    }
%>
<html>
<head>
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <%=sCSSPRINT%>
    <%=sCSSNORMAL%>
    <!-- MeadCo ScriptX Control -->
    <object id="factory" style="display:none" viewastext
    classid="clsid:1663ed61-23eb-11d2-b92f-008048fdd814"
    codebase="<c:url value="/util/cab/"/>ScriptX.cab#Version=6,1,428,2">
    </object>

    <style>
    td.myline {
        border-bottom : 1px solid Black;
        font-size: small;
    }
    </style>

    <script defer>
    function window.onload() {
      factory.printing.header = "";
      factory.printing.footer = "";
      factory.printing.portrait = true;
      factory.printing.leftMargin = 20.0;
      factory.printing.topMargin = 10.0;
      factory.printing.rightMargin = 20.0;
      factory.printing.bottomMargin = 10.0;
      factory.printing.Print(true);
    }
    </script>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
        <td align="center" valign="top" width="1%">
            <img src="<c:url value="/"/><%=sAPPDIR%>_img/logo_print.gif" border="0">
        </td>
        <td>&nbsp;</td>
        <td align="left">
            <%=aTrans[1]%><br>
            <%=aTrans[2]%><br>
            <%=aTrans[3]%><br><br>
            <span style=font-size:16px><b><%=aTrans[4]%></b></span>
        </td>
    </tr>
</table>
<hr>
<table>
    <tr>
        <td><b><%=aTrans[5]%></b>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td><%=aTrans[6]%>:&nbsp;<b><%=sLastname%></b>&nbsp;&nbsp;&nbsp;&nbsp;<%=aTrans[7]%>:&nbsp;<b><%=sFirstname%></b></td>
    </tr>
    <tr>
        <td></td>
        <td><%=aTrans[8]%>:&nbsp;<b><%=sDateOfBirth%></b>&nbsp;&nbsp;&nbsp;&nbsp;<%=aTrans[9]%>:&nbsp;<b><%=sGender%></b></td>
    </tr>
    <tr>
        <td></td>
        <td><%=aTrans[10]%>:&nbsp;<b><%=sAddress%></b><br><br></td>
    </tr>
    <tr>
        <td><b><%=aTrans[11]%></b>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td><%=sUnit%></td>
    </tr>
</table>
<hr>
<table>
    <tr>
        <td><b><%=aTrans[12]%></b></td>
    </tr>
    <tr>
        <td><%=refLab%></td>
    </tr>
</table>
<hr>
<table>
    <tr>
        <td><%=aTrans[13]%></td>
        <td><b><%=refNum%></b></td>
    </tr>
    <tr>
        <td><%=aTrans[14]%></td>
        <td><b><%=transaction.getUser().personVO.firstname+" "+transaction.getUser().personVO.lastname%></b></td>
    </tr>
    <tr>
        <td><%=aTrans[15]%></td>
        <td><b><%=new SimpleDateFormat("dd/MM/yyyy").format(transaction.getUpdateTime())%></b></td>
    </tr>
</table>

<hr>
<br>

<table class="list" width="100%">
<%
    String sValue = "";
    MessageReader messageReader = new MessageReaderMedidoc();
    Item labItem;

    for(int n=0;n<analyses.size();n++){
        item = (ItemVO)analyses.get(n);
        labItem = new Item();
        messageReader.lastline=item.getValue();
        labItem.type=messageReader.readField("|");

        if (labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
            labItem.comment=messageReader.readField("|");
        }
        else if (labItem.type.equalsIgnoreCase("N")||labItem.type.equalsIgnoreCase("D")||labItem.type.equalsIgnoreCase("H")||labItem.type.equalsIgnoreCase("M")||labItem.type.equalsIgnoreCase("S")){
            labItem.modifier=messageReader.readField("|");
            labItem.result=messageReader.readField("|");
            labItem.unit=messageReader.readField("|");
            labItem.normal=messageReader.readField("|");
            labItem.time=messageReader.readField("|");
            labItem.comment=messageReader.readField("|");
            int strLength = labItem.comment.length();
            sValue = labItem.comment.substring(1,strLength);
            labItem.id=item.getType().replaceAll("be.mxs.common.model.vo.healthrecord.IConstants.","");
        }

        if (labItem.type.equalsIgnoreCase("T") || labItem.type.equalsIgnoreCase("C")){
            if (labItem.comment.trim().length()==0){
                out.print("<tr><td class='admin' colspan='7'>"+getTran("TRANSACTION_TYPE_LAB_RESULT",item.getType(),sWebLanguage)+"</td>");
            }
            else {
                out.print("<tr><td class='admin2'>"+getTran("TRANSACTION_TYPE_LAB_RESULT",item.getType(),sWebLanguage)+"</td>");
                out.print("<td class='text' colspan='6'>"+labItem.comment+"</td></tr>");
            }
        }
        else if (labItem.type.equalsIgnoreCase("N")||labItem.type.equalsIgnoreCase("D")||labItem.type.equalsIgnoreCase("H")||labItem.type.equalsIgnoreCase("M")||labItem.type.equalsIgnoreCase("S")){
            out.print("<tr>");
            out.print("<td class='admin2'>"+getTran("TRANSACTION_TYPE_LAB_RESULT",item.getType(),sWebLanguage)+"</td>");
            out.print("<td class='text' width='1%'>"+labItem.modifier+"</td>");
            out.print("<td class='");

            if (labItem.normal.trim().length()>0){
                out.print("textRed");
            }
            else {
                out.print("text");
            }

            out.print("' width='1%'><div "+setRightClick(labItem.id)+">"+labItem.result.trim()+"</div></td>");
            out.print("<td class='text' width='10%'>"+getTran("TRANSACTION_TYPE_LAB_RESULT","be.mxs.common.model.vo.healthrecord.IConstants.EXT_"+format+"UNIT_"+labItem.unit,sWebLanguage)+"</td>");
            out.print("<td class='text' width='1%'>"+labItem.normal+"</td>");
            out.print("<td class='text' width='1%'>"+labItem.time+"</td>");
            out.print("<td class='text'>"+sValue+"</td></tr></div>");
        }
    }
%>
</table>
<br>
<hr>
<table width="100%" border="0">
    <tr>
        <td><b><%=aTrans[20]%></b></td>
    </tr>
    <tr>
        <td>
            <%=aTrans[16]%><br>
            <%=aTrans[17]%><br>
            <%=aTrans[18]%>&nbsp;<b><%=(activeUser.person.lastname+" "+activeUser.person.firstname)%></b><br>
            <%=aTrans[19]%>&nbsp;<b><%=(activeUser.activeService.address+"<br>"+activeUser.activeService.zipcode+" "+activeUser.activeService.city)%></b><br>
        </td>
    </tr>
</table>
<script>
  window.resizeTo(600,420);
</script>
</body>
</html>