package be.openclinic.medical;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Hashtable;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.common.OC_Object;

public class LabProcedure extends OC_Object{
	String name;
	int minBatchSize;
	int maxBatchSize;
	int maxDelayInDays;
	Vector reagents=new Vector();
	
	public Vector getReagents() {
		return reagents;
	}
	public void setReagents(Vector reagents) {
		this.reagents = reagents;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getMaxBatchSize() {
		return maxBatchSize;
	}
	public void setMaxBatchSize(int maxBatchSize) {
		this.maxBatchSize = maxBatchSize;
	}
	public int getMinBatchSize() {
		return minBatchSize;
	}
	public void setMinBatchSize(int minBatchSize) {
		this.minBatchSize = minBatchSize;
	}
	public int getMaxDelayInDays() {
		return maxDelayInDays;
	}
	public void setMaxDelayInDays(int maxDelayInDays) {
		this.maxDelayInDays = maxDelayInDays;
	}
	
	private void loadReagents(){
		this.reagents=new Vector();
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		ResultSet rs =null;
		try{
			ps=conn.prepareStatement("select * from OC_LABPROCEDUREREAGENTS where OC_LABPROCEDUREREAGENTS_PROCEDUREUID=?");
			ps.setString(1, this.getUid());
			rs=ps.executeQuery();
			while(rs.next()){
				LabProcedureReagent reagent = new LabProcedureReagent();
				reagent.setProcedureuid(this.getUid());
				reagent.setReagentuid(rs.getString("OC_LABPROCEDUREREAGENTS_REAGENTUID"));
				reagent.setQuantity(rs.getDouble("OC_LABPROCEDUREREAGENTS_QUANTITY"));
				reagent.setConsumptionType(rs.getString("OC_LABPROCEDUREREAGENTS_CONSUMPTIONTYPE"));
				this.reagents.add(reagent);
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
	}

	public static Vector searchLabProcedures(String name){
		Vector procedures = new Vector();
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		ResultSet rs =null;
		try{
			ps=conn.prepareStatement("select * from OC_LABPROCEDURES where OC_LABPROCEDURE_NAME like ? order by OC_LABPROCEDURE_NAME");
			ps.setString(1, "%"+name+"%");
			rs=ps.executeQuery();
			while(rs.next()){
				LabProcedure procedure = new LabProcedure();
				procedure.setUid(rs.getString("OC_LABPROCEDURE_SERVERID")+"."+rs.getString("OC_LABPROCEDURE_OBJECTID"));
				procedure.setCreateDateTime(rs.getTimestamp("OC_LABPROCEDURE_CREATEDATETIME"));
				procedure.setMaxBatchSize(rs.getInt("OC_LABPROCEDURE_MAXBATCHSIZE"));
				procedure.setMinBatchSize(rs.getInt("OC_LABPROCEDURE_MINBATCHSIZE"));
				procedure.setMaxDelayInDays(rs.getInt("OC_LABPROCEDURE_MAXDELAYINDAYS"));
				procedure.setUpdateDateTime(rs.getTimestamp("OC_LABPROCEDURE_UPDATEDATETIME"));
				procedure.setUpdateUser(rs.getString("OC_LABPROCEDURE_UPDATEUID"));
				procedure.setVersion(rs.getInt("OC_LABPROCEDURE_VERSION"));
				procedure.setName(rs.getString("OC_LABPROCEDURE_NAME"));
				procedure.loadReagents();
				procedures.add(procedure);
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
		return procedures;
	}
	

	public void store(){
		Connection conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			if(this.getUid()!=null && this.getUid().split("\\.").length==2){
				//The labprocedure already exists. Move it to the history
				ps=conn.prepareStatement(	" insert into OC_LABPROCEDURES_HISTORY(OC_LABPROCEDURE_SERVERID,OC_LABPROCEDURE_OBJECTID,"+
											" OC_LABPROCEDURE_CREATEDATETIME,OC_LABPROCEDURE_MAXBATCHSIZE,OC_LABPROCEDURE_MINBATCHSIZE,"+
											" OC_LABPROCEDURE_MAXDELAYINDAYS,"+
											" OC_LABPROCEDURE_UPDATEDATETIME,OC_LABPROCEDURE_UPDATEUID,OC_LABPROCEDURE_VERSION,OC_LABPROCEDURE_NAME)"+
											" select OC_LABPROCEDURE_SERVERID,OC_LABPROCEDURE_OBJECTID,"+
											" OC_LABPROCEDURE_CREATEDATETIME,OC_LABPROCEDURE_MAXBATCHSIZE,OC_LABPROCEDURE_MINBATCHSIZE,"+
											" OC_LABPROCEDURE_MAXDELAYINDAYS,"+
											" OC_LABPROCEDURE_UPDATEDATETIME,OC_LABPROCEDURE_UPDATEUID,OC_LABPROCEDURE_VERSION,OC_LABPROCEDURE_NAME from OC_LABPROCEDURES"+
											" WHERE OC_LABPROCEDURE_SERVERID=? and OC_LABPROCEDURE_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(this.getUid().split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(this.getUid().split("\\.")[1]));
				ps.execute();
				ps.close();
				//Remove the labprocedure from the actual table
				ps=conn.prepareStatement("DELETE FROM OC_LABPROCEDURES WHERE OC_LABPROCEDURE_SERVERID=? and OC_LABPROCEDURE_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(this.getUid().split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(this.getUid().split("\\.")[1]));
				ps.execute();
				ps.close();
				//Increase the actual version
				this.setVersion(this.getVersion()+1);
			}
			else {
				this.setVersion(1);
				this.setUid(MedwanQuery.getInstance().getConfigInt("serverId")+"."+MedwanQuery.getInstance().getOpenclinicCounter("OC_LABPROCEDURES"));
				this.setCreateDateTime(new java.util.Date());
			}
			this.setUpdateDateTime(new java.util.Date());
			
			//Store the actual labprocedure
			ps=conn.prepareStatement(" insert into OC_LABPROCEDURES(OC_LABPROCEDURE_SERVERID,OC_LABPROCEDURE_OBJECTID,"+
											" OC_LABPROCEDURE_CREATEDATETIME,OC_LABPROCEDURE_MAXBATCHSIZE,OC_LABPROCEDURE_MINBATCHSIZE,"+
											" OC_LABPROCEDURE_MAXDELAYINDAYS,"+
											" OC_LABPROCEDURE_UPDATEDATETIME,OC_LABPROCEDURE_UPDATEUID,OC_LABPROCEDURE_VERSION,OC_LABPROCEDURE_NAME)"+
											" VALUES(?,?,?,?,?,?,?,?,?,?)");
			ps.setInt(1, Integer.parseInt(this.getUid().split("\\.")[0]));
			ps.setInt(2, Integer.parseInt(this.getUid().split("\\.")[1]));
			ps.setTimestamp(3, this.getCreateDateTime()==null?null:new java.sql.Timestamp(this.getCreateDateTime().getTime()));
			ps.setInt(4, this.getMaxBatchSize());
			ps.setInt(5, this.getMinBatchSize());
			ps.setInt(6, this.getMaxDelayInDays());
			ps.setTimestamp(7, new java.sql.Timestamp(this.getUpdateDateTime().getTime()));
			ps.setString(8, this.getUpdateUser());
			ps.setInt(9, this.getVersion());
			ps.setString(10, this.getName());
			ps.execute();
			ps.close();
			
			//Now store the reagents that go with the procedure
			ps=conn.prepareStatement("delete from OC_LABPROCEDUREREAGENTS where OC_LABPROCEDUREREAGENTS_PROCEDUREUID=?");
			ps.setString(1, this.getUid());
			ps.execute();
			ps.close();
			for(int n=0;n<reagents.size();n++){
				LabProcedureReagent reagent = (LabProcedureReagent)reagents.elementAt(n);
				ps=conn.prepareStatement("insert into OC_LABPROCEDUREREAGENTS(OC_LABPROCEDUREREAGENTS_PROCEDUREUID,OC_LABPROCEDUREREAGENTS_REAGENTUID,OC_LABPROCEDUREREAGENTS_QUANTITY,OC_LABPROCEDUREREAGENTS_CONSUMPTIONTYPE) values(?,?,?,?)");
				ps.setString(1, this.getUid());
				ps.setString(2, reagent.getReagentuid());
				ps.setDouble(3, reagent.getQuantity());
				ps.setString(4, reagent.getConsumptionType());
				ps.execute();
				ps.close();
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
	}
	
	public static LabProcedure get(String uid){
		LabProcedure procedure = null;
		Connection conn=null;
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			if(uid!=null && uid.split("\\.").length==2){
				conn=MedwanQuery.getInstance().getOpenclinicConnection();
				ps=conn.prepareStatement("select * from OC_LABPROCEDURES where OC_LABPROCEDURE_SERVERID=? and OC_LABPROCEDURE_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(uid.split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(uid.split("\\.")[1]));
				rs=ps.executeQuery();
				if(rs.next()){
					procedure = new LabProcedure();
					procedure.setUid(uid);
					procedure.setCreateDateTime(rs.getTimestamp("OC_LABPROCEDURE_CREATEDATETIME"));
					procedure.setMaxBatchSize(rs.getInt("OC_LABPROCEDURE_MAXBATCHSIZE"));
					procedure.setMinBatchSize(rs.getInt("OC_LABPROCEDURE_MINBATCHSIZE"));
					procedure.setMaxDelayInDays(rs.getInt("OC_LABPROCEDURE_MAXDELAYINDAYS"));
					procedure.setUpdateDateTime(rs.getTimestamp("OC_LABPROCEDURE_UPDATEDATETIME"));
					procedure.setUpdateUser(rs.getString("OC_LABPROCEDURE_UPDATEUID"));
					procedure.setVersion(rs.getInt("OC_LABPROCEDURE_VERSION"));
					procedure.setName(rs.getString("OC_LABPROCEDURE_NAME"));
					procedure.loadReagents();
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
		return procedure;
	}
	
	public static LabProcedure delete(String uid){
		LabProcedure procedure = null;
		Connection conn=null;
		PreparedStatement ps=null;
		try{
			if(uid!=null && uid.split("\\.").length==2){
				conn=MedwanQuery.getInstance().getOpenclinicConnection();
				ps=conn.prepareStatement("DELETE from OC_LABPROCEDURES where OC_LABPROCEDURE_SERVERID=? and OC_LABPROCEDURE_OBJECTID=?");
				ps.setInt(1, Integer.parseInt(uid.split("\\.")[0]));
				ps.setInt(2, Integer.parseInt(uid.split("\\.")[1]));
				ps.execute();
				ps.close();
				ps=conn.prepareStatement("DELETE from OC_LABPROCEDUREREAGENTS where OC_LABPROCEDUREREAGENTS_PROCEDUREUID=?");
				ps.setString(1, uid);
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
		return procedure;
	}
	
	public static Hashtable calculateReagentConsumption(java.util.Date begin,java.util.Date end){
		Hashtable consumedReagents = new Hashtable();
		Connection conn=null;
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			String sSql="select count(*) totalsamples,updatetime,procedureuid from (" +
					" select distinct b.transactionid,b.updateTime,c.procedureuid " +
					" from requestedlabanalyses a,transactions b,labanalysis c" +
					" where" +
					" a.transactionid=b.transactionid and" +
					" b.updatetime between ? and ? and" +
					" a.analysiscode=c.labcode and" +
					" a.finalvalidationdatetime is not null) a" +
					" group by procedureuid,updateTime" +
					" order by procedureuid,updateTime";
			System.out.println(sSql);
			conn=MedwanQuery.getInstance().getOpenclinicConnection();
			ps=conn.prepareStatement(sSql);
			ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
			rs=ps.executeQuery();
			String activeProcedureUid="";
			double testedsamples=0,remainingsamples=0;
			double consumedquantity=0;
			java.util.Date lastrequestdate=null;
			LabProcedure procedure = null;
			long day = 24*3600*1000;
			while(rs.next()){
				String procedureUid = rs.getString("procedureuid");
				java.util.Date date = rs.getTimestamp("updatetime");
				int totalsamples	= rs.getInt("totalsamples");
				System.out.println("total samples for procedure "+procedureUid+" on "+date+" = "+totalsamples);
				if(procedureUid!=null && procedureUid.length()>0){
					if(!activeProcedureUid.equalsIgnoreCase(procedureUid)){
						if(procedure!=null){
							//We have to save the data for this procedure
							for(int n=0;n<procedure.getReagents().size();n++){
								LabProcedureReagent reagent = (LabProcedureReagent)procedure.getReagents().elementAt(n);
								if(consumedReagents.get(reagent.getReagentuid())==null){
									if(reagent.getConsumptionType().equalsIgnoreCase("sample")){
										consumedReagents.put(reagent.getReagentuid(), (totalsamples-remainingsamples)*reagent.getQuantity());
									}
									else {
										consumedReagents.put(reagent.getReagentuid(), consumedquantity*reagent.getQuantity());
									}
								}
								else {
									if(reagent.getConsumptionType().equalsIgnoreCase("sample")){
										consumedReagents.put(reagent.getReagentuid(), ((Double)consumedReagents.get(reagent.getReagentuid())).doubleValue()+(totalsamples-remainingsamples)*reagent.getQuantity());
									}
									else {
										consumedReagents.put(reagent.getReagentuid(), ((Double)consumedReagents.get(reagent.getReagentuid())).doubleValue()+consumedquantity*reagent.getQuantity());
									}
								}
							}
						}
						activeProcedureUid=procedureUid;
						testedsamples=0;
						remainingsamples=0;
						consumedquantity=0;
						lastrequestdate=date;
						procedure=LabProcedure.get(activeProcedureUid);
					}
					remainingsamples=remainingsamples+totalsamples;
					testedsamples=testedsamples+totalsamples;
					//First we are going to count how many maximum batch sizes can be analyzed
					double q=Math.floor(remainingsamples / procedure.getMaxBatchSize());
					if(q>0){
						System.out.println("adding "+q+" batches of "+procedure.getMaxBatchSize()+" samples to procedure "+procedure.getUid());
						consumedquantity+= q;
						lastrequestdate=date;
						remainingsamples = remainingsamples - q*procedure.getMaxBatchSize();
					}
					//Now we will see if the remainder is bigger than MinBatchSize
					if(remainingsamples>=procedure.getMinBatchSize()){
						System.out.println("adding 1 batch of "+remainingsamples+" samples to procedure "+procedure.getUid());
						consumedquantity++;
						remainingsamples=0;
						lastrequestdate=date;
					}
					if(remainingsamples>0 && (date.getTime()-lastrequestdate.getTime())/day>procedure.getMaxDelayInDays()){
						System.out.println("adding 1 batch of "+remainingsamples+" samples to procedure "+procedure.getUid()+" because delay of "+procedure.getMaxDelayInDays()+" days was exceeded");
						consumedquantity++;
						remainingsamples=0;
						lastrequestdate=date;
					}
					System.out.println("Remaining samples = "+remainingsamples);
				}
			}
			if(procedure!=null){
				//We also have to save the data for the last procedure
				for(int n=0;n<procedure.getReagents().size();n++){
					LabProcedureReagent reagent = (LabProcedureReagent)procedure.getReagents().elementAt(n);
					if(consumedReagents.get(reagent.getReagentuid())==null){
						consumedReagents.put(reagent.getReagentuid(), consumedquantity*reagent.getQuantity());
					}
					else {
						consumedReagents.put(reagent.getReagentuid(), ((Double)consumedReagents.get(reagent.getReagentuid())).doubleValue()+consumedquantity*reagent.getQuantity());
					}
				}
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
		return consumedReagents;
	}
}
