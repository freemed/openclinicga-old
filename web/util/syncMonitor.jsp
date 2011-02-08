<%@include file="/includes/validateUser.jsp"%>
<head>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sCSSNORMAL%>
    <%=sJSPROTOTYPE %>
    <%=sJSAXMAKER %>
</head>
<%
%>
<%
	//Start hier een aparte thread op die de Synchroniser in een achtergrondproces uitvoert
	
%>
<!-- Toon de ajax-loader.gif om aan te geven dat de synchroniser aan het draaien is -->
<div id='divMonitor'><img src='<c:url value="/_img/ajax-loader.gif"/>'/></div>
<!-- Toon een bericht om aan te geven dat de synchroniser werd opgestart  -->
<div id='divMonitorMessage'>Started</div>
<script>

	//Start hier om de twee seconden een Ajax routine op die gaat kijken of het Synchroniser-achtergrondproces nog draait
	//Zie de Ajax routine (loadSyncMonitorData.jsp) voor de logica die controleert of de Synchroniser al dan niet klaar is
	monitorProcess=window.setInterval("loadSyncMonitorData()",2000);
	
    function loadSyncMonitorData(){
        var url= '<c:url value="/util/loadSyncMonitorData.jsp"/>?ts=' + new Date();
        new Ajax.Request(url,{
                method: "GET",
                onSuccess: function(resp){
		            var s = resp.responseText.trim();
		            var resultCode=s.split(';')[0];
		            var resultMessage=s.split(';')[1];
		            if(resultCode=="0"){
			            //Synchroniser werd beëindigd
			            //Verwijder ajax-loader.gif
						$('divMonitor').innerHTML='';
						//Stop het om de twee seconden uitvoeren van de Ajax routine
						window.clearInterval(monitorProcess);
		            }
		            //Toon een bericht met daarin het resultaat teruggegeven door de Ajax routine
		            $('divMonitorMessage').innerHTML=resultMessage;
                },
                onFailure: function(){
                    alert('Error checking synchroniser status');
                }
            }
        );
    }

    
</script>