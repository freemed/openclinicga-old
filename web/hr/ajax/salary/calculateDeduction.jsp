<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="org.dom4j.DocumentException,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSalaryUid = checkString(request.getParameter("SalaryUid"));

    // form data
    String sDeductionType = checkString(request.getParameter("deductionType")),
           sBegin         = checkString(request.getParameter("begin")),
           sEnd           = checkString(request.getParameter("end")),
           sSalary        = checkString(request.getParameter("salary")),
           sSalaryPeriod  = checkString(request.getParameter("salaryPeriod"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* calculateDeduction.jsp **************");
        Debug.println("sSalaryUid     : "+sSalaryUid);
        Debug.println("sDeductionType : "+sDeductionType);
        Debug.println("sBegin         : "+sBegin);
        Debug.println("sEnd           : "+sEnd);
        Debug.println("sSalary        : "+sSalary);
        Debug.println("sSalaryPeriod  : "+sSalaryPeriod+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    double deduction = -1d;
    String sValue = "", sMsg = "";

    // 1 - fiscalCountry
    String sFiscalCountry = MedwanQuery.getInstance().getConfigParam("fiscalCountry","");
    
    if(sFiscalCountry.length() > 0){
        Debug.println("Using config 'fiscalCountry' : "+sFiscalCountry);
        DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigParam("priceFormat","0.00"));

        // 2 - salary        
        if(sSalary.length() > 0){
            double salary = Double.parseDouble(sSalary);
                    
            // 3 - bonusType
            if(sDeductionType.length() > 0){
                // TODO : country specific calculation 
                if(sDeductionType.equalsIgnoreCase("type1")){
                    deduction = (1 * salary) / 100;
                }
                else if(sDeductionType.equalsIgnoreCase("type2")){
                    deduction = (2 * salary) / 100;
                }
                else if(sDeductionType.equalsIgnoreCase("type3")){
                    deduction = (3 * salary) / 100;
                }    
                
                sValue = (deduction>-1?(deci.format(deduction)).replace(",","."):"");
            }
            else{
                sMsg = "<font color='red'>No 'deductionType' specified for bonus-calculation</font>";
                Debug.println("WARNING : No bonusType specified");
            }
        }
        else{
            sMsg = "<font color='red'>No 'salary' specified for bonus-calculation</font>";
            Debug.println("WARNING : No salary specified");
        }
    }    
    else{
        sMsg = "<font color='red'>No config 'fiscalCountry' configured for bonus-calculation</font>";
        Debug.println("WARNING : No config 'fiscalCountry' configured");
    }    
%>

{
  "value":"<%=sValue%>",
  "message":"<%=sMsg%>"
}