<style>
	#preview-popup {
		position: absolute;
		width: 459px;
		height: 594px;
		background-color: #fff;
		border: 1px solid #000;
		border-radius: 10px;
		display: none;
		padding: 20px;
		box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
		z-index: 9999; /* Add this line */
	}

	#preview-content {
		width: 100%;
		height: 95%;
		overflow: auto;
	}

	#close-preview {
		position: absolute;
		top: 10px;
		right: 10px;
	}
</style>

<div id="preview-popup" style="display: none;">
	<div id="preview-content"></div>
	<button id="close-preview" class="btn btn-monospaced btn-primary btn-xs" type="button" aria-label="Close" title="Close">
		<svg class="lexicon-icon lexicon-icon-times" role="presentation" viewBox="0 0 512 512">
			<path class="lexicon-icon-outline" d="M300.4,256L467,89.4c29.6-29.6-14.8-74.1-44.4-44.4L256,211.6L89.4,45C59.8,15.3,15.3,59.8,45,89.4L211.6,256L45,422.6 c-29.7,29.7,14.7,74.1,44.4,44.4L256,300.4L422.6,467c29.7,29.7,74.1-14.7,44.4-44.4L300.4,256z"></path>
		</svg>
	</button>
	<div id="preview-buttons">
		<button id="plus-icon" class="btn btn-monospaced btn-primary btn-xs" type="button" aria-label="Add to My Collection" style="margin: 6px;" title="Add to My Collection">
			<svg class="lexicon-icon lexicon-icon-print" role="presentation">
				<use xlink:href="/o/dialect-theme/images/clay/icons.svg#plus"></use>
			</svg>
		</button>
		<span style="white-space: nowrap;">Add to My Collection</span>
		<button id="email-icon" class="btn btn-monospaced btn-primary btn-xs" type="button" aria-label="Email" style="margin: 6px;" title="Email">
			<svg class="lexicon-icon lexicon-icon-print" role="presentation">
				<use xlink:href="/o/dialect-theme/images/clay/icons.svg#envelope-closed"></use>
			</svg>
		</button>
		<span style="white-space: nowrap;">Email</span>
	</div>
</div>

<div class="c-mb-4 c-mt-4 search-total-label">
    <#if searchContainer.getTotal() == 1>
        ${languageUtil.format(locale, "x-result-for-x", [searchContainer.getTotal(), "<strong>" + htmlUtil.escape(searchResultsPortletDisplayContext.getKeywords()) + "</strong>"], false)}
    <#else>
        ${languageUtil.format(locale, "x-results-for-x", [searchContainer.getTotal(), "<strong>" + htmlUtil.escape(searchResultsPortletDisplayContext.getKeywords()) + "</strong>"], false)}
    </#if>
</div>

<div class="display-list">
	<ul class="list-group" id="search-results-display-list">
        <#if entries?has_content>
            <#list entries as entry>
				<li class="list-group-item list-group-item-flex">
					<div class="autofit-col">
                        <#if entry.isThumbnailVisible()>
							<span class="sticker">
								<span class="sticker-overlay">
									<img
										alt="${languageUtil.get(locale, "thumbnail")}"
										class="sticker-img"
										src="${entry.getThumbnailURLString()}"
									/>
								</span>
							</span>
                        <#elseif entry.isUserPortraitVisible() && stringUtil.equals(entry.getClassName(), userClassName)>
                            <@liferay_ui["user-portrait"] userId=entry.getAssetEntryUserId() />
                        <#elseif entry.isIconVisible()>
							<span class="sticker sticker-rounded sticker-secondary sticker-static">
								<@clay.icon symbol="${entry.getIconId()}" />
							</span>
                        </#if>
					</div>

					<div class="autofit-col autofit-col-expand">
						<section class="autofit-section">
							<div class="c-mt-0 list-group-title">
								<a href="${entry.getViewURL()}">
                                    ${entry.getHighlightedTitle()}
								</a>
								<span>&nbsp;</span>
                                <#if entry.isAssetRendererURLDownloadVisible() && entry.getViewURL()?contains("find_file_entry")>
                                    <#assign downloadUrl = entry.getAssetRendererURLDownload()?replace("&download=true", "")>
									<a href="#" class="preview-link" data-preview="${downloadUrl}#page=1">[Preview]</a>
                                <#else>
									<a href="#" class="preview-link" data-fullview="${entry.getViewURL()}">[Preview]</a>
                                </#if>
<#assign classNameMap = {
  "com.liferay.blogs.model.BlogsEntry": "blog",
  "com.liferay.document.library.kernel.model.DLFileEntry": "document",
  "com.liferay.journal.model.JournalArticle": "article"
} />

<#assign assetType = classNameMap[entry.getClassName()]!"unknown" />
									<a href="#" class="preview-link" data-fullview="https://webserver-lctclarity-prd.lfr.cloud/web/clarity/ai-summary?assetType=${assetType}&assetTitle=${entry.getTitle()}&p_p_state=pop_up">[AI Summary]</a>
							</div>

							<div class="search-results-metadata">
								<p class="list-group-subtext">
                                    <#if entry.isModelResourceVisible()>
										<span class="subtext-item">
											<strong>${entry.getModelResource()}</strong>
										</span>
                                    </#if>

                                    <#if entry.isLocaleReminderVisible()>
										<span class="lfr-portal-tooltip" title="${entry.getLocaleReminder()}">
											<@clay["icon"] symbol="${entry.getLocaleLanguageId()?lower_case?replace('_', '-')}" />
										</span>
                                    </#if>

                                    <#if entry.isCreatorVisible()>
										<span class="subtext-item">
											&#183;

											<@liferay.language key="written-by" />

											<strong>${htmlUtil.escape(entry.getCreatorUserName())}</strong>
										</span>
                                    </#if>

                                    <#if entry.isCreationDateVisible()>
										<span class="subtext-item">
											<@liferay.language key="on-date" />

                                            ${entry.getCreationDateString()}
										</span>
                                    </#if>
								</p>

                                <#if entry.isContentVisible()>
									<p class="list-group-subtext">
										<span class="subtext-item">
											${entry.getContent()}
										</span>
									</p>
                                </#if>

                                <#if entry.isFieldsVisible()>
									<p class="list-group-subtext">
                                        <#assign separate = false />

                                        <#list entry.getFieldDisplayContexts() as fieldDisplayContext>
                                            <#if separate>
												&#183;
                                            </#if>

											<span class="badge">${fieldDisplayContext.getName()}</span>

											<span>${fieldDisplayContext.getValuesToString()}</span>

                                            <#assign separate = true />
                                        </#list>
									</p>
                                </#if>

                                <#if entry.isAssetCategoriesOrTagsVisible()>
									<div class="c-mt-2 h6 search-document-tags text-default">
                                        <@liferay_asset["asset-tags-summary"]
                                        className=entry.getClassName()
                                        classPK=entry.getClassPK()
                                        paramName=entry.getFieldAssetTagNames()
                                        portletURL=entry.getPortletURL()
                                        />

                                        <@liferay_asset["asset-categories-summary"]
                                        className=entry.getClassName()
                                        classPK=entry.getClassPK()
                                        paramName=entry.getFieldAssetCategoryIds()
                                        portletURL=entry.getPortletURL()
                                        />
									</div>
                                </#if>

                                <#if entry.isDocumentFormVisible()>
									<div class="expand-details text-default">
										<span class="list-group-text text-2">
											<a class="shadow-none" href="javascript:void(0);">
												<@liferay.language key="details" />...
											</a>
										</span>
									</div>

									<div class="hide search-results-list table-details table-responsive">
										<table class="table table-head-bordered table-hover table-sm table-striped">
											<thead>
											<tr>
												<th class="table-cell-expand-smaller table-cell-text-end">
                                                    <@liferay.language key="key" />
												</th>
												<th class="table-cell-expand">
                                                    <@liferay.language key="value" />
												</th>
											</tr>
											</thead>

											<tbody>
                                            <#list entry.getDocumentFormFieldDisplayContexts() as fieldDisplayContext>
												<tr>
													<td class="table-cell-expand-smaller table-cell-text-end table-details-content">
														<strong>${htmlUtil.escape(fieldDisplayContext.getName())}</strong>
													</td>
													<td class="table-cell-expand table-details-content">
														<code>
                                                            ${fieldDisplayContext.getValuesToString()}
														</code>
													</td>
												</tr>
                                            </#list>
											</tbody>
										</table>
									</div>
                                </#if>
							</div>
						</section>
					</div>

                    <#if entry.isAssetRendererURLDownloadVisible()>
						<div class="autofit-col">
							<span
								class="c-mt-2 lfr-portal-tooltip"
								title="Download"
							>
								<@clay.link
                                aria\-label="${languageUtil.format(locale, 'download-x', [entry.getTitle()])}"
                                cssClass="link-monospaced link-outline link-outline-borderless link-outline-secondary"
                                displayType="secondary"
                                href="${entry.getAssetRendererURLDownload()}"
                                >
                                    <@clay.icon symbol="download" />
                                </@clay.link>
							</span>
						</div>
                    </#if>
				</li>
            </#list>
        </#if>
	</ul>
</div>

<@liferay_aui.script use="aui-base">
	A.one('#search-results-display-list').delegate(
	'click',
	function(event) {
	var currentTarget = event.currentTarget;

	currentTarget.siblings('.search-results-list').toggleClass('hide');
	},
	'.expand-details'
	);
</@liferay_aui.script>

<script>

	document.getElementById('close-preview').addEventListener('click', function() {
		document.getElementById('preview-popup').style.display = 'none';
	});

	document.querySelectorAll('.preview-link').forEach(link => {
		link.addEventListener('click', function(e) {
			e.preventDefault();
			var previewPopup = document.getElementById('preview-popup');
			var previewContent = document.getElementById('preview-content');
			console.log('this.dataset');
			console.log(this.dataset);
			if (this.dataset.preview) {
				// previewContent.innerHTML = '<embed src="' + this.dataset.preview + '" width="100%" height="100%" type="image/png">';
				previewContent.innerHTML = '<embed src="' + this.dataset.preview + '" width="100%" height="100%" type="application/pdf">';
				document.getElementById('preview-buttons').style.display = 'block';
			} else {
				previewContent.innerHTML = '<iframe id="previewIframe" src="' + this.dataset.fullview + '" width="100%" height="100%" style="border: none;">';
				document.getElementById('preview-buttons').style.display = 'none';
			}
			// Get the parent <div> of the clicked link
			var parentDiv = this.closest('div.autofit-col');

			// Append the previewPopup to the parent <div>
			parentDiv.appendChild(previewPopup);

			// Display the previewPopup
			previewPopup.style.position = 'absolute';
			previewPopup.style.right = '0';
			previewPopup.style.top = '0';
			previewPopup.style.display = 'block';
		});
	});
</script>
