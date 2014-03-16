package be.openclinic.statistics;

import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * User: Frank Verbeke
 * Date: 6-sep-2007
 * Time: 8:10:44
 */
public class CsvStats {
    private String begin;
    private String end;
    private String query;
    private Connection connection = null;
    private ResultSet resultSet=null;


    public CsvStats(String begin, String end, Connection connection, String query) {
        this.begin = begin;
        this.end = end;
        this.query = query;
        this.connection=connection;
    }

    public StringBuffer execute(){
        StringBuffer result=new StringBuffer();
        try {
            query=query.replaceAll("<begin>",begin).replaceAll("<end>",end);
            PreparedStatement ps = connection.prepareStatement(query);
            resultSet=ps.executeQuery();
            boolean bHeader=false;
            while(resultSet.next()){
                if(!bHeader){
                    bHeader=true;
                    for(int n=0;n<resultSet.getMetaData().getColumnCount();n++){
                        if(n>0){
                            result.append(";");
                        }
                        result.append(resultSet.getMetaData().getColumnLabel(n+1));
                    }
                    result.append("\r\n");
                }
                for(int n=0;n<resultSet.getMetaData().getColumnCount();n++){
                    if(n>0){
                        result.append(";");
                    }
                    try{
                    	result.append((resultSet.getObject(n+1)+"").replaceAll(";", ","));
                    }
                    catch(Exception q){
                    }
                }
                result.append("\r\n");
            }
            resultSet.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  
        }
        return result;
    }
}
