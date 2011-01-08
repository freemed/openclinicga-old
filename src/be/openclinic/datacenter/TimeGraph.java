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

import com.lowagie.text.Cell;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.PdfPCell;

public class TimeGraph {
	
	public static String drawSimpleValueGraph(Date begin,Date end, int serverId, String parameterId, String sLanguage,String userid){
    	
		Connection conn=null;
		PreparedStatement ps=null;
        try {
			TimeSeries series = new TimeSeries("data");
			conn = MedwanQuery.getInstance().getStatsConnection();
			ps = conn.prepareStatement("select * from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME between ? and ? order by DC_SIMPLEVALUE_CREATEDATETIME");
			ps.setInt(1, serverId);
			ps.setString(2, parameterId);
			ps.setTimestamp(3, new java.sql.Timestamp(begin.getTime()));
			ps.setTimestamp(4, new java.sql.Timestamp(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
	    		series.addOrUpdate(new Day(rs.getTimestamp("DC_SIMPLEVALUE_CREATEDATETIME")),Integer.parseInt(rs.getString("DC_SIMPLEVALUE_DATA")));
	    	}
			rs.close();
			
	    	TimeSeriesCollection dataset = new TimeSeriesCollection(series);
	    	// create chart
	        final JFreeChart chart = ChartFactory.createTimeSeriesChart(
	        		ScreenHelper.getTranNoLink("datacenterserver", serverId+"", sLanguage)+"\n"+ScreenHelper.getTranNoLink("datacenterparameter", parameterId, sLanguage), // chart title
	            ScreenHelper.getTranNoLink("web","time", sLanguage), // domain axis label
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
	        renderer.setSeriesShape(0,new Ellipse2D.Double(dotSize/2.0*(-1),dotSize/2.0*(-1),dotSize,dotSize));
	        renderer.setSeriesShapesVisible(1, false);
	        renderer.setSeriesPaint(0, Color.BLACK);
	        renderer.setSeriesPaint(1, Color.RED);
	        plot.setRenderer(renderer);
	        File file = new File(MedwanQuery.getInstance().getConfigString("DocumentsFolder")+"/"+userid+"."+serverId+"."+parameterId+".png");
	        file.delete();
			ChartUtilities.saveChartAsPNG(file, chart, 640, 480);
	        return file.getName();
        }
		catch(Exception e){
			try {
				if(ps!=null){
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

}
