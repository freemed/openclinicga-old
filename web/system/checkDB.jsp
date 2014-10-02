<%@page import="org.dom4j.Document,
                org.dom4j.io.SAXReader,
                java.net.URL,
                be.mxs.common.util.db.MedwanQuery,
                org.dom4j.Element,
                java.text.SimpleDateFormat,
                java.util.HashMap,
                java.util.Iterator,
                be.mxs.common.util.system.Debug,
                java.util.Vector,
                java.io.IOException,java.sql.*,be.mxs.common.util.system.ScreenHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@taglib uri="/WEB-INF/c-1_0.tld" prefix="c" %>
<!-- Hier geen Validateuser toevoegen!!!!! -->
<%!
    String sTDAdminWidth = "200";
    String sCONTEXTPATH = "/openwork";

    //--- GET CONFIG STRING -----------------------------------------------------------------------
    public String getConfigString(String key) {
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        String s = getConfigStringDB(key, co_conn);
        try{
        	co_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        return s;
    }

    //--- GET CONFIG STRING DB --------------------------------------------------------------------
    public String getConfigStringDB(String key, Connection Configlad_conn) {
        String cs = "";

        try {
            Statement st = Configlad_conn.createStatement();
            String sQuery = "SELECT oc_value FROM OC_Config" +
                    " WHERE oc_key like '" + key + "' AND deletetime is null ORDER BY oc_key";
            ResultSet Configrs = st.executeQuery(sQuery);
            while (Configrs.next()) {
                cs += Configrs.getString("ow_value");
            }

            Configrs.close();
            st.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        return ScreenHelper.checkString(cs);
    }

    //--- GET CONFIG INT --------------------------------------------------------------------------
    public int getConfigInt(String key) {
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        int n= getConfigIntDB(key, co_conn);
        try{
        	co_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        return n;
    }

    //--- GET CONFIG INT --------------------------------------------------------------------------
    public int getConfigInt(String key, int defaultValue) {
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        int n = getConfigIntDB(key, defaultValue, co_conn);
        try{
        	co_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        return n;
        
    }

    //--- GET CONFIG INT DB (1) -------------------------------------------------------------------
    public int getConfigIntDB(String key, Connection Configlad_conn) {
        int cs = 0;

        try {
            Statement st = Configlad_conn.createStatement();
            String sQuery = "SELECT oc_value FROM OC_Config" +
                    " WHERE oc_key like '" + key + "'" +
                    "  AND deletetime is null" +
                    " ORDER BY oc_key";
            ResultSet Configrs = st.executeQuery(sQuery);
            if (Configrs.next()) {
                String sOwValue = Configrs.getString("ow_value");
                if (sOwValue.length() > 0) {
                    cs = Integer.parseInt(sOwValue);
                }
            }

            Configrs.close();
            st.close();
        }
        catch (Exception e) {
            //e.printStackTrace();
        }

        return cs;
    }

    //--- GET CONFIG INT DB (2) -------------------------------------------------------------------
    public int getConfigIntDB(String key, int defaultValue, Connection Configlad_conn) {
        int cs = 0;

        try {
            Statement st = Configlad_conn.createStatement();
            String sQuery = "SELECT oc_value FROM OC_Config WHERE oc_key like '" + key + "'" +
                    "  AND deletetime is null ORDER BY oc_key";
            ResultSet Configrs = st.executeQuery(sQuery);
            if (Configrs.next()) {
                String sOwValue = Configrs.getString("ow_value");
                if (sOwValue.length() > 0) {
                    cs = Integer.parseInt(sOwValue);
                }
            } else {
                cs = defaultValue;
            }

            Configrs.close();
            st.close();
        }
        catch (Exception e) {
            //e.printStackTrace();
        }

        return cs;
    }

    //--- SET CONFIG STRING -----------------------------------------------------------------------
    public void setConfigString(String key, String value) {
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        setConfigStringDB(key, value, co_conn);
        try{
        	co_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
    }

    //--- SET CONFIG STRING DB --------------------------------------------------------------------
    public void setConfigStringDB(String key, String value, java.sql.Connection Configlad_conn) {
        PreparedStatement ps = null;

        // delete
      	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        try {
            ps = co_conn.prepareStatement("delete FROM OC_Config WHERE oc_key like ?");
            ps.setString(1, key);
            ps.execute();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (ps != null) ps.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }

        // insert
        try {
            ps = co_conn.prepareStatement("insert into OC_Config(oc_key,oc_value, sql_value,synchronize) values(?,?,'','')");
            ps.setString(1, key);
            ps.setString(2, value);
            ps.execute();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            try {
                if (ps != null) ps.close();
                co_conn.close();
            }
            catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }

    public String getConfigParam(String key, String param) {
    	Connection co_conn = MedwanQuery.getInstance().getConfigConnection();
        String s = getConfigParamDB(key, param, co_conn);
        try{
        	co_conn.close();
        }
        catch(Exception e){
        	e.printStackTrace();
        }
        return s;
    }

    public String getConfigParamDB(String key, String param, Connection Configlad_conn) {
        return getConfigString(key).replaceAll("<param>", param);
    }

    public void status(javax.servlet.jsp.JspWriter out, String message) throws IOException {
        out.println("<script>window.status=\"" + message + "\";</script>");
        out.flush();
    }

    public String writeTableHeader(String sType, String sID, String sLanguage, String sPage) {
        String sReturn = "<table width='100%' cellspacing='0'>" +
                "<tr class='admin' height='20'>" +
                "<td>" + MedwanQuery.getInstance().getLabel(sType, sID, sLanguage) + "</td>";

        if (sPage.trim().length() > 0) {
            sReturn += "<td align='right'>" +
                    "<a class='previousButton' href='" + sPage + "' title='"+MedwanQuery.getInstance().getLabel("Web", "Back", sLanguage) +"' alt='"+MedwanQuery.getInstance().getLabel("Web", "Back", sLanguage) +"'>" +
                    " &nbsp;" +
                    "</a>" +
                    "</td>";
        }

        sReturn += "</tr></table>";

        return sReturn;
    }

    private void comment(JspWriter out, String msg, int ok) {
        if (Debug.enabled) Debug.println(msg);
        try {
            if (ok == 1) {
                out.println("<tr><td colspan='2' class='menuItemGreen'>" + msg + "</td></tr>");
            } else if (ok == 2) {
                out.println("<tr class='list'><td>&nbsp;</td><td class='menuItemRed'>" + msg + "</td></tr>");
            } else {
                out.println("<tr class='list'><td>&nbsp;</td><td class='admin2'>" + msg + "</td></tr>");
            }
            status(out, msg.replaceAll("<b>", "").replaceAll("</b>", ""));
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Object getValueForName(String name, HashMap elements) {
        Iterator keys = elements.keySet().iterator();
        Element key;
        while (keys.hasNext()) {
            key = (Element) keys.next();
            if (key.attribute("name").getValue().equals(name)) {
                return elements.get(key);
            }
        }
        return null;
    }

    private void executeProcedure(String procedure, HashMap cols, java.sql.Connection source, Connection destination, JspWriter out) {
        if (procedure.equalsIgnoreCase("riskprofile")) {
            boolean bMoveProfile = false;
            boolean bArchiveProfile = false;
            int profileId = -1;
            int personid = ((Integer) getValueForName("personId", cols)).intValue();
            Timestamp dateBegin = (Timestamp) getValueForName("dateBegin", cols);
            try {
                //Look for the active riskprofile for this patient on the destinationserver
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
                    ps.close();
                }
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
						ps.close();
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
						rs.close();
						ps.close();
                    }
                    else {
						rs.close();
						ps.close();
                    }
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
                String sOwnServerId = MedwanQuery.getInstance().getConfigString("serverId");
                if (false && versionserverid == Integer.parseInt(sOwnServerId)) {
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
                        if (versionserverid == rs.getInt("versionserverid")) {
                            //Same versionserverid on both sides
                            if (version > rs.getInt("version")) {
                                //item on destination server has lower version
                                bMoveTransaction = true;
                                bArchiveTransaction = true;
                            } else {
                                //item on destination server has the same or higher version
                            }
                        } else if (versionserverid != rs.getInt("versionserverid")) {
                            //Different versionserverid's
                            if (ts.after(rs.getTimestamp("ts"))) {
                                //item on destination server is older
                                bMoveTransaction = true;
                                bArchiveTransaction = true;
                            } else {
                                //item on destinationserver is not older, do nothing
                            }
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
                        //Copy Transaction to TransactionsHistory & Item to ItemsHistory and remove them from
                        //the original tables
                        ps = destination.prepareStatement("insert into TransactionsHistory(transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,versionserverid,version) select transactionId,creationDate,transactionType,updateTime,status,healthRecordId,userId,serverid,versionserverid,version from Transactions where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
						ps.close();
                        ps = destination.prepareStatement("insert into ItemsHistory(itemId,type," + destinationValueColumn + "," + destinationDateColumn + ",transactionId,serverid,versionserverid,version) select itemId,type," + destinationValueColumn + "," + destinationDateColumn + ",transactionId,serverid,versionserverid,version from Items where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
                        ps.close();
                        ps = destination.prepareStatement("delete from Transactions where serverid=? and transactionId=?");
                        ps.setInt(1, serverid);
                        ps.setInt(2, transactionId);
                        ps.execute();
                        ps.close();
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
                                    ps.close();
                                }
                            } else {
        						rs.close();
        						ps.close();
                                healthrecordid = -1;
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
                        ps.close();
                        //Then move all Items that are linked to the Transaction
                        PreparedStatement psSource = source.prepareStatement("select * from Items where serverid=? and transactionId=? and version=? and versionserverid=?");
                        psSource.setInt(1, serverid);
                        psSource.setInt(2, transactionId);
                        psSource.setInt(3, version);
                        psSource.setInt(4, versionserverid);
                        rs = psSource.executeQuery();
                        while (rs.next()) {
                            String src = rs.getString(sourceValueColumn);
                            String typ = rs.getString("type");
    						rs.close();
    						ps.close();
                            ps = destination.prepareStatement("insert into Items(itemId,type," + destinationValueColumn + "," + destinationDateColumn + ",transactionId,serverid,version,versionserverid,valuehash) values(?,?,?,?,?,?,?,?,?)");
                            ps.setInt(1, rs.getInt("itemId"));
                            ps.setString(2, typ);
                            ps.setString(3, src);
                            ps.setTimestamp(4, rs.getTimestamp(sourceDateColumn));
                            ps.setInt(5, transactionId);
                            ps.setInt(6, serverid);
                            ps.setInt(7, version);
                            ps.setInt(8, versionserverid);
                            ps.setInt(9, (typ + src).hashCode());
                            ps.execute();
                            ps.close();
                        }
						if(rs!=null) rs.close();
    	                if (ps != null) {
                            ps.close();
                        }
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
<script>window.clearInterval(userinterval);</script>
<%
    Document document=null;
    String sDoc="";
    Connection loc_conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
    Connection sta_conn = MedwanQuery.getInstance().getStatsConnection();
    Connection lad_conn = MedwanQuery.getInstance().getLongAdminConnection();

    String sLocalDbType="?";
    String sLocalDbVersion = "?";

    //Find out local database type & version
    try {
        sLocalDbType = lad_conn.getMetaData().getDatabaseProductName();
        sLocalDbVersion = lad_conn.getMetaData().getDatabaseProductVersion();
    }
    catch(Exception e){
        //e.printStackTrace();
    }

    boolean bInit=false;
    if (document==null || request.getParameter("reload")!=null){
        Debug.println("reloading model");
        SAXReader reader = new SAXReader(false);
        sDoc = MedwanQuery.getInstance().getConfigString("templateSource","http://localhost/openclinic/_common/xml/")+"db.xml";
        document = reader.read(new URL(sDoc));
        bInit=true;
    }
%>
<form name="merge" method="post">
    <table width="100%" class="list" cellspacing="1">
        <tr>
            <td colspan="2"><%=writeTableHeader("Web.Occup","medwan.common.db-management","N","main.jsp?Page=system/menu.jsp")%></td>
        </tr>
        <tr><td width="<%=sTDAdminWidth%>" class="admin">Local database type</td><td class="admin2" colspan="2"><b><%=sLocalDbType%></b> version <b><%=sLocalDbVersion.replaceAll(sLocalDbType,"")%></b></td></tr>
        <tr><td class="admin">Model document</td><td class="admin2" colspan="2"><b><%=sDoc%></b></td></tr>
        <tr>
            <td class="admin">&nbsp;</td><td class="admin2">
                <input id="5" type="checkbox" name="verify" value="verify" checked/>Verify objects &nbsp;
                <input id="6" type="checkbox" name="create" value="create" checked/>Create objects &nbsp;
                <input id="7" type="checkbox" name="synchronize" value="synchronize" checked/>Synchronize objects
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="submit" name="submit" value="execute"/>
                <input class="button" type="submit" name="reload" value="reload model"/>
                <input class="button" type="button" name="cancel" value='<%=MedwanQuery.getInstance().getLabel("Web","Back","N")%>' OnClick='javascript:window.location.href="main.jsp?Page=system/menu.jsp"'>
            </td>
        </tr>
    </table>
    <br>
<script>
    if ("<%= request.getParameter("verify")+""%>" == "verify") {document.getElementById(5).checked=true} else {document.getElementById(5).checked=false};
    if ("<%= request.getParameter("create")+""%>" == "create") {document.getElementById(6).checked=true} else {document.getElementById(6).checked=false};
    if ("<%= request.getParameter("synchronize")+""%>" == "synchronize") {document.getElementById(7).checked=true} else {document.getElementById(7).checked=false};
</script>

<a href="#" onclick="checkAll(true);"><%=MedwanQuery.getInstance().getLabel("Web.Manage.CheckDb","CheckAll","N")%></a>
<a href="#" onclick="checkAll(false);"><%=MedwanQuery.getInstance().getLabel("Web.Manage.CheckDb","UncheckAll","N")%></a>
<a href="#" onclick="checkAllReset(true);"><%=MedwanQuery.getInstance().getLabel("Web.Manage.CheckDb","CheckAllReset","N")%></a>
<a href="#" onclick="checkAllReset(false);"><%=MedwanQuery.getInstance().getLabel("Web.Manage.CheckDb","UncheckAllReset","N")%></a>
<a href="#" onclick="checkAllFullSync(true);"><%=MedwanQuery.getInstance().getLabel("Web.Manage.CheckDb","CheckAllFullSync","N")%></a>
<a href="#" onclick="checkAllFullSync(false);"><%=MedwanQuery.getInstance().getLabel("Web.Manage.CheckDb","UncheckAllFullSync","N")%></a>

<table width="100%" class="list" cellspacing="1">
<%
    comment(out, "Sync tables:", 1);
    Iterator tables = document.getRootElement().elementIterator("table");
    Element table;
    String sMessage = "";

    while (tables.hasNext()) {
        table = (Element) tables.next();
        if (table.attribute("sync") != null && !table.attribute("sync").getValue().equalsIgnoreCase("NONE")) {
            out.print("<tr class='list'><td>&nbsp;</td><td><input type='checkbox' name='" + table.attribute("name").getValue() + "'"
                    + (bInit || request.getParameter(table.attribute("name").getValue()) != null ? " checked " : "") + "/>"
                    + table.attribute("name").getValue() + " (" + table.attribute("sync").getValue() + ")");
            out.print("&nbsp;&nbsp;&nbsp;<input type='checkbox' name='" + table.attribute("name").getValue() + ".fullreset' value='medwan.common.true'/>Reset");
            out.print("&nbsp;&nbsp;&nbsp;<input type='checkbox' name='" + table.attribute("name").getValue() + ".fullsync' value='medwan.common.true'/>Full sync");
            out.print("</td></tr>");
        }
    }

    if (request.getParameter("submit") != null) {

        try {
            String sOwnServerId = MedwanQuery.getInstance().getConfigString("serverId");
            Element versionColumn = null;
            Connection connectionCheck = null;
            PreparedStatement psCheck = null;
            ResultSet rsCheck = null;
            Connection otherAdminConnection = null;
            Connection otherOccupConnection = null;
            if (request.getParameter("synchronize") != null) {
                if (request.getParameter("driver").equals("Sybase")) {
                    Class.forName("com.sybase.jdbc2.jdbc.SybDriver");
                    otherAdminConnection = DriverManager.getConnection("jdbc:sybase:Tds:" + request.getParameter("ipadmin"), request.getParameter("username"), request.getParameter("password"));
                    otherOccupConnection = java.sql.DriverManager.getConnection("jdbc:sybase:Tds:" + request.getParameter("ipoccup"), request.getParameter("username"), request.getParameter("password"));
                }

                if (request.getParameter("driver").equals("MSSQLServer")) {
                    Class.forName("net.sourceforge.jtds.jdbc.Driver");
                    otherAdminConnection = DriverManager.getConnection("jdbc:jtds:sqlserver://" + request.getParameter("ipadmin"), request.getParameter("username"), request.getParameter("password"));
                    otherOccupConnection = DriverManager.getConnection("jdbc:jtds:sqlserver://" + request.getParameter("ipoccup"), request.getParameter("username"), request.getParameter("password"));
                }

            }
            Element model = document.getRootElement();
            comment(out, "Parsing model <b>" + model.attribute("name").getValue() + "</b> version <b>" + model.attribute("version").getValue() + "</b> dd <b>" + model.attribute("date").getValue() + "</b>", 1);
            comment(out, "Parsing tables...", 1);

            Element column, index, view, proc, exec, sql;
            DatabaseMetaData databaseMetaData;
            Iterator columns, indexes, indexcolumns, views, sqlIterator, procs, execs;
            String sSelect, sVal, sQuery, sCountQuery, otherServerId, inSql, versioncompare, values, outSql, indexname;
            Connection source, destination;
            boolean inited, indexFound, bDoWork, bInited, bCreate;
            PreparedStatement psSync;
            ResultSet rsSync, rsCount;
            PreparedStatement psCountSync, psSync2;
            ResultSet rsCountSync, rsSync2;
            Object maxVersion;
            HashMap primaryKey, cols;
            int counter, total, syncTotal, rowCounter, compareStatus;
            Statement stDelete, stCount, st;
            Integer nVal;
            Vector params;

            tables = model.elementIterator("table");
            while (tables.hasNext()) {
                table = (Element) tables.next();
                comment(out, "Parsing table <b>" + table.attribute("name").getValue() + "</b> in database " + table.attribute("db").getValue(), 1);
                //Checking existence of table
                //First select right connection

                if (table.attribute("db").getValue().equalsIgnoreCase("ocadmin")) {

                    connectionCheck = lad_conn;

                } else if (table.attribute("db").getValue().equalsIgnoreCase("openclinic")) {

                    connectionCheck = loc_conn;

	            } else if (table.attribute("db").getValue().equalsIgnoreCase("stats")) {
	
	                connectionCheck = sta_conn;
	
	            }

                //Now verify existence of table
                databaseMetaData = connectionCheck.getMetaData();
                rsCheck = databaseMetaData.getTables(null, null, table.attribute("name").getValue(), null);

                boolean tableExists=rsCheck.next();

                if (!tableExists){
                    rsCheck=databaseMetaData.getTables(null, null, table.attribute("name").getValue().toLowerCase(), null);
                    tableExists=rsCheck.next();
                }

                if (tableExists) {
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
                                boolean columnExists=rsCheck.next();
                                if(!columnExists){
                                    rsCheck = databaseMetaData.getColumns(null, null, table.attribute("name").getValue().toLowerCase(), column.attribute("name").getValue());
                                    columnExists=rsCheck.next();
                                }
                                if(!columnExists){
                                    rsCheck = databaseMetaData.getColumns(null, null, table.attribute("name").getValue().toLowerCase(), column.attribute("name").getValue().toLowerCase());
                                    columnExists=rsCheck.next();
                                }
                                if (!columnExists) {
                                    comment(out, "&nbsp;Column <b>" + column.attribute("name").getValue() + "</b> does not exist", 0);
                                    if (request.getParameter("create") != null) {
                                        comment(out, "&nbsp;Creating Column", 0);
                                        if (column.attribute("nulls") != null && column.attribute("nulls").getValue().equalsIgnoreCase("0")) {
                                            comment(out, "&nbsp;WARNING, column is not nullable but will be added as nullable!", 0);
                                        }
                                        sSelect = "alter table " + table.attribute("name").getValue() + " add " + column.attribute("name").getValue() + " ";
                                        if (column.attribute("dbtype").getValue().equalsIgnoreCase("char") || column.attribute("dbtype").getValue().equalsIgnoreCase("varchar")) {
                                            sSelect += column.attribute("dbtype").getValue() + "(" + column.attribute("size").getValue() + ")";
                                        } else {
                                            sSelect += column.attribute("dbtype").getValue();
                                        }
                                        sSelect += " null";
                                        psCheck = connectionCheck.prepareStatement(sSelect);
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

                        sSelect = "create table " + table.attribute("name").getValue() + "(";
                        columns = table.element("columns").elementIterator("column");
                        inited = false;

                        while (columns.hasNext()) {
                            column = (Element) columns.next();
                            if (inited) {
                                sSelect += ",";
                            } else {
                                inited = true;
                            }

                            sSelect += column.attribute("name").getValue() + " ";

                            if (column.attribute("dbtype").getValue().equalsIgnoreCase("char") || column.attribute("dbtype").getValue().equalsIgnoreCase("varchar")) {
                                sSelect += column.attribute("dbtype").getValue() + "(" + column.attribute("size").getValue() + ")";
                            } else {
                                sSelect += column.attribute("dbtype").getValue();
                            }

                            if (column.attribute("nulls") != null && column.attribute("nulls").getValue().equalsIgnoreCase("0")) {
                                sSelect += " not null";
                            } else {
                                sSelect += " null";
                            }

                        }
                        try {
                            sSelect += ")";
                            psCheck = connectionCheck.prepareStatement(sSelect);
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
                                        sSelect = "create ";
                                        if (index.attribute("unique") != null && index.attribute("unique").getValue().equalsIgnoreCase("1")) {
                                            sSelect += " unique ";
                                        }
                                        sSelect += "index " + index.attribute("name").getValue() + " on " + table.attribute("name").getValue() + "(";
                                        indexcolumns = index.elementIterator("indexcolumn");
                                        inited = false;
                                        while (indexcolumns.hasNext()) {
                                            Element indexcolumn = (Element) indexcolumns.next();
                                            if (inited) {
                                                sSelect += ",";
                                            } else {
                                                inited = true;
                                            }
                                            if (indexcolumn.attribute("order").getValue().equalsIgnoreCase("ASC")) {
                                                sSelect += indexcolumn.attribute("name").getValue();
                                            } else {
                                                sSelect += indexcolumn.attribute("name").getValue() + " " + indexcolumn.attribute("order").getValue();
                                            }
                                        }
                                        sSelect += ")";
                                        psCheck = connectionCheck.prepareStatement(sSelect);
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
                            if (MedwanQuery.getInstance().getConfigString("masterEnabled").equalsIgnoreCase("1")) {
                                //This machine is the master (source)
                                if (table.attribute("db").getValue().equalsIgnoreCase("admin")) {
                                    source = lad_conn;
                                    destination = otherAdminConnection;
                                }
                                if (table.attribute("db").getValue().equalsIgnoreCase("occup")) {
                                    source = loc_conn;
                                    destination = otherOccupConnection;
                                }
                            } else {
                                //The other machine is the master (source)
                                if (table.attribute("db").getValue().equalsIgnoreCase("admin")) {
                                    source = otherAdminConnection;
                                    destination = lad_conn;
                                }
                                if (table.attribute("db").getValue().equalsIgnoreCase("occup")) {
                                    source = otherOccupConnection;
                                    destination = loc_conn;
                                }
                            }
                            //MASTER, MASTEREXIST, MERGE
                            //In any case the source -> destination synchro has to be done
                            //First determine the last checked version
                            psSync = null;
                            rsSync = null;
                            sQuery = null;
                            psCountSync = null;
                            rsCountSync = null;
                            sCountQuery = null;
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
                                    && !"medwan.common.true".equalsIgnoreCase(request.getParameter(table.attribute("name").getValue() + ".fullsync"))
                                    && MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) != null
                                    && !MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()).equalsIgnoreCase("")) {
                                //Do select from source table where version later than last checked version
                                if (versionColumn == null) {
                                    sQuery = "select * from " + table.attribute("name").getValue();
                                    sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue();
                                    psSync = source.prepareStatement(sQuery);
                                    psCountSync = source.prepareStatement(sCountQuery);
                                } else {
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + inSql + "order by " + versionColumn.attribute("name").getValue();
                                    sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + inSql;
                                    psSync = source.prepareStatement(sQuery);
                                    psCountSync = source.prepareStatement(sCountQuery);
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        psSync.setInt(1, Integer.parseInt(MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())));
                                        psCountSync.setInt(1, Integer.parseInt(MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        psSync.setString(1, MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()));
                                        psCountSync.setString(1, MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        Timestamp ts = new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())).getTime());
                                        psSync.setTimestamp(1, ts);
                                        psCountSync.setTimestamp(1, ts);
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
                                if (versionColumn == null || "medwan.common.true".equalsIgnoreCase(request.getParameter(table.attribute("name").getValue() + ".fullsync"))) {
                                    sQuery = "select * from " + table.attribute("name").getValue();
                                    sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue();
                                    psSync = source.prepareStatement(sQuery);
                                    psCountSync = source.prepareStatement(sCountQuery);
                                } else {
                                    stCount = destination.createStatement();
                                    rsCount = stCount.executeQuery("select max(" + versionColumn.attribute("name").getValue() + ") as maxVal from " + table.attribute("name").getValue());
                                    if (rsCount.next() && rsCount.getObject("maxVal") != null) {
                                        if (Debug.enabled)
                                            Debug.println("maxVal=" + rsCount.getObject("maxVal").toString());
                                        sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + inSql + "order by " + versionColumn.attribute("name").getValue();
                                        sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + inSql;
                                        psSync = source.prepareStatement(sQuery);
                                        psCountSync = source.prepareStatement(sCountQuery);
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                            psSync.setInt(1, rsCount.getInt("maxVal"));
                                            psCountSync.setInt(1, rsCount.getInt("maxVal"));
                                        }
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                            psSync.setString(1, rsCount.getString("maxVal"));
                                            psCountSync.setString(1, rsCount.getString("maxVal"));
                                        }
                                        if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                            psSync.setTimestamp(1, rsCount.getTimestamp("maxVal"));
                                            psCountSync.setTimestamp(1, rsCount.getTimestamp("maxVal"));
                                        }
                                    } else {
                                        sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + " is not null " + inSql + "order by " + versionColumn.attribute("name").getValue();
                                        sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + " is not null " + inSql;
                                        psSync = source.prepareStatement(sQuery);
                                        psCountSync = source.prepareStatement(sCountQuery);
                                    }
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
                                    stCount = destination.createStatement();
                                    rsCount = stCount.executeQuery("select count(*) total from " + table.attribute("name").getValue());
                                    if (rsCount.next()) {
                                        if (total == rsCount.getInt("total")) {
                                            bDoWork = false;
                                        }
                                    }
                                }
                                rsCount.close();
                                stCount.close();
                            }
                            if (bDoWork) {
                                if (Debug.enabled)
                                    Debug.println("MASTER -> SLAVE (?=" + MedwanQuery.getInstance().getConfigString("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) + "):" + sQuery);
                                rsSync = psSync.executeQuery();
                                rsCountSync = psCountSync.executeQuery();
                                rsCountSync.next();
                                syncTotal = rsCountSync.getInt("sync_total");
                                rsCountSync.close();
                                psCountSync.close();
                                rowCounter = 0;
                                while (rsSync.next()) {
                                    if (rowCounter % 100 == 0 || (counter > 0 && counter % 100 == 0)) {
                                        status(out, " Synchronizing master to slave: " + table.attribute("name").getValue() + " " + rowCounter + " rows of " + syncTotal + " verified, " + counter + " rows copied...");
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
                                                Timestamp dVal = rsSync.getTimestamp(column.attribute("name").getValue());
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
                                                psSync2.close();
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
                                            psSync2.close();
                                        }
                                    }
                                }

                                if (maxVersion != null) {
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        setConfigStringDB("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), (maxVersion).toString(), loc_conn);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        setConfigStringDB("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), (String) maxVersion, loc_conn);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        setConfigStringDB("lastCheckFor." + otherServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), new SimpleDateFormat("yyyyMMddHHmmssSSS").format((Timestamp) maxVersion), loc_conn);
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
                                if (!"medwan.common.true".equalsIgnoreCase(request.getParameter(table.attribute("name").getValue() + ".fullsync")) && MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) != null && !getConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), loc_conn).equalsIgnoreCase("")) {
                                    //Do select from source table where version later than last checked version
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + outSql + "order by " + versionColumn.attribute("name").getValue();
                                    sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + versioncompare + "? " + outSql;
                                    psSync = destination.prepareStatement(sQuery);
                                    psCountSync = destination.prepareStatement(sCountQuery);
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        psSync.setInt(1, Integer.parseInt(MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())));
                                        psCountSync.setInt(1, Integer.parseInt(MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        psSync.setString(1, MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()));
                                        psCountSync.setString(1, MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()));
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        psSync.setTimestamp(1, new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())).getTime()));
                                        psCountSync.setTimestamp(1, new Timestamp(new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue())).getTime()));
                                    }
                                } else {
                                    //First time select. Select all rows from source database
                                    sQuery = "select * from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + " is not null " + outSql + "order by " + versionColumn.attribute("name").getValue();
                                    sCountQuery = "select count(*) sync_total from " + table.attribute("name").getValue() + " where " + versionColumn.attribute("name").getValue() + " is not null " + outSql;
                                    psSync = destination.prepareStatement(sQuery);
                                    psCountSync = destination.prepareStatement(sCountQuery);
                                }
                                maxVersion = null;
                                primaryKey = new HashMap();
                                if (Debug.enabled)
                                    Debug.println("SLAVE -> MASTER (?=" + MedwanQuery.getInstance().getConfigString("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue()) + "):" + sQuery);
                                rsSync = psSync.executeQuery();
                                rsCountSync = psCountSync.executeQuery();
                                rsCountSync.next();
                                syncTotal = rsCountSync.getInt("sync_total");
                                rsCountSync.close();
                                psCountSync.close();
                                rowCounter = 0;
                                while (rsSync.next()) {
                                    if (rowCounter % 100 == 0 || (counter > 0 && counter % 100 == 0)) {
                                        status(out, " Synchronizing slave to master: " + table.attribute("name").getValue() + " " + rowCounter + " rows of " + syncTotal + " verified, " + counter + " rows copied...");
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
                                                Timestamp dVal = rsSync.getTimestamp(column.attribute("name").getValue());
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
                                }
                                psSync.close();
                                if (maxVersion != null) {
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("integer")) {
                                        setConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), (maxVersion).toString(), loc_conn);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("string")) {
                                        setConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), (String) maxVersion, loc_conn);
                                    }
                                    if (versionColumn.attribute("javatype").getValue().equalsIgnoreCase("date")) {
                                        setConfigStringDB("lastCheckFor." + sOwnServerId + "." + table.attribute("db").getValue() + "." + table.attribute("name").getValue(), new SimpleDateFormat("yyyyMMddHHmmssSSS").format((Timestamp) maxVersion), loc_conn);
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
            comment(out, "Parsing views...", 1);
            views = model.elementIterator("view");
            while (views.hasNext()) {
                try {
                    view = (Element) views.next();
                    comment(out, "Parsing view <b>" + view.attribute("name").getValue() + "</b> in database " + view.attribute("db").getValue(), 1);
                    //Checking existence of view
                    //First select right connection
                    sqlIterator = view.elementIterator("sql");
                    String s = "";
                    while (sqlIterator.hasNext()) {
                        sql = (Element) sqlIterator.next();
                        if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
                            s = sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin")).replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic"));
                        }
                    }
                    if (s.trim().length() > 0) {
                        if (view.attribute("db").getValue().equalsIgnoreCase("ocadmin")) {
                            connectionCheck = lad_conn;
                        } else if (view.attribute("db").getValue().equalsIgnoreCase("openclinic")) {
                            connectionCheck = loc_conn;
	                    } else if (view.attribute("db").getValue().equalsIgnoreCase("stats")) {
	                        connectionCheck = sta_conn;
                    	}
                        //Now verify existence of view
                        databaseMetaData = connectionCheck.getMetaData();
                        rsCheck = databaseMetaData.getTables(null, null, view.attribute("name").getValue(), null);
                        bCreate = true;
                        if (rsCheck.next()) {
                            if (view.attribute("drop") != null && view.attribute("drop").getValue().equalsIgnoreCase("1")) {
                                //drop the view
                                if (request.getParameter("create") != null) {
                                    psCheck = connectionCheck.prepareStatement("drop view " + view.attribute("name").getValue());
                                    try{
                                    	psCheck.execute();
                                    }
                                    catch(Exception v){
                                    	psCheck = connectionCheck.prepareStatement("drop table " + view.attribute("name").getValue());
                                    	psCheck.execute();
                                    }
                                    comment(out, " View <b>" + view.attribute("name").getValue() + "</b> dropped", 0);
                                    psCheck.close();
                                }
                            } else {
                                bCreate = false;
                            }
                        } else {
                            comment(out, " View <b>" + view.attribute("name").getValue() + "</b> does not exist", 0);
                        }

                        if (bCreate && request.getParameter("create") != null) {
                            sqlIterator = view.elementIterator("sql");
                            while (sqlIterator.hasNext()) {
                                sql = (Element) sqlIterator.next();
                                if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
                                    st = connectionCheck.createStatement();
                                    String sq = sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin")).replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic"));
                                    sq = sq.replaceAll("\n", " ");
                                    sq = sq.replaceAll("\r", " ");
                                    st.addBatch(sq);
                                    st.executeBatch();
                                    st.close();
                                    comment(out, " View <b>" + view.attribute("name").getValue() + "</b> created", 0);
                                }
                            }
                        }
                    }
                }
                catch (Exception e) {
                    comment(out, e.getMessage(), 2);
                }
            }
            comment(out, "Parsing stored procedures...", 1);
            procs = model.elementIterator("proc");
            while (procs.hasNext()) {
                try {
                    proc = (Element) procs.next();
                    comment(out, "Parsing procedure <b>" + proc.attribute("name").getValue() + "</b> in database " + proc.attribute("db").getValue(), 1);
                    //Checking existence of view
                    //First select right connection
                    sqlIterator = proc.elementIterator("sql");
                    String s = "";
                    while (sqlIterator.hasNext()) {
                        sql = (Element) sqlIterator.next();
                        if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
                            s = sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin")).replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic"));
                        }
                    }
                    if (s.trim().length() > 0) {
                        if (proc.attribute("db").getValue().equalsIgnoreCase("admin")) {
                            connectionCheck = lad_conn;
                        } else if (proc.attribute("db").getValue().equalsIgnoreCase("occup")) {
                            connectionCheck = loc_conn;
	                    } else if (proc.attribute("db").getValue().equalsIgnoreCase("stats")) {
	                        connectionCheck = sta_conn;
	                	}
                        //Now verify existence of view
                        databaseMetaData = connectionCheck.getMetaData();
                        rsCheck = databaseMetaData.getProcedures(null, null, proc.attribute("name").getValue());
                        bCreate = true;
                        if (rsCheck.next()) {
                            if (proc.attribute("drop") != null && proc.attribute("drop").getValue().equalsIgnoreCase("1")) {
                                if (request.getParameter("create") != null) {
                                    //drop the view
                                    psCheck = connectionCheck.prepareStatement("drop proc " + proc.attribute("name").getValue());
                                    psCheck.execute();
                                    comment(out, " Procedure <b>" + proc.attribute("name").getValue() + "</b> dropped", 0);
                                    psCheck.close();
                                }
                            } else {
                                bCreate = false;
                            }
                        } else {
                            comment(out, " Procedure <b>" + proc.attribute("name").getValue() + "</b> does not exist", 0);
                        }
                        if (bCreate && request.getParameter("create") != null) {
                            sqlIterator = proc.elementIterator("sql");
                            while (sqlIterator.hasNext()) {
                                sql = (Element) sqlIterator.next();
                                if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
                                    st = connectionCheck.createStatement();
                                    st.addBatch(sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin")).replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic")));
                                    st.executeBatch();
                                    st.close();
                                    comment(out, " Procedure <b>" + proc.attribute("name").getValue() + "</b> created", 0);
                                }
                            }
                        }
                    }
                }
                catch (Exception e) {
                    comment(out, e.getMessage(), 2);
                }
            }
            comment(out, "Parsing direct sql...", 1);
            execs = model.elementIterator("exec");
            while (execs.hasNext()) {
                try {
                    exec = (Element) execs.next();
                    //First check if direct SQL has not been executed yet
                    String exeId = "directSQL." + exec.attribute("id").getValue() + ".executed";
                    if (!MedwanQuery.getInstance().getConfigString(exeId).equals("medwan.common.true")) {
                        //Select right connection
                        if (exec.attribute("db").getValue().equalsIgnoreCase("admin")) {
                            connectionCheck = lad_conn;
                        } else if (exec.attribute("db").getValue().equalsIgnoreCase("occup")) {
                            connectionCheck = loc_conn;
	                    } else if (exec.attribute("db").getValue().equalsIgnoreCase("stats")) {
	                        connectionCheck = sta_conn;
	                	}
                        //Now verify existence of view
                        if (request.getParameter("create") != null) {
                            sqlIterator = exec.elementIterator("sql");
                            while (sqlIterator.hasNext()) {
                                sql = (Element) sqlIterator.next();
                                if (sql.attribute("db") == null || sql.attribute("db").getValue().equalsIgnoreCase(sLocalDbType)) {
                                    st = connectionCheck.createStatement();
                                    st.addBatch(sql.getText().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin")).replaceAll("@openclinic@", MedwanQuery.getInstance().getConfigString("openclinicdbName","openclinic")).replaceAll(";", "\n"));
                                    st.executeBatch();
                                    st.close();
                                    comment(out, " sql executed", 0);
                                    setConfigStringDB("directSQL." + exec.attribute("id").getValue() + ".executed", "medwan.common.true", loc_conn);
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
        catch (Exception e) {
            comment(out, e.getMessage(), 2);
        }
    }
    loc_conn.close();
    lad_conn.close();
    sta_conn.close();
%>
</table>

<script>
  function checkAll(setchecked){
    for (i = 0; i < merge.elements.length; i++){
      if ((merge.elements[i].name!="verify")
      &&(merge.elements[i].name!="create")
      &&(merge.elements[i].name!="synchronize")
      &&(merge.elements[i].name!="driver")
      &&(merge.elements[i].name.indexOf("fullreset")<1)
      &&(merge.elements[i].name.indexOf("fullsync")<1)
      ){
        merge.elements[i].checked = setchecked;
      }
    }
  }

  function checkAllReset(setchecked){
    for (i = 0; i < merge.elements.length; i++){
      if (merge.elements[i].name.indexOf("fullreset")>0) {
        merge.elements[i].checked = setchecked;
      }
    }
  }

  function checkAllFullSync(setchecked){
    for (i = 0; i < merge.elements.length; i++){
      if (merge.elements[i].name.indexOf("fullsync")>0) {
        merge.elements[i].checked = setchecked;
      }
    }
  }
</script>
<br>
<input class="button" type="button" name="cancel" value='<%=MedwanQuery.getInstance().getLabel("Web","Back","N")%>' OnClick='javascript:window.location.href="main.jsp?Page=system/menu.jsp"'>
<a href="#topp" class="topbutton">&nbsp;</a>
</form>