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
    static Hashtable countryCodesAndContinent;
    static Vector countryColors;
    static double centerValue;

    static {
	    //*********************************************************************
        //*** country colors **************************************************
	    //*********************************************************************
	    // 10 colors suffice for any amount of values to display --> %10
        countryColors = new Vector();
        countryColors.add("990000"); // red
        countryColors.add("33cc44"); // green, light
        countryColors.add("990099"); // purple, rose
        countryColors.add("FF9900"); // light orange, kaki
        countryColors.add("DC3912"); // dark orange, reddish
        countryColors.add("ffdd00"); // yellow 1
        countryColors.add("009900"); // green
        countryColors.add("6622cc"); // purple, violet
        countryColors.add("33dd33"); // blue, light
        countryColors.add("000099"); // blue, navy
        countryColors.add("ffdd99"); // yellow 2
        countryColors.add("660099"); // red 2
        
        //*********************************************************************
        //*** countrycodes per continent **************************************
        //*********************************************************************
        countryCodesAndContinent = new Hashtable();
        countryCodesAndContinent.put("AD","EU");
        countryCodesAndContinent.put("AE","AS");
        countryCodesAndContinent.put("AF","AS");
        countryCodesAndContinent.put("AG","NA");
        countryCodesAndContinent.put("AI","NA");
        countryCodesAndContinent.put("AL","EU");
        countryCodesAndContinent.put("AM","AS");
        countryCodesAndContinent.put("AN","NA");
        countryCodesAndContinent.put("AO","AF");
        countryCodesAndContinent.put("AP","AS");
        countryCodesAndContinent.put("AQ","AN");
        countryCodesAndContinent.put("AR","SA");
        countryCodesAndContinent.put("AS","OC");
        countryCodesAndContinent.put("AT","EU");
        countryCodesAndContinent.put("AU","OC");
        countryCodesAndContinent.put("AW","NA");
        countryCodesAndContinent.put("AX","EU");
        countryCodesAndContinent.put("AZ","AS");
        countryCodesAndContinent.put("BA","EU");
        countryCodesAndContinent.put("BB","NA");
        countryCodesAndContinent.put("BD","AS");
        countryCodesAndContinent.put("BE","EU");
        countryCodesAndContinent.put("BF","AF");
        countryCodesAndContinent.put("BG","EU");
        countryCodesAndContinent.put("BH","AS");
        countryCodesAndContinent.put("BI","AF");
        countryCodesAndContinent.put("BJ","AF");
        countryCodesAndContinent.put("BL","NA");
        countryCodesAndContinent.put("BM","NA");
        countryCodesAndContinent.put("BN","AS");
        countryCodesAndContinent.put("BO","SA");
        countryCodesAndContinent.put("BR","SA");
        countryCodesAndContinent.put("BS","NA");
        countryCodesAndContinent.put("BT","AS");
        countryCodesAndContinent.put("BV","AN");
        countryCodesAndContinent.put("BW","AF");
        countryCodesAndContinent.put("BY","EU");
        countryCodesAndContinent.put("BZ","NA");
        countryCodesAndContinent.put("CA","NA");
        countryCodesAndContinent.put("CC","AS");
        countryCodesAndContinent.put("CD","AF");
        countryCodesAndContinent.put("CF","AF");
        countryCodesAndContinent.put("CG","AF");
        countryCodesAndContinent.put("CH","EU");
        countryCodesAndContinent.put("CI","AF");
        countryCodesAndContinent.put("CK","OC");
        countryCodesAndContinent.put("CL","SA");
        countryCodesAndContinent.put("CM","AF");
        countryCodesAndContinent.put("CN","AS");
        countryCodesAndContinent.put("CO","SA");
        countryCodesAndContinent.put("CR","NA");
        countryCodesAndContinent.put("CU","NA");
        countryCodesAndContinent.put("CV","AF");
        countryCodesAndContinent.put("CX","AS");
        countryCodesAndContinent.put("CY","AS");
        countryCodesAndContinent.put("CZ","EU");
        countryCodesAndContinent.put("DE","EU");
        countryCodesAndContinent.put("DJ","AF");
        countryCodesAndContinent.put("DK","EU");
        countryCodesAndContinent.put("DM","NA");
        countryCodesAndContinent.put("DO","NA");
        countryCodesAndContinent.put("DZ","AF");
        countryCodesAndContinent.put("EC","SA");
        countryCodesAndContinent.put("EE","EU");
        countryCodesAndContinent.put("EG","AF");
        countryCodesAndContinent.put("EH","AF");
        countryCodesAndContinent.put("ER","AF");
        countryCodesAndContinent.put("ES","EU");
        countryCodesAndContinent.put("ET","AF");
        countryCodesAndContinent.put("EU","EU");
        countryCodesAndContinent.put("FI","EU");
        countryCodesAndContinent.put("FJ","OC");
        countryCodesAndContinent.put("FK","SA");
        countryCodesAndContinent.put("FM","OC");
        countryCodesAndContinent.put("FO","EU");
        countryCodesAndContinent.put("FR","EU");
        countryCodesAndContinent.put("FX","EU");				
        countryCodesAndContinent.put("GA","AF");
        countryCodesAndContinent.put("GB","EU");
        countryCodesAndContinent.put("GD","NA");
        countryCodesAndContinent.put("GE","AS");
        countryCodesAndContinent.put("GF","SA");
        countryCodesAndContinent.put("GG","EU");
        countryCodesAndContinent.put("GH","AF");
        countryCodesAndContinent.put("GI","EU");
        countryCodesAndContinent.put("GL","NA");
        countryCodesAndContinent.put("GM","AF");
        countryCodesAndContinent.put("GN","AF");
        countryCodesAndContinent.put("GP","NA");
        countryCodesAndContinent.put("GQ","AF");
        countryCodesAndContinent.put("GR","EU");
        countryCodesAndContinent.put("GS","AN");
        countryCodesAndContinent.put("GT","NA");
        countryCodesAndContinent.put("GU","OC");
     	countryCodesAndContinent.put("GW","AF");
        countryCodesAndContinent.put("GY","SA");
        countryCodesAndContinent.put("HK","AS");
        countryCodesAndContinent.put("HM","AN");
        countryCodesAndContinent.put("HN","NA");
        countryCodesAndContinent.put("HR","EU");
        countryCodesAndContinent.put("HT","NA");
        countryCodesAndContinent.put("HU","EU");
        countryCodesAndContinent.put("ID","AS");
        countryCodesAndContinent.put("IE","EU");
        countryCodesAndContinent.put("IL","AS");
        countryCodesAndContinent.put("IM","EU");
        countryCodesAndContinent.put("IN","AS");
        countryCodesAndContinent.put("IO","AS");
        countryCodesAndContinent.put("IQ","AS");
        countryCodesAndContinent.put("IR","AS");
        countryCodesAndContinent.put("IS","EU");
        countryCodesAndContinent.put("IT","EU");
        countryCodesAndContinent.put("JE","EU");
        countryCodesAndContinent.put("JM","NA");
        countryCodesAndContinent.put("JO","AS");
        countryCodesAndContinent.put("JP","AS");
        countryCodesAndContinent.put("KE","AF");
        countryCodesAndContinent.put("KG","AS");
        countryCodesAndContinent.put("KH","AS");
        countryCodesAndContinent.put("KI","OC");
        countryCodesAndContinent.put("KM","AF");
        countryCodesAndContinent.put("KN","NA");
        countryCodesAndContinent.put("KP","AS");
        countryCodesAndContinent.put("KR","AS");
        countryCodesAndContinent.put("KW","AS");
        countryCodesAndContinent.put("KY","NA");
        countryCodesAndContinent.put("KZ","AS");
        countryCodesAndContinent.put("LA","AS");
        countryCodesAndContinent.put("LB","AS");
        countryCodesAndContinent.put("LC","NA");
        countryCodesAndContinent.put("LI","EU");
        countryCodesAndContinent.put("LK","AS");
        countryCodesAndContinent.put("LR","AF");
        countryCodesAndContinent.put("LS","AF");
        countryCodesAndContinent.put("LT","EU");
        countryCodesAndContinent.put("LU","EU");
        countryCodesAndContinent.put("LV","EU");
        countryCodesAndContinent.put("LY","AF");
        countryCodesAndContinent.put("MA","AF");
        countryCodesAndContinent.put("MC","EU");
        countryCodesAndContinent.put("MD","EU");
        countryCodesAndContinent.put("ME","EU");
        countryCodesAndContinent.put("MF","NA");
        countryCodesAndContinent.put("MG","AF");
        countryCodesAndContinent.put("MH","OC");
        countryCodesAndContinent.put("MK","EU");
        countryCodesAndContinent.put("ML","AF");
        countryCodesAndContinent.put("MM","AS");
        countryCodesAndContinent.put("MN","AS");
        countryCodesAndContinent.put("MO","AS");
        countryCodesAndContinent.put("MP","OC");
        countryCodesAndContinent.put("MQ","NA");
        countryCodesAndContinent.put("MR","AF");
        countryCodesAndContinent.put("MS","NA");
        countryCodesAndContinent.put("MT","EU");
        countryCodesAndContinent.put("MU","AF");
        countryCodesAndContinent.put("MV","AS");
        countryCodesAndContinent.put("MW","AF");
        countryCodesAndContinent.put("MX","NA");
        countryCodesAndContinent.put("MY","AS");
        countryCodesAndContinent.put("MZ","AF");
        countryCodesAndContinent.put("NA","AF");
        countryCodesAndContinent.put("NC","OC");
        countryCodesAndContinent.put("NE","AF");
        countryCodesAndContinent.put("NF","OC");
        countryCodesAndContinent.put("NG","AF");
        countryCodesAndContinent.put("NI","NA");
        countryCodesAndContinent.put("NL","EU");
        countryCodesAndContinent.put("NO","EU");
        countryCodesAndContinent.put("NP","AS");
        countryCodesAndContinent.put("NR","OC");
        countryCodesAndContinent.put("NU","OC");
        countryCodesAndContinent.put("NZ","OC");
        countryCodesAndContinent.put("OM","AS");
        countryCodesAndContinent.put("PA","NA");
        countryCodesAndContinent.put("PE","SA");
        countryCodesAndContinent.put("PF","OC");
        countryCodesAndContinent.put("PG","OC");
        countryCodesAndContinent.put("PH","AS");
        countryCodesAndContinent.put("PK","AS");
        countryCodesAndContinent.put("PL","EU");
        countryCodesAndContinent.put("PM","NA");
        countryCodesAndContinent.put("PN","OC");
        countryCodesAndContinent.put("PR","NA");
        countryCodesAndContinent.put("PS","AS");
        countryCodesAndContinent.put("PT","EU");
        countryCodesAndContinent.put("PW","OC");
        countryCodesAndContinent.put("PY","SA");
        countryCodesAndContinent.put("QA","AS");
        countryCodesAndContinent.put("RE","AF");
        countryCodesAndContinent.put("RO","EU");
        countryCodesAndContinent.put("RS","EU");
        countryCodesAndContinent.put("RU","EU");
        countryCodesAndContinent.put("RW","AF");
        countryCodesAndContinent.put("SA","AS");
        countryCodesAndContinent.put("SB","OC");
        countryCodesAndContinent.put("SC","AF");
        countryCodesAndContinent.put("SD","AF");
        countryCodesAndContinent.put("SE","EU");
        countryCodesAndContinent.put("SG","AS");
        countryCodesAndContinent.put("SH","AF");
        countryCodesAndContinent.put("SI","EU");
        countryCodesAndContinent.put("SJ","EU");
        countryCodesAndContinent.put("SK","EU");
        countryCodesAndContinent.put("SL","AF");
        countryCodesAndContinent.put("SM","EU");
        countryCodesAndContinent.put("SN","AF");
        countryCodesAndContinent.put("SO","AF");
        countryCodesAndContinent.put("SR","SA");
        countryCodesAndContinent.put("ST","AF");
        countryCodesAndContinent.put("SV","NA");
        countryCodesAndContinent.put("SY","AS");
        countryCodesAndContinent.put("SZ","AF");
        countryCodesAndContinent.put("TC","NA");
        countryCodesAndContinent.put("TD","AF");
        countryCodesAndContinent.put("TF","AN");
        countryCodesAndContinent.put("TG","AF");
        countryCodesAndContinent.put("TH","AS");
        countryCodesAndContinent.put("TJ","AS");
        countryCodesAndContinent.put("TK","OC");
        countryCodesAndContinent.put("TL","AS");
        countryCodesAndContinent.put("TM","AS");
        countryCodesAndContinent.put("TN","AF");
        countryCodesAndContinent.put("TO","OC");
        countryCodesAndContinent.put("TR","EU");
        countryCodesAndContinent.put("TT","NA");
        countryCodesAndContinent.put("TV","OC");
        countryCodesAndContinent.put("TW","AS");
        countryCodesAndContinent.put("TZ","AF");
        countryCodesAndContinent.put("UA","EU");
        countryCodesAndContinent.put("UG","AF");
        countryCodesAndContinent.put("UM","OC");
        countryCodesAndContinent.put("US","NA");
        countryCodesAndContinent.put("UY","SA");
        countryCodesAndContinent.put("UZ","AS");
        countryCodesAndContinent.put("VA","EU");
        countryCodesAndContinent.put("VC","NA");
        countryCodesAndContinent.put("VE","SA");
        countryCodesAndContinent.put("VG","NA");
        countryCodesAndContinent.put("VI","NA");
        countryCodesAndContinent.put("VN","AS");
        countryCodesAndContinent.put("VU","OC");
        countryCodesAndContinent.put("WF","OC");
        countryCodesAndContinent.put("WS","OC");
        countryCodesAndContinent.put("YE","AS");
        countryCodesAndContinent.put("YT","AF");
        countryCodesAndContinent.put("ZA","AF");
        countryCodesAndContinent.put("ZM","AF");
        countryCodesAndContinent.put("ZW","AF");
        
        // Middle-East
        countryCodesAndContinent.put("AM","ME");
        countryCodesAndContinent.put("AZ","ME");
        countryCodesAndContinent.put("BH","ME");
        countryCodesAndContinent.put("GE","ME");
        countryCodesAndContinent.put("IR","ME");
        countryCodesAndContinent.put("IQ","ME");
        countryCodesAndContinent.put("IL","ME");
        countryCodesAndContinent.put("JO","ME");
        countryCodesAndContinent.put("KW","ME");
        countryCodesAndContinent.put("LB","ME");
        countryCodesAndContinent.put("NT","ME");
        countryCodesAndContinent.put("OM","ME");
        countryCodesAndContinent.put("QA","ME");
        countryCodesAndContinent.put("SA","ME");
        countryCodesAndContinent.put("SY","ME");
        countryCodesAndContinent.put("TR","ME");
        countryCodesAndContinent.put("TM","ME");
        countryCodesAndContinent.put("AE","ME");
        countryCodesAndContinent.put("YE","ME");
    }

    //### INNER CLASS : SiteData ##################################################################
    private class SiteData implements Comparable {
        public int id;
        public String country;
        public String countryCode;
        public String city;
        public String coordsLAT;
        public String coordsLNG; 
        public String dataType;
        public String dataDate;
        
        // counters
        public int patients;
        public int visits;
        public int admissions;
        public int transactions;
        public int debets;
        public int invoices;
        public int labs;
        
        //--- TO JSON ---------------------------------------------------------
        // { "serviceId":8,"coordsLAT":"x","coordsLONG":"x","value":16,"dataDate":"20/12/2012","location":"Nyamata, RW" },
        public String toJSON(boolean isLastRecord){    	 
   	        String sJSON = "{"+
                            "\"serviceId\":"+this.id+","+
                            "\"location\":\""+this.city+", "+this.country+"\","+ // city, country
                            "\"countryCode\":\""+this.countryCode+"\","+
                            "\"coordsLAT\":\""+this.coordsLAT+"\","+
                            "\"coordsLONG\":\""+this.coordsLNG+"\",";

   	        if(this.dataType.equals("sites")){
                sJSON+= "\"value\":1,";
   	        }
   	        else if(this.dataType.equals("patients")){
                sJSON+= "\"value\":"+this.patients+",";
   	        }   
   	        else if(this.dataType.equals("outpatients")){
                sJSON+= "\"value\":"+this.visits+",";
   	        }   
   	        else if(this.dataType.equals("admissions")){
                sJSON+= "\"value\":"+this.admissions+",";
   	        }   
   	        else if(this.dataType.equals("transactions")){
                sJSON+= "\"value\":"+this.transactions+",";
   	        }   
   	        else if(this.dataType.equals("debets")){
                sJSON+= "\"value\":"+this.debets+",";
   	        }   
   	        else if(this.dataType.equals("invoices")){
                sJSON+= "\"value\":"+this.invoices+",";
   	        }
   	        else if(this.dataType.equals("labanalyses")){
                sJSON+= "\"value\":"+this.labs+",";
   	        }
                               
            sJSON+=  "\"dataDate\":\""+this.dataDate+"\""+
                    "}"+(isLastRecord?"":",")+"\r\n";
                          
	       return sJSON;
       }   
       
       //--- COMPARE TO ------------------------------------------------------------------------------
       public int compareTo(Object o){
           int comp=0;
           
           if(o.getClass().isInstance(this)){
        	   // reverse
      	       if(this.dataType.equals("sites")){
                   comp = (this.countryCode.compareTo(((SiteData)o).countryCode));
       	       }
       	       else if(this.dataType.equals("patients")){
                   comp = -(this.patients - ((SiteData)o).patients);
       	       }   
       	       else if(this.dataType.equals("outpatients")){
                   comp = -(this.visits - ((SiteData)o).visits);
       	       }   
       	       else if(this.dataType.equals("admissions")){
                   comp = -(this.admissions - ((SiteData)o).admissions);
       	       }   
       	       else if(this.dataType.equals("transactions")){
                   comp = -(this.transactions - ((SiteData)o).transactions);
       	       }   
       	       else if(this.dataType.equals("debets")){
                   comp = -(this.debets - ((SiteData)o).debets);
       	       }   
       	       else if(this.dataType.equals("invoices")){
                   comp = -(this.invoices - ((SiteData)o).invoices);
       	       }
       	       else if(this.dataType.equals("labanalyses")){
                   comp = -(this.labs - ((SiteData)o).labs);
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
           if(!(o instanceof SiteData)) return false;
           
           final SiteData site = (SiteData)o;
           return site.id == (this.id);
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
		
	//--- GET COUNTRY COLOR PER WEIGHT ------------------------------------------------------------
	public String getCountryColorPerWeight(double centerValue, int value, int minValue, int maxValue){
        double rgbToCenterFactor = ((double)128/centerValue);
        int rgbScaled = (int)(rgbToCenterFactor*(double)value)-1; // 0 ~ 127
        
        if(rgbScaled > 255) rgbScaled = 255;
        if(rgbScaled < 0) rgbScaled = 0;
        
        /*
        // 3 colors
        String sColor = "000000";
             if(rgbScaled <=  85) sColor = "66bb00"; // green = light
	    else if(rgbScaled <= 170) sColor = "ff7700"; // orange
	    else if(rgbScaled <= 256) sColor = "ff3311"; // red3 = heavy
	    else{
	    }
        */
        
        //*** x shades of green ***
        int shadesCount = (maxValue-minValue)+1;
        if(shadesCount > 15) shadesCount = 15;
        String sColor = "";
        int rgbGreen;
        
        for(int i=0; i<=shadesCount; i++){
        	rgbGreen = (int)(((255d/(double)shadesCount)*i));
        	
        	if(rgbScaled <= rgbGreen){
        	    sColor = rgbToHtml(51,(255-rgbGreen),0); // 51 == 33 hex == some red to soften the green
        	    break;
        	}
        }   
	    
        return sColor; 
	}
	
	//--- RG TO HTML ------------------------------------------------------------------------------
	private String rgbToHtml(int r, int g, int b){
		String hexR = Integer.toHexString(r),
		       hexG = Integer.toHexString(g),
		       hexB = Integer.toHexString(b);

        if(hexR.length() < 2) hexR = "0"+hexR;
        if(hexG.length() < 2) hexG = "0"+hexG;
        if(hexB.length() < 2) hexB = "0"+hexB;

        return hexR+hexG+hexB; 
	}
	
	//--- GET CENTER VALUE ------------------------------------------------------------------------
	// center of effective value range : 20 ~ 200 --> 110
	private double getCenterValue(Vector servers){
		// sum values per country
		Hashtable valuesSummedPerCountry = new Hashtable();
		SiteData siteData;
		
		for(int i=0; i<servers.size(); i++){
			siteData = (SiteData)servers.get(i);
					
		    if(valuesSummedPerCountry.get(siteData.countryCode)==null){
		        if(siteData.dataType.equals("sites")){
		        	valuesSummedPerCountry.put(siteData.countryCode,1);
		        }
		        else if(siteData.dataType.equals("patients")){
		        	valuesSummedPerCountry.put(siteData.countryCode,siteData.patients);
		   	    }   
		   	    else if(siteData.dataType.equals("outpatients")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.visits);
		   	    }   
		   	    else if(siteData.dataType.equals("admissions")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.admissions);
		   	    }   
		   	    else if(siteData.dataType.equals("transactions")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.transactions);
		   	    }   
		   	    else if(siteData.dataType.equals("debets")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.debets);
		   	    }   
		   	    else if(siteData.dataType.equals("invoices")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.invoices);
		   	    }
		   	    else if(siteData.dataType.equals("labanalyses")){ // labs
		   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.labs);
		   	    }
		     }
		     else{
		        Integer value = (Integer)valuesSummedPerCountry.get(siteData.countryCode);
		
		        if(siteData.dataType.equals("sites")){
		        	valuesSummedPerCountry.put(siteData.countryCode,value+1);
		        }
		        else if(siteData.dataType.equals("patients")){
		        	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.patients);
		   	    }   
		   	    else if(siteData.dataType.equals("outpatients")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.visits);
		   	    }   
		   	    else if(siteData.dataType.equals("admissions")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.admissions);
		   	    }   
		   	    else if(siteData.dataType.equals("transactions")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.transactions);
		   	    }   
		   	    else if(siteData.dataType.equals("debets")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.debets);
		   	    }   
		   	    else if(siteData.dataType.equals("invoices")){
		   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.invoices);
		   	    }
		   	    else if(siteData.dataType.equals("labanalyses")){ // labs
		   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.labs);
		   	    }
			}
		}
		
		int minValue = getMinValue(valuesSummedPerCountry.values()), 
		    maxValue = getMaxValue(valuesSummedPerCountry.values());
		
		
		double centerValue = (double)minValue+((double)(maxValue-minValue)/2d); // 80 ~ 330 --> 80+(330/2) = 205
	    Debug.println("==> minValue = "+minValue); ///////////////
	    Debug.println("==> maxValue = "+maxValue); ///////////////
	    Debug.println("===> centerValue = "+centerValue); ///////////////

	    
		return centerValue; 
	}
	
    //#############################################################################################
    //### END COMMON FUNCTIONS ####################################################################
    //#############################################################################################	
    	
	//--- VECTOR TO JSON --------------------------------------------------------------------------
    public StringBuffer vectorToJSON(Vector vector, String sItemsType, String sParameter, String sTitle){
        StringBuffer sJSON = new StringBuffer();
                
        // open main array
        sJSON.append("var data = {\r\n")
             .append("\"queryDate\":\""+ScreenHelper.fullDateFormat.format(new java.util.Date())+"\",\r\n") // now
             .append("\"mapTitle\":\""+sTitle+"\",\r\n")
	         .append("\""+sItemsType+"\": [\r\n"); // services
        
        boolean lastRecord;
        for(int i=0; i<vector.size(); i++){
        	lastRecord = (i==vector.size()-1);
         	
        	// comma for all except last record
        	sJSON.append(((SiteData)(vector.get(i))).toJSON(lastRecord));   
        }

        // close main array
        sJSON.append("]\r\n").
             append("}\r\n");
        
        return sJSON;
    }
	
    public StringBuffer vectorToIMG(Vector servers, String sTitle, String sContinent, String sWebLanguage){        
        //*** a : count values per country ************************************
        // (instead of per hospital/town in the specified vector)
        Hashtable countryValues = new Hashtable();
        String sCountryCode, sDataType = "";
        SiteData site;
        
        for(int i=0; i<servers.size(); i++){
            site = (SiteData)servers.get(i);        	 	
            sCountryCode = site.countryCode;
                        
         	// country name
         	if(sCountryCode.length() > 0 && site.city.length() > 0){
       	        sCountryCode = sCountryCode.toUpperCase();
       	        if(sCountryCode.equals("B")) sCountryCode = "BE";
       	        if(sCountryCode.equals("GB")) sCountryCode = "GB-ENG"; // GB-ENG England country
       	                                                               // GB-NIR North Ireland province
       	                                                               // GB-SCT Scotland country
       	                                                               // GB-WLS Wales
       	        
       	        // take Kansas as center of US, otherwise wihtout state-code no label is shown                     
                if(countryValues.get(sCountryCode)==null){
           	        if(site.dataType.equals("sites")){
                        countryValues.put(sCountryCode,1);
           	        }
           	        else if(site.dataType.equals("patients")){
                        countryValues.put(sCountryCode,site.patients);
               	    }   
               	    else if(site.dataType.equals("outpatients")){
                        countryValues.put(sCountryCode,site.visits);
               	    }   
               	    else if(site.dataType.equals("admissions")){
                        countryValues.put(sCountryCode,site.admissions);
               	    }   
               	    else if(site.dataType.equals("transactions")){
                        countryValues.put(sCountryCode,site.transactions);
               	    }   
               	    else if(site.dataType.equals("debets")){
                        countryValues.put(sCountryCode,site.debets);
               	    }   
               	    else if(site.dataType.equals("invoices")){
                        countryValues.put(sCountryCode,site.invoices);
               	    }
               	    else if(site.dataType.equals("labanalyses")){
                        countryValues.put(sCountryCode,site.labs);
               	    }
                }
                else{
                    Integer value = (Integer)countryValues.get(sCountryCode);

           	        if(site.dataType.equals("sites")){
                        countryValues.put(sCountryCode,value+1);
           	        }
           	        else if(site.dataType.equals("patients")){
                        countryValues.put(sCountryCode,value+site.patients);
               	    }   
               	    else if(site.dataType.equals("outpatients")){
                        countryValues.put(sCountryCode,value+site.visits);
               	    }   
               	    else if(site.dataType.equals("admissions")){
                        countryValues.put(sCountryCode,value+site.admissions);
               	    }   
               	    else if(site.dataType.equals("transactions")){
                        countryValues.put(sCountryCode,value+site.transactions);
               	    }   
               	    else if(site.dataType.equals("debets")){
                        countryValues.put(sCountryCode,value+site.debets);
               	    }   
               	    else if(site.dataType.equals("invoices")){
                        countryValues.put(sCountryCode,value+site.invoices);
               	    }
               	    else if(site.dataType.equals("labanalyses")){
                        countryValues.put(sCountryCode,value+site.labs);
               	    }
                }
       	        
       	        if(sCountryCode.equals("US") && !sContinent.equalsIgnoreCase("World")){
       	        	sCountryCode = "US-KS"; // Kansas
       	        	
                    if(countryValues.get(sCountryCode)==null){
               	        if(site.dataType.equals("sites")){
                            countryValues.put(sCountryCode,1);
               	        }
               	        else if(site.dataType.equals("patients")){
                            countryValues.put(sCountryCode,site.patients);
                   	    }   
                   	    else if(site.dataType.equals("outpatients")){
                            countryValues.put(sCountryCode,site.visits);
                   	    }   
                   	    else if(site.dataType.equals("admissions")){
                            countryValues.put(sCountryCode,site.admissions);
                   	    }   
                   	    else if(site.dataType.equals("transactions")){
                            countryValues.put(sCountryCode,site.transactions);
                   	    }   
                   	    else if(site.dataType.equals("debets")){
                            countryValues.put(sCountryCode,site.debets);
                   	    }   
                   	    else if(site.dataType.equals("invoices")){
                            countryValues.put(sCountryCode,site.invoices);
                   	    }
                   	    else if(site.dataType.equals("labanalyses")){
                            countryValues.put(sCountryCode,site.labs);
                   	    }
                    }
                    else{
                        Integer value = (Integer)countryValues.get(sCountryCode);

               	        if(site.dataType.equals("sites")){
                            countryValues.put(sCountryCode,value+1);
               	        }
               	        else if(site.dataType.equals("patients")){
                            countryValues.put(sCountryCode,value+site.patients);
                   	    }   
                   	    else if(site.dataType.equals("outpatients")){
                            countryValues.put(sCountryCode,value+site.visits);
                   	    }   
                   	    else if(site.dataType.equals("admissions")){
                            countryValues.put(sCountryCode,value+site.admissions);
                   	    }   
                   	    else if(site.dataType.equals("transactions")){
                            countryValues.put(sCountryCode,value+site.transactions);
                   	    }   
                   	    else if(site.dataType.equals("debets")){
                            countryValues.put(sCountryCode,value+site.debets);
                   	    }   
                   	    else if(site.dataType.equals("invoices")){
                            countryValues.put(sCountryCode,value+site.invoices);
                   	    }
                   	    else if(site.dataType.equals("labanalyses")){
                            countryValues.put(sCountryCode,value+site.labs);
                   	    }
                    }
       	        }
         	} 
        }        

        int minValue = getMinValue(countryValues.values()),
            maxValue = getMaxValue(countryValues.values());
        
        //***** b : compose IMG tag *******************************************
        StringBuffer sIMG = new StringBuffer();
        
        // open image tag and src-attribute
        sIMG.append("<img src=\"http://chart.googleapis.com/chart?chs=600x450"); // max 300.000 pixels
        
        // zoom        
        if(sContinent.equalsIgnoreCase("World")){ // S,W,N,E
            sIMG.append("&cht=map:fixed=-56,-170,84,-173");
        }
        else if(sContinent.equalsIgnoreCase("Auto")){
            sIMG.append("&cht=map:auto");
        }
        else if(sContinent.equalsIgnoreCase("Africa")){
            sIMG.append("&cht=map:fixed=-36,-30,38,56");
        }
        else if(sContinent.equalsIgnoreCase("Europe")){
            sIMG.append("&cht=map:fixed=35,-13,71,48");
        }
        else if(sContinent.equalsIgnoreCase("Asia")){
        	sIMG.append("&cht=map:fixed=-10,25,75,180");
        }
        else if(sContinent.equalsIgnoreCase("North-America")){
        	sIMG.append("&cht=map:fixed=13,-175,76,-35");
        }
        else if(sContinent.equalsIgnoreCase("South-America")){
        	sIMG.append("&cht=map:fixed=-57,-130,20,-35");	
        }
        else if(sContinent.equalsIgnoreCase("Oceania")){
        	sIMG.append("&cht=map:fixed=-50,109,5,180");
        }
        else if(sContinent.equalsIgnoreCase("Middle-East")){
        	sIMG.append("&cht=map:fixed=10,20,45,75");
        }
                
        //*** data per country ****************************
        // chco (colors per country) &
        // chld (country-codes) &
        // chdl (country-names) &
        // chm (data to visualise)
        String chld = "&chld=",  chdl = "&chdl=", chco = "&chco=B3BCC0|", chm = "&chm=";
        String sCountryName, sCountryColor;
        int countryValue, countryIdx = 0;

        DecimalFormat deci = new DecimalFormat("#,###.###"); // 1.482,465
    	
        boolean applyCountryColorsPerWeight = true;
        centerValue = getCenterValue(servers);
        
        Enumeration countryCodeEnum = countryValues.keys();
        while(countryCodeEnum.hasMoreElements()){
        	sCountryCode = (String)countryCodeEnum.nextElement();
       	    countryValue = ((Integer)countryValues.get(sCountryCode)).intValue();
        	
        	sCountryName = getTranNoLink("country",sCountryCode,sWebLanguage);
        	if(sCountryName.indexOf(",") > 0){
        	    sCountryName = sCountryName.substring(0,sCountryName.indexOf(",")); 
        	}
        	sCountryName = normalizeSpecialCharacters(sCountryName);
        	sCountryName = sCountryName.toUpperCase();
        	
        	if(applyCountryColorsPerWeight){
           	    sCountryColor = getCountryColorPerWeight(centerValue,countryValue,minValue,maxValue);
        	}
        	else{
        		sCountryColor = (String)countryColors.get(countryIdx%10); // just the next color	
        	}
       	                  	
   	        chld+= sCountryCode+"|";
       	    chdl+= sCountryName+" : "+countryValue+" |";
       	    chco+= sCountryColor+"|";
       	
       	    if(sContinent.equals("World")){
	       	    if(countryValues.size() > 30){
         	    	// no flags per country --> to crowded
	       	    }
	       	    else if(countryValues.size() > 20){
	         	    chm+= "f"+sCountryCode+": "+deci.format(countryValue)+",000000,0,"+countryIdx+",8|"; // code
	       	    }
	       	    else{
	           	    chm+= "f"+sCountryName+": "+deci.format(countryValue)+",000000,0,"+countryIdx+",8|"; // name
	       	    }
       	    }
       	    else{
	       	    // show shorter code instead of name when many countrues are shown
	       	    if(sContinent.equals("Africa") || countryValues.size() > 10){
	         	    chm+= "f"+sCountryCode+": "+deci.format(countryValue)+",000000,0,"+countryIdx+",8|"; // code
	       	    }
	       	    else{
	           	    chm+= "f"+sCountryName+": "+deci.format(countryValue)+",000000,0,"+countryIdx+",8|"; // name
	       	    }
       	    }
       	    
            countryIdx++;
        }
        
        chld = chld.substring(0,chld.length()-1);
        chdl = chdl.substring(0,chdl.length()-1);
        chco = chco.substring(0,chco.length()-1);
        chm = chm.substring(0,chm.length()-1); 
        
	    sIMG.append(chld);	    
	    //sIMG.append(chdl); // legend
	    sIMG.append(chco);	        
	    sIMG.append(chm);	
        //*************************************************
        
        // chtt (title)        
        if(sContinent.length() > 0){
        	sTitle+= " - "+getTranNoLink("web",sContinent,sWebLanguage);
        }
        sTitle = normalizeSpecialCharacters(sTitle);
       	sTitle = sTitle.substring(0,1).toUpperCase()+sTitle.substring(1);
        sIMG.append("&chtt="+sTitle.replaceAll(" ","+"));
                	
        // close src-attribute
        sIMG.append("&chts=000000,16\" ");
                        	
        // close img tag        
        sIMG.append("width=\"600\" height=\"450\" alt=\""+sTitle+"\" style=\"border:1px solid #ccc\"/>");
        
        Debug.println(sIMG.toString());
        return sIMG;
    }
	
	//--- LOAD COORDS FROM FILE -------------------------------------------------------------------
	private Hashtable loadCoordsFromFile(){
        Hashtable coordsPerService = new Hashtable();        
        BufferedReader bufReader = null;
        String[] coords;
        String sFileUri = "";
        int serviceId, lineCount = 0;

        try{
        	// read csv
        	//String sContextPath = MedwanQuery.getInstance().getConfigString("contextpath");
        	String sContextPath = sAPPFULLDIR; // todo
        	sFileUri = sContextPath+"/datacenter/gis/googleMaps/data/coords.csv";
        	FileReader reader = new FileReader(sFileUri);
	        bufReader = new BufferedReader(reader);
        	
	        String sLine;
	        while((sLine = bufReader.readLine())!=null){
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
                if(bufReader!=null) bufReader.close();
        	}
        	catch(Exception e){
                e.printStackTrace();
        	}
        }

        Debug.println("Loaded "+coordsPerService.size()+" coords from '"+sFileUri+"'"); 
        return coordsPerService;
	}
	
	//--- GET COUNTRY CODES IN CONTINENT ----------------------------------------------------------
	private Vector getCountryCodesInContinent(String sContinentCode){
        Vector countryCodes = new Vector();
        
        Enumeration countryCodeEnum = countryCodesAndContinent.keys();
        String sTmpCountryCode, sTmpContinentCode;
        while(countryCodeEnum.hasMoreElements()){
        	sTmpCountryCode = (String)countryCodeEnum.nextElement();
        	sTmpContinentCode = (String)countryCodesAndContinent.get(sTmpCountryCode);
        	
        	if(sContinentCode.equalsIgnoreCase(sTmpContinentCode)){
                countryCodes.add(sTmpCountryCode);
        	}
        }
        
        return countryCodes;
	}
	
    //--- GET TOTAL VALUE -------------------------------------------------------------------------
    private int getTotalValue(Vector sites){
    	int totalValue = 0;
    	
    	SiteData site;
    	for(int i=0; i<sites.size(); i++){
    	    site = (SiteData)sites.get(i);

   	        if(site.dataType.equals("sites")){
                totalValue+= 1;
   	        }
   	        else if(site.dataType.equals("patients")){
                totalValue+= site.patients;
    	    }   
    	    else if(site.dataType.equals("outpatients")){
                totalValue+= site.visits;
    	    }   
    	    else if(site.dataType.equals("admissions")){
                totalValue+= site.admissions;
    	    }   
    	    else if(site.dataType.equals("transactions")){
                totalValue+= site.transactions;
    	    }   
    	    else if(site.dataType.equals("debets")){
                totalValue+= site.debets;
    	    }   
    	    else if(site.dataType.equals("invoices")){
                totalValue+= site.invoices;
    	    }
    	    else if(site.dataType.equals("labanalyses")){
                totalValue+= site.labs;
    	    }
    	}
    	
    	return totalValue;
    }
    
    //--- GET MIN VALUE ---------------------------------------------------------------------------
    private int getMinValue(Collection values){
        int minValue = 999999999; 
        int value = 0;

        Iterator iter = values.iterator();
    	while(iter.hasNext()){
    		value = (Integer)iter.next();    		        	
   	        if(value < minValue) minValue = value;
    	}
    	
        return minValue;
    }
    
    //--- GET MAX VALUE ---------------------------------------------------------------------------
    private int getMaxValue(Collection values){
        int maxValue = -999999999;  
        int value = 0;
    	
        Iterator iter = values.iterator();
    	while(iter.hasNext()){
    		value = (Integer)iter.next();
   	        if(value > maxValue) maxValue = value;
    	}
    	
        return maxValue;
    }    
%>

<%
    Debug.enabled = true; // todo : removeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    
	// form-data	
	String sSiteId    = ScreenHelper.checkString(request.getParameter("siteId")), 
           sMapType   = ScreenHelper.checkString(request.getParameter("mapType")),
           sParameter = ScreenHelper.checkString(request.getParameter("parameter")),
	       sContinent = ScreenHelper.checkString(request.getParameter("continent")); // used only for mapChart

    String jsonFileId = ScreenHelper.checkString(request.getParameter("jsonFileId"));
	if(sContinent.length()==0){
	    sContinent = "World"; // default
	} 

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("******** datacenter/gis/createJSONPublic.jsp ********");
        Debug.println("sSiteId    : "+sSiteId);
        Debug.println("sMapType   : "+sMapType);
        Debug.println("sParameter : "+sParameter);
        Debug.println("sContinent : "+sContinent);
        Debug.println("jsonFileId : "+jsonFileId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
    
    Vector servers = new Vector(); // "sites" actually..
    String sFileDir;
    String[] coords;
    
    // DB-stuff
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String sSql = "";

	//String sContextPath = MedwanQuery.getInstance().getConfigString("contextpath");
	String sContextPath = sAPPFULLDIR; 

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
	SortedMap countries = new TreeMap();
	SortedMap cities = null, sites = null;

	conn = MedwanQuery.getInstance().getStatsConnection();
	sSql = "select distinct * from dc_monitorservers a, dc_monitorvalues b"+
	       " where b.dc_monitorvalue_serverid = a.dc_monitorserver_serverid"+
	       "  and b.dc_monitorvalue_date > ?"+
	       "  and a.dc_monitorserver_name <> ''"+
	       "  and a.dc_monitorserver_country <> ''";
	 	       
	// limit to contries in specified continent
	String sContinentCode = ""; // no continent == worldwide
	     if(sContinent.equalsIgnoreCase("Oceania")) sContinentCode = "OC";
	else if(sContinent.equalsIgnoreCase("Asia"))    sContinentCode = "AS";
	else if(sContinent.equalsIgnoreCase("Africa"))  sContinentCode = "AF";
	else if(sContinent.equalsIgnoreCase("Europe"))  sContinentCode = "EU";
	else if(sContinent.equalsIgnoreCase("North-America")) sContinentCode = "NA";
	else if(sContinent.equalsIgnoreCase("South-America")) sContinentCode = "SA";
	else if(sContinent.equalsIgnoreCase("Middle-East")) sContinentCode = "ME"; // not a continent
	
	if(sContinentCode.length() > 0){
        Vector countryCodesPerContinent = getCountryCodesInContinent(sContinentCode);
        sSql+= " and a.dc_monitorserver_country in ("+vectorToString(countryCodesPerContinent,",",true)+")";
	}
	
	sSql+= " order by dc_monitorserver_country, dc_monitorserver_city, dc_monitorserver_serverid, dc_monitorvalue_date desc";
	Debug.println(sSql);
	ps = conn.prepareStatement(sSql);
	
	// revert one month
	long month = 30*24*3600;
	month = month*1000;	
	ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()-MedwanQuery.getInstance().getConfigInt("gbhPublicInactivityPeriodInMonths",3)*month));

	rs = ps.executeQuery();
	int serverid, activeServer = -1;
        
	while(rs.next()){
        serverid = rs.getInt("dc_monitorserver_serverid");
        
        if(serverid!=activeServer){
        	activeServer = serverid;
        	
        	String country = getTranNoLink("country",rs.getString("dc_monitorserver_country").replaceAll("ZR","CD").replaceAll("BE","B"),sWebLanguage).toUpperCase();
        	if(countries.get(country)==null){
                countries.put(country,new TreeMap());
        	}
        	
        	cities = (SortedMap)countries.get(country);
        	String city = rs.getString("dc_monitorserver_city");
        	if(cities.get(city)==null){
                cities.put(city,new TreeMap());
        	}
        	
        	sites = (SortedMap)cities.get(city);
        	
        	SiteData siteData = new SiteData();
        	siteData.id = activeServer;
        	siteData.country = country; 
        	siteData.countryCode = rs.getString("dc_monitorserver_country").replaceAll("ZR","CD").replaceAll("BE","B");
            siteData.city = city;
        	siteData.dataDate = ScreenHelper.stdDateFormat.format(rs.getTimestamp("dc_monitorvalue_date"));
        	siteData.dataType = sParameter;
        	siteData.coordsLAT = rs.getString("dc_monitorserver_latitude"); 
        	siteData.coordsLNG = rs.getString("dc_monitorserver_longitude");  
                	
        	
        	// counters
        	siteData.patients   = rs.getInt("dc_monitorvalue_patientcount");
        	siteData.visits     = rs.getInt("dc_monitorvalue_visitcount");
        	siteData.admissions = rs.getInt("dc_monitorvalue_admissioncount");
        	siteData.labs       = rs.getInt("dc_monitorvalue_labanalysescount");
        	siteData.invoices   = rs.getInt("dc_monitorvalue_patientinvoicecount");
        	siteData.debets     = rs.getInt("dc_monitorvalue_debetcount");
        	
        	sites.put(activeServer,siteData);
        	
        	// determine min and max value
        	int value = 0;
   	        if(siteData.dataType.equals("sites")){
   	        	value = 1;
   	        }
   	        else if(siteData.dataType.equals("patients")){
   	        	value = siteData.patients;
       	    }   
       	    else if(siteData.dataType.equals("outpatients")){
   	        	value = siteData.visits;
       	    }   
       	    else if(siteData.dataType.equals("admissions")){
   	        	value = siteData.admissions;
       	    }   
       	    else if(siteData.dataType.equals("transactions")){
   	        	value = siteData.transactions;
       	    }   
       	    else if(siteData.dataType.equals("debets")){
   	        	value = siteData.debets;
       	    }   
       	    else if(siteData.dataType.equals("invoices")){
   	        	value = siteData.invoices;
       	    }
       	    else if(siteData.dataType.equals("labanalyses")){
   	        	value = siteData.labs;
       	    }
        }
	}
	rs.close();
	ps.close();
	conn.close();
	
	Iterator countryIter = countries.keySet().iterator();
	SiteData siteData;
	String country;

	// run through countries
	while(countryIter.hasNext()){
        country = (String)countryIter.next();        
        cities = (SortedMap)countries.get(country);
        
        // run through cities
        Iterator cityIter = cities.keySet().iterator();
        while(cityIter.hasNext()){
        	String city = (String)cityIter.next();
        	sites = (SortedMap)cities.get(city);
        	Iterator siteIter = sites.keySet().iterator();
        	
        	// run through sites
        	while(siteIter.hasNext()){
                siteData = (SiteData)sites.get(siteIter.next());
                servers.add(siteData);
        	}
        }
	}
	
	// sum values per country
	Hashtable valuesSummedPerCountry = new Hashtable();
	for(int i=0; i<servers.size(); i++){
		siteData = (SiteData)servers.get(i);
				
	    if(valuesSummedPerCountry.get(siteData.countryCode)==null){
	        if(siteData.dataType.equals("sites")){
	        	valuesSummedPerCountry.put(siteData.countryCode,1);
	        }
	        else if(siteData.dataType.equals("patients")){
	        	valuesSummedPerCountry.put(siteData.countryCode,siteData.patients);
	   	    }   
	   	    else if(siteData.dataType.equals("outpatients")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.visits);
	   	    }   
	   	    else if(siteData.dataType.equals("admissions")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.admissions);
	   	    }   
	   	    else if(siteData.dataType.equals("transactions")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.transactions);
	   	    }   
	   	    else if(siteData.dataType.equals("debets")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.debets);
	   	    }   
	   	    else if(siteData.dataType.equals("invoices")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.invoices);
	   	    }
	   	    else if(siteData.dataType.equals("labanalyses")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,siteData.labs);
	   	    }
	     }
	     else{
	        Integer value = (Integer)valuesSummedPerCountry.get(siteData.countryCode);
	
	        if(siteData.dataType.equals("sites")){
	        	valuesSummedPerCountry.put(siteData.countryCode,value+1);
	        }
	        else if(siteData.dataType.equals("patients")){
	        	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.patients);
	   	    }   
	   	    else if(siteData.dataType.equals("outpatients")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.visits);
	   	    }   
	   	    else if(siteData.dataType.equals("admissions")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.admissions);
	   	    }   
	   	    else if(siteData.dataType.equals("transactions")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.transactions);
	   	    }   
	   	    else if(siteData.dataType.equals("debets")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.debets);
	   	    }   
	   	    else if(siteData.dataType.equals("invoices")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.invoices);
	   	    }
	   	    else if(siteData.dataType.equals("labanalyses")){
	   	    	valuesSummedPerCountry.put(siteData.countryCode,value+siteData.labs);
	   	    }
		}
	}
	
	int minValue = getMinValue(valuesSummedPerCountry.values()), 
	    maxValue = getMaxValue(valuesSummedPerCountry.values());

	Debug.println("countries : "+countries.size());
	Debug.println("sites : "+servers.size());
    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //*************************************************************************
    //*** write xml to file ***************************************************
    //*************************************************************************        
    if(servers.size() > -1){
        // title
        String sTitle = MedwanQuery.getInstance().getLabel("web",sParameter,sWebLanguage);
                
        //*** mapChart (not a json, but an html containing an img tag) ***
        if(sMapType.equals("mapChart")){
   	        try{                   	        	
    	        // create new file
                sFileDir = sContextPath+"/datacenter/gis/googleMaps";
                FileWriter writer = new FileWriter(sFileDir+"/mapChart_"+jsonFileId+".html");
                
                writer.write("<html>");
                writer.write("<title>MapChart - "+sContinent+"</title>");
                
                // ajax
                writer.write("<script src='"+sCONTEXTPATH+"/_common/_script/prototype.js'></script>");
                
                // table
                writer.write("<table style='font-family:Arial;font-size:12px;'>"+
                              "<tr>");
                
                // col 1 : IMG tag
                Collections.sort(servers);
                writer.write("<td>"+vectorToIMG(servers,sTitle,sContinent,sWebLanguage).toString()+"</td>\n");
                
                // col 2 : links to other continents
                writer.write("<td style='vertical-align:top;padding-top:3px;'>\n");

                /*
                if(sContinent.equalsIgnoreCase("Auto")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('Auto');\">Auto</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('Auto');\">Auto</a>\n");
                }
                */
                
                if(sContinent.equalsIgnoreCase("World")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('World');\">"+HTMLEntities.htmlentities(getTran("web","world",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('World');\">"+HTMLEntities.htmlentities(getTran("web","world",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("Africa")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('Africa');\">"+HTMLEntities.htmlentities(getTran("web","africa",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('Africa');\">"+HTMLEntities.htmlentities(getTran("web","africa",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("Middle-East")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('Middle-East');\">"+HTMLEntities.htmlentities(getTran("web","middle-east",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('Middle-East');\">"+HTMLEntities.htmlentities(getTran("web","middle-east",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("Europe")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('Europe');\">"+HTMLEntities.htmlentities(getTran("web","europe",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('Europe');\">"+HTMLEntities.htmlentities(getTran("web","europe",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("North-America")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('North-America');\">"+HTMLEntities.htmlentities(getTran("web","north-america",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('North-America');\">"+HTMLEntities.htmlentities(getTran("web","north-america",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("South-America")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('South-America');\">"+HTMLEntities.htmlentities(getTran("web","south-america",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('South-America');\">"+HTMLEntities.htmlentities(getTran("web","south-america",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("Asia")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('Asia');\">"+HTMLEntities.htmlentities(getTran("web","asia",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('Asia');\">"+HTMLEntities.htmlentities(getTran("web","asia",sWebLanguage))+"</a>\n");
                }
                
                if(sContinent.equalsIgnoreCase("Oceania")){
                    writer.write("<li><b><a href='#' onClick=\"javascript:showContinent('Oceania');\">"+HTMLEntities.htmlentities(getTran("web","oceania",sWebLanguage))+"</a></b>\n");
                }
                else{
                    writer.write("<li><a href='#' onClick=\"javascript:showContinent('Oceania');\">"+HTMLEntities.htmlentities(getTran("web","oceania",sWebLanguage))+"</a>\n");
                }
                
                // legend
	            DecimalFormat deci = new DecimalFormat("#,###");
                
                if(servers.size() > 0){	                
	                // spacer
	                writer.write("<br><br><table width='100%' cellspacing='0' cellpadding='0'>");

	                double rgbToCenterFactor = ((double)128/centerValue);
	                
	                /*
	                // 3 colors
	                writer.write("<li><font color='66bb00'>green : <= "+deci.format(85d/rgbToCenterFactor)+"</font>");
	                writer.write("<li><font color='ff7700'>orange : <= "+deci.format(170d/rgbToCenterFactor)+"</font>");
	                writer.write("<li><font color='ff3311'>red : <= "+deci.format(256d/rgbToCenterFactor)+"</font>");
	                */

	                //*** x shades of green ***
	                int shadesCount = (maxValue-minValue)+1;
	                if(shadesCount > 15) shadesCount = 15;
	                String sColor = "";
	                int rgbGreen;
	         
	                for(int i=shadesCount-1; i>0; i--){
	                	rgbGreen = (int)(((255d/(double)shadesCount)*i));
                 	    sColor = rgbToHtml(51,rgbGreen,0); // 51 == 33 hex == some red to soften the green

	                    writer.write("<tr><td style='text-align:center' bgcolor='#"+sColor+"'><font style='color:#ffffff;font-size:12px'><= "+deci.format((int)((255-rgbGreen)/rgbToCenterFactor))+"&nbsp;</font></td></tr>");
	                }
	                
                    // last legend
	                int prevRgbGreen = (int)(((255d/(double)shadesCount)*1)); // before the last legend
                    rgbGreen = (int)(((255d/(double)shadesCount)*0));
                 	sColor = rgbToHtml(51,rgbGreen,0); // 51 == 33 hex == some red to soften the green
                    writer.write("<tr><td style='text-align:center' bgcolor='#"+sColor+"'><font style='color:#ffffff;font-size:12px'>&nbsp;> "+deci.format((int)((255-prevRgbGreen)/rgbToCenterFactor))+"&nbsp;</font></td></tr>");
                }
                
                writer.write("</table></td>\n");
                                 
                writer.write( "</tr>\n"+
                             "<table>\n");                

                // wcripts
                writer.write("<script>\n");


    	       	// generate new id 
    	       	jsonFileId = Long.toString(System.currentTimeMillis());
    	       	
                // a : showContinent    	       
                writer.write("function showContinent(sContinent){\n"+
                              "var url = '"+request.getContextPath()+"/datacenter/gis/createJSONPublic.jsp"+
                               "?ts='+new Date().getTime()+'"+
                               "&siteId="+sSiteId+
                               "&mapType="+sMapType+
                               "&parameter="+sParameter+
                               "&jsonFileId="+jsonFileId+
                               "&continent='+sContinent;"+                                       
                              "new Ajax.Request(url,{\n"+
                              " method: 'GET',\n"+
                              " onSuccess: function(resp){\n"+
    	                      "  url = '"+request.getContextPath()+"/datacenter/gis/googleMaps/"+sMapType+"_"+jsonFileId+".html?ts='+new Date().getTime();\n"+
    	                      "  gisWin = window.open(url,'GISVisualiser','toolbar=no,status=no,scrollbars=yes,resizable=yes,width=890,height=515,menubar=no');\n"+
                              " },\n"+
                              " onFailure: function(resp){\n"+
                              "  alert(resp.responseText);\n"+
                              " }\n"+
                              "});\n"+                              
                             "}\n");
                
                // b : center popup
                writer.write("window.moveTo((self.screen.width-document.body.clientWidth)/2,(self.screen.height-document.body.clientHeight)/2);\n");
                
                writer.write("</script>\n");

                //*** display total below IMG ***
	            DecimalFormat deciTotal = new DecimalFormat("#,###.###");
	                
                writer.write("<div style='font-family:Arial;font-size:8pt;'>"+
             	               deciTotal.format(getTotalValue(servers))+" "+getTranNoLink("web",sParameter,sWebLanguage).toLowerCase()+" "+getTran("web","datacenter.in",sWebLanguage).toLowerCase()+" "+countries.size()+" "+getTran("web","countries",sWebLanguage)+", "+getTran("web","datacenter.in",sWebLanguage).toLowerCase()+" "+getTranNoLink("web",sContinent,sWebLanguage)+
                             "</div>");
                    
                if(servers.size() > 0){
	                writer.write("<div style='font-family:Arial;font-size:8pt;'>"+
	                               "minValue: "+deci.format(minValue)+", maxValue: "+deci.format(maxValue)+
	                             "</div>");        
                }
                
                writer.write("</html>");                
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
    	        // sort ASC
    	    	Collections.sort(servers);
    	    	
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