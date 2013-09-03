package be.mxs.common.util.io;

import java.io.*;

import sun.net.ftp.FtpClient;
import java.util.Vector;

/**
  * This is a basic wrapper around the sun.net.ftp.FtpClient
  * class, which is an undocumented class which is included
  * with Sun Java that allows you to make FTP connections
  * and file transfers.
  *
  * Program version 1.0. Author Julian Robichaux, http://www.nsftools.com
  *
  * @author Julian Robichaux ( http://www.nsftools.com )
  * @version 1.0
  */
public class SunFtpWrapper extends FtpClient {
	/*
	 * Methods you might use from the base FtpClient class
	 * // set the transfer type to ascii
	 * public void ascii()
	 *
	 * // set the transfer type to binary
	 * public void binary()
	 *
	 * // change to the specified directory
	 * public void cd(String remoteDirectory)
	 *
	 * // close the connection to the server
	 * public void closeServer()
	 *
	 * // download the specified file from the FTP server
	 * public TelnetInputStream get(String filename)
	 *
	 * // return the last response from the server as a single String
	 * public String getResponseString()
	 *
	 * // return the last response from the server as a Vector of Strings
	 * public Vector getResponseStrings()
	 *
	 * // list the contents of the current directory (could be in any number
	 * // of formats, depending on the remote server)
	 * public TelnetInputStream list()
	 *
	 * // login to the FTP server, using the specified username and password
	 * public void login(String username, String password)
	 *
	 * // open a connection to the specified FTP server, using port 21
	 * public void openServer(String host)
	 *
	 * // open a connection to the specified FTP server, using the specified port
	 * public void openServer(String host, int port))
	 *
	 * // upload a file to the FTP server (the uploaded file will have the specified
	 * // file name
	 * public TelnetOutputStream put(String filename)
	 */

	/** Get the present working directory */
	public String pwd() throws IOException {
		issueCommand("PWD");
		if (isValidResponse()) {
			String response = getResponseString().substring(4).trim();
			if (response.startsWith("\""))
				response = response.substring(1);
			if (response.endsWith("\""))
				response = response.substring(0, response.length() - 1);
			return response;
		} else {
			return "";
		}
	}

	/** Go up one directory */
	public boolean cdup() throws IOException {
		issueCommand("CDUP");
		return isValidResponse();
	}

	/** Create a new directory */
	public boolean mkdir (String newDir) throws IOException {
		issueCommand("MKDIR " + newDir);
		return isValidResponse();
	}

	/** Delete a remote file */
	public boolean deleteFile (String fileName) throws IOException {
		issueCommand("DELE " + fileName);
		return isValidResponse();
	}

	/** Get the results of the LIST command as a Vector of Strings.
	  * Because there's no standard format for the results of a LIST
	  * command, it's hard to tell what resulting data will look like.
	  * Just be aware that different servers have different ways of
	  * returning your LIST data. */
	public Vector listRaw() throws IOException {
		String fileName;
		Vector ftpList = new Vector();
		BufferedReader reader = new BufferedReader(new InputStreamReader(list()));
		while ((fileName = reader.readLine()) != null) {
			ftpList.add(fileName);
		}
		return ftpList;
	}

	/** Get the response code from the last command that was sent */
	public int getResponseCode() throws NumberFormatException {
		return Integer.parseInt(getResponseString().substring(0, 3));
	}

	/** Return true if the last response code was in the 200 range,
	  * false otherwise */
	public boolean isValidResponse() {
		try {
			int respCode = getResponseCode();
			return (respCode  >= 200 && respCode < 300);
		} catch (Exception e) {
			return false;
		}
	}

	/** Send a raw FTP command to the server. You can get the response
	  * by calling getResponseString (which returns the entire response as a
	  * single String) or getResponseStrings (which returns the response
	  * as a Vector). */
	public int issueRawCommand (String command) throws IOException {
		return issueCommand(command);
	}

	/** Download a file from the server, and save it to the specified local file */
	public boolean downloadFile (String serverFile, String localFile) throws IOException {
		int i = 0;
		byte[] bytesIn = new byte[1024];
		BufferedInputStream in = new BufferedInputStream(get(serverFile));
		FileOutputStream out = new FileOutputStream(localFile);
		while ((i = in.read(bytesIn)) >= 0) {
			out.write(bytesIn, 0, i);
		}
		out.close();
		return true;
	}

	/** Upload a file to the server */
	public boolean uploadFile (String localFile, String serverFile) throws IOException {
		int i = 0;
		byte[] bytesIn = new byte[1024];
		FileInputStream in = new FileInputStream(localFile);
		BufferedOutputStream out = new BufferedOutputStream(put(serverFile));
		while ((i = in.read(bytesIn)) >= 0) {
			out.write(bytesIn, 0, i);
		}
		in.close();
		out.close();
		return true;
	}
}


