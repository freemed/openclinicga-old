<%@include file="/includes/SingletonContainer.jsp"%>
<%@page import="be.openclinic.finance.Insurar,
                be.openclinic.finance.InsuranceCategory,
                java.util.Vector,
                net.admin.Label"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/ajaxRequirements.jsp"%>
<%=checkPermission("system.manageinsurars","all",activeUser)%>
<%=sJSSORTTABLE%>
<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="ajaxFloatingLoader" style="position:absolute;width:250px;height:30px;visibility:hidden;">
    <table width="100%" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center;padding:20px;">
                <img src="<c:url value='/_img/ajax-loader.gif'/>"><br><br>
                <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>
<%-- End Floating layer -------------------------------------------------------------------------%>
<%!
    //--- ADD CATEGORY ----------------------------------------------------------------------------
    private String addCategory(int iTotal, String sCatName, String sCatLabel, String sCatPatientPercentage, String sWebLanguage){
        return "<tr id='rowCategory"+iTotal+"' class='"+(iTotal%2==0?"list":"list1")+"'>"+
                "<td>"+
                 "<a href='#' onclick='deleteCategory(rowCategory"+iTotal+");'>"+
                  "<img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' alt='"+getTranNoLink("Web","delete",sWebLanguage)+"' border='0'>"+
                 "</a>&nbsp;"+
                 "<a href='#' onclick='editCategory(rowCategory"+iTotal+");'>"+
                  "<img src='"+sCONTEXTPATH+"/_img/icon_edit.gif' alt='"+getTranNoLink("Web","edit",sWebLanguage)+"' border='0'>"+
                 "</a>&nbsp;"+
                "</td>"+
               "<td>"+sCatName+"</td>"+
               "<td>"+sCatLabel+"</td>"+
               "<td>"+sCatPatientPercentage+"%</td>"+
               "<td>"+(100-Integer.parseInt(sCatPatientPercentage))+"%</td>"+
               "<td><div id='catDiv_"+sCatName+"'></div></td>"+
               "<td>&nbsp;</td>"+
              "</tr>";
    }
%>
<%
    String sAction = checkString(request.getParameter("Action"));
    String msg = "", sCategoriesJS = "";
    int catCount = 0;

    String sFindInsurarId       = checkString(request.getParameter("FindInsurarId")),
           sFindInsurarName     = checkString(request.getParameter("FindInsurarName")),
           sFindInsurarLanguage = checkString(request.getParameter("FindInsurarLanguage")),
           sFindInsurarContact  = checkString(request.getParameter("FindInsurarContact")),
           sEditInsurarId       = checkString(request.getParameter("EditInsurarId")),
           sEditInsurarType       = checkString(request.getParameter("EditInsurarType"));

    // DEBUG //////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        System.out.println("\n### mngInsurars ###################################");
        System.out.println("# sAction             : "+sAction);
        System.out.println("# sEditInsurarId      : "+sEditInsurarId+"\n");
        System.out.println("# sFindInsurarId      : "+sFindInsurarId);
        System.out.println("# sFindInsurarName    : "+sFindInsurarName);
        System.out.println("# FindInsurarLanguage : "+sFindInsurarLanguage);
        System.out.println("# FindInsurarContact  : "+sFindInsurarContact+"\n");
        System.out.println("# EditInsurarType     : "+sEditInsurarType+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    //--- SAVE ------------------------------------------------------------------------------------
    // delete all categories for the specified insurar,
    // then add all selected categories (those in request)
    if(sAction.equals("save")){
    	if(request.getParameter("EditInsurarExtra")==null){
			String[] supportedlanguages=MedwanQuery.getInstance().getConfigString("supportedLanguages","nl,fr,en").split(",");
			for(int n=0;n<supportedlanguages.length;n++){
	    		Label.delete("patientsharecoverageinsurance",sEditInsurarId,supportedlanguages[n]);
			}
    	}
    	else {
    		Label label = new Label();
    		label.showLink="0";
    		label.type="patientsharecoverageinsurance";
    		label.id=sEditInsurarId;
    		label.updateUserId=activeUser.userid;
    		label.value=checkString(request.getParameter("EditInsurarName"));
			String[] supportedlanguages=MedwanQuery.getInstance().getConfigString("supportedLanguages","nl,fr,en").split(",");
			for(int n=0;n<supportedlanguages.length;n++){
	    		label.language=supportedlanguages[n];
	    		label.saveToDB();
			}
    	}
		reloadSingleton(session);
        // categories
        String sCategoriesToSave   = checkString(request.getParameter("selectedCategories")),
               sCategoriesToDelete = checkString(request.getParameter("categoriesToDelete"));

        //*** delete categories ***
        if(sCategoriesToDelete.length() > 0){
            StringTokenizer tokenizer = new StringTokenizer(sCategoriesToDelete,"$");
            String sCategoryLetter;
            while(tokenizer.hasMoreTokens()){
                sCategoryLetter = tokenizer.nextToken();
                Insurar.deleteCategory(sEditInsurarId,sCategoryLetter);
            }
        }

        //*** save insurar ***
        Insurar insurar;

        if(sEditInsurarId.equals("-1")){
            // new insurar
            insurar = new Insurar();
            int iServerId = MedwanQuery.getInstance().getConfigInt("serverid",1);
            insurar.setUid(iServerId+".-1");
        }
        else{
            // existing insurar
            Insurar.deleteCategories(sEditInsurarId);
            insurar = Insurar.get(sEditInsurarId);
        }

        insurar.setName(checkString(request.getParameter("EditInsurarName")));
        insurar.setContact(checkString(request.getParameter("EditInsurarContact")));
        insurar.setLanguage(checkString(request.getParameter("EditInsurarLanguage")));
        insurar.setOfficialName(checkString(request.getParameter("EditInsurarOfficialName")));
        insurar.setContactPerson(checkString(request.getParameter("EditInsurarContactPerson")));
        insurar.setType(checkString(request.getParameter("EditInsurarType")));

        //*** save categories ***
        if(sCategoriesToSave.length() > 0){
            String catName, catLabel, catPatientShare, sOneCategory, catUid;
            Vector categories = new Vector();
            InsuranceCategory category;

            StringTokenizer catsTokenizer = new StringTokenizer(sCategoriesToSave,"$");
            StringTokenizer catTokenizer;
            while(catsTokenizer.hasMoreTokens()){
                sOneCategory = catsTokenizer.nextToken();
                catTokenizer = new StringTokenizer(sOneCategory,"£");

                if(catTokenizer.hasMoreTokens()){
                    catName         = catTokenizer.nextToken();
                    catLabel        = catTokenizer.nextToken();
                    catPatientShare = catTokenizer.nextToken();
                    catUid          = catTokenizer.nextToken();

                    // remove quotes from label
                    catLabel = catLabel.replaceAll("'","");
                    catLabel = catLabel.replaceAll("\"","");

                    category = new InsuranceCategory(catUid,catName,catLabel,catPatientShare,insurar.getUid());
                    categories.add(category);
                }
            }

            insurar.setInsuraceCategories(categories);
        }

        insurar.store(Integer.parseInt(activeUser.userid));
        sEditInsurarId = insurar.getUid();
        msg = getTran("web","dataIsSaved",sWebLanguage);
        sFindInsurarName=insurar.getName();
        sAction = "search";
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){
        Insurar.delete(sEditInsurarId);
        msg = getTran("web","dataIsDeleted",sWebLanguage);
    }
%>
<script>
  var categoriesArray = new Array();
  var categoryIds = new Array();
</script>
<%
    String sOnKeyDown = "", sBackFunction = "doBack();";
    if(!sAction.equals("edit") && !sAction.equals("new")){
        sOnKeyDown = "onkeydown='if(enterEvent(event,13)){searchInsurar();}'";
        sBackFunction = "doBackToMenu();";
    }
%>
<form id="transactionForm" name="transactionForm" method="post" <%=sOnKeyDown%> onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="FindInsurarId">
    <input type="hidden" name="EditInsurarId" value="<%=sEditInsurarId%>">

    <%=writeTableHeader("Web.manage","ManageInsurars",sWebLanguage," doBackToMenu();")%>

    <%-- SEARCH FIELDS --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr height="22">
            <td class="menu">
                &nbsp;<%=getTran("web","insurar",sWebLanguage)%>&nbsp;&nbsp;<input type="text" class="text" name="FindInsurarName" size="30" maxChars="255" value="<%=sFindInsurarName%>">

                <%-- BUTTONS --%>
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","Search",sWebLanguage)%>" onClick="searchInsurar();">&nbsp;
                <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","New",sWebLanguage)%>" onClick="newInsurar();">&nbsp;
                <input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onClick="<%=sBackFunction%>">
            </td>
        </tr>
    </table>
    <%
        //--- SHOW FOUND INSURARS -----------------------------------------------------------------
        if(sAction.equals("search")){
            Vector foundInsurars = Insurar.getInsurarsByName(sFindInsurarName);
            int insurarCount = 0;

            if(foundInsurars.size() > 0){
                %>
                    <br>

                    <table id="searchresults" cellpadding="0" cellspacing="0" width="100%" class="sortable" style="border:1px solid #cccccc;">
                        <%-- header --%>
                        <tr class="admin">
                            <td width="25">&nbsp;</td>
                            <td width="150"><%=getTran("system.manage","insurarName",sWebLanguage)%></td>
                            <td width="200"><%=getTran("system.manage","insurarOfficialName",sWebLanguage)%></td>
                            <td width="*"><%=getTran("system.manage","insurarContact",sWebLanguage)%></td>
                            <td width="100"><%=getTran("system.manage","insurarLanguage",sWebLanguage)%></td>
                        </tr>

                        <tbody>
                            <%
                                String sTranDelete = getTran("Web","delete",sWebLanguage);
                                String sClass = "1", sContact, sLanguage;
                                Insurar insurar;

                                for(int i=0; i<foundInsurars.size(); i++){
                                    insurar = (Insurar)foundInsurars.get(i);
                                    insurarCount++;

                                    sContact = checkString(insurar.getContact());
                                    //sContact = sContact.replaceAll("\r\n","<br>");

                                    // language
                                    sLanguage = checkString(insurar.getLanguage());
                                    if(sLanguage.length() > 0){
                                        sLanguage = getTran("web.language",sLanguage,sWebLanguage);
                                    }

                                    // alternate row-style
                                    if(sClass.equals("")) sClass = "1";
                                    else                  sClass = "";

                                    %>
                                        <tr class="list<%=sClass%>" onmouseover="this.className='list_select';this.style.cursor='hand';" onmouseout="this.className='list<%=sClass%>';this.style.cursor='default';">
                                            <td>
                                                <a href="#" onclick="deleteInsurar('<%=insurar.getUid()%>');"><img src='<c:url value="/_img/icon_delete.gif"/>' border='0' alt="<%=sTranDelete%>"></a>
                                            </td>
                                            <td class="hand" onClick="editInsurar('<%=insurar.getUid()%>');"><%=checkString(insurar.getName())%></td>
                                            <td class="hand" onClick="editInsurar('<%=insurar.getUid()%>');"><%=checkString(insurar.getOfficialName())%></td>
                                            <td class="hand" onClick="editInsurar('<%=insurar.getUid()%>');"><%=sContact%></td>
                                            <td class="hand"  onClick="editInsurar('<%=insurar.getUid()%>');"><%=sLanguage%></td>
                                        </tr>
                                    <%
                                    if(insurarCount>50){
                                        break;
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                <%
            }

            // number of found records
            if(insurarCount > 50){
                %>&gt;50 <%=getTran("web","recordsFound",sWebLanguage)%><%
            }
            else if(insurarCount > 0){
                %><%=insurarCount%> <%=getTran("web","recordsFound",sWebLanguage)%><%
            }
            else{
                %><br><%=getTran("web","noRecordsFound",sWebLanguage)%><%
            }

            // display message
            if(msg.length() > 0){
                %><br><%=msg%><br><%
            }
        }
        //--- SHOW ONE INSURAR IN DETAIL ----------------------------------------------------------
        else if(sAction.equals("edit") || sAction.equals("new")){
            StringBuffer sCategoryHtml = new StringBuffer();
            Insurar insurar = new Insurar();

            // load specified insurar
            if(sAction.equals("edit")){
                insurar = Insurar.get(sEditInsurarId);

                Vector insurarCategories = insurar.getInsuraceCategories();
                InsuranceCategory insuranceCategory;
                String catName, catLabel, catShare, catUid;

                for(int i=0; i<insurarCategories.size(); i++){
                    insuranceCategory = (InsuranceCategory)insurarCategories.get(i);
                    catName  = insuranceCategory.getCategory();
                    catLabel = insuranceCategory.getLabel();
                    catShare = insuranceCategory.getPatientShare();
                    catUid   = insuranceCategory.getUid();

                    sCategoriesJS+= "rowCategory"+catCount+"="+catName+"£"+catLabel+ "£"+catShare+"£"+catUid+"$";
                    sCategoryHtml.append(addCategory(catCount,catName,catLabel,catShare,sWebLanguage));
                    catCount++;
                }
            }
            %>
                <br>

                <%-- EDIT FIELDS ----------------------------------------------------------------%>
                <table width="100%" cellspacing="1" cellpadding="0" class="list">
                    <%-- INSURAR NAME --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","id",sWebLanguage)%></td>
                        <td class="admin2">
                            <%=insurar.getUid()%>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("system.manage","insurarname",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditInsurarName" size="50" maxChars="255" value="<%=checkString(insurar.getName())%>">
                        </td>
                    </tr>
                    <%-- INSURAR OFFICIAL NAME --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("system.manage","insurarOfficialName",sWebLanguage)%>&nbsp;*&nbsp;</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditInsurarOfficialName" size="50" maxChars="255" value="<%=checkString(insurar.getOfficialName())%>">
                        </td>
                    </tr>
                    <%-- INSURAR CONTACT --%>
                    <tr>
                        <td class="admin"><%=getTran("system.manage","insurarContact",sWebLanguage)%></td>
                        <td class="admin2">
                            <textArea class="text" name="EditInsurarContact" cols="50" rows="5" onKeyup="limitChars(this,255);"><%=checkString(insurar.getContact())%></textArea>
                        </td>
                    </tr>
                    <%-- INSURAR LANGUAGE --%>
                    <tr>
                        <td class="admin"><%=getTran("system.manage","insurarLanguage",sWebLanguage)%></td>
                        <td class="admin2">
                            <%
                                String sEditInsurarLanguage = checkString(insurar.getLanguage());


                                String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
                                if(sSupportedLanguages.length()==0){
                                    sSupportedLanguages = "nl,fr";
                                }
                            %>
                            <select class="text" name="EditInsurarLanguage">
                                <option><%=getTran("web","choose",sWebLanguage)%></option>
                                <%
                                    String tmpLang;
                                    StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
                                    while (tokenizer.hasMoreTokens()) {
                                        tmpLang = tokenizer.nextToken();

                                        %><option value="<%=tmpLang%>" <%=(tmpLang.equalsIgnoreCase(sEditInsurarLanguage)?"selected":"")%>><%=getTran("web.language",tmpLang,sWebLanguage)%></option><%
                                    }

                                %>

                            </select>
                        </td>
                    </tr>
                    <%-- type --%>
                    <tr>
                        <td class="admin">
                            <%=getTran("web","tariff",sWebLanguage)%>
                        </td>
                        <td class="admin2">
                            <select class="text" name="EditInsurarType">
                                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%=ScreenHelper.writeSelect("insurance.types",checkString(insurar.getType()),sWebLanguage)%>
                            </select>
                        </td>
                    </tr>
                    <%-- INSURAR CONTACT PERSON --%>
                    <tr>
                        <td class="admin"><%=getTran("system.manage","insurarContactPerson",sWebLanguage)%></td>
                        <td class="admin2">
                            <textArea class="text" name="EditInsurarContactPerson" cols="50" rows="5" onKeyup="limitChars(this,255);"><%=checkString(insurar.getContactPerson())%></textArea>
                        </td>
                    </tr>
                    <%-- INSURAR EXTRA COVERAGE --%>
                    <tr>
                        <td class="admin"><%=getTran("web","complementarycoverage",sWebLanguage)%></td>
                        <%
                        	String sExtraInsurar="";
                        	if(!sEditInsurarId.equalsIgnoreCase(getTranNoLink("patientsharecoverageinsurance",sEditInsurarId,sWebLanguage))){
                        		sExtraInsurar="checked";
                        	}
                        %>
                        <td class="admin2">
                            <input type="checkbox" class="text" name="EditInsurarExtra" <%=sExtraInsurar %>/>
                        </td>
                    </tr>
                    <%-- SELECTED CATEGORIES --%>
                    <tr>
                        <td class="admin"><%=getTran("web.manage","selectedinsurarcategories",sWebLanguage)%></td>
                        <td class="admin2" style="padding:5px;">
                            <table id="tblCategories" width="750" cellspacing="1" cellpadding="0" class="list" onkeydown="if(enterEvent(event,13)){addCategory();}">
                                <%-- HEADER --%>
                                <tr class="admin">
                                    <td width="40">&nbsp;</td>
                                    <td nowrap><%=getTran("system.manage","category",sWebLanguage)%></td>
                                    <td nowrap><%=getTran("system.manage","categoryName",sWebLanguage)%></td>
                                    <td nowrap><%=getTran("system.manage","categoryPatientShare",sWebLanguage)%></td>
                                    <td nowrap><%=getTran("system.manage","categoryInsurarShare",sWebLanguage)%></td>
                                    <td nowrap><%=getTran("system.manage","patientsPerCategory",sWebLanguage)%></td>
                                    <td width="80">&nbsp;</td>
                                </tr>
                                <%-- ADD ROW --%>
                                <tr>
                                    <td class="admin">&nbsp;</td>
                                    <td class="admin">
                                        <select name="EditCategoryName" class="text">
                                            <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                            <%
                                                StringBuffer sAlfabet = new StringBuffer("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
                                                for(int i=0; i<sAlfabet.length(); i++){
                                                    %><option value="<%=sAlfabet.charAt(i)%>"><%=sAlfabet.charAt(i)%></option><%
                                                }
                                            %>
                                        </select>
                                    </td>
                                    <td class="admin">
                                        <input type="text" class="text" name="EditCategoryLabel" size="50">
                                    </td>
                                    <td class="admin">
                                        <input type="text" class="text" name="EditPatientShare" size="4" onKeyUp="if(!isNumber(this))this.value = '';" onBlur="if(!isNumberLimited(this,-1,100))this.value = '';">%
                                    </td>
                                    <td class="admin">&nbsp;</td>
                                    <%-- button : count number of patients per category --%>
                                    <td class="admin">
                                        <input type="button" class="button" name="countPatientsPerCategoryButton" value="<%=getTranNoLink("web","calculate",sWebLanguage)%>" onClick="countPatientsPerCategory('<%=sEditInsurarId%>');">
                                    </td>
                                    <%--- category buttons --%>
                                    <td class="admin">
                                        <input type="button" class="button" name="addCategoryButton" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onClick="addCategory();">&nbsp;
                                        <input type="button" class="button" name="updateCategoryButton" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onClick="updateCategory();">
                                    </td>
                                </tr>
                                <%-- categories --%>
                                <%=sCategoryHtml%>
                            </table>
                            <%-- number of categories found --%>
                            <span id="recordsFoundMsg" style="width:49%;text-align:left;vertical-align:top;">
                                <%
                                    if(catCount > 0){
                                        %>
                                            <%=catCount%> <%=getTran("web.manage","insurarCategoriesFound",sWebLanguage)%>
                                        <%

                                        if(catCount > 20){
                                            // link to top of page
                                            %>
                                                <span style="width:51%;text-align:right;padding-top:2px;">
                                                    <a href="#topp" class="topbutton">&nbsp;</a>
                                                </span>
                                            <%
                                        }
                                    }
                                    else{
                                        %><%=getTran("web.manage","noInsurarCategoriesFound",sWebLanguage)%><%
                                    }
                                %>
                            </span>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"/>
                        <td class="admin2">
                            <%-- BUTTONS --%>
                            <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="saveInsurar();"></button>
                            <button class="button" name="saveButton" onclick="saveInsurar();"><%=getTranNoLink("accesskey","save",sWebLanguage)%></button>&nbsp;

                            <%
                                // no delete button for new insurar
                                if(!sEditInsurarId.equals("-1")){
                                    %><input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deleteInsurar('<%=insurar.getUid()%>');">&nbsp;<%
                                }
                            %>
                            <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="<%=sBackFunction%>">
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
    <%-- hidden fields --%>
    <input type="hidden" name="selectedCategoryIds">
    <input type="hidden" name="selectedCategories">
    <input type="hidden" name="categoriesToDelete">
</form>
<script>
  <%
      if(sAction.equals("edit") || sAction.equals("new")){
          %>transactionForm.EditInsurarName.focus();<%
      }
      else{
          %>transactionForm.FindInsurarName.focus();<%
      }
  %>
  var iIndexCategories = <%=catCount%>;
  var sCategories = "<%=sCategoriesJS%>";
  var editCategoryRowid = "";
  var categoriesToDeleteOnSave = "";
  if(transactionForm.updateCategoryButton!=null) transactionForm.updateCategoryButton.disabled = true;

  initCategoriesArray(sCategories);

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindInsurarName.value = "";
    transactionForm.FindInsurarName.focus();
  }

  <%-- NEW INSURAR --%>
  function newInsurar(){
    transactionForm.FindInsurarName.value = "";
    transactionForm.FindInsurarId.value = "";
    transactionForm.EditInsurarId.value = "-1";
    transactionForm.Action.value = "new";
    transactionForm.submit();
  }

  <%-- EDIT INSURAR --%>
  function editInsurar(sInsurarUid){
    transactionForm.EditInsurarId.value = sInsurarUid;
    transactionForm.Action.value = "edit";
    transactionForm.submit();
  }

  <%-- DELETE INSURAR --%>
  function deleteInsurar(sInsurarUid){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");

    if(answer==1){
      transactionForm.EditInsurarId.value = sInsurarUid;
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }

  <%-- SEARCH INSURAR --%>
  function searchInsurar(){
    //if(transactionForm.FindInsurarName.value.length > 0){
      transactionForm.Action.value = "search";
      transactionForm.submit();
    //}
    //else{
    //  transactionForm.FindInsurarName.focus();
    //}
  }

  <%-- COUNT PATIENTS PER CATEGORY --%>
  function countPatientsPerCategory(insurarUid){
    var catCount = <%=catCount%>;
    if(catCount > 0){
      var url = "<c:url value='/financial/countPatientsPerCategory.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: {
            InsurarUid:insurarUid
          },
          onSuccess: function(resp){
            var sPatientsPerCategory = resp.responseText.trim();
            var counts = sPatientsPerCategory.split("$");
            var letterAndCount;

            var catDivs = document.getElementsByTagName("div");
            var div;
            for(var i=0; i<catDivs.length; i++){
              div = catDivs[i];
              if(div.id.startsWith("catDiv_")){
                div.innerHTML = "0";
              }
            }

            for(var i=0; i<counts.length-1; i++){
              letterAndCount = counts[i];
              $("catDiv_"+letterAndCount.split(":")[0]).innerHTML = letterAndCount.split(":")[1];
            }
          },
          onFailure: function(){
          }
        }
      );
    }
  }

  <%-- ADD CATEGORY --%>
  function addCategory(){
    var catName  = transactionForm.EditCategoryName.value;
    var catLabel = transactionForm.EditCategoryLabel.value;
    var catShare = transactionForm.EditPatientShare.value;

    if(areAllCategoryFieldsFilled()){
      addCategoryToTable(catName,catLabel,catShare,-1);
    }
    else{
           if(catName.length == 0) { transactionForm.EditCategoryName.focus(); }
      else if(catLabel.length == 0){ transactionForm.EditCategoryLabel.focus(); }
      else if(catShare.length == 0){ transactionForm.EditPatientShare.focus(); }

      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=somefieldsareempty";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        if (window.showModalDialog) {
            window.showModalDialog(popupUrl,"",modalities);
        }
        else {
            alert('<%=getTranNoLink("web.manage","somefieldsareempty",sWebLanguage).replaceAll("\n","").replaceAll("\r","")%>');
        }
    }
  }

  <%-- IS AT LEAST ONE CATEGORY FIELD FILLED --%>
  function isAtLeastOneCategoryFieldFilled(){
    var catName  = transactionForm.EditCategoryName.value;
    var catLabel = transactionForm.EditCategoryLabel.value;
    var catShare = transactionForm.EditPatientShare.value;

    if(catName.length > 0 || catLabel.length > 0 || catShare.length > 0){
      return true;
    }
    return false;
  }

  <%-- ARE ALL CATEGORY FIELDS FILLED --%>
  function areAllCategoryFieldsFilled(){
    var catName  = transactionForm.EditCategoryName.value;
    var catLabel = transactionForm.EditCategoryLabel.value;
    var catShare = transactionForm.EditPatientShare.value;

    if(catName.length > 0 && catLabel.length > 0 && catShare.length > 0){
      return true;
    }
    return false;
  }

  <%-- ADD CATEGORY TO TABLE --%>
  function addCategoryToTable(catName,catLabel,catPatientShare,catuid){
    if(!allreadySelected(catName)){
      sCategories+= "rowCategory"+iIndexCategories+"="+catName+"£"+catLabel+"£"+catPatientShare+"£"+catuid+"$";
      var row = tblCategories.insertRow(tblCategories.rows.length);
      row.id = "rowCategory"+iIndexCategories;

      if(tblCategories.rows.length%2==0) row.className = "list1";
      else                               row.className = "list";

      row.style.height = "20px";

      <%-- insert cells in row --%>
      for(var i=0; i<7; i++){
        row.insertCell(i);
      }

      row.cells[0].innerHTML = "<a href='#' onclick='deleteCategory(rowCategory"+iIndexCategories+");'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' border='0'></a>&nbsp;"+
                               "<a href='#' onclick='editCategory(rowCategory"+iIndexCategories+");'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTranNoLink("Web","edit",sWebLanguage)%>' border='0'></a>&nbsp;";
      row.cells[1].innerHTML = catName;

      // remove quotes from label
      catLabel = replaceAll(catLabel,"'","");
      catLabel = replaceAll(catLabel,"\"","");
      row.cells[2].innerHTML = catLabel;

      row.cells[3].innerHTML = catPatientShare+"%";
      row.cells[4].innerHTML = (100-catPatientShare)+"%";
      row.cells[5].innerHTML = "<div id='divCat_"+catName+"'></div>";
      row.cells[6].innerHTML = "&nbsp;";

      iIndexCategories++;
      categoriesArray[categoriesArray.length] = new Array(catName,catLabel,catPatientShare);
      categoryIds.push(catName);
      transactionForm.selectedCategoryIds.value = categoryIds.join(",");

      recordsFoundMsg.innerHTML = (tblCategories.rows.length-2)+" <%=getTranNoLink("web.manage","insurarCategoriesFound",sWebLanguage)%>";

      clearCategoryFields();
    }
    else{
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=categoryExists";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        if (window.showModalDialog) {
            window.showModalDialog(popupUrl,"",modalities);
        }
        else {
            alert('<%=getTranNoLink("web.manage","categoryExists",sWebLanguage).replaceAll("\n","").replaceAll("\r","")%>');
        }

      transactionForm.EditCategoryName.focus();
    }
  }

  <%-- EDIT CATEGORY --%>
  function editCategory(rowid){
    var row = getRowFromArrayString(sCategories,rowid.id);

    transactionForm.EditCategoryName.value = getCelFromRowString(row,0);
    transactionForm.EditCategoryLabel.value = getCelFromRowString(row,1);
    transactionForm.EditPatientShare.value = getCelFromRowString(row,2);

    editCategoryRowid = rowid;
    if(transactionForm.updateCategoryButton!=null) transactionForm.updateCategoryButton.disabled = false;
  }

  <%-- UPDATE CATEGORY --%>
  function updateCategory(){
    if(isAtLeastOneCategoryFieldFilled()){
      var newRow = editCategoryRowid.id+"="+
                   transactionForm.EditCategoryName.value+"£"+
                   transactionForm.EditCategoryLabel.value+"£"+
                   transactionForm.EditPatientShare.value+"£"+
                   transactionForm.EditInsurarId.value+"$";

      sCategories = replaceRowInArrayString(sCategories,newRow,editCategoryRowid.id);
      sCategories = sCategories.replace("\r"," ").replace("\n"," ");

      <%-- update table object --%>
      var row = tblCategories.rows[editCategoryRowid.rowIndex];
      row.cells[0].innerHTML = "<a href='#' onclick='deleteCategory("+editCategoryRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("web","delete",sWebLanguage)%>' border='0'></a> "+
                               "<a href='#' onclick='editCategory("+editCategoryRowid.id+")'><img src='<%=sCONTEXTPATH%>/_img/icon_edit.gif' alt='<%=getTran("web","edit",sWebLanguage)%>' border='0'></a>";

      row.cells[1].innerHTML = transactionForm.EditCategoryName.value;
      row.cells[2].innerHTML = transactionForm.EditCategoryLabel.value;
      row.cells[3].innerHTML = transactionForm.EditPatientShare.value+"%";
      row.cells[4].innerHTML = (100-transactionForm.EditPatientShare.value)+"%";
      row.cells[5].innerHTML = "<div id='divCat_"+transactionForm.EditCategoryName.value+"'></div>";
      row.cells[6].innerHTML = "&nbsp;";

      clearCategoryFields();
      if(transactionForm.updateCategoryButton!=null) transactionForm.updateCategoryButton.disabled = true;
    }
  }

  <%-- CLEAR CATEGORY FIELDS --%>
  function clearCategoryFields(){
    transactionForm.EditCategoryName.value = "";
    transactionForm.EditCategoryLabel.value = "";
    transactionForm.EditPatientShare.value = "";
  }

  <%-- SORT CATEGORIES --%>
  function sortCategories(){
    var sortLink = document.getElementById("lnk0");
    if(sortLink!=null){
      ts_resortTable(sortLink,1,false);
    }
  }

  <%-- DELETE CATEGORY --%>
  function deleteCategory(rowid){
    var row = getRowFromArrayString(sCategories,rowid.id);
    var categoryName = getCelFromRowString(row,0);
    var catDiv = document.getElementById("catDiv_"+categoryName);

    if(catDiv!=null){
      var patientCount = catDiv.innerHTML;

      if(patientCount.length==0){
        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=countPatientsPerCategoryBeforeDelete";
        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        if (window.showModalDialog) {
            window.showModalDialog(popupUrl,"",modalities);
        }
        else {
            alert('<%=getTranNoLink("web.manage","countPatientsPerCategoryBeforeDelete",sWebLanguage).replaceAll("\n","").replaceAll("\r","")%>');
        }
      }
      else{
        if(patientCount==0){
          <%-- no patients in this category, so delete it --%>
          var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
          var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>');

          if(answer==1){
            sCategories = deleteRowFromArrayString(sCategories,rowid.id);
            initCategoriesArray(sCategories);
            tblCategories.deleteRow(rowid.rowIndex);
            updateRowStylesCategories();

            recordsFoundMsg.innerHTML = (tblCategories.rows.length-2)+" <%=getTranNoLink("web.manage","insurarCategoriesFound",sWebLanguage)%>";
          }
        }
        else{
          <%-- some patients in this category, so ask again before deleting it --%>
          var msg = "<%=getTranNoLink("web.manage","patientsInThisCategory",sWebLanguage)%><br><%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>";
          msg = replaceAll(msg,"#patientCount#",patientCount);
          var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelValue="+msg;
          var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>');

          if(answer==1){
            categoriesToDeleteOnSave+= categoryName+"$";

            sCategories = deleteRowFromArrayString(sCategories,rowid.id);
            initCategoriesArray(sCategories);
            tblCategories.deleteRow(rowid.rowIndex);
            updateRowStylesCategories();

            recordsFoundMsg.innerHTML = (tblCategories.rows.length-2)+" <%=getTranNoLink("web.manage","insurarCategoriesFound",sWebLanguage)%>";
          }
        }
      }
    }
    else{
      <%-- category that has not been saved yet, so delete it --%>
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>');

      if(answer==1){
        sCategories = deleteRowFromArrayString(sCategories,rowid.id);
        initCategoriesArray(sCategories);
        tblCategories.deleteRow(rowid.rowIndex);
        updateRowStylesCategories();

        recordsFoundMsg.innerHTML = (tblCategories.rows.length-2)+" <%=getTranNoLink("web.manage","insurarCategoriesFound",sWebLanguage)%>";
      }
    }
  }

  <%-- INIT CATEGORIES ARRAY --%>
  function initCategoriesArray(sArray){
    categoriesArray = new Array();
    categoryIds = new Array();
    transactionForm.selectedCategoryIds.value = "";

    if(sArray != ""){
      var sOneCat;
      for(var i=0; i<iIndexCategories; i++){
        sOneCat = getRowFromArrayString(sCategories,"rowCategory"+i);
        if(sOneCat.length > 0){
          var oneCat = sOneCat.split("£");
          categoriesArray.push(oneCat);
          categoryIds.push(oneCat[0]);
        }
      }

      transactionForm.selectedCategoryIds.value = categoryIds.join(",");
    }
  }

  <%-- ALLREADY SELECTED --%>
  function allreadySelected(catName){
    for(var i=0; i<categoriesArray.length; i++){
      if(categoriesArray[i][0] == catName){
        return true;
      }
    }
    return false;
  }

  <%-- GET CELL FROM ROW STRING --%>
  function getCelFromRowString(sRow, celid) {
    var row = sRow.split("£");
    return row[celid];
  }

  <%-- GET ROW FROM ARRAY STRING --%>
  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid)>-1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
    return row;
  }

  <%-- REPLACE ROW IN ARRAY STRING --%>
  function replaceRowInArrayString(sArray,newRow,rowid){
    var array = sArray.split("$");
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        array.splice(i,1,newRow);
        break;
      }
    }

    return array.join("$");
  }

  <%-- DELETE ROW FROM ARRAY STRING --%>
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

  <%-- DELETE ALL CATEGORIES --%>
  function deleteAllCategories(){
    if(tblCategories.rows.length > 1){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>');

      if(answer==1){
        deleteAllCategoriesNoConfirm();
      }
    }
  }

  <%-- DELETE ALL CATEGORIES NO CONFIRM --%>
  function deleteAllCategoriesNoConfirm(){
    if(tblCategories.rows.length > 1){
      var len = tblCategories.rows.length;
      for(var i=len-1; i!=0; i--){
        tblCategories.deleteRow(i);
      }

      sCategories = "";
      initCategoriesArray("");

      recordsFoundMsg.innerHTML = (tblCategories.rows.length-2)+" <%=getTranNoLink("web.manage","insurarCategoriesFound",sWebLanguage)%>";
    }
  }

  <%-- SAVE INSURAR --%>
  function saveInsurar(){
    if(transactionForm.EditInsurarName.value.length > 0 && transactionForm.EditInsurarOfficialName.value.length > 0){
      if(transactionForm.EditInsurarId.value.length==0){
        transactionForm.EditInsurarId.value = "-1";
      }

      while(sCategories.indexOf("rowCategory") > -1){
        var sTmpBegin = sCategories.substring(sCategories.indexOf("rowCategory"));
        var sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
        sCategories = sCategories.substring(0,sCategories.indexOf("rowCategory"))+sTmpEnd;
      }

      transactionForm.selectedCategories.value = sCategories;
      transactionForm.categoriesToDelete.value = categoriesToDeleteOnSave;
      transactionForm.saveButton.style.visibility = "hidden";
      transactionForm.Action.value = "save";
      var temp = Form.findFirstElement(transactionForm);//for ff compatibility
      <%
          SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
      %>
    }
    else{
      if(transactionForm.EditInsurarName.value.length==0){
        transactionForm.EditInsurarName.focus();
      }
      else if(transactionForm.EditInsurarOfficialName.value.length==0){
        transactionForm.EditInsurarOfficialName.focus();
      }

      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=dataMissing";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";

        if (window.showModalDialog) {
            window.showModalDialog(popupUrl,"",modalities);
        }
        else {
            alert('<%=getTranNoLink("web.manage","dataMissing",sWebLanguage).replaceAll("\n","").replaceAll("\r","")%>');
        }
    }
  }

  <%-- UPDATE ROW STYLES (after sorting) --%>
  function updateRowStyles(){
    for(var i=1; i<searchresults.rows.length; i++){
      if(i%2>0) searchresults.rows[i].className = "list";
      else      searchresults.rows[i].className = "list1";
    }
  }

  <%-- UPDATE ROW STYLES CATEGORIES (after deleting) --%>
  function updateRowStylesCategories(){
    for(var i=1; i<tblCategories.rows.length; i++){
      if(i%2>0) tblCategories.rows[i].className = "list1";
      else      tblCategories.rows[i].className = "list";
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    <%
        if(sAction.equals("edit") || sAction.equals("new")){
            %>
              if(checkSaveButton("<%=sCONTEXTPATH%>","<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")){
                  window.location.href = "<c:url value='/main.do'/>?Page=system/manageInsurars.jsp";
              }
            <%
        }
        else{
            %>window.location.href = "<c:url value='/main.do'/>?Page=system/manageInsurars.jsp";<%
        }
    %>
  }

  <%-- DO BACK TO MENU --%>
  function doBackToMenu(){
    <%
        if(sAction.equals("edit") || sAction.equals("new")){
            %>
              if(checkSaveButton("<%=sCONTEXTPATH%>","<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>")){
                window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
              }
            <%
        }
        else{
            %>window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";<%
        }
    %>
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>