package be.openclinic.medical;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.common.KeyValue;
import be.openclinic.common.Util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;

public class CarePrescriptionAdministrationSchema {
    private Date date;
    private String personuid;
    private Vector carePrescriptionSchemas=new Vector();

    public class AdministrationSchemaLine{
        private CarePrescription careprescription;
        private Vector timeQuantities=new Vector();
        private Hashtable timeAdministrations=new Hashtable();

        public CarePrescription getCarePrescription() {
            return careprescription;
        }

        public void setCarePrescription(CarePrescription careprescription) {
            this.careprescription = careprescription;
        }

        public Hashtable getTimeAdministrations() {
            return timeAdministrations;
        }

        public Vector getTimeQuantities() {
            return timeQuantities;
        }

        public void setTimeQuantities(Vector timeQuantities) {
            this.timeQuantities = timeQuantities;
        }

        public void setTimeAdministrations(Hashtable timeAdministrations) {
            this.timeAdministrations = timeAdministrations;
        }

        public AdministrationSchemaLine(CarePrescription careprescription) {
            this.careprescription = careprescription;
        }

        public String getTimeAdministration(String datetime){
            String quantity = (String)timeAdministrations.get(datetime);
            if(quantity!=null){
                return quantity;
            }
            else {
                return "";
            }
        }
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getPersonuid() {
        return personuid;
    }

    public void setPersonuid(String personuid) {
        this.personuid = personuid;
    }

    public Vector getCarePrescriptionSchemas() {
        return carePrescriptionSchemas;
    }

    public void setCarePrescriptionSchemas(Vector vCarePrescriptionSchemas) {
        this.carePrescriptionSchemas = vCarePrescriptionSchemas;
    }

    public CarePrescriptionAdministrationSchema(Date date, String personuid) {
        this.date = date;
        this.personuid = personuid;
        SortedMap schemaTimes = new TreeMap();
        Vector prescriptions= CarePrescription.find(personuid,"","",new SimpleDateFormat("dd/MM/yyyy").format(new Date(date.getTime()+24*3600*1000)),new SimpleDateFormat("dd/MM/yyyy").format(date),"","","");
        //We inventariseren eerst alle noodzakelijke tijdstippen
        CarePrescription prescription;
        CarePrescriptionSchema prescriptionSchema;
        Vector timequantities;
        KeyValue keyValue;
        for (int n=0;n<prescriptions.size();n++){
            prescription= (CarePrescription)prescriptions.elementAt(n);
            prescriptionSchema = CarePrescriptionSchema.getCarePrescriptionSchema(prescription.getUid());
            timequantities = prescriptionSchema.getTimequantities();
            for(int i=0;i<timequantities.size();i++){
                keyValue = (KeyValue)timequantities.elementAt(i);
                schemaTimes.put(new Integer(keyValue.getKey()),"");
            }
        }
        //Voor elk van de voorschriften gaan we nu de eenheden invullen die bij het betreffende uur horen
        AdministrationSchemaLine administrationSchemaLine;
        Iterator iterator;
        Integer time;
        for (int n=0;n<prescriptions.size();n++){
            prescription= (CarePrescription)prescriptions.elementAt(n);
            prescriptionSchema = CarePrescriptionSchema.getCarePrescriptionSchema(prescription.getUid());
            administrationSchemaLine = new AdministrationSchemaLine(prescription);
            iterator = schemaTimes.keySet().iterator();
            while (iterator.hasNext()){
                time = (Integer)iterator.next();
                administrationSchemaLine.getTimeQuantities().add(new KeyValue(time.toString(),prescriptionSchema.getQuantity(time.toString())+""));
            }
            carePrescriptionSchemas.add(administrationSchemaLine);
        }
    }

    public CarePrescriptionAdministrationSchema(Date dateBegin, Date dateEnd, String personuid) {
        this.date = dateBegin;
        this.personuid = personuid;
        SortedMap schemaTimes = new TreeMap();
        Vector prescriptions= CarePrescription.find(personuid,"","",new SimpleDateFormat("dd/MM/yyyy").format(dateEnd),new SimpleDateFormat("dd/MM/yyyy").format(dateBegin),"","","");
        //We inventariseren eerst alle noodzakelijke tijdstippen
        CarePrescription prescription;
        CarePrescriptionSchema prescriptionSchema;
        Vector timequantities;
        KeyValue keyValue;
        for (int n=0;n<prescriptions.size();n++){
            prescription= (CarePrescription)prescriptions.elementAt(n);
            prescriptionSchema = CarePrescriptionSchema.getCarePrescriptionSchema(prescription.getUid());
            timequantities = prescriptionSchema.getTimequantities();
            for(int i=0;i<timequantities.size();i++){
                keyValue = (KeyValue)timequantities.elementAt(i);
                schemaTimes.put(new Integer(keyValue.getKey()),"");
            }
        }
        //Voor elk van de voorschriften gaan we nu de eenheden invullen die bij het betreffende uur horen
        AdministrationSchemaLine administrationSchemaLine;
        Iterator iterator;
        Integer time;
        Connection dbConnection= MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps;
        ResultSet rs;
        for (int n=0;n<prescriptions.size();n++){
            prescription= (CarePrescription)prescriptions.elementAt(n);
            prescriptionSchema = CarePrescriptionSchema.getCarePrescriptionSchema(prescription.getUid());
            administrationSchemaLine = new AdministrationSchemaLine(prescription);
            iterator = schemaTimes.keySet().iterator();
            while (iterator.hasNext()){
                time = (Integer)iterator.next();
                administrationSchemaLine.getTimeQuantities().add(new KeyValue(time.toString(),prescriptionSchema.getQuantity(time.toString())+""));
            }
            //Nu zoeken we voor betreffende geneesmiddelen de toedieningen op

            try {
                ps = dbConnection.prepareStatement("select * from OC_CAREPRESCRIPTION_ADMINISTRATION where OC_CAREPRESCR_SERVERID=? and OC_CAREPRESCR_OBJECTID=?");
                ps.setInt(1, Util.getServerid(prescription.getUid()));
                ps.setInt(2, Util.getObjectid(prescription.getUid()));
                rs = ps.executeQuery();
                while (rs.next()){
                    administrationSchemaLine.getTimeAdministrations().put(new SimpleDateFormat("yyyyMMdd").format(rs.getDate("OC_CARESCHEMA_DATE"))+"."+rs.getString("OC_CARESCHEMA_TIME"),rs.getString("OC_CARESCHEMA_QUANTITY"));
                }
                rs.close();
                ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            carePrescriptionSchemas.add(administrationSchemaLine);
        }
        try {
			dbConnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static void storeAdministration(String prescriptionUid,Date date,int time,int quantity){
        Connection dbConnection= MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = dbConnection.prepareStatement("delete from OC_CAREPRESCRIPTION_ADMINISTRATION where OC_CAREPRESCR_SERVERID=? and OC_CAREPRESCR_OBJECTID=? and OC_CARESCHEMA_DATE=? and OC_CARESCHEMA_TIME=?");
            ps.setInt(1,Util.getServerid(prescriptionUid));
            ps.setInt(2,Util.getObjectid(prescriptionUid));
            ps.setDate(3,new java.sql.Date(date.getTime()));
            ps.setInt(4,time);
            ps.execute();
            ps.close();
            if(quantity>0){
                ps = dbConnection.prepareStatement("insert into OC_CAREPRESCRIPTION_ADMINISTRATION (OC_CAREPRESCR_SERVERID,OC_CAREPRESCR_OBJECTID,OC_CARESCHEMA_DATE,OC_CARESCHEMA_TIME,OC_CARESCHEMA_QUANTITY) values(?,?,?,?,?)");
                ps.setInt(1,Util.getServerid(prescriptionUid));
                ps.setInt(2,Util.getObjectid(prescriptionUid));
                ps.setDate(3,new java.sql.Date(date.getTime()));
                ps.setInt(4,time);
                ps.setInt(5,quantity);
                ps.execute();
                ps.close();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			dbConnection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
}
