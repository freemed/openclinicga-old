package be.openclinic.datacenter;

import java.io.ByteArrayInputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import javax.mail.MessagingException;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

public class Importer {

	public static void execute(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		String parameterid,parametertype;
		try{
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_IMPORTDATETIME is null and OC_IMPORT_ERRORCODE is null");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				parameterid=rs.getString("OC_IMPORT_ID");
				parametertype=ScreenHelper.checkString((String)MedwanQuery.getInstance().getDatacenterparametertypes().get(parameterid));
				if(parametertype.equalsIgnoreCase("simplevalue")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeSimpleValue(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("bedoccupancy")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeBedOccupancy(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("diagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDiagnosis(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
				else if(parametertype.equalsIgnoreCase("financial")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeFinancial(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
					else {
					}
				}
				else if(parametertype.equalsIgnoreCase("admissiondiagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDiagnosis(importMessage,"admission")){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
					else {
					}
				}
				else if(parametertype.equalsIgnoreCase("visitdiagnosis")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeDiagnosis(importMessage,"visit")){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
			}
			rs.close();
			ps.close();
	        String msgid=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_IMPORTDATETIME is not null and OC_IMPORT_IMPORTACKDATETIME is null");
			rs = ps.executeQuery();
			Vector ackMessages = new Vector();
			while(rs.next()){
				ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
				ackMessages.add(importMessage);
			}
			ImportMessage.sendImportAck(ackMessages);
			rs.close();
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (MessagingException e) {
			// TODO Auto-generated catch block
        	Debug.println(e.getMessage());
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static boolean storeDiagnosis(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("medical.1")){
				Element diags = root.element("diags");
				Iterator diagnoses = diags.elementIterator("diagnosis");
				while(diagnoses.hasNext()){
					Element diagnosis = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_DIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, "KPGS");
					ps.setString(3, diagnosis.attributeValue("code"));
					ps.setInt(4,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_DIAGNOSISVALUES(DC_DIAGNOSISVALUE_SERVERID,DC_DIAGNOSISVALUE_OBJECTID,DC_DIAGNOSISVALUE_CODETYPE,DC_DIAGNOSISVALUE_CODE,DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH,DC_DIAGNOSISVALUE_COUNT) values(?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, "KPGS");
					ps.setString(4, diagnosis.attributeValue("code"));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(6,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setInt(7,Integer.parseInt(diagnosis.attributeValue("count")));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeBedOccupancy(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").equalsIgnoreCase("encounter.1")){
				Element services = root.element("services");
				Iterator servs = services.elementIterator("service");
				ps = conn.prepareStatement("delete from DC_BEDOCCUPANCYVALUES where DC_BEDOCCUPANCYVALUE_SERVERID=? and DC_BEDOCCUPANCYVALUE_OBJECTID=?");
				ps.setInt(1, importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.executeUpdate();
				ps.close();
				while(servs.hasNext()){
					Element service = (Element)servs.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("insert into DC_BEDOCCUPANCYVALUES(DC_BEDOCCUPANCYVALUE_SERVERID,DC_BEDOCCUPANCYVALUE_OBJECTID,DC_BEDOCCUPANCYVALUE_SERVICEUID,DC_BEDOCCUPANCYVALUE_DATE,DC_BEDOCCUPANCYVALUE_TOTALBEDS,DC_BEDOCCUPANCYVALUE_OCCUPIEDBEDS) values(?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, service.attributeValue("serviceid"));
					ps.setTimestamp(4, new java.sql.Timestamp(new SimpleDateFormat("yyyyMMddHHmmss").parse(service.attributeValue("date")).getTime()));
					ps.setInt(5,Integer.parseInt(service.attributeValue("totalbeds")));
					ps.setInt(6,Integer.parseInt(service.attributeValue("occupiedbeds").equalsIgnoreCase("null")?"0":service.attributeValue("occupiedbeds")));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (ParseException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeDiagnosis(ImportMessage importMessage,String type){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && root.attributeValue("parameterid").startsWith("medical.1")){
				Element diags = root.element("diags");
				Iterator diagnoses = diags.elementIterator("diagnosis");
				while(diagnoses.hasNext()){
					Element diagnosis = (Element)diagnoses.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_ENCOUNTERDIAGNOSISVALUES where DC_DIAGNOSISVALUE_SERVERID=? and DC_DIAGNOSISVALUE_CODETYPE=? and DC_DIAGNOSISVALUE_CODE=? and DC_DIAGNOSISVALUE_YEAR=? and DC_DIAGNOSISVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, "KPGS");
					ps.setString(3, diagnosis.attributeValue("code"));
					ps.setInt(4,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_ENCOUNTERDIAGNOSISVALUES(DC_DIAGNOSISVALUE_SERVERID,DC_DIAGNOSISVALUE_OBJECTID,DC_DIAGNOSISVALUE_CODETYPE,DC_DIAGNOSISVALUE_CODE,DC_DIAGNOSISVALUE_YEAR,DC_DIAGNOSISVALUE_MONTH,DC_DIAGNOSISVALUE_COUNT,DC_DIAGNOSISVALUE_ENCOUNTERTYPE) values(?,?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, "KPGS");
					ps.setString(4, diagnosis.attributeValue("code"));
					ps.setInt(5,Integer.parseInt(diagnosis.attributeValue("year")));
					ps.setInt(6,Integer.parseInt(diagnosis.attributeValue("month")));
					ps.setInt(7,Integer.parseInt(diagnosis.attributeValue("count")));
					ps.setString(8, type);
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeFinancial(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
            SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(importMessage.data.getBytes("UTF-8")));
			Element root = document.getRootElement();
			if(root.getName().equalsIgnoreCase("data") && ( root.attributeValue("parameterid").startsWith("financial.0") ||
					root.attributeValue("parameterid").startsWith("financial.1") ||
					root.attributeValue("parameterid").startsWith("financial.2") ||
					root.attributeValue("parameterid").startsWith("financial.3") )){
				Element financial = root.element("financial");
				//First clear a possible existing value
				ps = conn.prepareStatement("delete from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_PARAMETERID=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_MONTH=?");
				ps.setInt(1, importMessage.getServerId());
				ps.setString(2, root.attributeValue("parameterid"));
				ps.setInt(3,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
				ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
				ps.execute();
				ps.close();
				ps = conn.prepareStatement("insert into DC_FINANCIALVALUES(DC_FINANCIALVALUE_SERVERID,DC_FINANCIALVALUE_OBJECTID,DC_FINANCIALVALUE_PARAMETERID,DC_FINANCIALVALUE_YEAR,DC_FINANCIALVALUE_MONTH,DC_FINANCIALVALUE_VALUE) values(?,?,?,?,?,?)");
				ps.setInt(1, importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.setString(3, root.attributeValue("parameterid"));
				ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
				ps.setInt(5,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
				ps.setString(6,financial.attributeValue("count"));
				ps.execute();
				ps.close();
				bSuccess=true;
			}
			else if(root.getName().equalsIgnoreCase("data") &&  root.attributeValue("parameterid").equalsIgnoreCase("financial.4")){
				Element financials =root.element("financials");
				Iterator fins = financials.elementIterator("financial");
				while(fins.hasNext()){
					Element financial = (Element)fins.next();
					//First clear a possible existing value
					ps = conn.prepareStatement("delete from DC_FINANCIALVALUES where DC_FINANCIALVALUE_SERVERID=? and DC_FINANCIALVALUE_PARAMETERID=? and DC_FINANCIALVALUE_CLASS=? and DC_FINANCIALVALUE_YEAR=? and DC_FINANCIALVALUE_MONTH=?");
					ps.setInt(1, importMessage.getServerId());
					ps.setString(2, root.attributeValue("parameterid"));
					ps.setString(3, financial.attributeValue("family"));
					ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
					ps.setInt(5,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
					ps.execute();
					ps.close();
					ps = conn.prepareStatement("insert into DC_FINANCIALVALUES(DC_FINANCIALVALUE_SERVERID,DC_FINANCIALVALUE_OBJECTID,DC_FINANCIALVALUE_PARAMETERID,DC_FINANCIALVALUE_YEAR,DC_FINANCIALVALUE_MONTH,DC_FINANCIALVALUE_VALUE,DC_FINANCIALVALUE_CLASS) values(?,?,?,?,?,?,?)");
					ps.setInt(1, importMessage.getServerId());
					ps.setInt(2, importMessage.getObjectId());
					ps.setString(3, root.attributeValue("parameterid"));
					ps.setInt(4,Integer.parseInt(financial.attributeValue("month").substring(0,4)));
					ps.setInt(5,Integer.parseInt(financial.attributeValue("month").substring(4,6)));
					ps.setString(6,financial.attributeValue("count"));
					ps.setString(7,financial.attributeValue("family"));
					ps.execute();
					ps.close();
				}
				bSuccess=true;
			}
			
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			importMessage.setError(2);
			e.printStackTrace();
		} catch (DocumentException e) {
			importMessage.setError(2);
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
	
	public static boolean storeSimpleValue(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
			ps=conn.prepareStatement("SELECT * from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_OBJECTID=?");
			ps.setInt(1,importMessage.getServerId());
			ps.setInt(2, importMessage.getObjectId());
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				rs.close();
				importMessage.updateErrorCode(1);
			}
			else {
				rs.close();
				ps.close();
				ps=conn.prepareStatement("INSERT INTO DC_SIMPLEVALUES(DC_SIMPLEVALUE_SERVERID,DC_SIMPLEVALUE_OBJECTID,DC_SIMPLEVALUE_PARAMETERID," +
						"DC_SIMPLEVALUE_CREATEDATETIME,DC_SIMPLEVALUE_SENTDATETIME," +
						"DC_SIMPLEVALUE_RECEIVEDATETIME,DC_SIMPLEVALUE_IMPORTDATETIME,DC_SIMPLEVALUE_DATA) " +
						"values (?,?,?,?,?,?,?,?)");
				ps.setInt(1,importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.setString(3, importMessage.getMessageId());
				ps.setTimestamp(4,importMessage.getCreateDateTime()==null?null:new java.sql.Timestamp(importMessage.getCreateDateTime().getTime()));
				ps.setTimestamp(5,importMessage.getSentDateTime()==null?null:new java.sql.Timestamp(importMessage.getSentDateTime().getTime()));
				ps.setTimestamp(6,importMessage.getReceiveDateTime()==null?null:new java.sql.Timestamp(importMessage.getReceiveDateTime().getTime()));
				ps.setTimestamp(7,importMessage.getImportDateTime()==null?null:new java.sql.Timestamp(importMessage.getImportDateTime().getTime()));
				ps.setString(8, importMessage.getData());
				ps.executeUpdate();
				importMessage.updateErrorCode(0);
				bSuccess=true;
			}
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return bSuccess;
	}
}