<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.Supplier,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditSupplierUID = checkString(request.getParameter("EditSupplierUID"));

    String sCode           = ScreenHelper.checkString(request.getParameter("code")),
           sName           = ScreenHelper.checkString(request.getParameter("name")),
           sAddress        = ScreenHelper.checkString(request.getParameter("address")),
           sCity           = ScreenHelper.checkString(request.getParameter("city")),
           sZipcode        = ScreenHelper.checkString(request.getParameter("zipcode")),
           sCountry        = ScreenHelper.checkString(request.getParameter("country")),
           sVatNumber      = ScreenHelper.checkString(request.getParameter("vatNumber")),
           sTaxIDNumber    = ScreenHelper.checkString(request.getParameter("taxIDNumber")),
           sContactPerson  = ScreenHelper.checkString(request.getParameter("contactPerson")),
           sTelephone      = ScreenHelper.checkString(request.getParameter("telephone")),
           sEmail          = ScreenHelper.checkString(request.getParameter("email")),
           sAccountingCode = ScreenHelper.checkString(request.getParameter("accountingCode")),
           sComment        = ScreenHelper.checkString(request.getParameter("comment"));
    
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** saveSupplier.jsp *****************");
        Debug.println("sEditSupplierUID : "+sEditSupplierUID);
        Debug.println("sCode            : "+sCode);
        Debug.println("sName            : "+sName);
        Debug.println("sAddress         : "+sAddress);
        Debug.println("sCity            : "+sCity);
        Debug.println("sZipcode         : "+sZipcode);
        Debug.println("sCountry         : "+sCountry);
        Debug.println("sVatNumber       : "+sVatNumber);
        Debug.println("sTaxIDNumber     : "+sTaxIDNumber);
        Debug.println("sContactPerson   : "+sContactPerson);
        Debug.println("sTelephone       : "+sTelephone);
        Debug.println("sEmail           : "+sEmail);
        Debug.println("sAccountingCode  : "+sAccountingCode);
        Debug.println("sComment         : "+sComment+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    Supplier supplier = new Supplier();
    String sMessage = "";
    
    if(sEditSupplierUID.length() > 0){
        supplier.setUid(sEditSupplierUID);
    }
    else{
        supplier.setUid("-1");
        supplier.setCreateDateTime(getSQLTime());
    }

    supplier.code = sCode;
    supplier.name = sName;
    supplier.address = sAddress;
    supplier.city = sCity;
    supplier.zipcode = sZipcode;
    supplier.country = sCountry;
    supplier.vatNumber = sVatNumber;
    supplier.taxIDNumber = sTaxIDNumber;
    supplier.contactPerson = sContactPerson;
    supplier.telephone = sTelephone;
    supplier.email = sEmail;
    supplier.accountingCode = sAccountingCode;
    supplier.comment = sComment;

    supplier.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    supplier.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = supplier.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTranNoLink("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUID":"<%=supplier.getUid()%>"
}