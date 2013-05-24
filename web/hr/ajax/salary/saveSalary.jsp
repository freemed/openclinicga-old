<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Salary,
                java.util.*"%>
<%@page import="java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- BENEFITS TO XML -------------------------------------------------------------------------
    /*
        -    Benefits (multi-add)
            o    Begin* (date selector >= Salary.Begin)
            o    End (date selector >= Begin)
            o    Benefit period* (select) => daily (working days only), weekly, monthly , yearly (default) 
            o    Benefit type* (select)
            o    Benefit amount (text – numeric with priceFormat mask)
    */
    private Element benefitsToXml(String sBenefits, Element benefitsElem){        
        if(sBenefits.length() > 0){
            if(sBenefits.indexOf("$") > -1){
                String sTmpBenefits = sBenefits;
                sBenefits = "";
                
                String sTmpBegin = "", sTmpEnd = "", sTmpPeriod = "", sTmpType = "", sTmpAmount = "";
                
                while(sTmpBenefits.indexOf("$") > -1){
                    sTmpBegin = "";
                    sTmpEnd = "";
                    sTmpPeriod = "";
                    sTmpType = "";
                    sTmpAmount = "";

                    if(sTmpBenefits.indexOf("|") > -1){
                        sTmpBegin = sTmpBenefits.substring(0,sTmpBenefits.indexOf("|"));
                        sTmpBenefits = sTmpBenefits.substring(sTmpBenefits.indexOf("|")+1);
                    }
                    
                    if(sTmpBenefits.indexOf("|") > -1){
                        sTmpEnd = sTmpBenefits.substring(0,sTmpBenefits.indexOf("|"));
                        sTmpBenefits = sTmpBenefits.substring(sTmpBenefits.indexOf("|")+1);
                    }
                    
                    if(sTmpBenefits.indexOf("|") > -1){
                        sTmpPeriod = sTmpBenefits.substring(0,sTmpBenefits.indexOf("|"));
                        sTmpBenefits = sTmpBenefits.substring(sTmpBenefits.indexOf("|")+1);
                    }
                
                    if(sTmpBenefits.indexOf("|") > -1){
                       sTmpType = sTmpBenefits.substring(0,sTmpBenefits.indexOf("|"));
                       sTmpBenefits = sTmpBenefits.substring(sTmpBenefits.indexOf("|")+1);
                    }

                    if(sTmpBenefits.indexOf("$") > -1){
                        sTmpAmount = sTmpBenefits.substring(0,sTmpBenefits.indexOf("$"));
                        sTmpBenefits = sTmpBenefits.substring(sTmpBenefits.indexOf("$")+1);
                    }

                    Element benefitElem = benefitsElem.addElement("Benefit");
                    benefitElem.addElement("Begin").addText(sTmpBegin);
                    benefitElem.addElement("End").addText(sTmpEnd);
                    benefitElem.addElement("Period").addText(sTmpPeriod);
                    benefitElem.addElement("Type").addText(sTmpType);
                    benefitElem.addElement("Amount").addText(sTmpAmount);
                }
            }            
        }
        
        return benefitsElem;
    }

    //--- BONUSES TO XML --------------------------------------------------------------------------
    /*
        -    Bonuses (multi-add)
            o    Begin* (date selector selector >= Salary.Begin)
            o    End (date selector >= Begin)
            o    Bonus period* (select) => daily (working days only), weekly, monthly , yearly (default) 
            o    Bonus type* (select) => specific options can trigger a Bonus period & amount calculation based on the fiscalCountry config value : refers to ajaxCalculateBonus.jsp (all fields sent to ajax, alert message if some fields are lacking)
            o    Bonus percentage (text – numeric) => calculates Bonus amount based on % of Yearly gross salary
            o    Bonus amount* (text – numeric with priceFormat mask) => calculated or manual
    */
    private Element bonusesToXml(String sBonuses, Element bonusesElem){        
        if(sBonuses.length() > 0){
            if(sBonuses.indexOf("$") > -1){
                String sTmpBonuses = sBonuses;
                sBonuses = "";
                
                String sTmpBegin = "", sTmpEnd = "", sTmpPeriod = "", sTmpType = "", sTmpPercent = "", sTmpAmount = "";
                
                while(sTmpBonuses.indexOf("$") > -1){
                    sTmpBegin = "";
                    sTmpEnd = "";
                    sTmpPeriod = "";
                    sTmpType = "";
                    sTmpPercent = "";
                    sTmpAmount = "";
    
                    if(sTmpBonuses.indexOf("|") > -1){
                        sTmpBegin = sTmpBonuses.substring(0,sTmpBonuses.indexOf("|"));
                        sTmpBonuses = sTmpBonuses.substring(sTmpBonuses.indexOf("|")+1);
                    }
                    
                    if(sTmpBonuses.indexOf("|") > -1){
                        sTmpEnd = sTmpBonuses.substring(0,sTmpBonuses.indexOf("|"));
                        sTmpBonuses = sTmpBonuses.substring(sTmpBonuses.indexOf("|")+1);
                    }
                    
                    if(sTmpBonuses.indexOf("|") > -1){
                        sTmpPeriod = sTmpBonuses.substring(0,sTmpBonuses.indexOf("|"));
                        sTmpBonuses = sTmpBonuses.substring(sTmpBonuses.indexOf("|")+1);
                    }
                
                    if(sTmpBonuses.indexOf("|") > -1){
                       sTmpType = sTmpBonuses.substring(0,sTmpBonuses.indexOf("|"));
                       sTmpBonuses = sTmpBonuses.substring(sTmpBonuses.indexOf("|")+1);
                    }
                
                    if(sTmpBonuses.indexOf("|") > -1){
                       sTmpPercent = sTmpBonuses.substring(0,sTmpBonuses.indexOf("|"));
                       sTmpBonuses = sTmpBonuses.substring(sTmpBonuses.indexOf("|")+1);
                    }
    
                    if(sTmpBonuses.indexOf("$") > -1){
                        sTmpAmount = sTmpBonuses.substring(0,sTmpBonuses.indexOf("$"));
                        sTmpBonuses = sTmpBonuses.substring(sTmpBonuses.indexOf("$")+1);
                    }
    
                    Element bonusElem = bonusesElem.addElement("Bonus");
                    bonusElem.addElement("Begin").addText(sTmpBegin);
                    bonusElem.addElement("End").addText(sTmpEnd);
                    bonusElem.addElement("Period").addText(sTmpPeriod);
                    bonusElem.addElement("Type").addText(sTmpType);
                    bonusElem.addElement("Percentage").addText(sTmpPercent); // extra field 
                    bonusElem.addElement("Amount").addText(sTmpAmount);
                }
            }            
        }
        
        return bonusesElem;
    }

    //--- OTHER INCOMES TO XML --------------------------------------------------------------------
    /*
        -    Other income elements (multi-add)
            o    Begin* (date selector selector >= Salary.Begin)
            o    End (date selector >= Begin)
            o    Period (select) => daily (working days only), weekly, monthly , yearly (default)
            o    Type* (select) => specific options can trigger a Period & Amount calculation based on the fiscalCountry config value : refers to ajaxCalculateOtherIncomeElements.jsp (all fields sent to ajax, alert message if some fields are lacking)
            o    Amount* (text – numeric with priceFormat mask) => calculated or manual
    */
    private Element otherIncomesToXml(String sOtherIncomes, Element otherIncomesElem){        
        if(sOtherIncomes.length() > 0){
            if(sOtherIncomes.indexOf("$") > -1){
                String sTmpOtherIncomes = sOtherIncomes;
                sOtherIncomes = "";
                
                String sTmpBegin = "", sTmpEnd = "", sTmpPeriod = "", sTmpType = "", sTmpAmount = "";
                
                while(sTmpOtherIncomes.indexOf("$") > -1){
                    sTmpBegin = "";
                    sTmpEnd = "";
                    sTmpPeriod = "";
                    sTmpType = "";
                    sTmpAmount = "";
    
                    if(sTmpOtherIncomes.indexOf("|") > -1){
                        sTmpBegin = sTmpOtherIncomes.substring(0,sTmpOtherIncomes.indexOf("|"));
                        sTmpOtherIncomes = sTmpOtherIncomes.substring(sTmpOtherIncomes.indexOf("|")+1);
                    }
                    
                    if(sTmpOtherIncomes.indexOf("|") > -1){
                        sTmpEnd = sTmpOtherIncomes.substring(0,sTmpOtherIncomes.indexOf("|"));
                        sTmpOtherIncomes = sTmpOtherIncomes.substring(sTmpOtherIncomes.indexOf("|")+1);
                    }
                    
                    if(sTmpOtherIncomes.indexOf("|") > -1){
                        sTmpPeriod = sTmpOtherIncomes.substring(0,sTmpOtherIncomes.indexOf("|"));
                        sTmpOtherIncomes = sTmpOtherIncomes.substring(sTmpOtherIncomes.indexOf("|")+1);
                    }
                
                    if(sTmpOtherIncomes.indexOf("|") > -1){
                       sTmpType = sTmpOtherIncomes.substring(0,sTmpOtherIncomes.indexOf("|"));
                       sTmpOtherIncomes = sTmpOtherIncomes.substring(sTmpOtherIncomes.indexOf("|")+1);
                    }
    
                    if(sTmpOtherIncomes.indexOf("$") > -1){
                        sTmpAmount = sTmpOtherIncomes.substring(0,sTmpOtherIncomes.indexOf("$"));
                        sTmpOtherIncomes = sTmpOtherIncomes.substring(sTmpOtherIncomes.indexOf("$")+1);
                    }
    
                    Element otherIncomeElem = otherIncomesElem.addElement("OtherIncome");
                    otherIncomeElem.addElement("Begin").addText(sTmpBegin);
                    otherIncomeElem.addElement("End").addText(sTmpEnd);
                    otherIncomeElem.addElement("Period").addText(sTmpPeriod);
                    otherIncomeElem.addElement("Type").addText(sTmpType);
                    otherIncomeElem.addElement("Amount").addText(sTmpAmount);
                }
            }            
        }
        
        return otherIncomesElem;
    }

    //--- DEDUCTIONS TO XML -----------------------------------------------------------------------
    /*
        -    Deductions (multi-add)
            o    Begin* (date selector selector >= Salary.Begin)
            o    End (date selector >= Begin)
            o    Period (select) => daily (working days only), weekly, monthly , yearly (default)
            o    Type* (select) => specific options can trigger a Period & Amount calculation based on the fiscalCountry config value : refers to ajaxCalculateDeductions.jsp (all fields sent to ajax, alert message if some fields are lacking)
            o    Amount* (text – numeric with priceFormat mask) => calculated or manual
    */
    private Element deductionsToXml(String sDeductions, Element deductionsElem){        
        if(sDeductions.length() > 0){
            if(sDeductions.indexOf("$") > -1){
                String sTmpDeductions = sDeductions;
                sDeductions = "";
                
                String sTmpBegin = "", sTmpEnd = "", sTmpPeriod = "", sTmpType = "", sTmpAmount = "";
                
                while(sTmpDeductions.indexOf("$") > -1){
                    sTmpBegin = "";
                    sTmpEnd = "";
                    sTmpPeriod = "";
                    sTmpType = "";
                    sTmpAmount = "";
    
                    if(sTmpDeductions.indexOf("|") > -1){
                        sTmpBegin = sTmpDeductions.substring(0,sTmpDeductions.indexOf("|"));
                        sTmpDeductions = sTmpDeductions.substring(sTmpDeductions.indexOf("|")+1);
                    }
                    
                    if(sTmpDeductions.indexOf("|") > -1){
                        sTmpEnd = sTmpDeductions.substring(0,sTmpDeductions.indexOf("|"));
                        sTmpDeductions = sTmpDeductions.substring(sTmpDeductions.indexOf("|")+1);
                    }
                    
                    if(sTmpDeductions.indexOf("|") > -1){
                        sTmpPeriod = sTmpDeductions.substring(0,sTmpDeductions.indexOf("|"));
                        sTmpDeductions = sTmpDeductions.substring(sTmpDeductions.indexOf("|")+1);
                    }
                
                    if(sTmpDeductions.indexOf("|") > -1){
                       sTmpType = sTmpDeductions.substring(0,sTmpDeductions.indexOf("|"));
                       sTmpDeductions = sTmpDeductions.substring(sTmpDeductions.indexOf("|")+1);
                    }
    
                    if(sTmpDeductions.indexOf("$") > -1){
                        sTmpAmount = sTmpDeductions.substring(0,sTmpDeductions.indexOf("$"));
                        sTmpDeductions = sTmpDeductions.substring(sTmpDeductions.indexOf("$")+1);
                    }
    
                    Element deductionElem = deductionsElem.addElement("Deduction");
                    deductionElem.addElement("Begin").addText(sTmpBegin);
                    deductionElem.addElement("End").addText(sTmpEnd);
                    deductionElem.addElement("Period").addText(sTmpPeriod);
                    deductionElem.addElement("Type").addText(sTmpType);
                    deductionElem.addElement("Amount").addText(sTmpAmount);
                }
            }            
        }
        
        return deductionsElem;
    }
%>

<%
    String sEditSalaryUid = checkString(request.getParameter("EditSalaryUid")),
           sPersonId      = checkString(request.getParameter("PersonId"));

    String sBegin        = checkString(request.getParameter("begin")),
           sEnd          = checkString(request.getParameter("end")),
           sContractUid  = checkString(request.getParameter("contractUid")),
           sSalary       = checkString(request.getParameter("salary")),
           sSalaryPeriod = checkString(request.getParameter("salaryPeriod")),
             sComment      = checkString(request.getParameter("comment"));
    
    // xmls
    String sBenefits    = checkString(request.getParameter("benefits")),
           sBonuses     = checkString(request.getParameter("bonuses")),
           sOtherIncome = checkString(request.getParameter("otherIncome")),
           sDeductions  = checkString(request.getParameter("deductions"));
                    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** saveSalary.jsp *****************");
        Debug.println("sEditSalaryUid : "+sEditSalaryUid);
        Debug.println("sPersonId      : "+sPersonId);
        Debug.println("sBegin         : "+sBegin);
        Debug.println("sEnd           : "+sEnd);
        Debug.println("sContractUid   : "+sContractUid);
        Debug.println("sSalary        : "+sSalary);
        Debug.println("sSalaryPeriod  : "+sSalaryPeriod);
        Debug.println("sComment       : "+sComment+"\n");

        // xmls
        Debug.println("sBenefits    : "+sBenefits);
        Debug.println("sBonuses     : "+sBonuses);
        Debug.println("sOtherIncome : "+sOtherIncome);
        Debug.println("sDeductions  : "+sDeductions+"\n");
    }

    Salary salary = new Salary();
    salary.personId = Integer.parseInt(sPersonId);
    String sMessage = "";
    
    if(sEditSalaryUid.length() > 0){
        salary.setUid(sEditSalaryUid);
    }
    else{
        salary.setUid("-1");
        salary.setCreateDateTime(getSQLTime());
    }
    
    salary.contractUid = sContractUid;

    if(sBegin.length() > 0){
        salary.begin = ScreenHelper.stdDateFormat.parse(sBegin);
    }
    if(sEnd.length() > 0){
        salary.end = ScreenHelper.stdDateFormat.parse(sEnd);
    }
    
    if(sSalary.length() > 0){
        salary.salary = Float.parseFloat(sSalary);
    }
    
    salary.salaryPeriod = sSalaryPeriod;
    
    ///////////////////////////////////////////////////////////////////////////
    /// XML-BOUND DATA ////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////        
    if(sBenefits.length() > 0){                
        org.dom4j.Document document = DocumentHelper.createDocument();
        Element benefitsElem = document.addElement("Benefits");
        benefitsToXml(sBenefits,benefitsElem);
        salary.benefits = benefitsElem.asXML();
    }
    
    if(sBonuses.length() > 0){                
        org.dom4j.Document document = DocumentHelper.createDocument();
        Element bonusesElem = document.addElement("Bonuses"); 
        bonusesToXml(sBonuses,bonusesElem);
        salary.bonuses = bonusesElem.asXML();
    }
    
    if(sOtherIncome.length() > 0){                
        org.dom4j.Document document = DocumentHelper.createDocument();
        Element otherIncomesElem = document.addElement("OtherIncomes"); 
        otherIncomesToXml(sOtherIncome,otherIncomesElem);
        salary.otherIncome = otherIncomesElem.asXML();
    }
    
    if(sDeductions.length() > 0){                
        org.dom4j.Document document = DocumentHelper.createDocument();
        Element deductionsElem = document.addElement("Deductions"); 
        deductionsToXml(sDeductions,deductionsElem);
        salary.deductions = deductionsElem.asXML();
    }
    ///////////////////////////////////////////////////////////////////////////
    
    salary.comment = sComment;
    salary.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    salary.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = salary.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=salary.getUid()%>"
}