package be.openclinic.datacenter;

import java.net.URL;
import java.util.Iterator;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class District {
	String id;
	String province;
	String name;
	String zipcode;
	String map;
	double score;
	
	public District(String id, String province, String name, String zipcode,
			String map, double score) {
		super();
		this.id = id;
		this.province = province;
		this.name = name;
		this.zipcode = zipcode;
		this.map = map;
		this.score = score;
	}
	
	
	public District() {
		super();
	}
	
	public static District getDistrictWithZipcode(String countryFile, String zipcode){
        District d = null;
		SAXReader reader = new SAXReader(false);
        try {
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + countryFile;
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("district");
            Element district;
            String l_zipcode;
            while (elements.hasNext()) {
                district = (Element) elements.next();
                l_zipcode=district.attributeValue("zipcode");
                if(l_zipcode.equalsIgnoreCase(zipcode)){
                	d = new District(district.attributeValue("id"),district.attributeValue("province"),district.attributeValue("district"),zipcode,root.attributeValue("directory")+"/"+district.attributeValue("map"),0);
                }
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        return d;
	}

	public static District getDistrictWithId(String countryFile, String id){
        District d = null;
		SAXReader reader = new SAXReader(false);
        try {
            String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + countryFile;
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Iterator elements = root.elementIterator("district");
            Element district;
            String l_id;
            while (elements.hasNext()) {
                district = (Element) elements.next();
                l_id=district.attributeValue("id");
                if(l_id.equalsIgnoreCase(id)){
                	d = new District(id,district.attributeValue("province"),district.attributeValue("district"),district.attributeValue("zipcode"),root.attributeValue("directory")+"/"+district.attributeValue("map"),0);
                }
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        return d;
	}

	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getProvince() {
		return province;
	}
	public void setProvince(String province) {
		this.province = province;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getZipcode() {
		return zipcode;
	}
	public void setZipcode(String zipcode) {
		this.zipcode = zipcode;
	}
	public String getMap() {
		return map;
	}
	public void setMap(String map) {
		this.map = map;
	}
	public double getScore() {
		return score;
	}
	public void setScore(double score) {
		this.score = score;
	}
	
	
}
