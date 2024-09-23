# Nginx

Here is a nerdctl compose to run APIM with nginx.

You can now access your component like this:

| Component      	| URL                      	 |
|----------------	|--------------------|
| Gateway        	| http://localhost/gateway/ 	 |
| Management API 	| http://localhost/management/ |
| Portal API 	    | http://localhost/portal/ |
| Console UI 	    | http://localhost/console/ |
| Portal UI 	    | http://localhost/  |
|                	| 	                  |

## How to run ?

⚠️ You need a license file to be able to run Enterprise Edition of APIM. Do not forget to add your license file into `./.license`.

`APIM_VERSION={APIM_VERSION} nerdctl compose up -d ` 

To be sure to fetch last version of images, you can do
`export APIM_VERSION={APIM_VERSION} && nerdctl compose down -v && nerdctl compose pull && nerdctl compose up`

