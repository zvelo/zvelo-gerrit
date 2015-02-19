#!/bin/bash

usage() {
    me=`basename "$0"`
    echo >&2 "Usage: $me {configure|init|reindex|start}"
    exit 1
}

configure() {
  git config -f ${GERRIT_HOME}/etc/gerrit.config gerrit.basePath    "volume/git"
  git config -f ${GERRIT_HOME}/etc/gerrit.config cache.directory    "volume/cache"
  git config -f ${GERRIT_HOME}/etc/gerrit.config container.user     "gerrit2"
  git config -f ${GERRIT_HOME}/etc/gerrit.config container.javaHome "${JAVA_HOME}"

  if [ -n "${REGISTER_EMAIL_PRIVATE_KEY}" ]; then
    git config -f ${GERRIT_HOME}/etc/secure.config auth.registerEmailPrivateKey "${REGISTER_EMAIL_PRIVATE_KEY}"
    chmod 600 ${GERRIT_HOME}/etc/secure.config
  fi

  if [ -n "${REST_TOKEN_PRIVATE_KEY}" ]; then
    git config -f ${GERRIT_HOME}/etc/secure.config auth.restTokenPrivateKey "${REST_TOKEN_PRIVATE_KEY}"
    chmod 600 ${GERRIT_HOME}/etc/secure.config
  fi

  if [ -n "${AUTH_TYPE}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config auth.type "${AUTH_TYPE}"
  fi

  if [ -n "${HTTP_LISTEN_URL}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config httpd.listenUrl "${HTTP_LISTEN_URL}"
  fi

  if [ -n "${SMTP_FROM}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config sendemail.from "${SMTP_FROM}"
  fi

  if [ -n "${SMTP_SERVER}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config sendemail.smtpServer "${SMTP_SERVER}"
  fi

  if [ -n "${SMTP_PORT}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config sendemail.smtpServerPort "${SMTP_PORT}"
  fi

  if [ -n "${SMTP_ENCRYPTION}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config sendemail.smtpEncryption "${SMTP_ENCRYPTION}"
  fi

  if [ -n "${SMTP_USER}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config sendemail.smtpUser "${SMTP_USER}"
  fi

  if [ -n "${SMTP_PASS}" ]; then
    git config -f ${GERRIT_HOME}/etc/secure.config sendemail.smtpPass "${SMTP_PASS}"
    chmod 600 ${GERRIT_HOME}/etc/secure.config
  fi

  if [ -n "${PUBLIC_URL}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config gerrit.canonicalWebUrl "${PUBLIC_URL}"
  fi

  if [ -n "${DATABASE_TYPE}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config database.type "${DATABASE_TYPE}"
  fi

  if [ -n "${DATABASE_NAME}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config database.database "${DATABASE_NAME}"
  fi

  if [ -n "${DATABASE_USERNAME}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config database.username "${DATABASE_USERNAME}"
  fi

  if [ -n "${DATABASE_HOSTNAME}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config database.hostname "${DATABASE_HOSTNAME}"
  fi

  if [ -n "${DATABASE_PASSWORD}" ]; then
    git config -f ${GERRIT_HOME}/etc/secure.config database.password "${DATABASE_PASSWORD}"
    chmod 600 ${GERRIT_HOME}/etc/secure.config
  fi

  if [ -n "${THEME_BACKGROUND}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.backgroundColor ${THEME_BACKGROUND}
  fi

  if [ -n "${THEME_TOP_MENU}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.topMenuColor ${THEME_TOP_MENU}
  fi

  if [ -n "${THEME_TEXT}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.textColor ${THEME_TEXT}
  fi

  if [ -n "${THEME_TRIM}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.trimColor ${THEME_TRIM}
  fi

  if [ -n "${THEME_SELECTION}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.selectionColor ${THEME_SELECTION}
  fi

  if [ -n "${THEME_CHANGE_TABLE_OUTDATED}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.changeTableOutdatedColor ${THEME_CHANGE_TABLE_OUTDATED}
  fi

  if [ -n "${THEME_TABLE_ODD_ROW}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.tableOddRowColor ${THEME_TABLE_ODD_ROW}
  fi

  if [ -n "${THEME_TABLE_EVEN_ROW}" ]; then
    git config -f ${GERRIT_HOME}/etc/gerrit.config theme.tableEvenRowColor ${THEME_TABLE_EVEN_ROW}
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
    git config -f ${GERRIT_HOME}/etc/gerrit.config github.clientId      "${GITHUB_CLIENT_ID}"
    git config -f ${GERRIT_HOME}/etc/secure.config github.clientSecret  "${GITHUB_CLIENT_SECRET}"

    chmod 600 ${GERRIT_HOME}/etc/secure.config
  fi

  if [ -n "${REPLICATION_ORG}" ]; then
    git config -f ${GERRIT_HOME}/etc/replication.config remote.github.url "git@github.com:${REPLICATION_ORG}/\${name}.git"
  fi

  if [ -n "${SSH_PUBLIC_KEY}" -a -n "${SSH_PRIVATE_KEY}" ]; then
    mkdir ${GERRIT_HOME}/.ssh
    echo -e "${SSH_PUBLIC_KEY}"  > ${GERRIT_HOME}/.ssh/id_rsa.pub
    echo -e "${SSH_PRIVATE_KEY}" > ${GERRIT_HOME}/.ssh/id_rsa
    chmod 700 ${GERRIT_HOME}/.ssh
    chmod 600 ${GERRIT_HOME}/.ssh/id_rsa
    echo "StrictHostKeyChecking no" > ${GERRIT_HOME}/.ssh/config
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}/.ssh
  fi
}

case "$1" in
  configure)
    configure
    git config -f ${GERRIT_HOME}/etc/gerrit.config -l
    ;;
  init|reindex)
    configure
    java -jar ${GERRIT_HOME}/bin/gerrit.war "$@" -d ${GERRIT_HOME}
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}
    ;;
  start)
    configure
    chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}
    su -c "${GERRIT_HOME}/bin/gerrit.sh $1" ${GERRIT_USER}
    if [ $? -eq 0 ]; then
      tail -n 0 -f ${GERRIT_HOME}/logs/error_log | grep -v '\ INFO\ ' 1>&2
    else
      cat ${GERRIT_HOME}/logs/error_log 1>&2
    fi
    ;;
  *)
    usage
    ;;
esac
