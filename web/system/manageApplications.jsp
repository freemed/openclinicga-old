<%@page import="org.dom4j.DocumentException,java.util.*,be.openclinic.system.Application" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    public String writePermission(String sLabel, String sScreenID, int idx, int categoryIdx) {
        String sChecked = "";

        if (Application.isDisabled(sScreenID)){
            sChecked = " checked";
        }

        return "<tr " + (idx % 2 == 0 ? "class='list'" : "") + ">" +
            " <td/>" +
            " <td>" + sLabel + "</td>" +
            " <td colspan='2'><input type='checkbox' name='cat" + categoryIdx + "$" + sScreenID + "'" + sChecked + "></td>" +
            "</tr>";
    }

    public String writeHeader(String sHeader, int headerIdx, boolean displaySection) {
        return (headerIdx == 0 ? "" : "<br>") +
                "<input type='hidden' name='cat" + headerIdx + "_selected' value='1'>" +
                "<table width='100%' cellspacing='0' class='list'>" +
                " <tr class='admin'>" +
                "  <td width='2%'>" +
                "   <a href='#'><img id='Input_" + headerIdx + "_S' border='0' src='" + sCONTEXTPATH + "/_img/plus.png' OnClick='showD(\"Input_" + headerIdx + "\",\"Input_" + headerIdx + "_S\",\"Input_" + headerIdx + "_H\")' style='display:none'></a>" +
                "   <a href='#'><img id='Input_" + headerIdx + "_H' border='0' src='" + sCONTEXTPATH + "/_img/minus.png' OnClick='hideD(\"Input_" + headerIdx + "\",\"Input_" + headerIdx + "_S\", \"Input_" + headerIdx + "_H\")'></a>" +
                "  </td>" +
                "  <td width='300'>" + sHeader + "</td>" +
                "  <td width='8%'>&nbsp;<a href='javascript:togglePermissions(" + headerIdx + ");'>All</a></td>" +
                "  <td align='right'><a href=\"#topp\" class=\"topbutton\">&nbsp;</a></td>" +
                " </tr>" +
                " <tbody id='Input_" + headerIdx + "'>";
    }

    public String writeFooter() {
        return " </tbody>" +
                "</table>";
    }

    private String displayPermissions(String categoryName, Hashtable permissions, int categoryIdx, boolean sortPermissions, boolean displaySection) {
        // sort permissions on translation
        Vector labels = new Vector(permissions.keySet());
        if (sortPermissions) Collections.sort(labels);

        StringBuffer out = new StringBuffer();
        out.append(writeHeader(categoryName, categoryIdx, displaySection));

        int counter = 0;
        String label, permissionName;
        for (int i = 0; i < labels.size(); i++) {
            label = (String) labels.get(i);
            permissionName = (String) permissions.get(label);
			
            out.append(writePermission(label, permissionName, counter++, categoryIdx));
        }

        out.append(writeFooter());

        if (!displaySection) {
            out.append("<script>toggleSection('").append(categoryIdx).append("');</script>");
        }

        return out.toString();
    }
%>
<%
    String sMessage = "";
    String sAction = checkString(request.getParameter("ActionField"));
    //*** SAVE ***
    if (sAction.equalsIgnoreCase("save")) {
        String sPassword = checkString(request.getParameter("EditPassword"));

        if (Application.checkPassword(Application.encrypt(sPassword))){
            Application.deleteScreens();
            
            String sTmpName, sTmpValue, sTmpPermission;
            Enumeration e = request.getParameterNames();
            while (e.hasMoreElements()) {
                sTmpName = (String) e.nextElement();

                if (sTmpName.startsWith("cat")) {
                    sTmpValue = checkString(request.getParameter(sTmpName));

                    if (sTmpValue.equals("on")) {
                        sTmpPermission = sTmpName.substring(sTmpName.indexOf("$") + 1).toLowerCase();

                       Application.storeScreenId(sTmpPermission);
                    }
                }
            }
            sMessage = getTran("web","dataissaved",sWebLanguage);
        }
        else {
            sMessage = "<font color='red'>"+getTran("web.occup","medwan.transaction.delete.wrong-password",sWebLanguage)+"</font>";
        }
        MedwanQuery.reload();
    }
%>
<script>
  function toggleSection(sectionIdx){
    if(document.getElementById("cat" + sectionIdx + "_selected")){
        var sectionDisplayed = document.getElementById("cat" + sectionIdx + "_selected").value == "1";
        if(sectionDisplayed){
          hideD(eval("'Input_" + sectionIdx + "'"),eval("'Input_" + sectionIdx + "_S'"),eval("'Input_" + sectionIdx + "_H'"));
        }
        else{
          showD("'Input_" + sectionIdx + "','Input_" + sectionIdx + "_S','Input_" + sectionIdx + "_H'");
        }
    }
  }
</script>
<a name="topp"></a>
<form name="profileForm" id="profileForm" method="post">
    <%=writeTableHeader("Web.manage","applications",sWebLanguage," doBack();")%>
    <table class="list" width="100%" cellpadding="0" cellspacing="2">
        <tr>
            <td colspan="2">
                <%
                    int headerIdx = 0;
                    String title;
                    Hashtable perms;
                    SAXReader xmlReader = new SAXReader();
                    String sPermissions = MedwanQuery.getInstance().getConfigString("templateSource") + "permissions.xml";
                    Document document;
                    String sApplicationType, sApplicationId, sApplicationDisplaySection, sPermissionType, sPermissionId, sPermission;
                    boolean bDisplaySection;

                    try {
                        document = xmlReader.read(new URL(sPermissions));
                        if (document != null) {
                            Element root = document.getRootElement();
                            if (root != null) {
                                Element eApplication, ePermission;
                                Iterator applications = root.elementIterator("application");

                                while (applications.hasNext()) {
                                    eApplication = (Element) applications.next();
                                    sApplicationType = checkString(eApplication.attributeValue("type"));
                                    sApplicationId = checkString(eApplication.attributeValue("id"));
                                    sApplicationDisplaySection = checkString(eApplication.attributeValue("displaysection"));

                                    title = getTran(sApplicationType, sApplicationId, sWebLanguage);
                                    perms = new Hashtable();

                                    Iterator permissions = eApplication.elementIterator("permission");
                                    while (permissions.hasNext()) {
                                        ePermission = (Element) permissions.next();
                                        sPermissionType = checkString(ePermission.attributeValue("type"));
                                        sPermissionId = checkString(ePermission.attributeValue("id"));
                                        sPermission = checkString(ePermission.getText());

                                        perms.put(getTran(sPermissionType, sPermissionId, sWebLanguage), sPermission);
                                    }

                                    bDisplaySection = !sApplicationDisplaySection.equalsIgnoreCase("false");
                                    out.print(displayPermissions(title, perms, headerIdx++, true, bDisplaySection));
                                }
                            }
                        }
                    } catch (DocumentException e) {
                    }
                %>
        <tr>
            <td><%=getTran("web.occup","medwan.authentication.password",sWebLanguage)%></td>
            <td><input name="EditPassword" class="text" type="password"></td>
        </tr>
    </table>
    <%=ScreenHelper.alignButtonsStart()%>
        <b><%=sMessage%></b>
        <input type="button" class="button" name="saveButton"  value="<%=getTran("Web","Save",sWebLanguage)%>" onclick="doSave();">&nbsp;
        <input type="button" class="button" name="backButton" Value='<%=getTran("Web","Back",sWebLanguage)%>' OnClick="doBack();">&nbsp;
        <input type="button" class="button" value="<%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%>" onClick="checkAll(true);">&nbsp;
        <input type="button" class="button" value="<%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%>" onClick="checkAll(false);">
    <%=ScreenHelper.alignButtonsStop()%>
    <input type="hidden" name="ActionField">
</form>
<script>

  function doSave(){
      if (profileForm.EditPassword.value.length==0){
          alert("<%=getTran("web.occup","medwan.transaction.delete.wrong-password",sWebLanguage)%>");
      }
      else {
          profileForm.ActionField.value="save";
          profileForm.submit();
      }
  }
  function doBack(){
      window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  function checkAll(setchecked){
    for(var i=0; i<profileForm.elements.length; i++){
      if(profileForm.elements[i].type=="hidden" && profileForm.elements[i].name.indexOf("_selected") > -1){
        if(setchecked) profileForm.elements[i].value = 0;
        else           profileForm.elements[i].value = 1;
      }
    }

    for(var i=0; i<profileForm.elements.length; i++){
      if(profileForm.elements[i].type=="checkbox"){
        profileForm.elements[i].checked = setchecked;
      }
    }
  }

  function togglePermissions(headerIdx){
    var isChecked = (document.getElementsByName('cat'+headerIdx+'_selected')[0].value==1);
    if(isChecked) document.getElementsByName('cat'+headerIdx+'_selected')[0].value = 0;
    else          document.getElementsByName('cat'+headerIdx+'_selected')[0].value = 1;

    for(var i=0; i<profileForm.elements.length; i++){
      if(profileForm.elements[i].type=="checkbox"){
        if(profileForm.elements[i].name.indexOf("cat"+headerIdx+"$")==0){
          profileForm.elements[i].checked = isChecked;
        }
      }
    }
  }
</script>
<%=writeJSButtons("profileForm","saveButton")%>