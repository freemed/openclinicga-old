package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

public class ExporterFinancial extends Exporter {

	public void export(){
		if(!mustExport(getParam())){
			return;
		}
		if(getParam().equalsIgnoreCase("financial.0")){
			//Find last months total revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT)+sum(OC_DEBET_INSURARAMOUNT)+sum(OC_DEBET_EXTRAINSURARAMOUNT) total from OC_DEBETS where OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.0");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.0.1")){
			//Find last months total admission revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT)+sum(OC_DEBET_INSURARAMOUNT)+sum(OC_DEBET_EXTRAINSURARAMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='admission' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.0.1");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.0.2")){
			//Find last months total visit revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT)+sum(OC_DEBET_INSURARAMOUNT)+sum(OC_DEBET_EXTRAINSURARAMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='visit' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.0.2");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.1")){
			//Find last months patient revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT) total from OC_DEBETS where OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.1");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.1.1")){
			//Find last months patient admission revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='admission' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.1.1");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.1.2")){
			//Find last months patient visit revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='visit' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.1.2");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.2")){
			//Find last months insurar revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_INSURARAMOUNT) total from OC_DEBETS where OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.2");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.2.1")){
			//Find last months insurar admission revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_INSURARAMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='admission' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.2.1");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.2.2")){
			//Find last months insurar visit revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_INSURARAMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='visit' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.2.2");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.3")){
			//Find last months extra insurar revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_EXTRAINSURARAMOUNT) total from OC_DEBETS where OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.3");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.3.1")){
			//Find last months extra insurar admission revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_EXTRAINSURARAMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='admission' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.3.1");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.3.2")){
			//Find last months extra insurar visit revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_EXTRAINSURARAMOUNT) total from OC_DEBETS,OC_ENCOUNTERS where OC_ENCOUNTER_OBJECTID=replace(OC_DEBET_ENCOUNTERUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_ENCOUNTER_TYPE='visit' and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ?");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					int amount = rs.getInt("total");
					exportSingleValue("<financial month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>", "financial.3.2");
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("financial.4")){
			//Find last months care delivery classes revenue
			Date begin = DatacenterHelper.getBeginOfPreviousMonth();
			Date end = DatacenterHelper.getEndOfPreviousMonth();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select sum(OC_DEBET_AMOUNT)+sum(OC_DEBET_INSURARAMOUNT)+sum(OC_DEBET_EXTRAINSURARAMOUNT) total,OC_PRESTATION_REFTYPE from OC_DEBETS,OC_PRESTATIONS where OC_PRESTATION_OBJECTID=replace(OC_DEBET_PRESTATIONUID,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and OC_DEBET_DATE >= ? and OC_DEBET_DATE <= ? GROUP BY OC_PRESTATION_REFTYPE");
				ps.setTimestamp(1, new java.sql.Timestamp(begin.getTime()));
				ps.setTimestamp(2, new java.sql.Timestamp(end.getTime()));
				ResultSet rs = ps.executeQuery();
				StringBuffer sb = new StringBuffer("<financials>");
				while(rs.next()){
					int amount = rs.getInt("total");
					sb.append("<financial family='"+rs.getString("OC_PRESTATION_REFTYPE")+"' month='"+new SimpleDateFormat("yyyyMM").format(begin)+"' count='"+amount+"'/>");
				}
				sb.append("</financials>");
				exportSingleValue(sb.toString(), "financial.4");
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
