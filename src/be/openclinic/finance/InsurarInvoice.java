package be.openclinic.finance;

import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.common.ObjectReference;

import java.util.Hashtable;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Statement;



public class InsurarInvoice extends Invoice {
    private String insurarUid;
    private Insurar insurar;

    //--- S/GET INSURAR UID -----------------------------------------------------------------------
    public void setInsurarUid(String insurarUid) {
        this.insurarUid = insurarUid;
    }

    public String getInsurarUid() {
        return insurarUid;
    }

    //--- S/GET INSURAR ---------------------------------------------------------------------------
    public void setInsurar(Insurar insurar) {
        this.insurar = insurar;
    }

    public Insurar getInsurar() {
        if(insurar==null){
            if(ScreenHelper.checkString(insurarUid).length()>0){
                insurar=Insurar.get(insurarUid);
            }
        }
        return insurar;
    }

    public double getAmount(){
    	double amount=0;
    	Vector debets = getDebets();
    	if(debets==null){
    		debets=Debet.getFullInsurarDebetsViaInvoiceUid(getUid());
    	}
    	for(int n=0;n<debets.size();n++){
    		Debet debet = (Debet)debets.elementAt(n);
    		if(debet!=null){
    			amount+=debet.getInsurarAmount();
    		}
    	}
    	return amount;
    }
    
    public boolean hasDebetsForService(String serviceuid){
    	return hasDebetsForService(this.getUid(),serviceuid);
    }
    
    public static boolean hasDebetsForService(String invoiceuid,String serviceuid){
    	boolean bHas=false;
    	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	PreparedStatement ps=null;
    	ResultSet rs=null;
        try{
            ps = oc_conn.prepareStatement("select * from OC_DEBETS where OC_DEBET_INSURARINVOICEUID=? and OC_DEBET_SERVICEUID=?");
            ps.setString(1,invoiceuid);
            ps.setString(2,serviceuid);
            rs = ps.executeQuery();
            if(rs.next()){
            	bHas=true;
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return bHas;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static InsurarInvoice get(String uid){
        InsurarInvoice insurarInvoice = new InsurarInvoice();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_INSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        insurarInvoice.setUid(uid);
                        insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                        insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                        insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                        insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                        insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                        insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                        insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                        insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                        insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                    }
                    rs.close();
                    ps.close();

                    insurarInvoice.debets = Debet.getFullInsurarDebetsViaInvoiceUid(insurarInvoice.getUid());
                    insurarInvoice.credits = InsurarCredit.getInsurarCreditsViaInvoiceUID(insurarInvoice.getUid());
                }
                catch(Exception e){
                    Debug.println("OpenClinic => InsurarInvoice.java => get => "+e.getMessage());
                    e.printStackTrace();
                }
                finally{
                    try{
                        if(rs!=null)rs.close();
                        if(ps!=null)ps.close();
                        oc_conn.close();
                    }
                    catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }
        return insurarInvoice;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static InsurarInvoice getWithoutDebetsOrCredits(String uid){
        InsurarInvoice insurarInvoice = new InsurarInvoice();

        if(uid!=null && uid.length()>0){
            String [] ids = uid.split("\\.");

            if (ids.length==2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect = "SELECT * FROM OC_INSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()){
                        insurarInvoice.setUid(uid);
                        insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                        insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                        insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                        insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                        insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                        insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                        insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                        insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                        insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
                    }
                    rs.close();
                    ps.close();

                }
                catch(Exception e){
                    Debug.println("OpenClinic => InsurarInvoice.java => get => "+e.getMessage());
                    e.printStackTrace();
                }
                finally{
                    try{
                        if(rs!=null)rs.close();
                        if(ps!=null)ps.close();
                        oc_conn.close();
                    }
                    catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }
        return insurarInvoice;
    }

    public static InsurarInvoice getViaInvoiceUID(String sInvoiceID){
        InsurarInvoice insurarInvoice = new InsurarInvoice();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "SELECT * FROM OC_INSURARINVOICES WHERE OC_INSURARINVOICE_ID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sInvoiceID));
            rs = ps.executeQuery();

            if(rs.next()){
                insurarInvoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));
            }
            rs.close();
            ps.close();

            insurarInvoice.debets = Debet.getInsurarDebetsViaInvoiceUid(insurarInvoice.getUid());
            insurarInvoice.credits = InsurarCredit.getInsurarCreditsViaInvoiceUID(insurarInvoice.getUid());
        }
        catch(Exception e){
            Debug.println("OpenClinic => InsurarInvoice.java => getViaInvoiceUID => "+e.getMessage());
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return insurarInvoice;
    }

    public boolean store(){
        boolean bStored = true;
        String ids[];
        int iVersion = 1;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");

                if(ids.length == 2){
                    sSelect = "SELECT OC_INSURARINVOICE_VERSION FROM OC_INSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();

                    if(rs.next()) {
                        iVersion = rs.getInt("OC_INSURARINVOICE_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sSelect = "INSERT INTO OC_INSURARINVOICES_HISTORY SELECT * FROM OC_INSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sSelect = " DELETE FROM OC_INSURARINVOICES WHERE OC_INSURARINVOICE_SERVERID = ? AND OC_INSURARINVOICE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
                else{
                    ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+""};
                    this.setUid(ids[0]+"."+ids[1]);
                    this.setInvoiceUid(ids[1]);
                }
            }
            else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_INVOICES")+""};
                this.setUid(ids[0]+"."+ids[1]);
                this.setInvoiceUid(ids[1]);
            }

            if(ids.length == 2){
               sSelect = " INSERT INTO OC_INSURARINVOICES (" +
                          " OC_INSURARINVOICE_SERVERID," +
                          " OC_INSURARINVOICE_OBJECTID," +
                          " OC_INSURARINVOICE_DATE," +
                          " OC_INSURARINVOICE_ID," +
                          " OC_INSURARINVOICE_INSURARUID," +
                          " OC_INSURARINVOICE_CREATETIME," +
                          " OC_INSURARINVOICE_UPDATETIME," +
                          " OC_INSURARINVOICE_UPDATEUID," +
                          " OC_INSURARINVOICE_VERSION," +
                          " OC_INSURARINVOICE_BALANCE," +
                          " OC_INSURARINVOICE_STATUS" +
                        ") " +
                         " VALUES(?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setTimestamp(3,new Timestamp(this.getDate().getTime()));
                ps.setInt(4,Integer.parseInt(this.getInvoiceUid()));
                ps.setString(5,this.getInsurarUid());
                ps.setTimestamp(6,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(7,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(8,this.getUpdateUser());
                ps.setInt(9,iVersion);
                ps.setDouble(10,this.getBalance());
                ps.setString(11,this.getStatus());
                ps.executeUpdate();
                ps.close();

                sSelect = "UPDATE OC_DEBETS SET OC_DEBET_INSURARINVOICEUID = NULL WHERE OC_DEBET_INSURARINVOICEUID = ? ";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getUid());
                ps.executeUpdate();
                ps.close();
                Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                Statement st= loc_conn.createStatement();
                boolean hasqueries=false;
                if (this.debets!=null && !this.status.equalsIgnoreCase("canceled")){
                    String sDebetUID;
                    String[] aDebetUID;
                    String UIDs="";
                    int counter=0;
                    for (int i=0;i<this.debets.size();i++){
                        sDebetUID = ScreenHelper.checkString(((Debet)this.debets.elementAt(i)).getUid());
                        if (sDebetUID.length()>0){
                            aDebetUID = sDebetUID.split("\\.");
                            if (aDebetUID.length==2){
                                hasqueries=true;
                                if(UIDs.length()>0){
                                    UIDs+=",";
                                }
                                UIDs+=aDebetUID[1];
                                counter++;
                            }
                        }
                        if(counter>=250){
                            st.addBatch("UPDATE OC_DEBETS SET OC_DEBET_INSURARINVOICEUID = '"+this.getUid()+"' WHERE OC_DEBET_OBJECTID in ("+UIDs+")");
                            UIDs="";
                            counter=0;
                        }
                    }
                    if(counter>0){
                        st.addBatch("UPDATE OC_DEBETS SET OC_DEBET_INSURARINVOICEUID = '"+this.getUid()+"' WHERE OC_DEBET_OBJECTID in ("+UIDs+")");
                    }
                }
                if(hasqueries){
                    st.executeBatch();
                }
                st.close();
                loc_conn.close();

                sSelect = "UPDATE OC_INSURARCREDITS SET OC_INSURARCREDIT_INVOICEUID = NULL WHERE OC_INSURARCREDIT_INVOICEUID = ?";
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getUid());
                ps.executeUpdate();
                ps.close();

                if (this.credits!=null && !this.status.equalsIgnoreCase("canceled")){
                    String sCreditUID;
                    String[] aCreditUID;

                    for (int i=0;i<this.credits.size();i++){
                        sCreditUID = ScreenHelper.checkString((String)this.credits.elementAt(i));

                        if (sCreditUID.length()>0){
                            aCreditUID = sCreditUID.split("\\.");

                            if (aCreditUID.length==2){
                                sSelect = "UPDATE OC_INSURARCREDITS SET OC_INSURARCREDIT_INVOICEUID = ? WHERE OC_INSURARCREDIT_SERVERID = ? AND OC_INSURARCREDIT_OBJECTID = ? ";
                                ps = oc_conn.prepareStatement(sSelect);
                                ps.setString(1,this.getUid());
                                ps.setInt(2,Integer.parseInt(aCreditUID[0]));
                                ps.setInt(3,Integer.parseInt(aCreditUID[1]));
                                ps.executeUpdate();
                                ps.close();
                            }
                        }
                    }
                }
            }
            updateBalance();
        }
        catch(Exception e){
            e.printStackTrace();
            bStored = false;
            Debug.println("OpenClinic => InsurarInvoice.java => store => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return bStored;
    }
    
    public static double getDebetAmount(String insurarInvoiceUid){
    	double total=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sql = 	" select sum(oc_debet_insuraramount) total from oc_debets where oc_debet_insurarinvoiceuid=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sql);
    		ps.setString(1,insurarInvoiceUid);
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			total = rs.getDouble("total");
    		}
    		else {
                rs.close();
                ps.close();
    		}
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return total;
    }

    public static double getCreditAmount(String insurarInvoiceUid){
    	double total=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sql = 	"select sum(oc_insurarcredit_amount) total from oc_insurarcredits where oc_insurarcredit_invoiceuid=?";
    		PreparedStatement ps = oc_conn.prepareStatement(sql);
    		ps.setString(1,insurarInvoiceUid);
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			total = rs.getDouble("total");
    		}
    		else {
                rs.close();
                ps.close();
    		}
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return total;
    }

   public void updateBalance(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sql = 	" select sum(total) total from ("+
							" select sum(oc_debet_insuraramount) total from oc_debets where oc_debet_insurarinvoiceuid=?"+
							" union"+ 
							" select -sum(oc_insurarcredit_amount) total from oc_insurarcredits where oc_insurarcredit_invoiceuid=?"+
							" ) a";
    		PreparedStatement ps = oc_conn.prepareStatement(sql);
    		ps.setString(1, getUid());
    		ps.setString(2,getUid());
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			double total = rs.getDouble("total");
    			sql = "update OC_INSURARINVOICES set OC_INSURARINVOICE_BALANCE=? where OC_INSURARINVOICE_SERVERID=? and OC_INSURARINVOICE_OBJECTID=?";
    			rs.close();
    			ps.close();
    			ps= oc_conn.prepareStatement(sql);
    			ps.setDouble(1, total);
    			ps.setInt(2, Integer.parseInt(getUid().split("\\.")[0]));
    			ps.setInt(3, Integer.parseInt(getUid().split("\\.")[1]));
    			ps.executeUpdate();
    			ps.close();
    			setBalance(total);
    		}
    		else {
                rs.close();
                ps.close();
    		}
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    	try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    //--- SEARCH INVOICES -------------------------------------------------------------------------
    public static Vector searchInvoices(String sInvoiceDate, String sInvoiceNr, String sInvoicePatientUid, String sInvoiceStatus){
        return searchInvoices(sInvoiceDate,sInvoiceNr,sInvoicePatientUid,sInvoiceStatus,"","");
    }

    public static Vector searchInvoices(String sInvoiceDate, String sInvoiceNr, String sInvoiceInsurarUid,
                                        String sInvoiceStatus, String sAmountMin, String sAmountMax){
        Vector invoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT OC_INSURARINVOICE_SERVERID,OC_INSURARINVOICE_OBJECTID,OC_INSURARINVOICE_ID,OC_INSURARINVOICE_DATE,OC_INSURARINVOICE_INSURARUID,OC_INSURARINVOICE_CREATETIME,OC_INSURARINVOICE_UPDATETIME," +
                    "OC_INSURARINVOICE_UPDATEUID,OC_INSURARINVOICE_VERSION,OC_INSURARINVOICE_STATUS,OC_INSURARINVOICE_BALANCE FROM OC_INSURARINVOICES WHERE ";
            if(sInvoiceDate.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE = ? AND";
            }
            if(sInvoiceNr.length() > 0){
                sSql+= " OC_INSURARINVOICE_OBJECTID = ? AND";
            }
            if(sInvoiceInsurarUid.length() > 0){
                sSql+= " OC_INSURARINVOICE_INSURARUID = ? AND";
            }
            if(sInvoiceStatus.length() > 0){
                sSql+= " OC_INSURARINVOICE_STATUS = ? AND";
            }

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                sSql+= " OC_INSURARINVOICE_BALANCE BETWEEN ? AND ?";
            }
            else if (sAmountMin.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE >= ?";
            }
            else if (sAmountMax.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE <= ?";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql += " UNION SELECT OC_INSURARINVOICE_SERVERID,OC_INSURARINVOICE_OBJECTID,OC_INSURARINVOICE_ID,OC_INSURARINVOICE_DATE,OC_INSURARINVOICE_INSURARUID,OC_INSURARINVOICE_CREATETIME,OC_INSURARINVOICE_UPDATETIME," +
                    " OC_INSURARINVOICE_UPDATEUID,OC_INSURARINVOICE_VERSION,OC_INSURARINVOICE_STATUS,OC_INSURARINVOICE_BALANCE FROM OC_EXTRAINSURARINVOICES WHERE ";
            if(sInvoiceDate.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE = ? AND";
            }
            if(sInvoiceNr.length() > 0){
                sSql+= " OC_INSURARINVOICE_OBJECTID = ? AND";
            }
            if(sInvoiceInsurarUid.length() > 0){
                sSql+= " OC_INSURARINVOICE_INSURARUID = ? AND";
            }
            if(sInvoiceStatus.length() > 0){
                sSql+= " OC_INSURARINVOICE_STATUS = ? AND";
            }

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                sSql+= " OC_INSURARINVOICE_BALANCE BETWEEN ? AND ?";
            }
            else if (sAmountMin.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE >= ?";
            }
            else if (sAmountMax.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE <= ?";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY OC_INSURARINVOICE_DATE DESC";

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            if(sInvoiceNr.length() > 0) ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            if(sInvoiceDate.length() > 0) ps.setDate(qmIdx++,new java.sql.Date(stdDateFormat.parse(sInvoiceDate).getTime()));
            if(sInvoiceInsurarUid.length() > 0) ps.setString(qmIdx++,sInvoiceInsurarUid);
            if(sInvoiceStatus.length() > 0) ps.setString(qmIdx++,sInvoiceStatus);

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMin));
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMax));
            }
            else if (sAmountMin.length() > 0){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMin));
            }
            else if (sAmountMax.length() > 0){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMax));
            }

            if(sInvoiceNr.length() > 0) ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            if(sInvoiceDate.length() > 0) ps.setDate(qmIdx++,new java.sql.Date(stdDateFormat.parse(sInvoiceDate).getTime()));
            if(sInvoiceInsurarUid.length() > 0) ps.setString(qmIdx++,sInvoiceInsurarUid);
            if(sInvoiceStatus.length() > 0) ps.setString(qmIdx++,sInvoiceStatus);

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMin));
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }
            else if (sAmountMin.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMin));
            }
            else if (sAmountMax.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }

            rs = ps.executeQuery();

            InsurarInvoice invoice;
            while(rs.next()){
                invoice = new InsurarInvoice();

                invoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                invoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                invoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                invoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                invoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                invoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                invoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                invoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                invoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                invoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));

                invoices.add(invoice);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return invoices;
    }

    public static Vector searchInvoices(String sInvoiceDateBegin, String sInvoiceDateEnd, String sInvoiceNr, String sAmountMin, String sAmountMax){
        Vector invoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSql = "SELECT * FROM OC_INSURARINVOICES WHERE ";
            if(sInvoiceDateBegin.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE >= ? AND";
            }

            if(sInvoiceDateEnd.length() > 0){
                sSql+= " OC_INSURARINVOICE_DATE <= ? AND";
            }

            if(sInvoiceNr.length() > 0){
                sSql+= " OC_INSURARINVOICE_OBJECTID = ? AND";
            }

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                sSql+= " OC_INSURARINVOICE_BALANCE BETWEEN ? AND ? AND";
            }
            else if (sAmountMin.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE >= ? AND";
            }
            else if (sAmountMax.length() > 0){
                sSql+= " OC_INSURARINVOICE_BALANCE <= ? AND";
            }

            // remove last AND
            if(sSql.endsWith("AND")){
                sSql = sSql.substring(0,sSql.length()-3);
            }

            sSql+= " ORDER BY OC_INSURARINVOICE_DATE DESC";

            ps = oc_conn.prepareStatement(sSql);

            // set question marks
            int qmIdx = 1;
            if(sInvoiceNr.length() > 0) ps.setInt(qmIdx++,Integer.parseInt(sInvoiceNr));
            if(sInvoiceDateBegin.length() > 0) ps.setDate(qmIdx++,ScreenHelper.getSQLDate(sInvoiceDateBegin));
            if(sInvoiceDateEnd.length() > 0) ps.setDate(qmIdx++,ScreenHelper.getSQLDate(sInvoiceDateEnd));

            if ((sAmountMin.length() > 0)&&(sAmountMax.length()>0)){
                ps.setDouble(qmIdx++,Double.parseDouble(sAmountMin));
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }
            else if (sAmountMin.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMin));
            }
            else if (sAmountMax.length() > 0){
                ps.setDouble(qmIdx,Double.parseDouble(sAmountMax));
            }

            rs = ps.executeQuery();

            InsurarInvoice invoice;
            while(rs.next()){
                invoice = new InsurarInvoice();

                invoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                invoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                invoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                invoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                invoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                invoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                invoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                invoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                invoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                invoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));

                invoices.add(invoice);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return invoices;
    }

    public static Vector getInsurarInvoicesWhereDifferentStatus(String sStatus){
        Vector vInsurarInvoices = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT * FROM OC_INSURARINVOICES WHERE  OC_INSURARINVOICE_STATUS not in ("+sStatus+")";
            ps = oc_conn.prepareStatement(sSelect);

            rs = ps.executeQuery();
            InsurarInvoice insurarInvoice;
            while(rs.next()){
                insurarInvoice = new InsurarInvoice();

                insurarInvoice.setUid(rs.getInt("OC_INSURARINVOICE_SERVERID")+"."+rs.getInt("OC_INSURARINVOICE_OBJECTID"));
                insurarInvoice.setDate(rs.getTimestamp("OC_INSURARINVOICE_DATE"));
                insurarInvoice.setInvoiceUid(rs.getInt("OC_INSURARINVOICE_ID")+"");
                insurarInvoice.setInsurarUid(rs.getString("OC_INSURARINVOICE_INSURARUID"));
                insurarInvoice.setCreateDateTime(rs.getTimestamp("OC_INSURARINVOICE_CREATETIME"));
                insurarInvoice.setUpdateDateTime(rs.getTimestamp("OC_INSURARINVOICE_UPDATETIME"));
                insurarInvoice.setUpdateUser(rs.getString("OC_INSURARINVOICE_UPDATEUID"));
                insurarInvoice.setVersion(rs.getInt("OC_INSURARINVOICE_VERSION"));
                insurarInvoice.setBalance(rs.getDouble("OC_INSURARINVOICE_BALANCE"));
                insurarInvoice.setStatus(rs.getString("OC_INSURARINVOICE_STATUS"));

                vInsurarInvoices.add(insurarInvoice);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return vInsurarInvoices;
    }

    //--- GET DEBETS FOR INVOICE ------------------------------------------------------------------
    public static Vector getDebetsForInvoice(String sInvoiceUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector debets = new Vector();
        String sSelect = "";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT a.lastname, a.firstname, d.*,e.* ,c.* "+
                      " FROM OC_DEBETS d, OC_INSURARINVOICES i, OC_ENCOUNTERS e, AdminView a, OC_PRESTATIONS c"+
                      "  WHERE d.OC_DEBET_INSURARINVOICEUID = ?"+
                      "   AND i.OC_INSURARINVOICE_OBJECTID = replace(d.OC_DEBET_INSURARINVOICEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND e.OC_ENCOUNTER_OBJECTID = replace(d.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND c.OC_PRESTATION_OBJECTID = replace(d.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND e.OC_ENCOUNTER_PATIENTUID = a.personid"+
                      " ORDER BY lastname, firstname, OC_DEBET_DATE DESC";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);

            rs = ps.executeQuery();
            Debet debet;
            while(rs.next()){
                debet = new Debet();

                debet.setUid(rs.getInt("OC_DEBET_SERVERID")+"."+rs.getInt("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.setInsuranceUid(rs.getString("OC_DEBET_INSURANCEUID"));
                debet.setPrestationUid(rs.getString("OC_DEBET_PRESTATIONUID"));
                debet.setEncounterUid(rs.getString("OC_DEBET_ENCOUNTERUID"));
                debet.setSupplierUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                debet.setPatientInvoiceUid(rs.getString("OC_DEBET_PATIENTINVOICEUID"));
                debet.setInsurarInvoiceUid(rs.getString("OC_DEBET_INSURARINVOICEUID"));
                debet.setComment(rs.getString("OC_DEBET_COMMENT"));
                debet.setCredited(rs.getInt("OC_DEBET_CREDITED"));
                debet.setQuantity(rs.getInt("OC_DEBET_QUANTITY"));
                debet.setServiceUid(rs.getString("OC_DEBET_SERVICEUID"));
                debet.setPatientName(rs.getString("lastname")+", "+rs.getString("firstname"));

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));

                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));

                //Now find the most recent service for this encounter
                Encounter.EncounterService encounterService = encounter.getLastEncounterService();
                if (encounterService != null) {
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));

                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);

                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);


                debets.add(debet);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return debets;
    }

    //--- GET DEBETS FOR INVOICE ------------------------------------------------------------------
    public static Vector getDebetsForInvoiceSortByDate(String sInvoiceUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector debets = new Vector();
        String sSelect = "";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sSelect = "SELECT a.lastname, a.firstname, d.*,e.*,c.*"+
                      " FROM OC_DEBETS d, OC_INSURARINVOICES i, OC_ENCOUNTERS e, AdminView a, OC_PRESTATIONS c"+
                      "  WHERE d.OC_DEBET_INSURARINVOICEUID = ?"+
                      "   AND i.OC_INSURARINVOICE_OBJECTID = replace(d.OC_DEBET_INSURARINVOICEUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND e.OC_ENCOUNTER_OBJECTID = replace(d.OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND c.OC_PRESTATION_OBJECTID = replace(d.OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                      "   AND e.OC_ENCOUNTER_PATIENTUID = a.personid"+
                      " ORDER BY OC_DEBET_DATE,lastname,firstname,OC_DEBET_PATIENTINVOICEUID";
            ps = loc_conn.prepareStatement(sSelect);
            ps.setString(1,sInvoiceUid);

            rs = ps.executeQuery();
            Debet debet;
            while(rs.next()){
                debet = new Debet();

                debet.setUid(rs.getInt("OC_DEBET_SERVERID")+"."+rs.getInt("OC_DEBET_OBJECTID"));
                debet.setDate(rs.getTimestamp("OC_DEBET_DATE"));
                debet.setAmount(rs.getDouble("OC_DEBET_AMOUNT"));
                debet.setInsurarAmount(rs.getDouble("OC_DEBET_INSURARAMOUNT"));
                debet.setInsuranceUid(rs.getString("OC_DEBET_INSURANCEUID"));
                debet.setExtraInsurarAmount(rs.getDouble("OC_DEBET_EXTRAINSURARAMOUNT"));
                debet.setExtraInsurarUid(rs.getString("OC_DEBET_EXTRAINSURARUID"));
                debet.setPrestationUid(rs.getString("OC_DEBET_PRESTATIONUID"));
                debet.setEncounterUid(rs.getString("OC_DEBET_ENCOUNTERUID"));
                debet.setSupplierUid(rs.getString("OC_DEBET_SUPPLIERUID"));
                debet.setPatientInvoiceUid(rs.getString("OC_DEBET_PATIENTINVOICEUID"));
                debet.setInsurarInvoiceUid(rs.getString("OC_DEBET_INSURARINVOICEUID"));
                debet.setComment(rs.getString("OC_DEBET_COMMENT"));
                debet.setCredited(rs.getInt("OC_DEBET_CREDITED"));
                debet.setQuantity(rs.getInt("OC_DEBET_QUANTITY"));
                debet.setServiceUid(rs.getString("OC_DEBET_SERVICEUID"));
                debet.setPatientName(rs.getString("lastname")+", "+rs.getString("firstname"));

                //*********************
                //add Encounter object
                //*********************
                Encounter encounter = new Encounter();
                encounter.setPatientUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_PATIENTUID")));
                encounter.setDestinationUID(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_DESTINATIONUID")));

                encounter.setUid(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OBJECTID")));
                encounter.setCreateDateTime(rs.getTimestamp("OC_ENCOUNTER_CREATETIME"));
                encounter.setUpdateDateTime(rs.getTimestamp("OC_ENCOUNTER_UPDATETIME"));
                encounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_UPDATEUID")));
                encounter.setVersion(rs.getInt("OC_ENCOUNTER_VERSION"));
                encounter.setBegin(rs.getTimestamp("OC_ENCOUNTER_BEGINDATE"));
                encounter.setEnd(rs.getTimestamp("OC_ENCOUNTER_ENDDATE"));
                encounter.setType(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_TYPE")));
                encounter.setOutcome(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_OUTCOME")));
                encounter.setOrigin(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_ORIGIN")));
                encounter.setSituation(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_SITUATION")));
                encounter.setCategories(ScreenHelper.checkString(rs.getString("OC_ENCOUNTER_CATEGORIES")));

                //Now find the most recent service for this encounter
                Encounter.EncounterService encounterService = encounter.getLastEncounterService();
                if (encounterService != null) {
                    encounter.setServiceUID(encounterService.serviceUID);
                    encounter.setManagerUID(encounterService.managerUID);
                    encounter.setBedUID(encounterService.bedUID);
                }
                debet.setEncounter(encounter);

                //*********************
                //add Prestation object
                //*********************
                Prestation prestation = new Prestation();
                prestation.setUid(rs.getString("OC_PRESTATION_SERVERID") + "." + rs.getString("OC_PRESTATION_OBJECTID"));
                prestation.setCode(rs.getString("OC_PRESTATION_CODE"));
                prestation.setDescription(rs.getString("OC_PRESTATION_DESCRIPTION"));
                prestation.setPrice(rs.getDouble("OC_PRESTATION_PRICE"));
                prestation.setCategories(rs.getString("OC_PRESTATION_CATEGORIES"));

                ObjectReference or = new ObjectReference();
                or.setObjectType(rs.getString("OC_PRESTATION_REFTYPE"));
                or.setObjectUid(rs.getString("OC_PRESTATION_REFUID"));
                prestation.setReferenceObject(or);

                prestation.setCreateDateTime(rs.getTimestamp("OC_PRESTATION_CREATETIME"));
                prestation.setUpdateDateTime(rs.getTimestamp("OC_PRESTATION_UPDATETIME"));
                prestation.setUpdateUser(rs.getString("OC_PRESTATION_UPDATEUID"));
                prestation.setVersion(rs.getInt("OC_PRESTATION_VERSION"));
                prestation.setType(rs.getString("OC_PRESTATION_TYPE"));
                debet.setPrestation(prestation);


                debets.add(debet);
            }
        }
        catch(Exception e){
            e.printStackTrace();
            Debug.println("OpenClinic => InsurarInvoice.java => getInsurarInvoicesWhereDifferentStatus => "+e.getMessage()+" = "+sSelect);
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                loc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return debets;
    }
    
    //--- GET DEBETS FOR INVOICE ------------------------------------------------------------------
    public static SortedMap getDebetsForInvoiceSortByService(String sInvoiceUid){
    	Vector debs = getDebetsForInvoiceSortByDate(sInvoiceUid);
    	SortedMap debets = new TreeMap();
    	String service;
    	for(int n=0;n<debs.size();n++){
    		Debet debet = (Debet)debs.elementAt(n);
    		service = debet.getEncounter().getServiceUID(debet.getDate());
    		if(service==null || service.length()==0){
    			service =debet.getEncounter().getServiceUID(debet.getEncounter().getBegin());
    		}
    		if(service==null || service.length()==0){
    			service="?";
    		}
    		//Nu kijken of de service al bestaat
    		Vector vService = (Vector)debets.get(service);
    		if(vService==null){
    			vService= new Vector();
    			debets.put(service, vService);
    		}
    		//nu het debet aan de vector toevoegen
    		vService.add(debet);
    	}
        return debets;
    }

    public static boolean setStatusOpen(String sInvoiceID,String UserId){

        PreparedStatement ps = null;
        ResultSet rs = null;
        boolean okQuery = false;
        String sSelect = "update OC_INSURARINVOICES SET OC_INSURARINVOICE_STATUS ='open',OC_INSURARINVOICE_UPDATETIME=?,OC_INSURARINVOICE_UPDATEUID=? WHERE OC_INSURARINVOICE_OBJECTID = ? ";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime())); // now
            ps.setString(2,UserId);
            ps.setInt(3,Integer.parseInt(sInvoiceID));

            okQuery = (ps.executeUpdate()>0);

            rs.close();
            ps.close();
      }
        catch(Exception e){
            Debug.println("OpenClinic => InsurarInvoice.java => setStatusOpen => "+e.getMessage());
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
        return okQuery;
    }
}
