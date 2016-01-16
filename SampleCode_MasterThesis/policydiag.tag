<%--
/*******************************************************************************
 * Copyright (c) 2012-2014 University of Stuttgart.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and the Apache License 2.0 which both accompany this distribution,
 * and are available at http://www.eclipse.org/legal/epl-v10.html
 * and http://www.apache.org/licenses/LICENSE-2.0
 *
 * Contributors:
 *    Oliver Kopp - initial API and implementation and/or initial documentation
 *******************************************************************************/
--%>

<%@tag import="org.eclipse.winery.model.tosca.TPolicyTemplate"%>
<%@tag
	description="Dialog to add or update a policy. Offers function showUpdateDiagForPolicy(policyElement) / showAddDiagForPolicy(nodeTemplateElement)"
	pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@taglib prefix="o" tagdir="/WEB-INF/tags/common/orioneditor"%>
<%@taglib prefix="w" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="ct" tagdir="/WEB-INF/tags/common"%>
<%@taglib prefix="wc" uri="http://www.eclipse.org/winery/functions"%>

<%@attribute name="allPolicyTypes" required="true"
	type="java.util.Collection"
	description="Collection&lt;QName&gt; of all available policy types"%>
<%@attribute name="repositoryURL" required="true"
	type="java.lang.String" description="The URL of winery's repository"%>

<%@attribute name="serviceTemplateName" required="true"
	type="java.lang.String" description="The URL of winery's repository"%>


<div class="modal fade" id="PolicyDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Policy</h4>
			</div>
			<div class="modal-body">

				<ct:id_name_type idPrefix="policy" allTypes="${allPolicyTypes}"
					hideIdField="true" />

				<div class="form-group">
					<label for="policyTemplate" class="control-label">Policy
						Template:</label> <input id="policyTemplate" class="form-control"
						name="policyTemplate"></input>
				</div>

				<o:orioneditorarea areaid="OrionpolicyXML" withoutsavebutton="true" />
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
				<button type="button" id="deletePolicy" class="btn btn-danger"
					onclick="deletePolicy();">Delete</button>
				<button type="button" id="updatePolicy" class="btn btn-primary"
					onclick="addOrUpdatePolicy(false);">Update</button>
				<button type="button" id="addPolicy" class="btn btn-primary"
					onclick="addOrUpdatePolicy(true);">Add</button>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="ChoosePerformancePolicyTypeDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Choose Performance Policy Type</h4>
			</div>
			<div class="modal-body">

				<ct:QNameChooser allQNames="${allPolicyTypes}"
					idOfSelectField="perf1PolicyType"
					labelOfSelectField="Performance Policy Type" />

				<div class="form-group">
					<button type="button" id="choosePerformancePolicyType"
						class="btn btn-primary" onclick="choosePerformancePolicyType();">Confirm</button>
				</div>

			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="SelectPerformancePolicyTypeDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Select Performance Policy Type for
					Template</h4>
			</div>
			<div class="modal-body">

				<ct:QNameChooser allQNames="${allPolicyTypes}"
					idOfSelectField="perf2PolicyType"
					labelOfSelectField="Performance Policy Type" />

				<div class="form-group">
					<button type="button" id="selectPerformancePolicyType"
						class="btn btn-primary" onclick="selectPerformancePolicyType();">Confirm</button>
				</div>

			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="ChoosePerformancePolicyTemplateDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Choose Performance Policy Template</h4>
			</div>
			<div class="modal-body">

				<ct:QNameChooser allQNames="${allPolicyTypes}"
					idOfSelectField="perfPolicyType"
					labelOfSelectField="Performance Policy Type" />

				<div class="form-group">
					<label for="perfPolicyTemplate" class="control-label">Policy
						Template:</label> <input id="perfPolicyTemplate" class="form-control"
						name="perfPolicyTemplate"></input>
				</div>

				<div class="form-group">
					<button type="button" id="choosePerformancePolicyTemplate"
						class="btn btn-primary"
						onclick="choosePerformancePolicyTemplate();">Confirm</button>
				</div>

			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="PolicyTypeDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">All Policy Types</h4>
			</div>
			<div class="modal-body">

				<div class="form-group">
					<table class="table" id="PolicyTypeDiagTable">
						<tbody>
							<tr>
								<td>
									<button type="button" id="addPerformancePolicyType"
										class="btn btn-primary" onclick="addPerformancePolicyType();">Add
										Performance Type</button>
								</td>
								<td>
									<button type="button" id="addPerformancePolicyType"
										class="btn btn-primary"
										onclick="updatePerformancePolicyType();">Update
										Performance Type</button>
								</td>
							</tr>
							<tr>
								<td>
									<button type="button" id="viewPolicyType"
										class="btn btn-primary"
										onclick="document.location.href='/winery/policytypes/'">View
										Policy Types</button>
								</td>
								<td>
									<button type="button" id="deletePolicyType"
										class="btn btn-danger"
										onclick="document.location.href='/winery/policytypes/'">Delete
										Policy Types</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="PolicyTemplateDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">All Policy Templates</h4>
			</div>
			<div class="modal-body">

				<div class="form-group">
					<table class="table" id="PolicyTemplateDiagTable">
						<tbody>
							<tr>
								<td>
									<button type="button" id="addPerformancePolicyTemplate"
										class="btn btn-primary"
										onclick="addPerformancePolicyTemplate();">Add
										Performance Template</button>
								</td>
								<td>
									<button type="button" id="updatePerformancePolicyTemplate"
										class="btn btn-primary"
										onclick="updatePerformancePolicyTemplate();">Update
										Performance Template</button>
								</td>
							</tr>
							<tr>
								<td>
									<button type="button" id="viewPolicyTemplate"
										class="btn btn-primary"
										onclick="document.location.href='/winery/policytemplates/'">View
										Policy Templates</button>
								</td>
								<td>
									<button type="button" id="deletePolicyTemplate"
										class="btn btn-danger"
										onclick="document.location.href='/winery/policytemplates/'">Delete
										Policy Templates</button>
								</td>
							</tr>
						</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="PerformancePolicyTypeDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Add/Update Performance Policy Type</h4>
			</div>
			<div class="modal-body">

				<div class="form-group">
					<label for="performancePolicyTypeName" class="control-label">Performance
						Policy Type Name:</label> <input id="performancePolicyTypeName"
						class="form-control" name="performancePolicyTypeName" type="text"
						required="required" />
				</div>

				<div class="form-group">
					<label for="performancePropertiesDefinitionName"
						class="control-label">Properties Definition Name:</label> <input
						id="performancePropertiesDefinitionName" class="form-control"
						name="performancePropertiesDefinitionName" type="text"
						required="required" />
				</div>

				<div class="form-group">
					<button type="button" id="submitPerformancePolicyType"
						class="btn btn-primary" onclick="submitPerformancePolicyType();">Submit</button>
				</div>

			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="PerformancePolicyTemplateDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Add/Update Performance Policy Template</h4>
			</div>
			<div class="modal-body">

				<div class="form-group">
					<label for="perfPolName" class="control-label">Performance
						Policy Template Name:</label> <input id="perfPolName" class="form-control"
						name="perfPolName" type="text" required="required" />
				</div>

				<div class="form-group">
					<label for="perfPolType" class="control-label">Performance
						Policy Type:</label> <input id="perfPolType" class="form-control"
						name="perfPolType" type="text" required="required" />
				</div>

				<div class="form-group">
					<label for="perfPropDefinitionName" class="control-label">Performance
						Policy Type Properties Definition Name:</label> <input
						id="perfPropDefinitionName" class="form-control"
						name="perfPropDefinitionName" type="text" required="required" />
				</div>

				<div class="form-group">
					<label for="performanceCategoryName" class="control-label">Performance
						Category Name:</label> <select id="performanceCategoryName"
						name="performanceCategoryName" class="form-control">
						<option value="Availability">Availability</option>
						<option value="TimeBehavior">Time Behavior</option>
						<option value="Other">Other</option>
					</select>
				</div>

				<div class="form-group">
					<b>Other Performance Category:</b><br /> <input id="perfCatName"
						class="form-control" name="perfCatName" type="text" />
				</div>

				<label for="performanceMetricName" class="control-label">Performance
					Metric Name:</label> <select id="performanceMetricName"
					name="performanceCategoryName" class="form-control"></select>

				<div class="form-group">
					<b>Other Performance Metric:</b><br /> <input id="perfMetricName"
						class="form-control" name="perfMetricName" type="text" />
				</div>

				<div class="form-group">
					<b>Performance Threshold:</b><br />
					<div class="col-sm-4">
						<label for="thresholdMin" class="control-label">Minimum
							Value:</label> <input id="thresholdMin" class="form-control"
							name="thresholdMin" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="thresholdMax" class="control-label">Maximum
							Value:</label> <input id="thresholdMax" class="form-control"
							name="thresholdMax" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="thresholdUnit" class="control-label">Measurement
							Unit:</label> <input id="thresholdUnit" class="form-control"
							name="thresholdUnit" type="text" />
					</div>
				</div>

				<div class="form-group">
					<label for="monitoringLink" class="control-label">Monitoring
						Link:</label> <input id="monitoringLink" class="form-control"
						name="monitoringLink" type="text" />
				</div>

				<div class="form-group">
					<b>Analytical Indicator:</b><br />
					<div class="col-sm-4">
						<label for="indicatorIndexName" class="control-label">Name:</label>
						<input id="indicatorIndexName" class="form-control"
							name="indicatorIndexName" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="indicatorIndexUnit" class="control-label">Measurement
							Unit:</label> <input id="indicatorIndexUnit" class="form-control"
							name="indicatorIndexUnit" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="indicatorValue" class="control-label">Required
							Value:</label> <input id="indicatorValue" class="form-control"
							name="indicatorValue" type="text" />
					</div>
				</div>

			</div>
			<div class="modal-footer">
				<button type="button" id="addPerformanceMetrics"
					class="btn btn-primary" onclick="addPerformanceMetrics();">Add
					Metrics</button>

				<button type="button" id="viewPerformanceMetrics"
					class="btn btn-primary" onclick="viewPerformanceMetrics();">List
					Metrics</button>

				<button type="button" id="submitPerformancePolicyTemplate"
					class="btn btn-primary"
					onclick="submitPerformancePolicyTemplate();">Submit</button>
			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="PerformanceMetricsDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">All Performance Metrics List</h4>
			</div>
			<div class="modal-body">

				<div class="form-group">

					<table class="table" id="MetricsTable">
						<thead>
							<tr>
								<th>Category</th>
								<th>Metric</th>
								<th>Minimum Threshold</th>
								<th>Maximum Threshold</th>
								<th>Threshold Unit</th>
								<th>Monitoring Link</th>
								<th>Indicator Index Name</th>
								<th>Indicator Index Unit</th>
								<th>Indicator Value</th>

							</tr>
						</thead>
						<tbody>

						</tbody>
					</table>

				</div>

			</div>
		</div>
	</div>
</div>

<div class="modal fade" id="UpdateMetricDiag">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal"
					aria-hidden="true">&times;</button>
				<h4 class="modal-title">Update Performance Metric</h4>
			</div>
			<div class="modal-body">

				<div class="form-group">
					<label for="updateCatName" class="control-label">Performance
						Category Name:</label> <input id="updateCatName" class="form-control"
						name="updateCatName" type="text" />
				</div>

				<div class="form-group">
					<label for="updateMetricName" class="control-label">Performance
						Metric Name:</label> <input id="updateMetricName" class="form-control"
						name="updateMetricName" type="text" />
				</div>

				<div class="form-group">
					<b>Performance Threshold:</b><br />
					<div class="col-sm-4">
						<label for="updateThresholdMin" class="control-label">Minimum
							Value:</label> <input id="updateThresholdMin" class="form-control"
							name="updateThresholdMin" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="updateThresholdMax" class="control-label">Maximum
							Value:</label> <input id="updateThresholdMax" class="form-control"
							name="updateThresholdMax" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="updateThresholdUnit" class="control-label">Measurement
							Unit:</label> <input id="updateThresholdUnit" class="form-control"
							name="updateThresholdUnit" type="text" />
					</div>
				</div>

				<div class="form-group">
					<label for="updateMonitoringLink" class="control-label">Monitoring
						Link:</label> <input id="updateMonitoringLink" class="form-control"
						name="updateMonitoringLink" type="text" />
				</div>

				<div class="form-group">
					<b>Analytical Indicator:</b><br />
					<div class="col-sm-4">
						<label for="updateIndicatorIndexName" class="control-label">Name:</label>
						<input id="updateIndicatorIndexName" class="form-control"
							name="updateIndicatorIndexName" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="updateIndicatorIndexUnit" class="control-label">Measurement
							Unit:</label> <input id="updateIndicatorIndexUnit" class="form-control"
							name="updateIndicatorIndexUnit" type="text" />
					</div>
					<div class="col-sm-4">
						<label for="updateIndicatorValue" class="control-label">Required
							Value:</label> <input id="updateIndicatorValue" class="form-control"
							name="updateIndicatorValue" type="text" />
					</div>
				</div>
				<div class="form-group">
					<button type="button" id="updateMetricTable"
						class="btn btn-primary" onclick="updateMetricTable();">Confirm</button>
				</div>

			</div>
		</div>
	</div>
</div>


<c:set var="clazz"
	value="<%=org.eclipse.winery.model.tosca.TPolicy.class%>" />
<textarea id="emptyPolicy" class="hidden">${wc:XMLAsString(clazz, null)}</textarea>


<script>
//global variable set by showUpdateDiagForPolicy and read by addOrUpdatePolicy
var serviceTemplate="${serviceTemplateName}";
var currentPolicyElement;
var metricUpdateButtonId;
// possibly this is a duplicate information as we also have "currentlySelectedNodeTemplate" (or similar)
var currentNodeTemplateElement;
var repositoryPath="";
var policyTypeNamespace="";
var policyTemplateNamespace="";
var performanceMetricsArray= [];
var metricsAsString= "";
var countValue= 0;
var createMetricsTable= "";

var Availability=["Uptime", "MTBF", "MTTR", "Other"];
var TimeBehavior=["Response Time", "Speed", "Other"]; 
selectDropdown();

$('#performanceCategoryName').change(function(){
	selectDropdown();
});
    
$('#performanceMetricName').change(function(){
    var item=$('#performanceMetricName').val();
        if(item=="Other")
        {
        	$("#perfMetricName").show();
        } 
        else {
        	$("#perfMetricName").hide();
        }
        	
 });

$.get("/winery/readPropertiesFile.jsp", function(data, status){
	var resArray=data.split(",End Here,");
	repositoryPath=resArray[0];
	policyTypeNamespace=resArray[1];
	policyTypeNamespace=encodeURIComponent(policyTypeNamespace);
	policyTemplateNamespace=resArray[2];
	policyTemplateNamespace=encodeURIComponent(policyTemplateNamespace);
	});

function selectDropdown(){
    var tmp=$('#performanceCategoryName').val();
    if(tmp=="Other")
    {
    	$("#perfCatName").show();
    	$("#perfMetricName").show();
    }
    else {
    	$("#perfCatName").hide();
    	$("#perfMetricName").hide();
    }
    $('#performanceMetricName').html('');
    
       eval(tmp).forEach(function(x) { 
            $('#performanceMetricName').append('<option>'+x+'</option>');
        });
}
    
function workloadLink(){
	var sendparams = "/winery/displayWorkload.jsp?serviceTemplate="+serviceTemplate+"&repositoryPath="+repositoryPath;
	window.location.replace(sendparams);
}

function updatePolicyTemplateSelect(valueToSelect) {
	require(["winery-support-common"], function(w) {
		var type = $("#policyType").val();
		var fragment = w.getURLFragmentOutOfFullQName(type);
		var url = "${repositoryURL}/policytypes/" + fragment + "/instances/";
		$.ajax(url, {
			dataType: 'json'
		}).fail(function(jqXHR, textStatus, errorThrown) {
			vShowAJAXError("Could not get policy templates", jqXHR, errorThrown);
		}).done(function(data) {
			// add "(none)" to available items
			var none = {
				id: "(none)",
				text: "(none)"
			};
			data.unshift(none);

			if (typeof valueToSelect === "undefined") {
				valueToSelect = "(none)";
			}

			$("#policyTemplate")
				.select2({data: data})
				.select2("val", valueToSelect);
		});
	});
}

function updatePerformanceTemplateSelect(valueToSelect) {
	require(["winery-support-common"], function(w) {
		var type = $("#perfPolicyType").val();
		var fragment = w.getURLFragmentOutOfFullQName(type);
		var url = "${repositoryURL}/policytypes/" + fragment + "/instances/";
		
		$.ajax(url, {
			dataType: 'json'
		}).fail(function(jqXHR, textStatus, errorThrown) {
			vShowAJAXError("Could not get policy templates", jqXHR, errorThrown);
		}).done(function(data) {
			// add "(none)" to available items
			var none = {
				id: "(none)",
				text: "(none)"
			};
			data.unshift(none);

			if (typeof valueToSelect === "undefined") {
				valueToSelect = "(none)";
			}

			$("#perfPolicyTemplate")
				.select2({data: data})
				.select2("val", valueToSelect);
		});
	});
}

function updatePerformancePolicyTemplate(){
	updatePerformanceTemplateSelect();
	var mydiag = $("#PolicyTemplateDiag");
	require(["winery-support-common"], function(w) {
		mydiag.modal("hide");
	});
	var diag = $("#ChoosePerformancePolicyTemplateDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
	
}

function choosePerformancePolicyType(){
	var mydiag = $("#ChoosePerformancePolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		mydiag.modal("hide");
	});
	
	var perf1Policytype = $("#perf1PolicyType").select2("data");	
	var typeName=perf1Policytype.text;
	$("#performancePolicyTypeName").val(typeName);
	$("#performancePropertiesDefinitionName").val("");
	
	$.get("/winery/policyTypeRead.jsp?typeName="+typeName+"&repositoryPath="+repositoryPath+"&policyTypeNamespace="+policyTypeNamespace, function(data, status){
		var propDef = "";
		$(data).find("tosca\\:PropertiesDefinition").each(function(){
			propDef = $(this).attr("element");
			propDef = propDef.split(':')[1];
			$("#performancePropertiesDefinitionName").val(propDef);
		});
		
		var diag = $("#PerformancePolicyTypeDiag");
		require(["winery-support-common"], function(w) {
			diag.modal("show");
		});
		
	});
}

function selectPerformancePolicyType(){
	var mydiag = $("#SelectPerformancePolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		mydiag.modal("hide");
	});
	$("#submitPerformancePolicyTemplate").hide();
	$("#perfCatName").hide();
	$("#perfMetricName").hide();
	$("#MetricsTable > tbody").html("");
	performanceMetricsArray= [];
	countValue=0;
	$("#perfPolName").val("");
	$("#perfPolType").val(""); 
	$("#perfPropDefinitionName").val("");
	var perf2Policytype = $("#perf2PolicyType").select2("data");	
	var typeName=perf2Policytype.text;
	
	$("#perfPolType").val(typeName);
	$("#perfPropDefinitionName").val("");
	$.get("/winery/policyTypeRead.jsp?typeName="+typeName+"&repositoryPath="+repositoryPath+"&policyTypeNamespace="+policyTypeNamespace, function(data, status){
		var propDef = "";
		$(data).find("tosca\\:PropertiesDefinition").each(function(){
			propDef = $(this).attr("element");
			propDef = propDef.split(':')[1];
			$("#perfPropDefinitionName").val(propDef);
		});
		
		var diag = $("#PerformancePolicyTemplateDiag");
		require(["winery-support-common"], function(w) {
			diag.modal("show");
		});
		
	});
}

function choosePerformancePolicyTemplate(){
	var perfPolicytype = $("#perfPolicyType").select2("data");	
	var typeName=perfPolicytype.text;
	var perfPolicytemplate = $("#perfPolicyTemplate").select2("data");	
	var templateName=perfPolicytemplate.text;
	$("#MetricsTable > tbody").html("");
	performanceMetricsArray=[];
	countValue=0;
	$("#submitPerformancePolicyTemplate").show();
	$("#perfPolName").val(templateName);
	$("#perfPolType").val(typeName);
	$("#perfPropDefinitionName").val("");
	var propDef="";
	$.get("/winery/policyTypeRead.jsp?typeName="+typeName+"&repositoryPath="+repositoryPath+"&policyTypeNamespace="+policyTypeNamespace, function(data, status){
		$(data).find("tosca\\:PropertiesDefinition").each(function(){
			propDef = $(this).attr("element");
			propDef = propDef.split(':')[1];
			$("#perfPropDefinitionName").val(propDef);
		});
		
	});
	
	$.get("/winery/policyTemplateRead.jsp?templateName="+templateName+"&repositoryPath="+repositoryPath+"&policyTemplateNamespace="+policyTemplateNamespace, function(data, status){
		
		$(data).find("AnalyticalIndicator").each(function(){
			countValue=countValue+1;
		            var metricName = $(this).parent("Metric").attr("Name");
		            var categoryName = $(this).parent("Metric").parent("MetricsCategory").attr("Name");
		            var minThreshold = $(this).siblings("Threshold").children("Lower").text();
		            var maxThreshold = $(this).siblings("Threshold").children("Upper").text();
		            var unitThreshold = $(this).siblings("Threshold").attr("MeasurementUnit");
		            var linkMonitor = $(this).siblings("monitoringLink").text();
		            var indicatorName =$(this).children("Index").attr("Name");
		            var indicatorUnit =$(this).children("Index").attr("MeasurementUnit");
		            var valueIndicator =$(this).children("IndicatorValue").text();

		    		var myobj={rowID:countValue, categoryName:categoryName, metricName:metricName, minThreshold:minThreshold, maxThreshold:maxThreshold, unitThreshold:unitThreshold, linkMonitor:linkMonitor, indicatorName:indicatorName, indicatorUnit:indicatorUnit, valueIndicator:valueIndicator};
		    		performanceMetricsArray.push(myobj);
				    
				});
		var diag = $("#PerformancePolicyTemplateDiag");
		require(["winery-support-common"], function(w) {
			diag.modal("show");
		});
		
		$("#perfCatName").hide();
		$("#perfMetricName").hide();
		createMetricsTable= "";
		
		$.each(performanceMetricsArray, function( key, value ) {
			createMetricsTable= "<tr id=\"tr"+ value.rowID + "\"><td>"+ value.categoryName + "</td> <td>" +  value.metricName + " </td> <td>" + value.minThreshold +" </td> <td>" +  value.maxThreshold +" </td> <td>" +  value.unitThreshold +" </td> <td>" +  value.linkMonitor +" </td> <td>" +  value.indicatorName +" </td> <td>" +  value.indicatorUnit +" </td> <td>" +  value.valueIndicator + " </td><td><button type=\"button\"  id=\"r"+ value.rowID + "\" class=\"btn btn-primary\" onclick=\"updateMetric(this);\">Update</button></td><td><button type=\"button\"  id=\"" + value.rowID + "\" class=\"btn btn-danger\" onclick=\"deleteMetric(this);\">Delete</button></td></tr>"; 
			$("#MetricsTable").append(createMetricsTable);  
			});
		
    });
	
	
}

function showUpdateDiagForPolicy(policyElement) {
	currentPolicyElement = policyElement;

	$("#deletePolicy").show();
	$("#updatePolicy").show();
	$("#addPolicy").hide();
	
	var name = policyElement.children("div.name").text();
	var type = policyElement.children("span.type").text();
	
		$("#policyName").val(name);
		$("#policyType").val(type);
		

	// onchange of type is not called, we have to update the template selection field for ourselves
	// we also have to select the current user's choice
	updatePolicyTemplateSelect(policyElement.children("span.template").text());

	var diag = $("#PolicyDiag");
	require(["winery-support-common"], function(w) {
		w.replaceDialogShownHookForOrionUpdate(diag, "OrionpolicyXML", currentPolicyElement.children("textarea").val());
		diag.modal("show");
	});
}


function showDiagPolicyType(){
	
	var diag = $("#PolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function showDiagPolicyTemplate(){
	
	var diag = $("#PolicyTemplateDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function addPerformancePolicyType(){
	$("#performancePolicyTypeName").val("");
	$("#performancePropertiesDefinitionName").val("");
	var diag = $("#PerformancePolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function updatePerformancePolicyType(){
	
	var mydiag = $("#PolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		mydiag.modal("hide");
	});
	
	var diag = $("#ChoosePerformancePolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function addPerformancePolicyTemplate(){
	
	var mydiag = $("#PolicyTemplateDiag");
	require(["winery-support-common"], function(w) {
		mydiag.modal("hide");
	});	
	
	var diag = $("#SelectPerformancePolicyTypeDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitPerformancePolicyType(){
	
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var name = $("#performancePolicyTypeName").val();
	var propDef = $("#performancePropertiesDefinitionName").val();
	var sendparams = "/winery/policyTypeAddition.jsp?name="+name;
    sendparams += "&propDef="+propDef+"&repositoryPath="+repositoryPath+"&policyTypeNamespace="+policyTypeNamespace;
	window.location.replace(sendparams);

}

function submitPerformancePolicyTemplate(){
	
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var name = $("#perfPolName").val();
	var perfPolicytype = $("#perfPolType").val(); 
	var propDef = $("#perfPropDefinitionName").val();
	
	var arrayLength = performanceMetricsArray.length;
	var metricsCategoryArray = [];
	
	
	// store all the metrics categories
	for (var i = 0; i < arrayLength; i++) {
	   var obj = performanceMetricsArray[i];
	    
	   var categoryName = obj.categoryName;
	   metricsCategoryArray.push(categoryName);
	    
	}
	
	
	var distinctCategoryArray = [];
	//store all distinct metrics categories
	$.each(metricsCategoryArray, function(i, e) {
	        if ($.inArray(e, distinctCategoryArray) == -1) 
	        	distinctCategoryArray.push(e);
	    });
	
	var arraySize = distinctCategoryArray.length;
	metricsAsString = "";
	for (var i = 0; i < arraySize; i++) {
	 var tmpArray = performanceMetricsArray.filter(function (el) {
	        return el.categoryName == distinctCategoryArray[i];
	       });
	    
	    if(tmpArray.length > 1)
	    {
	    	var metricsArray = [];
	    	//Store all metrics
	    	for (var j = 0; j < tmpArray.length; j++) {
	    		   var newobj = tmpArray[j];
	    		    
	    		   var metricName = newobj.metricName;
	    		   metricsArray.push(metricName);
	    		    
	    		}
	    		
	    		
	    		
	    		var distinctMetricsArray = [];
	    		//Store all distinct metrics
	    		$.each(metricsArray, function(k, e) {
	    		        if ($.inArray(e, distinctMetricsArray) == -1) 
	    		        	distinctMetricsArray.push(e);
	    		    });
	    		
	    		var size = distinctMetricsArray.length;
	    		metricsAsString = metricsAsString+"<MetricsCategory Name= \"" + distinctCategoryArray[i] + "\">";
	    		for (var m = 0; m < size; m++) {
	    		 var localArray = tmpArray.filter(function (el) {
	    		        return el.metricName == distinctMetricsArray[m];
	    		       });
	    		 
	    		 if(localArray.length > 1)
	    		    {
	    			 metricsAsString = metricsAsString+ "<Metric Name= \"" + distinctMetricsArray[m] + "\">";
	    			 var tmp = localArray[0];
	    			 
	    				 metricsAsString = metricsAsString+ "<Threshold MeasurementUnit= \"" + tmp.unitThreshold + "\"><Lower>"+tmp.minThreshold+"</Lower><Upper>"+tmp.maxThreshold+"</Upper></Threshold><monitoringLink>"+tmp.linkMonitor+"</monitoringLink>";

	    		    	$.each(localArray, function(){
		    				
		    		    	 metricsAsString = metricsAsString+ "<AnalyticalIndicator><Index Name= \""+this.indicatorName+"\" MeasurementUnit= \""+this.indicatorUnit+"\"/><IndicatorValue>"+this.valueIndicator+"</IndicatorValue></AnalyticalIndicator>";
		    				
		    			});
		    		   	metricsAsString = metricsAsString+"</Metric>";
	    		    }
	    		   
	    		  else{
	    			 $.each(localArray, function(){	
	    			  metricsAsString = metricsAsString+ "<Metric Name= \"" + this.metricName + "\"><Threshold MeasurementUnit= \"" + this.unitThreshold + "\"><Lower>"+this.minThreshold+"</Lower><Upper>"+this.maxThreshold+"</Upper></Threshold><monitoringLink>"+this.linkMonitor+"</monitoringLink><AnalyticalIndicator><Index Name= \""+this.indicatorName+"\" MeasurementUnit= \""+this.indicatorUnit+"\"/><IndicatorValue>"+this.valueIndicator+"</IndicatorValue></AnalyticalIndicator></Metric>";
	    			 });	
	    		    }}
	    		metricsAsString = metricsAsString+"</MetricsCategory>"; 
	    }
	    
	    else {
	    	$.each(tmpArray, function(){
			
	    		metricsAsString = metricsAsString+"<MetricsCategory Name= \"" + distinctCategoryArray[i] + "\">";
	    		metricsAsString = metricsAsString+ "<Metric Name= \"" + this.metricName + "\"><Threshold MeasurementUnit= \"" + this.unitThreshold + "\"><Lower>"+this.minThreshold+"</Lower><Upper>"+this.maxThreshold+"</Upper></Threshold><monitoringLink>"+this.linkMonitor+"</monitoringLink><AnalyticalIndicator><Index Name= \""+this.indicatorName+"\" MeasurementUnit= \""+this.indicatorUnit+"\"/><IndicatorValue>"+this.valueIndicator+"</IndicatorValue></AnalyticalIndicator></Metric></MetricsCategory>";
			
		});
	    }
	        
	}

	var sendparams = "/winery/policyTemplateAddition.jsp?name="+name;
    sendparams += "&perfPolicytype="+perfPolicytype+"&propDef="+propDef+"&metricsAsString="+metricsAsString+"&repositoryPath="+repositoryPath+"&policyTemplateNamespace="+policyTemplateNamespace;
    
    performanceMetricsArray= [];
	countValue= 0;
    metricsAsString= "";
    window.location.replace(sendparams);

}

function addPerformanceMetrics(){
	var tmp1 = $("#performanceCategoryName").val();
	var tmp2 = $("#performanceMetricName").val();
	if(tmp1=="Other")
    {
		var category=$("#perfCatName").val();
		var metrics=$("#perfMetricName").val();
    }
	else if(tmp2=="Other"){
		var category=tmp1;
		var metrics=$("#perfMetricName").val();
	}
	else{
		var category=tmp1;
		var metrics=tmp2;
	}
	var thresholdMin = $("#thresholdMin").val();
	var thresholdMax = $("#thresholdMax").val();
	var thresholdUnit = $("#thresholdUnit").val();
	var monitoringLink = $("#monitoringLink").val();
	var indicatorIndexName = $("#indicatorIndexName").val();
	var indicatorIndexUnit = $("#indicatorIndexUnit").val();
	var indicatorValue = $("#indicatorValue").val();
	countValue= countValue + 1; 
	
	var metricObject = {
			rowID: countValue,
			categoryName: category,
			metricName: metrics,
			minThreshold: thresholdMin,
			maxThreshold: thresholdMax,
			unitThreshold: thresholdUnit,
			linkMonitor: monitoringLink,
			indicatorName: indicatorIndexName,
			indicatorUnit: indicatorIndexUnit,
			valueIndicator: indicatorValue
			
	};
	
	performanceMetricsArray.push(metricObject);
	createMetricsTable= "";
	createMetricsTable= "<tr id=\"tr"+ countValue + "\"><td>"+ metricObject['categoryName'] + "</td> <td>" +  metricObject['metricName'] + " </td> <td>" +  metricObject['minThreshold'] +" </td> <td>" +  metricObject['maxThreshold'] +" </td> <td>" +  metricObject['unitThreshold'] +" </td> <td>" +  metricObject['linkMonitor'] +" </td> <td>" +  metricObject['indicatorName'] +" </td> <td>" +  metricObject['indicatorUnit'] +" </td> <td>" +  metricObject['valueIndicator'] + " </td><td><button type=\"button\"  id=\"r"+ countValue + "\" class=\"btn btn-primary\" onclick=\"updateMetric(this);\">Update</button></td><td><button type=\"button\"  id=\"" + countValue + "\" class=\"btn btn-danger\" onclick=\"deleteMetric(this);\">Delete</button></td></tr>"; 
	
    //add to the table
    $("#MetricsTable").append(createMetricsTable);
	$("#submitPerformancePolicyTemplate").show();
}

function viewPerformanceMetrics(){
	var diag = $("#PerformanceMetricsDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function deleteMetric(el){
	var buttonId = $(el).attr('id');

    var tmpArray = performanceMetricsArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
	performanceMetricsArray= tmpArray;
	
	//write the logic for removing metrics
	$("#tr"+ buttonId).remove(); 

	if (performanceMetricsArray.length === 0) {
		$("#submitPerformancePolicyTemplate").hide();
	}

}

function updateMetric(el){
	metricUpdateButtonId = $(el).attr('id');
	var tmpArray = [];
	$('#t'+metricUpdateButtonId+' td').each(function() {
        var a=$(this).text();
        tmpArray.push(a);
    });

	$("#updateCatName").val($.trim(tmpArray[0]));
	$("#updateMetricName").val($.trim(tmpArray[1]));
	$("#updateThresholdMin").val($.trim(tmpArray[2]));
	$("#updateThresholdMax").val($.trim(tmpArray[3]));
	$("#updateThresholdUnit").val($.trim(tmpArray[4]));
	$("#updateMonitoringLink").val($.trim(tmpArray[5]));
	$("#updateIndicatorIndexName").val($.trim(tmpArray[6]));
	$("#updateIndicatorIndexUnit").val($.trim(tmpArray[7]));
	$("#updateIndicatorValue").val($.trim(tmpArray[8]));

	var diag = $("#UpdateMetricDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}        
        
function updateMetricTable(){
	var diag = $("#UpdateMetricDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
	$('#t'+metricUpdateButtonId+' td').eq(0).text($("#updateCatName").val());
	$('#t'+metricUpdateButtonId+' td').eq(1).text($("#updateMetricName").val());
	$('#t'+metricUpdateButtonId+' td').eq(2).text($("#updateThresholdMin").val());
	$('#t'+metricUpdateButtonId+' td').eq(3).text($("#updateThresholdMax").val());
	$('#t'+metricUpdateButtonId+' td').eq(4).text($("#updateThresholdUnit").val());
	$('#t'+metricUpdateButtonId+' td').eq(5).text($("#updateMonitoringLink").val());
	$('#t'+metricUpdateButtonId+' td').eq(6).text($("#updateIndicatorIndexName").val());
	$('#t'+metricUpdateButtonId+' td').eq(7).text($("#updateIndicatorIndexUnit").val());
	$('#t'+metricUpdateButtonId+' td').eq(8).text($("#updateIndicatorValue").val());
	
	var tableRowId=metricUpdateButtonId.substring(1);
	
	$.each(performanceMetricsArray, function() {
	    if (this.rowID == tableRowId) {
	        this.categoryName=$("#updateCatName").val();
	        this.metricName=$("#updateMetricName").val();
	        this.minThreshold=$("#updateThresholdMin").val();
	        this.maxThreshold=$("#updateThresholdMax").val();
	        this.unitThreshold=$("#updateThresholdUnit").val();
	        this.linkMonitor=$("#updateMonitoringLink").val();
	        this.indicatorName=$("#updateIndicatorIndexName").val();
	        this.indicatorUnit=$("#updateIndicatorIndexUnit").val();
	        this.valueIndicator=$("#updateIndicatorValue").val();
	    }
	});
}       

function showAddDiagForPolicy(nodeTemplateElement) {
	currentNodeTemplateElement = nodeTemplateElement;

	$("#deletePolicy").hide();
	$("#updatePolicy").hide();
	$("#addPolicy").show();
	
	$("#policyName").val("");

	// fill policy template select field
	updatePolicyTemplateSelect();

	var diag = $("#PolicyDiag");
	require(["winery-support-common"], function(w) {
		w.replaceDialogShownHookForOrionUpdate(diag, "OrionpolicyXML", $("#emptyPolicy").val());
		diag.modal("show");
	});
}

function addOrUpdatePolicy(doAdd) {
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}

	require(["winery-support-common", "tmpl"], function(wsc, tmpl) {
		var res = wsc.synchronizeNameAndType("policy", false, [{
			attribute: "policyType",
			fieldSuffix: "Type",
		}, {
			attribute: "policyRef",
			fieldSuffix: "Template"
		}]);

		if (res) {
			var policyTemplate = $("#policyTemplate").select2("data");
			var renderData = {
				name: $("#policyName").val(),

				policyTypeText: $("#policyType :selected").text(),
				policyTypeVal: $("#policyType").val(),

				policyTemplateText: policyTemplate.text,
				policyTemplateVal: policyTemplate.id,

				xml: res.xml
			};
			var div = tmpl("tmpl-policy", renderData);
			if (doAdd) {
				currentNodeTemplateElement.children("div.policiesContainer").children("div.content").children("div.addnewpolicy").before(div);
			} else {
				currentPolicyElement.replaceWith(div);
			}
			$("#PolicyDiag").modal("hide");
		} else {
			vShowError("Could not synchronize XML fields");
		}
	});
}


function deletePolicy() {
	// We just have to remove the HTML element:
	// The save operation converts the information in the HTML to XML
	currentPolicyElement.remove();
	$("#PolicyDiag").modal("hide");
}


$("#policyType")
	.select2()
	.on("change", updatePolicyTemplateSelect);
	
$("#perfPolicyType")
.select2()
.on("change", updatePerformanceTemplateSelect);	


</script>

<%-- parameters: o.id, o.name, o.policyType, o.policyRef, o.xml. Has to be consistent with the HTML generated by policies.tag --%>
<script type="text/x-tmpl" id="tmpl-policy">
	<div class="policy row"> <%-- "even"/"odd" is not set. Could be done by using $.prev() --%>
		<div class="col-xs-4 policy name">{%=o.name%}</div>

		<%-- we do not provide a link here. Link is only available at reload. Makes life easier here. makeArtifactTemplateURL at winery-common.js is a first hint of how to generate links --%>
		<div class="col-xs-4 policy type">{%=o.policyTypeText%}</div>
		<span class="type">{%=o.policyTypeVal%}</span>

		<div class="col-xs-4 policy template">{%=o.policyTemplateText%}</div>
		<span class="template">{%=o.policyTemplateVal%}</span>

		<textarea class="policy_xml">{%=o.xml%}</textarea>
	</div>
</script>
