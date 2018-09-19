FROM ruby:2.3.3-alpine

ENV BUILD_PACKAGES bash ca-certificates git mariadb-dev nodejs tzdata
ENV BUILD_AND_DEL_PACKAGES build-base curl-dev linux-headers ruby-dev wget

# Env
ENV INSTALL_PATH /app
ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    GEM_HOME=/usr/local/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
ENV USER docker
ENV PHANTOMJS_VERSION 2.1.1

RUN addgroup -g 2000 $USER && \
    adduser -D -h $INSTALL_PATH -u 1000 -G $USER $USER

WORKDIR $INSTALL_PATH

# Bundle install
COPY Gemfile Gemfile.lock ./
RUN apk add --no-cache $BUILD_PACKAGES $BUILD_AND_DEL_PACKAGES \
  && bundle config --local github.https true \
  && wget --no-check-certificate -q -O - https://cnpmjs.org/mirrors/phantomjs/phantomjs-$PHANTOMJS_VERSION-linux-x86_64.tar.bz2 | tar xjC /tmp \
  && ln -s /tmp/phantomjs-$PHANTOMJS_VERSION-linux-x86_64/bin/phantomjs /usr/bin/phantomjs \
  && wget --no-check-certificate -q -O - https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh > /tmp/wait-for-it.sh \
  && chmod a+x /tmp/wait-for-it.sh \
  && gem install bundler && bundle install --deployment --jobs 20 --retry 5 \
  && apk del $BUILD_AND_DEL_PACKAGES

RUN chown -R docker:docker $BUNDLE_PATH \
    && chown -R docker:docker /usr/bin/phantomjs /tmp/wait-for-it.sh
USER $USER

COPY --chown=docker:docker . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
