<script>
 Event.observe(window,"load",function(){changeInputColor();});

 function logOut(){
  window.location.href = "login.jsp?Action=logout&ts=<%=new java.util.Date().hashCode()%>";
 }
 function doNewSearch(){
  window.location.href = "searchPatient.jsp?ts=<%=new java.util.Date().hashCode()%>";
 }
 function showPatientMenu(){
  window.location.href = "patientMenu.jsp?ts=<%=new java.util.Date().hashCode()%>";
 }
 </script>
 
<%
    // credits
    if(!sUriPage.endsWith("welcome.jsp")){
	    %><div style="color:#999;text-align:right;font-size:9px">GA Open Source Edition by MXS SA/NV</div><%
	}
%>
</body>
</html>