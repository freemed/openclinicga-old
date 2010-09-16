<%@page import="be.openclinic.medical.CarePrescriptionAdministrationSchema,
                be.openclinic.common.KeyValue,
                be.mxs.webapp.wl.servlet.http.RequestParameterParser,
                java.util.Hashtable" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("medical.managecareprescriptionsschema","all",activeUser)%>

<form name="formAdministrations" method="post">
    <%=writeTableHeader("web","medicationschema",sWebLanguage,"")%>
    <br>

    <table width="100%" cellspacing="1">
    <%
        int adminDays = MedwanQuery.getInstance().getConfigInt("administrationSchemaDays", 5);

        //--- SAVE ------------------------------------------------------------------------------------
        if (request.getParameter("saveButton") != null) {
            Hashtable requestParameters = RequestParameterParser.getInstance().parseRequestParameters(request, "prescr");
            Iterator iterator = requestParameters.keySet().iterator();
            String parameter, day, prescriptionUid, time, value;
            while (iterator.hasNext()) {
                parameter = (String) iterator.next();
                day = parameter.substring(6).split("_")[0];
                prescriptionUid = parameter.substring(6).split("_")[1];
                time = parameter.substring(6).split("_")[2];
                value = (String) requestParameters.get(parameter);

                CarePrescriptionAdministrationSchema.storeAdministration(prescriptionUid, new SimpleDateFormat("yyyyMMdd").parse(day), Integer.parseInt(time), Integer.parseInt(value));
            }
        }

        // start date
        java.util.Date dStart = new java.util.Date(new java.util.Date().getTime() - 2 * 24 * 3600 * 1000);
        String sStartDate = checkString(request.getParameter("startdate"));
        if (sStartDate.length() > 0) {
            dStart = new java.util.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sStartDate).getTime() - 2 * 24 * 3600 * 1000);
        }

        CarePrescriptionAdministrationSchema schema = new CarePrescriptionAdministrationSchema(dStart, new Date(dStart.getTime() + adminDays * 24 * 3600 * 1000), activePatient.personid);
        if (schema.getCarePrescriptionSchemas().size() > 0) {
            CarePrescriptionAdministrationSchema.AdministrationSchemaLine line = (CarePrescriptionAdministrationSchema.AdministrationSchemaLine) schema.getCarePrescriptionSchemas().elementAt(0);

            // Day header
            out.print("<tr><td/>");
            String hours = line.getTimeQuantities().size() + "";
            for (int d = 0; d < adminDays; d++) {
                %>
                    <td class="admin" colspan="<%=hours%>%>">
                        <center><a href="<c:url value='/main.do'/>?Page=medical/manageCarePrescriptionsSchema.jsp&startdate=<%=new SimpleDateFormat("dd/MM/yyyy").format(new Date(dStart.getTime() + d * 24 * 3600 * 1000))%>"><%=new SimpleDateFormat("dd/MM/yyyy").format(new Date(dStart.getTime() + d * 24 * 3600 * 1000))%></a></center>
                    </td>
                <%
            }
            out.print("</tr>");

            // Hour header
            out.print("<tr><td/>");
            for (int d = 0; d < adminDays; d++) {
                for (int i = 0; i < line.getTimeQuantities().size(); i++) {
                    out.print("<td class='admin'><center>" + ((KeyValue) line.getTimeQuantities().elementAt(i)).getKey() + getTran("web", "abbreviation.hour", sWebLanguage) + "</center></td>");
                }
            }
            out.print("</tr>");
        }

        Date day;
        int val, adminVal;
        String sClass;

        CarePrescriptionAdministrationSchema.AdministrationSchemaLine line;
        for (int n = 0; n < schema.getCarePrescriptionSchemas().size(); n++) {
            line = (CarePrescriptionAdministrationSchema.AdministrationSchemaLine) schema.getCarePrescriptionSchemas().elementAt(n);

            out.print("<tr bgcolor='lightgrey'>");
            out.print(" <td><b>" + (line.getCarePrescription().getCareUid()!=null?getTran("care_type",line.getCarePrescription().getCareUid(),sWebLanguage):"Unknown care type") + "</b></td>");

            for (int d = 0; d < adminDays; d++) {
                day = new Date(dStart.getTime() + d * 24 * 3600 * 1000);
                for (int i = 0; i < line.getTimeQuantities().size(); i++) {
                    if (!line.getCarePrescription().getBegin().after(day) && !(line.getCarePrescription().getEnd() != null && line.getCarePrescription().getEnd().before(day))) {
                        val = ((KeyValue) line.getTimeQuantities().elementAt(i)).getValueInt();
                        out.print("<td><center>" + (val > 0 ? val + "" : "&nbsp;"));
                        if (val > 0) {
                            try {
                                adminVal = Integer.parseInt(line.getTimeAdministration(new SimpleDateFormat("yyyyMMdd").format(day) + "." + ((KeyValue) line.getTimeQuantities().elementAt(i)).getKey()));
                            }
                            catch (Exception e) {
                                adminVal = 0;
                            }

                            sClass = "text";
                            if (adminVal < val) {
                                sClass = "textred";
                            }

                            out.print(" <input name='prescr" + new SimpleDateFormat("yyyyMMdd").format(day) + "_" + line.getCarePrescription().getUid() + "_" + ((KeyValue) line.getTimeQuantities().elementAt(i)).getKey() + "' type='text' class='" + sClass + "' size='1' value='" + adminVal + "'/>");
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
    window.location.href = "<c:url value='/main.do'/>?Page=medical/manageCarePrescriptionsSchema.jsp&startdate=<%=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())%>";
  }
</script>