<%@page import="java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<% 
    String sAction = checkString(request.getParameter("addOrDeleteValue"));
    String sItemType = checkString(request.getParameter("itemType")).toUpperCase();

    String sItemValue = checkString(request.getParameter("Itemvalue"));
    String sCounterEdit = checkString(request.getParameter("editCounter"));

    int sItemId = 0;
    if(!checkString(request.getParameter("itemid")).equals("")){
        sItemId = Integer.parseInt(checkString(request.getParameter("itemid")));
    }
    
    int sUserId = 0;
    if(!checkString(request.getParameter("userID")).equals("")){
        sUserId = Integer.parseInt(checkString(request.getParameter("userID")));
    }
    
    int sCounter = 0;
    if(!checkString(request.getParameter("counterValue")).equals("")){
        sCounter = Integer.parseInt(checkString(request.getParameter("counterValue")));
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*************** searchByAjax/editAutocompletionValues.jsp *************");
    	Debug.println("sAction      : "+sAction);
    	Debug.println("sItemType    : "+sItemType);
    	Debug.println("sItemValue   : "+sItemValue);
    	Debug.println("sCounterEdit : "+sCounterEdit);
    	Debug.println("sItemId      : "+sItemId);
    	Debug.println("sUserId      : "+sUserId);
    	Debug.println("sCounter     : "+sCounter+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    MedwanQuery medwanQuery = MedwanQuery.getInstance();
    if(sAction.equals("del")){
        //*** if delete value from user ***
        if(sItemId > 0){
            //*** if delete one value ***
            medwanQuery.delAutocompletionItemsValues(sItemId,"",0);
        }
        else{
            //*** if delete all type values of this user ***
            medwanQuery.delAutocompletionItemsValues(0,sItemType,sUserId);
        }
    }
    else if(sAction.equals("edit")){
        if(!sCounterEdit.equals("")){
            //*** if edit counter ***
            medwanQuery.setAutocompletionCounterValues(sItemId,Integer.parseInt(sItemValue));
            out.write(getTran("Web.manage","addNewValue",sWebLanguage)+
            		  "<script>var getValues = ajaxChangeSearchResults(\"_common/search/searchByAjax/itemsTypesShow.jsp\",transactionForm,\"&itemTypeSelect="+sItemValue+"\",\"ItemsValuesByType\");</script>");
        }
        else{
            //*** IF UPDATE VALUE ***
            medwanQuery.delAutocompletionItemsValues(sItemId,"",0);
            medwanQuery.setAutocompletionItemsValues(sItemType,sItemValue,sUserId,sCounter);
            out.write(getTran("Web.manage","addNewValue",sWebLanguage)+
            		  "<script>var getValues = ajaxChangeSearchResults(\"_common/search/searchByAjax/itemsTypesShow.jsp\",transactionForm,\"&itemTypeSelect="+sItemValue+"\",\"ItemsValuesByType\");</script>");
        }
    }
    else{
        //*** if insert new value ***
        medwanQuery.setAutocompletionItemsValues(sItemType,sItemValue,sUserId,0);
        out.write(getTran("Web.manage","addNewValue",sWebLanguage)+
        		  "<script>var getValues = ajaxChangeSearchResults(\"_common/search/searchByAjax/itemsTypesShow.jsp\",transactionForm,\"&itemTypeSelect="+sItemValue+"\",\"ItemsValuesByType\");</script>");
    }
%>