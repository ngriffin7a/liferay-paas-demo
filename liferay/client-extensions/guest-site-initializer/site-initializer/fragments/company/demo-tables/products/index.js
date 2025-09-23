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

function skuFormatter(values, row) {
	if (values) {
		return values && values[0] && values[0].sku
                ? values[0].sku
                : 'N/A';
	}
	return "";
}

function arrayFormatter(arrayIndex, values, row) {
	if (values) {
		return values && values[arrayIndex] && values[arrayIndex].value
                ? values[arrayIndex].value 
                : 'N/A';
	}
	return "";
}

function dosageSizeFormatter(values, row) {
	return arrayFormatter(0, values, row);
}

function manufacturerFormatter(values, row) {
	return arrayFormatter(1, values, row);
}

function priceFormatter(values, row) {
	if (values) {
		return values && values[0] && values[0].price && values[0].price.priceFormatted 
                ? values[0].price.priceFormatted
                : 'N/A';
	}
	return "";
}

$(".fragment-products table").bootstrapTable({
	ajax: function ajaxRequest(params) {
		console.log(params);
		var url = '/o/headless-commerce-delivery-catalog/v1.0/channels/40916/products?nestedFields=productSpecifications,skus';
		if (params.data.search) {
			url += '&search=' + params.data.search;
		}
		if (params.data.sort) {
			url += '&sort=' + params.data.sort;
			if (params.data.order) {
				url += ':' + params.data.order;
			}
		}
		const page = Math.floor(params.data.offset / params.data.limit) + 1;
		url += '&page=' + page;
		if (params.data.limit) {
			url += '&pageSize=' + params.data.limit;
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
		{ field: 'skus', sortName: 'sku', formatter: skuFormatter },
		{ field: 'shortDescription', sortName: 'shortDescription' },
		{ field: 'productSpecifications', formatter: dosageSizeFormatter },
		{ field: 'productSpecifications', formatter: manufacturerFormatter },
		{ field: 'skus', formatter: priceFormatter }
	],
});
