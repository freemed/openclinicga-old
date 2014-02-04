<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="org.dom4j.DocumentException,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSalaryUid = checkString(request.getParameter("SalaryUid"));

    // form data
    String sOtherIncomeType = checkString(request.getParameter("otherIncomeType")),
           sBegin           = checkString(request.getParameter("begin")),
           sEnd             = checkString(request.getParameter("end")),
           sSalary          = checkString(request.getParameter("salary")),
           sSalaryPeriod    = checkString(request.getParameter("salaryPeriod"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************ calculateOtherIncome.jsp *************");
        Debug.println("sSalaryUid       : "+sSalaryUid);
        Debug.println("sOtherIncomeType : "+sOtherIncomeType);
        Debug.println("sBegin           : "+sBegin);
        Debug.println("sEnd             : "+sEnd);
        Debug.println("sSalary          : "+sSalary);
        Debug.println("sSalaryPeriod    : "+sSalaryPeriod+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    double otherIncome = -1d;
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
            if(sOtherIncomeType.length() > 0){
                // TODO : country specific calculation 
                if(sOtherIncomeType.equalsIgnoreCase("type1")){
                    otherIncome = (1 * salary) / 100;
                }
                else if(sOtherIncomeType.equalsIgnoreCase("type2")){
                    otherIncome = (2 * salary) / 100;
                }
                else if(sOtherIncomeType.equalsIgnoreCase("type3")){
                    otherIncome = (3 * salary) / 100;
                }    
                
                sValue = (otherIncome>-1?(deci.format(otherIncome)).replace(",","."):"");
            }
            else{
                sMsg = "<font color='red'>No 'otherIncomeType' specified for otherIncome-calculation</font>";
                Debug.println("WARNING : No bonusType specified");
            }
        }
        else{
            sMsg = "<font color='red'>No 'salary' specified for otherIncome-calculation</font>";
            Debug.println("WARNING : No salary specified");
        }
    }    
    else{
        sMsg = "<font color='red'>No config 'fiscalCountry' configured for otherIncome-calculation</font>";
        Debug.println("WARNING : No config 'fiscalCountry' configured");
    }    
%>

{
  "value":"<%=sValue%>",
  "message":"<%=sMsg%>"
}