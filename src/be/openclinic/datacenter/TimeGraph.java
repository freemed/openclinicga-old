package be.openclinic.datacenter;
import java.awt.Color;
import java.awt.geom.Ellipse2D;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.List;
import java.util.LinkedList;
import java.util.Vector;

import javax.mail.MessagingException;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtilities;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.data.time.Day;
import org.jfree.data.time.RegularTimePeriod;
import org.jfree.data.time.TimeSeries;
import org.jfree.data.time.TimeSeriesCollection;
import org.jfree.data.time.TimeSeriesDataItem;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.StatFunctions;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfPCell;
import com.lowagie.text.pdf.hyphenation.TernaryTree.Iterator;
public class TimeGraph {
    /*
   USED TO CREATE A IMAGE OF GRAPH
    */
    public static String drawSimpleValueGraph(Date begin, Date end, int serverId, String parameterId, String sLanguage, String userid) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            TimeSeries series = new TimeSeries("data");
            conn = MedwanQuery.getInstance().getStatsConnection();
            ps = conn.prepareStatement("select * from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME between ? and ? order by DC_SIMPLEVALUE_CREATEDATETIME");
            ps.setInt(1, serverId);
            ps.setString(2, parameterId);
            ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(4, new java.sql.Timestamp(end.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                series.addOrUpdate(new Day(rs.getTimestamp("DC_SIMPLEVALUE_CREATEDATETIME")), Integer.parseInt(rs.getString("DC_SIMPLEVALUE_DATA")));
            }
            rs.close();
            TimeSeriesCollection dataset = new TimeSeriesCollection(series);
            // create chart
            final JFreeChart chart = ChartFactory.createTimeSeriesChart(
                    ScreenHelper.getTranNoLink("datacenterserver", serverId + "", sLanguage) + "\n" + ScreenHelper.getTranNoLink("datacenterparameter", parameterId, sLanguage), // chart title
                    ScreenHelper.getTranNoLink("web", "time", sLanguage), // domain axis label
                    "#", // range axis label
                    dataset, // data
                    false, // legend
                    false, // tooltips
                    false // urls
            );
            // customize chart
            chart.setAntiAlias(true);
            // round dots for all series
            XYPlot plot = chart.getXYPlot();
            plot.setBackgroundPaint(Color.WHITE);
            plot.setRangeGridlinePaint(Color.GRAY);
            plot.setDomainGridlinePaint(Color.GRAY);
            XYLineAndShapeRenderer renderer = new XYLineAndShapeRenderer();
            int dotSize = 4;
            renderer.setSeriesShape(0, new Ellipse2D.Double(dotSize / 2.0 * (-1), dotSize / 2.0 * (-1), dotSize, dotSize));
            renderer.setSeriesShapesVisible(1, false);
            renderer.setSeriesPaint(0, Color.BLACK);
            renderer.setSeriesPaint(1, Color.RED);
            plot.setRenderer(renderer);
            File file = new File(MedwanQuery.getInstance().getConfigString("DocumentsFolder") + "/" + userid + "." + serverId + "." + parameterId + ".png");
            file.delete();
            ChartUtilities.saveChartAsPNG(file, chart, 640, 480);
            return file.getName();
        }
        catch (Exception e) {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException e2) {
                // TODO Auto-generated catch block
                e2.printStackTrace();
            }
            e.printStackTrace();
        }
        finally {
            try {
                conn.close();
            } catch (SQLException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return null;
    }
    /*
    METHOD TO USE
    Will create a Sorted List
    */
    public static List getListValueGraph(Date begin, Date end, int serverId, String parameterId, String sLanguage, String userid) {
        Connection conn = null;
        PreparedStatement ps = null;
        List lArray = new LinkedList();
        try {
            conn = MedwanQuery.getInstance().getStatsConnection();
            ps = conn.prepareStatement("select * from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME between ? and ? order by DC_SIMPLEVALUE_CREATEDATETIME");
            ps.setInt(1, serverId);
            ps.setString(2, parameterId);
            ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(4, new java.sql.Timestamp(end.getTime()));
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // series.addOrUpdate(new Day(rs.getTimestamp("DC_SIMPLEVALUE_CREATEDATETIME")), Integer.parseInt(rs.getString("DC_SIMPLEVALUE_DATA")));
                Date dDate = rs.getTimestamp("DC_SIMPLEVALUE_CREATEDATETIME");
                Integer iValue = Integer.parseInt(rs.getString("DC_SIMPLEVALUE_DATA"));
                lArray.add(new Object[]{dDate, iValue});
            }
            rs.close();
        }
        catch (Exception e) {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (SQLException e2) {
                // TODO Auto-generated catch block
                e2.printStackTrace();
            }
            e.printStackTrace();
        }
        finally {
            try {
                conn.close();
            } catch (SQLException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        return lArray;
    }
    
    //--- GET LIST VALUE GRAPH FOR SERVER GROUP ---------------------------------------------------
    public static List getListValueGraphForServerGroup(java.util.Date begin, java.util.Date end, int serverGroupId,
     		                                           String parameterId, String sLanguage, String userid){
    	List graphData = null; // object to return
    	
        Debug.println("\n**************************** getListValueGraphForServerGroup ****************************\n");
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Debug.println("serverGroupId : "+serverGroupId);
        Debug.println("parameterId : "+parameterId);
        Debug.println("begin : "+ScreenHelper.stdDateFormat.format(begin));
        Debug.println("end : "+ScreenHelper.stdDateFormat.format(end)+"\n");
        
        try{
            //begin = ScreenHelper.stdDateFormat.parse("01/07/2012"); // debug
            //end = ScreenHelper.stdDateFormat.parse("01/08/2012"); // debug
             
            conn = MedwanQuery.getInstance().getStatsConnection();
            
            // get serverids in specified servergroup
            String sServerIds = ScreenHelper.vectorToString(getServerIdsInServerGroup(serverGroupId),",",false);
            if(sServerIds.endsWith(",")){
            	sServerIds = sServerIds.substring(0,sServerIds.length()-1);
            }
            Debug.println("sServerIds : "+sServerIds);
            
            // fetch data from database (might contain 'holes' on days servers did not send data)
            String sSql = "select distinct max(DC_SIMPLEVALUE_DATA) as value, DC_SIMPLEVALUE_SERVERID as serverid,"+
                          "  DATE_FORMAT(DC_SIMPLEVALUE_CREATEDATETIME,'%Y/%m/%d') as date"+
                          " from DC_SIMPLEVALUES"+
                          "  where DC_SIMPLEVALUE_SERVERID IN ("+sServerIds+")"+
            		      "   and DC_SIMPLEVALUE_PARAMETERID = ?"+
                          "   and DC_SIMPLEVALUE_CREATEDATETIME between ? and ?"+
            		      " group by serverid, date"+
            		      "  order by date asc";
            Debug.println("\nsSql : "+sSql+"\n");
            ps = conn.prepareStatement(sSql);
            ps.setString(1,parameterId);
            ps.setTimestamp(2,new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(3,new java.sql.Timestamp(end.getTime()));
            rs = ps.executeQuery();
            
            //*** 1 - sum per server and per date **********************************
            Debug.println("\n***************** 1 - sum per server and per date ****************\n");
            java.util.Date date;
            Integer value = null;
            Hashtable valuesPerServerAndPerDate = new Hashtable();
            Hashtable valuesPerServer; // values on specific date for one server
            int rsCount = 0, serverId;
            
            while(rs.next()){
            	// 3 values from rs  : 
                date = rs.getDate("date");    
                serverId = rs.getInt("serverid");
                value = Integer.parseInt(rs.getString("value"));
                                
                if(valuesPerServerAndPerDate.get(serverId)==null){ 
                	valuesPerServer = new Hashtable();
                	valuesPerServer.put(date,new Integer(value));
                	valuesPerServerAndPerDate.put(serverId,valuesPerServer); // init hashes   
                	
                    Debug.println("**** ["+(rsCount++)+"](a) serverId/date : "+serverId+"$"+ScreenHelper.stdDateFormat.format(date)+" --> "+value); // todo             	
                }
                else{
                	valuesPerServer = (Hashtable)valuesPerServerAndPerDate.get(serverId);
                	if(valuesPerServer.get(date)==null){
                        valuesPerServer.put(date,new Integer(value));
                        
                    	Debug.println("**** ["+(rsCount++)+"](b) serverId/date : "+serverId+"$"+ScreenHelper.stdDateFormat.format(date)+" --> 0+"+value+" = "+value); // todo
                	}
                	else{
                	    int existingValue = (Integer)valuesPerServer.get(date);
                        valuesPerServer.put(date,new Integer(existingValue+value));
                        
                    	Debug.println("**** ["+(rsCount++)+"](c) serverId/date : "+serverId+"$"+ScreenHelper.stdDateFormat.format(date)+" --> "+existingValue+"+"+value+" = "+new Integer(existingValue+value)); // todo
                	}             	
                }                
            }
            rs.close();
            ps.close();
            
            //*** 2 - calculate value on missing dates, per server *****************
            Debug.println("\n***************** 2 - calculate value on missing dates, per server *****************\n");
            java.util.Date periodBegin = null, periodEnd = null;
            boolean inPeriod = false;
            long millisInDay = 24*3600*1000;
            Integer beginValue = null, endValue = null, prevValue;
            int valuePerDate = 0;

            java.util.Date generalLastDate = end;
            java.util.Date firstDate, lastDate; 
            Debug.println("generalLastDate : "+ScreenHelper.stdDateFormat.format(generalLastDate)+"\n");
            
            // loop servers : to complete wholes and extend period until generalBegin and generalEnd
            Vector serverIds = new Vector(valuesPerServerAndPerDate.keySet());
            Collections.sort(serverIds); // required ?
                         
            for(int s=0; s<serverIds.size(); s++){
            	serverId = (Integer)serverIds.get(s);
            	Debug.println("\n@@@@@@@@@@@@@@@ serverId : "+serverId+" @@@@@@@@@@@@@@@@@@");

            	// reset per server
            	beginValue = 0;
	        	prevValue = 0;
                inPeriod = false;

	            // determine first date for this server
	        	Calendar cal = Calendar.getInstance();
            	valuesPerServer = (Hashtable)valuesPerServerAndPerDate.get(serverId);
	            Vector serverDaysVector = new Vector(valuesPerServer.keySet());
	            Collections.sort(serverDaysVector);
	        	firstDate = (java.util.Date)serverDaysVector.get(0);	        	
	        	cal.setTime(firstDate);
	        	Debug.println("firstDate for server "+serverId+" : "+ScreenHelper.stdDateFormat.format(firstDate));
	        	
	            // loop all days in period
	            while(cal.getTime().getTime() < generalLastDate.getTime()){
	            	// check for and compute missing values per server           	
	            	date = cal.getTime();
	            	Debug.println("*** processing cal date : "+ScreenHelper.stdDateFormat.format(date)+" ***");
	            	
	            	if(valuesPerServer.get(date)==null){
	                	// found missing date
	            		if(!inPeriod){
		                	periodBegin = date;
		                	beginValue = prevValue;
		                	inPeriod = true;
	            		}
	            		
	                	Debug.println("found missing date for server "+serverId+" : "+ScreenHelper.formatDate(periodBegin)+" = "+beginValue);
	            	}
	            	else{
	                    value = (Integer)valuesPerServer.get(date);
	                    prevValue = value;
		            	Debug.println("value on date "+ScreenHelper.stdDateFormat.format(date)+" for server "+serverId+" = "+value);
	                        	
	                	if(inPeriod){
	                		periodEnd = date;
	                    	Debug.println("periodBegin : "+ScreenHelper.formatDate(periodBegin));
	                    	Debug.println("periodEnd : "+ScreenHelper.formatDate(periodEnd));
	                		endValue = value;
	                    	Debug.println("beginValue : "+beginValue);
	                    	Debug.println("endValue : "+endValue+"\n");
	                		
	                		//*** calculate values on missing dates ***
	                        // 2013-01-20 --> 424
	                        // 2013-01-24 --> 640
	                        // ==> 2013-01-21 --> dayX0 + (640-424)/4 = 424 + (216/4) --> 424 + 54 = 478
	                        //     2013-01-22 --> 478 + 54 = 532
	                        //     2013-01-23 --> 532 + 54 = 586
	                		int daysInPeriod = (int)(((long)periodEnd.getTime() - (long)periodBegin.getTime())/millisInDay);
	                    	Debug.println("daysInPeriod : "+daysInPeriod);
	                    	
	                    	int periodValueDiff = endValue - beginValue;
	                    	Debug.println("periodValueDiff : "+periodValueDiff);
	                    	
	                    	int interpolatedDayValue = periodValueDiff/daysInPeriod;
	                    	Debug.println("interpolatedDayValue : "+interpolatedDayValue+"\n");
	                    	
	                    	// add missing days to hash, starting at begin of period
	                    	Calendar period = Calendar.getInstance();
	                    	period.setTime(periodBegin);

	                    	java.util.Date missingDate;
	                    	for(int d=0; d<daysInPeriod; d++){
	                    		missingDate = period.getTime();
	                        	Debug.println("missingDate : "+ScreenHelper.stdDateFormat.format(missingDate));
	                    		
	                    		valuesPerServer.put(missingDate,(beginValue+interpolatedDayValue));
	                    		Debug.println("["+d+"] (b) "+ScreenHelper.stdDateFormat.format(missingDate)+" = "+(beginValue+interpolatedDayValue)); // todo

	                    		period.add(Calendar.DATE,1);
	                    	}  
	                    	
	                		inPeriod = false;                  
	                	}	
	                }
	            	
	            	cal.add(Calendar.DATE,1); // proceed one day 
	            }           

	            // extrapolate last period too	            
	        	Debug.println("************* extrapolate last period too ************");        	
	        	if(!inPeriod){      
		            prevValue = value;
		            periodBegin = periodEnd; // end of last period
		            if(periodBegin==null){
		            	periodBegin = cal.getTime();
		            }
	        	} 
	        	
	        	periodEnd = generalLastDate;

            	Debug.println("periodBegin : "+ScreenHelper.formatDate(periodBegin)); 
            	Debug.println("periodEnd   : "+ScreenHelper.formatDate(periodEnd));
            	Debug.println("prevValue   : "+prevValue);
            	
        		if(periodEnd.getTime() >= periodBegin.getTime()){	            		        		
	        		//*** calculate values on missing dates ***
	        		int daysInPeriod = (int)(((long)periodEnd.getTime() - (long)periodBegin.getTime())/millisInDay);
	            	Debug.println("daysInPeriod : "+daysInPeriod);
	            	
	            	// add missing days to hash, starting at begin of period
	            	Calendar period = Calendar.getInstance();
	            	period.setTime(periodBegin);

	            	java.util.Date missingDate;
	            	for(int d=0; d<daysInPeriod; d++){
	            		missingDate = period.getTime();
	                	Debug.println("missingDate : "+ScreenHelper.stdDateFormat.format(missingDate));
	            		
	            		valuesPerServer.put(missingDate,prevValue);
	            		Debug.println("["+d+"] (b) "+ScreenHelper.stdDateFormat.format(missingDate)+" = "+prevValue);
	
	            		period.add(Calendar.DATE,1);
	            	}
	        	}
            } 	
        	
            //*** 3 - convert hash to list (summing server values per date) *******
            Debug.println("\n**************** 3 - convert hash to list (summing server values per date) *************\n");
            serverIds = new Vector(valuesPerServerAndPerDate.keySet());
            Collections.sort(serverIds); // required ?
            
            Vector days; 
            Hashtable dataHash = new Hashtable();
            for(int s=0; s<serverIds.size(); s++){
            	serverId = (Integer)serverIds.get(s);
            	Debug.println("\n*** serverId = "+serverId+" *************************************************");		
            	valuesPerServer = (Hashtable)valuesPerServerAndPerDate.get(serverId);
            	
            	// loop days of one server
                days = new Vector(valuesPerServer.keySet());
                Collections.sort(days);
            
	            for(int d=0; d<days.size(); d++){
	            	date = (java.util.Date)days.get(d);
	            	value = (Integer)valuesPerServer.get(date);
	            	Debug.println("loop-date : "+ScreenHelper.stdDateFormat.format(date)+" = "+value); 
	            	
	            	// search dataHash for date-value pair with same date
	            	Object[] pair;
	            	boolean valueOnDateFound = false;
	            	Enumeration dataEnum = dataHash.elements();
                    while(dataEnum.hasMoreElements()){
	            		pair = (Object[])dataEnum.nextElement();
	            		
	            		// value on date found --> add server-value
		            	if(((java.util.Date)pair[0]).getTime()==date.getTime()){
		            		value = (Integer)pair[1]+value;			            	
		            		pair = new Object[]{date,value};		            		
		            		dataHash.put(date,pair);
		            		
		            	    Debug.println(" --> sum with existing pair : "+ScreenHelper.stdDateFormat.format(date)+" - "+value);
		            	    valueOnDateFound = true;
		            		break;
		            	}
	            	}
	            	
	            	if(!valueOnDateFound){       	
	            		dataHash.put(date,new Object[]{date,value}); // init pair on date
	            	    Debug.println(" --> add new pair : "+ScreenHelper.stdDateFormat.format(date)+" - "+value);
	            	}
	            }
            }  
            
            //*** 4 - vector to list ***********************************************
            graphData = new LinkedList();
            
            // sort dataHash on date
            Vector dataDates = new Vector(dataHash.keySet());
            Collections.sort(dataDates);
            
            // fill up list from dataHash
            Object[] pair;
            for(int i=0; i<dataDates.size(); i++){
            	date = (java.util.Date)dataDates.get(i);
            	pair = (Object[])dataHash.get(date);
            	
            	graphData.add(pair);
            }
             
            // display content of list
            if(Debug.enabled){
	        	Debug.println("\n#################################################################################"); //////////////
	            for(int m=0; m<graphData.size(); m++){
	            	pair = (Object[])graphData.get(m);
	            	Debug.println(ScreenHelper.stdDateFormat.format(pair[0])+" - "+pair[1]); //////////////
	            }
	        	Debug.println("#################################################################################\n"); //////////////
            }
        }
        catch(Exception e){
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
            }
            catch(SQLException e2){
                e2.printStackTrace();
            }
            e.printStackTrace();
        }
        finally{
            try{
                conn.close();
            }
            catch(SQLException e){
                e.printStackTrace();
            }
        }
        
        return graphData;
    }

    //--- GET SERVER IDS IN SERVER GROUP ----------------------------------------------------------
    private static Vector getServerIdsInServerGroup(int serverGroupId){
	    Vector serverIds = new Vector();
	    
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    	    
	    try{
	    	String sSql = "SELECT distinct dc_server_serverid"+
	                      " FROM dc_servers a, dc_servergroups b"+
	                      "  WHERE a.dc_server_serverid = b.dc_servergroup_serverid"+
	                      "   AND b.dc_servergroup_id = ?";
			conn = MedwanQuery.getInstance().getOpenclinicConnection();
			ps = conn.prepareStatement(sSql);
			ps.setInt(1,serverGroupId);
			rs = ps.executeQuery();
			
			while(rs.next()){
				serverIds.add(new Integer(rs.getInt("dc_server_serverid")).toString()); // as String !
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
	    
	    return serverIds;
    }
}
