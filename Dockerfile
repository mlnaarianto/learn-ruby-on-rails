FROM ruby:4.0.5

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    default-libmysqlclient-dev \
    nodejs \
    npm \
    git \
    curl \
    zip \
    unzip

# Install yarn official
RUN npm install -g yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# 🔥 FIX PERMISSION: Buat folder bundle dan berikan akses ke appuser
RUN mkdir -p /usr/local/bundle && \
    groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app /usr/local/bundle

# Pakai user non-root
USER appuser