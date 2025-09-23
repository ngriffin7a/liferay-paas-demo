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

function dateFormatter(value, row) {
	if (value) {
		const date = new Date(value);
		const month = ('0' + (date.getMonth() + 1)).slice(-2); // Add leading zero and get month
		const day = ('0' + date.getDate()).slice(-2); // Add leading zero and get day
		const year = date.getFullYear();
		return `${month}/${day}/${year}`;
	}
	return "";
}

$(".fragment-tickets table").bootstrapTable({
	ajax: function ajaxRequest(params) {
		console.log(params);
		var url = '/o/c/tickets/scopes/71052?a=1';
		if (params.data.search) {
			url += '&search=' + params.data.search;
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
		Liferay.Util.fetch(
			url,
			{
				headers: {
					// Add your headers here if needed
				},
			})
			.then((response) => response.json())
			.then((json) => {
				console.log(json.items);
				params.success({ "rows": json.items, "total": json.totalCount });
			});
	},
	columns: [
		{ field: 'creator.name', sortName: 'createdBy' },
		{ field: 'dateCreated', sortName: 'dateCreated', formatter: dateFormatter },
		{ field: 'dateModified', sortName: 'dateModified', formatter: dateFormatter },
		{ field: 'dueDate', sortName: 'dueDate', formatter: dateFormatter },
		{ field: 'priority.name', sortName: 'priority' },
		{ field: 'title', sortName: 'title' }
	],
});
