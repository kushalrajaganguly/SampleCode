<%--
/*******************************************************************************
 * Copyright (c) 2012-2013 University of Stuttgart.
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
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="v"
	uri="http://www.eclipse.org/winery/repository/functions"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags"%>
<%@taglib prefix="wc" uri="http://www.eclipse.org/winery/functions"%>
<%-- In English, one can usually form a plural by adding an "s". Therefore, we resue the label to form the window title --%>
<t:genericpage windowtitle="${it.label}s" selected="${it.type}"
	cssClass="${it.CSSclass}">

	<c:choose>
		<c:when test="${empty pageContext.request.contextPath}">
			<c:set var="URL" value="/" />
		</c:when>
		<c:otherwise>
			<c:set var="URL" value="${pageContext.request.contextPath}/" />
		</c:otherwise>
	</c:choose>
	<t:simpleSingleFileUpload title="Upload CSAR" text="CSAR file"
		URL="${URL}" type="POST" id="upCSAR" accept="application/zip,.csar" />

	<t:addComponentInstance label="${it.label}"
		typeSelectorData="${it.typeSelectorData}" />

	<div class="middle" id="ccontainer">
		<br />

		<table cellpadding=0 cellspacing=0
			style="margin-top: 0px; margin-left: 30px;">
			<tr>
				<td valign="top" style="padding-top: 25px; width: 680px;">

					<div id="searchBoxContainer">

						<input id="searchBox" />

						<script>

						$('#searchBox').keyup(function() {
							var searchString = $(this).val();
							searchString = searchString.toLowerCase();

							$(".entityContainer").each (function() {
								var name = $(this).find(".informationContainer > .name").text();
								var namespace = $(this).find(".informationContainer > .namespace").text();

								var t = name + namespace;
								t = t.toLowerCase();

								if (t.indexOf(searchString) == -1) {
									$(this).hide();
								} else {
									$(this).show();
								}

							});

						});

					</script>

					</div> <c:forEach var="t" items="${it.componentInstanceIds}">
						<%-- even though the id is an invalid XML, it is used for a simple implementation on a click on the graphical rendering to trigger opening the editor --%>
						<div class="entityContainer ${it.CSSclass}"
							id="${v:URLencode(t.namespace.encoded)}/${v:URLencode(t.xmlId.encoded)}/">
							<div class="left">
								<c:if test="${it.type eq 'NodeType'}">
									<a
										href="./${v:URLencode(t.namespace.encoded)}/${v:URLencode(t.xmlId.encoded)}/?edit">
										<img
										src='./${v:URLencode(t.namespace.encoded)}/${v:URLencode(t.xmlId.encoded)}/visualappearance/50x50'
										style='margin-top: 21px; margin-left: 30px; height: 40px; width: 40px;' />
									</a>
								</c:if>
							</div>
							<div class="center">
								<div class="informationContainer">
									<div class="name">${wc:escapeHtml4(t.xmlId.decoded)}</div>
									<div class="namespace"
										alt="${wc:escapeHtml4(t.namespace.decoded)}">
										${wc:escapeHtml4(t.namespace.decoded)}</div>
								</div>
								<div class="buttonContainer">
									<a
										href="${v:URLencode(t.namespace.encoded)}/${v:URLencode(t.xmlId.encoded)}/?csar"
										class="exportButton"></a> <a
										href="${v:URLencode(t.namespace.encoded)}/${v:URLencode(t.xmlId.encoded)}/?edit"
										class="editButton"></a>
									<%-- we need double encoding of the URL as the passing to javascript: decodes the given string once --%>
									<a
										href="javascript:deleteCI('${wc:escapeHtml4(t.xmlId.decoded)}', '${v:URLencode(v:URLencode(t.namespace.encoded))}/${v:URLencode(v:URLencode(t.xmlId.encoded))}/');"
										class="deleteButton"
										onclick="element = $(this).parent().parent().parent();"></a>
								</div>
							</div>
							<div class="right"></div>
						</div>
					</c:forEach>
				</td>
				<td id="gcprightcolumn" valign="top">
					<div id="overviewtopshadow"></div>
					<div id="overviewbottomshadow"></div>
				</td>
				<td valign="top">
					<div class="btn-group-vertical" id="buttonList">
						<button type="button" class="btn btn-default"
							onclick="openNewCIdiag();">Add new</button>
						<button type="button" class="btn btn-default"
							onclick="importCSAR();">Import CSAR</button>
						<button type="button" class="btn btn-default"
							onclick="chooseServiceTemplate();">Add Workload</button>
					</div>
				</td>
			</tr>
		</table>
	</div>

	<div class="modal fade" id="ChooseServiceTemplate">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Choose Service Template</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="templateNamespace" class="control-label">Service
							Template Namespace:</label> <select id="templateNamespace"
							name="templateNamespace" class="form-control" required="required"></select>
					</div>
					<div class="form-group">
						<label for="serviceTemplateName" class="control-label">Service
							Template Name:</label> <select id="serviceTemplateName"
							class="form-control" name="serviceTemplateName"
							required="required"></select>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" id="submitServiceTemplate"
						class="btn btn-primary" onclick="submitServiceTemplate();">Submit</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="WorkloadDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add Workload Samples</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="servTemplateName" class="control-label">Service
							Template Name:</label> <input id="servTemplateName" class="form-control"
							name="servTemplateName" type="text" required="required" />
					</div>

					<div class="form-group">
						<button type="button" id="addWorkloadSample"
							class="btn btn-primary" onclick="addWorkloadSample();">Add
							New Sample</button>
					</div>

					<div class="form-group">
						<button type="button" id="listWorkloadSample"
							class="btn btn-primary" onclick="listWorkloadSample();">List
							Samples</button>
					</div>

				</div>
				<div class="modal-footer">
					<button type="button" id="submitWorkload" class="btn btn-danger"
						onclick="submitWorkload();">Submit</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="AddWorkloadDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add New Workload Sample</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="workloadSampleName" class="control-label">Workload
							Sample Name:</label> <input id="workloadSampleName" class="form-control"
							name="workloadSampleName" type="text" required="required" />
					</div>

					<div class="form-group">
						<div class="col-sm-6">
							<label for="sampleTimeInterval" class="control-label">Workload
								Sample Duration:</label> <input id="sampleTimeInterval"
								class="form-control" name="sampleTimeInterval" type="text"
								required="required" />
						</div>
						<div class="col-sm-6">
							<label for="sampleTimeUnit" class="control-label">Sample
								Duration Unit:</label> <input id="sampleTimeUnit" name="sampleTimeUnit"
								class="form-control" type="text" required="required" />
						</div>
					</div>
					<div class="form-group">
						<table class="table" id="addWorkloadDiagTable">
							<tbody>
								<tr>
									<td>User Information:</td>
									<td>
										<button type="button" id="addUserInfo" class="btn btn-primary"
											onclick="addUserInfo();">Add</button>
									</td>
									<td>
										<button type="button" id="listUserInfo"
											class="btn btn-primary" onclick="listUserInfo();">List</button>
									</td>
								</tr>
								<tr>
									<td>Behavior Model Information:</td>
									<td>
										<button type="button" id="addBehaviorInfo"
											class="btn btn-primary" onclick="addBehaviorInfo();">Add</button>
									</td>
									<td>
										<button type="button" id="listBehaviorInfo"
											class="btn btn-primary" onclick="listBehaviorInfo();">List</button>
									</td>
								</tr>

								<tr>
									<td>Application State Information:</td>
									<td>
										<button type="button" id="addAppStateInfo"
											class="btn btn-primary" onclick="addAppStateInfo();">Add</button>
									</td>
									<td>
										<button type="button" id="listAppStateInfo"
											class="btn btn-primary" onclick="listAppStateInfo();">List</button>
									</td>
								</tr>
								<tr>
									<td>
										<button type="button" id="submitWorkloadSample"
											class="btn btn-danger" onclick="submitWorkloadSample();">Submit</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="ListWorkloadDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">List Workload Samples</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ListWorkloadDiagTable">
							<thead>
								<tr>
									<th>Sample</th>
									<th>Time Duration</th>
									<th>Unit</th>

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

	<div class="modal fade" id="AddUserInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add New User Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<div class="col-sm-6">
							<label for="userID" class="control-label">User ID:</label> <input
								id="userID" class="form-control" name="userID" type="text"
								required="required" />
						</div>
						<div class="col-sm-6">
							<label for="sessionCount" class="control-label">Average
								Number of Sessions:</label> <input id="sessionCount"
								class="form-control" name="sessionCount" type="text"
								required="required" />
						</div>
					</div>
					<div class="form-group">
						<div class="col-sm-6">
							<label for="sessionDuration" class="control-label">Average
								Session Duration:</label> <input id="sessionDuration"
								class="form-control" name="sessionDuration" type="text"
								required="required" />
						</div>
						<div class="col-sm-6">
							<label for="sessionTimeUnit" class="control-label">Session
								Duration Unit:</label> <input id="sessionTimeUnit"
								name="sessionTimeUnit" class="form-control" type="text"
								required="required" />

						</div>
					</div>

				</div>
				<div class="modal-footer">
					<button type="button" id="submitUserInfo" class="btn btn-primary"
						onclick="submitUserInfo();">Add</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="ListUserInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">List User Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ListUserInfoDiagTable">
							<thead>
								<tr>
									<th>User ID</th>
									<th>Number of Sessions</th>
									<th>Session Duration</th>
									<th>Unit</th>

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

	<div class="modal fade" id="UpdateUserInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Update User Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<div class="col-sm-6">
							<label for="updateUserID" class="control-label">User ID:</label>
							<input id="updateUserID" class="form-control" name="updateUserID"
								type="text" required="required" />
						</div>
						<div class="col-sm-6">
							<label for="updateSessionCount" class="control-label">Average
								Number of Sessions:</label> <input id="updateSessionCount"
								class="form-control" name="updateSessionCount" type="text"
								required="required" />
						</div>
					</div>
					<div class="form-group">
						<div class="col-sm-6">
							<label for="updateSessionDuration" class="control-label">Average
								Session Duration:</label> <input id="updateSessionDuration"
								class="form-control" name="updateSessionDuration" type="text"
								required="required" />
						</div>
						<div class="col-sm-6">
							<label for="updateSessionTimeUnit" class="control-label">Session
								Duration Unit:</label> <input id="updateSessionTimeUnit"
								name="updateSessionTimeUnit" class="form-control" type="text" />

						</div>
					</div>

				</div>
				<div class="modal-footer">
					<button type="button" id="submitUpdateUserInfo"
						class="btn btn-primary" onclick="submitUpdateUserInfo();">Update</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="AddBehaviorInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add New Behavior Model Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="behaviorModelName" class="control-label">Behavior
							Model Name:</label> <input id="behaviorModelName" class="form-control"
							name="behaviorModelName" type="text" required="required" />
					</div>

					<div class="form-group">
						<div class="col-sm-6">
							<label for="relativeOccurence" class="control-label">Probability
								of Occurrence:</label> <input id="relativeOccurence"
								class="form-control" name="relativeOccurence" type="text"
								required="required" />
						</div>
						<div class="col-sm-6">
							<label for="importCSV" class="control-label">Upload
								Probabilistic Model File:</label>
							<button type="button" id="importCSV" class="btn btn-default"
								onclick="importCSV();">Import CSV File</button>
						</div>
					</div>

				</div>
				<div class="modal-footer">
					<button type="button" id="submitBehaviorInfo"
						class="btn btn-primary" onclick="submitBehaviorInfo();">Add</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="upCSVFileDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Upload CSV File for Probabilistic
						Model</h4>
				</div>
				<div class="modal-body">
					<div class="form-group">
						<label for="csvFileUpload" class="control-label">Upload
							CSV File:</label> <input type="file" id="csvFileUpload" />
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" id="csvUpload" class="btn btn-primary">Upload</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="ListBehaviorInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">List Behavior Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ListBehaviorInfoDiagTable">
							<thead>
								<tr>
									<th>Behavior Model Name</th>
									<th>Probability of Occurrence</th>
									<th>CSV File Reference</th>

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

	<div class="modal fade" id="UpdateBehaviorInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Update Behavior Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="updateBehaviorModelName" class="control-label">Behavior
							Model Name:</label> <input id="updateBehaviorModelName"
							class="form-control" name="updateBehaviorModelName" type="text"
							required="required" />
					</div>

					<div class="form-group">
						<div class="col-sm-6">
							<label for="updateRelativeOccurence" class="control-label">Probability
								of Occurrence:</label> <input id="updateRelativeOccurence"
								class="form-control" name="updateRelativeOccurence" type="text"
								required="required" />
						</div>
						<div class="col-sm-6">
							<label for="updateImportCSV" class="control-label">Upload
								Probabilistic Model File:</label>
							<button type="button" id="updateImportCSV"
								class="btn btn-default" onclick="updateImportCSV();">Import
								CSV File</button>
						</div>
					</div>

				</div>
				<div class="modal-footer">
					<button type="button" id="updateSubmitBehaviorInfo"
						class="btn btn-primary" onclick="updateSubmitBehaviorInfo();">Update</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="AddAppStateInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add New Application State Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="appStateName" class="control-label">Application
							State Name:</label> <input id="appStateName" class="form-control"
							name="appStateName" type="text" required="required" />
					</div>

					<div class="form-group">
						<table class="table" id="AddAppStateInfoDiagTable">
							<tbody>
								<tr>
									<td>Operations Information:</td>
									<td>
										<button type="button" id="addOperationInfo"
											class="btn btn-primary" onclick="addOperationInfo();">Add</button>
									</td>
									<td>
										<button type="button" id="listOperationInfo"
											class="btn btn-primary" onclick="listOperationInfo();">List</button>
									</td>
								</tr>
								<tr>
									<td>
										<button type="button" id="submitAppState"
											class="btn btn-danger" onclick="submitAppState();">Submit</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="ListAppStateInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">List Application State Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ListAppStateInfoDiagTable">
							<thead>
								<tr>
									<th>Application State Name:</th>
									<th>View</th>

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

	<div class="modal fade" id="AddOperationInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add New Operation Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="operationName" class="control-label">Operation
							Name:</label> <input id="operationName" class="form-control"
							name="operationName" type="text" required="required" />
					</div>
					<div class="form-group">
						<table class="table" id="AddOperationInfoDiagTable">
							<tbody>
								<tr>
									<td>Request Information:</td>
									<td>
										<button type="button" id="addRequest" class="btn btn-primary"
											onclick="addRequest();">Add</button>
									</td>
									<td>
										<button type="button" id="listRequest" class="btn btn-primary"
											onclick="listRequest();">List</button>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" id="submitOperationInfo"
						class="btn btn-primary" onclick="submitOperationInfo();">Add</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="ListOperationInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">List Operation Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ListOperationInfoDiagTable">
							<thead>
								<tr>
									<th>Operation Name</th>
									<th>View</th>

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


	<div class="modal fade" id="ViewOperationInfoDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">View Operation Information</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ViewOperationInfoDiagTable">
							<thead>
								<tr>
									<th>Operation Name</th>
									<th>View</th>
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

	<div class="modal fade" id="AddRequestDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Add New Request</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">
						<label for="requestName" class="control-label">Request:</label> <input
							id="requestName" class="form-control" name="requestName"
							type="text" required="required" />
					</div>

				</div>
				<div class="modal-footer">
					<button type="button" id="submitRequest" class="btn btn-primary"
						onclick="submitRequest();">Add</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="ListRequestDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">List Request</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ListRequestDiagTable">
							<thead>
								<tr>
									<th>Request</th>

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


	<div class="modal fade" id="ViewRequestDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">View Request</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ViewRequestDiagTable">
							<thead>
								<tr>
									<th>Request</th>
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

	<div class="modal fade" id="ShowRequestDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Show Request</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="ShowRequestDiagTable">
							<thead>
								<tr>
									<th>Request</th>
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


	<div class="modal fade" id="upCSVFileUpdateDiag">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">Upload CSV File for Probabilistic
						Model</h4>
				</div>
				<div class="modal-body">
					<div class="form-group">
						<label for="csvUpdateFileUpload" class="control-label">Upload
							CSV File:</label> <input type="file" id="csvUpdateFileUpload" />
					</div>
				</div>
				<div class="modal-footer">
					<button type="button" id="csvUpdateUpload" class="btn btn-primary">Upload</button>
				</div>
			</div>
		</div>
	</div>

	<div class="modal fade" id="showCSVLink">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal"
						aria-hidden="true">&times;</button>
					<h4 class="modal-title">CSV File Reference</h4>
				</div>
				<div class="modal-body">

					<div class="form-group">

						<table class="table" id="showCSVLinkTable">
							<tbody>

							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script>
	var repositoryPath="";
	var serviceTemplate="";
	var sampleName="";
	var behavModelName="";
	var createSamplesTable= "";
	var createUserInfoTable="";
	var createbehavModelTable= "";
	var createAppStateTable= "";
	var createOpInfoTable="";
	var createrequestTable= "";
	var updateButtonId1="";
	var updateButtonId2="";
	var samplesCount=0;
	var userInfoCounter= 0;
	var behavModelCounter= 0;
	var appStateCounter= 0;
	var operationCounter= 0;
	var requestCounter= 0;
	var userInfoArray=[];
	var behavInfoArray=[];
	var appStateInfoArray=[];
	var operationInfoArray=[];
	var requestArray=[];
	var samplesArray=[];
	
	$.get("/winery/readPropertiesFile.jsp", function(data, status){
		var resArray=data.split(",End Here,");
		repositoryPath=resArray[0];
		$.get("/winery/listTemplateNamespace.jsp?repositoryPath="+repositoryPath, function(data, status){
			var resArray=data.split(",End Here,");
			$('#templateNamespace').html('');
			eval(resArray).forEach(function(x) {
						var y=decodeURIComponent(x);
			            $('#templateNamespace').append('<option value='+x+'>'+y+'</option>');
			        });

		});
	});
	
	$(function () {
	    $("#csvUpload").bind("click", function () {
	        var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
	        if (regex.test($("#csvFileUpload").val().toLowerCase())) {
	            
	            if (typeof (FileReader) != "undefined") {
	                var reader = new FileReader();
	                reader.onload = function (e) {
	                    var rows = e.target.result.split("\n");
	                    var tmpArray=[];
	                    for (var i = 0; i < rows.length; i++) {
	                        var cells = rows[i].split(",");
	                        tmpArray.push(cells);
	                        tmpArray.push("End Here");
	                        }
	                    
	                    $.get("/winery/csvFileWrite.jsp?tmpArray="+tmpArray+"&repositoryPath="+repositoryPath+"&serviceTemplate="+serviceTemplate+"&sampleName="+sampleName+"&behavModelName="+behavModelName, function(data, status){
		            		var mydiag = $("#upCSVFileDiag");
		            		require(["winery-support-common"], function(w) {
		            			mydiag.modal("hide");
		            		});
		            	});
	                }
	                reader.readAsText($("#csvFileUpload")[0].files[0]);
	            } else {
	                alert("This browser does not support HTML5.");
	            }
	        } else {
	            alert("Please upload a valid CSV file.");
	        }
	    });
	    
	});
	
	$(function () {
	    $("#csvUpdateUpload").bind("click", function () {
	        var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
	        if (regex.test($("#csvUpdateFileUpload").val().toLowerCase())) {
	            
	            if (typeof (FileReader) != "undefined") {
	                var reader = new FileReader();
	                reader.onload = function (e) {
	                    var rows = e.target.result.split("\n");
	                    var tmpArray=[];
	                    for (var i = 0; i < rows.length; i++) {
	                        var cells = rows[i].split(",");
	                        tmpArray.push(cells);
	                        tmpArray.push("End Here");
	                        }
	                    
	                    $.get("/winery/csvFileWrite.jsp?tmpArray="+tmpArray+"&repositoryPath="+repositoryPath+"&serviceTemplate="+serviceTemplate+"&sampleName="+sampleName+"&behavModelName="+behavModelName, function(data, status){
		            		var mydiag = $("#upCSVFileUpdateDiag");
		            		require(["winery-support-common"], function(w) {
		            			mydiag.modal("hide");
		            		});
		            	});
	                }
	                reader.readAsText($("#csvUpdateFileUpload")[0].files[0]);
	            } else {
	                alert("This browser does not support HTML5.");
	            }
	        } else {
	            alert("Please upload a valid CSV file.");
	        }
	    });
	    
	});

	
	selectList();
	$('#templateNamespace').change(function(){
		selectList();
	});
	    
	function selectList(){
		var selectedNamespace=$('#templateNamespace').val();
		selectedNamespace=encodeURIComponent(selectedNamespace);
		$.get("/winery/listServiceTemplates.jsp?selectedNamespace="+selectedNamespace+"&repositoryPath="+repositoryPath, function(data, status){
			var resArray=data.split(",End Here,");
	    $('#serviceTemplateName').html('');
	    
	    eval(resArray).forEach(function(x) { 
	    	if(x!=""){
	            $('#serviceTemplateName').append('<option>'+x+'</option>');
	    	}
	    	});
	       
	});
	}

	
function chooseServiceTemplate(){
	 $("#serviceTemplateName").val("");
	 
	var diag = $("#ChooseServiceTemplate");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitServiceTemplate(){
	samplesArray=[];
	$("#ListWorkloadDiagTable > tbody").html("");
	samplesCount=0;
	var serviceName = $("#serviceTemplateName").val();
	$("#servTemplateName").val(serviceName);
	
	var diag = $("#WorkloadDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitWorkload(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var workloadString="";
	var samplesString="";
	
	$.each(samplesArray, function() {
			var tmpArray1=this.userArray;
			var tmpArray2=this.behaviorArray;
			var tmpArray3=this.appStateArray;
			var usersString="";
			var behaviorsString="";
			var appStatesString="";
			
			$.each(tmpArray1, function() {
				var userString="<User UserID=\""+this.user+"\"><SessionCount>"+this.countSession+"</SessionCount><SessionDuration>"+this.durationSession+"</SessionDuration><Unit>"+this.unitSessionTime+"</Unit></User>";
				usersString=usersString.concat(userString);
			});
			
			$.each(tmpArray2, function() {
				var tmp=this.csv;
					tmp=tmp.replace(/&/g, "&amp;");
					tmp=encodeURIComponent(tmp);
					var behaviorString="<BehaviorModel ModelName=\""+this.model+"\"><ProbabilityOccurrence>"+this.relOccurence+"</ProbabilityOccurrence><CSVReference>"+tmp+"</CSVReference></BehaviorModel>";
				behaviorsString=behaviorsString.concat(behaviorString);
			});
			
			$.each(tmpArray3, function() {
				var tmpArray4=this.arr;
				var protocolsString="";
				
				$.each(tmpArray4, function() {
					var tmpArray5=this.innerArr;
					var requestsString="";
					$.each(tmpArray5, function() {
						var requestString="<Request>"+this.reqName+"</Request>";
						requestsString=requestsString.concat(requestString);
					});
					var protocolString="<ProtocolLayer Name=\""+this.opName+"\">"+requestsString+"</ProtocolLayer>";
					protocolsString=protocolsString.concat(protocolString);
				});
				
				var appStateString="<ApplicationState Name=\""+this.nameState+"\">"+protocolsString+"</ApplicationState>";
				appStatesString=appStatesString.concat(appStateString);
			});	
			
		behaviorsString="<BehaviorMix>"+behaviorsString+"</BehaviorMix>";
		appStatesString="<ApplicationModel>"+appStatesString+"</ApplicationModel>";
		var sampleString="<WorkloadSample SampleName=\""+this.sampleName+"\"><SampleInterval>"+this.sampleInterval+"</SampleInterval><Unit>"+this.sampleUnit+"</Unit>"+usersString+behaviorsString+appStatesString+"</WorkloadSample>";
		samplesString=samplesString.concat(sampleString);
		});
	
	var name=$("#servTemplateName").val();
	
	$.get("/winery/displayWorkload.jsp?serviceTemplate="+name+"&repositoryPath="+repositoryPath, function(data, status){
		if(data!=null)
			{
			workloadString=(new XMLSerializer()).serializeToString(data);	
			}
		
		workloadString=workloadString.replace("<Workload>",'');
		workloadString=workloadString.replace("</Workload>",'');
		workloadString=workloadString.replace("<Workload/>",'');
		workloadString=workloadString.replace("<Message>There is no workload specification for the service template</Message>",'');
		workloadString=encodeURIComponent(workloadString);
		workloadString=workloadString.concat(samplesString);
		workloadString="<Workload>"+workloadString+"</Workload>";
		
		
		var sendparams = "/winery/workloadAddition.jsp?name="+name;
		sendparams += "&samplesArray="+workloadString+"&repositoryPath="+repositoryPath;
	    
		samplesArray=[];
	    $("#ListWorkloadDiagTable > tbody").html("");
		samplesCount=0;
		
		window.location.replace(sendparams);
		
	});
	
	
}

function addWorkloadSample(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	userInfoArray=[];
	behavInfoArray=[];
	appStateInfoArray=[];
	userInfoCounter= 0;
	behavModelCounter= 0;
	appStateCounter= 0;
	operationCounter=0;
	requestCounter=0;
	
	$("#workloadSampleName").val("");
	$("#sampleTimeInterval").val("");
	$("#sampleTimeUnit").val("");
	$("#ListUserInfoDiagTable > tbody").html("");
	$("#ListBehaviorInfoDiagTable > tbody").html("");
	$("#ListAppStateInfoDiagTable > tbody").html("");
	
	var diag = $("#AddWorkloadDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitWorkloadSample(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	samplesCount= samplesCount+1;
	var sampleObj={
		  rowID:samplesCount,	
		  sampleName:$("#workloadSampleName").val(),
		  sampleInterval:$("#sampleTimeInterval").val(),
		  sampleUnit:$("#sampleTimeUnit").val(),
		  userArray:userInfoArray,
		  behaviorArray:behavInfoArray,
		  appStateArray:appStateInfoArray
	};
	samplesArray.push(sampleObj);
	createSamplesTable= "";
	createSamplesTable= "<tr id=\"tra"+ samplesCount + "\"><td>"+ sampleObj['sampleName'] +"</td> <td>" +  sampleObj['sampleInterval'] + " </td> <td>" +  sampleObj['sampleUnit']+ " </td><td><button type=\"button\"  id=\"a" + samplesCount + "\" class=\"btn btn-danger\" onclick=\"deleteSample(this);\">Delete</button></td></tr>"; 
	//add to the table
    $("#ListWorkloadDiagTable").append(createSamplesTable);
	
	var diag = $("#AddWorkloadDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function listWorkloadSample(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var diag = $("#ListWorkloadDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function deleteSample(el){
	var buttonId = $(el).attr('id');
	buttonId=buttonId.substring(1);
    var tmpArray = samplesArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
    samplesArray= tmpArray;
	
	//write the logic for removing
	$("#tra"+ buttonId).remove(); 
}

function addUserInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	
	$("#userID").val("");
	$("#sessionCount").val(""); 
	$("#sessionDuration").val("");
	$("#sessionTimeUnit").val("");
	
	var diag =$("#AddUserInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitUserInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var userID = $("#userID").val();
	var sessionCount = $("#sessionCount").val(); 
	var sessionDuration = $("#sessionDuration").val();
	var sessionTimeUnit = $("#sessionTimeUnit").val();
	userInfoCounter = userInfoCounter +1;
	var userInfoObj={
			rowID:userInfoCounter,
			user:userID,
			countSession:sessionCount,
			durationSession:sessionDuration,
			unitSessionTime:sessionTimeUnit
	};
	userInfoArray.push(userInfoObj);
	createUserInfoTable= "";
	createUserInfoTable= "<tr id=\"tru"+ userInfoCounter + "\"><td>"+ userInfoObj['user'] + "</td> <td>" +  userInfoObj['countSession'] + " </td> <td>" +  userInfoObj['durationSession'] +" </td> <td>" +  userInfoObj['unitSessionTime'] + " </td><td><button type=\"button\"  id=\"ru"+ userInfoCounter + "\" class=\"btn btn-primary\" onclick=\"updateUserInfo(this);\">Update</button></td><td><button type=\"button\"  id=\"u" + userInfoCounter + "\" class=\"btn btn-danger\" onclick=\"deleteUserInfo(this);\">Delete</button></td></tr>"; 
	//add to the table
    $("#ListUserInfoDiagTable").append(createUserInfoTable);
	var diag = $("#AddUserInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function listUserInfo(){
	var diag = $("#ListUserInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function updateUserInfo(el){
	updateButtonId1 = $(el).attr('id');
	var tmpArray = [];
	$('#t'+updateButtonId1+' td').each(function() {
        var a=$(this).text();
        tmpArray.push(a);
    });

	$("#updateUserID").val($.trim(tmpArray[0]));
	$("#updateSessionCount").val($.trim(tmpArray[1]));
	$("#updateSessionDuration").val($.trim(tmpArray[2]));
	$("#updateSessionTimeUnit").val($.trim(tmpArray[3]));
	
	var diag = $("#UpdateUserInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitUpdateUserInfo(){
	var diag = $("#UpdateUserInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
	$('#t'+updateButtonId1+' td').eq(0).text($("#updateUserID").val());
	$('#t'+updateButtonId1+' td').eq(1).text($("#updateSessionCount").val());
	$('#t'+updateButtonId1+' td').eq(2).text($("#updateSessionDuration").val());
	$('#t'+updateButtonId1+' td').eq(3).text($("#updateSessionTimeUnit").val());
	
	var tableRowId=updateButtonId1.substring(2);
	
	$.each(userInfoArray, function() {
	    if (this.rowID == tableRowId) {
	        this.user=$("#updateUserID").val();
	        this.countSession=$("#updateSessionCount").val();
	        this.durationSession=$("#updateSessionDuration").val();
	        this.unitSessionTime=$("#updateSessionTimeUnit").val();
	        }
	});
	var diag = $("#UpdateUserInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function deleteUserInfo(el){
	var buttonId = $(el).attr('id');
	buttonId=buttonId.substring(1);
    var tmpArray = userInfoArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
    userInfoArray= tmpArray;
	
	//write the logic for removing
	$("#tru"+ buttonId).remove(); 
}

function addBehaviorInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	$("#behaviorModelName").val("");
	$("#relativeOccurence").val("");
	
	var diag = $("#AddBehaviorInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function importCSV() {
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	serviceTemplate=$("#servTemplateName").val();
    sampleName=$("#workloadSampleName").val();
    behavModelName=$("#behaviorModelName").val();
    
	var diag = $("#upCSVFileDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});

}

function submitBehaviorInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var modelName = $("#behaviorModelName").val();
	var probOccurence = $("#relativeOccurence").val(); 
	var csvLink = "http://localhost:8080/winery/csvTable.jsp?repositoryPath="+$.trim(repositoryPath)+"&serviceTemplate="+serviceTemplate+"&sampleName="+sampleName+"&behavModelName="+behavModelName;
	behavModelCounter = behavModelCounter +1;
	var behavModelObj={
			rowID:behavModelCounter,
			model:modelName,
			relOccurence:probOccurence,
			csv:csvLink
			};
	behavInfoArray.push(behavModelObj);
	createbehavModelTable= "";
	createbehavModelTable= "<tr id=\"trb"+ behavModelCounter + "\"><td>"+ behavModelObj['model'] + "</td> <td>" +  behavModelObj['relOccurence'] + " </td> <td>" +  "<button type=\"button\"  id=\"csv"+ behavModelCounter + "\" class=\"btn btn-primary\" onclick=\"showLink(this);\">Show</button>" + " </td><td><button type=\"button\"  id=\"rb"+ behavModelCounter + "\" class=\"btn btn-primary\" onclick=\"updateBehaviorInfo(this);\">Update</button></td><td><button type=\"button\"  id=\"b" + behavModelCounter + "\" class=\"btn btn-danger\" onclick=\"deleteBehaviorInfo(this);\">Delete</button></td></tr>"; 
	//add to the table
    $("#ListBehaviorInfoDiagTable").append(createbehavModelTable);
	var diag = $("#AddBehaviorInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function listBehaviorInfo(){
	var diag = $("#ListBehaviorInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function showLink(el){
	$("#showCSVLinkTable > tbody").html("");
	updateButtonId2 = $(el).attr('id');
	var tableRowId=updateButtonId2.substring(3);
	var linkCSV="";
	$.each(behavInfoArray, function() {
	    if (this.rowID == tableRowId) {
	        linkCSV=this.csv;
	        }
	});
	$("#showCSVLinkTable").append("<tr><td><a class=\"btn btn-default\" href="+linkCSV+" target=\"_blank\">Link</a>"+"</td></tr>");
	var diag = $("#showCSVLink");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function updateBehaviorInfo(el){
	updateButtonId2 = $(el).attr('id');
	var tmpArray = [];
	$('#t'+updateButtonId2+' td').each(function() {
        var a=$(this).text();
        tmpArray.push(a);
    });

	$("#updateBehaviorModelName").val($.trim(tmpArray[0]));
	$("#updateRelativeOccurence").val($.trim(tmpArray[1]));
	
	var diag = $("#UpdateBehaviorInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function updateImportCSV() {
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	serviceTemplate=$("#servTemplateName").val();
    sampleName=$("#workloadSampleName").val();
    behavModelName=$("#updateBehaviorModelName").val();
    
	var diag = $("#upCSVFileUpdateDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});

}

function updateSubmitBehaviorInfo(){
	var diag = $("#UpdateBehaviorInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
	var csvLink = "http://localhost:8080/winery/csvTable.jsp?repositoryPath="+$.trim(repositoryPath)+"&serviceTemplate="+serviceTemplate+"&sampleName="+sampleName+"&behavModelName="+behavModelName;
	$('#t'+updateButtonId2+' td').eq(0).text($("#updateBehaviorModelName").val());
	$('#t'+updateButtonId2+' td').eq(1).text($("#updateRelativeOccurence").val());
	
	var tableRowId=updateButtonId2.substring(2);
	
	$.each(behavInfoArray, function() {
	    if (this.rowID == tableRowId) {
	        this.model=$("#updateBehaviorModelName").val();
	        this.relOccurence=$("#updateRelativeOccurence").val();
	        this.csv=csvLink;
	        }
	});
	var diag = $("#UpdateBehaviorInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function deleteBehaviorInfo(el){
	var buttonId = $(el).attr('id');
	buttonId=buttonId.substring(1);
    var tmpArray = behavInfoArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
    behavInfoArray= tmpArray;
	
	//write the logic for removing
	$("#trb"+ buttonId).remove(); 	
}

function addAppStateInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	$("#ListOperationInfoDiagTable > tbody").html("");
	$("#appStateName").val("");
	operationInfoArray=[];
	var diag = $("#AddAppStateInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitAppState(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var stateName = $("#appStateName").val();
	appStateCounter = appStateCounter +1;
	var appStateObj={
			rowID:appStateCounter,
			nameState:stateName,
			arr:operationInfoArray
			};
	appStateInfoArray.push(appStateObj);
	createAppStateTable= "";
	createAppStateTable= "<tr id=\"trs"+ appStateCounter + "\"><td>"+ appStateObj['nameState'] + " </td>"+"<td><button type=\"button\"  id=\"rs" + appStateCounter + "\" class=\"btn btn-primary\" onclick=\"viewAppStateInfo(this);\">View</button></td>"+"<td><button type=\"button\"  id=\"s" + appStateCounter + "\" class=\"btn btn-danger\" onclick=\"deleteAppStateInfo(this);\">Delete</button></td></tr>"; 
	
    //add to the table
    $("#ListAppStateInfoDiagTable").append(createAppStateTable);
	var diag = $("#AddAppStateInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function listAppStateInfo(){
	var diag = $("#ListAppStateInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function viewAppStateInfo(el){
	$("#ViewOperationInfoDiagTable > tbody").html("");
	var updateButtonId3 = $(el).attr('id');
	var tableRowId=updateButtonId3.substring(2);
	var tmpArray=[];
	$.each(appStateInfoArray, function() {
	    if (this.rowID == tableRowId) {
	    	tmpArray=this.arr;
	        }
	});
	
	$.each(tmpArray, function() {
		createOpInfoTable="";
		createOpInfoTable="<tr><td>"+ this.opName + " </td> <td>" + "<button type=\"button\"  id=\"" + this.opName + "\" class=\"btn btn-primary\" onclick=\"viewRequest(this);\">View</button></td>" +"</td></tr>";
		$("#ViewOperationInfoDiagTable").append(createOpInfoTable);
	});
		
	var diag = $("#ViewOperationInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});

}

function deleteAppStateInfo(el){
	var buttonId = $(el).attr('id');
	buttonId=buttonId.substring(1);
    var tmpArray = appStateInfoArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
    appStateInfoArray= tmpArray;
	
	//write the logic for removing
	$("#trs"+ buttonId).remove(); 
}

function addOperationInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	$("#operationName").val(""); 
	requestArray=[];
	$("#ListRequestDiagTable > tbody").html("");
	var diag = $("#AddOperationInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitOperationInfo(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var operationName = $("#operationName").val(); 
	operationCounter = operationCounter +1;
	var opInfoObj={
			rowID:operationCounter,
			opName:operationName,
			innerArr:requestArray
	};
	operationInfoArray.push(opInfoObj);
	createOpInfoTable= "";
	createOpInfoTable= "<tr id=\"tro"+ operationCounter + "\"><td>"+ opInfoObj['opName'] + "</td><td><button type=\"button\"  id=\"ro" + operationCounter + "\" class=\"btn btn-primary\" onclick=\"showRequest(this);\">View</button>" + " </td><td><button type=\"button\"  id=\"o" + operationCounter + "\" class=\"btn btn-danger\" onclick=\"deleteOperationInfo(this);\">Delete</button></td></tr>"; 
	//add to the table
    $("#ListOperationInfoDiagTable").append(createOpInfoTable);
	var diag = $("#AddOperationInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function showRequest(el){
	$("#ShowRequestDiagTable > tbody").html("");
	var updateButtonId4 = $(el).attr('id');
	var tableRowId=updateButtonId4.substring(2);
	var tmpArray=[];
	$.each(operationInfoArray, function() {
	    if (this.rowID == tableRowId) {
	    	tmpArray=this.innerArr;
	        }
	});
	
	$.each(tmpArray, function() {
		createrequestTable="";
		createrequestTable="<tr><td>"+ this.reqName +"</td></tr>";
	$("#ShowRequestDiagTable").append(createrequestTable);
	});
	var diag = $("#ShowRequestDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});

}

function listOperationInfo(){
	var diag = $("#ListOperationInfoDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function deleteOperationInfo(el){
	var buttonId = $(el).attr('id');
	buttonId=buttonId.substring(1);
    var tmpArray = operationInfoArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
    operationInfoArray= tmpArray;
	
	//write the logic for removing
	$("#tro"+ buttonId).remove(); 
}

function addRequest(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	$("#requestName").val("");
	
	var diag = $("#AddRequestDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function submitRequest(){
	if (highlightRequiredFields()) {
		vShowError("Please fill in all required fields");
		return;
	}
	var requestName = $("#requestName").val(); 
	requestCounter = requestCounter +1;
	var requestObj={
			rowID:requestCounter,
			reqName:requestName
	};
	requestArray.push(requestObj);
	createrequestTable= "";
	createrequestTable= "<tr id=\"trr"+ requestCounter + "\"><td>"+ requestObj['reqName'] + " </td><td><button type=\"button\"  id=\"r" + requestCounter + "\" class=\"btn btn-danger\" onclick=\"deleteRequest(this);\">Delete</button></td></tr>"; 
	//add to the table
    $("#ListRequestDiagTable").append(createrequestTable);
	var diag = $("#AddRequestDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("hide");
	});
}

function listRequest(){
	var diag = $("#ListRequestDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});
}

function viewRequest(el){
	var buttonId = $(el).attr('id');
	var newArr=[];
	$("#ViewRequestDiagTable > tbody").html("");
	$.each(appStateInfoArray, function() {
		var tmpArray=this.arr;
		$.each(tmpArray, function() {
	    if (this.opName == buttonId) {
	    	newArr=this.innerArr;
	        }
		});
	});
	$.each(newArr, function() {	
		createRequestTable="";
		createRequestTable="<tr><td>"+ this.reqName + " </td> </tr>";
	$("#ViewRequestDiagTable").append(createRequestTable);
	});
	
	var diag = $("#ViewRequestDiag");
	require(["winery-support-common"], function(w) {
		diag.modal("show");
	});

}

function deleteRequest(el){
	var buttonId = $(el).attr('id');
	buttonId=buttonId.substring(1);
    var tmpArray = requestArray.filter(function (el) {
        return el.rowID != buttonId;
       });
    
    requestArray= tmpArray;
	
	//write the logic for removing
	$("#trr"+ buttonId).remove(); 
}


//old code
function entityContainerClicked(e) {
	var target = $(e.target);
	if (target.is("a")) {
		// do nothing as a nested a element is clicked
	} else {
		var ec = target.parents("div.entityContainer");
		var url = ec.attr('id');
		if (e.ctrlKey) {
			// emulate browser's default behavior to open a new tab
			window.open(url);
		} else {
			window.location = url;
		}
	}
}

$("div.entityContainer").on("click", entityContainerClicked);

/**
 * deletes given component instance
 * uses global variable "element", which stores the DOM element to delete upon successful deletion
 */
function deleteCI(name, URL) {
	deleteResource(name, URL, function() {
		element.remove();
	});
}

function importCSAR() {
	$('#upCSARDiag').modal('show');
}


// If export button is clicked with "CTRL", the plain XML is shown, not the CSAR
// We use "on" with filters instead as new elements could be added when pressing "Add new" (in the future)
// contained code is the same as the code of the CSAR button at the topology modeler (see index.jsp)
$(document).on("click", ".exportButton", function(evt) {
	var url = $(this).attr("href");
	if (evt.ctrlKey) {
		url = url.replace(/csar$/, "definitions");
	}
	window.open(url);
	return false;
});

<%-- Special feature in the case of the service template --%>
<c:if test="${it.type eq 'ServiceTemplate'}">
//If edit button is clicked with "CTRL", the topology modeler is opened, not the service template editor
//We use "on" with filters instead as new elements could be added when pressing "Add new" (in the future)
$(document).on("click", ".editButton", function(evt) {
	var url = $(this).attr("href");
	if (evt.ctrlKey) {
		url = url.replace(/\?edit$/, "topologytemplate/?edit");
		// open in new tab
		var newWin = window.open(url);
		// focussing the new window does not work in Chrome
		newWin.focus();
	} else {
		// normal behavior
		window.location = url;
	}
	evt.preventDefault();
});
</c:if>

$(".exportButton").tooltip({
	placement: 'bottom',
	html: true,
	title: "Export CSAR.<br/>Hold CTRL key to export XML only."
});
$(".editButton").tooltip({
	placement: 'bottom',
	html: true,
	title: <c:if test="${it.type eq 'ServiceTemplate'}">"Edit.<br/>Hold CTRL key to directly open the topology modeler."</c:if><c:if test="${not (it.type eq 'ServiceTemplate')}">"Edit"</c:if>
});
$(".deleteButton").tooltip({
	placement: 'bottom',
	title: "Delete"
});
</script>
</t:genericpage>
