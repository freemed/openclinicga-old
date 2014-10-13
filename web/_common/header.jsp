<%@page import="be.openclinic.id.FingerPrint,
                be.mxs.common.util.system.Picture,
                be.openclinic.id.Barcode"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<script>
  function setButtonCheckDropDown(){
    //if(!bSaveHasNotChanged){
      if(checkSaveButton()){
        //target.click();
      }
    //}
  }
    
  function checkDropdown(evt){
    if(window.myButton){
      lastevt = evt || window.event;
      var target;
      if(lastevt.target){
        target = lastevt.target;
      }
      else{
        target = lastevt.srcElement;
      }
      if((target.id.indexOf("menu") > -1) || (target.id.indexOf("ddIcon") > -1)){
        setButtonCheckDropDown();
      }
    }
  }
</script>

<table width="100%" border="0" cellspacing="0" cellpadding="0" class="topline">
    <tr>
        <%-- ADMIN HEADER --%>
        <td width="100%" valign='top' align="left">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <%
                    if(!"datacenter".equalsIgnoreCase((String)session.getAttribute("edition"))){
                        %>
			                <tr onmousedown="checkDropdown(event);">
			                    <td class="menu_bar" style="vertical-align:top;" colspan="3">
			                        <%ScreenHelper.setIncludePage(customerInclude("/_common/dropdownmenu.jsp"),pageContext);%>
			                    </td>			
			                </tr>
			                <tr>
			                    <td align="left">
			                        <%ScreenHelper.setIncludePage(customerInclude("/_common/searchPatient.jsp"),pageContext);%>
			                    </td>
			                </tr>
	                    <%
	                }
	            %>
            </table>
        </td>
    </tr>
</table>

<div style="position:absolute;right:5px;top:27px;width:400px;">
<%
    if(!"datacenter".equalsIgnoreCase((String)session.getAttribute("edition"))){        
        String sVersion = checkString((String)session.getAttribute("ProjectVersion"));
        //Debug.println("--> sVersion : "+sVersion);

        String bgi = "";
        String sEdition = MedwanQuery.getInstance().getConfigString("edition","");
        if("datacenter".equalsIgnoreCase(sEdition)){
       	    bgi = "projects/datacenter/_img/projectlogo.jpg";
        }
        else if("openlab".equalsIgnoreCase(sEdition)){
       	    bgi = "projects/openlab/_img/projectlogo.jpg";
        }
        else if("openpharmacy".equalsIgnoreCase(sEdition)){
       	    bgi = "_img/openpharmacyprojectlogo.jpg";
        }
        else if("openinsurance".equalsIgnoreCase(sEdition)){
       	    bgi = "_img/openinsuranceprojectlogo.jpg";
        }
        else{
        	// default
		    bgi = "/"+sAPPDIR+"_img/themes/"+(sUserTheme.length()==0?"default":sUserTheme)+"/logo.png";
        }

        %>        
            <div style="float:right;">
                <%        		
			        // only show logo-div when logo-file was found
			   	    if(bgi.length() > 0){
			   	   	    String sLogoUrl = MedwanQuery.getInstance().getConfigString("baseDirectory")+"/"+bgi;
			   	   	    //Debug.println("--> sLogoUrl : "+sLogoUrl);
			   	   	    
			   	   	    java.io.File file = new java.io.File(sLogoUrl); 
			   	   	    if(file.exists() && file.isFile()){ 
			   	   	   	    bgi = sCONTEXTPATH+"/"+bgi;   	   	   	    
			   	    	    %><div class="logo" style="background:url('<%=bgi%>');"></div><%
			   	   	    }
			   	   	    else{
			   	   	    	Debug.println("INFO : Configured project-logo-file for edition '"+sEdition+"' does not exist : '"+sLogoUrl+"'");
			   	   	    }
			   	    }
                %> 
                       		    			
				<div class="topicones">
				    <%
				        if(MedwanQuery.getInstance().getConfigString("TestEdition").equals("1")){
				            %><img style="float:right;" src="<c:url value='/_img/stamp_test.gif'/>" alt=""/><%
				        }
				        else{
				            String sWorkTimeMessage = checkString((String)session.getAttribute("WorkTimeMessage"));
				            if(sWorkTimeMessage.length() > 0){
				                %><img style="float:right;" src="<c:url value='/_img/men_at_work.gif'/>" alt="<%=(getTran("Web.Occup","medwan.common.workuntil",sWebLanguage)+" "+sWorkTimeMessage)%>"/><%
				            }
				        }
		
		                String sTmpPersonid = checkString(request.getParameter("personid"));
		                if(sTmpPersonid.length()==0){
		                    sTmpPersonid = checkString(request.getParameter("PersonID"));
		                }
		                
		                if(sTmpPersonid.length() > 0){
		                	try{
		                		sTmpPersonid=Integer.parseInt(sTmpPersonid)+"";
		                	}
		                	catch(Exception e){
		                		e.printStackTrace();
		                	}
		                    boolean bFingerPrint = FingerPrint.exists(Integer.parseInt(sTmpPersonid)),
		                            bPicture     = Picture.exists(Integer.parseInt(sTmpPersonid)),
		                            bBarcode     = Barcode.exists(Integer.parseInt(sTmpPersonid));
		                    if(!bFingerPrint){
		                        %> <a class="imglink" href="javascript:enrollFingerPrint();"><img border='0' src="<c:url value='/_img/themes/default/fingerprint.png'/>" alt="<%=getTranNoLink("web","enrollFingerPrint",sWebLanguage)%>"/></a><%
		                    }
		                    if(!bBarcode){
		                        %> <a class="imglink" href="javascript:printPatientCard();"><img border='0' src="<c:url value='/_img/themes/default/badge.png'/>" alt="<%=getTranNoLink("web","printPatientCard",sWebLanguage)%>"/></a><%
		                    }
		                    if(!bPicture){
		                        %> <a class="imglink" href="javascript:storePicture();"><img border='0' src="<c:url value='/_img/themes/default/camera.png'/>" alt="<%=getTranNoLink("web","loadPicture",sWebLanguage)%>"/></a><%
		                    }
		                }
		            %>
				</div>
        	</div>        
	        <div class="version"><%=sVersion%></div>
        <%
    }
%>
</div>