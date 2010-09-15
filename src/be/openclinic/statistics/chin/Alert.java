package be.openclinic.statistics.chin;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;
import java.util.Date;

/**
 * User: Frank Verbeke
 * Date: 30-jul-2007
 * Time: 8:37:49
 */
public class Alert {
    private String type;
    private int timeunit;
    private double level;
    private String destination;
    private double [] values;

    public double[] getValues() {
        return values;
    }

    public void setValues(double[] values) {
        this.values = values;
    }

    public Alert(String type, int timeunit, double level, String destination) {
        this.type = type;
        this.timeunit = timeunit;
        this.level = level;
        this.destination = destination;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getTimeunit() {
        return timeunit;
    }

    public void setTimeunit(int timeunit) {
        this.timeunit = timeunit;
    }

    public double getLevel() {
        return level;
    }

    public void setLevel(double level) {
        this.level = level;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public void analyse(double duration,String codetype,String code){
        int durationInUnits=new Double(Math.ceil(duration/getTimeunit())).intValue();
        Connection connection = MedwanQuery.getInstance().getLongOpenclinicConnection();
        PreparedStatement ps;
        try {
            if(getType().equalsIgnoreCase("absolutecases")){
                values = new double[durationInUnits];
                for(int n=0;n<values.length;n++){
                    values[n]=0;
                }
                String sQuery="select "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit())+" as weeks,count(*) as cases" +
                        " from oc_diagnoses diags,OC_ENCOUNTERS" +
                        " where" +
                        " "+ MedwanQuery.getInstance().convert("varchar(10)","oc_encounters.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","oc_encounters.OC_ENCOUNTER_OBJECTID")+"=diags.oc_diagnosis_encounteruid and" +
                        " oc_diagnosis_encounterobjectid=oc_encounter_objectid and " +
                        " (" +
                        "   (oc_diagnosis_codetype=? and oc_diagnosis_code like ?) or" +
                        "   (?='icpc' and oc_diagnosis_codetype='icd10' and exists (select icpc from classifications where icd10=oc_diagnosis_code and icpc like ?)) or" +
                        "   (?='icd10' and oc_diagnosis_codetype='icpc' and exists (select icd10 from classifications where icpc=oc_diagnosis_code and icd10 like ?))" +
                        " ) and" +
                        " "+MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"<=" + duration +" and" +
                        " "+MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+">=0"+
                        " group by "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit()) +
                        " order by "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit());
                ps=connection.prepareStatement(sQuery);
                ps.setString(1,codetype);
                ps.setString(2,code);
                ps.setString(3,codetype);
                ps.setString(4,code);
                ps.setString(5,codetype);
                ps.setString(6,code);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    values[rs.getInt("weeks")]=rs.getInt("cases");
                }
                rs.close();
                ps.close();
            }
            else if(getType().equalsIgnoreCase("relativecases")){
                values = new double[durationInUnits];
                for(int n=0;n<values.length;n++){
                    values[n]=0;
                }
                //Eerst de absolute waarden stockeren
                String sQuery="select "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit())+" as weeks,count(*) as cases" +
                        " from oc_diagnoses diags,OC_ENCOUNTERS" +
                        " where" +
                        " "+ MedwanQuery.getInstance().convert("varchar(10)","oc_encounters.OC_ENCOUNTER_SERVERID")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","oc_encounters.OC_ENCOUNTER_OBJECTID")+"=diags.oc_diagnosis_encounteruid and" +
                        " oc_diagnosis_encounterobjectid=oc_encounter_objectid and " +
                        " (" +
                        "   (oc_diagnosis_codetype=? and oc_diagnosis_code like ?) or" +
                        "   (?='icpc' and oc_diagnosis_codetype='icd10' and exists (select icpc from classifications where icd10=oc_diagnosis_code and icpc like ?)) or" +
                        "   (?='icd10' and oc_diagnosis_codetype='icpc' and exists (select icd10 from classifications where icpc=oc_diagnosis_code and icd10 like ?))" +
                        " ) and" +
                        " "+MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"<=" + duration +" and" +
                        " "+MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+">=0"+
                        " group by "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit()) +
                        " order by "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit());

                ps=connection.prepareStatement(sQuery);
                ps.setString(1,codetype);
                ps.setString(2,code);
                ps.setString(3,codetype);
                ps.setString(4,code);
                ps.setString(5,codetype);
                ps.setString(6,code);
                ResultSet rs = ps.executeQuery();
                while(rs.next()){
                    values[rs.getInt("weeks")]=rs.getInt("cases");
                }
                rs.close();
                ps.close();
                //Nu delen door het totaal aantal gevallen voor dezelfde periode
                sQuery="select "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit())+" as weeks,count(*) as cases" +
                        " from OC_ENCOUNTERS" +
                        " where" +
                        " "+MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"<=" + duration +" and" +
                        " "+MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+">=0"+
                        " group by "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit()) +
                        " order by "+MedwanQuery.getInstance().convert("int",MedwanQuery.getInstance().datediff("d","OC_ENCOUNTER_BEGINDATE",MedwanQuery.getInstance().getConfigString("dateFunction","getdate()"))+"/"+getTimeunit());
                ps=connection.prepareStatement(sQuery);
                rs = ps.executeQuery();
                while(rs.next()){
                    values[rs.getInt("weeks")]=values[rs.getInt("weeks")]*100/rs.getInt("cases");
                }
                rs.close();
                ps.close();
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

    }
}
