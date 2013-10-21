<%@ page import="be.openclinic.hr.SalaryCalculation,
                 be.openclinic.hr.SalaryCalculationCode,
                 be.mxs.common.util.system.HTMLEntities,
                 java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    /////////////////////////////// INFO : exists in commonFunctions //////////////////////////////
	//--- DAYS BETWEEN (params are Dates) ---------------------------------------------------------
	public int daysBetween(final java.util.Date startDate, final java.util.Date endDate){
		Calendar startCal = Calendar.getInstance();
		startCal.setTime(startDate);
		
		Calendar endCal = Calendar.getInstance();
		endCal.setTime(endDate);
		
	    int dayCount = 0;
	    Calendar cursor = (Calendar)startCal.clone();   
	     
	    // test
	    Calendar test = (Calendar)startCal.clone();
	    test.add(Calendar.DATE,1); 
	    if(test.after(endCal)) return dayCount;
	
	    // next full unit
	    Calendar nfu = (Calendar)startCal.clone();
	    
	    // count        
	    while(cursor.getTimeInMillis() < endCal.getTimeInMillis()){   
	        cursor.add(Calendar.DATE,1);   
	
	        // next full unit
	        nfu.add(Calendar.DATE,1); 
	        if(!nfu.after(endCal)) dayCount++;
	        else                    break;
	    }
	     
	    return dayCount;   
	}  
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<%
    String sPersonId = checkString(request.getParameter("PersonId")),
           sMonth    = checkString(request.getParameter("Month")); // MM/yyyy 

    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***** hr/ajax/salaryCalculations/getSalaryCalculations.jsp *****");
        Debug.println("sPersonId : "+sPersonId);
        Debug.println("sMonth    : "+sMonth+"\n"); // month/year
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>
     
<%   
    StringBuffer sHtml = new StringBuffer();
    
    // days in specified month (and year)
    Calendar cal = Calendar.getInstance();
    cal.set(Calendar.MONTH,Integer.parseInt(sMonth.split("\\/")[0]));
    cal.set(Calendar.YEAR,Integer.parseInt(sMonth.split("\\/")[1]));
    int daysInMonth = cal.getMaximum(Calendar.DAY_OF_MONTH);

    // object that contains search criteria
    SalaryCalculation searchObj = new SalaryCalculation();
    searchObj.personId = Integer.parseInt(sPersonId);
    searchObj.begin = ScreenHelper.stdDateFormat.parse("01/0"+sMonth);
    searchObj.end   = ScreenHelper.stdDateFormat.parse(daysInMonth+"/0"+sMonth);
    
    List calculations = SalaryCalculation.getList(searchObj);
    Debug.println("Found "+calculations.size()+" calculations for personId:"+sPersonId+" in month:"+sMonth);
    
    SimpleDateFormat usDateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm:ss",new java.util.Locale("en","US"));    
    SalaryCalculation calculation;
    SalaryCalculationCode code;
    String sLabel;
    
    DecimalFormat doubleFormat = new DecimalFormat("0.0");
    float totalDurationHours = 0.0f;
    int totalDurationDays = 0;
    
    for(int i=0; i<calculations.size(); i++){
        calculation = (SalaryCalculation)calculations.get(i);
        totalDurationDays = daysBetween(calculation.begin,calculation.end)+1;

        // "x more codes.." when no space to list all codes
        int moreCodes = calculation.codes.size()-5;
        int maxCodes = 6;
        if(moreCodes > 2) maxCodes = 5;
        
        // list codes
        String sCodes = "";
        totalDurationHours = 0.0f;
        for(int j=0; j<calculation.codes.size() && j<maxCodes; j++){
            code = (SalaryCalculationCode)calculation.codes.get(j);
            
            // limit length of label
            sLabel = code.code+" - "+getTranNoLink("salaryCalculationCode",code.code,sWebLanguage);
            if(sLabel.length() > 18){
            	sLabel = sLabel.substring(0,18)+"..";
            }
            
            sCodes+= "<i>"+(code.duration<10?"&nbsp;&nbsp;":"")+doubleFormat.format(code.duration)+"h : "+sLabel+"</i><br>";
            totalDurationHours+= code.duration;
        }
        
        // "x more codes.." when no space to list all codes
        if(moreCodes > 0){
        	sCodes+= moreCodes+" "+getTranNoLink("web","more",sWebLanguage)+"..";
        }
        
        Debug.println(" --> Found "+calculation.codes.size()+" codes for calculation:"+calculation.getUid());
        
        // one salary calculation (containing many codes)
        sHtml.append("\n<item>")
	          .append("\n<id>"+calculation.getUid()+"</id>")
	          .append("\n<source>"+calculation.source+"</source>")
	          .append("\n<type>"+calculation.type+"</type>")
	          .append("\n<codes>"+sCodes+"</codes>")
	          .append("\n<totalDurationHours>"+doubleFormat.format(totalDurationHours)+"</totalDurationHours>")
	          .append("\n<totalDurationDays>"+totalDurationDays+"</totalDurationDays>") // always one
	          .append("\n<begin>"+usDateFormat.format(calculation.begin)+"</begin>")
	          .append("\n<end>"+usDateFormat.format(calculation.end)+"</end>")
        .append("\n</item>");
    }
    
    out.print(sHtml);
    
    Debug.println("--> sHtml : "+sHtml);
%>




