<%@page import="be.openclinic.finance.Prestation"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.manageprestations","all",activeUser)%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=sJSSORTTABLE%>
<%!
    private StringBuffer addCategory(int iTotal,String sCategoryName,String sPrice,String sWebLanguage){
        StringBuffer sTmp = new StringBuffer();
        sTmp.append("<tr id='rowCategory"+iTotal+"'>")
             .append("<td class=\"admin2\">")
             .append("<a href='javascript:deleteCategory(rowCategory"+iTotal+")'><img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web.Occup","medwan.common.delete",sWebLanguage) + "' border='0'></a> ")
             .append("</td>")
             .append("<td class='admin2'>&nbsp;" + getTranNoLink("insurance.types",sCategoryName,sWebLanguage) + "</td>")
             .append("<td class='admin2'>&nbsp;" + sPrice + "</td>")
             .append("<td class='admin2'>")
             .append("</td>")
            .append("</tr>");

        return sTmp;
    }
%>
<%
    String sAction = checkString(request.getParameter("Action"));
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
    String msg = "";
    String sCategory = "";
    int iCategoryTotal = 0;

    String sFindPrestationUid   = checkString(request.getParameter("FindPrestationUid")),
           sFindPrestationCode  = checkString(request.getParameter("FindPrestationCode")),
           sFindPrestationDescr = checkString(request.getParameter("FindPrestationDescr")),
           sFindPrestationType  = checkString(request.getParameter("FindPrestationType")),
           sFindPrestationPrice = checkString(request.getParameter("FindPrestationPrice"));

    String sEditPrestationUid   = checkString(request.getParameter("EditPrestationUid")),
           sEditPrestationCode  = checkString(request.getParameter("EditPrestationCode")),
           sEditPrestationCodeAlias  = checkString(request.getParameter("EditPrestationCodeAlias")),
           sEditPrestationDescr = checkString(request.getParameter("EditPrestationDescr")),
           sEditPrestationType  = checkString(request.getParameter("EditPrestationType")),
           sEditPrestationUpdatetime  = checkString(request.getParameter("EditPrestationUpdatetime")),
           sEditPrestationCategories  = checkString(request.getParameter("EditPrestationCategories")),
           sEditPrestationFamily  = checkString(request.getParameter("EditPrestationFamily")),
           sEditPrestationInvoiceGroup  = checkString(request.getParameter("EditPrestationInvoiceGroup")),
           sEditPrestationMfpPercentage  = checkString(request.getParameter("EditPrestationMfpPercentage")),
           sEditPrestationMfpAdmissionPercentage  = checkString(request.getParameter("EditPrestationMfpAdmissionPercentage")),
           sEditPrestationAnesthesiaPercentage  = checkString(request.getParameter("EditPrestationAnesthesiaPercentage")),
           sEditPrestationSupplement  = checkString(request.getParameter("EditPrestationSupplement")),
           sEditPrestationClass  = checkString(request.getParameter("EditPrestationClass")),
           sEditPrestationVariablePrice = checkString(request.getParameter("EditPrestationVariablePrice")),
           sEditPrestationInactive  = checkString(request.getParameter("EditPrestationInactive")),
           sEditPrestationPrice = checkString(request.getParameter("EditPrestationPrice")),
           sEditPrestationFlag1 = checkString(request.getParameter("EditPrestationFlag1")),
           sEditPrestationServiceUid = checkString(request.getParameter("EditPrestationServiceUid")),
		   sEditCareProvider = checkString(request.getParameter("EditCareProvider"));
		if(sEditPrestationVariablePrice.length()==0){
			sEditPrestationVariablePrice="0";
		}
	   try{
		   sEditPrestationPrice =""+Double.parseDouble(sEditPrestationPrice);
	   }
	   catch(Exception e){
		   sEditPrestationPrice="0";
	   }

	   try{
		   sEditPrestationSupplement =""+Double.parseDouble(sEditPrestationSupplement);
	   }
	   catch(Exception e){
		   sEditPrestationSupplement="0";
	   }

	   if(!sEditPrestationInactive.equals("1")){
		   sEditPrestationInactive="0";
	   }
	   try{
		   sEditPrestationMfpPercentage =""+Integer.parseInt(sEditPrestationMfpPercentage);
	   }
	   catch(Exception e){
		   sEditPrestationMfpPercentage="0";
	   }
	   try{
		   sEditPrestationMfpAdmissionPercentage =""+Double.parseDouble(sEditPrestationMfpAdmissionPercentage);
	   }
	   catch(Exception e){
		   sEditPrestationMfpAdmissionPercentage="0";
	   }
	   try{
		   sEditPrestationAnesthesiaPercentage =""+Double.parseDouble(sEditPrestationAnesthesiaPercentage);
	   }
	   catch(Exception e){
		   sEditPrestationAnesthesiaPercentage="0";
	   }
	   String sEditPrestationServiceName="";
	   if(sEditPrestationServiceUid.length()>0){
		   Service service = Service.getService(sEditPrestationServiceUid);
		   if(service!=null){
			   sEditPrestationServiceName=service.getLabel(sWebLanguage);
		   }
	   }

    // DEBUG //////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        System.out.println("\n### mngPrestations ############################");
        System.out.println("# sAction              : "+sAction);
        System.out.println("# sFindPrestationUid   : "+sFindPrestationUid);
        System.out.println("# sFindPrestationCode  : "+sFindPrestationCode);
        System.out.println("# sFindPrestationDescr : "+sFindPrestationDescr);
        System.out.println("# sFindPrestationType  : "+sFindPrestationType);
        System.out.println("# sFindPrestationPrice : "+sFindPrestationPrice+"\n");
        System.out.println("# sEditPrestationUid   : "+sEditPrestationUid);
        System.out.println("# sEditPrestationCode  : "+sEditPrestationCode);
        System.out.println("# sEditPrestationDescr : "+sEditPrestationDescr);
        System.out.println("# sEditPrestationType  : "+sEditPrestationType);
        System.out.println("# sEditPrestationCategories  : "+sEditPrestationCategories);
        System.out.println("# sEditPrestationFamily: "+sEditPrestationFamily);
        System.out.println("# sEditPrestationInvoiceGroup: "+sEditPrestationInvoiceGroup);
        System.out.println("# sEditPrestationPrice : "+sEditPrestationPrice+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    //--- SAVE ------------------------------------------------------------------------------------
    // delete all categories for the specified prestation,
    // then add all selected categories (those in request)
    if(sAction.equals("save")){
        Prestation prestation;

        if(sEditPrestationUid.equals("-1")){
            // new prestation
            prestation = new Prestation();
            prestation.setUpdateUser(activeUser.userid);
        }
        else{
            // existing prestation
            prestation = Prestation.get(sEditPrestationUid);
        }

        // store prestation
        prestation.setCode(sEditPrestationCode);
        prestation.setDescription(sEditPrestationDescr);
        prestation.setType(sEditPrestationType);
        prestation.setCategories(sEditPrestationCategories);
        prestation.setPrice(Double.parseDouble(sEditPrestationPrice));
        prestation.setReferenceObject(new ObjectReference(sEditPrestationFamily,sEditPrestationCodeAlias)); 
        prestation.setInvoiceGroup(sEditPrestationInvoiceGroup);
        prestation.setMfpPercentage(Integer.parseInt(sEditPrestationMfpPercentage));
        prestation.setMfpAdmissionPercentage(Double.parseDouble(sEditPrestationMfpAdmissionPercentage));
        prestation.setAnesthesiaPercentage(Double.parseDouble(sEditPrestationAnesthesiaPercentage));
        prestation.setSupplement(Double.parseDouble(sEditPrestationSupplement));
        prestation.setInactive(Integer.parseInt(sEditPrestationInactive));
        prestation.setPerformerUid(sEditCareProvider);
        prestation.setVariablePrice(Integer.parseInt(sEditPrestationVariablePrice));
        prestation.setPrestationClass(sEditPrestationClass);
        prestation.setServiceUid(sEditPrestationServiceUid);
        prestation.setFlag1(sEditPrestationFlag1);
        try{
        	prestation.setUpdateDateTime(new SimpleDateFormat("dd/MM/yyyy").parse(sEditPrestationUpdatetime));
        }
        catch(Exception e){}
		System.out.println("1 prestation.getDescription()="+prestation.getDescription());
		System.out.println("1 sEditPrestationDescr="+sEditPrestationDescr);
        prestation.store();
		System.out.println("2 prestation.getDescription()="+prestation.getDescription());
		System.out.println("2 sEditPrestationDescr="+sEditPrestationDescr);
        //activeUser.addPrestation(prestation.getUid());
        sEditPrestationUid = prestation.getUid();
        msg = getTran("web","dataIsSaved",sWebLanguage);
        sAction = "search";
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){
        Prestation.delete(sEditPrestationUid);
        msg = getTran("web","dataIsDeleted",sWebLanguage);
        sAction = "search";
    }

    // keydown
    String sOnKeyDown, sBackFunction;
    if(sAction.equals("edit") || sAction.equals("new")){
        sOnKeyDown = "onkeydown='if(enterEvent(event,13)){savePrestation();}'";
        sBackFunction = "doBack();";
    }
    else{
        sOnKeyDown = "onkeydown='if(enterEvent(event,13)){searchPrestation();}'";
        sBackFunction = "doBackToMenu();";
    }
%>

<form id="transactionForm" name="transactionForm" onsubmit="return false;" method="post" <%=sOnKeyDown%>>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="FindPrestationUid">
    <input type="hidden" name="EditPrestationUid" value="<%=sEditPrestationUid%>">
    <input type="hidden" name="EditPrestationCategories">
    <%=writeTableHeader("Web.manage","ManagePrestations",sWebLanguage," doBackToMenu();")%>
    <%-- SEARCH FIELDS --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web","code",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindPrestationCode" size="20" maxlength="50" value="<%=sFindPrestationCode%>">
            </td>
        </tr>
        <tr>
            <td><%=getTran("web","description",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindPrestationDescr" size="80" maxlength="80" value="<%=sFindPrestationDescr%>">
            </td>
        </tr>
        <tr>
            <td><%=getTran("web","type",sWebLanguage)%></td>
            <td>
                <select class="text" name="FindPrestationType">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("prestation.type",sFindPrestationType,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
            <td><%=getTran("web","price",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindPrestationPrice" size="10" maxlength="8" onKeyUp="if(!isNumber(this)){this.value='';}" value="<%=sFindPrestationPrice%>">&nbsp;<%=sCurrency%>
            </td>
        </tr>
        <tr>
            <td><%=getTran("web","sort",sWebLanguage)%></td>
            <td>
                <select class="text" name="FindPrestationSort">
                    <option value="OC_PRESTATION_CODE"><%=getTran("web","code",sWebLanguage) %></option>
                    <option value="OC_PRESTATION_DESCRIPTION"><%=getTran("web","description",sWebLanguage) %></option>
                    <option value="OC_PRESTATION_PRICE"><%=getTran("web","price",sWebLanguage) %></option>
                </select>
            </td>
        </tr>
       <tr>
           <td/>
           <td>
               <input type="button" class="button" name="editButton" value="<%=getTranNoLink("Web","Search",sWebLanguage)%>" onClick="transactionForm.Action.value='search';searchPrestation();">&nbsp;
               <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","New",sWebLanguage)%>" onClick="newPrestation();">&nbsp;
               <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearSearchFields();">&nbsp;
               <input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onClick="<%=sBackFunction%>">
               <input type="button" class="button" name="test" value="+" onClick="document.getElementById('divFindRecords').style.height='350px';">
               <input type="button" class="button" name="test" value="-" onClick="document.getElementById('divFindRecords').style.height='150px';">
           </td>
       </tr>
    </table>
    <br>
	    <div style="height:150px;" class="searchResults" id="divFindRecords"></div>
    <%
        //--- SHOW ONE PRESTATION IN DETAIL ----------------------------------------------------------
        if(sAction.equals("edit") || sAction.equals("new")){
            Prestation prestation;
            String sCategoryHtml = "";

            // load specified prestation
            if(sAction.equals("edit")){
            	MedwanQuery.getInstance().getObjectCache().removeObject("prestation", sEditPrestationUid);
            	prestation = Prestation.get(sEditPrestationUid);
                if(prestation!=null){
                	sEditPrestationServiceUid=prestation.getServiceUid();
                	if(sEditPrestationServiceUid!=null && sEditPrestationServiceUid.length()>0){
                		Service service = Service.getService(sEditPrestationServiceUid);
                		if(service!=null){
                			sEditPrestationServiceName=service.getLabel(sWebLanguage);
                		}
                	}
                }
            }
            else{
                // ..or create a new one
                prestation = new Prestation();
            }
        	if(prestation.getUpdateDateTime()!=null){
        		sEditPrestationUpdatetime=new SimpleDateFormat("dd/MM/yyyy").format(prestation.getUpdateDateTime());
        	}
        	else {
        		sEditPrestationUpdatetime=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
        	}

            if (checkString(prestation.getCategories()).length()>0){
                sCategory = checkString(prestation.getCategories());
                String[] aCategories = prestation.getCategories().split(";");
                String[] aCategory;

                for (int i=0;i<aCategories.length;i++){
                    aCategory = aCategories[i].split("=");
                    
                    if (aCategory.length==2){
                        sCategoryHtml += addCategory(iCategoryTotal,aCategory[0],aCategory[1],sWebLanguage);
                        iCategoryTotal++;
                    }
                }
            }

            %>
               <br>
                <%-- EDIT FIELDS ----------------------------------------------------------------%>
                <table width="100%" cellspacing="1" cellpadding="0" class="list">
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>">ID</td>
                        <td class="admin2"><%=checkString(prestation.getUid())%></td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","validfrom",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                        	<%=writeDateField("EditPrestationUpdatetime","transactionForm",sEditPrestationUpdatetime,sWebLanguage)%>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","code",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationCode" size="20" maxlength="50" value="<%=checkString(prestation.getCode())%>">
                        </td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","code.alias",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationCodeAlias" size="80" maxlength="250" value="<%=prestation.getReferenceObject()==null?"":checkString(prestation.getReferenceObject().getObjectUid())%>">
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","description",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationDescr" size="80" maxlength="80" value="<%=checkString(prestation.getDescription())%>">
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","type",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <select class="text" name="EditPrestationType">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelect("prestation.type",checkString(prestation.getType()),sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%
                        // prevent 0 from showing for new records
                        String sPrice = prestation.getPrice()+"";
                        if(sEditPrestationUid.equals("-1")){
                            double price = prestation.getPrice();
                            if(price==0) sPrice = "";
                        }
                    %>
                    <tr>
                        <td class="admin"><%=getTran("web","family",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationFamily" size="<%=MedwanQuery.getInstance().getConfigInt("maxprestationfamilysize",10) %>" maxlength="<%=MedwanQuery.getInstance().getConfigInt("maxprestationfamilysize",10)-2 %>" value="<%=prestation.getReferenceObject()==null?"":prestation.getReferenceObject().getObjectType()%>">
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","invoicegroup",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationInvoiceGroup" size="10" maxlength="8" value="<%=prestation.getInvoiceGroup()==null?"":prestation.getInvoiceGroup()%>">
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","class",sWebLanguage)+(MedwanQuery.getInstance().getConfigInt("cnarEnabled",0)==1?" *":"")%></td>
                        <td class="admin2">
                            <select class="text" name="EditPrestationClass">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelect("prestation.class",checkString(prestation.getPrestationClass()),sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%
                    	if(MedwanQuery.getInstance().getConfigInt("cnarEnabled",0)==1){
                    %>
	                    <tr>
	                        <td class="admin"><%=getTran("web","cnarclass",sWebLanguage)%> *</td>
	                        <td class="admin2">
	                            <select class="text" name="EditPrestationFlag1">
	                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
	                                <%=ScreenHelper.writeSelect("prestation.cnarclass",prestation.getFlag1(),sWebLanguage)%>
	                            </select>
	                        </td>
	                    </tr>
	                <%
                    	}
	                %>
                    <tr>
                        <td class="admin"><%=getTran("web","defaultprice",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationPrice" size="10" maxlength="10" value="<%=sPrice%>" onKeyup="if(!isNumber(this)){this.value='';}">&nbsp;<%=sCurrency%>
							<%if(MedwanQuery.getInstance().getConfigInt("allowVariablePrestationPrices",0)==1){ %>
                            	&nbsp;<%=getTran("web","variable",sWebLanguage)%> <input type="checkbox" class="text" value="1" name="EditPrestationVariablePrice" id="EditPrestationVariablePrice" <%=prestation!=null && prestation.getVariablePrice()==1?"checked":"" %>/>
                            <%} %>
                        </td>
                    </tr>
                    <%
                    	if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){
                    %>
	                    <tr>
	                        <td class="admin"><%=getTran("web","mfppercentage",sWebLanguage)%></td>
	                        <td class="admin2">
	                            <input type="text" class="text" name="EditPrestationMfpPercentage" size="4" maxlength="3" value="<%=prestation.getMfpPercentage()%>" onKeyup="if(!isNumber(this)){this.value='';}">%
	                        </td>
	                    </tr>
                    <%
                    		if(MedwanQuery.getInstance().getConfigInt("enableMFPAdmission",0)==1){
                    %>
		                    <tr>
		                        <td class="admin"><%=getTran("web","mfpadmissionpercentage",sWebLanguage)%></td>
		                        <td class="admin2">
		                            <input type="text" class="text" name="EditPrestationMfpAdmissionPercentage" size="4" maxlength="3" value="<%=prestation.getMfpAdmissionPercentage()%>" onKeyup="if(!isNumber(this)){this.value='';}">%
		                        </td>
		                    </tr>
                    <%
                    		}
                    	}
                    %>
                    <%
                    	if(MedwanQuery.getInstance().getConfigString("anesthesiaPrestationUid","").length()>0){
                    %>
                    <tr>
                        <td class="admin"><%=getTran("web","anesthesiapercentage",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationAnesthesiaPercentage" size="4" maxlength="3" value="<%=prestation.getAnesthesiaPercentage()%>" onKeyup="if(!isNumber(this)){this.value='';}">%
                        </td>
                    </tr>
                    <%
                    	}
                    %>
                    <tr>
                        <td class="admin"><%=getTran("web","supplement",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationSupplement" size="10" maxlength="10" value="<%=prestation.getSupplement()%>" onKeyup="if(!isNumber(this)){this.value='';}">&nbsp;<%=sCurrency%>
                        </td>
                    </tr>
                    <tr>
			            <td class='admin'><%=getTran("web","invoicingcareprovider",sWebLanguage)%></td>
			            <td class='admin2'>
			            	<select class='text' name='EditCareProvider' id='EditCareProvider'>
			            		<option value=''></option>
					            <%
					            	Vector users = UserParameter.getUserIds("invoicingcareprovider", "on");
					            	SortedMap usernames = new TreeMap();
					            	for(int n=0;n<users.size();n++){
					            		User user = User.get(Integer.parseInt((String)users.elementAt(n)));
					            		usernames.put(user.person.lastname.toUpperCase()+", "+user.person.firstname,user.userid);
					            	}
				            		String sSelectedValue=checkString(prestation.getPerformerUid());
					            	Iterator i = usernames.keySet().iterator();
					            	while(i.hasNext()){
					            		String username=(String)i.next();
					            		out.println("<option value='"+usernames.get(username)+"'"+(sSelectedValue.equals(usernames.get(username))?" selected":"")+">"+username+"</option>");
					            	}
					            %>
			            	</select>
			            </td>
			        </tr>
			       <tr id="Service">
			           <td class="admin"><%=getTran("Web","linked.service",sWebLanguage)%></td>
			           <td class='admin2'>
			               <input type="hidden" name="EditPrestationServiceUid" id="EditPrestationServiceUid" value="<%=sEditPrestationServiceUid%>">
			               <input class="text" type="text" name="EditPrestationServiceName" id="EditPrestationServiceName" readonly size="<%=sTextWidth%>" value="<%=sEditPrestationServiceName%>" onblur="">
			               <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('EditPrestationServiceUid','EditPrestationServiceName');">
			               <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditPrestationServiceUid').value='';document.getElementById('EditPrestationServiceName').value='';">
			           </td>
			       </tr>
                    
                    <tr>
                        <td class="admin"><%=getTran("web","inactive",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="checkbox" class="text" name="EditPrestationInactive" value="1" <%=prestation.getInactive()==1?"checked":"" %>/>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","categories",sWebLanguage)%></td>
                        <td class="admin2">
                            <%
                                prestation.getCategories();
                            %>
                            <table id="tblCategories" width="100%" cellspacing="1" cellpadding="0" class="list">
                                <%-- HEADER --%>
                                <tr class="admin">
                                    <td width="40"/>
                                    <td><%=getTran("system.manage","category",sWebLanguage)%></td>
                                    <td><%=getTran("web","price",sWebLanguage)%></td>
                                    <td/>
                                </tr>
                                <tr>
                                    <td class="admin"/>
                                    <td class="admin">
                                        <select name="EditCategoryName" class="text">
                                            <%=ScreenHelper.writeSelect("insurance.types","",sWebLanguage)%>
                                        </select>
                                    </td>
                                    <td class="admin">
                                        <input type="text" class="text" name="EditCategoryPrice" size="10" onKeyUp="if(!isNumber(this))this.value = '';"> <%=sCurrency%>
                                    </td>
                                    <td class="admin">
                                        <input type="button" class="button" name="addCategoryButton" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onClick="addCategory();">&nbsp;
                                    </td>
                                </tr>
                                <%=sCategoryHtml%>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"/>
                        <td class="admin2">
                            <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="savePrestation();"></button>
                            <button class="button" name="saveButton" onclick="savePrestation();"><%=getTranNoLink("accesskey","save",sWebLanguage)%></button>&nbsp;
                            <%
                                // no delete button for new prestation
                                if(!sEditPrestationUid.equals("-1")){
                                    %><input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deletePrestation('<%=prestation.getUid()%>');">&nbsp;<%
                                }
                            %>
                        </td>
                    </tr>
                </table>
                <br>
                <%
                // display message
                if(msg.length() > 0){
                    %><%=msg%><br><%
                }
        }
    %>
</form>
<script>
  var iCategoryIndex = <%=iCategoryTotal%>;
  var sCategory = "<%=sCategory%>";
  var editCategoryRowid = "";

  function newPrestation(){
    clearSearchFields();
    if(document.getElementById("EditPrestationVariablePrice")) document.getElementById("EditPrestationVariablePrice").checked=false;
    transactionForm.EditPrestationPrice="";
    transactionForm.EditPrestationUid.value = "-1";
    transactionForm.Action.value = "new";
    transactionForm.submit();
  }

  function editPrestation(sPrestationUid){
    transactionForm.EditPrestationUid.value = sPrestationUid;
    transactionForm.Action.value = "edit";
    transactionForm.submit();
  }

  function deletePrestation(sPrestationUid){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>');

    if(answer==1){
      transactionForm.EditPrestationUid.value = sPrestationUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }
  function searchPrestation(){
    document.getElementById('divFindRecords').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
    var today = new Date();
    var desc=transactionForm.FindPrestationDescr.value;
    var params = 'FindPrestationCode=' + transactionForm.FindPrestationCode.value
          +"&FindPrestationDescr="+transactionForm.FindPrestationDescr.value
          +"&FindPrestationType="+transactionForm.FindPrestationType.value
          +"&FindPrestationSort="+transactionForm.FindPrestationSort.value
          +"&FindPrestationPrice="+transactionForm.FindPrestationPrice.value;
     var url= '<c:url value="/system/managePrestationsFind.jsp"/>?ts=' + today;
    new Ajax.Request(url,{
            method: "POST",
            parameters: params,
            onSuccess: function(resp){
                $('divFindRecords').innerHTML=resp.responseText;
            }
        }
    );  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/managePrestations.jsp";
  }

  function doBackToMenu(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  function clearSearchFields(){
    transactionForm.FindPrestationUid.value = "";
    transactionForm.FindPrestationCode.value = "";
    transactionForm.FindPrestationDescr.value = "";
    transactionForm.FindPrestationType.value = "";
    transactionForm.FindPrestationPrice.value = "";
  }

  function savePrestation(){
    if(transactionForm.EditPrestationCode.value.length > 0 && transactionForm.EditPrestationDescr.value.length > 0 &&
       transactionForm.EditPrestationType.value.length > 0 <%=MedwanQuery.getInstance().getConfigInt("cnarEnabled",0)==1?"&& transactionForm.EditPrestationClass.value.length > 0 && transactionForm.EditPrestationFlag1.value.length > 0":""%>){
      if(transactionForm.EditPrestationUid.value.length==0){
          transactionForm.EditPrestationUid.value = "-1";
      }

      if (transactionForm.EditCategoryPrice.value.length>0){
          addCategory();
      }

      if (sCategory.length<3){
          sCategory = "";
      }

      transactionForm.EditPrestationCategories.value = sCategory;
      var temp = Form.findFirstElement(transactionForm);//for ff compatibility
      transactionForm.saveButton.style.visibility = "hidden";
      transactionForm.Action.value = "save";

      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
    else{
      if(transactionForm.EditPrestationCode.value.length==0){
        transactionForm.EditPrestationCode.focus();
      }
      else if(transactionForm.EditPrestationDescr.value.length==0){
        transactionForm.EditPrestationDescr.focus();
      }
      else if(transactionForm.EditPrestationType.value.length==0){
        transactionForm.EditPrestationType.focus();
      }
      else if(transactionForm.EditPrestationPrice.value.length==0){
        transactionForm.EditPrestationPrice.focus();
      }
      <%
      	if(MedwanQuery.getInstance().getConfigInt("cnarEnabled",0)==1){
      %>
	    else if(transactionForm.EditPrestationClass.value.length==0){
    	    transactionForm.EditPrestationClass.focus();
        }
	    else if(transactionForm.EditPrestationFlag1.value.length==0){
    	    transactionForm.EditPrestationFlag1.focus();
        }
      <%
      	}
      %>

      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=dataMissing";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.manage","dataMissing",sWebLanguage)%>');

    }
  }

  function addCategory(){
    if(isAtLeastOneCategoryFieldFilled()){
      iCategoryIndex++;

      sCategory+=transactionForm.EditCategoryName.value+"="
                               +transactionForm.EditCategoryPrice.value+";";
      var tr;
      tr = tblCategories.insertRow(tblCategories.rows.length);
      tr.id = "rowCategory"+iCategoryIndex;

      var td = tr.insertCell(0);
      td.innerHTML = "<a href='javascript:deleteCategory(rowCategory"+iCategoryIndex+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web.Occup","medwan.common.delete",sWebLanguage)%>' border='0'></a>";
      tr.appendChild(td);

      td = tr.insertCell(1);
      td.innerHTML = "&nbsp;"+transactionForm.EditCategoryName.value;
      tr.appendChild(td);

      td = tr.insertCell(2);
      td.innerHTML = "&nbsp;"+transactionForm.EditCategoryPrice.value;
      tr.appendChild(td);

      td = tr.insertCell(3);
      td.innerHTML = "&nbsp;";
      tr.appendChild(td);

      setCellStyle(tr);

      clearCategoryFields();
    }
    return true;
  }

  function isAtLeastOneCategoryFieldFilled(){
    if(transactionForm.EditCategoryName.value != "") return true;
    if(transactionForm.EditCategoryPrice.value != "") return true;
    return false;
  }

  function clearCategoryFields(){
    transactionForm.EditCategoryName.selectedIndex = -1;
    transactionForm.EditCategoryPrice.value = "";
  }

  function deleteCategory(rowid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalitiesIE = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

    var answer;
    if(window.showModalDialog){
      answer = window.showModalDialog(popupUrl,"",modalitiesIE);
    }
    else{
      answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }

    if(answer==1){
      sCategory = deleteRowFromArrayString(sCategory,rowid.id.substring(11,rowid.id.length-1));
      tblCategories.deleteRow(rowid.rowIndex);
      clearCategoryFields();
    }
  }

  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split(";");
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        array.splice(i,1);
      }
    }
    var sTmp = array.join(";");

    if (!sTmp.endsWith(";")){
        sTmp += ";";
    }
    return sTmp;
  }

  function setCellStyle(row){
    for(var i=0; i<row.cells.length; i++){
      row.cells[i].style.color = "#333333";
      row.cells[i].style.fontFamily = "arial";
      row.cells[i].style.fontSize = "10px";
      row.cells[i].style.fontWeight = "normal";
      row.cells[i].style.textAlign = "left";
      row.cells[i].style.paddingLeft = "5px";
      row.cells[i].style.paddingRight = "1px";
      row.cells[i].style.paddingTop = "1px";
      row.cells[i].style.paddingBottom = "1px";
      row.cells[i].style.backgroundColor = "#E0EBF2";
    }
  }
  
  function searchService(serviceUidField,serviceNameField){
      openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
      document.getElementById(serviceNameField).focus();
  }


  <%
  if (sAction.length()>0){
    out.print("  searchPrestation();");
  }
  %>
</script>
<%=writeJSButtons("transactionForm","saveButton")%>