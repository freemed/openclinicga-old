package be.mxs.common.util.db;

import java.sql.Connection;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 2-sep-2004
 * Time: 19:46:22
 * To change this template use Options | File Templates.
 */
public class UserConnection{
    public String username;
    public String database;
    public Connection connection;
    public java.util.Date lastAccess;

    public UserConnection(String username, String database, Connection connection){
        this.username=username;
        this.database=database;
        this.connection=connection;
        this.lastAccess=new java.util.Date();
    }
}

