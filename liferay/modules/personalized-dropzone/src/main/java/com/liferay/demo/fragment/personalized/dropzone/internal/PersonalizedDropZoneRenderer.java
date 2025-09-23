/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */

package com.liferay.demo.fragment.personalized.dropzone.internal;

import com.liferay.fragment.model.FragmentEntryLink;
import com.liferay.fragment.renderer.FragmentRenderer;
import com.liferay.fragment.renderer.FragmentRendererContext;
import com.liferay.fragment.renderer.FragmentRendererRegistry;
import com.liferay.fragment.renderer.constants.FragmentRendererConstants;
import com.liferay.petra.string.StringPool;
import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.json.JSONFactory;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.language.Language;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.model.User;
import com.liferay.portal.kernel.theme.ThemeDisplay;
import com.liferay.portal.kernel.util.GetterUtil;
import com.liferay.portal.kernel.util.ResourceBundleUtil;
import com.liferay.portal.kernel.util.SetUtil;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.kernel.util.WebKeys;
import com.liferay.segments.SegmentsEntryRetriever;
import com.liferay.segments.constants.SegmentsEntryConstants;
import com.liferay.segments.context.RequestContextMapper;
import com.liferay.segments.model.SegmentsEntry;
import com.liferay.segments.service.SegmentsEntryLocalService;

import java.io.IOException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.Set;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

/**
 * @author Neil Griffin
 */
@Component(service = FragmentRenderer.class)
public class PersonalizedDropZoneRenderer implements FragmentRenderer {

	@Override
	public String getCollectionKey() {
		return "layout-elements";
	}

	@Override
	public String getConfiguration(
		FragmentRendererContext fragmentRendererContext) {

		FragmentEntryLink fragmentEntryLink =
			fragmentRendererContext.getFragmentEntryLink();

		if ((fragmentEntryLink == null) ||
			(fragmentEntryLink.getGroupId() == 0L)) {

			return StringPool.BLANK;
		}

		/*
		List<SegmentsEntry> segmentsEntries =
			_segmentsEntryLocalService.getSegmentsEntries(
				fragmentEntryLink.getGroupId(), true,
				SegmentsEntryConstants.SOURCE_DEFAULT, User.class.getName(),
				QueryUtil.ALL_POS, QueryUtil.ALL_POS,
				new SegmentNameOrderByComparator(
					fragmentRendererContext.getLocale()));
		 */
		List<SegmentsEntry> segmentsEntries =
			_segmentsEntryLocalService.getSegmentsEntries(
				fragmentEntryLink.getGroupId(),
				QueryUtil.ALL_POS, QueryUtil.ALL_POS,
				new SegmentNameOrderByComparator(
					fragmentRendererContext.getLocale()));

		List<Map<String, Object>> fields = new ArrayList<>();

		for (SegmentsEntry segmentsEntry : segmentsEntries) {
			Map<String, Object> map = new HashMap<>();

			map.put("defaultValue", false);

			map.put(
				"label",
				segmentsEntry.getName(fragmentRendererContext.getLocale()));

			map.put("name", segmentsEntry.getSegmentsEntryId());

			map.put("type", "checkbox");

			Map<String, String> typeOptionsMap = new HashMap<>();

			typeOptionsMap.put("displayType", "toggle");

			map.put("typeOptions", typeOptionsMap);

			fields.add(map);
		}

		Map<String, Object> map = new HashMap<>();

		map.put("fields", fields);
		map.put("label", "segments");

		List<Map<String, Object>> fieldSets = new ArrayList<>();

		fieldSets.add(map);

		JSONObject jsonObject = _jsonFactory.createJSONObject();

		jsonObject.put("fieldSets", fieldSets);

		return jsonObject.toString();
	}

	@Override
	public String getIcon() {
		return "filter";
	}

	@Override
	public String getLabel(Locale locale) {
		ResourceBundle moduleResourceBundle = ResourceBundleUtil.getBundle(
			"content.Language", locale, getClass());

		return _language.get(moduleResourceBundle, "personalized-dropzone");
	}

	public boolean hasViewPermission(
		FragmentRendererContext fragmentRendererContext,
		HttpServletRequest httpServletRequest) {

		if (fragmentRendererContext.isEditMode()) {
			return true;
		}

		// without this check, the page editor will show "permission denied" instead of 
		// the segments selection when the editing user is not themselves in a segment 
		// that this fragment would be rendered for in VIEW mode.
		// (there might be a more elegant way to figure out this condition... this method
		// is called twice within the page editor - but only once apparently in EDIT mode)
		Object portletId = httpServletRequest.getAttribute("PORTLET_ID");
		if(Validator.isNotNull(portletId)) {
			if(portletId.equals("com_liferay_layout_content_page_editor_web_internal_portlet_ContentPageEditorPortlet")) {
				return true;
			}
		}

		FragmentEntryLink fragmentEntryLink =
			fragmentRendererContext.getFragmentEntryLink();

		String editableValues = fragmentEntryLink.getEditableValues();

		if (Validator.isNotNull(editableValues)) {
			ThemeDisplay themeDisplay =
				(ThemeDisplay)httpServletRequest.getAttribute(
					WebKeys.THEME_DISPLAY);

			try {
				JSONObject jsonObject = _jsonFactory.createJSONObject(
					editableValues);

				JSONObject segmentsJSONObject = jsonObject.getJSONObject(
					_SEGMENTS_KEY);

				if (segmentsJSONObject == null) {
					return true;
				}

				Set<Long> segmentsEntryIdMap = SetUtil.fromArray(
					_segmentsEntryRetriever.getSegmentsEntryIds(
						themeDisplay.getScopeGroupId(),
						themeDisplay.getUserId(),
						_requestContextMapper.map(httpServletRequest), null));

				Set<String> segmentKeys = segmentsJSONObject.keySet();
				int totalSegmentsEnabled = 0;

				for (String segmentKey : segmentKeys) {
					boolean currentSegmentEnabled =
						segmentsJSONObject.getBoolean(segmentKey);

					if (currentSegmentEnabled) {
						totalSegmentsEnabled++;

						Long segmentEntryId = GetterUtil.getLong(segmentKey);

						if (segmentsEntryIdMap.contains(segmentEntryId)) {
							_log.debug(
								"segmentEntryId=" + segmentEntryId +
									" is enabled");

							return true;
						}
					}
				}

				if (totalSegmentsEnabled == 0) {
					_log.debug("No segments are enabled");

					return false;
				}
			}
			catch (PortalException portalException) {
				_log.error(portalException.getMessage(), portalException);

				return false;
			}
		}

		if (_log.isDebugEnabled()) {
			_log.debug("Editable values: " + editableValues);
		}

		return false;
	}

	@Override
	public void render(
			FragmentRendererContext fragmentRendererContext,
			HttpServletRequest httpServletRequest,
			HttpServletResponse httpServletResponse)
		throws IOException {

		if (hasViewPermission(fragmentRendererContext, httpServletRequest)) {
			FragmentRenderer fragmentEntryFragmentRenderer =
				_fragmentRendererRegistry.getFragmentRenderer(
					FragmentRendererConstants.
						FRAGMENT_ENTRY_FRAGMENT_RENDERER_KEY);

			fragmentEntryFragmentRenderer.render(
				fragmentRendererContext, httpServletRequest,
				httpServletResponse);
		}
	}

	private static final String _SEGMENTS_KEY =
		"com.liferay.fragment.entry.processor.freemarker." +
			"FreeMarkerFragmentEntryProcessor";

	private static final Log _log = LogFactoryUtil.getLog(
		PersonalizedDropZoneRenderer.class);

	@Reference
	private FragmentRendererRegistry _fragmentRendererRegistry;

	@Reference
	private JSONFactory _jsonFactory;

	@Reference
	private Language _language;

	@Reference
	private RequestContextMapper _requestContextMapper;

	@Reference
	private SegmentsEntryLocalService _segmentsEntryLocalService;

	@Reference
	private volatile SegmentsEntryRetriever _segmentsEntryRetriever;

	@Reference(
		target = "(osgi.web.symbolicname=com.liferay.demo.fragment.personalized.dropzone)",
		unbind = "-"
	)
	private ServletContext _servletContext;

}
