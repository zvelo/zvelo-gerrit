FROM java
MAINTAINER Joshua Rubin <jrubin@zvelo.com>
ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre
ENV GERRIT_VERSION 2.10
ENV GERRIT_USER gerrit2
ENV GERRIT_HOME /opt/gerrit
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install gitweb --no-install-recommends \
  && useradd --system --home-dir ${GERRIT_HOME} ${GERRIT_USER} \
  && mkdir -p ${GERRIT_HOME}/bin \
  && mkdir -p ${GERRIT_HOME}/lib \
  && mkdir -p ${GERRIT_HOME}/plugins \
  && curl -fsSL https://gerrit-releases.storage.googleapis.com/gerrit-${GERRIT_VERSION}.war -o ${GERRIT_HOME}/bin/gerrit.war \
  && curl -fsSL https://ci.gerritforge.com/job/Plugin_github_stable-${GERRIT_VERSION}/lastStableBuild/artifact/github-oauth/target/github-oauth-${GERRIT_VERSION}-SNAPSHOT.jar -o ${GERRIT_HOME}/lib/github-oauth.jar \
  && curl -fsSL https://ci.gerritforge.com/job/Plugin_github_stable-${GERRIT_VERSION}/lastStableBuild/artifact/github-plugin/target/github-plugin-${GERRIT_VERSION}-SNAPSHOT.jar -o ${GERRIT_HOME}/plugins/github-plugin.jar \
  && curl -fsSL https://ci.gerritforge.com/job/Plugin_gravatar_master/lastStableBuild/artifact/gravatar.jar -o ${GERRIT_HOME}/plugins/gravatar.jar \
  && curl -fsSL https://ci.gerritforge.com/job/Plugin_delete-project_master/lastStableBuild/artifact/delete-project.jar -o ${GERRIT_HOME}/plugins/delete-project.jar \
  && java -jar ${GERRIT_HOME}/bin/gerrit.war init --batch --install-plugin singleusergroup -d ${GERRIT_HOME} \
  && java -jar ${GERRIT_HOME}/bin/gerrit.war init --batch -d ${GERRIT_HOME} \
  && chown -R ${GERRIT_USER}:${GERRIT_USER} ${GERRIT_HOME}
ADD start.sh ${GERRIT_HOME}/bin/start.sh
WORKDIR ${GERRIT_HOME}
USER ${GERRIT_USER}
EXPOSE 8005 29418
ENTRYPOINT ["/opt/gerrit/bin/start.sh", "start"]
