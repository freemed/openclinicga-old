<%@page import="be.openclinic.hr.Salary,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page import="java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- PARSE BENEFITS --------------------------------------------------------------------------
    /*
        <Benefits>
            <Benefit>
                <Begin>01/05/2013</Begin>
                <End>09/05/2013</End>
                <Period>period2</Period>
                <Type>type2</Type>
                <Percentage>15.00</Percentage> ----> only for bonuses
                <Amount>1050.00</Amount>
             </Benefit>
        </Benefits>

        --> sBegin+"|"+sEnd+"|"+sPeriod+"|"+sType+"|"+sAmount+"$"
    */    
    private String parseBenefits(String sBenefits){
        String sConcatValue = "";

        if(sBenefits.length() > 0){
            try{
                // parse benefits from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sBenefits));
                Element benefitsElem = document.getRootElement();
         
                if(benefitsElem!=null){  
                    Iterator benefitsIter = benefitsElem.elementIterator("Benefit");
        
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
                    Element benefitElem;
                    
                    while(benefitsIter.hasNext()){
                        benefitElem = (Element)benefitsIter.next();
                                                
                        sTmpBegin  = checkString(benefitElem.elementText("Begin"));
                        sTmpEnd    = checkString(benefitElem.elementText("End"));
                        sTmpPeriod = checkString(benefitElem.elementText("Period"));
                        sTmpType   = checkString(benefitElem.elementText("Type"));
                        sTmpAmount = checkString(benefitElem.elementText("Amount"));
                        
                        sConcatValue+= sTmpBegin+"|"+sTmpEnd+"|"+sTmpPeriod+"|"+sTmpType+"|"+sTmpAmount+"$";
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
        
    //--- PARSE BONUSES ---------------------------------------------------------------------------
    private String parseBonuses(String sBonuses){
        String sConcatValue = "";

        if(sBonuses.length() > 0){
            try{
                // parse benefits from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sBonuses));
                Element bonusesElem = document.getRootElement();
         
                if(bonusesElem!=null){  
                    Iterator bonusesIter = bonusesElem.elementIterator("Bonus");
        
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpPercentage, sTmpAmount;
                    Element bonusElem;
                    
                    while(bonusesIter.hasNext()){
                        bonusElem = (Element)bonusesIter.next();
                                                
                        sTmpBegin      = checkString(bonusElem.elementText("Begin"));
                        sTmpEnd        = checkString(bonusElem.elementText("End"));
                        sTmpPeriod     = checkString(bonusElem.elementText("Period"));
                        sTmpType       = checkString(bonusElem.elementText("Type"));
                        sTmpPercentage = checkString(bonusElem.elementText("Percentage"));
                        sTmpAmount     = checkString(bonusElem.elementText("Amount"));
                        
                        sConcatValue+= sTmpBegin+"|"+sTmpEnd+"|"+sTmpPeriod+"|"+sTmpType+"|"+sTmpPercentage+"|"+sTmpAmount+"$";
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
    
    //--- PARSE OTHER INCOME ----------------------------------------------------------------------  
    private String parseOtherIncome(String sOtherIncome){
        String sConcatValue = "";

        if(sOtherIncome.length() > 0){
            try{
                // parse benefits from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sOtherIncome));
                Element benefitsElem = document.getRootElement();
         
                if(benefitsElem!=null){  
                    Iterator otherIncomesIter = benefitsElem.elementIterator("OtherIncome");
        
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
                    Element otherIncomeElem;
                    
                    while(otherIncomesIter.hasNext()){
                        otherIncomeElem = (Element)otherIncomesIter.next();
                                                
                        sTmpBegin  = checkString(otherIncomeElem.elementText("Begin"));
                        sTmpEnd    = checkString(otherIncomeElem.elementText("End"));
                        sTmpPeriod = checkString(otherIncomeElem.elementText("Period"));
                        sTmpType   = checkString(otherIncomeElem.elementText("Type"));
                        sTmpAmount = checkString(otherIncomeElem.elementText("Amount"));
                        
                        sConcatValue+= sTmpBegin+"|"+sTmpEnd+"|"+sTmpPeriod+"|"+sTmpType+"|"+sTmpAmount+"$";
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
    
    //--- PARSE DEDUCTIONS ------------------------------------------------------------------------  
    private String parseDeductions(String sDeductions){
        String sConcatValue = "";

        if(sDeductions.length() > 0){
            try{
                // parse benefits from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sDeductions));
                Element deductionsElem = document.getRootElement();
         
                if(deductionsElem!=null){  
                    Iterator deductionsIter = deductionsElem.elementIterator("Deduction");
        
                    String sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
                    Element deductionElem;
                    
                    while(deductionsIter.hasNext()){
                        deductionElem = (Element)deductionsIter.next();
                                                
                        sTmpBegin  = checkString(deductionElem.elementText("Begin"));
                        sTmpEnd    = checkString(deductionElem.elementText("End"));
                        sTmpPeriod = checkString(deductionElem.elementText("Period"));
                        sTmpType   = checkString(deductionElem.elementText("Type"));
                        sTmpAmount = checkString(deductionElem.elementText("Amount"));
                        
                        sConcatValue+= sTmpBegin+"|"+sTmpEnd+"|"+sTmpPeriod+"|"+sTmpType+"|"+sTmpAmount+"$";
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
    String sSalaryUid = checkString(request.getParameter("SalaryUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** getSalary.jsp ******************");
        Debug.println("sSalaryUid : "+sSalaryUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
                
    Salary salary = Salary.get(sSalaryUid);
    
    // contractName == contractId (not uid)
    String sContractName = "";
    if(checkString(salary.contractUid).length() > 0){
        //sContractName = getTranNoLink("contract",salary.contractUid,sWebLanguage);
        sContractName = salary.contractUid.substring(salary.contractUid.indexOf(".")+1);
    }

    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigParam("priceFormat","0.00"));
%>
        
{
  "begin":"<%=(salary.begin!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(salary.begin)):"")%>",
  "end":"<%=(salary.end!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(salary.end)):"")%>",
  "contractUid":"<%=salary.contractUid%>",
  "contractName":"<%=sContractName%>",
  "salary":"<%=(deci.format(salary.salary)).replace(",",".")%>",
  "salaryPeriod":"<%=HTMLEntities.htmlentities(salary.salaryPeriod)%>",
  "benefits":"<%=HTMLEntities.htmlentities(checkString(parseBenefits(salary.benefits)))%>",
  "bonuses":"<%=HTMLEntities.htmlentities(checkString(parseBonuses(salary.bonuses)))%>",
  "otherIncome":"<%=HTMLEntities.htmlentities(checkString(parseOtherIncome(salary.otherIncome)))%>",
  "deductions":"<%=HTMLEntities.htmlentities(checkString(parseDeductions(salary.deductions)))%>",
  "comment":"<%=HTMLEntities.htmlentities(checkString(salary.comment.replaceAll("\r\n","<br>")))%>"
}