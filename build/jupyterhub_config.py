import os
import sys

from tornado.httpclient import HTTPRequest

from proxy_configuration import configure_proxy

notebook_dir = os.environ.get("DOCKER_NOTEBOOK_DIR")
network_name = "jupyterhub-network"

c.Spawner.debug = False
c.Spawner.default_url = "/lab"
c.Spawner.environment = {
    "SPARKMAGIC_CONF_DIR": os.environ.get("SPARKMAGIC_CONF_DIR", "~/.sparkmagic"),
    "JUPYTER_ENABLE_LAB": "yes",
    "HTTP_PROXY": os.environ.get("HTTP_PROXY"),
    "HTTPS_PROXY": os.environ.get("HTTPS_PROXY"),
    "NO_PROXY": os.environ.get("NO_PROXY"),
    "http_proxy": os.environ.get("http_proxy"),
    "https_proxy": os.environ.get("https_proxy"),
    "no_proxy": os.environ.get("no_proxy"),
}
c.Spawner.env_keep = [
    "AWS_DEFAULT_REGION",
    "AWS_EXECUTION_ENV",
    "AWS_REGION",
    "AWS_CONTAINER_CREDENTIALS_RELATIVE_URI",
    "ECS_CONTAINER_METADATA_URI",
    "S3_BUCKET",
    "USER",
    "KMS_HOME",
    "KMS_SHARED",
]

c.JupyterHub.hub_ip = "0.0.0.0"
c.JupyterHub.port = 8000

c.JupyterHub.ssl_key = "/etc/jupyterhub/conf/key.pem"
c.JupyterHub.ssl_cert = "/etc/jupyterhub/conf/cert.pem"

c.JupyterHub.services = [
    {
        "name": "idle-culler",
        "admin": True,
        "command": [sys.executable, "-m", "jupyterhub_idle_culler", "--timeout=3600"],
    }
]

c.JupyterHub.authenticate_prometheus = False

# https://cognito-idp.eu-west-2.amazonaws.com/${user_pool_id}/.well-known/openid-configuration
if os.environ.get("COGNITO_ENABLED"):
    from oauthenticator.awscognito import AWSCognitoAuthenticator

    c.JupyterHub.authenticator_class = (
        "oauthenticator.awscognito.AWSCognitoAuthenticator"
    )
    c.AWSCognitoAuthenticator.client_id = os.environ.get("COGNITO_CLIENT_ID")
    c.AWSCognitoAuthenticator.client_secret = os.environ.get("COGNITO_CLIENT_SECRET")
    c.AWSCognitoAuthenticator.oauth_callback_url = os.environ.get(
        "COGNITO_OAUTH_CALLBACK_URL"
    )
    c.AWSCognitoAuthenticator.oauth_logout_redirect_url = os.environ.get(
        "COGNITO_OAUTH_LOGOUT_CALLBACK_URL"
    )
    c.AWSCognitoAuthenticator.username_key = "username"
else:
    c.JupyterHub.authenticator_class = "passthroughauth.auth.PassThroughAuthenticator"
    c.PassThroughAuthenticator.guest_user = os.environ.get("USER")
    c.Authenticator.auto_login = True

"""HACK: consume HTTPS_PROXY and NO_PROXY environment variables so Hub can connect to external services.
https://github.com/jupyterhub/oauthenticator/issues/217"""
HTTPRequest._DEFAULTS["prepare_curl_callback"] = configure_proxy

"""Disable SSL verification for livy requests"""
HTTPRequest._DEFAULTS["validate_cert"] = False
