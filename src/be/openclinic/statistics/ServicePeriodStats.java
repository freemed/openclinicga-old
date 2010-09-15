package be.openclinic.statistics;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Date;
import java.util.Vector;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.net.URL;

import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.Element;


/**
 * User: Frank Verbeke
 * Date: 6-aug-2007
 * Time: 21:46:42
 */
public class ServicePeriodStats {
    private String serviceUid;
    private Date begin;
    private Date end;
    private int patients;
    private int admissions;
    private int admissiondays;
    private int visits;

    private Vector transactionStats=new Vector();
    private Vector itemStats=new Vector();

    public int getPatients() {
        return patients;
    }

    public void setPatients(int patients) {
        this.patients = patients;
    }

    public int getAdmissions() {
        return admissions;
    }

    public void setAdmissions(int admissions) {
        this.admissions = admissions;
    }

    public int getAdmissiondays() {
        return admissiondays;
    }

    public void setAdmissiondays(int admissiondays) {
        this.admissiondays = admissiondays;
    }

    public int getVisits() {
        return visits;
    }

    public void setVisits(int visits) {
        this.visits = visits;
    }

    public Vector getTransactionStats() {
        return transactionStats;
    }

    public ServicePeriodTransactionStats getTransactionStats(String transactionType) {
        ServicePeriodTransactionStats tranStats = null;
        for(int n=0;n<transactionStats.size();n++){
            ServicePeriodTransactionStats t = (ServicePeriodTransactionStats)transactionStats.elementAt(n);
            if(t.getTransactionType().equalsIgnoreCase(transactionType)){
                tranStats=t;
                break;
            }
        }
        return tranStats;
    }

    public Vector getItemStats() {
        return itemStats;
    }

    public ServicePeriodStats(String serviceUid, Date begin, Date end) {
        this.serviceUid = serviceUid;
        this.begin = begin;
        this.end = end;
    }

    public String getServiceUid() {
        return serviceUid;
    }

    public void setServiceUid(String serviceUid) {
        this.serviceUid = serviceUid;
    }

    public Date getBegin() {
        return begin;
    }

    public void setBegin(Date begin) {
        this.begin = begin;
    }

    public Date getEnd() {
        return end;
    }

    public void setEnd(Date end) {
        this.end = end;
    }

    public void initialize(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            //We voeren verschillende basisberekeingen uit
            //Aantal verschillende patiënten voor deze periode
            String sQuery="select count(distinct OC_ENCOUNTER_PATIENTUID) total from OC_ENCOUNTERS_VIEW" +
                    " where" +
                    " OC_ENCOUNTER_ENDDATE>=? and" +
                    " OC_ENCOUNTER_BEGINDATE<? and" +
                    " OC_ENCOUNTER_SERVICEUID like '"+serviceUid+"%'";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(begin.getTime()));
            ps.setDate(2,new java.sql.Date(end.getTime()));
            ResultSet rs=ps.executeQuery();
            if(rs.next()){
                setPatients(rs.getInt("total"));
            }
            rs.close();
            ps.close();
            //Aantal nieuwe hospitalisaties voor deze periode
            sQuery="select count(distinct OC_ENCOUNTER_OBJECTID) total from OC_ENCOUNTERS_VIEW" +
                    " where" +
                    " OC_ENCOUNTER_TYPE='admission' and" +
                    " OC_ENCOUNTER_BEGINDATE>=? and" +
                    " OC_ENCOUNTER_BEGINDATE<? and" +
                    " OC_ENCOUNTER_SERVICEUID like '"+serviceUid+"%'";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(begin.getTime()));
            ps.setDate(2,new java.sql.Date(end.getTime()));
            rs=ps.executeQuery();
            if(rs.next()){
                setAdmissions(rs.getInt("total"));
            }
            rs.close();
            ps.close();
            //Aantal verschillende hospitalisatiedagen voor deze periode
            sQuery="select sum(days) total from" +
                    " (" +
                    " select "+MedwanQuery.getInstance().datediff("d",MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?"),MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?"))+" days "+
                    " from OC_ENCOUNTERS_VIEW " +
                    " where" +
                    " OC_ENCOUNTER_TYPE='admission' and" +
                    " OC_ENCOUNTER_ENDDATE>=? and" +
                    " OC_ENCOUNTER_BEGINDATE<? and" +
                    " OC_ENCOUNTER_SERVICEUID like '"+serviceUid+"%'" +
                    " ) admissions";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(begin.getTime()));
            ps.setDate(2,new java.sql.Date(begin.getTime()));
            ps.setDate(3,new java.sql.Date(end.getTime()));
            ps.setDate(4,new java.sql.Date(end.getTime()));
            ps.setDate(5,new java.sql.Date(begin.getTime()));
            ps.setDate(6,new java.sql.Date(end.getTime()));
            rs=ps.executeQuery();
            if(rs.next()){
                setAdmissiondays(rs.getInt("total"));
            }
            rs.close();
            ps.close();
            //Aantal verschillende nieuwe bezoeken voor deze periode
            sQuery="select count(distinct OC_ENCOUNTER_OBJECTID) total from OC_ENCOUNTERS_VIEW" +
                    " where" +
                    " OC_ENCOUNTER_TYPE='visit' and" +
                    " OC_ENCOUNTER_BEGINDATE>=? and" +
                    " OC_ENCOUNTER_BEGINDATE<? and" +
                    " OC_ENCOUNTER_SERVICEUID like '"+serviceUid+"%'";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(begin.getTime()));
            ps.setDate(2,new java.sql.Date(end.getTime()));
            rs=ps.executeQuery();
            if(rs.next()){
                setVisits(rs.getInt("total"));
            }
            rs.close();
            ps.close();

            //Nu maken we een lijst van alle transactiontypes en we initializeren een stat voor elk transactiontype
            sQuery="select transactionType,count(*) as total " +
                    " from OC_ENCOUNTERS_VIEW a, Transactions b, Healthrecord c" +
                    " where" +
                    " OC_ENCOUNTER_BEGINDATE>=? and" +
                    " OC_ENCOUNTER_ENDDATE<? and" +
                    " OC_ENCOUNTER_SERVICEUID like '"+serviceUid+"%' and"+
                    " a.OC_ENCOUNTER_PATIENTUID=c.personId and" +
                    " b.healthRecordId=c.healthRecordId and" +
                    " b.updateTime>=a.OC_ENCOUNTER_BEGINDATE and" +
                    " b.updateTime<=a.OC_ENCOUNTER_ENDDATE" +
                    " group by transactionType" +
                    " order by count(*) DESC";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1,new java.sql.Date(ScreenHelper.getDate(begin).getTime()));
            ps.setDate(2,new java.sql.Date(end.getTime()));
            rs=ps.executeQuery();
            while(rs.next()){
                ServicePeriodTransactionStats servicePeriodTransactionStats=new ServicePeriodTransactionStats(rs.getString("transactionType"),rs.getInt("total"));
                transactionStats.add(servicePeriodTransactionStats);
            }
            rs.close();
            ps.close();
            //Nu maken we een lijst van alle itemtypes en we initializeren een stat voor elk itemtype
            //We halen eerst alle gewenste itemtypes op uit een XML-bestand
            String sFilename= MedwanQuery.getInstance().getConfigString("templateSource")+"/ServiceStats.xml";
            SAXReader reader = new SAXReader(false);
            Document document = reader.read(new URL(sFilename));
            Element root = document.getRootElement();
            Iterator servicestats=root.elementIterator("servicestat");
            while(servicestats.hasNext()){
                Element servicestat = (Element)servicestats.next();
                if(serviceUid.startsWith(servicestat.attributeValue("serviceuid"))){
                    //Dit is de correcte service, we doorlopen nu de items
                    Iterator items = servicestat.elementIterator("item");
                    while(items.hasNext()){
                        Element item = (Element)items.next();
                        String itemType=item.attributeValue("type");
                        sQuery="select count(*) as total " +
                                " from OC_ENCOUNTERS_VIEW a, Transactions b, Healthrecord c, Items d" +
                                " where" +
                                " OC_ENCOUNTER_BEGINDATE>=? and" +
                                " OC_ENCOUNTER_ENDDATE<? and" +
                                " OC_ENCOUNTER_SERVICEUID like '"+serviceUid+"%' and"+
                                " a.OC_ENCOUNTER_PATIENTUID=c.personId and" +
                                " b.healthRecordId=c.healthRecordId and" +
                                " b.updateTime>=a.OC_ENCOUNTER_BEGINDATE and" +
                                " b.updateTime<=a.OC_ENCOUNTER_ENDDATE and" +
                                " b.serverid=d.serverid and" +
                                " b.transactionId=d.transactionId and" +
                                " d.type=?";
                        ps = oc_conn.prepareStatement(sQuery);
                        ps.setDate(1,new java.sql.Date(ScreenHelper.getDate(begin).getTime()));
                        ps.setDate(2,new java.sql.Date(end.getTime()));
                        ps.setString(3,itemType);
                        rs=ps.executeQuery();
                        while(rs.next()){
                            ServicePeriodItemStats servicePeriodItemStats=new ServicePeriodItemStats(itemType,rs.getInt("total"));
                            itemStats.add(servicePeriodItemStats);
                        }
                        rs.close();
                        ps.close();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
}
