<%@page import="be.openclinic.finance.InsurarCredit,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.finance.InsurarInvoice,
                be.openclinic.finance.ExtraInsurarInvoice"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- ADD CREDITS -----------------------------------------------------------------------------
    private String addCredits(Vector vCredits, String sClass, boolean bChecked, String sWebLanguage){
        String sReturn = "";

        if(vCredits!=null){
            String sInsurarCreditUID;
            InsurarCredit insurarcredit;
            String sChecked = "";
            if(bChecked){
                sChecked = " checked";
            }

            for(int i=0; i<vCredits.size(); i++){
                sInsurarCreditUID = checkString((String)vCredits.elementAt(i));

                if(sInsurarCreditUID.length() > 0){
                    insurarcredit = InsurarCredit.get(sInsurarCreditUID);

                    if(insurarcredit!=null){
                    	// alternate row-style
                        if(sClass.equals((""))) sClass = "1";
                        else                    sClass = "";

                        sReturn+= "<tr class='list"+sClass+"'>"+
                                   "<td><input type='checkbox' name='cbInsurarInvoice"+insurarcredit.getUid()+"="+insurarcredit.getAmount()+"' onclick='doBalance(this, false)'"+sChecked+"></td>"+
                                   "<td>"+ScreenHelper.getSQLDate(insurarcredit.getDate())+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(getTran("credit.type", checkString(insurarcredit.getType()), sWebLanguage))+"</td>"+
                                   "<td>"+insurarcredit.getAmount()+"</td>"+
                                  "</tr>";
                    }
                }
            }
        }
        
        return sReturn;
    }
%>
<table width="100%" cellspacing="1" cellpadding="0">
    <tr class="gray">
        <td width="20"/>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td width="50%"><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
    </tr>
<%
    String sEditInsurarInvoiceUID = checkString(request.getParameter("EditInsurarInvoiceUID"));
    String sClass = "";
    ExtraInsurarInvoice insurarInvoice = null;
    Vector vInsurarCredits = new Vector(), vUnassignedCredits = new Vector();

    if(sEditInsurarInvoiceUID.length() > 0){
        insurarInvoice = ExtraInsurarInvoice.get(sEditInsurarInvoiceUID);
        vInsurarCredits = insurarInvoice.getCredits();
        out.print(addCredits(vInsurarCredits,sClass,true,sWebLanguage));
    }

    if((insurarInvoice == null) || (!(checkString(insurarInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(insurarInvoice.getStatus()).equalsIgnoreCase("canceled")))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        vUnassignedCredits = InsurarCredit.getUnassignedInsurarCredits(sInsurarUid);
        out.print(addCredits(vUnassignedCredits,sClass,false,sWebLanguage));
    }
    
   	out.print("<tr><td colspan='4'>"+(vInsurarCredits.size()+vUnassignedCredits.size())+" "+getTranNoLink("web","records.loaded",sWebLanguage)+"</td></tr>");
%>
</table>