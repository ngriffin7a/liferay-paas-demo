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
import com.liferay.fragment.service.FragmentEntryLinkServiceWrapper;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.service.ServiceContext;
import com.liferay.portal.kernel.service.ServiceWrapper;

import java.util.Objects;

import org.osgi.service.component.annotations.Component;

/**
 * @author Neil Griffin
 */
@Component(immediate = true, property = {}, service = ServiceWrapper.class)
public class FragmentEntryLinkServiceOverride
	extends FragmentEntryLinkServiceWrapper {

	public FragmentEntryLinkServiceOverride() {
		super(null);
	}

	@Override
	public FragmentEntryLink addFragmentEntryLink(
			String externalReferenceCode, long groupId, long originalFragmentEntryLinkId,
			long fragmentEntryId, long segmentsExperienceId, long plid,
			String css, String html, String js, String configuration,
			String editableValues, String namespace, int position,
			String rendererKey, int type, ServiceContext serviceContext)
		throws PortalException {

		if (Objects.equals(
				PersonalizedDropZoneRenderer.class.getName(), rendererKey)) {

			html =
				"<div class=\"personalized-drop-zone\">" +
					"<lfr-drop-zone></lfr-drop-zone></div>";
		}

		return super.addFragmentEntryLink(
			externalReferenceCode, groupId, originalFragmentEntryLinkId, fragmentEntryId,
			segmentsExperienceId, plid, css, html, js, configuration,
			editableValues, namespace, position, rendererKey, type,
			serviceContext);
	}

}