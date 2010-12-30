package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.text.SimpleDateFormat;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class ImportAckMessage extends DatacenterMessage {
	
	public ImportAckMessage(String xml){
        SAXReader reader = new SAXReader(false);
        try {
			Document document = reader.read(new ByteArrayInputStream(xml.getBytes("UTF-8")));
			Element root = document.getRootElement();
			Element data = root.element("data");
			if(data!=null){
				setServerId(Integer.parseInt(data.attributeValue("serverid")));
				setObjectId(Integer.parseInt(data.attributeValue("objectid")));
				setImportAckDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("importackdatetime")));
				setImportDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("importdatetime")));
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public ImportAckMessage(Element data){
        SAXReader reader = new SAXReader(false);
        try {
			if(data!=null){
				setServerId(Integer.parseInt(data.attributeValue("serverid")));
				setObjectId(Integer.parseInt(data.attributeValue("objectid")));
				setError(Integer.parseInt(data.attributeValue("errorcode")));
				setImportAckDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("importackdatetime")));
				setImportDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("importdatetime")));
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
