<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%!
    //--- SET CHECK BOX ---------------------------------------------------------------------------
    private String setCb(int index, String sTab, String sFieldName, String sID, String sWebLanguage, String sLabelType) {
        String sObligatoryFields = MedwanQuery.getInstance().getConfigString("ObligatoryFields_" + sTab);
        String sChecked = "";

        // check on "name+komma" otherwise 'comment1' is seen as 'comment' !
        if (sObligatoryFields.toLowerCase().indexOf(sFieldName.toLowerCase() + ",") > -1) {
            sChecked = " checked";
        }

        return "<input type='checkbox' name='" + index + "$" + sTab + "$" + sFieldName + "'" + sChecked + " id='" + sTab + "_cb" + sFieldName + "'>&nbsp;" + getLabel(sLabelType, sID, sWebLanguage, sTab + "_cb" + sFieldName) + "<br>";
    }

    //--- HASH TO STRING --------------------------------------------------------------------------
    // convert hashtable to comma-concatenated-string
    private String hashToString(Hashtable hash) {
        StringBuffer buffer = new StringBuffer();
        Vector keys = new Vector(hash.keySet());
        Collections.sort(keys);

        for (int i = 0; i < keys.size(); i++) {
            buffer.append((String) hash.get(keys.get(i))).append(",");
        }

        return buffer.toString();
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    //--- SAVE ------------------------------------------------------------------------------------
    // compose configString value for each "tab" in patient-edit
    if (sAction.equals("save")) {
        String sParamName, sParamValue, fieldIdx = "", tab = "", field = "";
        StringTokenizer tokenizer;

        Hashtable adminFieldsHash = new Hashtable();
        Hashtable adminPrivateFieldsHash = new Hashtable();
        Hashtable zelfstandigeFieldsHash = new Hashtable();

        Enumeration e = request.getParameterNames();
        while (e.hasMoreElements()) {
            sParamName = (String) e.nextElement();

            if (sParamName.indexOf("$") > -1) {
                sParamValue = checkString(request.getParameter(sParamName));

                if (sParamValue.equals("on")) {
                    // get data from parametername (idx $ tab $ field)
                    tokenizer = new StringTokenizer(sParamName, "$");
                    while (tokenizer.hasMoreTokens()) {
                        fieldIdx = tokenizer.nextToken();
                        tab = tokenizer.nextToken();
                        field = tokenizer.nextToken();
                    }

                    if (tab.equals("Admin")) {
                        adminFieldsHash.put(new Integer(fieldIdx), field);
                    } else if (tab.equals("AdminPrivate")) {
                        adminPrivateFieldsHash.put(new Integer(fieldIdx), field);
                    } else if (tab.equals("Zelfstandige")) {
                        zelfstandigeFieldsHash.put(new Integer(fieldIdx), field);
                    }
                }
            }
        }

        // save selected field-names as configStrings
        MedwanQuery.getInstance().setConfigString("ObligatoryFields_Admin", hashToString(adminFieldsHash));
        MedwanQuery.getInstance().setConfigString("ObligatoryFields_AdminPrivate", hashToString(adminPrivateFieldsHash));
        MedwanQuery.getInstance().setConfigString("ObligatoryFields_Zelfstandige", hashToString(zelfstandigeFieldsHash));
    }
%>
<form name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <%-- title --%>
    <%=writeTableHeader("Web.manage","obligatory_fields",sWebLanguage," doBack();")%>
    <br>
    <%-- tab = Admin ----------------------------------------------------------------------------%>
    <table width="100%" cellspacing="0" class="menu">
        <tr class="label" height="18">
            <td class="titleadmin"><%=getTran("Web","actualpersonaldata",sWebLanguage)%></td>
        </tr>
        <tr>
            <td>
            <%
                int i = 0;

                out.print(setCb(i++,"Admin","Lastname","lastname",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Firstname","firstname",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","DateOfBirth","dateofbirth",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","ImmatNew","immatnew",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","ImmatOld","immatold",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","NatReg","natreg",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Language","language",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Gender","gender",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Candidate","candidate",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Engagement","engagement",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Pension","pension",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Claimant","claimant",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","ClaimantExpiration","claimantexpiration",sWebLanguage,"web"));

                out.print(setCb(i++,"Admin","NativeCountryDescription","NativeCountry",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","NativeTown","nativeTown",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Comment","comment",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Comment1","comment1",sWebLanguage,"web"));

                out.print(setCb(i++,"Admin","Comment2","comment2",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Comment3","comment3",sWebLanguage,"web"));

                out.print(setCb(i++,"Admin","Comment4","comment4",sWebLanguage,"web"));
                out.print(setCb(i++,"Admin","Comment5","comment5",sWebLanguage,"web"));
                if(MedwanQuery.getInstance().getConfigInt("cnarEnabled",0)==1){
                    out.print(setCb(i++,"Admin","centerreason","center",sWebLanguage,"web"));
                }
            %>
            </td>
        </tr>
    </table>
    <a href="javascript:checkAll('Admin',true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
    <a href="javascript:checkAll('Admin',false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
    <br><br>
    <%-- tab = AdminPrivate ---------------------------------------------------------------------%>
    <table width="100%" cellspacing="0" class="menu">
        <tr class="label" height="18">
            <td class="titleadmin"><%=getTran("Web","private",sWebLanguage)%></td>
        </tr>
        <tr>
            <td>
            <%
                i = 0;

                // begin
                out.print(setCb(i++,"AdminPrivate","PBegin","begin",sWebLanguage,"web"));

                out.print(setCb(i++,"AdminPrivate","PAddress","address",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PZipcode","zipcode",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PCity","city",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PCountry","country",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PProvince","province",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PDistrict","district",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PSector","community",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PEmail","email",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PTelephone","telephone",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PFax","fax",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PMobile","mobile",sWebLanguage,"web"));
                out.print(setCb(i++,"AdminPrivate","PComment","comment",sWebLanguage,"web"));
            %>
            </td>
        </tr>
    </table>
    <a href="javascript:checkAll('AdminPrivate',true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
    <a href="javascript:checkAll('AdminPrivate',false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
    <br><br>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input type="button" class="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">
        <input type="button" class="button" name="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" OnClick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
    <script>
      <%-- CHECK ALL --%>
      function checkAll(tab,setchecked){
        for(var i=0; i<transactionForm.elements.length; i++){
          var element = transactionForm.elements[i];
          if(element.type=="checkbox"){
            if(element.id.indexOf(tab+"_cb") > -1){
              element.checked = setchecked;
            }
          }
        }
      }

      <%-- DO SAVE --%>
      function doSave(){
        transactionForm.Action.value = "save";
        transactionForm.submit();
      }

      <%-- DO BACK --%>
      function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
      }
    </script>
</form>