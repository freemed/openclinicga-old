<%@page import="be.openclinic.pharmacy.*,org.dom4j.*,org.dom4j.io.*,java.util.*,java.text.*,java.sql.*,be.mxs.common.util.db.*,be.mxs.common.util.system.*"%>
<%
	//Now output the document as an XML-file to the brwoser
	org.dom4j.Document document = DocumentHelper.createDocument();
	Element root = document.addElement("message");
	root.addAttribute("date", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new java.util.Date()));
	//We zoeken de huidige status op van de stockgegevens
	String pharmacyexportmodules = MedwanQuery.getInstance().getConfigString("pharmacyexportmodules","");
	if(pharmacyexportmodules.contains("servicestockstatus")){
		//Export the actual data of the Pharmacy Stock
		String pharmacyexportstock = MedwanQuery.getInstance().getConfigString("pharmacyexportstock","");
		if(pharmacyexportstock.length()>0){
			//First write a header for the servicestock
			ServiceStock serviceStock = ServiceStock.get(pharmacyexportstock);
			Element eSection = root.addElement("section");
			eSection.addAttribute("type", "servicestockstatus");
			eSection.addAttribute("id", serviceStock.getUid());
			eSection.addAttribute("name", serviceStock.getName());
			//now add elements for the productstocks
			Vector productstocks = serviceStock.getProductStocks();
			for(int n=0;n<productstocks.size();n++){
				ProductStock productStock = (ProductStock)productstocks.elementAt(n);
				Element eProductStock = eSection.addElement("productstock");	
				eProductStock.addAttribute("stockid", ScreenHelper.checkString(productStock.getUid()));
				eProductStock.addAttribute("productid", ScreenHelper.checkString(productStock.getProductUid()));
				eProductStock.addAttribute("productunit", ScreenHelper.checkString(productStock.getProduct()==null?"":productStock.getProduct().getUnit()));
				eProductStock.addAttribute("productpackage", productStock.getProduct()==null?"":productStock.getProduct().getPackageUnits()+"");
				eProductStock.addAttribute("stocklevel", productStock.getLevel()+"");
				eProductStock.addText(HTMLEntities.htmlentities(ScreenHelper.checkString(productStock.getProduct()==null?"":productStock.getProduct().getName())));
			}
		}
	}
	if(pharmacyexportmodules.contains("productstockoperations")){
		//Export the actual data of the Pharmacy Stock
		String pharmacyexportstock = MedwanQuery.getInstance().getConfigString("pharmacyexportstock","");
		if(pharmacyexportstock.length()>0){
			//First write a header for the servicestock
			ServiceStock serviceStock = ServiceStock.get(pharmacyexportstock);
			Element eSection = root.addElement("section");
			eSection.addAttribute("type", "productstockoperations");
			eSection.addAttribute("id", serviceStock.getUid());
			eSection.addAttribute("name", serviceStock.getName());
			//now add elements for the productstockoperations
			Vector productstocks = serviceStock.getProductStocks();
			for(int n=0;n<productstocks.size();n++){
				ProductStock productStock = (ProductStock)productstocks.elementAt(n);
				Element eProductStock = eSection.addElement("productstock");	
				eProductStock.addAttribute("stockid", ScreenHelper.checkString(productStock.getUid()));
				eProductStock.addAttribute("productid", ScreenHelper.checkString(productStock.getProductUid()));
				eProductStock.addAttribute("productunit", ScreenHelper.checkString(productStock.getProduct()==null?"":productStock.getProduct().getUnit()));
				eProductStock.addAttribute("productpackage", productStock.getProduct()==null?"":productStock.getProduct().getPackageUnits()+"");
				eProductStock.addAttribute("stocklevel", productStock.getLevel()+"");
				eProductStock.addText(productStock.getProduct()==null?"":HTMLEntities.htmlentities(ScreenHelper.checkString(productStock.getProduct().getName())));
				Vector operations = productStock.getAllProductStockOperations();
				for(int i=0;i<operations.size();i++){
					ProductStockOperation operation = (ProductStockOperation)operations.elementAt(i);
					Element eOperation = eProductStock.addElement("operation");
					eOperation.addAttribute("id", operation.getUid());
					eOperation.addAttribute("date", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(operation.getDate()));
					eOperation.addAttribute("type", ScreenHelper.checkString(operation.getDescription()));
					eOperation.addAttribute("batch", ScreenHelper.checkString(operation.getBatchNumber()));
					eOperation.addAttribute("sourcedestinationtype", ScreenHelper.checkString(operation.getSourceDestination().getObjectType()));
					eOperation.addAttribute("sourcedestinationid", ScreenHelper.checkString(operation.getSourceDestination().getObjectUid()));
				}
			}
		}
	}
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenpharmacyExport." + MedwanQuery.getInstance().getConfigString("mdnacserverid")+"."+ new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date()) + ".xml\"");
    ServletOutputStream os = response.getOutputStream();
	XMLWriter writer = new XMLWriter(os);	
	writer.setEscapeText(false);
	writer.write(document);
    os.flush();
    os.close();
%>