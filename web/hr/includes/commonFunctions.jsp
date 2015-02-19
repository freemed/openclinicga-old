<%@page import="be.mxs.common.util.system.ScreenHelper,
                java.util.*"%>                            
                
<%!
    //--- YEARS BETWEEN ---------------------------------------------------------------------------
    public long yearsBetween(final Calendar startDate, final Calendar endDate){
        int yearCount = 0;
        Calendar cursor = (Calendar)startDate.clone();   
                  
        // test
        Calendar test = (Calendar)startDate.clone();
        test.add(Calendar.YEAR,1); 
        if(test.after(endDate)) return yearCount;

        // next full unit
        Calendar nfu = (Calendar)startDate.clone();

        // count        
        while(cursor.getTimeInMillis() < endDate.getTimeInMillis()){   
            cursor.add(Calendar.YEAR,1);   

            // next full unit
            nfu.add(Calendar.YEAR,1); 
            if(!nfu.after(endDate)) yearCount++;
            else                    break;
        }
         
        return yearCount;   
    }  
    
    //--- MONTHS BETWEEN --------------------------------------------------------------------------
    public long monthsBetween(final Calendar startDate, final Calendar endDate){
        int monthCount = 0;
        Calendar cursor = (Calendar)startDate.clone();
         
        // test
        Calendar test = (Calendar)startDate.clone();
        test.add(Calendar.MONTH,1); 
        if(test.after(endDate)) return monthCount;

        // next full unit
        Calendar nfu = (Calendar)startDate.clone();
        
        // count        
        while(cursor.getTimeInMillis() < endDate.getTimeInMillis()){   
            cursor.add(Calendar.MONTH,1);   

            // next full unit
            nfu.add(Calendar.MONTH,1); 
            if(!nfu.after(endDate)) monthCount++;
            else                    break;
        }
         
        return monthCount;   
    }  
    
    //--- DAYS BETWEEN ----------------------------------------------------------------------------
    public long daysBetween(final Calendar startDate, final Calendar endDate){
        int dayCount = 0;
        Calendar cursor = (Calendar)startDate.clone();   
         
        // test
        Calendar test = (Calendar)startDate.clone();
        test.add(Calendar.DATE,1); 
        if(test.after(endDate)) return dayCount;

        // next full unit
        Calendar nfu = (Calendar)startDate.clone();
        
        // count        
        while(cursor.getTimeInMillis() < endDate.getTimeInMillis()){   
            cursor.add(Calendar.DATE,1);   

            // next full unit
            nfu.add(Calendar.DATE,1); 
            if(!nfu.after(endDate)) dayCount++;
            else                    break;
        }
         
        return dayCount;   
    }  

    //--- CALCULATE PERIOD ------------------------------------------------------------------------
    public String calculatePeriod(java.util.Date startDate, java.util.Date endDate, String sWebLanguage){
        String sPeriod = "";
        
        // check
        if(startDate==null || endDate==null){
            return sPeriod;
        }

        // init
        Calendar startCal = Calendar.getInstance(),
                 endCal   = Calendar.getInstance();
        startCal.setTime(startDate);
        endCal.setTime(endDate);

        // calculate
        long totalYears = yearsBetween(startCal,endCal);
        
        startCal.add(Calendar.YEAR,(int)totalYears); // proceed
        long totalMonths = monthsBetween(startCal,endCal);

        startCal.add(Calendar.MONTH,(int)totalMonths); // proceed
        long totalDays = daysBetween(startCal,endCal);
                    
        // format
        if(totalYears > 0){
            if(totalYears==1){
                sPeriod+= totalYears+" "+ScreenHelper.getTran("web","year",sWebLanguage).toLowerCase();
            }
            else{
                sPeriod+= totalYears+" "+ScreenHelper.getTran("web","years",sWebLanguage).toLowerCase();
            }
        }
        
        if(totalMonths > 0){
            if(sPeriod.length() > 0) sPeriod+= ", "; // separator

            if(totalMonths==1){
                sPeriod+= totalMonths+" "+ScreenHelper.getTran("web","month",sWebLanguage).toLowerCase();
            }
            else{
                sPeriod+= totalMonths+" "+ScreenHelper.getTran("web","months",sWebLanguage).toLowerCase();
            }
        }       
        
        if(totalDays > 0){
            if(sPeriod.length() > 0) sPeriod+= ", "; // separator

            if(totalDays==1){
                sPeriod+= totalDays+" "+ScreenHelper.getTran("web","day",sWebLanguage).toLowerCase();
            }
            else{
                sPeriod+= totalDays+" "+ScreenHelper.getTran("web","days",sWebLanguage).toLowerCase();
            }
        }        

        return sPeriod;
    }
%>

<script>  
  <%-- ALERT DIALOG --%>
  function alertDialog(labelType,labelId){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alertDialogAjax(labelType,labelId); // Opera          
    }
  }

  <%-- ALERT DIALOG DIRECT TEXT --%>
  function alertDialogDirectText(sMsg){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelValue="+sMsg;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alert(sMsg); // Opera          
    } 
  }

  <%-- ALERT DIALOG AJAX --%>
  function alertDialogAjax(labelType,labelId){
    var url = "<c:url value='/_common/getLabel.jsp'/>?ts=<%=ScreenHelper.getTs()%>&LabelType="+labelType+"&LabelId="+labelId;
    new Ajax.Request(url,{
      onSuccess:function(resp){
        var label = resp.responseText.trim();
        if(label.length > 0){
          label = label.unhtmlEntities();
          alertDialogDirectText(label);
        }
        else{
          alert(labelType+"."+labelId);
        }
      }
    });  
  }

  <%-- YESNO DIALOG --%>
  function yesnoDialog(labelType,labelId,callbackFunction){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts="+new Date().getTime()+"&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);

      if(callbackFunction){
    	if(answer==true) callbackFunction.call(this);
      }
      else return answer;
    }
    else{   
      var url = "<c:url value='/_common/getLabel.jsp'/>?ts=<%=ScreenHelper.getTs()%>&LabelType="+labelType+"&LabelId="+labelId;
      new Ajax.Request(url,{
        async:false,
        onSuccess:function(resp){
          var label = resp.responseText.trim();
          if(label.length > 0){
            label = label.unhtmlEntities();
        	if(yesnoDialogDirectText(label)){
              callbackFunction.call(this);
        	}
          }
          else{
        	if(window.confirm(labelType+"."+labelId)){
              callbackFunction.call(this);
        	}
          }
        }
      });
    }
  }
  
  <%-- YESNO DIALOG DIRECT TEXT --%>
  function yesnoDialogDirectText(labelText){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts="+new Date().getTime()+"&labelValue="+labelText;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelText);          
    }
    
    return answer; // FF
  }
    
  <%-- YESNO DELETE DIALOG --%>
  function yesnoDeleteDialog(){
	<%
	    /*
        String sAPPTITLE = ScreenHelper.checkString((String)session.getAttribute("activeProjectTitle"));
	    if(sAPPTITLE.length()==0) sAPPTITLE = "Openclinic";
	    
        String sWebLanguage = ScreenHelper.checkString((String)session.getAttribute(sAPPTITLE+"WebLanguage"));
        */
	%>
	return yesnoDialogDirectText("<%=ScreenHelper.getTranNoLink("Web","areYouSureToDelete",sWebLanguage)%>");	
  }
</script>