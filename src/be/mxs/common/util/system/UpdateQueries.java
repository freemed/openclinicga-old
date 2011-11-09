package be.mxs.common.util.system;

import java.net.MalformedURLException;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.Document;
import org.dom4j.io.SAXReader;

import be.mxs.common.util.db.MedwanQuery;

public class UpdateQueries {
	public static void updateQueries(javax.servlet.ServletContext application){
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "updatequeries.xml";
        if (Debug.enabled) Debug.println("login.jsp : processing update-queries file '" + sDoc + "'.");
        if (MedwanQuery.getInstance().getConfigInt("cacheDB") != 1) {
            // read xml file
            try {
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new URL(sDoc));
                Element queryElem;
                boolean queryIsExecuted;
                String sQuery;
                PreparedStatement ps = null;
                Connection conn = null;
                java.util.Iterator queriesIter = document.getRootElement().elementIterator("Query");
                while (queriesIter.hasNext()) {
                    queryElem = (Element) queriesIter.next();
                    try {
                        queryIsExecuted = MedwanQuery.getInstance().getConfigString(queryElem.attribute("id").getValue()).length() > 0;
                        if (!queryIsExecuted) {
                            // Select the right connection
                            if (queryElem.attribute("db").getValue().equalsIgnoreCase("ocadmin"))
                                conn = MedwanQuery.getInstance().getAdminConnection();
                            else if (queryElem.attribute("db").getValue().equalsIgnoreCase("openclinic"))
                                conn = MedwanQuery.getInstance().getOpenclinicConnection();

                            // execute query
                            if (conn != null) {
                                String sLocalDbType = conn.getMetaData().getDatabaseProductName();
                                if (queryElem.attribute("dbserver") == null || queryElem.attribute("dbserver").getValue().equalsIgnoreCase(sLocalDbType)) {
                                	sQuery = queryElem.getTextTrim().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin"));
	                                sQuery = queryElem.getTextTrim().replaceAll("@admin@", MedwanQuery.getInstance().getConfigString("admindbName","ocadmin"));
	                                if (sQuery.length() > 0) {
	                                    try {
	                                        ps = conn.prepareStatement(sQuery);
	                                        ps.execute();
	
	                                        // add configString query.id
	                                        MedwanQuery.getInstance().setConfigString(queryElem.attribute("id").getValue(), "executed : first time");
	                                        if (Debug.enabled)
	                                            Debug.println(queryElem.attribute("id").getValue() + " : executed");
	                                    }
	                                    catch (Exception e) {
	                                        if (e.getMessage().indexOf("There is already an object named") > -1) {
	                                            // table allready exists in DB, add configValue query.id
	                                            MedwanQuery.getInstance().setConfigString(queryElem.attribute("id").getValue(), "executed : table allready exists");
	                                            if (Debug.enabled)
	                                                Debug.println(queryElem.attribute("id").getValue() + " : table already exists");
	                                        } else {
	                                            // display query error
	                                            if (Debug.enabled)
	                                                Debug.println(queryElem.attribute("id").getValue() + " : ERROR : " + e.getMessage());
	                                        }
	                                    }
	                                    finally {
	                                        if (ps != null) ps.close();
	                                    }
	                                } else {
	                                    if (Debug.enabled) {
	                                        Debug.println(queryElem.attribute("id").getValue() + " : empty");
	                                    }
	                                }
                                }
                                conn.close();
                            } else {
                                if (Debug.enabled) {
                                    Debug.println("login.jsp : Query-element specifies an invalid database to use : " + queryElem.attribute("db").getValue());
                                }
                            }
                        } else {
                            if (Debug.enabled) {
                                Debug.println(queryElem.attribute("id").getValue() + " : allready executed");
                            }
                        }
                    }
                    catch (NullPointerException e) {
                        if (Debug.enabled)
                            Debug.println("login.jsp : Query-element does not have all required attributes.");
                    } catch (SQLException e) {
						e.printStackTrace();
					}
                }

                // tell application that update queries are processed
                application.setAttribute("updateQueriesProcessedDateOC", new java.util.Date());
            }
            catch (MalformedURLException me) {
                if (Debug.enabled) {
                    if (me.getMessage().indexOf("updatequeries.xml") > -1) {
                        Debug.println("login.jsp : Document '" + sDoc + "' not found.");
                    } else {
                        Debug.println("login.jsp : " + me.getMessage());
                        me.printStackTrace();
                    }
                }
            }
            catch (DocumentException de) {
                if (Debug.enabled) {
                    if (de.getMessage().indexOf("updatequeries.xml") > -1) {
                        Debug.println("login.jsp : Document '" + sDoc + "' not found.");
                    } else {
                        Debug.println("login.jsp : " + de.getMessage());
                        de.printStackTrace();
                    }
                }
            }
        }
	}
}
