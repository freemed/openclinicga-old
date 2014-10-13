<%@page import="be.openclinic.assets.Supplier,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../assets/includes/commonFunctions.jsp"%>

<%
    // search-criteria
    String sCode           = checkString(request.getParameter("code")),
           sName           = checkString(request.getParameter("name")),
           //sAddress        = checkString(request.getParameter("address")),
           //sCity           = checkString(request.getParameter("city")),
           //sZipcode        = checkString(request.getParameter("zipcode")),
           //sCountry        = checkString(request.getParameter("country")),
           sVatNumber      = checkString(request.getParameter("vatNumber"));
           //sTaxIDNumber    = checkString(request.getParameter("taxIDNumber")),
           //sContactPerson  = checkString(request.getParameter("contactPerson")),
           //sTelephone      = checkString(request.getParameter("telephone")),
           //sEmail          = checkString(request.getParameter("email")),
           //sAccountingCode = checkString(request.getParameter("accountingCode")),
           //sComment        = checkString(request.getParameter("comment"));


    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** seests/ajax/getSuppliers.jsp ***************");
        Debug.println("sCode           : "+sCode);
        Debug.println("sName           : "+sName);
        //Debug.println("sAddress        : "+sAddress);
        //Debug.println("sCity           : "+sCity);
        //Debug.println("sZipcode        : "+sZipcode);
        //Debug.println("sCountry        : "+sCountry);
        Debug.println("sVatNumber      : "+sVatNumber+"\n");
        //Debug.println("sTaxIDNumber    : "+sTaxIDNumber);
        //Debug.println("sContactPerson  : "+sContactPerson);
        //Debug.println("sTelephone      : "+sTelephone);
        //Debug.println("sEmail          : "+sEmail);
        //Debug.println("sAccountingCode : "+sAccountingCode);
        //Debug.println("sComment        : "+sComment+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Supplier findObject = new Supplier();
    findObject.code = sCode;
    findObject.name = sName;
    findObject.vatNumber = sVatNumber;

    List suppliers = Supplier.getList(findObject);
    String sReturn = "";
    
    if(suppliers.size() > 0){
        Hashtable hSort = new Hashtable();
        Supplier supplier;
    
        // sort on supplier.code
        for(int i=0; i<suppliers.size(); i++){
            supplier = (Supplier)suppliers.get(i);

            hSort.put(supplier.name+"="+supplier.getUid(),
                      " onclick=\"displaySupplier('"+supplier.getUid()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+supplier.code+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+supplier.name+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+supplier.vatNumber+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+supplier.email+"</td>"+
                     "</tr>");
        }
    
        Vector keys = new Vector(hSort.keySet());
        Collections.sort(keys);
        Iterator iter = keys.iterator();
        String sClass = "1";
        
        while(iter.hasNext()){
            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            sReturn+= "<tr class='list"+sClass+"' "+hSort.get(iter.next());
        }
    }
    else{
        sReturn = "<td colspan='4'>"+getTran("web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(suppliers.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">    
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran("web","code",sWebLanguage))%></td>
        <td width="25%" nowrap><asc><%=HTMLEntities.htmlentities(getTran("web","name",sWebLanguage))%></asc></td>
        <td width="15%" nowrap><%=HTMLEntities.htmlentities(getTran("web","vatNumber",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran("web","email",sWebLanguage))%></td>
    </tr>
    
    <tbody class="hand">
        <%=sReturn%>
    </tbody>
</table> 

&nbsp;<i><%=suppliers.size()+" "+getTran("web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>