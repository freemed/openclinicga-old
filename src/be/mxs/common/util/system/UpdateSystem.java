package be.mxs.common.util.system;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.StringReader;
import java.net.URL;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Properties;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import net.admin.Label;
import net.admin.Parameter;
import net.admin.User;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.system.TransactionItem;

public class UpdateSystem implements Runnable {
	private int progress = -1;
	private String basedir;
	Thread thread;

	//--- RUN -------------------------------------------------------------------------------------
	public void run(){
        update(); // perform only once
	}
	
	//--- CONSTRUCTOR -----------------------------------------------------------------------------
	public UpdateSystem(){
	}
	
	//--- START -----------------------------------------------------------------------------------
	public void start(){
		thread = new Thread(this);
		thread.start();
	}
	
	//--- SET BASE DIR ----------------------------------------------------------------------------
	public void setBasedir(String basedir){
		this.basedir = basedir;
	}
	
	//--- UPDATE ----------------------------------------------------------------------------------
	public void update(){
		 setProgress(5); // "started"
		updateDb();
		 setProgress(20); // "updateDb done"
		updateLabels(basedir);
		 setProgress(40); // "updateLabels done"
		updateTransactionItems(basedir);
		 setProgress(60); // "updateTransactionItems done"
		updateCounters();
		 setProgress(80); // "updateCounters done"
		updateExaminations();
		 setProgress(90); // "updateExaminations done"
			
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "application.xml";
        SAXReader reader = new SAXReader(false);
        try{
	        Document document = reader.read(new URL(sDoc));
	        Element element = document.getRootElement().element("version");
	        int thisversion=Integer.parseInt(element.attribute("major").getValue())*1000000+Integer.parseInt(element.attribute("minor").getValue())*1000+Integer.parseInt(element.attribute("bug").getValue());
	        MedwanQuery.getInstance().setConfigString("updateVersion",thisversion+"");
        }
        catch(Exception e){
        	e.printStackTrace();
        }
                
		setProgress(100); // "completed"
	}
	
	//--- SET PROGRESS ----------------------------------------------------------------------------
	private void setProgress(int progress){
		this.progress = progress;
	}
	
	//--- GET PROGRESS ----------------------------------------------------------------------------
	public int getProgress(){
		return this.progress;
	}
	
	
	//--- UPDATE QUERIES --------------------------------------------------------------------------
	public void updateQueries(javax.servlet.ServletContext application){
		UpdateQueries.updateQueries(application);
	}
	
	//--- UPDATE DB -------------------------------------------------------------------------------
	public void updateDb(){
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": start updatedb");
		try {
			String sDoc="";
			Connection loc_conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
			Connection sta_conn = MedwanQuery.getInstance().getStatsConnection();
			Connection lad_conn = MedwanQuery.getInstance().getLongAdminConnection();
			String sLocalDbType="?";
			try {
			    sLocalDbType = lad_conn.getMetaData().getDatabaseProductName();
			}
			catch(Exception e){
			    //e.printStackTrace();
			}

			boolean bInit=false;
			SAXReader reader = new SAXReader(false);
			sDoc = MedwanQuery.getInstance().getConfigString("templateSource","http://localhost/openclinic/_common/xml/")+"db.xml";
			org.dom4j.Document document = reader.read(new URL(sDoc));
			bInit=true;
			Iterator tables = document.getRootElement().elementIterator("table");

			Element table;
			String sMessage = "";
		    String sOwnServerId = MedwanQuery.getInstance().getConfigString("serverId");
		    Element versionColumn = null;
		    Connection connectionCheck = null;
		    PreparedStatement psCheck = null;
		    ResultSet rsCheck = null,rsCheck2=null;
		    Connection otherAdminConnection = null;
		    Connection otherOccupConnection = null;
		    Element model = document.getRootElement();
		    Element column, index, view, proc, exec, sql;
		    DatabaseMetaData databaseMetaData;
		    Hashtable adminTables=new Hashtable(),adminColumns=new Hashtable(),adminIndexes=new Hashtable(),openclinicTables=new Hashtable(),openclinicColumns=new Hashtable(),openclinicIndexes=new Hashtable(),statsTables=new Hashtable(),statsColumns=new Hashtable(),statsIndexes=new Hashtable();
		    Hashtable hTables=null,hColumns=null,hIndexes=null;
		    Iterator columns, indexes, indexcolumns, views, sqlIterator, procs, execs;
		    String sSelect, sVal, sQuery, sCountQuery, otherServerId, inSql, versioncompare, values, outSql, indexname;
		    Connection source, destination;
		    boolean inited, indexFound, bDoWork, bInited, bCreate;
		    PreparedStatement psSync;
		    ResultSet rsSync, rsCount;
		    PreparedStatement psCountSync, psSync2;
		    ResultSet rsCountSync, rsSync2;
		    Object maxVersion;
		    HashMap primaryKey, cols;
		    int counter, total, syncTotal, rowCounter, compareStatus;
		    Statement stDelete, stCount, st;
		    Integer nVal;
		    Vector params;

			System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": update tables");
			//First load databasemodels
			String tableName,columnName,indexName;
			databaseMetaData=lad_conn.getMetaData();
			rsCheck=databaseMetaData.getColumns(null, null, null, null);
			while(rsCheck.next()){
				tableName=rsCheck.getString("TABLE_NAME");
				columnName=rsCheck.getString("COLUMN_NAME");
				if(adminTables.get(tableName)==null){
					rsCheck2=databaseMetaData.getIndexInfo(null, null, tableName, false, true);
					while(rsCheck2.next()){
						indexName=rsCheck2.getString("INDEX_NAME");
						adminIndexes.put((tableName+"$"+indexName).toLowerCase(),"");
					}
					adminTables.put(tableName.toLowerCase(),"");
				}
				adminColumns.put((tableName+"$"+columnName).toLowerCase(),"");
			}
			
			databaseMetaData=loc_conn.getMetaData();
			rsCheck=databaseMetaData.getColumns(null, null, null, null);
			while(rsCheck.next()){
				tableName=rsCheck.getString("TABLE_NAME");
				columnName=rsCheck.getString("COLUMN_NAME");
				if(openclinicTables.get(tableName)==null){
					openclinicTables.put(tableName.toLowerCase(),"");
					rsCheck2=databaseMetaData.getIndexInfo(null, null, tableName, false, true);
					while(rsCheck2.next()){
						indexName=rsCheck2.getString("INDEX_NAME");
						openclinicIndexes.put((tableName+"$"+indexName).toLowerCase(),"");
					}
				}
				openclinicColumns.put((tableName+"$"+columnName).toLowerCase(),"");
			}

			databaseMetaData=sta_conn.getMetaData();
			rsCheck=databaseMetaData.getColumns(null, null, null, null);
			while(rsCheck.next()){
				tableName=rsCheck.getString("TABLE_NAME");
				columnName=rsCheck.getString("COLUMN_NAME");
				if(statsTables.get(tableName)==null){
					statsTables.put(tableName.toLowerCase(),"");
					rsCheck2=databaseMetaData.getIndexInfo(null, null, tableName, false, true);
					while(rsCheck2.next()){
						indexName=rsCheck2.getString("INDEX_NAME");
						statsIndexes.put((tableName+"$"+indexName).toLowerCase(),"");
					}
				}
				statsColumns.put((tableName+"$"+columnName).toLowerCase(),"");
			}
			
		    tables = model.elementIterator("table");
		    while (tables.hasNext()) {
		        table = (Element) tables.next();
		        if (table.attribute("db").getValue().equalsIgnoreCase("ocadmin")) {
		            connectionCheck = lad_conn;
		            hTables=adminTables;
		            hColumns=adminColumns;
		            hIndexes=adminIndexes;
		        } else if (table.attribute("db").getValue().equalsIgnoreCase("openclinic")) {
		            connectionCheck = loc_conn;
		            hTables=openclinicTables;
		            hColumns=openclinicColumns;
		            hIndexes=openclinicIndexes;
		        } else if (table.attribute("db").getValue().equalsIgnoreCase("stats")) {
		            connectionCheck = sta_conn;
		            hTables=statsTables;
		            hColumns=statsColumns;
		            hIndexes=statsIndexes;
		        }

		        boolean tableExists=hTables.get(table.attribute("name").getValue().toLowerCase())!=null;

		        if (tableExists) {
		            //verify the table columns
		            versionColumn = null;
		            columns = table.element("columns").elementIterator("column");
		            while (columns.hasNext()) {
		                try {
		                    column = (Element) columns.next();
		                    if (column.attribute("version") != null && column.attribute("version").getValue().equalsIgnoreCase("1")) {
		                        versionColumn = column;
		                    }
		                    rsCheck = databaseMetaData.getColumns(null, null, table.attribute("name").getValue(), column.attribute("name").getValue());
		                    boolean columnExists=hColumns.get(table.attribute("name").getValue().toLowerCase()+"$"+column.attribute("name").getValue().toLowerCase())!=null;
		                    if (!columnExists) {
		                        sSelect = "alter table " + table.attribute("name").getValue() + " add " + column.attribute("name").getValue() + " ";
		                        if (column.attribute("dbtype").getValue().equalsIgnoreCase("char") || column.attribute("dbtype").getValue().equalsIgnoreCase("varchar")) {
		                            sSelect += column.attribute("dbtype").getValue() + "(" + column.attribute("size").getValue() + ")";
		                        } else {
		                            sSelect += column.attribute("dbtype").getValue();
		                        }
		                        sSelect += " null";
		                        psCheck = connectionCheck.prepareStatement(sSelect);
		                        psCheck.execute();
		                        psCheck.close();
		                    }
		                }
		                catch (Exception e) {
		                	e.printStackTrace();
		                }
		            }
		        } else {
		               //create the table
		               sSelect = "create table " + table.attribute("name").getValue() + "(";
		               columns = table.element("columns").elementIterator("column");
		               inited = false;
		               while (columns.hasNext()) {
		                   column = (Element) columns.next();
		                   if (inited) {
		                       sSelect += ",";
		                   } else {
		                       inited = true;
		                   }

		                   sSelect += column.attribute("name").getValue() + " ";

		                   if (column.attribute("dbtype").getValue().equalsIgnoreCase("char") || column.attribute("dbtype").getValue().equalsIgnoreCase("varchar")) {
		                       sSelect += column.attribute("dbtype").getValue() + "(" + column.attribute("size").getValue() + ")";
		                   } else {
		                       sSelect += column.attribute("dbtype").getValue();
		                   }

		                   if (column.attribute("nulls") != null && column.attribute("nulls").getValue().equalsIgnoreCase("0")) {
		                       sSelect += " not null";
		                   } else {
		                       sSelect += " null";
		                   }

		               }
		               try {
		                   sSelect += ")";
		                   psCheck = connectionCheck.prepareStatement(sSelect);
		                   psCheck.execute();
		                   psCheck.close();
		               }
		               catch (Exception e) {
							e.printStackTrace();
						}
		        }

		        //Now verify the indexes of the table
		        if (table.element("indexes") != null) {
		            indexes = table.element("indexes").elementIterator("index");
		            while (indexes.hasNext()) {
		                try {
		                    index = (Element) indexes.next();
		                    indexFound = hIndexes.get(table.attribute("name").getValue().toLowerCase()+"$"+index.attribute("name").getValue().toLowerCase())!=null;
		                    if (!indexFound) {
		                        sSelect = "create ";
		                        if (index.attribute("unique") != null && index.attribute("unique").getValue().equalsIgnoreCase("1")) {
		                            sSelect += " unique ";
		                        }
		                        sSelect += "index " + index.attribute("name").getValue() + " on " + table.attribute("name").getValue() + "(";
		                        indexcolumns = index.elementIterator("indexcolumn");
		                        inited = false;
		                        while (indexcolumns.hasNext()) {
		                            Element indexcolumn = (Element) indexcolumns.next();
		                            if (inited) {
		                                sSelect += ",";
		                            } else {
		                                inited = true;
		                            }
		                            if (indexcolumn.attribute("order").getValue().equalsIgnoreCase("ASC")) {
		                                sSelect += indexcolumn.attribute("name").getValue();
		                            } else {
		                                sSelect += indexcolumn.attribute("name").getValue() + " " + indexcolumn.attribute("order").getValue();
		                            }
		                        }
		                        sSelect += ")";
		                        psCheck = connectionCheck.prepareStatement(sSelect);
		                        psCheck.execute();
		                        psCheck.close();
		                    }
		                }
		                catch (Exception e) {
		                    e.printStackTrace();
		                }
		            }
		        }
		    }
			System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": update views");
		    views = model.elementIterator("view");
		    while (views.hasNext()) {
		        try {
		            view = (Element) views.next();
		            //Checking existence of view
		            //First select right connection
		            sqlIterator = view.elementIterator("sql");
		            String s = "";
		            while (sqlIterator.hasNext()) {
		                sql = (Element) sqlIterator.next();
		                if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
		                    s = sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin"));
		                }
		            }
		            if (s.trim().length() > 0) {
		                if (view.attribute("db").getValue().equalsIgnoreCase("ocadmin")) {
		                    connectionCheck = lad_conn;
				            hTables=adminTables;
		                } else if (view.attribute("db").getValue().equalsIgnoreCase("openclinic")) {
		                    connectionCheck = loc_conn;
				            hTables=openclinicTables;
		                } else if (view.attribute("db").getValue().equalsIgnoreCase("stats")) {
		                    connectionCheck = sta_conn;
				            hTables=statsTables;
		            	}
		                //Now verify existence of view
				        boolean viewExists=hTables.get(view.attribute("name").getValue().toLowerCase())!=null;
		                bCreate = true;
		                if (viewExists) {
		                    if (view.attribute("drop") != null && view.attribute("drop").getValue().equalsIgnoreCase("1")) {
		                        //drop the view
		                        psCheck = connectionCheck.prepareStatement("drop view " + view.attribute("name").getValue());
		                        psCheck.execute();
		                        psCheck.close();
		                    } else {
		                        bCreate = false;
		                    }
		                } 
		                else {
		                }
		                sqlIterator = view.elementIterator("sql");
		                while (sqlIterator.hasNext()) {
		                    sql = (Element) sqlIterator.next();
		                    if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
		                        st = connectionCheck.createStatement();
		                        String sq = sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin")).replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic"));
		                        sq = sq.replaceAll("\n", " ");
		                        sq = sq.replaceAll("\r", " ");
		                        st.addBatch(sq);
		                        st.executeBatch();
		                        st.close();
		                    }
		                }
		            }
		        }
		        catch (Exception e) {
		            e.printStackTrace();
		        }
		    }
			loc_conn.close();
			lad_conn.close();
			sta_conn.close();
		}
		catch (Exception e) {
		    e.printStackTrace();
		}
		
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": end updatedb");
	}
	
	//--- UPDATE LABELS ---------------------------------------------------------------------------
	public void updateLabels(String basedir){
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": reload labels");
        reloadSingleton();
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": end reload labels");
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": start updateLabels");
		
        String paramName, paramValue;
        String[] identifiers;
        String[] languages = MedwanQuery.getInstance().getConfigString("supportedLanguages","nl,fr,en,pt").split("\\,");
        for(int n=0;n<languages.length;n++){
    		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": load Labels."+languages[n]+".ini");
	        Properties iniProps = getPropertyFile(basedir+"/_common/xml/Labels."+languages[n]+".ini");
    		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": Labels."+languages[n]+".ini loaded");
	        Enumeration e = iniProps.keys();
	        boolean exists;
	        Hashtable langHashtable,typeHashtable,idHashtable;
	        Label label;
	        while(e.hasMoreElements()){
	            paramName = (String)e.nextElement();
	            paramValue = iniProps.getProperty(paramName);
	            identifiers = paramName.split("\\$");
	            exists=false;
	            langHashtable = MedwanQuery.getInstance().getLabels();
	            if(langHashtable!=null && identifiers.length>2){
	                typeHashtable = (Hashtable) langHashtable.get(identifiers[2]);
	                if(typeHashtable!=null){
	                    idHashtable = (Hashtable) typeHashtable.get(identifiers[0].toLowerCase());
	                    if(idHashtable!=null){
	                        label = (Label) idHashtable.get(identifiers[1]);
	                        if(label!=null){
	                        	exists=true;
	                        }
	                    }
	                }
	            }
	            if(!exists && identifiers.length>1){
	                MedwanQuery.getInstance().storeLabel(identifiers[0],identifiers[1],identifiers[2],paramValue,0);
	            }
	        }
        }
        String sDeliveries=MedwanQuery.getInstance().getConfigString("autorizedProductStockOperationDeliveries","'medicationdelivery.1','medicationdelivery.2','medicationdelivery.3','medicationdelivery.4','medicationdelivery.5','medicationdelivery.99'");
        String sReceipts=MedwanQuery.getInstance().getConfigString("autorizedProductStockOperationReceipts","'medicationreceipt.1','medicationreceipt.2','medicationreceipt.3','medicationreceipt.4','medicationreceipt.99'");
        String sOutcomes=MedwanQuery.getInstance().getConfigString("autorizedEncounterOutcomes","'better','contrareference','dead','deterioration','escape','other','recovered','reference'");
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	PreparedStatement ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE='productstockoperation.medicationdelivery' and OC_LABEL_ID not in ("+sDeliveries+")");
        	ps.execute();
        	ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE='productstockoperation.medicationreceipt' and OC_LABEL_ID not in ("+sReceipts+")");
        	ps.execute();
        	ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE='encounter.outcome' and OC_LABEL_ID not in ("+sOutcomes+")");
        	ps.execute();
        	ps.close();
        	conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        //Clear non-existing extrainsurars
        try{
        	PreparedStatement ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE='patientsharecoverageinsurance' and replace(OC_LABEL_ID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') not in (select OC_INSURAR_OBJECTID from OC_INSURARS)");
        	ps.execute();
        	ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE='patientsharecoverageinsurance2' and replace(OC_LABEL_ID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') not in (select OC_INSURAR_OBJECTID from OC_INSURARS)");
        	ps.execute();
        	ps.close();
        	conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": reload labels");
        reloadSingleton();
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": end updateLabels");
	}
	
	//--- UPDATE TRANSACTION ITEMS ----------------------------------------------------------------
	public void updateTransactionItems(String basedir){
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": start updatetransactionitems");
		Hashtable transactionItems = MedwanQuery.getInstance().getAllTransactionItems();
        String paramName, paramValue;
        TransactionItem objTI;
        Properties iniProps = getPropertyFile(basedir+"/_common/xml/TransactionItems.ini");
        Enumeration e = iniProps.keys();
        while(e.hasMoreElements()){
            paramName = (String)e.nextElement();
            paramValue = iniProps.getProperty(paramName);
            if (transactionItems.get(paramName)==null) {
            	objTI = new TransactionItem();
                objTI.setTransactionTypeId(paramName.split("\\$")[0]);
                objTI.setItemTypeId(paramName.split("\\$")[1]);
                if(paramValue.split("\\$")!=null && paramValue.split("\\$").length>0){
                	objTI.setDefaultValue(paramValue.split("\\$")[0]);
                    if(paramValue.split("\\$")!=null && paramValue.split("\\$").length>1){
                        objTI.setModifier(paramValue.split("\\$")[1]);
                    }
                    else {
                        objTI.setModifier("");
                    }
                }
                else {
                	objTI.setDefaultValue("");
                    objTI.setModifier("");
                }
                TransactionItem.addTransactionItem(objTI);
            }
    	}
		System.out.println(new SimpleDateFormat("HH:mm:ss.SSS").format(new java.util.Date())+": end updatetransactionitems");
	}
	
    //--- RELOAD SINGLETON ------------------------------------------------------------------------
    public void reloadSingleton() {
        Hashtable labelLanguages = new Hashtable();
        Hashtable labelTypes = new Hashtable();
        Hashtable labelIds;
        net.admin.Label label;

        // only load labels in memory that are service nor function.
        Vector vLabels = net.admin.Label.getNonServiceFunctionLabels();
        Iterator iter = vLabels.iterator();

        if (Debug.enabled) Debug.println("About to (re)load labels.");
        while(iter.hasNext()){
            label = (net.admin.Label)iter.next();
            // type
            labelTypes = (Hashtable) labelLanguages.get(label.language);
            if (labelTypes == null) {
                labelTypes = new Hashtable();
                labelLanguages.put(label.language, labelTypes);
                //Debug.println("new language : "+label.language);
            }

            // id
            labelIds = (Hashtable) labelTypes.get(label.type);
            if (labelIds == null) {
                labelIds = new Hashtable();
                labelTypes.put(label.type, labelIds);
                //Debug.println("new type : "+label.type);
            }

            labelIds.put(label.id, label);
        }

        // status info
        if (Debug.enabled) {
            Debug.println("Labels (re)loaded.");

            Debug.println(" * " + labelLanguages.size() + " languages");
            Debug.println(" * " + labelTypes.size() + " types per language");
        }

        MedwanQuery.getInstance().putLabels(labelLanguages);
    }
    
    //--- UPDATE PROJECT --------------------------------------------------------------------------
    public void updateProject(String sProject){
    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
    	PreparedStatement ps;
		try {
			ps = conn.prepareStatement("update Users set project=?");
	    	ps.setString(1, sProject);
	    	ps.execute();
	    	ps.close();
	    	conn.close();
	    	MedwanQuery.getInstance().setConfigString("availableProjects", sProject);
	    	MedwanQuery.getInstance().setConfigString("defaultProject", sProject);
		} catch (SQLException e) {
			e.printStackTrace();
		}
    }
    
    //--- GET PROPERTY FILE -----------------------------------------------------------------------
    private Properties getPropertyFile(String sFilename) {
        FileInputStream iniIs;
        Properties iniProps = new Properties();

        // create ini file if they do not exist
        try {
            iniIs = new FileInputStream(sFilename);
            iniProps.load(iniIs);
            iniIs.close();
        }
        catch (FileNotFoundException e) {
            // create the file if it does not exist
            try {
                new FileOutputStream(sFilename);
            }
            catch (Exception e1) {
                if (Debug.enabled) Debug.println(e1.getMessage());
            }
        }
        catch (Exception e) {
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        return iniProps;
    }
    
    //--- VALIDATE COUNCIL REGISTRATIONS ----------------------------------------------------------
    public void validateCouncilRegistrations(){
    	String regnrs="";
    	Hashtable hRegs=new Hashtable();
    	Hashtable councils=new Hashtable();
    	try{
	    	Connection conn = MedwanQuery.getInstance().getAdminConnection();
	    	PreparedStatement ps = conn.prepareStatement("select distinct userid,value from UserParameters a where parameter='automaticorganizationidvalidation' and active=1");
	    	ResultSet rs = ps.executeQuery();
	    	while(rs.next()){
	    		String council = rs.getString("value");
	    		int userid = rs.getInt("userid");
	    		PreparedStatement ps2 = conn.prepareStatement("select * from UserParameters where userid=? and parameter='organisationid' and active=1");
	    		ps2.setInt(1, userid);
	    		ResultSet rs2=ps2.executeQuery();
	    		if(rs2.next()){
		    		String reg=rs2.getString("value");
		    		if(hRegs.get(reg)==null){
			    		String regs = (String)councils.get(council);
			    		if(regs==null){
			    			regs="";
			    		}
			    		if(regs.length()>0){
			    			regs+=";";
			    		}
		    			regs+=reg;
			    		councils.put(council, regs);
			    		hRegs.put(reg,"1");
		    		}
	    		}
	    		rs2.close();
	    		ps2.close();
	    	}
	    	rs.close();
	    	ps.close();
	    	
	    	//We now have all id's to verify
	    	Enumeration r = councils.keys();
	    	while(r.hasMoreElements()){
	    		String council = (String)r.nextElement();
	    		String regs = (String)councils.get(council);
	    		//Launch the updatequery for this council
	    		HttpClient client = new HttpClient();
	    		MedwanQuery.getInstance().reloadLabels();
	    		String lookupUrl=ScreenHelper.getTran("professional.council.url",council,"fr");
	    		System.out.println("launching post to "+lookupUrl);
	    		PostMethod method = new PostMethod(lookupUrl);
	    		method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
	    		NameValuePair nvp1= new NameValuePair("regnrs",regs);
	    		NameValuePair nvp2= new NameValuePair("key",MedwanQuery.getInstance().getConfigString("councilLookupKey"));
	    		method.setQueryString(new NameValuePair[]{nvp1,nvp2});
	    		try{
	    			int statusCode = client.executeMethod(method);
		    		System.out.println("resultcode = "+statusCode);
	    			if(statusCode==200){
	    				String xml = method.getResponseBodyAsString();
	    				org.dom4j.Document document=null;
	    				Element root=null;
	    				BufferedReader br = new BufferedReader(new StringReader(xml));
	    				SAXReader reader=new SAXReader(false);
	    				document=reader.read(br);
			    		System.out.println("xml = "+document.asXML());
	    				root=document.getRootElement();
	    				if(root.getName().equalsIgnoreCase("registration")){
	    					Iterator elements = root.elementIterator("status");
	    					while(elements.hasNext()){
	    						Element element = (Element)elements.next();
	    						ps=conn.prepareStatement("select * from UserParameters where parameter='organisationid' and value=? and active=1");
	    						ps.setString(1, element.attributeValue("regnr"));
	    						rs=ps.executeQuery();
	    						while(rs.next()){
		    						User user = User.get(rs.getInt("userid"));
		    						if(user !=null && !user.getParameter("registrationstatus").equalsIgnoreCase(element.attributeValue("id"))){
		    							user.updateParameter(new Parameter("registrationstatus",element.attributeValue("id")));
		    							user.updateParameter(new Parameter("registrationstatusdate",ScreenHelper.stdDateFormat.format(new java.util.Date())));
		    						}
		    						else if(user!=null && !user.getParameter("registrationstatus").equalsIgnoreCase("0")){
		    							if(MedwanQuery.getInstance().getConfigInt("enableProfessionalCouncilRegistrationCancellation",0)==1){
			    							try{
			    								long trimester = 24*3600*1000;
			    								trimester=trimester*MedwanQuery.getInstance().getConfigInt("professionalCouncilRegistrationCancellationDelay",90);
			    								if(new java.util.Date().getTime()-ScreenHelper.parseDate(user.getParameter("registrationstatusdate")).getTime()>trimester){
			    									//Cancel user access
			    									user.stop=ScreenHelper.stdDateFormat.format(new java.util.Date());
			    									user.saveToDB();
			    								}
			    							}
			    							catch(Exception e4){
			    								e4.printStackTrace();
			    							}
		    							}
		    						}
	    							user.updateParameter(new Parameter("registrationstatusupdatetime",ScreenHelper.stdDateFormat.format(new java.util.Date())));
	    						}
	    						rs.close();
	    						ps.close();
	    					}
	    				}
	    				MedwanQuery.getInstance().setConfigString("lastProfessionalCouncilValidation", new SimpleDateFormat("yyyyMMdd").format(new java.util.Date()));
	    			}
	    		}
	    		catch(Exception e3){
	    			e3.printStackTrace();
	    		}
	    	}
	    	conn.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
    
    //--- UPDATE SETUP ----------------------------------------------------------------------------
    public void updateSetup(String section, String code, HttpServletRequest request){
    	MedwanQuery.getInstance().setConfigString("setup."+section, code);
        try{
	        SAXReader xmlReader = new SAXReader();
	        Document document;
	        String sMenuXML = MedwanQuery.getInstance().getConfigString("setupXMLFile","setup.xml");
	        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
	        // Check if menu file exists, else use file at templateSource location.
	        document = xmlReader.read(new URL(sMenuXMLUrl));
	        if (document != null) {
	            Element root = document.getRootElement();
	            if (root != null) {
	                Iterator elements = root.elementIterator(section);
	                while (elements.hasNext()) {
	                    Element e = (Element) elements.next();
	                    if(e.attributeValue("code").equalsIgnoreCase(code)){
	                    	Iterator configelements = e.elementIterator();
	                    	while(configelements.hasNext()){
	                    		Element configelement = (Element)configelements.next();
	                    		if(configelement.getName().equalsIgnoreCase("config")){
	                    			//This is an OC_CONFIG setting
	                    			MedwanQuery.getInstance().setConfigString(configelement.attributeValue("key"), configelement.attributeValue("value").replaceAll("\\$setupdir\\$", request.getSession().getServletContext().getRealPath("/").replaceAll("\\\\","/")));
	                    		}
	                    		else if(configelement.getName().equalsIgnoreCase("labels")){
	                    			//This is a label list 
	                    			//First erase existing entries
	                    			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	                    			PreparedStatement ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE=?");
	                    			ps.setString(1, configelement.attributeValue("type"));
	                    			ps.execute();
	                    			ps.close();
	                    			conn.close();
	                    			//Then, add every label that is inside this label list
	                    			Iterator labels = configelement.elementIterator("label");
	                    			while(labels.hasNext()){
	                    				Element labelelement = (Element)labels.next();
	                    				Label label = new Label(configelement.attributeValue("type"),labelelement.attributeValue("id"),labelelement.attributeValue("language"),labelelement.getText(),"1","4");
	                    				label.saveToDB();
	                    			}
	                    			MedwanQuery.getInstance().reloadLabels();
	                    		}
	                    	}
	                    }
	                }
	            }
	        }
        }catch (Exception e){
        	e.printStackTrace();
        }
    }
    
    //--- INITIAL SETUP ---------------------------------------------------------------------------
    public void initialSetup(String section, String code, HttpServletRequest request){
    	MedwanQuery.getInstance().setConfigString("setup."+section, code);
        try{
	        SAXReader xmlReader = new SAXReader();
	        Document document;
	        String sMenuXML = MedwanQuery.getInstance().getConfigString("setupXMLFile","setup.xml");
	        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
	        // Check if menu file exists, else use file at templateSource location.
	        document = xmlReader.read(new URL(sMenuXMLUrl));
	        if (document != null) {
	            Element root = document.getRootElement();
	            if (root != null) {
	                Iterator elements = root.elementIterator(section);
	                while (elements.hasNext()) {
	                    Element e = (Element) elements.next();
	                    if(e.attributeValue("code").equalsIgnoreCase(code)){
	                    	Iterator configelements = e.elementIterator();
	                    	while(configelements.hasNext()){
	                    		Element configelement = (Element)configelements.next();
	                    		if(configelement.getName().equalsIgnoreCase("config")){
	                    			//This is an OC_CONFIG setting
	                    			MedwanQuery.getInstance().setConfigString(configelement.attributeValue("key"), configelement.attributeValue("value").replaceAll("\\$setupdir\\$", request.getSession().getServletContext().getRealPath("/").replaceAll("\\\\","/")));
	                    		}
	                    		else if(configelement.getName().equalsIgnoreCase("labels")){
	                    			//This is a label list 
	                    			//First erase existing entries
	                    			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	                    			PreparedStatement ps = conn.prepareStatement("delete from OC_LABELS where OC_LABEL_TYPE=?");
	                    			ps.setString(1, configelement.attributeValue("type"));
	                    			ps.execute();
	                    			ps.close();
	                    			conn.close();
	                    			//Then, add every label that is inside this label list
	                    			Iterator labels = configelement.elementIterator("label");
	                    			while(labels.hasNext()){
	                    				Element labelelement = (Element)labels.next();
	                    				Label label = new Label(configelement.attributeValue("type"),labelelement.attributeValue("id"),labelelement.attributeValue("language"),labelelement.getText(),"1","4");
	                    				label.saveToDB();
	                    			}
	                    			MedwanQuery.getInstance().reloadLabels();
	                    		}
	                    		else if(configelement.getName().equalsIgnoreCase("project")){
	                    			updateProject(configelement.getText());
	                    		}
	                    	}
	                    }
	                }
	            }
	        }
        }catch (Exception e){
        	e.printStackTrace();
        }
    }
    
    //--- UPDATE EXAMINATIONS ---------------------------------------------------------------------
    public int updateExaminations(){
        int counter=0;
    	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	PreparedStatement ps=null;
    	ResultSet rs=null;
    	try{
    		SAXReader xmlReader = new SAXReader();
	        Document document;
	        String sMenuXML = MedwanQuery.getInstance().getConfigString("examinationsXMLFile","examinations.xml");
	        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
	        // Check if menu file exists, else use file at templateSource location.
	        document = xmlReader.read(new URL(sMenuXMLUrl));
	        if (document != null) {
	            Element root = document.getRootElement();
	            if (root != null) {
	                Iterator elements = root.elementIterator("Row");
	                while (elements.hasNext()) {
	                    Element e = (Element) elements.next();
	                    Element id = e.element("id");
	                    Element transactiontype = e.element("transactiontype");
	                    Element data =e.element("Data");
	                    Element fr=e.element("fr");
	                    Element en=e.element("en");
	                    Element es=e.element("es");
	                    Element nl=e.element("nl");
	                    Element pt=e.element("pt");
	                    if(id!=null && transactiontype!=null){
	                    	counter++;
	                    	//First search if the examination already exists
	                    	ps=conn.prepareStatement("select * from examinations where transactiontype=?");
	                    	ps.setString(1, transactiontype.getText());
	                    	rs=ps.executeQuery();
	                    	if(rs.next()){
	                    		//Examination exists
	                    		int oldid = rs.getInt("id");
	                    		if(oldid!=Integer.parseInt(id.getText())){
		                    		//Update examinations, serviceexaminations and oc_labels tables with new id value
		                    		rs.close();
		                    		ps.close();
		                    		ps=conn.prepareStatement("update examinations set id=? where id=?");
		                    		ps.setInt(1, Integer.parseInt(id.getText()));
		                    		ps.setInt(2, oldid);
		                    		ps.execute();
		                    		ps.close();
		                    		ps=conn.prepareStatement("update serviceexaminations set examinationid=? where examinationid=?");
		                    		ps.setInt(1, Integer.parseInt(id.getText()));
		                    		ps.setInt(2, oldid);
		                    		ps.execute();
		                    		ps.close();
		                    		ps=conn.prepareStatement("update oc_labels set oc_label_id=? where oc_label_id=? and oc_label_type='examination'");
		                    		ps.setString(1, id.getText());
		                    		ps.setString(2, oldid+"");
		                    		ps.execute();
		                    		ps.close();
	                    		}
	                    		else {
	                    			//Update has already been performed on this examination, do nothing
	                    		}
	                    	}
	                    	else{
	                    		//Examination doesn't exist, let's add it
	                    		rs.close();
	                    		ps.close();
	                    		ps=conn.prepareStatement("insert into examinations(id,transactiontype,priority,data,updatetime,updateuserid,messageKey) values(?,?,1,?,?,4,'')");
	                    		ps.setInt(1,Integer.parseInt(id.getText()));
	                    		ps.setString(2, transactiontype.getText());
	                    		ps.setString(3, data!=null?data.asXML():"");
	                    		ps.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
	                    		ps.execute();
	                    		ps.close();
	                    		if(fr!=null){
	                    			Label label = new Label("examination",id.getText(),"fr",fr.getText(),"1","4");
	                    			label.saveToDB();
	                    		}
	                    		if(en!=null){
	                    			Label label = new Label("examination",id.getText(),"en",en.getText(),"1","4");
	                    			label.saveToDB();
	                    		}
	                    		if(es!=null){
	                    			Label label = new Label("examination",id.getText(),"es",es.getText(),"1","4");
	                    			label.saveToDB();
	                    		}
	                    		if(nl!=null){
	                    			Label label = new Label("examination",id.getText(),"nl",nl.getText(),"1","4");
	                    			label.saveToDB();
	                    		}
	                    		if(pt!=null){
	                    			Label label = new Label("examination",id.getText(),"pt",pt.getText(),"1","4");
	                    			label.saveToDB();
	                    		}
	                    	}
	                    }
	                }
	            }
	        }
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	finally{
    		try{
    			conn.close();
    			reloadSingleton();
    			updateCounters();
    		}
    		catch(Exception e2){
    			e2.printStackTrace();
    		}
    	}
    	return counter;
    }
    
    //--- UPDATE COUNTERS -------------------------------------------------------------------------
    public void updateCounters() {
        try{
        	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        	PreparedStatement ps = conn.prepareStatement("select * from oc_config where oc_key like 'quickList%'");
        	ResultSet rs = ps.executeQuery();
        	while (rs.next()){
        		String oc_key=rs.getString("OC_KEY");
        		String oc_value=rs.getString("OC_VALUE");
        		String news="";
        		if(oc_value.indexOf("£")<0){
        			String[] s=oc_value.split(";");
        			for(int n=0;n<s.length;n++){
        				if(news.length()>0){
        					news=";"+news;
        				}
        				for (int i=s[n].split("\\.").length-1;i>-1;i--){
        					if(i==s[n].split("\\.").length-3){
        						news="£"+news;
        					}
        					else if (i<s[n].split("\\.").length-1){
        						news="."+news;
        					}
        					news=s[n].split("\\.")[i]+news;
        				}
        			}
        			MedwanQuery.getInstance().setConfigString(oc_key, news);
        		}
        	}
        	rs.close();
        	ps.close();
        	conn.close();
	        SAXReader xmlReader = new SAXReader();
	        Document document;
	        String sMenuXML = MedwanQuery.getInstance().getConfigString("countersXMLFile","counters.xml");
	        String sMenuXMLUrl = MedwanQuery.getInstance().getConfigString("templateSource") + sMenuXML;
	        // Check if menu file exists, else use file at templateSource location.
	        document = xmlReader.read(new URL(sMenuXMLUrl));
	        if (document != null) {
	            Element root = document.getRootElement();
	            if (root != null) {
	                Iterator elements = root.elementIterator("counter");
	                while (elements.hasNext()) {
	                    Element e = (Element) elements.next();
	                    MedwanQuery.getInstance().setSynchroniseCounters(e.attributeValue("name"), e.attributeValue("table"), e.attributeValue("field"), e.attributeValue("bd"));
	                }
	            }
	        }
        }catch (Exception e){
        	e.printStackTrace();
        }
        
        //Patients archiveFileCode
        String s="select max(archivefilecode) as maxcode from adminview where "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(archivefilecode)=(select max("+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(archivefilecode)) from adminview where "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(archivefilecode)<7)";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
        	PreparedStatement ps=oc_conn.prepareStatement(s);
        	ResultSet rs = ps.executeQuery();
        	if(rs.next()){
        		String maxcode=rs.getString("maxcode");
            	rs.close();
            	ps.close();
				s="update OC_COUNTERS set OC_COUNTER_VALUE=? where OC_COUNTER_NAME=?";
				ps=oc_conn.prepareStatement(s);
				ps.setInt(1,ScreenHelper.convertFromAlfabeticalCode(maxcode)+1);
				ps.setString(2,"ArchiveFileId");
				ps.executeUpdate();
				ps.close();
        	}
        	else{
	        	rs.close();
	        	ps.close();

        	}
        }
        catch(Exception e){
        	e.printStackTrace();
		}
        try{
        	oc_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
    }

}
