import os

import pycurl
from fnmatch import fnmatch
from urllib.parse import urlparse


def configure_proxy(curl):
    proxies = _get_proxies_for_url(curl.getinfo(pycurl.EFFECTIVE_URL))
    if proxies:
        host, _, port = proxies["https"].rpartition(":")
        print(f"Adding proxy configuration: {host}:{port}")
        curl.setopt(pycurl.PROXY, host)
        if port:
            curl.setopt(pycurl.PROXYPORT, int(port))


def _get_proxies_for_url(url):
    http_proxy = os.environ.get("HTTP_PROXY", os.environ.get("http_proxy"))
    https_proxy = os.environ.get("HTTPS_PROXY", os.environ.get("https_proxy"))
    no_proxy = os.environ.get("NO_PROXY", os.environ.get("no_proxy"))
    p = urlparse(url)
    netloc = p.netloc
    _userpass, _, hostport = p.netloc.rpartition("@")
    url_hostname, _, _port = hostport.partition(":")
    proxies = {}
    if http_proxy:
        proxies["http"] = http_proxy
    if https_proxy:
        proxies["https"] = https_proxy
    if no_proxy:
        for hostname in no_proxy.split(","):
            # Support "*.example.com" and "10.*"
            if fnmatch(url_hostname, hostname.strip()):
                proxies = {}
                break
            # Support ".example.com"
            elif hostname.strip().replace("*", "").endswith(url_hostname):
                proxies = {}
                break
    return proxies
