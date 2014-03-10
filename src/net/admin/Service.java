package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.db.ObjectCacheFactory;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.pharmacy.ServiceStock;
import be.openclinic.adt.Bed;

import java.sql.*;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;

public class Service {

    public String type;
    public String code="";
    public Vector labels=new Vector();
    public String address="";
    public String city="";
    public String zipcode="";
    public String country="";
    public String telephone="";
    public String fax="";
    public String email="";
    public String comment="";
    public String parentcode="";
    public String showOrder="";
    public String language="";
    public String inscode="";
    public String contract="";
    public String contracttype="";
    public String contractdate="";
    public String portal_email;
    public String wicket="0";
    public String inactive="0";
    public String defaultContext="";
    public String defaultServiceStockUid;

    public String contactperson="";
    public String contactaddress;
    public String contactzipcode;
    public String contactcity;
    public String contactcountry;
    public String contacttelephone;
    public String contactfax;
    public String contactemail;

    public String code1="";
    public String code2="";
    public String code3="";
    public String code4="";
    public String code5="";
    public int totalbeds=0;

    public Date updatetime;
    public String updateuserid;
    public String costcenter;
    public String performeruid;
    public String stayprestationuid;
    
    public String acceptsVisits="0";

   public Service(){
        type = "";
        code = "";
        labels = new Vector();
        address = "";
        city = "";
        zipcode = "";
        country = "";
        telephone = "";
        fax = "";
        email = "";
        comment = "";
        parentcode = "";
        showOrder = "";
        language = "";
        inscode = "";
        contract = "";
        contracttype = "";
        contactperson = "";
        contractdate = "";
        portal_email = "";
        defaultContext = "";
        defaultServiceStockUid = "";

        contactaddress = "";
        contactzipcode = "";
        contactcity = "";
        contactcountry = "";
        contacttelephone = "";
        contactfax = "";
        contactemail = "";

        code1 = "";
        code2 = "";
        code3 = "";
        code4 = "";
        code5 = "";

        wicket = "0";
        inactive = "0";
        totalbeds=0;
        costcenter="";
        acceptsVisits="0";
        stayprestationuid="";
        //updatetime;
        //updateuserid;
    }

    //--- GET LABEL -------------------------------------------------------------------------------
    public String getLabel(String language){
        Label label;
        for (int n=0;n<labels.size();n++){
            label = (Label)labels.elementAt(n);
            if (label.language.equalsIgnoreCase(language)){
                return label.value;
            }
        }
        return "";
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public void delete(Connection connection){
        if (this.code!=null && this.code.length()>0){
            try {
                PreparedStatement ps = connection.prepareStatement("delete from Services where serviceid=?");
                ps.setString(1,this.code);
                ps.execute();
                ps.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }
            MedwanQuery.getInstance().services.remove(this.code);
        }
    }

    public void store(){
    	try {
        		Connection conn = MedwanQuery.getInstance().getAdminConnection();
	          PreparedStatement ps = conn.prepareStatement("delete from Services where serviceid='"+this.code+"'");
	          ps.execute();
	          ps.close();
	          ObjectCacheFactory.getInstance().resetObjectCache();
	          String sSelect = "INSERT INTO Services (serviceid, address, city, zipcode, country,"+
                    "  telephone, fax, email, comment, servicelanguage, serviceparentid, serviceorder,"+
                    "  inscode, contract, contracttype, contactperson, contractdate,"+
                    "  contactaddress, contactzipcode, contactcity, contactcountry,"+
                    "  contacttelephone, contactfax, contactemail, portal_email, wicket, defaultcontext,"+
                    "  defaultservicestockuid, code1, code2, code3, code4, code5, updatetime,totalbeds,inactive,costcenter,performeruid,acceptsVisits,stayprestationuid)"+
                    " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

	          ps = conn.prepareStatement(sSelect);
	          ps.setString(1,this.code.toUpperCase());
	          ps.setString(2,this.address);
	          ps.setString(3,this.city);
	          ps.setString(4,this.zipcode);
	          ps.setString(5,this.country);
	          ps.setString(6,this.telephone);
	          ps.setString(7,this.fax);
	          ps.setString(8,this.email);
	          ps.setString(9,this.comment);
	          ps.setString(10,this.language);
	          ps.setString(11,this.parentcode);
	          ps.setString(12,this.showOrder);
	          ps.setString(13,this.inscode);
	          ps.setString(14,this.contract);
	          ps.setString(15,this.contracttype);
	          ps.setString(16,this.contactperson);
	          ScreenHelper.setSQLDate(ps,17,this.contractdate);
	          ps.setString(18,this.contactaddress);
	          ps.setString(19,this.contactzipcode);
	          ps.setString(20,this.contactcity);
	          ps.setString(21,this.contactcountry);
	          ps.setString(22,this.contacttelephone);
	          ps.setString(23,this.contactfax);
	          ps.setString(24,this.contactemail);
	          ps.setString(25,this.portal_email);
	          ps.setString(26,this.wicket);
	          ps.setString(27,this.defaultContext);
	          ps.setString(28,this.defaultServiceStockUid);
	
	          ps.setString(29,this.code1);
	          ps.setString(30,this.code2);
	          ps.setString(31,this.code3);
	          ps.setString(32,this.code4);
	          ps.setString(33,this.code5);
	
	          ps.setTimestamp(34,new Timestamp(new java.util.Date().getTime()));
	          ps.setInt(35,this.totalbeds);
	          ps.setString(36,this.inactive);
	          ps.setString(37,this.costcenter);
	          ps.setString(38,this.performeruid);
	          ps.setString(39,this.acceptsVisits);
	          ps.setString(40,this.stayprestationuid);
	          ps.executeUpdate();
	          if(ps!=null) ps.close();
	          conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    //--- SAVE TO DB (copied from AdminService ------------------------------------------------------------------------------
    public boolean saveToDB(String sWorkID, Connection connection) {
        boolean bReturn = true;

        try {
            PreparedStatement ps;
            ResultSet rs;

            for (int i=0; (i<this.labels.size())&&(bReturn);i++) {
                ((Label)(this.labels.elementAt(i))).saveToDB("Service",this.code);
            }

            if ((bReturn)&&(this.type.trim().length()>0)&&(this.code.trim().length()>0)) {
                // adminservices
                String sType = this.type.substring(0,1).toUpperCase();
                String sSelect;

                if ((sWorkID!=null)&&(sWorkID.trim().length()>0)) {
                    sSelect = "SELECT workid FROM AdminServices WHERE workid = ? AND servicetype = ?";
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sWorkID));
                    ps.setString(2,sType);
                    rs = ps.executeQuery();
                    if (rs.next())  {
                        sSelect = "UPDATE AdminServices SET serviceid = ?, updatetime = ?, updateserverid = "+MedwanQuery.getInstance().getConfigInt("serverId")+
                                  " WHERE workid = ? AND servicetype = ?";
                        rs.close();
                        ps.close();
                        ps = connection.prepareStatement(sSelect);
                        ps.setString(1,this.code.toUpperCase());
                        ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
                        ps.setInt(3,Integer.parseInt(sWorkID));
                        ps.setString(4,sType);
                        ps.executeUpdate();
                        if (ps!=null)ps.close();
                    }
                    else  {
                        sSelect = "INSERT INTO AdminServices (workid, serviceid, servicetype, updatetime,updateserverid)"+
                                  " VALUES (?,?,?,?,"+MedwanQuery.getInstance().getConfigInt("serverId")+")";
                        rs.close();
                        ps.close();
                        ps = connection.prepareStatement(sSelect);
                        ps.setInt(1,Integer.parseInt(sWorkID));
                        ps.setString(2,this.code.toUpperCase());
                        ps.setString(3,sType);
                        ps.setTimestamp(4,new java.sql.Timestamp(new java.util.Date().getTime()));
                        ps.executeUpdate();
                        if (ps!=null)ps.close();
                    }

                }

                // services
                sSelect = "SELECT serviceid FROM Services WHERE UPPER(serviceid) = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setString(1,this.code.toUpperCase());
                rs = ps.executeQuery();
                if (rs.next()) {
                    Hashtable hSelect = new Hashtable();
                    if(this.address.trim().length()>0) hSelect.put(" address = ? ",this.address);
                    if(this.city.trim().length()>0) hSelect.put(" city = ? ",this.city);
                    if(this.zipcode.trim().length()>0) hSelect.put(" zipcode = ? ",this.zipcode);
                    if(this.country.trim().length()>0) hSelect.put(" country = ? ",this.country);
                    if(this.telephone.trim().length()>0) hSelect.put(" telephone = ? ",this.telephone);
                    if(this.fax.trim().length()>0) hSelect.put(" fax = ? ",this.fax);
                    if(this.email.trim().length()>0) hSelect.put(" email = ? ",this.email);
                    if(this.comment.trim().length()>0) hSelect.put(" comment = ? ",this.comment);
                    if(this.parentcode.trim().length()>0) hSelect.put(" serviceparentid = ? ",this.parentcode);
                    if(this.showOrder.trim().length()>0) hSelect.put(" serviceorder = ? ",this.showOrder);
                    if(this.language.trim().length()>0) hSelect.put(" servicelanguage = ? ",this.language);
                    if(this.inscode.trim().length()>0) hSelect.put(" inscode = ? ",this.inscode);
                    if(this.contract.trim().length()>0) hSelect.put(" contract = ? ",this.contract);
                    if(this.contracttype.trim().length()>0) hSelect.put(" contracttype = ? ",this.contracttype);
                    if(this.contactperson.trim().length()>0) hSelect.put(" contactperson = ? ",this.contactperson);
                    if(this.contractdate.trim().length()>0) hSelect.put(" contractdate = ? ",this.contractdate);
                    if(this.portal_email.trim().length()>0) hSelect.put(" portal_email = ? ",this.portal_email);
                    if(this.wicket.trim().length()>0) hSelect.put(" wicket = ? ",this.wicket);
                    if(this.inactive.trim().length()>0) hSelect.put(" inactive = ? ",this.inactive);
                    if(this.defaultContext.trim().length()>0) hSelect.put(" defaultcontext = ? ",this.defaultContext);
                    if(this.defaultServiceStockUid.trim().length()>0) hSelect.put(" defaultservicestockuid = ? ",this.defaultServiceStockUid);

                    if(this.contactaddress.trim().length()>0) hSelect.put(" contactaddress = ? ",this.contactaddress);
                    if(this.contactzipcode.trim().length()>0) hSelect.put(" contactzipcode = ? ",this.contactzipcode);
                    if(this.contactcity.trim().length()>0) hSelect.put(" contactcity = ? ",this.contactcity);
                    if(this.contactcountry.trim().length()>0) hSelect.put(" contactcountry = ? ",this.contactcountry);
                    if(this.contacttelephone.trim().length()>0) hSelect.put(" contacttelephone = ? ",this.contacttelephone);
                    if(this.contactfax.trim().length()>0) hSelect.put(" contactfax = ? ",this.contactfax);
                    if(this.contactemail.trim().length()>0) hSelect.put(" contactemail = ? ",this.contactemail);

                    if(this.code1.trim().length()>0) hSelect.put(" code1 = ? ",this.code1);
                    if(this.code2.trim().length()>0) hSelect.put(" code2 = ? ",this.code2);
                    if(this.code3.trim().length()>0) hSelect.put(" code3 = ? ",this.code3);
                    if(this.code4.trim().length()>0) hSelect.put(" code4 = ? ",this.code4);
                    if(this.code5.trim().length()>0) hSelect.put(" code5 = ? ",this.code5);
                    if(this.code5.trim().length()>0) hSelect.put(" code5 = ? ",this.code5);
                    if(this.acceptsVisits.trim().length()>0) hSelect.put(" acceptsVisits = ? ",this.acceptsVisits);

                    if(this.costcenter.trim().length()>0) hSelect.put(" costcenter = ? ",this.costcenter);
                    if(this.performeruid.trim().length()>0) hSelect.put(" performeruid = ? ",this.performeruid);
                    if(this.stayprestationuid.trim().length()>0) hSelect.put(" stayprestationuid = ? ",this.stayprestationuid);

                    if (hSelect.size()>0) {
                        sSelect = "UPDATE Services SET ";
                        Enumeration e = hSelect.keys();
                        boolean initialized=false;
                        String sKey;
                        while (e.hasMoreElements()){
                            sKey = (String) e.nextElement();
                            sSelect += (initialized?",":"")+sKey;
                            initialized =true;
                        }


                        sSelect += (initialized?",":"")+" updatetime = ?";
                        sSelect += " WHERE serviceid = ? ";
                        rs.close();
                        ps.close();
                        ps = connection.prepareStatement(sSelect);

                        int iIndex = 1;
                        e = hSelect.keys();
                        String sValue;
                        while (e.hasMoreElements()){
                            sKey = (String) e.nextElement();
                            sValue = (String)hSelect.get(sKey);
                            if (sKey.equalsIgnoreCase(" contractdate = ? ")){
                                ScreenHelper.setSQLDate(ps,iIndex,sValue);
                            }
                            else if (sKey.equalsIgnoreCase(" wicket = ? ")){
                                ps.setInt(iIndex,Integer.parseInt(sValue));
                            }
                            else if (sKey.equalsIgnoreCase(" acceptsVisits = ? ")){
                                ps.setInt(iIndex,Integer.parseInt(sValue));
                            }
                            else if (sKey.equalsIgnoreCase(" inactive = ? ")){
                                ps.setInt(iIndex,Integer.parseInt(sValue));
                            }
                            else {
                                ps.setString(iIndex,sValue);
                            }
                            iIndex++;
                        }

                        // updatetime
                        ps.setTimestamp(iIndex,new Timestamp(new java.util.Date().getTime()));
                        iIndex++;

                        // serviceid
                        ps.setString(iIndex,this.code);

                        ps.executeUpdate();
                        if(ps!=null) ps.close();
                    }
                }
                else {
                    sSelect = "INSERT INTO Services (serviceid, address, city, zipcode, country,"+
                              "  telephone, fax, email, comment, servicelanguage, serviceparentid, serviceorder,"+
                              "  inscode, contract, contracttype, contactperson, contractdate,"+
                              "  contactaddress, contactzipcode, contactcity, contactcountry,"+
                              "  contacttelephone, contactfax, contactemail, portal_email, wicket, defaultcontext,"+
                              "  defaultservicestockuid, code1, code2, code3, code4, code5, updatetime,totalbeds,inactive,costcenter,performeruid,acceptsVisits,stayprestationuid)"+
                              " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setString(1,this.code.toUpperCase());
                    ps.setString(2,this.address);
                    ps.setString(3,this.city);
                    ps.setString(4,this.zipcode);
                    ps.setString(5,this.country);
                    ps.setString(6,this.telephone);
                    ps.setString(7,this.fax);
                    ps.setString(8,this.email);
                    ps.setString(9,this.comment);
                    ps.setString(10,this.language);
                    ps.setString(11,this.parentcode);
                    ps.setString(12,this.showOrder);
                    ps.setString(13,this.inscode);
                    ps.setString(14,this.contract);
                    ps.setString(15,this.contracttype);
                    ps.setString(16,this.contactperson);
                    ScreenHelper.setSQLDate(ps,17,this.contractdate);
                    ps.setString(18,this.contactaddress);
                    ps.setString(19,this.contactzipcode);
                    ps.setString(20,this.contactcity);
                    ps.setString(21,this.contactcountry);
                    ps.setString(22,this.contacttelephone);
                    ps.setString(23,this.contactfax);
                    ps.setString(24,this.contactemail);
                    ps.setString(25,this.portal_email);
                    ps.setString(26,this.wicket);
                    ps.setString(27,this.defaultContext);
                    ps.setString(28,this.defaultServiceStockUid);

                    ps.setString(29,this.code1);
                    ps.setString(30,this.code2);
                    ps.setString(31,this.code3);
                    ps.setString(32,this.code4);
                    ps.setString(33,this.code5);

                    ps.setTimestamp(34,new Timestamp(new java.util.Date().getTime()));
                    ps.setInt(35,this.totalbeds);
                    ps.setString(36,this.inactive);
                    ps.setString(37,this.costcenter);
                    ps.setString(38,this.performeruid);
                    ps.setString(39,this.acceptsVisits);
                    ps.setString(40,this.stayprestationuid);
                    ps.executeUpdate();
                    if(ps!=null) ps.close();
                }
            }
        }
        catch(SQLException e){
        	Debug.printStackTrace(e);
        }
        MedwanQuery.getInstance().services.put(this.code,this);

        return bReturn;
    }

    //--- GET SERVICE -----------------------------------------------------------------------------
    public static Service getService(String sServiceID){
        if(sServiceID==null){
            sServiceID="NONEXISTING";
        }
        Service service=(Service) MedwanQuery.getInstance().services.get(sServiceID);
        if(service==null){
        	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            try {
               // PreparedStatement ps;
               // ResultSet rs;
                PreparedStatement ps = ad_conn.prepareStatement(" SELECT * FROM Services WHERE serviceid = ? ");
                ps.setString(1,sServiceID);
    //leak in rs 0,2 sec
                ResultSet rs = ps.executeQuery();
                if (rs.next()){
                    service = new Service();

                    service.type = "";
                    service.code = ScreenHelper.checkString(rs.getString("serviceid"));
                    service.labels = service.getServiceLabels();
                    service.address = ScreenHelper.checkString(rs.getString("address"));
                    service.city = ScreenHelper.checkString(rs.getString("city"));
                    service.zipcode = ScreenHelper.checkString(rs.getString("zipcode"));
                    service.country = ScreenHelper.checkString(rs.getString("country"));
                    service.telephone = ScreenHelper.checkString(rs.getString("telephone"));
                    service.fax = ScreenHelper.checkString(rs.getString("fax"));
                    service.email = ScreenHelper.checkString(rs.getString("email"));
                    service.comment = ScreenHelper.checkString(rs.getString("comment"));
                    service.parentcode = ScreenHelper.checkString(rs.getString("serviceparentid"));
                    service.showOrder = ScreenHelper.checkString(rs.getString("serviceorder"));
                    service.language = ScreenHelper.checkString(rs.getString("servicelanguage"));
                    service.inscode = ScreenHelper.checkString(rs.getString("inscode"));
                    service.contract = ScreenHelper.checkString(rs.getString("contract"));
                    service.contracttype = ScreenHelper.checkString(rs.getString("contracttype"));
                    service.contactperson = ScreenHelper.checkString(rs.getString("contactperson"));
                    service.contractdate = rs.getDate("contractdate")!=null?new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("contractdate")):null;
                    service.contactaddress = ScreenHelper.checkString(rs.getString("contactaddress"));
                    service.contactzipcode = ScreenHelper.checkString(rs.getString("contactzipcode"));
                    service.contactcity = ScreenHelper.checkString(rs.getString("contactcity"));
                    service.contactcountry = ScreenHelper.checkString(rs.getString("contactcountry"));
                    service.contacttelephone = ScreenHelper.checkString(rs.getString("contacttelephone"));
                    service.contactfax = ScreenHelper.checkString(rs.getString("contactfax"));
                    service.contactemail = ScreenHelper.checkString(rs.getString("contactemail"));
                    service.portal_email = ScreenHelper.checkString(rs.getString("portal_email"));
                    service.wicket = ScreenHelper.checkString(rs.getString("wicket"));
                    service.inactive = ScreenHelper.checkString(rs.getString("inactive"));
                    service.defaultContext = ScreenHelper.checkString(rs.getString("defaultcontext"));
                    service.defaultServiceStockUid = ScreenHelper.checkString(rs.getString("defaultservicestockuid"));
                    
                    // codes
                    service.code1 = rs.getString("code1");
                    service.code2 = rs.getString("code2");
                    service.code3 = rs.getString("code3");
                    service.code4 = rs.getString("code4");
                    service.code5 = rs.getString("code5");

                    service.updatetime = rs.getDate("updatetime");
                    service.updateuserid = rs.getString("updateuserid");
                    service.totalbeds=rs.getInt("totalbeds");
                    service.costcenter=rs.getString("costcenter");
                    service.performeruid=rs.getString("performeruid");
                    service.acceptsVisits=rs.getString("acceptsVisits");
                    service.stayprestationuid=rs.getString("stayprestationuid");
                }
                rs.close();
                ps.close();
            }
            catch (Exception e){
                e.printStackTrace();
            }
            if(service!=null){
                MedwanQuery.getInstance().services.put(sServiceID,service);
            }
            try {
				ad_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }
        return service;
    }

    //--- GET PARENT IDS --------------------------------------------------------------------------
    public static Vector getParentIds(String childId){
        HashSet parentIds = new HashSet();
        String parentId = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

        try{
            Service service = Service.getService(childId);
            if(service!=null){
                parentId = service.parentcode;
                if(parentId!=null && parentId.trim().length()>0){
                    parentIds.add(parentId);
                    parentIds.addAll(getParentIds(parentId)); // recursion
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        // Set to Vector
        Iterator iter = parentIds.iterator();
        Vector ids = new Vector();
        while(iter.hasNext()){
            ids.add(iter.next());
        }

        Collections.reverse(ids);

        return ids;
    }

    public static String getChildIdsAsString(String parentId){
    	String childids="'"+parentId+"'";
    	Vector children = getChildIds(parentId);
    	for(int n=0;n<children.size();n++){
    		if(childids.length()>0){
    			childids+=",";
    		}
    		childids+="'"+children.elementAt(n)+"'";
    	}
    	return childids;
    }
    //--- GET CHILD IDS ---------------------------------------------------------------------------
    public static Vector getChildIds(String parentId){
        HashSet childIds = new HashSet();
        String childId = "";
        PreparedStatement ps = null;
        ResultSet rs = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            if(childId!=null && childId.trim().length()>0){
                childIds.add(childId);
            }

            String sSelect = "SELECT serviceid FROM Services WHERE serviceparentid = ?";
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,parentId);

            rs = ps.executeQuery();
            while(rs.next()){
                childId = rs.getString("serviceid");

                if(childId!=null && childId.trim().length()>0){
                    childIds.add(childId);
                    childIds.addAll(getChildIds(childId)); // recursion
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                ad_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        // Set to Vector
        Iterator iter = childIds.iterator();
        Vector ids = new Vector();
        while(iter.hasNext()){
            ids.add(iter.next());
        }

        return ids;
    }

    public static Vector getServiceIDsByParentID(String sCode){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT serviceid FROM Services WHERE serviceparentid = ?";

        Vector vServiceIDs = new Vector();
        String sServiceID = "";


    	Connection lad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = lad_conn.prepareStatement(sSelect);
            ps.setString(1,sCode);
            rs = ps.executeQuery();

            while(rs.next()){
                sServiceID = ScreenHelper.checkString(rs.getString("serviceid"));
                vServiceIDs.addElement(sServiceID);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                lad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vServiceIDs;
    }

    public static Hashtable getMultipleServiceIDsByText(String sWebLanguage,String sOldText){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hServiceIDs = new Hashtable();
        String sID,sLabel;

        String sTmp = "", sTmpText = "";

        if (sOldText.indexOf(" ") > 0){
            while (sOldText.indexOf(" ") > -1){
                sTmp = sOldText.substring(0,sOldText.indexOf(" "));
                sTmpText += " AND (OC_LABEL_ID = '"+sTmp.trim().toLowerCase()+"' OR OC_LABEL_ID LIKE '"+sTmp.trim()+".%' "
                           +" OR "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE")+" LIKE '%"+sTmp.trim().toLowerCase()+"%') AND OC_LABEL_LANGUAGE = ?";
                sOldText = sOldText.substring(sOldText.indexOf(" ")+1);
            }
            sTmpText += " AND (OC_LABEL_ID = '"+sOldText.trim().toLowerCase()+"' OR OC_LABEL_ID LIKE '"+sOldText.trim()+".%' "
                       +" OR "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE")+" LIKE '%"+sOldText.trim().toLowerCase()+"%') AND OC_LABEL_LANGUAGE = ?";

        }
        else {
            sTmpText = " AND (OC_LABEL_ID = '"+sOldText.trim().toLowerCase()+"' OR OC_LABEL_ID LIKE '"+sOldText.trim()+".%' "
                      +" OR "+ ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE")+" like '%"+sOldText.trim().toLowerCase()+"%') AND OC_LABEL_LANGUAGE = ?";
        }

        String sQuery = "SELECT * FROM OC_LABELS WHERE OC_LABEL_TYPE='Service' "+sTmpText+" ORDER BY OC_LABEL_ID";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery,ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
            ps.setString(1,sWebLanguage);
            rs = ps.executeQuery();

            while(rs.next()){
                sID = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));
                sLabel = ScreenHelper.checkString(rs.getString("OC_LABEL_VALUE"));
                hServiceIDs.put(sID,sLabel);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return hServiceIDs;
    }

    public static Vector getServiceIDsByText(String sWebLanguage, String sText){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vServiceIDs = new Vector();
        String sID;


        String sQuery = "SELECT OC_LABEL_TYPE,OC_LABEL_ID FROM OC_LABELS"+
                        " WHERE "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_TYPE")+" = 'service'"+
                        "  AND "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_LANGUAGE")+" LIKE ?"+
                        "  AND ("+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID")+" LIKE ?"+
                        "   OR "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_ID")+" LIKE ?"+
                        "   OR "+ScreenHelper.getConfigParam("lowerCompare","OC_LABEL_VALUE")+" LIKE ?"+
                        "  )";

        Connection loc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = loc_conn.prepareStatement(sQuery);
            ps.setString(1,"%"+sWebLanguage.toLowerCase()+"%");
            ps.setString(2,"%"+sText.toLowerCase()+"%");
            ps.setString(3,"%"+sText.toLowerCase()+".%");
            ps.setString(4,"%"+sText.toLowerCase()+"%");
            rs = ps.executeQuery();

            while(rs.next()){
                sID = ScreenHelper.checkString(rs.getString("OC_LABEL_ID"));

                vServiceIDs.addElement(sID);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                loc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vServiceIDs;
    }

    public static Vector getTopServiceIDs(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vServiceIDs = new Vector();
        String sID;

        String sSelect = "SELECT serviceid FROM Services"+
                         " WHERE serviceparentid IS NULL OR serviceparentid = ''";

    	Connection lad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = lad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                sID = ScreenHelper.checkString(rs.getString("serviceid"));
                vServiceIDs.addElement(sID);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                lad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vServiceIDs;
    }


    //--- GET ACTIVE SERVICE STOCKS ---------------------------------------------------------------
    // return vector containing active ServiceStocks belonging to the specified Service and its subservices
    public static Vector getActiveServiceStocks(String serviceId){
        Vector serviceStocks = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_STOCK_SERVERID, OC_STOCK_OBJECTID FROM OC_SERVICESTOCKS"+
                             "  WHERE (OC_STOCK_END > ? OR OC_STOCK_END IS NULL)";

            if(serviceId.length() > 0){
                // search all service and its child-services
                Vector childIds = Service.getChildIds(serviceId);
                String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
                if(sChildIds.length() > 0){
                    sSelect+= " AND OC_STOCK_SERVICEUID IN ("+sChildIds+") AND ";
                }
                else{
                    sSelect+= " AND OC_STOCK_SERVICEUID IN ('') AND ";
                }
            }

            // remove last AND if any
            if(sSelect.indexOf("AND ")>0){
                sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
            }

            ps = oc_conn.prepareStatement(sSelect);
            ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()));

            // execute
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                serviceStocks.add(ServiceStock.get(rs.getString("OC_STOCK_SERVERID")+"."+rs.getString("OC_STOCK_OBJECTID")));
            }
        }
        catch(Exception e){
            //e.printStackTrace();
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return serviceStocks;
    }

    //--- GET SERVICE STOCKS ----------------------------------------------------------------------
    // return vector containing ServiceStocks belonging to the specified Service and its subservices
    public static Vector getServiceStocks(String serviceId){
        Vector serviceStocks = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_STOCK_SERVERID, OC_STOCK_OBJECTID FROM OC_SERVICESTOCKS"+
                             "  WHERE ";

            if(serviceId.length() > 0){
                // search all service and its child-services
                Vector childIds = Service.getChildIds(serviceId);
                String sChildIds = ScreenHelper.tokenizeVector(childIds,",","'");
                if(sChildIds.length() > 0){
                    sSelect+= " OC_STOCK_SERVICEUID IN ("+sChildIds+") AND ";
                }
                else{
                    sSelect+= " OC_STOCK_SERVICEUID IN ('') AND ";
                }
            }

            // remove last AND if any
            if(sSelect.indexOf("AND ")>0){
                sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
            }

            ps = oc_conn.prepareStatement(sSelect);

            // execute
            rs = ps.executeQuery();

            // get data from DB
            while(rs.next()){
                serviceStocks.add(ServiceStock.get(rs.getString("OC_STOCK_SERVERID")+"."+rs.getString("OC_STOCK_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return serviceStocks;
    }

    //--- IS EXTERNAL SERVICE ---------------------------------------------------------------------
    // Check wether one of the parents is an external service ('extfour' in id)
    //---------------------------------------------------------------------------------------------
    public static boolean isExternalService(String sServiceUid){
        boolean isExternalService = false;

        // parent of all external services is an external service too, even when it has no parent.
        if(sServiceUid.equalsIgnoreCase("extfour")) return true;

        Vector parents = getParentIds(sServiceUid.trim());
        String parentId;
        for(int i=0; i<parents.size(); i++){
            parentId = (String)parents.get(i);
            if(parentId.toLowerCase().startsWith("extfour")){
                isExternalService = true;
                break;
            }
        }

        return isExternalService;
    }

    public static boolean hasParentCode(String sServiceUid,String parentCode){
        boolean hasParentCode = false;

        // parent of all external services is an external service too, even when it has no parent.
        if(sServiceUid.equalsIgnoreCase(parentCode)) return true;

        Vector parents = getParentIds(sServiceUid.trim());
        String parentId;
        for(int i=0; i<parents.size(); i++){
            parentId = (String)parents.get(i);
            if(parentId.toLowerCase().startsWith(parentCode)){
                hasParentCode = true;
                break;
            }
        }

        return hasParentCode;
    }

    public static boolean hasBeds(String serviceid){
        Service service = Service.getService(serviceid);
        return service!=null && service.totalbeds>0;
    }

    public static boolean acceptsVisits(String serviceid){
        Service service = Service.getService(serviceid);
        return service!=null && ScreenHelper.checkDbString(service.acceptsVisits).equalsIgnoreCase("1");
    }

    public static int getAllBeds(String serviceid){
        int result=0;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect = "SELECT sum(totalbeds) total FROM Services WHERE serviceid like ?+'%'";
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            ps.setString(1,serviceid);
            rs = ps.executeQuery();
            if(rs.next()){
                result=rs.getInt("total");
            }
            rs.close();
            ps.close();

        }
        catch (Exception e){
            e.printStackTrace();
        }
        try {
			ad_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return result;
    }

    //--- GET WICKETS ----------------------------------------------------------------------
    // return vector containing all services that flagged as a wicket
    public static Vector getWickets(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vServiceids = new Vector();

        String sServiceId = "";

        String sSelect = "SELECT * FROM Services WHERE wicket = '1'";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                sServiceId = "";

                sServiceId = ScreenHelper.checkString(rs.getString("serviceid"));
                vServiceids.addElement(sServiceId);

            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vServiceids;
    }

    public String getFullyQualifiedName(String language){
    	String name=getLabel(language);
    	if(parentcode!=null && parentcode.length()>0){
    		Service parentService = Service.getService(parentcode);
    		if(parentService!=null){
    			name=parentService.getFullyQualifiedName(language)+" - "+name;
    		}
    	}
    	return name;
    }
    //--- GET SERVICE LABELS ----------------------------------------------------------------------
    // return vector with the labels (diff. lang) for the service
    public Vector getServiceLabels(){
        Vector vServiceLabels = new Vector();

        if(this.code.length() > 0){
            String supportedLanguages = ScreenHelper.getConfigString("supportedLanguages");
            if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
                supportedLanguages = supportedLanguages.toLowerCase();
            Label label;
            String tmpLang = "";
            StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();
                label = new Label(tmpLang,ScreenHelper.getTranNoLink("service",this.code,tmpLang));
                vServiceLabels.addElement(label);
            }
        }

        return vServiceLabels;
    }

    public static void manageServiceSave(Hashtable hService){
        PreparedStatement ps = null;
        MedwanQuery.getInstance().services.remove(hService.get("serviceid").toString().toUpperCase());
        String sInsert = " INSERT INTO Services (serviceid, address, city, zipcode, country, telephone," +
                         " fax, comment, updatetime, email, serviceparentid, inscode, serviceorder," +
                         " servicelanguage, updateuserid, contract, contracttype, contactperson, contractdate," +
                         " defaultcontext, defaultservicestockuid, contactaddress, contactzipcode, contactcity," +
                         " contactcountry, contacttelephone, contactfax, contactemail, code3, code5,wicket,totalbeds,inactive,costcenter,performeruid,acceptsVisits,stayprestationuid)" +
                         " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{

            ps = ad_conn.prepareStatement(sInsert);
            ps.setString(1, hService.get("serviceid").toString().toUpperCase());
            ps.setString(2, hService.get("address").toString());
            ps.setString(3, hService.get("city").toString());
            ps.setString(4, hService.get("zipcode").toString());
            ps.setString(5, hService.get("country").toString());
            ps.setString(6, hService.get("telephone").toString());
            ps.setString(7, hService.get("fax").toString());
            ps.setString(8, hService.get("comment").toString());
            ps.setTimestamp(9,(Timestamp)hService.get("updatetime"));
            ps.setString(10, hService.get("email").toString());
            ps.setString(11, hService.get("serviceparentid").toString());
            ps.setString(12, hService.get("inscode").toString());
            ps.setString(13, hService.get("serviceorder").toString());
            ps.setString(14, hService.get("servicelanguage").toString());
            ps.setInt(15, Integer.parseInt(hService.get("updateuserid").toString()));
            ps.setString(16, hService.get("contract").toString());
            ps.setString(17, hService.get("contracttype").toString());
            ps.setString(18, hService.get("contactperson").toString());
            ScreenHelper.setSQLDate(ps,19,(String)hService.get("contractdate"));
            ps.setString(20, hService.get("defaultcontext").toString());
            ps.setString(21, hService.get("defaultservicestockuid").toString());
            ps.setString(22, hService.get("contactaddress").toString());
            ps.setString(23, hService.get("contactzipcode").toString());
            ps.setString(24, hService.get("contactcity").toString());
            ps.setString(25, hService.get("contactcountry").toString());
            ps.setString(26, hService.get("contacttelephone").toString());
            ps.setString(27, hService.get("contactfax").toString());
            ps.setString(28, hService.get("contactemail").toString());

            // codes
            ps.setString(29, hService.get("code3").toString()); // NACE
            ps.setString(30, hService.get("code5").toString()); // MED CENTRE
            ps.setInt(31,((Integer)hService.get("wicket")).intValue());
            ps.setInt(32,((Integer)hService.get("totalbeds")).intValue());
            ps.setInt(33,((Integer)hService.get("inactive")).intValue());
            ps.setString(34,hService.get("costcenter").toString());
            ps.setString(35,hService.get("performeruid").toString());
            ps.setString(36,hService.get("acceptsVisits").toString());
            ps.setString(37,hService.get("stayprestationuid").toString());

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static void manageServiceUpdate(Hashtable hService){
        MedwanQuery.getInstance().services.remove(hService.get("serviceid").toString().toUpperCase());
        PreparedStatement ps = null;

        String sUpdate = " UPDATE Services SET" +
                         "  serviceid = ?, address = ?, city = ?, zipcode = ?, country = ?, telephone = ?, fax = ?," +
                         "  comment = ?, updatetime = ?, email = ?, serviceparentid = ?, inscode = ?, serviceorder = ?," +
                         "  servicelanguage = ?, updateuserid = ?, contract = ?, contracttype = ?, contactperson = ?," +
                         "  contractdate = ?, defaultcontext = ?, defaultservicestockuid = ?, contactaddress = ?," +
                         "  contactzipcode = ?, contactcity = ?, contactcountry = ?, contacttelephone = ?," +
                         "  contactfax = ?, contactemail = ?, code3 = ?, code5 = ?, wicket = ?, totalbeds = ?, inactive = ?, costcenter= ?, performeruid=?,acceptsVisits=?,stayprestationuid=?" +
                         " WHERE serviceid = ?";

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
        try{
            ps = ad_conn.prepareStatement(sUpdate);

            ps.setString(1, hService.get("serviceid").toString());
            ps.setString(2, hService.get("address").toString());
            ps.setString(3, hService.get("city").toString());
            ps.setString(4, hService.get("zipcode").toString());
            ps.setString(5, hService.get("country").toString());
            ps.setString(6, hService.get("telephone").toString());
            ps.setString(7, hService.get("fax").toString());
            ps.setString(8, hService.get("comment").toString());
            ps.setTimestamp(9, (Timestamp)hService.get("updatetime"));
            ps.setString(10, hService.get("email").toString());
            ps.setString(11, hService.get("serviceparentid").toString());
            ps.setString(12, hService.get("inscode").toString());
            ps.setString(13, hService.get("serviceorder").toString());
            ps.setString(14, hService.get("servicelanguage").toString());
            ps.setInt(15, Integer.parseInt(hService.get("updateuserid").toString()));
            ps.setString(16, hService.get("contract").toString());
            ps.setString(17, hService.get("contracttype").toString());
            ps.setString(18, hService.get("contactperson").toString());
            ps.setDate(19, ScreenHelper.getSQLDate(hService.get("contractdate").toString()));
            ps.setString(20, hService.get("defaultcontext").toString());
            ps.setString(21, hService.get("defaultservicestockuid").toString());

            ps.setString(22, hService.get("contactaddress").toString());
            ps.setString(23, hService.get("contactzipcode").toString());
            ps.setString(24, hService.get("contactcity").toString());
            ps.setString(25, hService.get("contactcountry").toString());
            ps.setString(26, hService.get("contacttelephone").toString());
            ps.setString(27, hService.get("contactfax").toString());
            ps.setString(28, hService.get("contactemail").toString());

            ps.setString(29, hService.get("code3").toString()); // NACE
            ps.setString(30, hService.get("code5").toString()); // MED CENTRE
            ps.setInt(31, Integer.parseInt(hService.get("wicket").toString()));
            ps.setInt(32, Integer.parseInt(hService.get("totalbeds").toString()));
            ps.setInt(33, Integer.parseInt(hService.get("inactive").toString()));
            ps.setString(34, hService.get("costcenter").toString());
            ps.setString(35, hService.get("performeruid").toString());
            ps.setString(36, hService.get("acceptsVisits").toString());
            ps.setString(37, hService.get("stayprestationuid").toString());

            ps.setString(38, hService.get("oldserviceid").toString());

            ps.executeUpdate();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Vector getServicesWithBeds(){
        Vector services = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select distinct OC_BED_SERVICEUID from OC_BEDS order by OC_BED_SERVICEUID";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                Service service = Service.getService(rs.getString("OC_BED_SERVICEUID"));
                if(service!=null){
                    services.add(service);
                }
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return services;
    }

    public Vector getBeds(){
        Vector beds = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select * from OC_BEDS where OC_BED_SERVICEUID=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,this.code);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                Bed bed = Bed.get(rs.getString("OC_BED_SERVERID")+"."+rs.getString("OC_BED_OBJECTID"));
                if(bed!=null){
                    beds.add(bed);
                }
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return beds;
    }

    public int getOccupiedBedCount(){
        int count=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select count(*) total from OC_ENCOUNTERS_VIEW where OC_ENCOUNTER_SERVICEUID=? and (OC_ENCOUNTER_ENDDATE IS NULL OR OC_ENCOUNTER_ENDDATE>?)";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,this.code);
            ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
            ResultSet rs = ps.executeQuery();
            if (rs.next()){
                count=rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return count;
    }

    public double getAverageOccupiedBedCount(double days){
        double count=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        java.util.Date date = new java.util.Date();
        long seconds=0;
        try{
        	for(int n=0;n<days;n++){
        		seconds+=24*3600*1000;
        		date.setTime(date.getTime()-seconds);
	        	String sQuery="select count(*) total from OC_ENCOUNTERS_VIEW where OC_ENCOUNTER_SERVICEUID=? and OC_ENCOUNTER_BEGINDATE<=? AND (OC_ENCOUNTER_ENDDATE IS NULL OR OC_ENCOUNTER_ENDDATE>?)";
	            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
	            ps.setString(1,this.code);
	            ps.setDate(2,new java.sql.Date(date.getTime()));
	            ps.setDate(3,new java.sql.Date(date.getTime()));
	            ResultSet rs = ps.executeQuery();
	            if (rs.next()){
	                count+=rs.getInt("total");
	            }
	            rs.close();
	            ps.close();
        	}
        	count=count/days;
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return count;
    }

    public int getTotalBedCount(){
        int count=0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sQuery="select count(*) total from OC_BEDS where OC_BED_SERVICEUID=?";
            PreparedStatement ps = oc_conn.prepareStatement(sQuery);
            ps.setString(1,this.code);
            ResultSet rs = ps.executeQuery();
            if (rs.next()){
                count=rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return count;
    }

}
