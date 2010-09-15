<%@include file="/includes/validateUser.jsp"%>

<center>
<table width="20%">
<tr><td>
<img src="<c:url value='/'/>_img/aries.jpg"/>
</td><td>
<table width="18%">
<%

    // load config values from XML
    try {
        SAXReader reader = new SAXReader(false);
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "archive.xml";
        Document document = reader.read(new URL(sDoc));
        Element root = document.getRootElement();
        for(int n=activePatient.getID("archiveFileCode").length()-1;n>=0;n--){
            Iterator elements = root.elementIterator("letter");
            Element letter;
            while (elements.hasNext()) {
                letter = (Element) elements.next();
                if(letter.attributeValue("id").equalsIgnoreCase(activePatient.getID("archiveFileCode").substring(n,n+1))){
                    out.println("<tr><td align='center' style='{border-style: solid; border-color: black;border-left-width: 1px;border-top-width: 1px;border-right-width: 1px;border-bottom-width: 1px;;color: "+letter.attributeValue("color")+" }' bgcolor='"+letter.attributeValue("bgcolor")+"'><font style='{vertical-align: center;font-size: 47px;font-weight: bold;}'>"+letter.attributeValue("id").toUpperCase()+"</font></td></tr>");
                    break;
                }
            }
        }
    }
    catch (Exception e) {
        if(Debug.enabled) Debug.println(e.getMessage());
    }

%>
</table>
</td></tr>
</table>

</center>