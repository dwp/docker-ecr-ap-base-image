#!/usr/bin/env bash
## Script to generate SSL certificates and then start jupyterhub

/usr/bin/openssl req -x509 -newkey rsa:4096 -keyout /etc/jupyterhub/conf/key.pem -out /etc/jupyterhub/conf/cert.pem -days 30 -nodes -subj '/CN=jupyter'

echo "Adding ${USER}"
if [ -d /mnt/s3fs/s3-home ]
then
    adduser --no-create-home --home "/home/${USER}" -D --uid 1001 -s /bin/bash ${USER}
    ln -s /mnt/s3fs/s3-home /home/${USER}
    cp -rf /etc/skel/. /home/${USER}
    chown -R "${USER}:${USER}" /home/${USER}
else
    adduser --home "/home/${USER}" -D --uid 1001 -s /bin/bash ${USER}
fi
sed -i "s/USERNAME_TO_REPLACE/${USER}/g" /home/${USER}/.sparkmagic/config.json
sed -i "s#EMR_URL_TO_REPLACE#${EMR_URL}#g" /home/${USER}/.sparkmagic/config.json
sed -i "s/LIVY_SESSION_STARTUP_TIMEOUT_SECONDS_TO_REPLACE/${LIVY_SESSION_STARTUP_TIMEOUT_SECONDS:-120}/g" /home/${USER}/.sparkmagic/config.json
sed -i "s/JWT_TOKEN_TO_REPLACE/${JWT_TOKEN}/g" /home/${USER}/.sparkmagic/config.json


crontab -l > /tmp/crontab
echo "${PUSH_CRON:-* * * * 2099} curl -s https://localhost:8000/hub/metrics -k | curl -s -k --data-binary @- https://${PUSH_HOST:-localhost}:${PUSH_PORT:-9091}/metrics/job/jupyterhub/instance/${USER}" >> /tmp/crontab
crontab /tmp/crontab
rm /tmp/crontab

mkdir /git
chmod 755 /git
chown -R "${USER}:${USER}" /git

if [ "${GITHUB_URL}" != "" ]
then
    if [ "${HTTPS_PROXY}" != "" ]
    then
      echo -n | /usr/bin/openssl s_client -connect ${GITHUB_URL}:443 -proxy ${HTTPS_PROXY} | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/git_cert.pem
    else
      echo -n | /usr/bin/openssl s_client -connect ${GITHUB_URL}:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/git_cert.pem
    fi
    git config --system http.sslCAInfo /tmp/git_cert.pem
fi

# Tells git branch, git switch and git checkout to set up new branches so that git-pull will
# appropriately merge from the starting point branch.
git config --system branch.autoSetupMerge always

# When pushing, don't ask for upstream branch - just push to the remote branch with the same name.
# Creates remote branch if it doesn't exist
git config --system push.default current

/usr/sbin/crond -f -l 8 &
jupyterhub $@
