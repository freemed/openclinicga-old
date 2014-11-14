<%@include file="/includes/validateUser.jsp"%>

<center>
    <table width="20%" style="padding-top:10px">
        <tr>
            <td><img src="<%=sCONTEXTPATH%>/_img/aries.jpg"/></td>
            <td>
                <table width="18%">
				<%				
				    // load config values from XML
				    try{
				        SAXReader reader = new SAXReader(false);
				        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"archive.xml";
				        Document document = reader.read(new URL(sDoc));
				        Element root = document.getRootElement();
				        
				        for(int n=activePatient.getID("archiveFileCode").length()-1; n>=0; n--){
				            Iterator elements = root.elementIterator("letter");
				            
				            Element letter;
				            while(elements.hasNext()){
				                letter = (Element)elements.next();
				                if(letter.attributeValue("id").equalsIgnoreCase(activePatient.getID("archiveFileCode").substring(n,n+1))){
				                    out.print("<tr>"+
				                                "<td style='border:1px solid black; color:"+letter.attributeValue("color")+"; background:"+letter.attributeValue("bgcolor")+"; padding:0 5px'>"+
				                                  "<font style='font-size:47px; font-weight:bold;'>"+letter.attributeValue("id").toUpperCase()+"</font>"+
				                                "</td>"+
				                              "</tr>");
				                    break;
				                }
				            }
				        }
				    }
				    catch(Exception e){
				        Debug.printStackTrace(e);
				    }				    
				%>
				</table>
			</td>
	    </tr>
	</table>
</center>