# Liferay PaaS Demo

This is a Liferay Workspace that contains various assets and client-extensions for building demos with Liferay PaaS.

## License

[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

## Client Extensions

This workspace provides the following Client Extension (CX) features:

### CMSChat

The [CMSChat CX](liferay/client-extensions/cmschat) is a Spring Boot REST microservice for use with the [CMSChat](liferay/client-extensions/guest-site-initializer/site-initializer/fragments/company/demo-ai/cmschat) and [AI Summary](liferay/client-extensions/guest-site-initializer/site-initializer/fragments/company/demo-ai/cmschat) fragments. It enables Retrieval Augmented Generation by doing a headless search, extracting the text content from the top 3 results, and calling the [OpenAI Completions API](https://platform.openai.com/docs/api-reference/completions) with user prompts/instructions along with the extracted text. The result that comes back is the model's answer to the user's questions.

### Guest Site Initializer

The [Guest Site Initializer CX] in one sense is aptly named, in that it will initialize parts of the /web/guest (default) site with widget and page templates. But in another sense it is poorly named, because any fragments found under [site-initializer/fragments/company](liferay/client-extensions/guest-site-initializer/site-initializer/fragments/company) will be imported into the Global site, so that they can be used in all sites.

## Instructions for CMSChat and AI Summary

- Clone the repo
- `cd liferay/client-extensions/cmschat`
- `blade gw clean build && lcp deploy --extension dist/*.zip`
- When prompted, select the Liferay PaaS environment for deployment
- Upon successful deployment, it can take anywhere from 5-30 minutes for Liferay PaaS to publish the DNS entry for the microservice, and to provision an SSL certificate
- `cd ../`
- `cd client-extensions/guest-site-initializer`
- `blade gw clean build && lcp deploy --extension dist/*.zip`
- When prompted, select the Liferay PaaS environment for deployment
- Deployment should be immediate, but due to some potential shortcomings of the site initializer feature, it will likely be necessary (and highly recommended) to restart the Liferay DXP instance afterward
- Enable the following Feature Flags:
  - LPS-122920: Semantic Search
  - LPS-179669: Search Headless API
  - LPD-11232: Search Headless GET API
  - LPD-48862: Re-enable Liferay.OAuth2Client.FromUserAgentApplication
- Note that some of the aforementioned feature flags might be "Developer" feature flags. If that's the case, then add `feature.flag.ui.visible[dev]=true` to portal-ext.properties and restart the Liferay service.
- Create a [Semantic Search Blueprint](https://learn.liferay.com/w/dxp/search/liferay-enterprise-search/semantic-search/creating-a-search-blueprint-for-semantic-search) and note the ERC after it is created
- Create a new content page named "CMSChat" and add the "CMSChat" fragment to it
- Configure the "Blueprint ERC" for the fragment, as noted from the step above
- Configure "Host Name" for the fragment, e.g., "cmschat-lctxyz-prd.lfr.cloud"
- Publish the CMSChat page
- Reload the page, and test the chat feature
- Note that if the [liferay-icon-white-boxes.png](liferay/client-extensions/guest-site-initializer/site-initializer/fragments/cmschat/liferay-icon-white-boxes.png) image does not render properly as the "busy cursor" (so to speak), then you may need to import it manually into the "AI Demo" fragment library in the Global site.
- If that still doesn't work, you may need to copy the CMSChat Fragment from the "Demo AI" fragment library to a new fragment library and make it work there. That's often times necessary if you want to have a customer-specific logo as a busy cursor image
- On the Search page of the site, configure the Search Results widget with the "Search Results Preview" widget template, which is automatically imported into the /web/guest site via the guest-site-initializer
- Publish the Search page
- Create a new content page named "AI Summary", and configure it with the following CSS at the page level:

```
@media only screen and (max-width: 600px) {
  .show-on-phone {
    display: block !important;
  }
}

@media only screen and (max-width: 600px) {
  .hide-on-phone {
    display: none !important;
  }
}
```

- Add the "AI Summary" fragment to the page
- Configure the "Blueprint ERC" for the fragment, as noted from the step above
- Configure "Host Name" for the fragment, e.g., "cmschat-lctxyz-prd.lfr.cloud"
- Publish the "AI Summary" page
- In order to test it, visit the Search page, submit a search, and then click on the "AI Summary" link next to any of the search results
