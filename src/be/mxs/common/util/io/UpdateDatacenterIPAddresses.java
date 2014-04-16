package be.mxs.common.util.io;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.StringReader;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Vector;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import net.admin.User;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;

public class UpdateDatacenterIPAddresses {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//Find date of last export
		try {
			StringBuffer exportfile = new StringBuffer();
			// This will load the MySQL driver, each DB has its own driver
		    Class.forName("com.mysql.jdbc.Driver");			
		    Connection conn =  DriverManager.getConnection("jdbc:mysql://localhost:3306/ocstats_dbo?"+args[0]);
			Date lastexport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse("19000101000000000");
			PreparedStatement ps = conn.prepareStatement("select * from dc_monitorservers where (dc_monitorserver_country is null or dc_monitorserver_country='' or dc_monitorserver_city is null or dc_monitorserver_city='') and dc_monitorserver_name is not null and dc_monitorserver_name<>''");
		    ResultSet rs = ps.executeQuery();
		    while(rs.next()){
		    	String ip=rs.getString("dc_monitorserver_name");
		    	int id = rs.getInt("dc_monitorserver_serverid");
    			String location="";

		    	String[] ips = ip.split(",");
		    	for(int n=0;n<ips.length;n++){
		    		if(!ips[n].startsWith("10.") && !ips[n].startsWith("192.168.")){
		    			HttpClient client = new HttpClient();
		    			String url = "http://api.ipinfodb.com/v3/ip-city";
		    			GetMethod method = new GetMethod(url);
		    			method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
		    			Vector<NameValuePair> vNvp = new Vector<NameValuePair>();
		            	vNvp.add(new NameValuePair("key","70ea4340aef713dcc480e4a769f65baac5f487363baa8fac715058301df596c1"));
		            	vNvp.add(new NameValuePair("ip",ips[n]));
		            	vNvp.add(new NameValuePair("format","xml"));
		    			NameValuePair[] nvp = new NameValuePair[vNvp.size()];
		    			vNvp.copyInto(nvp);
		    			method.setQueryString(nvp);
		    			int statusCode = client.executeMethod(method);
		    			System.out.println("checking ip "+ips[n]);
		    			if(method.getResponseBodyAsString().contains("<Response>")){
		    				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
		    				SAXReader reader=new SAXReader(false);
		    				Document document=reader.read(br);
		    				Element root = document.getRootElement();
		    				if(!root.element("countryCode").getText().equalsIgnoreCase("-")){
		    					PreparedStatement ps2 = conn.prepareStatement("update dc_monitorservers set dc_monitorserver_country=? where dc_monitorserver_serverid=?");
		    					ps2.setString(1, root.element("countryCode").getText().toUpperCase());
		    					ps2.setInt(2,id);
		    					ps2.execute();
		    					ps2.close();
		    					location+="-> "+root.element("countryCode").getText().toUpperCase();
		    				}
		    				if(!root.element("cityName").getText().equalsIgnoreCase("-")){
		    					PreparedStatement ps2 = conn.prepareStatement("update dc_monitorservers set dc_monitorserver_city=? where dc_monitorserver_serverid=?");
		    					ps2.setString(1, root.element("cityName").getText().toUpperCase());
		    					ps2.setInt(2,id);
		    					ps2.execute();
		    					ps2.close();
		    					location+=", "+root.element("cityName").getText().toUpperCase();
		    				}
		    			}
				    	System.out.println("IP address to evaluate="+ips[n]+" "+location);
		    		}
		    	}
		    }
		    rs.close();
		    ps.close();
		    
		    //Update geographical positions
			ps = conn.prepareStatement("select * from dc_monitorservers where (dc_monitorserver_latitude is null OR dc_monitorserver_longitude is null) and dc_monitorserver_country is not null and dc_monitorserver_country<>'' and dc_monitorserver_city is not null and dc_monitorserver_city<>'' and dc_monitorserver_name not like '10.%' and dc_monitorserver_name not like '192.168.%'");
			rs=ps.executeQuery();
			while(rs.next()){
    			int id = rs.getInt("dc_monitorserver_serverid");
				HttpClient client = new HttpClient();
    			String url = "http://maps.googleapis.com/maps/api/geocode/xml";
    			PostMethod method = new PostMethod(url);
    			method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
    			Vector<NameValuePair> vNvp = new Vector<NameValuePair>();
            	String address=ScreenHelper.checkString(rs.getString("dc_monitorserver_city"))+","+ScreenHelper.checkString(rs.getString("dc_monitorserver_country"));
            	System.out.println("trying address "+address);
    			vNvp.add(new NameValuePair("address",address));
            	vNvp.add(new NameValuePair("sensor","false"));
    			NameValuePair[] nvp = new NameValuePair[vNvp.size()];
    			vNvp.copyInto(nvp);
    			method.setQueryString(nvp);
    			String lattitude="",longitude="";
    			int statusCode = client.executeMethod(method);
    			if(method.getResponseBodyAsString().contains("<GeocodeResponse>")){
    				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
    				SAXReader reader=new SAXReader(false);
    				Document document=reader.read(br);
    				Element root = document.getRootElement();
    				if(root.elementText("status").equalsIgnoreCase("OK")){
    					Element result = root.element("result");
    					Element geometry = result.element("geometry");
    					Element location = geometry.element("location");
    					lattitude=location.elementText("lat");
    					longitude=location.elementText("lng");
        				if(lattitude.length()>0 && longitude.length()>0){
        					PreparedStatement ps2 = conn.prepareStatement("update dc_monitorservers set dc_monitorserver_latitude=?,dc_monitorserver_longitude=? where dc_monitorserver_serverid=?");
        					ps2.setString(1, lattitude);
        					ps2.setString(2, longitude);
        					ps2.setInt(3,id);
        					ps2.execute();
        					ps2.close();
        					Debug.println("Server ID "+id+" -> Lat: "+lattitude+"     Long: "+longitude);
        				}
    				}
    				else if(root.elementText("status").equalsIgnoreCase("ZERO_RESULTS")){
    	    			method = new PostMethod(url);
    	    			method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
    	    			vNvp = new Vector<NameValuePair>();
    	            	address=ScreenHelper.checkString(rs.getString("dc_monitorserver_country"));
    	            	System.out.println("trying address "+address);
    	    			vNvp.add(new NameValuePair("address",address));
    	            	vNvp.add(new NameValuePair("sensor","false"));
    	    			nvp = new NameValuePair[vNvp.size()];
    	    			vNvp.copyInto(nvp);
    	    			method.setQueryString(nvp);
    	    			lattitude="";
    	    			longitude="";
    	    			statusCode = client.executeMethod(method);
    	    			if(method.getResponseBodyAsString().contains("<GeocodeResponse>")){
    	    				br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
    	    				reader=new SAXReader(false);
    	    				document=reader.read(br);
    	    				root = document.getRootElement();
    	    				if(root.elementText("status").equalsIgnoreCase("OK")){
    	    					Element result = root.element("result");
    	    					Element geometry = result.element("geometry");
    	    					Element location = geometry.element("location");
    	    					lattitude=location.elementText("lat");
    	    					longitude=location.elementText("lng");
    	        				if(lattitude.length()>0 && longitude.length()>0){
    	        					PreparedStatement ps2 = conn.prepareStatement("update dc_monitorservers set dc_monitorserver_latitude=?,dc_monitorserver_longitude=? where dc_monitorserver_serverid=?");
    	        					ps2.setString(1, lattitude);
    	        					ps2.setString(2, longitude);
    	        					ps2.setInt(3,id);
    	        					ps2.execute();
    	        					ps2.close();
    	        					Debug.println("Server ID "+id+" -> Lat: "+lattitude+"     Long: "+longitude);
    	        				}
    	    				}
    	    			}
    				}
    			}

			}
			conn.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
		

	}

}
