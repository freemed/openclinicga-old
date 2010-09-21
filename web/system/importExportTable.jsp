<%@ page import="be.mxs.common.util.io.table.SyncTables,
                 be.mxs.common.util.io.table.SyncTable,
                 be.mxs.common.util.io.table.SyncRow,
                 be.mxs.common.util.io.table.SyncColumn,
                 java.io.*,
                 org.dom4j.io.XMLWriter,
                 java.text.DecimalFormat,
                 org.dom4j.io.SAXReader,
                 org.dom4j.Document,
                 java.net.URL,
                 org.dom4j.Element,
                 be.mxs.common.util.db.MedwanQuery,
                 java.util.SortedSet,
                 java.util.TreeSet,
                 java.sql.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sFindDatabase = checkString(request.getParameter("FindDatabase"));
    String sFindTable = checkString(request.getParameter("FindTable"));
    String sFindExportFile = checkString(request.getParameter("FindExportFile"));
    String sAction = checkString(request.getParameter("Action"));
    String sFindUploadFile = checkString(request.getParameter("FindUploadFile"));

    if ((sAction.equalsIgnoreCase("import"))&&(sFindUploadFile.length()>0)){
        try{
            SAXReader xmlReader = new SAXReader();
            Document document = xmlReader.read(new URL(sFindUploadFile));
            Element root = document.getRootElement();
            SyncTables tables = new SyncTables();
            tables.parse(root);
            if (tables.save()){
                out.print("Data is imported.");
            }
            else {
                out.print("Error saving data.");
            }
        }
        catch(Exception e){
            e.printStackTrace();
         }
    }
    else if ((sAction.equalsIgnoreCase("export"))&&(sFindTable.length()>0)&&(sFindDatabase.length()>0)){
        SyncTables tables = new SyncTables();
        tables.setVersion(getSQLTimeStamp(getSQLTime()));
        SyncTable table = new SyncTable();
        table.setName(sFindTable);
        table.setDatabase(sFindDatabase);
        SyncColumn column;
        SyncRow row;

        Connection connectionMy = null;
    	if(sFindDatabase.equalsIgnoreCase("openclinic")){
    		connectionMy = MedwanQuery.getInstance().getOpenclinicConnection();
    	}
    	else if(sFindDatabase.equalsIgnoreCase("admin")){
    		connectionMy = MedwanQuery.getInstance().getAdminConnection();
    	}
    	else if(sFindDatabase.equalsIgnoreCase("stats")){
    		connectionMy = MedwanQuery.getInstance().getStatsConnection();
    	}
        String sSelect = " SELECT * FROM "+sFindTable;
        PreparedStatement ps = connectionMy.prepareStatement(sSelect);
        ResultSet rs = ps.executeQuery();
        ResultSetMetaData rsmd = rs.getMetaData();
        String sShow = ",";

        for (int i=1;i<=rsmd.getColumnCount();i++){
            column = new SyncColumn();
            column.setName(rsmd.getColumnName(i));
            if (checkString(request.getParameter("Export"+column.getName())).equals("on")){
                sShow += i+",";
                if (checkString(request.getParameter("Id"+column.getName())).equals("on")){
                    column.setId("1");
                }
                if (rsmd.getColumnType(i)==java.sql.Types.CHAR){
                    column.setType("char");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.DATE){
                    column.setType("datetime");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.FLOAT){
                    column.setType("float");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.INTEGER){
                    column.setType("int");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.TIMESTAMP){
                    column.setType("datetime");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.VARCHAR){
                    column.setType("varchar");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.BIT){
                    column.setType("bit");
                }
                else if (rsmd.getColumnType(i)==java.sql.Types.LONGVARBINARY){
                    column.setType("bytes");
                }
                else if (rsmd.getColumnTypeName(i).equals("text")){
                    column.setType("text");
                }
                table.getColumns().add(column);
            }
        }
        out.print("Columns added<br>");
        String sData;
        StringBuffer buffer;
        DecimalFormat deci;
        deci = new DecimalFormat("000");
        int iCounter = 0;
        byte[] byteArray;

        while (rs.next()){
            row = new SyncRow();

            for (int i=1;i<=rsmd.getColumnCount();i++){
                if (sShow.indexOf(","+i+",")>-1){
                    sData = "";
                    if (rsmd.getColumnType(i)==java.sql.Types.CHAR){
                        sData = checkString(rs.getString(i));
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.DATE){
                        sData = ScreenHelper.getSQLDate(rs.getDate(i));
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.FLOAT){
                        sData = rs.getFloat(i)+"";
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.INTEGER){
                        sData = rs.getInt(i)+"";
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.TIMESTAMP){
                        sData = getSQLTimeStamp(rs.getTimestamp(i));
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.VARCHAR){
                        sData = checkString(rs.getString(i));
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.BIT){
                        sData = checkString(rs.getString(i));
                    }
                    else if (rsmd.getColumnType(i)==java.sql.Types.LONGVARBINARY){
                        try{
                            //sData = new String(rs.getBytes(i));

                            buffer = new StringBuffer();
                            byteArray = rs.getBytes(i);
                            for(int y=0; y<byteArray.length; y++){
                                buffer.append(deci.format((new Byte(byteArray[y]).intValue()+128)));
                            }
                            sData = buffer.toString();
                        }
                        catch (Exception e){
                            sData = "";
                        }
                    }
                    else if (rsmd.getColumnTypeName(i).equals("text")){
                         sData = checkString(rs.getString(i));
                    }

                    row.getData().add(sData);
                }
            }
            table.getRows().add(row);
            iCounter++;
        }
        rs.close();
        ps.close();
        connectionMy.close();
        out.print(iCounter+" rows added<br>");

        tables.getTables().add(table);

        /*File fileExport = new File(getConfigString("templateDirectory",ConfigdbConnection)+"/"+sFindExportFile);
        Writer writeExport = new BufferedWriter(new FileWriter(fileExport));

        writeExport.write(tables.toXML());
        writeExport.close();
         */
        XMLWriter writer = new XMLWriter(new FileWriter(MedwanQuery.getInstance().getConfigString("templateDirectory")+"/"+sFindExportFile) );
        writer.write(tables.toXML());
        writer.close();

        out.print("Data written to "+MedwanQuery.getInstance().getConfigString("templateDirectory")+"/"+sFindExportFile);
    }
%>

<form name="transactionForm" method="post">
    <%=writeTableHeader("Web.manage","import_export_table",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table border="0" width='100%' cellspacing="1" class="list">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">Import</td>
            <td class="admin2">
                <input type="text" name="FindUploadFile" size="100" class="normal" value="http://<%=request.getLocalName()+":"+request.getLocalPort()+request.getContextPath()+"/"%>">
                &nbsp;
                <input type="button" class="button" name="ButtonUpload" value="Upload" onclick="doSubmit('Import')">
            </td>
        </tr>
        <tr>
            <td class="admin" valign="top">Export</td>
            <td>
                <table cellspacing="1" border="0" width="100%">
                    <tr>
                        <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("Web.Manage.Counter","DB",sWebLanguage)%></td>
                        <td class="admin2">
                            <select name="FindDatabase" class="text" onchange="transactionForm.submit();">
                            <%
	                            SortedSet set = new TreeSet();
	    	                    set.add("openclinic");
	    	                    set.add("admin");
	    	                    set.add("stats");
                                //sorteer
                                Iterator it = set.iterator();
                                String sPool, sSelected;
                                while (it.hasNext()) {
                                    sSelected = "";
                                    sPool = (String)it.next();
                                    if ((sFindDatabase==null)||(sFindDatabase.trim().length()==0)) {
                                        sFindDatabase = sPool;
                                    }
                                    if (sPool.equals(sFindDatabase)){
                                        sSelected = " selected";
                                    }
                                    %>
                                   <option<%=sSelected%> name="<%=sPool%>"><%=sPool%></option>
                                    <%
                                }
                            %>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin2"><%=getTran("web.translations","table",sWebLanguage)%></td>
                        <td class="admin2">
                            <select name="FindTable" class="text" onchange="doSubmit('SelectTable');">
                                <option/>
                        <%
	                        Connection connectionMy = null;
	                    	if(sFindDatabase.equalsIgnoreCase("openclinic")){
	                    		connectionMy = MedwanQuery.getInstance().getOpenclinicConnection();
	                    	}
	                    	else if(sFindDatabase.equalsIgnoreCase("admin")){
	                    		connectionMy = MedwanQuery.getInstance().getAdminConnection();
	                    	}
	                    	else if(sFindDatabase.equalsIgnoreCase("stats")){
	                    		connectionMy = MedwanQuery.getInstance().getStatsConnection();
	                    	}
                            DatabaseMetaData dbmd = connectionMy.getMetaData();
                            String[] tableTypes = {"TABLE"};
                            ResultSet rs = dbmd.getTables(null,null,null,tableTypes);
                            String sTableName;
                            while (rs.next()){
                                sTableName = rs.getString("TABLE_NAME");
                                sSelected = "";
                                if (sTableName.equals(sFindTable)){
                                    sSelected = " selected";
                                }
                                %>
                                <option<%=sSelected%> value="<%=sTableName%>"><%=sTableName%></option>
                                <%
                            }
                        %>
                            </select>
                            &nbsp;
                            <input type="button" class="button" name="ButtonSelect" value="Select" onclick="doSubmit('SelectTable');">
                        </td>
                    </tr>
                    <%
                        if (sAction.equalsIgnoreCase("SelectTable")){
                        %>
                    <tr>
                        <td class="admin2"/>
                        <td class="admin2">
                            <table class="list" cellspacing="1">
                                <tr class="label">
                                    <td>Column</td><td>Export</td><td>Id</td>
                                </tr>
                        <%
                        String sSelect = " SELECT * FROM "+sFindTable+" WHERE 1 > 2 ";
                        PreparedStatement ps = connectionMy.prepareStatement(sSelect);
                        rs = ps.executeQuery();
                        ResultSetMetaData rsmd = rs.getMetaData();
                        String sClass = "";
                        for (int i=1;i<=rsmd.getColumnCount();i++){
                            if (sClass.equals("")){
                                sClass = "1";
                            }
                            else {
                                sClass = "";
                            }
                            %>
                                <tr class="list<%=sClass%>">
                                    <td><%=rsmd.getColumnName(i)%></td>
                                    <td><input type="checkbox" name="Export<%=rsmd.getColumnName(i)%>" checked></td>
                                    <td><input type="checkbox" name="Id<%=rsmd.getColumnName(i)%>"></td>
                                </tr>
                            <%
                        }
                        rs.close();
                        ps.close();
                        connectionMy.close();
                        %>
                            </table>
                        </td>
                    </tr>
                        <%
                        }
                    %>
                    <tr>
                        <td class="admin2" width="100" nowrap><%=getTran("web.manage.io","tofile",sWebLanguage)%>: <%=MedwanQuery.getInstance().getConfigString("templateDirectory")%></td>
                        <td class="admin2">
                            <input type="text" class="normal" name="FindExportFile" size="50" value="<%=sFindExportFile%>">
                            &nbsp;
                            <input type="button" class="button" name="ButtonExport" value="Export" onclick="doSubmit('Export');">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td colspan="2" class="admin2">
                <input class="button" type="button" name="cancel" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick='window.location.href="<c:url value='/main.do'/>?Page=system/menu.jsp";'>
            </td>
        </tr>
    </table>
    <input type="hidden" name="Action">
    <script>
    function doSubmit(sAction){
        transactionForm.Action.value = sAction;
        transactionForm.submit();
    }
    </script>
</form>