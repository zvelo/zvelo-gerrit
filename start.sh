#!/bin/bash

git config -f ${GERRIT_HOME}/etc/gerrit.config gerrit.basePath    volume/git
git config -f ${GERRIT_HOME}/etc/gerrit.config cache.directory    volume/cache
git config -f ${GERRIT_HOME}/etc/gerrit.config container.user     gerrit2
git config -f ${GERRIT_HOME}/etc/gerrit.config container.javaHome ${JAVA_HOME}
git config -f ${GERRIT_HOME}/etc/gerrit.config auth.type          ${AUTH_TYPE}
git config -f ${GERRIT_HOME}/etc/gerrit.config database.type      ${DATABASE_TYPE}
git config -f ${GERRIT_HOME}/etc/gerrit.config database.database  ${DATABASE_NAME}
git config -f ${GERRIT_HOME}/etc/gerrit.config httpd.listenUrl    ${HTTP_LISTEN_URL}

if [ -n "${PUBLIC_URL}" ]; then
  git config -f ${GERRIT_HOME}/etc/gerrit.config gerrit.canonicalWebUrl ${PUBLIC_URL}
fi

if [ -n "${DATABASE_USERNAME}" ]; then
  git config -f ${GERRIT_HOME}/etc/gerrit.config database.username ${DATABASE_USERNAME}
fi

if [ -n "${DATABASE_HOSTNAME}" ]; then
  git config -f ${GERRIT_HOME}/etc/gerrit.config database.hostname ${DATABASE_HOSTNAME}
fi

if [ -n "${DATABASE_PASSWORD}" ]; then
  git config -f ${GERRIT_HOME}/etc/secure.config database.password ${DATABASE_PASSWORD}
  chmod 600 ${GERRIT_HOME}/etc/secure.config
fi

if [ "${AUTH_TYPE}" = "HTTP" -a -n "${GITHUB_CLIENT_ID}" -a -n "${GITHUB_CLIENT_SECRET}" ]; then
  git config -f ${GERRIT_HOME}/etc/gerrit.config auth.loginText       'GitHub Sign-in'
  git config -f ${GERRIT_HOME}/etc/gerrit.config auth.loginUrl        /login
  git config -f ${GERRIT_HOME}/etc/gerrit.config auth.registerPageUrl /plugins/github-plugin/static/account.html
  git config -f ${GERRIT_HOME}/etc/gerrit.config auth.gitBasicAuth    true
  git config -f ${GERRIT_HOME}/etc/gerrit.config auth.httpHeader      GITHUB_USER
  git config -f ${GERRIT_HOME}/etc/gerrit.config auth.httpEmailHeader GITHUB_EMAIL
  git config -f ${GERRIT_HOME}/etc/gerrit.config httpd.filterClass    com.googlesource.gerrit.plugins.github.oauth.OAuthFilter
  git config -f ${GERRIT_HOME}/etc/gerrit.config github.scopes        USER,REPO
  git config -f ${GERRIT_HOME}/etc/gerrit.config github.clientId      ${GITHUB_CLIENT_ID}
  git config -f ${GERRIT_HOME}/etc/secure.config github.clientSecret  ${GITHUB_CLIENT_SECRET}

  chmod 600 ${GERRIT_HOME}/etc/secure.config
fi

case "$1" in
  init)
    java -jar ${GERRIT_HOME}/bin/gerrit.war init --batch -d ${GERRIT_HOME}
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}
    ;;
  reindex)
    java -jar ${GERRIT_HOME}/bin/gerrit.war reindex -d ${GERRIT_HOME}
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}
    ;;
  *)
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}
    su -c "${GERRIT_HOME}/bin/gerrit.sh $1" ${GERRIT_USER}
    if [ $? -eq 0 ]; then
      tail -n 0 -f ${GERRIT_HOME}/logs/error_log | grep -v '\ INFO\ ' 1>&2
    else
      cat ${GERRIT_HOME}/logs/error_log 1>&2
    fi
    ;;
esac
