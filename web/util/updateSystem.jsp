<%@page import="be.mxs.common.util.system.*"%>
<%@include file="/includes/helper.jsp"%>
<%=sJSJQUERY%>
<%=sCSSNORMAL%>
<%=sIcon%>

<title>OpenClinic Update</title>

<style>
 #infoBox {
   width: 450px;
   height: 100px;
   border: 1px solid #9DBFDB;
   text-align: center;
   float: center;
   padding: 30px;
   padding-top: 20px;
   background-color: #D2E0EB; 
   font-size: 11px;
 }
  
 #progressBarSpace {
   width: 90%px;
   height: 20px;
   border: 1px solid #9DBFDB;
   background-color: white;
 }
 
 #progressBar {
   background-color: #9DBFDB;
   height: 18px;
   width: 0%;
   text-align: center;
   float: left;
   padding-top: 2px;
   color: white;
 }
</style>

<%
    String sTmpAPPDIR = ScreenHelper.checkString(ScreenHelper.getCookie("activeProjectDir",request));
    String sProcessID = checkString(request.getParameter("processId"));
%>

<center>
<div style="width:100%;height:100%;padding-top:100px">
  <div id="infoBox">
    <br>The OpenClinic system is being updated. This might take several minutes.<br><br>
    <div id="progressBarSpace">
      <div id="progressBar" style="text-weight:normal"></div>
    </div>
  </div>
</div>
</center>

<script>
  var processID = "<%=sProcessID%>";
  setTimeout(checkProgress,50);

  <%-- CHECK PROGRESS --%>
  function checkProgress(){
    $.getJSON("systemUpdateProgressServlet?processId="+processID+"&ts="+new Date().getTime(),function(progress){
      $("#progressBar").text(progress+"%");
      $("#progressBar").width(progress+"%");

      if(parseInt(progress) < 100){
        setTimeout(checkProgress,500);
      }
      else{
        document.getElementById("progressBar").style.textWeight = "bold";
    	$("#progressBar").text("COMPLETE");
        setTimeout(goToLogin,2000);
      }
    }); 
  }
  
  <%-- GO TO LOGIN --%>
  function goToLogin(){
  	window.location.href = "<%=sCONTEXTPATH%>/<%=sTmpAPPDIR%>";
  }
</script>
