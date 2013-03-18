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
import java.util.Vector;

import net.admin.User;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.Pointer;

public class ExportAMO {

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
			Date lastexport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse("19000101000000000");
			PreparedStatement ps = conn.prepareStatement("select oc_value from oc_config where oc_key='lastAMOexport'");
		    ResultSet rs = ps.executeQuery();
		    if(rs.next()){
				lastexport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(rs.getString("oc_value"));
			    System.out.println("lastExport="+lastexport);
		    }
		    rs.close();
		    ps.close();
		    String mfp="$erfaefaef";
		    ps = conn.prepareStatement("select oc_value from oc_config where oc_key='MFP'");
		    rs = ps.executeQuery();
		    if(rs.next()){
				mfp = rs.getString("oc_value");
		    }
		    rs.close();
		    ps.close();
		    String exportamofile="/temp/exportAMO.csv";
		    ps = conn.prepareStatement("select oc_value from oc_config where oc_key='exportAMOfile'");
		    rs = ps.executeQuery();
		    if(rs.next()){
		    	exportamofile = rs.getString("oc_value");
		    }
		    rs.close();
		    ps.close();
		    java.util.Date mindate=new java.util.Date();
		    java.util.Date maxdate=new java.util.Date();
		    
		  	ps = conn.prepareStatement(	"select * from oc_debets a,oc_encounters b,adminview c,oc_patientinvoices d,oc_insurances e,oc_prestations f"+
					" where"+
					" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'1.','') and"+
					" d.oc_patientinvoice_objectid=replace(oc_debet_patientinvoiceuid,'1.','') and" +
					" d.oc_patientinvoice_status='closed' and" +
					" b.oc_encounter_patientuid=c.personid and"+
					" length(oc_debet_patientinvoiceuid)>0  and" +
					" d.oc_patientinvoice_updatetime>? and" +
					" e.oc_insurance_objectid=replace(a.oc_debet_insuranceuid,'1.','') and" +
					" e.oc_insurance_insuraruid=? and" +
					" f.oc_prestation_objectid=replace(a.oc_debet_prestationuid,'1.','')" +
					" order by d.oc_patientinvoice_objectid");
			ps.setTimestamp(1, new Timestamp(lastexport.getTime()));
			ps.setString(2, mfp);
			rs = ps.executeQuery();
			exportfile.append("PREST_ID;");
			exportfile.append("PREST_DATE;");
			exportfile.append("CONTACT_TYPE;");
			exportfile.append("CONTACT_ID;");
			exportfile.append("CHUGT_ID;");
			exportfile.append("AMO_ID;");
			exportfile.append("AMO_STATUS;");
			exportfile.append("AMO_SOURCE;");
			exportfile.append("PAT_LASTNAME;");
			exportfile.append("PAT_FIRSTNAME;");
			exportfile.append("PREST_CODE;");
			exportfile.append("PREST_NAME;");
			exportfile.append("PREST_PRICE;");
			exportfile.append("PREST_QUANTITY;");
			exportfile.append("INV_AMO;");
			exportfile.append("INV_PATIENTREF;");
			exportfile.append("AUTH_AMO\n");
			

			boolean hasdata = false;
			int totalprice=0,totalamo=0,countdebets=0,price,amo,quantity;
			String personid="";
			java.util.Date debetdate;
			while(rs.next()){
				String objectid=rs.getString("oc_debet_objectid");
				exportfile.append(objectid+";");
				Date date = rs.getTimestamp("oc_patientinvoice_updatetime");
				if(date.before(mindate)){
					mindate=date;
				}
				if(date.after(maxdate)){
					maxdate=date;
				}
				price=rs.getInt("oc_prestation_price");
				totalprice+=price;
				amo=rs.getInt("oc_debet_insuraramount");
				totalamo+=amo;
				quantity=rs.getInt("oc_debet_quantity");
				countdebets+=quantity;
				personid=rs.getString("oc_encounter_patientuid");
				debetdate=rs.getDate("oc_debet_date");
				exportfile.append(new SimpleDateFormat("dd/MM/yyyy").format(debetdate)+";");
				exportfile.append((rs.getString("oc_encounter_type").equalsIgnoreCase("admission")?"H":"C")+";");
				exportfile.append(rs.getString("oc_encounter_objectid")+";");
				exportfile.append(personid+";");
				exportfile.append(rs.getString("oc_insurance_nr")+";");
				exportfile.append(rs.getString("oc_insurance_status")+";");
				exportfile.append((rs.getString("oc_insurance_insurancecategoryletter").equalsIgnoreCase("A")?"INPS":"CMSS")+";");
				exportfile.append(rs.getString("lastname")+";");
				exportfile.append(rs.getString("firstname")+";");
				exportfile.append(rs.getString("oc_prestation_code")+";");
				exportfile.append(rs.getString("oc_prestation_description")+";");
				exportfile.append(price+";");
				exportfile.append(quantity+";");
				exportfile.append(amo+";");
				exportfile.append(rs.getString("oc_patientinvoice_objectid")+";");
				boolean bAmoUserFound=false;
				try{
					PreparedStatement ps2=conn.prepareStatement("select OC_POINTER_VALUE from OC_POINTERS where OC_POINTER_KEY=? order by OC_POINTER_VALUE");
					ps2.setString(1,"AUTH."+mfp+"."+personid+"."+new SimpleDateFormat("yyyyMM").format(debetdate));
					ResultSet rs2=ps2.executeQuery();
					while(rs2.next()){
						String pointer = rs2.getString("OC_POINTER_VALUE");
						Date dValidUntil = new SimpleDateFormat("yyyyMMddHHmmss").parse(pointer.split(";")[0]);
						if(dValidUntil.after(debetdate)){
							PreparedStatement ps3=conn.prepareStatement("select lastname,firstname from adminview a,usersview b where a.personid=b.personid and b.userid=?");
							ps3.setInt(1, Integer.parseInt(pointer.split(";")[1]));
							ResultSet rs3=ps3.executeQuery();
							if(rs3.next()){
								exportfile.append(rs3.getString("lastname").toUpperCase()+", "+rs3.getString("firstname")+"\n");
							}
							else {
								exportfile.append(pointer.split(";")[1]+"\n");
							}
							rs3.close();
							ps3.close();
							bAmoUserFound=true;
							break;
						}
					}
					rs2.close();
					ps2.close();
					if(!bAmoUserFound){
						exportfile.append("?\n");
					}
				}
				catch (Exception e1) {
					e1.printStackTrace();
					exportfile.append("?\n");
				}
				hasdata=true;
			}
			System.out.println("hasdata="+hasdata);
			rs.close();
			ps.close();
			String title="The Global Health Barometer - TEST AMO extract CHU GT";
			String message="Message de test avec extraction de données de facturation pour CHU GT en annexe.\n" +
							"- Période de facturation couverte: du "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(mindate)+" au "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(maxdate)+"\n" +
							"- Nombre de prestations facturées: "+countdebets+"\n" +
							"- Montant total des prestations: "+totalprice+" XOF\n" +
							"- Montant total à charge de l'AMO: "+totalamo+" XOF\n\n" +
							"Colonnes de la table en annexe:\n" +
							"- PREST_ID: numéro unique de la prestation facturée\n" +
							"- PREST_DATE: date de la prestation\n" +
							"- CONTACT_TYPE: C=Consultation, H=Hospitalisation\n" +
							"- CONTACT_ID: numéro unique de la consultation ou de l'hospitalisation\n" +
							"- CHUGT_ID: numéro d'identification interne du bénéficiaire au CHU Gabriel Touré\n" +
							"- AMO_ID: numéro AMO du bénéficiaire\n" +
							"- AMO_STATUS: affiliate=Adhérent, child=Enfant, partner=Conjoint, parent=Parent\n" +
							"- AMO_SOURCE: INPS ou CMSS\n" +
							"- PAT_LASTNAME: nom du patient\n" +
							"- PAT_FIRSTNAME: prénom du patient\n" +
							"- PREST_CODE: code de la prestation au CHU Gabriel Touré\n" +
							"- PREST_NAME: dénomination de la prestation\n" +
							"- PREST_PRICE: prix (tarif) de la prestation\n" +
							"- PREST_QUANTITY: nombre de prestations réalisées\n" +
							"- INV_AMO: montant à charge de l'AMO\n" +
							"- INV_PATIENTREF: numéro de la facture patient qui reprend la prestation\n" +
							"- AUTH_AMO: agent AMO qui a autorisé la transaction\n\n" +
							"Message généré automatiquement le "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date())+" pour le CHU Gabriel Touré par le Global Health Barometer. " +
							"Veuillez ne pas répondre directement à ce message svp. " +
							"Pour toute information supplémentaire concernant la structure de l'annexe, vous pouvez contacter Tidiani Togola (tidianitogola@sante.gov.ml) " +
							"à l'Agence Nationale de Télésanté et d'Informatique Médicale (ANTIM).\n\n" +
							"Pour le Global Health Barometer\n" +
							"ICT4development - Vrije Universiteit Brussel\n" +
							"dr. Frank Verbeke\n" +
							"frank.verbeke@vub.ac.be\n" +
							"Coordinateur Santé";
			if(hasdata){
				System.out.println("sending message to: "+args[3]);
				BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(exportamofile));
				bufferedWriter.write(exportfile.toString());
				bufferedWriter.flush();
				bufferedWriter.close();
				Mail.sendMail(args[1], args[2], args[3], title, message,exportamofile,"exportAMO.csv");
				System.out.println("Message successfully sent");
				
			    ps = conn.prepareStatement("update oc_config set oc_value=? where oc_key='lastAMOexport'");
			    ps.setString(1,new SimpleDateFormat("yyyyMMddHHmmssSSS").format(maxdate));
			    ps.execute();
			    ps.close();
				System.out.println("lastAMOexport set to "+new SimpleDateFormat("yyyyMMddHHmmssSSS").format(maxdate));

			}
			conn.close();

		} catch (Exception e) {
			e.printStackTrace();
		}
		

	}

}
