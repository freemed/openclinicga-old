<%@page import="be.openclinic.finance.Debet,
                be.mxs.common.util.db.*,
                java.util.Vector,
                be.mxs.common.util.system.Debug,
                be.mxs.common.util.system.ScreenHelper"%>
                
<%
    String sPersonId = ScreenHelper.checkString(request.getParameter("personid"));
    boolean quickInvoicingEnabled = (MedwanQuery.getInstance().getConfigInt("enableQuickInvoicing",0)==1);
    Vector debets = new Vector();
    if(quickInvoicingEnabled){
    	Debet.getUnassignedPatientDebets(sPersonId);
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* financial/checkQuickInvoice.jsp *******************");
    	Debug.println("sPersonId             : "+sPersonId);
    	Debug.println("quickInvoicingEnabled : "+quickInvoicingEnabled);
    	Debug.println("--> debets : "+debets.size());
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
	if(quickInvoicingEnabled && debets.size()>0){
		Debug.println("--> <OK>");
		out.println("<OK>");
	}
%>