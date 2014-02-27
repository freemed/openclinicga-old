<%@page import="org.dom4j.Document,org.dom4j.Element,org.dom4j.io.SAXReader,java.io.*,java.util.*,java.sql.*,be.mxs.common.util.db.*,java.text.*"%>
<%
	System.out.println("Storing CAISFF data");
	String result="<ERROR>";
	String message = request.getParameter("message");
	if(message!=null){
		try{
			System.setProperty("java.security.egd", "file:///dev/urandom");
			String sDriver=MedwanQuery.getInstance().getConfigString("CAISFFDatabaseConnectionDriver","oracle.jdbc.OracleDriver");
			System.out.println("Loading database driver "+sDriver);
			Class.forName(sDriver);	
			String sUrl=MedwanQuery.getInstance().getConfigString("CAISFFDatabaseConnectionURL","jdbc:oracle:thin:openclinic/overmeire@localhost:1521:XE");
			System.out.println("Connecting to database using "+sUrl);
		    Connection conn =  DriverManager.getConnection(sUrl);
			
		    System.out.println("Reading XML message");
			SAXReader reader = new SAXReader(false);
			Document document = reader.read(new ByteArrayInputStream(message.getBytes("UTF-8")));
			Element root = document.getRootElement();
		    System.out.println("Found root element "+root.getName());
		    System.out.println("Iterating through payments");
			Iterator payments = root.elementIterator("payment");
			int connects=0;
			while(payments.hasNext()){
				connects++;
				Element payment = (Element)payments.next();
				//We found the element, first let's check if the element doesn't exist yet
				PreparedStatement ps = conn.prepareStatement("select * from OC_FINANCE where SITE_ID=? and PREST_ID=? and PAYMENT_ID=?");
				System.out.print("ID "+payment.elementText("payment_id")+"."+payment.elementText("prest_id")+"... ");
				ps.setString(1,root.attributeValue("caisffid"));
				ps.setInt(2,Integer.parseInt(payment.elementText("prest_id")));
				ps.setInt(3,Integer.parseInt(payment.elementText("payment_id")));
				ResultSet rs = ps.executeQuery();
				if(!rs.next()){
					System.out.println(" is new");
					//The payment doesn't exist yet, let's store it
					rs.close();
					ps.close();
					ps = conn.prepareStatement("insert into OC_FINANCE(SITE_ID,PREST_ID,PREST_DATE,CONTACT_TYPE,CONTACT_ID,HOSP_ID,PAT_LASTNAME,PAT_FIRSTNAME,PREST_CODE,PREST_NAME,PREST_PRICE,PREST_QUANTITY,INV_AM,INV_PATIENT,INV_PATIENTREF,INV_PAID,INV_PERCENTPAID,PAYMENT_ID,PAYMENT_DATE,PAYMENT_AGENT,UPDATETIME) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
					ps.setString(1,root.attributeValue("caisffid"));
					ps.setInt(2,Integer.parseInt(payment.elementText("prest_id")));
					ps.setDate(3,new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(payment.elementText("prest_date")).getTime()));
					ps.setString(4,payment.elementText("contact_type"));
					ps.setInt(5,Integer.parseInt(payment.elementText("contact_id")));
					ps.setInt(6,Integer.parseInt(payment.elementText("hosp_id")));
					ps.setString(7,payment.elementText("pat_lastname"));
					ps.setString(8,payment.elementText("pat_firstname"));
					ps.setString(9,payment.elementText("prest_code"));
					ps.setString(10,payment.elementText("prest_name"));
					ps.setDouble(11,Double.parseDouble(payment.elementText("prest_price").replaceAll(",",".")));
					ps.setInt(12,Integer.parseInt(payment.elementText("prest_quantity")));
					ps.setDouble(13,Double.parseDouble(payment.elementText("inv_am").replaceAll(",",".")));
					ps.setDouble(14,Double.parseDouble(payment.elementText("inv_patient").replaceAll(",",".")));
					ps.setString(15,payment.elementText("inv_patientref"));
					ps.setDouble(16,Double.parseDouble(payment.elementText("inv_paid").replaceAll(",",".")));
					ps.setDouble(17,Double.parseDouble(payment.elementText("inv_percentpaid").replaceAll(",",".")));
					ps.setInt(18,Integer.parseInt(payment.elementText("payment_id")));
					ps.setDate(19,new java.sql.Date(new SimpleDateFormat("yyyyMMdd").parse(payment.elementText("payment_date")).getTime()));
					ps.setString(20,payment.elementText("payment_agent"));
					ps.setTimestamp(21,new java.sql.Timestamp(new java.util.Date().getTime()));
					ps.execute();
					ps.close();
				}
				else {
					System.out.println(" exists, skip");
					rs.close();
					ps.close();
				}
				if(connects%3==0){
					conn.close();
					conn =  DriverManager.getConnection(sUrl);
				}
			}
			conn.close();
			result="<OK>";
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<%= result %>