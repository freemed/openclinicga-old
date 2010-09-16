<%@page import="be.openclinic.pharmacy.AdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable, be.openclinic.medical.CarePrescriptionAdministrationSchema" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("medication.medicationschema","all",activeUser)%>
<%
    int adminDays = MedwanQuery.getInstance().getConfigInt("administrationSchemaDays", 5);
    SimpleDateFormat compactDateFormat = new SimpleDateFormat("yyyyMMdd"),
                     stdDateFormat     = new SimpleDateFormat("dd/MM/yyyy");
    //--- SAVE ------------------------------------------------------------------------------------
    if(request.getParameter("saveButton") != null){
        Hashtable requestParameters = RequestParameterParser.getInstance().parseRequestParameters(request, "drugprescr");
        Iterator iterator = requestParameters.keySet().iterator();
        String parameter, day, prescriptionUid, time, value;
        while (iterator.hasNext()) {
            parameter = (String) iterator.next();
            day = parameter.substring(10).split("_")[0];
            prescriptionUid = parameter.substring(10).split("_")[1];
            time = parameter.substring(10).split("_")[2];
            value = (String) requestParameters.get(parameter);

            AdministrationSchema.storeAdministration(prescriptionUid, compactDateFormat.parse(day), Integer.parseInt(time), Integer.parseInt(value));
        }
    }
    // start date
    java.util.Date dStart = new java.util.Date(ScreenHelper.getDate(new java.util.Date()).getTime() - 2 * 24 * 3600 * 1000);
    String sStartDate = checkString(request.getParameter("startdate"));
    if (sStartDate.length() > 0) {
        dStart = new java.util.Date(stdDateFormat.parse(sStartDate).getTime() - 2 * 24 * 3600 * 1000);
    }
%>
<form name="formAdministrations" method="post">
    <%=writeTableHeader("web","medicationschema",sWebLanguage,"")%>
    <br>
    <table width="100%" cellspacing="1" class="list">
    <%
        //Eerst de geneesmiddelen
        AdministrationSchema schema = new AdministrationSchema(dStart, new java.util.Date(dStart.getTime() + adminDays * 24 * 3600 * 1000), activePatient.personid);
        if (schema.getPrescriptionSchemas().size() > 0) {
            AdministrationSchema.AdministrationSchemaLine line = (AdministrationSchema.AdministrationSchemaLine) schema.getPrescriptionSchemas().elementAt(0);

            // Day header
            out.print("<tr><td width='20%'/>");
            String hours = line.getTimeQuantities().size() + "";
            for (int d = 0; d < adminDays; d++) {
                %>
                    <td class="admin" colspan="<%=hours%>" width="<%=80/(adminDays)%>%">
                        <center><a href="<c:url value='/main.do'/>?Page=pharmacy/manageAdministrations.jsp&startdate=<%=stdDateFormat.format(new java.util.Date(dStart.getTime() + d * 24 * 3600 * 1000))%>"><%=stdDateFormat.format(new java.util.Date(dStart.getTime() + d * 24 * 3600 * 1000))%></a></center>
                    </td>
                <%
            }
            out.print("</tr>");

            // Hour header
            out.print("<tr><td width='20%'/>");
            for (int d = 0; d < adminDays; d++) {
                for (int i = 0; i < line.getTimeQuantities().size(); i++) {
                    out.print("<td class='admin' width='"+(80/(adminDays)/line.getTimeQuantities().size())+"%'><center>" + ((KeyValue) line.getTimeQuantities().elementAt(i)).getKey() + getTran("web", "abbreviation.hour", sWebLanguage) + "</center></td>");
                }
            }
            out.print("</tr>");
        }

        java.util.Date day;
        int val, adminVal;
        String sClass;
        AdministrationSchema.AdministrationSchemaLine line;

        for (int n=0; n<schema.getPrescriptionSchemas().size(); n++) {
            line = (AdministrationSchema.AdministrationSchemaLine)schema.getPrescriptionSchemas().elementAt(n);

            out.print("<tr bgcolor='lightgrey'>");
            out.print("<td width='20%'><b>" + (line.getPrescription().getProduct()!=null?line.getPrescription().getProduct().getName():"Unknown product") + "</b></td>");

            // display days
            for (int d = 0; d < adminDays; d++) {
                day = new java.util.Date(dStart.getTime() + d * 24 * 3600 * 1000);

                for (int i = 0; i < line.getTimeQuantities().size(); i++) {
                    if (!line.getPrescription().getBegin().after(day) && !(line.getPrescription().getEnd() != null && line.getPrescription().getEnd().before(day))) {
                        val = ((KeyValue)line.getTimeQuantities().elementAt(i)).getValueInt();

                        out.print("<td width='"+(80/(adminDays)/line.getTimeQuantities().size())+"%'><center>" + (val > 0 ? val + "" : "&nbsp;"));
                        if (val > 0) {
                            try {
                                adminVal = Integer.parseInt(line.getTimeAdministration(compactDateFormat.format(day) + "." + ((KeyValue) line.getTimeQuantities().elementAt(i)).getKey()));
                            }
                            catch (Exception e) {
                                adminVal = 0;
                            }

                            sClass = "text";
                            if (adminVal < val) {
                                sClass = "textred";
                            }
                            out.print(" <input name='drugprescr" + compactDateFormat.format(day) + "_" + line.getPrescription().getUid() + "_" + ((KeyValue) line.getTimeQuantities().elementAt(i)).getKey() + "' type='text' class='" + sClass + "' size='1' value='" + adminVal + "'/>");
                        }
                    }
                    else {
                        out.print("<td>&nbsp;");
                    }
                    out.print("</center></td>");
                }
            }
            out.print("</tr>");
        }
    %>
    </table>
    <br/>
    <%=writeTableHeader("web","careschema",sWebLanguage,"")%>
    <br>

    <table width="100%" cellspacing="1">
    <%
        adminDays = MedwanQuery.getInstance().getConfigInt("administrationSchemaDays", 5);
        //--- SAVE ------------------------------------------------------------------------------------
        if (request.getParameter("saveButton") != null) {
            Hashtable requestParameters = RequestParameterParser.getInstance().parseRequestParameters(request, "careprescr");
            Iterator iterator = requestParameters.keySet().iterator();
            String parameter, sDay, prescriptionUid, time, value;
            while (iterator.hasNext()) {
                parameter = (String) iterator.next();
                sDay = parameter.substring(10).split("_")[0];
                prescriptionUid = parameter.substring(10).split("_")[1];
                time = parameter.substring(10).split("_")[2];
                value = (String) requestParameters.get(parameter);

                CarePrescriptionAdministrationSchema.storeAdministration(prescriptionUid, new SimpleDateFormat("yyyyMMdd").parse(sDay), Integer.parseInt(time), Integer.parseInt(value));
            }
        }

        CarePrescriptionAdministrationSchema.AdministrationSchemaLine cLine;
        CarePrescriptionAdministrationSchema cSchema = new CarePrescriptionAdministrationSchema(dStart, new java.util.Date(dStart.getTime() + adminDays * 24 * 3600 * 1000), activePatient.personid);
        if (cSchema.getCarePrescriptionSchemas().size() > 0) {
            cLine = (CarePrescriptionAdministrationSchema.AdministrationSchemaLine) cSchema.getCarePrescriptionSchemas().elementAt(0);

            // Day header
            out.print("<tr><td width='20%'/>");
            String hours = cLine.getTimeQuantities().size() + "";
            for (int d = 0; d < adminDays; d++) {
    %>
                    <td class="admin" colspan="<%=hours%>" width="<%=80/(adminDays)%>%">
                        <center><a href="<c:url value='/main.do'/>?Page=pharmacy/manageAdministrations.jsp&startdate=<%=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(dStart.getTime() + d * 24 * 3600 * 1000))%>"><%=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(dStart.getTime() + d * 24 * 3600 * 1000))%></a></center>
                    </td>
                <%
            }
            out.print("</tr>");

            // Hour header
            out.print("<tr><td width='20%'/>");
            for (int d = 0; d < adminDays; d++) {
                for (int i = 0; i < cLine.getTimeQuantities().size(); i++) {
                    out.print("<td class='admin' width='"+(80/(adminDays)/cLine.getTimeQuantities().size())+"%'><center>" + ((KeyValue) cLine.getTimeQuantities().elementAt(i)).getKey() + getTran("web", "abbreviation.hour", sWebLanguage) + "</center></td>");
                }
            }
            out.print("</tr>");
        }

        for (int n = 0; n < cSchema.getCarePrescriptionSchemas().size(); n++) {
            cLine = (CarePrescriptionAdministrationSchema.AdministrationSchemaLine) cSchema.getCarePrescriptionSchemas().elementAt(n);

            out.print("<tr bgcolor='lightgrey'>");
            out.print(" <td width='20%'><b>" + (cLine.getCarePrescription().getCareUid()!=null?getTran("care_type",cLine.getCarePrescription().getCareUid(),sWebLanguage):"Unknown care type") + "</b></td>");

            for (int d = 0; d < adminDays; d++) {
                day = new java.util.Date(dStart.getTime() + d * 24 * 3600 * 1000);
                for (int i = 0; i < cLine.getTimeQuantities().size(); i++) {
                    if (!cLine.getCarePrescription().getBegin().after(day) && !(cLine.getCarePrescription().getEnd() != null && cLine.getCarePrescription().getEnd().before(day))) {
                        val = ((KeyValue) cLine.getTimeQuantities().elementAt(i)).getValueInt();
                        out.print("<td width='"+(80/(adminDays)/cLine.getTimeQuantities().size())+"%'><center>" + (val > 0 ? val + "" : "&nbsp;"));
                        if (val > 0) {
                            try {
                                adminVal = Integer.parseInt(cLine.getTimeAdministration(new SimpleDateFormat("yyyyMMdd").format(day) + "." + ((KeyValue) cLine.getTimeQuantities().elementAt(i)).getKey()));
                            }
                            catch (Exception e) {
                                adminVal = 0;
                            }

                            sClass = "text";
                            if (adminVal < val) {
                                sClass = "textred";
                            }

                            out.print(" <input name='careprescr" + new SimpleDateFormat("yyyyMMdd").format(day) + "_" + cLine.getCarePrescription().getUid() + "_" + ((KeyValue) cLine.getTimeQuantities().elementAt(i)).getKey() + "' type='text' class='" + sClass + "' size='1' value='" + adminVal + "'/>");
                        }
                    }
                    else {
                        out.print("<td>&nbsp;");
                    }
                    out.print("</center></td>");
                }
            }
            out.print("</tr>");
        }
    %>
    </table>
    <br/>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="submit" name="saveButton" value="<%=getTranNoLink("Web","save",sWebLanguage)%>"/>
        <input class="button" type="button" name="todayButton" value="<%=getTranNoLink("Web","today",sWebLanguage)%>" onclick="doToday();"/>
    <%=ScreenHelper.alignButtonsStart()%>
</form>
<script>
  <%-- DO TODAY --%>
  function doToday(){
    window.location.href = "<c:url value="/main.do"/>?Page=pharmacy/manageAdministrations.jsp&startdate=<%=stdDateFormat.format(new java.util.Date())%>";
  }
</script>
