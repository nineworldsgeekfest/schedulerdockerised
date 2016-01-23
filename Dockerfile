FROM debian:8

# set up basic environment
RUN apt-get update && apt-get install -y \
	curl \
	git \
	libpq-dev \
	libqt4-dev \
	libqtwebkit4 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
	curl -sSL https://get.rvm.io | bash -s stable --ruby && \
	echo 'source /etc/profile.d/rvm.sh' >> /etc/profile && \
	/bin/bash -l -c "rvm requirements;" 

# Start setting up our dev environment
RUN mkdir -p /app
WORKDIR /app

ENV PATH /usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

COPY scheduler/.ruby-version /app/.ruby-version
COPY scheduler/.ruby-gemset /app/.ruby-gemset
COPY scheduler/Gemfile /app/Gemfile
COPY scheduler/Gemfile.lock /app/Gemfile.lock

RUN [ "/bin/bash" , "-l" , "-c" , "source /etc/profile && rvm use ruby-2.2.1@scheduler && rvm install $(cat .ruby-version) && rvm use --default $(cat .ruby-version) && rvm gemset use $(cat .ruby-gemset) && gem install bundler && bundle install" ]

CMD ["/bin/bash" , "-l" , "-c" , "source /etc/profile && rvm use ruby-2.2.1@scheduler && bundler exec rake spec"]
