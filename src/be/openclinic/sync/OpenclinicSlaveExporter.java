package be.openclinic.sync;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.Vector;

import org.apache.commons.httpclient.HttpVersion;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.util.EntityUtils;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.SessionMessage;

public class OpenclinicSlaveExporter implements Runnable{
	Thread thread;
	public SortedMap patientrecordblocks = new TreeMap();
	public Hashtable patientrecords = new Hashtable();
	public Date begin,end;
	public int maxrecordblocks=MedwanQuery.getInstance().getConfigInt("slaveExportMaxRecordBlocks",10000);

	public void run(){
		if(updateIds()){
			exportBatch(); 
		}
	}

	public void start(){
		thread = new Thread(this);
		thread.start();
	}

	public OpenclinicSlaveExporter(SessionMessage sessionMessage) {
		super();
		this.sessionMessage = sessionMessage;
	}

	private SessionMessage sessionMessage;
	
	public Document store(Document message){
		sessionMessage.setMessage("Start storage of document");
		Element records = message.getRootElement();
		Iterator iRecords = records.elementIterator("record");
		while(iRecords.hasNext()){
			Element record = (Element)iRecords.next();
			sessionMessage.setMessage("Storing patient record "+record.attributeValue("personid"));
			storePatientRecord(record);
			sessionMessage.setMessage("Done storing patient record "+record.attributeValue("personid"));
		}
		Document response = DocumentHelper.createDocument();
		Element root=response.addElement("response");
		root.addAttribute("id", message.getRootElement().attributeValue("id"));
		root.addAttribute("end", message.getRootElement().attributeValue("end"));
		root.addAttribute("patientrecords", message.getRootElement().attributeValue("patientrecords"));
		sessionMessage.setMessage("Done with storage of document");
		return message;
	}
	
	public void storePatientRecord(Element record){
		int personid = Integer.parseInt(record.attributeValue("personid"));
		Iterator blocks = record.elementIterator();
		while(blocks.hasNext()){
			Element block = (Element)blocks.next();
			if(block.getName().equalsIgnoreCase("admin")){
				storeAdminRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("adminprivate")){
				storeAdminPrivateRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("adminextends")){
				storeAdminExtendsRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("encounter")){
				storeEncounterRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("transaction")){
				storeTransactionRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("debet")){
				storeDebetRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("invoice")){
				storeInvoiceRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("credit")){
				storeCreditRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("insurance")){
				storeInsuranceRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("problem")){
				storeProblemRecord(personid,block);
			}
			else if(block.getName().equalsIgnoreCase("lab")){
				storeLabRecord(personid,block);
			}
		}
	}
	
	public void storeLabRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from requestedlabanalyses where transactionid=? and analysiscode=?");
			ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
			ps.setString(2, element.elementText("analysiscode"));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("resultdate").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("resultdate")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("delete from requestedlabanalyses where transactionid=? and analysiscode=?");
					ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
					ps.setString(2, element.elementText("analysiscode"));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into requestedlabanalyses(serverid,transactionid,analysiscode,comment,resultvalue,resultunit,resultmodifier,resultcomment,resultrefmax,"
						+ "resultrefmin,resultdate,resultuserid,patientid,resultprovisional,technicalvalidator,technicalvalidationdatetime,finalvalidator,finalvalidationdatetime,"
						+ "requestdatetime,samplereceptiondatetime,sampletakendatetime,sampler,worklisteddatetime,objectid,updatetime) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(1,serverid);
				int transactionid=0;
				try{
					transactionid=Integer.parseInt(element.elementText("transactionid"));
				}
				catch(Exception e2){}
				ps.setInt(2,transactionid);
				ps.setString(3, element.elementText("analysiscode"));
				ps.setString(4, element.elementText("comment"));
				ps.setString(5, element.elementText("resultvalue"));
				ps.setString(6, element.elementText("resultunit"));
				ps.setString(7, element.elementText("resultmodifier"));
				ps.setString(8, element.elementText("resultcomment"));
				ps.setString(9, element.elementText("resultrefmax"));
				ps.setString(10, element.elementText("resultrefmin"));
				java.sql.Timestamp resultdate=null;
				try{
					resultdate=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("resultdate")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(11,resultdate);
				int resultuserid=0;
				try{
					resultuserid=Integer.parseInt(element.elementText("resultuserid"));
				}
				catch(Exception e2){}
				ps.setInt(12,resultuserid);
				ps.setInt(13,personid);
				ps.setString(14, element.elementText("resultprovisional"));
				int technicalvalidator=0;
				try{
					technicalvalidator=Integer.parseInt(element.elementText("technicalvalidator"));
				}
				catch(Exception e2){}
				ps.setInt(15,technicalvalidator);
				java.sql.Timestamp technicalvalidationdatetime=null;
				try{
					technicalvalidationdatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("technicalvalidationdatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(16,technicalvalidationdatetime);
				int finalvalidator=0;
				try{
					finalvalidator=Integer.parseInt(element.elementText("finalvalidator"));
				}
				catch(Exception e2){}
				ps.setInt(17,finalvalidator);
				java.sql.Timestamp finalvalidationdatetime=null;
				try{
					finalvalidationdatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("finalvalidationdatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(18,finalvalidationdatetime);
				java.sql.Timestamp requestdatetime=null;
				try{
					requestdatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("requestdatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(19,requestdatetime);
				java.sql.Timestamp samplereceptiondatetime=null;
				try{
					samplereceptiondatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("samplereceptiondatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(20,samplereceptiondatetime);
				java.sql.Timestamp sampletakendatetime=null;
				try{
					sampletakendatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("sampletakendatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(21,sampletakendatetime);
				int sampler=0;
				try{
					sampler=Integer.parseInt(element.elementText("sampler"));
				}
				catch(Exception e2){}
				ps.setInt(22,sampler);
				java.sql.Timestamp worklisteddatetime=null;
				try{
					worklisteddatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("worklisteddatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(23,worklisteddatetime);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(24,objectid);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(25,updatetime);
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void storeTransactionRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from transactions where transactionid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("ts").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("ts")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("insert into transactionshistory(transactionid,creationdate,transactiontype,updatetime,status,healthrecordid,userid,serverid,version,versionserverid,ts) select transactionid,creationdate,transactiontype,updatetime,status,healthrecordid,userid,serverid,version,versionserverid,ts from transactions where transactionid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
					ps.execute();
					ps.close();
					ps=conn.prepareStatement("insert into itemshistory(itemid,type,value,date,transactionid,serverid,version,versionserverid,priority) select itemid,type,value,date,transactionid,serverid,version,versionserverid,priority from items where transactionid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
					ps.execute();
					ps.close();
					ps=conn.prepareStatement("delete from transactions where transactionid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
					ps.execute();
					ps=conn.prepareStatement("delete from items where transactionid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("transactionid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into transactions(transactionid,creationdate,transactiontype,updatetime,status,healthrecordid,userid,serverid,version,versionserverid,ts) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?)");
				int transactionid=0;
				try{
					transactionid=Integer.parseInt(element.elementText("transactionid"));
				}
				catch(Exception e2){}
				ps.setInt(1,transactionid);
				java.sql.Date creationdate=null;
				try{
					creationdate=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("creationdate")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(2,creationdate);
				ps.setString(3, element.elementText("transactiontype"));
				java.sql.Date updatetime=null;
				try{
					updatetime=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(4,updatetime);
				int status=0;
				try{
					status=Integer.parseInt(element.elementText("status"));
				}
				catch(Exception e2){}
				ps.setInt(5,status);
				ps.setInt(6,MedwanQuery.getInstance().getHealthRecordIdFromPersonIdWithCreate(personid));
				int userid=0;
				try{
					userid=Integer.parseInt(element.elementText("userid"));
				}
				catch(Exception e2){}
				ps.setInt(7,userid);
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(8,serverid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(9,version);
				int versionserverid=0;
				try{
					versionserverid=Integer.parseInt(element.elementText("versionserverid"));
				}
				catch(Exception e2){}
				ps.setInt(10,versionserverid);
				java.sql.Timestamp ts=null;
				try{
					ts=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("ts")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(11,ts);
				ps.execute();
				ps.close();
				//Now we run through the items
				Element items = element.element("items");
				if(items!=null){
					Iterator iItems = items.elementIterator("item");
					while(iItems.hasNext()){
						Element item = (Element)iItems.next();
						storeItemRecord(transactionid,updatetime,serverid,version,versionserverid,item);
					}
				}
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void storeItemRecord(int transactionid,java.sql.Date date,int serverid,int version,int versionserverid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps=conn.prepareStatement("insert into items(itemid,type,value,date,transactionid,serverid,version,versionserverid,priority) "
					+ "values(?,?,?,?,?,?,?,?,?)");
			int itemid=0;
			try{
				itemid=Integer.parseInt(element.elementText("itemid"));
			}
			catch(Exception e2){}
			ps.setInt(1,itemid);
			ps.setString(2, element.elementText("type"));
			ps.setString(3, element.elementText("value"));
			ps.setDate(4, date);
			ps.setInt(5,transactionid);
			ps.setInt(6,serverid);
			ps.setInt(7,version);
			ps.setInt(8,versionserverid);
			int priority=0;
			try{
				priority=Integer.parseInt(element.elementText("priority"));
			}
			catch(Exception e2){}
			ps.setInt(9,priority);
			ps.execute();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void storeProblemRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from oc_problems where oc_problem_objectid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("oc_problem_updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("insert into oc_problems_history(oc_problem_patientuid,oc_problem_codetype,oc_problem_code,oc_problem_begin,oc_problem_end,oc_problem_serverid,"
						+ "oc_problem_objectid,oc_problem_createtime,oc_problem_updatetime,oc_problem_updateuid,oc_problem_version,oc_problem_gravity,oc_problem_certainty,oc_problem_comment) select oc_problem_patientuid,oc_problem_codetype,oc_problem_code,oc_problem_begin,oc_problem_end,oc_problem_serverid,"
						+ "oc_problem_objectid,oc_problem_createtime,oc_problem_updatetime,oc_problem_updateuid,oc_problem_version,oc_problem_gravity,oc_problem_certainty,oc_problem_comment from oc_problems where oc_problem_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
					ps.close();
					ps=conn.prepareStatement("delete from oc_problems where oc_problem_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into oc_problems(oc_problem_patientuid,oc_problem_codetype,oc_problem_code,oc_problem_begin,oc_problem_end,oc_problem_serverid,"
						+ "oc_problem_objectid,oc_problem_createtime,oc_problem_updatetime,oc_problem_updateuid,oc_problem_version,oc_problem_gravity,oc_problem_certainty,oc_problem_comment) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				ps.setInt(1,personid);
				ps.setString(2, element.elementText("codetype"));
				ps.setString(3, element.elementText("code"));
				java.sql.Timestamp begin=null;
				try{
					begin=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("begin")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(4,begin);
				java.sql.Timestamp end=null;
				try{
					end=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("end")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(5,end);
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(6,serverid);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(7,objectid);
				java.sql.Timestamp createtime=null;
				try{
					createtime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("createtime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(8,createtime);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(9,updatetime);
				int updateuid=0;
				try{
					updateuid=Integer.parseInt(element.elementText("updateuid"));
				}
				catch(Exception e2){}
				ps.setInt(10,updateuid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(11,version);
				int gravity=0;
				try{
					gravity=Integer.parseInt(element.elementText("gravity"));
				}
				catch(Exception e2){}
				ps.setInt(12,gravity);
				int certainty=0;
				try{
					certainty=Integer.parseInt(element.elementText("certainty"));
				}
				catch(Exception e2){}
				ps.setInt(13,certainty);
				ps.setString(14, element.elementText("comment"));
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeInsuranceRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from oc_insurances where oc_insurance_objectid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("oc_insurance_updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("delete from oc_insurances where oc_insurance_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into oc_insurances(oc_insurance_serverid,oc_insurance_objectid,oc_insurance_nr,oc_insurance_insuraruid,oc_insurance_type,"
						+ "oc_insurance_start,oc_insurance_stop,oc_insurance_comment,oc_insurance_createtime,oc_insurance_updatetime,oc_insurance_updateuid,oc_insurance_version,"
						+ "oc_insurance_patientuid,oc_insurance_insurancecategoryletter,oc_insurance_member,oc_insurance_member_immat,oc_insurance_member_employer,"
						+ "oc_insurance_status,oc_insurance_extrainsuraruid,oc_insurance_extrainsuraruid2,oc_insurance_default) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(1,serverid);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(2,objectid);
				ps.setString(3, element.elementText("nr"));
				ps.setString(4, element.elementText("insuraruid"));
				ps.setString(5, element.elementText("type"));
				java.sql.Timestamp start=null;
				try{
					start=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("start")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(6,start);
				java.sql.Timestamp stop=null;
				try{
					stop=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("stop")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(7,stop);
				ps.setString(8, element.elementText("comment"));
				java.sql.Timestamp createtime=null;
				try{
					createtime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("createtime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(9,createtime);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(10,updatetime);
				int updateuid=0;
				try{
					updateuid=Integer.parseInt(element.elementText("updateuid"));
				}
				catch(Exception e2){}
				ps.setInt(11,updateuid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(12,version);
				ps.setString(13, personid+"");
				ps.setString(14, element.elementText("insurancecategoryletter"));
				ps.setString(15, element.elementText("member"));
				ps.setString(16, element.elementText("member_immat"));
				ps.setString(17, element.elementText("member_employer"));
				ps.setString(18, element.elementText("status"));
				ps.setString(19, element.elementText("extrainsuraruid"));
				ps.setString(20, element.elementText("extrainsuraruid2"));
				int def=0;
				try{
					def=Integer.parseInt(element.elementText("default"));
				}
				catch(Exception e2){}
				ps.setInt(21,def);
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeCreditRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from oc_patientcredits where oc_patientcredit_objectid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("oc_patientcredit_updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("delete from oc_patientcredits where oc_patientcredit_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into oc_patientcredits(oc_patientcredit_createtime,oc_patientcredit_updatetime,oc_patientcredit_updateuid,oc_patientcredit_version,"
						+ "oc_patientcredit_serverid,oc_patientcredit_objectid,oc_patientcredit_date,oc_patientcredit_invoiceuid,oc_patientcredit_amount,oc_patientcredit_type,"
						+ "oc_patientcredit_encounteruid,oc_patientcredit_comment) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?)");
				java.sql.Timestamp createtime=null;
				try{
					createtime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("createtime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(1,createtime);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(2,updatetime);
				int updateuid=0;
				try{
					updateuid=Integer.parseInt(element.elementText("updateuid"));
				}
				catch(Exception e2){}
				ps.setInt(3,updateuid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(4,version);
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(5,serverid);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(6,objectid);
				java.sql.Timestamp date=null;
				try{
					date=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("date")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(7,date);
				ps.setString(8, element.elementText("invoiceuid"));
				double amount=0;
				try{
					amount=Double.parseDouble(element.elementText("amount"));
				}
				catch(Exception e2){}
				ps.setDouble(9,amount);
				ps.setString(10, element.elementText("type"));
				ps.setString(11, element.elementText("encounteruid"));
				ps.setString(12, element.elementText("comment"));
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeInvoiceRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from oc_patientinvoices where oc_patientinvoice_objectid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("oc_patientinvoice_updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("insert into oc_patientinvoices_history(oc_patientinvoice_createtime,oc_patientinvoice_updatetime,oc_patientinvoice_updateuid,oc_patientinvoice_version,"
						+ "oc_patientinvoice_serverid,oc_patientinvoice_objectid,oc_patientinvoice_id,oc_patientinvoice_date,oc_patientinvoice_patientuid,oc_patientinvoice_status,"
						+ "oc_patientinvoice_balance,oc_patientinvoice_number,oc_patientinvoice_insurarreference,oc_patientinvoice_acceptationuid,oc_patientinvoice_insurarreferencedate,"
						+ "oc_patientinvoice_verifier,oc_patientinvoice_comment,oc_patientinvoice_modifiers) select oc_patientinvoice_createtime,oc_patientinvoice_updatetime,oc_patientinvoice_updateuid,oc_patientinvoice_version,"
						+ "oc_patientinvoice_serverid,oc_patientinvoice_objectid,oc_patientinvoice_id,oc_patientinvoice_date,oc_patientinvoice_patientuid,oc_patientinvoice_status,"
						+ "oc_patientinvoice_balance,oc_patientinvoice_number,oc_patientinvoice_insurarreference,oc_patientinvoice_acceptationuid,oc_patientinvoice_insurarreferencedate,"
						+ "oc_patientinvoice_verifier,oc_patientinvoice_comment,oc_patientinvoice_modifiers from oc_patientinvoices where oc_patientinvoice_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
					ps.close();
					ps=conn.prepareStatement("delete from oc_patientinvoices where oc_patientinvoice_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into oc_patientinvoices(oc_patientinvoice_createtime,oc_patientinvoice_updatetime,oc_patientinvoice_updateuid,oc_patientinvoice_version,"
						+ "oc_patientinvoice_serverid,oc_patientinvoice_objectid,oc_patientinvoice_id,oc_patientinvoice_date,oc_patientinvoice_patientuid,oc_patientinvoice_status,"
						+ "oc_patientinvoice_balance,oc_patientinvoice_number,oc_patientinvoice_insurarreference,oc_patientinvoice_acceptationuid,oc_patientinvoice_insurarreferencedate,"
						+ "oc_patientinvoice_verifier,oc_patientinvoice_comment,oc_patientinvoice_modifiers) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				java.sql.Timestamp createtime=null;
				try{
					createtime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("createtime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(1,createtime);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(2,updatetime);
				int updateuid=0;
				try{
					updateuid=Integer.parseInt(element.elementText("updateuid"));
				}
				catch(Exception e2){}
				ps.setInt(3,updateuid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(4,version);
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(5,serverid);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(6,objectid);
				int id=0;
				try{
					id=Integer.parseInt(element.elementText("id"));
				}
				catch(Exception e2){}
				ps.setInt(7,id);
				java.sql.Timestamp date=null;
				try{
					date=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("date")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(8,date);
				ps.setString(9, personid+"");
				ps.setString(10, element.elementText("status"));
				double balance=0;
				try{
					balance=Double.parseDouble(element.elementText("balance"));
				}
				catch(Exception e2){}
				ps.setDouble(11,balance);
				ps.setString(12, element.elementText("number"));
				ps.setString(13, element.elementText("insurarreference"));
				ps.setString(14, element.elementText("acceptationuid"));
				ps.setString(15, element.elementText("insurarreferencedate"));
				ps.setString(16, element.elementText("verifier"));
				ps.setString(17, element.elementText("comment"));
				ps.setString(18, element.elementText("modifiers"));
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeDebetRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from oc_debets where oc_debet_objectid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("oc_debet_updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("insert into oc_debets_history(oc_debet_serverid,oc_debet_objectid,oc_debet_amount,oc_debet_balanceuid,oc_debet_date,oc_debet_description,oc_debet_encounteruid,"
						+ "oc_debet_prestationuid,oc_debet_suppliertype,oc_debet_supplieruid,oc_debet_reftype,oc_debet_refuid,oc_debet_createtime,oc_debet_updatetime,oc_debet_updateuid,"
						+ "oc_debet_version,oc_debet_quantity,oc_debet_credited,oc_debet_insuranceuid,oc_debet_patientinvoiceuid,oc_debet_insurarinvoiceuid,oc_debet_comment,oc_debet_insuraramount,"
						+ "oc_debet_extrainsuraruid,oc_debet_extrainsurarinvoiceuid,oc_debet_extrainsuraramount,oc_debet_renewalinterval,oc_debet_renewaldate,oc_debet_performeruid,oc_debet_extrainsuraruid2,"
						+ "oc_debet_extrainsurarinvoiceuid2,oc_debet_extrainsuraramount2,oc_debet_serviceuid) select oc_debet_serverid,oc_debet_objectid,oc_debet_amount,oc_debet_balanceuid,oc_debet_date,oc_debet_description,oc_debet_encounteruid,"
						+ "oc_debet_prestationuid,oc_debet_suppliertype,oc_debet_supplieruid,oc_debet_reftype,oc_debet_refuid,oc_debet_createtime,oc_debet_updatetime,oc_debet_updateuid,"
						+ "oc_debet_version,oc_debet_quantity,oc_debet_credited,oc_debet_insuranceuid,oc_debet_patientinvoiceuid,oc_debet_insurarinvoiceuid,oc_debet_comment,oc_debet_insuraramount,"
						+ "oc_debet_extrainsuraruid,oc_debet_extrainsurarinvoiceuid,oc_debet_extrainsuraramount,oc_debet_renewalinterval,oc_debet_renewaldate,oc_debet_performeruid,oc_debet_extrainsuraruid2,"
						+ "oc_debet_extrainsurarinvoiceuid2,oc_debet_extrainsuraramount2,oc_debet_serviceuid from oc_debets where oc_debet_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
					ps.close();
					ps=conn.prepareStatement("delete from oc_debets where oc_debet_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into oc_debets(oc_debet_serverid,oc_debet_objectid,oc_debet_amount,oc_debet_balanceuid,oc_debet_date,oc_debet_description,oc_debet_encounteruid,"
						+ "oc_debet_prestationuid,oc_debet_suppliertype,oc_debet_supplieruid,oc_debet_reftype,oc_debet_refuid,oc_debet_createtime,oc_debet_updatetime,oc_debet_updateuid,"
						+ "oc_debet_version,oc_debet_quantity,oc_debet_credited,oc_debet_insuranceuid,oc_debet_patientinvoiceuid,oc_debet_insurarinvoiceuid,oc_debet_comment,oc_debet_insuraramount,"
						+ "oc_debet_extrainsuraruid,oc_debet_extrainsurarinvoiceuid,oc_debet_extrainsuraramount,oc_debet_renewalinterval,oc_debet_renewaldate,oc_debet_performeruid,oc_debet_extrainsuraruid2,"
						+ "oc_debet_extrainsurarinvoiceuid2,oc_debet_extrainsuraramount2,oc_debet_serviceuid) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(1,serverid);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(2,objectid);
				double amount=0;
				try{
					amount=Double.parseDouble(element.elementText("amount"));
				}
				catch(Exception e2){}
				ps.setDouble(3,amount);
				ps.setString(4, element.elementText("balanceuid"));
				java.sql.Timestamp date=null;
				try{
					date=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("date")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(5,date);
				ps.setString(6, element.elementText("description"));
				ps.setString(7, element.elementText("encounteruid"));
				ps.setString(8, element.elementText("prestationuid"));
				ps.setString(9, element.elementText("suppliertype"));
				ps.setString(10, element.elementText("supplieruid"));
				ps.setString(11, element.elementText("reftype"));
				ps.setString(12, element.elementText("refuid"));
				java.sql.Timestamp createtime=null;
				try{
					createtime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("createtime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(13,createtime);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(14,updatetime);
				int updateuid=0;
				try{
					updateuid=Integer.parseInt(element.elementText("updateuid"));
				}
				catch(Exception e2){}
				ps.setInt(15,updateuid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(16,version);
				int quantity=0;
				try{
					quantity=Integer.parseInt(element.elementText("quantity"));
				}
				catch(Exception e2){}
				ps.setInt(17,quantity);
				int credited=0;
				try{
					credited=Integer.parseInt(element.elementText("credited"));
				}
				catch(Exception e2){}
				ps.setInt(18,credited);
				ps.setString(19, element.elementText("insuranceuid"));
				ps.setString(20, element.elementText("patientinvoiceuid"));
				ps.setString(21, element.elementText("insurarinvoiceuid"));
				ps.setString(22, element.elementText("comment"));
				double insuraramount=0;
				try{
					insuraramount=Double.parseDouble(element.elementText("insuraramount"));
				}
				catch(Exception e2){}
				ps.setDouble(23,insuraramount);
				ps.setString(24, element.elementText("extrainsuraruid"));
				ps.setString(25, element.elementText("extrainsurarinvoiceuid"));
				double extrainsuraramount=0;
				try{
					extrainsuraramount=Double.parseDouble(element.elementText("extrainsuraramount"));
				}
				catch(Exception e2){}
				ps.setDouble(26,extrainsuraramount);
				int renewalinterval=0;
				try{
					renewalinterval=Integer.parseInt(element.elementText("renewalinterval"));
				}
				catch(Exception e2){}
				ps.setInt(27,renewalinterval);
				java.sql.Timestamp renewaldate=null;
				try{
					renewaldate=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("renewaldate")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(28,renewaldate);
				ps.setString(29, element.elementText("performeruid"));
				ps.setString(30, element.elementText("extrainsuraruid2"));
				ps.setString(31, element.elementText("extrainsurarinvoiceuid2"));
				double extrainsuraramount2=0;
				try{
					extrainsuraramount2=Double.parseDouble(element.elementText("extrainsuraramount2"));
				}
				catch(Exception e2){}
				ps.setDouble(32,extrainsuraramount2);
				ps.setString(33, element.elementText("serviceuid"));
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeEncounterRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from oc_encounters where oc_encounter_objectid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("oc_encounter_updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("insert into oc_encounters_history(oc_encounter_serverid,oc_encounter_objectid,oc_encounter_type,oc_encounter_begindate,oc_encounter_enddate,"
						+ "oc_encounter_patientuid,oc_encounter_createtime,oc_encounter_updatetime,oc_encounter_updateuid,oc_encounter_version,oc_encounter_outcome,"
						+ "oc_encounter_destinationuid,oc_encounter_origin,oc_encounter_situation,oc_encounter_processed,oc_encounter_categories,oc_encounter_newcase,oc_encounter_etiology) select oc_encounter_serverid,oc_encounter_objectid,oc_encounter_type,oc_encounter_begindate,oc_encounter_enddate,"
						+ "oc_encounter_patientuid,oc_encounter_createtime,oc_encounter_updatetime,oc_encounter_updateuid,oc_encounter_version,oc_encounter_outcome,"
						+ "oc_encounter_destinationuid,oc_encounter_origin,oc_encounter_situation,oc_encounter_processed,oc_encounter_categories,oc_encounter_newcase,oc_encounter_etiology from oc_encounters where oc_encounter_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
					ps.close();
					ps=conn.prepareStatement("delete from oc_encounters where oc_encounter_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
					ps=conn.prepareStatement("delete from oc_encounter_services where oc_encounter_objectid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("objectid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into oc_encounters(oc_encounter_serverid,oc_encounter_objectid,oc_encounter_type,oc_encounter_begindate,oc_encounter_enddate,"
						+ "oc_encounter_patientuid,oc_encounter_createtime,oc_encounter_updatetime,oc_encounter_updateuid,oc_encounter_version,oc_encounter_outcome,"
						+ "oc_encounter_destinationuid,oc_encounter_origin,oc_encounter_situation,oc_encounter_processed,oc_encounter_categories,oc_encounter_newcase,oc_encounter_etiology) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				int serverid=0;
				try{
					serverid=Integer.parseInt(element.elementText("serverid"));
				}
				catch(Exception e2){}
				ps.setInt(1,serverid);
				int objectid=0;
				try{
					objectid=Integer.parseInt(element.elementText("objectid"));
				}
				catch(Exception e2){}
				ps.setInt(2,objectid);
				ps.setString(3, element.elementText("type"));
				java.sql.Timestamp begindate=null;
				try{
					begindate=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("begindate")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(4,begindate);
				java.sql.Timestamp enddate=null;
				try{
					enddate=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("enddate")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(5,enddate);
				ps.setInt(6, personid);
				java.sql.Timestamp createtime=null;
				try{
					createtime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("createtime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(7,createtime);
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(8,updatetime);
				int updateuid=0;
				try{
					updateuid=Integer.parseInt(element.elementText("updateuid"));
				}
				catch(Exception e2){}
				ps.setInt(9,updateuid);
				int version=0;
				try{
					version=Integer.parseInt(element.elementText("version"));
				}
				catch(Exception e2){}
				ps.setInt(10,version);
				ps.setString(11, element.elementText("outcome"));
				ps.setString(12, element.elementText("destinationuid"));
				ps.setString(13, element.elementText("origin"));
				ps.setString(14, element.elementText("situation"));
				java.sql.Timestamp processed=null;
				try{
					processed=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("processed")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(15,processed);
				ps.setString(16, element.elementText("categories"));
				int newcase=0;
				try{
					newcase=Integer.parseInt(element.elementText("newcase"));
				}
				catch(Exception e2){}
				ps.setInt(17,newcase);
				ps.setString(18, element.elementText("etiology"));
				ps.execute();
				ps.close();
				//Now insert encounter services
				Element services = element.element("services");
				if(services!=null){
					Iterator iServices = services.elementIterator();
					while(iServices.hasNext()){
						Element service = (Element)iServices.next();
						ps = conn.prepareStatement("insert into oc_encounter_services(oc_encounter_serverid,oc_encounter_objectid,oc_encounter_serviceuid,oc_encounter_beduid,"
								+ "oc_encounter_manageruid,oc_encounter_servicebegindate,oc_encounter_serviceenddate) "
								+ "values(?,?,?,?,?,?,?)");
						ps.setInt(1, serverid);
						ps.setInt(2, objectid);
						ps.setString(3, service.elementText("serviceuid"));
						ps.setString(4, service.elementText("beduid"));
						ps.setString(5, service.elementText("manageruid"));
						java.sql.Timestamp servicebegindate=null;
						try{
							servicebegindate=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(service.elementText("servicebegindate")).getTime());
						}
						catch(Exception e2){}
						ps.setTimestamp(6,servicebegindate);
						java.sql.Timestamp serviceenddate=null;
						try{
							serviceenddate=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(service.elementText("serviceenddate")).getTime());
						}
						catch(Exception e2){}
						ps.setTimestamp(7,serviceenddate);
						ps.execute();
						ps.close();
					}
				}
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeAdminExtendsRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from adminextends where personid=? and labelid=?");
			ps.setInt(1, personid);
			ps.setInt(2, Integer.parseInt(element.elementText("labelid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("delete from adminextends where personid=? and labelid=?");
					ps.setInt(1, personid);
					ps.setInt(2, Integer.parseInt(element.elementText("labelid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into adminextends(personid,extendid,extendtype,labelid,extendvalue,updatetime,updateuserid,updateserverid) "
						+ "values(?,?,?,?,?,?,?,?)");
				ps.setInt(1, personid);
				int extendid=0;
				try{
					extendid=Integer.parseInt(element.elementText("extendid"));
				}
				catch(Exception e2){}
				ps.setInt(2,extendid);
				ps.setString(3, element.elementText("extendtype"));
				ps.setString(4, element.elementText("labelid"));
				ps.setString(5, element.elementText("extendvalue"));
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(6,updatetime);
				int updateuserid=0;
				try{
					updateuserid=Integer.parseInt(element.elementText("updateuserid"));
				}
				catch(Exception e2){}
				ps.setInt(7,updateuserid);
				int updateserverid=0;
				try{
					updateserverid=Integer.parseInt(element.elementText("updateserverid"));
				}
				catch(Exception e2){}
				ps.setInt(8,updateserverid);
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeAdminPrivateRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from adminprivate where privateid=?");
			ps.setInt(1, Integer.parseInt(element.elementText("privateid")));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("delete from adminprivate where privateid=?");
					ps.setInt(1, Integer.parseInt(element.elementText("privateid")));
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into adminprivate(privateid,personid,start,stop,address,city,zipcode,country,telephone,fax,mobile,email,comment,"
						+ "updatetime,type,updateserverid,district,sanitarydistrict,province,sector,cell,quarter,business,businessfunction) "
						+ "values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				int privateid=0;
				try{
					privateid=Integer.parseInt(element.elementText("privateid"));
				}
				catch(Exception e2){}
				ps.setInt(1,privateid);
				ps.setInt(2, personid);
				java.sql.Date start=null;
				try{
					start=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("start")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(3,start);
				java.sql.Date stop=null;
				try{
					stop=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("stop")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(4,stop);
				ps.setString(5, element.elementText("address"));
				ps.setString(6, element.elementText("city"));
				ps.setString(7, element.elementText("zipcode"));
				ps.setString(8, element.elementText("country"));
				ps.setString(9, element.elementText("telephone"));
				ps.setString(10, element.elementText("fax"));
				ps.setString(11, element.elementText("mobile"));
				ps.setString(12, element.elementText("email"));
				ps.setString(13, element.elementText("comment"));
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(14,updatetime);
				ps.setString(15, element.elementText("type"));
				int updateserverid=0;
				try{
					updateserverid=Integer.parseInt(element.elementText("updateserverid"));
				}
				catch(Exception e2){}
				ps.setInt(16,updateserverid);
				ps.setString(17, element.elementText("district"));
				ps.setString(18, element.elementText("sanitarydistrict"));
				ps.setString(19, element.elementText("province"));
				ps.setString(20, element.elementText("sector"));
				ps.setString(21, element.elementText("cell"));
				ps.setString(22, element.elementText("quarter"));
				ps.setString(23, element.elementText("business"));
				ps.setString(24, element.elementText("businessfunction"));
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void storeAdminRecord(int personid,Element element){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try{
			boolean doInsert=true;
			PreparedStatement ps = conn.prepareStatement("select * from admin where personid=?");
			ps.setInt(1, personid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(!rs.getTimestamp("updatetime").before(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")))){
					//Existing record is more recent. Do nothing
					doInsert=false;
					rs.close();
				}
				else {
					//Received record is more recent
					//Copy existing record to history
					rs.close();
					ps.close();
					ps=conn.prepareStatement("insert into adminhistory(personid,immatold,immatnew,candidate,lastname,firstname,gender,dateofbirth,comment,sourceid,language,"
						+ "engagement,pension,statute,claimant,searchname,updatetime,claimant_expiration,native_country,native_town,motive_end_of_service,startdate_inactivity,"
						+ "enddate_inactivity,code_inactivity,update_status,person_type,situation_end_of_service,updateuserid,comment1,comment2,comment3,comment4,comment5,natreg,"
						+ "middlename,begindate,enddate,updateserverid,archivefilecode) select personid,immatold,immatnew,candidate,lastname,firstname,gender,dateofbirth,comment,sourceid,language,"
						+ "engagement,pension,statute,claimant,searchname,updatetime,claimant_expiration,native_country,native_town,motive_end_of_service,startdate_inactivity,"
						+ "enddate_inactivity,code_inactivity,update_status,person_type,situation_end_of_service,updateuserid,comment1,comment2,comment3,comment4,comment5,natreg,"
						+ "middlename,begindate,enddate,updateserverid,archivefilecode from admin where personid=?");
					ps.setInt(1, personid);
					ps.execute();
					//Remove existingrecord
					ps.close();
					ps=conn.prepareStatement("delete from admin where personid=?");
					ps.setInt(1, personid);
					ps.execute();
				}
			}
			else {
				rs.close();
			}
			ps.close();
			if(doInsert){
				ps=conn.prepareStatement("insert into admin(personid,immatold,immatnew,candidate,lastname,firstname,gender,dateofbirth,comment,sourceid,language,"
						+ "engagement,pension,statute,claimant,searchname,updatetime,claimant_expiration,native_country,native_town,motive_end_of_service,startdate_inactivity,"
						+ "enddate_inactivity,code_inactivity,update_status,person_type,situation_end_of_service,updateuserid,comment1,comment2,comment3,comment4,comment5,natreg,"
						+ "middlename,begindate,enddate,updateserverid,archivefilecode) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
				ps.setInt(1, personid);
				ps.setString(2, element.elementText("immatold"));
				ps.setString(3, element.elementText("immatnew"));
				ps.setString(4, element.elementText("candidate"));
				ps.setString(5, element.elementText("lastname"));
				ps.setString(6, element.elementText("firstname"));
				ps.setString(7, element.elementText("gender"));
				java.sql.Date dateofbirth=null;
				try{
					dateofbirth=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("dateofbirth")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(8, dateofbirth);
				ps.setString(9, element.elementText("comment"));
				ps.setString(10, element.elementText("sourceid"));
				ps.setString(11, element.elementText("language"));
				java.sql.Date engagement=null;
				try{
					engagement=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("engagement")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(12,engagement);
				java.sql.Date pension=null;
				try{
					pension=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("pension")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(13,pension);
				ps.setString(14, element.elementText("statute"));
				ps.setString(15, element.elementText("claimant"));
				ps.setString(16, element.elementText("searchname"));
				java.sql.Timestamp updatetime=null;
				try{
					updatetime=new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(element.elementText("updatetime")).getTime());
				}
				catch(Exception e2){}
				ps.setTimestamp(17,updatetime);
				java.sql.Date claimant_expiration=null;
				try{
					claimant_expiration=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("claimant_expiration")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(18,claimant_expiration);
				ps.setString(19, element.elementText("native_country"));
				ps.setString(20, element.elementText("native_town"));
				ps.setString(21, element.elementText("motive_end_of_service"));
				java.sql.Date startdate_inactivity=null;
				try{
					startdate_inactivity=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("startdate_inactivity")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(22,startdate_inactivity);
				java.sql.Date enddate_inactivity=null;
				try{
					enddate_inactivity=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("enddate_inactivity")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(23,enddate_inactivity);
				ps.setString(24, element.elementText("code_inactivity"));
				ps.setString(25, element.elementText("update_status"));
				ps.setString(26, element.elementText("person_type"));
				ps.setString(27, element.elementText("situation_end_of_service"));
				int updateuserid=0;
				try{
					updateuserid=Integer.parseInt(element.elementText("updateuserid"));
				}
				catch(Exception e2){}
				ps.setInt(28,updateuserid);
				ps.setString(29, element.elementText("comment1"));
				ps.setString(30, element.elementText("comment2"));
				ps.setString(31, element.elementText("comment3"));
				ps.setString(32, element.elementText("comment4"));
				ps.setString(33, element.elementText("comment5"));
				ps.setString(34, element.elementText("natreg"));
				ps.setString(35, element.elementText("middlename"));
				java.sql.Date begindate=null;
				try{
					begindate=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("begindate")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(36,begindate);
				java.sql.Date enddate=null;
				try{
					enddate=new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(element.elementText("enddate")).getTime());
				}
				catch(Exception e2){}
				ps.setDate(37,enddate);
				int updateserverid=0;
				try{
					updateserverid=Integer.parseInt(element.elementText("updateserverid"));
				}
				catch(Exception e2){}
				ps.setInt(38,updateserverid);
				ps.setString(39, element.elementText("archivefilecode"));
				ps.execute();
				ps.close();
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public int exportBatch(){
		sessionMessage.setMessage("Start export batches");
		int records=0;
		int counter=0;
		try {
			while(true){
				counter++;
				sessionMessage.setMessage("Creating batch "+counter+" for export");
				Document message = exportToXML();
				Element export = message.getRootElement();
				sessionMessage.setMessage("Created batch "+counter+" with "+export.attributeValue("patientrecords")+" patient records");
				int messageid = MedwanQuery.getInstance().getOpenclinicCounter("messageId");
				export.addAttribute("id", messageid+"");
				export.addAttribute("command", "store");
				HttpClient client = new DefaultHttpClient();
				String url = MedwanQuery.getInstance().getConfigString("masterServerURL","http://localhost:10080/openclinic/util/webservice.jsp");
			    HttpPost httppost = new HttpPost(url);
			    StringEntity entity = new StringEntity(message.asXML());
	   	        httppost.addHeader("Accept" , "text/xml");
			    httppost.setEntity(entity);
			    ResponseHandler<String> responseHandler = new BasicResponseHandler();
		        String resultstring = client.execute(httppost, responseHandler);
			    if (resultstring != null) {
			    	sessionMessage.setMessage("Done sending batch "+counter+" to "+url);
			    	message = DocumentHelper.parseText(resultstring);
			    	export = message.getRootElement();
			    	if(export.attributeValue("id").equalsIgnoreCase(messageid+"")){
						sessionMessage.setMessage("Received correct xml response for batch "+counter+", updating last export date");
						setLastExport(new SimpleDateFormat("yyyyMMddHHmmssSSSS").parse(export.attributeValue("end")));
						sessionMessage.setMessage("Done updating last export date");
						records+=Integer.parseInt(export.attributeValue("patientrecords"));
					}
			    }
				if(patientrecordblocks.size()<maxrecordblocks){
					break;
				}
			}
		} catch (Exception e1) {
			sessionMessage.setErrorMessage(e1.getMessage());
			e1.printStackTrace();
		}
		sessionMessage.setMessage("Done with export batches");
		sessionMessage.setMessage(".");
		return records;
	}
	
	public Document exportToXML(){
		patientrecords=new Hashtable();
		patientrecordblocks=new TreeMap();
		begin = getLastExport();
		addAdmin();
		addPrivate();
		addExtends();
		addEncounters();
		addInsurances();
		addDebets();
		addInvoices();
		addCredits();
		addTransactions();
		addProblems();
		addLab();
		//Now we move the recordblocks to patientrecords
		Iterator i = patientrecordblocks.keySet().iterator();
		while(i.hasNext()){
			String key = (String)i.next();
			addToRecord(Integer.parseInt(key.split("\\.")[1]), (Element)patientrecordblocks.get(key));
		}
		Document document = DocumentHelper.createDocument();
		Element export = document.addElement("export");
		export.addAttribute("date", new SimpleDateFormat("yyyyMMddHHmmssSSSS").format(new java.util.Date()));
		export.addAttribute("begin", new SimpleDateFormat("yyyyMMddHHmmssSSSS").format(begin));
		export.addAttribute("sourceid", MedwanQuery.getInstance().getConfigString("slaveId",""));
		export.addAttribute("sourcename", MedwanQuery.getInstance().getConfigString("slaveName",""));
		export.addAttribute("project", MedwanQuery.getInstance().getConfigString("slaveProject","openclinic"));
		Enumeration e = patientrecords.keys();
		while(e.hasMoreElements()){
			int personid = (Integer)e.nextElement();
			export.add((Element)patientrecords.get(personid));
		}
		export.addAttribute("end", ((String)patientrecordblocks.lastKey()).split("\\.")[0]);
		export.addAttribute("patientrecords", patientrecords.size()+"");
		
		return document;
	}
	
	public Document getNewIds(Document message){
		sessionMessage.setMessage("Start getting new ids");
		Element ids=message.getRootElement();
		Iterator iElements = ids.elementIterator("id");
		while(iElements.hasNext()){
			Element id = (Element)iElements.next();
			if(id.attributeValue("type").equalsIgnoreCase("admin")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("PersonID")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("private")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("PrivateID")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("encounter")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("OC_ENCOUNTERS")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("insurance")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("OC_INSURANCES")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("debet")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("OC_DEBETS")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("invoice")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("credit")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("OC_PATIENTCREDITS")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("transaction")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("TransactionID")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("problem")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("OC_PROBLEMS")+"");
			}
			else if(id.attributeValue("type").equalsIgnoreCase("item")){
				id.addAttribute("newvalue", MedwanQuery.getInstance().getOpenclinicCounter("ItemID")+"");
			}
		}
		sessionMessage.setMessage("Done getting new ids");
		return message;
	}
	
	public boolean updateIds(){
		sessionMessage.setMessage("Start requesting updateids");
		boolean updateIds=false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			sessionMessage.setMessage("Make a list of updateids");
			//First make a list of all negative IDs
			Document message = DocumentHelper.createDocument();
			int messageid = MedwanQuery.getInstance().getOpenclinicCounter("messageId");
			Element ids = message.addElement("ids");
			ids.addAttribute("command", "getIds");
			ids.addAttribute("id", messageid+"");
			PreparedStatement ps = adminconn.prepareStatement("select personid from admin where personid<0");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "admin");
				id.addAttribute("value", rs.getString("personid"));
			}
			rs.close();
			ps.close();
			ps = adminconn.prepareStatement("select privateid from adminprivate where privateid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "private");
				id.addAttribute("value", rs.getString("privateid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select oc_encounter_objectid from oc_encounters where oc_encounter_objectid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "encounter");
				id.addAttribute("value", rs.getString("oc_encounter_objectid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select oc_insurance_objectid from oc_insurances where oc_insurance_objectid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "insurance");
				id.addAttribute("value", rs.getString("oc_insurance_objectid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select oc_debet_objectid from oc_debets where oc_debet_objectid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "debet");
				id.addAttribute("value", rs.getString("oc_debet_objectid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select oc_patientinvoice_objectid from oc_patientinvoices where oc_patientinvoice_objectid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "invoice");
				id.addAttribute("value", rs.getString("oc_patientinvoice_objectid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select oc_patientcredit_objectid from oc_patientcredits where oc_patientcredit_objectid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "credit");
				id.addAttribute("value", rs.getString("oc_patientcredit_objectid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select transactionid from transactions where transactionid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "transaction");
				id.addAttribute("value", rs.getString("transactionid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select itemid from items where itemid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "item");
				id.addAttribute("value", rs.getString("itemid"));
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select oc_problem_objectid from oc_problems where oc_problem_objectid<0");
			rs = ps.executeQuery();
			while(rs.next()){
				Element id=ids.addElement("id");
				id.addAttribute("type", "problem");
				id.addAttribute("value", rs.getString("oc_problem_objectid"));
			}
			rs.close();
			ps.close();
			sessionMessage.setMessage("Done making list of updateids");
			//Send the list to the master server and get the updated list from it
			HttpClient client = new DefaultHttpClient();
			sessionMessage.setMessage("Initialized client");
			String url = MedwanQuery.getInstance().getConfigString("masterServerURL","http://localhost:10080/openclinic/util/webservice.jsp");
		    HttpPost httppost = new HttpPost(url);
			sessionMessage.setMessage("Initialized HttpPost");
		    StringEntity entity = new StringEntity(message.asXML());
			sessionMessage.setMessage("Created entity");
   	        httppost.addHeader("Accept" , "text/xml");
		    httppost.setEntity(entity);
			sessionMessage.setMessage("Set entity");
		    ResponseHandler<String> responseHandler = new BasicResponseHandler();
	        String resultstring = client.execute(httppost, responseHandler);
			sessionMessage.setMessage("Executed client");
		    if (resultstring != null) {
		    	sessionMessage.setMessage(resultstring);
				sessionMessage.setMessage("Done sending list, analyzing response");
				message = DocumentHelper.parseText(resultstring);
				ids=message.getRootElement();
				if(ids.attributeValue("command").equalsIgnoreCase("setIds") && ids.attributeValue("id").equalsIgnoreCase(messageid+"")){
					sessionMessage.setMessage("Correct xml file received, updating ids on client side");
					//We received a correct response to the message that was sent, now update the IDs
					Iterator iElements = ids.elementIterator("id");
					while(iElements.hasNext()){
						Element id = (Element)iElements.next();
						if(id.attributeValue("type").equalsIgnoreCase("admin")){
							updateAdminId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("private")){
							updateAdminPrivateId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("encounter")){
							updateEncounterId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("insurance")){
							updateInsuranceId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("debet")){
							updateDebetId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("invoice")){
							updateInvoiceId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("credit")){
							updateCreditId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("transaction")){
							updateTransactionId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("problem")){
							updateProblemId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
						else if(id.attributeValue("type").equalsIgnoreCase("item")){
							updateItemId(id.attributeValue("newvalue"),id.attributeValue("value"));
						}
					}
					sessionMessage.setMessage("Done updating ids on client side, initializing counters");
					//All Ids have been updated, now we reinitialize the counters (set them to a negative value <= -1.000.000
					initializeCounters();
					updateIds=true;
					sessionMessage.setMessage("Done initializing counters");
				}
			}
			else {
				sessionMessage.setMessage("ERROR connection to "+url);
			}
		}
		catch(Exception e){
			sessionMessage.setErrorMessage(e.getMessage());
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return updateIds;
	}
	
	public void initializeCounters(){
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = adminconn.prepareStatement("select min(personid) counter from admin");
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("PersonID", counter);
			}
			rs.close();
			ps.close();
			ps = adminconn.prepareStatement("select min(privateid) counter from adminprivate");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("PrivateID", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(oc_encounter_objectid) counter from oc_encounters");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("OC_ENCOUNTERS", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(oc_insurance_objectid) counter from oc_insurances");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("OC_INSURANCES", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(oc_debet_objectid) counter from oc_debets");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("OC_DEBETS", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(oc_patientinvoice_objectid) counter from oc_patientinvoices");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("OC_INVOICES", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(oc_patientcredit_objectid) counter from oc_patientcredits");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("OC_PATIENTCREDITS", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(transactionid) counter from transactions");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("TransactionID", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(itemid) counter from items");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("ItemID", counter);
			}
			rs.close();
			ps.close();
			ps = occonn.prepareStatement("select min(oc_problem_objectid) counter from oc_problems");
			rs = ps.executeQuery();
			if(rs.next()){
				int counter = rs.getInt("counter");
				if(counter<0){
					counter=counter-1000000;
				}
				else {
					counter=-1000000;
				}
				MedwanQuery.getInstance().setOpenclinicCounter("OC_PROBLEMS", counter);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	

	public boolean updateItemId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update items set itemid=? where itemid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update arch_documents set arch_document_tran_transactionid=? where arch_document_tran_transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update items set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update permanentitems set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update requestedlabanalyses set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateTransactionId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update transactions set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update arch_documents set arch_document_tran_transactionid=? where arch_document_tran_transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update items set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update permanentitems set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update requestedlabanalyses set transactionid=? where transactionid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateCreditId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update oc_patientcredits set oc_patientcredit_objectid=? where oc_patientcredit_objectid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateInvoiceId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update oc_patientinvoices set oc_patientinvoice_objectid=? where oc_patientinvoice_objectid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_debets set oc_debet_patientinvoiceuid=? where oc_debet_patientinvoiceuid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_patientcredits set oc_patientcredit_invoiceuid=? where oc_patientcredit_invoiceuid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateProblemId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update oc_problems set oc_problem_objectid=? where oc_problem_objectid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateInsuranceId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update oc_insurances set oc_insurance_objectid=? where oc_insurance_objectid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_debets set oc_debet_insuranceuid=? where oc_debet_insuranceuid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateDebetId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update oc_debets set oc_debet_objectid=? where oc_debet_objectid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_debetfees set oc_debetfee_debetuid=? where oc_debetfee_debetuid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateEncounterId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = occonn.prepareStatement("update oc_encounters set oc_encounter_objectid=? where oc_encounter_objectid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_debets set oc_debet_encounteruid=? where oc_debet_encounteruid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_diagnoses set oc_diagnosis_encounteruid=? where oc_diagnosis_encounteruid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_patientcredits set oc_patientcredit_encounteruid=? where oc_patientcredit_encounteruid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_rfe set oc_rfe_encounteruid=? where oc_rfe_encounteruid=?");
			ps.setString(1, MedwanQuery.getInstance().getConfigInt("serverId")+"."+newid);
			ps.setString(2, MedwanQuery.getInstance().getConfigInt("serverId")+"."+oldid);
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateAdminPrivateId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = adminconn.prepareStatement("update adminprivate set privateid=? where privateid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}

	public boolean updateAdminId(String newid, String oldid){
		boolean success = false;
		Connection adminconn = MedwanQuery.getInstance().getAdminConnection();
		Connection occonn = MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			PreparedStatement ps = adminconn.prepareStatement("update admin set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = adminconn.prepareStatement("update adminprivate set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = adminconn.prepareStatement("update adminwork set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = adminconn.prepareStatement("update alternateid set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update appointments set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update arch_documents set arch_document_personid=? where arch_document_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update healthrecord set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_careers set hr_career_personid=? where hr_career_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_contracts set hr_contract_personid=? where hr_contract_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_disciplinary_records set hr_discrec_personid=? where hr_discrec_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_leave set hr_leave_personid=? where hr_leave_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_salaries set hr_salary_personid=? where hr_salary_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_skills set hr_skill_personid=? where hr_skill_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_training set hr_training_personid=? where hr_training_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update hr_workschedule set hr_workschedule_personid=? where hr_workschedule_personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_balances set oc_balance_owneruid=? where oc_balance_owneruid=? and oc_balance_ownertype='Person'");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_barcodes set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_careprescriptions set oc_careprescr_patientuid=? where oc_careprescr_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_chronicmedications set oc_chronicmed_patientuid=? where oc_chronicmed_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps = occonn.prepareStatement("update oc_encounters set oc_encounter_patientuid=? where oc_encounter_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_fingerprints set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_insurances set oc_insurance_patientuid=? where oc_insurance_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_paperprescriptions set oc_pp_patientuid=? where oc_pp_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_patient_meals set oc_pm_patientuid=? where oc_pm_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_patientinvoices set oc_patientinvoice_patientuid=? where oc_patientinvoice_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_person_pictures set personid=? where personid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_planning set oc_planning_patientuid=? where oc_planning_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_prescriptions set oc_prescr_patientuid=? where oc_prescr_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update oc_problems set oc_problem_patientuid=? where oc_problem_patientuid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();
			ps = occonn.prepareStatement("update requestedlabanalyses set patientid=? where patientid=?");
			ps.setInt(1, Integer.parseInt(newid));
			ps.setInt(2, Integer.parseInt(oldid));
			ps.execute();
			ps.close();

			success=true;
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try {
				adminconn.close();
				occonn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return success;
	}
	

	public void addCredits(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select p.*,e.oc_encounter_patientuid from oc_patientcredits p,oc_encounters e where oc_patientcredit_updatetime>=? and oc_encounter_objectid=replace(oc_patientcredit_encounteruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') order by oc_patientcredit_updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("oc_encounter_patientuid"));
					Timestamp updatetime = rs.getTimestamp("oc_patientcredit_updatetime");
			        Element element = DocumentHelper.createElement("credit");
			        addTimestampElement(element, "updatetime", updatetime);
			        addTimestampElement(element, "createtime", rs.getTimestamp("oc_patientcredit_createtime"));
			        addStringElement(element, "updateuid", rs.getString("oc_patientcredit_updateuid"));
			        addStringElement(element, "version", rs.getString("oc_patientcredit_version"));
			        addStringElement(element, "serverid", rs.getString("oc_patientcredit_serverid"));
			        String objectid=rs.getString("oc_patientcredit_objectid");
			        addStringElement(element, "objectid", objectid);
			        addTimestampElement(element, "date", rs.getTimestamp("oc_patientcredit_date"));
			        addStringElement(element, "invoiceuid", rs.getString("oc_patientcredit_invoiceuid"));
			        addStringElement(element, "amount", rs.getString("oc_patientcredit_amount"));
			        addStringElement(element, "type", rs.getString("oc_patientcredit_type"));
			        addStringElement(element, "encounteruid", rs.getString("oc_patientcredit_encounteruid"));
			        addStringElement(element, "comment", rs.getString("oc_patientcredit_comment"));
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".C."+objectid, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void addProblems(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from oc_problems where oc_problem_updatetime>=? order by oc_problem_updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("oc_problem_patientuid"));
					Timestamp updatetime = rs.getTimestamp("oc_problem_updatetime");
			        Element element = DocumentHelper.createElement("problem");
			        addTimestampElement(element, "updatetime", updatetime);
			        addTimestampElement(element, "createtime", rs.getTimestamp("oc_problem_createtime"));
			        addStringElement(element, "updateuid", rs.getString("oc_problem_updateuid"));
			        addStringElement(element, "version", rs.getString("oc_problem_version"));
			        addStringElement(element, "serverid", rs.getString("oc_problem_serverid"));
			        String objectid=rs.getString("oc_problem_objectid");
			        addStringElement(element, "objectid", objectid);
			        addTimestampElement(element, "begin", rs.getTimestamp("oc_problem_begin"));
			        addTimestampElement(element, "end", rs.getTimestamp("oc_problem_end"));
			        addStringElement(element, "codetype", rs.getString("oc_problem_codetype"));
			        addStringElement(element, "code", rs.getString("oc_problem_code"));
			        addStringElement(element, "gravity", rs.getString("oc_problem_gravity"));
			        addStringElement(element, "certainty", rs.getString("oc_problem_certainty"));
			        addStringElement(element, "comment", rs.getString("oc_problem_comment"));
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".O."+objectid, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void addLab(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from requestedlabanalyses where updatetime>=? order by updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("patientid"));
					Timestamp updatetime = rs.getTimestamp("updatetime");
			        Element element = DocumentHelper.createElement("lab");
			        addTimestampElement(element, "updatetime", updatetime);
			        addStringElement(element, "serverid", rs.getString("serverid"));
			        String objectid=rs.getString("objectid");
			        addStringElement(element, "objectid", objectid);
			        String transactionid= rs.getString("transactionid");
			        addStringElement(element, "transactionid",transactionid);
			        String analysiscode=rs.getString("analysiscode");
			        addStringElement(element, "analysiscode", analysiscode);
			        addStringElement(element, "comment", rs.getString("comment"));
			        addStringElement(element, "resultvalue", rs.getString("resultvalue"));
			        addStringElement(element, "resultunit", rs.getString("resultunit"));
			        addStringElement(element, "resultmodifier", rs.getString("resultmodifier"));
			        addStringElement(element, "resultcomment", rs.getString("resultcomment"));
			        addStringElement(element, "resultrefmax", rs.getString("resultrefmax"));
			        addStringElement(element, "resultrefmin", rs.getString("resultrefmin"));
			        addStringElement(element, "resultuserid", rs.getString("resultuserid"));
			        addStringElement(element, "resultprovisional", rs.getString("resultprovisional"));
			        addStringElement(element, "technicalvalidator", rs.getString("technicalvalidator"));
			        addTimestampElement(element, "technicalvalidationdatetime", rs.getTimestamp("technicalvalidationdatetime"));
			        addTimestampElement(element, "resultdate", rs.getTimestamp("resultdate"));
			        addStringElement(element, "finalvalidator", rs.getString("finalvalidator"));
			        addTimestampElement(element, "finalvalidationdatetime", rs.getTimestamp("finalvalidationdatetime"));
			        addTimestampElement(element, "requestdatetime", rs.getTimestamp("requestdatetime"));
			        addTimestampElement(element, "samplereceptiondatetime", rs.getTimestamp("samplereceptiondatetime"));
			        addTimestampElement(element, "sampletakendatetime", rs.getTimestamp("sampletakendatetime"));
			        addStringElement(element, "sampler", rs.getString("sampler"));
			        addTimestampElement(element, "worklisteddatetime", rs.getTimestamp("worklisteddatetime"));
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".L."+transactionid+"."+analysiscode, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void addInvoices(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from oc_patientinvoices where oc_patientinvoice_updatetime>=? order by oc_patientinvoice_updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("oc_patientinvoice_patientuid"));
					Timestamp updatetime = rs.getTimestamp("oc_patientinvoice_updatetime");
			        Element element = DocumentHelper.createElement("invoice");
			        addTimestampElement(element, "updatetime", updatetime);
			        addTimestampElement(element, "createtime", rs.getTimestamp("oc_patientinvoice_createtime"));
			        addStringElement(element, "updateuid", rs.getString("oc_patientinvoice_updateuid"));
			        addStringElement(element, "version", rs.getString("oc_patientinvoice_version"));
			        addStringElement(element, "serverid", rs.getString("oc_patientinvoice_serverid"));
			        String objectid=rs.getString("oc_patientinvoice_objectid");
			        addStringElement(element, "objectid", objectid);
			        addStringElement(element, "id", rs.getString("oc_patientinvoice_id"));
			        addTimestampElement(element, "date", rs.getTimestamp("oc_patientinvoice_date"));
			        addStringElement(element, "status", rs.getString("oc_patientinvoice_status"));
			        addStringElement(element, "balance", rs.getString("oc_patientinvoice_balance"));
			        addStringElement(element, "number", rs.getString("oc_patientinvoice_number"));
			        addStringElement(element, "insurarreference", rs.getString("oc_patientinvoice_insurarreference"));
			        addStringElement(element, "acceptationuid", rs.getString("oc_patientinvoice_acceptationuid"));
			        addStringElement(element, "insurarreferencedate", rs.getString("oc_patientinvoice_insurarreferencedate"));
			        addStringElement(element, "verifier", rs.getString("oc_patientinvoice_verifier"));
			        addStringElement(element, "comment", rs.getString("oc_patientinvoice_comment"));
			        addStringElement(element, "modifiers", rs.getString("oc_patientinvoice_modifiers"));
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".F."+objectid, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void addInsurances(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from oc_insurances where oc_insurance_updatetime>=? order by oc_insurance_updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("oc_insurance_patientuid"));
					Timestamp updatetime = rs.getTimestamp("oc_insurance_updatetime");
			        Element element = DocumentHelper.createElement("insurance");
			        addTimestampElement(element, "updatetime", updatetime);
			        addStringElement(element, "serverid", rs.getString("oc_insurance_serverid"));
			        String objectid=rs.getString("oc_insurance_objectid");
			        addStringElement(element, "objectid", objectid);
			        addStringElement(element, "nr", rs.getString("oc_insurance_nr"));
			        addStringElement(element, "insuraruid", rs.getString("oc_insurance_insuraruid"));
			        addStringElement(element, "type", rs.getString("oc_insurance_type"));
			        addTimestampElement(element, "start", rs.getTimestamp("oc_insurance_start"));
			        addTimestampElement(element, "stop", rs.getTimestamp("oc_insurance_stop"));
			        addStringElement(element, "comment", rs.getString("oc_insurance_comment"));
			        addTimestampElement(element, "createtime", rs.getTimestamp("oc_insurance_createtime"));
			        addStringElement(element, "updateuid", rs.getString("oc_insurance_updateuid"));
			        addStringElement(element, "version", rs.getString("oc_insurance_version"));
			        addStringElement(element, "insurancecategoryletter", rs.getString("oc_insurance_insurancecategoryletter"));
			        addStringElement(element, "member", rs.getString("oc_insurance_member"));
			        addStringElement(element, "memberimmat", rs.getString("oc_insurance_member_immat"));
			        addStringElement(element, "memberemployer", rs.getString("oc_insurance_member_employer"));
			        addStringElement(element, "status", rs.getString("oc_insurance_status"));
			        addStringElement(element, "extrainsuraruid", rs.getString("oc_insurance_extrainsuraruid"));
			        addStringElement(element, "extrainsuraruid2", rs.getString("oc_insurance_extrainsuraruid2"));
			        addStringElement(element, "default", rs.getString("oc_insurance_default"));
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".I."+objectid, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public void addDebets(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select d.*,e.oc_encounter_patientuid from oc_debets d,oc_encounters e where oc_encounter_objectid=replace(oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and oc_debet_updatetime>=? order by oc_debet_updatetime asc limit "+maxrecordblocks);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("oc_encounter_patientuid"));
					Timestamp updatetime = rs.getTimestamp("oc_debet_updatetime");
			        Element element = DocumentHelper.createElement("debet");
			        addTimestampElement(element, "updatetime", updatetime);
			        addStringElement(element, "serverid", rs.getString("oc_debet_serverid"));
			        String objectid=rs.getString("oc_debet_objectid");
			        addStringElement(element, "objectid", objectid);
			        addStringElement(element, "amount", rs.getString("oc_debet_amount"));
			        addStringElement(element, "balanceuid", rs.getString("oc_debet_balanceuid"));
			        addTimestampElement(element, "date", rs.getTimestamp("oc_debet_date"));
			        addStringElement(element, "description", rs.getString("oc_debet_description"));
			        addStringElement(element, "encounteruid", rs.getString("oc_debet_encounteruid"));
			        addStringElement(element, "prestationuid", rs.getString("oc_debet_prestationuid"));
			        addStringElement(element, "suppliertype", rs.getString("oc_debet_suppliertype"));
			        addStringElement(element, "supplieruid", rs.getString("oc_debet_supplieruid"));
			        addStringElement(element, "reftype", rs.getString("oc_debet_reftype"));
			        addStringElement(element, "refuid", rs.getString("oc_debet_refuid"));
			        addTimestampElement(element, "createtime", rs.getTimestamp("oc_debet_createtime"));
			        addStringElement(element, "updatetuid", rs.getString("oc_debet_updateuid"));
			        addStringElement(element, "version", rs.getString("oc_debet_version"));
			        addStringElement(element, "quantity", rs.getString("oc_debet_quantity"));
			        addStringElement(element, "credited", rs.getString("oc_debet_credited"));
			        addStringElement(element, "insuranceuid", rs.getString("oc_debet_insuranceuid"));
			        addStringElement(element, "patientinvoiceuid", rs.getString("oc_debet_patientinvoiceuid"));
			        addStringElement(element, "comment", rs.getString("oc_debet_comment"));
			        addStringElement(element, "insuraramount", rs.getString("oc_debet_insuraramount"));
			        addStringElement(element, "extrainsuraruid", rs.getString("oc_debet_extrainsuraruid"));
			        addStringElement(element, "extrainsurarinvoiceuid", rs.getString("oc_debet_extrainsurarinvoiceuid"));
			        addStringElement(element, "extrainsuraramount", rs.getString("oc_debet_extrainsuraramount"));
			        addStringElement(element, "renewalinterval", rs.getString("oc_debet_renewalinterval"));
			        addStringElement(element, "renewaldate", rs.getString("oc_debet_renewaldate"));
			        addStringElement(element, "performeruid", rs.getString("oc_debet_performeruid"));
			        addStringElement(element, "extrainsuraruid2", rs.getString("oc_debet_extrainsuraruid2"));
			        addStringElement(element, "extrainsurarinvoiceuid2", rs.getString("oc_debet_extrainsurarinvoiceuid2"));
			        addStringElement(element, "extrainsuraramount2", rs.getString("oc_debet_extrainsuraramount2"));
			        addStringElement(element, "serviceuid", rs.getString("oc_debet_serviceuid"));
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".D."+objectid, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void addEncounters(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from oc_encounters where oc_encounter_updatetime>=? order by oc_encounter_updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				try{
					int personid= Integer.parseInt(rs.getString("oc_encounter_patientuid"));
					Timestamp updatetime = rs.getTimestamp("oc_encounter_updatetime");
			        Element element = DocumentHelper.createElement("encounter");
			        addTimestampElement(element, "updatetime", updatetime);
			        int serverid = rs.getInt("oc_encounter_serverid");
			        addStringElement(element, "serverid", serverid+"");
			        int objectid=rs.getInt("oc_encounter_objectid");
			        addStringElement(element, "objectid", objectid+"");
			        addStringElement(element, "type", rs.getString("oc_encounter_type"));
			        addTimestampElement(element, "begindate", rs.getTimestamp("oc_encounter_begindate"));
			        addTimestampElement(element, "enddate", rs.getTimestamp("oc_encounter_enddate"));
			        addTimestampElement(element, "createtime", rs.getTimestamp("oc_encounter_createtime"));
			        addStringElement(element, "updatetuid", rs.getString("oc_encounter_updateuid"));
			        addStringElement(element, "version", rs.getString("oc_encounter_version"));
			        addStringElement(element, "outcome", rs.getString("oc_encounter_outcome"));
			        addStringElement(element, "destinationuid", rs.getString("oc_encounter_destinationuid"));
			        addStringElement(element, "origin", rs.getString("oc_encounter_origin"));
			        addTimestampElement(element, "processed", rs.getTimestamp("oc_encounter_processed"));
			        addStringElement(element, "categories", rs.getString("oc_encounter_categories"));
			        addStringElement(element, "newcase", rs.getString("oc_encounter_newcase"));
			        addStringElement(element, "etiology", rs.getString("oc_encounter_etiology"));
			        //Now add the encounterservices
			        Element services = element.addElement("services");
			        PreparedStatement ps2 = conn.prepareStatement("select * from oc_encounter_services where oc_encounter_serverid=? and oc_encounter_objectid=?");
			        ps2.setInt(1, serverid);
			        ps2.setInt(2, objectid);
			        ResultSet rs2=ps2.executeQuery();
			        while(rs2.next()){
			        	Element service = services.addElement("service");
			        	addStringElement(service, "serviceuid", rs2.getString("oc_encounter_serviceuid"));
			        	addStringElement(service, "beduid", rs2.getString("oc_encounter_beduid"));
			        	addStringElement(service, "manageruid", rs2.getString("oc_encounter_manageruid"));
				        addTimestampElement(service, "servicebegindate", rs2.getTimestamp("oc_encounter_servicebegindate"));
				        addTimestampElement(service, "serviceenddate", rs2.getTimestamp("oc_encounter_serviceenddate"));
			        }
			        rs2.close();
			        ps2.close();
			        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".E."+objectid, element)){
			        	break;
			        }
				}
				catch(Exception e2){
					e2.printStackTrace();
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void addTransactions(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select t.*,h.personid from transactions t, healthrecord h where t.healthrecordid=h.healthrecordid and ts>=? order by ts asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int personid= rs.getInt("personid");
		        Timestamp updatetime = rs.getTimestamp("ts");
		        Element element = DocumentHelper.createElement("transaction");
		        addTimestampElement(element, "ts", updatetime);
		        addDateElement(element, "updatetime", rs.getDate("updatetime"));
		        int transactionid=rs.getInt("transactionid");
		        addStringElement(element, "transactionid", transactionid+"");
		        addDateElement(element, "creationdate", rs.getDate("creationdate"));
		        addStringElement(element, "transactiontype", rs.getString("transactiontype"));
		        addStringElement(element, "status", rs.getString("status"));
		        addStringElement(element, "userid", rs.getString("userid"));
		        int serverid=rs.getInt("serverid");
		        addStringElement(element, "serverid", serverid+"");
		        addStringElement(element, "version", rs.getString("version"));
		        addStringElement(element, "versionserverid", rs.getString("versionserverid"));
		        //Now add the items for this transaction
		        Element items = element.addElement("items");
				PreparedStatement ps2 = conn.prepareStatement("select * from items where serverid=? and transactionid=?");
				ps2.setInt(1,serverid);
				ps2.setInt(2,transactionid);
				ResultSet rs2 = ps2.executeQuery();
				while(rs2.next()){
					Element item = items.addElement("item");
			        addStringElement(item, "itemid", rs2.getString("itemid"));
			        addStringElement(item, "type", rs2.getString("type"));
			        addStringElement(item, "value", rs2.getString("value"));
			        addStringElement(item, "priority", rs2.getString("priority"));
				}
				rs2.close();
				ps2.close();
		        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".T."+transactionid, element)){
		        	break;
		        }
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void addExtends(){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from adminextends where updatetime>=? order by updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int personid= rs.getInt("personid");
		        Timestamp updatetime = rs.getTimestamp("updatetime");
		        Element element = DocumentHelper.createElement("adminextends");
		        addTimestampElement(element, "updatetime", updatetime);
		        addStringElement(element, "extendid", rs.getString("extendid"));
		        addStringElement(element, "extendtype", rs.getString("extendtype"));
		        addStringElement(element, "labelid", rs.getString("labelid"));
		        addStringElement(element, "extendvalue", rs.getString("extendvalue"));
		        addStringElement(element, "updateuserid", rs.getString("updateuserid"));
		        addStringElement(element, "updateserverid", rs.getString("updateserverid"));
		        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".X", element)){
		        	break;
		        }
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void addPrivate(){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from adminprivate where updatetime>=? order by updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int personid= rs.getInt("personid");
		        Timestamp updatetime = rs.getTimestamp("updatetime");
		        Element element = DocumentHelper.createElement("adminprivate");
		        addTimestampElement(element, "updatetime", updatetime);
		        addStringElement(element, "privateid", rs.getString("privateid"));
		        addDateElement(element, "start", rs.getDate("start"));
		        addDateElement(element, "stop", rs.getDate("stop"));
		        addStringElement(element, "address", rs.getString("address"));
		        addStringElement(element, "city", rs.getString("city"));
		        addStringElement(element, "zipcode", rs.getString("zipcode"));
		        addStringElement(element, "country", rs.getString("country"));
		        addStringElement(element, "telephone", rs.getString("telephone"));
		        addStringElement(element, "fax", rs.getString("fax"));
		        addStringElement(element, "mobile", rs.getString("mobile"));
		        addStringElement(element, "email", rs.getString("email"));
		        addStringElement(element, "comment", rs.getString("comment"));
		        addStringElement(element, "type", rs.getString("type"));
		        addStringElement(element, "updateserverid", rs.getString("updateserverid"));
		        addStringElement(element, "district", rs.getString("district"));
		        addStringElement(element, "sanitarydistrict", rs.getString("sanitarydistrict"));
		        addStringElement(element, "province", rs.getString("province"));
		        addStringElement(element, "sector", rs.getString("sector"));
		        addStringElement(element, "cell", rs.getString("cell"));
		        addStringElement(element, "quarter", rs.getString("quarter"));
		        addStringElement(element, "business", rs.getString("business"));
		        addStringElement(element, "businessfunction", rs.getString("businessfunction"));
		        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".P", element)){
		        	break;
		        }
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void addAdmin(){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from admin where updatetime>=? and updateserverid order by updatetime asc");
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int personid= rs.getInt("personid");
		        Timestamp updatetime = rs.getTimestamp("updatetime");
		        Element element = DocumentHelper.createElement("admin");
		        addStringElement(element, "immatold", rs.getString("immatold"));
		        addStringElement(element, "immatnew", rs.getString("immatnew"));
		        addStringElement(element, "candidate", rs.getString("candidate"));
		        addStringElement(element, "lastname", rs.getString("lastname"));
		        addStringElement(element, "firstname", rs.getString("firstname"));
		        addStringElement(element, "gender", rs.getString("gender"));
		        addDateElement(element, "dateofbirth", rs.getDate("dateofbirth"));
		        addStringElement(element, "comment", rs.getString("comment"));
		        addStringElement(element, "sourceid", rs.getString("sourceid"));
		        addStringElement(element, "language", rs.getString("language"));
		        addStringElement(element, "gender", rs.getString("gender"));
		        addDateElement(element, "engagement", rs.getDate("engagement"));
		        addDateElement(element, "pension", rs.getDate("pension"));
		        addStringElement(element, "claimant", rs.getString("claimant"));
		        addStringElement(element, "searchname", rs.getString("searchname"));
		        addTimestampElement(element, "updatetime", updatetime);
		        addDateElement(element, "claimant_expiration", rs.getDate("claimant_expiration"));
		        addStringElement(element, "native_country", rs.getString("native_country"));
		        addStringElement(element, "native_town", rs.getString("native_town"));
		        addStringElement(element, "motive_end_of_service", rs.getString("motive_end_of_service"));
		        addDateElement(element, "startdate_inactivity", rs.getDate("startdate_inactivity"));
		        addDateElement(element, "enddate_inactivity", rs.getDate("enddate_inactivity"));
		        addStringElement(element, "code_inactivity", rs.getString("code_inactivity"));
		        addStringElement(element, "update_status", rs.getString("update_status"));
		        addStringElement(element, "person_type", rs.getString("person_type"));
		        addStringElement(element, "situation_end_of_service", rs.getString("situation_end_of_service"));
		        addStringElement(element, "updateuserid", rs.getString("updateuserid"));
		        addStringElement(element, "updateserverid", rs.getString("updateserverid"));
		        addStringElement(element, "comment1", rs.getString("comment1"));
		        addStringElement(element, "comment2", rs.getString("comment2"));
		        addStringElement(element, "comment3", rs.getString("comment3"));
		        addStringElement(element, "comment4", rs.getString("comment4"));
		        addStringElement(element, "comment5", rs.getString("comment5"));
		        addStringElement(element, "natreg", rs.getString("natreg"));
		        addStringElement(element, "middlename", rs.getString("middlename"));
		        addDateElement(element, "begindate", rs.getDate("begindate"));
		        addDateElement(element, "enddate", rs.getDate("enddate"));
		        addStringElement(element, "archivefilecode", rs.getString("archivefilecode"));
		        if(!addRecordBlock(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(updatetime)+"."+personid+".A", element)){
		        	break;
		        }
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally{
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}

	public Date getLastExport(){
		Date dLastExport = null;
		try {
			dLastExport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lastOpenClinicExport","19000101000000000"));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return dLastExport;
	}
	
	public void setLastExport(Date date){
		if(date!=null){
			MedwanQuery.getInstance().setConfigString("lastOpenClinicExport",new SimpleDateFormat("yyyyMMddHHmmssSSS").format(date));
		}
	}
	
	private boolean addRecordBlock(String key, Element element){
		if(patientrecordblocks.size()>maxrecordblocks){
			try {
				if(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(((String)patientrecordblocks.lastKey()).split("\\.")[0]).after(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(key.split("\\.")[0]))){
					patientrecordblocks.remove(patientrecordblocks.lastKey());
				}
				else{
					return false;
				}
			} catch (ParseException e) {
				return false;
			}
		}
		patientrecordblocks.put(key, element);
		return true;
	}

	private void addToRecord(int personid, Element element){
		if(patientrecords.get(personid)==null){
			Element e = DocumentHelper.createElement("record");
			e.addAttribute("personid", personid+"");
			patientrecords.put(personid, e);
		}
		Element e = (Element)patientrecords.get(personid);
		e.add(element);
	}
	
	private void addStringElement(Element parent, String elementName, String elementValue){
		if(elementValue!=null && elementValue.length()>0){
			Element e = parent.addElement(elementName);
			e.setText(HTMLEntities.htmlentities(elementValue));
			
		}
	}
	
	private void addDateElement(Element parent, String elementName, Date elementValue){
		if(elementValue!=null){
			Element e = parent.addElement(elementName);
			e.setText(new SimpleDateFormat("yyyyMMdd").format(elementValue));
		}
	}
	
	private void addTimestampElement(Element parent, String elementName, Timestamp elementValue){
		if(elementValue!=null){
			Element e = parent.addElement(elementName);
			e.setText(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(elementValue));
		}
	}
	
	
}
