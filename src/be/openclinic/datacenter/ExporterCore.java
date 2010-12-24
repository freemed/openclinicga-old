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
	}
}
