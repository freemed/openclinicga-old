package be.mxs.common.model.vo.healthrecord;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;



/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 23-feb-2005
 * Time: 17:47:15
 * To change this template use Options | File Templates.
 */
public class ICPCCode {
    public String code;
    public String label;

    public ICPCCode (String code,String label){
        this.code=code;
        this.label=label;
    }

    public ICPCCode(String code,String label,String table){
        this.code=code;
        this.label="";
        while(this.label.length()==0 && code.length()>0){
            try{
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            	PreparedStatement ps = oc_conn.prepareStatement("select * from "+table+" where code like '"+code+"%'");
                ResultSet rs = ps.executeQuery();
                if(rs.next()){
                    this.label=rs.getString(label);
                    this.code=rs.getString("code");
                }
                rs.close();
                ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
            code=code.substring(0,code.length()-1);
        }
    }
}
