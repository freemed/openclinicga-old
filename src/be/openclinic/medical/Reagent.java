package be.openclinic.medical;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.common.OC_Object;
import be.openclinic.pharmacy.Product;

public class Reagent extends OC_Object{
	String name;
	String unit;
	String provider;
	String productUid;
	Product product=null;
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getUnit() {
		return unit;
	}
	public void setUnit(String unit) {
		this.unit = unit;
	}
	public String getProvider() {
		return provider;
	}
	public void setProvider(String provider) {
		this.provider = provider;
	}
	public String getProductUid() {
		return productUid;
	}
	public void setProductUid(String productUid) {
		this.productUid = productUid;
		this.product=null;
	}
	
	public Product getProduct(){
		if(this.product==null && this.getProductUid()!=null){
			this.product=Product.get(this.getProductUid());
		}
		return this.product;
	}
	
	public static Vector searchReagents(String name){
		Vector reagents = new Vector();
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		ResultSet rs =null;
		try{
			ps=conn.prepareStatement("select * from OC_REAGENTS where OC_REAGENT_NAME like ? order by OC_REAGENT_NAME");
			ps.setString(1, "%"+name+"%");
			rs=ps.executeQuery();
			while(rs.next()){
				Reagent reagent = new Reagent();
				reagent.setUid(rs.getString("OC_REAGENT_SERVERID")+"."+rs.getString("OC_REAGENT_OBJECTID"));
				reagent.setCreateDateTime(rs.getTimestamp("OC_REAGENT_CREATEDATETIME"));
				reagent.setName(rs.getString("OC_REAGENT_NAME"));
				reagent.setUnit(rs.getString("OC_REAGENT_UNIT"));
				reagent.setProvider(rs.getString("OC_REAGENT_PROVIDER"));
				reagent.setProductUid(rs.getString("OC_REAGENT_PRODUCTUID"));
				reagent.setUpdateDateTime(rs.getTimestamp("OC_REAGENT_UPDATEDATETIME"));
				reagent.setUpdateUser(rs.getString("OC_REAGENT_UPDATEUID"));
				reagent.setVersion(rs.getInt("OC_REAGENT_VERSION"));
				reagents.add(reagent);
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
		return reagents;
	}
	
	public void store(){
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			if(this.getUid()!=null && this.getUid().split("\\.").length==2){
				//The reagent already exists. Move it to the history
				ps=conn.prepareStatement(	" insert into OC_REAGENTS_HISTORY(OC_REAGENT_SERVERID,OC_REAGENT_OBJECTID,"+
											" OC_REAGENT_CREATEDATETIME,OC_REAGENT_NAME,OC_REAGENT_UNIT,"+
											" OC_REAGENT_PROVIDER,OC_REAGENT_PRODUCTUID,"+
											" OC_REAGENT_UPDATEDATETIME,OC_REAGENT_UPDATEUID,OC_REAGENT_VERSION)"+
											" select OC_REAGENT_SERVERID,OC_REAGENT_OBJECTID,"+
											" OC_REAGENT_CREATEDATETIME,OC_REAGENT_NAME,OC_REAGENT_UNIT,"+
											" OC_REAGENT_PROVIDER,OC_REAGENT_PRODUCTUID,"+
											" OC_REAGENT_UPDATEDATETIME,OC_REAGENT_UPDATEUID,OC_REAGENT_VERSION from OC_REAGENTS"+
											" WHERE OC_REAGENT_SERVERID=? and OC_REAGENT_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(this.getUid().split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(this.getUid().split("\\.")[1]));
				ps.execute();
				ps.close();
				//Remove the reagnet from the actual table
				ps=conn.prepareStatement("DELETE FROM OC_REAGENTS WHERE OC_REAGENT_SERVERID=? and OC_REAGENT_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(this.getUid().split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(this.getUid().split("\\.")[1]));
				ps.execute();
				ps.close();
				//Increase the actual version
				this.setVersion(this.getVersion()+1);
			}
			else {
				this.setVersion(1);
				this.setUid(MedwanQuery.getInstance().getConfigInt("serverId")+"."+MedwanQuery.getInstance().getOpenclinicCounter("OC_REAGENTS"));
				this.setCreateDateTime(new java.util.Date());
			}
			this.setUpdateDateTime(new java.util.Date());
			
			//Store the actual reagent
			ps=conn.prepareStatement(" insert into OC_REAGENTS(OC_REAGENT_SERVERID,OC_REAGENT_OBJECTID,"+
											" OC_REAGENT_CREATEDATETIME,OC_REAGENT_NAME,OC_REAGENT_UNIT,"+
											" OC_REAGENT_PROVIDER,OC_REAGENT_PRODUCTUID,"+
											" OC_REAGENT_UPDATEDATETIME,OC_REAGENT_UPDATEUID,OC_REAGENT_VERSION)"+
											" VALUES(?,?,?,?,?,?,?,?,?,?)");
			ps.setInt(1, Integer.parseInt(this.getUid().split("\\.")[0]));
			ps.setInt(2, Integer.parseInt(this.getUid().split("\\.")[1]));
			ps.setTimestamp(3, this.getCreateDateTime()==null?null:new java.sql.Timestamp(this.getCreateDateTime().getTime()));
			ps.setString(4, this.getName());
			ps.setString(5, this.getUnit());
			ps.setString(6, this.getProvider());
			ps.setString(7, this.getProductUid());
			ps.setTimestamp(8, new java.sql.Timestamp(this.getUpdateDateTime().getTime()));
			ps.setString(9, this.getUpdateUser());
			ps.setInt(10, this.getVersion());
			ps.execute();
			ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
	}
	
	public static Reagent get(String uid){
		Reagent reagent = null;
		Connection conn=null;
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			if(uid!=null && uid.split("\\.").length==2){
				conn=MedwanQuery.getInstance().getOpenclinicConnection();
				ps=conn.prepareStatement("select * from OC_REAGENTS where OC_REAGENT_SERVERID=? and OC_REAGENT_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(uid.split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(uid.split("\\.")[1]));
				rs=ps.executeQuery();
				if(rs.next()){
					reagent = new Reagent();
					reagent.setUid(uid);
					reagent.setCreateDateTime(rs.getTimestamp("OC_REAGENT_CREATEDATETIME"));
					reagent.setName(rs.getString("OC_REAGENT_NAME"));
					reagent.setUnit(rs.getString("OC_REAGENT_UNIT"));
					reagent.setProvider(rs.getString("OC_REAGENT_PROVIDER"));
					reagent.setProductUid(rs.getString("OC_REAGENT_PRODUCTUID"));
					reagent.setUpdateDateTime(rs.getTimestamp("OC_REAGENT_UPDATEDATETIME"));
					reagent.setUpdateUser(rs.getString("OC_REAGENT_UPDATEUID"));
					reagent.setVersion(rs.getInt("OC_REAGENT_VERSION"));
				}
				rs.close();
				ps.close();
				conn.close();
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
		return reagent;
	}	
	
	public static Reagent delete(String uid){
		Reagent reagent = null;
		Connection conn=null;
		PreparedStatement ps=null;
		try{
			if(uid!=null && uid.split("\\.").length==2){
				conn=MedwanQuery.getInstance().getOpenclinicConnection();
				ps=conn.prepareStatement("DELETE from OC_REAGENTS where OC_REAGENT_SERVERID=? and OC_REAGENT_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(uid.split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(uid.split("\\.")[1]));
				ps.execute();
				ps.close();
				conn.close();
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e2){
				e2.printStackTrace();
			}
		}
		return reagent;
	}	
}
