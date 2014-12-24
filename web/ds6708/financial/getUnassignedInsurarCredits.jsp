<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));

    //--- ADD UNASSIGNED CREDITS ------------------------------------------------------------------
    private String addUnassignedCredits(Vector vCredits, String sWebLanguage){
    	String sHtml = "";
        String sClass = "";
        
        try{
	        if(vCredits != null){
	            InsurarCredit credit;
	            String sCreditUid, sCreditType;
	            Hashtable hSort = new Hashtable();
	            String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
	            DecimalFormat deciLong = new DecimalFormat("###,###,###,###");
	            
	            for(int i=0; i<vCredits.size(); i++){
	                sCreditUid = checkString((String)vCredits.elementAt(i));
	
	                if(sCreditUid.length() > 0){
	                    credit = InsurarCredit.get(sCreditUid);
	                    String insurar = "";
	
	                    if(credit!=null){
	                        //insurar
	                        insurar = Insurar.get(credit.getInsurarUid()).getName();
	                        
	                        // type
	                        if(checkString(credit.getType()).length() > 0){
	                            sCreditType = getTranNoLink("credit.type",credit.getType(),sWebLanguage);
	                        }
	                        else{
	                            sCreditType = "";
	                        }
	                        
	                        String invoiceref = "-";
	                        if(ScreenHelper.checkString(credit.getInvoiceUid()).length() > 0){
	                            InsurarInvoice invoice = InsurarInvoice.get(credit.getInvoiceUid());
	                            if(invoice!=null && invoice.getUid()!=null && invoice.getUid().length()>0 && invoice.getUid().split("\\.").length==2){
	                            	invoiceref = invoice.getUid().split("\\.")[1]+" ("+(invoice.getBalance()==0?"0 ":deciLong.format(-invoice.getBalance())+" ")+MedwanQuery.getInstance().getConfigString("currency", "EUR")+")";
	                            }
	                        }
	                        
	                        String wicketUid = "", wicketName = "";
	                        WicketCredit wicketCredit = WicketCredit.getByReferenceUid(credit.getUid(),"InsurarCredit");
	                        if(wicketCredit!=null && wicketCredit.getUid()!=null && wicketCredit.getUid().length()>1){
	                            wicketUid = wicketCredit.getWicketUID();
	                            Wicket wicket = Wicket.get(wicketUid);
	                            if(wicket!=null && wicket.getService()!=null){
	                            	wicketName = checkString(wicket.getService().getLabel(sWebLanguage));
	                            }
	                        }
	
	                        hSort.put(credit.getDate().getTime()+"="+credit.getUid(),
	                                  " onclick=\"selectCredit('"+credit.getUid()+"','"+ScreenHelper.formatDate(credit.getDate())+"','"+credit.getAmount()+"','"+credit.getType()+"','"+HTMLEntities.htmlentities(credit.getComment())+"','"+checkString(credit.getInvoiceUid())+"','"+wicketUid+"');\">"+
	                                   "<td>"+ScreenHelper.formatDate(credit.getDate())+"</td>"+
	                                   "<td align='right'>"+priceFormat.format(credit.getAmount())+"&nbsp;"+sCurrency+"&nbsp;&nbsp;</td>"+
	                                   "<td>"+HTMLEntities.htmlentities(insurar)+"</td>"+
	                                   "<td>"+HTMLEntities.htmlentities(sCreditType)+"</td>"+
	                                   "<td>"+HTMLEntities.htmlentities(invoiceref)+"</td>"+
	                                   "<td>"+HTMLEntities.htmlentities(credit.getComment())+"</td>"+
	                                   "<td>"+HTMLEntities.htmlentities(wicketName)+"</td>"+
	                                  "</tr>"
	                        );
	                    }
	                }
	            }
	
	            Vector keys = new Vector(hSort.keySet());
	            Collections.sort(keys);
	            Collections.reverse(keys);
	            Iterator iter = keys.iterator();
	
	            while(iter.hasNext()){
	                // alternate row-style
	                if(sClass.equals("")) sClass = "1";
	                else                  sClass = "";
	
	                sHtml+= "<tr class='list"+sClass+"' "+hSort.get(iter.next());
	            }
	        }
		}
		catch(Exception e2){
			e2.printStackTrace();
		}
        
	    return sHtml;
	}
%>

<%
	String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd   = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));

    String sInsurarUid = checkString(request.getParameter("insurarUid"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** financial/getUnassignedInsurarCredits.jsp *************");
        Debug.println("sFindDateBegin : "+sFindDateBegin);
        Debug.println("sFindDateEnd : "+sFindDateEnd);
        Debug.println("sFindAmountMin : "+sFindAmountMin);
        Debug.println("sFindAmountMax : "+sFindAmountMax+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    Vector vCredits;

    if(sFindDateBegin.length()==0 && sFindDateEnd.length()==0 && sFindAmountMin.length()==0 && sFindAmountMax.length()==0){
        vCredits = InsurarCredit.getUnassignedInsurarCredits(sInsurarUid);
    }
    else{
        vCredits = InsurarCredit.getInsurarCredits(sInsurarUid,sFindDateBegin,sFindDateEnd,sFindAmountMin,sFindAmountMax);
    }
    
    if(vCredits.size() > 0){
        %>
        <table width="100%" class="list" cellspacing="0" style="border:none;">
            <tr class="admin">
                <td width="80"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
                <td width="100" align="right"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%>&nbsp;&nbsp;</td>
                <td><%=HTMLEntities.htmlentities(getTran("web","insurar",sWebLanguage))%></td>
                <td width="200"><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
                <td><%=HTMLEntities.htmlentities(getTran("web","invoice",sWebLanguage))%></td>
                <td><%=HTMLEntities.htmlentities(getTran("web","description",sWebLanguage))%></td>
                <td width="*"><%=HTMLEntities.htmlentities(getTran("web","wicket",sWebLanguage))%></td>
            </tr>
            <tbody class="hand">
                <%=addUnassignedCredits(vCredits,sWebLanguage)%>
            </tbody>
        </table>
        <%
    }
    else{
        %><%=HTMLEntities.htmlentities(getTranNoLink("web","noRecordsFound",sWebLanguage))%><%
    }
%>