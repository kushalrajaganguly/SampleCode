/**
 * @file        Database.java
 *
 * @package     com.bsh.tc.bshinfo.dao;
 *
 * @brief       Package to read database objects
 */
package com.bsh.tc.bshinfo.dao;

import java.awt.Dimension;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.Hashtable;
import java.util.Locale;

import javax.imageio.ImageIO;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * Create the database connection and get BSH actual information items.
 */
public class Database {

	private static org.apache.log4j.Logger log = Logger
			.getLogger(Database.class);

	private long timeOfLastUpdate = 0l;

	public boolean runthread = true;
	private static ReloadThread myThread;
	private boolean reload = true;
	// private Connection connection = null;
	// private PreparedStatement statement = null;
	// private ResultSet resultSet = null;
	private ArrayList<BSHActualInformationItem> actualInformationItems;
	private ArrayList<NXVersion> actualNXVersionItems;
	private ArrayList<TCVersion> actualTCVersionItems;
	private ArrayList<TCHistory> actualTCHistoryItems;
	private ArrayList<TCHost> actualTCHostItems;

	// Database parameters
	protected String driverClass;
	protected String databaseName;
	protected String url;
	private String passwd;
	private String username;
	private static int threaddelay = 20000; // default value can be overwritten
											// by web.xml initparameter

	private String imagepath;
	private String tcmsgtable = "PLMsupportDB.BSHInfoFrame.tcmsg";
	private String nxversiontable = "PLMsupportDB.PLMsupport.NXVersion";
	private String tcversiontable = "PLMsupportDB.BSHInfoFrame.TCVersion";
	private String tchistorytable = "PLMsupportDB.BSHInfoFrame.TcHistory";
	private String tchosttable = "PLMsupportDB.BSHInfoFrame.TCWorkstations";
	private String column = "image";
	private Dimension imgrec = new Dimension(300, 300);

	public boolean updateTCVersion = false;
	public boolean updateActualInformationItems = false;
	public boolean updateNXVersion = false;
	public boolean updateTCHistory = false;

	/**
	 * Initialize database parameters.
	 *
	 * @param host
	 *            Database host name
	 * @param port
	 *            Database port number
	 * @param imagepath
	 * @param threaddelay
	 */
	public Database(String host, int port, String type, String databasename,
			String db_user, String db_password, String imagepath, int delay) {

		// this.type = type;

		this.databaseName = "bshinfo";
		if (type.equalsIgnoreCase("mysql")) {
			this.url = "jdbc:mysql://" + host + ":" + port + "/" + databaseName;
			this.driverClass = "com.mysql.jdbc.Driver";
		} else if (type.equalsIgnoreCase("mssql")) {
			this.url = "jdbc:sqlserver://" + host + "\\" + databasename;
			this.driverClass = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
		}
		this.imagepath = imagepath;
		this.username = db_user;
		this.passwd = db_password;
		if (delay > 100) {
			threaddelay = delay;
		}
		myThread = new ReloadThread(this, Database.threaddelay);
		// ((Thread) myThread).start();

	}

	public synchronized void startThread() {
		if (!myThread.isAlive()) {
			myThread.start();
		}
	}

	public void setReload(boolean bool) {
		this.reload = bool;
	}

	public boolean getReload() {
		return this.reload;
	}

	/**
	 * Open the database connection.
	 *
	 * @param userName
	 *            Database user name
	 * @param password
	 *            Database user password
	 * @return
	 * @throws SQLException
	 */
	public Connection open() throws SQLException {
		try {
			Class.forName(driverClass).newInstance();
		} catch (InstantiationException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}

		Connection connection = null;
		try {
			connection = DriverManager.getConnection(url, this.username,
					this.passwd);
		} catch (SQLException e) {
			log.error("Could not connect to database.");
			e.printStackTrace();
			throw e;
		}
		return connection;
	}

	/**
	 * Get all BSH actual information datasets from database.
	 * 
	 * @param connection
	 *
	 * @return ArrayList with BSH actual informations items.
	 */
	public ArrayList<BSHActualInformationItem> loadActualInformationItems(
			Connection connection) {
		ArrayList<BSHActualInformationItem> actualInformationItems = new ArrayList<BSHActualInformationItem>();

		String sqlString = "SELECT id,fromdate,todate,tcsystem,information,starttcallowed,onetime,type,imagetype"
				+ " FROM " + tcmsgtable;
		// + " where fromdate < getdate() and todate > getdate();";

		try {
			PreparedStatement statement = connection
					.prepareStatement(sqlString);
			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				Timestamp fromTimestamp = resultSet.getTimestamp("fromdate");
				Timestamp toTimestamp = resultSet.getTimestamp("todate");

				Date fromDate = null;
				Date toDate = null;

				if (fromTimestamp != null) {
					fromDate = new Date(fromTimestamp.getTime());
				}

				if (toTimestamp != null) {
					toDate = new Date(toTimestamp.getTime());
				}

				String tcSystem = resultSet.getString("tcsystem");
				String message = resultSet.getString("information");
				String imagetype = resultSet.getString("imagetype");
				boolean startTCAllowed = resultSet.getBoolean("starttcallowed");
				boolean oneTime = resultSet.getBoolean("oneTime");
				int id = resultSet.getInt("id");
				String type = resultSet.getString("type");

				BSHActualInformationItem actualInformationItem = new BSHActualInformationItem(
						fromDate, toDate, tcSystem, message, imagetype,
						startTCAllowed, oneTime, id, type);

				actualInformationItems.add(actualInformationItem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return actualInformationItems;
	}

	/**
	 * Get all BSH actual information datasets from database.
	 * 
	 * @param connection
	 *
	 * @return ArrayList with BSH actual informations items.
	 */
	public ArrayList<TCVersion> loadTCVersionItems(Connection connection) {
		ArrayList<TCVersion> actualTCVersionItems = new ArrayList<TCVersion>();

		String sqlString = "SELECT id,tcsystem,base_version,bsh_version,svn_version,status,comment"
				+ " FROM " + tcversiontable + ";";

		try {
			PreparedStatement statement = connection
					.prepareStatement(sqlString);
			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				int id = resultSet.getInt("id");
				String tcSystem = resultSet.getString("tcsystem");
				String base_version = resultSet.getString("base_version");
				String bsh_version = resultSet.getString("bsh_version");
				int svn_version = resultSet.getInt("svn_version");
				String status = resultSet.getString("status");
				String comment = resultSet.getString("comment");

				TCVersion actualTCVersionItem = new TCVersion(id, tcSystem,
						base_version, bsh_version, svn_version, status, comment);
				actualTCVersionItems.add(actualTCVersionItem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return actualTCVersionItems;
	}

	public ArrayList<NXVersion> loadNXVersionItems(Connection connection) {
		ArrayList<NXVersion> actualNXVersionItems = new ArrayList<NXVersion>();

		String sqlString = "SELECT ID,NX,Type,ValidFrom,ValidTo,BSH_NX_VERSION,SPLM_NX_VERSION,MinimumVersion,WebLink,AddedBy,DateAdded,ModifiedBy,DateModified"
				+ " FROM " + nxversiontable + ";";

		try {
			PreparedStatement statement = connection
					.prepareStatement(sqlString);
			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				
				Timestamp fromTimestamp = resultSet.getTimestamp("ValidFrom");
				Timestamp toTimestamp = resultSet.getTimestamp("ValidTo");
				Timestamp addedTimestamp = resultSet.getTimestamp("DateAdded");
				Timestamp modifiedTimestamp = resultSet.getTimestamp("DateModified");
				
				Date ValidFrom = null;
				Date ValidTo = null;
				Date DateAdded = null;
				Date DateModified = null;

				if (fromTimestamp != null) {
					ValidFrom = new Date(fromTimestamp.getTime());
								}

				if (toTimestamp != null) {
					ValidTo = new Date(toTimestamp.getTime());
								}
				if (addedTimestamp != null) {
					DateAdded = new Date(addedTimestamp.getTime());
								}
				if (modifiedTimestamp != null) {
					DateModified = new Date(modifiedTimestamp.getTime());
								}
				
				int ID = resultSet.getInt("ID");
				String NX = resultSet.getString("NX");
				String Type = resultSet.getString("Type");			
				String BSH_NX_VERSION = resultSet.getString("BSH_NX_VERSION");
				String SPLM_NX_VERSION = resultSet.getString("SPLM_NX_VERSION");
				String MinimumVersion = resultSet.getString("MinimumVersion");
				String WebLink = resultSet.getString("WebLink");
				String AddedBy = resultSet.getString("AddedBy");		
				String ModifiedBy = resultSet.getString("ModifiedBy");

				NXVersion actualNXVersionItem = new NXVersion(ID, NX, Type,
						ValidFrom, ValidTo, BSH_NX_VERSION, SPLM_NX_VERSION,
						MinimumVersion, WebLink, AddedBy, DateAdded,
						ModifiedBy, DateModified);

				actualNXVersionItems.add(actualNXVersionItem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return actualNXVersionItems;
	}
	
	public ArrayList<TCHistory> loadTCHistoryItems(Connection connection) {
		ArrayList<TCHistory> actualTCHistoryItems = new ArrayList<TCHistory>();

		String sqlString = "SELECT ID,Type,ChangeString,ChangeDate,ChangeUser,Operation"
				+ " FROM " + tchistorytable + " ORDER BY ChangeDate DESC";

		try {
			log.debug(sqlString);
			PreparedStatement statement = connection
					.prepareStatement(sqlString);
			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				
				Timestamp modifiedDate = resultSet.getTimestamp("ChangeDate");
				
				Date DateModified = null;

				if (modifiedDate != null) {
					DateModified = new Date(modifiedDate.getTime());
								}

				int ID = resultSet.getInt("ID");
				String Type = resultSet.getString("Type");			
				String ChangeString = resultSet.getString("ChangeString");
				String ChangeUser = resultSet.getString("ChangeUser");		
				String Operation = resultSet.getString("Operation");

				TCHistory actualTCHistoryItem = new TCHistory(ID, Type, 
						ChangeString, DateModified, ChangeUser, Operation);

				actualTCHistoryItems.add(actualTCHistoryItem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return actualTCHistoryItems;
	}
	
	public ArrayList<TCHost> loadTCHostItems(Connection connection) {
		ArrayList<TCHost> actualTCHostItems = new ArrayList<TCHost>();

		String sqlString = "SELECT Workstation,TCSite,LastLogin,Count"
				+ " FROM " + tchosttable + " ORDER BY LastLogin DESC";

		try {
			log.debug(sqlString);
			PreparedStatement statement = connection
					.prepareStatement(sqlString);
			ResultSet resultSet = statement.executeQuery();

			while (resultSet.next()) {
				
				Timestamp modifiedDate = resultSet.getTimestamp("LastLogin");
				
				Date DateModified = null;

				if (modifiedDate != null) {
					DateModified = new Date(modifiedDate.getTime());
								}

				String Workstation = resultSet.getString("Workstation");			
				String TCSite = resultSet.getString("TCSite");
				int Count = resultSet.getInt("Count");

				TCHost actualTCHostItem = new TCHost(Workstation,TCSite,DateModified,Count);

				actualTCHostItems.add(actualTCHostItem);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return actualTCHostItems;
	}

	public synchronized ArrayList<TCHost> ActualTCHostItems(
			ArrayList<TCHost> list) {
		if (list != null) {
			this.actualTCHostItems = list;
		}
		if (this.actualTCHostItems == null) {
			this.actualTCHostItems = new ArrayList<TCHost>();
		}
		return this.actualTCHostItems;
	}
	
	public synchronized ArrayList<TCHistory> ActualTCHistoryItems(
			ArrayList<TCHistory> list) {
		if (list != null) {
			this.actualTCHistoryItems = list;
		}
		if (this.actualTCHistoryItems == null) {
			this.actualTCHistoryItems = new ArrayList<TCHistory>();
		}
		return this.actualTCHistoryItems;
	}
	
	public synchronized ArrayList<NXVersion> ActualNXVersionItems(
			ArrayList<NXVersion> list) {
		if (list != null) {
			this.actualNXVersionItems = list;
		}
		if (this.actualNXVersionItems == null) {
			this.actualNXVersionItems = new ArrayList<NXVersion>();
		}
		return this.actualNXVersionItems;
	}

	public synchronized ArrayList<TCVersion> ActualTCVersionItems(
			ArrayList<TCVersion> list) {
		if (list != null) {
			this.actualTCVersionItems = list;
		}
		return this.actualTCVersionItems;

	}

	public synchronized ArrayList<BSHActualInformationItem> ActualInformationItems(
			ArrayList<BSHActualInformationItem> list) {
		if (list != null) {
			this.actualInformationItems = list;
		}
		return this.actualInformationItems;
	}

	public ArrayList<BSHActualInformationItem> getCurrentActualInformationItems() {
		long actualdate = new GregorianCalendar(Locale.GERMANY).getTime()
				.getTime();
		ArrayList<BSHActualInformationItem> res = new ArrayList<BSHActualInformationItem>();
		ArrayList<BSHActualInformationItem> temp = new ArrayList<BSHActualInformationItem>();
		temp.addAll(ActualInformationItems(null));
		for (BSHActualInformationItem elem : temp) {
			if (elem.getFromDate().getTime() < actualdate
					&& actualdate < elem.getToDate().getTime()) {
				res.add(elem);
			}
		}
		log.debug("found " + res.size() + " actual informations");
		return res;
	}

	/**
	 * Close the database connection.
	 * 
	 * @param connection
	 */
	public void close(Connection connection) {
		try {

			if (connection != null) {
				connection.close();
			}
		} catch (SQLException e) {
			log.error(e.getMessage());
			if (log.getLevel() == Level.DEBUG) {
				e.printStackTrace();
			}
		}
	}

	public void insertImage(String img, Connection connection) {
		int len;
		String query;
		PreparedStatement pstmt;

		try {
			File file = new File(img);
			FileInputStream fis = new FileInputStream(file);
			len = (int) file.length();

			query = ("update " + tcmsgtable + " set " + column + "=?");
			pstmt = connection.prepareStatement(query);
			// pstmt.setString(1,file.getName());
			// pstmt.setInt(2, len);

			// Method used to insert a stream of bytes
			pstmt.setBinaryStream(1, fis, len);
			pstmt.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public String getImageDataFromDB(String filename, String filetype,
			String where, Connection connection) {

		byte[] fileBytes;
		String query;
		if (filetype == null) {
			filetype = "png";
		}
		try {
			query = "select " + column + " from " + tcmsgtable + " where "
					+ where;
			Statement state = connection.createStatement();
			ResultSet rs = state.executeQuery(query);
			if (rs.next()) {
				fileBytes = rs.getBytes(1);

				saveImageInFile(filename, filetype, fileBytes);

				return filename + "." + filetype;
			}
			return null;

		} catch (Exception e) {
			log.error(e.getMessage());
			e.printStackTrace();
			return null;
		}
	}

	public void saveImageInFile(String filename, String filetype,
			byte[] fileBytes) {
		File targetFile = new File(this.imagepath + "/" + filename + "."
				+ filetype.toLowerCase());
		ByteArrayInputStream bio = new ByteArrayInputStream(fileBytes);
		try {
			BufferedImage image = ImageIO.read(bio);
			BufferedImage image2 = scaleImage(image);
			ImageIO.write((RenderedImage) image2, filetype.toLowerCase(),
					targetFile);
		} catch (Exception e) {
			log.error(e.getMessage());
		}
		return;
	}

	public String[] saveActualInformationToDB(File image,
			Hashtable<String, String> params, String userName) {
		int i = 0;
		int j = 0;
		String errorstr = "";
		String[] result = new String[2];
		String tcHistoryQuery = "";
		String printedQuery = "";
		String modifiedQuery = "";
		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String newquery = "select MAX(id) FROM " + tcmsgtable + "";
		log.debug(newquery);
		
		String query = "INSERT INTO "
				+ tcmsgtable
				+ " (fromdate,todate,tcsystem,information,starttcallowed,onetime,type,image,imagetype)"
				+ " VALUES (?,?,?,?,?,?,?,?,?)";
		FileInputStream inStream = null;
		try {
			Connection connection = this.open();
			PreparedStatement pstmt = connection.prepareStatement(query);

			inStream = new FileInputStream(image);

			DateFormat format = new SimpleDateFormat("dd.MM.yyyy_H:m",
					Locale.GERMANY);
			java.util.Date fromdate = format.parse(params.get("fromdate") + "_"
					+ params.get("fromtime"));
			java.util.Date todate = format.parse(params.get("todate") + "_"
					+ params.get("totime"));
			Timestamp sqldate = new Timestamp(fromdate.getTime());
			Timestamp sqldate2 = new Timestamp(todate.getTime());
			
			String printedFromDate = params.get("fromdate") + "_"+ params.get("fromtime");
			String printedToDate = params.get("todate") + "_"+ params.get("totime");
			String printedtcsystem =  params.get("tcsystem"); 
			String printedinformation =  params.get("message"); 
			String printedstarttcallowed = params.get("starttcallowed");
			String printedonetime = params.get("onetime");
			String printedtype = params.get("type");
			String printedimagetype = params.get("fileextension");
			pstmt.setTimestamp(1, sqldate);
			pstmt.setTimestamp(2, sqldate2);
			pstmt.setString(3, params.get("tcsystem"));
			pstmt.setString(4, params.get("message"));
			pstmt.setInt(5, Integer.parseInt(params.get("starttcallowed")));
			pstmt.setInt(6, Integer.parseInt(params.get("onetime")));
			pstmt.setString(7, params.get("type"));
			pstmt.setBinaryStream(8, inStream);
			pstmt.setString(9, params.get("fileextension"));
			i = pstmt.executeUpdate();
			
			if(i == 1){
				pstmt = connection.prepareStatement(newquery);
				ResultSet newresultSet = pstmt.executeQuery();
				if (newresultSet.next()) {
					j = newresultSet.getInt(1);
				}
				printedQuery = "INSERT INTO "
						+ tcmsgtable
						+ " (fromdate,todate,tcsystem,information,starttcallowed,onetime,type,image,imagetype)"
						+ " VALUES ('"+printedFromDate+"','"+printedToDate+"','"+printedtcsystem+"','"+printedinformation+"','"+printedstarttcallowed+"','"+printedonetime+"','"+printedtype+"','Image_File','"+printedimagetype+"')";
				modifiedQuery = printedQuery.replaceAll("'", "''");
				tcHistoryQuery = "insert into "
						+ tchistorytable
						+ "  (ID,Type,ChangeString,ChangeDate,ChangeUser,Operation) "
						+ "values ('" + j + "','TCMsg', '"+modifiedQuery+"', CONVERT(datetime,'" + sdf.format(now) + "',120), '"
						+ userName + "', 'Insert')";
				log.debug(tcHistoryQuery);
				pstmt = connection.prepareStatement(tcHistoryQuery);
				pstmt.executeUpdate();
			}
			
			
			log.debug("insert " + i + " row(s)");
		} catch (Exception e) {
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}
		}

		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}

	public String[] insertOrUpdateTCVersion(String idField, String tcsystem,
			String baseversion, String bshversion, String svnversion,
			String status, String comment, String userName) {
		int i = 0;
		int j = 0;
		String errorstr = "";
		String[] result = new String[2];
		String tcHistoryQuery = "";
		String modifiedQuery = "";
		String query = "";
		FileInputStream inStream = null;
		Connection connection = null;
		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		try {
			if (idField.equals("0")) {
				query = "insert into "
						+ tcversiontable
						+ "  (TCSystem,base_version,bsh_version,svn_version,status,comment) "
						+ "values ('" + tcsystem + "','" + baseversion + "','"
						+ bshversion + "','" + svnversion + "','" + status
						+ "','" + comment + "')";
				
				modifiedQuery = query.replaceAll("'", "''");
				
				
			} else {
				query = "update " + tcversiontable + "  set TCSystem='" + tcsystem
							+ "',base_version='" + baseversion
						+ "',bsh_version='" + bshversion
						+ "',svn_version='" + svnversion
						+ "',status='" + status
						+ "',comment='" + comment + "' where id='" + idField + "'";
				
				modifiedQuery = query.replaceAll("'", "''");
				
				tcHistoryQuery = "insert into "
						+ tchistorytable
						+ "  (ID,Type,ChangeString,ChangeDate,ChangeUser,Operation) "
						+ "values ('" + idField + "','TCVersion', '"+modifiedQuery+"', CONVERT(datetime,'" + sdf.format(now) + "',120), '"
						+ userName + "', 'Update')";
			
			}
			log.debug(query);
			connection = this.open();
			PreparedStatement pstmt = connection.prepareStatement(query);
			i = pstmt.executeUpdate();
			
			if(i == 1){
				if(idField.equals("0")){
				String newQuery = "select id FROM " + tcversiontable + " where tcsystem='"
						+ tcsystem + "' and base_version='" + baseversion
						+ "' and bsh_version='" + bshversion + "' and svn_version='"
						+ svnversion + "'";
				
				log.debug(newQuery);
				pstmt = connection.prepareStatement(newQuery);

				ResultSet newresultSet = pstmt.executeQuery();
				if (newresultSet.next()) {
					j = newresultSet.getInt(1);
				}
				
				tcHistoryQuery = "insert into "
						+ tchistorytable
						+ "  (ID,Type,ChangeString,ChangeDate,ChangeUser,Operation) "
						+ "values ('" + j + "','TCVersion', '"+modifiedQuery+"', CONVERT(datetime,'" + sdf.format(now) + "',120), '"
						+ userName + "', 'Insert')";
				
				}
				log.debug(tcHistoryQuery);
				pstmt = connection.prepareStatement(tcHistoryQuery);
				pstmt.executeUpdate();
			}
			
			log.debug("For tcsystem " + tcsystem + " " + i
					+ " row(s) is affected");
			this.updateTCVersion = true;
		} catch (Exception e) {
			e.getStackTrace();
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}
			try {
				if (connection!=null) {
					connection.close();
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}

	public String[] insertOrUpdateNXVersion(String idField, String nxfield,
			String typefield, String fromDateTime, String toDateTime,
			String bshnxversion, String splmnxversion, String minversion,
			String weblink, String userName) {

		String addedBy = userName;
		String modifiedBy = userName;
		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		String errorstr = "";
		String[] result = new String[2];
		String query = "";
		int i = 0;
		FileInputStream inStream = null;
		Connection connection = null;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			if (!nxfield.isEmpty() && !typefield.isEmpty()
					&& !bshnxversion.isEmpty() && !splmnxversion.isEmpty() && fromDateTime != null && toDateTime != null && !fromDateTime.isEmpty() && !toDateTime.isEmpty()) {

				connection = this.open();

				if (idField.equals("0")) {
					query = "insert into "
							+ nxversiontable
							+ "  (NX,Type,ValidFrom,ValidTo,BSH_NX_VERSION,SPLM_NX_VERSION,MinimumVersion,WebLink,AddedBy) "
							+ "values ('" + nxfield + "','" + typefield
							+ "',CONVERT(datetime,'" + fromDateTime
							+ "',120),CONVERT(datetime,'" + toDateTime + "',120),'"
							+ bshnxversion + "','" + splmnxversion + "','"
							+ minversion + "','" + weblink + "','" + addedBy
							+ "')";
				} else {
					query = "update " + nxversiontable + "  set NX='" + nxfield
							+ "',Type='" + typefield
							+ "',ValidFrom=CONVERT(datetime,'" + fromDateTime
							+ "',120),ValidTo=CONVERT(datetime,'" + toDateTime
							+ "',120),BSH_NX_VERSION='" + bshnxversion
							+ "',SPLM_NX_VERSION='" + splmnxversion
							+ "',MinimumVersion='" + minversion + "',WebLink='"
							+ weblink + "',ModifiedBy='" + modifiedBy
							+ "',DateModified=CONVERT(datetime,'" + sdf.format(now) + "',120) where ID='" + idField
							+ "'";
				}
				log.debug(query);
				PreparedStatement pstmt = connection.prepareStatement(query);
				i = pstmt.executeUpdate();
				log.debug("For NX " + nxfield + " " + i + " row(s) is affected");
				this.updateNXVersion = true;
			}
		} catch (Exception e) {
			e.getStackTrace();
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}

			try {
				if (connection!=null) {
					connection.close();
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}
	
	public String[] updateTCMsg(String msgidfield, String updatestarttcallowed,
			String updateonetime, String updatetype, String updatetcsystem, String fromDateTime, String toDateTime,
			 String updatemessage, String userName) {

		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		String errorstr = "";
		String[] result = new String[2];
		String query = "";
		String modifiedQuery = "";
		String tcHistoryQuery = "";
		int i = 0;
		FileInputStream inStream = null;
		Connection connection = null;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			if (!updatestarttcallowed.isEmpty() && !updateonetime.isEmpty()
					&& !updatetype.isEmpty() && !updatetcsystem.isEmpty() && fromDateTime != null && toDateTime != null && !fromDateTime.isEmpty() && !toDateTime.isEmpty() && !updatemessage.isEmpty()) {

				connection = this.open();

					query = "update " + tcmsgtable + "  set fromdate=CONVERT(datetime,'" + fromDateTime
							+ "',120),todate=CONVERT(datetime,'" + toDateTime
							+ "',120),tcsystem='" + updatetcsystem
							+ "',information='" + updatemessage
							+ "',starttcallowed='" + updatestarttcallowed + "',onetime='"
							+ updateonetime + "',type='" + updatetype
							+ "' where ID='" + msgidfield
							+ "'";
				}
				log.debug(query);
				PreparedStatement pstmt = connection.prepareStatement(query);
				i = pstmt.executeUpdate();
				
				modifiedQuery = query.replaceAll("'", "''");
				tcHistoryQuery = "insert into "
						+ tchistorytable
						+ "  (ID,Type,ChangeString,ChangeDate,ChangeUser,Operation) "
						+ "values ('" + msgidfield + "','TCMsg', '"+modifiedQuery+"', CONVERT(datetime,'" + sdf.format(now) + "',120), '"
						+ userName + "', 'Update')";
				log.debug(tcHistoryQuery);
				pstmt = connection.prepareStatement(tcHistoryQuery);
				pstmt.executeUpdate();
				
				log.debug("For TCMsg " + updatetcsystem + " " + i + " row(s) is affected");
				this.updateActualInformationItems = true;
			
		} catch (Exception e) {
			e.getStackTrace();
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}

			try {
				if (connection!=null) {
					connection.close();
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}
	
	public String[] insertTCHostTable(String tcsite,String workstation ) {

		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		String errorstr = "";
		String[] result = new String[2];
		String query = "";
		int i = 0;
		FileInputStream inStream = null;
		Connection connection = null;
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		query = "select Count FROM " + tchosttable + " where Workstation='"
				+ workstation + "' and TCSite='" + tcsite + "'";
		log.debug(query);
		try {
			if (workstation != null && tcsite != null && !workstation.isEmpty() && !tcsite.isEmpty()) {

				connection = this.open();
				PreparedStatement pstmt = connection.prepareStatement(query);

				ResultSet resultSet = pstmt.executeQuery();
				if (resultSet.next()) {
					i = resultSet.getInt(1);
				}

				if (i == 0) {
					i=1;
					query = "insert into "
							+ tchosttable
							+ "  (Workstation,TCSite,LastLogin,Count) "
							+ "values ('" + workstation + "','" + tcsite
							+ "',CONVERT(datetime,'" + sdf.format(now)
							+ "',120),'"
							+ i
							+ "')";
				} else {
					i=i+1;
					query = "update " + tchosttable + "  set LastLogin=CONVERT(datetime,'" + sdf.format(now) + "',120), Count='" + i
							+ "' where Workstation='" + workstation
							+ "' and TCSite='"+ tcsite
							+ "'";
				}
				log.debug(query);
				pstmt = connection.prepareStatement(query);
				i = pstmt.executeUpdate();
				log.debug("For Workstation: "+ workstation + " and TCSite: "+ tcsite +" of TCHostTable " + i + " row(s) is affected");
				this.updateNXVersion = true;
			}
		} catch (Exception e) {
			e.getStackTrace();
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}

			try {
				if (connection!=null) {
					connection.close();
				}
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}

	public BufferedImage scaleImage(BufferedImage image) {
		float factor = 1;
		if (image.getWidth() > imgrec.width) {
			factor = (float) (imgrec.width * 1.0f / image.getWidth() * 1.0f);
		}
		if (image.getHeight() > imgrec.height) {
			float factortemp = (float) (imgrec.height * 1.0f
					/ image.getHeight() * 1.0f);
			if (factortemp < factor) {
				factor = factortemp;
			}
		}
		/*
		 * Image temp = image.getScaledInstance(Math.round(image.getWidth() *
		 * factor), Math.round(image.getHeight() * factor), Image.SCALE_FAST);
		 * 
		 * int w = temp.getWidth(null); int h = temp.getHeight(null); int type =
		 * BufferedImage.TYPE_INT_RGB; BufferedImage out = new BufferedImage(w,
		 * h, type); Graphics2D g2 = out.createGraphics(); g2.drawImage(temp, 0,
		 * 0, null); g2.dispose();
		 */

		AffineTransform af = new AffineTransform();
		af.scale(factor, factor);

		AffineTransformOp operation = new AffineTransformOp(af,
				AffineTransformOp.TYPE_NEAREST_NEIGHBOR);
		BufferedImage out = operation.filter(image, null);

		return out;
	}

	/**
	 * Create the database connection and get all BSH actual information items.
	 *
	 * @param args
	 *            -host - Database host name -port - Database port number -user
	 *            - Database user name -password - Database user password
	 * @throws InterruptedException
	 * @throws ClassNotFoundException
	 * @throws SQLException
	 * @throws IOException
	 */
	public static void main(String[] args) throws InterruptedException,
			ClassNotFoundException, IOException {
		String host = null;
		int port = -1;
		String user = null;
		String password = null;
		Connection connection = null;
		String type = "";

		// Get input parameters
		for (int i = 0; i < args.length; i++) {
			String arg = args[i];

			if (arg.equals("-host") && (i + 1 < args.length)
					&& (args[i + 1].startsWith("-") == false)) {
				host = args[++i];
			} else if (arg.equals("-port") && (i + 1 < args.length)
					&& (args[i + 1].startsWith("-") == false)) {
				port = Integer.parseInt(args[++i]);
			} else if (arg.equals("-user") && (i + 1 < args.length)
					&& (args[i + 1].startsWith("-") == false)) {
				user = args[++i];
			} else if (arg.equals("-password") && (i + 1 < args.length)
					&& (args[i + 1].startsWith("-") == false)) {
				password = args[++i];
			} else if (arg.equals("-type") && (i + 1 < args.length)
					&& (args[i + 1].startsWith("-") == false)) {
				type = args[++i];
			}
		}

		// Check input parameters
		if (host == null || port == -1 || user == null || password == null) {
			log.debug("Database - Create a database connection and get BSH all actual information items.\n");
			log.debug("usage: Database");
			log.debug("\t-host     <Database host name>");
			log.debug("\t-port     <Database port number>");
			log.debug("\t-user     <Database user name>");
			log.debug("\t-password <Database user password\n");
			log.debug("\t-type <Database type (mysql / mssql)\n");
		} else {
			PreparedStatement pstmt = null;
			if (type.equalsIgnoreCase("mysql")) {
				String databaseName = "bshinfo";
				Database dao = new Database(host, port, type, databaseName,
						user, password, "e:/temp/", -1);
				int loop = 1;
				while (loop == 1) {
					ArrayList<BSHActualInformationItem> aIIList = dao
							.ActualInformationItems(null);

					for (BSHActualInformationItem dataSet : aIIList) {
						log.debug(dataSet);
					}

					log.debug("Found " + aIIList.size() + " item(s).");
					Thread.sleep(4000);
				}
			} else if (type.equalsIgnoreCase("mssql")) {
				String databaseName = "NXMCAD";
				Database dao = new Database(host, port, type, databaseName,
						user, password, "e:/temp/", -1);

				try {
					connection = dao.open();
					// Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
					// Connection conn =
					// DriverManager.getConnection(url,user=bsh_info_user;password=Z}UjjvJ5);

					log.debug("connection created");

					// Statement st = dao.connection.createStatement();
					// String sql =
					// "select count(*) from PLMsupportDB.dbo.tcmsg";
					// ResultSet rs = st.executeQuery(sql);
					// while (rs.next()) {
					// log.debug("Count: " + rs.getString(1));
					// // log.debug("Address : "+rs.getString(2));
					// }
					//
					String query = "INSERT INTO "
							+ dao.tcmsgtable
							+ " (id,fromdate,todate,tcsystem,information,starttcallowed,onetime,type,image,imagetype)"
							+ " VALUES (?,?,?,?,?,?,?,?,?,?)";
					pstmt = connection.prepareStatement(query);
					FileInputStream inStream = new FileInputStream(new File(
							"e:\\temp\\1.png"));
					Timestamp sqldate = new Timestamp(
							new java.util.Date().getTime());
					Timestamp sqldate2 = new Timestamp(
							new java.util.Date().getTime() + 1000000000);
					pstmt.setInt(1, 8);
					pstmt.setTimestamp(2, sqldate);
					pstmt.setTimestamp(3, sqldate2);
					pstmt.setString(4, "plmd10");
					pstmt.setString(5, "This are testinformations");
					pstmt.setInt(6, 1);
					pstmt.setInt(7, 0);
					pstmt.setString(8, "info");

					pstmt.setBinaryStream(9, inStream);
					pstmt.setString(10, "png");

					int i = pstmt.executeUpdate();
					log.debug(i);
					inStream.close();
				} catch (SQLException sqle) {
					log.debug(sqle.getMessage());

				} finally {
					if (pstmt != null)
						try {
							pstmt.close();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
					if (connection != null)
						try {
							connection.close();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
				}

				try {
					connection = dao.open();
					dao.getImageDataFromDB("newer.png", "png", " id=1",
							connection);
					dao.close(connection);
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
					dao.close(connection);
				}

			}

		}
	}

	public void setImagePath(String realPath) {
		this.imagepath = realPath;
	}

	public String getImagePath() {
		if (this.imagepath == null) {
			return "";
		}
		return this.imagepath;
	}

	public String getImagepath() {
		return imagepath;
	}

	public void killThread() {
		this.runthread = false;
		myThread.db.runthread = false;

	}

	public void checkThread() {
		if (myThread.isAlive()) {
			return;
		} else {
			this.startThread();
		}
	};

	public synchronized String[] deleteAktualInformation(int id, String userName) {
		int i = 0;
		String errorstr = "";
		String[] result = new String[2];
		String modifiedQuery = "";
		String tcHistoryQuery = "";
		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		String query = "DELETE FROM " + tcmsgtable + " where id=" + id;
		modifiedQuery = query.replaceAll("'", "''");
		FileInputStream inStream = null;
		try {
			Connection connection = this.open();
			PreparedStatement pstmt = connection.prepareStatement(query);

			i = pstmt.executeUpdate();
			log.debug("delete " + i + " row(s)");
			
			if(i == 1){
				tcHistoryQuery = "insert into "
						+ tchistorytable
						+ "  (ID,Type,ChangeString,ChangeDate,ChangeUser,Operation) "
						+ "values ('" + id + "','TCMsg', '"+modifiedQuery+"', CONVERT(datetime,'" + sdf.format(now) + "',120), '"
						+ userName + "', 'Delete')";
				log.debug(tcHistoryQuery);
				pstmt = connection.prepareStatement(tcHistoryQuery);
				pstmt.executeUpdate();
			}

			for (int j = 0; j < this.actualInformationItems.size(); j++) {
				if (this.actualInformationItems.get(j).getID() == id) {
					this.actualInformationItems.remove(j);
					break;
				}
			}

		} catch (Exception e) {
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}

	public class ReloadThread extends Thread {
		private Database db;
		private int intervall;

		public ReloadThread(Database db, int intervall) {
			this.db = db;
			this.intervall = intervall;
		}

		@Override
		public void run() {
			synchronized (this) {
				int counter = 0;
				while (db.runthread) {
					counter++;
					log.trace(counter);
					if (counter % 10 == 0) {
						counter = 0;
						log.debug("thread aktive ( " + this.toString() + " )");
					}

					if (db.timeOfLastUpdate == 0
							|| (new java.util.Date()).getTime() > (db.timeOfLastUpdate + intervall)
							|| db.getReload()) {
						log.debug("Load data");
						try {
							Connection connection = db.open();
							ArrayList<BSHActualInformationItem> actualInformationItems = db
									.loadActualInformationItems(connection);

							for (BSHActualInformationItem temp : actualInformationItems) {
								String imgurl = db.getImageDataFromDB(
										"" + temp.getID(), temp.getImageType(),
										" id=" + temp.getID(), connection);
								if (imgurl != null) {
									temp.setImageUrl(imgurl);
								}
							}

							ArrayList<NXVersion> actualNXVersionItems = db
									.loadNXVersionItems(connection);
							db.ActualNXVersionItems(actualNXVersionItems);
							
							ArrayList<TCHistory> actualTCHistoryItems = db
									.loadTCHistoryItems(connection);
							db.ActualTCHistoryItems(actualTCHistoryItems);
							
							ArrayList<TCHost> actualTCHostItems = db
									.loadTCHostItems(connection);
							db.ActualTCHostItems(actualTCHostItems);

							ArrayList<TCVersion> actualTCVersionItems = db
									.loadTCVersionItems(connection);
							db.ActualTCVersionItems(actualTCVersionItems);

							db.ActualInformationItems(actualInformationItems);
							db.close(connection);
							if (db.getReload()) {
								db.setReload(false);
							}
							db.timeOfLastUpdate = (new java.util.Date())
									.getTime();
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						} finally {
							db.close(null);
						}
					} else {
						if (db.updateTCVersion) {
							Connection connection;
							db.updateTCVersion = false;
							try {
								connection = db.open();
								ArrayList<TCVersion> actualTCVersionItems = db
										.loadTCVersionItems(connection);
								db.ActualTCVersionItems(actualTCVersionItems);
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							} finally {
								db.close(null);
							}
						}
						if (db.updateNXVersion) {
							Connection connection;
							db.updateNXVersion = false;
							try {
								connection = db.open();
								ArrayList<NXVersion> actualNXVersionItems = db
										.loadNXVersionItems(connection);
								db.ActualNXVersionItems(actualNXVersionItems);
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							} finally {
								db.close(null);
							}
						}
						if (db.updateActualInformationItems) {
							Connection connection;
							db.updateActualInformationItems = false;
							try {
								connection = db.open();
								ArrayList<TCVersion> actualTCVersionItems = db
										.loadTCVersionItems(connection);
								db.ActualTCVersionItems(actualTCVersionItems);
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							} finally {
								db.close(null);
							}
						}

					}

					Level temp = log.getEffectiveLevel();

					temp.isGreaterOrEqual(Level.DEBUG);
					if (temp.isGreaterOrEqual(Level.TRACE)) {
						ArrayList<BSHActualInformationItem> actualInformationItems = db
								.ActualInformationItems(null);
						String logstr = "count of actual Information: "
								+ actualInformationItems.size();
						if (actualInformationItems.size() > 0) {
							logstr = logstr + " with id";
							if (actualInformationItems.size() > 1) {
								logstr = logstr + "s";
							}
							logstr = logstr + ": ";
							for (BSHActualInformationItem item : actualInformationItems) {
								logstr = logstr + " " + item.getID();
							}
						}

					}

					try {
						wait(2000l);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
		}
	}

	public String[] deleteTCVersion(int id, String userName) {
		int i = 0;
		String errorstr = "";
		String[] result = new String[2];
		String modifiedQuery = "";
		String tcHistoryQuery = "";
		java.util.Date now = new GregorianCalendar(Locale.GERMANY).getTime();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		
		String query = "DELETE FROM " + tcversiontable + " where id=" + id;
		modifiedQuery = query.replaceAll("'", "''");
		FileInputStream inStream = null;
		
		try {
			Connection connection = this.open();
			PreparedStatement pstmt = connection.prepareStatement(query);

			i = pstmt.executeUpdate();
			log.debug("delete " + i + " row(s)");

			if(i == 1){
				tcHistoryQuery = "insert into "
						+ tchistorytable
						+ "  (ID,Type,ChangeString,ChangeDate,ChangeUser,Operation) "
						+ "values ('" + id + "','TCVersion', '"+modifiedQuery+"', CONVERT(datetime,'" + sdf.format(now) + "',120), '"
						+ userName + "', 'Delete')";
				log.debug(tcHistoryQuery);
				pstmt = connection.prepareStatement(tcHistoryQuery);
				pstmt.executeUpdate();
			}

			for (int j = 0; j < this.actualTCVersionItems.size(); j++) {
				if (this.actualTCVersionItems.get(j).getID() == id) {
					this.actualTCVersionItems.remove(j);
					break;
				}
			}

		} catch (Exception e) {
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}

	public String[] deleteNXVersion(int id) {
		int i = 0;
		String errorstr = "";
		String[] result = new String[2];
		String query = "DELETE FROM " + nxversiontable + " where ID=" + id;
		FileInputStream inStream = null;
		try {
			Connection connection = this.open();
			PreparedStatement pstmt = connection.prepareStatement(query);

			i = pstmt.executeUpdate();
			log.debug("delete " + i + " row(s)");

			for (int j = 0; j < this.actualNXVersionItems.size(); j++) {
				if (this.actualNXVersionItems.get(j).getID() == id) {
					this.actualNXVersionItems.remove(j);
					break;
				}
			}

		} catch (Exception e) {
			log.error(e.getMessage());
			for (StackTraceElement temp : e.getStackTrace()) {
				log.error(temp.toString());
				errorstr += temp.toString() + "\n";
			}
		} finally {
			if (inStream != null) {
				try {
					inStream.close();
				} catch (IOException e) {
					log.error(e.getMessage());
				}
			}
		}
		result[0] = i + "";
		result[1] = errorstr;
		return result;

	}

}
