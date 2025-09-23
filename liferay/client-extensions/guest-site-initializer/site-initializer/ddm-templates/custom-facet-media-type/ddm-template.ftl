<@liferay_ui["panel-container"]
extended=true
id="${namespace + 'facetCustomPanelContainer'}"
markupView="lexicon"
persistState=true
>
    <@liferay_ui.panel
    collapsible=true
    cssClass="search-facet"
    id="${namespace + 'facetCustomPanel'}"
    markupView="lexicon"
    persistState=true
    title="${customFacetDisplayContext.getDisplayCaption()}"
    >
        <#if !customFacetDisplayContext.isNothingSelected()>
            <@clay.button
            cssClass="btn-unstyled c-mb-4 facet-clear-btn"
            displayType="link"
            id="${namespace + 'facetCustomClear'}"
            onClick="Liferay.Search.FacetUtil.clearSelections(event);"
            >
				<strong>${languageUtil.get(locale, "clear")}</strong>
            </@clay.button>
        </#if>

		<ul class="custom list-unstyled">
            <#if entries?has_content>
                <#list entries as entry>
					<li class="facet-value">
						<div class="custom-checkbox custom-control">
							<label class="facet-checkbox-label" for="${namespace}${entry.getBucketText()}">
								<input
									autocomplete="off"
                                        ${(entry.isSelected())?then("checked", "")}
									class="custom-control-input facet-term"
									data-term-id="${htmlUtil.escape(entry.getBucketText())}"
									disabled
									id="${namespace}${entry.getBucketText()}"
									name="${namespace}${entry.getBucketText()}"
									onChange='Liferay.Search.FacetUtil.changeSelection(event);'
									type="checkbox"
								/>

								<span class="custom-control-label term-name ${(entry.isSelected())?then('facet-term-selected', 'facet-term-unselected')}">
									<span class="custom-control-label-text">
                						<#if entry.isSelected()>
            									<strong>
                						</#if>
                                                    <#if entry.getBucketText() == "application_pdf">
														PDF
                                                    <#elseif entry.getBucketText() == "application_vnd+liferay.video.external.shortcut+html">
														Streaming
                                                    <#elseif entry.getBucketText() == "application_octet-stream">
														Streaming
                                                    <#elseif entry.getBucketText() == "image_png">
														PNG Image
                                                    <#elseif entry.getBucketText() == "image_jpg">
														JPEG Image
                                                    <#elseif entry.getBucketText() == "image_jpeg">
														JPEG Image
                                                    <#elseif entry.getBucketText() == "image_webp">
														WebP Image
                                                    <#elseif entry.getBucketText() == "video_mp4">
														MP4 Video
                                                    <#else>
                                                        <@liferay_ui["message"] key="${htmlUtil.escape(entry.getBucketText())}" />
                                                    </#if>
                                                    <#if entry.isSelected()>
            								</strong>
        								</#if>
									</span>
								</span>

                                <#if entry.isFrequencyVisible()>
									<small class="term-count">
										(${entry.getFrequency()})
									</small>
                                </#if>
							</label>
						</div>
					</li>
                </#list>
            </#if>
		</ul>
    </@>
</@>