
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- PAD -------------------------------------------------------------------------------------
    private String pad(String colContent, int colWidth, int maxColWidth){
        if(colWidth > maxColWidth) colWidth = maxColWidth;

        if(colContent.length() > colWidth){
            colContent = colContent.substring(0,colWidth);
        }
        else{
            for (int i=colContent.length(); i<colWidth; i++){
                colContent+= "&nbsp;";
            }
        }

        return colContent;
    }

    //--- INNER CLASS COLUMN ----------------------------------------------------------------------
    private class Column{
        String name = "";
        int type = 0;
        int width = 0;

        // constructor
        public Column(String name, int type, int width){
            this.name = name;
            this.type = type;
            this.width = width;

            if (this.width<=name.length()){
                this.width = name.length()+1;
            }
        }
    }
%>
<%
    String colHeader = "", colSeparator = "|";
    StringBuffer result = new StringBuffer();

    int maxColWidth = 10; // default
    try{
        maxColWidth = Integer.parseInt(request.getParameter("maxColWidth"));
    }
    catch(Exception e){
        // nothing
    }

    int maxRows = 100; // default
    try{
        maxRows = Integer.parseInt(request.getParameter("maxRows"));
    }
    catch(Exception e){
        // nothing
    }

    String db      = checkString(request.getParameter("db"));
    String sqlText = checkString(request.getParameter("sqlText"));

    if (db.length() > 0 && sqlText.length() > 0){
        // execute the sql statement
        try {
        	Statement ps;
        	Connection connection = null;
        	if(db.equalsIgnoreCase("openclinic")){
        		connection = MedwanQuery.getInstance().getOpenclinicConnection();
        	}
        	else if(db.equalsIgnoreCase("admin")){
        		connection = MedwanQuery.getInstance().getAdminConnection();
        	}
        	else if(db.equalsIgnoreCase("stats")){
        		connection = MedwanQuery.getInstance().getStatsConnection();
        	}
        	
			if(sqlText.indexOf(";")>-1){
	            ps = connection.createStatement();
	            String[] s = sqlText.split(";");
				for(int n=0;n<s.length;n++){
					ps.addBatch(s[n]);
				}
	            ps.executeBatch();
			}
			else {
				ps = connection.prepareStatement(sqlText);
				((PreparedStatement)ps).execute();
			}

            if (sqlText.startsWith("update") || ps.getResultSet()==null){
            	ps.close();
            	connection.close();
                result.append("This query does not return any rows");
            }
            else {
                // get info on column structure
                ResultSet rs = ps.getResultSet();
                Vector columns = new Vector();
                Column column;

                for (int n=1; n<=rs.getMetaData().getColumnCount(); n++){
                    int displaySizeLimited = rs.getMetaData().getColumnDisplaySize(n);
                    if(displaySizeLimited > maxColWidth) displaySizeLimited = maxColWidth;

                    column = new Column(rs.getMetaData().getColumnName(n),rs.getMetaData().getColumnType(n),displaySizeLimited);
                    columns.add(column);
                    colHeader+= pad(column.name,column.width,maxColWidth)+colSeparator;
                }

                // add line beneath colheader
                colHeader+= "<BR/>"+repeat("=",colHeader.length()); // —

                int counter = 0;
                SimpleDateFormat fullDateFormat = ScreenHelper.fullDateFormatSS;

                while (rs.next()){
                    result.append("<br/>");

                    for (int n=0; n<columns.size(); n++){
                        column = (Column)columns.get(n);

                        if (rs.getObject(column.name)==null){
                            result.append(pad("null",column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.BINARY){
                            result.append(pad(new String(rs.getBytes(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.LONGVARBINARY){
                            result.append(pad(new String(rs.getBytes(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.VARBINARY){
                            result.append(pad(new String(rs.getBytes(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.LONGVARCHAR){
                            result.append(pad(rs.getString(column.name),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.VARCHAR){
                            result.append(pad(rs.getString(column.name),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.CHAR){
                            result.append(pad(rs.getString(column.name),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.BIT){
                            result.append(pad(Integer.toString(rs.getInt(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.INTEGER){
                            result.append(pad(Integer.toString(rs.getInt(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.FLOAT){
                            result.append(pad(Float.toString(rs.getFloat(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.NUMERIC){
                            result.append(pad(Float.toString(rs.getFloat(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.DATE){
                            result.append(pad(fullDateFormat.format(rs.getDate(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.TIME){
                            result.append(pad(fullDateFormat.format(rs.getDate(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                        else if (column.type==java.sql.Types.TIMESTAMP){
                            result.append(pad(fullDateFormat.format(rs.getDate(column.name)),column.width,maxColWidth)+colSeparator);
                        }
                    }

                    if (counter >= maxRows){
                        break;
                    }

                    counter++;
                }
                rs.close();
                ps.close();
                connection.close();

                // add number of found records
                result.append("<br/><br/>");
                if (counter >= maxRows){
                    result.append(counter+" records displayed. More records found.");
                }
                else{
                    result.append(counter+" records found");
                }
            }
        }
        catch(Exception e){
            result = new StringBuffer(checkString(e.getMessage()));
        }
    }
%>
<form name="sqlForm" method="post">
    <%=writeTableHeader("Web.Occup","medwan.common.execute-sql",sWebLanguage,"doBack();")%>
    <table width="100%" cellspacing="1" class="list">
        <%-- available databases dropdown --%>
        <tr>
            <td width="<%=sTDAdminWidth%>" class="admin">Database</td>
            <td class="admin2">
                <select name="db" class="text">
                    <%
                        SortedSet set = new TreeSet();
	                    set.add("openclinic");
	                    set.add("admin");
	                    set.add("stats");

                        // sort
                        String sPool, sSelected;
                        Iterator it = set.iterator();
                        while (it.hasNext()) {
                            sPool = (String) it.next();

                            if (sPool.equals(db)) {
                                sSelected = " selected";
                            } else {
                                sSelected = "";
                            }

                    %><option<%=sSelected%> name="<%=sPool%>"><%=sPool%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
        <%-- SQLTEXT (query) --%>
        <tr>
            <td class="admin">SQL</td>
            <td class="admin2"><textarea class="normal" name="sqlText" onKeyup='resizeTextarea(this,10);' cols="100"><%=sqlText%></textarea></td>
        </tr>
        <%-- RESULT --%>
        <tr>
            <td class="admin">Result</td>
            <td><div style="padding-left:5px;background-color: #DEEAFF;"><div id="sr" style="background-color: white;border: 1px #6CA0D9 solid;border-right: 1px solid #DDEDFF;border-bottom: 1px solid #DDEDFF;height:200px;overflow:scroll;white-space:nowrap;font-size:11px;font-family:'courier new'" name="sqlResult"><%=colHeader+result%></div></div></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%-- maxColWidth selector --%>
                <span>Column width : </span>
                <select name="maxColWidth" class="text">
                    <option value="10" <%=(maxColWidth==10?" SELECTED":"")%>>10</option>
                    <option value="25" <%=(maxColWidth==25?" SELECTED":"")%>>25</option>
                    <option value="50" <%=(maxColWidth==50?" SELECTED":"")%>>50</option>
                    <option value="100" <%=(maxColWidth==100?" SELECTED":"")%>>100</option>
                    <option value="255" <%=(maxColWidth==255?" SELECTED":"")%>>255</option>
                </select>&nbsp;
                <%-- maxRows selector --%>
                <span>Max results : </span>
                <select name="maxRows" class="text">
                    <option value="10" <%=(maxRows==10?" SELECTED":"")%>>10</option>
                    <option value="50" <%=(maxRows==50?" SELECTED":"")%>>50</option>
                    <option value="100" <%=(maxRows==100?" SELECTED":"")%>>100</option>
                    <option value="250" <%=(maxRows==250?" SELECTED":"")%>>250</option>
                    <option value="500" <%=(maxRows==500?" SELECTED":"")%>>500</option>
                </select>
            </td>
        </tr>
        <%-- BUTTONS ROW --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <%-- buttons --%>
            <input type="button" class="button" name="executeButton" value="<%=getTranNoLink("Web.Occup","medwan.common.execute",sWebLanguage)%>" onClick="executeQuery();"/>
            <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearTAs();"/>
            <input type="button" class="button" name="backButton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onClick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
</form>
<script>
  document.getElementById("sr").style.width=screen.width-<%=sTDAdminWidth%>;
  function executeQuery(){
    if(sqlForm.sqlText.value.length > 0){
      sqlForm.executeButton.disabled = true;
      sqlForm.clearButton.disabled = true;
      sqlForm.backButton.disabled = true;

      sqlForm.submit();
    }
  }

  function clearTAs(){
    sqlForm.sqlText.value = "";
    sqlForm.sqlResult.value = "";
    sqlForm.sqlText.focus();
  }

  function doBack(){
    window.location.href = '<c:url value='/main.do'/>?Page=system/menu.jsp';
  }
</script>