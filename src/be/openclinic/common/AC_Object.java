package be.openclinic.common;

import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public abstract class AC_Object {
	private int id=-1;
    private String updateUser;
    private Date updateDateTime;
    private SortedMap columns = new TreeMap();
    private String table;

    protected abstract void initialize();
    
    public boolean load(){
    	boolean bSuccess=false;
    	Connection conn=null;
    	PreparedStatement ps=null;
    	try{
    		conn = MedwanQuery.getInstance().getAdminConnection();
    		if(id>0){
    			//First remove old object with identical id
    			String sSelect = "SELECT * FROM "+table+" WHERE "+columns.get("id")+" = ?"; 
    			ps=conn.prepareStatement(sSelect);
    			ps.setInt(1, id);
    			ResultSet rs =ps.executeQuery();
    			if(rs.next()){
    	    		Iterator i = columns.keySet().iterator();
    	    		while(i.hasNext()){
    	    			String key=(String)i.next();
    	    			Field field=null;
    	    			try{
    	    				field = this.getClass().getDeclaredField(key);
    	    			}
    	    			catch(java.lang.NoSuchFieldException no){
    	    				field = AC_Object.class.getDeclaredField(key);
    	    			}
    	    			field.setAccessible(true);
    	    			if (String.class.equals(field.getType())){
    	    				field.set(this,rs.getString((String)columns.get(key)));
    	    			}
    	    			else if (int.class.equals(field.getType())){
    	    				field.setInt(this,rs.getInt((String)columns.get(key)));
    	    			}
    	    			else if (double.class.equals(field.getType())){
    	    				field.setDouble(this,rs.getDouble((String)columns.get(key)));
    	    			}
    	    			else if (java.util.Date.class.equals(field.getType())){
    	    				field.set(this,rs.getTimestamp((String)columns.get(key)));
    	    			}
        				bSuccess=true;
    	    		}
    			}
    			rs.close();
    			ps.close();
    		}
    		conn.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	return bSuccess;
    }
    
    public Vector getAll(){
    	Vector objects = new Vector();
    	Connection conn=null;
    	PreparedStatement ps=null;
    	try{
    		conn = MedwanQuery.getInstance().getAdminConnection();
			//First remove old object with identical id
			ps=conn.prepareStatement("SELECT * FROM "+table+" ORDER BY "+(String)columns.get("id"));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				AC_Object object = this.getClass().newInstance();
	    		Iterator i = columns.keySet().iterator();
	    		while(i.hasNext()){
	    			String key=(String)i.next();
	    			Field field=null;
	    			try{
	    				field = object.getClass().getDeclaredField(key);
	    			}
	    			catch(java.lang.NoSuchFieldException no){
	    				field = AC_Object.class.getDeclaredField(key);
	    			}
	    			field.setAccessible(true);
	    			if (String.class.equals(field.getType())){
	    				field.set(object,rs.getString((String)columns.get(key)));
	    			}
	    			else if (int.class.equals(field.getType())){
	    				field.setInt(object,rs.getInt((String)columns.get(key)));
	    			}
	    			else if (double.class.equals(field.getType())){
	    				field.setDouble(object,rs.getDouble((String)columns.get(key)));
	    			}
	    			else if (java.util.Date.class.equals(field.getType())){
	    				field.set(object,rs.getTimestamp((String)columns.get(key)));
	    			}
	    		}
    			objects.add(object);
			}
			rs.close();
			ps.close();
    		conn.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	return objects;
    }
    
    public Vector getAllSorted(String sortfield){
    	Vector objects = new Vector();
    	Connection conn=null;
    	PreparedStatement ps=null;
    	try{
    		conn = MedwanQuery.getInstance().getAdminConnection();
			//First remove old object with identical id
			ps=conn.prepareStatement("SELECT * FROM "+table+" ORDER BY "+sortfield);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				AC_Object object = this.getClass().newInstance();
	    		Iterator i = columns.keySet().iterator();
	    		while(i.hasNext()){
	    			String key=(String)i.next();
	    			Field field=null;
	    			try{
	    				field = object.getClass().getDeclaredField(key);
	    			}
	    			catch(java.lang.NoSuchFieldException no){
	    				field = AC_Object.class.getDeclaredField(key);
	    			}
	    			field.setAccessible(true);
	    			if (String.class.equals(field.getType())){
	    				field.set(object,rs.getString((String)columns.get(key)));
	    			}
	    			else if (int.class.equals(field.getType())){
	    				field.setInt(object,rs.getInt((String)columns.get(key)));
	    			}
	    			else if (double.class.equals(field.getType())){
	    				field.setDouble(object,rs.getDouble((String)columns.get(key)));
	    			}
	    			else if (java.util.Date.class.equals(field.getType())){
	    				field.set(object,rs.getTimestamp((String)columns.get(key)));
	    			}
	    		}
    			objects.add(object);
			}
			rs.close();
			ps.close();
    		conn.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	return objects;
    }
    
    public boolean delete(){
    	boolean bSuccess=false;
    	Connection conn=null;
    	PreparedStatement ps=null;
    	try{
    		conn = MedwanQuery.getInstance().getAdminConnection();
    		if(id>0){
    			//First remove old object with identical id
    			ps=conn.prepareStatement("DELETE FROM "+table+" WHERE "+columns.get("id")+" = ?");
    			ps.setInt(1, id);
    			ps.execute();
    			ps.close();
    		}
    		conn.close();
    		bSuccess=true;
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	return bSuccess;
    }
    
    public boolean store(){
    	boolean bSuccess=false;
    	setUpdateDateTime(new java.util.Date());
    	Connection conn=null;
    	PreparedStatement ps=null;
    	try{
    		conn = MedwanQuery.getInstance().getAdminConnection();
    		if(id>0){
    			//First remove old object with identical id
    			ps=conn.prepareStatement("DELETE FROM "+table+" WHERE "+columns.get("id")+" = ?");
    			ps.setInt(1, id);
    			ps.execute();
    			ps.close();
    		}
    		else{
    			id=MedwanQuery.getInstance().getOpenclinicCounter(table);
    		}
    		String sQuery="INSERT INTO "+table+"(";
    		Iterator i = columns.keySet().iterator();
    		boolean bInitialized=false;
    		while(i.hasNext()){
    			String key=(String)i.next();
    			if(bInitialized){
    				sQuery=sQuery+",";
    			}
    			else{
    				bInitialized=true;
    			}
    			sQuery=sQuery+columns.get(key);
    		}
    		sQuery+=") VALUES(";
    		i = columns.keySet().iterator();
    		bInitialized=false;
    		while(i.hasNext()){
    			i.next();
    			if(bInitialized){
    				sQuery=sQuery+",";
    			}
    			else{
    				bInitialized=true;
    			}
    			sQuery=sQuery+"?";
    		}
    		sQuery+=")";
    		ps=conn.prepareStatement(sQuery);
    		i = columns.keySet().iterator();
    		int index=1;
    		bInitialized=false;
    		while(i.hasNext()){
    			String key=(String)i.next();
    			Field field=null;
    			try{
    				field = this.getClass().getDeclaredField(key);
    			}
    			catch(java.lang.NoSuchFieldException no){
    				field = AC_Object.class.getDeclaredField(key);
    			}
    			field.setAccessible(true);
    			if (String.class.equals(field.getType())){
    				ps.setString(index++, (String)field.get(this));
    			}
    			else if (int.class.equals(field.getType())){
    				ps.setInt(index++, (Integer)field.get(this));
    			}
    			else if (double.class.equals(field.getType())){
    				ps.setDouble(index++, (Double)field.get(this));
    			}
    			else if (java.util.Date.class.equals(field.getType())){
    				ps.setTimestamp(index++, new java.sql.Timestamp(((java.util.Date)field.get(this)).getTime()));
    			}
    		}
    		ps.execute();
    		ps.close();
    		conn.close();
    		bSuccess=true;
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	return bSuccess;
    }
    public String getTable() {
		return table;
	}

	protected void setTable(String table) {
		this.table = table;
	}

	public AC_Object(){
    	initialize();
    }
    public SortedMap getColumns() {
		return columns;
	}
	protected void setColumns(SortedMap columns) {
		this.columns = columns;
	}
	public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUpdateUser() {
        return updateUser;
    }

    public void setUpdateUser(String updateUser) {
        this.updateUser = updateUser;
    }

    public Date getUpdateDateTime() {
        return updateDateTime;
    }

    public void setUpdateDateTime(Date updateDateTime) {
        this.updateDateTime = updateDateTime;
    }
}
