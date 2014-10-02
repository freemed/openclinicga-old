<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- INNER CLASS : SiteData ------------------------------------------------------------------
	public class SiteData{
		java.util.Date date;
		int patients;
		int visits;
		int admissions;
		int transactions;
		int debets;
		int invoices;
		int labs;
		int id;
		String softwareversion;
	}

	public int countCities(SortedMap countries, String country){
		int members=0;
		members=((SortedMap)countries.get(country)).size();
		return members;
	}
	
	public int countSites(SortedMap countries, String country){
		int members=0;
		SortedMap cities = (SortedMap)countries.get(country);
		Iterator i = cities.keySet().iterator();
		while(i.hasNext()){
			members+=((SortedMap)cities.get(i.next())).size();
		}
		return members;
	}
%>
<%
	if(request.getParameter("logout")!=null){
		session.removeAttribute("datacenteruser");
	}
	if(request.getParameter("username")!=null && request.getParameter("password")!=null){
		if(MedwanQuery.getInstance().getConfigString("datacenterUserPassword."+request.getParameter("username"),"plmouidgsjejn,fjfk").equalsIgnoreCase(request.getParameter("password"))){
			session.setAttribute("datacenteruser",request.getParameter("username"));
		}
	}
    String jsonFileId = Long.toString(System.currentTimeMillis()); //request.getSession().getId();

%>
<html>
<head>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSCHAR%>
    <%=sJSPOPUPMENU%>
    <%//=sCSSNORMAL%>
    <%=sJSPROTOTYPE %>
    <%=sJSAXMAKER %>
    <%=sJSPROTOCHART %>
    <!--[if IE]>
    <%=sJSEXCANVAS %>
    <![endif]-->
    <%=sJSFUSIONCHARTS%>
    <%=sJSAXMAKER %>
    <%=sJSSCRPTACULOUS %>
    <%=sJSMODALBOX%>
    <%=sCSSDATACENTER%>
    <%=sCSSMODALBOXDATACENTER%>
    <!--[if IE]>
    <%=sCSSDATACENTERIE%>
     <![endif]-->
    <%
        /**
        * Insert project css if exists
        **/
        if(session.getAttribute("datacenteruser")!=null){
            out.write("<link href='"+sCONTEXTPATH+"/_common/_css/datacenter_"+session.getAttribute("datacenteruser")+".css' rel='stylesheet' type='text/css'>");
        }
    %>
</head>
<%
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", 0); //prevents caching at the proxy server
%>

<%
    String sPage=checkString(request.getParameter("p"));
    if(MedwanQuery.getInstance().getConfigString("BackButtonDisabled").equalsIgnoreCase("true")){
        %>
            <script>
              if(window.history.forward(1) != null){
               // window.history.forward(1);
              }
            </script>
        <%
    }
%>

<body>
        <div id="footer-wrap">
           <div id="footer-container">
                <div id="footer">
                    <div id="footer_logo">
                        <%
                            if(session.getAttribute("datacenteruser")!=null){
                        %>
                            <img height="40px;" src="<%=MedwanQuery.getInstance().getConfigString("datacenterUserLogo."+session.getAttribute("datacenteruser"))%>"/>
                        <%
                            }
                        %>

                        </div>
                        <div id="footer_info"><a href="javascript:window.location.href='datacenterHome.jsp';">Login</a> - <a href="javascript:setLanguage('PT')">Pt</a> <a href="javascript:setLanguage('ES')">Es</a> <a href="javascript:setLanguage('FR')">Fr</a> <a href="javascript:setLanguage('EN')">En</a> - developped by Mxs</div>
                </div>
            </div>
        </div>
        <div id="header-wrap">
            <div id="header-container">
                <div id="header">
                </div>
            </div>
        </div>
        <div id="container">
            <div id="content">
            	<label><h3><%=getTran("web","datacenter.intro",sWebLanguage).replaceAll("OpenClinic", "<a href='http://sourceforge.net/projects/open-clinic'>OpenClinic</a>") %> <%=getTran("web","datacenter.intro2",sWebLanguage)%></h3></label>
            	<table width="100%" class="content" cellpadding="0" cellspacing="1" style="padding:0px;">
			<%
				String toggleCountryCode="",toggleCountryIdx="";
				String me=checkString((String)session.getAttribute("me"));
				SiteData summarySite=new SiteData();
				SortedMap countries = new TreeMap();
				SortedMap cities = null, sites=null;
				Connection conn = MedwanQuery.getInstance().getStatsConnection();
				String sSql = "select distinct * from dc_monitorservers a, dc_monitorvalues b"+
				              " where b.dc_monitorvalue_serverid = a.dc_monitorserver_serverid"+
				              "  and b.dc_monitorvalue_date > ?"+
				              "  and a.dc_monitorserver_name<>''"+
				              "  and a.dc_monitorserver_country<>''"+
				              " order by dc_monitorserver_country, dc_monitorserver_city, dc_monitorserver_serverid, dc_monitorvalue_date desc";
				PreparedStatement ps=conn.prepareStatement(sSql);
				long month=30*24*3600;
				month=month*1000;
				ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()-MedwanQuery.getInstance().getConfigInt("gbhPublicInactivityPeriodInMonths",3)*month));
				ResultSet rs = ps.executeQuery();
				int serverid,activeServer=-1;
				while(rs.next()){
					serverid=rs.getInt("dc_monitorserver_serverid");
					if(serverid!=activeServer){
						activeServer=serverid;
						
						String country = rs.getString("dc_monitorserver_country").replaceAll("ZR","CD").replaceAll("BE","B");
						if(countries.get(country)==null){
							countries.put(country,new TreeMap());
						}
						
						cities=(SortedMap)countries.get(country);
						String city = rs.getString("dc_monitorserver_city");
						if(cities.get(city)==null){
							cities.put(city,new TreeMap());
						}
						
						sites=(SortedMap)cities.get(city);
						
						SiteData siteData = new SiteData();
						siteData.date=rs.getTimestamp("dc_monitorvalue_date");
						siteData.patients=rs.getInt("dc_monitorvalue_patientcount");
						siteData.visits=rs.getInt("dc_monitorvalue_visitcount");
						siteData.admissions=rs.getInt("dc_monitorvalue_admissioncount");
						siteData.labs=rs.getInt("dc_monitorvalue_labanalysescount");
						siteData.invoices=rs.getInt("dc_monitorvalue_patientinvoicecount");
						siteData.debets=rs.getInt("dc_monitorvalue_debetcount");
						siteData.id=activeServer;
						if(me.length()>0 && me.equalsIgnoreCase(checkString(rs.getString("dc_monitorserver_serveruid")))){
							toggleCountryCode=country;
						}
						siteData.softwareversion = checkString(rs.getString("dc_monitorserver_softwareversion"));
						sites.put(activeServer,siteData);
						
						summarySite.patients+=siteData.patients;
						summarySite.visits+=siteData.visits;
						summarySite.admissions+=siteData.admissions;
						summarySite.labs+=siteData.labs;
						summarySite.invoices+=siteData.invoices;
						summarySite.debets+=siteData.debets;
						summarySite.id++;
					}
				}
				rs.close();
				ps.close();
				conn.close();
				
				// headers per country
				Iterator countriesIter = countries.keySet().iterator();
				StringBuffer output = new StringBuffer();
				SiteData siteData;
				DecimalFormat deci = new DecimalFormat("#,###");
				String sCountryCode, sCountryName, sCity;
				Iterator citiesIter, sitesIter;
				
				int countryIdx= 0;
				while(countriesIter.hasNext()){
					sCountryCode = (String)countriesIter.next();
					countryIdx++;
					if(toggleCountryCode.equals(sCountryCode)){
						toggleCountryIdx=countryIdx+"";
					}
					sCountryName = getTranNoLink("country",sCountryCode,sWebLanguage).toUpperCase();
										
					// run though cities in country, counting totals
			        SiteData countryTotal = new SiteData();
					cities = (SortedMap)countries.get(sCountryCode);
					citiesIter = cities.keySet().iterator();
					while(citiesIter.hasNext()){
						sCity = (String)citiesIter.next();

						// sum sites in city
						sites = (SortedMap)cities.get(sCity);
						sitesIter = sites.keySet().iterator();
						while(sitesIter.hasNext()){
							siteData = (SiteData)sites.get(sitesIter.next());
							
							// sum totals per country
							countryTotal.patients+=siteData.patients;
							countryTotal.visits+=siteData.visits;
							countryTotal.admissions+=siteData.admissions;
							countryTotal.labs+=siteData.labs;
							countryTotal.invoices+=siteData.invoices;
							countryTotal.debets+=siteData.debets;
						}
					}

					output.append("<tr style='padding:0px;' bgcolor='#dddddd'>")
					       .append("<td colspan='1' width='25%' nowrap>")
					        .append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_plus.png' style='vertical-align:-3px;' id='plus_"+countryIdx+"' onClick=\"toggleSites('"+sCountryCode+"','"+countryIdx+"');\"/> <b>"+(sCountryCode.equals("B")?"BE":sCountryCode)+" - "+sCountryName+"</b>")
					       .append("</td>")
					       .append("<td align='right' width='15%'>"+countSites(countries,sCountryCode)+" "+getTran("web","sites",sWebLanguage)+" "+getTran("web","datacenter.in",sWebLanguage).toLowerCase()+" "+countCities(countries,sCountryCode)+" "+getTran("web","cities",sWebLanguage)+"</td>")
					       .append("<td align='right' width='10%'>"+deci.format(countryTotal.patients)+"</td>")
					       .append("<td align='right' width='10%'>"+deci.format(countryTotal.visits)+"</td>")
					       .append("<td align='right' width='10%'>"+deci.format(countryTotal.admissions)+"</td>")
					       .append("<td align='right' width='10%'>"+deci.format(countryTotal.labs)+"</td>")
					       .append("<td align='right' width='10%'>"+deci.format(countryTotal.invoices)+"</td>")
					       .append("<td align='right' width='10%'>"+deci.format(countryTotal.debets)+"</td>")
					      .append("</tr>");
					
					output.append("<tr style='padding:0px;' id='dataTR_"+countryIdx+"' style='visibility:hidden;'>")
					       .append("<td style='padding:0px;' colspan='8' id='dataDIV_"+countryIdx+"'>")
					        		
						   .append("</td>")
				          .append("</tr>");
				}
				
				// totals row : header
				out.println("<tr style='padding:0px;' bgcolor='black'>"+
				              "<td colspan='1' width='1%' nowrap><b><font color='white'>"+getTran("web","total",sWebLanguage)+"</font></b></td>"+
				              "<td>"+
				                "<font color='white'><b>"+summarySite.id+" "+getTran("web","sites",sWebLanguage)+" "+getTran("web","datacenter.in",sWebLanguage).toLowerCase()+" "+countries.size()+" "+getTran("web","countries",sWebLanguage)+"</b><br>"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','sites','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','sites','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				              "<td>"+
				                "<font color='white'><b>"+getTran("web","patients",sWebLanguage)+"</b><br>"+
				                  " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','patients','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','patients','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				              "<td>"+
				                "<font color='white'><b>"+getTran("web","outpatients",sWebLanguage)+"</b><br>"+
				                  " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','outpatients','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','outpatients','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				              "<td>"+
				                "<font color='white'><b>"+getTran("web","admissions",sWebLanguage)+"</b><br>"+
				                  " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','admissions','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','admissions','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				              "<td>"+
				                "<font color='white'><b>"+getTran("web","labanalyses",sWebLanguage)+"</b><br>"+
				                  " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','labanalyses','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','labanalyses','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				              "<td>"+
				                "<font color='white'><b>"+getTran("web","invoices",sWebLanguage)+"</b><br>"+
				                  " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','invoices','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','invoices','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				              "<td>"+
				                "<font color='white'><b>"+getTran("web","debets",sWebLanguage)+"</b><br>"+
				                  " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','debets','clusterer');\">GIS</a>]&nbsp;"+
						          " [<a style='color:white;' href='javascript:void(0);' onClick=\"openGISMap('"+summarySite.id+"','debets','mapChart');\">GISmap</a>]"+
				                "</font>"+
				              "</td>"+
				            "</tr>");

				// totals row : numbers
				out.println("<tr style='padding:0px;'>"+
			                  "<td/>"+
				              "<td/>"+
						      "<td align='right'><b>"+deci.format(summarySite.patients)+"</b></td>"+
				              "<td align='right'><b>"+deci.format(summarySite.visits)+"</b></td>"+
						      "<td align='right'><b>"+deci.format(summarySite.admissions)+"</b></td>"+
						      "<td align='right'><b>"+deci.format(summarySite.labs)+"</b></td>"+
						      "<td align='right'><b>"+deci.format(summarySite.invoices)+"</b></td>"+
				              "<td align='right'><b>"+deci.format(summarySite.debets)+"</b></td>"+
						    "</tr>");
								
				out.println(output);
		    %>
		</table>
    </div>
    <div class="pad2">&nbsp;</div>
</div>
        
  <script>
    var gisWin = null;
    var me='<%=checkString((String)session.getAttribute("me"))%>';

    <%-- OPEN GIS MAP --%>
    function openGISMap(siteId,parameter,mapType){    	
      if(gisWin) gisWin.close();  
	
      var url = "<c:url value='/datacenter/gis/createJSONPublic.jsp'/>?ts="+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: "siteId="+siteId+
                    "&parameter="+parameter+
                    "&mapType="+mapType+
                    "&jsonFileId=<%=jsonFileId%>."+parameter,
        onSuccess: function(resp){
          createHtml(siteId,parameter,mapType);     		
        },
        onFailure: function(resp){
      	  alert(resp.responseText);
        }
      });
    }
    
    <%-- CREATE HTML --%>
    function createHtml(siteId,parameter,mapType){       	
  	  if(mapType=="mapChart"){
        openGISMapContinued(siteId,parameter,mapType);   	
  	  }
      else{
	    var url = "<c:url value='/datacenter/gis/createHTML.jsp'/>?ts="+new Date().getTime();	
        new Ajax.Request(url,{
          method: "GET",
          parameters: "jsonFileId=<%=jsonFileId%>."+parameter+
                      "&htmlPage="+mapType+".html",
          onSuccess: function(resp){
        	  openGISMapContinued(siteId,parameter,mapType);   		
          },
          onFailure: function(resp){
            alert(resp.responseText);
          }
        });
  	  }
    }      
    
    <%-- OPEN GIS MAP CONTINUED --%>
    function openGISMapContinued(siteId,parameter,mapType){   	
  	  // circles|clusterer|customMarker|mapChart|heatMap|heatMapWeighted
      if(mapType=="mapChart"){
    	  var url = "<c:url value='/datacenter/gis/googleMaps/'/>"+mapType+"_<%=jsonFileId%>."+parameter+".html?ts="+new Date().getTime();
	      gisWin = window.open(url,"GISVisualiser","toolbar=no,status=no,scrollbars=yes,resizable=yes,width=810,height=520,menubar=no");
      }
      else{            
        var url = "<c:url value='/datacenter/gis/googleMaps/'/>"+mapType+"_<%=jsonFileId%>."+parameter+".html?ts="+new Date().getTime();
        gisWin = window.open(url,"GISVisualiser","toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1040,height=680,menubar=no");
      }
    
      gisWin.focus();
    }      
    
    <%-- TOGGLE SITES --%>
    function toggleSites(countryCode,countryIdx){
      var dataTR = document.getElementById("dataTR_"+countryIdx);
      var dataDIV = document.getElementById("dataDIV_"+countryIdx);
      var divIsOpen = (dataTR.style.visibility=="visible");
      
      <%-- change icon and toggle dataTR --%>
      var icon = document.getElementById("plus_"+countryIdx);
      if(divIsOpen==true){
    	icon.src = "<%=sCONTEXTPATH%>/_img/icons/icon_plus.png";
    	dataTR.style.visibility = "collapse";
      }
      else{
        icon.src = "<%=sCONTEXTPATH%>/_img/icons/icon_minus.png";
        dataTR.style.visibility = "visible";
        dataDIV.innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/default/ajax-loader.gif' style='vertical-align:-3px;'/>&nbsp;&nbsp;<%=getTranNoLink("web","loading",sWebLanguage)%>";
      }

      <%-- fetch data and put it in dataTR --%>
      if(divIsOpen==false){
	    var url = "<c:url value='/datacenter/ajax/getSitesForCountryHtml.jsp'/>?ts="+new Date().getTime();
        new Ajax.Request(url,{
          method: "GET",
          parameters: "CountryCode="+countryCode+"&me="+me,
          onSuccess: function(resp){
        	dataDIV.innerHTML = trim(resp.responseText);
          },
          onFailure: function(resp){
            alert(resp.responseText);
          }
        });
      }
    }

    function keepAlive(){
	        var r="";
	        var today = new Date();
	        var url= '<c:url value="/util/keepAlive.jsp"/>?ts='+today;
	        new Ajax.Request(url,{
	                method: "GET",
	                parameters: "",
	                onSuccess: function(resp){
	                }
	            }
	        );
	    }


    //  resizeAllTextareas(10);

      <%
          if(MedwanQuery.getInstance().getConfigString("BackButtonDisabled").equalsIgnoreCase("true")){
              %>
                if(window.history.forward(1) != null){
                 // window.history.forward(1);
                }
              <%
          }
      %>

      function logout(){
  		window.location.href="<c:url value="/datacenter/datacenterHome.jsp?logout=true"/>";
      }

    function openPopupWindow(page, width, height, title){
        if (width == undefined){
            width = 700;
        }
        if (height == undefined){
            height = 400;
        }
        if (title == undefined) {
           title = "&nbsp;";
        }
        page = "<c:url value="/"/>"+page;

        Modalbox.show(page, {title: title, width: width,height: height} );
    }

    function setGraph(array){
        var options = {
        lines: { show: true },
        points: { show: false },
        xaxis: { mode: "time",fillColor:"#00ff00",monthNames:["jan","Fev","Mar","Avr","Mai","Jun","Jul","Aou","Sep","Oct","Nov","Dec"]},
        selection: { mode: "x" }
        };

        new Proto.Chart($('barchart'),
        [
            {data: array, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"}
        ],options);
    }
    function setGraph2(array,array2){
        var options = {
        lines: { show: true },
        points: { show: false },
        xaxis: { mode: "time",fillColor:"#00ff00",monthNames:["jan","Fev","Mar","Avr","Mai","Jun","Jul","Aou","Sep","Oct","Nov","Dec"]},
        selection: { mode: "x" }
        };

        new Proto.Chart($('barchart'),
        [
         {data: array, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"},
         {data: array2, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"}
        ],options);
    }
    function setGraph2Named(array,array2,name,legend1,legend2){
        var options = {
        legend: {
			show: true,
			noColumns: 1,
			labelFormatter: function(str) { return ""+str+""},
			labelBoxBorderColor: "#dedede",
			position: "ne",
			backgroundColor: "#eee",
			backgroundOpacity: 0.3
		},
		grid: {
			borderWidth: 2,
			coloredAreas: [{y1: 5, y2:7}, {x1: 5, x2: 7.5}],
			coloredAreasColor: "#FFF2F9",
			drawXAxis: true,
			drawYAxis: true,
			clickable: true
		},
        points: { show: false },
        xaxis: { mode: "time",fillColor:"#00ff00",monthNames:["jan","Fev","Mar","Avr","Mai","Jun","Jul","Aou","Sep","Oct","Nov","Dec"]},
        selection: { mode: "x" }
        };

        new Proto.Chart($(name),
        [
         {data: array, label: legend1},
         {data: array2, label: legend2, lines: {fill: true}}
        ],options);
    }
    function setGraph3(array,array2,array3){
        var options = {
        lines: { show: true },
        points: { show: false },
        xaxis: { mode: "time",fillColor:"#00ff00",monthNames:["jan","Fev","Mar","Avr","Mai","Jun","Jul","Aou","Sep","Oct","Nov","Dec"]},
        selection: { mode: "x" }
        };

        new Proto.Chart($('barchart'),
        [
         {data: array, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"},
         {data: array2, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"},
         {data: array3, label: "<%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%>"}
        ],options);
    }
    function setGraph4(array,array2,array3,array4,legend1,legend2,legend3,legend4){
        var options = {
        legend: {
			show: true,
			noColumns: 2,
			labelFormatter: function(str) { return ""+str+""},
			labelBoxBorderColor: "#dedede",
			position: "ne",
			backgroundColor: "#eee",
			backgroundOpacity: 0.3
		},
		grid: {
			borderWidth: 2,
			coloredAreas: [{y1: 5, y2:7}, {x1: 5, x2: 7.5}],
			coloredAreasColor: "#FFF2F9",
			drawXAxis: true,
			drawYAxis: true,
			clickable: true
		},
        xaxis: { mode: "time",fillColor:"#00ff00",monthNames:["jan","Fev","Mar","Avr","Mai","Jun","Jul","Aou","Sep","Oct","Nov","Dec"]},
        selection: { mode: "x" }
        };

        new Proto.Chart($('barchart'),
        [
         {data: array, label: legend1},
         {data: array2, label: legend2},
         {data: array3, label: legend3,lines: {fill: true}},
         {data: array4, label: legend4,lines: {fill: true}}
        ],options);
    }
    
    function entsub(event,ourform) {
        if (event && event.which == 13){
            $('transactionForm').submit();
            return true;
        }else{
           return false;
        }
    }
    function setLanguage(language){
        var today = new Date();
        var url= '<c:url value="/datacenter/setLanguage.jsp"/>?ts='+today;
        new Ajax.Request(url,{
                method: "GET",
                parameters: "language="+language,
                onSuccess: function(resp){
    				window.location.reload();
                }
            }
        );
    }
    
    if(me.length>0){
    	toggleSites('<%=toggleCountryCode%>','<%=toggleCountryIdx%>');
    }
    </script>
</body>


</html>