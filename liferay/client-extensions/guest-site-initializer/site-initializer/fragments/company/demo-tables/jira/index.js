const authToken = configuration.authToken;
const hostname = configuration.hostName;

function assigneeFormatter(value, row) {
	if ((value) && (value.displayName)) {
		return value.displayName;
	}

	return "Unassigned";
}

function linkFormatter(value, row) {
	return '<a href="' + 'https://' + hostname + '/browse/' + value + '" target="blank">' + value + '</a>';
}

$(".fragment-jira select").change(function(event) {
	$(".fragment-jira table").bootstrapTable("refresh");
});

$(".fragment-jira table").bootstrapTable({
	ajax: function ajaxRequest(params) {
		console.log(params);
		const projectKey = $(".fragment-jira select").val();
		var url = 'https://' + hostname + '/jira/issues?projectKey=' + projectKey;
		if (params.data.search) {
			url += '%20AND%20text%20~%20' + params.data.search;
		}
		if (params.data.sort) {
			url += '%20ORDER%20BY%20' + params.data.sort;
			if (params.data.order) {
				url += '%20' + params.data.order;
			}
		}
		url += '&startAt=' + params.data.offset;
		if (params.data.limit) {
			url += '&maxResults=' + params.data.limit;
		}
		const oAuth2Client = Liferay.OAuth2Client.FromUserAgentApplication(
    '4ca57228-5461-46cf-6331-e4a7a0f80db1'
  );
		oAuth2Client.fetch(
			url,
			{
			headers: {
			}
			})
		.then((response) => response.json())
		.then((json) => {console.log(json.issues); params.success({"rows": json.issues, "total" : json.total})
});
	},
    columns: [
      { field: 'key', formatter: linkFormatter },
      { field: 'fields.status.name', sortName: 'status' },
      { field: 'fields.summary', sortName: "summary" },
      { field: 'fields.creator.displayName', sortName: "creator" },
      { field: 'fields.assignee', formatter: assigneeFormatter, sortName: "assignee" }
    ],
})