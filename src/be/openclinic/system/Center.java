package be.openclinic.system;
import be.openclinic.common.OC_Object;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.*;
import java.util.List;
import java.util.LinkedList;

public class Center extends OC_Object {
    private String name;
    private String province;
    private String district;
    private String zone;
    private String sector;
    private String fosa;
    private String cell;
    private String contactName;
    private String contactFunction;
    private String remEpidemiology;
    private String remDrugs;
    private String remVaccinations;
    private String remEquipment;
    private String remBuilding;
    private String remTransport;
    private String remPersonnel;
    private String remOther;
    
    private int populationTotal;
    private float populationLt1m;
    private float populationLt1y;
    private float populationLt5y;
    private float populationLt25y;
    private float populationLt50y;
    private float populationMt50y;
    private float populationPreg;
    private float populationMut;
    private String NumeroUid;
    private int beds;
    private int active;
    
    private boolean actual;
    
    
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getProvince() {
        return province;
    }
    public void setProvince(String province) {
        this.province = province;
    }
    public String getDistrict() {
        return district;
    }
    public void setDistrict(String district) {
        this.district = district;
    }
    public String getZone() {
        return zone;
    }
    public void setZone(String zone) {
        this.zone = zone;
    }
    public String getSector() {
        return sector;
    }
    public void setSector(String sector) {
        this.sector = sector;
    }
    public String getFosa() {
        return fosa;
    }
    public void setFosa(String fosa) {
        this.fosa = fosa;
    }
    public String getCell() {
        return cell;
    }
    public void setCell(String cell) {
        this.cell = cell;
    }
    public String getContactName() {
        return contactName;
    }
    public void setContactName(String contactName) {
        this.contactName = contactName;
    }
    public String getContactFunction() {
        return contactFunction;
    }
    public void setContactFunction(String contactFunction) {
        this.contactFunction = contactFunction;
    }
    public String getRemEpidemiology() {
        return remEpidemiology;
    }
    public void setRemEpidemiology(String remEpidemiology) {
        this.remEpidemiology = remEpidemiology;
    }
    public String getRemDrugs() {
        return remDrugs;
    }
    public void setRemDrugs(String remDrugs) {
        this.remDrugs = remDrugs;
    }
    public String getRemVaccinations() {
        return remVaccinations;
    }
    public void setRemVaccinations(String remVaccinations) {
        this.remVaccinations = remVaccinations;
    }
    public String getRemEquipment() {
        return remEquipment;
    }
    public void setRemEquipment(String remEquipment) {
        this.remEquipment = remEquipment;
    }
    public String getRemBuilding() {
        return remBuilding;
    }
    public void setRemBuilding(String remBuilding) {
        this.remBuilding = remBuilding;
    }
    public String getRemTransport() {
        return remTransport;
    }
    public void setRemTransport(String remTransport) {
        this.remTransport = remTransport;
    }
    public String getRemPersonnel() {
        return remPersonnel;
    }
    public void setRemPersonnel(String remPersonnel) {
        this.remPersonnel = remPersonnel;
    }
    public String getRemOther() {
        return remOther;
    }
    public void setRemOther(String remOther) {
        this.remOther = remOther;
    }
    public int getPopulationTotal() {
        return populationTotal;
    }
    public void setPopulationTotal(int populationTotal) {
        this.populationTotal = populationTotal;
    }
    public int getBeds() {
        return beds;
    }
    public void setBeds(int beds) {
        this.beds = beds;
    }
    public int getActive() {
        return active;
    }
    public void setActive(int active) {
        this.active = active;
    }
    public float getPopulationLt1m() {
        return populationLt1m;
    }
    public void setPopulationLt1m(float populationLt1m) {
        this.populationLt1m = populationLt1m;
    }
    public float getPopulationLt1y() {
        return populationLt1y;
    }
    public void setPopulationLt1y(float populationLt1y) {
        this.populationLt1y = populationLt1y;
    }
    public float getPopulationLt5y() {
        return populationLt5y;
    }
    public void setPopulationLt5y(float populationLt5y) {
        this.populationLt5y = populationLt5y;
    }
    public float getPopulationLt25y() {
        return populationLt25y;
    }
    public void setPopulationLt25y(float populationLt25y) {
        this.populationLt25y = populationLt25y;
    }
    public float getPopulationLt50y() {
        return populationLt50y;
    }
    public void setPopulationLt50y(float populationLt50y) {
        this.populationLt50y = populationLt50y;
    }
    public float getPopulationMt50y() {
        return populationMt50y;
    }
    public void setPopulationMt50y(float populationMt50y) {
        this.populationMt50y = populationMt50y;
    }
    public float getPopulationPreg() {
        return populationPreg;
    }
    public void setPopulationPreg(float populationPreg) {
        this.populationPreg = populationPreg;
    }
    public float getPopulationMut() {
        return populationMut;
    }
    public void setPopulationMut(float populationMut) {
        this.populationMut = populationMut;
    }
    public String getNumeroUid() {
        return NumeroUid;
    }
    public void setNumeroUid(String numeroUid) {
        NumeroUid = numeroUid;
    }
    public boolean isActual() {
        return actual;
    }
    public void setActual(boolean actual) {
        this.actual = actual;
    }
    
    //--- STORE -----------------------------------------------------------------------------------
    public void store() {
        PreparedStatement ps;
        ResultSet rs;
        String sInsert, sSelect, sDelete;
        int iVersion = 1;
        String[] ids;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            if ((this.getUid() != null) && (this.getUid().length() > 0)) {
                ids = this.getUid().split("\\.");
                if (ids.length == 2) {
                    sSelect = "SELECT * FROM OC_HC WHERE OC_HC_SERVERID = ? AND OC_HC_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        iVersion = rs.getInt("OC_HC_VERSION") + 1;
                        this.setCreateDateTime(rs.getDate("OC_HC_CREATETIME"));
                    }
                    rs.close();
                    ps.close();
                    sInsert = " INSERT INTO OC_HC_HISTORY " +
                            " SELECT * FROM OC_HC where OC_HC_SERVERID = ? AND OC_HC_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                    sDelete = "DELETE FROM OC_HC WHERE OC_HC_SERVERID = ? AND OC_HC_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1, Integer.parseInt(ids[0]));
                    ps.setInt(2, Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            } else {
                ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), 1 + ""};
                this.setUid(ids[0] + "." + ids[1]);
            }
            if (ids.length == 2) {
                sInsert = " INSERT INTO OC_HC (" +
                        " OC_HC_SERVERID," + //1
                        " OC_HC_OBJECTID," +//2
                        " OC_HC_CREATETIME," +//3
                        " OC_HC_UPDATETIME," +//4
                        " OC_HC_UPDATEUID," +//5
                        " OC_HC_VERSION," +//6
                        " OC_HC_NAME," +//7
                        " OC_HC_UID," + //8
                        " OC_HC_PROVINCE," +//9
                        " OC_HC_DISTRICT," +//10
                        " OC_HC_ZONE," +//11
                        " OC_HC_SECTOR," + //12
                        " OC_HC_FOSA," +//13
                        " OC_HC_CELL," +//14
                        " OC_HC_CONTACTNAME," +//15
                        " OC_HC_CONTACTFUNCTION," +//16
                        " OC_HC_REM_EPIDEMIOLOGY," +//17
                        " OC_HC_REM_DRUGS," +//18
                        " OC_HC_REM_VACCINATIONS," +//19
                        " OC_HC_REM_EQUIPMENT," +//20
                        " OC_HC_REM_BUILDING," +//21
                        " OC_HC_REM_TRANSPORT," + //22
                        " OC_HC_REM_PERSONNEL," +//23
                        " OC_HC_REM_OTHER," +//24
                        " OC_HC_POPULATION_TOTAL," + //25
                        " OC_HC_POPULATION_LT1M," + //26
                        " OC_HC_POPULATION_LT1Y," +//27
                        " OC_HC_POPULATION_LT5Y," +//28
                        " OC_HC_POPULATION_LT25Y," +//29
                        " OC_HC_POPULATION_LT50Y," +//30
                        " OC_HC_POPULATION_MT50Y," +//31
                        " OC_HC_POPULATION_PREG," +//32
                        " OC_HC_POPULATION_MUT," +//33
                        " OC_HC_BEDS," +   //34
                        " OC_HC_ACTIVE" + //35
                        ") " +
                        " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1, Integer.parseInt(ids[0]));
                ps.setInt(2, Integer.parseInt(ids[1]));
                ps.setTimestamp(3, new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(4, new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(5, this.getUpdateUser());
                ps.setInt(6, iVersion);
                ps.setString(7, this.getName());
                ps.setString(8, this.getNumeroUid());
                ps.setString(9, this.getProvince());
                ps.setString(10, this.getDistrict());
                ps.setString(11, this.getZone());
                ps.setString(12, this.getSector());
                ps.setString(13, this.getFosa());
                ps.setString(14, this.getCell());
                ps.setString(15, this.getContactName());
                ps.setString(16, this.getContactFunction());
                ps.setString(17, this.getRemEpidemiology());
                ps.setString(18, this.getRemDrugs());
                ps.setString(19, this.getRemVaccinations());
                ps.setString(20, this.getRemEquipment());
                ps.setString(21, this.getRemBuilding());
                ps.setString(22, this.getRemTransport());
                ps.setString(23, this.getRemPersonnel());
                ps.setString(24, this.getRemOther());
                ps.setInt(25, this.getPopulationTotal());
                ps.setFloat(26, this.getPopulationLt1m());
                ps.setFloat(27, this.getPopulationLt1y());
                ps.setFloat(28, this.getPopulationLt5y());
                ps.setFloat(29, this.getPopulationLt25y());
                ps.setFloat(30, this.getPopulationLt50y());
                ps.setFloat(31, this.getPopulationMt50y());
                ps.setFloat(32, this.getPopulationPreg());
                ps.setFloat(33, this.getPopulationMut());
                ps.setInt(34, this.getBeds());
                ps.setInt(35, this.getActive());
                ps.executeUpdate();
                ps.close();
            }
        } catch (Exception e) {
            Debug.println("OpenClinic => Center.java => store => " + e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
    }
    
    //--- GET ALL ---------------------------------------------------------------------------------
    public static List getAll(String begin, String end, boolean actual) {
        List l = new LinkedList();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ResultSet rs;
            String sSelect = "";
            if (!actual) {
                sSelect = "SELECT * FROM OC_HC_HISTORY WHERE OC_HC_SERVERID = ? ";
            } else {
                sSelect = "SELECT * FROM OC_HC WHERE OC_HC_SERVERID = ? ";
            }
            if (begin.length() > 0) {
                sSelect += "AND OC_HC_UPDATETIME >= ? ";
            } else if (end.length() > 0) {
                sSelect += "AND OC_HC_UPDATETIME <= ? ";
            }
            sSelect += "ORDER BY OC_HC_VERSION DESC";
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1, MedwanQuery.getInstance().getConfigString("serverId"));
            if (begin.length() > 0) {
                ps.setDate(2, ScreenHelper.getSQLDate(begin));
            } else if (end.length() > 0) {
                ps.setDate(3, ScreenHelper.getSQLDate(end));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Center center = new Center();
                center.setUid(rs.getInt("OC_HC_SERVERID") + "." + rs.getInt("OC_HC_OBJECTID"));
                center.setCreateDateTime(rs.getTimestamp("OC_HC_CREATETIME"));
                center.setUpdateDateTime(rs.getTimestamp("OC_HC_UPDATETIME"));
                center.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_HC_UPDATEUID")));
                center.setVersion(rs.getInt("OC_HC_VERSION"));
                if (actual) {
                    center.setActual(true);
                }
                l.add(center);
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            Debug.println("OpenClinic => Center.java => getAll => " + e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
        return l;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static Center get(int version, boolean actual) {
        Center center = null;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        
        try {
            String[] ids = new String[]{MedwanQuery.getInstance().getConfigString("serverId"), 1 + ""};
            String sSelect = "";
            if (actual) {
                sSelect = "SELECT * FROM OC_HC WHERE OC_HC_SERVERID = ? AND OC_HC_OBJECTID = ? ";
            }
            else {
                sSelect = "SELECT * FROM OC_HC_HISTORY WHERE OC_HC_SERVERID = ? AND OC_HC_OBJECTID = ? ";
            }
            if (version > 0) {
                sSelect += " AND OC_HC_VERSION = ?";
            }
            
            PreparedStatement ps;
            ResultSet rs;
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1, Integer.parseInt(ids[0]));
            ps.setInt(2, Integer.parseInt(ids[1]));
            if (version > 0) {
                ps.setInt(3, version);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                center = new Center();
                center.setUid(ids[0] + "." + ids[1]);
                center.setCreateDateTime(rs.getTimestamp("OC_HC_CREATETIME"));
                center.setUpdateDateTime(rs.getTimestamp("OC_HC_UPDATETIME"));
                center.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_HC_UPDATEUID")));
                center.setVersion(rs.getInt("OC_HC_VERSION"));
                center.setName(ScreenHelper.checkString(rs.getString("OC_HC_NAME")));
                center.setNumeroUid(ScreenHelper.checkString(rs.getString("OC_HC_UID")));
                center.setProvince(ScreenHelper.checkString(rs.getString("OC_HC_PROVINCE")));
                center.setDistrict(ScreenHelper.checkString(rs.getString("OC_HC_DISTRICT")));
                center.setZone(ScreenHelper.checkString(rs.getString("OC_HC_ZONE")));
                center.setSector(ScreenHelper.checkString(rs.getString("OC_HC_SECTOR")));
                center.setFosa(ScreenHelper.checkString(rs.getString("OC_HC_FOSA")));
                center.setCell(ScreenHelper.checkString(rs.getString("OC_HC_CELL")));
                center.setContactName(ScreenHelper.checkString(rs.getString("OC_HC_CONTACTNAME")));
                center.setContactFunction(ScreenHelper.checkString(rs.getString("OC_HC_CONTACTFUNCTION")));
                center.setRemEpidemiology(ScreenHelper.checkString(rs.getString("OC_HC_REM_EPIDEMIOLOGY")));
                center.setRemDrugs(ScreenHelper.checkString(rs.getString("OC_HC_REM_DRUGS")));
                center.setRemVaccinations(ScreenHelper.checkString(rs.getString("OC_HC_REM_VACCINATIONS")));
                center.setRemEquipment(ScreenHelper.checkString(rs.getString("OC_HC_REM_EQUIPMENT")));
                center.setRemBuilding(ScreenHelper.checkString(rs.getString("OC_HC_REM_BUILDING")));
                center.setRemTransport(ScreenHelper.checkString(rs.getString("OC_HC_REM_TRANSPORT")));
                center.setRemPersonnel(ScreenHelper.checkString(rs.getString("OC_HC_REM_PERSONNEL")));
                center.setRemOther(ScreenHelper.checkString(rs.getString("OC_HC_REM_OTHER")));
                center.setPopulationTotal(rs.getInt("OC_HC_POPULATION_TOTAL"));
                center.setPopulationLt1m(rs.getFloat("OC_HC_POPULATION_LT1M"));
                center.setPopulationLt1y(rs.getFloat("OC_HC_POPULATION_LT1Y"));
                center.setPopulationLt5y(rs.getFloat("OC_HC_POPULATION_LT5Y"));
                center.setPopulationLt25y(rs.getFloat("OC_HC_POPULATION_LT25Y"));
                center.setPopulationLt50y(rs.getFloat("OC_HC_POPULATION_LT50Y"));
                center.setPopulationMt50y(rs.getFloat("OC_HC_POPULATION_MT50Y"));
                center.setPopulationPreg(rs.getFloat("OC_HC_POPULATION_PREG"));
                center.setPopulationMut(rs.getFloat("OC_HC_POPULATION_MUT"));
                center.setBeds(rs.getInt("OC_HC_BEDS"));
                center.setActive(rs.getInt("OC_HC_ACTIVE"));
            }
            rs.close();
            ps.close();            
        }
        catch(Exception e){
            Debug.println("OpenClinic => Center.java => get => " + e.getMessage());
            e.printStackTrace();
        }
        
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return center;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static boolean delete(String sUID){
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();

        boolean errorOccured = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try{
            String sSql = "DELETE FROM OC_HC WHERE OC_HC_SERVERID = ?"+
                          " AND OC_HC_OBJECTID = ?";            
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sUID.split("\\.")[0]));
            ps.setInt(2,Integer.parseInt(sUID.split("\\.")[1]));
            ps.executeUpdate();
            
            sSql = "DELETE FROM OC_HC_HISTORY WHERE OC_HC_SERVERID = ?"+
                   " AND OC_HC_OBJECTID = ?";            
	        ps = oc_conn.prepareStatement(sSql);
	        ps.setInt(1,Integer.parseInt(sUID.split("\\.")[0]));
	        ps.setInt(2,Integer.parseInt(sUID.split("\\.")[1]));
	        ps.executeUpdate();                         
        }
        catch(Exception e){
        	errorOccured = true;
            e.printStackTrace();
        }
        finally{
        	try{
	        	if(oc_conn!=null) oc_conn.close();
			}
	        catch(SQLException e){
	        	errorOccured = true;
				e.printStackTrace();
			}
        }
        
        return errorOccured;
    }
    
}
