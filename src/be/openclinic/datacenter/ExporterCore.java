package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import be.mxs.common.util.db.MedwanQuery;

public class ExporterCore extends Exporter {

	public void export(){
		if(getParam().equalsIgnoreCase("core.1")){
			//Export total number of patients in the ocadmin.admin table
			exportSingleValue("admin","select count(*) total from Admin", "total", "core.1");
		}
		else if(getParam().equalsIgnoreCase("core.1.1")){
			//Export total number of men in the ocadmin.admin table
			exportSingleValue("admin","select count(*) total from Admin where gender='M'", "total", "core.1.1");
		}
		else if(getParam().equalsIgnoreCase("core.1.2")){
			//Export total number of women in the ocadmin.admin table
			exportSingleValue("admin","select count(*) total from Admin where gender='F'", "total", "core.1.2");
		}
		else if(getParam().equalsIgnoreCase("core.1.3")){
			//Export total number of children<5y in the ocadmin.admin table
			Connection conn = MedwanQuery.getInstance().getAdminConnection();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select * from OC_EXPORTS where OC_EXPORT_ID='core.1.3' and OC_EXPORT_CREATEDATETIME>=?");
				ps.setTimestamp(1, new java.sql.Timestamp(getDeadline().getTime()));
				ResultSet rs = ps.executeQuery();
				if(!rs.next()){
					rs.close();
					ps.close();
					ps = conn.prepareStatement("select count(*) as total from Admin where dateofbirth>?");
					long day = 24*3600*1000;
					long y5 = 365*5*day;
					ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-y5));
					rs = ps.executeQuery();
					if(rs.next()){
						exportSingleValue(rs.getString("total"), "core.1.3");
					}
				}
				rs.close();
				ps.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			finally {
				try {
					conn.close();
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
		else if(getParam().equalsIgnoreCase("core.2")){
			//Export total number of users in the ocadmin.users table
			exportSingleValue("admin","select count(*) total from Users", "total", "core.2");
		}
		else if(getParam().equalsIgnoreCase("core.3")){
			//Export total number of defined services in the ocadmin.services table
			exportSingleValue("admin","select count(*) total from Services", "total", "core.3");
		}
		else if(getParam().equalsIgnoreCase("core.4")){
			//Export total number of encounters in the openclinic.oc_encounters table
			exportSingleValue("openclinic","select count(*) total from OC_ENCOUNTERS", "total", "core.4");
		}
		else if(getParam().equalsIgnoreCase("core.4.1")){
			//Export total number of admissions in the openclinic.oc_encounters table
			exportSingleValue("openclinic","select count(*) total from OC_ENCOUNTERS where OC_ENCOUNTER_TYPE='admission'", "total", "core.4.1");
		}
		else if(getParam().equalsIgnoreCase("core.4.2")){
			//Export total number of visits in the openclinic.oc_encounters table
			exportSingleValue("openclinic","select count(*) total from OC_ENCOUNTERS where OC_ENCOUNTER_TYPE='visit'", "total", "core.4.2");
		}
		else if(getParam().equalsIgnoreCase("core.5")){
			//Export total number of debets in the openclinic.oc_debets table
			exportSingleValue("openclinic","select count(*) total from OC_DEBETS", "total", "core.5");
		}
		else if(getParam().equalsIgnoreCase("core.6")){
			//Export total number of transactions in the openclinic.transactions table
			exportSingleValue("openclinic","select count(*) total from Transactions", "total", "core.6");
		}
		else if(getParam().equalsIgnoreCase("core.7")){
			//Export total number of items in the openclinic.items table
			exportSingleValue("openclinic","select count(*) total from Items", "total", "core.7");
		}
		else if(getParam().equalsIgnoreCase("core.8")){
			//Export total number of diagnoses in the openclinic.OC_DIAGNOSES table
			exportSingleValue("openclinic","select count(*) total from OC_DIAGNOSES", "total", "core.8");
		}
		else if(getParam().equalsIgnoreCase("core.8.1")){
			//Export total number of ICD10 diagnoses in the openclinic.OC_DIAGNOSES table
			exportSingleValue("openclinic","select count(*) total from OC_DIAGNOSES where OC_DIAGNOSIS_CODETYPE='icd10'", "total", "core.8.1");
		}
		else if(getParam().equalsIgnoreCase("core.8.2")){
			//Export total number of ICPC diagnoses in the openclinic.OC_DIAGNOSES table
			exportSingleValue("openclinic","select count(*) total from OC_DIAGNOSES where OC_DIAGNOSIS_CODETYPE='icpc'", "total", "core.8.2");
		}
		else if(getParam().equalsIgnoreCase("core.9")){
			//Export total number of reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_RFE", "total", "core.9");
		}
		else if(getParam().equalsIgnoreCase("core.9.1")){
			//Export total number of ICD10 reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_RFE where OC_RFE_CODETYPE='icd10'", "total", "core.9.1");
		}
		else if(getParam().equalsIgnoreCase("core.9.2")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_RFE where OC_RFE_CODETYPE='icpc'", "total", "core.9.2");
		}
		else if(getParam().equalsIgnoreCase("core.10")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_PROBLEMS", "total", "core.10");
		}
		else if(getParam().equalsIgnoreCase("core.11")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_PATIENTINVOICES", "total", "core.11");
		}
		else if(getParam().equalsIgnoreCase("core.12")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_INSURARINVOICES", "total", "core.12");
		}
		else if(getParam().equalsIgnoreCase("core.13")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_PATIENTCREDITS", "total", "core.13");
		}
		else if(getParam().equalsIgnoreCase("core.14")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_INSURARS", "total", "core.14");
		}
		else if(getParam().equalsIgnoreCase("core.15")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from OC_INSURARCREDITS", "total", "core.15");
		}
		else if(getParam().equalsIgnoreCase("core.16")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from labanalysis", "total", "core.16");
		}
		else if(getParam().equalsIgnoreCase("core.17")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from requestedlabanalyses", "total", "core.17");
		}
		else if(getParam().equalsIgnoreCase("core.18")){
			//Export total number of ICPC reasons for encounter in the openclinic.OC_RFE table
			exportSingleValue("openclinic","select count(*) total from labprofiles", "total", "core.18");
		}
	}
}
