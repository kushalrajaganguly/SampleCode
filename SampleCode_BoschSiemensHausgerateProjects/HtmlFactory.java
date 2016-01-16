/**
 * @file        HtmlFactory.java
 */

package com.bsh.tc.bshinfo.servlet;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.Hashtable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.log4j.Logger;

import com.bsh.tc.bshinfo.dao.BSHActualInformationItem;
import com.bsh.tc.bshinfo.dao.Database;
import com.bsh.tc.bshinfo.dao.NXVersion;
import com.bsh.tc.bshinfo.dao.TCVersion;
import com.bsh.tc.bshinfo.dao.TCHistory;
import com.bsh.tc.bshinfo.dao.TCHost;


/**
 * Create the HTML content as a helperclass for the servlet
 *
 */

public class HtmlFactory {
	private static org.apache.log4j.Logger log = Logger.getLogger(HtmlFactory.class);
	public static String context;
	public static String mappingname;
	public static String realpath;
	public static File html_folder=null;
	private static HtmlFactory instance;
	public static Hashtable<String,String> defaultHTML;

	public static final int HTML_Overview=0;
	public static final int HTML_Insert_TCMessage=1;
	public static final int HTML_Insert_TCVersion=2;
	public static final int HTML_Insert_NXVersion=3;
	public static final int HTML_Update_TCMessage=4;
	
	public static HtmlFactory getInstance(String context,String mappingname,String realpath) {
		if (instance==null) {
			HtmlFactory.context=context;
			HtmlFactory.mappingname=mappingname;
			HtmlFactory.realpath=realpath;
			html_folder=new File(realpath+File.separatorChar+"html");
			instance=new HtmlFactory();
			defaultHTML=new Hashtable<String, String>();
			for (File file:html_folder.listFiles()) {
				try {
					if (file.getName().endsWith(".html")) {
						String htmlsite=loadFromFile(file);
						htmlsite=htmlsite.replaceAll("\\{servleturl\\}", ""+context+""+mappingname);
						String name=file.getName().substring(0, file.getName().length()-5);
						defaultHTML.put(name, htmlsite);
					}
				} catch (FileNotFoundException e) {
					log.error("file:"+file.getName()+" - "+e.getMessage());
				}
			}
			
		}
		return instance;
	}
	
private static String getImageList() {
		
		File[] files = new File(realpath+"defaultimage").listFiles();
		String res ="";
		for (File f : files) {
		    if (f.getName().toLowerCase().endsWith(".png") || f.getName().toLowerCase().endsWith(".jpg")) {
		        res +="<td><input type=\"radio\" name=\"selectedImg\" value=\""+f.getName()+"\" id=\""+f.getName()+"-radio\" onClick=\"CB(this.value);\"></td>";
		        res +="<td><label for=\""+f.getName()+"-radio\"><div class='holder'><img src=\"defaultimage/"+f.getName()+"\"></div></label></td>";
		    }
		}
		
		return res;
		}
	
	public static String createTCMsgInsertSite(boolean[] access, Hashtable<String, String> params) {
		String res=getImageList();
		params=new Hashtable<String,String>();
		params.put("{param_selectImage}", res);
		log.debug("res for createTCMsgInsertSite()::::"+params.get("{param_selectImage}"));
		return doTheReplacements("default","",access,HTML_Insert_TCMessage, params);
	}
	
	public static String updateTCMsgInsertSite(boolean[] access, Hashtable<String, String> params) {
		
		return doTheReplacements("default","",access,HTML_Update_TCMessage, params);
	}
	
	public static String createTCVersionInsertSite(boolean[] access, Hashtable<String, String> params) {

		return doTheReplacements("default","",access,HTML_Insert_TCVersion, params);
	}
	
	public static String createNXVersionInsertSite(boolean[] access, Hashtable<String, String> params) {
		return doTheReplacements("default","",access,HTML_Insert_NXVersion, params);
	}
	
	public static String createDBInsertResultSite(String[] result, boolean[] access, String servleturl) {
		String bodycontend = "You have changes take affect to "+result[0]+" rows<br><br>\n";
		bodycontend += "<meta http-equiv=\"refresh\" content=\"3; url="+servleturl+"\" />"; 
		if (result[1]!="") {
			String msg=result[1].replaceAll("(\r\n|\n\r|\r|\n)", "<br />\n");
			bodycontend += "<h3>Error message</h3>"+msg;
		}
		return doTheReplacements("default",bodycontend,access,HTML_Overview,null);		
	}
	
	public static String createDefaultSite() {		
		String res=defaultHTML.get("login");
		String tmp="value=\""+BSHInfo.publicKeyStr+"\"";
		res=res.replace("{param_pubKey}", tmp);
		 return res;
		
	}
	public static String createOverviewSite(Database db, String tableType, boolean editallowed, boolean[] access) {
//		return defaultHTML.get("overview");
		String body = createActualString(db, tableType, editallowed);
		return doTheReplacements("default",body,access,HTML_Overview,null);		
	}
	
	private static String doTheReplacements(String site,String bodycontent, boolean[] access, int switchsite, Hashtable<String,String> para) {
		String mainmenu = getMainMenu(access);
		Hashtable<String,String>parameters=new Hashtable<String,String>();
		String res=defaultHTML.get(site);
		String tmp=BSHInfo.loginUser;
		res=res.replace("{user}", tmp);
		if (para!=null){
			parameters.putAll(para);
			log.debug(parameters);
			if(parameters.containsKey("{param_selectImage}")){
			res=res.replace("{param_selectImage}", parameters.get("{param_selectImage}"));
			}
			if(parameters.containsKey("{param_tcSystem_PLMEU}")){
				res=res.replace("{param_tcSystem_PLMEU}", parameters.get("{param_tcSystem_PLMEU}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMCEU}")){
				res=res.replace("{param_tcSystem_PLMCEU}", parameters.get("{param_tcSystem_PLMCEU}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMD8}")){
				res=res.replace("{param_tcSystem_PLMD8}", parameters.get("{param_tcSystem_PLMD8}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMD7}")){
				res=res.replace("{param_tcSystem_PLMD7}", parameters.get("{param_tcSystem_PLMD7}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMD1}")){
				res=res.replace("{param_tcSystem_PLMD1}", parameters.get("{param_tcSystem_PLMD1}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMI2}")){
				res=res.replace("{param_tcSystem_PLMI2}", parameters.get("{param_tcSystem_PLMI2}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMT7}")){
				res=res.replace("{param_tcSystem_PLMT7}", parameters.get("{param_tcSystem_PLMT7}"));
				}
			if(parameters.containsKey("{param_tcSystem_PLMRF}")){
				res=res.replace("{param_tcSystem_PLMRF}", parameters.get("{param_tcSystem_PLMRF}"));
				}
			}
		res=res.replace("{param_mainmenu}", mainmenu);
		res=res.replace("{bodycontend}", bodycontent);
		res=res.replace("{bodycontend}", bodycontent);
		String replacestring4msgvisibility = "none";
		String replacestring4versionvisibility = "none";
		String replacestring4nxvisibility = "none";
		String replacestring4updatemsgvisibility = "none";
		
		switch (switchsite) {			
		case HTML_Insert_TCMessage:
			replacestring4msgvisibility="block";
			break;
		case HTML_Insert_TCVersion:
			replacestring4versionvisibility="block";
			break;
		case HTML_Insert_NXVersion:
			replacestring4nxvisibility="block";
			break;	
		case HTML_Update_TCMessage:
			replacestring4updatemsgvisibility="block";
			break;	
		default:
			break;
		}
		res=res.replace("{tcversion_textstatusactive}",TCVersion.TextStatusActive);
		res=res.replace("{tcversion_textstatusdepricated}",TCVersion.TextStatusDepricated);
		res=res.replace("{tcversion_textstatustoold}",TCVersion.TextStatusToOld);
		
		res=res.replace("{msgvisibility}",replacestring4msgvisibility);
		res=res.replace("{versionvisibility}",replacestring4versionvisibility);
		res=res.replace("{nxvisibility}",replacestring4nxvisibility);
		res=res.replace("{updatemsgvisibility}",replacestring4updatemsgvisibility);
	
		Pattern p = Pattern.compile("(\\{param[a-z_]*\\})");
		Matcher m = p.matcher(res);
		String res2="";
		int i=0;
		while (m.find()) {
			String replacement="";
			if (parameters!=null && parameters.containsKey(m.group(0))) {
				replacement=parameters.get(m.group(0));
				log.debug(replacement);
			}
			
			res2+=res.substring(i,m.start(0))+replacement;
			i=m.end(0);
				
			
		}
		res2+=res.substring(i);
		return res2;
	}
	
	private static String createActualString(Database db, String tableType, boolean editallowed) {
		String res = "";
		if(tableType.equals("tcMsgTable")){
			res = "<h3>TC Message Table</h3>";
			res+="<div id=\"actualinfo\">";
			res+="<table id=\"msgtctable\">"+BSHActualInformationItem.getHtmlTableHeader(editallowed);
			for (BSHActualInformationItem temp:db.ActualInformationItems(null)) {
				res+=temp.toHtmlTableRow(context,mappingname,editallowed)+"\n";
			}
			res+="</table></div>";
			if(editallowed){
				String passingUrl = context+mappingname + "?method=dbinserttcmsg";
				res+="<br><input type=\"button\" value=\"Insert TC Message\" onclick=\"tcMsgInsertPage('"+passingUrl+"');\">";	
			}
		}	
		else if(tableType.equals("tcVersionTable")){
			res = "<h3>TC Version Table</h3>";
			res+="<div id=\"tcversion\">";
			res+="<table id=\"versiontctable\">"+TCVersion.getHtmlTableHeader(editallowed)+"\n";
			for (TCVersion temp:db.ActualTCVersionItems(null)) {
				res+=temp.toHtmlTableRow(context,mappingname,editallowed)+"\n";
			}
			res+="</table></div>";
			if(editallowed){
				String passingUrl = context+mappingname + "?method=dbinserttcversion";
				res+="<br><input type=\"button\" value=\"Insert TC Version\" onclick=\"tcVersionInsertPage('"+passingUrl+"');\">";	
			}
		}
		else if(tableType.equals("tcHostTable")){
			res = "<h3>TC Host Table</h3>";
			res+="<div id=\"tchosttable\">";
			res+="<table id=\"hosttctable\">"+TCHost.getHtmlTableHeader()+"\n";
			for (TCHost temp:db.ActualTCHostItems(null)) {
				res+=temp.toHtmlTableRow(context,mappingname)+"\n";
			}
			res+="</table></div>";
		}
		else if(tableType.equals("nxTable")){
			res = "<h3>NX Version Table</h3>";
		res+="<div id=\"nxversion\">";
		res+="<table id=\"versionnxtable\">"+NXVersion.getHtmlTableHeader(editallowed)+"\n";
		for (NXVersion temp:db.ActualNXVersionItems(null)) {
			res+=temp.toHtmlTableRow(context,mappingname,editallowed)+"\n";
		}
		res+="</table></div>";	
		if(editallowed){
			String passingUrl = context+mappingname + "?method=dbinsertnxversion";
			res+="<br><input type=\"button\" value=\"Insert NX Version\" onclick=\"nxVersionInsertPage('"+passingUrl+"');\">";	
		}
		}
		
		else if(tableType.equals("tcHistoryTable")){
			res = "<h3>TC History Table</h3>";
		res+="<div id=\"tchistory\">";
		res+="<table>"+TCHistory.getHtmlTableHeader()+"\n";
		for (TCHistory temp:db.ActualTCHistoryItems(null)) {
			res+=temp.toHtmlTableRow(context,mappingname)+"\n";
		}
		res+="</table></div>";
		}
		
		else if(tableType.equals("")){
			res = "<h1>Welcome<h1>";
		}
		return res;
		
	}
	
	
	public static String loadFromFile(String file) throws FileNotFoundException {
		return loadFromFile(new File(file));
	}
	
	private static String loadFromFile(File file) throws FileNotFoundException {
		String res="";
		if (file.exists()) {
			try(BufferedReader br = new BufferedReader(new FileReader(file))) {
			    StringBuilder sb = new StringBuilder();
			    String line = br.readLine();

			    while (line != null) {
			        sb.append(line);
			        sb.append(System.lineSeparator());
			        line = br.readLine();
			    }
			    res = sb.toString();
			} catch (IOException e) {
				log.error(e.getMessage());
			}
			
		}
		return res;
	}

	private static String getMainMenu(boolean[] access) {
		String servleturl = HtmlFactory.context + "" + HtmlFactory.mappingname;
		String res = "";
		if (access[0]) {
			res += "<a href=\"" + servleturl
					+ "?method=tcMsgTable\">TC MessageTable</a>";
		}
		if (access[1]) {
			if (!access[0]) {
				res += "<a href=\"" + servleturl
						+ "?method=tcMsgTable\">TC MessageTable</a>";
			}
			//res += " <a href=\"" + servleturl
				//	+ "?method=dbinserttcmsg\">Insert TC Messages</a>";
			
			res += " <a href=\"" + servleturl
					+ "?method=tcHistoryTable\">TC HistoryTable</a>";
		}
		if (access[2]) {
			res += " <a href=\"" + servleturl
					+ "?method=tcVersionTable\">TC VersionTable</a>";
		}
		if (access[3]) {
			if (!access[2]) {
				res += " <a href=\""
						+ servleturl
						+ "?method=tcVersionTable\">TC VersionTable</a>";
			}
			//res += " <a href=\"" + servleturl
					//+ "?method=dbinserttcversion\">Insert TC Version</a>";
			
			res += " <a href=\"" + servleturl
					+ "?method=tcHostTable\">TC HostTable</a>";
			
			if (!access[1]) {
				res += " <a href=\""
						+ servleturl
						+ "?method=tcHistoryTable\">TC HistoryTable</a>";
			}
		}
		if (access[4]) {
			res += " <a href=\"" + servleturl
					+ "?method=nxTable\">NXTable</a>";
		}
		if (access[5]) {
			if (!access[4]) {
				res += " <a href=\"" + servleturl
						+ "?method=nxTable\">NXTable</a>";
			}
			//res += " <a href=\"" + servleturl
					//+ "?method=dbinsertnxversion\">Insert NX Version</a>";
		}
		return res;
	}

}
