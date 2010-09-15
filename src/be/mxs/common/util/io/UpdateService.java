package be.mxs.common.util.io;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Internet;

import java.util.ArrayList;
import java.util.StringTokenizer;
import java.util.Iterator;
import java.io.File;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.Connection;
import java.sql.SQLException;

import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.Element;

/**
 * User: stijn smets
 * Date: 28-sep-2005
 */

//### PUBLIC METHODS ##############################################################################
// * static UpdateService getInstance()
// * String  getPathToUpdateFile()
// * String  getNewVersionId()
// * boolean isUpdateCheckNeeded()
// * String  getCurrentVersion()
// * boolean isUpdateNeeded(String programId)
//#################################################################################################
public class UpdateService {

    // declarations
    private static UpdateService instance;
    private SunFtpWrapper ftp;
    private String id, url, login, pwd, versionFilename, tempDirName, pathToUpdateFile, newVersionId;
    private SAXReader xmlReader;
    private Element serverElem;
    private int version, mostRecentVersion, currentVersion;
    private StringTokenizer tokenizer;
    private SimpleDateFormat simpleDateFormat;
    private boolean tempDirCreated;


    //--- PRIVATE CONSTRUCTOR ---------------------------------------------------------------------
    private UpdateService(){
        ftp = new SunFtpWrapper();
        xmlReader = new SAXReader();
        tempDirName = "/updateCheckTemp";
        simpleDateFormat = new SimpleDateFormat("dd-MM-yyyy");
    }

    //--- IS UPDATE CHECK NEEDED ------------------------------------------------------------------
    // only one updatecheck per day allowed. lastUpdateCheckDate is stored as a configString.
    // If lastUpdateCheckDate is older than NOW or does not exist yet, perform updatecheck.
    //---------------------------------------------------------------------------------------------
    public boolean isUpdateCheckNeeded(){
        boolean keyExists = false;
        boolean performUpdateCheck = false;
        String lastUpdateCheckDate = null;
        PreparedStatement ps;
        ResultSet rs;

        try{
            Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();

            String sSelect = "SELECT oc_key,oc_value FROM OC_Config WHERE oc_key = ?";
            ps = conn.prepareStatement(sSelect);
            ps.setString(1,"lastUpdateCheckDate");
            rs = ps.executeQuery();

            if(rs.next()){
                keyExists = true;
                lastUpdateCheckDate = rs.getString("oc_value");
            }
            rs.close();
            ps.close();

            if(!keyExists){
                sSelect = "INSERT INTO OC_Config(oc_key,oc_value,updatetime) VALUES (?,?,?)";

                ps = conn.prepareStatement(sSelect);
                ps.setString(1,"lastUpdateCheckDate");
                ps.setString(2,simpleDateFormat.format(new java.util.Date())); // now
                ps.setTimestamp(3,new Timestamp(new java.util.Date().getTime()));
                ps.executeUpdate();
                ps.close();

                // lastUpdateCheckDate does not exist, so perform update check anyway.
                performUpdateCheck = true;
            }
            else{
                // if lastUpdateCheckDate < NOW.day, perform update check
                if(!lastUpdateCheckDate.equals(simpleDateFormat.format(new java.util.Date()))){
                    performUpdateCheck = true;
                }

                // only update lastUpdateCheckDate if the updateCheck succesfuly completed.
                // --> updateLastUpdateCheckDate()
            }
            conn.close();
        }
        catch(Exception e){
            e.printStackTrace();

            // delete tempDir IF UpdateService created it and IF it is empty
            deleteTempDir(tempDirName);
        }

        return performUpdateCheck;
    }

    //--- IS UPDATE NEEDED ------------------------------------------------------------------------
    // Retreive all version files from all ftpservers specified in "ftpservers.xml".
    // Find out if there are files countaining a versionid larger than the current versionid.
    // If so, an update is needed.
    //---------------------------------------------------------------------------------------------
    public boolean isUpdateNeeded(String programId) throws Exception {
        boolean updateNeeded = false;

        // get current version
        currentVersion = getIntValue(getCurrentVersion());

        // download version file from all servers into temp dir
        downloadVersionFiles(tempDirName);

        // get all (and only) version files from temp dir
        ArrayList versionFiles = getVersionFilesFromTempDir(tempDirName);

        // compare current version with most recent version in version files.
        if(versionFiles.size() > 0){
            mostRecentVersion = getMostRecentVersion(versionFiles,programId);

            if(mostRecentVersion > currentVersion){
                updateNeeded = true;
            }
        }
        else{
            if(Debug.enabled) Debug.println("\nNo version files for program ('"+programId+"') found on any ftpserver.");
        }

        // updateCheck successfuly completed, so update lastUpdateCheckDate.
        updateLastUpdateCheckDate();

        return updateNeeded;
    }

    //--- GET CURRENT VERSION ---------------------------------------------------------------------
    public String getCurrentVersion() throws Exception {
        String currentVersion = "0";
        String sDoc = null;

        try{
            sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"application.xml";
            Document document = xmlReader.read(new URL(sDoc));
            Element versionElem = document.getRootElement().element("version");

            currentVersion = versionElem.attribute("major").getValue()+"."+
                             versionElem.attribute("minor").getValue()+"."+
                             versionElem.attribute("bug").getValue();

            if(Debug.enabled) Debug.println("Current version : "+currentVersion);
        }
        catch(Exception e){
            throw new Exception("ERROR : file containing current application version not found. ('"+sDoc+"')");
        }

        return currentVersion;
    }


    //#############################################################################################
    //### GETTERS #################################################################################
    //#############################################################################################

    //--- GET PATH TO UPDATE FILE -----------------------------------------------------------------
    public String getPathToUpdateFile(){
        return pathToUpdateFile;
    }

    //--- GET NEW VERSION ID ----------------------------------------------------------------------
    public String getNewVersionId(){
        return newVersionId;
    }

    //--- GET INSTANCE ----------------------------------------------------------------------------
    public static UpdateService getInstance(){
        if(instance==null) instance = new UpdateService();
        return instance;
    }


    //#############################################################################################
    //### PRIVATE METHODS #########################################################################
    //#############################################################################################

    //--- UPDATE LAST UPDATE CHECK DATE -----------------------------------------------------------
    private void updateLastUpdateCheckDate() throws SQLException {
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();

        String sSelect = "UPDATE OC_Config SET oc_value=?, updatetime=? WHERE oc_key = ?";

        PreparedStatement ps = conn.prepareStatement(sSelect);
        ps.setString(1,simpleDateFormat.format(new java.util.Date())); // now
        ps.setTimestamp(2,new Timestamp(new java.util.Date().getTime()));
        ps.setString(3,"lastUpdateCheckDate");
        ps.executeUpdate();
        ps.close();
        conn.close();
    }

    //--- GET SERVERS FROM XML --------------------------------------------------------------------
    private Element getServersFromXML() throws Exception {
        Document serversDoc;
        Element serversElem = null;
        String serversFilename = MedwanQuery.getInstance().getConfigString("templateSource")+"ftpservers.xml";

        try{
            serversDoc = xmlReader.read(serversFilename);
            serversElem = serversDoc.getRootElement();
        }
        catch(Exception e){
            throw new Exception("ERROR : ftpservers file not found. ('"+serversFilename+"') (configString : 'updateserversFilename')");
        }

        return removeInvalidServers(serversElem);
    }

    //--- REMOVE INVALID SERVERS ------------------------------------------------------------------
    // remove invalid server entries (attributes id, url, login, pwd, versionFilename required)
    //---------------------------------------------------------------------------------------------
    private Element removeInvalidServers(Element serversElem){
        Iterator serversIter = serversElem.elementIterator();
        Element serverElem;
        String attrValue;
        boolean attrMissing = false;
        ArrayList serversToRemove = new ArrayList();

        // run thru servers
        while(serversIter.hasNext()){
            serverElem = (Element)serversIter.next();

            // remove server from servers element if one of the required attributes is missing.
            attrValue = checkString(serverElem.attributeValue("id"));
            if(attrValue.length() == 0) attrMissing = true;

            if(!attrMissing){
                attrValue = checkString(serverElem.attributeValue("url"));
                if(attrValue.length() == 0) attrMissing = true;
            }

            if(!attrMissing){
                attrValue = checkString(serverElem.attributeValue("login"));
                if(attrValue.length() == 0) attrMissing = true;
            }

            if(!attrMissing){
                attrValue = checkString(serverElem.attributeValue("pwd"));
                if(attrValue.length() == 0) attrMissing = true;
            }

            if(!attrMissing){
                attrValue = checkString(serverElem.attributeValue("versionFilename"));
                if(attrValue.length() == 0) attrMissing = true;
            }

            // select for removal
            if(attrMissing){
                serversToRemove.add(serverElem);
                attrMissing = false;
            }
        }

        // remove
        for(int i=0; i<serversToRemove.size(); i++){
            serversElem.remove((Element)serversToRemove.get(i));
        }

        if(Debug.enabled){
            Debug.println(serversElem.elements().size()+" valid servers found in ftpservers file.");
        }

        return serversElem;
    }

    //--- GET INT VALUE ---------------------------------------------------------------------------
    // Each value in the versionid separated by a "." represents an integer value equal to
    // the product of the value and a power of 1000 depending on the place of the value in the versionid.
    //---------------------------------------------------------------------------------------------
    private int getIntValue(String versionid) {
        tokenizer = new StringTokenizer(versionid,".");
        int tokenCount = tokenizer.countTokens();
        int totalValue = 0, value = 0;

        while(tokenizer.hasMoreTokens()){
            tokenCount--;
            value = Integer.parseInt(tokenizer.nextToken());
            totalValue+= (value * Math.pow(1000,tokenCount));
        }

        return totalValue;
    }

    //--- DOWNLOAD VERSION FILES ------------------------------------------------------------------
    private void downloadVersionFiles(String tempDirName)
            throws Exception {

        int serverCount = 0;
        String targetFilename;

        createTempDir(tempDirName);

        // run thru servers in serversfile
        Element serversElem = getServersFromXML();
        Iterator serverIter = serversElem.elementIterator();

        while(serverIter.hasNext()){
            serverCount++;

            // get server info
            serverElem = (Element)serverIter.next();
            url = checkString(serverElem.attributeValue("url"));
            versionFilename = checkString(serverElem.attributeValue("versionFilename"));

            // check if server is open.
            try{
                // get timeout
                int ftpTimeOut = MedwanQuery.getInstance().getConfigInt("ftpTimeOut");
                if(ftpTimeOut < 0) ftpTimeOut = 1000; // default

                if(Debug.enabled) Debug.println("\nChecking server "+serverCount+" : "+url+" (Timeout:"+ftpTimeOut+")");

                if(Internet.isReachable(url,21,ftpTimeOut)){
                    ftp.openServer(url); // this method takes some time..

                    // download version file to temp dir
                    try{
                        if(ftp.serverIsOpen()){
                            login = checkString(serverElem.attributeValue("login"));
                            pwd   = checkString(serverElem.attributeValue("pwd"));

                            ftp.login(login,pwd);
                            ftp.binary();

                            // each file needs a unique name, to prevent them from being overwritten.
                            targetFilename = versionFilename.substring(0,versionFilename.lastIndexOf("."))+
                                             "_"+serverCount+
                                             versionFilename.substring(versionFilename.lastIndexOf("."));

                            ftp.downloadFile(versionFilename,(tempDirName+"/"+targetFilename).replaceAll("//","/"));
                            ftp.closeServer();

                            if(Debug.enabled) Debug.println("--> Version file received : '"+tempDirName+"/"+targetFilename+"'");
                        }
                        else{
                            if(Debug.enabled) Debug.println("--> Server is closed.");
                        }
                    }
                    catch(Exception e){
                        // continue with next server
                    }
                }
                else {
                    throw new Exception();
                }
            }
            catch(Exception e){
                if(Debug.enabled) Debug.println("--> Server could not be reached.");
            }
        }

        // delete tempDir if UpdateService created it and if it is empty
        deleteTempDir(tempDirName);
    }

    //--- GET VERSION FILES FROM TEMPDIR ----------------------------------------------------------
    // get all version files from temp dir.
    //---------------------------------------------------------------------------------------------
    private ArrayList getVersionFilesFromTempDir(String tempDirName) {
        ArrayList versionFiles = new ArrayList();
        File tempDir = createTempDir(tempDirName);
        File[] tempFiles = tempDir.listFiles();

        for(int i=0; i<tempFiles.length; i++){
            if(tempFiles[i].isFile()){
                versionFiles.add(tempFiles[i]);
            }
        }

        // delete tempDir if UpdateService created it and if it is empty
        deleteTempDir(tempDirName);

        return versionFiles;
    }

    //--- GET MOST RECENT VERSION -----------------------------------------------------------------
    // read id from all version files (for the specified program) and remember the most recent id.
    //---------------------------------------------------------------------------------------------
    private int getMostRecentVersion(ArrayList versionFiles, String programId){
        int mostRecentVersion = 0;
        Element programElem, versionElem;
        Document document;
        File versionFile;
        Iterator programIter;
        int minimumVersion;

        // run thru version files
        for(int i=0; i<versionFiles.size(); i++){
            versionFile = (File)versionFiles.get(i);

            try{
                // run thru all program elements in one version file.
                document = xmlReader.read(versionFile);
                versionElem = document.getRootElement();
                programIter = versionElem.elementIterator("program");

                while(programIter.hasNext()){
                    try{
                        programElem = (Element)programIter.next();
                        id = checkString(programElem.attributeValue("id"));

                        // only check versions of the specified program.
                        if(id.equals(programId)){
                            url = checkString(programElem.attributeValue("url"));

                            // only check if an url is specified.
                            if(url.length() > 5){
                                minimumVersion = getIntValue(checkString(programElem.attributeValue("minimumVersion")));

                                // only check if currentVersion >= minimumVersion
                                if(currentVersion >= minimumVersion){
                                    version = getIntValue(checkString(programElem.attributeValue("version")));

                                    if(version > mostRecentVersion){
                                        mostRecentVersion = version;
                                        pathToUpdateFile = url;
                                        newVersionId = programElem.attributeValue("version");
                                    }
                                }
                            }
                        }
                    }
                    catch(Exception e){
                        // continue with next program entry in version file
                    }
                }
            }
            catch(Exception e){
                // continue with next version file
            }

            // delete file from temp dir after inspecting it.
            versionFile.delete();
        }

        return mostRecentVersion;
    }

    //--- CREATE TEMP DIR -------------------------------------------------------------------------
    // create tempdir with specified name if it does not exist.
    //---------------------------------------------------------------------------------------------
    private File createTempDir(String tempDirName){
        File tempDir = new File(tempDirName);

        if(!tempDir.exists()){
            tempDir.mkdirs();
            tempDirCreated = true;
            //if(Debug.enabled) Debug.println("\nDirectory '"+tempDirName+"' created.");
        }

        return tempDir;
    }

    //--- DELETE TEMP DIR -------------------------------------------------------------------------
    // delete tempDir if UpdateService created it and if it is empty.
    //---------------------------------------------------------------------------------------------
    private void deleteTempDir(String tempDirName){
        if(tempDirCreated){
            File tempDir = new File(tempDirName);

            if(tempDir.isDirectory()){
                File[] filesInDir = tempDir.listFiles();

                if(filesInDir.length == 0){
                    tempDir.delete();
                    tempDirCreated = false;
                    //if(Debug.enabled) Debug.println("\nDirectory '"+tempDirName+"' deleted.");
                }
            }
        }
    }

    //--- CHECK STRING ----------------------------------------------------------------------------
    private String checkString(String string) {
      if(string==null || string.equalsIgnoreCase("null")){
          return "";
      }
      else{
          return string.trim();
      }
    }

}
