FROM nyulibraries/rails

COPY Gemfile Gemfile.lock ./
RUN bundle config --global github.https true
RUN gem install bundler && bundle install --jobs 20 --retry 5

COPY application.test.yml ./
RUN figsify application.test.yml

COPY . .

#RUN rake environment elasticsearch:import:model CLASS='Room' FORCE=true
#RUN rake environment elasticsearch:import:model CLASS='Reservation' FORCE=true
