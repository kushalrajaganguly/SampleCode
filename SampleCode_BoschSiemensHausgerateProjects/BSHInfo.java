/**
 * @file        BSHInfo.java
 *
 * @package     com.bsh.tc.bshinfo.servlet;
 *
 * @brief       BSHInfo servlet
 */
package com.bsh.tc.bshinfo.servlet;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.RSAPublicKeySpec;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeSet;

import javax.crypto.Cipher;
import javax.servlet.ServletConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRegistration;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.log4j.Logger;
//import org.apache.tomcat.util.http.fileupload.FileItem;
//import org.apache.tomcat.util.http.fileupload.disk.DiskFileItemFactory;
//import org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload;

















import com.bsh.tc.bshinfo.dao.BSHActualInformationItem;
import com.bsh.tc.bshinfo.dao.Database;
import com.bsh.tc.bshinfo.dao.NXVersion;
import com.bsh.tc.bshinfo.dao.TCVersion;
import com.bsh.tc.bshinfo.dao.UserRequest;
import com.bsh.tc.bshinfo.ldap.ValidServletUser;

/**
 * BSHInfo servlet implementation.
 *
 */
@WebServlet(description = "BSH Info")
@MultipartConfig
public class BSHInfo extends HttpServlet {
	private static org.apache.log4j.Logger log = Logger
			.getLogger(BSHInfo.class);
	private static Hashtable<String, ArrayList<ValidServletUser>> usersessions;
	/** BSH Version **/
	private static final String version = "1.2.2";
			
	private static final long serialVersionUID = Long.parseLong(version.replace(".", ""));
	// private static final String FILE_NAME = "bshinfo.xml";
	private static Database dao;
	private static String mappingname;
	public static HtmlFactory htmlfac;

	// Cache containing username and information ID
	private static HashMap<String, Integer> cache;
	private String VersionMissmatchMSG = "You should use a released Version of this client!";
	private String VersionMissmatchIMG = "info.png";
	private String VersionToOldIMG = "stop.png";
	private String VersionToOldMSG = "Please install a newer version of this client";
	private String VersionOldIMG = "warning.png";
	private String VersionOldMSG = "You use a older Version of this client. When you run in Problems install the new one";
	// private static final String LDAPGroupInfo = "BSH_S_BSHINFO";
	// private static final String LDAPGroupVersion = "BSH_S_BSHVERSION";

	public static String defaultimagepath = "";
	public static String[] LDAPGroups;

	private static String[] LDAPTCMsgGroupInfo; 	// = new String[]{"BSH_S_BSHINFO","BSH_S_BSHVERSION","BSH_V_AP2-PDM-CAD","BSH_V_AP2-PDM-CAD_Contributor"};
	private static String[] LDAPTCMsgGroupAdmin; 	// = new String[]{"BSH_S_BSHINFO"};
	private static String[] LDAPTCVerGroupInfo; 	// = new String[]{"BSH_S_BSHINFO","BSH_S_BSHVERSION","BSH_V_AP2-PDM-CAD","BSH_V_AP2-PDM-CAD_Contributor"};
	private static String[] LDAPTCVerGroupAdmin; 	// = new String[]{"BSH_S_BSHVERSION"};
	private static String[] LDAPNXGroupInfo;  		// = new String[]{"BSH_S_BSHINFO","BSH_S_BSHVERSION","BSH_V_AP2-PDM-CAD","BSH_V_AP2-PDM-CAD_Contributor"};
	private static String[] LDAPNXGroupAdmin; 		// = new String[]{"BSH_S_BSHVERSION"};

	static String publicKeyStr ="";
	static String loginUser ="";
	private static PrivateKey privateKey =null;
	/**
	 * Initialize servlet and open database connection.
	 *
	 * @param config
	 *            Servlet config
	 */
	@Override
	public void init(ServletConfig config) throws ServletException {
		super.init();
		log.debug("\n***************\nVersion:"+serialVersionUID+"\n***************");
		fillGroups(config);
		log.debug("initialisation of the servlet. Configurate DB Connection");
		/* Connect to DB */
		String db_host = config.getInitParameter("db_host");
		String db_port = config.getInitParameter("db_port");
		int db_port_number = Integer.parseInt(db_port);
		String db_user = config.getInitParameter("db_user");
		String db_password = config.getInitParameter("db_password");
		String db_type = config.getInitParameter("db_type");
		usersessions = new Hashtable<String, ArrayList<ValidServletUser>>();

		ServletRegistration temp = config.getServletContext()
				.getServletRegistrations().get("bshinfo");
		Collection<String> temp3 = temp.getMappings();
		if (temp3.size() > 0) {
			mappingname = (String) temp3.toArray()[0];
		}
				
		ServletContext context = config.getServletContext();
		String realPath = context.getRealPath("/");
		log.debug("contextpath:" + realPath + "mapping name:" + mappingname);
		
		replaceVersion(realPath,context);
		
		String databaseName = "";
		if (db_type.equalsIgnoreCase("mysql")) {
			databaseName = "bshinfo";
		} else if (db_type.equalsIgnoreCase("mssql")) {
			databaseName = "NXMCAD";
		}
		String delay = config.getInitParameter("threaddelay");
		int threaddelay = -1;
		if (delay != null) {
			threaddelay = Integer.parseInt(delay);
		}
		htmlfac = HtmlFactory.getInstance(context.getContextPath(),
				mappingname, realPath);

		dao = new Database(db_host, db_port_number, db_type, databaseName,
				db_user, db_password, "", threaddelay);
		cache = new HashMap<String, Integer>();
		if (dao.getImagePath() == "") {
			//dao.setImagePath(realPath+"/"+"msgimage");
			dao.setImagePath(realPath);
			dao.startThread();
		}
		defaultimagepath = realPath+"defaultimage";
		
		generateKey();
		
	}


	/**
	 * Get information from database and generate XML-file.
	 *
	 * @param request
	 *            Request from client with parameters "site" and "username"
	 * @param response
	 *            Response as XML-file
	 * 
	 * <br>
	 *            Requests are splittet with the values of the parameter method: <br>
	 *            =tc with the additional parameters: &site= &username= <br>
	 *            &hostname= =nx with the parameter &version=XX (e.g. NX10 or
	 *            NX8.5)
	 */
	@Override
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		Cookie[] cookies = request.getCookies();
		String token = "";
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				Cookie c = cookies[i];
				String name = c.getName();
				String value = c.getValue();
				if (name.equalsIgnoreCase("bshinfo")) {
					token = value;
					log.debug(name + " = " + value);
				} else {
					log.trace(name + " = " + value);
				}
			}
		}
		log.debug("new request from " + request.getRemoteHost() + " user: "
				+ request.getRemoteUser());

		UserRequest usreq = new UserRequest(request);

		/* Methods that are possible without login */
		if (request.getParameterMap().containsKey("method")) {
			String method = request.getParameter("method").toLowerCase();
			if (method != null) {
				if (method.equalsIgnoreCase("nx")
						|| method.equalsIgnoreCase("tc")
						|| method.equalsIgnoreCase("tcversion")) {
					answerVersionAndMessageRequest(method, usreq, request,
							response);
					return;
				} else if (method.equalsIgnoreCase("login")) {
					doLogin(request, response);
					return;
				} else if (method.equalsIgnoreCase("logout")) {
					doLogout(token, request, response);
					return;
				}
			}
		}

		/* Login necessary for following methods */
		if (token != "") {
			ValidServletUser user = isUserValid(token);
			
			if (user != null) {
				loginUser = (String) user.getUsername();
				boolean[] access = getAccessArray(user);
				log.debug("valid session");
				if (request.getParameterMap().containsKey("method")) {
					String method = request.getParameter("method")
							.toLowerCase();
					log.debug("method:" + method);
					if (method != null) {

						
	
						if (method.equalsIgnoreCase("tcMsgTable")
								&& (access[0] || access[1])) {
							response.getWriter().write(
									HtmlFactory.createOverviewSite(dao,
											"tcMsgTable", access[1], access));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("tcVersionTable")
								&& (access[2] || access[3])) {
							response.getWriter().write(
									HtmlFactory.createOverviewSite(dao,
											"tcVersionTable", access[3],
											access));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("tcHostTable")
								&& access[3]) {
							response.getWriter().write(
									HtmlFactory.createOverviewSite(dao,
											"tcHostTable", access[3],
											access));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("nxTable")
								&& (access[4] || access[5])) {
							response.getWriter().write(
									HtmlFactory.createOverviewSite(dao,
											"nxTable", access[5], access));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("tcHistoryTable")
								&& (access[1] || access[3])) {
							response.getWriter().write(
									HtmlFactory.createOverviewSite(dao,
											"tcHistoryTable", true, access));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("dbinserttcmsg")
								&& access[1]) {
							response.getWriter().write(
									HtmlFactory.createTCMsgInsertSite(access,
											null));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("dbinserttcversion")
								&& access[3]) {
							response.getWriter().write(
									HtmlFactory.createTCVersionInsertSite(
											access, null));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("dbinsertnxversion")
								&& access[5]) {
							response.getWriter().write(
									HtmlFactory.createNXVersionInsertSite(
											access, null));
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("tcmsgdata")) {
							/*
							 * this is never called cause is a post request look
							 * at dopost
							 */
							response.getWriter().close();
							return;
						} else if (method.equalsIgnoreCase("deleteactualInfo")
								&& access[1]) {
							if (request.getParameterMap().containsKey("id")) {
								String userName = (String) user.getUsername();
								String[] temp = dao.deleteAktualInformation(
										Integer.parseInt(request
												.getParameter("id")), userName);
								String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=tcMsgTable";
								response.getWriter().write(
										HtmlFactory.createDBInsertResultSite(
												temp, access, servleturl));
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("deleteTCVersion")
								&& access[3]) {
							if (request.getParameterMap().containsKey("id")) {
								String userName = (String) user.getUsername();
								String[] temp = dao.deleteTCVersion(Integer
										.parseInt(request.getParameter("id")),
										userName);
								String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=tcVersionTable";
								response.getWriter().write(
										HtmlFactory.createDBInsertResultSite(
												temp, access, servleturl));
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("deleteNXVersion")
								&& access[5]) {
							if (request.getParameterMap().containsKey("id")) {
								String[] temp = dao.deleteNXVersion(Integer
										.parseInt(request.getParameter("id")));
								String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=nxTable";
								response.getWriter().write(
										HtmlFactory.createDBInsertResultSite(
												temp, access, servleturl));
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("editactualInfo")
								&& access[1]) {
							if (request.getParameterMap().containsKey("id")) {
								BSHActualInformationItem tempmsg = null;
								int id = Integer.parseInt(request
										.getParameterMap().get("id")[0]);
								for (BSHActualInformationItem temp : dao
										.ActualInformationItems(null)) {
									if (temp.getID() == id) {
										tempmsg = temp;
										break;
									}
								}
								if (tempmsg != null) {
									Hashtable<String, String> params = tempmsg
											.getParams();
									response.getWriter().write(
											HtmlFactory
													.updateTCMsgInsertSite(
															access, params));
								} else {
									response.getWriter().write("not available");
								}
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("editTCVersion")
								&& access[3]) {
							if (request.getParameterMap().containsKey("id")) {
								TCVersion temptcv = null;
								int id = Integer.parseInt(request
										.getParameterMap().get("id")[0]);
								for (TCVersion temp : dao
										.ActualTCVersionItems(null)) {
									if (temp.getID() == id) {
										temptcv = temp;
										break;
									}
								}
								if (temptcv != null) {
									Hashtable<String, String> params = temptcv
											.getParams();
									response.getWriter().write(
											HtmlFactory
													.createTCVersionInsertSite(
															access, params));
								} else {
									response.getWriter().write("not available");
								}
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("editNXVersion")
								&& access[5]) {
							if (request.getParameterMap().containsKey("id")) {
								NXVersion tempnxv = null;
								int id = Integer.parseInt(request
										.getParameterMap().get("id")[0]);
								for (NXVersion temp : dao
										.ActualNXVersionItems(null)) {
									if (temp.getID() == id) {
										tempnxv = temp;
										break;
									}
								}
								if (tempnxv != null) {
									Hashtable<String, String> params = tempnxv
											.getParams();
									response.getWriter().write(
											HtmlFactory
													.createNXVersionInsertSite(
															access, params));
								} else {
									response.getWriter().write("not available");
								}
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("tcversdata")) {
							Map<String, String[]> paramap = request
									.getParameterMap();

							if (paramap.containsKey("tcidfield")
									&& paramap.containsKey("tcsystem")
									&& paramap.containsKey("baseversion")
									&& paramap.containsKey("bshversion")
									&& paramap.containsKey("svnversion")
									&& paramap.containsKey("status")
									&& paramap.containsKey("comment")) {

								String userName = (String) user.getUsername();
								String[] temp = dao.insertOrUpdateTCVersion(
										paramap.get("tcidfield")[0],
										paramap.get("tcsystem")[0],
										paramap.get("baseversion")[0],
										paramap.get("bshversion")[0],
										paramap.get("svnversion")[0],
										paramap.get("status")[0],
										paramap.get("comment")[0], userName);
								log.debug("tcversdata ::::::::::::::"+paramap.get("tcidfield")[0]);
								String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=tcVersionTable";
								response.getWriter().write(
										HtmlFactory.createDBInsertResultSite(
												temp, access, servleturl));
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("nxversdata")) {
							Map<String, String[]> paramap = request
									.getParameterMap();

							if (paramap.containsKey("idfield")
									&& paramap.containsKey("nxfield")
									&& paramap.containsKey("typefield")
									&& paramap.containsKey("fromDate")
									&& paramap.containsKey("begin")
									&& paramap.containsKey("toDate")
									&& paramap.containsKey("end")
									&& paramap.containsKey("bshnxversion")
									&& paramap.containsKey("splmnxversion")
									&& paramap.containsKey("minversion")
									&& paramap.containsKey("weblink")) {

								SimpleDateFormat fromUser = new SimpleDateFormat(
										"dd.MM.yyyy");
								SimpleDateFormat myFormat = new SimpleDateFormat(
										"yyyy-MM-dd");
								String reformattedStr1 = null;
								String reformattedStr2 = null;

								try {

									reformattedStr1 = myFormat.format(fromUser
											.parse(paramap.get("fromDate")[0]));
									reformattedStr2 = myFormat.format(fromUser
											.parse(paramap.get("toDate")[0]));

								} catch (ParseException e) {
									e.printStackTrace();
								}

								String fromTimeStamp = reformattedStr1 + " "
										+ paramap.get("begin")[0];
								String toTimeStamp = reformattedStr2 + " "
										+ paramap.get("end")[0];
								String userName = (String) user.getUsername();
								String[] temp = dao.insertOrUpdateNXVersion(
										paramap.get("idfield")[0],
										paramap.get("nxfield")[0],
										paramap.get("typefield")[0],
										fromTimeStamp, toTimeStamp,
										paramap.get("bshnxversion")[0],
										paramap.get("splmnxversion")[0],
										paramap.get("minversion")[0],
										paramap.get("weblink")[0], userName);
								log.debug("nxversdata ::::::::::::::"+paramap.get("idfield")[0]);
								String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=nxTable";
								response.getWriter().write(
										HtmlFactory.createDBInsertResultSite(
												temp, access, servleturl));
								response.getWriter().close();
								return;
							}
						} else if (method.equalsIgnoreCase("updatetcmsgdata")) {
							Map<String, String[]> paramap = request
									.getParameterMap();

							if (paramap.containsKey("msgidfield")
									&& paramap.containsKey("updatestarttcallowed")
									&& paramap.containsKey("updateonetime")
									&& paramap.containsKey("updatetype")
									&& paramap.containsKey("updatetcsystem")
									&& paramap.containsKey("updatefromdate")
									&& paramap.containsKey("updatefromtime")
									&& paramap.containsKey("updatetodate")
									&& paramap.containsKey("updatetotime")
									&& paramap.containsKey("updatemessage")) {

								SimpleDateFormat fromUser = new SimpleDateFormat(
										"dd.MM.yyyy");
								SimpleDateFormat myFormat = new SimpleDateFormat(
										"yyyy-MM-dd");
								String reformattedStr1 = null;
								String reformattedStr2 = null;

								try {

									reformattedStr1 = myFormat.format(fromUser
											.parse(paramap.get("updatefromdate")[0]));
									reformattedStr2 = myFormat.format(fromUser
											.parse(paramap.get("updatetodate")[0]));

								} catch (ParseException e) {
									e.printStackTrace();
								}

								String fromTimeStamp = reformattedStr1 + " "
										+ paramap.get("updatefromtime")[0];
								String toTimeStamp = reformattedStr2 + " "
										+ paramap.get("updatetotime")[0];
								
								String userName = (String) user.getUsername();
								
								String[] temp = dao.updateTCMsg(
										paramap.get("msgidfield")[0],
										paramap.get("updatestarttcallowed")[0],
										paramap.get("updateonetime")[0],
										paramap.get("updatetype")[0],
										paramap.get("updatetcsystem")[0],
										fromTimeStamp, toTimeStamp,									
										paramap.get("updatemessage")[0], userName);
								log.debug("updatetcmsg ::::::::::::::"+paramap.get("msgidfield")[0]);
								String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=tcMsgTable";
								response.getWriter().write(
										HtmlFactory.createDBInsertResultSite(
												temp, access, servleturl));
								response.getWriter().close();
								return;
							}
						}
						
					}
				}

				// response.sendRedirect(request.getContextPath()+mappingname);

				
				response.getWriter()
						.write(HtmlFactory.createOverviewSite(dao, "", true,
								access));
				response.getWriter().close();
				return;

			}
		}

		// String name = request.getParameter("cookieName");
		// if (name != null && name.length() > 0) {
		// String value = "eroigh qoierjgp 3";
		// Cookie c = new Cookie(name, value);
		//
		// response.addCookie(c);
		// log.debug("add cookie");
		// }

		response.getWriter().write(HtmlFactory.createDefaultSite());

	}

	private boolean[] getAccessArray(ValidServletUser user) {
		boolean[] access=new boolean[6];
		access[0]=user.checkIsInGroups(LDAPTCMsgGroupInfo);
		access[1]=user.checkIsInGroups(LDAPTCMsgGroupAdmin);
		access[2]=user.checkIsInGroups(LDAPTCVerGroupInfo);
		access[3]=user.checkIsInGroups(LDAPTCVerGroupAdmin);
		access[4]=user.checkIsInGroups(LDAPNXGroupInfo);
		access[5]=user.checkIsInGroups(LDAPNXGroupAdmin);
//		LDAPGroups = new String[6];
//		LDAPGroups[0] = LDAPTCMsgGroupInfo;
//		LDAPGroups[1] = LDAPTCMsgGroupAdmin;
//		LDAPGroups[2] = LDAPTCVerGroupInfo;
//		LDAPGroups[3] = LDAPTCVerGroupAdmin;
//		LDAPGroups[4] = LDAPNXGroupInfo;
//		LDAPGroups[5] = LDAPNXGroupAdmin;
		return access;
	}


	
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		log.debug("a post request");
		Hashtable<String, String> params = new Hashtable<String, String>();
		File imagefile = null;

		Cookie[] cookies = request.getCookies();
		String token = "";
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				Cookie c = cookies[i];
				String name = c.getName();
				String value = c.getValue();
				if (name.equalsIgnoreCase("bshinfo")) {
					token = value;
					log.debug(name + " = " + value);
				} else {
					log.trace(name + " = " + value);
				}
			}
		}

		if (token != "") {
			ValidServletUser user = isUserValid(token);
			if (user != null) {
				boolean[] access = getAccessArray(user);
//				boolean[] access = user.checkGroups(LDAPGroups);
				try {
					DiskFileItemFactory diskff = new DiskFileItemFactory();
					List<FileItem> items = new ServletFileUpload(diskff)
							.parseRequest(request);
					for (FileItem item : items) {
						String fieldName;
						if (item.isFormField()) {
							fieldName = item.getFieldName();
							String fieldValue = item.getString();
							params.put(fieldName, fieldValue);
							
						} else {
							// Process form file field (input type="file").
							fieldName = item.getFieldName();
							String fileName = item.getName();
							
							if(fileName.lastIndexOf("\\") != -1)
							{
							 fileName=fileName.substring(fileName.lastIndexOf("\\")+1);
							}
							
							String fileextension = fileName.substring(fileName
									.lastIndexOf(".") + 1);
							// InputStream fileContent = item.getInputStream();
							if (fileName == "") {
								continue;
							}
							imagefile = new File(defaultimagepath
									+ File.separator + fileName);
							imagefile.exists();
							imagefile.delete();
							imagefile.createNewFile();
							item.write(imagefile);
							params.put("filename", fileName);
							params.put("fileextension", fileextension);
						}
					}
					
					if(params.containsKey("selectedImg") && !params.get("selectedImg").equals("otherImage")){
						String fileName =params.get("selectedImg");
						String fileextension = fileName.substring(fileName
								.lastIndexOf(".") + 1);
						imagefile = new File(defaultimagepath
								+ File.separator + fileName);
						params.put("filename", fileName);
						params.put("fileextension", fileextension);
						
					}
					
				} catch (Exception e) {
					throw new ServletException(e.getMessage(), e);
				}

				for (String name : params.keySet()) {
					log.debug("-" + name + " = " + params.get(name));
				}

				if (params.containsKey("method")) {
					String html = "";
					PrintWriter writer = response.getWriter();
					if (params.get("method").equalsIgnoreCase("tcmsgdata")) {
						log.debug("get a tc message to insert into db");
						if (imagefile != null && imagefile.getUsableSpace() > 0) {
							String userName = (String) user.getUsername();
							String[] res = dao.saveActualInformationToDB(
									imagefile, params, userName);
							String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname +"?method=tcMsgTable";
							html = HtmlFactory.createDBInsertResultSite(res,
									access, servleturl);
						}
					}
					writer.write(html);
					writer.close();

				} else {
					response.sendRedirect("/method=data");
					return;
				}

			}
		}
	}

	// private static String getSubmittedFileName(Part part) {
	// for (String cd : part.getHeader("content-disposition").split(";")) {
	// if (cd.trim().startsWith("filename")) {
	// String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"",
	// "");
	// return fileName.substring(fileName.lastIndexOf('/') +
	// 1).substring(fileName.lastIndexOf('\\') + 1); // MSIE
	// // fix.
	// }
	// }
	// return null;
	// }

	private void answerVersionAndMessageRequest(String method,
			UserRequest usreq, HttpServletRequest request,
			HttpServletResponse response) throws IOException {
		PrintWriter writer = response.getWriter();

		
		//
		// version-check for NX
		//
		if (method.equalsIgnoreCase("nx")) {
			String version = usreq.getParameter("version");
			String res = "";
			ArrayList<NXVersion> temp = dao.ActualNXVersionItems(null); // get
																		// all
																		// versions
																		// (filled
																		// by
																		// thread
																		// so
																		// delay
																		// is
																		// possible)
			int count = 0;
			while (temp == null && count++ < 5) {
				log.debug("loop");
				try {
					Thread.sleep(1000);
				} catch (InterruptedException e) {
					log.error(e.getMessage());
				}
				temp = dao.ActualNXVersionItems(null);
			}
			Date actual = new GregorianCalendar(Locale.GERMANY).getTime();
			if (temp != null) {
				for (NXVersion iter : temp) {

					if (iter.nx.equalsIgnoreCase(version)) {
						if (iter.validFrom.getTime() < actual.getTime()) {
							if (iter.validTo.getTime() > actual.getTime()) {
								res += iter.getTextAnswerLine();
							}
						}
					}
				}
			}
			if (res != null && res != "") {
				writer.write(res);
				writer.close();
			}
			//
			// version-check for TEAMCENTER
			//
		} else if (method.equalsIgnoreCase("tc")) {
//			String[] tmp = dao.insertTCHostTable(usreq.getSite(), usreq.getHostname());
			// ArrayList<BSHActualInformationItem> temp =
			// dao.getCurrentActualInformationItems();
			// int count = 0;
			// while (temp == null && count++ < 5) {
			// log.debug("loop");
			// try {
			// Thread.sleep(1000);
			// } catch (InterruptedException e) {
			// Auto-generated catch block
			// e.printStackTrace();
			// }
			// temp = dao.ActualInformationItems(null);
			// }
			String baseversion = usreq.getParameter("baseversion");
			String bshversion = usreq.getParameter("bshversion");
			String svnversion = usreq.getParameter("svnversion");
			String xml = createXMLForTC(usreq.getSite(), usreq.getUsername(),
					baseversion, bshversion, svnversion);
			writer.write(xml);
			writer.close();
			
			if (usreq.getSite()!="" && usreq.getHostname()!="") {
				String[] temp = dao.insertTCHostTable(usreq.getSite().toUpperCase(),usreq.getHostname().toUpperCase());
				if (Integer.parseInt(temp[0])!=1) {
					log.debug("inserterror in TCHostTable");
				}
			}
			
			// } else if (method.equalsIgnoreCase("data")) {
			//
			// //
			// // String res = HtmlFactory.createTCMsgInsertSite(null);
			// // writer.write(res);
			// } else if (method.equalsIgnoreCase("tcversion")) {

		} else {
			writer.write("Servlet alive");
			writer.close();
		}
		
		

	}

	/**
	 * 
	 * @param site
	 *            a TC System
	 * @param username
	 *            the OS username on clientsite
	 * @param version
	 *            the TC client version
	 * @param svnversion
	 * @param bshversion
	 * @return xml - String with bshinfos as the root elem <br>
	 *         then one or more "bshinfo" - elem/s with following elements: <br>
	 *         message: message that shoult be shown in the frame <br>
	 *         imagename: an url to the server where the image can be downloaded <br>
	 *         level: Level of the message e.g. warning, info etc. <br>
	 *         starttcallowed: is it allowed to start the TC client <br>
	 *         onetime: show this message only onetime
	 */
	public String createXMLForTC(String site, String username,
			String baseversion, String bshversion, String svnversion) {
		String xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
		xml += "<bshinfos>\n";
		Date actualDate = new Date();

		// Get all actual information items
		ArrayList<BSHActualInformationItem> actualInformationItems = dao
				.getCurrentActualInformationItems();
		for (BSHActualInformationItem actualInformationItem : actualInformationItems) {
			Date fromDate = actualInformationItem.getFromDate();
			Date toDate = actualInformationItem.getToDate();
			String tcSystem = actualInformationItem.getTCSystem();

			// Check if the date is valid for the site
			if ((fromDate == null || actualDate.after(fromDate))
					&& (toDate == null || actualDate.before(toDate))
					&& tcSystem.equalsIgnoreCase(site)) {
				Integer id = Integer.valueOf(actualInformationItem.getID());

				String message = actualInformationItem.getMessage();
				String imageurl = actualInformationItem.getImageUrl();

				String level = actualInformationItem.getType();
				boolean startTCAllowed = actualInformationItem
						.isStartTCAllowed();
				boolean oneTime = actualInformationItem.isOneTime();

				// Check if site_user is in cache
				String siteUser = actualInformationItem.getID() + "_"
						+ username;

				boolean siteUserInCache = cache.containsKey(siteUser);

				// The site with user name is not in cache
				if (siteUserInCache == false) {
					cache.put(siteUser, id);
				}

				String imageName;
				if (imageurl != null && imageurl != "") {
					imageName = imageurl;
				} else {
					imageName = "info.png";
				}

				if (siteUserInCache && oneTime) {
					log.debug("user:" + username
							+ " already gets message with id:"
							+ actualInformationItem.getID());
				} else {
					xml += "\t<bshinfo>\n";
					xml += "\t\t<message>" + message + "</message>\n";
					xml += "\t\t<imagename>" + imageName + "</imagename>\n";
					xml += "\t\t<level>" + level + "</level>\n";
					xml += "\t\t<starttcallowed>" + startTCAllowed
							+ "</starttcallowed>\n";
					xml += "\t\t<onetime>" + oneTime + "</onetime>\n";
					// xml += "\t\t<cache>" + siteUserInCache + "</cache>\n";
					xml += "\t</bshinfo>\n";
				}
				continue;
			}
		}
		int sw = -1;
		// Now get Version informations!
		if (baseversion != null && bshversion != null && svnversion != null) {
			for (TCVersion temp : dao.ActualTCVersionItems(null)) {
				System.out.println("Vergl.: "
						+ temp.checkTCVersion(site, baseversion, bshversion,
								svnversion));
				if (temp.tcSystem.equalsIgnoreCase(site)) {
					sw = temp.checkTCVersion(site, baseversion, bshversion,
							svnversion);
					if (sw > 0) {
						break;
					}
				}
			}
		}

		switch (sw) {
		case TCVersion.StatusToOld: {
			xml += "\t<bshinfo>\n";
			xml += "\t\t<message>" + VersionToOldMSG + "</message>\n";
			xml += "\t\t<imagename>" + VersionToOldIMG + "</imagename>\n";
			xml += "\t\t<level>version</level>\n";
			xml += "\t\t<starttcallowed>false</starttcallowed>\n";
			xml += "\t\t<onetime>false</onetime>\n";
			// xml += "\t\t<cache>" + siteUserInCache +
			// "</cache>\n";
			xml += "\t</bshinfo>\n";
			break;
		}
		case TCVersion.StatusDepricated: {
			xml += "\t<bshinfo>\n";
			xml += "\t\t<message>" + VersionOldMSG + "</message>\n";
			xml += "\t\t<imagename>" + VersionOldIMG + "</imagename>\n";
			xml += "\t\t<level>version</level>\n";
			xml += "\t\t<starttcallowed>true</starttcallowed>\n";
			xml += "\t\t<onetime>false</onetime>\n";
			// xml += "\t\t<cache>" + siteUserInCache +
			// "</cache>\n";
			xml += "\t</bshinfo>\n";
			break;
		}
		case 0: {
			xml += "\t<bshinfo>\n";
			xml += "\t\t<message>" + VersionMissmatchMSG + "</message>\n";
			xml += "\t\t<imagename>" + VersionMissmatchIMG + "</imagename>\n";
			xml += "\t\t<level>version</level>\n";
			xml += "\t\t<starttcallowed>true</starttcallowed>\n";
			xml += "\t\t<onetime>false</onetime>\n";
			// xml += "\t\t<cache>" + siteUserInCache +
			// "</cache>\n";
			xml += "\t</bshinfo>\n";
			break;
		}
		default: {
			break;
		}
		}

		xml += "</bshinfos>\n";
		return xml;

	}

	/**
	 * Destroy servlet and close database connection.
	 */
	@Override
	public void destroy() {
		super.destroy();
		log.info("kill existing threads");
		dao.killThread();
	}

	private static void addSession(ValidServletUser user) {
		ArrayList<ValidServletUser> temp = usersessions.get(user.getToken());
		if (temp == null) {
			temp = new ArrayList<ValidServletUser>();
		}
		if (!temp.contains(user)) {
			temp.add(user);
		}
		usersessions.put(user.getToken(), temp);
	}

	
	private void fillGroups(ServletConfig config) {
		
		LDAPTCMsgGroupInfo = config.getInitParameter("LDAPTCMsgGroupInfo").split(",");
		LDAPTCMsgGroupAdmin = config.getInitParameter("LDAPTCMsgGroupAdmin").split(",");
		LDAPTCVerGroupInfo = config.getInitParameter("LDAPTCVerGroupInfo").split(",");
		LDAPTCVerGroupAdmin = config.getInitParameter("LDAPTCVerGroupAdmin").split(",");
		LDAPNXGroupInfo = config.getInitParameter("LDAPNXGroupInfo").split(",");
		LDAPNXGroupAdmin = config.getInitParameter("LDAPNXGroupAdmin").split(",");

		TreeSet<String> temp1 = new TreeSet<String>();
		temp1.addAll(Arrays.asList(LDAPTCMsgGroupInfo));
		temp1.addAll(Arrays.asList(LDAPTCMsgGroupAdmin));
		temp1.addAll(Arrays.asList(LDAPTCVerGroupInfo));
		temp1.addAll(Arrays.asList(LDAPTCVerGroupAdmin));
		temp1.addAll(Arrays.asList(LDAPNXGroupInfo));
		temp1.addAll(Arrays.asList(LDAPNXGroupAdmin));
		String[] temp =temp1.toArray(new String[temp1.size()]);
//		System.out.println(temp.length);
		BSHInfo.LDAPGroups = temp;
		return;
	}

	
	
	
	private static ValidServletUser isUserValid(String token) {
		ArrayList<ValidServletUser> temp = usersessions.get(token);
		if (temp == null) {
			return null;
		}

		for (ValidServletUser elem : temp) {
			if (elem.getToken().equalsIgnoreCase(token)) {
				return elem;
			}
		}

		return null;
	}

	private void doLogin(HttpServletRequest request,
			HttpServletResponse response) throws IOException {
		String client = request.getRemoteHost();
		String clientip = request.getRemoteAddr();
		String clientuser = request.getRemoteUser();
		String user = request.getParameter("user");
		String pwd = request.getParameter("pwd");		
		String passwrd=decrypt(pwd, privateKey);
		//log.debug(passwrd);
		ValidServletUser vuser = null;
		try {
			vuser = new ValidServletUser(user, clientuser, client, clientip,
					passwrd, BSHInfo.LDAPGroups);
		} catch (Exception e) {
			log.debug(e.getMessage());
		}

		if (vuser != null) {
			log.debug("user is authenticated");
			Cookie cookie = new Cookie("bshinfo", vuser.getToken());
			// setting cookie to expiry in 60 mins
			cookie.setMaxAge(60 * 60);
			response.addCookie(cookie);
			response.sendRedirect(request.getContextPath() + "" + mappingname);
			addSession(vuser);
			return;
		} else {
			response.sendRedirect(request.getContextPath() + "" + mappingname);
			return;
		}
	}

	private void doLogout(String token, HttpServletRequest request,
			HttpServletResponse response) throws IOException {
		log.debug("user logout");
		Cookie cookie = new Cookie("bshinfo", "");
		cookie.setMaxAge(0);
		response.addCookie(cookie);
		response.sendRedirect(request.getContextPath() + "" + mappingname);
		usersessions.remove(token);
		return;
	}
	
	private void replaceVersion(String realPath, ServletContext context) {
//		File tfile = new File(realPath+"index.html");
//		FileInputStream fst = new FileInputStream(tfile);
		BufferedReader br = null;
		String index ="";
		try {
			br=new BufferedReader(new FileReader(realPath+"index.html.template"));
			StringBuilder sb = new StringBuilder();
		    String line = br.readLine();

		    while (line != null) {
		        sb.append(line);
		        sb.append(System.lineSeparator());
		        line = br.readLine();
		    }
		    index = sb.toString();
		} catch (Exception e) {
//			e.printStackTrace();
		} finally {
			try {
				if (br!=null) {
					br.close();
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		index=index.replace("#BSHINFOVERSION#", ""+version);
		index=index.replace("#BSHINFOOVERVIEW#",context.getContextPath()+mappingname);
		
		File tfile= new File(realPath+"index.html");
		PrintWriter out=null;
		try {
			out = new PrintWriter(tfile);
			out.write(index);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			out.close();
		}
		
	}
	
	public static void generateKey() {
		 try {
		 KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
		 keyGen.initialize(1024);
		 KeyPair key = keyGen.generateKeyPair();
		 PublicKey publicKey = key.getPublic();
		 privateKey = key.getPrivate();
		 KeyFactory keyFac = KeyFactory.getInstance("RSA");
	        RSAPublicKeySpec pub = new RSAPublicKeySpec(BigInteger.ZERO, BigInteger.ZERO);
	        pub = keyFac.getKeySpec(publicKey, RSAPublicKeySpec.class);
	        publicKeyStr=pub.getModulus().toString(16);
				 
		 } catch (Exception e) {
		 e.printStackTrace();
		 }

		}
	
	public static String decrypt(String text, PrivateKey key) {
		Cipher cipher;
		
		 byte[] dectyptedText = new byte[1];
		 
		 try {
			 cipher = javax.crypto.Cipher.getInstance("RSA");
			 byte[] byteArray = new byte[128];
			 BigInteger passwordInt = new BigInteger(text, 16);
			 if (passwordInt.toByteArray().length > 128) {
			        for (int i=1; i<129; i++) {
			            byteArray[i-1] = passwordInt.toByteArray()[i];
			        }
			    } else {
			        byteArray = passwordInt.toByteArray();
			    }
			   cipher.init(Cipher.DECRYPT_MODE, privateKey);
			   dectyptedText = cipher.doFinal(byteArray);

		} catch (Exception ex) {
		 ex.printStackTrace();
		 }

		 return new String(dectyptedText);
		 }
	
}
