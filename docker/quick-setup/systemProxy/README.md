# System proxy

Here is a nerdctl compose to run APIM with MongoDB as database and using [mitmproxy](https://mitmproxy.org/).

---
> For more information, please read :
> https://documentation.gravitee.io/apim/getting-started/configuration/repositories/mongodb
---

## How to run ?

⚠️ You need a license file to be able to run Enterprise Edition of APIM. Do not forget to add your license file into `./.license`.

`APIM_VERSION={APIM_VERSION} nerdctl compose up -d ` 

To be sure to fetch last version of images, you can do
`export APIM_VERSION={APIM_VERSION} && nerdctl compose down -v && nerdctl compose pull && nerdctl compose up`

## Web interface for proxy
You can connect [here](http://0.0.0.0:8081/) to monitor the proxy
![mitmproxy.png](mitmproxy.png)
