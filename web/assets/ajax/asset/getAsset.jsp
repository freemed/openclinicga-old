<%@page import="be.openclinic.assets.Asset,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*,
                java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!   
    //--- PARSE LOAN REIMBURSEMENT PLANS ----------------------------------------------------------
    /*
        <ReimbursementPlans>
            <Plan>
                <Date>01/05/2013</Date>
                <Capital>20000</Capital>
                <Interest>3.25</Interest>
            </Plan>
        </ReimbursementPlans>

        --> date|capital|interest$
    */    
    private String parseLoanReimbursementPlans(String sLoanReimbursementPlans){
        String sConcatValue = "";

        if(sLoanReimbursementPlans.length() > 0){
            try{
                // parse reimbursementplans from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sLoanReimbursementPlans));
                Element containerElem = document.getRootElement(); // ReimbursementPlans
         
                if(containerElem!=null){  
                    Iterator childsIter = containerElem.elementIterator("Plan");
        
                    String sTmpDate, sTmpCapital, sTmpInterest;
                    Element childElem;
                    
                    while(childsIter.hasNext()){
                        childElem = (Element)childsIter.next();
                                                
                        sTmpDate     = checkString(childElem.elementText("Date"));
                        sTmpCapital  = checkString(childElem.elementText("Capital"));
                        sTmpInterest = checkString(childElem.elementText("Interest"));
                        
                        sConcatValue+= sTmpDate+"|"+sTmpCapital+"|"+sTmpInterest+"$";
                    }
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }
                
        return sConcatValue;
    }
        
    //--- PARSE GAINS -----------------------------------------------------------------------------
    /*
        <Gains>
            <Gain>
                <Date>01/05/2013</Date>
                <Value>20000</Value>
            </Gain>
        </Gains>

        --> date|value$
    */    
    private String parseGains(String sGains){
        String sConcatValue = "";

        if(sGains.length() > 0){
            try{
                // parse gains from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sGains));
                Element containerElem = document.getRootElement(); // Gains
         
                if(containerElem!=null){  
                    Iterator childIter = containerElem.elementIterator("Gain");
        
                    String sTmpDate, sTmpValue;
                    Element childElem;
                    
                    while(childIter.hasNext()){
                        childElem = (Element)childIter.next();
                                                
                        sTmpDate  = checkString(childElem.elementText("Date"));
                        sTmpValue = checkString(childElem.elementText("Value"));
                        
                        sConcatValue+= sTmpDate+"|"+sTmpValue+"$";
                    }
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }
                
        return sConcatValue;
    }
        
    //--- PARSE LOSSES ----------------------------------------------------------------------------
    /*
        <Losses>
            <Loss>
                <Date>01/05/2013</Date>
                <Value>20000</Value>
            </Loss>
        </Losses>

        --> date|value$
    */    
    private String parseLosses(String sLosses){
        String sConcatValue = "";

        if(sLosses.length() > 0){
            try{
                // parse plans from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sLosses));
                Element containerElem = document.getRootElement(); // Losses
         
                if(containerElem!=null){  
                    Iterator childIter = containerElem.elementIterator("Loss");
        
                    String sTmpDate, sTmpValue;
                    Element childElem;
                    
                    while(childIter.hasNext()){
                        childElem = (Element)childIter.next();
                                                
                        sTmpDate  = checkString(childElem.elementText("Date"));
                        sTmpValue = checkString(childElem.elementText("Value"));
                        
                        sConcatValue+= sTmpDate+"|"+sTmpValue+"$";
                    }
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }
                
        return sConcatValue;
    }
%>
        
<%
    String sAssetUID = checkString(request.getParameter("AssetUID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************* assets/ajax/asset/getAsset.jsp *********************");
        Debug.println("sAssetUID : "+sAssetUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Asset asset = Asset.get(sAssetUID);
    
    double[] totals = asset.calculateReimbursementTotals();
    double reimbursementCapitalTotal  = totals[0],
           reimbursementInterestTotal = totals[1],
           reimbursementAmount        = totals[2];
    
    DecimalFormat deci = new DecimalFormat("0.00"); // do not display zeroes
%>

{
  "code":"<%=HTMLEntities.htmlentities(asset.code)%>",
  "parentUID":"<%=HTMLEntities.htmlentities(asset.parentUid)%>",
  "parentCode":"<%=(asset.parentUid.length()>0?HTMLEntities.htmlentities(asset.getParentCode(asset.parentUid)):"")%>",
  "description":"<%=HTMLEntities.htmlentities(asset.description.replaceAll("\r","").replaceAll("\r\n","<br>"))%>",
  "serialnumber":"<%=HTMLEntities.htmlentities(asset.serialnumber)%>",
  "quantity":"<%=deci.format(asset.quantity).replaceAll(",",".")%>",
  "assetType":"<%=HTMLEntities.htmlentities(asset.assetType)%>",
  "supplierUID":"<%=HTMLEntities.htmlentities(asset.supplierUid)%>",
  "supplierName":"<%=(asset.supplierUid.length()>0?HTMLEntities.htmlentities(asset.getSupplierName(asset.supplierUid)):"")%>",
  <%
      if(asset.purchaseDate!=null){
          %>"purchaseDate":"<%=ScreenHelper.stdDateFormat.format(asset.purchaseDate)%>",<%        
      }
      else{
          %>"purchaseDate":"",<% // empty
      }
  %>  
  "purchasePrice":"<%=(asset.purchasePrice>-1?deci.format(asset.purchasePrice).replaceAll(",","."):"")%>",
  "receiptBy":"<%=HTMLEntities.htmlentities(asset.receiptBy)%>",
  "purchaseDocuments":"<%=HTMLEntities.htmlentities(asset.purchaseDocuments)%>",
  "writeOffMethod":"<%=HTMLEntities.htmlentities(asset.writeOffMethod)%>",
  "writeOffPeriod":"<%=(asset.writeOffPeriod>-1?asset.writeOffPeriod:"")%>",
  "annuity":"<%=HTMLEntities.htmlentities(asset.annuity)%>",
  "characteristics":"<%=HTMLEntities.htmlentities(asset.characteristics.replaceAll("\r","").replaceAll("\r\n","<br>"))%>",
  "accountingCode":"<%=HTMLEntities.htmlentities(asset.accountingCode)%>",
  <%
      if(asset.gains.length() > 0){
          %>"gains":"<%=HTMLEntities.htmlentities(parseGains(asset.gains))%>",<%        
      }
      else{
          %>"gains":"",<% // empty
      }
  %>
  <%
      if(asset.losses.length() > 0){
          %>"losses":"<%=HTMLEntities.htmlentities(parseLosses(asset.losses))%>",<%        
      }
      else{
          %>"losses":"",<% // empty
      }
  %>
  "residualValueHistory":"<%=HTMLEntities.htmlentities(asset.calculateResidualValueHistory(sWebLanguage))%>",
  <%
      if(asset.loanDate!=null){
          %>"loanDate":"<%=ScreenHelper.stdDateFormat.format(asset.loanDate)%>",<%        
      }
      else{
          %>"loanDate":"",<% // empty
      }
  %>
  "loanAmount":"<%=(asset.loanAmount>-1?deci.format(asset.loanAmount).replaceAll(",","."):"")%>",
  "loanInterestRate":"<%=HTMLEntities.htmlentities(asset.loanInterestRate.replaceAll("\\[percent]","%"))%>",
  <%
      if(asset.loanReimbursementPlan.length() > 0){
          %>"loanReimbursementPlan":"<%=HTMLEntities.htmlentities(parseLoanReimbursementPlans(asset.loanReimbursementPlan))%>",<%        
      }
      else{
          %>"loanReimbursementPlan":"",<% // empty
      }
  %>
  "loanReimbursementCapitalTotal":"<%=(reimbursementCapitalTotal>-1?deci.format(reimbursementCapitalTotal).replaceAll(",","."):"")%>",
  "loanReimbursementInterestTotal":"<%=(reimbursementInterestTotal>-1?deci.format(reimbursementInterestTotal).replaceAll(",","."):"")%>",
  "loanReimbursementAmount":"<%=(reimbursementAmount>-1?deci.format(reimbursementAmount).replaceAll(",","."):"")%>",
  "loanComment":"<%=HTMLEntities.htmlentities(asset.loanComment.replaceAll("\r","").replaceAll("\r\n","<br>"))%>",
  "loanDocuments":"<%=HTMLEntities.htmlentities(asset.loanDocuments)%>",
  <%
      if(asset.saleDate!=null){
          %>"saleDate":"<%=ScreenHelper.stdDateFormat.format(asset.saleDate)%>",<%        
      }
      else{
          %>"saleDate":"",<% // empty
      }
  %>
  "saleValue":"<%=(asset.saleValue>-1?deci.format(asset.saleValue).replaceAll(",","."):"")%>",
  "saleClient":"<%=HTMLEntities.htmlentities(asset.saleClient.replaceAll("\r","").replaceAll("\r\n","<br>"))%>"
}