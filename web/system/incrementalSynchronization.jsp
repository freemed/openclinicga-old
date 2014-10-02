<%@page import="org.dom4j.Document,
                org.dom4j.io.SAXReader,
                java.net.URL,
                be.mxs.common.util.db.MedwanQuery,
                org.dom4j.Element,
                java.text.SimpleDateFormat,
                java.util.HashMap,
                java.util.Vector,
                be.mxs.common.util.system.Debug"%>
<%@ page import="java.sql.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%!
    Document document = null;
    String sDoc = "";
    boolean bSuccess = true;
    String sErrors = "";

    private void comment(JspWriter out, String msg, int ok) {
        if (Debug.enabled) Debug.println(msg);
        try {
            status(out, msg.replaceAll("<b>", "").replaceAll("</b>", ""));
            if (ok == 2) {
                bSuccess = false;
                sErrors += msg + "<br/>";
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Object getValueForName(String name, HashMap elements) {
        Iterator keys = elements.keySet().iterator();
        while (keys.hasNext()) {
            Element key = (Element) keys.next();
            if (key.attribute("name").getValue().equals(name)) {
                return elements.get(key);
            }
        }
        return null;
    }

    private void executeProcedure(String procedure, HashMap cols, Connection source, Connection destination, JspWriter out) {
        if (procedure.equalsIgnoreCase("riskprofile")) {
            boolean bMoveProfile = false;
            boolean bArchiveProfile = false;
            int profileId = -1;
            if (Debug.enabled) Debug.println("1");
            int personid = ((Integer) getValueForName("personId", cols)).intValue();
            Timestamp dateBegin = (Timestamp) getValueForName("dateBegin", cols);

            try {
                //Look for the active riskprofile for this patient on the destinationserver
                if (Debug.enabled) Debug.println("2");
                PreparedStatement ps = destination.prepareStatement("select * from RiskProfiles where dateEnd is null and personId=?");
                ps.setInt(1, personid);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    //There is an active profile. Verify the beginDate
                    if (dateBegin.after(rs.getTimestamp("dateBegin"))) {
                        profileId = rs.getInt("profileId");
                        bMoveProfile = true;
                        bArchiveProfile = true;
                    } else {
                        //This is an older profile, buzz off
                    }
                } else {
                    //There is no active profile for this patient, create one
                    bMoveProfile = true;
                }
                rs.close();
                ps.close();
                if (Debug.enabled) Debug.println("3");
                if (bArchiveProfile) {
                    ps = destination.prepareStatement("update RiskProfiles set dateEnd=? where personId=?");
                    ps.setTimestamp(1, dateBegin);
                    ps.setInt(2, personid);
                    ps.execute();
                    if (ps != null) ps.close();
                }
                if (Debug.enabled) Debug.println("4");
                if (bMoveProfile) {
                    //First verify if this person exists
                    ps = destination.prepareStatement("select * from AdminView where personid=?");
                    ps.setInt(1, personid);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        profileId = MedwanQuery.getInstance().getOpenclinicCounter("RiskProfileID");
                        rs.close();
                        ps.close();
                        ps = destination.prepareStatement("insert into RiskProfiles(profileId,dateBegin,dateEnd,personId,updatetime) values(?,?,null,?,?)");
                        ps.setInt(1, profileId);
                        ps.setTimestamp(2, dateBegin);
                        ps.setInt(3, personid);
                        ps.setTimestamp(4, (Timestamp) getValueForName("updatetime", cols));
                        ps.execute();
                        if (ps != null) ps.close();
                        if (Debug.enabled) Debug.println("5");
                        //Now copy also all RiskProfileContexts and RiskProfileExaminations
                        ps = source.prepareStatement("select * from RiskProfileContexts where profileId=?");
                        ps.setInt(1, ((Integer) getValueForName("profileId", cols)).intValue());
                        rs = ps.executeQuery();
                        PreparedStatement psSync;

                        while (rs.next()) {
                            psSync = destination.prepareStatement("insert into RiskProfileContexts(profileContextId,itemType,itemId,profileId) values(?,?,?,?)");
                            psSync.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("RiskProfileContextID"));
                            psSync.setString(2, rs.getString("itemType"));
                            psSync.setInt(3, rs.getInt("itemId"));
                            psSync.setInt(4, profileId);
                            psSync.execute();
                            psSync.close();
                        }
                        rs.close();
                        ps.close();
                        if (Debug.enabled) Debug.println("6");
                        ps = source.prepareStatement("select * from RiskProfileItems where profileId=?");
                        ps.setInt(1, ((Integer) getValueForName("profileId", cols)).intValue());
                        rs = ps.executeQuery();

                        while (rs.next()) {
                            psSync = destination.prepareStatement("insert into RiskProfileItems(profileItemId,itemType,itemId,status,comment,profileId,frequency,tolerance,ageGenderControl) values(?,?,?,?,?,?,?,?,?)");
                            psSync.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("RiskProfileItemID"));
                            psSync.setString(2, rs.getString("itemType"));
                            psSync.setInt(3, rs.getInt("itemId"));
                            psSync.setInt(4, rs.getInt("status"));
                            psSync.setString(5, rs.getString("comment"));
                            psSync.setInt(6, profileId);
                            psSync.setInt(7, rs.getInt("frequency"));
                            psSync.setInt(8, rs.getInt("tolerance"));
                            psSync.setString(9, rs.getString("ageGenderControl"));
                            psSync.execute();
                            psSync.close();
                        }
                    }
                    rs.close();
                    ps.close();
                }
            }
            catch (Exception e) {
                comment(out, e.getMessage(), 2);
            }
        }

        if (procedure.equalsIgnoreCase("transaction")) {
            boolean bMoveTransaction = false;
            boolean bArchiveTransaction = false;
            int transactionId = -1;
            int serverid = -1;
            int version = -1;
            int versionserverid = -1;
            Timestamp ts = null;
            transactionId = ((Integer) getValueForName("transactionId", cols)).intValue();
            serverid = ((Integer) getValueForName("serverid", cols)).intValue();
            version = ((Integer) getValueForName("version", cols)).intValue();
            versionserverid = ((Integer) getValueForName("versionserverid", cols)).intValue();
            ts = ((Timestamp) getValueForName("ts", cols));
            try {
                //Transfer the transaction from source to destination
                String sOwnServerId = getConfigStringDB("serverId", destination);
                if (versionserverid == Integer.parseInt(sOwnServerId)) {
                    //Transaction comes from destination, so buzz off
                    if (Debug.enabled) Debug.println("Received own transaction, do nothing");
                } else {
                    if (Debug.enabled)
                        Debug.println("Synchronize Transaction with transactionId=" + transactionId + " and serverid=" + serverid);
                    PreparedStatement ps = destination.prepareStatement("select * from Transactions where transactionId=? and serverid=?");
                    ps.setInt(1, transactionId);
                    ps.setInt(2, serverid);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        //This transaction already exists on the destination server, check origin and version
                        if (versionserverid == rs.getInt("versionserverid") && version > rs.getInt("version")) {
                            bMoveTransaction = true;
                            bArchiveTransaction = true;
                        } else if (versionserverid != rs.getInt("versionserverid") && ts.after(rs.getTimestamp("ts"))) {
                            bMoveTransaction = true;
                            bArchiveTransaction = true;
                        }
                    } else {
                        //This transaction does not exist on the destiation server, just copy it
                        bMoveTransaction = true;
                    }
                    rs.close();
                    ps.close();

                    String sourceValueColumn = getConfigStringDB("valueColumn", source);
                    String sourceDateColumn = getConfigStringDB("dateColumn", source);
                    String destinationValueColumn = getConfigStringDB("valueColumn", destination);
                    String destinationDateColumn = getConfigStringDB("dateColumn", destination);
                    String destinationTimeStamp = getConfigStringDB("timeStamp", destination);

                    if (bArchiveTransaction) {
                        ps = destination.prepareStatement("insert into TransactionsHistory(transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,versionserverid,version) select transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,versionserverid,version from Transactions where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
                        if (ps != null) ps.close();

                        ps = destination.prepareStatement("insert into ItemsHistory(itemId,type," + destinationValueColumn + "," + destinationDateColumn + ",transactionId,serverid,versionserverid,version) select itemId,type," + destinationValueColumn + "," + destinationDateColumn + ",transactionId,serverid,versionserverid,version from Items where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
                        if (ps != null) ps.close();

                        ps = destination.prepareStatement("delete from Transactions where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
                        if (ps != null) ps.close();

                        ps = destination.prepareStatement("delete from Items where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
                        ps.close();
                    }
                    if (bMoveTransaction) {
                        //First move the tansaction
                        //Lets map the correct HealthRecord first
                        int healthrecordid = 0;
                        if (((Integer) getValueForName("healthRecordId", cols)).intValue() != 0) {
                            ps = source.prepareStatement("select personId from Healthrecord where healthRecordId=?");
                            ps.setInt(1, ((Integer) getValueForName("healthRecordId", cols)).intValue());
                            rs = ps.executeQuery();
                            if (rs.next()) {
                                int personid = rs.getInt("personId");
                                rs.close();
                                ps.close();
                                ps = destination.prepareStatement("select * from Healthrecord where personId=?");
                                ps.setInt(1, personid);
                                rs = ps.executeQuery();
                                if (rs.next()) {
                                    healthrecordid = rs.getInt("healthRecordId");
                                    rs.close();
                                    ps.close();
                                } else {
                                    //The healthrecord does not exist on the destinationserver yet, create it
                                    healthrecordid = MedwanQuery.getInstance().getOpenclinicCounter("HealthRecordID");
                                    rs.close();
                                    ps.close();
                                    ps = destination.prepareStatement("insert into Healthrecord(healthRecordId,dateBegin,dateEnd,personId,serverid,version,versionserverid) values(?,?,null,?,?,1,?)");
                                    ps.setInt(1, healthrecordid);
                                    ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime()));
                                    ps.setInt(3, personid);
                                    ps.setInt(4, Integer.parseInt(sOwnServerId));
                                    ps.setInt(5, Integer.parseInt(sOwnServerId));
                                    ps.execute();
                                    if (ps != null) ps.close();
                                }
                            } else {
                                healthrecordid = -1;
                                rs.close();
                                ps.close();
                            }
                        }
                        ps = destination.prepareStatement("insert into Transactions(transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,version,versionserverid,ts) values(?,?,?,?,?,?,?,?,?,?," + destinationTimeStamp + ")");
                        ps.setInt(1, transactionId);
                        ps.setTimestamp(2, (Timestamp) getValueForName("creationDate", cols));
                        ps.setString(3, (String) getValueForName("transactionType", cols));
                        ps.setTimestamp(4, (Timestamp) getValueForName("updateTime", cols));
                        ps.setInt(5, ((Integer) getValueForName("status", cols)).intValue());
                        ps.setInt(6, healthrecordid);
                        ps.setInt(7, ((Integer) getValueForName("userId", cols)).intValue());
                        ps.setInt(8, serverid);
                        ps.setInt(9, version);
                        ps.setInt(10, versionserverid);
                        ps.execute();
                        if (ps != null) ps.close();

                        //Then move all Items that are linked to the Transaction
                        PreparedStatement psSource = source.prepareStatement("select * from Items where serverid=? and transactionId=? and version=? and versionserverid=?");
                        psSource.setInt(1, serverid);
                        psSource.setInt(2, transactionId);
                        psSource.setInt(3, version);
                        psSource.setInt(4, versionserverid);
                        rs = psSource.executeQuery();
                        while (rs.next()) {
                            ps = destination.prepareStatement("insert into Items(itemId,type," + destinationValueColumn + "," + destinationDateColumn + ",transactionId,serverid,version,versionserverid) values(?,?,?,?,?,?,?,?)");
                            ps.setInt(1, rs.getInt("itemId"));
                            ps.setString(2, rs.getString("type"));
                            ps.setString(3, rs.getString(sourceValueColumn));
                            ps.setTimestamp(4, rs.getTimestamp(sourceDateColumn));
                            ps.setInt(5, transactionId);
                            ps.setInt(6, serverid);
                            ps.setInt(7, version);
                            ps.setInt(8, versionserverid);
                            ps.execute();
                            if (ps != null) ps.close();
                        }
                        rs.close();
                        if (ps != null) ps.close();
                        psSource.close();
                    }
                }
            }
            catch (Exception e) {
                comment(out, e.getMessage(), 2);
            }
        }
    }
%>

<%
    bSuccess = true;
    sErrors = "";
    Connection OccupdbConnection = MedwanQuery.getInstance().getLongOpenclinicConnection();
    Connection dbConnection = MedwanQuery.getInstance().getLongAdminConnection();

    //Set default values
    String ipadmin = "127.0.0.1:1433/admin";
    String ipoccup = "127.0.0.1:1433/admin";
    String username = "sa";
    String password = "";
    String driver = "Sybase";
    String admindb = "admin";
    String sLocalDbType = "?";
    String sLocalDbVersion = "?";

    //Get database values
    String syncIpAdmin = MedwanQuery.getInstance().getConfigString("syncIpAdmin");
    String syncIpOccup = MedwanQuery.getInstance().getConfigString("syncIpOccup");
    String syncUserName = MedwanQuery.getInstance().getConfigString("syncUserName");
    String syncPassword = MedwanQuery.getInstance().getConfigString("syncPassword");
    String syncDriver = MedwanQuery.getInstance().getConfigString("syncDriver");
    String syncAdminDb = MedwanQuery.getInstance().getConfigString("admindbName");

    if (syncIpAdmin.length()>0 && !syncIpAdmin.equals("")){
        ipadmin=syncIpAdmin;
    }
    if (syncIpOccup.length()>0 && !syncIpOccup.equals("")){
        ipoccup=syncIpOccup;
    }
    if (syncUserName.length()>0 && !syncUserName.equals("")){
        username=syncUserName;
    }
    if (syncPassword.length()>0 && !syncPassword.equals("")){
        password=syncPassword;
    }
    if (syncDriver.length()>0 && !syncDriver.equals("")){
        driver=syncDriver;
    }
    if (syncAdminDb.length()>0 && !syncAdminDb.equals("")){
        admindb=syncAdminDb;
    }

    //Find out local database type & version
    try {
        sLocalDbType = dbConnection.getMetaData().getDatabaseProductName();
        sLocalDbVersion = dbConnection.getMetaData().getDatabaseProductVersion();
    }
    catch(Exception e){
        //e.printStackTrace();
    }

    Debug.println("reloading model");
    SAXReader reader = new SAXReader(false);
    sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"openwork.xml";
    document = reader.read(new URL(sDoc));
%>
<form name="merge" method="post">
    <input id="7" class="checkBox" type="hidden" name="synchronize" value="synchronize"/>
    <%=writeTableHeader("Web.manage","Synchronization",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="submit" name="submit" value="<%=getTranNoLink("Web.Occup","medwan.common.execute",sWebLanguage)%>"/>
        <input class="button" type="button" name="cancel" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' OnClick='javascript:window.location.href="main.do?Page=system/menu.jsp"'>
    <%=ScreenHelper.alignButtonsStop()%>
    <br>
<%
    comment(out, "Sync tables:", 1);
    Iterator tables = document.getRootElement().elementIterator("table");
    Element table;

    while (tables.hasNext()) {
        table = (Element) tables.next();
        if (table.attribute("sync") != null && !table.attribute("sync").getValue().equalsIgnoreCase("NONE")) {
            out.print("<input type='hidden' name='" + table.attribute("name").getValue() + "' value='medwan.common.true'/>");
        }
    }

    if (request.getParameter("submit") != null) {
        try {
            //Debug.println("1");
            String sOwnServerId = MedwanQuery.getInstance().getConfigString("serverId");
            Element versionColumn = null;
            Connection connectionCheck = null;
            PreparedStatement psCheck = null;
            ResultSet rsCheck = null;
            Connection otherAdminConnection = null;
            Connection otherOccupConnection = null;

            if (request.getParameter("synchronize") != null) {
                if (driver.equals("Sybase")) {
                    Class.forName("com.sybase.jdbc2.jdbc.SybDriver");
                    otherAdminConnection = java.sql.DriverManager.getConnection("jdbc:sybase:Tds:" + ipadmin, username, password);
                    otherOccupConnection = DriverManager.getConnection("jdbc:sybase:Tds:" + ipoccup, username, password);
                }

                if (driver.equals("MSSQLServer")) {
                    Class.forName("net.sourceforge.jtds.jdbc.Driver");
                    otherAdminConnection = DriverManager.getConnection("jdbc:jtds:sqlserver://" + ipadmin, username, password);
                    otherOccupConnection = DriverManager.getConnection("jdbc:jtds:sqlserver://" + ipoccup, username, password);
                }
            }

            Element model = document.getRootElement();
            comment(out, "Parsing model <b>" + model.attribute("name").getValue() + "</b> version <b>" + model.attribute("version").getValue() + "</b> dd <b>" + model.attribute("date").getValue() + "</b>", 1);
            comment(out, "Parsing tables...", 1);
            tables = model.elementIterator("table");

            DatabaseMetaData databaseMetaData;
            Element column, index, indexcolumn;
            String sql, indexname, sMessage, values, outSql, sQuery, otherServerId, inSql, sVal, versioncompare;
            Iterator columns, indexes, indexcolumns;
            boolean inited, indexFound, bDoWork, bInited;
            Statement stDelete, stCount;
            Connection source, destination;
            PreparedStatement psSync, psSync2;
            ResultSet rsSync, rsCount, rsSync2;
            Object maxVersion;
            HashMap primaryKey, cols;
            int counter, total, rowCounter, compareStatus;
            Integer nVal;
            Vector params;
            Timestamp dVal;

            while (tables.hasNext()) {
                table = (Element) tables.next();
                comment(out, "Parsing table <b>" + table.attribute("name").getValue() + "</b> in database " + table.attribute("db").getValue(), 1);

                //Checking existence of table
                //First select right connection
                if (table.attribute("db").getValue().equalsIgnoreCase("admin")) {
                    connectionCheck = dbConnection;
                } else if (table.attribute("db").getValue().equalsIgnoreCase("occup")) {
                    connectionCheck = OccupdbConnection;
                }

                //Now verify existence of table
                databaseMetaData = connectionCheck.getMetaData();
                rsCheck = databaseMetaData.getTables(null, null, table.attribute("name").getValue(), null);
                if (rsCheck.next()) {
                    //verify the table columns
                    versionColumn = null;
                    columns = table.element("columns").elementIterator("column");
                    while (columns.hasNext()) {
                        try {
                            column = (Element) columns.next();
                            if (column.attribute("version") != null && column.attribute("version").getValue().equalsIgnoreCase("1")) {
                                versionColumn = column;
                            }

                            if (request.getParameter("verify") != null) {
                                rsCheck = databaseMetaData.getColumns(null, null, table.attribute("name").getValue(), column.attribute("name").getValue());
                                if (!rsCheck.next()) {
                                    comment(out, "&nbsp;Column <b>" + column.attribute("name").getValue() + "</b> does not exist", 0);
                                    if (request.getParameter("create") != null) {
                                        comment(out, "&nbsp;Creating Column", 0);
                                        if (column.attribute("nulls") != null && column.attribute("nulls").getValue().equalsIgnoreCase("0")) {
                                            comment(out, "&nbsp;WARNING, column is not nullable but will be added as nullable!", 0);
                                        }
                                        sql = "alter table " + table.attribute("name").getValue() + " add " + column.attribute("name").getValue() + " ";
                                        if (column.attribute("dbtype").getValue().equalsIgnoreCase("char") || column.attribute("dbtype").getValue().equalsIgnoreCase("varchar")) {
                                            sql += column.attribute("dbtype").getValue() + "(" + column.attribute("size").getValue() + ")";
                                        } else {
                                            sql += column.attribute("dbtype").getValue();
                                        }
                                        sql += " null";
                                        psCheck = connectionCheck.prepareStatement(sql);
                                        psCheck.execute();
                                        psCheck.close();
                                    }
                                }
                            }
                        }
                        catch (Exception e) {
                            comment(out, e.getMessage(), 2);
                        }
                    }
                } else {
                    comment(out, "&nbsp;Table does not exist", 0);
                    if (request.getParameter("create") != null) {
                        comment(out, "&nbsp;Creating table", 0);
                        //create the table
                        sql = "create table " + table.attribute("name").getValue() + "(";
                        columns = table.element("columns").elementIterator("column");
                        inited = false;
                        while (columns.hasNext()) {
                            column = (Element) columns.next();
                            if (inited) {
                                sql += ",";
                            } else {
                                inited = true;
                            }

                            sql += column.attribute("name").getValue() + " ";
                            if (column.attribute("dbtype").getValue().equalsIgnoreCase("char") || column.attribute("dbtype").getValue().equalsIgnoreCase("varchar")) {
                                sql += column.attribute("dbtype").getValue() + "(" + column.attribute("size").getValue() + ")";
                            } else {
                                sql += column.attribute("dbtype").getValue();
                            }

                            if (column.attribute("nulls") != null && column.attribute("nulls").getValue().equalsIgnoreCase("0")) {
                                sql += " not null";
                            } else {
                                sql += " null";
                            }
                        }
                        try {
                            sql += ")";
                            psCheck = connectionCheck.prepareStatement(sql);
                            psCheck.execute();
                            psCheck.close();
                        }
                        catch (Exception e) {
                            comment(out, e.getMessage(), 2);
                        }
                    }
                }
                //Now verify the indexes of the table
                if (request.getParameter("verify") != null) {
                    if (table.element("indexes") != null) {
                        indexes = table.element("indexes").elementIterator("index");
                        while (indexes.hasNext()) {
                            try {
                                index = (Element) indexes.next();
                                rsCheck = databaseMetaData.getIndexInfo(null, null, table.attribute("name").getValue(), (index.attribute("unique") != null && index.attribute("unique").getValue().equalsIgnoreCase("1")), false);
                                indexFound = false;
                                while (rsCheck.next()) {
                                    indexname = rsCheck.getString("INDEX_NAME");
                                    if (indexname != null && indexname.equalsIgnoreCase(index.attribute("name").getValue())) {
                                        indexFound = true;
                                    }
                                }

                                if (!indexFound) {
                                    comment(out, " Index <b>" + index.attribute("name").getValue() + "</b> does not exist", 0);
                                    if (request.getParameter("create") != null) {
                                        comment(out, "&nbsp;Creating index", 0);
                                        sql = "create ";
                                        if (index.attribute("unique") != null && index.attribute("unique").getValue().equalsIgnoreCase("1")) {
                                            sql += " unique ";
                                        }
                                        sql += "index " + index.attribute("name").getValue() + " on " + table.attribute("name").getValue() + "(";
                                        indexcolumns = index.elementIterator("indexcolumn");
                                        inited = false;

                                        while (indexcolumns.hasNext()) {
                                            indexcolumn = (Element) indexcolumns.next();
                                            if (inited) {
                                                sql += ",";
                                            } else {
                                                inited = true;
                                            }
                                            sql += indexcolumn.attribute("name").getValue() + " " + indexcolumn.attribute("order").getValue();
                                        }
                                        sql += ")";
                                        psCheck = connectionCheck.prepareStatement(sql);
                                        psCheck.execute();
                                        psCheck.close();
                                    }
                                }
                            }
                            catch (Exception e) {
                                comment(out, e.getMessage(), 2);
                            }
                        }
                    }
                }

                //Now check if this table has to be synchronized
                //First of all the synchronize checkbox has to be checked and we need a version-column
                if (request.getParameter("synchronize") != null && (versionColumn != null || !table.attribute("sync").getValue().equalsIgnoreCase("merge")) && request.getParameter(table.attribute("name").getValue()) != null) {
                    comment(out, " Synchronizing <b>" + table.attribute("name").getValue() + "</b> ...", 0);
                    try {
                        //First check if the master, masterexist or merge synchronization has been flagged
                        if (table.attribute("sync").getValue().equalsIgnoreCase("master") || table.attribute("sync").getValue().equalsIgnoreCase("masterexist") || table.attribute("sync").getValue().equalsIgnoreCase("merge")) {
                            source = null;
                            destination = null;
                            if (MedwanQuery.getInstance().getConfigString("masterEnabled").equals("1")) {
                                //This machine is the master
                                if (table.attribute("db").getValue().equalsIgnoreCase("admin")) {
                                    source = dbConnection;
                                    destination = otherAdminConnection;
                                }

                                if (table.attribute("db").getValue().equalsIgnoreCase("occup")) {
                                    source = OccupdbConnection;
                                    destination = otherOccupConnection;
                                }
                            } else {
                                //The other machine is the master
                                if (table.attribute("db").getValue().equalsIgnoreCase("admin")) {
                                    source = otherAdminConnection;
                                    destination = dbConnection;
                                }

                                if (table.attribute("db").getValue().equalsIgnoreCase("occup")) {
                                    source = otherOccupConnection;
                                    destination = OccupdbConnection;
                                }
                            }

                            //MASTER, MASTEREXIST, MERGE
                            //In any case the source -> destination synchro has to be done
                            //First determine the last checked version
                            psSync = null;
                            rsSync = null;
                            sQuery = null;
                            otherServerId = MedwanQuery.getInstance().getConfigString("serverId");
                            inSql = "";
                            if (table.attribute("insql") != null) {
                                inSql = "and " + table.attribute("insql").getValue().replaceAll("@sourceserverid@", getConfigStringDB("serverId", source)) + " ";
                            }
                            versioncompare = ">";
                            if (versionColumn != null && versionColumn.attribute("versioncompare") != null) {
                                versioncompare = versionColumn.attribute("versioncompare").getValue();
                            }
                            maxVersion = null;
                            primaryKey = new HashMap();
                            counter = 0;
                            if (!"medwan.common.true".equalsIgnoreCase(request.getParameter(table.attribute("name").getValue() + ".fullreset"))
                                    && MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) != null
                                    && !MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()).equalsIgnoreCase("")) {
                                //Do select from source table where version later than last checked version
                                if (versionColumn == null) {
                                    sQuery = "select * from " + table.attribute("name").getValue();
                                    psSync = source.prepareStatement(sQuery);
                                } else {
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + inSql + "order by " + versionColumn.attribute("name").getValue();
                                    psSync = source.prepareStatement(sQuery);
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        psSync.setInt(1, Integer.parseInt(MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())));
                                    }

                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        psSync.setString(1, MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()));
                                    }

                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        Timestamp ts = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())).getTime());
                                        psSync.setTimestamp(1, ts);
                                    }
                                }
                            } else {
                                if ("medwan.common.true".equalsIgnoreCase(request.getParameter(table.attribute("name").getValue() + ".fullreset"))) {
                                    //Clear table(s) on destination server
                                    stDelete = destination.createStatement();
                                    stDelete.execute("delete from " + table.attribute("name").getValue());
                                    if (table.attribute("proc") != null && !table.attribute("proc").getValue().equalsIgnoreCase("")) {
                                        if (table.attribute("proc").getValue().equalsIgnoreCase("riskprofile")) {
                                            stDelete.execute("delete from riskProfileContexts");
                                            stDelete.execute("delete from riskProfileItems");
                                        }

                                        if (table.attribute("proc").getValue().equalsIgnoreCase("transaction")) {
                                            stDelete.execute("delete from TransactionsHistory");
                                            stDelete.execute("delete from Items");
                                            stDelete.execute("delete from ItemsHistory");
                                        }
                                    }
                                    stDelete.close();
                                }

                                //First time select. Select all rows from source database
                                if (versionColumn == null) {
                                    sQuery = "select * from " + table.attribute("name").getValue();
                                    psSync = source.prepareStatement(sQuery);
                                } else {
                                    stCount = destination.createStatement();
                                    rsCount = stCount.executeQuery("select max(" + versionColumn.attribute("name").getValue() + ") as maxVal from " + table.attribute("name").getValue());
                                    if (rsCount.next() && rsCount.getObject("maxVal") != null) {
                                        if (Debug.enabled)
                                            Debug.println("maxVal=" + rsCount.getObject("maxVal").toString());
                                        sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + inSql + "order by " + versionColumn.attribute("name").getValue();
                                        psSync = source.prepareStatement(sQuery);
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                            psSync.setInt(1, rsCount.getInt("maxVal"));
                                        }

                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                            psSync.setString(1, rsCount.getString("maxVal"));
                                        }

                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                            psSync.setTimestamp(1, rsCount.getTimestamp("maxVal"));
                                        }
                                    } else {
                                        sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + " is not null " + inSql + "order by " + versionColumn.attribute("name").getValue();
                                        psSync = source.prepareStatement(sQuery);
                                    }

                                    if (Debug.enabled) Debug.println(sQuery);
                                    rsCount.close();
                                    stCount.close();
                                }
                            }

                            //If we don't have a merge sync and both tables contain the same number of elements, do nothing
                            bDoWork = true;
                            if (versionColumn == null) {
                                stCount = source.createStatement();
                                rsCount = stCount.executeQuery("select count(*) total from " + table.attribute("name").getValue());
                                if (rsCount.next()) {
                                    total = rsCount.getInt("total");
                                    rsCount.close();
                                    stCount.close();
                                    stCount = destination.createStatement();
                                    rsCount = stCount.executeQuery("select count(*) total from " + table.attribute("name").getValue());
                                    if (rsCount.next()) {
                                        if (total == rsCount.getInt("total")) {
                                            bDoWork = false;
                                        }
                                    }
                                }
                                else {
                                    rsCount.close();
                                    stCount.close();
                                }
                            }

                            if (bDoWork) {
                                if (Debug.enabled)
                                    Debug.println("MASTER -> SLAVE (?=" + MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) + "):" + sQuery);
                                rsSync = psSync.executeQuery();
                                rowCounter = 0;
                                while (rsSync.next()) {
                                    if (rowCounter % 100 == 0 || (counter > 0 && counter % 100 == 0)) {
                                        status(out, " Synchronizing slave to master: " + table.attribute("name").getValue() + " " + rowCounter + " rows verified, " + counter + " rows copied...");
                                    }
                                    rowCounter++;
                                    params = new Vector();
                                    if (versionColumn != null && !table.attribute("sync").getValue().equalsIgnoreCase("masterexist")) {
                                        //Store version of this row as maxVersion
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                            maxVersion = new Integer(rsSync.getInt(versionColumn.attribute("name").getValue()));
                                        }

                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                            maxVersion = rsSync.getString(versionColumn.attribute("name").getValue());
                                        }

                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                            maxVersion = rsSync.getTimestamp(versionColumn.attribute("name").getValue());
                                        }
                                    }

                                    //Check every sourcerow against the destinationrow
                                    sMessage = "searching table " + table.attribute("name").getValue() + " for ";
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where 1=1";
                                    columns = table.element("columns").elementIterator("column");
                                    while (columns.hasNext()) {
                                        column = (Element) columns.next();
                                        if (column.attribute("primary") != null && column.attribute("primary").getValue().equalsIgnoreCase("1")) {
                                            sMessage += column.attribute("name").getValue() + "=";
                                            if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                nVal = new Integer(rsSync.getInt(column.attribute("name").getValue()));
                                                if (nVal != null) {
                                                    params.add(nVal);
                                                    primaryKey.put(column, nVal);
                                                    sQuery += " and " + column.attribute("name").getValue() + "=?";
                                                    sMessage += nVal + " ";
                                                }
                                            }

                                            if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                sVal = rsSync.getString(column.attribute("name").getValue());
                                                if (sVal != null) {
                                                    params.add(sVal);
                                                    primaryKey.put(column, sVal);
                                                    sQuery += " and " + column.attribute("name").getValue() + "=?";
                                                    sMessage += sVal + " ";
                                                }
                                            }

                                            if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                dVal = rsSync.getTimestamp(column.attribute("name").getValue());
                                                if (dVal != null) {
                                                    params.add(dVal);
                                                    primaryKey.put(column, rsSync.getTimestamp(column.attribute("name").getValue()));
                                                    sQuery += " and " + column.attribute("name").getValue() + "=?";
                                                    sMessage += new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(dVal) + " ";
                                                }
                                            }
                                        }
                                    }

                                    psSync2 = destination.prepareStatement(sQuery);
                                    for (int n = 0; n < params.size(); n++) {
                                        if (params.get(n) == null) {
                                            psSync2.setObject(n + 1, null);
                                        } else if (Integer.class.isInstance(params.get(n))) {
                                            psSync2.setInt(n + 1, ((Integer) params.get(n)).intValue());
                                        } else if (String.class.isInstance(params.get(n))) {
                                            psSync2.setString(n + 1, ((String) params.get(n)));
                                        } else if (Timestamp.class.isInstance(params.get(n))) {
                                            psSync2.setTimestamp(n + 1, ((Timestamp) params.get(n)));
                                        }
                                    }

                                    //Debug.println(sMessage);
                                    rsSync2 = psSync2.executeQuery();
                                    if (versionColumn != null && !table.attribute("sync").getValue().equalsIgnoreCase("masterexist") && rsSync2.next()) { //We do not want to synchronize objects that exist on both sides for masterexist
                                        //compare versions
                                        compareStatus = 0; //0=equal,1=destination newer,2=source newer
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                            if (rsSync2.getInt(versionColumn.attribute("name").getValue()) > rsSync.getInt(versionColumn.attribute("name").getValue())) {
                                                compareStatus = 1;
                                            } else
                                            if (rsSync2.getInt(versionColumn.attribute("name").getValue()) < rsSync.getInt(versionColumn.attribute("name").getValue())) {
                                                compareStatus = 2;
                                            }
                                        }

                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                            if (rsSync2.getTimestamp(versionColumn.attribute("name").getValue()) != null && rsSync2.getTimestamp(versionColumn.attribute("name").getValue()).after(rsSync.getTimestamp(versionColumn.attribute("name").getValue()))) {
                                                compareStatus = 1;
                                            } else
                                            if (rsSync2.getTimestamp(versionColumn.attribute("name").getValue()) == null || rsSync2.getTimestamp(versionColumn.attribute("name").getValue()).before(rsSync.getTimestamp(versionColumn.attribute("name").getValue()))) {
                                                compareStatus = 2;
                                            }
                                        }

                                        //Debug.println("Comparestatus="+compareStatus);
                                        if (compareStatus == 0) {
                                            if (Debug.enabled) Debug.println("Destination is equal to Source");
                                            //DO NOTHING
                                        } else if (compareStatus == 1) {
                                            if (Debug.enabled) Debug.println("Destination newer than Source");
                                            //DO NOTHING
                                        } else if (compareStatus == 2) {
                                            if (Debug.enabled) Debug.println("Destination older than Source");
                                            counter++;
                                            //If a specific procedure was created, then transfer the columns of the object to that procedure
                                            if (table.attribute("proc") != null && !table.attribute("proc").getValue().equalsIgnoreCase("")) {
                                                columns = table.element("columns").elementIterator("column");
                                                cols = new HashMap();
                                                while (columns.hasNext()) {
                                                    column = (Element) columns.next();
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                        cols.put(column, new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                        cols.put(column, rsSync.getString(column.attribute("name").getValue()));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                        cols.put(column, rsSync.getTimestamp(column.attribute("name").getValue()));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                        cols.put(column, new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                        cols.put(column, rsSync.getBytes(column.attribute("name").getValue()));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                        cols.put(column, new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                    }
                                                }
                                                executeProcedure(table.attribute("proc").getValue(), cols, source, destination, out);
                                            } else {
                                                //Copy source data to destination
                                                sMessage = "update " + table.attribute("name").getValue() + " set ";
                                                sQuery = "update " + table.attribute("name").getValue() + " set ";
                                                bInited = false;
                                                columns = table.element("columns").elementIterator("column");
                                                params = new Vector();
                                                //Debug.println("1");
                                                while (columns.hasNext()) {
                                                    column = (Element) columns.next();
                                                    if (bInited) {
                                                        sQuery += ",";
                                                    } else {
                                                        bInited = true;
                                                    }
                                                    sMessage += column.attribute("name").getValue() + "=";
                                                    sQuery += column.attribute("name").getValue() + "=?";
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                        params.add(new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                        sMessage += rsSync.getInt(column.attribute("name").getValue()) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                        params.add(rsSync.getString(column.attribute("name").getValue()));
                                                        sMessage += rsSync.getString(column.attribute("name").getValue()) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                        params.add(rsSync.getTimestamp(column.attribute("name").getValue()));
                                                        if (rsSync.getTimestamp(column.attribute("name").getValue()) != null) {
                                                            sMessage += new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(rsSync.getTimestamp(column.attribute("name").getValue())) + " ";
                                                        } else {
                                                            sMessage += "null ";
                                                        }
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                        params.add(new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                        sMessage += rsSync.getBoolean(column.attribute("name").getValue()) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                        params.add(rsSync.getBytes(column.attribute("name").getValue()));
                                                        sMessage += "-bytes- ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                        params.add(new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                        sMessage += rsSync.getFloat(column.attribute("name").getValue()) + " ";
                                                    }
                                                }

                                                //Debug.println("2");
                                                sMessage += " where 1=1";
                                                sQuery += " where 1=1";
                                                columns = table.element("columns").elementIterator("column");
                                                while (columns.hasNext()) {
                                                    column = (Element) columns.next();
                                                    if (column.attribute("primary") != null && column.attribute("primary").getValue().equalsIgnoreCase("1")) {
                                                        sMessage += " and " + column.attribute("name").getValue() + "=";
                                                        sQuery += " and " + column.attribute("name").getValue() + "=?";
                                                        if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                            params.add(new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                            sMessage += rsSync.getInt(column.attribute("name").getValue()) + " ";
                                                        }
                                                        if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                            params.add(rsSync.getString(column.attribute("name").getValue()));
                                                            sMessage += rsSync.getString(column.attribute("name").getValue()) + " ";
                                                        }
                                                        if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                            params.add(rsSync.getTimestamp(column.attribute("name").getValue()));
                                                            sMessage += new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(rsSync.getTimestamp(column.attribute("name").getValue())) + " ";
                                                        }
                                                    }
                                                }

                                                //Debug.println(sMessage);
                                                psSync2 = destination.prepareStatement(sQuery);
                                                for (int n = 0; n < params.size(); n++) {
                                                    if (params.get(n) == null) {
                                                        psSync2.setObject(n + 1, null);
                                                    } else {
                                                        if (Integer.class.isInstance(params.get(n))) {
                                                            psSync2.setInt(n + 1, ((Integer) params.get(n)).intValue());
                                                        } else if (String.class.isInstance(params.get(n))) {
                                                            psSync2.setString(n + 1, ((String) params.get(n)));
                                                        } else if (Timestamp.class.isInstance(params.get(n))) {
                                                            psSync2.setTimestamp(n + 1, ((Timestamp) params.get(n)));
                                                        } else if (byte[].class.isInstance(params.get(n))) {
                                                            psSync2.setBytes(n + 1, ((byte[]) params.get(n)));
                                                        } else if (Boolean.class.isInstance(params.get(n))) {
                                                            psSync2.setBoolean(n + 1, ((Boolean) params.get(n)).booleanValue());
                                                        } else if (Float.class.isInstance(params.get(n))) {
                                                            psSync2.setFloat(n + 1, ((Float) params.get(n)).floatValue());
                                                        }
                                                    }
                                                }
                                                psSync2.execute();
                                            }
                                        }
                                    } else if (!rsSync2.next()) {
                                        counter++;
                                        //new record, insert it
                                        if (Debug.enabled) Debug.println("Record does not exist, inserting new record");
                                        if (table.attribute("proc") != null && !table.attribute("proc").getValue().equalsIgnoreCase("")) {
                                            columns = table.element("columns").elementIterator("column");
                                            cols = new HashMap();
                                            while (columns.hasNext()) {
                                                column = (Element) columns.next();
                                                if (Debug.enabled) Debug.println(column.attribute("name").getValue());
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                    cols.put(column, new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                    cols.put(column, rsSync.getString(column.attribute("name").getValue()));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                    cols.put(column, rsSync.getTimestamp(column.attribute("name").getValue()));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                    cols.put(column, new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                    cols.put(column, rsSync.getBytes(column.attribute("name").getValue()));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                    cols.put(column, new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                }
                                            }
                                            executeProcedure(table.attribute("proc").getValue(), cols, source, destination, out);
                                        } else {
                                            values = "";
                                            sQuery = "insert into " + table.attribute("name").getValue() + "(";
                                            bInited = false;
                                            columns = table.element("columns").elementIterator("column");
                                            params = new Vector();
                                            while (columns.hasNext()) {
                                                column = (Element) columns.next();
                                                if (bInited) {
                                                    sQuery += ",";
                                                    values += ",";
                                                } else {
                                                    bInited = true;
                                                }
                                                values += "?";
                                                sQuery += column.attribute("name").getValue();
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                    params.add(new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                    params.add(rsSync.getString(column.attribute("name").getValue()));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                    params.add(rsSync.getTimestamp(column.attribute("name").getValue()));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                    params.add(new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                    params.add(rsSync.getBytes(column.attribute("name").getValue()));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                    params.add(new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                }
                                            }
                                            sQuery += ") values (" + values + ")";
                                            psSync2 = destination.prepareStatement(sQuery);
                                            //Debug.println("1");
                                            for (int n = 0; n < params.size(); n++) {
                                                if (params.get(n) == null) {
                                                    psSync2.setObject(n + 1, null);
                                                } else {
                                                    //Debug.println("2");
                                                    if (Integer.class.isInstance(params.get(n))) {
                                                        psSync2.setInt(n + 1, ((Integer) params.get(n)).intValue());
                                                    } else if (String.class.isInstance(params.get(n))) {
                                                        psSync2.setString(n + 1, ((String) params.get(n)));
                                                    } else if (Timestamp.class.isInstance(params.get(n))) {
                                                        psSync2.setTimestamp(n + 1, ((Timestamp) params.get(n)));
                                                    } else if (byte[].class.isInstance(params.get(n))) {
                                                        psSync2.setBytes(n + 1, ((byte[]) params.get(n)));
                                                    } else if (Boolean.class.isInstance(params.get(n))) {
                                                        psSync2.setBoolean(n + 1, ((Boolean) params.get(n)).booleanValue());
                                                    } else if (Float.class.isInstance(params.get(n))) {
                                                        psSync2.setFloat(n + 1, ((Float) params.get(n)).floatValue());
                                                    }
                                                    //Debug.println("3");
                                                }
                                            }
                                            //Debug.println(sQuery);
                                            psSync2.execute();
                                        }
                                    }
                                }

                                if (maxVersion != null) {
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        setConfigStringDB("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), maxVersion.toString(), OccupdbConnection);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        setConfigStringDB("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), (String) maxVersion, OccupdbConnection);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        setConfigStringDB("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), new SimpleDateFormat("yyyyMMddHHmmssSSS").format((Timestamp) maxVersion), OccupdbConnection);
                                    }
                                }
                            }

                            //In case of a MERGE, we also have to copy from destination -> source
                            if (table.attribute("sync").getValue().equalsIgnoreCase("merge")) {
                                outSql = "";
                                if (table.attribute("outsql") != null) {
                                    outSql = "and " + table.attribute("outsql").getValue().replaceAll("@sourceserverid@", getConfigStringDB("serverId", destination)) + " ";
                                }
                                versioncompare = ">";

                                if (versionColumn.attribute("versioncompare") != null) {
                                    versioncompare = versionColumn.attribute("versioncompare").getValue();
                                }

                                if (MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) != null
                                        && !MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()).equalsIgnoreCase("")) {
                                    //Do select from source table where version later than last checked version
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + outSql + "order by " + versionColumn.attribute("name").getValue();
                                    psSync = destination.prepareStatement(sQuery);
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        psSync.setInt(1, Integer.parseInt(MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        psSync.setString(1, MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        psSync.setTimestamp(1, new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(getConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), OccupdbConnection)).getTime()));
                                    }
                                } else {
                                    //First time select. Select all rows from source database
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + " is not null " + outSql + "order by " + versionColumn.attribute("name").getValue();
                                    psSync = destination.prepareStatement(sQuery);
                                }

                                maxVersion = null;
                                primaryKey = new HashMap();
                                if (Debug.enabled)
                                    Debug.println("SLAVE -> MASTER (?=" + MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) + "):" + sQuery);
                                rsSync = psSync.executeQuery();
                                rowCounter = 0;

                                while (rsSync.next()) {
                                    if (rowCounter % 100 == 0 || (counter > 0 && counter % 100 == 0)) {
                                        status(out, " Synchronizing slave to master: " + table.attribute("name").getValue() + " " + rowCounter + " rows verified, " + counter + " rows copied...");
                                    }
                                    rowCounter++;
                                    params = new Vector();
                                    //Store version of this row as maxVersion
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        maxVersion = new Integer(rsSync.getInt(versionColumn.attribute("name").getValue()));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        maxVersion = rsSync.getString(versionColumn.attribute("name").getValue());
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        maxVersion = rsSync.getTimestamp(versionColumn.attribute("name").getValue());
                                    }

                                    //Check every destinationrow against the sourcerow
                                    sMessage = "searching table " + table.attribute("name").getValue() + " for ";
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where 1=1";
                                    columns = table.element("columns").elementIterator("column");
                                    while (columns.hasNext()) {
                                        column = (Element) columns.next();
                                        if (column.attribute("primary") != null && column.attribute("primary").getValue().equalsIgnoreCase("1")) {
                                            sMessage += column.attribute("name").getValue() + "=";
                                            sQuery += " and " + column.attribute("name").getValue() + "=?";
                                            if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                nVal = new Integer(rsSync.getInt(column.attribute("name").getValue()));
                                                params.add(nVal);
                                                primaryKey.put(column, nVal);
                                                sMessage += nVal + " ";
                                            }

                                            if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                sVal = rsSync.getString(column.attribute("name").getValue());
                                                params.add(sVal);
                                                primaryKey.put(column, sVal);
                                                sMessage += sVal + " ";
                                            }

                                            if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                dVal = rsSync.getTimestamp(column.attribute("name").getValue());
                                                params.add(dVal);
                                                primaryKey.put(column, rsSync.getTimestamp(column.attribute("name").getValue()));
                                                sMessage += new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(dVal) + " ";
                                            }
                                        }
                                    }

                                    psSync2 = source.prepareStatement(sQuery);
                                    for (int n = 0; n < params.size(); n++) {
                                        if (Integer.class.isInstance(params.get(n))) {
                                            psSync2.setInt(n + 1, ((Integer) params.get(n)).intValue());
                                        }
                                        if (String.class.isInstance(params.get(n))) {
                                            psSync2.setString(n + 1, ((String) params.get(n)));
                                        }
                                        if (Timestamp.class.isInstance(params.get(n))) {
                                            psSync2.setTimestamp(n + 1, ((Timestamp) params.get(n)));
                                        }
                                    }

                                    //Debug.println(sMessage);
                                    rsSync2 = psSync2.executeQuery();
                                    if (rsSync2.next()) {
                                        //compare versions
                                        compareStatus = 0; //0=equal,1=source newer,2=destination newer
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                            if (rsSync2.getInt(versionColumn.attribute("name").getValue()) > rsSync.getInt(versionColumn.attribute("name").getValue())) {
                                                compareStatus = 1;
                                            } else
                                            if (rsSync2.getInt(versionColumn.attribute("name").getValue()) < rsSync.getInt(versionColumn.attribute("name").getValue())) {
                                                compareStatus = 2;
                                            }
                                        }

                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                            if (rsSync2.getTimestamp(versionColumn.attribute("name").getValue()) != null && rsSync2.getTimestamp(versionColumn.attribute("name").getValue()).after(rsSync.getTimestamp(versionColumn.attribute("name").getValue()))) {
                                                compareStatus = 1;
                                            } else
                                            if (rsSync2.getTimestamp(versionColumn.attribute("name").getValue()) == null || rsSync2.getTimestamp(versionColumn.attribute("name").getValue()).before(rsSync.getTimestamp(versionColumn.attribute("name").getValue()))) {
                                                compareStatus = 2;
                                            }
                                        }

                                        //Debug.println("Comparestatus="+compareStatus);
                                        if (compareStatus == 0) {
                                            if (Debug.enabled) Debug.println("Source is equal to Destination");
                                            //DO NOTHING
                                        } else if (compareStatus == 1) {
                                            if (Debug.enabled) Debug.println("Source newer than Destination");
                                            //DO NOTHING
                                        } else if (compareStatus == 2) {
                                            if (Debug.enabled) Debug.println("Source older than Destination");
                                            counter++;
                                            //If a specific procedure was created, then transfer the columns of the object to that procedure
                                            if (table.attribute("proc") != null && !table.attribute("proc").getValue().equalsIgnoreCase("")) {
                                                columns = table.element("columns").elementIterator("column");
                                                cols = new HashMap();
                                                while (columns.hasNext()) {
                                                    column = (Element) columns.next();
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                        cols.put(column, new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                        cols.put(column, rsSync.getString(column.attribute("name").getValue()));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                        cols.put(column, rsSync.getTimestamp(column.attribute("name").getValue()));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                        cols.put(column, new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                        cols.put(column, rsSync.getBytes(column.attribute("name").getValue()));
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                        cols.put(column, new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                    }
                                                }
                                                //Debug.println("Sending back");
                                                executeProcedure(table.attribute("proc").getValue(), cols, destination, source, out);
                                            } else {
                                                //Copy source data to source
                                                sMessage = "update " + table.attribute("name").getValue() + " set ";
                                                sQuery = "update " + table.attribute("name").getValue() + " set ";
                                                bInited = false;
                                                columns = table.element("columns").elementIterator("column");
                                                params = new Vector();
                                                while (columns.hasNext()) {
                                                    column = (Element) columns.next();
                                                    if (bInited) {
                                                        sQuery += ",";
                                                    } else {
                                                        bInited = true;
                                                    }
                                                    sMessage += column.attribute("name").getValue() + "=";
                                                    sQuery += column.attribute("name").getValue() + "=?";
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                        params.add(new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                        sMessage += rsSync.getInt(column.attribute("name").getValue()) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                        params.add(rsSync.getString(column.attribute("name").getValue()));
                                                        sMessage += rsSync.getString(column.attribute("name").getValue()) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                        params.add(rsSync.getTimestamp(column.attribute("name").getValue()));
                                                        sMessage += new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(rsSync.getTimestamp(column.attribute("name").getValue())) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                        params.add(new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                        sMessage += rsSync.getBoolean(column.attribute("name").getValue()) + " ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                        params.add(rsSync.getBytes(column.attribute("name").getValue()));
                                                        sMessage += "-bytes- ";
                                                    }
                                                    if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                        params.add(new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                        sMessage += rsSync.getFloat(column.attribute("name").getValue()) + " ";
                                                    }
                                                }
                                                sMessage += " where 1=1";
                                                sQuery += " where 1=1";
                                                columns = table.element("columns").elementIterator("column");
                                                while (columns.hasNext()) {
                                                    column = (Element) columns.next();
                                                    if (column.attribute("primary") != null && column.attribute("primary").getValue().equalsIgnoreCase("1")) {
                                                        sMessage += " and " + column.attribute("name").getValue() + "=";
                                                        sQuery += " and " + column.attribute("name").getValue() + "=?";
                                                        if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                            params.add(new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                            sMessage += rsSync.getInt(column.attribute("name").getValue()) + " ";
                                                        }
                                                        if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                            params.add(rsSync.getString(column.attribute("name").getValue()));
                                                            sMessage += rsSync.getString(column.attribute("name").getValue()) + " ";
                                                        }
                                                        if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                            params.add(rsSync.getTimestamp(column.attribute("name").getValue()));
                                                            sMessage += new SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(rsSync.getTimestamp(column.attribute("name").getValue())) + " ";
                                                        }
                                                    }
                                                }
                                                //Debug.println(sMessage);
                                                psSync2 = source.prepareStatement(sQuery);
                                                for (int n = 0; n < params.size(); n++) {
                                                    if (params.get(n) == null) {
                                                        psSync2.setObject(n + 1, null);
                                                    } else {
                                                        if (Integer.class.isInstance(params.get(n))) {
                                                            psSync2.setInt(n + 1, ((Integer) params.get(n)).intValue());
                                                        } else if (String.class.isInstance(params.get(n))) {
                                                            psSync2.setString(n + 1, ((String) params.get(n)));
                                                        } else if (Timestamp.class.isInstance(params.get(n))) {
                                                            psSync2.setTimestamp(n + 1, ((Timestamp) params.get(n)));
                                                        } else if (byte[].class.isInstance(params.get(n))) {
                                                            psSync2.setBytes(n + 1, ((byte[]) params.get(n)));
                                                        } else if (Boolean.class.isInstance(params.get(n))) {
                                                            psSync2.setBoolean(n + 1, ((Boolean) params.get(n)).booleanValue());
                                                        } else if (Float.class.isInstance(params.get(n))) {
                                                            psSync2.setFloat(n + 1, ((Float) params.get(n)).floatValue());
                                                        }
                                                    }
                                                }
                                                psSync2.execute();
                                            }
                                        }
                                    } else {
                                        //new record, insert it
                                        counter++;
                                        if (Debug.enabled) Debug.println("Record does not exist, inserting new record");
                                        if (table.attribute("proc") != null && !table.attribute("proc").getValue().equalsIgnoreCase("")) {
                                            columns = table.element("columns").elementIterator("column");
                                            cols = new HashMap();
                                            while (columns.hasNext()) {
                                                column = (Element) columns.next();
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                    cols.put(column, new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                    cols.put(column, rsSync.getString(column.attribute("name").getValue()));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                    cols.put(column, rsSync.getTimestamp(column.attribute("name").getValue()));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                    cols.put(column, new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                    cols.put(column, rsSync.getBytes(column.attribute("name").getValue()));
                                                }
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                    cols.put(column, new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                }
                                            }
                                            executeProcedure(table.attribute("proc").getValue(), cols, destination, source, out);
                                        } else {
                                            values = "";
                                            sQuery = "insert into " + table.attribute("name").getValue() + "(";
                                            bInited = false;
                                            columns = table.element("columns").elementIterator("column");
                                            params = new Vector();
                                            while (columns.hasNext()) {
                                                column = (Element) columns.next();
                                                if (bInited) {
                                                    sQuery += ",";
                                                    values += ",";
                                                } else {
                                                    bInited = true;
                                                }
                                                values += "?";
                                                sQuery += column.attribute("name").getValue();
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                                    params.add(new Integer(rsSync.getInt(column.attribute("name").getValue())));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                                    params.add(rsSync.getString(column.attribute("name").getValue()));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                                    params.add(rsSync.getTimestamp(column.attribute("name").getValue()));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("boolean")) {
                                                    params.add(new Boolean(rsSync.getBoolean(column.attribute("name").getValue())));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("bytes")) {
                                                    params.add(rsSync.getBytes(column.attribute("name").getValue()));
                                                } else
                                                if (column.attribute("javatype").getValue().equalsIgnoreCase("float")) {
                                                    params.add(new Float(rsSync.getFloat(column.attribute("name").getValue())));
                                                }
                                            }
                                            sQuery += ") values (" + values + ")";
                                            psSync2 = source.prepareStatement(sQuery);
                                            //Debug.println("1");
                                            for (int n = 0; n < params.size(); n++) {
                                                if (params.get(n) == null) {
                                                    psSync2.setObject(n + 1, null);
                                                } else {
                                                    //Debug.println("2");
                                                    if (Integer.class.isInstance(params.get(n))) {
                                                        psSync2.setInt(n + 1, ((Integer) params.get(n)).intValue());
                                                    } else if (String.class.isInstance(params.get(n))) {
                                                        psSync2.setString(n + 1, ((String) params.get(n)));
                                                    } else if (Timestamp.class.isInstance(params.get(n))) {
                                                        psSync2.setTimestamp(n + 1, ((Timestamp) params.get(n)));
                                                    } else if (byte[].class.isInstance(params.get(n))) {
                                                        psSync2.setBytes(n + 1, ((byte[]) params.get(n)));
                                                    } else if (Boolean.class.isInstance(params.get(n))) {
                                                        psSync2.setBoolean(n + 1, ((Boolean) params.get(n)).booleanValue());
                                                    } else if (Float.class.isInstance(params.get(n))) {
                                                        psSync2.setFloat(n + 1, ((Float) params.get(n)).floatValue());
                                                    }
                                                    //Debug.println("3");
                                                }
                                            }
                                            //Debug.println(sQuery);
                                            psSync2.execute();
                                        }
                                    }
                                }

                                if (maxVersion != null) {
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        setConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), maxVersion.toString(), OccupdbConnection);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        setConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), (String) maxVersion, OccupdbConnection);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        setConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), new SimpleDateFormat("yyyyMMddHHmmssSSS").format((Timestamp) maxVersion), OccupdbConnection);
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception e) {
                        comment(out, e.getMessage(), 2);
                    }
                }
            }
        }
        catch (Exception e) {
            comment(out, e.getMessage(), 2);
        }

        out.print("<table width='100%'>");

        if (bSuccess) {
            out.print("<tr><td class='admin'><b>" + getTran("Web.Occup", "medwan.common.synchronization-successfull", sWebLanguage) + "</b></td></tr>");
        } else {
            out.print("<tr><td class='admin'><b>" + getTran("Web.Occup", "medwan.common.synchronization-unsuccessfull", sWebLanguage) + "</b></td></tr>");
            out.print("<tr><td class='text'>" + sErrors + "</td></tr>");
        }
    }
    OccupdbConnection.close();
    dbConnection.close();
%>
</table>
</form>