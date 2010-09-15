package be.mxs.common.util.db;

import net.admin.User;

import java.util.*;
import java.sql.Connection;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 2-sep-2004
 * Time: 19:26:23
 * To change this template use Options | File Templates.
 */
public class UserConnections {
    private Hashtable connections;

    public UserConnections(){
        connections = new Hashtable();
    }

    private void check(){
        try{
            Enumeration enumeration = connections.elements();
            UserConnection userConnection;
            while(enumeration.hasMoreElements()){
                userConnection = (UserConnection)enumeration.nextElement();
                if ((userConnection.connection==null || userConnection.connection.isClosed()) && new java.util.Date().getTime()-userConnection.lastAccess.getTime()>1200000){
                    connections.remove(userConnection.connection);
                }
            }
        }
        catch (Exception e){e.printStackTrace();}
    }

    public void addConnection(User user,String database, Connection connection){
        String username="system";
        if (user != null){
            username=user.person.firstname+" "+user.person.lastname;
        }
        connections.put(connection,new UserConnection(username,database,connection));
        check();
    }

    public void addConnection(User user,String database, Connection connection,String ip){
        String username="system";
        if (user != null){
            username=user.person.firstname+" "+user.person.lastname+" ("+ip+")";
        }
        connections.put(connection,new UserConnection(username,database,connection));
        check();
    }

    public Hashtable getConnections(){
        check();
        return connections;
    }
}
