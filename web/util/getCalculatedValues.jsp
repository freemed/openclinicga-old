<%@include file="/includes/validateUser.jsp"%>
<%
    String returnValue = "";
    String valueType   = request.getParameter("valueType");
    String sourceField = request.getParameter("sourceField");

    if (valueType.equalsIgnoreCase("nextVaccinationDate")){
        String vaccinationType    = checkString(request.getParameter("vaccinationType"));
        String vaccinationSubType = checkString(request.getParameter("vaccinationSubType"));
        String vaccinationDate    = checkString(request.getParameter("vaccinationDate"));

        try{
            java.util.Date nextDate = MedwanQuery.getInstance().calculateNextVaccination(vaccinationType,vaccinationSubType,new SimpleDateFormat("dd/MM/yyyy").parse(vaccinationDate));
            if(nextDate!=null){
                returnValue = new SimpleDateFormat("dd/MM/yyyy").format(nextDate);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
    }
%>
<!-- Let's return the calculated value here -->
<script>
  window.opener.document.getElementsByName('<%=sourceField%>')[0].value='<%=returnValue%>';
  window.close();
</script>