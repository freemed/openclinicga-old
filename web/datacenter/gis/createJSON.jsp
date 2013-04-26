<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="uk.org.primrose.pool.core.*,
                be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.util.system.Debug,
                be.mxs.common.util.system.ScreenHelper,
                java.text.DecimalFormat,
                java.util.*,
                java.io.*,
                java.sql.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    static Hashtable parametersAndTheirTable, parametersAndTheirConversion, parametersAndTheirDataScale,
           countryCodes;
    static Vector countryColors;

    static {
	    //*********************************************************************
    	//*** parameter --> table *********************************************
	    //*********************************************************************
	    parametersAndTheirTable = new Hashtable();
	    
	    // table = dc_simplevalues
	    parametersAndTheirTable.put("vis.counter.0","dc_simplevalues");   
	    parametersAndTheirTable.put("vis.counter.0.0","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.1","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.2","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.2.0","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.3","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.3.0","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.4","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.4.0","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.5","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.5.0","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.6","dc_simplevalues");
	    parametersAndTheirTable.put("vis.counter.6.0","dc_simplevalues");
	    
	    // table = dc_encounterdiagnosisvalues
	    parametersAndTheirTable.put("vis.counter.7","dc_encounterdiagnosisvalues");
	    parametersAndTheirTable.put("vis.counter.7.0","dc_encounterdiagnosisvalues");
	    parametersAndTheirTable.put("vis.counter.7.0.0","dc_encounterdiagnosisvalues");
	    parametersAndTheirTable.put("vis.counter.7.1","dc_encounterdiagnosisvalues");
	    parametersAndTheirTable.put("vis.counter.7.1.0","dc_encounterdiagnosisvalues");
	    
	    // table = dc_mortalityvalues
	    parametersAndTheirTable.put("vis.counter.8","dc_mortalityvalues");
	    parametersAndTheirTable.put("vis.counter.8.0","dc_mortalityvalues");
	    parametersAndTheirTable.put("vis.counter.8.1","dc_mortalityvalues");
	    
	    // table = dc_bedoccupancyvalues
	    parametersAndTheirTable.put("vis.counter.9","dc_bedoccupancyvalues");
	    
	    // table = dc_financialvalues
	    parametersAndTheirTable.put("vis.counter.10","dc_financialvalues");
	    parametersAndTheirTable.put("vis.counter.10.0","dc_financialvalues");
	    parametersAndTheirTable.put("vis.counter.10.1","dc_financialvalues");
	    parametersAndTheirTable.put("vis.counter.10.2","dc_financialvalues");

	    //*********************************************************************
    	//*** parameter --> conversion ****************************************
	    //*********************************************************************
	    parametersAndTheirConversion = new Hashtable();
	    
	    // conversion = type of 'core'
	    parametersAndTheirConversion.put("vis.counter.0","core.1");   
	    parametersAndTheirConversion.put("vis.counter.0.0","core.1");
	    parametersAndTheirConversion.put("vis.counter.1","core.2");
	    parametersAndTheirConversion.put("vis.counter.2","core.4.1");
	    parametersAndTheirConversion.put("vis.counter.2.0","core.4.1");
	    parametersAndTheirConversion.put("vis.counter.3","core.4.2");
	    parametersAndTheirConversion.put("vis.counter.3.0","core.4.2");
	    parametersAndTheirConversion.put("vis.counter.4","core.5");
	    parametersAndTheirConversion.put("vis.counter.4.0","core.5");
	    parametersAndTheirConversion.put("vis.counter.5","core.11");
	    parametersAndTheirConversion.put("vis.counter.5.0","core.11");
	    parametersAndTheirConversion.put("vis.counter.6","core.17");
	    parametersAndTheirConversion.put("vis.counter.6.0","core.17");
	    
	    // conversion = 'admission', 'visit' or either one
	    parametersAndTheirConversion.put("vis.counter.7",""); // admission OR visit
	    parametersAndTheirConversion.put("vis.counter.7.0","");
	    parametersAndTheirConversion.put("vis.counter.7.0.0","admission");
	    parametersAndTheirConversion.put("vis.counter.7.1","admission");
	    parametersAndTheirConversion.put("vis.counter.7.1.0","visit");
	    parametersAndTheirConversion.put("vis.counter.8","visit");
	    
	    // conversion = no conversion
	    parametersAndTheirConversion.put("vis.counter.8.0","");
	    parametersAndTheirConversion.put("vis.counter.8.1","");
	    
	    // conversion = no conversion
	    parametersAndTheirConversion.put("vis.counter.9","");
	    
	    // conversion = type of 'financial'
	    parametersAndTheirConversion.put("vis.counter.10","financial.0");
	    parametersAndTheirConversion.put("vis.counter.10.0","financial.1");
	    parametersAndTheirConversion.put("vis.counter.10.1","financial.2");
	    parametersAndTheirConversion.put("vis.counter.10.2","financial.3");

	    //*********************************************************************
    	//*** parameter --> dataScale *****************************************
	    //*********************************************************************
	    parametersAndTheirDataScale = new Hashtable();
	    
	    parametersAndTheirDataScale.put("vis.counter.0","1");    // aantal patiënten in de database (t1) 
	    parametersAndTheirDataScale.put("vis.counter.0.0","1");  // aantal nieuw geregistreerde patiënten (t1 - t0)
	    parametersAndTheirDataScale.put("vis.counter.1","1");    // aantal gebruikers in de database (t1)
	    parametersAndTheirDataScale.put("vis.counter.2","1");    // aantal hospitalisaties in de database (t1)
	    parametersAndTheirDataScale.put("vis.counter.2.0","1");  // aantal nieuw geregistreerde hospitalisaties (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.3","1");    // aantal consultaties in de database (t1)
	    parametersAndTheirDataScale.put("vis.counter.3.0","1");  // aantal nieuw geregistreerde consultaties (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.4","1");    // aantal prestaties in de database (t1)
	    parametersAndTheirDataScale.put("vis.counter.4.0","1");  // aantal nieuw geregistreerde prestaties (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.5","1");    // aantal patiëntfacturen in de database (t1)
	    parametersAndTheirDataScale.put("vis.counter.5.0","1");  // aantal nieuw geregistreerde patiëntfacturen (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.6","1");    // aantal lab-analyses in de database  (t1)
	    parametersAndTheirDataScale.put("vis.counter.6.0","1");  // aantal nieuw geregistreerde lab-analyses in de database (t1)
	    
	    parametersAndTheirDataScale.put("vis.counter.7","1");     // aantal patiënten in de database met diagnose X (t1)
	    parametersAndTheirDataScale.put("vis.counter.7.0","1");   // aantal gehospitaliseerde patiënten met diagnose X (t1)
	    parametersAndTheirDataScale.put("vis.counter.7.0.0","1"); // aantal nieuwe gehospitaliseerde patiënten met diagnoses X (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.7.1","1");   // aantal consultaties voor patiënten in database met diagnose X (t1)
	    parametersAndTheirDataScale.put("vis.counter.7.1.0","1"); // aantal nieuwe consultaties voor patiënten met diagnoses X (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.8","2");     // aantal nieuwe overlijdens (t1-t0)
	    
	    parametersAndTheirDataScale.put("vis.counter.8.0","2");   // aantal nieuwe overlijdens voor diagnose X (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.8.1","2");   // relatieve mortaliteit voor diagnose X (t1-t0)	    
	    parametersAndTheirDataScale.put("vis.counter.9","2");     // bedbezettingsgraad (t1)
	    
	    parametersAndTheirDataScale.put("vis.counter.10","0.05");    // totale inkomsten over periode (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.10.0","0.05");  // totale patiënt-inkomsten over periode (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.10.1","0.05");  // totale verzekeraar-inkomsten over periode (t1-t0)
	    parametersAndTheirDataScale.put("vis.counter.10.2","0.05");  // totale extra-verzekeraar-inkomsten over periode (t1-t0)

	    //*********************************************************************
		//*** load African country codes **************************************
	    //*********************************************************************
		countryCodes = new Hashtable();		
		countryCodes.put("Algeria".toLowerCase(),"DZ");
		countryCodes.put("Angola".toLowerCase(),"AO");
		countryCodes.put("Ascension".toLowerCase(),"SH");
		countryCodes.put("Benin".toLowerCase(),"BJ");
		countryCodes.put("Botswana".toLowerCase(),"BW");
		countryCodes.put("Burkina Faso".toLowerCase(),"BF");
		countryCodes.put("Burundi".toLowerCase(),"BI");
		countryCodes.put("Cameroon".toLowerCase(),"CM");
		countryCodes.put("Cape Verde".toLowerCase(),"CV");
		countryCodes.put("Central African Rep".toLowerCase(),"CF");
		countryCodes.put("Chad".toLowerCase(),"TD");
		countryCodes.put("Comoros".toLowerCase(),"KM");
		countryCodes.put("Congo".toLowerCase(),"CG");
		countryCodes.put("Djibouti".toLowerCase(),"DJ");
		countryCodes.put("Egypt".toLowerCase(),"EG");
		countryCodes.put("Guinea".toLowerCase(),"GQ");
		countryCodes.put("Eritrea".toLowerCase(),"ER");
		countryCodes.put("Ethiopia".toLowerCase(),"ET");
		countryCodes.put("Gabon".toLowerCase(),"GA");
		countryCodes.put("Gambia".toLowerCase(),"GM");
		countryCodes.put("Ghana".toLowerCase(),"GH");
		countryCodes.put("Guinea Bissau".toLowerCase(),"GW");
		countryCodes.put("Guinea".toLowerCase(),"GN");
		countryCodes.put("Ivory Coast".toLowerCase(),"CI");
		countryCodes.put("Kenya".toLowerCase(),"KE");
		countryCodes.put("Lesotho".toLowerCase(),"LS");
		countryCodes.put("Liberia".toLowerCase(),"LR");
		countryCodes.put("Libya".toLowerCase(),"LY");
		countryCodes.put("Madagascar".toLowerCase(),"MG");
		countryCodes.put("Malawi".toLowerCase(),"MW");
		countryCodes.put("Mali".toLowerCase(),"ML");
		countryCodes.put("Mauritania".toLowerCase(),"MR");
		countryCodes.put("Mauritius".toLowerCase(),"MU");
		countryCodes.put("Mayotte".toLowerCase(),"YT");
		countryCodes.put("Morocco".toLowerCase(),"MA");
		countryCodes.put("Mozambique".toLowerCase(),"MZ");
		countryCodes.put("Namibia".toLowerCase(),"NA");
		countryCodes.put("Niger".toLowerCase(),"NE");
		countryCodes.put("Nigeria".toLowerCase(),"NG");
		countryCodes.put("Principe".toLowerCase(),"ST");
		countryCodes.put("Reunion".toLowerCase(),"RE"); 
		countryCodes.put("Rwanda".toLowerCase(),"RW"); 
		countryCodes.put("Sao Tome".toLowerCase(),"ST"); 
		countryCodes.put("Senegal".toLowerCase(),"SN"); 
		countryCodes.put("Seychelles".toLowerCase(),"SC"); 
		countryCodes.put("Sierra Leone".toLowerCase(),"SL"); 
		countryCodes.put("Somalia".toLowerCase(),"SO"); 
		countryCodes.put("South Africa".toLowerCase(),"ZA");
		countryCodes.put("St. Helena".toLowerCase(),"SH"); 
		countryCodes.put("Sudan".toLowerCase(),"SD"); 
		countryCodes.put("Swaziland".toLowerCase(),"SZ"); 
		countryCodes.put("Tanzania".toLowerCase(),"TZ"); 
		countryCodes.put("Togo".toLowerCase(),"TG"); 
		countryCodes.put("Tunisia".toLowerCase(),"TN"); 
		countryCodes.put("Uganda".toLowerCase(),"UG"); 
		countryCodes.put("Zaire".toLowerCase(),"CD"); 
		countryCodes.put("Zambia".toLowerCase(),"ZM"); 
		countryCodes.put("Zanzibar".toLowerCase(),"TZ"); 
		countryCodes.put("Zimbabwe".toLowerCase(),"ZW"); 
		
		// synonyms / additions
		countryCodes.put("Belgium".toLowerCase(),"BE");
		countryCodes.put("DRC".toLowerCase(),"CG");
		countryCodes.put("Democratic Republic of the Congo".toLowerCase(),"CG");
		countryCodes.put("DRC".toLowerCase(),"CG");
		countryCodes.put("Somalia Republic".toLowerCase(),"SO"); 
		countryCodes.put("Senegal Republic".toLowerCase(),"SN"); 
		countryCodes.put("Mayotte Island".toLowerCase(),"YT");
		countryCodes.put("Mali Republic".toLowerCase(),"ML");
		countryCodes.put("Gabon Republic".toLowerCase(),"GA");
		countryCodes.put("Equatorial Guinea".toLowerCase(),"GQ"); 
		countryCodes.put("Chad Republic".toLowerCase(),"TD");
		countryCodes.put("Republic of Benin".toLowerCase(),"BJ");
		countryCodes.put("Cape Verde Islands".toLowerCase(),"CV");
		countryCodes.put("Central African Republic".toLowerCase(),"CF");

	    //*********************************************************************
		//*** country colors **************************************************
	    //*********************************************************************
	    // 10 colors suffice for any amount of values to display --> %10
		countryColors = new Vector();
		countryColors.add("990099"); // purple, rose
		countryColors.add("6622cc"); // purple, violet
		countryColors.add("990000"); // red
		countryColors.add("DC3912"); // dark orange, reddish
		countryColors.add("FF9900"); // light orange, kaki
		countryColors.add("ffdd00"); // yellow
		countryColors.add("009900"); // green
		countryColors.add("33cc44"); // green, light
		countryColors.add("000099"); // blue, navy
		countryColors.add("33ddcc"); // blue, light
    }

    //### INNER CLASS : Server ####################################################################
    private class Server implements Comparable {
       public int id;
       public String coordsLAT;
       public String coordsLONG;
       public String location;
       public int patientCount;
       public double percentage;
       public int sum1;
       public int sum2;
       public String dataType;
       public String dataDate;
       
       public Server(){
    	   // init
    	   this.id = 0;
    	   this.coordsLAT = "";
    	   this.coordsLONG = "";    	   
    	   this.location = "";
    	   this.patientCount = 0;
    	   this.percentage = 0;
    	   this.sum1 = 0;
    	   this.sum2 = 0;    	   
    	   this.dataType = "";
    	   this.dataDate = "";
       }

       //--- TO JSON ----------------------------------------------------------
       // { "serviceId":8,"coordsLAT":"2.00","coordsLONG":"30.00","value":16,"dataDate":"20/12/2012","location":"Nyamata, Rwanda" },
       public String toJSON(boolean isLastRecord){    	   
   	       String sJSON = "{"+
		                   "\"serviceId\":"+this.id+","+
		                   "\"coordsLAT\":\""+this.coordsLAT+"\","+
		                   "\"coordsLONG\":\""+this.coordsLONG+"\",";
		           
   	       if(this.dataType.equals("percentage")){
		       sJSON+= "\"value\":"+this.percentage+",";
	           sJSON+= "\"sum1\":"+this.sum1+","+
	                   "\"sum2\":"+this.sum2+",";
		       
		       /*
		       // smallest sum up front
		       if(this.sum1 <= this.sum2){
		           sJSON+= "\"sum1\":"+this.sum1+","+
		                   "\"sum2\":"+this.sum2+",";
		       }
		       else{
		    	   // switch
			       sJSON+= "\"sum1\":"+this.sum2+","+
			               "\"sum2\":"+this.sum1+",";
		       }
		       */
   	       }
   	       else{
		       sJSON+= "\"value\":"+this.patientCount+",";
   	       }	                   
		           
		   sJSON+=  "\"dataDate\":\""+this.dataDate+"\","+
		            "\"location\":\""+this.location+"\""+
		           "}"+(isLastRecord?"":",")+"\r\n";
		                  
	       return sJSON;
       }   
       
       //--- COMPARE TO ------------------------------------------------------------------------------
       public int compareTo(Object o){
           int comp;
           
           if(o.getClass().isInstance(this)){
       	       if(this.dataType.equals("percentage")){
                   comp = (int)(this.percentage - ((Server)o).percentage);
       	       }
       	       else{
       	    	   // reverse
                   comp = -(this.patientCount - ((Server)o).patientCount);
       	       }
           }
           else{
               throw new ClassCastException();
           }
           
           return comp;
       }

       //--- EQUALS ----------------------------------------------------------------------------------
       public boolean equals(Object o){
           if(this==o) return true;           
           if(!(o instanceof Server)) return false;
           
           final Server server = (Server)o;
           return server.id == (this.id);
       }
    
    }

    //#############################################################################################
    //### COMMON FUNCTIONS ########################################################################
    //#############################################################################################	

    //--- NORMALIZE SPECIAL CHARACTERS ------------------------------------------------------------
    private String normalizeSpecialCharacters(String sTest){
        sTest = sTest.replaceAll("´","'");

    	// lowercase
        sTest = sTest.replaceAll("é","e");
        sTest = sTest.replaceAll("è","e");
        sTest = sTest.replaceAll("ê","e");
        sTest = sTest.replaceAll("ë","e");
        
        sTest = sTest.replaceAll("ì","i");
        sTest = sTest.replaceAll("í","i");
        sTest = sTest.replaceAll("î","i");
        sTest = sTest.replaceAll("ï","i");
        
        sTest = sTest.replaceAll("ó","o");
        sTest = sTest.replaceAll("ò","o");
        sTest = sTest.replaceAll("ô","o");
        sTest = sTest.replaceAll("ö","o");
        
        sTest = sTest.replaceAll("á","a");
        sTest = sTest.replaceAll("à","a");
        sTest = sTest.replaceAll("â","a");
        sTest = sTest.replaceAll("ä","a");
        
        sTest = sTest.replaceAll("ú","u");
        sTest = sTest.replaceAll("ù","u");
        sTest = sTest.replaceAll("û","u");
        sTest = sTest.replaceAll("ü","u");
        
        // uppercase
        sTest = sTest.replaceAll("É","E");
        sTest = sTest.replaceAll("È","E");
        sTest = sTest.replaceAll("Ê","E");
        sTest = sTest.replaceAll("Ë","E");

        sTest = sTest.replaceAll("Í","I");
        sTest = sTest.replaceAll("Ì","I");
        sTest = sTest.replaceAll("Î","I");
        sTest = sTest.replaceAll("Ï","I");

        sTest = sTest.replaceAll("Ó","O");
        sTest = sTest.replaceAll("Ò","O");
        sTest = sTest.replaceAll("Ô","O");
        sTest = sTest.replaceAll("Ö","O");
        
        sTest = sTest.replaceAll("Á","A");
        sTest = sTest.replaceAll("À","A");
        sTest = sTest.replaceAll("Â","A");
        sTest = sTest.replaceAll("Ä","A");

        sTest = sTest.replaceAll("Ù","U");
        sTest = sTest.replaceAll("Ú","U");
        sTest = sTest.replaceAll("Û","U");
        sTest = sTest.replaceAll("Ü","U");
        
        return sTest;
    }
 
    //--- GET CONNECTION --------------------------------------------------------------------------
    private Connection getConnection(String sDatabaseName){
        Connection conn = null;

        /*
        if(sDatabaseName.equals("admin")){
        	conn = MedwanQuery.getInstance().getAdminConnection();
        }
        else if(sDatabaseName.equals("openclinic")){
        	conn = MedwanQuery.getInstance().getOpenclinicConnection();
        }
        else if(sDatabaseName.equals("stats")){
        	conn = MedwanQuery.getInstance().getStatsConnection();
        }
        */
        
		try{		      
	        List loadedPools = PoolLoader.getLoadedPools();                                
	        Iterator poolIter = loadedPools.iterator();
	        Pool pool;
	        while(poolIter.hasNext()){
	            pool = (Pool)poolIter.next();
	            	            
	            if(pool.getPoolName().equals(sDatabaseName)){
	            	conn = pool.getConnection();
	            	break;
	            }
	        }
		}
		catch(Exception e){
			e.printStackTrace();
		}
        
        return conn;
    } 
    
    /*
    //--- GET SIMPLE CONNECTION -------------------------------------------------------------------
	//conn = getSimpleConnection("obelix.mxs.be","ocstats_dbo");
    private Connection getSimpleConnection(String sServer, String sDBName) {
        String DB_CONN_STRING = "jdbc:mysql://"+sServer+":3306/"+sDBName; 
        String DRIVER_CLASS_NAME = "org.gjt.mm.mysql.Driver";
        String USER_NAME = "root";
        String PASSWORD = "";
        
        Connection result = null;
        try{
            Class.forName(DRIVER_CLASS_NAME).newInstance();
        }
        catch(Exception ex){
        	Debug.println("Check classpath. Cannot load db driver: " + DRIVER_CLASS_NAME);
        }

        try{
            result = DriverManager.getConnection(DB_CONN_STRING, USER_NAME, PASSWORD);
        }
        catch(SQLException e){
             Debug.println("Driver loaded, but cannot connect to db: " + DB_CONN_STRING);
        }
        
        return result;
    }
    */
	
	//--- COUNT TOKENS ----------------------------------------------------------------------------
	private int countTokens(String sValue, String sToken){
		int tokenCount = 0;

		while(sValue.indexOf(sToken) > -1){
		    tokenCount++;
			sValue = sValue.substring(sValue.indexOf(sToken)+1,sValue.length());
		}

		return tokenCount;
		
		/*
        StringTokenizer tokenizer = new StringTokenizer(sValue,sToken);
        int tokenCount = tokenizer.countTokens();
        */
	}

	//--- CREATE TEMP DIR -------------------------------------------------------------------------
	// create tempdir with specified name if it does not exist.
	//---------------------------------------------------------------------------------------------
	private File createTempDir(String tempDirName){
	    File tempDir = new File(tempDirName);
	 
	    if(!tempDir.exists()){
	        tempDir.mkdirs();
	        Debug.println("Created dir(s) : "+tempDirName);
	    }
	
	    return tempDir;
	}

	//--- VECTOR TO STRING ------------------------------------------------------------------------
	private String vectorToString(Vector vector, String sDelimeter){
	    return vectorToString(vector,sDelimeter,true);
	}
	
	private String vectorToString(Vector vector, String sDelimeter, boolean addApostrophes){
		StringBuffer stringBuffer = new StringBuffer();
	    
	    for(int i=0; i<vector.size(); i++){
	    	if(addApostrophes) stringBuffer.append("'");
	        stringBuffer.append(((Object)vector.get(i)).toString());	        
	    	if(addApostrophes) stringBuffer.append("'");
	        
	    	// delimeter, except for last item
	        if(i<vector.size()-1){
	        	stringBuffer.append(sDelimeter);
	        }
	    }		    
	    
	    return stringBuffer.toString();
	}
	
    //#############################################################################################
    //### END COMMON FUNCTIONS ####################################################################
    //#############################################################################################	
    	
	//--- VECTOR TO JSON --------------------------------------------------------------------------
	/*	
	  var data = {
	    "mapTitle":"Number of patients (01/01/2013)",
	    "dataScale":1.5,
	    "services": [
	      { "serviceId":8,"coordsLAT":"2.00","coordsLONG":"30.00","patientCount":16,"dataDate":"15/05/2011","location":"Nyamata, Rwanda" },
	      { "serviceId":10,"coordsLAT":"4.00","coordsLONG":"32.00","patientCount":29,"dataDate":"23/08/2011","location":"Cyangugu, Rwanda" }
        ]
      }
	*/
    public StringBuffer vectorToJSON(Vector vector, String sItemsType, String sParameter, String sTitle){
		StringBuffer sJSON = new StringBuffer();
		
		// percentage == relative
		String sRelativeOrAbsolute = "absolute";
		if(sParameter.equalsIgnoreCase("vis.counter.8.1") || sParameter.equalsIgnoreCase("vis.counter.9")){
			sRelativeOrAbsolute = "relative";  
		}
		
		// open main array
		sJSON.append("var data = {\r\n")
             .append("\"queryDate\":\""+ScreenHelper.fullDateFormat.format(new java.util.Date())+"\",\r\n") // now
             .append("\"relativeOrAbsolute\":\""+sRelativeOrAbsolute+"\",\r\n")
             .append("\"mapTitle\":\""+sTitle+"\",\r\n")
             .append("\"dataScale\":"+getDataScale(sParameter)+",\r\n")
	         .append("\""+sItemsType+"\": [\r\n"); // services
		
		boolean lastRecord;
        for(int i=0; i<vector.size(); i++){
        	lastRecord = (i==vector.size()-1);
         	
        	// comma for all except last record
        	sJSON.append(((Server)(vector.get(i))).toJSON(lastRecord));   
        }

        // close main array
        sJSON.append("]\r\n").
             append("}\r\n");
        
        return sJSON;
    }
	
	//--- VECTOR TO IMG ---------------------------------------------------------------------------
	// first order data per country, then generate a Google-IMG-tag
	/*	
      <img src="https://chart.googleapis.com/chart?chs=650x460
       &cht=map:fixed=-40,-30,40,70
       &chco=B3BCC0|DC3912|FF9900|109618|990099
       &chld=CD|ET|RW|KE
       &chdl=Congo|Ethiopia|Rwanda|Kenia
       &chm=f1000,000000,0,0,10|
            f2000,000000,0,1,10|
            f3000,000000,0,2,10|
            f4000,000000,0,3,10
       &chtt=Hospitals+in+Africa
       &chts=676767,20"
       width="700" height="500" alt="Hospitals in Africa" style="border:1px solid #ccc"/>	
	*/
    public StringBuffer vectorToIMG(Vector vector, String sTitle){		
		//*** a : count values per country ************************************
		// (instead of per hospital/town in the specified vector)
		Hashtable countryValues = new Hashtable();
		String sLocation, sCountryName, sDataType = "";
		Server server;
		
        for(int i=0; i<vector.size(); i++){
            server = (Server)vector.get(i);
        	 	
         	// country name
         	sCountryName = "unknown";
         	if(server.location.length() > 0 && server.location.indexOf(", ") > -1){
         	    String[] parts = server.location.split("\\,");
         		
         		if(parts.length > 0){
         		    sCountryName = ScreenHelper.checkString(parts[parts.length-1]);
         		    if(sCountryName.equalsIgnoreCase("Democratic Republic of the Congo")){
         		    	sCountryName = "DRC";         		    	
         		    }
         		    sCountryName = sCountryName.toLowerCase();
         		    
         		    // calculate percentage from sum1 and sum2 (per country, called 'value' in json file))
         		    if(server.dataType.equals("percentage")){
         		    	sDataType = server.dataType; // to use further on
         		    	
	         		    if(countryValues.get(sCountryName)==null){
	         		    	String sNewSums = (0+server.sum1)+"$"+(0+server.sum2);
	         		        countryValues.put(sCountryName,sNewSums);
	         		    	Debug.println("*** ADD(0,'"+sCountryName+"') - sum1:"+0+", sum2:"+0+" --> "+sNewSums); // todo
	         		    }
	         		    else{
	         		    	String sSums = (String)countryValues.get(sCountryName);
	         		    	String[] sums = sSums.split("\\$");
	         		    	int sum1 = Integer.parseInt(sums[0]),
	         		            sum2 = Integer.parseInt(sums[1]);
	         		    	String sNewSums = (sum1+server.sum1)+"$"+(sum2+server.sum2);
	         		    	
	         		    	Debug.println("*** ADD(x,'"+sCountryName+"') - sum1:"+sum1+", sum2:"+sum2+" --> "+sNewSums); // todo
	         		        countryValues.put(sCountryName,sNewSums);
	         		    }
         		    }
         		    // just display the patientCount (called 'value' in json file)
         		    else{
         		    	if(countryValues.get(sCountryName)==null){
	         		        countryValues.put(sCountryName,server.patientCount);
	         		    	Debug.println("*** ADD(0,'"+sCountryName+"') - patientCount = "+server.patientCount); // todo
	         		    }
	         		    else{
	         		    	Integer value = (Integer)countryValues.get(sCountryName);
	         		    	Debug.println("*** ADD(x,'"+sCountryName+"') - "+value+"+patientCount("+server.patientCount+") = "+(value+server.patientCount)); // todo
	         		        countryValues.put(sCountryName,value+server.patientCount);
	         		    }
         		    }
         		}
         	} 
        }		
		
		//***** b : compose IMG tag *******************************************
		StringBuffer sIMG = new StringBuffer();
		
		// open image tag and src-attribute
		sIMG.append("<img src=\"https://chart.googleapis.com/chart?chs=652x460"); // max 300.000 pixels
		
		// zoom
	    sIMG.append("&cht=map:fixed=-20,-20,30,50"); // only MXS' active countries focussed 
	    //sIMG.append("&cht=map:fixed=-30,-20,30,50"); // equal trim above as below
		//sIMG.append("&cht=map:fixed=-40,-30,40,70"); // Africa completely on map 
		
		//*** data per country ****************************
		// chco (colors per country) &
		// chld (country-codes) &
		// chdl (country-names) &
		// chm (data to visualise)
		String chld = "&chld=",  chdl = "&chdl=", chco = "&chco=B3BCC0|", chm = "&chm=";
		String sCountryCode, sCountryColor;
		double countryValue;
		int countryIdx = 0;

		DecimalFormat deci = new DecimalFormat("#,###.###"); // 1.482,465
    	if(sDataType.equals("percentage")){
		    deci = new DecimalFormat("0.#"); // 23,1
    	}
    	
		Enumeration countryNameEnum = countryValues.keys();
        while(countryNameEnum.hasMoreElements()){
        	sCountryName = (String)countryNameEnum.nextElement();
        	        	               
        	sCountryCode = (String)countryCodes.get(sCountryName); // code according to name
        	sCountryColor = (String)countryColors.get(countryIdx%10); // just the next color
        	
        	if(sDataType.equals("percentage")){
        		String sSums = (String)countryValues.get(sCountryName);
 		    	String[] sums = sSums.split("\\$");
 		    	int sum1 = Integer.parseInt(sums[0]),
 		            sum2 = Integer.parseInt(sums[1]);
        	    countryValue = ((double)sum1 / (double)sum2) * (double)100; // percentage
        	    Debug.println("sum1 ("+sCountryCode+") : "+sum1); // todo
        	    Debug.println("sum2 ("+sCountryCode+") : "+sum2); // todo
        	    Debug.println("countryValue ("+sCountryCode+") : "+countryValue); // todo
        	}
        	else{
        	    countryValue = ((Integer)countryValues.get(sCountryName)).intValue();
        	}
    		Debug.println("IMG : ["+countryIdx+"] "+sCountryCode+" ('"+sCountryName+"') : "+countryValue); // todo
    		
        	// first letter uppercase
        	sCountryName = sCountryName.substring(0,1).toUpperCase()+sCountryName.substring(1);
        	
    	    chld+= sCountryCode+"|";
        	chdl+= sCountryName+" ("+sCountryCode+") |";
        	chco+= sCountryColor+"|";  
        	
        	if(sDataType.equals("percentage")){
    		    chm+= "f"+sCountryName+": "+deci.format(countryValue).replaceAll(",",".")+"%,000000,0,"+countryIdx+",10|"; // %
        	}
        	else{
        		chm+= "f"+sCountryName+": "+deci.format(countryValue)+",000000,0,"+countryIdx+",10|";
        	}        	
    		
    		countryIdx++;
        }
        
        chld = chld.substring(0,chld.length()-1);
		chdl = chdl.substring(0,chdl.length()-1);
        chco = chco.substring(0,chco.length()-1);
		chm = chm.substring(0,chm.length()-1); 
		
	    sIMG.append(chld);	    
	    sIMG.append(chdl);	
	    sIMG.append(chco);	        
	    sIMG.append(chm);		    		
		//*************************************************
		
        // chtt (title)
        //sTitle = HTMLEntities.htmlentities(sTitle);
		sTitle = normalizeSpecialCharacters(sTitle);
        sIMG.append("&chtt="+sTitle.replaceAll(" ","+"));
        			
        // close src-attribute
        sIMG.append("&chts=000000,12\" ");
                			
        // close img tag        
        sIMG.append("width=\"652\" height=\"460\" alt=\""+sTitle+"\" style=\"border:1px solid #ccc\"/>");
        
        return sIMG;
    }
	
	//--- LOAD COORDS FROM FILE -------------------------------------------------------------------
	private Hashtable loadCoordsFromFile(){
		Hashtable coordsPerService = new Hashtable();		
		BufferedReader r = null;
        String[] coords;
        String sFileUri = "";
        int serviceId, lineCount = 0;

		try{
			// read csv	
			//String sContextPath = MedwanQuery.getInstance().getConfigString("contextpath");
			String sContextPath = "c:/projects/openclinic/web"; // todooooooooooooooooooooo
			sFileUri = sContextPath+"/datacenter/gis/googleMaps/data/coords.csv";
			FileReader reader = new FileReader(sFileUri);
	        r = new BufferedReader(reader);
			
	        String sLine;
	        while((sLine = r.readLine())!=null){
				sLine = ScreenHelper.checkString(sLine);
				
				if(sLine.length()==0) continue;
				else{
					Debug.println("["+lineCount+"] : "+sLine);
					lineCount++;
					
					if(sLine.indexOf(";") > 0 && sLine.indexOf(",") > 0){
		                serviceId = Integer.parseInt(sLine.split(";")[0]);
					
		                String sCoords = (String)(sLine.split(";")[1]); 
					    coords = new String[2];
				        coords[0] = (String)(sCoords.split(",")[0]);
                        coords[1] = (String)(sCoords.split(",")[1]); 
                    
				        coordsPerService.put(serviceId,coords); 
				    }
				}
            }
		}
		catch(Exception e){
			e.printStackTrace();	
		}
		finally{
			try{
		        if(r!=null) r.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}

		Debug.println("Loaded "+coordsPerService.size()+" coords from '"+sFileUri+"'"); 
		return coordsPerService;
	}
	
	//--- PARAMETER REFERS TO TABLE ---------------------------------------------------------------
	private boolean parameterRefersToTable(String sParameter, String sTable){
		return (ScreenHelper.checkString((String)parametersAndTheirTable.get(sParameter)).startsWith(sTable));
	}
	
	//--- CONVERT PARAMETER -----------------------------------------------------------------------
	private String convertParameter(String sParameter){
		return (String)parametersAndTheirConversion.get(sParameter);
	}

    //--- GET DATA SCALE --------------------------------------------------------------------------
    private double getDataScale(String sParameter){
        double dataScale = 1.0; // default, no scaling
        
        String sDataScale = ScreenHelper.checkString((String)parametersAndTheirDataScale.get(sParameter.toLowerCase()));
        if(sDataScale.length() > 0){
        	dataScale = Double.parseDouble(sDataScale);
        }
         
        return dataScale;
    }
	
	//--- IS PARAMETER ABOUT NEW DATA -------------------------------------------------------------
	private boolean isParameterAboutNewData(String sParameter, int requiredDotCount){
		Debug.println("isParameterAboutNewData ("+sParameter+") : "+(sParameter.endsWith(".0") && countTokens(sParameter,".") >= requiredDotCount)); // todo
		return (sParameter.endsWith(".0") && countTokens(sParameter,".") >= requiredDotCount);
		
		/*
		      vis.counter.0		core.1		aantal patiënten in de database (t1)
		  --> vis.counter.0.0	core.1		aantal nieuw geregistreerde patiënten (t1 - t0)
			  vis.counter.1		core.2		aantal gebruikers in de database (t1)
			  vis.counter.2		core.4.1	aantal hospitalisaties in de database (t1)
		  --> vis.counter.2.0	core.4.1	aantal nieuw geregistreerde hospitalisaties (t1-t0)
			  vis.counter.3		core.4.2	aantal consultaties in de database (t1)
		  --> vis.counter.3.0	core.4.2	aantal nieuw geregistreerde consultaties (t1-t0)
			  vis.counter.4		core.5		aantal prestaties in de database (t1)
		  --> vis.counter.4.0	core.5		aantal nieuw geregistreerde prestaties (t1-t0)
			  vis.counter.5		core.11		aantal patiëntfacturen in de database (t1)
	 	  --> vis.counter.5.0	core.11		aantal nieuw geregistreerde patiëntfacturen (t1-t0)
			  vis.counter.6		core.17		aantal lab-analyses in de database  (t1)
		  --> vis.counter.6.0	core.17		aantal nieuw geregistreerde lab-analyses in de database (t1-t0)
		  
			  vis.counter.7					aantal patiënten in de database met diagnose X (t1)
			  vis.counter.7.0				aantal gehospitaliseerde patiënten met diagnose X (t1)
		  --> vis.counter.7.0.0				aantal nieuwe gehospitaliseerde patiënten met diagnoses X (t1-t0)
			  vis.counter.7.1				aantal consultaties voor patiënten in database met diagnose X (t1)
		  --> vis.counter.7.1.0				aantal nieuwe consultaties voor patiënten met diagnoses X (t1-t0)
		  --> vis.counter.8					aantal nieuwe overlijdens (t1-t0)
		  --> vis.counter.8.0				aantal nieuwe overlijdens voor diagnose X (t1-t0)
		  --> vis.counter.8.1				relatieve mortaliteit voor diagnose X (t1-t0)
			  vis.counter.9					bedbezettingsgraad (t1)
		  --> vis.counter.10				totale inkomsten over periode (t1-t0)
		  --> vis.counter.10.0				totale patiënt-inkomsten over periode (t1-t0)
		  --> vis.counter.10.1				totale verzekeraar-inkomsten over periode (t1-t0)
	 	  --> vis.counter.10.2				totale extra-verzekeraar-inkomsten over periode (t1-t0)
	    */
	}
	
	//--- GET SERVER IDS IN SPECIFIED GROUPS ------------------------------------------------------
	private Vector getServerIdsInSpecifiedGroups(String sServerGroupIds){
		Vector serverIds = new Vector();
	    
		// convert ;-concationation to sql-concatination
		// a;b;c; --> 'a','b','c'
		if(sServerGroupIds.endsWith(";")) sServerGroupIds = sServerGroupIds.substring(0,sServerGroupIds.length()-1);
		sServerGroupIds = sServerGroupIds.replaceAll(";","','");
		sServerGroupIds = "'"+sServerGroupIds+"'";
		
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    	    
	    try{
	    	String sSql = "SELECT DISTINCT dc_servergroup_serverid AS serverid"+
	                      " FROM dc_servergroups"+
	    			      "  WHERE dc_servergroup_id IN ("+sServerGroupIds+")"+
	    			      "   ORDER BY dc_servergroup_serverid";	    	    	
			conn = MedwanQuery.getInstance().getOpenclinicConnection();
			ps = conn.prepareStatement(sSql);
			rs = ps.executeQuery();
			
			while(rs.next()){
				serverIds.add(new Integer(rs.getInt("serverid")));
			}
	    }
	    catch(Exception e){
	    	e.printStackTrace();
	    }
	    finally{
	    	try{
	    		if(rs!=null) rs.close();
	    		if(ps!=null) ps.close();
	    		if(conn!=null) conn.close();
	    	}
	    	catch(Exception e){
	    		e.printStackTrace();
	    	}
	    }

		Debug.println("sServerGroupIds : "+sServerGroupIds+" --> serverIds : "+vectorToString(serverIds,",",true)); // todo
	    return serverIds;
	}
	
    //--- GET DIAGNOSIS LABEL ---------------------------------------------------------------------
    private String getDiagnosisLabel(String sDiagnosisCode, String sLabelLang){
    	String sLabel = "";	    
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    	    
	    try{
	    	String sSql = "SELECT label"+sLabelLang+" AS label"+
	                      " FROM icd10"+
	    			      "  WHERE code = ?";
			conn = MedwanQuery.getInstance().getOpenclinicConnection();
			ps = conn.prepareStatement(sSql);
			ps.setString(1,sDiagnosisCode);
			rs = ps.executeQuery();
			
			if(rs.next()){
				sLabel = ScreenHelper.checkString(rs.getString("label"));
			}
	    }
	    catch(Exception e){
	    	e.printStackTrace();
	    }
	    finally{
	    	try{
	    		if(rs!=null) rs.close();
	    		if(ps!=null) ps.close();
	    		if(conn!=null) conn.close();
	    	}
	    	catch(Exception e){
	    		e.printStackTrace();
	    	}
	    }
    	
    	return sLabel;
    }

    //--- GET TOTAL VALUE -------------------------------------------------------------------------
    private int getTotalValue(Vector servers){
    	int totalValue = 0;
    	
    	Server server;
    	for(int i=0; i<servers.size(); i++){
    		server = (Server)servers.get(i);
    		totalValue+= server.patientCount;
    	}
    	
    	return totalValue;
    }
    
    //--- GET TOTAL PERCENTAGE --------------------------------------------------------------------
    private double getTotalPercentage(Vector servers){
    	double totalPercentage = 0;
    	int totalSum1 = 0, totalSum2 = 0;
    	
    	Server server;
    	for(int i=0; i<servers.size(); i++){
    		server = (Server)servers.get(i);
    		
    		totalSum1+= server.sum1;
    		totalSum2+= server.sum2;
    	}
    	
    	totalPercentage = ((double)totalSum1 / (double)totalSum2) * (double)100;
    	
    	return totalPercentage;
    }
%>

<%
    Debug.enabled = true; // todo : removeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee

	// form-data
	String sDateFrom = ScreenHelper.checkString(request.getParameter("dateFrom")),
	       sDateTo   = ScreenHelper.checkString(request.getParameter("dateTo"));
	
	String sServerGroupIds = ScreenHelper.checkString(request.getParameter("serverGroupIds")),
		   sGraphType      = ScreenHelper.checkString(request.getParameter("graphType")),
		   sParameter      = ScreenHelper.checkString(request.getParameter("parameter")),
		   sDiagnosisCode  = ScreenHelper.checkString(request.getParameter("diagnosisCode"));
	
	String jsonFileId = ScreenHelper.checkString(request.getParameter("jsonFileId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("*********** datacenter/gis/createJSON.jsp ***********");
		Debug.println("sDateFrom       : "+sDateFrom);
		Debug.println("sDateTo         : "+sDateTo);
		Debug.println("sServerGroupIds : "+sServerGroupIds);
		Debug.println("sGraphType      : "+sGraphType);
		Debug.println("sParameter      : "+sParameter);
		Debug.println("sDiagnosisCode  : "+sDiagnosisCode);
		Debug.println("jsonFileId  : "+jsonFileId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
    
    // default dates
    if(sDateTo.length()==0){
    	sDateTo = ScreenHelper.stdDateFormat.format(ScreenHelper.stdDateFormat.parse("01/01/2100")); // future
    }
    java.util.Date dateTo = ScreenHelper.stdDateFormat.parse(sDateTo);
    
    if(sDateFrom.length()==0){
    	sDateFrom = ScreenHelper.stdDateFormat.format(ScreenHelper.stdDateFormat.parse("01/01/1900")); // past
		
    	/*
    	Calendar cal = Calendar.getInstance();
	    cal.setTime(dateTo);
	    cal.add(Calendar.MONTH,-3); // revert one quarter     	    
		sDateFrom = ScreenHelper.stdDateFormat.format(cal.getTime());
		Debug.println("--> sDateFrom (-1q) : "+sDateFrom); // todo
		*/
    }
    java.util.Date dateFrom = ScreenHelper.stdDateFormat.parse(sDateFrom);
    
    // parameter
    String sConvertedParameter = convertParameter(sParameter);  
    Debug.println("converted sParameter ('"+sParameter+"') to '"+sConvertedParameter+"'"); // todo
    
    // get serverids from specified servergroups
    Vector serverIds = getServerIdsInSpecifiedGroups(sServerGroupIds);
    String sServerIdsFromServerGroups = vectorToString(serverIds,",",true);
    
    Hashtable coordsPerServer = loadCoordsFromFile();

    Vector servers = new Vector();	
    Server server;
    String[] coords;
    int serverId;
    
    // DB-stuff
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String sSql = "";
	
	//String sContextPath = MedwanQuery.getInstance().getConfigString("contextpath");
	String sContextPath = sAPPFULLDIR; 
	
	// delete existing file IMG file first
	String sFileDir = sContextPath+"/datacenter/gis/googleMaps";
	File fileToRemove = new File(sFileDir+"/mapChart_"+jsonFileId+".html");
	fileToRemove.delete();

    // delete existing JSON file first
    sFileDir = sContextPath+"/datacenter/gis/googleMaps/data";
    fileToRemove = new File(sFileDir+"/gisData_"+jsonFileId+".json");
    fileToRemove.delete();
	
	
    //*************************************************************************
    //*** 1 : CORE (dc_simplevalues) ******************************************
    //*************************************************************************
    /*
      vis.counter.0		core.1		aantal patiënten in de database (t1)
	  vis.counter.0.0	core.1		aantal nieuw geregistreerde patiënten (t1 - t0)
	  vis.counter.1		core.2		aantal gebruikers in de database (t1)
	  vis.counter.2		core.4.1	aantal hospitalisaties in de database (t1)
	  vis.counter.2.0	core.4.1	aantal nieuw geregistreerde hospitalisaties (t1-t0)
	  vis.counter.3		core.4.2	aantal consultaties in de database (t1)
	  vis.counter.3.0	core.4.2	aantal nieuw geregistreerde consultaties (t1-t0)
	  vis.counter.4		core.5		aantal prestaties in de database (t1)
	  vis.counter.4.0	core.5		aantal nieuw geregistreerde prestaties (t1-t0)
	  vis.counter.5		core.11		aantal patiëntfacturen in de database (t1)
	  vis.counter.5.0	core.11		aantal nieuw geregistreerde patiëntfacturen (t1-t0)
	  vis.counter.6		core.17		aantal lab-analyses in de database  (t1)
	  vis.counter.6.0	core.17		aantal nieuw geregistreerde lab-analyses in de database (t1-t0)
    */    
    if(parameterRefersToTable(sParameter,"dc_simplevalues")){
    	Debug.println("*************** 1 : dc_simplevalues ***************"); // todo
        
    	if(isParameterAboutNewData(sParameter,3)){
    		//*** get difference of most recent and oldest value in specified range, per server ***
    		int mostRecentValue = 0, oldestValue = 0;
		    		    
		    boolean mostRecentValueFound;
    		for(int i=0; i<serverIds.size(); i++){
    			serverId = ((Integer)serverIds.get(i)).intValue();
    			mostRecentValueFound = false;
    			
	    		//*** a : most recent value in range ************************************		    	
	    	    sSql = "SELECT v.dc_simplevalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location,"+
		    		   "  v.dc_simplevalue_data AS value, v.dc_simplevalue_createdatetime AS date"+
	    		       " FROM dc_simplevalues v, openclinic_dbo.dc_servers s"+
           	    	   "  WHERE v.dc_simplevalue_serverid = s.DC_SERVER_SERVERID"+
	    		       "   AND v.dc_simplevalue_parameterid = ?"+
	    		       "   AND v.dc_simplevalue_serverid = ?"+
	    		       "   AND v.dc_simplevalue_createdatetime < ?"+ // t1
	    		       "   AND v.dc_simplevalue_createdatetime >= ?"+ // t0
	    		       "  ORDER BY v.dc_simplevalue_serverid, v.dc_simplevalue_createdatetime DESC"+ // most recent value on top
	    		       " LIMIT 1";	    	   
    		  	conn = getConnection("stats");
    	        Debug.println("\n1a : "+sSql+"\n"); // todo 
    		    ps = conn.prepareStatement(sSql);
    		    
    		    int psIdx = 1;
    		    ps.setString(psIdx++,sConvertedParameter);   
    		    ps.setInt(psIdx++,serverId);
    		    
    		    ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateTo).getTime()));
    	        ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateFrom).getTime()));
    		    
    	        rs = ps.executeQuery();
    		    if(rs.next()){
    		    	mostRecentValue = rs.getInt("value");
    		    	Debug.println("["+serverId+"] mostRecentValue ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+mostRecentValue);
    		    	mostRecentValueFound = true;
    		    }
			    else{
			    	Debug.println("["+serverId+"] no mostRecentValue found");
			    }
    	         
    	        if(ps!=null) ps.close();
    	        if(rs!=null) rs.close();
    	        if(conn!=null) conn.close(); 
    		
    		    if(mostRecentValueFound){
		    		//*** b : oldest value in range *************************************
		    	    sSql = "SELECT v.dc_simplevalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location,"+
		    		       "  v.dc_simplevalue_data AS value, v.dc_simplevalue_createdatetime AS date"+
		    	     	   " FROM dc_simplevalues v, openclinic_dbo.dc_servers s"+
		    	           "  WHERE v.dc_simplevalue_serverid = s.DC_SERVER_SERVERID"+
		    	     	   "   AND v.dc_simplevalue_parameterid = ?"+
		    	           "   AND v.dc_simplevalue_serverid = ?"+
		    	     	   "   AND v.dc_simplevalue_createdatetime < ?"+ // t1
		    	           "   AND v.dc_simplevalue_createdatetime >= ?"+ // t0
		    	           "  ORDER BY v.dc_simplevalue_serverid, v.dc_simplevalue_createdatetime ASC"+ // oldest value on top
		    	     	   " LIMIT 1";	    	   
				  	conn = getConnection("stats");
			        Debug.println("\n1b : "+sSql+"\n"); // todo 
				    ps = conn.prepareStatement(sSql);
				    
				    psIdx = 1;
				    ps.setString(psIdx++,sConvertedParameter);   
				    ps.setInt(psIdx++,serverId);
		
				    ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateTo).getTime()));
			        ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateFrom).getTime()));
		
			        rs = ps.executeQuery();	    
				    if(rs.next()){
				    	oldestValue = rs.getInt("value");
				    	Debug.println("[server "+serverId+"] oldestValue ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+oldestValue);
					    
					    // compute growth or decrease for actual server
					    int difference = mostRecentValue - oldestValue;
				    	Debug.println("--> [server "+serverId+"] difference : ("+mostRecentValue+"-"+oldestValue+") = "+difference);
				      	
				    	//*** add server to vector of servers ***
				    	server = new Server();      	
			          	server.id = rs.getInt("serverid");		          	
			          	coords = (String[])coordsPerServer.get(server.id);
			          	
			          	// only export when both coords specified
			          	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
			          	    server.coordsLAT = coords[0];
			          	    server.coordsLONG = coords[1];
			                      	    
			            	server.patientCount = difference;
			            	server.location = rs.getString("location");
			            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
			          		
			              	servers.add(server);
			          	}
				    }
				    else{
				    	Debug.println("[server "+serverId+"] no oldestValue found");
				    }
			         
			        if(ps!=null) ps.close();
			        if(rs!=null) rs.close();
			        if(conn!=null) conn.close(); 
    		    }

    	        status(out,"Compiling map-data.. ["+(i+1)+"/"+serverIds.size()+"]");
    		}
    	}
    	else{ 
    		// !isParameterAboutNewData : 
    		//*** get most recent value in range, per server ****************************
		    int value, totalValue = 0;
    	    		    		        
    		for(int i=0; i<serverIds.size(); i++){
    			serverId = ((Integer)serverIds.get(i)).intValue();
    			
	    	    sSql = "SELECT v.dc_simplevalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location,"+
	    	           "  v.dc_simplevalue_data AS value, v.dc_simplevalue_createdatetime AS date"+
	    		       " FROM dc_simplevalues v, openclinic_dbo.dc_servers s"+
	    		       "  WHERE v.dc_simplevalue_serverid = s.DC_SERVER_SERVERID"+
	    		       "   AND v.dc_simplevalue_parameterid = ?"+
	    		       "   AND v.dc_simplevalue_serverid = ?"+
	    		       "   AND v.dc_simplevalue_createdatetime < ?"+ // t1
	                   "   AND v.dc_simplevalue_createdatetime >= ?"+ // t0
	    		       "  ORDER BY v.dc_simplevalue_serverid, v.dc_simplevalue_createdatetime DESC"+ // most recent value on top
	     		       " LIMIT 1";     	   
			  	conn = getConnection("stats");
		        Debug.println("\n1c : "+sSql+"\n"); // todo 
			    ps = conn.prepareStatement(sSql);
			    
			    int psIdx = 1;
			    ps.setString(psIdx++,sConvertedParameter);   
			    ps.setInt(psIdx++,serverId);

			    ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateTo).getTime()));
		        ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateFrom).getTime()));
			    	
		        rs = ps.executeQuery();
			    if(rs.next()){
			    	value = rs.getInt("value");
			    	Debug.println("[server "+serverId+"] value ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+value);
				    
			    	//*** add server to vector of servers ***
			    	server = new Server();      
		          	server.id = rs.getInt("serverid");	          	
		          	coords = (String[])coordsPerServer.get(server.id);
		          	
		          	// only export when both coords specified
		          	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
		          	    server.coordsLAT = coords[0];
		          	    server.coordsLONG = coords[1];
		                      	    
		            	server.patientCount = rs.getInt("value");
		            	server.location = rs.getString("location");
		            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
		          		
		              	servers.add(server);
		          	}
			    }	
			    else{
			    	Debug.println("[server "+serverId+"] no value found");
			    }
		         
		        if(ps!=null) ps.close();
		        if(rs!=null) rs.close();
		        if(conn!=null) conn.close(); 		

		        status(out,"Compiling map-data.. ["+(i+1)+"/"+serverIds.size()+"]"); 
    		}
    	}	    	 
    }
    //*************************************************************************
    //*** 2 : dc_encounterdiagnosisvalues *************************************
    //*************************************************************************
    /*
      vis.counter.7		type=either		aantal patiënten in de database met diagnose X (t1)
	  vis.counter.7.0	type=admission 	aantal gehospitaliseerde patiënten met diagnose X (t1)
	  vis.counter.7.0.0	type=admission 	aantal nieuwe gehospitaliseerde patiënten met diagnoses X (t1-t0)
	  vis.counter.7.1	type=visit		aantal consultaties voor patiënten in database met diagnose X (t1)
	  vis.counter.7.1.0	type=visit		aantal nieuwe consultaties voor patiënten met diagnoses X (t1-t0)
    */
    else if(parameterRefersToTable(sParameter,"dc_encounterdiagnosisvalues")){
    	Debug.println("********** 2 : dc_encounterdiagnosisvalues **********"); // todo    
        
    	if(isParameterAboutNewData(sParameter,4)){
    		//*** get difference of most recent and oldest value in specified range, per server ***
    		int mostRecentValue = 0, oldestValue = 0;
		    		    
		    boolean mostRecentValueFound;
    		for(int i=0; i<serverIds.size(); i++){
    			serverId = ((Integer)serverIds.get(i)).intValue();
    			mostRecentValueFound = false;
    			
	    		//*** a : most recent value in range ************************************
	    	    sSql = "SELECT v.dc_diagnosisvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, v.dc_diagnosisvalue_count AS value,"+
	    		       "  STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') AS date"+
	    		       " FROM dc_encounterdiagnosisvalues v, openclinic_dbo.dc_servers s"+
           	    	   "  WHERE v.dc_diagnosisvalue_serverid = s.DC_SERVER_SERVERID"+
	    		       "   AND v.dc_diagnosisvalue_codetype = 'KPGS'"+ // fixed
	    		       "   AND v.dc_diagnosisvalue_code = ?";
    			
	       	  	if(sConvertedParameter.length() > 0){
	       	  	    sSql+= " AND v.dc_diagnosisvalue_encountertype = '"+sConvertedParameter+"'";
	            }
	       	  	
	    	  	sSql+= "  AND v.dc_diagnosisvalue_serverid = ?"+
	         	  	   "  AND STR_TO_DATE(CONCAT('01/',dc_diagnosisvalue_month,'/',dc_diagnosisvalue_year),'%d/%m/%Y') < ?"+ // t1
	           	  	   "  AND STR_TO_DATE(CONCAT('01/',dc_diagnosisvalue_month,'/',dc_diagnosisvalue_year),'%d/%m/%Y') >= ?"+ // t0
	    		       "  ORDER BY v.dc_diagnosisvalue_serverid, date DESC"+ // most recent on top
	    		       " LIMIT 1";	           	  	   
    		  	conn = getConnection("stats");
    	        Debug.println("\n2a : "+sSql+"\n"); // todo 
    		    ps = conn.prepareStatement(sSql);
    		    
    		    int psIdx = 1;
		        ps.setString(psIdx++,sDiagnosisCode);
    		    ps.setInt(psIdx++,serverId);

			    ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateTo).getTime()));
		        ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateFrom).getTime()));
    		    
    	        rs = ps.executeQuery();
    		    if(rs.next()){
    		    	mostRecentValue = rs.getInt("value");
    		    	Debug.println("["+serverId+"] mostRecentValue ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+mostRecentValue);
    		    	mostRecentValueFound = true;
    		    }
			    else{
			    	Debug.println("["+serverId+"] no mostRecentValue found");
			    }
    	         
    	        if(ps!=null) ps.close();
    	        if(rs!=null) rs.close();
    	        if(conn!=null) conn.close(); 
    		
    		    if(mostRecentValueFound){
		    		//*** b : oldest value in range *************************************
    	    	    sSql = "SELECT v.dc_diagnosisvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, v.dc_diagnosisvalue_count AS value,"+
		    		       "  STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') AS date"+
   		    		       " FROM dc_encounterdiagnosisvalues v, openclinic_dbo.dc_servers s"+
   	           	    	   "  WHERE v.dc_diagnosisvalue_serverid = s.DC_SERVER_SERVERID"+
   		    		       "   AND v.dc_diagnosisvalue_codetype = 'KPGS'"+ // fixed
   		    		       "   AND v.dc_diagnosisvalue_code = ?";
    	    			
   		       	  	if(sConvertedParameter.length() > 0){
   		       	  	    sSql+= " AND v.dc_diagnosisvalue_encountertype = '"+sConvertedParameter+"'";
   		            }
   		       	  	
   		    	  	sSql+= "  AND v.dc_diagnosisvalue_serverid = ?"+
   		         	  	   "  AND STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') < ?"+ // t1
   		           	  	   "  AND STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') >= ?"+ // t0
   		    		       "  ORDER BY v.dc_diagnosisvalue_serverid, date ASC"+ // oldest value on top
   		    		       " LIMIT 1";	    
			  	    conn = getConnection("stats");
			        Debug.println("\n2b : "+sSql+"\n"); // todo 
				    ps = conn.prepareStatement(sSql);
				    
				    psIdx = 1;
			        ps.setString(psIdx++,sDiagnosisCode);
				    ps.setInt(psIdx++,serverId);

				    ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateTo).getTime()));
			        ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateFrom).getTime()));
		
			        rs = ps.executeQuery();	    
				    if(rs.next()){
				    	oldestValue = rs.getInt("value");
				    	Debug.println("[server "+serverId+"] oldestValue ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+oldestValue);
					    
					    // compute growth or decrease for actual server
					    int difference = mostRecentValue - oldestValue;
				    	Debug.println("--> [server "+serverId+"] difference : ("+mostRecentValue+"-"+oldestValue+") = "+difference);
				      	
				    	//*** add server to vector of servers ***
				    	server = new Server();      	
			          	server.id = rs.getInt("serverid");		          	
			          	coords = (String[])coordsPerServer.get(server.id);
			          	
			          	// only export when both coords specified
			          	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
			          	    server.coordsLAT = coords[0];
			          	    server.coordsLONG = coords[1];

			            	server.patientCount = difference;
			            	server.location = rs.getString("location");
			            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
			          		
			              	servers.add(server);
			          	}
				    }
				    else{
				    	Debug.println("[server "+serverId+"] no oldestValue found");
				    }
			         
			        if(ps!=null) ps.close();
			        if(rs!=null) rs.close();
			        if(conn!=null) conn.close(); 
    		    }

    	        status(out,"Compiling map-data.. ["+(i+1)+"/"+serverIds.size()+"]");
    		}
    	}
    	else{ 
    		// !isParameterAboutNewData : 
    		//*** get most recent value in range, per server ****************************
		    int value, totalValue = 0;
		        
    		for(int i=0; i<serverIds.size(); i++){
    			serverId = ((Integer)serverIds.get(i)).intValue();
    			
	    	    sSql = "SELECT v.dc_diagnosisvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, v.dc_diagnosisvalue_count AS value,"+
	    	           "  STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') AS date"+
	    		       " FROM dc_encounterdiagnosisvalues v, openclinic_dbo.dc_servers s"+
   		    		   "  WHERE v.dc_diagnosisvalue_serverid = s.DC_SERVER_SERVERID"+
	    		       "   AND v.dc_diagnosisvalue_codetype = 'KPGS'"+ // fixed
	    		       "   AND v.dc_diagnosisvalue_code = ?";
	    		
	       	  	if(sConvertedParameter.length() > 0){
	       	  	    sSql+= " AND v.dc_diagnosisvalue_encountertype = '"+sConvertedParameter+"'";
	            }
	       	  	
	    	  	sSql+= "   AND v.dc_diagnosisvalue_serverid = ?"+
	         	  	   "   AND STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') < ?"+ // t1
	           	  	   "   AND STR_TO_DATE(CONCAT('01/',v.dc_diagnosisvalue_month,'/',v.dc_diagnosisvalue_year),'%d/%m/%Y') >= ?"+ // t0
	    		       "  ORDER BY v.dc_diagnosisvalue_serverid, date DESC"+ // most recent value on top
	    		       " LIMIT 1";	    
			  	conn = getConnection("stats");
		        Debug.println("\n2c : "+sSql+"\n"); // todo 
			    ps = conn.prepareStatement(sSql);
			    
			    int psIdx = 1;
		        ps.setString(psIdx++,sDiagnosisCode);
			    ps.setInt(psIdx++,serverId);

			    ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateTo).getTime()));
		        ps.setTimestamp(psIdx++,new java.sql.Timestamp(ScreenHelper.stdDateFormat.parse(sDateFrom).getTime()));
					        
		        rs = ps.executeQuery();
			    if(rs.next()){
			    	value = rs.getInt("value");
			    	Debug.println("[server "+serverId+"] value ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+value);
				    
			    	//*** add server to vector of servers ***
			    	server = new Server();      
		          	server.id = rs.getInt("serverid");	          	
		          	coords = (String[])coordsPerServer.get(server.id);
		          	
		          	// only export when both coords specified
		          	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
		          	    server.coordsLAT = coords[0];
		          	    server.coordsLONG = coords[1];
		                      	    
		            	server.patientCount = rs.getInt("value");
		            	server.location = rs.getString("location");
		            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
		          		
		              	servers.add(server);
		          	}
			    }	
			    else{
			    	Debug.println("[server "+serverId+"] no value found");
			    }
		         
		        if(ps!=null) ps.close();
		        if(rs!=null) rs.close();
		        if(conn!=null) conn.close(); 		

		        status(out,"Compiling map-data.. ["+(i+1)+"/"+serverIds.size()+"]"); 
    		}
    	}	    	 
    }
    //*************************************************************************
    //*** 3 : dc_mortalityvalues **********************************************
    //*************************************************************************
    /*
      vis.counter.8		aantal nieuwe overlijdens (t1-t0)
	  vis.counter.8.0	aantal nieuwe overlijdens voor diagnose X (t1-t0)
      vis.counter.8.1	relatieve mortaliteit voor diagnose X (t1-t0)
    */
    else if(parameterRefersToTable(sParameter,"dc_mortalityvalues")){
    	Debug.println("************** 3 : dc_mortalityvalues **************"); // todo
    	
    	// determine function
    	String sFunction, relOrAbs;
    	if(sParameter.equals("vis.counter.8.1")){
    		// a : relative mortality (%)
    	    sFunction = "v.dc_mortalityvalue_count AS sum1, v.dc_mortalityvalue_diagnosiscount AS sum2, "+
    		            "((v.dc_mortalityvalue_count / v.dc_mortalityvalue_diagnosiscount)*100) AS value";
    		relOrAbs = "rel";
    	}
    	else{
    		// b : absolute mortality
    	    sFunction = "max(dc_mortalityvalue_count) AS value";
    		relOrAbs = "abs";
    	}
    	
    	// compose query
   	  	sSql = "SELECT v.dc_mortalityvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, "+sFunction+","+ // difference
   	  		   "  STR_TO_DATE(CONCAT('01/',v.dc_mortalityvalue_month,'/',v.dc_mortalityvalue_year),'%d/%m/%Y') AS date"+
               " FROM dc_mortalityvalues v, openclinic_dbo.dc_servers s"+
   	  	       "  WHERE v.dc_mortalityvalue_serverid = s.DC_SERVER_SERVERID"+
   	  	       "   AND v.dc_mortalityvalue_count IS NOT NULL"+ // required for percentage-calculation
   	  	       "   AND v.dc_mortalityvalue_diagnosiscount IS NOT NULL"; // required for percentage-calculation
 
   	     if(!sParameter.equals("vis.counter.8")){
             sSql+= " AND v.dc_mortalityvalue_codetype = 'KPGS'"+ // fixed
   	  	            " AND v.dc_mortalityvalue_code = '"+sDiagnosisCode+"'";
   	     }
   	     
   	 	 sSql+= "  AND v.dc_mortalityvalue_serverid IN ("+sServerIdsFromServerGroups+")"+
     	  	    "  AND STR_TO_DATE(CONCAT('01/',v.dc_mortalityvalue_month,'/',v.dc_mortalityvalue_year),'%d/%m/%Y') < ?"+ // t1
       	  	    "  AND STR_TO_DATE(CONCAT('01/',v.dc_mortalityvalue_month,'/',v.dc_mortalityvalue_year),'%d/%m/%Y') >= ?"+ // t0
   	  	        " GROUP BY v.dc_mortalityvalue_serverid";   	  	    
   	  	conn = getConnection("stats");
        Debug.println("\n3 : "+sSql+"\n"); // todo 
   	    ps = conn.prepareStatement(sSql);    	

   	    int psIdx = 1;  		      
   	    ps.setString(psIdx++,sDateTo);  
   	    ps.setString(psIdx++,sDateFrom); 

	    rs = ps.executeQuery();	    
	    while(rs.next()){
	      	server = new Server();      	
	      	server.id = rs.getInt("serverid");
	    	Debug.println("server.id : "+server.id); // todo
	      	
	      	coords = (String[])coordsPerServer.get(server.id);
	      	
	      	// only export when both coords specified
	      	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
	      	    server.coordsLAT = coords[0];
	      	    server.coordsLONG = coords[1];
	            
	      	    if(relOrAbs.equals("rel")){
	      	    	// a : relative
	      	        server.dataType = "percentage";

		        	server.percentage = rs.getDouble("value"); // not 'patientCount'
		        	Debug.println("percentage : "+server.percentage);
		        	
		        	server.sum1 = rs.getInt("sum1"); // to be able to calculate percentage per country
		        	server.sum2 = rs.getInt("sum2"); // to be able to calculate percentage per country
		        	Debug.println("sum1 : "+server.sum1);
		        	Debug.println("sum2 : "+server.sum2);
	      	    }
	      	    else{
	      	    	// b : absolute
		        	server.patientCount = rs.getInt("value");
		        	Debug.println("patientCount : "+server.patientCount);
	      	    }
	      	    
	        	server.location = rs.getString("location");
            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
	        	Debug.println("dataDate : "+server.dataDate+"\n");
	      		
	          	servers.add(server);
	      	}
	    }
        
        if(ps!=null) ps.close();
        if(rs!=null) rs.close();
        if(conn!=null) conn.close(); 
    }
    //*************************************************************************
    //*** 4 : dc_bedoccupancyvalues *******************************************
    //*************************************************************************
    /*
    	vis.counter.9	dc_bedoccupancyvalues	bedbezettingsgraad (t1)
    */
    else if(parameterRefersToTable(sParameter,"dc_bedoccupancyvalues")){	
    	Debug.println("************** 4 : dc_bedoccupancyvalues **************"); // todo
        status(out,"Compiling map-data..");
    	
   	  	sSql = "SELECT v.dc_bedoccupancyvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location,"+
               "   sum(v.dc_bedoccupancyvalue_occupiedbeds) AS sum1, sum(v.dc_bedoccupancyvalue_totalbeds) AS sum2,"+
   	  	       "   ((sum(v.dc_bedoccupancyvalue_occupiedbeds) / sum(v.dc_bedoccupancyvalue_totalbeds)) * 100) AS value,"+ // percentage of 2 sums
   	  	       "   dc_bedoccupancyvalue_date AS date"+
   	  		   "  FROM dc_bedoccupancyvalues v, openclinic_dbo.dc_servers s"+
               "   WHERE v.dc_bedoccupancyvalue_serverid = s.DC_SERVER_SERVERID"+
               "    AND v.dc_bedoccupancyvalue_serverid IN ("+sServerIdsFromServerGroups+")"+
       	  	   "    AND v.dc_bedoccupancyvalue_date < ?"+ // t1
       	       "    AND v.dc_bedoccupancyvalue_date >= ?"+ // t0
               " GROUP BY v.dc_bedoccupancyvalue_serverid";
   	  	conn = getConnection("stats");
        Debug.println("\n4 : "+sSql+"\n"); // todo 
   	    ps = conn.prepareStatement(sSql);
   	    
	    int psIdx = 1;	    
	    ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateTo.getTime())); 
	    ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateFrom.getTime())); 
   	    
   	    //*** execute query *********************
	   	rs = ps.executeQuery();   	    
		while(rs.next()){
		 	server = new Server();      	
		  	server.id = rs.getInt("serverid");
	    	Debug.println("server.id : "+server.id); // todo
		    	
		  	coords = (String[])coordsPerServer.get(server.id);
		      	
		  	// only export when both coords specified
		  	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
		  	    server.coordsLAT = coords[0];
		  	    server.coordsLONG = coords[1];

		  	    // always relative
	      	    server.dataType = "percentage";
	        	server.percentage = rs.getDouble("value"); // not 'patientCount'
	        	Debug.println("percentage : "+server.percentage);
	        	
	        	server.sum1 = rs.getInt("sum1"); // to be able to calculate percentage per country
	        	server.sum2 = rs.getInt("sum2"); // to be able to calculate percentage per country
	        	Debug.println("sum1 : "+server.sum1);
	        	Debug.println("sum2 : "+server.sum2);
	        	server.location = rs.getString("location");
            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
		     		
		      	servers.add(server);
		  	}
		}
	     
	    if(ps!=null) ps.close();
	    if(rs!=null) rs.close();
	    if(conn!=null) conn.close(); 
    }
    //*************************************************************************
    //*** 5 : dc_financialvalues **********************************************
    //*************************************************************************
    /*
	    vis.counter.10		totale inkomsten over periode (t1-t0)
	    vis.counter.10.0	totale patiënt-inkomsten over periode (t1-t0)
	    vis.counter.10.1	totale verzekeraar-inkomsten over periode (t1-t0)
	    vis.counter.10.2	totale extra-verzekeraar-inkomsten over periode (t1-t0)
    */
    else if(parameterRefersToTable(sParameter,"dc_financialvalues")){   
    	Debug.println("*************** 5 : dc_financialvalues ***************"); // todo  
        status(out,"Compiling map-data.."); 
        
    	if(isParameterAboutNewData(sParameter,4)){
    		//*** get difference of most recent and oldest value in specified range, per server ***
    		int mostRecentValue = 0, oldestValue = 0;
		    		    
		    boolean mostRecentValueFound;
    		for(int i=0; i<serverIds.size(); i++){
    			serverId = ((Integer)serverIds.get(i)).intValue();
    			mostRecentValueFound = false;
    			
	    		// a : most recent value in range
    	   	  	sSql = "SELECT v.dc_financialvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, v.dc_financialvalue_value AS value,"+
    	   	  	       "  STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') AS date"+
    	   	  		   " FROM dc_financialvalues v, openclinic_dbo.dc_servers s"+
    	   	  	       "  WHERE v.dc_financialvalue_serverid = s.DC_SERVER_SERVERID"+
    	   	  	       "   AND v.dc_financialvalue_parameterid = ?"+
    	   	           "   AND v.dc_financialvalue_serverid = ?"+
    	   	  	       "   AND STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') < ?"+ // t1
    	   	  	       "   AND STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') >= ?"+ // t0
    		    	   "  ORDER BY v.dc_financialvalue_serverid, date DESC"+ // most recent value on top
    		    	   " LIMIT 1";
	  		  	conn = getConnection("stats");
	  	        Debug.println("\n5a : "+sSql+"\n"); // todo 
	  		    ps = conn.prepareStatement(sSql);	           	 
    	        
    		    int psIdx = 1;
    		    Debug.println("sConvertedParameter : "+sConvertedParameter); // todo
    		    ps.setString(psIdx++,sConvertedParameter);
    		    ps.setInt(psIdx++,serverId);

			    ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateTo.getTime()));
		        ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateFrom.getTime()));
    		    
    	        rs = ps.executeQuery();
    		    if(rs.next()){
    		    	mostRecentValue = rs.getInt("value");
    		    	Debug.println("["+serverId+"] mostRecentValue ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+mostRecentValue);
    		    	mostRecentValueFound = true;
    		    }
			    else{
			    	Debug.println("["+serverId+"] no mostRecentValue found");
			    }
    	         
    	        if(ps!=null) ps.close();
    	        if(rs!=null) rs.close();
    	        if(conn!=null) conn.close(); 
    		
    		    if(mostRecentValueFound){
		    		// b : oldest value in range
	    	   	  	sSql = "SELECT v.dc_financialvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, v.dc_financialvalue_value AS value,"+
	    	   	  	       "  STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') AS date"+
	    	   	  		   " FROM dc_financialvalues v, openclinic_dbo.dc_servers s"+
	    	   	  	       "  WHERE v.dc_financialvalue_serverid = s.DC_SERVER_SERVERID"+
	    	   	  	       "   AND v.dc_financialvalue_parameterid = ?"+
	    	   	           "   AND v.dc_financialvalue_serverid = ?"+
	    	   	  	       "   AND STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') < ?"+ // t1
	    	   	  	       "   AND STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') >= ?"+ // t0
	    		    	   "  ORDER BY v.dc_financialvalue_serverid, date ASC"+ // oldest value on top
	    		    	   " LIMIT 1";
		  		  	conn = getConnection("stats");
		  	        Debug.println("\n5b : "+sSql+"\n"); // todo 
		  		    ps = conn.prepareStatement(sSql);	           	 
	    	        
	    		    psIdx = 1;
	    		    Debug.println("sConvertedParameter : "+sConvertedParameter); // todo
	    		    ps.setString(psIdx++,sConvertedParameter);
	    		    ps.setInt(psIdx++,serverId);

				    ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateTo.getTime()));
			        ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateFrom.getTime()));
			        Debug.println("sDateTo   : "+sDateTo); // todo
			        Debug.println("sDateFrom : "+sDateFrom); // todo
		
			        rs = ps.executeQuery();	    
				    if(rs.next()){
				    	oldestValue = rs.getInt("value");
				    	Debug.println("[server "+serverId+"] oldestValue ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+oldestValue);
					    
					    // compute growth or decrease for actual server
					    int difference = mostRecentValue - oldestValue;
				    	Debug.println("--> [server "+serverId+"] difference : ("+mostRecentValue+"-"+oldestValue+") = "+difference);
				      	
				    	//*** add server to vector of servers ***
				    	server = new Server();      	
			          	server.id = rs.getInt("serverid");		          	
			          	coords = (String[])coordsPerServer.get(server.id);
			          	
			          	// only export when both coords specified
			          	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
			          	    server.coordsLAT = coords[0];
			          	    server.coordsLONG = coords[1];

			            	server.patientCount = difference;
			            	server.location = rs.getString("location");
			            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
			          		
			              	servers.add(server);
			          	}
				    }
				    else{
				    	Debug.println("[server "+serverId+"] no oldestValue found");
				    }
			         
			        if(ps!=null) ps.close();
			        if(rs!=null) rs.close();
			        if(conn!=null) conn.close(); 
    		    }

    	        status(out,"Compiling map-data.. ["+(i+1)+"/"+serverIds.size()+"]");
    		}
    	}
    	else{ 
    		// !isParameterAboutNewData : 
    		//*** get most recent value in range, per server ***
		    int value, totalValue = 0;
		        
    		for(int i=0; i<serverIds.size(); i++){
    			serverId = ((Integer)serverIds.get(i)).intValue();

    	   	  	sSql = "SELECT v.dc_financialvalue_serverid AS serverid, s.DC_SERVER_LOCATION AS location, v.dc_financialvalue_value AS value,"+
    	   	  	       "  STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') AS date"+
    	   	  		   " FROM dc_financialvalues v, openclinic_dbo.dc_servers s"+
    	   	  	       "  WHERE v.dc_financialvalue_serverid = s.DC_SERVER_SERVERID"+
    	   	  	       "   AND v.dc_financialvalue_parameterid = ?"+
    	   	           "   AND v.dc_financialvalue_serverid = ?"+
    	   	  	       "   AND STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') < ?"+ // t1
    	   	  	       "   AND STR_TO_DATE(CONCAT('01/',v.dc_financialvalue_month,'/',v.dc_financialvalue_year),'%d/%m/%Y') >= ?"+ // t0
    		    	   "  ORDER BY v.dc_financialvalue_serverid, date DESC"+ // most recent value on top
    		    	   " LIMIT 1";	    
			  	conn = getConnection("stats");
		        Debug.println("\n5c : "+sSql+"\n"); // todo 
			    ps = conn.prepareStatement(sSql);

    		    int psIdx = 1;
    		    Debug.println("sConvertedParameter : "+sConvertedParameter); // todo
    		    ps.setString(psIdx++,sConvertedParameter);
    		    ps.setInt(psIdx++,serverId);

			    ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateTo.getTime()));
		        ps.setTimestamp(psIdx++,new java.sql.Timestamp(dateFrom.getTime()));
					        
		        rs = ps.executeQuery();
			    if(rs.next()){
			    	value = rs.getInt("value");
			    	Debug.println("[server "+serverId+"] value ("+ScreenHelper.stdDateFormat.format(rs.getDate("date"))+") : "+value);
				    
			    	//*** add server to vector of servers ***
			    	server = new Server();      
		          	server.id = rs.getInt("serverid");	          	
		          	coords = (String[])coordsPerServer.get(server.id);
		          	
		          	// only export when both coords specified
		          	if(coords!=null && (ScreenHelper.checkString(coords[0]).length() > 0 && ScreenHelper.checkString(coords[1]).length() > 0)){
		          	    server.coordsLAT = coords[0];
		          	    server.coordsLONG = coords[1];
		                      	    
		            	server.patientCount = rs.getInt("value");
		            	server.location = rs.getString("location");
		            	server.dataDate = ScreenHelper.stdDateFormat.format(rs.getDate("date"));
		          		
		              	servers.add(server);
		          	}
			    }	
			    else{
			    	Debug.println("[server "+serverId+"] no value found");
			    }
		         
		        if(ps!=null) ps.close();
		        if(rs!=null) rs.close();
		        if(conn!=null) conn.close(); 		

		        status(out,"Compiling map-data.. ["+(i+1)+"/"+serverIds.size()+"]"); 
    		}
    	}	
    }
    
    //*************************************************************************
    //*** write xml to file ***************************************************
    //*************************************************************************        
    if(servers.size() > 0){
        //*** title ***********************************************************
        String sTitle = MedwanQuery.getInstance().getLabel("vis.counter",sParameter,sWebLanguage);
        
        String sOrigDateFrom = ScreenHelper.checkString(request.getParameter("dateFrom"));
        if(sOrigDateFrom.length()==0){
            sTitle+= " ("+sDateTo+")";
        }
        else{
            sTitle+= " ("+sDateFrom+" ~ "+sDateTo+")";	
        }
        
        // diagnose
        if(sDiagnosisCode.length() > 0){
        	String sLabel = getDiagnosisLabel(sDiagnosisCode,sWebLanguage);
        	if(sLabel.length() > 15){
        		sLabel = sLabel.substring(0,15)+"..";
        	}
        	
        	sTitle = sTitle.replaceAll(" X"," '"+sDiagnosisCode+" - "+sLabel+"'");
        }    

        //*** mapChart (not a json, but an html containing an img tag) ********
        if(sGraphType.equals("mapChart")){
   	        try{    		    
    	        // create new file
    		    sFileDir = sContextPath+"/datacenter/gis/googleMaps";
    		    FileWriter writer = new FileWriter(sFileDir+"/mapChart_"+jsonFileId+".html");
    		    
    		    // IMG tag
    		    writer.write(vectorToIMG(servers,sTitle).toString());
   		    
    		    // center popup
    		    writer.write("<script>"+
    		                  "window.moveTo((self.screen.width-document.body.clientWidth)/2,(self.screen.height-document.body.clientHeight)/2);"+
    		                 "</script>");

    		    //*** display total below IMG ***
    		    writer.write("<br>");

    		    // absolute total    		    
                if(!sParameter.equalsIgnoreCase("vis.counter.8.1") && !sParameter.equalsIgnoreCase("vis.counter.9")){
    	   	        DecimalFormat deci = new DecimalFormat("#,###.###");
	    		    writer.write("<div style='font-family:Arial;font-size:8pt;'>"+
	    		                  "Total : "+deci.format(getTotalValue(servers))+
	    		                 "</div>");
                }
    		    // relative total below IMG
                else{
    	   	        DecimalFormat deci = new DecimalFormat("0.##");
	    		    writer.write("<div style='font-family:Arial;font-size:8pt;'>"+
	    		                  "Total percentage : "+deci.format(getTotalPercentage(servers))+"%"+
	    		                 "</div>");
                }
                
    		    writer.close();
    		
    		    Debug.println("Data written to '"+sFileDir+"/mapChart_"+jsonFileId+".html'");		
    	    }
    	    catch(Exception e){
    	        e.printStackTrace();	
    	    }
        }
        //*** default : json **************************************************
        else{
    	    try{
    	    	// sort vector
                if(!sParameter.equalsIgnoreCase("vis.counter.8.1") && !sParameter.equalsIgnoreCase("vis.counter.9")){
    	        	// sort DESC (on patientCount)
    	    	    Collections.sort(servers);
    	    	}
    	        else{
    	        	// sort ASC (on percentage)
    	    	    Collections.sort(servers);
    	        	Collections.reverse(servers);
    	        }
    	    	
    	        // create new file
    		    sFileDir = sContextPath+"/datacenter/gis/googleMaps/data";
    		    FileWriter writer = new FileWriter(sFileDir+"/gisData_"+jsonFileId+".json");
    		    writer.write(vectorToJSON(servers,"services",sParameter,sTitle).toString());
    		    writer.close();
    		    
    		    Debug.println("Data written to '"+sFileDir+"/gisData_"+jsonFileId+".json'");		   
    	    }
    	    catch(Exception e){
    	        e.printStackTrace();	
    	    }
        } 
    	
	    Debug.println(servers.size()+" records added"); 
    }
%>        