/**
 * Copyright (c) 2000-2025 Liferay, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.liferay.demo.cmschat.service;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.tika.Tika;
import org.apache.tika.exception.TikaException;
import org.apache.tika.exception.WriteLimitReachedException;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.parser.AutoDetectParser;
import org.apache.tika.parser.ParseContext;
import org.apache.tika.sax.BodyContentHandler;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;

import org.springframework.security.oauth2.jwt.Jwt;

import org.springframework.stereotype.Component;

import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import com.liferay.demo.cmschat.dto.SearchResult;
import com.liferay.demo.cmschat.http.HttpResponseFactory;
import com.liferay.demo.cmschat.http.LiferayHttpRequestFactory;

import org.springframework.web.util.UriComponentsBuilder;
import org.xml.sax.SAXException;

/**
 * @author  Neil Griffin
 */
@Component
public class SearchServiceImpl implements SearchService {

	@Autowired
	private HttpResponseFactory _httpResponseFactory;

	@Autowired
	private LiferayHttpRequestFactory _liferayHttpRequestFactory;

	private static String _downloadText(Jwt jwt, String url, int maxChars) throws IOException {
		RestTemplate restTemplate = new RestTemplate();
		HttpHeaders headers = new HttpHeaders();
		headers.setBearerAuth(jwt.getTokenValue());

		HttpEntity<String> entity = new HttpEntity<>(headers);
		ResponseEntity<byte[]> response = restTemplate.exchange(url, HttpMethod.GET, entity, byte[].class);

		byte[] fileData = response.getBody();
		if (fileData == null) {
			throw new IOException("Failed to download file content from " + url);
		}

		try (InputStream stream = new ByteArrayInputStream(fileData)) {
			AutoDetectParser parser = new AutoDetectParser();
			BodyContentHandler handler = new BodyContentHandler(maxChars);
			Metadata metadata = new Metadata();
			ParseContext context = new ParseContext();

			try {
				parser.parse(stream, handler, metadata, context);
			} catch (WriteLimitReachedException e) {
				// Log or acknowledge the truncation
				System.err.println("Text extraction was truncated at " + maxChars + " characters.");
			}

			return handler.toString(); // Partial text is still available
		} catch (IOException | SAXException | TikaException e) {
			throw new RuntimeException("Failed to parse file content", e);
		}
	}

	@Override
	public List<SearchResult> getSearchResults(Jwt jwt, String keywords, String blueprintExternalReferenceCode, String scope) throws IOException {
		Map<String, String> urlParameters = new HashMap<>();

		String search = URLEncoder.encode(keywords, "UTF-8");
		System.err.println("-----------------------");
		System.err.println("keywords=" + keywords);
		System.err.println("urlParameters=");
		System.err.println(urlParameters);

		String url = UriComponentsBuilder
			.fromUriString("/search/v1.0/search")
			.queryParam("search", search)
			.queryParam("scope", scope)
			.queryParam("nestedFields", "embedded")
			.queryParam("blueprintExternalReferenceCode", blueprintExternalReferenceCode)
			.toUriString();

		System.err.println("url=" + url);
		System.err.println("-----------------------");

		return _getSearchResults(jwt,
				_httpResponseFactory.getHttpResponseBody(
					_liferayHttpRequestFactory.newLiferayGetRequest(url, jwt.getTokenValue())
						));
	}

	private Document _downloadDocument(Jwt jwt, String itemURL, String relativeContentURL, int maxChars) throws IOException {

		String contentURL = _relative2AbsoluteURL(itemURL, relativeContentURL);

		if (contentURL == null) {
			return new Document();
		}

		return new Document(_downloadText(jwt, contentURL, maxChars), contentURL);
	}

	private List<SearchResult> _getSearchResults(Jwt jwt, String json) throws IOException {
		List<SearchResult> searchResults = new ArrayList<>();
		ObjectMapper objectMapper = new ObjectMapper();

		try {
			JsonNode rootNode = objectMapper.readTree(json);
			JsonNode itemsJsonNode = rootNode.path("items");

			System.err.println("itemsJsonNode=" + itemsJsonNode);
			if (!itemsJsonNode.isArray()) {
				System.err.println("No search results found.");
				return searchResults;
			}
			System.err.println("itemsJsonNode.size()=" + itemsJsonNode.size());

			// 128_000 is the approximate upper bound of ChatGPT tokens for a single request
			// 80_000 is a safe margin for model + leaving room for the system prompt
			int remainingChars = 80_000;

			for (JsonNode itemJsonNode : itemsJsonNode) {

				if ((searchResults.size() == 3) || (remainingChars <= 1024)) {

					// Stop after 3 search results for now until relevance/score can be figured out better.
					break;
				}

				String title = itemJsonNode.path("title").asText();
				String description = itemJsonNode.path("description").asText();
				String contentURL = null;
				String itemURL = itemJsonNode.path("itemURL").asText();
				JsonNode embeddedJsonNode = itemJsonNode.path("embedded");
				SearchResult.Type type = _getType(embeddedJsonNode);

				String contentText = null;
				String relativeContentURL = null;
				boolean addSearchResult = false;

				switch (type) {

				case ARTICLE: {
					addSearchResult = true;

					JsonNode contentFields = embeddedJsonNode.path("contentFields");

					if (contentFields.isArray()) {
						StringBuilder sb = new StringBuilder();

						for (int i = 0; i < contentFields.size(); i++) {
							JsonNode contentField = contentFields.get(i);

							if ("string".equals(contentField.path("dataType"))) {
								JsonNode contentFieldValue = contentField.path("contentFieldValue");
								sb.append(contentFieldValue.path("data").asText());
								sb.append("\n");
							}
						}

						String text = sb.toString();
						contentText = text.length() > remainingChars ? text.substring(0, remainingChars) : text;

						System.err.println("embeddedJsonNode.path('siteId').asInt()=" + embeddedJsonNode.path("siteId").asInt());

						relativeContentURL = "/web/guest/w/" + embeddedJsonNode.path("friendlyUrlPath").asText();
						contentURL = _relative2AbsoluteURL(itemURL, relativeContentURL);
					}

					break;
				}

				case BLOG: {
					addSearchResult = true;
					String rawHtml = embeddedJsonNode.path("articleBody").asText();
					String text = _html2Text(rawHtml);
					contentText = text.length() > remainingChars ? text.substring(0, remainingChars) : text;
					relativeContentURL = "/web/guest/b/" + embeddedJsonNode.path("friendlyUrlPath").asText();
					contentURL = _relative2AbsoluteURL(itemURL, relativeContentURL);

					break;
				}

				case DOCUMENT: {
					addSearchResult = true;

					String encodingFormat = embeddedJsonNode.path("encodingFormat").asText();

					if ("application/vnd+liferay.video.external.shortcut+html".equals(encodingFormat)) {
						contentText = description;
						relativeContentURL = "/web/guest/d/" + embeddedJsonNode.path("friendlyUrlPath").asText();
						contentURL = _relative2AbsoluteURL(itemURL, relativeContentURL);
					}
					else {
						relativeContentURL = embeddedJsonNode.path("contentUrl").asText();

						Document document = _downloadDocument(jwt, itemURL, relativeContentURL, remainingChars);
						contentText = document.getContentText();
						contentURL = document.getURL();
					}

					break;
				}
				}

				if (addSearchResult) {

					System.err.println("Search Result: type=\"" + type.name() + "\" title=\"" + title + "\" description=\"" + description + "\"");

					searchResults.add(new SearchResult(title, description, itemURL, contentText, contentURL, type));

					remainingChars -= contentText.length();
				}
			}

		}
		catch (JsonProcessingException jsonProcessingException) {
			throw new IOException(jsonProcessingException);
		}

		return searchResults;
	}

	private SearchResult.Type _getType(JsonNode embeddedJsonNode) {

		if (embeddedJsonNode.has("pageType")) {
			return SearchResult.Type.PAGE;
		}

		if (embeddedJsonNode.has("numberOfDocuments")) {
			return SearchResult.Type.FOLDER;
		}

		if (embeddedJsonNode.has("jobTitle")) {
			return SearchResult.Type.USER;
		}

		if (embeddedJsonNode.has("documentType")) {
			return SearchResult.Type.DOCUMENT;
		}

		if (embeddedJsonNode.has("headline")) {
			return SearchResult.Type.BLOG;
		}

		if (embeddedJsonNode.has("contentStructureId")) {
			return SearchResult.Type.ARTICLE;
		}

		return SearchResult.Type.OTHER;
	}

	private String _html2Text(String html) throws IOException {
		Tika tika = new Tika();

		try {
			org.apache.tika.metadata.Metadata metadata = new org.apache.tika.metadata.Metadata();
			metadata.set(org.apache.tika.metadata.HttpHeaders.CONTENT_TYPE, "text/html");

			return tika.parseToString(new ByteArrayInputStream(html.getBytes()), metadata);
		}
		catch (TikaException e) {
			throw new IOException(e);
		}
	}

	private String _relative2AbsoluteURL(String referenceURL, String relativeContentURL) {

		if ((referenceURL != null) && !referenceURL.isBlank() && (relativeContentURL != null) &&
				!relativeContentURL.isBlank()) {
			URI referenceURI = null;

			try {
				referenceURI = new URI(referenceURL);
			}
			catch (URISyntaxException e) {
				return null;
			}

			URI contentURI = referenceURI.resolve(relativeContentURL);

			return contentURI.toString();
		}

		return null;
	}

	private class Document {
		private String _contentText;
		private String _url;

		public Document() {
		}

		public Document(String contentText, String url) {
			_contentText = contentText;
			_url = url;
		}

		public String getContentText() {
			return _contentText;
		}

		public String getURL() {
			return _url;
		}
	}
}