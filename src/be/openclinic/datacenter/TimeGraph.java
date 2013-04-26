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
import java.util.Date;
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
            TimeSeries series = new TimeSeries("data");
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
    public static List getListValueGraphForServerGroup(Date begin, Date end, int serverGroupId,
    		                                           String parameterId, String sLanguage, String userid) {
        Connection conn = null;
        PreparedStatement ps = null;
        List lArray = new LinkedList();
        try {
            TimeSeries series = new TimeSeries("data");
            conn = MedwanQuery.getInstance().getStatsConnection();
            String sServerIds = ScreenHelper.vectorToString(getServerIdsInServerGroup(serverGroupId),",",false);
            if(sServerIds.endsWith(",")) sServerIds = sServerIds.substring(0,sServerIds.length()-1);
            
            String sSql = "select SUM(DC_SIMPLEVALUE_DATA) as sum, DC_SIMPLEVALUE_CREATEDATETIME"+
                          " from DC_SIMPLEVALUES"+
                          "  where DC_SIMPLEVALUE_SERVERID IN ("+sServerIds+")"+
            		      "   and DC_SIMPLEVALUE_PARAMETERID = ?"+
                          "   and DC_SIMPLEVALUE_CREATEDATETIME between ? and ?"+
            		      " group by DC_SIMPLEVALUE_CREATEDATETIME"+
            		      " order by DC_SIMPLEVALUE_CREATEDATETIME";
            ps = conn.prepareStatement(sSql);
            ps.setString(1,parameterId);
            ps.setTimestamp(2,new java.sql.Timestamp(begin.getTime()));
            ps.setTimestamp(3,new java.sql.Timestamp(end.getTime()));
            ResultSet rs = ps.executeQuery();
            
            while(rs.next()){
                Date dDate = rs.getTimestamp("DC_SIMPLEVALUE_CREATEDATETIME");
                System.out.println("\n******************* dDate : "+dDate); // todo
                Integer iValue = Integer.parseInt(rs.getString("sum"));
                System.out.println("******************* iValue : "+iValue); // todo
                lArray.add(new Object[]{dDate,iValue});
            }
            rs.close();
        }
        catch(Exception e){
            try{
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
        
        return lArray;
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
	                      "  WHERE a.dc_server_serverid = b.dc_servergroup_id"+
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
