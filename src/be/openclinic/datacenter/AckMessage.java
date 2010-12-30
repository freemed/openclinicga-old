package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.text.SimpleDateFormat;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

public class AckMessage extends DatacenterMessage {
	
	public AckMessage(String xml){
        SAXReader reader = new SAXReader(false);
        try {
			Document document = reader.read(new ByteArrayInputStream(xml.getBytes("UTF-8")));
			Element root = document.getRootElement();
			Element data = root.element("data");
			if(data!=null){
				setServerId(Integer.parseInt(data.attributeValue("serverid")));
				setObjectId(Integer.parseInt(data.attributeValue("objectid")));
				setAckDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("ackdatetime")));
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public AckMessage(Element data){
        SAXReader reader = new SAXReader(false);
        try {
			if(data!=null){
				setServerId(Integer.parseInt(data.attributeValue("serverid")));
				setObjectId(Integer.parseInt(data.attributeValue("objectid")));
				setAckDateTime(new SimpleDateFormat("yyyyMMddHHmmss").parse(data.attributeValue("ackdatetime")));
			}
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
