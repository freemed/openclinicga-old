<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="org.dom4j.DocumentException,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSalaryUid = checkString(request.getParameter("SalaryUid"));

    // form data
    String sBonusType       = checkString(request.getParameter("bonusType")),
           sBonusPercentage = checkString(request.getParameter("bonusPercentage")),
           sBegin           = checkString(request.getParameter("begin")),
           sEnd             = checkString(request.getParameter("end")),
           sSalary          = checkString(request.getParameter("salary")),
           sSalaryPeriod    = checkString(request.getParameter("salaryPeriod"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** calculateBonus.jsp ****************");
        Debug.println("sSalaryUid       : "+sSalaryUid);
        Debug.println("sBonusType       : "+sBonusType);
        Debug.println("sBonusPercentage : "+sBonusPercentage);
        Debug.println("sBegin           : "+sBegin);
        Debug.println("sEnd             : "+sEnd);
        Debug.println("sSalary          : "+sSalary);
        Debug.println("sSalaryPeriod    : "+sSalaryPeriod+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    double bonus = -1d;
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
            if(sBonusType.length() > 0){
                // 4 - bonusPercentage
                if(sBonusPercentage.length() > 0){
                    double bonusPercentage = Double.parseDouble(sBonusPercentage);
                    
                    // TODO : country specific calculation 
                    if(sBonusType.equalsIgnoreCase("type1")){
                        bonus = (1 * salary * bonusPercentage) / 100;
                    }
                    else if(sBonusType.equalsIgnoreCase("type2")){
                        bonus = (2 * salary * bonusPercentage) / 100;
                    }
                    else if(sBonusType.equalsIgnoreCase("type3")){
                        bonus = (3 * salary * bonusPercentage) / 100;
                    }    
                    
                    sValue = (bonus>-1?(deci.format(bonus)).replace(",","."):"");
                }
                else{
                    sMsg = "<font color='red'>No 'bonusPercentage' specified for bonus-calculation</font>";
                    Debug.println("WARNING : No bonusPercentage specified");
                }
            }
            else{
                sMsg = "<font color='red'>No 'bonusType' specified for bonus-calculation</font>";
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