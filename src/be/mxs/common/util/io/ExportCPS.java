package be.mxs.common.util.io;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.Vector;

import net.admin.AdminPerson;
import net.admin.Service;
import net.admin.User;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;

public class ExportCPS {
	
	private static class CPSData{
		public int m0_11m,m1_4y,m5_9y,m10_14y,m15_25y,m26plus,f0_11m,f1_4y,f5_9y,f10_14y,f15_25y,f26plus;
		String serviceuid,prestationcode,prestationname,prestationnomenclature;
		
		public int getTotal(){
			return m0_11m+m1_4y+m5_9y+m10_14y+m15_25y+m26plus+f0_11m+f1_4y+f5_9y+f10_14y+f15_25y+f26plus;
		}
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		//Find date of last export
		try {
			StringBuffer exportfile = new StringBuffer();
			// This will load the MySQL driver, each DB has its own driver
		    Class.forName("com.mysql.jdbc.Driver");			
		    Connection conn =  DriverManager.getConnection("jdbc:mysql://localhost:3306/openclinic_dbo?"+args[0]);
			int nextmonthlyexport = Integer.parseInt((Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1)+new SimpleDateFormat("MM").format(new java.util.Date()));
			int nextdailyexport = Integer.parseInt((Integer.parseInt(new SimpleDateFormat("yyyyMM").format(new java.util.Date())))+"01");
			PreparedStatement ps = conn.prepareStatement("select oc_value from oc_config where oc_key='nextMonthlyCPSExport'");
		    ResultSet rs = ps.executeQuery();
		    if(rs.next()){
		    	nextmonthlyexport = Integer.parseInt(rs.getString("oc_value"));
			    System.out.println("nextMonthlyCPSExport="+nextmonthlyexport);
		    }
		    rs.close();
		    ps.close();
			ps = conn.prepareStatement("select oc_value from oc_config where oc_key='nextDailyCPSExport'");
		    rs = ps.executeQuery();
		    if(rs.next()){
		    	nextdailyexport = Integer.parseInt(rs.getString("oc_value"));
			    System.out.println("nextDailyCPSExport="+nextdailyexport);
		    }
		    rs.close();
		    ps.close();
		    String hospitalname="?";
		    ps=conn.prepareStatement("select * from OC_LABELS where OC_LABEL_TYPE='web' and OC_LABEL_ID='hospitalname' and OC_LABEL_LANGUAGE='fr'");
		    rs=ps.executeQuery();
		    if(rs.next()){
		    	hospitalname=rs.getString("OC_LABEL_VALUE");
		    }
		    rs.close();
		    ps.close();
		    String exportmonthlyamofile="/temp/exportCPSMonthly.csv";
		    ps = conn.prepareStatement("select oc_value from oc_config where oc_key='exportCPSMonthlyfile'");
		    rs = ps.executeQuery();
		    if(rs.next()){
		    	exportmonthlyamofile = rs.getString("oc_value");
		    }
		    rs.close();
		    ps.close();
		    String exportdailyamofile="/temp/exportCPSDaily.csv";
		    ps = conn.prepareStatement("select oc_value from oc_config where oc_key='exportCPSDailyfile'");
		    rs = ps.executeQuery();
		    if(rs.next()){
		    	exportdailyamofile = rs.getString("oc_value");
		    }
		    rs.close();
		    ps.close();
		    
		    java.util.Date nextMonthDate=new SimpleDateFormat("yyyyMMdd").parse(nextmonthlyexport+"01");
		    java.util.Date nextDayDate=new SimpleDateFormat("yyyyMMdd").parse(nextdailyexport+"");
		    
	        String sQuery="select oc_debet_quantity, oc_debet_serviceuid, oc_prestation_description, oc_debet_prestationuid,oc_prestation_code, oc_prestation_nomenclature,gender,dateofbirth" +
                    " from oc_debets a, oc_prestations b, oc_encounters c, adminview d" +
                    " where" +
                    " oc_encounter_objectid=replace(a.oc_debet_encounteruid,'1.','') and"+ 
                    " d.personid=c.oc_encounter_patientuid and"+
                    " oc_prestation_objectid=replace(a.oc_debet_prestationuid,'1.','') and"+ 
                    " (oc_debet_patientinvoiceuid is not null and oc_debet_patientinvoiceuid<>'') and"+
                    " oc_debet_date >= ? and oc_debet_date < ? ";
			Hashtable servicenames=new Hashtable();
			ps = conn.prepareStatement("select distinct oc_label_id,oc_label_value from oc_labels where oc_label_type='service' and oc_label_language='fr'");
			rs = ps.executeQuery();
			while(rs.next()){
				servicenames.put(rs.getString("oc_label_id").toUpperCase(), rs.getString("oc_label_value"));
			}
			rs.close();
			ps.close();

		    
		    //First we check if we have to export a new monthly file
		    java.util.Date thisMonthDate = new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMM").format(new java.util.Date())+"01");
		    java.util.Date newMonthDate;
		    while(thisMonthDate.after(nextMonthDate)){
		    	SortedMap hRows = new TreeMap();
		    	//Export for next month
				//First run through all debets
			  	ps = conn.prepareStatement(sQuery);
				ps.setTimestamp(1, new java.sql.Timestamp(nextMonthDate.getTime()));
		    	//Add 1 month to nextMonthDate
		    	int nextmonth = Integer.parseInt(new SimpleDateFormat("MM").format(nextMonthDate));
		    	if(nextmonth==12){
		    		newMonthDate=new SimpleDateFormat("yyyy/MM/dd").parse((Integer.parseInt(new SimpleDateFormat("yyyy").format(nextMonthDate))+1)+"/01/01");
		    	}
		    	else {
		    		newMonthDate=new SimpleDateFormat("yyyy/MM/dd").parse(new SimpleDateFormat("yyyy").format(nextMonthDate)+"/"+(Integer.parseInt(new SimpleDateFormat("MM").format(nextMonthDate))+1)+"/01");
		    	}
				ps.setTimestamp(2, new java.sql.Timestamp(newMonthDate.getTime()));
				System.out.println("Searching between "+nextMonthDate+" and "+newMonthDate);
				rs = ps.executeQuery();
				String prestationuid="",serviceuid="",servicename="",prestationcode="",prestationnomenclature="",prestationname="",key="";
				CPSData data;
				int age;
				while(rs.next()){
					serviceuid=rs.getString("oc_debet_serviceuid");
					prestationcode=rs.getString("oc_prestation_code");
					prestationnomenclature=rs.getString("oc_prestation_nomenclature");
					prestationname=rs.getString("oc_prestation_description");
					key=(serviceuid+";"+prestationcode).toUpperCase();
					data=(CPSData)hRows.get(key);
					if(data==null){
						data=new CPSData();
						data.serviceuid=serviceuid.toUpperCase();
						data.prestationcode=prestationcode;
						data.prestationnomenclature=prestationnomenclature;
						data.prestationname=prestationname;
					}
					age = AdminPerson.getYearsBetween(rs.getDate("dateofbirth"), nextMonthDate);
					if(rs.getString("gender").equalsIgnoreCase("m")){
						if(age<1){
							data.m0_11m+=rs.getInt("oc_debet_quantity");
						}
						else if(age<5){
							data.m1_4y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<10){
							data.m5_9y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<15){
							data.m10_14y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<26){
							data.m15_25y+=rs.getInt("oc_debet_quantity");
						}
						else{
							data.m26plus+=rs.getInt("oc_debet_quantity");
						}
					}
					else {
						if(age<1){
							data.f0_11m+=rs.getInt("oc_debet_quantity");
						}
						else if(age<5){
							data.f1_4y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<10){
							data.f5_9y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<15){
							data.f10_14y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<26){
							data.f15_25y+=rs.getInt("oc_debet_quantity");
						}
						else{
							data.f26plus+=rs.getInt("oc_debet_quantity");
						}
					}
					hRows.put(key, data);
				}
		    	rs.close();
		    	ps.close();
		    	if(hRows.size()>0){
			    	// Now print the debet counts to the file
			    	exportfile=new StringBuffer();
					exportfile.append("MONTH;");
					exportfile.append("DEPARTMENT_CODE;");
					exportfile.append("DEPARTMENT_NAME;");
					exportfile.append("PREST_CODE;");
					exportfile.append("PREST_NOMENCLATURE;");
					exportfile.append("PREST_NAME;");
					exportfile.append("PREST_TOTALQUANTITY;");
					exportfile.append("PREST_M_0_TO_11M;");
					exportfile.append("PREST_M_1_TO_4Y;");
					exportfile.append("PREST_M_5_TO_9Y;");
					exportfile.append("PREST_M_10_TO_14Y;");
					exportfile.append("PREST_M_15_TO_25Y;");
					exportfile.append("PREST_M_25plus;");
					exportfile.append("PREST_F_0_TO_11M;");
					exportfile.append("PREST_F_1_TO_4Y;");
					exportfile.append("PREST_F_5_TO_9Y;");
					exportfile.append("PREST_F_10_TO_14Y;");
					exportfile.append("PREST_F_15_TO_25Y;");
					exportfile.append("PREST_F_25plus\n");
					Iterator iRows = hRows.keySet().iterator();
					while(iRows.hasNext()){
						data = (CPSData)hRows.get(iRows.next());
						exportfile.append(new SimpleDateFormat("MM/yyyy").format(nextMonthDate)+";");
						exportfile.append((data.serviceuid==null||data.serviceuid.length()==0?"?":data.serviceuid)+";");
						exportfile.append((servicenames.get(data.serviceuid)==null?"?":servicenames.get(data.serviceuid))+";");
						exportfile.append(data.prestationcode+";");
						exportfile.append((data.prestationnomenclature==null?"":data.prestationnomenclature)+";");
						exportfile.append(data.prestationname+";");
						exportfile.append(data.getTotal()+";");
						exportfile.append(data.m0_11m+";");
						exportfile.append(data.m1_4y+";");
						exportfile.append(data.m5_9y+";");
						exportfile.append(data.m10_14y+";");
						exportfile.append(data.m15_25y+";");
						exportfile.append(data.m26plus+";");
						exportfile.append(data.f0_11m+";");
						exportfile.append(data.f1_4y+";");
						exportfile.append(data.f5_9y+";");
						exportfile.append(data.f10_14y+";");
						exportfile.append(data.f15_25y+";");
						exportfile.append(data.f26plus+"\n");
					}
					Hashtable newconsultationcases = new Hashtable(),newadmissioncases=new Hashtable();
					ps = conn.prepareStatement("select distinct a.OC_RFE_ENCOUNTERUID,a.OC_RFE_FLAGS,b.oc_encounter_type from OC_RFE a,OC_ENCOUNTERS b where b.OC_ENCOUNTER_OBJECTID=replace(a.OC_RFE_ENCOUNTERUID,'1.','') and b.OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<?");
					ps.setTimestamp(1,new java.sql.Timestamp(nextMonthDate.getTime()));
					ps.setTimestamp(2,new java.sql.Timestamp(newMonthDate.getTime()));
					rs = ps.executeQuery();
					while(rs.next()){
						if(rs.getString("OC_RFE_FLAGS").indexOf("N")>-1){
							if(rs.getString("oc_encounter_type").equalsIgnoreCase("visit")){
								newconsultationcases.put(rs.getString("OC_RFE_ENCOUNTERUID"),"1");
							}
							else {
								newadmissioncases.put(rs.getString("OC_RFE_ENCOUNTERUID"),"1");
							}
						}
					}
					int totalconsultationcases=0,totaladmissioncases=0;
					ps = conn.prepareStatement("select * from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<?");
					ps.setTimestamp(1,new java.sql.Timestamp(nextMonthDate.getTime()));
					ps.setTimestamp(2,new java.sql.Timestamp(newMonthDate.getTime()));
					rs = ps.executeQuery();
					while(rs.next()){
						if(rs.getString("oc_encounter_type").equalsIgnoreCase("visit")){
							totalconsultationcases++;	
							
						}
						else {
							totaladmissioncases++;	
						}
					}
					rs.close();
					ps.close();

					//Now try to send the file, if dend fails exit loop
					String title="The Global Health Barometer - TEST CPS extract "+hospitalname+"";
					String message="Message de test avec extraction de données CPS pour "+hospitalname+" en annexe.\n" +
									"- Période de rapportage couverte: du "+new SimpleDateFormat("dd/MM/yyyy").format(nextMonthDate)+" au "+new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date(newMonthDate.getTime()-1000))+"\n" +
									"\n" +
									"Consultations:\n"+
									" - Nouveaux cas: "+newconsultationcases.size()+"\n"+
									" - Nombre total de cas: "+totalconsultationcases+"\n"+
									"Nouvelles hospitalisations:\n"+
									" - Nouveaux cas: "+newadmissioncases.size()+"\n"+
									" - Nombre total de cas: "+totaladmissioncases+"\n"+
									"\n" +
									"Colonnes de la table en annexe:\n" +
									"- MONTH: mois et année des prestations\n" +
									"- DEPARTMENT_CODE: code du service prestataire\n" +
									"- DEPARTMENT_NAME: dénomination du service prestataire\n" +
									"- PREST_CODE: code de la prestation au "+hospitalname+"\n" +
									"- PREST_NOMENCLATURE: code de la prestation selon la nomenclature nationale\n" +
									"- PREST_NAME: dénomination de la prestation\n" +
									"- PREST_TOTALQUANTITY: nombre total de prestations réalisées pendant la période de rapportage\n" +
									"- PREST_M_0_TO_11M: nombre de prestations réalisées pour patients masculins de 0 à 11mois\n" +
									"- PREST_M_1_TO_4Y: nombre de prestations réalisées pour patients masculins de 1 à 4 ans\n" +
									"- PREST_M_5_TO_9y: nombre de prestations réalisées pour patients masculins de 5 à 9 ans\n" +
									"- PREST_M_10_TO_14y: nombre de prestations réalisées pour patients masculins de 10 à 14 ans\n" +
									"- PREST_M_15_TO_25y: nombre de prestations réalisées pour patients masculins de 15 à 25 ans\n" +
									"- PREST_M_25plus: nombre de prestations réalisées pour patients masculins de plus de 25 ans\n" +
									"- PREST_F_0_TO_11M: nombre de prestations réalisées pour patients féminins de 0 à 11mois\n" +
									"- PREST_F_1_TO_4Y: nombre de prestations réalisées pour patients féminins de 1 à 4 ans\n" +
									"- PREST_F_5_TO_9y: nombre de prestations réalisées pour patients féminins de 5 à 9 ans\n" +
									"- PREST_F_10_TO_14y: nombre de prestations réalisées pour patients féminins de 10 à 14 ans\n" +
									"- PREST_F_15_TO_25y: nombre de prestations réalisées pour patients féminins de 15 à 25 ans\n" +
									"- PREST_F_25plus: nombre de prestations réalisées pour patients féminins de plus de 25 ans\n" +
									"\n" +
									"Message généré automatiquement le "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date())+" pour le "+hospitalname+" par le Global Health Barometer. " +
									"Veuillez ne pas répondre directement à ce message svp. " +
									"Pour toute information supplémentaire concernant la structure de l'annexe, vous pouvez contacter Tidiani Togola (tidianitogola@sante.gov.ml) " +
									"à l'Agence Nationale de Télésanté et d'Informatique Médicale (ANTIM).\n\n" +
									"Pour le Global Health Barometer\n" +
									"ICT4development - Vrije Universiteit Brussel\n" +
									"dr. Frank Verbeke\n" +
									"frank.verbeke@vub.ac.be\n" +
									"Coordinateur Santé";
					System.out.println(exportfile.toString());
					Debug.println("sending message exportCPSMonthly to: "+args[3]);
					try{
						BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(exportmonthlyamofile));
						bufferedWriter.write(exportfile.toString());
						bufferedWriter.flush();
						bufferedWriter.close();
						Mail.sendMail(args[1], args[2], args[3], title, message,exportmonthlyamofile,"exportCPSMonthly.csv");
						System.out.println("Message exportCPSMonthly successfully sent");
					}
					catch(Exception e){
						e.printStackTrace();
						System.out.println("Error sending message exportCPSMonthly");
						break;
					}
		    	}
				nextMonthDate=newMonthDate;
				ps=conn.prepareStatement("select * from oc_config where oc_key='nextMonthlyCPSExport'");
				rs=ps.executeQuery();
				if(!rs.next()){
					rs.close();
					ps.close();
				    ps = conn.prepareStatement("insert into oc_config(oc_key,oc_value) values('nextMonthlyCPSExport',?)");
				    ps.setString(1,new SimpleDateFormat("yyyyMM").format(nextMonthDate));
				    ps.execute();
				    ps.close();
				}
				else {
					rs.close();
					ps.close();
				    ps = conn.prepareStatement("update oc_config set oc_value=? where oc_key='nextMonthlyCPSExport'");
				    ps.setString(1,new SimpleDateFormat("yyyyMM").format(nextMonthDate));
				    ps.execute();
				    ps.close();
				}
				System.out.println("nextMonthlyCPSExport set to "+new SimpleDateFormat("yyyyMM").format(nextMonthDate));
		    }

		    //Now we check if we have to export a new daily file
		    java.util.Date thisDayDate = new SimpleDateFormat("yyyyMMdd").parse(new SimpleDateFormat("yyyyMMdd").format(new java.util.Date()));
		    java.util.Date newDayDate;
		    long day=24*3600*1000;
		    System.out.println("thisDayDate="+thisDayDate);
		    System.out.println("nextDayDate="+nextDayDate);
		    while(thisDayDate.after(nextDayDate)){
		    	SortedMap hRows = new TreeMap();
		    	//Export for next month
				//First run through all debets
			  	ps = conn.prepareStatement(sQuery);
				ps.setTimestamp(1, new java.sql.Timestamp(nextDayDate.getTime()));
		    	//Add 24 hours to nextDayDate
				newDayDate=new java.util.Date(nextDayDate.getTime()+day);
				ps.setTimestamp(2, new java.sql.Timestamp(newDayDate.getTime()));
				rs = ps.executeQuery();
				String prestationuid="",serviceuid="",servicename="",prestationcode="",prestationnomenclature="",prestationname="",key="";
				CPSData data;
				int age;
				while(rs.next()){
					serviceuid=rs.getString("oc_debet_serviceuid");
					prestationcode=rs.getString("oc_prestation_code");
					prestationnomenclature=rs.getString("oc_prestation_nomenclature");
					prestationname=rs.getString("oc_prestation_description");
					key=(serviceuid+";"+prestationcode).toUpperCase();
					data=(CPSData)hRows.get(key);
					if(data==null){
						data=new CPSData();
						data.serviceuid=serviceuid.toUpperCase();
						data.prestationcode=prestationcode;
						data.prestationnomenclature=prestationnomenclature;
						data.prestationname=prestationname;
					}
					age = AdminPerson.getYearsBetween(rs.getDate("dateofbirth"), nextMonthDate);
					if(rs.getString("gender").equalsIgnoreCase("m")){
						if(age<1){
							data.m0_11m+=rs.getInt("oc_debet_quantity");
						}
						else if(age<5){
							data.m1_4y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<10){
							data.m5_9y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<15){
							data.m10_14y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<26){
							data.m15_25y+=rs.getInt("oc_debet_quantity");
						}
						else{
							data.m26plus+=rs.getInt("oc_debet_quantity");
						}
					}
					else {
						if(age<1){
							data.f0_11m+=rs.getInt("oc_debet_quantity");
						}
						else if(age<5){
							data.f1_4y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<10){
							data.f5_9y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<15){
							data.f10_14y+=rs.getInt("oc_debet_quantity");
						}
						else if(age<26){
							data.f15_25y+=rs.getInt("oc_debet_quantity");
						}
						else{
							data.f26plus+=rs.getInt("oc_debet_quantity");
						}
					}
					hRows.put(key, data);
				}
		    	rs.close();
		    	ps.close();
		    	if(hRows.size()>0){
			    	// Now print the debet counts to the file
			    	exportfile=new StringBuffer();
			    	exportfile.append("DATE;");
					exportfile.append("DEPARTMENT_CODE;");
					exportfile.append("DEPARTMENT_NAME;");
					exportfile.append("PREST_CODE;");
					exportfile.append("PREST_NOMENCLATURE;");
					exportfile.append("PREST_NAME;");
					exportfile.append("PREST_TOTALQUANTITY;");
					exportfile.append("PREST_M_0_TO_11M;");
					exportfile.append("PREST_M_1_TO_4Y;");
					exportfile.append("PREST_M_5_TO_9Y;");
					exportfile.append("PREST_M_10_TO_14Y;");
					exportfile.append("PREST_M_15_TO_25Y;");
					exportfile.append("PREST_M_25plus;");
					exportfile.append("PREST_F_0_TO_11M;");
					exportfile.append("PREST_F_1_TO_4Y;");
					exportfile.append("PREST_F_5_TO_9Y;");
					exportfile.append("PREST_F_10_TO_14Y;");
					exportfile.append("PREST_F_15_TO_25Y;");
					exportfile.append("PREST_F_25plus\n");
					Iterator iRows = hRows.keySet().iterator();
					while(iRows.hasNext()){
						data = (CPSData)hRows.get(iRows.next());
						exportfile.append(new SimpleDateFormat("dd/MM/yyyy").format(nextDayDate)+";");
						exportfile.append((data.serviceuid==null||data.serviceuid.length()==0?"?":data.serviceuid)+";");
						exportfile.append((servicenames.get(data.serviceuid)==null?"?":servicenames.get(data.serviceuid))+";");
						exportfile.append(data.prestationcode+";");
						exportfile.append(data.prestationnomenclature+";");
						exportfile.append(data.prestationname+";");
						exportfile.append(data.getTotal()+";");
						exportfile.append(data.m0_11m+";");
						exportfile.append(data.m1_4y+";");
						exportfile.append(data.m5_9y+";");
						exportfile.append(data.m10_14y+";");
						exportfile.append(data.m15_25y+";");
						exportfile.append(data.m26plus+";");
						exportfile.append(data.f0_11m+";");
						exportfile.append(data.f1_4y+";");
						exportfile.append(data.f5_9y+";");
						exportfile.append(data.f10_14y+";");
						exportfile.append(data.f15_25y+";");
						exportfile.append(data.f26plus+"\n");
					}
					Hashtable newconsultationcases = new Hashtable(),newadmissioncases=new Hashtable();
					ps = conn.prepareStatement("select distinct a.OC_RFE_ENCOUNTERUID,a.OC_RFE_FLAGS,b.oc_encounter_type from OC_RFE a,OC_ENCOUNTERS b where b.OC_ENCOUNTER_OBJECTID=replace(a.OC_RFE_ENCOUNTERUID,'1.','') and b.OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<?");
					ps.setTimestamp(1,new java.sql.Timestamp(nextDayDate.getTime()));
					ps.setTimestamp(2,new java.sql.Timestamp(newDayDate.getTime()));
					rs = ps.executeQuery();
					while(rs.next()){
						if(rs.getString("OC_RFE_FLAGS").indexOf("N")>-1){
							if(rs.getString("oc_encounter_type").equalsIgnoreCase("visit")){
								newconsultationcases.put(rs.getString("OC_RFE_ENCOUNTERUID"),"1");
							}
							else {
								newadmissioncases.put(rs.getString("OC_RFE_ENCOUNTERUID"),"1");
							}
						}
					}
					int totalconsultationcases=0,totaladmissioncases=0;
					ps = conn.prepareStatement("select * from OC_ENCOUNTERS where OC_ENCOUNTER_BEGINDATE>=? and OC_ENCOUNTER_BEGINDATE<?");
					ps.setTimestamp(1,new java.sql.Timestamp(nextDayDate.getTime()));
					ps.setTimestamp(2,new java.sql.Timestamp(newDayDate.getTime()));
					rs = ps.executeQuery();
					while(rs.next()){
						if(rs.getString("oc_encounter_type").equalsIgnoreCase("visit")){
							totalconsultationcases++;	
							
						}
						else {
							totaladmissioncases++;	
						}
					}
					rs.close();
					ps.close();

					//Now try to send the file, if dend fails exit loop
					String title="The Global Health Barometer - TEST CPS extract "+hospitalname+"";
					String message="Message de test avec extraction de données CPS pour "+hospitalname+" en annexe.\n" +
									"- Période de rapportage couverte: du "+new SimpleDateFormat("dd/MM/yyyy").format(nextDayDate)+" 00:00:00 au "+new SimpleDateFormat("dd/MM/yyyy").format(nextDayDate)+" 23:59:59\n" +
									"\n" +
									"Consultations:\n"+
									" - Nouveaux cas: "+newconsultationcases.size()+"\n"+
									" - Nombre total de cas: "+totalconsultationcases+"\n"+
									"Nouvelles hospitalisations:\n"+
									" - Nouveaux cas: "+newadmissioncases.size()+"\n"+
									" - Nombre total de cas: "+totaladmissioncases+"\n"+
									"\n" +
									"Colonnes de la table en annexe:\n" +
									"- DATE: date des prestations\n" +
									"- DEPARTMENT_CODE: code du service prestataire\n" +
									"- DEPARTMENT_NAME: dénomination du service prestataire\n" +
									"- PREST_CODE: code de la prestation au "+hospitalname+"\n" +
									"- PREST_NOMENCLATURE: code de la prestation selon la nomenclature nationale\n" +
									"- PREST_NAME: dénomination de la prestation\n" +
									"- PREST_TOTALQUANTITY: nombre total de prestations réalisées pendant la période de rapportage\n" +
									"- PREST_M_0_TO_11M: nombre de prestations réalisées pour patients masculins de 0 à 11mois\n" +
									"- PREST_M_1_TO_4Y: nombre de prestations réalisées pour patients masculins de 1 à 4 ans\n" +
									"- PREST_M_5_TO_9y: nombre de prestations réalisées pour patients masculins de 5 à 9 ans\n" +
									"- PREST_M_10_TO_14y: nombre de prestations réalisées pour patients masculins de 10 à 14 ans\n" +
									"- PREST_M_15_TO_25y: nombre de prestations réalisées pour patients masculins de 15 à 25 ans\n" +
									"- PREST_M_25plus: nombre de prestations réalisées pour patients masculins de plus de 25 ans\n" +
									"- PREST_F_0_TO_11M: nombre de prestations réalisées pour patients féminins de 0 à 11mois\n" +
									"- PREST_F_1_TO_4Y: nombre de prestations réalisées pour patients féminins de 1 à 4 ans\n" +
									"- PREST_F_5_TO_9y: nombre de prestations réalisées pour patients féminins de 5 à 9 ans\n" +
									"- PREST_F_10_TO_14y: nombre de prestations réalisées pour patients féminins de 10 à 14 ans\n" +
									"- PREST_F_15_TO_25y: nombre de prestations réalisées pour patients féminins de 15 à 25 ans\n" +
									"- PREST_F_25plus: nombre de prestations réalisées pour patients féminins de plus de 25 ans\n" +
									"\n" +
									"Message généré automatiquement le "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date())+" pour le "+hospitalname+" par le Global Health Barometer. " +
									"Veuillez ne pas répondre directement à ce message svp. " +
									"Pour toute information supplémentaire concernant la structure de l'annexe, vous pouvez contacter Tidiani Togola (tidianitogola@sante.gov.ml) " +
									"à l'Agence Nationale de Télésanté et d'Informatique Médicale (ANTIM).\n\n" +
									"Pour le Global Health Barometer\n" +
									"ICT4development - Vrije Universiteit Brussel\n" +
									"dr. Frank Verbeke\n" +
									"frank.verbeke@vub.ac.be\n" +
									"Coordinateur Santé";
					System.out.println(exportfile.toString());
					Debug.println("sending message exportCPSDaily to: "+args[3]);
					try{
						BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(exportdailyamofile));
						bufferedWriter.write(exportfile.toString());
						bufferedWriter.flush();
						bufferedWriter.close();
						Mail.sendMail(args[1], args[2], args[3], title, message,exportdailyamofile,"exportCPSDaily.csv");
						System.out.println("Message exportCPSDaily successfully sent");
					}
					catch(Exception e){
						e.printStackTrace();
						System.out.println("Error sending message exportCPSDaily");
						break;
					}
		    	}
				nextDayDate=newDayDate;
				ps=conn.prepareStatement("select * from oc_config where oc_key='nextDailyCPSExport'");
				rs=ps.executeQuery();
				if(!rs.next()){
					rs.close();
					ps.close();
				    ps = conn.prepareStatement("insert into oc_config(oc_key,oc_value) values('nextDailyCPSExport',?)");
				    ps.setString(1,new SimpleDateFormat("yyyyMMdd").format(nextDayDate));
				    ps.execute();
				    ps.close();
				}
				else {
					rs.close();
					ps.close();
				    ps = conn.prepareStatement("update oc_config set oc_value=? where oc_key='nextDailyCPSExport'");
				    ps.setString(1,new SimpleDateFormat("yyyyMMdd").format(nextDayDate));
				    ps.execute();
				    ps.close();
				}
				System.out.println("nextDailyCPSExport set to "+new SimpleDateFormat("yyyyMMdd").format(nextDayDate));
		    }		    
		    conn.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
		

	}

}
