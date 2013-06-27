<%@page import="be.openclinic.assets.Supplier,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSupplierUid = checkString(request.getParameter("SupplierUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** getSupplier.jsp ******************");
        Debug.println("sSupplierUid : "+sSupplierUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    Supplier supplier = Supplier.get(sSupplierUid);
    
    if(supplier!=null){
        %>    
{    
  "supplierUid":"<%=supplier.getUid()%>",
  "code":"<%=HTMLEntities.htmlentities(supplier.code)%>",
  "name":"<%=HTMLEntities.htmlentities(supplier.name)%>",
  "address":"<%=HTMLEntities.htmlentities(supplier.address)%>",
  "city":"<%=HTMLEntities.htmlentities(supplier.city)%>",
  "zipcode":"<%=HTMLEntities.htmlentities(supplier.zipcode)%>",
  "countryCode":"<%=HTMLEntities.htmlentities(supplier.country)%>",
  "country":"<%=HTMLEntities.htmlentities(getTranNoLink("country",supplier.country,sWebLanguage))%>",
  "vatNumber":"<%=HTMLEntities.htmlentities(supplier.vatNumber)%>",
  "taxIDNumber":"<%=HTMLEntities.htmlentities(supplier.taxIDNumber)%>",
  "contactPerson":"<%=HTMLEntities.htmlentities(supplier.contactPerson)%>",
  "telephone":"<%=HTMLEntities.htmlentities(supplier.telephone)%>",
  "email":"<%=HTMLEntities.htmlentities(supplier.email)%>",
  "accountingCode":"<%=HTMLEntities.htmlentities(supplier.accountingCode)%>",
  "comment":"<%=HTMLEntities.htmlentities(supplier.comment.replaceAll("\r\n","<br>"))%>"
}
        <%
    }
    else{
        %>    
{
  "supplierUid":"-1",
  "code":"",
  "name":"",
  "address":"",
  "city":"",
  "zipcode":"",
  "country":"",
  "vatNumber":"",
  "taxIDNumber":"",
  "contactPerson":"",
  "telephone":"",
  "email":"",
  "accountingCode":"",
  "comment":""
}
        <%
    }
%>