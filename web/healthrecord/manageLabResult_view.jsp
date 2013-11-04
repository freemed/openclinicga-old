<%@ page import="be.openclinic.medical.RequestedLabAnalysis" %>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.medical.LabRequest" %>
<%@ page import="java.util.Date" %>
<%@ page import="be.openclinic.medical.LabAnalysis" %>
<%@ page import="java.text.DecimalFormat" %>
<%!
    public class LabRow {
        int type;
        String tag;

        public LabRow(int type, String tag) {
            this.type = type;
            this.tag = tag;
        }
    }

public String getComplexResult(String id, Map map, String sWebLanguage) {
	    String sReturn = "<input type='hidden' name='result." + id + "' />";
	    sReturn += "<input type='hidden' id='resultAntibio." + id + ".germ1' name='resultAntibio." + id + ".germ1' value='" + checkString((String) map.get("germ1")) + "'/>";
	    sReturn += "<input type='hidden' id='resultAntibio." + id + ".germ2' name='resultAntibio." + id + ".germ2' value='" + checkString((String) map.get("germ2")) + "' />";
	    sReturn += "<input type='hidden' id='resultAntibio." + id + ".germ3' name='resultAntibio." + id + ".germ3' value='" + checkString((String) map.get("germ3")) + "' />";
	    sReturn += "<input type='hidden' id='resultAntibio." + id + ".antibio1' name='resultAntibio." + id + ".ANTIBIOGRAMME1' value='" + checkString((String) map.get("ANTIBIOGRAMME1")) + "' />";
	    sReturn += "<input type='hidden' id='resultAntibio." + id + ".antibio2' name='resultAntibio." + id + ".ANTIBIOGRAMME2' value='" + checkString((String) map.get("ANTIBIOGRAMME2")) + "' />";
	    sReturn += "<input type='hidden' id='resultAntibio." + id + ".antibio3' name='resultAntibio." + id + ".ANTIBIOGRAMME3' value='" + checkString((String) map.get("ANTIBIOGRAMME3")) + "' />";
	    sReturn += "<a class='link' style='padding-left:2px' href='javascript:void(0)' onclick='openComplexResult(\"" + id + "\")'>" + getTranNoLink("labanalysis", "viewantibiogramresult", sWebLanguage) + "</a>";
	    return sReturn;
	}

%>
<head>
    <%=sCSSNORMAL%>
</head>

<body/>
<%
    SortedMap requestList = new TreeMap();
    Enumeration parameters = request.getParameterNames();
    while (parameters.hasMoreElements()) {
        String name = (String) parameters.nextElement();
        String[] items = name.split("\\.");
        if (items[0].equalsIgnoreCase("show")) {
            LabRequest labRequest = new LabRequest(Integer.parseInt(items[1]),Integer.parseInt(items[2]));
            if(labRequest.getRequestdate()!=null){
                requestList.put(new SimpleDateFormat("yyyyMMddHHmmss").format(labRequest.getRequestdate())+"."+items[1]+"."+items[2],labRequest);
            }
        }
    }

    SortedMap groups = new TreeMap();
    Iterator iterator = requestList.keySet().iterator();
    while(iterator.hasNext()){
        LabRequest labRequest=(LabRequest)requestList.get(iterator.next());
        Enumeration enumeration = labRequest.getAnalyses().elements();
        while(enumeration.hasMoreElements()){
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)enumeration.nextElement();
            if(groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group",requestedLabAnalysis.getLabgroup(),sWebLanguage))==null){
                groups.put(MedwanQuery.getInstance().getLabel("labanalysis.group",requestedLabAnalysis.getLabgroup(),sWebLanguage),new Hashtable());
            }
            ((Hashtable)groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group",requestedLabAnalysis.getLabgroup(),sWebLanguage))).put(requestedLabAnalysis.getAnalysisCode(),"1");
        }
    }

%>
<table class="list" width="100%">
    <tr>
        <td colspan="3"><%=getTran("web","analysis",sWebLanguage)%></td>
    <%
        Iterator requestsIterator = requestList.keySet().iterator();
        while (requestsIterator.hasNext()) {
            LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
            out.println("<td>" + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate()) + "&nbsp;&nbsp;&nbsp;" +
                    "<a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a>&nbsp;&nbsp;&nbsp;" +
                    "<a href='javascript:printRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + getTran("web","print",sWebLanguage) + "</b></a></td>");
        }
    %>
    </tr>
    <%
        String abnormal=MedwanQuery.getInstance().getConfigString("abnormalModifiers","*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*");
        Iterator groupsIterator = groups.keySet().iterator();
          int i = 0;   // for colors
        while(groupsIterator.hasNext()){
            i++;
            String groupname=(String)groupsIterator.next();
            Hashtable analysisList = (Hashtable)groups.get(groupname);
            out.print("<tr><td class='color color"+i+"' rowspan='"+(analysisList.size())+"'><b>"+MedwanQuery.getInstance().getLabel("labanalysis.group",groupname,sWebLanguage)+"</b></td>");

            SortedSet sortedSet = new TreeSet();
            sortedSet.addAll(analysisList.keySet());
            Iterator analysisEnumeration = sortedSet.iterator();
            while (analysisEnumeration.hasNext()){
                String analysisCode=(String)analysisEnumeration.next();
                String c = analysisCode;
                String u = "";
                String refs="";
                LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisCode);
                if(analysis!=null){
                    c=analysis.getLabId()+"";
                    u=" ("+analysis.getUnit()+")";
                    String min=analysis.getResultRefMin(activePatient.gender,activePatient.getAge());
                    try{
                        float f=Float.parseFloat(min.replace(",","."));
                        min=new DecimalFormat("#,###.###").format(f);
                    }
                    catch (Exception e){}
                    String max=analysis.getResultRefMax(activePatient.gender,activePatient.getAge());
                    try{
                        float f=Float.parseFloat(max.replace(",","."));
                        max=new DecimalFormat("#,###.###").format(f);
                    }
                    catch (Exception e){}
                    refs=" ["+min+"-"+max+"]";
                }
                out.print("<td class='color color" + i + "' width='1%'>"+analysisCode+"</td><td class='color color" + i + "'><b>"+LabAnalysis.labelForCode(analysisCode,sWebLanguage)+" "+u+refs+"</b></td>");
                requestsIterator = requestList.keySet().iterator();
                while(requestsIterator.hasNext()){
                    LabRequest labRequest = (LabRequest)requestList.get(requestsIterator.next());
                    RequestedLabAnalysis requestedLabAnalysis=(RequestedLabAnalysis)labRequest.getAnalyses().get(analysisCode);
                    String result="";
                    if(requestedLabAnalysis!=null){
                    	if(!requestedLabAnalysis.getLabgroup().equalsIgnoreCase("bacteriology")){
                    		if(analysis.getLimitedVisibility()>0 && !activeUser.getAccessRight("labos.limitedvisibility.select")){
                    			result=getTran("web","invisible",sWebLanguage);	
                    		}
                    		else if(requestedLabAnalysis.getFinalvalidation()>0){
	                    		result=requestedLabAnalysis.getResultValue();
	                    	}
	                    	else {
	                    		result="?";
	                    	}
                    	}
                    	else {
	                    	if(requestedLabAnalysis.existsNonEmptyAntibiogrammesByUid(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode())){
	                        	result = getComplexResult(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode(), RequestedLabAnalysis.getAntibiogrammes(labRequest.getServerid() + "." + labRequest.getTransactionid() + "." + requestedLabAnalysis.getAnalysisCode()), sWebLanguage);                        	
	                    	}
	                    	else {
	                    		result="?";
	                    	}
                    	}
                    }
                    
                    boolean bAbnormal=(result.length()>0 && !result.equalsIgnoreCase("?") && abnormal.toLowerCase().indexOf("*"+checkString(requestedLabAnalysis.getResultModifier()).toLowerCase()+"*")>-1);
                    out.println("<td class='color color" + i + "'>"+result+(bAbnormal?" "+checkString(requestedLabAnalysis.getResultModifier().toUpperCase()):"")+"</td>");
                }
				//Todo: add link to unvalidate result and then remove image
                out.print("</tr>");
            }
        }
    %>
</table>
</body>
<script type="text/javascript">
    function resizeMe(w,h){
        window.resizeTo(w,h);
        window.moveTo((screen.width-w)/2,(screen.height-h)/2)
    }
    function showRequest(serverid,transactionid){
        window.open("<c:url value='/labos/manageLabResult_view.jsp'/>?ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }
    function printRequest(serverid,transactionid){
        window.open("<c:url value='/labos/createLabResultsPdf.jsp'/>?ts=<%=getTs()%>&print."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }
    openComplexResult = function(id) {
        var params = "antibiogramuid=" + id + "&editable=false";
        var url = "<c:url value="/labos/ajax/getComplexResult.jsp" />?ts=" + new Date().getTime();
        Modalbox.show(url, {title:"<%=getTranNoLink("web","antibiogram",sWebLanguage)%>",params:params,width:600});
    }
    addObserversToAntibiogram = function(id) {
        $("germ1").value = $F("resultAntibio." + id + ".germ1");
        $("germ2").value = $F("resultAntibio." + id + ".germ2");
        $("germ3").value = $F("resultAntibio." + id + ".germ3");
        setCheckBoxValues(id, $F("resultAntibio." + id + ".antibio1").split(","), 1);
        setCheckBoxValues(id, $F("resultAntibio." + id + ".antibio2").split(","), 2);
        setCheckBoxValues(id, $F("resultAntibio." + id + ".antibio3").split(","), 3);
        $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
            e.parentNode.observe('click', function(event) {
                //alert(Event.element(event));
                var elem = Event.element(event);
                if (elem.tagName == "TD") {
                    if (elem.firstChild.checked) {
                        elem.firstChild.checked = false;
                    } else {
                        elem.firstChild.checked = true;
                        new Effect.Highlight(elem, { startcolor: '#FFE7DA'});
                    }
                } else {
                    new Effect.Highlight(elem.parentNode, { startcolor: '#FFE7DA'});
                }
            });
        });

    }
    setCheckBoxValues = function(id, tab, nb) {
        tab.each(function(anti) {
            if (anti.length > 0) {
                var tAnti = anti.split("=");
                try {
                    $(tAnti[0] + "_radio_" + nb + "_" + tAnti[1]).checked = true;
                } catch(e) {
                    alert(tAnti[0] + "_radio_" + nb + "_" + tAnti[1]);
                }
            }
        });
    }
    setAntibiogram = function (id) {
        var s = "";
        $("resultAntibio." + id + ".germ1").value = $F("germ1");
        $("resultAntibio." + id + ".germ2").value = $F("germ2");
        $("resultAntibio." + id + ".germ3").value = $F("germ3");
        $("resultAntibio." + id + ".antibio1").value = "";
        $("resultAntibio." + id + ".antibio2").value = "";
        $("resultAntibio." + id + ".antibio3").value = "";
        $('antibiogramtable').getElementsBySelector('[type="radio"]').each(function(e) {
            if (e.checked) {
                s += "\n" + e.name + " -  " + e.value;
                var tab = e.name.split("_");
                $("resultAntibio." + id + ".antibio" + tab[2]).value = $F("resultAntibio." + id + ".antibio" + tab[2]) + "," + tab[0] + "=" + e.value;
            }
        });
        Modalbox.hide();
    }
</script>