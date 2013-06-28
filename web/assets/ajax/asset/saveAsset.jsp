<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.Asset,
                java.util.*"%>
<%@page import="java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- REIMBURSEMENT PLAN TO XML ---------------------------------------------------------------
    /*
        sConcatValue : date|capital|interest$ -->
        
        <ReimbursementPlans>
            <Plan>
                <Date>01/05/2013</Date>
                <Capital>20000</Capital>
                <Interest>3.25</Interest>
            </Plan>
        </ReimbursementPlans>
    */
    private String reimbursementPlanToXML(String sConcatValue){
        String sXML = "";
        
        if(sConcatValue.length() > 0){           
            org.dom4j.Document document = DocumentHelper.createDocument();
            Element rpElem = document.addElement("ReimbursementPlans"); 
              
            String sChild, sDate, sCapital, sInterest;
            while(sConcatValue.indexOf("$") > -1){
                Element planElem = rpElem.addElement("Plan"); 
                
                sChild = sConcatValue.substring(0,sConcatValue.indexOf("$")+1); 
                        
                // date
                sDate = sChild.substring(0,sChild.indexOf("|"));
                sChild = sChild.substring(sChild.indexOf("|")+1); 
                if(sDate.length() > 0){
                    planElem.addElement("Date").setText(sDate);
                }
                
                // capital
                sCapital = sChild.substring(0,sChild.indexOf("|")); 
                sChild = sChild.substring(sChild.indexOf("|")+1);
                if(sCapital.length() > 0){
                    planElem.addElement("Capital").setText(sCapital);
                }
                
                // interest
                sInterest = sChild.substring(0,sChild.indexOf("$"));  
                if(sInterest.length() > 0){
                    planElem.addElement("Interest").setText(sInterest);
                }
                
                // remaining childs
                sConcatValue = sConcatValue.substring(sConcatValue.indexOf("$")+1);
            }
            
            Debug.println("\n"+rpElem.asXML()+"\n");
            
            sXML = rpElem.asXML();
        }
        
        return sXML;
    }

    //--- GAINS TO XML ----------------------------------------------------------------------------
    /*
        sConcatValue : date|value$ -->
        
        <Gains>
            <Gain>
                <Date>01/05/2013</Date>
                <Value>20000</Value>
            </Gain>
        </Gains>
    */
    private String gainsToXML(String sConcatValue){
        String sXML = "";
        
        if(sConcatValue.length() > 0){           
            org.dom4j.Document document = DocumentHelper.createDocument();
            Element rpElem = document.addElement("Gains"); 
              
            String sChild, sDate, sValue;
            while(sConcatValue.indexOf("$") > -1){
                Element planElem = rpElem.addElement("Gain"); 
                
                sChild = sConcatValue.substring(0,sConcatValue.indexOf("$")+1); 
                        
                // date
                sDate = sChild.substring(0,sChild.indexOf("|"));
                sChild = sChild.substring(sChild.indexOf("|")+1); 
                if(sDate.length() > 0){
                    planElem.addElement("Date").setText(sDate);
                }
                
                // capital
                sValue = sChild.substring(0,sChild.indexOf("$")); 
                sChild = sChild.substring(sChild.indexOf("$")+1);
                if(sValue.length() > 0){
                    planElem.addElement("Value").setText(sValue);
                }
                                
                // remaining childs
                sConcatValue = sConcatValue.substring(sConcatValue.indexOf("$")+1);
            }
            
            Debug.println("\n"+rpElem.asXML()+"\n");
            
            sXML = rpElem.asXML();
        }
        
        return sXML;
    }

    //--- LOSSES TO XML ---------------------------------------------------------------------------
    /*
        sConcatValue : date|value$ -->
        
        <Losses>
            <Loss>
                <Date>01/05/2013</Date>
                <Value>20000</Value>
            </Loss>
        </Losses>
    */
    private String lossesToXML(String sConcatValue){
        String sXML = "";
        
        if(sConcatValue.length() > 0){           
            org.dom4j.Document document = DocumentHelper.createDocument();
            Element rpElem = document.addElement("Losses"); 
              
            String sChild, sDate, sValue;
            while(sConcatValue.indexOf("$") > -1){
                Element planElem = rpElem.addElement("Loss"); 
                
                sChild = sConcatValue.substring(0,sConcatValue.indexOf("$")+1); 
                        
                // date
                sDate = sChild.substring(0,sChild.indexOf("|"));
                sChild = sChild.substring(sChild.indexOf("|")+1); 
                if(sDate.length() > 0){
                    planElem.addElement("Date").setText(sDate);
                }
                
                // capital
                sValue = sChild.substring(0,sChild.indexOf("$")); 
                sChild = sChild.substring(sChild.indexOf("$")+1);
                if(sValue.length() > 0){
                    planElem.addElement("Value").setText(sValue);
                }
                                
                // remaining childs
                sConcatValue = sConcatValue.substring(sConcatValue.indexOf("$")+1);
            }
            
            Debug.println("\n"+rpElem.asXML()+"\n");
            
            sXML = rpElem.asXML();
        }
        
        return sXML;
    }
%>

<%
    String sEditAssetUid = checkString(request.getParameter("EditAssetUid"));

    String sCode          = checkString(request.getParameter("code")),
           sParentUid     = checkString(request.getParameter("parentUid")),
           sDescription   = checkString(request.getParameter("description")),
           sSerialnumber  = checkString(request.getParameter("serialnumber")),
           sQuantity      = checkString(request.getParameter("quantity")),
           sAssetType     = checkString(request.getParameter("assetType")),
           sSupplierUid   = checkString(request.getParameter("supplierUid")),           
           sPurchaseDate  = checkString(request.getParameter("purchaseDate")),
           sPurchasePrice = checkString(request.getParameter("purchasePrice")),
           sReceiptBy     = checkString(request.getParameter("receiptBy")),
           sPurchaseDocuments = checkString(request.getParameter("purchaseDocuments")),
           sWriteOffMethod    = checkString(request.getParameter("writeOffMethod")),
           sAnnuity           = checkString(request.getParameter("annuity")),
           sCharacteristics   = checkString(request.getParameter("characteristics")),
           sAccountingCode    = checkString(request.getParameter("accountingCode")),
           sGains             = checkString(request.getParameter("gains")),
           sLosses            = checkString(request.getParameter("losses")),

           //*** loan ***
           sLoanDate                = checkString(request.getParameter("loanDate")),
           sLoanAmount              = checkString(request.getParameter("loanAmount")),
           sLoanInterestRate        = checkString(request.getParameter("loanInterestRate")),
           sLoanReimbursementPlan   = checkString(request.getParameter("loanReimbursementPlan")),
           sLoanReimbursementAmount = checkString(request.getParameter("loanReimbursementAmount")),
           sLoanComment             = checkString(request.getParameter("loanComment")),
           sLoanDocuments           = checkString(request.getParameter("loanDocuments")),
                                                           
           sSaleDate   = checkString(request.getParameter("saleDate")),
           sSaleValue  = checkString(request.getParameter("saleValue")),
           sSaleClient = checkString(request.getParameter("saleClient"));
       
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** saveAsset.jsp ******************");
        Debug.println("sEditAssetUid      : "+sEditAssetUid);
        Debug.println("sCode              : "+sCode);
        Debug.println("sParentUid         : "+sParentUid);
        Debug.println("sDescription       : "+sDescription);
        Debug.println("sSerialnumber      : "+sSerialnumber);
        Debug.println("sQuantity          : "+sQuantity);
        Debug.println("sAssetType         : "+sAssetType);
        Debug.println("sSupplierUid       : "+sSupplierUid);
        Debug.println("sPurchaseDate      : "+sPurchaseDate);
        Debug.println("sPurchasePrice     : "+sPurchasePrice);
        Debug.println("sReceiptBy         : "+sReceiptBy);
        Debug.println("sPurchaseDocuments : "+sPurchaseDocuments);
        Debug.println("sWriteOffMethod    : "+sWriteOffMethod);
        Debug.println("sAnnuity           : "+sAnnuity);
        Debug.println("sCharacteristics   : "+sCharacteristics);
        Debug.println("sAccountingCode    : "+sAccountingCode);
        Debug.println("sGains             : "+sGains);
        Debug.println("sLosses            : "+sLosses);
        
        //*** loan ***
        Debug.println("loanDate                : "+sLoanDate);
        Debug.println("loanAmount              : "+sLoanAmount);
        Debug.println("loanInterestRate        : "+sLoanInterestRate);
        Debug.println("loanReimbursementPlan   : "+sLoanReimbursementPlan);
        Debug.println("loanReimbursementAmount : "+sLoanReimbursementAmount);
        Debug.println("loanComment             : "+sLoanComment);
        Debug.println("loanDocuments           : "+sLoanDocuments);

        Debug.println("saleDate           : "+sSaleDate);
        Debug.println("saleValue          : "+sSaleValue);
        Debug.println("saleClient         : "+sSaleClient+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    Asset asset = new Asset();
    String sMessage = "";
    
    if(sEditAssetUid.length() > 0){
        asset.setUid(sEditAssetUid);
    }
    else{
        asset.setUid("-1");
        asset.setCreateDateTime(getSQLTime());
    }

    // set dates
    if(sPurchaseDate.length() > 0){
        asset.purchaseDate = ScreenHelper.stdDateFormat.parse(sPurchaseDate);
    }
    if(sLoanDate.length() > 0){
        asset.loanDate = ScreenHelper.stdDateFormat.parse(sLoanDate);
    }
    if(sSaleDate.length() > 0){
        asset.saleDate = ScreenHelper.stdDateFormat.parse(sSaleDate);
    }

    asset.code = sCode;
    asset.parentUid = sParentUid;
    sDescription = sDescription.replaceAll("\r","");
    sDescription = sDescription.replaceAll("\r\n","<br>");
    asset.description = sDescription.replaceAll("\n","<br>");
    
    asset.serialnumber = sSerialnumber;
    if(sQuantity.length() > 0){
        asset.quantity = Double.parseDouble(sQuantity);
    }
    asset.assetType = sAssetType;
    asset.supplierUid = sSupplierUid;
    if(sPurchasePrice.length() > 0){
        asset.purchasePrice = Double.parseDouble(sPurchasePrice);
    }
    asset.receiptBy = sReceiptBy;
    asset.purchaseDocuments = sPurchaseDocuments;
    asset.writeOffMethod = sWriteOffMethod;
    asset.annuity = sAnnuity;
    
    sCharacteristics = sCharacteristics.replaceAll("\r","");
    sCharacteristics = sCharacteristics.replaceAll("\r\n","<br>");
    asset.characteristics = sCharacteristics.replaceAll("\n","<br>");
    asset.accountingCode = sAccountingCode;
    
    asset.gains = sGains;
    asset.gains = gainsToXML(sGains);
    asset.losses = sLosses;
    asset.losses = lossesToXML(sLosses);
    
    //*** loan ***
    if(sLoanAmount.length() > 0){
        asset.loanAmount = Double.parseDouble(sLoanAmount);
    }
    
    System.out.println("@@@@@@@@@@@@@@@@@@@@@@@@@@@ sLoanInterestRate : "+sLoanInterestRate); ///////////
    if(sLoanInterestRate.length() > 0){
        asset.loanInterestRate = sLoanInterestRate;
    }
    asset.loanReimbursementPlan = reimbursementPlanToXML(sLoanReimbursementPlan);
    
    /* // calculated
    if(sLoanReimbursementAmount.length() > 0){
        asset.loanReimbursementAmount = Integer.parseInt(sLoanReimbursementAmount);
    }
    */

    sLoanComment = sLoanComment.replaceAll("\r","");
    sLoanComment = sLoanComment.replaceAll("\r\n","<br>");
    asset.loanComment = sLoanComment.replaceAll("\n","<br>");
    asset.loanDocuments = sLoanDocuments;
    
    if(sSaleValue.length() > 0){
        asset.saleValue = Double.parseDouble(sSaleValue);
    } 
    sSaleClient = sSaleClient.replaceAll("\r",""); 
    sSaleClient = sSaleClient.replaceAll("\r\n","<br>");
    asset.saleClient = sSaleClient.replaceAll("\n","<br>");      
    
    asset.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    asset.setUpdateUser(activeUser.userid);
    
    
    boolean errorOccurred = asset.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=asset.getUid()%>"
}